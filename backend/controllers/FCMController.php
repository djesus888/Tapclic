<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../middleware/Auth.php';

class FCMController
{
    private $conn;

    public function __construct()
    {
        $this->conn = (new Database())->getConnection();
    }

    public function register(): void
    {
        header('Content-Type: application/json');
        $auth = Auth::verify();
        if (!$auth) {
            http_response_code(401);
            echo json_encode(['error' => 'No autorizado']);
            return;
        }

        $input = json_decode(file_get_contents('php://input'), true);
        $token = $input['token'] ?? '';
        $userId = $auth['id'];

        if (empty($token)) {
            echo json_encode(['success' => false, 'message' => 'Token requerido']);
            return;
        }

        $stmt = $this->conn->prepare("
            INSERT INTO fcm_tokens (user_id, token)
            VALUES (?, ?)
            ON DUPLICATE KEY UPDATE token = VALUES(token), updated_at = NOW()
        ");
        $stmt->execute([$userId, $token]);

        echo json_encode(['success' => true]);
    }

    public function unregister(): void
    {
        header('Content-Type: application/json');
        $auth = Auth::verify();
        if (!$auth) {
            http_response_code(401);
            echo json_encode(['error' => 'No autorizado']);
            return;
        }

        $input = json_decode(file_get_contents('php://input'), true);
        $token = $input['token'] ?? '';

        $stmt = $this->conn->prepare("DELETE FROM fcm_tokens WHERE token = ? AND user_id = ?");
        $stmt->execute([$token, $auth['id']]);

        echo json_encode(['success' => true]);
    }

    public static function sendToUser(int $userId, string $title, string $message, array $data = []): void
    {
        $db = (new Database())->getConnection();
        $stmt = $db->prepare("SELECT token FROM fcm_tokens WHERE user_id = ?");
        $stmt->execute([$userId]);
        $tokens = $stmt->fetchAll(PDO::FETCH_COLUMN);

        if (empty($tokens)) return;

        $serverKey = 'AIzaSyCdqfjqNQhVm3qd5jJw7cBKd71RGek3Xvk'; // ← REEMPLAZAR con tu Server Key de Firebase

        foreach ($tokens as $token) {
            $payload = [
                'to' => $token,
                'notification' => [
                    'title' => $title,
                    'body' => $message,
                    'icon' => '/img/logo.png'
                ],
                'data' => $data
            ];

            $ch = curl_init('https://fcm.googleapis.com/fcm/send');
            curl_setopt_array($ch, [
                CURLOPT_POST => true,
                CURLOPT_POSTFIELDS => json_encode($payload),
                CURLOPT_HTTPHEADER => [
                    'Content-Type: application/json',
                    'Authorization: key=' . $serverKey
                ],
                CURLOPT_RETURNTRANSFER => true,
                CURLOPT_TIMEOUT => 5
            ]);
            curl_exec($ch);
            curl_close($ch);
        }
    }
}
