<?php
// backend/controllers/ConversationController.php

require_once __DIR__ . "/../middleware/Auth.php";
require_once __DIR__ . '/../models/Conversation.php';
require_once __DIR__ . '/../models/Message.php';
require_once __DIR__ . '/../utils/jwt.php';

class ConversationController
{
    private $conversationModel;
    private $messageModel;
    private $db;

    public function __construct()
    {
        $this->conversationModel = new Conversation();
        $this->messageModel = new Message();
        $this->db = (new Database())->getConnection();
        $this->db->exec("SET NAMES utf8mb4");
    }

    /* -------------------------------------------------- */
    private function authUser()
    {
        $user = Auth::verify();

        if (!$user || !isset($user->id) || !isset($user->role)) {
            http_response_code(401);
            echo json_encode(["message" => "Token inválido o no proporcionado"]);
            exit;
        }

        return $user;
    }

    /* -------------------------------------------------- */
    public function handle(string $method): void
    {
        switch ($method) {
            case 'GET':
                $this->getConversations();
                break;
            default:
                http_response_code(405);
                echo json_encode(['message' => 'Método no permitido']);
        }
    }

    /* -------------------------------------------------- */
    public function getById(int $id)
    {
        try {
            // Verificar autenticación
            $user = $this->authUser();
            if (!$user) {
                http_response_code(401);
                echo json_encode(['error' => 'No autorizado']);
                return;
            }

            $currentUserId = $user->id;
            $currentUserRole = $user->role;

            // Obtener la conversación verificando que el usuario sea participante
            $stmt = $this->db->prepare("
                SELECT c.*
                FROM conversations c
                WHERE c.id = ?
                AND (
                    (c.participant1_id = ? AND c.participant1_type = ?) OR
                    (c.participant2_id = ? AND c.participant2_type = ?)
                )
                LIMIT 1
            ");

            $stmt->execute([
                $id,
                $currentUserId, $currentUserRole,
                $currentUserId, $currentUserRole
            ]);

            $conversation = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$conversation) {
                http_response_code(404);
                echo json_encode(['error' => 'Conversación no encontrada o no tienes acceso']);
                return;
            }

            // Determinar el otro participante
            $isParticipant1 = ($conversation['participant1_id'] == $currentUserId &&
                $conversation['participant1_type'] == $currentUserRole);

            $otherParticipantId = $isParticipant1
                ? $conversation['participant2_id']
                : $conversation['participant1_id'];

            $otherParticipantType = $isParticipant1
                ? $conversation['participant2_type']
                : $conversation['participant1_type'];

// Obtener info del otro participante
$otherUser = null;
if ($otherParticipantType === 'user' || $otherParticipantType === 'provider' || $otherParticipantType === 'admin') {
    $userStmt = $this->db->prepare("SELECT id, name, avatar_url, role FROM users WHERE id = ? AND role = ? LIMIT 1");
    $userStmt->execute([$otherParticipantId, $otherParticipantType]);
    $otherUser = $userStmt->fetch(PDO::FETCH_ASSOC);
} elseif (strpos($otherParticipantType, 'staff_') === 0) {
    $userStmt = $this->db->prepare("SELECT id, name, avatar_url, role FROM provider_staff WHERE id = ? LIMIT 1");
    $userStmt->execute([$otherParticipantId]);
    $otherUser = $userStmt->fetch(PDO::FETCH_ASSOC);
    if ($otherUser) {
        $otherUser['role'] = 'staff_' . ($otherUser['role'] ?? 'delivery');
    }
}

if (!$otherUser) {
    $otherUser = [
        'id' => $otherParticipantId,
        'name' => 'Usuario',
        'avatar_url' => null,
        'role' => $otherParticipantType
    ];
}
            // Contar mensajes no leídos usando message_status
            $unreadStmt = $this->db->prepare("
                SELECT COUNT(*) as unread_count
                FROM messages m
                INNER JOIN message_status ms ON m.id = ms.message_id
                WHERE m.conversation_id = ?
                AND ms.user_id = ?
                AND ms.user_type = ?
                AND ms.is_read = FALSE
                AND ms.is_deleted = FALSE
            ");
            $unreadStmt->execute([$id, $currentUserId, $currentUserRole]);
            $unreadCount = $unreadStmt->fetch(PDO::FETCH_ASSOC)['unread_count'] ?? 0;

            // Obtener último mensaje (solo no eliminados)
            $lastMessageStmt = $this->db->prepare("
                SELECT m.text, m.created_at, m.sender_id, m.sender_type
                FROM messages m
                INNER JOIN message_status ms ON m.id = ms.message_id
                WHERE m.conversation_id = ?
                AND ms.user_id = ?
                AND ms.user_type = ?
                AND ms.is_deleted = FALSE
                ORDER BY m.created_at DESC
                LIMIT 1
            ");
            $lastMessageStmt->execute([$id, $currentUserId, $currentUserRole]);
            $lastMessage = $lastMessageStmt->fetch(PDO::FETCH_ASSOC);

            // Formatear respuesta
            $response = [
                'id' => (int)$conversation['id'],
                'participant1_id' => (int)$conversation['participant1_id'],
                'participant1_type' => $conversation['participant1_type'],
                'participant2_id' => (int)$conversation['participant2_id'],
                'participant2_type' => $conversation['participant2_type'],
                'other_participant' => [
                    'id' => (int)$otherUser['id'],
                    'name' => $otherUser['name'] ?? 'Usuario',
                    'avatar_url' => $otherUser['avatar_url'],
                    'role' => $otherUser['role']
                ],
                'last_message' => $lastMessage ? [
                    'text' => $lastMessage['text'],
                    'sender_id' => (int)$lastMessage['sender_id'],
                    'sender_type' => $lastMessage['sender_type'],
                    'created_at' => $lastMessage['created_at'],
                    'is_mine' => ((int)$lastMessage['sender_id'] == $currentUserId) // ✅ Bandera para identificar si es mío
                ] : null,
                'unread_count' => (int)$unreadCount,
                'created_at' => $conversation['created_at'],
                'updated_at' => $conversation['updated_at']
            ];

            header('Content-Type: application/json; charset=utf-8'); // ✅ Añadido charset
            echo json_encode([
                'success' => true,
                'conversation' => $response
            ], JSON_UNESCAPED_UNICODE); // ✅ Soporte para tildes

        } catch (Exception $e) {
            error_log("Error en getById: " . $e->getMessage());
            http_response_code(500);
            echo json_encode(['error' => 'Error interno del servidor']);
        }
    }

    /**
     * Buscar conversación por participantes
     * GET /conversations/find/{user_id}/{user_role}
     */
    public function findByParticipants($participantId, $participantRole)
    {
        $user = Auth::verify();
        if (!$user) {
            http_response_code(401);
            echo json_encode(["error" => "No autorizado"]);
            return;
        }

        $conversation = $this->conversationModel->findByParticipants(
            $user->id,
            $user->role,
            $participantId,
            $participantRole
        );

        header('Content-Type: application/json; charset=utf-8'); // ✅ Añadido charset
        if ($conversation) {
            echo json_encode($conversation, JSON_UNESCAPED_UNICODE);
        } else {
            http_response_code(404);
            echo json_encode(["error" => "Conversación no encontrada"]);
        }
    }

    /**
     * Crear nueva conversación
     * POST /conversations/create
     */
    public function create()
    {
        $user = Auth::verify();
        if (!$user) {
            http_response_code(401);
            echo json_encode(["error" => "No autorizado"]);
            return;
        }

        $data = json_decode(file_get_contents("php://input"), true);

        $participantId = $data['participant_id'] ?? null;
        $participantRole = $data['participant_role'] ?? null;

        if (!$participantId || !$participantRole) {
            http_response_code(400);
            echo json_encode(["error" => "Faltan datos del participante"]);
            return;
        }

        // Verificar si ya existe
        $existing = $this->conversationModel->findByParticipants(
            $user->id,
            $user->role,
            $participantId,
            $participantRole
        );

        header('Content-Type: application/json; charset=utf-8'); // ✅ Añadido charset
        if ($existing) {
            echo json_encode($existing, JSON_UNESCAPED_UNICODE);
            return;
        }

        // Crear nueva
        $conversationId = $this->conversationModel->create(
            $user->id,
            $user->role,
            $participantId,
            $participantRole
        );

        if ($conversationId) {
            echo json_encode(['id' => $conversationId]);
        } else {
            http_response_code(500);
            echo json_encode(["error" => "Error al crear conversación"]);
        }
    }

    /**
     * Obtener lista de conversaciones del usuario
     */
    private function getConversations(): void
    {
        $user = $this->authUser();
        $userId = $user->id;
        $userRole = $user->role;

        $rows = $this->conversationModel->getByParticipant($userId, $userRole);

        $conversations = [];
        foreach ($rows as $conv) {
            // Obtener último mensaje no eliminado
            $last = $this->messageModel->getLastMessageForUser($conv['id'], $userId, $userRole);

            // Contar no leídos usando message_status
            $unread = $this->messageModel->countUnreadForUser($conv['id'], $userId, $userRole);

            // ✅ CORREGIDO: Estructura unificada con 'participant' en singular
            $conversations[] = [
                'id' => (int)$conv['id'],
                'participant' => [ // ✅ Cambiado de 'participants' a 'participant'
                    'id' => (int)$conv['participant_id'],
                    'name' => $conv['participant_name'],
                    'avatar' => $conv['participant_avatar'] ?: '/img/default-avatar.png',
                    'role' => $conv['participant_role']
                ],
                'lastMessage' => $last ? [
                    'text' => $last['text'],
                    'created_at' => $last['created_at'],
                    'sender_id' => (int)$last['sender_id'], // ✅ Añadido para identificar quién envió
                    'sender_type' => $last['sender_type'],
                    'is_mine' => ((int)$last['sender_id'] == $userId) // ✅ Bandera para identificar si es mío
                ] : null,
                'unreadCount' => (int)$unread,
            ];
        }

        header('Content-Type: application/json; charset=utf-8'); // ✅ Añadido charset
        echo json_encode([
            'success' => true,
            'conversations' => $conversations
        ], JSON_UNESCAPED_UNICODE); // ✅ Soporte para tildes
    }
}
