<?php
require_once __DIR__ . "/../middleware/Auth.php";
// backend/controllers/ConversationController.php

require_once __DIR__ . '/../models/Conversation.php';
require_once __DIR__ . '/../models/Message.php';
require_once __DIR__ . '/../utils/jwt.php';

class ConversationController
{
    private $conversationModel;
    private $messageModel;

    public function __construct()
    {
        $this->conversationModel = new Conversation();
        $this->messageModel      = new Message();
    }

    /* -------------------------------------------------- */

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
    private function getConversations(): void
    {
        $user      = $this->authUser();
        $userId    = $user->id;
        $userRole  = $user->role;

        $rows = $this->conversationModel->getByParticipant($userId, $userRole);

        $conversations = [];
        foreach ($rows as $conv) {
            $last   = $this->messageModel->getLastMessage($conv['id']);
            $unread = $this->messageModel->countUnread($conv['id'], $userId, $userRole);

            $conversations[] = [
                'id'            => (int)$conv['id'],
                'participants' => [
    'id' => (int)$conv['participant_id'],
    'name' => $conv['participant_name'],
    'avatar' => $conv['participant_avatar'] ?: '/img/default-avatar.png',
    'role' => $conv['participant_role']
],
                'lastMessage'   => $last ? [
                    'text'       => $last['text'],
                    'created_at' => $last['created_at'],
                ] : null,
                'unreadCount'   => (int)$unread,
            ];
        }

        header('Content-Type: application/json');
        echo json_encode(['success' => true, 'conversations' => $conversations]);
    }
}
