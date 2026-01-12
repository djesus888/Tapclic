<?php
// models/Message.php

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/Conversation.php';

use services\WebSocketService;

class Message
{
    private $db;

    public function __construct()
    {
        $this->db = (new Database())->getConnection();
    }

    // ✅ CORREGIDO: Ahora acepta senderType y receiverType
    public function getMessages(int $senderId, int $receiverId, string $senderType, string $receiverType): array
    {
        $conv = new Conversation();
        $conversationId = $conv->findOrCreate($senderId, $senderType, $receiverId, $receiverType);
        return $this->getMessagesByConversation($conversationId);
    }

    public function getMessagesByConversation(int $conversationId): array
    {
        $stmt = $this->db->prepare("
            SELECT
                m.id,
                m.sender_id,
                m.receiver_id,
                m.text,
                m.type,
                m.status,
                m.created_at,
                m.updated_at,
                m.attachment_url,
                m.metadata,
                m.read_at,
                m.sender_type,
                u.avatar_url,
                u.name
            FROM messages m
            LEFT JOIN users u ON u.id = m.sender_id
            WHERE m.conversation_id = :convId
            ORDER BY m.created_at ASC
        ");
        $stmt->execute(['convId' => $conversationId]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        return array_map(fn($r) => $this->mapMessage($r), $rows ?: []);
    }

    public function getLastMessage(int $conversationId): ?array
    {
        $stmt = $this->db->prepare("
            SELECT
                m.id,
                m.text,
                m.created_at
            FROM messages m
            WHERE m.conversation_id = :convId
            ORDER BY m.created_at DESC
            LIMIT 1
        ");
        $stmt->execute(['convId' => $conversationId]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row ?: null;
    }

    public function countUnread(int $conversationId, int $userId): int
    {
        $stmt = $this->db->prepare("
            SELECT COUNT(*) AS c
            FROM messages m
            WHERE m.conversation_id = :convId
              AND m.receiver_id = :uid
              AND m.read_at IS NULL
        ");
        $stmt->execute([
            'convId' => $conversationId,
            'uid'    => $userId,
        ]);
        return (int)$stmt->fetchColumn();
    }

    // ✅ CORREGIDO: Ahora acepta conversation_id como primer parámetro
    public function insertMessage(
        int    $conversationId,  // NUEVO: primer parámetro
        int    $senderId,
        int    $receiverId,
        string $text,
        string $type = 'text',
        ?string $attachment_url = null,
        string $senderType = 'user'
    ): array {
        $text = trim($text);

        if (!$receiverId || ($text === '' && !$attachment_url)) {
            throw new InvalidArgumentException('Faltan datos requeridos');
        }

        $allowed = ['text', 'image', 'file', 'audio', 'video', 'system'];
        $type    = in_array($type, $allowed, true) ? $type : 'text';

        try {
            $this->db->beginTransaction();

            $stmt = $this->db->prepare("
                INSERT INTO messages
                (conversation_id, sender_id, receiver_id, text, type,
                 attachment_url, status, sender_type, created_at, updated_at)
                VALUES
                (:conv, :s, :r, :t, :ty,
                 :att, 'sent', :st, NOW(), NOW())
            ");
            $stmt->execute([
                'conv' => $conversationId,
                's'    => $senderId,
                'r'    => $receiverId,
                't'    => $text,
                'ty'   => $type,
                'att'  => $attachment_url,
                'st'   => $senderType,
            ]);

            $id = (int)$this->db->lastInsertId();
            $this->db->commit();
            return $this->getMessageById($id);
        } catch (Throwable $e) {
            $this->db->rollBack();
            error_log("❌ insertMessage error: " . $e->getMessage());
            WebSocketService::emit([
                'receiver_id'   => 1,
                'receiver_role' => 'admin',
                'title'         => 'Error al guardar mensaje',
                'message'       => "Error: " . $e->getMessage(),
            ]);
            throw $e;
        }
    }

    public function getMessageById(int $id): array
    {
        $stmt = $this->db->prepare("
            SELECT
                m.id,
                m.conversation_id,
                m.sender_id,
                m.receiver_id,
                m.text,
                m.type,
                m.status,
                m.created_at,
                m.updated_at,
                m.attachment_url,
                m.metadata,
                m.read_at,
                m.sender_type,
                u.avatar_url,
                u.name
            FROM messages m
            LEFT JOIN users u ON u.id = m.sender_id
            WHERE m.id = :id
            LIMIT 1
        ");
        $stmt->execute(['id' => $id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $this->mapMessage($row);
    }

    public function markReadBatch(array $ids, int $readerId): int
    {
        if (empty($ids)) return 0;

        $placeholders = implode(',', array_fill(0, count($ids), '?'));
        $sql = "UPDATE messages
                SET read_at = NOW()
                WHERE id IN ($placeholders)
                  AND receiver_id = ?
                  AND read_at IS NULL";
        $stmt = $this->db->prepare($sql);
        $stmt->execute([...$ids, $readerId]);
        return $stmt->rowCount();
    }

    public function markRead(int $messageId, int $readerId): int
    {
        return $this->markReadBatch([$messageId], $readerId);
    }

    private function mapMessage(array $msg): array
    {                                                         return [
            'id'             => (int)$msg['id'],
            'conversation_id'=> (int)($msg['conversation_id'] ?? 0),
            'text'           => $msg['text'] ?? '',
            'sender'         => $msg['sender_type'] ?? 'user',
            'type'           => $msg['type'],
            'status'         => $msg['status'],
            'created_at'     => $msg['created_at'],
            'updated_at'     => $msg['updated_at'],               'avatar_url'     => $msg['avatar_url'] ?? null,
            'attachment_url' => $msg['attachment_url'] ?? null,
            'read_at'        => $msg['read_at'] ?? null,
            'parent_id'      => isset($msg['parent_id']) ? (int)$msg['parent_id'] : null,
            'metadata'       => isset($msg['metadata']) && $msg['metadata']
                                ? json_decode($msg['metadata'], true) : null,
        ];
    }
}
