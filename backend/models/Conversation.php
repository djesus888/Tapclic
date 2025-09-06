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

    /**
     * Obtener todas las conversaciones de un participante
     */
    public function getByParticipant(int $userId, string $role): array
    {
        $stmt = $this->db->prepare("
            SELECT
                c.id,
                CASE
                    WHEN c.participant1_id = :uid AND c.participant1_type = :role THEN
                        (SELECT CASE
                            WHEN c.participant2_type = 'user' THEN (SELECT name FROM users WHERE id = c.participant2_id)
                            WHEN c.participant2_type = 'provider' THEN (SELECT name FROM users WHERE id = c.participant2_id)
                            WHEN c.participant2_type = 'admin' THEN 'Admin'
                        END)
                    ELSE
                        (SELECT CASE
                            WHEN c.participant1_type = 'user' THEN (SELECT name FROM users WHERE id = c.participant1_id)
                            WHEN c.participant1_type = 'provider' THEN (SELECT name FROM users WHERE id = c.participant1_id)
                            WHEN c.participant1_type = 'admin' THEN 'Admin'
                        END)
                END AS participant_name,
                CASE
                    WHEN c.participant1_id = :uid AND c.participant1_type = :role THEN
                        (SELECT avatar_url FROM users WHERE id = c.participant2_id LIMIT 1)
                    ELSE
                        (SELECT avatar_url FROM users WHERE id = c.participant1_id LIMIT 1)
                END AS participant_avatar,
                CASE
                    WHEN c.participant1_id = :uid AND c.participant1_type = :role THEN
                        c.participant2_type
                    ELSE
                        c.participant1_type
                END AS participant_role,
                CASE
                    WHEN c.participant1_id = :uid AND c.participant1_type = :role THEN
                        c.participant2_id
                    ELSE
                        c.participant1_id
                END AS participant_id,
                CASE
                    WHEN c.participant1_id = :uid AND c.participant1_type = :role THEN
                        c.participant2_type
                    ELSE
                        c.participant1_type
                END AS participant_type,
                COALESCE(lm.created_at, c.updated_at) AS last_message_at,
                (SELECT COUNT(*) 
                 FROM messages m2 
                 WHERE m2.conversation_id = c.id 
                   AND m2.receiver_id = :uid 
                   AND m2.read_at IS NULL) as unread_count
            FROM conversations c
            LEFT JOIN (
                SELECT conversation_id, MAX(created_at) AS created_at
                FROM messages
                GROUP BY conversation_id
            ) lm ON lm.conversation_id = c.id
            WHERE (c.participant1_id = :uid AND c.participant1_type = :role)
               OR (c.participant2_id = :uid AND c.participant2_type = :role)
            ORDER BY last_message_at DESC
        ");
        $stmt->execute(['uid' => $userId, 'role' => $role]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Buscar o crear conversación entre dos participantes
     */
    public function findOrCreate(int $userId1, string $type1, int $userId2, string $type2): int
    {
        // Buscar conversación existente
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

        // Crear nueva conversación
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

    /**
     * Obtener participantes de una conversación
     */
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

    /**
     * Verificar si un usuario es participante de una conversación
     */
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

    /**
     * Actualizar timestamp de conversación
     */
    public function touch(int $conversationId): void
    {
        $stmt = $this->db->prepare("
            UPDATE conversations 
            SET updated_at = NOW() 
            WHERE id = :id
        ");
        $stmt->execute(['id' => $conversationId]);
    }

    /**
     * Obtener ID de conversación entre dos usuarios
     */
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
}
