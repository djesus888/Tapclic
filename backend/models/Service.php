<?php
// backend/models/Service.php

require_once __DIR__ . '/../config/database.php';

class Service
{
    private $conn;
    private string $table = 'services';

    public function __construct()
    {
        $this->conn = (new Database())->getConnection();
    }

    /* ----------  CREATE  ---------- */
    public function create(array $data): bool
    {
        $sql = "INSERT INTO {$this->table}
                (user_id, title, description, service_details, status, price, category, location,
                 image_url, provider_name, provider_avatar_url, provider_rating, isAvailable)
                VALUES
                (:user_id, :title, :description, :service_details, :status, :price, :category, :location,
                 :image_url, :provider_name, :provider_avatar_url, :provider_rating, :isAvailable)";

        $stmt = $this->conn->prepare($sql);

        return $stmt->execute([
            ':user_id'             => $data['user_id'],
            ':title'               => $data['title'],
            ':description'         => $data['description'],
            ':service_details'     => $data['service_details'] ?? null,
            ':status'              => $data['status'] ?? 'pending',
            ':price'               => $data['price'] ?? 0,
            ':category'            => $data['category'] ?? null,
            ':location'            => $data['location'] ?? null,
            ':image_url'           => $data['image_url'] ?? null,
            ':provider_name'       => $data['provider_name'] ?? null,
            ':provider_avatar_url' => $data['provider_avatar_url'] ?? null,
            ':provider_rating'     => $data['provider_rating'] ?? 5.0,
            ':isAvailable'         => $data['isAvailable'] ?? 1,
        ]);
    }

    /* ----------  READ  ---------- */
    public function getByUser(int $userId): array
    {
        $stmt = $this->conn->prepare("SELECT * FROM {$this->table} WHERE user_id = ? ORDER BY created_at DESC");
        $stmt->execute([$userId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getAll(): array
    {
        $stmt = $this->conn->query("SELECT * FROM {$this->table} ORDER BY created_at DESC");
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getAvailable(int $userId): array
    {
        $sql = "
            SELECT
                s.*,
                u.avatar_url  AS provider_avatar_url,
                u.address     AS provider_address,
                u.phone       AS provider_phone,
                (
                    SELECT JSON_ARRAYAGG(
                        JSON_OBJECT(
                            'method_type',    ppm.method_type,
                            'bank_name',      ppm.bank_name,
                            'holder_name',    ppm.holder_name,
                            'id_number',      ppm.id_number,
                            'phone_number',   ppm.phone_number,
                            'account_number', ppm.account_number,
                            'email',          ppm.email
                        )
                    )
                    FROM provider_payment_methods ppm
                    WHERE ppm.provider_id = s.user_id
                      AND ppm.is_active   = 1
                      AND ppm.method_type IN ('pago_movil','transferencia','paypal','zelle','binance')
                ) AS payment_methods
            FROM {$this->table} s
            JOIN users u ON u.id = s.user_id
            WHERE s.status     = 'active'
              AND s.isAvailable = 1
            ORDER BY s.created_at DESC
        ";

        $stmt = $this->conn->prepare($sql);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /* ----------  UPDATE  ---------- */
    public function update(int $id, int $userId, array $data): bool
    {
        $fields = [
            'title'           => $data['title']           ?? null,
            'description'     => $data['description']     ?? null,
            'service_details' => $data['service_details'] ?? null,
            'price'           => $data['price']           ?? null,
            'category'        => $data['category']        ?? null,
            'location'        => $data['location']        ?? null,
            'status'          => $data['status']          ?? null,
            'image_url'       => $data['image_url']       ?? null,
        ];

        $fields = array_filter($fields, fn($v) => $v !== null);
        if (!$fields) return false;

        $set = implode(', ', array_map(fn($col) => "$col = :$col", array_keys($fields)));
        $sql = "UPDATE {$this->table} SET $set WHERE id = :id AND user_id = :userId";

        $stmt = $this->conn->prepare($sql);
        return $stmt->execute(array_merge($fields, [':id' => $id, ':userId' => $userId]));
    }

    /* ----------  DELETE  ---------- */
    public function delete(int $id, int $userId): bool
    {
        $stmt = $this->conn->prepare("DELETE FROM {$this->table} WHERE id = ? AND user_id = ?");
        return $stmt->execute([$id, $userId]);
    }
}
