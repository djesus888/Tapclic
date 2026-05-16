<?php
// ✅ NUEVO: Configurar error reporting para ver errores
error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('log_errors', 1);
ini_set('error_log', '/data/data/com.termux/files/usr/var/log/php_error.log');

// backend/controllers/MessageController.php
require_once __DIR__ . "/../middleware/Auth.php";
require_once __DIR__ . '/../models/Message.php';
require_once __DIR__ . '/../models/Conversation.php';
require_once __DIR__ . '/../utils/jwt.php';
require_once __DIR__ . '/../services/WebSocketService.php';
require_once __DIR__ . '/../config/database.php';

use Services\WebSocketService;

class MessageController
{
    private $messageModel;
    private $conversationModel;
    private $db;

    public function __construct()
    {
        $this->messageModel = new Message();
        $this->conversationModel = new Conversation();
        $database = new Database();
        $this->db = $database->getConnection();
        // ✅ NUEVO: Configurar charset para tildes
        $this->db->exec("SET NAMES utf8mb4");
    }

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

    private function getBaseUrl()
    {
        try {
            $query = "SELECT api_host, system_host FROM system_config WHERE system_active = 1 LIMIT 1";
            $stmt = $this->db->prepare($query);
            $stmt->execute();
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            if ($row) {
                if (!empty($row['api_host'])) {
                    return rtrim($row['api_host'], '/');
                }
                if (!empty($row['system_host'])) {
                    $host = str_replace(':5173', ':8000', $row['system_host']);
                    return rtrim($host, '/');
                }
            }
        } catch (Exception $e) {
            error_log("Error obteniendo configuración de host: " . $e->getMessage());
        }
        return $this->getBaseUrlFromRequest();
    }

    private function getBaseUrlFromRequest()
    {
        $protocol = isset($_SERVER['HTTP_X_FORWARDED_PROTO'])
            ? $_SERVER['HTTP_X_FORWARDED_PROTO'] . '://'
            : (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? 'https://' : 'http://');
        $host = $_SERVER['HTTP_X_FORWARDED_HOST'] ?? $_SERVER['HTTP_HOST'];
        return rtrim($protocol . $host, '/');
    }

    private function jsonError(int $code, string $msg): void
    {
        http_response_code($code);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode(['error' => $msg], JSON_UNESCAPED_UNICODE);
        exit;
    }

    private function checkConversationAccess($conversationId, $requireAdmin = false)
    {
        $user = $this->authUser();
        $conversation = $this->conversationModel->getById($conversationId);
        if (!$conversation) {
            http_response_code(404);
            echo json_encode(["message" => "Conversación no encontrada"]);
            exit;
        }

        if (
            $conversation['participant1_id'] != $user->id &&
            $conversation['participant2_id'] != $user->id &&
            $user->role !== 'admin'
        ) {
            http_response_code(403);
            echo json_encode(["message" => "No tienes permiso para acceder a esta conversación"]);
            exit;
        }
        return $conversation;
    }

    private function checkMessageAccess($messageId, $requireAdmin = false)
    {
        $user = $this->authUser();
        $message = $this->messageModel->getMessageById($messageId);

        if (!$message) {
            http_response_code(404);
            echo json_encode(["message" => "Mensaje no encontrado"]);
            exit;
        }

        if ($message['sender_id'] != $user->id && (!$requireAdmin || $user->role !== 'admin')) {
            http_response_code(403);
            echo json_encode(["message" => "No tienes permiso para acceder a este mensaje"]);
            exit;
        }
        return $message;
    }

    public function getMessages($data)
    {
        $user = $this->authUser();
        $userId = $user->id;
        $userRole = $user->role;

        $targetId = intval($data['target_id'] ?? $data['provider_id'] ?? 0);
        $targetRole = $data['target_role'] ?? '';

        if (!$targetId || !$targetRole) {
            http_response_code(400);
            echo json_encode(["message" => "Faltan target_id o target_role"]);
            exit;
        }

        $conversationId = $this->conversationModel->findOrCreate($userId, $userRole, $targetId, $targetRole);

        $messages = $this->messageModel->getMessagesByConversationForUser(
            $conversationId,
            $userId,
            $userRole
        );
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode(["success" => true, "messages" => $messages], JSON_UNESCAPED_UNICODE);
        exit;
    }

