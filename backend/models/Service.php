<?php
// models/Service.php

require_once __DIR__ . '/../config/database.php';

class Service {
    private $conn;
    private $table = 'services';

    public function __construct() {
        $this->conn = (new Database())->getConnection();
}
public function create(array $data): bool
{
    $sql = "INSERT INTO {$this->table}
            (user_id, title, description, status, price, category, location,
             image_url, provider_name, provider_avatar_url, provider_rating, isAvailable)
            VALUES
            (:user_id, :title, :description, :status, :price, :category, :location,
             :image_url, :provider_name, :provider_avatar_url, :provider_rating, :isAvailable)";

    $stmt = $this->conn->prepare($sql);

    try {
        return $stmt->execute([
            ':user_id'             => $data['user_id'],
            ':title'               => $data['title'],
            ':description'         => $data['description'],
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
    } catch (PDOException $e) {
        error_log($e->getMessage());
        http_response_code(500);
        echo json_encode(['error' => $e->getMessage()]);
        return false;
    }
}


    public function getByUser($userId) {
        $stmt = $this->conn->prepare("SELECT * FROM {$this->table} WHERE user_id = ? ORDER BY created_at DESC");
        $stmt->execute([$userId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getAll() {
        $stmt = $this->conn->query("SELECT * FROM {$this->table} ORDER BY created_at DESC");
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function update($id, $userId, $data) {
        $query = "UPDATE {$this->table} 
                  SET title = :title, 
                      description = :description, 
                      status = :status,
                      price = :price,
                      category = :category,
                      location = :location,
                      image_url = :image_url
                  WHERE id = :id AND user_id = :user_id";
        
        $stmt = $this->conn->prepare($query);
        return $stmt->execute([
            ':title' => $data['title'],
            ':description' => $data['description'],
            ':status' => $data['status'] ?? 'pending',
            ':price' => $data['price'] ?? 0.00,
            ':category' => $data['category'] ?? null,
            ':location' => $data['location'] ?? null,
            ':image_url' => $data['image_url'] ?? null,
            ':id' => $id,
            ':user_id' => $userId
        ]);
    }

    public function delete($id, $userId) {
        $stmt = $this->conn->prepare("DELETE FROM {$this->table} WHERE id = ? AND user_id = ?");
        return $stmt->execute([$id, $userId]);
    }

    public function getAvailable($userId) {
        $stmt = $this->conn->prepare(
            "SELECT * FROM {$this->table} 
             WHERE user_id != ? 
             AND status = 'active' 
             AND isAvailable = 1 
             ORDER BY created_at DESC"
        );
        $stmt->execute([$userId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}
