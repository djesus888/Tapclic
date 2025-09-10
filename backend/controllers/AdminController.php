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





    public function stats(): void
    {
        header('Content-Type: application/json');
        $this->requireAdmin();

        $data = [
            "totalUsers"         => $this->model->getTotalUsers(),
            "totalServices"      => $this->model->getTotalServices(),
            "totalNotifications" => $this->model->getTotalNotifications(),
            "latestActivities"   => $this->model->getLatestActivities(),
        ];
        echo json_encode($data);
    }
}
