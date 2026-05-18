<?php
require_once __DIR__ . "/../middleware/Auth.php";
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

        // Verificación principal de rutas válidas
        if (
            ($method === 'GET'  && preg_match('~/api/history/?$~', $path)) ||
            ($method === 'POST' && preg_match('~/api/history/rate/?$~', $path)) ||
            ($method === 'POST' && preg_match('~/api/history/rate-user/?$~', $path)) ||
            ($method === 'POST' && preg_match('~/api/user-reviews/rate/?$~', $path)) ||
            ($method === 'GET'  && preg_match('~/api/user-reviews/my/?$~', $path)) ||
            ($method === 'GET'  && preg_match('~/api/reviews/received/?$~', $path)) ||
            ($method === 'GET'  && preg_match('~/api/reviews/my/?$~', $path)) ||
            ($method === 'GET'  && preg_match('~/api/history/by-request/(\d+)/?$~', $path)) ||
            ($method === 'PUT'  && preg_match('~/api/reviews/\d+/?$~', $path)) ||
            ($method === 'PUT'  && preg_match('~/api/reviews/\d+/reply/?$~', $path))
        ) {
            // Procesamiento de rutas (ordenado de más específico a menos específico)
            if ($method === 'PUT' && preg_match('~/api/reviews/(\d+)/reply/?$~', $path, $m)) {
                $this->reply((int)$m[1]);
            } elseif ($method === 'PUT' && preg_match('~/api/reviews/(\d+)/?$~', $path, $m)) {
                $this->updateReview((int)$m[1]);
            } elseif ($method === 'GET' && preg_match('~/api/history/by-request/(\d+)/?$~', $path, $m)) {
                $this->getHistoryByRequest((int)$m[1]);
            } elseif ($method === 'POST' && preg_match('~/api/history/rate-user/?$~', $path)) {
                $this->rateUser();
            } elseif ($method === 'POST' && preg_match('~/api/user-reviews/rate/?$~', $path)) {
                $this->rateUser();
            } elseif ($method === 'GET' && preg_match('~/api/reviews/received/?$~', $path)) {
                $this->receivedReviews();
            } elseif ($method === 'GET' && preg_match('~/api/user-reviews/my/?$~', $path)) {
                $this->myUserReviews();
            } elseif ($method === 'GET' && preg_match('~/api/reviews/my/?$~', $path)) {
                $this->myReviews();
            } elseif ($method === 'POST' && preg_match('~/api/history/rate/?$~', $path)) {
                $this->rate();
            } elseif ($method === 'GET' && preg_match('~/api/history/?$~', $path)) {
                $this->index();
            }
        } else {
            http_response_code(404);
            echo json_encode(['error' => 'Ruta no válida']);
        }
    }

    // ✅ NUEVO: Método para obtener historial por ID de request
    public function getHistoryByRequest(int $requestId): void
    {
        $userId = $this->checkAuth();

        $stmt = $this->conn->prepare("
            SELECT
                h.id,
                h.service_title,
                h.service_description,
                h.service_price,
                h.user_name,
                h.user_avatar,
                h.finished_at,
                h.status,
                h.cancelled_by,
                h.payment_status,
                h.payment_method,
                h.user_id,
                h.provider_id
            FROM service_history h
            WHERE h.request_id = :rid
              AND (h.user_id = :uid OR h.provider_id = :uid)
            LIMIT 1
        ");
        $stmt->execute([
            ':rid' => $requestId,
            ':uid' => $userId
        ]);
        $history = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$history) {
            $this->send(404, ['message' => 'Historial no encontrado']);
        }

        $this->send(200, ['success' => true, 'history' => $history]);
    }

    public function updateReview(int $reviewId): void
    {
        $userId = $this->checkAuth();
        $input = json_decode(file_get_contents('php://input'), true);

        // Verificar que el review pertenezca al usuario
        $stmt = $this->conn->prepare("SELECT id FROM service_reviews WHERE id = :rid AND user_id = :uid");
        $stmt->execute([':rid' => $reviewId, ':uid' => $userId]);
        if (!$stmt->fetch()) {
            $this->send(403, ['message' => 'No autorizado']);
        }

        // Actualizar solo comentario y tags
        $stmt = $this->conn->prepare("UPDATE service_reviews SET comment = :c, tags = :t WHERE id = :id");
        $stmt->execute([
            ':c' => $input['comment'] ?? '',
            ':t' => json_encode($input['tags'] ?? []),
            ':id' => $reviewId
        ]);
        $this->send(200, ['success' => true]);
    }

    /* ==================== MÉTODO PARA CREAR RESPUESTA (NUEVO) ==================== */
    public function createReply(int $reviewId): void
    {
        $userId = $this->checkAuth();
        $input = json_decode(file_get_contents('php://input'), true);
        $message = trim($input['message'] ?? '');

        if (!$message) {
            $this->send(400, ['message' => 'Mensaje vacío']);
        }

        // Determinar tipo de reseña y validar permisos
        $stmtRole = $this->conn->prepare("SELECT role FROM users WHERE id = :uid");
        $stmtRole->execute([':uid' => $userId]);
        $role = $stmtRole->fetchColumn();

        if (!$role) {
            $this->send(403, ['message' => 'Usuario no encontrado']);
        }

        // Verificar que la reseña existe y el usuario es el destinatario
        if ($role === 'provider') {
            $stmt = $this->conn->prepare("
                SELECT id, user_id
                FROM service_reviews
                WHERE id = :rid AND provider_id = :pid
            ");
            $stmt->execute([':rid' => $reviewId, ':pid' => $userId]);
            $review = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$review) {
                $this->send(403, ['message' => 'No autorizado para responder esta reseña']);
            }

            $senderType = 'provider';
            $receiverId = (int)$review['user_id'];
            $receiverRole = 'user';
        } else {
            $stmt = $this->conn->prepare("
                SELECT id, provider_id
                FROM user_reviews
                WHERE id = :rid AND user_id = :uid
            ");
            $stmt->execute([':rid' => $reviewId, ':uid' => $userId]);
            $review = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$review) {
                $this->send(403, ['message' => 'No autorizado para responder esta reseña']);
            }

            $senderType = 'user';
            $receiverId = (int)$review['provider_id'];
            $receiverRole = 'provider';
        }

        // Verificar si ya existe una respuesta (para evitar duplicados)
        $stmt = $this->conn->prepare("
            SELECT id FROM review_messages
            WHERE review_id = :rid AND sender_type = :stype AND sender_id = :sid
        ");
        $stmt->execute([
            ':rid' => $reviewId,
            ':stype' => $senderType,
            ':sid' => $userId
        ]);

        if ($stmt->fetch()) {
            $this->send(409, ['message' => 'Ya has respondido esta reseña']);
        }

        // Insertar nueva respuesta
        $stmt = $this->conn->prepare("
            INSERT INTO review_messages
                (review_id, sender_type, sender_id, message, created_at)
            VALUES
                (:rid, :stype, :sid, :msg, NOW())
        ");
        $stmt->execute([
            ':rid' => $reviewId,
            ':stype' => $senderType,
            ':sid' => $userId,
            ':msg' => $message
        ]);

        // Notificar al receptor
        if ($receiverId > 0) {
            $notif = $this->conn->prepare("
                INSERT INTO notifications
                    (sender_id, receiver_id, receiver_role, title, message, data_json, is_read, created_at)
                VALUES
                    (:sender, :receiver, :rrole, :title, :message, :data, 0, NOW())
            ");
            $notif->execute([
                ':sender' => $userId,
                ':receiver' => $receiverId,
                ':rrole' => $receiverRole,
                ':title' => 'Respuesta a tu reseña',
                ':message' => 'Tienes una nueva respuesta a tu reseña.',
                ':data' => json_encode(['route' => '/reviews'])
            ]);
        }

        $this->send(200, ['success' => true, 'message' => 'Respuesta guardada', 'reply' => ['review_id' => $reviewId, 'sender_type' => $senderType, 'sender_id' => $userId, 'message' => $message, 'created_at' => date('Y-m-d H:i:s')]]);
    }

    /* ==================== MÉTODO PARA ACTUALIZAR RESPUESTA (CORREGIDO) ==================== */
    public function reply(int $reviewId): void
    {
        $userId = $this->checkAuth();
        $input = json_decode(file_get_contents('php://input'), true);
        $message = trim($input['message'] ?? '');

        if (!$message) {
            $this->send(400, ['message' => 'Mensaje vacío']);
        }

        // Determinar rol
        $stmtRole = $this->conn->prepare("SELECT role FROM users WHERE id = :uid");
        $stmtRole->execute([':uid' => $userId]);
        $role = $stmtRole->fetchColumn();

        if (!$role) {
            $this->send(403, ['message' => 'Usuario no encontrado']);
        }

        // Verificar que la reseña existe y pertenece al usuario
        if ($role === 'provider') {
            $stmt = $this->conn->prepare("
                SELECT id, user_id
                FROM service_reviews
                WHERE id = :rid AND provider_id = :pid
            ");
            $stmt->execute([':rid' => $reviewId, ':pid' => $userId]);
            $review = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$review) {
                $this->send(403, ['message' => 'No autorizado']);
            }

            $senderType = 'provider';
            $receiverId = (int)$review['user_id'];
            $receiverRole = 'user';
        } else {
            $stmt = $this->conn->prepare("
                SELECT id, provider_id
                FROM user_reviews
                WHERE id = :rid AND user_id = :uid
            ");
            $stmt->execute([':rid' => $reviewId, ':uid' => $userId]);
            $review = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$review) {
                $this->send(403, ['message' => 'No autorizado']);
            }

            $senderType = 'user';
            $receiverId = (int)$review['provider_id'];
            $receiverRole = 'provider';
        }

        // Actualizar respuesta existente
        $stmt = $this->conn->prepare("
            UPDATE review_messages
            SET message = :msg, created_at = NOW()
            WHERE review_id = :rid AND sender_type = :stype AND sender_id = :sid
        ");
        $stmt->execute([
            ':msg' => $message,
            ':rid' => $reviewId,
            ':stype' => $senderType,
            ':sid' => $userId
        ]);

        // Si no se actualizó nada, significa que no existía la respuesta
        if ($stmt->rowCount() === 0) {
            $this->send(404, ['message' => 'No existe una respuesta para actualizar']);
        }

        // Notificar al receptor de la actualización
        if ($receiverId > 0) {
            $notif = $this->conn->prepare("
                INSERT INTO notifications
                    (sender_id, receiver_id, receiver_role, title, message, data_json, is_read, created_at)
                VALUES
                    (:sender, :receiver, :rrole, :title, :message, :data, 0, NOW())
            ");
            $notif->execute([
                ':sender' => $userId,
                ':receiver' => $receiverId,
                ':rrole' => $receiverRole,
                ':title' => 'Respuesta actualizada',
                ':message' => 'Una respuesta a tu reseña fue actualizada.',
                ':data' => json_encode(['route' => '/reviews'])
            ]);
        }

        $this->send(200, ['success' => true, 'message' => 'Respuesta actualizada', 'reply' => ['review_id' => $reviewId, 'sender_type' => $senderType, 'sender_id' => $userId, 'message' => $message, 'created_at' => date('Y-m-d H:i:s')]]);
    }

    /* ================== HELPERS ================== */
    private function checkAuth(): int
    {
        $headers = getallheaders();
        $auth = $headers['Authorization'] ?? '';

        if (!str_starts_with($auth, 'Bearer ')) {
            $this->send(401, ['message' => 'Token no proporcionado']);
        }

        $token = str_replace('Bearer ', '', $auth);
        $decoded = JwtHandler::decode($token);

        if (!$decoded || !isset($decoded->id)) {
            $this->send(401, ['message' => 'Token inválido']);
        }

        return (int)$decoded->id;
    }

    private function send(int $code, array $data): void
    {
        http_response_code($code);
        header('Content-Type: application/json');
        echo json_encode($data);
        exit;
    }

    /* ---------- helper interno para subir imágenes ---------- */
    private function saveUploadedImages(int $historyId): array
    {
        $saved = [];
        if (empty($_FILES['images']['name'][0])) {
            return $saved;
        }

        $uploadDir = __DIR__ . '/../uploads/reviews/' . $historyId;
        if (!is_dir($uploadDir) && !mkdir($uploadDir, 0755, true)) {
            return $saved;
        }

        $total = count($_FILES['images']['name']);
        for ($i = 0; $i < $total; $i++) {
            $error = $_FILES['images']['error'][$i];
            $tmp   = $_FILES['images']['tmp_name'][$i];
            if ($error !== UPLOAD_ERR_OK || !is_uploaded_file($tmp)) {
                continue;
            }

            $ext   = strtolower(pathinfo($_FILES['images']['name'][$i], PATHINFO_EXTENSION));
            $name  = bin2hex(random_bytes(8)) . '.' . $ext;
            $dest  = $uploadDir . '/' . $name;

            if (move_uploaded_file($tmp, $dest)) {
                $baseUrl = getenv('API_BASE_URL');
                if (!$baseUrl) {
                    throw new Exception("API_BASE_URL environment variable is not set");
                }
                $url = rtrim($baseUrl, '/') . "/uploads/reviews/{$historyId}/{$name}";
                $saved[] = $url;
            }
        }
        return $saved;
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

        $contentType = $_SERVER['CONTENT_TYPE'] ?? '';
        if (str_contains($contentType, 'application/json')) {
            $input = json_decode(file_get_contents('php://input'), true) ?? [];
        } else {
            $input = $_POST;
        }

        if (!empty($_FILES['images']['name'][0])) {
            $input = array_merge($input, $_POST);
        }

        $historyId = $input['service_history_id'] ?? $input['id'] ?? null;
        $stars = $input['rating'] ?? null;
        $comment = trim($input['comment'] ?? '');

        if (!$historyId || !$stars || $stars < 1 || $stars > 5) {
            http_response_code(400);
            echo json_encode(['message' => 'Faltan datos o rating inválido']);
            return;
        }

        error_log("rate: historyId=$historyId, userId=$decoded->id, role=$decoded->role");

        // ✅ CORREGIDO: Permitir user_id, provider_id O admin
        if ($decoded->role === 'admin') {
            $stmt = $this->conn->prepare("SELECT * FROM service_history WHERE id = :hid");
            $stmt->execute([':hid' => $historyId]);
        } else {
            $stmt = $this->conn->prepare("SELECT * FROM service_history WHERE id = :hid AND (user_id = :uid OR provider_id = :uid)");
            $stmt->execute([':hid' => $historyId, ':uid' => $decoded->id]);
        }
        $history = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$history) {
            http_response_code(404);
            echo json_encode(['message' => 'Historial no encontrado o no autorizado']);
            return;
        }

        // Verificar si ya calificó
        $stmt = $this->conn->prepare("SELECT id FROM service_reviews WHERE service_history_id = :hid AND user_id = :uid");
        $stmt->execute([':hid' => $historyId, ':uid' => $decoded->id]);
        if ($stmt->fetch()) {
            http_response_code(409);
            echo json_encode(['message' => 'Ya calificaste este servicio']);
            return;
        }

        $tags = json_encode(array_filter(explode(',', $input['tags'] ?? ''))) ?: '[]';
        $jsonPhotos = array_filter(explode(',', $input['photos'] ?? ''));
        $uploadedPhotos = $this->saveUploadedImages((int)$historyId);
        $allPhotos = array_merge($jsonPhotos, $uploadedPhotos);
        $photos = json_encode($allPhotos) ?: '[]';

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
        $this->notifyProviderEvaluated((int)$history['provider_id'], (int)$stars, (int)$decoded->id);

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

    // ✅ CORREGIDO: Añadido el parámetro $userId que se estaba pasando pero no se recibía
    private function notifyProviderEvaluated(int $providerId, int $stars, int $userId): void
    {
        $message = "Un cliente te calificó con {$stars} estrella" . ($stars === 1 ? '' : 's') . ".";
        $dataJson = json_encode([
            'type' => 'review',
            'notification_type' => 'review_received',
            'route' => '/reviews',
            'url' => '/dashboard/provider/reviews',
            'action' => 'view_reviews'
        ]);

        // ✅ CORREGIDO: Guardar en BD con sender_id correcto
        $stmt = $this->conn->prepare("
            INSERT INTO notifications (sender_id, receiver_id, receiver_role, title, message, data_json, is_read, created_at)
            VALUES (:sender, :receiver, 'provider', :title, :message, :data, 0, NOW())
        ");
        $stmt->execute([
            ':sender'   => $userId,
            ':receiver' => $providerId,
            ':title'    => '¡Tienes una nueva evaluación!',
            ':message'  => $message,
            ':data'     => $dataJson
        ]);

        // ✅ NUEVO: Enviar notificación por WebSocket
        try {
            require_once __DIR__ . '/../services/WebSocketService.php';
            \Services\WebSocketService::sendNotification(
                'provider',
                $providerId,
                '¡Tienes una nueva evaluación!',
                $message,
                [
                    'event' => 'review_received',
                    'notification_type' => 'review_received',
                    'url' => '/dashboard/provider/reviews',
                    'action' => 'view_reviews',
                    'rating' => $stars
                ]
            );
        } catch (\Exception $e) {
            error_log("Error enviando WebSocket en notifyProviderEvaluated: " . $e->getMessage());
        }
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
        if (!$decoded || !isset($decoded->id) || !in_array($decoded->role, ['provider', 'user'])) {
            http_response_code(403);
            echo json_encode(['message' => 'No autorizado']);
            return;
        }

        if ($decoded->role === 'provider') {
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
                WHERE sr.provider_id = :id
                ORDER BY sr.created_at DESC
            ");
            $stmt->execute([':id' => $decoded->id]);
            $reviews = $stmt->fetchAll(PDO::FETCH_ASSOC);

            foreach ($reviews as &$r) {
                if ($r['provider_reply_message']) {
                    $r['provider_reply'] = [
                        'message' => $r['provider_reply_message'],
                        'created_at' => $r['provider_reply_createdAt']
                    ];
                } else {
                    $r['provider_reply'] = null;
                }
                unset($r['provider_reply_message'], $r['provider_reply_createdAt']);
            }

            $avg = $this->conn->prepare("SELECT AVG(rating) AS avg FROM service_reviews WHERE provider_id = :id");
            $avg->execute([':id' => $decoded->id]);
            $average = (float) ($avg->fetchColumn() ?: 0);

            echo json_encode([
                'success' => true,
                'average' => round($average, 1),
                'total'   => count($reviews),
                'reviews' => $reviews
            ]);
        } elseif ($decoded->role === 'user') {
            $stmt = $this->conn->prepare("
                SELECT
                    ur.id,
                    ur.rating,
                    ur.comment,
                    ur.created_at,
                    ur.photos,
                    ur.tags,
                    p.name       AS provider_name,
                    p.avatar_url AS provider_avatar,
                    sh.service_title,
                    COALESCE(hc.cnt, 0) AS helpful_count,
                    pm.message    AS user_reply_message,
                    pm.created_at AS user_reply_createdAt
                FROM user_reviews ur
                JOIN users p ON p.id = ur.provider_id
                JOIN service_history sh ON sh.id = ur.service_history_id
                LEFT JOIN (
                    SELECT review_id, COUNT(*) AS cnt
                    FROM review_helpful
                    GROUP BY review_id
                ) hc ON hc.review_id = ur.id
                LEFT JOIN review_messages pm
                       ON pm.review_id = ur.id
                      AND pm.sender_type = 'user'
                WHERE ur.user_id = :id
                ORDER BY ur.created_at DESC
            ");
            $stmt->execute([':id' => $decoded->id]);
            $reviews = $stmt->fetchAll(PDO::FETCH_ASSOC);

            foreach ($reviews as &$r) {
                if ($r['user_reply_message']) {
                    $r['user_reply'] = [
                        'message' => $r['user_reply_message'],
                        'created_at' => $r['user_reply_createdAt']
                    ];
                } else {
                    $r['user_reply'] = null;
                }
                unset($r['user_reply_message'], $r['user_reply_createdAt']);
            }

            $avg = $this->conn->prepare("SELECT AVG(rating) AS avg FROM user_reviews WHERE user_id = :id");
            $avg->execute([':id' => $decoded->id]);
            $average = (float) ($avg->fetchColumn() ?: 0);

            echo json_encode([
                'success' => true,
                'average' => round($average, 1),
                'total'   => count($reviews),
                'reviews' => $reviews
            ]);
        }
    }

    public function myUserReviews(): void
    {
        $userId = $this->checkAuth();

        $stmt = $this->conn->prepare("
            SELECT
                ur.id,
                ur.rating,
                ur.comment,
                ur.created_at,
                p.name AS provider_name,
                p.avatar_url AS provider_avatar,
                sh.service_title
            FROM user_reviews ur
            JOIN users p ON p.id = ur.provider_id
            JOIN service_history sh ON sh.id = ur.service_history_id
            WHERE ur.user_id = :uid
            ORDER BY ur.created_at DESC
        ");
        $stmt->execute([':uid' => $userId]);
        $reviews = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode([
            'success' => true,
            'reviews' => $reviews
        ]);
    }

    /* ---------- helper interno para subir imágenes (rateUser) ---------- */
    private function saveUploadedImagesUser(int $historyId): array
    {
        $saved = [];
        if (empty($_FILES['images']['name'][0])) {
            return $saved;
        }

        $uploadDir = __DIR__ . '/../uploads/user-reviews/' . $historyId;
        if (!is_dir($uploadDir) && !mkdir($uploadDir, 0755, true)) {
            return $saved;
        }

        $total = count($_FILES['images']['name']);
        for ($i = 0; $i < $total; $i++) {
            $error = $_FILES['images']['error'][$i];
            $tmp   = $_FILES['images']['tmp_name'][$i];
            if ($error !== UPLOAD_ERR_OK || !is_uploaded_file($tmp)) {
                continue;
            }

            $ext   = strtolower(pathinfo($_FILES['images']['name'][$i], PATHINFO_EXTENSION));
            $name  = bin2hex(random_bytes(8)) . '.' . $ext;
            $dest  = $uploadDir . '/' . $name;

            if (move_uploaded_file($tmp, $dest)) {
                $baseUrl = getenv('API_BASE_URL');
                if (!$baseUrl) {
                    throw new Exception("API_BASE_URL environment variable is not set");
                }
                $url = rtrim($baseUrl, '/') . "/uploads/user-reviews/{$historyId}/{$name}";
                $saved[] = $url;
            }
        }
        return $saved;
    }

    public function rateUser(): void
    {
        $providerId = $this->checkAuth();

        $contentType = $_SERVER['CONTENT_TYPE'] ?? '';
        if (str_contains($contentType, 'application/json')) {
            $input = json_decode(file_get_contents('php://input'), true) ?? [];
        } else {
            $input = $_POST;
        }

        if (!empty($_FILES['images']['name'][0])) {
            $input = array_merge($input, $_POST);
        }

        $historyId = $input['service_history_id'] ?? $input['id'] ?? null;
        $stars     = $input['rating'] ?? null;
        $comment   = trim($input['comment'] ?? '');

        if (!$historyId || !$stars || $stars < 1 || $stars > 5) {
            $this->send(400, ['message' => 'Datos incompletos o rating inválido']);
        }

        $stmt = $this->conn->prepare("
            SELECT user_id
            FROM service_history
            WHERE id = :hid AND provider_id = :pid
        ");
        $stmt->execute([':hid' => $historyId, ':pid' => $providerId]);
        $history = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$history) {
            $this->send(403, ['message' => 'No autorizado']);
        }

        $userId = (int)$history['user_id'];

        $stmt = $this->conn->prepare("
            SELECT id
            FROM user_reviews
            WHERE service_history_id = :hid
        ");
        $stmt->execute([':hid' => $historyId]);
        if ($stmt->fetch()) {
            $this->send(409, ['message' => 'Ya evaluaste a este usuario']);
        }

        $jsonPhotos      = array_filter(explode(',', $input['photos'] ?? ''));
        $uploadedPhotos  = $this->saveUploadedImagesUser((int)$historyId);
        $allPhotos       = array_merge($jsonPhotos, $uploadedPhotos);
        $photos          = json_encode($allPhotos) ?: '[]';
        $tags            = json_encode(array_filter(explode(',', $input['tags'] ?? ''))) ?: '[]';

        $stmt = $this->conn->prepare("
            INSERT INTO user_reviews
                (service_history_id, provider_id, user_id, rating, comment, tags, photos)
            VALUES
                (:hid, :pid, :uid, :rating, :comment, :tags, :photos)
        ");
        $stmt->execute([
            ':hid'     => $historyId,
            ':pid'     => $providerId,
            ':uid'     => $userId,
            ':rating'  => $stars,
            ':comment' => $comment,
            ':tags'    => $tags,
            ':photos'  => $photos
        ]);

        $this->notifyUserEvaluated($userId, $stars, $providerId);
        $this->send(200, ['success' => true, 'message' => 'Evaluación guardada']);
    }

    // ✅ CORREGIDO: Añadido el parámetro $providerId que se estaba pasando pero no se recibía
    private function notifyUserEvaluated(int $userId, int $stars, int $providerId): void
    {
        $message = "Un proveedor te calificó con {$stars} estrella" . ($stars === 1 ? '' : 's') . ".";
        $dataJson = json_encode([
            'type' => 'review',
            'notification_type' => 'review_received',
            'route' => '/my-reviews',
            'url' => '/reviews',
            'action' => 'view_reviews'
        ]);

        $stmt = $this->conn->prepare("
            INSERT INTO notifications (sender_id, receiver_id, receiver_role, title, message, data_json, is_read, created_at)
            VALUES (:sender, :receiver, 'user', :title, :message, :data, 0, NOW())
        ");
        $stmt->execute([
            ':sender'   => $providerId,
            ':receiver' => $userId,
            ':title'    => '¡Tienes una nueva evaluación!',
            ':message'  => $message,
            ':data'     => $dataJson
        ]);

        try {
            require_once __DIR__ . '/../services/WebSocketService.php';
            \Services\WebSocketService::sendNotification(
                'user',
                $userId,
                '¡Tienes una nueva evaluación!',
                $message,
                [
                    'event' => 'review_received',
                    'notification_type' => 'review_received',
                    'url' => '/reviews',
                    'action' => 'view_reviews',
                    'rating' => $stars
                ]
            );
        } catch (\Exception $e) {
            error_log("Error enviando WebSocket en notifyUserEvaluated: " . $e->getMessage());
        }
    }

    public function myReviews(): void
    {
        $userId = $this->checkAuth();

        $stmt = $this->conn->prepare("
            SELECT
                sr.id,
                sr.rating,
                sr.comment,
                sr.created_at,
                sr.tags,
                sr.photos,
                p.name       AS provider_name,
                p.avatar_url AS provider_avatar,
                sh.service_title,
                COALESCE(hc.cnt, 0) AS helpful_count,
                pm.message    AS provider_reply_message,
                pm.created_at AS provider_reply_createdAt
            FROM service_reviews sr
            JOIN users p ON p.id = sr.provider_id
            JOIN service_history sh ON sh.id = sr.service_history_id
            LEFT JOIN (
                SELECT review_id, COUNT(*) AS cnt
                FROM review_helpful
                GROUP BY review_id
            ) hc ON hc.review_id = sr.id
            LEFT JOIN review_messages pm
                   ON pm.review_id = sr.id
                  AND pm.sender_type = 'provider'
            WHERE sr.user_id = :uid
            ORDER BY sr.created_at DESC
        ");
        $stmt->execute([':uid' => $userId]);
        $reviews = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($reviews as &$r) {
            if ($r['provider_reply_message']) {
                $r['provider_reply'] = [
                    'message' => $r['provider_reply_message'],
                    'created_at' => $r['provider_reply_createdAt']
                ];
            } else {
                $r['provider_reply'] = null;
            }
            unset($r['provider_reply_message'], $r['provider_reply_createdAt']);
        }

        echo json_encode([
            'success' => true,
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

        $sql = "
            SELECT
                h.id,
                h.service_title,
                h.service_description,
                h.service_price,
                h.user_name,
                h.user_avatar,
                h.finished_at,
                h.status,
                h.cancelled_by,
                h.payment_status,
                h.payment_method
            FROM service_history h
            WHERE h.user_id = :userId OR h.provider_id = :providerId
            ORDER BY h.finished_at DESC
        ";

        $stmt = $this->conn->prepare($sql);
        $stmt->execute([
            ':userId'    => $decoded->id,
            ':providerId'=> $decoded->id
        ]);
        $data = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode([
            'success' => true,
            'history' => $data
        ]);
    }
}
