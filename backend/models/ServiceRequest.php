<?php
require_once __DIR__ . '/../config/database.php';

class ServiceRequest {
    private $conn;
    private $table = 'service_requests';

    public function __construct() {
        $this->conn = (new Database())->getConnection();
    }

    /* ----------  MÉTODOS YA EXISTENTES  ---------- */

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

    public function getByUser($userId) {
        $query = "
            SELECT sr.*,
                   s.title AS service_title,
                   s.description AS service_description,
                   s.price AS service_price,
                   s.provider_name AS service_provider_name,
                   s.provider_avatar_url AS service_image
            FROM {$this->table} sr
            LEFT JOIN services s ON sr.service_id = s.id
            WHERE sr.user_id = :id OR sr.provider_id = :id
            ORDER BY sr.created_at DESC
        ";

        $stmt = $this->conn->prepare($query);
        $stmt->execute([':id' => $userId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getCompletedByUser($userId) {
        $query = "
            SELECT sr.*,
                   s.title AS service_title,
                   s.description AS service_description,
                   s.price AS service_price,
                   s.provider_name AS service_provider_name,
                   s.provider_avatar_url AS service_image
            FROM {$this->table} sr
            LEFT JOIN services s ON sr.service_id = s.id
            WHERE (sr.user_id = :id OR sr.provider_id = :id)
              AND sr.status = 'completed'
            ORDER BY sr.created_at DESC
        ";

        $stmt = $this->conn->prepare($query);
        $stmt->execute([':id' => $userId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getServiceById($id) {
        $stmt = $this->conn->prepare("SELECT title, description FROM services WHERE id = ?");
        $stmt->execute([$id]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    public function getPending() {
        $query = "SELECT sr.*,
                     s.title AS service_title,
                     s.description AS service_description,
                     s.price AS service_price,
                     s.provider_name AS service_provider_name,
                     s.provider_avatar_url AS service_image
                  FROM {$this->table} sr
                  LEFT JOIN services s ON s.id = sr.service_id
                  WHERE sr.status = 'pending'
                  ORDER BY sr.created_at DESC";

        $stmt = $this->conn->prepare($query);
        if (!$stmt->execute()) return [];
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getPendingByProvider($providerId) {
        $query = "SELECT sr.*,
                     s.title AS service_title,
                     s.description AS service_description,
                     s.price AS service_price,
                     s.provider_name AS service_provider_name,
                     s.provider_avatar_url AS service_image
                  FROM {$this->table} sr
                  LEFT JOIN services s ON s.id = sr.service_id
                  WHERE sr.status = 'pending'
                    AND sr.provider_id = :provider_id
                  ORDER BY sr.created_at DESC";

        $stmt = $this->conn->prepare($query);
        $stmt->execute([':provider_id' => $providerId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getPendingByUser($userId) {
        $query = "SELECT sr.*,
                     s.title AS service_title,
                     s.description AS service_description,
                     s.price AS service_price,
                     s.provider_name AS service_provider_name,
                     s.provider_avatar_url AS service_image
                  FROM {$this->table} sr
                  LEFT JOIN services s ON s.id = sr.service_id
                  WHERE sr.status = 'pending'
                    AND sr.user_id = :user_id
                  ORDER BY sr.created_at DESC";

        $stmt = $this->conn->prepare($query);
        $stmt->execute([':user_id' => $userId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getActiveByUser($userId) {
    $query = "
        SELECT sr.*,
               s.title AS service_title,
               s.description AS service_description,
               s.price AS service_price,
               s.image_url AS service_image_url,
               s.provider_rating AS provider_rating,
               s.provider_name AS service_provider_name,
               u.avatar_url AS provider_avatar_url,
               u.address AS provider_address,
               u.phone AS provider_phone
        FROM {$this->table} sr
        LEFT JOIN services s ON s.id = sr.service_id
        LEFT JOIN users u ON u.id = sr.provider_id
        WHERE (sr.user_id = :id OR sr.provider_id = :id)
          AND sr.status IN ('pending','accepted')
        ORDER BY sr.created_at DESC
    ";

    $stmt = $this->conn->prepare($query);
    $stmt->execute([':id' => $userId]);
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}












public function getActiveByProvider(int $providerId): array
{
    $sql = "
        SELECT sr.*,
               s.title        AS service_title,
               s.description  AS service_description,
               s.price        AS service_price,
               u.name         AS user_name,
               u.avatar_url   AS user_avatar
        FROM {$this->table} sr
        JOIN services s ON s.id = sr.service_id
        JOIN users    u ON u.id = sr.user_id
        WHERE sr.provider_id = :pid
          AND sr.status = 'accepted'
        ORDER BY sr.updated_at DESC
    ";
    $stmt = $this->conn->prepare($sql);
    $stmt->execute([':pid' => $providerId]);
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

    public function getById($id) {
        $query = "SELECT * FROM {$this->table} WHERE id = :id LIMIT 1";
        $stmt = $this->conn->prepare($query);
        if (!$stmt->execute([':id' => $id])) return null;
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    public function updateStatus(int $id, int $actorId, string $newStatus): bool {
    $sql = "UPDATE {$this->table}
            SET status = :status, updated_at = NOW()
            WHERE id = :id
              AND (user_id = :actorId OR provider_id = :actorId)";
    $stmt = $this->conn->prepare($sql);
    return $stmt->execute([
        ':status'  => $newStatus,
        ':id'      => $id,
        ':actorId' => $actorId
    ]);
}


    public function saveNotification($data) {
        $query = "INSERT INTO notifications
                  (sender_id, receiver_id, receiver_role, title, message, is_read, created_at)
                  VALUES (:sender_id, :receiver_id, :receiver_role, :title, :message, 0, NOW())";

        $stmt = $this->conn->prepare($query);
        return $stmt->execute([
            ':sender_id' => $data['sender_id'] ?? null,
            ':receiver_id' => $data['receiver_id'],
            ':receiver_role' => $data['receiver_role'],
            ':title' => $data['title'],
            ':message' => $data['message']
        ]);
    }

    public function updatePaymentStatus($id, $status) {
        $query = "UPDATE {$this->table}
                  SET payment_status = :status, updated_at = NOW()
                  WHERE id = :id";
        $stmt = $this->conn->prepare($query);
        if (!$stmt->execute([':status' => $status, ':id' => $id])) {
            $errorInfo = $stmt->errorInfo();
            throw new Exception("Error actualizando estado de pago: " . implode(" | ", $errorInfo));
        }
        return $stmt->rowCount() > 0;
    }

    /* ----------  NUEVOS MÉTODOS PARA CANCELACIÓN  ---------- */

   public function cancel(int $requestId, int $actorId, string $actorRole): bool {
    if (!in_array($actorRole, ['user', 'provider'])) {
        throw new InvalidArgumentException("Rol inválido: debe ser 'user' o 'provider'");
    }

    $sql = "UPDATE {$this->table}
            SET status = 'cancelled',
                cancelled_by = :actorRole,
                updated_at = NOW()
            WHERE id = :id
              AND (user_id = :actorId OR provider_id = :actorId)";

    $stmt = $this->conn->prepare($sql);
    return $stmt->execute([
        ':actorRole' => $actorRole,
        ':id'        => $requestId,
        ':actorId'   => $actorId
    ]);
}



    public function getCancellationInfo(int $requestId): ?array {
        $sql = "SELECT status, cancelled_by FROM {$this->table} WHERE id = :id";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute([':id' => $requestId]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($row && $row['status'] === 'cancelled') {
            return ['cancelled_by' => $row['cancelled_by']];
        }
        return null;
    }

    /* ----------  MÉTODOS EXTRA DE HISTORIAL  ---------- */

    public function getCompletedByProvider(int $providerId): array {
        $sql = "
            SELECT sr.*,
                   s.title        AS service_title,
                   s.description  AS service_description,
                   s.price        AS service_price,
                   s.provider_name,
                   s.provider_avatar_url AS service_image
            FROM {$this->table} sr
            JOIN services s ON s.id = sr.service_id
            WHERE sr.provider_id = :pid
              AND sr.status = 'completed'
            ORDER BY sr.updated_at DESC
        ";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute([':pid' => $providerId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getHistoryByUser(int $userId): array {
    $sql = "
        SELECT sr.id, sr.status, sr.created_at, sr.updated_at,
               s.title        AS service_title,
               s.description  AS service_description,
               s.price        AS service_price,
               u.name         AS provider__name,
               u.avatar_url   AS provider_avatar,
               sr.cancelled_by
        FROM {$this->table} sr
        JOIN services s ON s.id = sr.service_id
        JOIN users    u ON u.id = sr.provider_id
        WHERE sr.user_id = :uid
          AND sr.status IN ('rejected','cancelled','completed','busy')
        ORDER BY sr.updated_at DESC
    ";
    $stmt = $this->conn->prepare($sql);
    $stmt->execute([':uid' => $userId]);
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}


    public function getHistoryByProvider(int $providerId): array {
        $sql = "
            SELECT sr.*,
                   s.title        AS service_title,
                   s.description  AS service_description,
                   s.price        AS service_price,
                   u.name         AS user_name,
                   u.avatar_url   AS user_avatar
            FROM {$this->table} sr
            JOIN services s ON s.id = sr.service_id
            JOIN users    u ON u.id = sr.user_id
            WHERE sr.provider_id = :pid
              AND sr.status IN ('rejected','cancelled','completed','busy')
            ORDER BY sr.updated_at DESC
        ";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute([':pid' => $providerId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}
