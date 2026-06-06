<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../middleware/Auth.php';
require_once __DIR__ . '/../models/Service.php';
require_once __DIR__ . '/../models/ServiceRequest.php';
require_once __DIR__ . '/../utils/Uploader.php';

use Utils\Uploader;

class MonetizationController
{
    private \PDO $conn;
    private $user;
    private Uploader $uploader;

    public function __construct()
    {
        $this->conn = (new Database())->getConnection();
        $auth = Auth::verify();
        $this->user = $auth;

        $basePath = __DIR__ . '/../public/uploads';
        $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? 'https://' : 'http://';
        $baseUrl = $protocol . $_SERVER['HTTP_HOST'] . '/uploads';
        $this->uploader = new Uploader($basePath, $baseUrl);
    }

    private function requireAuth(): void
    {
        if (!$this->user) {
            http_response_code(401);
            echo json_encode(['error' => 'No autorizado']);
            exit;
        }
    }

    private function requireAdmin(): void
    {
        $this->requireAuth();
        if (($this->user->role ?? '') !== 'admin') {
            http_response_code(403);
            echo json_encode(['error' => 'Acceso denegado']);
            exit;
        }
    }

    // ✅ RENOMBRADO: de getConfig a getSystemConfig para evitar conflicto
    private function getSystemConfig(): array
    {
        $stmt = $this->conn->query("SELECT * FROM system_config WHERE id = 1");
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    /* ========== CONFIGURACIÓN (ADMIN) ========== */

    // GET /api/admin/monetization/config
    public function getConfig(): void
    {
        $this->requireAdmin();
        $config = $this->getSystemConfig();

        echo json_encode([
            'success' => true,
            'config' => [
                'monetization_model' => $config['monetization_model'],
                'commission_percentage' => (float)$config['payment_default_commission'],
                'commission_min' => (float)$config['payment_min_commission'],
                'publish_cost' => (float)$config['service_publish_cost'],
                'publish_duration_days' => (int)$config['service_publish_duration'],
                'platform_earnings' => $this->getTotalEarnings()
            ]
        ]);
    }


// GET /api/monetization/publish-cost - Público
public function getPublishCost(): void
{
    $config = $this->getSystemConfig();

    echo json_encode([
        'success' => true,
        'publish_cost' => (float)$config['service_publish_cost'],
        'wallet_enabled' => $config['wallet_enabled'] == 1
    ]);
}


    // PUT /api/admin/monetization/config
    public function updateConfig(): void
    {
        $this->requireAdmin();
        $input = json_decode(file_get_contents('php://input'), true);

        $stmt = $this->conn->prepare("
            UPDATE system_config SET
                monetization_model = :model,
                payment_default_commission = :commission,
                payment_min_commission = :min_commission,
                service_publish_cost = :publish_cost,
                service_publish_duration = :duration
            WHERE id = 1
        ");

        $stmt->execute([
            ':model' => $input['monetization_model'] ?? 'commission',
            ':commission' => $input['commission_percentage'] ?? 10,
            ':min_commission' => $input['commission_min'] ?? 1,
            ':publish_cost' => $input['publish_cost'] ?? 0,
            ':duration' => $input['publish_duration_days'] ?? 30
        ]);

        echo json_encode(['success' => true, 'message' => 'Configuración actualizada']);
    }

    /* ========== PAGO POR PUBLICAR ========== */

    // POST /api/services/{id}/publish-external - Pago con comprobante externo
    public function payToPublishExternal(int $serviceId): void
    {
        $this->requireAuth();

        $stmt = $this->conn->prepare("SELECT * FROM services WHERE id = ? AND user_id = ?");
        $stmt->execute([$serviceId, $this->user->id]);
        $service = $stmt->fetch();

        if (!$service) {
            http_response_code(404);
            echo json_encode(['error' => 'Servicio no encontrado']);
            return;
        }

        $config = $this->getSystemConfig();
        $amount = (float)$config['service_publish_cost'];

        $method = $_POST['payment_method'] ?? 'transferencia';
        $reference = $_POST['reference'] ?? '';
        $proofUrl = null;

        if (isset($_FILES['payment_proof']) && $_FILES['payment_proof']['error'] === UPLOAD_ERR_OK) {
            try {
                $proofUrl = $this->uploader->saveFile(
                    $_FILES['payment_proof'],
                    Uploader::CAT_PAYMENTS
                );
            } catch (\RuntimeException $e) {
                error_log("Error subiendo comprobante publicación: " . $e->getMessage());
            }
        }

        // Guardar comprobante
        $stmt = $this->conn->prepare("
            INSERT INTO service_payment_proofs (service_id, provider_id, amount, payment_method, reference, proof_url, status)
            VALUES (?, ?, ?, ?, ?, ?, 'pending')
        ");
        $stmt->execute([$serviceId, $this->user->id, $amount, $method, $reference, $proofUrl]);

        // Actualizar estado del servicio
        $stmt = $this->conn->prepare("UPDATE services SET status = 'pending' WHERE id = ?");
        $stmt->execute([$serviceId]);

        // Notificar al admin
        $stmt = $this->conn->prepare("SELECT name FROM users WHERE id = ?");
        $stmt->execute([$this->user->id]);
        $provider = $stmt->fetch();

        $stmt = $this->conn->prepare("
            INSERT INTO notifications (receiver_id, receiver_role, title, message, data_json, created_at)
            SELECT id, 'admin', ?, ?, ?, NOW() FROM users WHERE role = 'admin' LIMIT 1
        ");
        $stmt->execute([
            '📎 Nuevo comprobante de publicación',
            "{$provider['name']} subió comprobante para '{$service['title']}' - \${$amount}",
            json_encode(['url' => '/admin/service-payments', 'action' => 'review_payment', 'service_id' => $serviceId])
        ]);

        echo json_encode([
            'success' => true,
            'message' => 'Comprobante enviado. El administrador verificará tu pago.',
            'proof_url' => $proofUrl
        ]);
    }


/* ========== COMISIÓN POR TRANSACCIÓN ========== */

/**
 * Calcular y cobrar comisión de una transacción
 * Se llama desde PaymentController cuando se confirma un pago
 */
public static function chargeCommission(int $requestId, float $amount): array
{
    $db = (new Database())->getConnection();

    $stmt = $db->prepare("SELECT payment_default_commission, payment_min_commission, monetization_model, wallet_enabled FROM system_config WHERE id = 1");
    $stmt->execute();
    $config = $stmt->fetch();

    if (!in_array($config['monetization_model'], ['commission', 'both'])) {
        return ['charged' => false, 'commission' => 0];
    }

    $percentage = (float)$config['payment_default_commission'];
    $min = (float)$config['payment_min_commission'];
    $commission = max(($amount * $percentage / 100), $min);

    // Obtener provider_id
    $stmt = $db->prepare("SELECT provider_id, user_id FROM service_requests WHERE id = ?");
    $stmt->execute([$requestId]);
    $request = $stmt->fetch();

    if (!$request) return ['charged' => false, 'commission' => 0];

    $walletEnabled = $config['wallet_enabled'] == 1;

    // ✅ Si wallet está activada, intentar descontar
    if ($walletEnabled) {
        $stmt = $db->prepare("SELECT balance FROM wallets WHERE user_id = ? FOR UPDATE");
        $stmt->execute([$request['provider_id']]);
        $wallet = $stmt->fetch();

        if ($wallet && $wallet['balance'] >= $commission) {
            $db->beginTransaction();
            try {
                $newBalance = $wallet['balance'] - $commission;
                $stmt = $db->prepare("UPDATE wallets SET balance = ?, updated_at = NOW() WHERE user_id = ?");
                $stmt->execute([$newBalance, $request['provider_id']]);

                $stmt = $db->prepare("
                    INSERT INTO wallet_transactions (user_id, type, amount, description, reference, status, created_at)
                    VALUES (?, 'debit', ?, ?, ?, 'completed', NOW())
                ");
                $stmt->execute([
                    $request['provider_id'],
                    $commission,
                    "Comisión por solicitud #{$requestId}",
                    'COMM-' . date('Ymd') . '-' . $requestId
                ]);

                self::recordPlatformEarningStatic($db, 'transaction_commission', $commission, $requestId, $request['provider_id']);

                // ✅ Notificar al proveedor sobre la comisión
$stmt = $db->prepare("SELECT name FROM users WHERE id = ?");
$stmt->execute([$request['provider_id']]);
$provider = $stmt->fetch();

$stmt = $db->prepare("
    INSERT INTO notifications (receiver_id, receiver_role, title, message, data_json, created_at)
    VALUES (?, 'provider', ?, ?, ?, NOW())
");
$stmt->execute([
    $request['provider_id'],
    '💰 Comisión registrada',
    "Se ha registrado una comisión de \${$commission} por la solicitud #{$requestId}. Se acumulará en tu factura mensual.",
    json_encode([
        'url' => '/provider/billing',
        'action' => 'view_billing',
        'notification_type' => 'commission'
    ])
]);

// ✅ WebSocket
require_once __DIR__ . '/../services/WebSocketService.php';
\services\WebSocketService::sendNotification(
    'provider',
    $request['provider_id'],
    '💰 Comisión registrada',
    "Se ha registrado una comisión de \${$commission} por la solicitud #{$requestId}.",
    [
        'notification_type' => 'commission',
        'url' => '/provider/billing',
        'action' => 'view_billing'
    ]
);



                $db->commit();
                return ['charged' => true, 'commission' => $commission, 'method' => 'wallet'];
            } catch (\Exception $e) {
                $db->rollBack();
            }
        }
    }

    // ✅ Si wallet no está activa o no tiene saldo, acumular deuda
    $currentMonth = date('Y-m');
    $periodStart = date('Y-m-01');
    $periodEnd = date('Y-m-t');

    // Buscar si ya existe una deuda para este período
    $stmt = $db->prepare("
        SELECT id, total_commission FROM provider_billing 
        WHERE provider_id = ? AND period_start = ? AND period_end = ?
    ");
    $stmt->execute([$request['provider_id'], $periodStart, $periodEnd]);
    $billing = $stmt->fetch();

    if ($billing) {
        // Actualizar deuda existente
        $stmt = $db->prepare("
            UPDATE provider_billing 
            SET total_commission = total_commission + ?, 
                total_transactions = total_transactions + 1,
                status = 'pending'
            WHERE id = ?
        ");
        $stmt->execute([$commission, $billing['id']]);
    } else {
        // Crear nueva deuda
        $stmt = $db->prepare("
            INSERT INTO provider_billing 
            (provider_id, period_start, period_end, total_commission, total_services, total_transactions, status)
            VALUES (?, ?, ?, ?, 1, 1, 'pending')
        ");
        $stmt->execute([$request['provider_id'], $periodStart, $periodEnd, $commission]);
    }

    // Registrar ganancia de la plataforma
    self::recordPlatformEarningStatic($db, 'transaction_commission', $commission, $requestId, $request['provider_id']);

    return ['charged' => true, 'commission' => $commission, 'method' => 'billing'];
}

    /* ========== GANANCIAS DE LA PLATAFORMA ========== */

    private function recordPlatformEarning(string $type, float $amount, int $referenceId, int $userId): void
    {
        $stmt = $this->conn->prepare("
            INSERT INTO platform_earnings (type, amount, reference_id, user_id, created_at)
            VALUES (?, ?, ?, ?, NOW())
        ");
        $stmt->execute([$type, $amount, $referenceId, $userId]);
    }

    private static function recordPlatformEarningStatic(\PDO $db, string $type, float $amount, int $referenceId, int $userId): void
    {
        $stmt = $db->prepare("
            INSERT INTO platform_earnings (type, amount, reference_id, user_id, created_at)
            VALUES (?, ?, ?, ?, NOW())
        ");
        $stmt->execute([$type, $amount, $referenceId, $userId]);
    }

    private function getTotalEarnings(): array
    {
        $stmt = $this->conn->query("
            SELECT
                COALESCE(SUM(amount), 0) as total,
                COALESCE(SUM(CASE WHEN type = 'transaction_commission' THEN amount END), 0) as commissions,
                COALESCE(SUM(CASE WHEN type = 'service_publish' THEN amount END), 0) as publications
            FROM platform_earnings
        ");
        $earnings = $stmt->fetch();

        $stmt = $this->conn->query("
            SELECT COALESCE(SUM(amount), 0) as total
            FROM platform_earnings
            WHERE created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
        ");
        $monthly = $stmt->fetch();

        return [
            'total' => (float)$earnings['total'],
            'commissions' => (float)$earnings['commissions'],
            'publications' => (float)$earnings['publications'],
            'this_month' => (float)$monthly['total']
        ];
    }


    public function getEarnings(): void
    {
        $this->requireAdmin();

        $earnings = $this->getTotalEarnings();

        $stmt = $this->conn->query("
            SELECT pe.*, u.name as user_name, u.email
            FROM platform_earnings pe
            LEFT JOIN users u ON u.id = pe.user_id
            ORDER BY pe.created_at DESC
            LIMIT 100
        ");
        $history = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode([
            'success' => true,
            'summary' => $earnings,
            'history' => $history
        ]);
    }
}
