<?php
require_once __DIR__ . "/../middleware/Auth.php";
require_once __DIR__ . '/../models/History.php';
require_once __DIR__ . '/../utils/jwt.php';
require_once __DIR__ . '/../utils/Uploader.php';

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
            ($method === 'PUT'  && preg_match('~/api/reviews/\d+/reply/?$~', $path)) ||
            ($method === 'POST' && preg_match('~/api/reviews/image/?$~', $path)) ||
            ($method === 'POST' && preg_match('~/api/reviews/helpful/?$~', $path)) ||
            ($method === 'POST' && preg_match('~/api/reviews/report/?$~', $path)) ||
            ($method === 'POST' && preg_match('~/api/reviews/report-content/?$~', $path)) ||
            ($method === 'GET'  && preg_match('~/api/admin/reports/?$~', $path)) ||
            ($method === 'POST' && preg_match('~/api/admin/resolve-report/?$~', $path))
        ) {
            // Procesamiento de rutas (ordenado de más específico a menos específico)
            if ($method === 'POST' && preg_match('~/api/reviews/image/?$~', $path)) {
                $this->uploadReviewImage();
            } elseif ($method === 'POST' && preg_match('~/api/reviews/helpful/?$~', $path)) {
                $this->markHelpful();
            } elseif ($method === 'POST' && preg_match('~/api/reviews/report/?$~', $path)) {
                $this->report();
            } elseif ($method === 'POST' && preg_match('~/api/reviews/report-content/?$~', $path)) {
                $this->reportContent();
            } elseif ($method === 'GET' && preg_match('~/api/admin/reports/?$~', $path)) {
                $this->getReports();
            } elseif ($method === 'POST' && preg_match('~/api/admin/resolve-report/?$~', $path)) {
                $this->resolveReport();
            } elseif ($method === 'PUT' && preg_match('~/api/reviews/(\d+)/reply/?$~', $path, $m)) {
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

    // ✅ Subir imagen de reseña
    public function uploadReviewImage(): void
    {
        $userId = $this->checkAuth();

        if (empty($_FILES['file'])) {
            $this->send(400, ['message' => 'No se recibió archivo']);
        }

        $file = $_FILES['file'];
        if ($file['error'] !== UPLOAD_ERR_OK) {
            $this->send(400, ['message' => 'Error al subir archivo']);
        }

        $allowed = ['image/jpeg', 'image/png', 'image/webp'];
        $finfo = finfo_open(FILEINFO_MIME_TYPE);
        $mime = finfo_file($finfo, $file['tmp_name']);
        finfo_close($finfo);

        if (!in_array($mime, $allowed)) {
            $this->send(400, ['message' => 'Formato no permitido. Usa JPG, PNG o WEBP']);
        }

        if ($file['size'] > 5 * 1024 * 1024) {
            $this->send(400, ['message' => 'La imagen no debe superar 5MB']);
        }

        $basePath = __DIR__ . '/../public/uploads';
        $baseUrl = rtrim(getenv('API_BASE_URL') ?: '', '/') . '/uploads';
        $uploader = new \Utils\Uploader($basePath, $baseUrl);

        try {
            $url = $uploader->saveFile($file, \Utils\Uploader::CAT_REVIEWS . '/temp');
        } catch (\RuntimeException $e) {
            $this->send(500, ['message' => 'Error al guardar imagen: ' . $e->getMessage()]);
        }
        $this->send(200, ['success' => true, 'url' => $url]);
    }

    // ✅ Marcar como útil
    public function markHelpful(): void
    {
        $userId = $this->checkAuth();
        $input = json_decode(file_get_contents('php://input'), true);

        $reviewId = $input['review_id'] ?? null;
        $reviewType = $input['review_type'] ?? 'service';

        if (!$reviewId) {
            $this->send(400, ['message' => 'Falta review_id']);
        }

        $stmt = $this->conn->prepare(
            "SELECT id FROM review_helpful WHERE review_id = :rid AND review_type = :rtype AND user_id = :uid"
        );
        $stmt->execute([':rid' => $reviewId, ':rtype' => $reviewType, ':uid' => $userId]);

        if ($stmt->fetch()) {
            $this->send(409, ['message' => 'Ya votaste como útil']);
        }

        $stmt = $this->conn->prepare(
            "INSERT INTO review_helpful (review_id, review_type, user_id) VALUES (:rid, :rtype, :uid)"
        );
        $stmt->execute([':rid' => $reviewId, ':rtype' => $reviewType, ':uid' => $userId]);

        $stmt = $this->conn->prepare(
            "SELECT COUNT(*) FROM review_helpful WHERE review_id = :rid AND review_type = :rtype"
        );
        $stmt->execute([':rid' => $reviewId, ':rtype' => $reviewType]);
        $count = (int)$stmt->fetchColumn();

        $this->send(200, ['success' => true, 'helpful_count' => $count]);
    }

    // ✅ Reportar reseña (simple)
    public function report(): void
    {
        $userId = $this->checkAuth();
        $input = json_decode(file_get_contents('php://input'), true);

        $reviewId = $input['review_id'] ?? null;
        $reviewType = $input['review_type'] ?? 'service';

        if (!$reviewId) {
            $this->send(400, ['message' => 'Falta review_id']);
        }

        $stmt = $this->conn->prepare(
            "SELECT id FROM review_reports WHERE review_id = :rid AND review_type = :rtype AND user_id = :uid"
        );
        $stmt->execute([':rid' => $reviewId, ':rtype' => $reviewType, ':uid' => $userId]);

        if ($stmt->fetch()) {
            $this->send(409, ['message' => 'Ya reportaste esta reseña']);
        }

        $stmt = $this->conn->prepare(
            "INSERT INTO review_reports (review_id, review_type, user_id, reason, status, created_at) 
             VALUES (:rid, :rtype, :uid, 'No especificado', 'pending', NOW())"
        );
        $stmt->execute([':rid' => $reviewId, ':rtype' => $reviewType, ':uid' => $userId]);

        // Notificar a admins
        $this->notifyAdminsAboutReport($reviewId, $reviewType, $userId, 'No especificado');

        $this->send(200, ['success' => true, 'message' => 'Reseña reportada']);
    }

    // ✅ Reportar contenido con motivo (CORREGIDO)
    public function reportContent(): void
    {
        $userId = $this->checkAuth();
        $input = json_decode(file_get_contents('php://input'), true);

        $reviewId = $input['review_id'] ?? null;
        $reviewType = $input['review_type'] ?? 'service';
        $reason = $input['reason'] ?? 'No especificado';
        $comment = $input['comment'] ?? '';

        if (!$reviewId) {
            $this->send(400, ['message' => 'Falta review_id']);
        }

        $stmt = $this->conn->prepare(
            "SELECT id FROM review_reports WHERE review_id = :rid AND review_type = :rtype AND user_id = :uid"
        );
        $stmt->execute([':rid' => $reviewId, ':rtype' => $reviewType, ':uid' => $userId]);

        if ($stmt->fetch()) {
            $this->send(409, ['message' => 'Ya reportaste esta reseña']);
        }

        // CORREGIDO: SQL con todos los parámetros
        $stmt = $this->conn->prepare(
            "INSERT INTO review_reports (review_id, review_type, user_id, reason, comment, status, created_at) 
             VALUES (:rid, :rtype, :uid, :reason, :comment, 'pending', NOW())"
        );
        $stmt->execute([
            ':rid' => $reviewId,
            ':rtype' => $reviewType,
            ':uid' => $userId,
            ':reason' => $reason,
            ':comment' => $comment
        ]);

        $reportId = $this->conn->lastInsertId();

        // Notificar a admins
        $this->notifyAdminsAboutReport($reviewId, $reviewType, $userId, $reason, $comment);

        error_log("Reporte de contenido: review_id=$reviewId, type=$reviewType, reason=$reason, user=$userId");

        $this->send(200, [
            'success' => true, 
            'message' => 'Contenido denunciado. Un administrador lo revisará pronto.',
            'report_id' => $reportId
        ]);
    }

    // ✅ NUEVO: Obtener reportes (solo admin/moderator)
    public function getReports(): void
    {
        $userId = $this->checkAuth();
        $this->checkAdminAccess($userId);

        $status = $_GET['status'] ?? 'all';
        $page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
        $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 20;
        $offset = ($page - 1) * $limit;

        $whereClause = "";
        $params = [];

        if ($status !== 'all') {
            $whereClause = "WHERE r.status = :status";
            $params[':status'] = $status;
        }

        // Obtener reportes con información relacionada
        $sql = "SELECT 
                    r.id,
                    r.review_id,
                    r.review_type,
                    r.reason,
                    r.comment,
                    r.status,
                    r.action_taken,
                    r.resolution_note,
                    r.created_at,
                    r.resolved_at,
                    u.id as reporter_id,
                    u.name as reporter_name,
                    u.email as reporter_email,
                    admin.name as resolver_name
                FROM review_reports r
                JOIN users u ON r.user_id = u.id
                LEFT JOIN users admin ON r.resolved_by = admin.id
                {$whereClause}
                ORDER BY r.created_at DESC
                LIMIT :limit OFFSET :offset";

        $stmt = $this->conn->prepare($sql);

        if ($status !== 'all') {
            $stmt->bindParam(':status', $status, PDO::PARAM_STR);
        }
        $stmt->bindParam(':limit', $limit, PDO::PARAM_INT);
        $stmt->bindParam(':offset', $offset, PDO::PARAM_INT);
        $stmt->execute();

        $reports = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // Contar total para paginación
        $countSql = "SELECT COUNT(*) FROM review_reports r {$whereClause}";
        $countStmt = $this->conn->prepare($countSql);
        if ($status !== 'all') {
            $countStmt->bindParam(':status', $status, PDO::PARAM_STR);
        }
        $countStmt->execute();
        $total = $countStmt->fetchColumn();

        $this->send(200, [
            'success' => true,
            'data' => $reports,
            'pagination' => [
                'total' => (int)$total,
                'page' => $page,
                'limit' => $limit,
                'total_pages' => ceil($total / $limit)
            ]
        ]);
    }

    // ✅ NUEVO: Resolver un reporte
    public function resolveReport(): void
    {
        $userId = $this->checkAuth();
        $this->checkAdminAccess($userId);
        
        $input = json_decode(file_get_contents('php://input'), true);
        
        $reportId = $input['report_id'] ?? null;
        $action = $input['action'] ?? 'dismiss';
        $resolutionNote = $input['resolution_note'] ?? '';

        if (!$reportId) {
            $this->send(400, ['message' => 'Falta report_id']);
        }

        // Actualizar reporte
        $stmt = $this->conn->prepare(
            "UPDATE review_reports 
             SET status = 'resolved', 
                 resolved_by = :admin_id, 
                 resolution_note = :note,
                 action_taken = :action,
                 resolved_at = NOW() 
             WHERE id = :report_id"
        );
        $stmt->execute([
            ':admin_id' => $userId,
            ':note' => $resolutionNote,
            ':action' => $action,
            ':report_id' => $reportId
        ]);

        // Si la acción es eliminar reseña
        if ($action === 'delete_review') {
            $stmt = $this->conn->prepare("SELECT review_id, review_type FROM review_reports WHERE id = :rid");
            $stmt->execute([':rid' => $reportId]);
            $report = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if ($report) {
                $this->deleteReview($report['review_id'], $report['review_type']);
            }
        }

        // Notificar al usuario que reportó
        $stmt = $this->conn->prepare(
            "SELECT u.id, u.email, u.name, r.review_id 
             FROM review_reports r 
             JOIN users u ON r.user_id = u.id 
             WHERE r.id = :rid"
        );
        $stmt->execute([':rid' => $reportId]);
        $reporter = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($reporter) {
            $this->notifyUserAboutResolution($reporter, $action, $resolutionNote);
        }

        $this->send(200, [
            'success' => true,
            'message' => 'Reporte resuelto exitosamente'
        ]);
    }

    // ✅ Método para obtener historial por ID de request
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

    // ✅ updateReview ahora soporta user_reviews
    public function updateReview(int $reviewId): void
    {
        $userId = $this->checkAuth();
        $input = json_decode(file_get_contents('php://input'), true);
        $reviewType = $input['review_type'] ?? 'service';

        if ($reviewType === 'user') {
            $stmt = $this->conn->prepare("SELECT id FROM user_reviews WHERE id = :rid AND provider_id = :uid");
        } else {
            $stmt = $this->conn->prepare("SELECT id FROM service_reviews WHERE id = :rid AND user_id = :uid");
        }
        $stmt->execute([':rid' => $reviewId, ':uid' => $userId]);

        if (!$stmt->fetch()) {
            $this->send(403, ['message' => 'No autorizado']);
        }

        if ($reviewType === 'user') {
            $stmt = $this->conn->prepare("UPDATE user_reviews SET comment = :c, tags = :t WHERE id = :id");
        } else {
            $stmt = $this->conn->prepare("UPDATE service_reviews SET comment = :c, tags = :t WHERE id = :id");
        }
        $stmt->execute([
            ':c' => $input['comment'] ?? '',
            ':t' => json_encode($input['tags'] ?? []),
            ':id' => $reviewId
        ]);

        $this->send(200, ['success' => true]);
    }

    /* ==================== MÉTODO PARA CREAR RESPUESTA (CORREGIDO) ==================== */
    public function createReply(int $reviewId): void
    {
        $userId = $this->checkAuth();
        $input = json_decode(file_get_contents('php://input'), true);
        $message = trim($input['message'] ?? '');
        $reviewType = $input['review_type'] ?? 'service';

        if (!$message) {
            $this->send(400, ['message' => 'Mensaje vacío']);
        }

        $stmtRole = $this->conn->prepare("SELECT role FROM users WHERE id = :uid");
        $stmtRole->execute([':uid' => $userId]);
        $role = $stmtRole->fetchColumn();

        if (!$role) {
            $this->send(403, ['message' => 'Usuario no encontrado']);
        }

        if ($reviewType === 'service') {
            $stmt = $this->conn->prepare("
                SELECT id, user_id FROM service_reviews
                WHERE id = :rid AND (provider_id = :pid OR :role = 'admin')
            ");
            $stmt->execute([':rid' => $reviewId, ':pid' => $userId, ':role' => $role]);
            $review = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$review) {
                $this->send(403, ['message' => 'No autorizado para responder esta reseña']);
            }

            $senderType = ($role === 'admin') ? 'admin' : 'provider';
            $receiverId = (int)$review['user_id'];
            $receiverRole = 'user';
        } else {
            $stmt = $this->conn->prepare("
                SELECT id, provider_id FROM user_reviews
                WHERE id = :rid AND (user_id = :uid OR :role = 'admin')
            ");
            $stmt->execute([':rid' => $reviewId, ':uid' => $userId, ':role' => $role]);
            $review = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$review) {
                $this->send(403, ['message' => 'No autorizado para responder esta reseña']);
            }

            $senderType = ($role === 'admin') ? 'admin' : 'user';
            $receiverId = (int)$review['provider_id'];
            $receiverRole = 'provider';
        }

        // Verificar si ya existe una respuesta
        $stmt = $this->conn->prepare("
            SELECT id FROM review_messages
            WHERE review_id = :rid AND review_type = :rtype AND sender_type = :stype AND sender_id = :sid
        ");
        $stmt->execute([
            ':rid' => $reviewId,
            ':rtype' => $reviewType,
            ':stype' => $senderType,
            ':sid' => $userId
        ]);

        if ($stmt->fetch()) {
            $this->send(409, ['message' => 'Ya has respondido esta reseña']);
        }

        // Insertar nueva respuesta
        $stmt = $this->conn->prepare("
            INSERT INTO review_messages (review_id, review_type, sender_type, sender_id, message, created_at)
            VALUES (:rid, :rtype, :stype, :sid, :msg, NOW())
        ");
        $stmt->execute([
            ':rid' => $reviewId,
            ':rtype' => $reviewType,
            ':stype' => $senderType,
            ':sid' => $userId,
            ':msg' => $message
        ]);

        // Notificar al receptor
        if ($receiverId > 0) {
            $notif = $this->conn->prepare("
                INSERT INTO notifications (sender_id, receiver_id, receiver_role, title, message, data_json, is_read, created_at)
                VALUES (:sender, :receiver, :rrole, :title, :message, :data, 0, NOW())
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

        $this->send(200, ['success' => true, 'message' => 'Respuesta guardada', 'reply' => ['review_id' => $reviewId, 'review_type' => $reviewType, 'sender_type' => $senderType, 'sender_id' => $userId, 'message' => $message, 'created_at' => date('Y-m-d H:i:s')]]);
    }

    /* ==================== MÉTODO PARA ACTUALIZAR RESPUESTA ==================== */
    public function reply(int $reviewId): void
    {
        $userId = $this->checkAuth();
        $input = json_decode(file_get_contents('php://input'), true);
        $message = trim($input['message'] ?? '');
        $reviewType = $input['review_type'] ?? 'service';

        if (!$message) {
            $this->send(400, ['message' => 'Mensaje vacío']);
        }

        $stmtRole = $this->conn->prepare("SELECT role FROM users WHERE id = :uid");
        $stmtRole->execute([':uid' => $userId]);
        $role = $stmtRole->fetchColumn();

        if (!$role) {
            $this->send(403, ['message' => 'Usuario no encontrado']);
        }

        if ($reviewType === 'service') {
            $stmt = $this->conn->prepare("
                SELECT id, user_id FROM service_reviews
                WHERE id = :rid AND (provider_id = :pid OR :role = 'admin')
            ");
            $stmt->execute([':rid' => $reviewId, ':pid' => $userId, ':role' => $role]);
            $review = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$review) {
                $this->send(403, ['message' => 'No autorizado']);
            }

            $senderType = ($role === 'admin') ? 'admin' : 'provider';
            $receiverId = (int)$review['user_id'];
            $receiverRole = 'user';
        } else {
            $stmt = $this->conn->prepare("
                SELECT id, provider_id FROM user_reviews
                WHERE id = :rid AND (user_id = :uid OR :role = 'admin')
            ");
            $stmt->execute([':rid' => $reviewId, ':uid' => $userId, ':role' => $role]);
            $review = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$review) {
                $this->send(403, ['message' => 'No autorizado']);
            }

            $senderType = ($role === 'admin') ? 'admin' : 'user';
            $receiverId = (int)$review['provider_id'];
            $receiverRole = 'provider';
        }

        // Actualizar respuesta existente
        $stmt = $this->conn->prepare("
            UPDATE review_messages
            SET message = :msg, created_at = NOW()
            WHERE review_id = :rid AND review_type = :rtype AND sender_type = :stype AND sender_id = :sid
        ");
        $stmt->execute([
            ':msg' => $message,
            ':rid' => $reviewId,
            ':rtype' => $reviewType,
            ':stype' => $senderType,
            ':sid' => $userId
        ]);

        if ($stmt->rowCount() === 0) {
            $this->send(404, ['message' => 'No existe una respuesta para actualizar']);
        }

        if ($receiverId > 0) {
            $notif = $this->conn->prepare("
                INSERT INTO notifications (sender_id, receiver_id, receiver_role, title, message, data_json, is_read, created_at)
                VALUES (:sender, :receiver, :rrole, :title, :message, :data, 0, NOW())
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

        $this->send(200, ['success' => true, 'message' => 'Respuesta actualizada', 'reply' => ['review_id' => $reviewId, 'review_type' => $reviewType, 'sender_type' => $senderType, 'sender_id' => $userId, 'message' => $message, 'created_at' => date('Y-m-d H:i:s')]]);
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

    // Verificar acceso de admin
    private function checkAdminAccess(int $userId): void
    {
        $stmt = $this->conn->prepare("SELECT role FROM users WHERE id = :uid AND active = 1");
        $stmt->execute([':uid' => $userId]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$user || !in_array($user['role'], ['admin', 'moderator'])) {
            $this->send(403, ['message' => 'Acceso denegado. Solo administradores.']);
        }
    }

    // Notificar a todos los admins sobre un reporte
    private function notifyAdminsAboutReport(int $reviewId, string $reviewType, int $reporterId, string $reason, string $comment = ''): void
    {
        // Obtener información del usuario que reporta
        $stmt = $this->conn->prepare("SELECT name FROM users WHERE id = :uid");
        $stmt->execute([':uid' => $reporterId]);
        $reporter = $stmt->fetch(PDO::FETCH_ASSOC);
        $reporterName = $reporter['name'] ?? 'Usuario';

        // Obtener todos los admins y moderadores
        $stmt = $this->conn->prepare(
            "SELECT id, email, name, role FROM users WHERE role IN ('admin', 'moderator') AND active = 1"
        );
        $stmt->execute();
        $admins = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($admins as $admin) {
            // Guardar notificación en BD para cada admin
            $notifStmt = $this->conn->prepare(
                "INSERT INTO notifications (sender_id, receiver_id, receiver_role, title, message, data_json, is_read, created_at) 
                 VALUES (:sender, :receiver, :role, :title, :message, :data, 0, NOW())"
            );
            $notifStmt->execute([
                ':sender' => $reporterId,
                ':receiver' => $admin['id'],
                ':role' => $admin['role'],
                ':title' => 'Nueva reseña reportada',
                ':message' => "El usuario {$reporterName} ha reportado una reseña. Motivo: {$reason}",
                ':data' => json_encode([
                    'type' => 'review_reported',
                    'review_id' => $reviewId,
                    'review_type' => $reviewType,
                    'reason' => $reason,
                    'comment' => $comment,
                    'route' => '/admin/reports'
                ])
            ]);

            // Intentar enviar notificación por WebSocket
            try {
                if (file_exists(__DIR__ . '/../services/WebSocketService.php')) {
                    require_once __DIR__ . '/../services/WebSocketService.php';
                    \Services\WebSocketService::sendNotification(
                        $admin['role'],
                        $admin['id'],
                        'Nueva reseña reportada',
                        "El usuario {$reporterName} ha reportado una reseña. Motivo: {$reason}",
                        [
                            'event' => 'review_reported',
                            'notification_type' => 'review_reported',
                            'url' => '/admin/reports',
                            'action' => 'view_reports'
                        ]
                    );
                }
            } catch (\Exception $e) {
                error_log("Error enviando WebSocket en notifyAdminsAboutReport: " . $e->getMessage());
            }
        }
    }

    // Eliminar reseña (soft delete)
    private function deleteReview(int $reviewId, string $reviewType): void
    {
        if ($reviewType === 'service' || $reviewType === 'service_review') {
            $stmt = $this->conn->prepare("UPDATE service_reviews SET is_deleted = 1, deleted_at = NOW() WHERE id = :rid");
        } else {
            $stmt = $this->conn->prepare("UPDATE user_reviews SET is_deleted = 1, deleted_at = NOW() WHERE id = :rid");
        }
        $stmt->execute([':rid' => $reviewId]);
    }

    // Notificar al usuario sobre la resolución de su reporte
    private function notifyUserAboutResolution(array $user, string $action, string $note): void
    {
        $message = match($action) {
            'dismiss' => 'Tu reporte ha sido revisado y no se encontraron violaciones.',
            'delete_review' => 'La reseña que reportaste ha sido eliminada por violar nuestras políticas.',
            'warn_user' => 'El usuario reportado ha recibido una advertencia.',
            default => 'Tu reporte ha sido procesado.'
        };

        if ($note) {
            $message .= " Nota del administrador: {$note}";
        }

        $stmt = $this->conn->prepare(
            "INSERT INTO notifications (sender_id, receiver_id, receiver_role, title, message, data_json, is_read, created_at) 
             VALUES (:sender, :receiver, 'user', 'Reporte resuelto', :message, :data, 0, NOW())"
        );
        $stmt->execute([
            ':sender' => 0, // Sistema
            ':receiver' => $user['id'],
            ':message' => $message,
            ':data' => json_encode(['route' => '/reviews'])
        ]);

        // Intentar enviar por WebSocket
        try {
            if (file_exists(__DIR__ . '/../services/WebSocketService.php')) {
                require_once __DIR__ . '/../services/WebSocketService.php';
                \Services\WebSocketService::sendNotification(
                    'user',
                    $user['id'],
                    'Reporte resuelto',
                    $message,
                    [
                        'event' => 'report_resolved',
                        'notification_type' => 'report_resolved',
                        'url' => '/reviews',
                        'action' => 'view_resolution'
                    ]
                );
            }
        } catch (\Exception $e) {
            error_log("Error enviando WebSocket en notifyUserAboutResolution: " . $e->getMessage());
        }
    }

    /* ---------- helper interno para subir imágenes ---------- */
    private function saveUploadedImages(int $historyId): array
    {
        $saved = [];
        if (empty($_FILES['images']['name'][0])) {
            return $saved;
        }

        $basePath = __DIR__ . '/../public/uploads';
        $baseUrl = rtrim(getenv('API_BASE_URL') ?: '', '/') . '/uploads';
        $uploader = new \Utils\Uploader($basePath, $baseUrl);

        $total = count($_FILES['images']['name']);
        for ($i = 0; $i < $total; $i++) {
            $error = $_FILES['images']['error'][$i];
            $tmp   = $_FILES['images']['tmp_name'][$i];
            if ($error !== UPLOAD_ERR_OK || !is_uploaded_file($tmp)) {
                continue;
            }

            try {
                $url = $uploader->saveFile([
                    'tmp_name' => $tmp,
                    'name' => $_FILES['images']['name'][$i],
                    'error' => $error
                ], \Utils\Uploader::CAT_REVIEWS . '/' . $historyId);
                $saved[] = $url;
            } catch (\RuntimeException $e) {
                continue;
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
        $stars = $input['rating'] ?? $input['stars'] ?? null;
        $comment = trim($input['comment'] ?? '');

        if (!$historyId || !$stars || $stars < 1 || $stars > 5) {
            http_response_code(400);
            echo json_encode(['message' => 'Faltan datos o rating inválido']);
            return;
        }

        error_log("rate: historyId=$historyId, userId=$decoded->id, role=$decoded->role, photos=" . ($input['photos'] ?? 'sin fotos'));

        if ($decoded->role === 'admin') {
            $stmt = $this->conn->prepare("SELECT * FROM service_history WHERE id = :hid");
            $stmt->execute([':hid' => $historyId, ':pid' => $reviewerId]);
        } else {
            $stmt = $this->conn->prepare("SELECT * FROM service_history WHERE id = :hid AND user_id = :uid");
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

        $photosInput = $input['photos'] ?? $input['images'] ?? '';

        if (is_array($photosInput)) {
            $photosInput = implode(',', $photosInput);
        }
        if (str_starts_with($photosInput, '[')) {
            $decodedPhotos = json_decode($photosInput, true);
            $photosInput = is_array($decodedPhotos) ? implode(',', $decodedPhotos) : '';
        }

        $jsonPhotos = array_filter(explode(',', $photosInput));
        $uploadedPhotos = $this->saveUploadedImages((int)$historyId);
        $allPhotos = array_merge($jsonPhotos, $uploadedPhotos);
        $photos = json_encode(array_values($allPhotos)) ?: '[]';

        $tags = json_encode(array_filter(explode(',', $input['tags'] ?? ''))) ?: '[]';

        error_log("rate: guardando photos=$photos, tags=$tags");

        $stmt = $this->conn->prepare("
            INSERT INTO service_reviews (service_history_id, user_id, provider_id, rating, comment, tags, photos)
            VALUES (:hid, :uid, :pid, :rating, :comment, :tags, :photos)
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

        echo json_encode(['success' => true, 'message' => 'Reseña guardada', 'photos_saved' => count($allPhotos)]);
    }

    private function updateProviderAverage(int $providerId): void
    {
        $stmt = $this->conn->prepare("
            UPDATE users SET average_rating = (
                SELECT ROUND(AVG(rating), 1) FROM service_reviews WHERE provider_id = :pid
            )
            WHERE id = :pid
        ");
        $stmt->execute([':pid' => $providerId]);
    }

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

    // ✅ receivedReviews ahora soporta admin
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
        if (!$decoded || !isset($decoded->id) || !in_array($decoded->role, ['provider', 'user', 'admin'])) {
            http_response_code(403);
            echo json_encode(['message' => 'No autorizado']);
            return;
        }

        $reviews = [];
        $average = 0;
        $total = 0;

        if ($decoded->role === 'provider') {
            $stmt = $this->conn->prepare("
                SELECT
                    sr.id, sr.rating, sr.comment, sr.created_at, sr.tags, sr.photos,
                    sr.service_history_id, sr.user_id, sr.provider_id,
                    u.name AS user_name, u.avatar_url AS user_avatar,
                    sh.service_title,
                    COALESCE(hc.cnt, 0) AS helpful_count,
                    pm.message AS provider_reply_message,
                    pm.created_at AS provider_reply_createdAt,
                    'service' AS review_type
                FROM service_reviews sr
                JOIN users u ON u.id = sr.user_id
                JOIN service_history sh ON sh.id = sr.service_history_id
                LEFT JOIN (
                    SELECT review_id, COUNT(*) AS cnt FROM review_helpful
                    WHERE review_type = 'service' GROUP BY review_id
                ) hc ON hc.review_id = sr.id
                LEFT JOIN review_messages pm
                       ON pm.review_id = sr.id AND pm.review_type = 'service'
                      AND pm.sender_type IN ('provider', 'admin')
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

            $avg = $this->conn->prepare("SELECT AVG(rating) FROM service_reviews WHERE provider_id = :id");
            $avg->execute([':id' => $decoded->id]);
            $average = round((float)($avg->fetchColumn() ?: 0), 1);
            $total = count($reviews);
        } elseif ($decoded->role === 'user') {
            $stmt = $this->conn->prepare("
                SELECT
                    ur.id, ur.rating, ur.comment, ur.created_at, ur.photos, ur.tags,
                    ur.service_history_id, ur.user_id, ur.provider_id,
                    p.name AS provider_name, p.avatar_url AS provider_avatar,
                    sh.service_title,
                    COALESCE(hc.cnt, 0) AS helpful_count,
                    pm.message AS user_reply_message,
                    pm.created_at AS user_reply_createdAt,
                    'user' AS review_type
                FROM user_reviews ur
                JOIN users p ON p.id = ur.provider_id
                JOIN service_history sh ON sh.id = ur.service_history_id
                LEFT JOIN (
                    SELECT review_id, COUNT(*) AS cnt FROM review_helpful
                    WHERE review_type = 'user' GROUP BY review_id
                ) hc ON hc.review_id = ur.id
                LEFT JOIN review_messages pm
                       ON pm.review_id = ur.id AND pm.review_type = 'user'
                      AND pm.sender_type IN ('user', 'admin')
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

            $avg = $this->conn->prepare("SELECT AVG(rating) FROM user_reviews WHERE user_id = :id");
            $avg->execute([':id' => $decoded->id]);
            $average = round((float)($avg->fetchColumn() ?: 0), 1);
            $total = count($reviews);
        } elseif ($decoded->role === 'admin') {
            // Como proveedor
            $stmt1 = $this->conn->prepare("
                SELECT
                    sr.id, sr.rating, sr.comment, sr.created_at, sr.tags, sr.photos,
                    sr.service_history_id, sr.user_id, sr.provider_id,
                    u.name AS user_name, u.avatar_url AS user_avatar,
                    sh.service_title,
                    COALESCE(hc.cnt, 0) AS helpful_count,
                    pm.message AS provider_reply_message,
                    pm.created_at AS provider_reply_createdAt,
                    'service' AS review_type
                FROM service_reviews sr
                JOIN users u ON u.id = sr.user_id
                JOIN service_history sh ON sh.id = sr.service_history_id
                LEFT JOIN (
                    SELECT review_id, COUNT(*) AS cnt FROM review_helpful
                    WHERE review_type = 'service' GROUP BY review_id
                ) hc ON hc.review_id = sr.id
                LEFT JOIN review_messages pm
                       ON pm.review_id = sr.id AND pm.review_type = 'service'
                      AND pm.sender_type IN ('provider', 'admin')
                WHERE sr.provider_id = :id
                ORDER BY sr.created_at DESC
            ");
            $stmt1->execute([':id' => $decoded->id]);
            $serviceReviews = $stmt1->fetchAll(PDO::FETCH_ASSOC);

            // Como usuario
            $stmt2 = $this->conn->prepare("
                SELECT
                    ur.id, ur.rating, ur.comment, ur.created_at, ur.photos, ur.tags,
                    ur.service_history_id, ur.user_id, ur.provider_id,
                    p.name AS provider_name, p.avatar_url AS provider_avatar,
                    sh.service_title,
                    COALESCE(hc.cnt, 0) AS helpful_count,
                    pm.message AS user_reply_message,
                    pm.created_at AS user_reply_createdAt,
                    'user' AS review_type
                FROM user_reviews ur
                JOIN users p ON p.id = ur.provider_id
                JOIN service_history sh ON sh.id = ur.service_history_id
                LEFT JOIN (
                    SELECT review_id, COUNT(*) AS cnt FROM review_helpful
                    WHERE review_type = 'user' GROUP BY review_id
                ) hc ON hc.review_id = ur.id
                LEFT JOIN review_messages pm
                       ON pm.review_id = ur.id AND pm.review_type = 'user'
                      AND pm.sender_type IN ('user', 'admin')
                WHERE ur.user_id = :id
                ORDER BY ur.created_at DESC
            ");
            $stmt2->execute([':id' => $decoded->id]);
            $userReviews = $stmt2->fetchAll(PDO::FETCH_ASSOC);

            foreach ($serviceReviews as &$r) {
                if ($r['provider_reply_message']) {
                    $r['provider_reply'] = ['message' => $r['provider_reply_message'], 'created_at' => $r['provider_reply_createdAt']];
                } else {
                    $r['provider_reply'] = null;
                }
                unset($r['provider_reply_message'], $r['provider_reply_createdAt']);
            }
            foreach ($userReviews as &$r) {
                if ($r['user_reply_message']) {
                    $r['user_reply'] = ['message' => $r['user_reply_message'], 'created_at' => $r['user_reply_createdAt']];
                } else {
                    $r['user_reply'] = null;
                }
                unset($r['user_reply_message'], $r['user_reply_createdAt']);
            }

            $reviews = array_merge($serviceReviews, $userReviews);
            usort($reviews, fn($a, $b) => strtotime($b['created_at']) - strtotime($a['created_at']));

            $avg1 = $this->conn->prepare("SELECT AVG(rating) FROM service_reviews WHERE provider_id = :id");
            $avg1->execute([':id' => $decoded->id]);
            $avgService = (float)($avg1->fetchColumn() ?: 0);

            $avg2 = $this->conn->prepare("SELECT AVG(rating) FROM user_reviews WHERE user_id = :id");
            $avg2->execute([':id' => $decoded->id]);
            $avgUser = (float)($avg2->fetchColumn() ?: 0);

            $average = round(($avgService + $avgUser) / max(($avgService > 0 ? 1 : 0) + ($avgUser > 0 ? 1 : 0), 1), 1);
            $total = count($reviews);
        }

        echo json_encode([
            'success' => true,
            'average' => $average,
            'total'   => $total,
            'reviews' => $reviews
        ]);
    }

    public function myUserReviews(): void
    {
        $userId = $this->checkAuth();

        $stmt = $this->conn->prepare("
            SELECT
                ur.id, ur.rating, ur.comment, ur.created_at, ur.photos, ur.tags,
                p.name AS provider_name, p.avatar_url AS provider_avatar,
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

        $basePath = __DIR__ . '/../public/uploads';
        $baseUrl = rtrim(getenv('API_BASE_URL') ?: '', '/') . '/uploads';
        $uploader = new \Utils\Uploader($basePath, $baseUrl);

        $total = count($_FILES['images']['name']);
        for ($i = 0; $i < $total; $i++) {
            $error = $_FILES['images']['error'][$i];
            $tmp   = $_FILES['images']['tmp_name'][$i];
            if ($error !== UPLOAD_ERR_OK || !is_uploaded_file($tmp)) {
                continue;
            }

            try {
                $url = $uploader->saveFile([
                    'tmp_name' => $tmp,
                    'name' => $_FILES['images']['name'][$i],
                    'error' => $error
                ], \Utils\Uploader::CAT_REVIEWS . '/user/' . $historyId);
                $saved[] = $url;
            } catch (\RuntimeException $e) {
                continue;
            }
        }
        return $saved;
    }

    // ✅ rateUser ahora permite admin
    public function rateUser(): void
    {
        $reviewerId = $this->checkAuth();
        $stmtRole = $this->conn->prepare("SELECT role FROM users WHERE id = :uid");
        $stmtRole->execute([':uid' => $reviewerId]);
        $reviewerRole = $stmtRole->fetchColumn();

        if (!in_array($reviewerRole, ['provider', 'admin'])) {
            $this->send(403, ['message' => 'Solo proveedores y administradores pueden calificar usuarios']);
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
        $stars     = $input['rating'] ?? null;
        $comment   = trim($input['comment'] ?? '');

        if (!$historyId || !$stars || $stars < 1 || $stars > 5) {
            $this->send(400, ['message' => 'Datos incompletos o rating inválido']);
        }

        if ($reviewerRole === 'admin') {
            $stmt = $this->conn->prepare("SELECT user_id FROM service_history WHERE id = :hid");
            $stmt->execute([':hid' => $historyId, ':pid' => $reviewerId]);
        } else {
            $stmt = $this->conn->prepare("SELECT user_id FROM service_history WHERE id = :hid AND provider_id = :pid");
            $stmt->execute([':hid' => $historyId, ':pid' => $reviewerId]);
        }
        $history = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$history) {
            $this->send(403, ['message' => 'No autorizado']);
        }

        $userId = (int)$history['user_id'];

        $stmt = $this->conn->prepare("SELECT id FROM user_reviews WHERE service_history_id = :hid AND provider_id = :pid");
        $stmt->execute([':hid' => $historyId, ':pid' => $reviewerId]);
        if ($stmt->fetch()) {
            $this->send(409, ['message' => 'Ya evaluaste a este usuario']);
        }

        $jsonPhotos      = array_filter(explode(',', $input['photos'] ?? ''));
        $uploadedPhotos  = $this->saveUploadedImagesUser((int)$historyId);
        $allPhotos       = array_merge($jsonPhotos, $uploadedPhotos);
        $photos          = json_encode($allPhotos) ?: '[]';
        $tags            = json_encode(array_filter(explode(',', $input['tags'] ?? ''))) ?: '[]';

        $stmt = $this->conn->prepare("
            INSERT INTO user_reviews (service_history_id, provider_id, user_id, rating, comment, tags, photos)
            VALUES (:hid, :pid, :uid, :rating, :comment, :tags, :photos)
        ");
        $stmt->execute([
            ':hid'     => $historyId,
            ':pid'     => $reviewerId,
            ':uid'     => $userId,
            ':rating'  => $stars,
            ':comment' => $comment,
            ':tags'    => $tags,
            ':photos'  => $photos
        ]);

        $this->notifyUserEvaluated($userId, $stars, $reviewerId);
        $this->send(200, ['success' => true, 'message' => 'Evaluación guardada']);
    }

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

    // ✅ myReviews ahora incluye user_reviews
    public function myReviews(): void
    {
        $userId = $this->checkAuth();
        $stmtRole = $this->conn->prepare("SELECT role FROM users WHERE id = :uid");
        $stmtRole->execute([':uid' => $userId]);
        $role = $stmtRole->fetchColumn();

        $allReviews = [];

        // Reseñas a proveedores (service_reviews) - como user o admin
        if (in_array($role, ['user', 'admin'])) {
            $stmt = $this->conn->prepare("
                SELECT sr.id, sr.rating, sr.comment, sr.created_at, sr.tags, sr.photos,
                       sr.service_history_id, sr.user_id, sr.provider_id,
                       p.name AS provider_name, p.avatar_url AS provider_avatar,
                       sh.service_title,
                       COALESCE(hc.cnt, 0) AS helpful_count,
                       pm.message AS provider_reply_message,
                       pm.created_at AS provider_reply_createdAt,
                       'service' AS review_type
                FROM service_reviews sr
                JOIN users p ON p.id = sr.provider_id
                JOIN service_history sh ON sh.id = sr.service_history_id
                LEFT JOIN (
                    SELECT review_id, COUNT(*) AS cnt FROM review_helpful
                    WHERE review_type = 'service' GROUP BY review_id
                ) hc ON hc.review_id = sr.id
                LEFT JOIN review_messages pm
                       ON pm.review_id = sr.id AND pm.review_type = 'service'
                      AND pm.sender_type IN ('provider', 'admin')
                WHERE sr.user_id = :uid
                ORDER BY sr.created_at DESC
            ");
            $stmt->execute([':uid' => $userId]);
            $serviceReviews = $stmt->fetchAll(PDO::FETCH_ASSOC);

            foreach ($serviceReviews as &$r) {
                if ($r['provider_reply_message']) {
                    $r['provider_reply'] = ['message' => $r['provider_reply_message'], 'created_at' => $r['provider_reply_createdAt']];
                } else {
                    $r['provider_reply'] = null;
                }
                unset($r['provider_reply_message'], $r['provider_reply_createdAt']);
            }
            $allReviews = array_merge($allReviews, $serviceReviews);
        }

        // Reseñas a usuarios (user_reviews) - como provider o admin
        if (in_array($role, ['provider', 'admin'])) {
            $stmt = $this->conn->prepare("
                SELECT ur.id, ur.rating, ur.comment, ur.created_at, ur.photos, ur.tags,
                       ur.service_history_id, ur.user_id, ur.provider_id,
                       u.name AS user_name, u.avatar_url AS user_avatar,
                       sh.service_title,
                       COALESCE(hc.cnt, 0) AS helpful_count,
                       pm.message AS user_reply_message,
                       pm.created_at AS user_reply_createdAt,
                       'user' AS review_type
                FROM user_reviews ur
                JOIN users u ON u.id = ur.user_id
                JOIN service_history sh ON sh.id = ur.service_history_id
                LEFT JOIN (
                    SELECT review_id, COUNT(*) AS cnt FROM review_helpful
                    WHERE review_type = 'user' GROUP BY review_id
                ) hc ON hc.review_id = ur.id
                LEFT JOIN review_messages pm
                       ON pm.review_id = ur.id AND pm.review_type = 'user'
                      AND pm.sender_type IN ('user', 'admin')
                WHERE ur.provider_id = :uid
                ORDER BY ur.created_at DESC
            ");
            $stmt->execute([':uid' => $userId]);
            $userReviews = $stmt->fetchAll(PDO::FETCH_ASSOC);

            foreach ($userReviews as &$r) {
                if ($r['user_reply_message']) {
                    $r['user_reply'] = ['message' => $r['user_reply_message'], 'created_at' => $r['user_reply_createdAt']];
                } else {
                    $r['user_reply'] = null;
                }
                unset($r['user_reply_message'], $r['user_reply_createdAt']);
            }
            $allReviews = array_merge($allReviews, $userReviews);
        }

        usort($allReviews, fn($a, $b) => strtotime($b['created_at']) - strtotime($a['created_at']));

        echo json_encode([
            'success' => true,
            'reviews' => $allReviews
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
                h.id, h.service_title, h.service_description, h.service_price,
                h.user_name, h.user_avatar, h.finished_at, h.status,
                h.cancelled_by, h.payment_status, h.payment_method
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
