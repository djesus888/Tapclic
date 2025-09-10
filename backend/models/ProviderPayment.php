<?php
require_once __DIR__ . '/../config/database.php';

class ProviderPayment
{
    private $conn;
    private $table = 'provider_payment_methods';

    public function __construct()
    {
        $this->conn = (new Database())->getConnection();
    }

    /* ---------- CRUD ---------- */

    public function create(int $providerId, array $data): int
    {
        $stmt = $this->conn->prepare(
            "INSERT INTO {$this->table}
             (provider_id, method_type, bank_name, holder_name, id_number,
              phone_number, account_number, email, qr_url, is_active)
             VALUES
             (:pid, :mt, :bn, :hn, :idn, :pn, :an, :em, :qr, :active)"
        );
        $stmt->execute([
            ':pid'    => $providerId,
            ':mt'     => $data['method_type'],
            ':bn'     => $data['bank_name']      ?? null,
            ':hn'     => $data['holder_name'],
            ':idn'    => $data['id_number'],
            ':pn'     => $data['phone_number']  ?? null,
            ':an'     => $data['account_number']?? null,
            ':em'     => $data['email']         ?? null,
            ':qr'     => $data['qr_url']        ?? null,
            ':active' => $data['is_active']     ?? 1
        ]);
        return (int)$this->conn->lastInsertId();
    }

    public function getByProvider(int $providerId): array
    {
        $stmt = $this->conn->prepare(
            "SELECT * FROM {$this->table}
             WHERE provider_id = :pid
             ORDER BY created_at DESC"
        );
        $stmt->execute([':pid' => $providerId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getActiveByProvider(int $providerId): array
    {
        $stmt = $this->conn->prepare(
            "SELECT * FROM {$this->table}
             WHERE provider_id = :pid AND is_active = 1"
        );
        $stmt->execute([':pid' => $providerId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function update(int $id, int $providerId, array $data): bool
    {
        $stmt = $this->conn->prepare(
            "UPDATE {$this->table}
                SET method_type    = :mt,
                    bank_name      = :bn,
                    holder_name    = :hn,
                    id_number      = :idn,
                    phone_number   = :pn,
                    account_number = :an,
                    email          = :em,
                    qr_url         = :qr,
                    is_active      = :active
              WHERE id = :id AND provider_id = :pid"
        );
        $stmt->execute([
            ':id'     => $id,
            ':pid'    => $providerId,
            ':mt'     => $data['method_type'],
            ':bn'     => $data['bank_name']      ?? null,
            ':hn'     => $data['holder_name'],
            ':idn'    => $data['id_number'],
            ':pn'     => $data['phone_number']  ?? null,
            ':an'     => $data['account_number']?? null,
            ':em'     => $data['email']         ?? null,
            ':qr'     => $data['qr_url']        ?? null,
            ':active' => $data['is_active']     ?? 1
        ]);
        return $stmt->rowCount() > 0;
    }

    public function delete(int $id, int $providerId): bool
    {
        $stmt = $this->conn->prepare(
            "DELETE FROM {$this->table}
             WHERE id = :id AND provider_id = :pid"
        );
        $stmt->execute([':id' => $id, ':pid' => $providerId]);
        return $stmt->rowCount() > 0;
    }
}
