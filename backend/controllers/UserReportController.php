<?php
require_once __DIR__ . '/../middleware/Auth.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../utils/AuditLogger.php';

class UserReportController
{
    private $conn;

    public function __construct()
    {
        $this->conn = (new Database())->getConnection();
    }

    // POST /api/user-reports - Crear reporte
    public function create(object $auth): void
    {
        $input = json_decode(file_get_contents('php://input'), true);
        $reportedUserId = $input['reported_user_id'] ?? null;
        $reason = $input['reason'] ?? null;

        if (!$reportedUserId || !$reason) {
            http_response_code(400);
            echo json_encode(['error' => 'Se requiere reported_user_id y reason']);
            return;
        }

        if (strlen($reason) < 10) {
            http_response_code(400);
            echo json_encode(['error' => 'La razón debe tener al menos 10 caracteres']);
            return;
        }

        if ((int)$auth->id === (int)$reportedUserId) {
            http_response_code(400);
            echo json_encode(['error' => 'No puedes reportarte a ti mismo']);
            return;
        }

        $stmt = $this->conn->prepare("SELECT id FROM users WHERE id = ?");
        $stmt->execute([$reportedUserId]);
        if (!$stmt->fetch()) {
            http_response_code(404);
            echo json_encode(['error' => 'El usuario reportado no existe']);
            return;
        }

        $stmt = $this->conn->prepare("
            INSERT INTO user_reports (reporter_id, reported_user_id, reason, type, status)
            VALUES (?, ?, ?, 'user_report', 'pending')
        ");
        $stmt->execute([$auth->id, $reportedUserId, $reason]);
        $reportId = $this->conn->lastInsertId();

        AuditLogger::log($auth->id, 'user_reported', 'Usuario reportado', "Reporte ID: {$reportId} - Reportado ID: {$reportedUserId} - Razón: {$reason}");

        echo json_encode(['success' => true, 'message' => 'Reporte enviado correctamente', 'report_id' => $reportId]);
    }

    // GET /api/user-reports/my - Ver mis reportes
    public function myReports(object $auth): void
    {
        $stmt = $this->conn->prepare("
            SELECT ur.*, u.name as reported_name, u.email as reported_email
            FROM user_reports ur
            JOIN users u ON u.id = ur.reported_user_id
            WHERE ur.reporter_id = ?
            ORDER BY ur.created_at DESC
        ");
        $stmt->execute([$auth->id]);
        echo json_encode(['success' => true, 'data' => $stmt->fetchAll(PDO::FETCH_ASSOC)]);
    }

    // GET /api/admin/user-reports - Admin: ver todos los reportes
    public function adminIndex(object $auth): void
    {
        if ($auth->role !== 'admin') {
            http_response_code(403);
            echo json_encode(['error' => 'Acceso denegado']);
            return;
        }

        $stmt = $this->conn->prepare("
            SELECT ur.*,
                   u1.name as reporter_name,
                   u2.name as reported_user_name
            FROM user_reports ur
            JOIN users u1 ON u1.id = ur.reporter_id
            JOIN users u2 ON u2.id = ur.reported_user_id
            ORDER BY ur.created_at DESC
        ");
        $stmt->execute();
        echo json_encode(['success' => true, 'reports' => $stmt->fetchAll(PDO::FETCH_ASSOC)]);
    }
}
