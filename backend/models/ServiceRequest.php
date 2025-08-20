<?php
require_once __DIR__ . '/../config/database.php';

class ServiceRequest {
    private $conn;
    private $table = 'service_requests';

    public function __construct() {
        $this->conn = (new Database())->getConnection();
    }

    /**
     * Crear una nueva solicitud
     */
    public function create($data) {
        $query = "INSERT INTO {$this->table}
            (service_id, user_id, provider_id, price, payment_method, additional_details, payment_status, created_at)
            VALUES (:service_id, :user_id, :provider_id, :price, :payment_method, :additional_details, 'pending', NOW())";

        $stmt = $this->conn->prepare($query);

        $stmt->bindValue(':service_id', $data['service_id'], PDO::PARAM_INT);
        $stmt->bindValue(':user_id', $data['user_id'], PDO::PARAM_INT);
        $stmt->bindValue(':provider_id', $data['provider_id'], PDO::PARAM_INT);
        $stmt->bindValue(':price', $data['price']);
        $stmt->bindValue(':payment_method', $data['payment_method'] ?? 'efectivo');
        $stmt->bindValue(':additional_details', $data['additional_details'] ?? null, PDO::PARAM_STR);

        if (!$stmt->execute()) {
            $errorInfo = $stmt->errorInfo();
            throw new Exception("Error en la creación de solicitud: " . implode(" | ", $errorInfo));
        }

        return $this->conn->lastInsertId();
    }

    /**
     * Obtener todas las solicitudes de un usuario o proveedor
     */
    public function getByUser($userId) {
        $query = "SELECT * FROM {$this->table}
                  WHERE user_id = :id OR provider_id = :id
                  ORDER BY created_at DESC";
        $stmt = $this->conn->prepare($query);

        if (!$stmt->execute([':id' => $userId])) {
            return [];
        }

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Obtener solicitudes activas con datos del servicio
     */
    public function getActiveByUser($userId) {
        $query = "SELECT sr.*,
                     s.title AS service_title,
                     s.description AS service_description,
                     s.price AS service_price,
                     s.provider_name AS service_provider_name,
                     s.provider_avatar_url AS service_image
                  FROM {$this->table} sr
                  LEFT JOIN services s ON s.id = sr.service_id
                  WHERE (sr.user_id = :id OR sr.provider_id = :id)
                  AND sr.status IN ('pending','accepted')
                  ORDER BY sr.created_at DESC";

        $stmt = $this->conn->prepare($query);

        if (!$stmt->execute([':id' => $userId])) {
            return [];
        }

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Obtener solicitud por ID
     */
    public function getById($id) {
        $query = "SELECT * FROM {$this->table} WHERE id = :id LIMIT 1";
        $stmt = $this->conn->prepare($query);

        if (!$stmt->execute([':id' => $id])) {
            return null;
        }

        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    /**
     * Actualizar estado general de solicitud
     */
    public function updateStatus($id, $userId, $status) {
        $query = "UPDATE {$this->table}
                  SET status = :status, updated_at = NOW()
                  WHERE id = :id AND (user_id = :uid OR provider_id = :uid)";
        $stmt = $this->conn->prepare($query);

        return $stmt->execute([
            ':status' => $status,
            ':id'     => $id,
            ':uid'    => $userId
        ]);
    }

    /**
     * Actualizar estado de pago de la solicitud
     */
    public function updatePaymentStatus($id, $status) {
        $query = "UPDATE {$this->table}
                  SET payment_status = :status, updated_at = NOW()
                  WHERE id = :id";
        $stmt = $this->conn->prepare($query);

        if (!$stmt->execute([':status' => $status, ':id' => $id])) {
            $errorInfo = $stmt->errorInfo();
            throw new Exception("Error actualizando estado de pago: " . implode(" | ", $errorInfo));
        }

        return $stmt->rowCount() > 0; // true si se actualizó algo
    }
}
