<?php
// models/Message.php

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/Conversation.php';

class Message
{
    private $db;

    public function __construct()
    {
        $this->db = (new Database())->getConnection();
    }

    public function getMessages(int $senderId, int $receiverId, string $senderType, string $receiverType): array
    {
        $conv = new Conversation();
        $conversationId = $conv->findOrCreate($senderId, $senderType, $receiverId, $receiverType);
        return $this->getMessagesByConversationForUser($conversationId, $senderId, $senderType);
    }

    public function getMessagesByConversationForUser(int $conversationId, int $userId, string $userRole): array
    {
        // ✅ NUEVO: Marcar como entregados cuando el usuario SOLICITA los mensajes
        $this->markConversationMessagesAsDelivered($conversationId, $userId, $userRole);
        
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
                u.name,
                ms.is_read,
                ms.read_at as user_read_at,
                ms.is_deleted,
                ms.is_delivered,
                ms.delivered_at
            FROM messages m
            INNER JOIN message_status ms ON m.id = ms.message_id
            LEFT JOIN users u ON u.id = m.sender_id
            WHERE m.conversation_id = :convId
              AND ms.user_id = :userId
              AND ms.user_type = :userRole
              AND ms.is_deleted = FALSE
            ORDER BY m.created_at ASC
        ");

        $stmt->execute([
            'convId' => $conversationId,
            'userId' => $userId,
            'userRole' => $userRole
        ]);

        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        return array_map(function($r) use ($userId) {
            $msg = $this->mapMessageWithStatus($r);
            $msg['is_mine'] = ($r['sender_id'] == $userId);
            return $msg;
        }, $rows ?: []);
    }

    public function getMessagesByConversation(int $conversationId): array
    {
        throw new Exception("Debe usar getMessagesByConversationForUser con userId y userRole");
    }

