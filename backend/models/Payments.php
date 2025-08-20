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
     * @param int $serviceRequestId
     * @param string $method
     * @param string|null $reference
     * @param string|null $captureFilePath
     * @return int Inserted payment ID
     */
    public function create($serviceRequestId, $method, $reference = null, $captureFilePath = null) {
        $query = "INSERT INTO {$this->table} 
            (service_request_id, payment_method, reference, capture_file, created_at) 
            VALUES (:service_request_id, :payment_method, :reference, :capture_file, NOW())";

        $stmt = $this->conn->prepare($query);
        $stmt->bindValue(':service_request_id', $serviceRequestId, PDO::PARAM_INT);
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
     * Obtener pagos por solicitud
     */
    public function getByRequestId($serviceRequestId) {
        $query = "SELECT * FROM {$this->table} WHERE service_request_id = :service_request_id";
        $stmt = $this->conn->prepare($query);
        $stmt->execute([':service_request_id' => $serviceRequestId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Actualizar estado de pago
     */
    public function updateStatus($paymentId, $status) {
        $query = "UPDATE {$this->table} SET status = :status WHERE id = :id";
        $stmt = $this->conn->prepare($query);
        return $stmt->execute([':status' => $status, ':id' => $paymentId]);
    }
}
?>
