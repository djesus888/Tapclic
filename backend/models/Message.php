<?php
// models/Message.php

require_once __DIR__ . '/../config/database.php';

class Message {

    private $db;

    public function __construct() {
        $this->db = (new Database())->connect();
    }

    /**
     * Obtener todos los mensajes entre un usuario y un driver
     */
    public function getMessages($userId, $driverId) {
        $userId = intval($userId);
        $driverId = intval($driverId);

        $stmt = $this->db->prepare("
            SELECT
                m.id, m.sender_id, m.receiver_id, m.text, m.type, m.status, m.created_at,
                m.attachment_url, m.parent_id, m.read_at, m.metadata,
                u.avatar_url, u.name, u.role
            FROM messages m
            LEFT JOIN users u ON u.id = m.sender_id
            WHERE (m.sender_id = :userId AND m.receiver_id = :driverId)
               OR (m.sender_id = :driverId AND m.receiver_id = :userId)
            ORDER BY m.created_at ASC
        ");
        $stmt->execute([
            'userId' => $userId,
            'driverId' => $driverId
        ]);

        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        if (!$rows) $rows = [];

        return array_map(fn($msg) => $this->mapMessage($msg, $userId), $rows);
    }

    /**
     * Insertar un nuevo mensaje
     */
  public function insertMessage($senderId, $receiverId, $text, $type = 'text', $attachment_url = null, $parent_id = null, $metadata = null) {
    $senderId = intval($senderId);
    $receiverId = intval($receiverId);
    $text = trim($text);

    if (!$receiverId || (!$text && !$attachment_url)) return null;

    // Insertamos el mensaje en la base de datos
    $stmt = $this->db->prepare("
        INSERT INTO messages (sender_id, receiver_id, text, type, attachment_url, parent_id, metadata, status, created_at)
        VALUES (:sender_id, :receiver_id, :text, :type, :attachment_url, :parent_id, :metadata, 'sent', NOW())
    ");
    $success = $stmt->execute([
        'sender_id' => $senderId,
        'receiver_id' => $receiverId,
        'text' => $text,
        'type' => $type,
        'attachment_url' => $attachment_url,
        'parent_id' => $parent_id,
        'metadata' => $metadata
    ]);

    if (!$success) return null;

    // Obtenemos el ID del mensaje insertado
    $id = $this->db->lastInsertId();

    // Obtenemos el mensaje completo y lo mapeamos a formato consistente
    $stmt = $this->db->prepare("
        SELECT m.id, m.sender_id, m.receiver_id, m.text, m.type, m.status, m.created_at,
               m.attachment_url, m.parent_id, m.read_at, m.metadata,
               u.avatar_url, u.name, u.role
        FROM messages m
        LEFT JOIN users u ON u.id = m.sender_id
        WHERE m.id = :id
    ");
    $stmt->execute(['id' => intval($id)]);
    $msg = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$msg) return null;

    return [
        "id" => intval($msg['id']),
        "text" => $msg['text'],
        "sender" => ($msg['role'] === 'driver' || $msg['role'] === 'provider' ? 'provider' : 'user'),
        "type" => $msg['type'],
        "status" => $msg['status'],
        "created_at" => $msg['created_at'],
        "avatar_url" => $msg['avatar_url'] ?? '',
        "attachment_url" => $msg['attachment_url'] ?? null,
        "parent_id" => $msg['parent_id'] ?? null,
        "read_at" => $msg['read_at'] ?? null,
        "metadata" => $msg['metadata'] ?? null,
        "sender_name" => $msg['name'] ?? ($msg['role'] === 'driver' ? 'Proveedor' : 'Usuario')
    ];
}

    /**
     * Recuperar un mensaje por ID
     */
    public function getMessageById($id, $loggedUserId = null) {
        $stmt = $this->db->prepare("
            SELECT
                m.id, m.sender_id, m.receiver_id, m.text, m.type, m.status, m.created_at,
                m.attachment_url, m.parent_id, m.read_at, m.metadata,
                u.avatar_url, u.name, u.role
            FROM messages m
            LEFT JOIN users u ON u.id = m.sender_id
            WHERE m.id = :id
        ");
        $stmt->execute(['id' => intval($id)]);
        $msg = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$msg) return null;

        return $this->mapMessage($msg, $loggedUserId);
    }

    /**
     * Mapear mensaje a formato consistente para frontend
     */
    private function mapMessage($msg, $loggedUserId = null) {
        return [
            "id" => intval($msg['id']),
            "text" => $msg['text'],
            "sender" => ($msg['role'] === 'driver' ? 'provider' : 'user'),
            "type" => $msg['type'],
            "status" => $msg['status'],
            "created_at" => $msg['created_at'],
            "avatar_url" => $msg['avatar_url'] ?? null,
            "attachment_url" => $msg['attachment_url'] ?? null,
            "parent_id" => $msg['parent_id'] ?? null,
            "read_at" => $msg['read_at'] ?? null,
            "metadata" => $msg['metadata'] ?? null,
            "name" => $msg['name'] ??  null
        ];
    }

    /**
     * Marcar mensaje como leído
     */
    public function markAsRead($messageId) {
        $stmt = $this->db->prepare("
            UPDATE messages SET status = 'read', read_at = NOW() WHERE id = :id
        ");
        return $stmt->execute(['id' => intval($messageId)]);
    }
}
