<?php
// controllers/AdminController.php

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../models/Admin.php';
require_once __DIR__ . '/../models/UserAdmin.php';
require_once __DIR__ . '/../models/ServiceAdmin.php';
require_once __DIR__ . '/../utils/jwt.php';

class AdminController
{
    private Admin $model;
    private UserAdmin $userAdmin;
    private ServiceAdmin $serviceAdmin;
    private \PDO $conn;

    public function __construct()
    {
        $this->model        = new Admin();
        $this->userAdmin    = new UserAdmin();
        $this->serviceAdmin = new ServiceAdmin();
        $this->conn         = (new Database())->getConnection();
    }

    private function auth()
    {
        $headers = getallheaders();
        $authHeader = $headers['Authorization'] ?? '';
        if (!str_starts_with($authHeader, 'Bearer ')) {
            return null;
        }
        return JwtHandler::decode(str_replace('Bearer ', '', $authHeader));
    }

    /* ---------- verificación rápida admin ---------- */
    private function requireAdmin(): void
    {
        $auth = $this->auth();
        if (($auth->role ?? '') !== 'admin') {
            http_response_code(401);
            echo json_encode(['error' => 'No autorizado']);
            exit;
        }
    }

    public function users()
    {
        header('Content-Type: application/json');
        $this->requireAdmin();

        $page   = max(1, (int)($_GET['page']   ?? 1));
        $search = trim($_GET['search'] ?? '');
        $role   = $_GET['role']   ?? '';
        $active = $_GET['active'] ?? '';
        $limit  = 15;
        $offset = ($page - 1) * $limit;

        $where = [];
        $args  = [];
        if ($search !== '') {
            $where[] = "(name LIKE :s OR email LIKE :s OR phone LIKE :s)";
            $args[':s'] = "%$search%";
        }
        if ($role !== '') {
            $where[] = "role = :role";
            $args[':role'] = $role;
        }
        if ($active !== '') {
            $where[] = "active = :active";
            $args[':active'] = (int)$active;
        }
        $sqlWhere = $where ? 'WHERE ' . implode(' AND ', $where) : '';

        $stmt = $this->conn->prepare("SELECT COUNT(*) FROM users $sqlWhere");
        foreach ($args as $k => $v) $stmt->bindValue($k, $v);
        $stmt->execute();
        $total = (int)$stmt->fetchColumn();

        $stmt = $this->conn->prepare(
            "SELECT id, name, email, phone, role, avatar_url, active
               FROM users
               $sqlWhere
               ORDER BY id DESC
               LIMIT :limit OFFSET :offset"
        );
        foreach ($args as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindValue(':limit',  $limit,  \PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, \PDO::PARAM_INT);
        $stmt->execute();
        $data = $stmt->fetchAll(\PDO::FETCH_ASSOC);

        echo json_encode([
            'data'         => $data,
            'current_page' => $page,
            'last_page'    => (int)ceil($total / $limit),
            'total'        => $total,
            'from'         => $offset + 1,
            'to'           => min($offset + $limit, $total),
        ]);
    }

    /* ---------- Servicios (CRUD admin) ---------- */
    public function listServices(): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $search = $_GET['search'] ?? '';
        $status = $_GET['status'] ?? '';

        $sql = "SELECT * FROM services WHERE 1=1";
        if ($search !== '') {
            $sql .= " AND (title LIKE :search OR description LIKE :search)";
        }
        if ($status !== '') {
            $sql .= " AND status = :status";
        }
        $sql .= " ORDER BY id DESC";

        $stmt = $this->conn->prepare($sql);
        if ($search !== '') {
            $stmt->bindValue(':search', "%$search%");
        }
        if ($status !== '') {
            $stmt->bindValue(':status', $status);
        }
        $stmt->execute();
        $services = $stmt->fetchAll(\PDO::FETCH_ASSOC);
        echo json_encode(['services' => $services]);
    }