    public function getMessagesByConversation($conversationId)
    {
        $user = $this->authUser();
        $conversation = $this->checkConversationAccess($conversationId);

        // ✅ CORREGIDO: Marcar como entregados (ahora devuelve solo el contador)
        $deliveredCount = $this->messageModel->markConversationMessagesAsDeliveredAndNotify(
            $conversationId,
            $user->id,
            $user->role
        );

        // ✅ NUEVO: Si se marcaron mensajes como entregados, notificar a los remitentes
        if ($deliveredCount > 0) {
            $sql = "SELECT DISTINCT m.id, m.sender_id, m.sender_type
                    FROM messages m
                    INNER JOIN message_status ms ON m.id = ms.message_id
                    WHERE m.conversation_id = :conversation_id
                      AND ms.user_id = :user_id
                      AND ms.user_type = :user_type
                      AND ms.delivered_at IS NOT NULL
                      AND ms.is_delivered = TRUE";

            $stmt = $this->db->prepare($sql);
            $stmt->execute([
                'conversation_id' => $conversationId,
                'user_id' => $user->id,
                'user_type' => $user->role
            ]);
            $affectedMessages = $stmt->fetchAll(PDO::FETCH_ASSOC);

            if (!empty($affectedMessages)) {
                // Agrupar por remitente para notificar individualmente
                $sendersGrouped = [];
                foreach ($affectedMessages as $msg) {
                    $senderKey = $msg['sender_type'] . '_' . $msg['sender_id'];
                    if (!isset($sendersGrouped[$senderKey])) {
                        $sendersGrouped[$senderKey] = [
                            'sender_id' => $msg['sender_id'],
                            'sender_type' => $msg['sender_type'],
                            'message_ids' => []
                        ];
                    }
                    $sendersGrouped[$senderKey]['message_ids'][] = $msg['id'];
                }

                // Notificar a cada remitente
                foreach ($sendersGrouped as $senderData) {
                    WebSocketService::emitToUser(
                        $senderData['sender_type'],
                        $senderData['sender_id'],
                        'message_delivered',
                        [
                            'conversation_id' => $conversationId,
                            'message_ids' => $senderData['message_ids'],
                            'delivered_at' => date('Y-m-d H:i:s')
                        ]
                    );
                }
                error_log("📬 Notificada entrega de " . count($affectedMessages) . " mensajes en conversación {$conversationId}");
            }
        }
        $messages = $this->messageModel->getMessagesByConversationForUser(
            $conversationId,
            $user->id,
            $user->role
        );

        header('Content-Type: application/json; charset=utf-8');
        echo json_encode(["success" => true, "messages" => $messages], JSON_UNESCAPED_UNICODE);
    }

    public function uploadMessageImage(): void
    {
        $this->authUser();
        if (!isset($_FILES['image']) || $_FILES['image']['error'] !== UPLOAD_ERR_OK) {
            $code = $_FILES['image']['error'] ?? UPLOAD_ERR_NO_FILE;
            $this->jsonError(400, 'Error al subir la imagen: código ' . $code);
        }
        $file = $_FILES['image'];
        $maxSize = 5 * 1024 * 1024;
        if ($file['size'] > $maxSize) {
            $this->jsonError(413, 'La imagen es demasiado grande (máx 5MB)');
        }

        $allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
        $finfo = new finfo(FILEINFO_MIME_TYPE);
        $mime = $finfo->file($file['tmp_name']);
        if (!in_array($mime, $allowedTypes, true)) {
            $this->jsonError(415, 'Tipo de archivo no permitido. Solo imágenes JPG, PNG, GIF o WEBP');
        }

        $uploadDir = __DIR__ . '/../public/uploads/messages/';
        if (!is_dir($uploadDir) && !mkdir($uploadDir, 0755, true)) {
            $this->jsonError(500, 'No se pudo crear el directorio de uploads');
        }

        $ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
        $ext = preg_replace('/[^a-z0-9]/', '', $ext);
        $filename = 'msg_' . bin2hex(random_bytes(8)) . '.' . $ext;
        $targetPath = $uploadDir . $filename;

        if (!move_uploaded_file($file['tmp_name'], $targetPath)) {
            $this->jsonError(500, 'Error al guardar el archivo');
        }
        $baseUrl = $this->getBaseUrl();
        $imageUrl = $baseUrl . '/uploads/messages/' . $filename;

        header('Content-Type: application/json; charset=utf-8');
        echo json_encode(['image_url' => $imageUrl], JSON_UNESCAPED_UNICODE);
        exit;
    }

