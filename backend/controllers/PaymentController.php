<?php

require_once __DIR__ . "/../middleware/Auth.php";
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../models/Payments.php';
require_once __DIR__ . '/../models/ServiceRequest.php';
require_once __DIR__ . '/../utils/jwt.php';
require_once __DIR__ . '/../utils/AuditLogger.php';
require_once __DIR__ . '/../utils/Uploader.php';
require_once __DIR__ . '/../services/WebSocketService.php';

use services\WebSocketService;
use Utils\Uploader;

class PaymentController
{
    private $conn;
    private string $table = 'payments';
    private Uploader $uploader;

    public function __construct()
    {
        $this->conn = (new Database())->getConnection();

        $basePath = __DIR__ . '/../public/uploads';
        $protocol = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
        $baseUrl  = $protocol . '://' . $_SERVER['HTTP_HOST'] . '/uploads';
        $this->uploader = new Uploader($basePath, $baseUrl);
    }

    private function saveProof(int $requestId, array $file): ?string
    {
        try {
            return $this->uploader->saveFile($file, Uploader::CAT_PAYMENTS);
        } catch (\RuntimeException $e) {
            error_log('Error guardando comprobante: ' . $e->getMessage());
            return null;
        }
    }

    private function unauthorized(): void
    {
        http_response_code(401);
        echo json_encode(['error' => 'No autorizado']);
    }

    private function badRequest(): void
    {
        http_response_code(400);
        echo json_encode(['error' => 'Faltan parámetros']);
    }

    public function handle($method)
    {
        $auth = Auth::verify();
        if (!$auth) return $this->unauthorized();

        $path = $_SERVER['REQUEST_URI'];

        if (preg_match('/\/api\/payments\/create/', $path) && $method === 'POST') {
            $this->createPayment($auth);
        } elseif (preg_match('/\/api\/payments\/mine/', $path) && $method === 'GET') {
            $this->getMyPayments($auth);
        } elseif (preg_match('/\/api\/payments\/public/', $path) && $method === 'GET') {
            $providerId = $_GET['provider_id'] ?? null;
            if (!$providerId) return $this->badRequest();
            $this->getPublicMethods((int)$providerId);
        } elseif (preg_match('/\/api\/payments\/confirm-payment/', $path) && $method === 'POST') {
            $this->confirmPayment($auth);
        } elseif (preg_match('/\/api\/payments\/reject-payment/', $path) && $method === 'POST') {
            $this->rejectPayment($auth);
        } elseif (preg_match('/\/api\/payments\/proof/', $path) && $method === 'GET') {
            $this->getProof($auth);
        } else {
            echo json_encode(['error' => 'Ruta no válida']);
        }
    }

    private function createPayment(object $auth): void
    {
        $requestId = $_POST['request_id'] ?? null;
        $method = $_POST['payment_method'] ?? null;
        $reference = $_POST['reference'] ?? null;

        $proofUrl = null;
        if (isset($_FILES['proof_file']) && $_FILES['proof_file']['error'] === UPLOAD_ERR_OK) {
            $proofUrl = $this->saveProof((int)$requestId, $_FILES['proof_file']);
        }

        if (!$requestId || !$method) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Faltan datos']);
            return;
        }

        $req = (new ServiceRequest())->getById((int)$requestId);
        if (!$req || $req['user_id'] != $auth->id) {
            http_response_code(403);
            echo json_encode(['success' => false, 'message' => 'Request no encontrada o no es tuya']);
            return;
        }

        try {
            $paymentId = (new Payment())->create((int)$requestId, $method, $reference, $proofUrl, $auth->id);


           // ✅ Mapear método de pago a gateway_name
$gatewayMap = [
    'pago-movil' => 'mobile_payment',
    'transferencia' => 'bank_transfer', 
    'zelle' => 'zelle',
    'paypal' => 'paypal',
    'efectivo' => 'cash'
];
$gatewayName = $gatewayMap[$method] ?? 'cash';

$stmt = $this->conn->prepare("UPDATE payments SET gateway_name = ? WHERE id = ?");
$stmt->execute([$gatewayName, $paymentId]);

        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
            return;
        }

        // ✅ LOG
        AuditLogger::log($auth->id, 'payment_created', 'Pago registrado', "Solicitud ID: {$requestId} - Método: {$method} - Pago ID: {$paymentId}");

        $request = (new ServiceRequest())->getById((int)$requestId);

        $notif = [
            'sender_id' => $auth->id,
            'receiver_id' => $request['provider_id'],
            'receiver_role' => 'provider',
            'title' => 'Pago registrado',
            'message' => $method === 'efectivo'
                ? 'El cliente pagará en efectivo'
                : 'Cliente subió comprobante – verifica el pago',
            'data_json' => json_encode([
                'type' => 'payment',
                'notification_type' => 'payment_received',
                'url' => '/dashboard/provider',
                'action' => 'verify_payment',
                'request_id' => (int)$requestId,
                'payment_id' => $paymentId
            ])
        ];
        (new ServiceRequest())->saveNotification($notif);