    public function updateService(): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $input = json_decode(file_get_contents('php://input'), true);
        if (empty($input['id'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Falta id']);
            return;
        }

        $allowed = ['title','description','category','price','location','status','provider_rating'];
        $sets = [];
        $params = ['id' => $input['id']];
        foreach ($allowed as $col) {
            if (array_key_exists($col, $input)) {
                $sets[] = "$col = :$col";
                $params[$col] = $input[$col];
            }
        }
        if (!$sets) {
            http_response_code(400);
            echo json_encode(['error' => 'Sin campos para actualizar']);
            return;
        }

        $sql = "UPDATE services SET " . implode(', ', $sets) . " WHERE id = :id";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute($params);

        echo json_encode(['message' => 'Servicio actualizado']);
    }

    public function deleteService(): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $input = json_decode(file_get_contents('php://input'), true);
        if (empty($input['id'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Falta id']);
            return;
        }
        $stmt = $this->conn->prepare("DELETE FROM services WHERE id = :id");
        $stmt->execute(['id' => $input['id']]);

        echo json_encode(['message' => 'Servicio eliminado']);
    }

    // reporte del sistema
    public function reports(): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $db = $this->conn;

        // totales
        $totalUsers      = (int) $db->query("SELECT COUNT(*) FROM users")->fetchColumn();
        $totalServices   = (int) $db->query("SELECT COUNT(*) FROM services WHERE status='active'")->fetchColumn();
        $totalRequests   = (int) $db->query("SELECT COUNT(*) FROM service_requests")->fetchColumn();
        $totalTickets    = (int) $db->query("SELECT COUNT(*) FROM support_tickets WHERE status='open'")->fetchColumn();

        // ingresos brutos (requests finalizadas × precio servicio)
        $ingresos = (float) $db->query(
            "SELECT SUM(s.price)
             FROM service_requests r
             JOIN services s ON s.id = r.service_id
             WHERE r.status = 'completed'"
        )->fetchColumn();

        // pedidos por día (últimos 30)
        $stmt = $db->query(
            "SELECT DATE(created_at) as dia, COUNT(*) as cant
             FROM service_requests
             WHERE created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
             GROUP BY dia
             ORDER BY dia"
        );
        $porDia = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // top 5 servicio
        $stmt = $db->query(
            "SELECT s.title, COUNT(*) as veces
             FROM service_requests r
             JOIN services s ON s.id = r.service_id
             GROUP BY s.id
             ORDER BY veces DESC
             LIMIT 5"
        );
        $topServicios = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // rating promedio
        $avgRating = (float) $db->query("SELECT AVG(provider_rating) FROM services")->fetchColumn();

        echo json_encode([
            'totalUsers'     => $totalUsers,
            'totalServices'  => $totalServices,
            'totalRequests'  => $totalRequests,
            'totalTickets'   => $totalTickets,
            'ingresos'       => $ingresos,
            'porDia'         => $porDia,
            'topServicios'   => $topServicios,
            'avgRating'      => round($avgRating, 2)
        ]);
    }

   

public function getSystemConfig(): void
{
    $this->requireAdmin();
    header('Content-Type: application/json');
    $stmt = $this->conn->query("SELECT * FROM system_config WHERE id = 1");
    echo json_encode($stmt->fetch(PDO::FETCH_ASSOC));
}

public function updateSystemConfig(): void
{
    $this->requireAdmin();
    $input = json_decode(file_get_contents('php://input'), true);
    $fields = [
        'system_name','system_host','company_name','company_address',
        'support_email','support_phone','default_language','timezone','currency',
        'theme_color','items_per_page','max_login_attempts','session_timeout_minutes',
        'password_expiration_days','system_active','maintenance_mode','allow_user_registration',
        'system_logo','system_favicon'
    ];
    $sets = implode(' = ?, ', $fields) . ' = ?';
    $values = array_map(fn($f) => $input[$f] ?? null, $fields);
    $values[] = 1; // WHERE id = 1

    $stmt = $this->conn->prepare("UPDATE system_config SET $sets WHERE id = ?");
    $stmt->execute($values);

    header('Content-Type: application/json');
    echo json_encode(['message' => 'Configuración actualizada']);
}

public function uploadLogo(): void
{
    $this->requireAdmin();
    $url = $this->saveUpload($_FILES['file'], 'logo');
    echo json_encode(['url' => $url]);
}

public function uploadFavicon(): void
{
    $this->requireAdmin();
    $url = $this->saveUpload($_FILES['file'], 'favicon');
    echo json_encode(['url' => $url]);
}

private function saveUpload(array $file, string $prefix): string
{
    $ext = pathinfo($file['name'], PATHINFO_EXTENSION);
    $name = $prefix . '_' . time() . '.' . $ext;
    $dest = __DIR__ . '/../public/uploads/logos' . $name;
    move_uploaded_file($file['tmp_name'], $dest);
    return '/logos/' . $name;
}

   /* ----------  ESTADÍSTICAS (todas reales)  ---------- */
    public function stats(): void
    {
        header('Content-Type: application/json');
        $this->requireAdmin();
        $db = $this->conn;

        /* 1  USUARIOS EN LÍNEA */
        $onlineNow = (int) $db->query(
            "SELECT COUNT(*) FROM users WHERE last_seen_at >= NOW() - INTERVAL 5 MINUTE"
        )->fetchColumn();

        /* 2  TOTAL USUARIOS */
        $totalUsers = (int) $db->query("SELECT COUNT(*) FROM users")->fetchColumn();

        /* 3  ÓRDENES PENDIENTES */
        $pendingOrders = (int) $db->query(
            "SELECT COUNT(*) FROM service_requests WHERE status = 'pending'"
        )->fetchColumn();

        /* 4  PROVEEDORES ACTIVOS */
        $activeProviders = (int) $db->query(
            "SELECT COUNT(*) FROM users WHERE role = 'provider' AND active = 1"
        )->fetchColumn();

        /* 5  INGRESOS DEL MES (solo pagos completados) */
        $firstDay = date('Y-m-01');
        $stmt = $db->prepare(
            "SELECT COALESCE(SUM(r.price),0)
             FROM service_requests r
             JOIN payments p ON p.service_request_id = r.id
             WHERE p.status = 'completed'
               AND p.created_at >= ?
               AND r.status   = 'completed'"
        );
        $stmt->execute([$firstDay]);
        $monthIncome = (float) $stmt->fetchColumn();


        /* 6  REVISIONES PENDIENTES (requests terminadas sin review) */
        $pendingReviews = (int) $db->query(
            "SELECT COUNT(*)
             FROM service_requests r
             LEFT JOIN service_history h ON h.request_id = r.id
             LEFT JOIN service_reviews sr ON sr.service_history_id = h.id
             WHERE r.status = 'completed'
               AND h.status = 'completed'
               AND sr.id IS NULL"
        )->fetchColumn();


        /* 7  SERVICIOS */
        $totalServices = (int) $db->query(
            "SELECT COUNT(*) FROM services WHERE status='active'"
        )->fetchColumn();

        /* 8  NOTIFICACIONES */
        $totalNotif = (int) $db->query("SELECT COUNT(*) FROM notifications")->fetchColumn();

        /* 9  CONFIGURACIONES (cantidad de filas en la tabla system_config) */
        $settings = (int) $db->query("SELECT COUNT(*) FROM system_config")->fetchColumn();

        /* 10  ACTIVIDADES (las que ya tenías) */
        $activities = $this->model->getLatestActivities();

        echo json_encode([
            'onlineUsers'        => $onlineNow,
            'totalUsers'         => $totalUsers,
            'pendingOrders'      => $pendingOrders,
            'activeProviders'    => $activeProviders,
            'monthIncome'        => $monthIncome,
            'pendingReviews'     => $pendingReviews,
            'totalServices'      => $totalServices,
            'totalNotifications' => $totalNotif,
            'settings'           => $settings,
            'latestActivities'   => $activities,
        ]);
    }

}