    // ✅ CORREGIDO: markAsRead - AHORA EMITE UN SOLO EVENTO CON TODOS LOS IDs
    public function markAsRead($data)
    {
        $user = $this->authUser();
        $ids = $data['message_ids'] ?? [];

        if (!is_array($ids) || empty($ids)) {
            http_response_code(400);
            echo json_encode(['message' => 'Faltan message_ids']);
            exit;
        }

        $ids = array_map('intval', $ids);

        // ✅ CORREGIDO: Marcar como leído para el usuario actual
        $updated = $this->messageModel->markAsReadForUser($ids, $user->id, $user->role);

        error_log("📖 markAsRead: {$updated} mensajes marcados como leídos para usuario {$user->id}");

        // ✅ 🔥 CORRECCIÓN CRÍTICA: Emitir UN SOLO evento con TODOS los message_ids
        // Obtener conversation_id del primer mensaje (todos deberían ser de la misma conversación)
        $firstMsg = $this->messageModel->getMessageById($ids[0]);

        if ($firstMsg && isset($firstMsg['conversation_id'])) {
            WebSocketService::emitToRoom(
                "conversation_{$firstMsg['conversation_id']}",
                'message_read',
                [
                    'conversation_id' => $firstMsg['conversation_id'],
                    'message_ids' => $ids, // 🔥 TODOS LOS IDs JUNTOS
                    'user_id' => $user->id,
                    'user_role' => $user->role,
                    'read_at' => date('Y-m-d H:i:s')
                ]
            );
            error_log("📖 Emitido message_read para " . count($ids) . " mensajes en conversación {$firstMsg['conversation_id']}");
        }

        header('Content-Type: application/json; charset=utf-8');
        echo json_encode(['success' => true]);
        exit;
    }

    public function typingIndicator($data)
    {
        $user = $this->authUser();
        $senderId = $user->id;
        $senderType = $user->role;
        $receiverId = intval($data['receiver_id'] ?? 0);
        $receiverType = $data['receiver_role'] ?? '';
        $isTyping = filter_var($data['is_typing'] ?? false, FILTER_VALIDATE_BOOLEAN);
        $conversationId = intval($data['conversation_id'] ?? 0);

        if (!$receiverId || !$receiverType || !$conversationId) {
            http_response_code(400);
            echo json_encode(["message" => "Faltan datos requeridos"]);
            exit;
        }

        if (!$this->conversationModel->isParticipant($conversationId, $senderId, $senderType)) {
            http_response_code(403);
            echo json_encode(["message" => "No tienes acceso a esta conversación"]);
            exit;
        }

        // ✅ CORREGIDO: Usar emitToRoom para la sala de conversación
        WebSocketService::emitToRoom(
            "conversation_{$conversationId}",
            'typing_indicator',
            [
                'conversation_id' => $conversationId,
                'user_id' => $senderId,
                'user_role' => $senderType,
                'is_typing' => $isTyping,
                'timestamp' => time()
            ]
        );

        header('Content-Type: application/json; charset=utf-8');
        echo json_encode(['success' => true]);
        exit;
    }

