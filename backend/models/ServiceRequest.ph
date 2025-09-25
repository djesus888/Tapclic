<?php
require_once __DIR__ . '/../config/database.php';

class ServiceRequest
{
    public $conn; // expuesta para acceso rápido desde controller
    private $table = 'service_requests';

    public function __construct()
    {
        $this->conn = (new Database())->getConnection();
    }

    /* ----------  MÉTODOS YA EXISTENTES  ---------- */

    public function create($data)
    {
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

    public function getByUser($userId)
    {
        $query = "
            SELECT
                sr.*,
                s.title AS service_title,
                s.description AS service_description,
                s.price AS service_price,
                s.provider_name AS service_provider_name,
                s.provider_avatar_url AS service_image,
                s.location AS service_location,
                s.provider_rating AS service_provider_rating,
                s.isAvailable AS service_is_available
            FROM {$this->table} sr
            LEFT JOIN services s ON sr.service_id = s.id
            WHERE sr.user_id = :id OR sr.provider_id = :id
            ORDER BY sr.created_at DESC
        ";

        $stmt = $this->conn->prepare($query);
        $stmt->execute([':id' => $userId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getCompletedByUser($userId)
    {
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

    public function getServiceById($id)
    {
        $stmt = $this->conn->prepare("SELECT title, description FROM services WHERE id = ?");
        $stmt->execute([$id]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    public function getPending()
    {
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

    public function getPendingByProvider($providerId)
    {
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

    public function getPendingByUser($userId)
    {
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

    public function getActiveByUser(int $userId): array
    {
        $query = "
        SELECT
            sr.*,
            s.title AS service_title,
            s.description AS service_description,
            s.price AS service_price,
            s.image_url AS service_image_url,
            s.provider_rating AS provider_rating,
            s.provider_name AS service_provider_name,
            u.avatar_url AS provider_avatar_url,
            u.address AS provider_address,
            u.phone AS provider_phone,
            (
                SELECT JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'method_type', ppm.method_type,
                        'bank_name', ppm.bank_name,
                        'holder_name', ppm.holder_name,
                        'id_number', ppm.id_number,
                        'phone_number', ppm.phone_number,
                        'account_number', ppm.account_number,
                        'email', ppm.email
                    )
                )
                FROM provider_payment_methods ppm
                WHERE ppm.provider_id = sr.provider_id
                  AND ppm.is_active = 1
                  AND ppm.method_type IN ('pago_movil', 'transferencia', 'paypal', 'zelle', 'binance')
            ) AS payment_methods
        FROM {$this->table} sr
        LEFT JOIN services s ON s.id = sr.service_id
        LEFT JOIN users u ON u.id = sr.provider_id
        WHERE sr.user_id = :id
          AND sr.status IN ('pending','accepted','in_progress','on_the_way','arrived')
        ORDER BY sr.created_at DESC
    ";

        $stmt = $this->conn->prepare($query);
        $stmt->execute([':id' => $userId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getActiveByProvider(int $providerId): array
    {
        $sql = "
        SELECT
            sr.*,
            s.title AS service_title,
            s.description AS service_description,
            s.price AS service_price,
            u.name AS user_name,
            u.avatar_url AS user_avatar
        FROM {$this->table} sr
        JOIN services s ON s.id = sr.service_id
        JOIN users u ON u.id = sr.user_id
        WHERE sr.provider_id = :pid
          AND sr.status IN ('accepted','in_progress','on_the_way','arrived')
        ORDER BY sr.updated_at DESC
    ";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute([':pid' => $providerId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getById($id)
    {
        $query = "SELECT * FROM {$this->table} WHERE id = :id LIMIT 1";
        $stmt = $this->conn->prepare($query);
        if (!$stmt->execute([':id' => $id])) return null;
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    public function updateStatus(int $id, int $actorId, string $newStatus): bool
    {
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

    public function saveNotification($data)
    {
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

    /**
     * Actualiza el campo payment_status y devuelve TRUE si al menos una fila fue afectada.
     */
    public function updatePaymentStatus(int $id, string $status): bool
    {
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

    /* ----------  MÉTODOS PARA CANCELACIÓN  ---------- */
    public function cancel(int $requestId, int $actorId, string $actorRole): bool
    {
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

    public function existsOpenRequest(int $userId, int $serviceId, int $providerId): bool
    {
        $sql = "SELECT id FROM service_requests
                WHERE user_id = :user
                  AND service_id = :service
                  AND provider_id = :provider
                  AND status IN ('pending','accepted','in_progress')
                LIMIT 1";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute([
            ':user'     => $userId,
            ':service'  => $serviceId,
            ':provider' => $providerId
        ]);
        return (bool) $stmt->fetchColumn();
    }

    public function getCancellationInfo(int $requestId): ?array
    {
        $sql = "SELECT status, cancelled_by FROM {$this->table} WHERE id = :id";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute([':id' => $requestId]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($row && $row['status'] === 'cancelled') {
            return ['cancelled_by' => $row['cancelled_by']];
        }
        return null;
    }

    /* ----------------------------------------------------------
       N U E V O S   M É T O D O S   P A R A   C E R R A R
       ---------------------------------------------------------- */
    /**
     * Cierra la request (completed | cancelled | rejected)
     * y la traslada al historial.
     */
    public function close(int $reqId, string $finalStatus): void
    {
        if (!in_array($finalStatus, ['completed', 'cancelled', 'rejected'], true)) {
            throw new InvalidArgumentException('Estado no válido');
        }
        $this->closeRequest($this->conn, $reqId, $finalStatus);
    }

    /**
     * Lógica interna: procedimiento si existe, fallback si no.
     */
    private function closeRequest(PDO $pdo, int $reqId, string $status): void
    {
        try {
            // ¿Existe procedimiento?
            $hasProc = (bool) $pdo->query(
                "SELECT COUNT(*) FROM mysql.proc WHERE name = 'close_request'"
            )->fetchColumn();

            if ($hasProc) {
                $pdo->prepare("CALL close_request(:id, :st)")
                    ->execute(['id' => $reqId, 'st' => $status]);
                return;
            }

            // Fallback manual
            $pdo->beginTransaction();

            /* --------------------------------------------------
             * 1. Leer datos de pago ANTES de borrar la request
             * -------------------------------------------------- */
            $payData = $pdo->prepare("SELECT payment_status, payment_method FROM service_requests WHERE id = ?");
            $payData->execute([$reqId]);
            $payRow  = $payData->fetch(PDO::FETCH_ASSOC);

            $finStatus = $payRow['payment_status'] ?? 'pending';
            $finMethod = $payRow['payment_method'] ?? null;

            /* --------------------------------------------------
             * 2. INSERTAR en el historial CON los datos de pago
             * -------------------------------------------------- */
            $sql = "INSERT INTO service_history
                      (user_id, service_id, request_id, service_title, service_price,
                       provider_name, status, finished_at, provider_id,
                       payment_status, payment_method)
                    SELECT r.user_id, r.service_id, r.id,
                           s.title, s.price, s.provider_name, :st, NOW(), r.provider_id,
                           :payStatus, :payMethod
                    FROM   service_requests r
                    JOIN   services s ON s.id = r.service_id
                    WHERE  r.id = :id";
            $stmt = $pdo->prepare($sql);
            $stmt->execute([
                ':id'         => $reqId,
                ':st'         => $status,
                ':payStatus'  => $finStatus,
                ':payMethod'  => $finMethod
            ]);

            // 3. Borrar el pago asociado
            $stmtPay = $pdo->prepare("DELETE FROM payments WHERE service_request_id = ?");
            $stmtPay->execute([$reqId]);

            // 4. Borrar la request
            $stmtReq = $pdo->prepare("DELETE FROM service_requests WHERE id = ?");
            $stmtReq->execute([$reqId]);

            $pdo->commit();
        } catch (Throwable $e) {
            $pdo->inTransaction() && $pdo->rollBack();
            throw $e;
        }
    }
}

