<?php
header("Access-Control-Allow-Origin: http://localhost:5173");
header("Access-Control-Allow-Headers: Origin, X-Requested-With, Content-Type, Accept, Authorization");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once __DIR__ . '/../models/History.php';
require_once __DIR__ . '/../utils/jwt.php';

class HistoryController
{
    private History $history;
    private PDO $conn;

    public function __construct()
    {
        $this->history = new History();
        $this->conn = (new Database())->getConnection();
    }

    public function handle(string $method): void
    {
        $path = $_SERVER['REQUEST_URI'];

        if (
            ($method === 'GET'  && preg_match('~/api/history/?$~', $path)) ||
            ($method === 'POST' && preg_match('~/api/history/rate/?$~', $path)) ||
            ($method === 'GET'  && preg_match('~/api/reviews/received/?$~', $path))
        ) {
            if ($method === 'GET' && str_contains($path, '/reviews/received')) {
                $this->receivedReviews();
            } elseif ($method === 'GET') {
                $this->index();
            } elseif ($method === 'POST') {
                $this->rate();
            }
        } else {
            http_response_code(404);
            echo json_encode(['error' => 'Ruta no válida']);
        }
    }



public function markHelpful(): void
{
    $userId = $this->checkAuth(); // extrae id del token o 401
    $input = json_decode(file_get_contents('php://input'), true);
    $reviewId = $input['review_id'] ?? 0;

    if (!$reviewId) { $this->send(400, 'Faltan datos'); return; }

    // upsert
    $stmt = $this->conn->prepare("
        INSERT INTO review_helpful (review_id, user_id) VALUES (:rid, :uid)
        ON DUPLICATE KEY UPDATE created_at = NOW()
    ");
    $stmt->execute([':rid' => $reviewId, ':uid' => $userId]);
    $this->send(200, ['success' => true]);
}

public function report(): void
{
    $userId = $this->checkAuth();
    $input = json_decode(file_get_contents('php://input'), true);
    $reviewId = $input['review_id'] ?? 0;

    if (!$reviewId) { $this->send(400, 'Faltan datos'); return; }

    $stmt = $this->conn->prepare("
        INSERT INTO review_reports (review_id, user_id, created_at)
        VALUES (:rid, :uid, NOW())
        ON DUPLICATE KEY UPDATE created_at = NOW()
    ");
    $stmt->execute([':rid' => $reviewId, ':uid' => $userId]);
    $this->send(200, ['success' => true]);
}

public function reply(int $reviewId): void
{
    $providerId = $this->checkAuth();
    $input = json_decode(file_get_contents('php://input'), true);
    $message = trim($input['message'] ?? '');

    if (!$message) { $this->send(400, 'Mensaje vacío'); return; }

    // comprobar que el review es SUYO
    $stmt = $this->conn->prepare("SELECT id FROM service_reviews WHERE id = :rid AND provider_id = :pid");
    $stmt->execute([':rid' => $reviewId, ':pid' => $providerId]);
    if (!$stmt->fetch()) { $this->send(403, 'No autorizado'); return; }

    // borrar respuesta previa (opcional) e insertar nueva
    $this->conn->prepare("DELETE FROM review_messages WHERE review_id = :rid AND sender_type = 'provider'")->execute([':rid' => $reviewId]);

    $stmt = $this->conn->prepare("
        INSERT INTO review_messages (review_id, sender_type, sender_id, message, created_at)
        VALUES (:rid, 'provider', :sid, :msg, NOW())
    ");
    $stmt->execute([':rid' => $reviewId, ':sid' => $providerId, ':msg' => $message]);
    $this->send(200, ['success' => true]);
}

/* helper */
private function checkAuth(): int
{
    $headers = getallheaders();
    $auth = $headers['Authorization'] ?? '';
    if (!str_starts_with($auth, 'Bearer ')) { $this->send(401, 'Token no proporcionado'); exit; }
    $token = str_replace('Bearer ', '', $auth);
    $decoded = JwtHandler::decode($token);
    if (!$decoded || !isset($decoded->id)) { $this->send(401, 'Token inválido'); exit; }
    return (int)$decoded->id;
}

private function send(int $code, array $data): void
{
    http_response_code($code);
    header('Content-Type: application/json');
    echo json_encode($data);
    exit();
}




    public function rate(): void
    {
        $headers = getallheaders();
        $auth = $headers['Authorization'] ?? '';
        if (!str_starts_with($auth, 'Bearer ')) {
            http_response_code(401);
            echo json_encode(['message' => 'Token no proporcionado']);
            return;
        }

        $token = str_replace('Bearer ', '', $auth);
        $decoded = JwtHandler::decode($token);
        if (!$decoded || !isset($decoded->id)) {
            http_response_code(401);
            echo json_encode(['message' => 'Token inválido o expirado']);
            return;
        }

        $input = json_decode(file_get_contents("php://input"), true);
        $historyId = $input['id'] ?? null;
        $stars = $input['stars'] ?? null;
        $comment = $input['comment'] ?? '';

        if (!$historyId || !$stars || $stars < 1 || $stars > 5) {
            http_response_code(400);
            echo json_encode(['message' => 'Faltan datos o rating inválido']);
            return;
        }

        $stmt = $this->conn->prepare("SELECT * FROM service_history WHERE id = :hid AND user_id = :uid");
        $stmt->execute([':hid' => $historyId, ':uid' => $decoded->id]);
        $history = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$history) {
            http_response_code(404);
            echo json_encode(['message' => 'Historial no encontrado o no autorizado']);
            return;
        }

        $stmt = $this->conn->prepare("SELECT id FROM service_reviews WHERE service_history_id = :hid");
        $stmt->execute([':hid' => $historyId]);
        if ($stmt->fetch()) {
            http_response_code(409);
            echo json_encode(['message' => 'Ya calificaste este servicio']);
            return;
        }



// Normalizamos tags y photos
$tags  = json_encode(array_filter(explode(',', $input['tags'] ?? ''))) ?: '[]';
$photos = json_encode(array_filter(explode(',', $input['photos'] ?? ''))) ?: '[]';

$stmt = $this->conn->prepare("
    INSERT INTO service_reviews 
        (service_history_id, user_id, provider_id, rating, comment, tags, photos)
    VALUES 
        (:hid, :uid, :pid, :rating, :comment, :tags, :photos)
");
$stmt->execute([
    ':hid' => $historyId,
    ':uid' => $decoded->id,
    ':pid' => $history['provider_id'],
    ':rating' => $stars,
    ':comment' => $comment,
    ':tags' => $tags,
    ':photos' => $photos
      ]);
        $this->updateProviderAverage((int)$history['provider_id']);
        $this->notifyProviderEvaluated((int)$history['provider_id'], (int)$stars);

        echo json_encode(['success' => true, 'message' => 'Reseña guardada']);
    }

    private function updateProviderAverage(int $providerId): void
    {
        $stmt = $this->conn->prepare("
            UPDATE users
            SET average_rating = (
                SELECT ROUND(AVG(rating), 1)
                FROM service_reviews
                WHERE provider_id = :pid
            )
            WHERE id = :pid
        ");
        $stmt->execute([':pid' => $providerId]);
    }

    private function notifyProviderEvaluated(int $providerId, int $stars): void
    {
        $message = "Un cliente te calificó con {$stars} estrella" . ($stars === 1 ? '' : 's') . ".";
        $dataJson = json_encode(['route' => '/reviews']);

        $stmt = $this->conn->prepare("
            INSERT INTO notifications (sender_id, receiver_id, receiver_role, title, message, data_json, is_read, created_at)
            VALUES (NULL, :receiver, 'provider', :title, :message, :data, 0, NOW())
        ");
        $stmt->execute([
            ':receiver' => $providerId,
            ':title'    => '¡Tienes una nueva evaluación!',
            ':message'  => $message,
            ':data'     => $dataJson
        ]);
    }

    public function receivedReviews(): void
    {
        $headers = getallheaders();
        $auth = $headers['Authorization'] ?? '';
        if (!str_starts_with($auth, 'Bearer ')) {
            http_response_code(401);
            echo json_encode(['message' => 'Token no proporcionado']);
            return;
        }

        $token = str_replace('Bearer ', '', $auth);
        $decoded = JwtHandler::decode($token);
        if (!$decoded || !isset($decoded->id) || $decoded->role !== 'provider') {
            http_response_code(403);
            echo json_encode(['message' => 'No autorizado']);
            return;
        }

        $stmt = $this->conn->prepare("
    SELECT
        sr.id,
        sr.rating,
        sr.comment,
        sr.created_at,
        sr.tags,
        sr.photos,
        u.name        AS user_name,
        u.avatar_url  AS user_avatar,
        sh.service_title,
        COALESCE(hc.cnt, 0) AS helpful_count,
        pm.message    AS provider_reply_message,
        pm.created_at AS provider_reply_createdAt
    FROM service_reviews sr
    JOIN users u ON u.id = sr.user_id
    JOIN service_history sh ON sh.id = sr.service_history_id
    LEFT JOIN (
        SELECT review_id, COUNT(*) AS cnt
        FROM review_helpful
        GROUP BY review_id
    ) hc ON hc.review_id = sr.id
    LEFT JOIN review_messages pm
           ON pm.review_id = sr.id
          AND pm.sender_type = 'provider'
    WHERE sr.provider_id = :pid
    ORDER BY sr.created_at DESC
");
        $stmt->execute([':pid' => $decoded->id]);
        $reviews = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $avg = $this->conn->prepare("SELECT AVG(rating) AS avg FROM service_reviews WHERE provider_id = :pid");
        $avg->execute([':pid' => $decoded->id]);
        $average = (float) ($avg->fetchColumn() ?: 0);

        echo json_encode([
            'success' => true,
            'average' => round($average, 1),
            'total'   => count($reviews),
            'reviews' => $reviews
        ]);
    }

    public function index(): void
    {
        $headers = getallheaders();
        $auth = $headers['Authorization'] ?? '';
        if (!str_starts_with($auth, 'Bearer ')) {
            http_response_code(401);
            echo json_encode(['message' => 'Token no proporcionado']);
            return;
        }

        $token = str_replace('Bearer ', '', $auth);
        $decoded = JwtHandler::decode($token);
        if (!$decoded || !isset($decoded->id)) {
            http_response_code(401);
            echo json_encode(['message' => 'Token inválido o expirado']);
            return;
        }

        if ($decoded->role === 'provider') {
            $data = $this->history->getHistoryByProvider($decoded->id);
        } else {
            $data = $this->history->getHistoryByUser($decoded->id);
        }

        echo json_encode([
            'success' => true,
            'history' => $data
        ]);
    }
}
