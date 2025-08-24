<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../models/Payments.php';
require_once __DIR__ . '/../models/ServiceRequest.php';
require_once __DIR__ . '/../utils/jwt.php';

class PaymentController {
    private $conn;
    private $table = 'payments';

    public function __construct() {
        $this->conn = (new Database())->getConnection();
    }

    public function handle($method) {
        switch($method) {
            case 'POST':
                $this->createPayment();
                break;
            default:
                http_response_code(405);
                echo json_encode(["error" => "Método no permitido"]);
        }
    }

    private function createPayment() {
    // Token
    $headers = getallheaders();
    if (!isset($headers['Authorization'])) {
        http_response_code(401);
        echo json_encode(["error" => "No autorizado"]);
        return;
    }
    $token = str_replace('Bearer ', '', $headers['Authorization']);
    $userId = $this->validateToken($token);
    if (!$userId) {
        http_response_code(401);
        echo json_encode(["error" => "Token inválido"]);
        return;
    }

    // Datos
    $serviceRequestId = $_POST['serviceRequestId'] ?? null;
    $paymentMethod    = $_POST['paymentMethod'] ?? null;
    $reference        = $_POST['reference'] ?? null;

    if (!$serviceRequestId || !$paymentMethod) {
        http_response_code(400);
        echo json_encode(["error" => "Faltan datos requeridos"]);
        return;
    }

    // Archivo
    $captureFile = null;
    if (isset($_FILES['capture']) && $_FILES['capture']['error'] === 0) {
        $uploadDir = __DIR__ . '/../uploads/payments/';
        if (!is_dir($uploadDir)) mkdir($uploadDir, 0755, true);
        $captureFile = $uploadDir . basename($_FILES['capture']['name']);
        if (!move_uploaded_file($_FILES['capture']['tmp_name'], $captureFile)) {
            $captureFile = null; // evita fallo
        }
    }

    try {
        $stmt = $this->conn->prepare("
            INSERT INTO {$this->table} 
            (service_request_id, user_id, payment_method, reference, capture_file, status, created_at)
            VALUES (:service_request_id, :user_id, :payment_method, :reference, :capture_file, 'pending', NOW())
        ");
        $stmt->bindValue(':service_request_id', $serviceRequestId, PDO::PARAM_INT);
        $stmt->bindValue(':user_id', $userId, PDO::PARAM_INT);
        $stmt->bindValue(':payment_method', $paymentMethod);
        $stmt->bindValue(':reference', $reference);
        $stmt->bindValue(':capture_file', $captureFile);

        if (!$stmt->execute()) {
            $errorInfo = $stmt->errorInfo();
            throw new Exception("DB Error: " . implode(' | ', $errorInfo));
        }

        // Actualizar status del request
        try {
            $serviceRequest = new ServiceRequest();
            $serviceRequest->updatePaymentStatus($serviceRequestId, 'paid', $userId);
        } catch (Exception $e) {
            // No interrumpe el flujo
        }

        echo json_encode(["success" => true, "message" => "Pago registrado correctamente"]);

    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(["error" => "Error interno", "details" => $e->getMessage()]);
    }
}

      

    private function validateToken($token) {
        try {
            $decoded = JwtHandler::decode($token);
            return $decoded->id ?? null;
        } catch (Exception $e) {
            return null;
        }
    }
}
?>
