<?php
require_once __DIR__ . '/../config/database.php';

class SupportModel {
    private $conn;
    private $table = 'support_tickets';

    public function __construct() {
        $this->conn = (new Database())->getConnection();
    }

    /**
     * Crear un ticket
     */
    public function createTicket(array $data): int {
        $query = "INSERT INTO {$this->table}
                  (user_id, subject, description, category, status, created_at, updated_at)
                  VALUES (:user_id, :subject, :description, :category, 'open', NOW(), NOW())";

        $stmt = $this->conn->prepare($query);
        $stmt->execute([
            ':user_id'    => $data['user_id'],
            ':subject'    => $data['subject'],
            ':description'=> $data['description'],
            ':category'   => $data['category']
        ]);

        return $this->conn->lastInsertId();
    }

    /**
     * Obtener tickets de un usuario
     */
    public function getTicketsByUser(int $userId): array {
        $query = "SELECT id, subject, description, category, status, created_at, updated_at
                  FROM {$this->table}
                  WHERE user_id = :user_id
                  ORDER BY created_at DESC";

        $stmt = $this->conn->prepare($query);
        $stmt->execute([':user_id' => $userId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Cambiar estado del ticket
     */
    public function updateStatus(int $id, string $status): bool {
        $query = "UPDATE {$this->table}
                  SET status = :status, updated_at = NOW()
                  WHERE id = :id";

        $stmt = $this->conn->prepare($query);
        return $stmt->execute([':status' => $status, ':id' => $id]);
    }
}
