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
        } elseif (preg_match('/\/api\/payments\/dispute\b/', $path) && $method === 'POST') {
            $this->openDispute($auth);
        } elseif (preg_match('/\/api\/disputes\/(\d+)\/message/', $path, $m) && $method === 'POST') {
            $this->addDisputeMessage($auth, (int)$m[1]);
        } elseif (preg_match('/\/api\/disputes\/(\d+)\/upload/', $path, $m) && $method === 'POST') {
            $this->uploadDisputeEvidence($auth, (int)$m[1]);
        } elseif (preg_match('/\/api\/disputes\/(\d+)\/appeal/', $path, $m) && $method === 'POST') {
            $this->appealDispute($auth, (int)$m[1]);
        } elseif (preg_match('/\/api\/disputes\/(\d+)/', $path, $m) && $method === 'GET') {
            $this->getDisputeDetail($auth, (int)$m[1]);
        } elseif (preg_match('/\/api\/payments\/disputes/', $path) && $method === 'GET') {
            $this->getMyDisputes($auth);
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
                'url' => '/orders/' . $requestId,
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
                'url' => '/orders/' . $requestId,
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

        require_once __DIR__ . '/MonetizationController.php';
        $request = (new ServiceRequest())->getById($row['service_request_id']);
        MonetizationController::chargeCommission($row['service_request_id'], (float)($request['price'] ?? 0));

        AuditLogger::log($auth->id, 'payment_confirmed', 'Pago confirmado', "Solicitud ID: {$row['service_request_id']} - Pago ID: {$paymentId}");

        $stmtRole = $this->conn->prepare("SELECT role FROM users WHERE id = ?");
        $stmtRole->execute([$row['user_id']]);
        $userRole = $stmtRole->fetchColumn() ?: 'user';

        $notif = [
            'sender_id' => $auth->id,
            'receiver_id' => $row['user_id'],
            'receiver_role' => $userRole,
            'title' => 'Pago confirmado',
            'message' => 'El proveedor certificó que recibió tu pago',
            'data_json' => json_encode(['type' => 'payment', 'notification_type' => 'payment_received', 'url' => '/orders/' . $row['service_request_id'], 'action' => 'view_order', 'request_id' => (int)$row['service_request_id'], 'payment_id' => (int)$paymentId])
        ];
        (new ServiceRequest())->saveNotification($notif);

        WebSocketService::sendNotification($userRole, $row['user_id'], 'Pago confirmado', 'El proveedor certificó que recibió tu pago', [
            'event' => 'payment_received', 'notification_type' => 'payment_received', 'url' => '/orders/' . $row['service_request_id'], 'action' => 'view_order', 'request_id' => (int)$row['service_request_id'], 'payment_id' => (int)$paymentId
        ]);

        WebSocketService::emitToUser($userRole, $row['user_id'], 'payment_updated', ['request_id' => (int)$row['service_request_id'], 'payment_status' => 'paid']);
        WebSocketService::emitToUser($userRole, $row['user_id'], 'request_updated', ['request' => ['id' => (int)$row['service_request_id'], 'payment_status' => 'paid', 'status' => 'accepted', 'updated_at' => date('Y-m-d H:i:s')]]);
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

        AuditLogger::log($auth->id, 'payment_rejected', 'Pago rechazado', "Solicitud ID: {$row['service_request_id']} - Pago ID: {$paymentId}");

        $stmtRole = $this->conn->prepare("SELECT role FROM users WHERE id = ?");
        $stmtRole->execute([$row['user_id']]);
        $userRole = $stmtRole->fetchColumn() ?: 'user';

        $notif = [
            'sender_id' => $auth->id,
            'receiver_id' => $row['user_id'],
            'receiver_role' => $userRole,
            'title' => 'Pago rechazado',
            'message' => 'El proveedor rechazó tu comprobante de pago.',
            'data_json' => json_encode(['type' => 'payment', 'notification_type' => 'payment_received', 'url' => '/orders/' . $row['service_request_id'], 'action' => 'view_order', 'request_id' => (int)$row['service_request_id'], 'payment_id' => (int)$paymentId])
        ];
        (new ServiceRequest())->saveNotification($notif);

        WebSocketService::sendNotification($userRole, $row['user_id'], 'Pago rechazado', 'El proveedor rechazó tu comprobante.', [
            'event' => 'payment_received', 'notification_type' => 'payment_received', 'url' => '/orders/' . $row['service_request_id'], 'action' => 'view_order', 'request_id' => (int)$row['service_request_id'], 'payment_id' => (int)$paymentId
        ]);

        WebSocketService::emitToUser($userRole, $row['user_id'], 'payment_updated', ['request_id' => (int)$row['service_request_id'], 'payment_status' => 'rejected']);
        WebSocketService::emitToUser($userRole, $row['user_id'], 'request_updated', ['request' => ['id' => (int)$row['service_request_id'], 'payment_status' => 'pending', 'updated_at' => date('Y-m-d H:i:s')]]);
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

    // ========== SISTEMA DE DISPUTAS ==========

    // POST /api/payments/dispute - Abrir disputa
    public function openDispute(object $auth): void
    {
        $input = json_decode(file_get_contents('php://input'), true);
        $requestId = $input['request_id'] ?? null;
        $reason = $input['reason'] ?? null;
        $description = $input['description'] ?? '';

        if (!$requestId || !$reason) {
            http_response_code(400);
            echo json_encode(['error' => 'Faltan datos: request_id y reason']);
            return;
        }

        $stmt = $this->conn->prepare("SELECT id, user_id, provider_id, status FROM service_requests WHERE id = ?");
        $stmt->execute([$requestId]);
        $request = $stmt->fetch();

        if (!$request || ($request['user_id'] != $auth->id && $request['provider_id'] != $auth->id)) {
            http_response_code(403);
            echo json_encode(['error' => 'No autorizado']);
            return;
        }

        $stmt = $this->conn->prepare("SELECT id FROM disputes WHERE request_id = ? AND status IN ('open','under_review')");
        $stmt->execute([$requestId]);
        if ($stmt->fetch()) {
            http_response_code(409);
            echo json_encode(['error' => 'Ya existe una disputa abierta para esta solicitud']);
            return;
        }

        $stmt = $this->conn->prepare("SELECT id FROM payments WHERE service_request_id = ? ORDER BY created_at DESC LIMIT 1");
        $stmt->execute([$requestId]);
        $payment = $stmt->fetch();

        $stmt = $this->conn->prepare("INSERT INTO disputes (request_id, payment_id, user_id, provider_id, reason, description) VALUES (?, ?, ?, ?, ?, ?)");
        $stmt->execute([$requestId, $payment["id"] ?? null, $auth->id, $request["provider_id"], $reason, $description]);
        $disputeId = $this->conn->lastInsertId();

        $stmt = $this->conn->prepare("SELECT name FROM users WHERE id = ?");
        $stmt->execute([$auth->id, $auth->id]);
        $user = $stmt->fetch();

        $stmt = $this->conn->prepare("
            INSERT INTO notifications (sender_id, receiver_id, receiver_role, title, message, data_json, is_read, created_at)
            SELECT ?, id, role, 'Nueva disputa abierta', ?, ?, 0, NOW() FROM users WHERE role = 'admin'
        ");
        $stmt->execute([
            $auth->id,
            "{$user['name']} abrió una disputa: {$reason}",
            json_encode(['type' => 'dispute', 'dispute_id' => $disputeId, 'request_id' => $requestId, 'route' => '/admin/reports'])
        ]);

        try {
            WebSocketService::emitToRole("admin", "new-notification", [
                "title" => "Nueva disputa abierta",
                "message" => "{$user["name"]} abrió una disputa: {$reason}",
                "notification_type" => "dispute_opened",
                "dispute_id" => $disputeId,
                "request_id" => $requestId,
                "url" => "/admin/reports",
                "action" => "view_dispute",
                "timestamp" => date("Y-m-d H:i:s")
            ]);

            if ($request["provider_id"]) {
                WebSocketService::emitToUser("provider", $request["provider_id"], "new-notification", [
                    "title" => "Disputa abierta en tu servicio",
                    "message" => "{$user["name"]} abrió una disputa sobre tu servicio: {$reason}",
                    "notification_type" => "dispute_opened",
                    "dispute_id" => $disputeId,
                    "request_id" => $requestId,
                    "url" => "/disputes/" . $disputeId,
                    "action" => "view_dispute",
                    "timestamp" => date("Y-m-d H:i:s")
                ]);
            }
        } catch (Exception $e) {
            error_log("Error al notificar disputa por WebSocket: " . $e->getMessage());
        }
        echo json_encode(['success' => true, 'dispute_id' => $disputeId, 'message' => 'Disputa abierta. Un administrador la revisará.']);
    }

    // GET /api/payments/disputes - Ver mis disputas (usuario o proveedor)
    public function getMyDisputes(object $auth): void
    {
        if ($auth->role === 'provider') {
            $stmt = $this->conn->prepare("
                SELECT d.*, u.name as reporter_name
                FROM disputes d
                
                LEFT JOIN users u ON u.id = d.user_id
                WHERE d.provider_id = ? OR d.user_id = ?
                ORDER BY d.created_at DESC
            ");
            $stmt->execute([$auth->id, $auth->id]);
        }
        echo json_encode(['success' => true, 'disputes' => $stmt->fetchAll(PDO::FETCH_ASSOC)]);
    }

    // ========== NUEVOS MÉTODOS PARA DISPUTAS ==========

    // POST /api/disputes/{id}/message - Agregar comentario
    public function addDisputeMessage(object $auth, int $disputeId): void
    {
        $input = json_decode(file_get_contents('php://input'), true);
        $message = $input['message'] ?? '';

        if (!$message) {
            http_response_code(400);
            echo json_encode(['error' => 'El mensaje no puede estar vacío']);
            return;
        }

        $stmt = $this->conn->prepare("SELECT * FROM disputes WHERE id = ?");
        $stmt->execute([$disputeId]);
        $dispute = $stmt->fetch();

        if (!$dispute) {
            http_response_code(404);
            echo json_encode(['error' => 'Disputa no encontrada']);
            return;
        }

        $senderRole = $auth->role;
        if (!in_array($senderRole, ['user', 'provider', 'admin'])) {
            $senderRole = 'user';
        }

        $stmt = $this->conn->prepare("INSERT INTO dispute_messages (dispute_id, sender_id, sender_role, message) VALUES (?, ?, ?, ?)");
        $stmt->execute([$disputeId, $auth->id, $senderRole, $message]);

        // Si hay mensaje nuevo, actualizar estado a under_review si está open
        if ($dispute['status'] === 'open') {
            $stmt = $this->conn->prepare("UPDATE disputes SET status='under_review' WHERE id = ?");
            $stmt->execute([$disputeId]);
        }

        // Notificar al admin si el mensaje es de usuario/proveedor
        if ($senderRole !== 'admin') {
            try {
                WebSocketService::emitToRole("admin", "new-notification", [
                    "title" => "Nuevo mensaje en disputa #{$disputeId}",
                    "message" => $message,
                    "notification_type" => "dispute_message",
                    "dispute_id" => $disputeId,
                    "request_id" => $dispute['request_id'],
                    "url" => "/admin/reports",
                    "action" => "view_dispute",
                    "timestamp" => date("Y-m-d H:i:s")
                ]);
            } catch (Exception $e) {
                error_log("Error al notificar mensaje de disputa: " . $e->getMessage());
            }
        } else {
            // Notificar al usuario si el mensaje es del admin
            try {
                WebSocketService::emitToUser("user", $dispute["user_id"], "new-notification", [
                    "title" => "Admin respondió en disputa #{$disputeId}",
                    "message" => $message,
                    "notification_type" => "dispute_message",
                    "dispute_id" => $disputeId,
                    "request_id" => $dispute["request_id"],
                    "url" => "/disputes/" . $disputeId,
                    "action" => "view_dispute",
                    "timestamp" => date("Y-m-d H:i:s")
                ]);

                // Notificar también al proveedor
                $stmt = $this->conn->prepare("SELECT provider_id FROM service_requests WHERE id = ?");
                $stmt->execute([$dispute["request_id"]]);
                $requestRow = $stmt->fetch();

                if ($requestRow && $requestRow["provider_id"] && $requestRow["provider_id"] != $dispute["user_id"]) {
                    WebSocketService::emitToUser("provider", $requestRow["provider_id"], "new-notification", [
                        "title" => "Admin respondió en disputa #{$disputeId}",
                        "message" => $message,
                        "notification_type" => "dispute_message",
                        "dispute_id" => $disputeId,
                        "request_id" => $dispute["request_id"],
                        "url" => "/disputes/" . $disputeId,
                        "action" => "view_dispute",
                        "timestamp" => date("Y-m-d H:i:s")
                    ]);
                }
            } catch (Exception $e) {
                error_log("Error al notificar mensaje de disputa al usuario: " . $e->getMessage());
            }
        }

        echo json_encode(['success' => true, 'message' => 'Mensaje agregado']);
    }
    // POST /api/disputes/{id}/upload - Subir evidencia
    public function uploadDisputeEvidence(object $auth, int $disputeId): void
    {
        $stmt = $this->conn->prepare("SELECT * FROM disputes WHERE id = ?");
        $stmt->execute([$disputeId]);
        $dispute = $stmt->fetch();

        if (!$dispute) {
            http_response_code(404);
            echo json_encode(['error' => 'Disputa no encontrada']);
            return;
        }

        $fileUrl = null;
        $fileType = null;
        if (isset($_FILES['evidence']) && $_FILES['evidence']['error'] === UPLOAD_ERR_OK) {
            $file = $_FILES['evidence'];
            $fileType = $file['type'];
            $fileUrl = $this->uploader->saveFile($file, Uploader::CAT_DISPUTES);
        }

        if (!$fileUrl) {
            http_response_code(400);
            echo json_encode(['error' => 'No se pudo subir el archivo']);
            return;
        }

        $message = $input['description'] ?? 'Evidencia adjunta';
        $senderRole = $auth->role;
        if (!in_array($senderRole, ['user', 'provider', 'admin'])) {
            $senderRole = 'user';
        }

        $stmt = $this->conn->prepare("INSERT INTO dispute_messages (dispute_id, sender_id, sender_role, message, file_url, file_type) VALUES (?, ?, ?, ?, ?, ?)");
        $stmt->execute([$disputeId, $auth->id, $senderRole, $message, $fileUrl, $fileType]);

        echo json_encode(['success' => true, 'file_url' => $fileUrl]);
    }

    // POST /api/disputes/{id}/appeal - Apelar resolución
    public function appealDispute(object $auth, int $disputeId): void
    {
        $input = json_decode(file_get_contents('php://input'), true);
        $reason = $input['reason'] ?? '';

        $stmt = $this->conn->prepare("SELECT * FROM disputes WHERE id = ?");
        $stmt->execute([$disputeId]);
        $dispute = $stmt->fetch();

        if (!$dispute || $dispute['status'] !== 'resolved') {
            http_response_code(404);
            echo json_encode(['error' => 'Disputa no encontrada o no está resuelta']);
            return;
        }

        if ($dispute['user_id'] !== $auth->id) {
            http_response_code(403);
            echo json_encode(['error' => 'No autorizado']);
            return;
        }

        $stmt = $this->conn->prepare("UPDATE disputes SET status='open', resolved_at=NULL, resolved_by=NULL WHERE id = ?");
        $stmt->execute([$disputeId]);

        $stmt = $this->conn->prepare("INSERT INTO dispute_messages (dispute_id, sender_id, sender_role, message) VALUES (?, ?, 'user', ?)");
        $stmt->execute([$disputeId, $auth->id, "Apelación: $reason"]);

        try {
            WebSocketService::emitToRole("admin", "new-notification", [
                "title" => "Apelación de disputa #{$disputeId}",
                "message" => $reason,
                "notification_type" => "dispute_appealed",
                "dispute_id" => $disputeId,
                "request_id" => $dispute['request_id'],
                "url" => "/admin/reports",
                "action" => "view_dispute",
                "timestamp" => date("Y-m-d H:i:s")
            ]);
        } catch (Exception $e) {
            error_log("Error al notificar apelación: " . $e->getMessage());
        }

        echo json_encode(['success' => true, 'message' => 'Apelación enviada']);
    }

    // GET /api/disputes/{id} - Ver detalle completo
    public function getDisputeDetail(object $auth, int $disputeId): void
    {
        $stmt = $this->conn->prepare("
            SELECT d.*, u.name as reporter_name
            FROM disputes d
            LEFT JOIN users u ON u.id = d.user_id
            
            WHERE d.id = ?
        ");
        $stmt->execute([$disputeId]);
        $dispute = $stmt->fetch();

        if (!$dispute) {
            http_response_code(404);
            echo json_encode(['error' => 'Disputa no encontrada']);
            return;
        }

        // Verificar permisos
        $isAdmin = $auth->role === 'admin';
        $isReporter = $dispute['user_id'] === $auth->id;
        $isProvider = $dispute['provider_id'] === $auth->id;

        if (!$isAdmin && !$isReporter && !$isProvider) {
            http_response_code(403);
            echo json_encode(['error' => 'No autorizado']);
            return;
        }

        $stmt = $this->conn->prepare("SELECT * FROM dispute_messages WHERE dispute_id = ? ORDER BY created_at ASC");
        $stmt->execute([$disputeId]);
        $messages = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode(['success' => true, 'dispute' => $dispute, 'messages' => $messages]);
    }

    // ========== ADMIN: GESTIÓN DE DISPUTAS ==========

    // GET /api/admin/disputes - Listar disputas (admin)
    public function adminGetDisputes(): void
    {
        $auth = Auth::verify();
        if (!$auth || $auth->role !== 'admin') {
            http_response_code(403);
            echo json_encode(['error' => 'No autorizado']);
            return;
        }

        $status = $_GET['status'] ?? 'open';
        $stmt = $this->conn->prepare("
            SELECT d.*, sr.service_id, u.name as reporter_name,
                   p.commission_amount as payment_amount, p.payment_method
            FROM disputes d
            
            JOIN users u ON u.id = d.user_id
            LEFT JOIN payments p ON p.id = d.payment_id
            WHERE d.status = ?
            ORDER BY d.created_at DESC
        ");
        $stmt->execute([$status]);
        echo json_encode(['success' => true, 'disputes' => $stmt->fetchAll(PDO::FETCH_ASSOC)]);
    }

    // POST /api/admin/disputes/resolve - Resolver disputa (admin)
    public function adminResolveDispute(): void
    {
        $auth = Auth::verify();
        if (!$auth || $auth->role !== 'admin') {
            http_response_code(403);
            echo json_encode(['error' => 'No autorizado']);
            return;
        }

        $input = json_decode(file_get_contents('php://input'), true);
        $disputeId = $input['dispute_id'] ?? null;
        $action = $input['action'] ?? 'close';
        $resolution = $input['resolution'] ?? '';

        if (!$disputeId) {
            http_response_code(400);
            echo json_encode(['error' => 'Falta dispute_id']);
            return;
        }

        $stmt = $this->conn->prepare("SELECT * FROM disputes WHERE id = ? AND status IN ('open', 'under_review')");
        $stmt->execute([$disputeId]);
        $dispute = $stmt->fetch();

        if (!$dispute) {
            http_response_code(404);
            echo json_encode(['error' => 'Disputa no encontrada o ya resuelta']);
            return;
        }

        $this->conn->beginTransaction();
        try {
            $stmt = $this->conn->prepare("UPDATE disputes SET status='resolved', resolution=?, resolved_by=?, resolved_at=NOW() WHERE id=?");
            $stmt->execute([$resolution, $auth->id, $disputeId]);

            if ($action === 'refund_user' && $dispute['payment_id']) {
                $stmt = $this->conn->prepare("SELECT commission_amount as amount FROM payments WHERE id = ?");
                $stmt->execute([$dispute['payment_id']]);
                $payment = $stmt->fetch();

                if ($payment && $payment['amount'] > 0) {
                    $stmt = $this->conn->prepare("UPDATE wallets SET balance = balance + ?, updated_at = NOW() WHERE user_id = ?");
                    $stmt->execute([$payment['amount'], $dispute['user_id']]);
                }
            }

            $this->conn->commit();

            $stmt = $this->conn->prepare("INSERT INTO notifications (sender_id, receiver_id, receiver_role, title, message, data_json, is_read, created_at) VALUES (?, ?, 'user', 'Disputa resuelta', ?, ?, 0, NOW())");
            $stmt->execute([$auth->id, $dispute["user_id"], $resolution, json_encode(["type" => "dispute_resolved", "dispute_id" => $disputeId, "url" => "/disputes/" . $disputeId])]);

            try {
                WebSocketService::emitToUser("user", $dispute["user_id"], "new-notification", [
                    "title" => "Disputa resuelta",
                    "message" => $resolution,
                    "notification_type" => "dispute_resolved",
                    "dispute_id" => $disputeId,
                    "request_id" => $dispute["request_id"],
                    "url" => "/disputes/" . $disputeId,
                    "action" => "view_dispute",
                    "timestamp" => date("Y-m-d H:i:s")
                ]);

                $stmt = $this->conn->prepare("SELECT provider_id FROM service_requests WHERE id = ?");
                $stmt->execute([$dispute["request_id"]]);
                $requestRow = $stmt->fetch();

                if ($requestRow && $requestRow["provider_id"]) {
                    WebSocketService::emitToUser("provider", $requestRow["provider_id"], "new-notification", [
                        "title" => "Disputa resuelta",
                        "message" => $resolution,
                        "notification_type" => "dispute_resolved",
                        "dispute_id" => $disputeId,
                        "request_id" => $dispute["request_id"],
                        "url" => "/disputes/" . $disputeId,
                        "action" => "view_dispute",
                        "timestamp" => date("Y-m-d H:i:s")
                    ]);
                }
            } catch (Exception $e) {
                error_log("Error al notificar resolución de disputa por WebSocket: " . $e->getMessage());
            }
            echo json_encode(['success' => true, 'message' => 'Disputa resuelta']);
        } catch (\Exception $e) {
            $this->conn->rollBack();
            http_response_code(500);
            echo json_encode(['error' => 'Error: ' . $e->getMessage()]);
        }
    }
}
