<?php
require_once __DIR__ . "/../middleware/Auth.php";
// controllers/MessageController.php
require_once __DIR__ . '/../models/Message.php';
require_once __DIR__ . '/../models/Conversation.php';
require_once __DIR__ . '/../utils/jwt.php';
require_once __DIR__ . '/../services/WebSocketService.php';

use services\WebSocketService;

class MessageController
{
    private $messageModel;
    private $conversationModel;

    public function __construct()
    {
        $this->messageModel = new Message();
        $this->conversationModel = new Conversation();
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
        
        $conversationId = $this->conversationModel->findOrCreate(
            $userId, $userRole,
            $targetId, $targetRole
        );

        $messages = $this->messageModel->getMessagesByConversation($conversationId);
        header('Content-Type: application/json');
        echo json_encode(["success" => true, "messages" => $messages]);
        exit;
    }

    public function uploadMessageImage(): void
    {
        if (!isset($_FILES['image']) || $_FILES['image']['error'] !== UPLOAD_ERR_OK) {
            $code = $_FILES['image']['error'] ?? UPLOAD_ERR_NO_FILE;
            $this->jsonError(400, 'Upload error: ' . $code);
        }

        $file = $_FILES['image'];
        $maxSize = 5 * 1024 * 1024;
        if ($file['size'] > $maxSize) {
            $this->jsonError(413, 'File too large');
        }

        $allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
        $finfo = new finfo(FILEINFO_MIME_TYPE);
        $mime = $finfo->file($file['tmp_name']);
        if (!in_array($mime, $allowedTypes, true)) {
            $this->jsonError(415, 'Unsupported file type');
        }

        $uploadDir = __DIR__ . '/../public/uploads/messages/';
        if (!is_dir($uploadDir) && !mkdir($uploadDir, 0755, true)) {
            $this->jsonError(500, 'Cannot create directory');
        }
        
        $ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
        $ext = preg_replace('/[^a-z0-9]/', '', $ext);
        $filename = 'msg_' . bin2hex(random_bytes(8)) . '.' . $ext;
        $target   = $uploadDir . $filename;
        if (!move_uploaded_file($file['tmp_name'], $target)) {
            $this->jsonError(500, 'Failed to save file');
        }

        $baseUrl = $_ENV['APP_URL'] ?? 'http://localhost:8000';
        $imageUrl = rtrim($baseUrl, '/') . '/uploads/messages/' . $filename;

        header('Content-Type: application/json');
        echo json_encode(['image_url' => $imageUrl]);
    }

    private function jsonError(int $code, string $msg): void
    {
        http_response_code($code);
        header('Content-Type: application/json');
        echo json_encode(['error' => $msg]);
        exit;
    }

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
        $this->messageModel->markReadBatch($ids, $user->id);
        
        foreach ($ids as $id) {
            $msg = $this->messageModel->getById($id);
            if ($msg) {
                WebSocketService::emit([
                    'receiver_id'   => $msg['sender_id'],
                    'receiver_role' => $msg['sender_type'],
                    'type'          => 'read',
                    'message_id'    => $id,
                    'read_at'       => date('Y-m-d H:i:s')
                ]);
            }
        }

        echo json_encode(['success' => true]);
        exit;
    }

    public function sendMessage($data)
    {
        $user = $this->authUser();
        $senderId = $user->id;
        $senderType = $user->role;

        $receiverId = intval($data['recipient_id'] ?? $data['provider_id'] ?? 0);
        $receiverType = $data['recipient_role'] ?? '';
        $text = trim($data['text'] ?? '');

        $attachment_url = $data['attachment_url'] ?? $data['image_url'] ?? null;
        $parent_id = $data['parent_id'] ?? null;
        $metadata = $data['metadata']  ?? null;

        $type = empty($attachment_url) ? 'text' : 'image';

        if (!$receiverId || !$receiverType || ($text === '' && empty($attachment_url))) {
            http_response_code(400);
            echo json_encode(["message" => "Faltan datos requeridos (recipient_id, recipient_role o contenido)"]);
            exit;
        }

        $conversationId = $this->conversationModel->findOrCreate(
            $senderId, $senderType,
            $receiverId, $receiverType
        );

        try {
            $message = $this->messageModel->insertMessage(
                $conversationId,
                $senderId,
                $receiverId,
                $text,
                $type,
                $attachment_url,
                $senderType
            );
        } catch (Throwable $e) {
            error_log("Excepción en insertMessage: " . $e->getMessage());
            WebSocketService::emit([
                'receiver_id'   => 1,
                'receiver_role' => 'admin',
                'title'         => 'Error al guardar mensaje',
                'message'       => $e->getMessage()
            ]);
            http_response_code(500);
            echo json_encode(["message" => "Error al guardar el mensaje"]);
            exit;
        }

        WebSocketService::emit([
            'receiver_id'   => $receiverId,
            'receiver_role' => $receiverType,
            'title'         => 'Nuevo mensaje',
            'message'       => $text ?: 'Imagen',
            'data_json'     => json_encode([
                'url' => '/chat/' . $conversationId,
                'action' => 'view_chat',
                'notification_type' => 'new_message',
                'conversation_id' => $conversationId
            ])
        ]);

        header('Content-Type: application/json');
        echo json_encode(["success" => true, "message" => $message]);
        exit;
    }
}
