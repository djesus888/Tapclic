<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../middleware/Auth.php';
require_once __DIR__ . '/../services/WebSocketService.php';
require_once __DIR__ . '/../utils/Uploader.php';

use services\WebSocketService;
use Utils\Uploader;

class BillingController
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

    /* ========== GENERAR FACTURACIÓN (ADMIN) ========== */

    // POST /api/admin/billing/generate
    public function generateBilling(): void
    {
        $this->requireAdmin();

        $input = json_decode(file_get_contents('php://input'), true);
        $period = $input['period'] ?? 'monthly'; // monthly, biweekly

        if ($period === 'biweekly') {
            $start = date('Y-m-d', strtotime('-15 days'));
            $end = date('Y-m-d');
            $nextStart = date('Y-m-d', strtotime('+1 day'));
            $nextEnd = date('Y-m-d', strtotime('+15 days'));
        } else {
            $start = date('Y-m-01');
            $end = date('Y-m-t');
            $nextStart = date('Y-m-01', strtotime('+1 month'));
            $nextEnd = date('Y-m-t', strtotime('+1 month'));
        }

        // Obtener todas las transacciones completadas en el período
        $stmt = $this->conn->prepare("
            SELECT 
                sr.provider_id,
                COUNT(DISTINCT sr.id) as total_transactions,
                COUNT(DISTINCT s.id) as total_services,
                COALESCE(SUM(s.price), 0) as total_amount,
                COALESCE(SUM(CASE WHEN pe.type = 'transaction_commission' THEN pe.amount ELSE 0 END), 0) as total_commission
            FROM service_requests sr
            JOIN services s ON s.id = sr.service_id
            JOIN payments p ON p.service_request_id = sr.id
            LEFT JOIN platform_earnings pe ON pe.reference_id = sr.id AND pe.type = 'transaction_commission'
            WHERE p.status = 'paid'
            AND p.created_at BETWEEN ? AND ?
            AND sr.status = 'completed'
            GROUP BY sr.provider_id
            HAVING total_commission > 0
        ");
        $stmt->execute([$start . ' 00:00:00', $end . ' 23:59:59']);
        $providers = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $generated = 0;
        $notified = 0;

        foreach ($providers as $provider) {
            // Verificar si ya existe factura para este período
            $check = $this->conn->prepare("
                SELECT id FROM provider_billing 
                WHERE provider_id = ? AND period_start = ? AND period_end = ?
            ");
            $check->execute([$provider['provider_id'], $start, $end]);

            if ($check->fetch()) continue; // Ya existe

            // Crear factura
            $stmt = $this->conn->prepare("
                INSERT INTO provider_billing 
                (provider_id, period_start, period_end, total_commission, total_services, total_transactions, status)
                VALUES (?, ?, ?, ?, ?, ?, 'pending')
            ");
            $stmt->execute([
                $provider['provider_id'],
                $start,
                $end,
                $provider['total_commission'],
                $provider['total_services'],
                $provider['total_transactions']
            ]);
            $generated++;

            // Notificar al proveedor
            $this->notifyProviderBilling(
                $provider['provider_id'],
                $start,
                $end,
                $provider['total_commission']
            );
            $notified++;
        }

        echo json_encode([
            'success' => true,
            'message' => "Facturación generada: {$generated} facturas, {$notified} proveedores notificados",
            'period' => ['start' => $start, 'end' => $end],
            'next_period' => ['start' => $nextStart, 'end' => $nextEnd]
        ]);
    }

    /* ========== VER FACTURAS (PROVEEDOR) ========== */

    // GET /api/provider/billing
    public function getMyBilling(): void
    {
        $this->requireAuth();

        $stmt = $this->conn->prepare("
            SELECT * FROM provider_billing
            WHERE provider_id = ?
            ORDER BY period_end DESC
            LIMIT 24
        ");
        $stmt->execute([$this->user->id]);
        $bills = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // Estadísticas
        $stmt = $this->conn->prepare("
            SELECT 
                COALESCE(SUM(CASE WHEN status = 'pending' THEN total_commission END), 0) as pending,
                COALESCE(SUM(CASE WHEN status = 'paid' THEN total_commission END), 0) as paid,
                COALESCE(SUM(CASE WHEN status = 'overdue' THEN total_commission END), 0) as overdue
            FROM provider_billing
            WHERE provider_id = ?
        ");
        $stmt->execute([$this->user->id]);
        $stats = $stmt->fetch(PDO::FETCH_ASSOC);

        echo json_encode([
            'success' => true,
            'bills' => $bills,
            'stats' => [
                'pending' => (float)$stats['pending'],
                'paid' => (float)$stats['paid'],
                'overdue' => (float)$stats['overdue']
            ]
        ]);
    }

    /* ========== REPORTAR PAGO (PROVEEDOR) ========== */

    // POST /api/provider/billing/{id}/pay
   public function payBill(int $billId): void
    {
        $this->requireAuth();

        $stmt = $this->conn->prepare("
            SELECT * FROM provider_billing WHERE id = ? AND provider_id = ?
        ");
        $stmt->execute([$billId, $this->user->id]);
        $bill = $stmt->fetch();

        if (!$bill) {
            http_response_code(404);
            echo json_encode(['error' => 'Factura no encontrada']);
            return;
        }

        if (in_array($bill['status'], ['paid', 'cancelled'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Esta factura ya está ' . ($bill['status'] === 'paid' ? 'pagada' : 'cancelada')]);
            return;
        }

        $method = $_POST['payment_method'] ?? 'transferencia';
        $reference = $_POST['reference'] ?? '';
        $proofUrl = null;

        if (isset($_FILES['payment_proof']) && $_FILES['payment_proof']['error'] === UPLOAD_ERR_OK) {
            try {
                $proofUrl = $this->uploader->saveFile(
                    $_FILES['payment_proof'],
                    Uploader::CAT_BILLING
                );
            } catch (\RuntimeException $e) {
                error_log("Error subiendo comprobante billing: " . $e->getMessage());
            }
        }

        $stmt = $this->conn->prepare("
            UPDATE provider_billing SET
                status = 'verifying',
                paid_at = NOW(),
                payment_method = ?,
                payment_reference = ?,
                payment_proof = ?
            WHERE id = ?
        ");
        $stmt->execute([$method, $reference, $proofUrl, $billId]);

        // Notificar al admin
        $this->notifyAdminPayment($this->user->id, $bill['total_commission'], $billId);

        echo json_encode([
            'success' => true,
            'message' => 'Pago reportado exitosamente. Un administrador verificará tu comprobante.'
        ]);
    }

    /* ========== VER TODAS LAS FACTURAS (ADMIN) ========== */

    // GET /api/admin/billing
    public function getAllBilling(): void
    {
        $this->requireAdmin();

        $status = $_GET['status'] ?? '';
        $page = max(1, (int)($_GET['page'] ?? 1));
        $limit = 20;
        $offset = ($page - 1) * $limit;

        $where = '';
        $params = [];

        if ($status) {
            $where = "WHERE pb.status = ?";
            $params[] = $status;
        }

        $stmt = $this->conn->prepare("
            SELECT COUNT(*) FROM provider_billing pb $where
        ");
        $stmt->execute($params);
        $total = $stmt->fetchColumn();

        $stmt = $this->conn->prepare("
            SELECT pb.*, u.name as provider_name, u.email as provider_email, u.phone
            FROM provider_billing pb
            JOIN users u ON u.id = pb.provider_id
            $where
            ORDER BY pb.period_end DESC
            LIMIT $limit OFFSET $offset
        ");
        $stmt->execute($params);
        $bills = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode([
            'success' => true,
            'bills' => $bills,
            'pagination' => [
                'current_page' => $page,
                'last_page' => ceil($total / $limit),
                'total' => $total
            ]
        ]);
    }

    /* ========== VERIFICAR PAGO (ADMIN) ========== */

    // POST /api/admin/billing/{id}/verify
    public function verifyPayment(int $billId): void
    {
        $this->requireAdmin();

        $input = json_decode(file_get_contents('php://input'), true);
        $action = $input['action'] ?? 'approve'; // approve o reject

        $stmt = $this->conn->prepare("
            SELECT pb.*, u.name, u.email
            FROM provider_billing pb
            JOIN users u ON u.id = pb.provider_id
            WHERE pb.id = ?
        ");
        $stmt->execute([$billId]);
        $bill = $stmt->fetch();

        if (!$bill) {
            http_response_code(404);
            echo json_encode(['error' => 'Factura no encontrada']);
            return;
        }

        if ($action === 'approve') {
            $stmt = $this->conn->prepare("UPDATE provider_billing SET status = 'paid', paid_at = NOW() WHERE id = ?");
            $stmt->execute([$billId]);

            $this->sendNotification(
                $bill['provider_id'],
                '✅ Pago verificado',
                "Tu pago de \${$bill['total_commission']} del período {$bill['period_start']} - {$bill['period_end']} ha sido verificado."
            );
        } else {
            $stmt = $this->conn->prepare("UPDATE provider_billing SET status = 'pending', payment_proof = NULL, payment_reference = NULL WHERE id = ?");
            $stmt->execute([$billId]);

            $this->sendNotification(
                $bill['provider_id'],
                '❌ Pago rechazado',
                "Tu comprobante de pago fue rechazado. Por favor sube uno nuevo."
            );
        }

        echo json_encode(['success' => true, 'message' => $action === 'approve' ? 'Pago aprobado' : 'Comprobante rechazado']);
    }

    /* ========== BLOQUEAR / DESBLOQUEAR PROVEEDOR (ADMIN) ========== */

    // POST /api/admin/billing/block/{providerId}
    public function toggleBlock(int $providerId): void
    {
        $this->requireAdmin();

        $stmt = $this->conn->prepare("SELECT active FROM users WHERE id = ? AND role = 'provider'");
        $stmt->execute([$providerId]);
        $provider = $stmt->fetch();

        if (!$provider) {
            http_response_code(404);
            echo json_encode(['error' => 'Proveedor no encontrado']);
            return;
        }

        $newStatus = $provider['active'] ? 0 : 1;
        $stmt = $this->conn->prepare("UPDATE users SET active = ? WHERE id = ?");
        $stmt->execute([$newStatus, $providerId]);

        $action = $newStatus ? 'desbloqueado' : 'bloqueado';
        $this->sendNotification(
            $providerId,
            $newStatus ? '🔓 Cuenta desbloqueada' : '🚫 Cuenta bloqueada',
            $newStatus ? 'Tu cuenta ha sido desbloqueada. Ya puedes seguir operando.' : 'Tu cuenta ha sido bloqueada por falta de pago. Regulariza tu situación para continuar.'
        );

        echo json_encode(['success' => true, 'message' => "Proveedor {$action}"]);
    }

    /* ========== HELPER ========== */

    private function notifyProviderBilling(int $providerId, string $start, string $end, float $amount): void
    {
        $title = '💰 Nueva factura generada';
        $message = "Se ha generado tu factura del período {$start} - {$end} por \${$amount}. Debes pagarla antes del vencimiento.";

        // Guardar notificación en BD
        $stmt = $this->conn->prepare("
            INSERT INTO notifications (user_id, title, message, type, is_admin, created_at)
            VALUES (?, ?, ?, 'billing', 0, NOW())
        ");
        $stmt->execute([$providerId, $title, $message]);

        // WebSocket
        WebSocketService::sendNotification('provider', $providerId, $title, $message, [
            'notification_type' => 'billing',
            'url' => '/dashboard/provider',
            'action' => 'view_billing'
        ]);
    }

    private function notifyAdminPayment(int $providerId, float $amount, int $billId): void
    {
        $stmt = $this->conn->prepare("SELECT name FROM users WHERE id = ?");
        $stmt->execute([$providerId]);
        $provider = $stmt->fetch();

        $title = '💳 Nuevo comprobante de pago';
        $message = "{$provider['name']} reportó un pago de \${$amount}. Verifica el comprobante.";

        $stmt = $this->conn->prepare("
            INSERT INTO notifications (user_id, title, message, type, is_admin, created_at)
            SELECT id, ?, ?, 'billing_payment', 1, NOW() FROM users WHERE role = 'admin'
        ");
        $stmt->execute([$title, $message]);

        WebSocketService::emitToRole('admin', 'new-billing-payment', [
            'provider_id' => $providerId,
            'amount' => $amount,
            'bill_id' => $billId
        ]);
    }

    private function sendNotification(int $userId, string $title, string $message): void
    {
        $stmt = $this->conn->prepare("
            INSERT INTO notifications (user_id, title, message, type, is_admin, created_at)
            VALUES (?, ?, ?, 'system', 0, NOW())
        ");
        $stmt->execute([$userId, $title, $message]);

        WebSocketService::sendNotification(
            'provider',
            $userId,
            $title,
            $message,
            ['notification_type' => 'system']
        );
    }
}