    // ✅ CORREGIDO: sendMessage mejorado
    public function sendMessage($data)
    {
        // ✅ NUEVO: Log completo de lo que llega
        error_log("========== sendMessage llamado ==========");
        error_log("Data recibida: " . json_encode($data, JSON_UNESCAPED_UNICODE));
        error_log("POST raw: " . file_get_contents('php://input'));

        try {
            $user = $this->authUser();
            $senderId = $user->id;
            $senderType = $user->role;
            $receiverId = intval($data['recipient_id'] ?? $data['provider_id'] ?? 0);
            $receiverType = $data['recipient_role'] ?? '';
            $text = trim($data['text'] ?? '');
            $attachment_url = $data['attachment_url'] ?? $data['image_url'] ?? null;
            $parent_id = $data['parent_id'] ?? null;
            $metadata = $data['metadata'] ?? null;
            $conversationId = isset($data['conversation_id']) ? intval($data['conversation_id']) : null;
            $type = empty($attachment_url) ? 'text' : 'image';

            if (!$receiverId || !$receiverType || ($text === '' && empty($attachment_url))) {
                http_response_code(400);
                echo json_encode(["message" => "Faltan datos requeridos"]);
                exit;
            }

            if (!$conversationId) {
                $conversationId = $this->conversationModel->findOrCreate($senderId, $senderType, $receiverId, $receiverType);
            } else {
                $conversation = $this->conversationModel->getById($conversationId);
                if (!$conversation) {
                    http_response_code(404);
                    echo json_encode(["message" => "Conversación no encontrada"]);
                    exit;
                }
                if ($conversation['participant1_id'] != $senderId && $conversation['participant2_id'] != $senderId) {
                    http_response_code(403);
                    echo json_encode(["message" => "No tienes acceso a esta conversación"]);
                    exit;
                }
            }

            try {
                $this->db->beginTransaction();

                $message = $this->messageModel->insertMessageWithStatus(
                    $conversationId,
                    $senderId,
                    $receiverId,
                    $text,
                    $type,
                    $attachment_url,
                    $senderType,
                    $receiverType
                );

                // ✅ NUEVO: Agregar datos de conversación al mensaje
                $message['conversation_id'] = $conversationId;
                $message['is_mine'] = true;

                // ✅ NUEVO: Asegurar que sender_id está presente (por si acaso)
                if (!isset($message['sender_id'])) {
                    $message['sender_id'] = $senderId;
                }

                // ✅ NUEVO: Log para depuración
                error_log("📦 Mensaje insertado: " . json_encode([
                    'id' => $message['id'],
                    'sender_id' => $message['sender_id'],
                    'sender' => $message['sender'] ?? $senderType,
                    'text' => substr($message['text'] ?? '', 0, 30)
                ]));

                $messageForReceiver = $message;
                $messageForReceiver['is_mine'] = false;
                $message['sender_id'] = $senderId;
                $this->db->commit();

                // ✅ NUEVO: Obtener el mensaje con estados COMPLETOS para el remitente
                $messageWithStatus = $this->messageModel->getMessageByIdForUser(
                    $message['id'],
                    $senderId,
                    $senderType
                );

                // Si por alguna razón falla, usar el mensaje base
                if (!$messageWithStatus || empty($messageWithStatus)) {
                    $messageWithStatus = $message;
                    $messageWithStatus['is_delivered'] = false;
                    $messageWithStatus['is_read'] = false;
                }

                // ✅ Asegurar que is_mine está correcto
                $messageWithStatus['is_mine'] = true;
                error_log("📦 Enviando confirmación al remitente {$senderId}: " . json_encode([
                    'message_id' => $message['id'],
                    'is_delivered' => $messageWithStatus['is_delivered'] ?? false,
                    'is_read' => $messageWithStatus['is_read'] ?? false
                ]));

                // Enviar a la sala de conversación (para todos los participantes)
                WebSocketService::emitToRoom(
                    "conversation_{$conversationId}",
                    'new_message',
                    [
                        'conversation_id' => $conversationId,
                        'message' => $messageWithStatus,
                        'temp_id' => $data['temp_id'] ?? null,
                        'status' => 'sent'
                    ]
                );

                // ✅ NUEVO: Enviar confirmación al remitente CON TODOS LOS ESTADOS
                WebSocketService::emitToUser(
                    $senderType,
                    $senderId,
                    'message_sent_confirmation',
                    [
                        'conversation_id' => $conversationId,
                        'message' => $messageWithStatus,
                        'temp_id' => $data['temp_id'] ?? null,
                        'status' => 'confirmed'
                    ]
                );

                // ✅ IMPORTANTE: Devolver respuesta HTTP
                header('Content-Type: application/json; charset=utf-8');
                echo json_encode(["success" => true, "message" => $messageWithStatus], JSON_UNESCAPED_UNICODE);
                exit;

            } catch (Throwable $e) {
                $this->db->rollBack();
                error_log("❌ Excepción en insertMessage: " . $e->getMessage());
                http_response_code(500);
                echo json_encode(["message" => "Error al guardar el mensaje"]);
                exit;
            }
        } catch (Exception $e) {
            error_log("❌ EXCEPCIÓN: " . $e->getMessage());
            error_log("❌ STACK: " . $e->getTraceAsString());
            http_response_code(500);
            echo json_encode(["message" => $e->getMessage()]);
            exit;
        }
    }

