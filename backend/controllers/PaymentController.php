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
        // Verificar token Bearer
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

        // Obtener datos
        $serviceRequestId = $_POST['serviceRequestId'] ?? null;
        $paymentMethod = $_POST['paymentMethod'] ?? null;
        $reference = $_POST['reference'] ?? null;

        if (!$serviceRequestId || !$paymentMethod) {
            http_response_code(400);
            echo json_encode(["error" => "Faltan datos requeridos"]);
            return;
        }

        // Procesar archivo si existe
        $captureFile = null;
        if (isset($_FILES['capture']) && $_FILES['capture']['error'] === 0) {
            $uploadDir = __DIR__ . '/../uploads/payments/';
            if (!is_dir($uploadDir)) mkdir($uploadDir, 0755, true);
            $captureFile = $uploadDir . basename($_FILES['capture']['name']);
            move_uploaded_file($_FILES['capture']['tmp_name'], $captureFile);
        }

        try {
            // Guardar pago en DB
            $query = "INSERT INTO {$this->table}
                (service_request_id, user_id, payment_method, reference, capture_file, status, created_at)
                VALUES (:service_request_id, :user_id, :payment_method, :reference, :capture_file, 'pending', NOW())";
            $stmt = $this->conn->prepare($query);
            $stmt->bindValue(':service_request_id', $serviceRequestId, PDO::PARAM_INT);
            $stmt->bindValue(':user_id', $userId, PDO::PARAM_INT);
            $stmt->bindValue(':payment_method', $paymentMethod);
            $stmt->bindValue(':reference', $reference);
            $stmt->bindValue(':capture_file', $captureFile);

            if ($stmt->execute()) {
                // 🔥 Aquí pasamos el userId para que el update funcione
                $serviceRequest = new ServiceRequest();
                $updated = $serviceRequest->updatePaymentStatus($serviceRequestId, 'paid', $userId);

                if ($updated) {
                    echo json_encode([
                        "success" => true,
                        "message" => "Pago registrado correctamente"
                    ]);
                } else {
                    echo json_encode([
                        "success" => true,
                        "warning" => "Pago guardado, pero no se pudo actualizar el estado del servicio"
                    ]);
                }
            } else {
                http_response_code(500);
                echo json_encode(["error" => "No se pudo registrar el pago"]);
            }

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