    public function getLastMessageForUser(int $conversationId, int $userId, string $userRole): ?array
    {
        $stmt = $this->db->prepare("
            SELECT
                m.id,
                m.text,
                m.created_at,
                m.sender_id,
                m.sender_type
            FROM messages m
            INNER JOIN message_status ms ON m.id = ms.message_id
            WHERE m.conversation_id = :convId
              AND ms.user_id = :userId
              AND ms.user_type = :userRole
              AND ms.is_deleted = FALSE
            ORDER BY m.created_at DESC
            LIMIT 1
        ");

        $stmt->execute([
            'convId' => $conversationId,
            'userId' => $userId,
            'userRole' => $userRole
        ]);

        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row ?: null;
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

    public function countUnreadForUser(int $conversationId, int $userId, string $userRole): int
    {
        $stmt = $this->db->prepare("
            SELECT COUNT(*) AS c
            FROM messages m
            INNER JOIN message_status ms ON m.id = ms.message_id
            WHERE m.conversation_id = :convId
              AND ms.user_id = :userId
              AND ms.user_type = :userRole
              AND ms.is_read = FALSE
              AND ms.is_deleted = FALSE
        ");

        $stmt->execute([
            'convId' => $conversationId,
            'userId' => $userId,
            'userRole' => $userRole
        ]);

        return (int)$stmt->fetchColumn();
    }


public function markConversationMessagesAsDeliveredAndNotify(int $conversationId, int $userId, string $userRole): int
{
    try {
        // Primero obtener los mensajes que se marcarán como entregados
        $sql = "SELECT m.id, m.sender_id, m.sender_type
                FROM messages m
                INNER JOIN message_status ms ON m.id = ms.message_id
                WHERE m.conversation_id = :conversation_id
                  AND ms.user_id = :user_id
                  AND ms.user_type = :user_type
                  AND ms.is_delivered = FALSE";
        
        $stmt = $this->db->prepare($sql);
        $stmt->execute([
            'conversation_id' => $conversationId,
            'user_id' => $userId,
            'user_type' => $userRole
        ]);
        $affectedMessages = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        if (empty($affectedMessages)) {
            return 0;
        }
        
        // Marcar como entregados
        $updateSql = "UPDATE message_status ms
                      SET ms.is_delivered = TRUE, ms.delivered_at = NOW()
                      WHERE ms.message_id IN (
                          SELECT m.id FROM messages m
                          WHERE m.conversation_id = :conversation_id
                      )
                      AND ms.user_id = :user_id
                      AND ms.user_type = :user_type
                      AND ms.is_delivered = FALSE";
        
        $updateStmt = $this->db->prepare($updateSql);
        $updateStmt->execute([
            'conversation_id' => $conversationId,
            'user_id' => $userId,
            'user_type' => $userRole
        ]);
        
        $count = $updateStmt->rowCount();
        
        if ($count > 0) {
            $messageIds = array_column($affectedMessages, 'id');
            // Devolver los IDs y los senders para notificar
            return [
                'count' => $count,
                'message_ids' => $messageIds,
                'senders' => $affectedMessages
            ];
        }
        
        return 0;
    } catch (PDOException $e) {
        error_log("Error marcando mensajes como entregados: " . $e->getMessage());
        return 0;
    }
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

public function insertMessageWithStatus(
    int    $conversationId,
    int    $senderId,
    int    $receiverId,
    string $text,
    string $type = 'text',
    ?string $attachment_url = null,
    string $senderType = 'user',
    string $receiverType = 'user'
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

        $messageId = (int)$this->db->lastInsertId();

        $this->createMessageStatus($messageId, $senderId, $senderType, false, true);
        $this->createMessageStatus($messageId, $receiverId, $receiverType, false, false);

        $this->db->commit();

        // ✅ CORREGIDO: Obtener el mensaje COMPLETO con todos los campos incluyendo sender_id
        $message = $this->getMessageByIdForUser($messageId, $senderId, $senderType);
        
        // Asegurar que is_mine está correcto
        $message['is_mine'] = true;
        
        // ✅ Asegurar que sender_id está presente
        if (!isset($message['sender_id'])) {
            $message['sender_id'] = $senderId;
        }

        return $message;

    } catch (Throwable $e) {
        $this->db->rollBack();
        error_log("❌ insertMessageWithStatus error: " . $e->getMessage());
        throw $e;
    }
}


    private function createMessageStatus(int $messageId, int $userId, string $userType, bool $isRead = false, bool $isDelivered = false): void
    {
        $stmt = $this->db->prepare("
            INSERT INTO message_status
            (message_id, user_id, user_type, is_read, read_at, is_delivered, delivered_at, created_at)
            VALUES
            (:message_id, :user_id, :user_type, :is_read, :read_at, :is_delivered, :delivered_at, NOW())
        ");

        $stmt->execute([
            'message_id' => $messageId,
            'user_id' => $userId,
            'user_type' => $userType,
            'is_read' => $isRead ? 1 : 0,
            'read_at' => $isRead ? date('Y-m-d H:i:s') : null,
            'is_delivered' => $isDelivered ? 1 : 0,
            'delivered_at' => $isDelivered ? date('Y-m-d H:i:s') : null
        ]);
    }

    public function insertMessage(
        int    $conversationId,
        int    $senderId,
        int    $receiverId,
        string $text,
        string $type = 'text',
        ?string $attachment_url = null,
        string $senderType = 'user'
    ): array {
        $receiverType = ($senderType === 'user') ? 'provider' : 'user';

        return $this->insertMessageWithStatus(
            $conversationId,
            $senderId,
            $receiverId,
            $text,
            $type,
            $attachment_url,
            $senderType,
            $receiverType
        );
    }

public function getMessageByIdForUser(int $id, int $userId, string $userRole): array
{
    $stmt = $this->db->prepare("
        SELECT
            m.id,
            m.conversation_id,
            m.sender_id,           // ✅ IMPORTANTE: Este campo debe estar
            m.receiver_id,
            m.text,
            m.type,
            m.status,
            m.created_at,
            m.updated_at,
            m.attachment_url,
            m.metadata,
            m.read_at,
            m.sender_type as sender, // ✅ Alias para mantener compatibilidad
            u.avatar_url,
            u.name,
            ms.is_read,
            ms.read_at as user_read_at,
            ms.is_deleted,
            ms.is_delivered,
            ms.delivered_at
        FROM messages m
        INNER JOIN message_status ms ON m.id = ms.message_id
        LEFT JOIN users u ON u.id = m.sender_id
        WHERE m.id = :id
          AND ms.user_id = :userId
          AND ms.user_type = :userRole
        LIMIT 1
    ");

    $stmt->execute([
        'id' => $id,
        'userId' => $userId,
        'userRole' => $userRole
    ]);

    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$row) {
        return [];
    }
    
    $msg = $this->mapMessageWithStatus($row);
    $msg['is_mine'] = ($row['sender_id'] == $userId);
    
    // ✅ Asegurar que sender está presente (usando sender_type como fallback)
    if (!isset($msg['sender']) && isset($row['sender'])) {
        $msg['sender'] = $row['sender'];
    }
    
    return $msg;
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

    public function markAsDeliveredForUser(int $messageId, int $userId, string $userRole): bool
    {
        try {
            $message = $this->getMessageById($messageId);
            if ($message['receiver_id'] != $userId) {
                return false;
            }

            $stmt = $this->db->prepare("
                UPDATE message_status
                SET is_delivered = TRUE, delivered_at = NOW()
                WHERE message_id = :message_id
                  AND user_id = :user_id
                  AND user_type = :user_type
            ");

            $stmt->execute([
                'message_id' => $messageId,
                'user_id' => $userId,
                'user_type' => $userRole
            ]);

            return $stmt->rowCount() > 0;
        } catch (PDOException $e) {
            error_log("Error al marcar como entregado: " . $e->getMessage());
            return false;
        }
    }

    // ✅ NUEVO: Marcar TODOS los mensajes de una conversación como entregados
    public function markConversationMessagesAsDelivered(int $conversationId, int $userId, string $userRole): int
    {
        try {
            $sql = "UPDATE message_status ms
                    INNER JOIN messages m ON ms.message_id = m.id
                    SET ms.is_delivered = TRUE, ms.delivered_at = NOW()
                    WHERE m.conversation_id = :conversation_id
                      AND ms.user_id = :user_id
                      AND ms.user_type = :user_type
                      AND ms.is_delivered = FALSE";
            
            $stmt = $this->db->prepare($sql);
            $stmt->execute([
                'conversation_id' => $conversationId,
                'user_id' => $userId,
                'user_type' => $userRole
            ]);
            
            $count = $stmt->rowCount();
            
            if ($count > 0) {
                error_log("📬 Marcados $count mensajes como entregados para usuario $userId en conversación $conversationId");
            }
            
            return $count;
        } catch (PDOException $e) {
            error_log("Error marcando mensajes como entregados: " . $e->getMessage());
            return 0;
        }
    }

    public function markAsReadForUser(array $messageIds, int $userId, string $userRole): int
    {
        if (empty($messageIds)) return 0;

        $placeholders = implode(',', array_fill(0, count($messageIds), '?'));

        $sql = "UPDATE message_status
                SET is_read = TRUE, read_at = NOW()
                WHERE message_id IN ($placeholders)
                  AND user_id = ?
                  AND user_type = ?
                  AND is_read = FALSE";

        $stmt = $this->db->prepare($sql);

        $params = array_merge($messageIds, [$userId, $userRole]);
        $stmt->execute($params);

        return $stmt->rowCount();
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
        $count = $stmt->rowCount();

        $this->markAsReadForUser($ids, $readerId, $this->getUserRoleFromId($readerId));

        return $count;
    }

    public function markRead(int $messageId, int $readerId): int
    {
        return $this->markReadBatch([$messageId], $readerId);
    }

    public function deleteMessageForUser(int $messageId, int $userId, string $userRole): bool
    {
        try {
            $stmt = $this->db->prepare("
                UPDATE message_status
                SET is_deleted = TRUE, deleted_at = NOW()
                WHERE message_id = :message_id
                  AND user_id = :user_id
                  AND user_type = :user_type
            ");

            $stmt->execute([
                'message_id' => $messageId,
                'user_id' => $userId,
                'user_type' => $userRole
            ]);

            return $stmt->rowCount() > 0;
        } catch (PDOException $e) {
            error_log("Error al eliminar mensaje para usuario $messageId: " . $e->getMessage());
            return false;
        }
    }

    public function deleteConversationForUser(int $conversationId, int $userId, string $userRole): bool
    {
        try {
            $stmt = $this->db->prepare("
                UPDATE message_status ms
                INNER JOIN messages m ON ms.message_id = m.id
                SET ms.is_deleted = TRUE, ms.deleted_at = NOW()
                WHERE m.conversation_id = :conv_id
                  AND ms.user_id = :user_id
                  AND ms.user_type = :user_type
            ");

            $stmt->execute([
                'conv_id' => $conversationId,
                'user_id' => $userId,
                'user_type' => $userRole
            ]);

            return true;
        } catch (PDOException $e) {
            error_log("Error al eliminar conversación para usuario $conversationId: " . $e->getMessage());
            return false;
        }
    }

    public function hardDeleteMessage(int $id): bool
    {
        try {
            $stmt1 = $this->db->prepare("DELETE FROM message_status WHERE message_id = :id");
            $stmt1->execute(['id' => $id]);

            $stmt2 = $this->db->prepare("DELETE FROM messages WHERE id = :id");
            $stmt2->execute(['id' => $id]);

            return $stmt2->rowCount() > 0;
        } catch (PDOException $e) {
            error_log("Error al eliminar mensaje $id: " . $e->getMessage());
            return false;
        }
    }

    public function hardDeleteMessagesByConversation(int $conversationId): bool
    {
        try {
            $stmt = $this->db->prepare("SELECT id FROM messages WHERE conversation_id = :convId");
            $stmt->execute(['convId' => $conversationId]);
            $messageIds = $stmt->fetchAll(PDO::FETCH_COLUMN);

            if (!empty($messageIds)) {
                $placeholders = implode(',', array_fill(0, count($messageIds), '?'));
                $stmt1 = $this->db->prepare("DELETE FROM message_status WHERE message_id IN ($placeholders)");
                $stmt1->execute($messageIds);

                $stmt2 = $this->db->prepare("DELETE FROM messages WHERE conversation_id = :convId");
                $stmt2->execute(['convId' => $conversationId]);
            }

            return true;
        } catch (PDOException $e) {
            error_log("Error al eliminar mensajes de conversación $conversationId: " . $e->getMessage());
            return false;
        }
    }

    public function deleteMessage(int $id): bool
    {
        return $this->hardDeleteMessage($id);
    }

    public function deleteMessagesByConversation(int $conversationId): bool
    {
        return $this->hardDeleteMessagesByConversation($conversationId);
    }

    private function getUserRoleFromId(int $userId): string
    {
        $stmt = $this->db->prepare("SELECT role FROM users WHERE id = :id LIMIT 1");
        $stmt->execute(['id' => $userId]);
        $role = $stmt->fetchColumn();
        return $role ?: 'user';
    }

    private function mapMessageWithStatus(array $msg): array
    {
        $base = $this->mapMessage($msg);

        $base['is_read'] = isset($msg['is_read']) ? (bool)$msg['is_read'] : false;
        $base['user_read_at'] = $msg['user_read_at'] ?? null;
        $base['is_deleted'] = isset($msg['is_deleted']) ? (bool)$msg['is_deleted'] : false;
        $base['is_delivered'] = isset($msg['is_delivered']) ? (bool)$msg['is_delivered'] : false;
        $base['delivered_at'] = $msg['delivered_at'] ?? null;

        if (!empty($msg['user_read_at'])) {
            $base['read_at'] = $msg['user_read_at'];
        }

        return $base;
    }

    private function mapMessage(array $msg): array
    {
        if (!$msg) return [];

        return [
            'id'             => (int)$msg['id'],
            'conversation_id'=> (int)($msg['conversation_id'] ?? 0),
            'sender_id'      => (int)($msg['sender_id'] ?? 0),
            'text'           => $msg['text'] ?? '',
            'sender'         => $msg['sender_type'] ?? 'user',
            'type'           => $msg['type'],
            'status'         => $msg['status'],
            'created_at'     => $msg['created_at'],
            'updated_at'     => $msg['updated_at'],
            'avatar_url'     => $msg['avatar_url'] ?? null,
            'attachment_url' => $msg['attachment_url'] ?? null,
            'read_at'        => $msg['read_at'] ?? null,
            'parent_id'      => isset($msg['parent_id']) ? (int)$msg['parent_id'] : null,
            'metadata'       => isset($msg['metadata']) && $msg['metadata']
                                 ? json_decode($msg['metadata'], true) : null,
        ];
    }
}
?>
