<?php
// models/Conversation.php

require_once __DIR__ . '/../config/database.php';

class Conversation
{
    private $db;

    public function __construct()
    {
        $this->db = (new Database())->getConnection();
    }


public function getByParticipant(int $userId, string $role): array
{
    $stmt = $this->db->prepare("
        SELECT
            c.id,
            CASE
                WHEN c.participant1_id = :uid AND c.participant1_type = :role THEN
                    CASE
                        WHEN c.participant2_type IN ('user','provider','admin') THEN (SELECT name FROM users WHERE id = c.participant2_id)
                        WHEN c.participant2_type LIKE 'staff_%' THEN (SELECT name FROM provider_staff WHERE id = c.participant2_id)
                        ELSE 'Usuario'
                    END
                ELSE
                    CASE
                        WHEN c.participant1_type IN ('user','provider','admin') THEN (SELECT name FROM users WHERE id = c.participant1_id)
                        WHEN c.participant1_type LIKE 'staff_%' THEN (SELECT name FROM provider_staff WHERE id = c.participant1_id)
                        ELSE 'Usuario'
                    END
            END AS participant_name,
            CASE
                WHEN c.participant1_id = :uid AND c.participant1_type = :role THEN
                    CASE
                        WHEN c.participant2_type IN ('user','provider','admin') THEN (SELECT avatar_url FROM users WHERE id = c.participant2_id LIMIT 1)
                        WHEN c.participant2_type LIKE 'staff_%' THEN (SELECT avatar_url FROM provider_staff WHERE id = c.participant2_id LIMIT 1)
                        ELSE NULL
                    END
                ELSE
                    CASE
                        WHEN c.participant1_type IN ('user','provider','admin') THEN (SELECT avatar_url FROM users WHERE id = c.participant1_id LIMIT 1)
                        WHEN c.participant1_type LIKE 'staff_%' THEN (SELECT avatar_url FROM provider_staff WHERE id = c.participant1_id LIMIT 1)
                        ELSE NULL
                    END
            END AS participant_avatar,
            CASE
                WHEN c.participant1_id = :uid AND c.participant1_type = :role THEN c.participant2_type
                ELSE c.participant1_type
            END AS participant_role,
            CASE
                WHEN c.participant1_id = :uid AND c.participant1_type = :role THEN c.participant2_id
                ELSE c.participant1_id
            END AS participant_id,
            -- ✅ NUEVO: Obtener estado online del participante
            CASE
                WHEN c.participant1_id = :uid AND c.participant1_type = :role THEN
                    CASE
                        WHEN c.participant2_type IN ('user','provider','admin') THEN 
                            (SELECT CASE WHEN last_seen_at > DATE_SUB(NOW(), INTERVAL 2 MINUTE) THEN 1 ELSE 0 END FROM users WHERE id = c.participant2_id)
                        WHEN c.participant2_type LIKE 'staff_%' THEN 
                            (SELECT CASE WHEN is_online = 1 AND last_heartbeat > DATE_SUB(NOW(), INTERVAL 5 MINUTE) THEN 1 ELSE 0 END FROM provider_staff WHERE id = c.participant2_id)
                        ELSE 0
                    END
                ELSE
                    CASE
                        WHEN c.participant1_type IN ('user','provider','admin') THEN 
                            (SELECT CASE WHEN last_seen_at > DATE_SUB(NOW(), INTERVAL 2 MINUTE) THEN 1 ELSE 0 END FROM users WHERE id = c.participant1_id)
                        WHEN c.participant1_type LIKE 'staff_%' THEN 
                            (SELECT CASE WHEN is_online = 1 AND last_heartbeat > DATE_SUB(NOW(), INTERVAL 5 MINUTE) THEN 1 ELSE 0 END FROM provider_staff WHERE id = c.participant1_id)
                        ELSE 0
                    END
            END AS participant_is_online,
            COALESCE(lm.last_message_time, c.updated_at) AS last_message_at,
            (SELECT COUNT(*)
                    FROM messages m2
                    INNER JOIN message_status ms ON m2.id = ms.message_id
                    WHERE m2.conversation_id = c.id
                      AND ms.user_id = :uid
                      AND ms.user_type = :role
                      AND ms.is_read = FALSE
                      AND ms.is_deleted = FALSE
                ) as unread_count,
                (
                    SELECT COUNT(*)
                    FROM messages m3
                    INNER JOIN message_status ms3 ON m3.id = ms3.message_id
                    WHERE m3.conversation_id = c.id
                      AND ms3.user_id = :uid
                      AND ms3.user_type = :role
                      AND ms3.is_deleted = FALSE
                ) as visible_messages_count
            FROM conversations c
            LEFT JOIN (
                SELECT conversation_id, MAX(created_at) AS last_message_time
                FROM messages
                GROUP BY conversation_id
            ) lm ON lm.conversation_id = c.id
            WHERE (c.participant1_id = :uid AND c.participant1_type = :role)
               OR (c.participant2_id = :uid AND c.participant2_type = :role)
            HAVING visible_messages_count > 0
            ORDER BY last_message_at DESC
        ");

    $stmt->execute(['uid' => $userId, 'role' => $role]);
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

    public function findOrCreate(int $userId1, string $type1, int $userId2, string $type2): int
    {
        $stmt = $this->db->prepare("
            SELECT id FROM conversations
            WHERE (
                (participant1_id = :u1 AND participant1_type = :t1 AND participant2_id = :u2 AND participant2_type = :t2)
                OR
                (participant1_id = :u2 AND participant1_type = :t2 AND participant2_id = :u1 AND participant2_type = :t1)
            )
            LIMIT 1
        ");
        $stmt->execute([
            'u1' => $userId1,
            't1' => $type1,
            'u2' => $userId2,
            't2' => $type2
        ]);

        $id = $stmt->fetchColumn();
        if ($id) {
            return (int)$id;
        }

        $stmt = $this->db->prepare("
            INSERT INTO conversations
            (participant1_id, participant1_type, participant2_id, participant2_type, created_at, updated_at)
            VALUES (:u1, :t1, :u2, :t2, NOW(), NOW())
        ");
        $stmt->execute([
            'u1' => $userId1,
            't1' => $type1,
            'u2' => $userId2,
            't2' => $type2
        ]);

        return (int)$this->db->lastInsertId();
    }

    public function getParticipants(int $conversationId): ?array
    {
        $stmt = $this->db->prepare("
            SELECT
                participant1_id,
                participant1_type,
                participant2_id,
                participant2_type
            FROM conversations
            WHERE id = :id
            LIMIT 1
        ");
        $stmt->execute(['id' => $conversationId]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        return $row ?: null;
    }

    public function isParticipant(int $conversationId, int $userId, string $role): bool
    {
        $stmt = $this->db->prepare("
            SELECT 1 FROM conversations
            WHERE id = :convId
              AND (
                  (participant1_id = :uid AND participant1_type = :role)
                  OR
                  (participant2_id = :uid AND participant2_type = :role)
              )
            LIMIT 1
        ");
        $stmt->execute([
            'convId' => $conversationId,
            'uid' => $userId,
            'role' => $role
        ]);

        return (bool)$stmt->fetchColumn();
    }

    public function touch(int $conversationId): void
    {
        $stmt = $this->db->prepare("
            UPDATE conversations
            SET updated_at = NOW()
            WHERE id = :id
        ");
        $stmt->execute(['id' => $conversationId]);
    }

    public function getById(int $id): ?array
    {
        $stmt = $this->db->prepare("SELECT * FROM conversations WHERE id = :id LIMIT 1");
        $stmt->execute(['id' => $id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row ?: null;
    }

    public function deleteConversation(int $id): bool
    {
        try {
            $stmt = $this->db->prepare("DELETE FROM conversations WHERE id = :id");
            $stmt->execute(['id' => $id]);
            return $stmt->rowCount() > 0;
        } catch (PDOException $e) {
            error_log("Error al eliminar conversación $id: " . $e->getMessage());
            return false;
        }
    }

    public function findByParticipants($user1Id, $user1Role, $user2Id, $user2Role)
    {
        $query = "SELECT * FROM conversations
                  WHERE (participant1_id = :u1id AND participant1_type = :u1role
                        AND participant2_id = :u2id AND participant2_type = :u2role)
                  OR (participant1_id = :u2id AND participant1_type = :u2role
                      AND participant2_id = :u1id AND participant2_type = :u1role)
                  LIMIT 1";

        $stmt = $this->db->prepare($query);
        $stmt->execute([
            ':u1id' => $user1Id,
            ':u1role' => $user1Role,
            ':u2id' => $user2Id,
            ':u2role' => $user2Role
        ]);

        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    public function create($user1Id, $user1Role, $user2Id, $user2Role)
    {
        $query = "INSERT INTO conversations
                  (participant1_id, participant1_type, participant2_id, participant2_type, created_at)
                  VALUES (:u1id, :u1role, :u2id, :u2role, NOW())";

        $stmt = $this->db->prepare($query);
        $stmt->execute([
            ':u1id' => $user1Id,
            ':u1role' => $user1Role,
            ':u2id' => $user2Id,
            ':u2role' => $user2Role
        ]);

        return $this->db->lastInsertId();
    }

    public function userIsParticipant($conversationId, $userId)
    {
        $query = "SELECT * FROM conversations
                  WHERE id = :id
                  AND (participant1_id = :uid OR participant2_id = :uid)
                  LIMIT 1";

        $stmt = $this->db->prepare($query);
        $stmt->execute([':id' => $conversationId, ':uid' => $userId]);

        return $stmt->fetch() ? true : false;
    }

    public function getConversationId(int $userId1, string $type1, int $userId2, string $type2): ?int
    {
        $stmt = $this->db->prepare("
            SELECT id FROM conversations
            WHERE (
                (participant1_id = :u1 AND participant1_type = :t1 AND participant2_id = :u2 AND participant2_type = :t2)
                OR
                (participant1_id = :u2 AND participant1_type = :t2 AND participant2_id = :u1 AND participant2_type = :t1)
            )
            LIMIT 1
        ");
        $stmt->execute([
            'u1' => $userId1,
            't1' => $type1,
            'u2' => $userId2,
            't2' => $type2
        ]);

        $result = $stmt->fetchColumn();
        return $result ? (int)$result : null;
    }

    public function getOtherParticipant(int $conversationId, int $userId): ?array
    {
        $conv = $this->getById($conversationId);
        if (!$conv) return null;

        if ($conv['participant1_id'] == $userId) {
            return [
                'id' => $conv['participant2_id'],
                'type' => $conv['participant2_type']
            ];
        } elseif ($conv['participant2_id'] == $userId) {
            return [
                'id' => $conv['participant1_id'],
                'type' => $conv['participant1_type']
            ];
        }

        return null;
    }

    public function hasVisibleMessages(int $conversationId, int $userId, string $userRole): bool
    {
        $stmt = $this->db->prepare("
            SELECT COUNT(*)
            FROM messages m
            INNER JOIN message_status ms ON m.id = ms.message_id
            WHERE m.conversation_id = :conv_id
              AND ms.user_id = :user_id
              AND ms.user_type = :user_role
              AND ms.is_deleted = FALSE
            LIMIT 1
        ");

        $stmt->execute([
            'conv_id' => $conversationId,
            'user_id' => $userId,
            'user_role' => $userRole
        ]);

        return $stmt->fetchColumn() > 0;
    }
}
