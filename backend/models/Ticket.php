<?php
// backend/models/Ticket.php

require_once __DIR__ . '/../config/database.php';

class Ticket {
    private $conn;
    private $table = 'support_tickets';
    private $repliesTable = 'ticket_replies';

    public function __construct() {
        $this->conn = (new Database())->getConnection();
    }

    /**
     * Obtener todos los tickets con filtros
     */
    public function getAllTickets($status = null, $page = 1, $limit = 20) {
        $offset = ($page - 1) * $limit;
        
        $sql = "SELECT t.*, u.name as user_name, u.email as user_email 
                FROM {$this->table} t
                LEFT JOIN users u ON t.user_id = u.id";
        
        $params = [];
        if ($status) {
            $sql .= " WHERE t.status = :status";
            $params[':status'] = $status;
        }
        
        $sql .= " ORDER BY t.created_at DESC LIMIT :limit OFFSET :offset";
        
        $stmt = $this->conn->prepare($sql);
        
        if ($status) {
            $stmt->bindParam(':status', $status);
        }
        $stmt->bindParam(':limit', $limit, PDO::PARAM_INT);
        $stmt->bindParam(':offset', $offset, PDO::PARAM_INT);
        
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Contar tickets (para paginación)
     */
    public function countTickets($status = null) {
        $sql = "SELECT COUNT(*) as total FROM {$this->table}";
        $params = [];
        
        if ($status) {
            $sql .= " WHERE status = :status";
            $params[':status'] = $status;
        }
        
        $stmt = $this->conn->prepare($sql);
        $stmt->execute($params);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        return $result['total'];
    }

    /**
     * Obtener ticket por ID
     */
    public function getTicketById($id) {
        $sql = "SELECT t.*, u.name as user_name, u.email as user_email 
                FROM {$this->table} t
                LEFT JOIN users u ON t.user_id = u.id
                WHERE t.id = :id";
        
        $stmt = $this->conn->prepare($sql);
        $stmt->execute([':id' => $id]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    /**
     * Obtener respuestas de un ticket
     */
    public function getTicketReplies($ticketId) {
        $sql = "SELECT r.*, u.name as user_name 
                FROM {$this->repliesTable} r
                LEFT JOIN users u ON r.user_id = u.id
                WHERE r.ticket_id = :ticket_id
                ORDER BY r.created_at ASC";
        
        $stmt = $this->conn->prepare($sql);
        $stmt->execute([':ticket_id' => $ticketId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Agregar respuesta a ticket
     */
    public function addReply($ticketId, $userId, $userType, $message) {
        $sql = "INSERT INTO {$this->repliesTable} 
                (ticket_id, user_id, user_type, message) 
                VALUES (:ticket_id, :user_id, :user_type, :message)";
        
        $stmt = $this->conn->prepare($sql);
        $stmt->execute([
            ':ticket_id' => $ticketId,
            ':user_id' => $userId,
            ':user_type' => $userType,
            ':message' => $message
        ]);
        
        return $this->conn->lastInsertId();
    }

    /**
     * Actualizar estado del ticket
     */
    public function updateStatus($id, $status) {
        $sql = "UPDATE {$this->table} 
                SET status = :status, updated_at = NOW() 
                WHERE id = :id";
        
        $stmt = $this->conn->prepare($sql);
        return $stmt->execute([
            ':status' => $status,
            ':id' => $id
        ]);
    }

    /**
     * Contar tickets creados hoy
     */
    public function countTicketsToday() {
        $sql = "SELECT COUNT(*) as total FROM {$this->table} 
                WHERE DATE(created_at) = CURDATE()";
        
        $stmt = $this->conn->prepare($sql);
        $stmt->execute();
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        return $result['total'];
    }

    /**
     * Obtener tiempo promedio de respuesta (en horas)
     */
    public function getAverageResponseTime() {
        $sql = "SELECT AVG(TIMESTAMPDIFF(HOUR, t.created_at, r.created_at)) as avg_time
                FROM {$this->table} t
                JOIN {$this->repliesTable} r ON t.id = r.ticket_id
                WHERE r.user_type = 'admin'";
        
        $stmt = $this->conn->prepare($sql);
        $stmt->execute();
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        return round($result['avg_time'] ?? 0, 1);
    }

    /**
     * Asignar ticket a un admin
     */
    public function assignToAdmin($id, $adminId) {
        $sql = "UPDATE {$this->table} 
                SET assigned_to = :admin_id, updated_at = NOW() 
                WHERE id = :id";
        
        $stmt = $this->conn->prepare($sql);
        return $stmt->execute([
            ':admin_id' => $adminId,
            ':id' => $id
        ]);
    }


/**
 * Obtener la conexión a la base de datos
 */
public function getDb() {
    return $this->conn;
}

}
