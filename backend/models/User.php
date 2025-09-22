<?php
// models/User.php

require_once __DIR__ . '/../config/database.php';

class User {
    private $conn;
    private $table = 'users';

    public function __construct() {
        $this->conn = (new Database())->getConnection();
    }

    public function findByEmailOrPhone($identifier) {
        // Devuelve también password para verificación en login
        $query = "SELECT id, name, email, phone, role, password FROM {$this->table} WHERE email = :id OR phone = :id LIMIT 1";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $identifier);
        $stmt->execute();
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    public function findByEmail($email) {
        $stmt = $this->conn->prepare("SELECT id FROM {$this->table} WHERE email = ? LIMIT 1");
        $stmt->execute([$email]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    public function findByPhone($phone) {
        $stmt = $this->conn->prepare("SELECT id FROM {$this->table} WHERE phone = ? LIMIT 1");
        $stmt->execute([$phone]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    public function create($data) {
        $query = "INSERT INTO {$this->table} (name, email, phone, password, role)
                  VALUES (:name, :email, :phone, :password, :role)";
        $stmt = $this->conn->prepare($query);
        $stmt->execute([
            ':name'     => $data['name'],
            ':email'    => $data['email'],
            ':phone'    => $data['phone'],
            ':password' => password_hash($data['password'], PASSWORD_DEFAULT),
            ':role'     => $data['role']
        ]);
        return $this->conn->lastInsertId();
    }

    public function find(int $id): ?array{
        $stmt = $this->conn->prepare("SELECT id, name, avatar_url, average_rating FROM users WHERE id = ? LIMIT 1");
        $stmt->execute([$id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row ?: null;
    }

    public function findById($id) {
        $stmt = $this->conn->prepare("SELECT id, name, email, password, phone, role, avatar_url, address, business_address, service_categories, coverage_area, preferences  FROM {$this->table} WHERE id = ?");
        $stmt->execute([$id]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    public function updateProfile($id, $data) {
        $name = $data['name'] ?? '';
        $email = $data['email'] ?? '';
        $phone = $data['phone'] ?? '';

        $query = "UPDATE {$this->table} SET
                    name = :name,
                    email = :email,
                    phone = :phone,
                    address = :address,
                    business_address = :business_address,
                    service_categories = :service_categories,
                    coverage_area = :coverage_area,
                    preferences = :preferences
                    WHERE id = :id";
        $stmt = $this->conn->prepare($query);
        return $stmt->execute([
            ':name' => $data['name'],
            ':email' => $data['email'],
            ':phone' => $data['phone'],
            ':address' => $data['address'],
            ':business_address' => $data['business_address'],
            ':service_categories' => $data['service_categories'],
            ':coverage_area' => $data['coverage_area'],
            ':preferences' => $data['preferences'],
            ':id' => $id
        ]);
    }

    public function updateLastSeen(int $userId): void
    {
        $sql = "UPDATE users SET last_seen_at = NOW() WHERE id = :id";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute([':id' => $userId]);
    }

    public function updatePassword($id, $newPassword) {
        $hash = password_hash($newPassword, PASSWORD_DEFAULT);
        $query = "UPDATE {$this->table} SET password = :pwd WHERE id = :id";
        $stmt = $this->conn->prepare($query);
        return $stmt->execute([':pwd' => $hash, ':id' => $id]);
    }

    public function updatePreferences($id, $preferences) {
        $query = "UPDATE {$this->table} SET preferences = :prefs WHERE id = :id";
        $stmt = $this->conn->prepare($query);
        return $stmt->execute([':prefs' => json_encode($preferences), ':id' => $id]);
    }

    public function updateAvatar($id, $url) {
        $stmt = $this->conn->prepare("UPDATE {$this->table} SET avatar_url = ? WHERE id = ?");
        return $stmt->execute([$url, $id]);
    }

    public function updateProviderData($id, $data) {
        $query = "UPDATE {$this->table}
                  SET business_address = :addr, service_categories = :cat, coverage_area = :area
                  WHERE id = :id";
        $stmt = $this->conn->prepare($query);
        return $stmt->execute([
            ':addr' => $data['business_address'],
            ':cat'  => json_encode($data['service_categories']),
            ':area' => $data['coverage_area'],
            ':id'   => $id
        ]);
    }
}
