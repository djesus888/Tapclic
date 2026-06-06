<?php
require_once __DIR__ . '/../config/database.php';

class SupportModel {
    private $conn;
    private $table = 'support_tickets';

    /**
     * Campos permitidos para actualización (evita inyección SQL)
     */
    private const ALLOWED_UPDATE_FIELDS = ['subject', 'description', 'category'];

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

        return (int)$this->conn->lastInsertId();
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
     * Obtener ticket por ID
     */
    public function getTicketById(int $id): ?array {
        $query = "SELECT * FROM {$this->table} WHERE id = :id";
        $stmt = $this->conn->prepare($query);
        $stmt->execute([':id' => $id]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        return $result ?: null;
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

    /**
     * Actualizar ticket con campos validados (previene inyección SQL)
     */
    public function updateTicket(int $id, array $data): bool {
        $fields = [];
        $params = [];

        foreach ($data as $key => $value) {
            // Solo permitir campos definidos en la lista blanca
            if (!in_array($key, self::ALLOWED_UPDATE_FIELDS, true)) {
                continue;
            }
            $fields[] = "`$key` = :$key";
            $params[":$key"] = $value;
        }

        if (empty($fields)) {
            return false;
        }

        $fieldsStr = implode(', ', $fields);
        $params[':id'] = $id;

        $query = "UPDATE {$this->table} SET $fieldsStr, updated_at = NOW() WHERE id = :id";
        $stmt = $this->conn->prepare($query);
        return $stmt->execute($params);
    }

    /**
     * Agregar respuesta a un ticket
     */
    public function addReply(int $ticketId, int $userId, string $message): int {
        $query = "INSERT INTO ticket_replies (ticket_id, user_id, message, created_at)
                  VALUES (:ticket_id, :user_id, :message, NOW())";
        $stmt = $this->conn->prepare($query);
        $stmt->execute([
            ':ticket_id' => $ticketId,
            ':user_id'   => $userId,
            ':message'   => $message
        ]);
        return (int)$this->conn->lastInsertId();
    }

    /**
     * Actualizar timestamp del ticket
     */
    public function updateTimestamp(int $id): bool {
        $query = "UPDATE {$this->table} SET updated_at = NOW() WHERE id = :id";
        $stmt = $this->conn->prepare($query);
        return $stmt->execute([':id' => $id]);
    }

    /**
     * Obtener respuestas de un ticket con info del usuario
     */
    public function getRepliesByTicket(int $ticketId): array {
        $query = "SELECT tr.*, u.name as user_name, u.avatar_url
                  FROM ticket_replies tr
                  JOIN users u ON tr.user_id = u.id
                  WHERE tr.ticket_id = :tid
                  ORDER BY tr.created_at ASC";
        $stmt = $this->conn->prepare($query);
        $stmt->execute([':tid' => $ticketId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}
