<?php
require_once __DIR__ . '/../config/database.php';

class Payment {
    private $conn;
    private $table = 'payments';

    public function __construct() {
        $this->conn = (new Database())->getConnection();
    }

    /**
     * Registrar un pago
     * @param int $requestId ID de la solicitud de servicio
     * @param string $method Método de pago
     * @param string|null $reference Referencia opcional
     * @param string|null $captureFilePath Archivo capturado opcional
     * @return int ID del pago insertado
     * @throws Exception
     */
    public function create($requestId, $method, $reference = null, $captureFilePath = null) {
        // Validación mínima
        if (!$requestId || !$method) {
            throw new Exception("Faltan datos requeridos para registrar el pago");
        }

        $query = "INSERT INTO {$this->table} 
            (service_request_id, payment_method, reference, capture_file, status, created_at) 
            VALUES (:service_request_id, :payment_method, :reference, :capture_file, 'pending', NOW())";

        $stmt = $this->conn->prepare($query);
        $stmt->bindValue(':service_request_id', $requestId, PDO::PARAM_INT);
        $stmt->bindValue(':payment_method', $method, PDO::PARAM_STR);
        $stmt->bindValue(':reference', $reference, PDO::PARAM_STR);
        $stmt->bindValue(':capture_file', $captureFilePath, PDO::PARAM_STR);

        if (!$stmt->execute()) {
            $errorInfo = $stmt->errorInfo();
            throw new Exception("Error al registrar pago: " . implode(" | ", $errorInfo));
        }

        return $this->conn->lastInsertId();
    }

    /**
     * Obtener pagos por requestId
     */
    public function getByRequestId($requestId) {
        $query = "SELECT * FROM {$this->table} WHERE service_request_id = :service_request_id";
        $stmt = $this->conn->prepare($query);
        $stmt->execute([':service_request_id' => $requestId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Actualizar estado de pago
     */
    public function updateStatus($paymentId, $status) {
        if (!$paymentId || !$status) {
            return false;
        }
        $query = "UPDATE {$this->table} SET status = :status WHERE id = :id";
        $stmt = $this->conn->prepare($query);
        return $stmt->execute([':status' => $status, ':id' => $paymentId]);
    }
}
?>
