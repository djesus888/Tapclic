<?php
// models/Notification.php

require_once __DIR__ . '/../config/database.php';

class Notification {
    private $conn;
    private $table = 'notifications';

    public function __construct() {
        $this->conn = (new Database())->getConnection();
    }

    public function send($data) {
        $query = "INSERT INTO {$this->table}
                  (sender_id, receiver_id, receiver_role, title, message, data_json, is_read, created_at)
                  VALUES (:sender_id, :receiver_id, :receiver_role, :title, :message, :data_json, 0, NOW())";

        $stmt = $this->conn->prepare($query);

        return $stmt->execute([
            ':sender_id'     => $data['sender_id'],
            ':receiver_id'   => $data['receiver_id'],
            ':receiver_role' => $data['receiver_role'],
            ':title'         => $data['title'],
            ':message'       => $data['message'],
            ':data_json'     => $data['data_json'] ?? null
        ]);
    }

    public function getForUser($userId, $role) {
        $query = "SELECT id, title, message, data_json, is_read, created_at
                  FROM {$this->table}
                  WHERE receiver_id = :id AND receiver_role = :role
                  ORDER BY created_at DESC";

        $stmt = $this->conn->prepare($query);
        $stmt->execute([
            ':id'   => $userId,
            ':role' => $role
        ]);

        $notifications = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // Asegurar formato limpio para frontend
        foreach ($notifications as &$n) {
            $n['is_read'] = (bool) $n['is_read'];
            $n['created_at'] = $n['created_at'] ? date('c', strtotime($n['created_at'])) : null;
            $n['title'] = $n['title'] ?? '';
            $n['message'] = $n['message'] ?? '';
            $n['data_json'] = $n['data_json'] ?? null;
        }

        return $notifications;
    }

    public function markAsRead($id, $userId) {
        $query = "UPDATE {$this->table}
                  SET is_read = 1
                  WHERE id = :id AND receiver_id = :uid";

        $stmt = $this->conn->prepare($query);
        return $stmt->execute([
            ':id'  => $id,
            ':uid' => $userId
        ]);
    }
}
?>
