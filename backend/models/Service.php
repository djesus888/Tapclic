<?php
// models/Service.php

require_once __DIR__ . '/../config/database.php';

class Service {
    private $conn;
    private $table = 'services';

    public function __construct() {
        $this->conn = (new Database())->getConnection();
    }

    public function create($data) {
        $query = "INSERT INTO {$this->table} (user_id, title, description, status)
                  VALUES (:user_id, :title, :description, :status)";
        $stmt = $this->conn->prepare($query);
        return $stmt->execute([
            ':user_id' => $data['user_id'],
            ':title' => $data['title'],
            ':description' => $data['description'],
            ':status' => $data['status'] ?? 'pending'
        ]);
    }

    public function getByUser($userId) {
        $stmt = $this->conn->prepare("SELECT * FROM {$this->table} WHERE user_id = ?");
        $stmt->execute([$userId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getAll() {
        $stmt = $this->conn->query("SELECT * FROM {$this->table}");
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function update($id, $userId, $data) {
        $query = "UPDATE {$this->table} SET title = :title, description = :description, status = :status
                  WHERE id = :id AND user_id = :user_id";
        $stmt = $this->conn->prepare($query);
        return $stmt->execute([
            ':title' => $data['title'],
            ':description' => $data['description'],
            ':status' => $data['status'],
            ':id' => $id,
            ':user_id' => $userId
        ]);
    }

    public function delete($id, $userId) {
        $stmt = $this->conn->prepare("DELETE FROM {$this->table} WHERE id = ? AND user_id = ?");
        return $stmt->execute([$id, $userId]);
    }

    // Nuevo método para obtener servicios activos de otros usuarios
    public function getAvailable($userId) {
        $stmt = $this->conn->prepare("SELECT * FROM {$this->table} WHERE user_id != ? AND status = 'active'");
        $stmt->execute([$userId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}