    // =====================================================
    // ✅ NUEVO: Marcar TODOS los mensajes de una conversación como entregados
    // =====================================================
    public function markConversationAsDelivered($conversationId)
    {
        $user = $this->authUser();

        // Verificar que el usuario tiene acceso a la conversación
        $conversation = $this->checkConversationAccess($conversationId);
        if (!$conversation) {
            $this->jsonError(400, "Conversación inválida");
            return;
        }

        // Marcar todos los mensajes no entregados como entregados
        $count = $this->messageModel->markConversationMessagesAsDelivered(
            $conversationId,
            $user->id,
            $user->role
        );

        // ✅ NUEVO: manejar caso sin mensajes pendientes (NO error)
        if ($count === 0) {
            header('Content-Type: application/json; charset=utf-8');
            echo json_encode([
                'success' => true,
                'count' => 0,
                'message' => "No hay mensajes pendientes por marcar como entregados"
            ]);
            exit;
        }

        // Si se marcaron mensajes, notificar al emisor
        if ($count > 0) {
            $sql = "SELECT m.id, m.sender_id
                    FROM messages m
                    INNER JOIN message_status ms ON m.id = ms.message_id
                    WHERE m.conversation_id = ?
                      AND ms.user_id = ?
                      AND ms.user_type = ?
                      AND ms.delivered_at IS NOT NULL";

            $stmt = $this->db->prepare($sql);
            $stmt->execute([$conversationId, $user->id, $user->role]);
            $messages = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $messageIds = array_column($messages, 'id');

            if (!empty($messageIds)) {
                WebSocketService::emitToRoom(
                    "conversation_{$conversationId}",
                    'message_delivered',
                    [
                        'conversation_id' => $conversationId,
                        'message_ids' => $messageIds,
                        'delivered_at' => date('Y-m-d H:i:s')
                    ]
                );
                error_log("📬 Notificada entrega de " . count($messageIds) . " mensajes en conversación {$conversationId}");
            }
        }

        header('Content-Type: application/json; charset=utf-8');
        echo json_encode([
            'success' => true,
            'count' => $count,
            'message' => "{$count} mensajes marcados como entregados"
        ]);
        exit;
    }

    public function markAsDelivered($data)
    {
        $user = $this->authUser();
        $messageId = intval($data['message_id'] ?? 0);
        if (!$messageId) {
            http_response_code(400);
            echo json_encode(['message' => 'Falta message_id']);
            exit;
        }

        $success = $this->messageModel->markAsDeliveredForUser($messageId, $user->id, $user->role);

        if ($success) {
            $msg = $this->messageModel->getMessageById($messageId);
            if ($msg) {
                // ✅ CORREGIDO: Usar emitToRoom para la sala de conversación
                WebSocketService::emitToRoom(
                    "conversation_{$msg['conversation_id']}",
                    'message_delivered',
                    [
                        'conversation_id' => $msg['conversation_id'],
                        'message_ids' => [$messageId],
                        'delivered_at' => date('Y-m-d H:i:s')
                    ]
                );
            }
        }

        header('Content-Type: application/json; charset=utf-8');
        echo json_encode(['success' => true]);
        exit;
    }

