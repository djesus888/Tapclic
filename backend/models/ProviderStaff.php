<?php
require_once __DIR__ . '/../config/database.php';

class ProviderStaff {
    private $conn;
    private $table = 'provider_staff';

    public function __construct() {
        $this->conn = (new Database())->getConnection();
    }

    public function create(array $data): int|bool {
        $sql = "INSERT INTO {$this->table} (provider_id, name, email, phone, password, role)
                VALUES (:provider_id, :name, :email, :phone, :password, :role)";
        $stmt = $this->conn->prepare($sql);
        $saved = $stmt->execute([
            ':provider_id' => $data['provider_id'],
            ':name'        => $data['name'],
            ':email'       => $data['email'] ?? null,
            ':phone'       => $data['phone'] ?? null,
            ':password'    => password_hash($data['password'], PASSWORD_DEFAULT),
            ':role'        => $data['role'] ?? 'delivery',
        ]);
        return $saved ? (int)$this->conn->lastInsertId() : false;
    }

    public function findByProvider(int $providerId): array {
        $stmt = $this->conn->prepare("SELECT * FROM {$this->table} WHERE provider_id = :pid AND active = 1 ORDER BY name");
        $stmt->execute([':pid' => $providerId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function findById(int $id): ?array {
        $stmt = $this->conn->prepare("SELECT * FROM {$this->table} WHERE id = :id LIMIT 1");
        $stmt->execute([':id' => $id]);
        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
    }

    public function findByEmail(string $email): ?array {
        $stmt = $this->conn->prepare("SELECT * FROM {$this->table} WHERE email = :email LIMIT 1");
        $stmt->execute([':email' => $email]);
        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
    }

    public function update(int $id, array $data): bool {
        $sql = "UPDATE {$this->table} SET name = :name, phone = :phone, role = :role, active = :active WHERE id = :id";
        $stmt = $this->conn->prepare($sql);
        return $stmt->execute([
            ':name'   => $data['name'],
            ':phone'  => $data['phone'] ?? null,
            ':role'   => $data['role'] ?? 'delivery',
            ':active' => $data['active'] ?? 1,
            ':id'     => $id,
        ]);
    }

    public function updateProfile(int $id, array $data): bool {
        $fields = [];
        $params = [':id' => $id];

        if (isset($data['name'])) {
            $fields[] = 'name = :name';
            $params[':name'] = $data['name'];
        }
        if (isset($data['email'])) {
            $fields[] = 'email = :email';
            $params[':email'] = $data['email'];
        }
        if (isset($data['phone'])) {
            $fields[] = 'phone = :phone';
            $params[':phone'] = $data['phone'];
        }
        if (isset($data['avatar_url'])) {
            $fields[] = 'avatar_url = :avatar_url';
            $params[':avatar_url'] = $data['avatar_url'];
        }

        if (empty($fields)) {
            return false;
        }

        $sql = "UPDATE {$this->table} SET " . implode(', ', $fields) . " WHERE id = :id";
        $stmt = $this->conn->prepare($sql);
        return $stmt->execute($params);
    }

    public function updatePassword(int $id, string $newPassword): bool {
        $sql = "UPDATE {$this->table} SET password = :password WHERE id = :id";
        $stmt = $this->conn->prepare($sql);
        return $stmt->execute([
            ':password' => password_hash($newPassword, PASSWORD_DEFAULT),
            ':id'       => $id,
        ]);
    }

    // ✅ NUEVO: Actualizar estado online
    public function updateOnlineStatus(int $id, bool $isOnline): bool {
        $sql = "UPDATE {$this->table} 
                SET is_online = :is_online, 
                    last_seen = CASE WHEN :is_online = 1 THEN last_seen ELSE NOW() END
                WHERE id = :id";
        $stmt = $this->conn->prepare($sql);
        return $stmt->execute([
            ':is_online' => $isOnline ? 1 : 0,
            ':id' => $id
        ]);
    }



/**
 * Marcar como offline a staff que no ha enviado heartbeat
 * dentro del tiempo límite
 */
public function markOfflineByTimeout(int $timeoutMinutes = 5): int {
    $sql = "UPDATE {$this->table} 
            SET is_online = 0, 
                last_seen = NOW() 
            WHERE is_online = 1 
            AND active = 1
            AND last_heartbeat IS NOT NULL
            AND last_heartbeat < DATE_SUB(NOW(), INTERVAL :timeout MINUTE)";
    $stmt = $this->conn->prepare($sql);
    $stmt->execute([':timeout' => $timeoutMinutes]);
    return $stmt->rowCount();
}



    // ✅ NUEVO: Actualizar heartbeat
    public function updateHeartbeat(int $id): bool {
        $sql = "UPDATE {$this->table} 
                SET is_online = 1, 
                    last_heartbeat = NOW() 
                WHERE id = :id";
        $stmt = $this->conn->prepare($sql);
        return $stmt->execute([':id' => $id]);
    }

    public function delete(int $id): bool {
        $stmt = $this->conn->prepare("UPDATE {$this->table} SET active = 0 WHERE id = :id");
        return $stmt->execute([':id' => $id]);
    }
}
