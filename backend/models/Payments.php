<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/ServiceRequest.php';

class Payment
{
    private $conn;
    private $table = 'payments';

    public function __construct()
    {
        $this->conn = (new Database())->getConnection();
    }

    /**
     * Registrar un pago y actualizar el request
     * @param int    $requestId         ID de la solicitud
     * @param string $method            Método de pago
     * @param string $reference         Referencia (opcional)
     * @param string $captureFilePath   Ruta del archivo subido (opcional)
     * @param int    $userId            Usuario que registra el pago
     * @return int                      ID del pago insertado
     * @throws Exception
     */
    public function create(
        int $requestId,
        string $method,
        ?string $reference = null,
        ?string $captureFilePath = null,
        ?int $userId = null
    ): int {
        if (!$requestId || !$method) {
            throw new Exception("Faltan datos requeridos para registrar el pago");
        }

        // 1. Insertar pago
        $stmt = $this->conn->prepare("
            INSERT INTO {$this->table}
            (service_request_id, payment_method, reference, capture_file, status, created_at, user_id)
            VALUES (:req, :met, :ref, :capture, 'verifying', NOW(), :uid)
        ");
        $stmt->execute([
            ':req'     => $requestId,
            ':met'     => $method,
            ':ref'     => $reference,
            ':capture' => $captureFilePath,
            ':uid'     => $userId
        ]);
        $paymentId = (int)$this->conn->lastInsertId();

        // 2. Actualizar request → payment_status = verifying
        $requestModel = new ServiceRequest();
        $ok = $requestModel->updatePaymentStatus($requestId, 'verifying', $captureFilePath);
        if (!$ok) {
            throw new Exception("No se pudo actualizar el estado del servicio");
        }

        return $paymentId;
    }

    /**
     * Obtener todos los pagos de una solicitud
     */
    public function getByRequestId(int $requestId): array
    {
        $stmt = $this->conn->prepare("
            SELECT * FROM {$this->table}
            WHERE service_request_id = :req
            ORDER BY created_at DESC
        ");
        $stmt->execute([':req' => $requestId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Actualizar estado de un pago
     */
    public function updateStatus(int $paymentId, string $status): bool
    {
        if (!$paymentId || !$status) return false;
        $stmt = $this->conn->prepare("
            UPDATE {$this->table}
            SET status = :st, updated_at = NOW()
            WHERE id = :id
        ");
        return $stmt->execute([':st' => $status, ':id' => $paymentId]);
    }

    /**
     * Obtener el pago más reciente de una solicitud
     */
    public function getLastByRequest(int $requestId): ?array
    {
        $stmt = $this->conn->prepare("
            SELECT * FROM {$this->table}
            WHERE service_request_id = :req
            ORDER BY created_at DESC
            LIMIT 1
        ");
        $stmt->execute([':req' => $requestId]);
        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
    }
}
?>