    public function getMessageStatuses($conversationId)
    {
        $user = $this->authUser();
        $this->checkConversationAccess($conversationId);
        $sql = "SELECT
                    m.id,
                    m.conversation_id,
                    ms.is_delivered,
                    ms.delivered_at,
                    ms.is_read,
                    ms.read_at
                FROM messages m
                INNER JOIN message_status ms ON m.id = ms.message_id
                WHERE m.conversation_id = ?
                  AND ms.user_id = ?
                  AND ms.user_type = ?
                ORDER BY m.created_at ASC";

        $stmt = $this->db->prepare($sql);
        $stmt->execute([$conversationId, $user->id, $user->role]);
        $messages = $stmt->fetchAll(PDO::FETCH_ASSOC);

        header('Content-Type: application/json; charset=utf-8');
        echo json_encode([
            'success' => true,
            'messages' => $messages
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    public function deleteMessageForUser($messageId)
    {
        $user = $this->authUser();
        $message = $this->checkMessageAccess($messageId, false);
        $conversation = $this->conversationModel->getById($message['conversation_id']);

        $success = $this->messageModel->deleteMessageForUser($messageId, $user->id, $user->role);

        if ($success) {
            header('Content-Type: application/json; charset=utf-8');
            echo json_encode(["success" => true]);
        } else {
            http_response_code(500);
            echo json_encode(["message" => "Error al borrar el mensaje"]);
        }
        exit;
    }

    public function deleteMessage($messageId)
    {
        $user = $this->authUser();
        $message = $this->checkMessageAccess($messageId, true);

        $success = $this->messageModel->hardDeleteMessage($messageId);

        if ($success) {
            // ✅ CORREGIDO: Usar emitToRoom para la sala de conversación
            WebSocketService::emitToRoom(
                "conversation_{$message['conversation_id']}",
                'message_deleted',
                [
                    'message_id' => $messageId,
                    'conversation_id' => $message['conversation_id']
                ]
            );
            header('Content-Type: application/json; charset=utf-8');
            echo json_encode(["success" => true]);
        } else {
            http_response_code(500);
            echo json_encode(["message" => "Error al borrar el mensaje"]);
        }
        exit;
    }

    public function deleteConversationForUser($conversationId)
    {
        $user = $this->authUser();
        $conversation = $this->checkConversationAccess($conversationId);

        $success = $this->messageModel->deleteConversationForUser($conversationId, $user->id, $user->role);

        if ($success) {
            header('Content-Type: application/json; charset=utf-8');
            echo json_encode(["success" => true]);
        } else {
            http_response_code(500);
            echo json_encode(["message" => "Error al borrar la conversación"]);
        }
        exit;
    }

    public function deleteConversationMessages($conversationId)
    {
        $user = $this->authUser();
        $conversation = $this->checkConversationAccess($conversationId, true);

        $success = $this->messageModel->hardDeleteMessagesByConversation($conversationId);
        if ($success) {
            header('Content-Type: application/json; charset=utf-8');
            echo json_encode(["success" => true]);
        } else {
            http_response_code(500);
            echo json_encode(["message" => "Error al borrar los mensajes"]);
        }
        exit;
    }

    public function deleteConversation($conversationId)
    {
        $user = $this->authUser();
        $conversation = $this->checkConversationAccess($conversationId, true);
        $this->messageModel->hardDeleteMessagesByConversation($conversationId);
        $success = $this->conversationModel->deleteConversation($conversationId);
        if ($success) {
            header('Content-Type: application/json; charset=utf-8');
            echo json_encode(["success" => true]);
        } else {
            http_response_code(500);
            echo json_encode(["message" => "Error al borrar la conversación"]);
        }
        exit;
    }
}
?>