        WebSocketService::sendNotification(
            'provider',
            $request['provider_id'],
            'Pago registrado',
            $notif['message'],
            [
                'event' => 'payment_received',
                'notification_type' => 'payment_received',
                'url' => '/dashboard/provider',
                'action' => 'verify_payment',
                'request_id' => (int)$requestId,
                'payment_id' => $paymentId
            ]
        );

        WebSocketService::emitToUser('provider', $request['provider_id'], 'payment_updated', [
            'request_id' => (int)$requestId, 'payment_status' => 'verifying', 'proof_url' => $proofUrl, 'method' => $method, 'reference' => $reference
        ]);

        WebSocketService::emitToUser('provider', $request['provider_id'], 'request_updated', [
            'request' => ['id' => (int)$requestId, 'payment_status' => 'verifying', 'updated_at' => date('Y-m-d H:i:s')]
        ]);

        echo json_encode(['success' => true, 'message' => 'Pago registrado', 'status' => 'verifying', 'proof_url' => $proofUrl]);
    }

    private function confirmPayment(object $auth): void
    {
        $input = json_decode(file_get_contents('php://input'), true);
        $paymentId = $input['id'] ?? null;

        if (!$paymentId) { $this->badRequest(); return; }

        $stmt = $this->conn->prepare("
            SELECT p.id, p.status, p.service_request_id, sr.provider_id, sr.user_id, sr.service_id
            FROM payments p JOIN service_requests sr ON sr.id = p.service_request_id
            WHERE p.id = :pid
        ");
        $stmt->execute([':pid' => $paymentId]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$row || $row['provider_id'] != $auth->id) {
            http_response_code(403); echo json_encode(['error' => 'No autorizado']); return;
        }
        if ($row['status'] !== 'verifying') {
            http_response_code(400); echo json_encode(['error' => 'El pago no está en verificación']); return;
        }

        $this->conn->beginTransaction();
        try {
            $this->conn->prepare("UPDATE payments SET status='paid', updated_at=NOW() WHERE id=?")->execute([$paymentId]);
            $this->conn->prepare("UPDATE service_requests SET payment_status='paid', updated_at=NOW() WHERE id=?")->execute([$row['service_request_id']]);
            $this->conn->commit();
        } catch (Throwable $e) { $this->conn->rollBack(); throw $e; }


       // ✅ COBRAR COMISIÓN A LA PLATAFORMA
       require_once __DIR__ . '/MonetizationController.php';
       $request = (new ServiceRequest())->getById($row['service_request_id']);
       MonetizationController::chargeCommission($row['service_request_id'], (float)($request['price'] ?? 0));

        // ✅ LOG
        AuditLogger::log($auth->id, 'payment_confirmed', 'Pago confirmado', "Solicitud ID: {$row['service_request_id']} - Pago ID: {$paymentId}");

        $notif = [
            'sender_id' => $auth->id,
            'receiver_id' => $row['user_id'],
            'receiver_role' => 'user',
            'title' => 'Pago confirmado',
            'message' => 'El proveedor certificó que recibió tu pago',
            'data_json' => json_encode(['type' => 'payment', 'notification_type' => 'payment_received', 'url' => '/orders/' . $row['service_request_id'], 'action' => 'view_order', 'request_id' => (int)$row['service_request_id'], 'payment_id' => (int)$paymentId])
        ];
        (new ServiceRequest())->saveNotification($notif);

        WebSocketService::sendNotification('user', $row['user_id'], 'Pago confirmado', 'El proveedor certificó que recibió tu pago', [
            'event' => 'payment_received', 'notification_type' => 'payment_received', 'url' => '/orders/' . $row['service_request_id'], 'action' => 'view_order', 'request_id' => (int)$row['service_request_id'], 'payment_id' => (int)$paymentId
        ]);

        WebSocketService::emitToUser('user', $row['user_id'], 'payment_updated', ['request_id' => (int)$row['service_request_id'], 'payment_status' => 'paid']);
        WebSocketService::emitToUser('user', $row['user_id'], 'request_updated', ['request' => ['id' => (int)$row['service_request_id'], 'payment_status' => 'paid', 'status' => 'accepted', 'updated_at' => date('Y-m-d H:i:s')]]);
        WebSocketService::emitToUser('provider', $row['provider_id'], 'request_updated', ['request' => ['id' => (int)$row['service_request_id'], 'payment_status' => 'paid', 'updated_at' => date('Y-m-d H:i:s')]]);

        echo json_encode(['success' => true]);
    }

    private function rejectPayment(object $auth): void
    {
        $input = json_decode(file_get_contents('php://input'), true);
        $paymentId = $input['id'] ?? null;
        if (!$paymentId) { $this->badRequest(); return; }

        $stmt = $this->conn->prepare("
            SELECT p.id, p.status, p.service_request_id, sr.provider_id, sr.user_id
            FROM payments p JOIN service_requests sr ON sr.id = p.service_request_id
            WHERE p.id = :pid
        ");
        $stmt->execute([':pid' => $paymentId]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$row || $row['provider_id'] != $auth->id) {
            http_response_code(403); echo json_encode(['error' => 'No autorizado']); return;
        }

        $this->conn->beginTransaction();
        try {
            $this->conn->prepare("UPDATE payments SET status='rejected', updated_at=NOW() WHERE id=?")->execute([$paymentId]);
            $this->conn->prepare("UPDATE service_requests SET payment_status='pending', updated_at=NOW() WHERE id=?")->execute([$row['service_request_id']]);
            $this->conn->commit();
        } catch (Throwable $e) { $this->conn->rollBack(); throw $e; }

        // ✅ LOG
        AuditLogger::log($auth->id, 'payment_rejected', 'Pago rechazado', "Solicitud ID: {$row['service_request_id']} - Pago ID: {$paymentId}");

        $notif = [
            'sender_id' => $auth->id,
            'receiver_id' => $row['user_id'],
            'receiver_role' => 'user',
            'title' => 'Pago rechazado',
            'message' => 'El proveedor rechazó tu comprobante de pago.',
            'data_json' => json_encode(['type' => 'payment', 'notification_type' => 'payment_received', 'url' => '/orders/' . $row['service_request_id'], 'action' => 'view_order', 'request_id' => (int)$row['service_request_id'], 'payment_id' => (int)$paymentId])
        ];
        (new ServiceRequest())->saveNotification($notif);

        WebSocketService::sendNotification('user', $row['user_id'], 'Pago rechazado', 'El proveedor rechazó tu comprobante.', [
            'event' => 'payment_received', 'notification_type' => 'payment_received', 'url' => '/orders/' . $row['service_request_id'], 'action' => 'view_order', 'request_id' => (int)$row['service_request_id'], 'payment_id' => (int)$paymentId
        ]);

        WebSocketService::emitToUser('user', $row['user_id'], 'payment_updated', ['request_id' => (int)$row['service_request_id'], 'payment_status' => 'rejected']);
        WebSocketService::emitToUser('user', $row['user_id'], 'request_updated', ['request' => ['id' => (int)$row['service_request_id'], 'payment_status' => 'pending', 'updated_at' => date('Y-m-d H:i:s')]]);
        WebSocketService::emitToUser('provider', $row['provider_id'], 'request_updated', ['request' => ['id' => (int)$row['service_request_id'], 'payment_status' => 'pending', 'updated_at' => date('Y-m-d H:i:s')]]);

        echo json_encode(['success' => true]);
    }

    private function getProof(object $auth): void
    {
        $requestId = $_GET['request_id'] ?? null;
        if (!$requestId) { $this->badRequest(); return; }
        $stmt = $this->conn->prepare("
            SELECT p.id, p.capture_file, p.reference, p.payment_method, p.status
            FROM payments p JOIN service_requests sr ON sr.id = p.service_request_id
            WHERE sr.id = :rid AND (sr.user_id = :uid OR sr.provider_id = :uid)
            ORDER BY p.created_at DESC LIMIT 1
        ");
        $stmt->execute([':rid' => $requestId, ':uid' => $auth->id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$row) { http_response_code(404); echo json_encode(['error' => 'Sin datos']); return; }
        echo json_encode(['id' => $row['id'], 'proof_url' => $row['capture_file'], 'reference' => $row['reference'], 'method' => $row['payment_method'], 'status' => $row['status']]);
    }

    private function getMyPayments(object $auth): void
    {
        $stmt = $this->conn->prepare("
            SELECT p.*, s.title as service_title
            FROM payments p JOIN service_requests sr ON sr.id = p.service_request_id
            JOIN services s ON s.id = sr.service_id
            WHERE p.user_id = :uid ORDER BY p.created_at DESC
        ");
        $stmt->execute([':uid' => $auth->id]);
        echo json_encode(['success' => true, 'data' => $stmt->fetchAll(PDO::FETCH_ASSOC)]);
    }

    private function getPublicMethods(int $providerId): void
    {
        $stmt = $this->conn->prepare("
            SELECT method_type, bank_name, holder_name, id_number, phone_number, account_number, email, qr_url
            FROM provider_payment_methods WHERE provider_id = ? AND is_active = 1
        ");
        $stmt->execute([$providerId]);
        $raw = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $out = ['pagoMovil' => null, 'transferencia' => null, 'zelle' => null, 'paypal' => null];
        foreach ($raw as $m) {
            switch ($m['method_type']) {
                case 'pago_movil': $out['pagoMovil'] = ['banco' => $m['bank_name'], 'telefono' => $m['phone_number'], 'cedula' => $m['id_number']]; break;
                case 'transferencia': $out['transferencia'] = ['banco' => $m['bank_name'], 'cuenta' => $m['account_number'], 'cedula' => $m['id_number']]; break;
                case 'zelle': $out['zelle'] = ['email' => $m['email'], 'titular' => $m['holder_name']]; break;
                case 'paypal': $out['paypal'] = ['email' => $m['email'], 'titular' => $m['holder_name']]; break;
            }
        }
        echo json_encode(['paymentInfo' => $out]);
    }
}
