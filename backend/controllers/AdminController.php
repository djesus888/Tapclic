<?php
require_once __DIR__ . "/../middleware/Auth.php";
// controllers/AdminController.php

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../models/Admin.php';
require_once __DIR__ . '/../models/UserAdmin.php';
require_once __DIR__ . '/../models/ServiceAdmin.php';
require_once __DIR__ . '/../utils/jwt.php';
require_once __DIR__ . '/../models/System.php';

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

    /* ---------- verificación rápida admin ---------- */
    private function requireAdmin(): void
    {
        $auth = Auth::verify();
        if (($auth->role ?? '') !== 'admin') {
            http_response_code(401);
            echo json_encode(['error' => 'No autorizado']);
            exit;
        }
    }

/**
 * Obtener solo usuarios administradores
 */
public function getAdmins() {
    $auth = Auth::verify();
    if (!$auth || $auth->role !== 'admin') {
        http_response_code(403);
        echo json_encode(["error" => "No autorizado"]);
        return;
    }

    require_once __DIR__ . '/../models/User.php';
    $userModel = new User();
    
    $sql = "SELECT id, name, email, avatar_url FROM users WHERE role = 'admin' ORDER BY name";
    $stmt = $userModel->getDb()->prepare($sql);
    $stmt->execute();
    $admins = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'data' => $admins
    ]);
}


    /* ---------- Métodos Helper para Analytics ---------- */
    private function getDateRange(string $period): array
    {
        $now = date('Y-m-d H:i:s');

        switch ($period) {
            case 'day':
                $start = date('Y-m-d 00:00:00');
                break;
            case 'week':
                $start = date('Y-m-d 00:00:00', strtotime('-7 days'));
                break;
            case 'month':
                $start = date('Y-m-d 00:00:00', strtotime('-30 days'));
                break;
            case 'quarter':
                $start = date('Y-m-d 00:00:00', strtotime('-90 days'));
                break;
            case 'year':
                $start = date('Y-m-d 00:00:00', strtotime('-365 days'));
                break;
            default:
                $start = date('Y-m-d 00:00:00', strtotime('-7 days'));
        }

        return [
            'start' => $start,
            'end' => $now
        ];
    }

    private function getGroupBy(string $period): string
    {
        switch ($period) {
            case 'day': return 'HOUR';
            case 'week': return 'DAY';
            case 'month': return 'DAY';
            case 'quarter': return 'WEEK';
            case 'year': return 'MONTH';
            default: return 'DAY';
        }
    }

    /* ---------- SEGURIDAD: verificar SSL ---------- */
    private function checkSSLStatus($domain): array
    {
        if (!$domain) {
            return [
                'valid' => false,
                'message' => 'Dominio no configurado',
                'expires' => null
            ];
        }

        // Extraer solo el dominio
        $parsed = parse_url($domain);
        $host = $parsed['host'] ?? $domain;

        // Verificar SSL usando stream
        $context = stream_context_create([
            'ssl' => [
                'capture_peer_cert' => true,
                'verify_peer' => false,
                'verify_peer_name' => false,
            ]
        ]);

        try {
            $protocol = (strpos($host, 'https') === 0) ? 'ssl://' : 'tcp://';
            $client = stream_socket_client(
            "{$protocol}{$host}:3001",
                $errno,
                $errstr,
                30,
                STREAM_CLIENT_CONNECT,
                $context
            );

            if (!$client) {
                return [
                    'valid' => false,
                    'message' => "Error conectando: $errstr",
                    'expires' => null
                ];
            }

                        $cert = stream_context_get_params($client);
            
            // Verificar si existe certificado SSL
            if (isset($cert['options']['ssl']['peer_certificate'])) {
                $certInfo = openssl_x509_parse($cert['options']['ssl']['peer_certificate']);
                $validTo = $certInfo['validTo_time_t'] ?? null;
                $expiresIn = $validTo ? $validTo - time() : null;
                $isExpired = $expiresIn && $expiresIn < 0;
                
                $sslStatus = [
                    'valid' => !$isExpired,
                    'message' => $isExpired ? 'Certificado expirado' : 'Certificado válido',
                    'expires' => $validTo ? date('Y-m-d H:i:s', $validTo) : null,
                    'expires_in_days' => $expiresIn ? floor($expiresIn / 86400) : null,
                    'issuer' => $certInfo['issuer']['O'] ?? 'Desconocido',
                    'subject' => $certInfo['subject']['CN'] ?? 'Desconocido'
                ];
            } else {
                // Conexión sin SSL (tcp://)
                $sslStatus = [
                    'valid' => true,
                    'message' => 'Conexión sin SSL (modo desarrollo)',
                    'expires' => null,
                    'expires_in_days' => null,
                    'issuer' => 'N/A',
                    'subject' => 'N/A'
                ];
            }

            fclose($client);
            return $sslStatus;

            $validTo = $certInfo['validTo_time_t'] ?? null;
            $expiresIn = $validTo ? $validTo - time() : null;
            $isExpired = $expiresIn && $expiresIn < 0;

            return [
                'valid' => !$isExpired,
                'message' => $isExpired ? 'Certificado expirado' : 'Certificado válido',
                'expires' => $validTo ? date('Y-m-d H:i:s', $validTo) : null,
                'expires_in_days' => $expiresIn ? floor($expiresIn / 86400) : null,
                'issuer' => $certInfo['issuer']['O'] ?? 'Desconocido',
                'subject' => $certInfo['subject']['CN'] ?? 'Desconocido'
            ];

        } catch (Exception $e) {
            return [
                'valid' => false,
                'message' => 'Error verificando SSL: ' . $e->getMessage(),
                'expires' => null
            ];
        }
    }

    private function validatePaymentGateway($input) {
        $required = [];

        switch ($input['name']) {
            case 'paypal':
                $required = ['paypal_email'];
                if ($input['requires_api_keys']) {
                    $required[] = 'api_key_public';
                    $required[] = 'api_key_secret';
                }
                break;

            case 'mercadopago':
                $required = ['mercadopago_access_token'];
                break;

            case 'bank_transfer':
                $required = ['bank_name', 'bank_account', 'bank_holder'];
                break;

            case 'mobile_payment':
                $required = ['mobile_phone', 'mobile_operator'];
                break;

            case 'zelle':
                $required = ['zelle_email'];
                break;
        }

        foreach ($required as $field) {
            if (empty($input[$field])) {
                return "El campo $field es requerido para " . $input['name'];
            }
        }

        return null;
    }



/**
 * Obtener todos los tickets de soporte (admin)
 */
public function getAllTickets() {
    $auth = Auth::verify();
    if (!$auth || $auth->role !== 'admin') {
        http_response_code(403);
        echo json_encode(["error" => "No autorizado"]);
        return;
    }

    require_once __DIR__ . '/../models/Ticket.php';
    $ticketModel = new Ticket();
    
    $status = $_GET['status'] ?? null;
    $page = $_GET['page'] ?? 1;
    $limit = $_GET['limit'] ?? 20;
    
    $tickets = $ticketModel->getAllTickets($status, $page, $limit);
    $total = $ticketModel->countTickets($status);
    
    echo json_encode([
        'success' => true,
        'tickets' => $tickets,
        'pagination' => [
            'total' => $total,
            'page' => (int)$page,
            'limit' => (int)$limit,
            'pages' => ceil($total / $limit)
        ]
    ]);
}

/**
 * Obtener un ticket específico
 */
public function getTicket($id) {
    $auth = Auth::verify();
    if (!$auth || $auth->role !== 'admin') {
        http_response_code(403);
        echo json_encode(["error" => "No autorizado"]);
        return;
    }

    require_once __DIR__ . '/../models/Ticket.php';
    $ticketModel = new Ticket();
    
    $ticket = $ticketModel->getTicketById($id);
    
    if (!$ticket) {
        http_response_code(404);
        echo json_encode(["error" => "Ticket no encontrado"]);
        return;
    }
    
    // Obtener respuestas del ticket
    $replies = $ticketModel->getTicketReplies($id);
    
    echo json_encode([
        'success' => true,
        'ticket' => $ticket,
        'replies' => $replies
    ]);
}

/**
 * Responder a un ticket (admin)
 */
public function respondToTicket($id) {
    $auth = Auth::verify();
    if (!$auth || $auth->role !== 'admin') {
        http_response_code(403);
        echo json_encode(["error" => "No autorizado"]);
        return;
    }

    $input = json_decode(file_get_contents("php://input"), true);
    $message = $input['message'] ?? '';
    
    if (empty($message)) {
        http_response_code(400);
        echo json_encode(["error" => "El mensaje es requerido"]);
        return;
    }

    require_once __DIR__ . '/../models/Ticket.php';
    require_once __DIR__ . '/../utils/Mailer.php';
    require_once __DIR__ . '/../models/User.php';
    
    $ticketModel = new Ticket();
    $userModel = new User();
    
    // Verificar que el ticket existe
    $ticket = $ticketModel->getTicketById($id);
    if (!$ticket) {
        http_response_code(404);
        echo json_encode(["error" => "Ticket no encontrado"]);
        return;
    }
    
    // Guardar respuesta
    $replyId = $ticketModel->addReply($id, $auth->id, 'admin', $message);
    
    // Actualizar estado del ticket a 'in_progress' si estaba 'open'
    if ($ticket['status'] === 'open') {
        $ticketModel->updateStatus($id, 'in_progress');
    }
    
    // Enviar notificación por email al usuario
    $user = $userModel->findById($ticket['user_id']);
    if ($user && !empty($user['email'])) {
        $mailer = new Mailer();
        $subject = "Respuesta a tu ticket #{$id} - " . $ticket['subject'];
        $htmlMessage = "
        <h2>Ticket de soporte #{$id}</h2>
        <p><strong>Asunto:</strong> {$ticket['subject']}</p>
        <p><strong>Respuesta del administrador:</strong></p>
        <p>" . nl2br(htmlspecialchars($message)) . "</p>
        <p>Puedes ver la conversación completa en tu panel de usuario.</p>
        ";
        $mailer->send($user['email'], $subject, $htmlMessage);
    }
    
    echo json_encode([
        'success' => true,
        'message' => 'Respuesta enviada correctamente',
        'reply_id' => $replyId
    ]);
}

/**
 * Actualizar estado de un ticket
 */
public function updateTicketStatus($id) {
    $auth = Auth::verify();
    if (!$auth || $auth->role !== 'admin') {
        http_response_code(403);
        echo json_encode(["error" => "No autorizado"]);
        return;
    }

    $input = json_decode(file_get_contents("php://input"), true);
    $status = $input['status'] ?? '';
    
    $validStatuses = ['open', 'in_progress', 'resolved', 'closed'];
    if (!in_array($status, $validStatuses)) {
        http_response_code(400);
        echo json_encode(["error" => "Estado no válido. Use: " . implode(', ', $validStatuses)]);
        return;
    }

    require_once __DIR__ . '/../models/Ticket.php';
    $ticketModel = new Ticket();
    
    $updated = $ticketModel->updateStatus($id, $status);
    
    if ($updated) {
        echo json_encode([
            'success' => true,
            'message' => 'Estado actualizado correctamente'
        ]);
    } else {
        http_response_code(500);
        echo json_encode(["error" => "Error al actualizar estado"]);
    }
}

/**
 * Obtener estadísticas de tickets
 */
public function getTicketStats() {
    $auth = Auth::verify();
    if (!$auth || $auth->role !== 'admin') {
        http_response_code(403);
        echo json_encode(["error" => "No autorizado"]);
        return;
    }

    require_once __DIR__ . '/../models/Ticket.php';
    $ticketModel = new Ticket();
    
    $stats = [
        'open' => $ticketModel->countTickets('open'),
        'in_progress' => $ticketModel->countTickets('in_progress'),
        'resolved' => $ticketModel->countTickets('resolved'),
        'closed' => $ticketModel->countTickets('closed'),
        'total' => $ticketModel->countTickets(),
        'today' => $ticketModel->countTicketsToday(),
        'avg_response_time' => $ticketModel->getAverageResponseTime()
    ];
    
    echo json_encode([
        'success' => true,
        'stats' => $stats
    ]);
}

/**
 * Asignar ticket a un admin específico
 */
public function assignTicket($id) {
    $auth = Auth::verify();
    if (!$auth || $auth->role !== 'admin') {
        http_response_code(403);
        echo json_encode(["error" => "No autorizado"]);
        return;
    }

    $input = json_decode(file_get_contents("php://input"), true);
    $adminId = $input['admin_id'] ?? $auth->id;

    require_once __DIR__ . '/../models/Ticket.php';
    $ticketModel = new Ticket();
    
    $assigned = $ticketModel->assignToAdmin($id, $adminId);
    
    if ($assigned) {
        echo json_encode([
            'success' => true,
            'message' => 'Ticket asignado correctamente'
        ]);
    } else {
        http_response_code(500);
        echo json_encode(["error" => "Error al asignar ticket"]);
    }
}

/**
 * Cerrar ticket (admin)
 */
public function closeTicket($id) {
    $auth = Auth::verify();
    if (!$auth || $auth->role !== 'admin') {
        http_response_code(403);
        echo json_encode(["error" => "No autorizado"]);
        return;
    }

    require_once __DIR__ . '/../models/Ticket.php';
    $ticketModel = new Ticket();
    
    $closed = $ticketModel->updateStatus($id, 'closed');
    
    if ($closed) {
        echo json_encode([
            'success' => true,
            'message' => 'Ticket cerrado correctamente'
        ]);
    } else {
        http_response_code(500);
        echo json_encode(["error" => "Error al cerrar ticket"]);
    }
}

/**
 * Asignación masiva de tickets
 */
public function bulkAssign() {
    $auth = Auth::verify();
    if (!$auth || $auth->role !== 'admin') {
        http_response_code(403);
        echo json_encode(["error" => "No autorizado"]);
        return;
    }

    $input = json_decode(file_get_contents("php://input"), true);
    $ticketIds = $input['ticket_ids'] ?? [];
    $adminId = $input['admin_id'] ?? null;

    if (empty($ticketIds) || !$adminId) {
        http_response_code(400);
        echo json_encode(["error" => "Faltan datos requeridos"]);
        return;
    }

    require_once __DIR__ . '/../models/Ticket.php';
    $ticketModel = new Ticket();
    
    $success = true;
    foreach ($ticketIds as $ticketId) {
        if (!$ticketModel->assignToAdmin($ticketId, $adminId)) {
            $success = false;
        }
    }

    if ($success) {
        echo json_encode([
            'success' => true,
            'message' => count($ticketIds) . ' tickets asignados correctamente'
        ]);
    } else {
        http_response_code(500);
        echo json_encode(["error" => "Error al asignar algunos tickets"]);
    }
}

/**
 * Cambio masivo de estado
 */
public function bulkStatus() {
    $auth = Auth::verify();
    if (!$auth || $auth->role !== 'admin') {
        http_response_code(403);
        echo json_encode(["error" => "No autorizado"]);
        return;
    }

    $input = json_decode(file_get_contents("php://input"), true);
    $ticketIds = $input['ticket_ids'] ?? [];
    $status = $input['status'] ?? null;

    $validStatuses = ['open', 'in_progress', 'resolved', 'closed'];
    if (empty($ticketIds) || !in_array($status, $validStatuses)) {
        http_response_code(400);
        echo json_encode(["error" => "Datos inválidos"]);
        return;
    }

    require_once __DIR__ . '/../models/Ticket.php';
    $ticketModel = new Ticket();
    
    $success = true;
    foreach ($ticketIds as $ticketId) {
        if (!$ticketModel->updateStatus($ticketId, $status)) {
            $success = false;
        }
    }

    if ($success) {
        echo json_encode([
            'success' => true,
            'message' => count($ticketIds) . ' tickets actualizados correctamente'
        ]);
    } else {
        http_response_code(500);
        echo json_encode(["error" => "Error al actualizar algunos tickets"]);
    }
}

/**
 * Cambio masivo de prioridad
 */
public function bulkPriority() {
    $auth = Auth::verify();
    if (!$auth || $auth->role !== 'admin') {
        http_response_code(403);
        echo json_encode(["error" => "No autorizado"]);
        return;
    }

    $input = json_decode(file_get_contents("php://input"), true);
    $ticketIds = $input['ticket_ids'] ?? [];
    $priority = $input['priority'] ?? null;

    $validPriorities = ['low', 'medium', 'high', 'urgent'];
    if (empty($ticketIds) || !in_array($priority, $validPriorities)) {
        http_response_code(400);
        echo json_encode(["error" => "Datos inválidos"]);
        return;
    }

    require_once __DIR__ . '/../models/Ticket.php';
    $ticketModel = new Ticket();
    
    $success = true;
    foreach ($ticketIds as $ticketId) {
        $sql = "UPDATE support_tickets SET priority = :priority WHERE id = :id";
        $stmt = $ticketModel->getDb()->prepare($sql);
        if (!$stmt->execute([':priority' => $priority, ':id' => $ticketId])) {
            $success = false;
        }
    }

    if ($success) {
        echo json_encode([
            'success' => true,
            'message' => count($ticketIds) . ' tickets actualizados correctamente'
        ]);
    } else {
        http_response_code(500);
        echo json_encode(["error" => "Error al actualizar algunos tickets"]);
    }
}

/**
 * Agregar etiqueta masiva a tickets
 */
public function bulkTag() {
    $auth = Auth::verify();
    if (!$auth || $auth->role !== 'admin') {
        http_response_code(403);
        echo json_encode(["error" => "No autorizado"]);
        return;
    }

    $input = json_decode(file_get_contents("php://input"), true);
    $ticketIds = $input['ticket_ids'] ?? [];
    $tag = trim($input['tag'] ?? '');
    $color = $input['color'] ?? 'blue';

    if (empty($ticketIds) || empty($tag)) {
        http_response_code(400);
        echo json_encode(["error" => "Faltan datos requeridos"]);
        return;
    }

    require_once __DIR__ . '/../models/Ticket.php';
    $ticketModel = new Ticket();
    $conn = $ticketModel->getDb();
    
    $success = true;
    $updated = [];
    
    foreach ($ticketIds as $ticketId) {
        // Obtener tags actuales
        $sql = "SELECT tags FROM support_tickets WHERE id = ?";
        $stmt = $conn->prepare($sql);
        $stmt->execute([$ticketId]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        
        $currentTags = [];
        if (!empty($result['tags'])) {
            $currentTags = json_decode($result['tags'], true);
            if (!is_array($currentTags)) {
                $currentTags = [];
            }
        }
        
        // Verificar si la etiqueta ya existe
        $tagExists = false;
        foreach ($currentTags as $existingTag) {
            if (is_array($existingTag) && isset($existingTag['name']) && $existingTag['name'] === $tag) {
                $tagExists = true;
                break;
            }
        }
        
        if (!$tagExists) {
            $currentTags[] = ['name' => $tag, 'color' => $color];
            $sql = "UPDATE support_tickets SET tags = ? WHERE id = ?";
            $stmt = $conn->prepare($sql);
            if ($stmt->execute([json_encode($currentTags), $ticketId])) {
                $updated[] = $ticketId;
            } else {
                $success = false;
            }
        }
    }

    echo json_encode([
        'success' => $success,
        'message' => 'Etiqueta "' . $tag . '" agregada a ' . count($updated) . ' tickets',
        'updated' => $updated
    ]);
}

/**
 * Eliminación masiva de tickets
 */
public function bulkDelete() {
    $auth = Auth::verify();
    if (!$auth || $auth->role !== 'admin') {
        http_response_code(403);
        echo json_encode(["error" => "No autorizado"]);
        return;
    }

    $input = json_decode(file_get_contents("php://input"), true);
    $ticketIds = $input['ticket_ids'] ?? [];

    if (empty($ticketIds)) {
        http_response_code(400);
        echo json_encode(["error" => "No hay tickets seleccionados"]);
        return;
    }

    require_once __DIR__ . '/../models/Ticket.php';
    $ticketModel = new Ticket();
    
    $placeholders = implode(',', array_fill(0, count($ticketIds), '?'));
    
    // Primero eliminar respuestas
    $sql = "DELETE FROM ticket_replies WHERE ticket_id IN ($placeholders)";
    $stmt = $ticketModel->getDb()->prepare($sql);
    $stmt->execute($ticketIds);
    
    // Luego eliminar tickets
    $sql = "DELETE FROM support_tickets WHERE id IN ($placeholders)";
    $stmt = $ticketModel->getDb()->prepare($sql);
    $success = $stmt->execute($ticketIds);

    if ($success) {
        echo json_encode([
            'success' => true,
            'message' => count($ticketIds) . ' tickets eliminados correctamente'
        ]);
    } else {
        http_response_code(500);
        echo json_encode(["error" => "Error al eliminar tickets"]);
    }
}


  /* ---------- Métodos de Analytics ---------- */
public function getAnalyticsOverview(): void
{
    $this->requireAdmin();
    header('Content-Type: application/json');

    $db = $this->conn;
    $period = $_GET['period'] ?? 'week';

    // Determinar fechas según periodo
    $dateRange = $this->getDateRange($period);

    try {
        // 1. Usuarios nuevos
        $stmt = $db->prepare("SELECT COUNT(*) FROM users WHERE created_at BETWEEN ? AND ?");
        $stmt->execute([$dateRange['start'], $dateRange['end']]);
        $newUsers = (int) $stmt->fetchColumn();

        // 2. Servicios creados
        $stmt = $db->prepare("SELECT COUNT(*) FROM services WHERE created_at BETWEEN ? AND ? AND status = 'active'");
        $stmt->execute([$dateRange['start'], $dateRange['end']]);
        $newServices = (int) $stmt->fetchColumn();

        // 3. Solicitudes creadas
        $stmt = $db->prepare("SELECT COUNT(*) FROM service_requests WHERE created_at BETWEEN ? AND ?");
        $stmt->execute([$dateRange['start'], $dateRange['end']]);
        $newRequests = (int) $stmt->fetchColumn();

        // 4. Solicitudes completadas
        $stmt = $db->prepare("SELECT COUNT(*) FROM service_requests WHERE status = 'completed' AND updated_at BETWEEN ? AND ?");
        $stmt->execute([$dateRange['start'], $dateRange['end']]);
        $completedRequests = (int) $stmt->fetchColumn();

        // 5. Ingresos totales - CORREGIDO
        $stmt = $db->prepare("
            SELECT COALESCE(SUM(r.price), 0)
            FROM payments p
            JOIN service_requests r ON p.service_request_id = r.id
            WHERE p.status = 'paid'  -- Cambiado de 'completed' a 'paid'
            AND p.created_at BETWEEN ? AND ?
            AND r.status = 'completed'
        ");
        $stmt->execute([$dateRange['start'], $dateRange['end']]);
        $revenue = (float) $stmt->fetchColumn();

        // 6. Usuarios totales
        $totalUsers = (int) $db->query("SELECT COUNT(*) FROM users")->fetchColumn();

        // 7. Servicios totales activos
        $totalServices = (int) $db->query("SELECT COUNT(*) FROM services WHERE status = 'active'")->fetchColumn();

        // 8. Tasa de completitud
        $completionRate = $newRequests > 0 ? ($completedRequests / $newRequests) * 100 : 0;

        // Respuesta JSON
        echo json_encode([
            'success' => true,
            'data' => [
                'period' => $period,
                'start_date' => $dateRange['start'],
                'end_date' => $dateRange['end'],
                'new_users' => $newUsers,
                'total_users' => $totalUsers,
                'new_services' => $newServices,
                'total_services' => $totalServices,
                'new_requests' => $newRequests,
                'completed_requests' => $completedRequests,
                'completion_rate' => round($completionRate, 2),
                'revenue' => $revenue
            ]
        ]);

    } catch (Exception $e) {
        error_log("Error en getAnalyticsOverview: " . $e->getMessage());
        echo json_encode([
            'success' => false,
            'message' => 'Error: ' . $e->getMessage()
        ]);
    }
}

    public function getAnalyticsCharts(): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $db = $this->conn;
        $period = $_GET['period'] ?? 'week';
        $dateRange = $this->getDateRange($period);
        $groupBy = $this->getGroupBy($period);

        // 1. Usuarios por día
        $usersStmt = $db->prepare("
            SELECT DATE(created_at) as date, COUNT(*) as count
            FROM users
            WHERE created_at BETWEEN ? AND ?
            GROUP BY DATE(created_at)
            ORDER BY date
        ");
        $usersStmt->execute([$dateRange['start'], $dateRange['end']]);
        $usersByDay = $usersStmt->fetchAll(PDO::FETCH_ASSOC);

        // 2. Servicios por día
        $servicesStmt = $db->prepare("
            SELECT DATE(created_at) as date, COUNT(*) as count
            FROM services
            WHERE created_at BETWEEN ? AND ?
            AND status = 'active'
            GROUP BY DATE(created_at)
            ORDER BY date
        ");
        $servicesStmt->execute([$dateRange['start'], $dateRange['end']]);
        $servicesByDay = $servicesStmt->fetchAll(PDO::FETCH_ASSOC);

        // 3. Solicitudes por día
        $requestsStmt = $db->prepare("
            SELECT DATE(created_at) as date, COUNT(*) as count
            FROM service_requests
            WHERE created_at BETWEEN ? AND ?
            GROUP BY DATE(created_at)
            ORDER BY date
        ");
        $requestsStmt->execute([$dateRange['start'], $dateRange['end']]);
        $requestsByDay = $requestsStmt->fetchAll(PDO::FETCH_ASSOC);

        // 4. Ingresos por día
        $revenueStmt = $db->prepare("
            SELECT DATE(p.created_at) as date, COALESCE(SUM(r.price), 0) as amount
            FROM payments p
            JOIN service_requests r ON p.service_request_id = r.id
            WHERE p.status = 'completed'
            AND p.created_at BETWEEN ? AND ?
            AND r.status = 'completed'
            GROUP BY DATE(p.created_at)
            ORDER BY date
        ");
        $revenueStmt->execute([$dateRange['start'], $dateRange['end']]);
        $revenueByDay = $revenueStmt->fetchAll(PDO::FETCH_ASSOC);

        // 5. Categorías más populares
        $categoriesStmt = $db->prepare("
            SELECT
                COALESCE(s.category, 'Sin categoría') as name,
                COUNT(s.id) as service_count
            FROM services s
            WHERE s.created_at BETWEEN ? AND ?
            AND s.status = 'active'
            GROUP BY s.category
            ORDER BY service_count DESC
            LIMIT 10
        ");
        $categoriesStmt->execute([$dateRange['start'], $dateRange['end']]);
        $topCategories = $categoriesStmt->fetchAll(PDO::FETCH_ASSOC);

        // 6. Proveedores más activos
        $providersStmt = $db->prepare("
            SELECT u.name, COUNT(DISTINCT s.id) as service_count, COUNT(DISTINCT r.id) as request_count
            FROM users u
            LEFT JOIN services s ON u.id = s.user_id
            LEFT JOIN service_requests r ON s.id = r.service_id
            WHERE u.role = 'provider'
            AND u.active = 1
            AND (s.created_at BETWEEN ? AND ? OR r.created_at BETWEEN ? AND ?)
            GROUP BY u.id
            ORDER BY request_count DESC
            LIMIT 10
        ");
        $providersStmt->execute([
            $dateRange['start'], $dateRange['end'],
            $dateRange['start'], $dateRange['end']
        ]);
        $topProviders = $providersStmt->fetchAll(PDO::FETCH_ASSOC);

        // 7. Estado de solicitudes
        $requestsStatusStmt = $db->prepare("
            SELECT status, COUNT(*) as count
            FROM service_requests
            WHERE created_at BETWEEN ? AND ?
            GROUP BY status
        ");
        $requestsStatusStmt->execute([$dateRange['start'], $dateRange['end']]);
        $requestsStatus = $requestsStatusStmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode([
            'period' => $period,
            'charts' => [
                'users_by_day' => $usersByDay,
                'services_by_day' => $servicesByDay,
                'requests_by_day' => $requestsByDay,
                'revenue_by_day' => $revenueByDay,
                'top_categories' => $topCategories,
                'top_providers' => $topProviders,
                'requests_status' => $requestsStatus
            ]
        ]);
    }

    public function getAnalyticsRealTime(): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $db = $this->conn;

        // Usuarios online (últimos 5 minutos)
        $onlineUsers = (int) $db->query("
            SELECT COUNT(*) FROM users
            WHERE last_seen_at >= NOW() - INTERVAL 5 MINUTE
        ")->fetchColumn();

        // Solicitudes activas ahora
        $activeRequests = (int) $db->query("
            SELECT COUNT(*) FROM service_requests
            WHERE status IN ('pending', 'accepted', 'in_progress', 'on_the_way')
        ")->fetchColumn();

        // Proveedores disponibles
        $availableProviders = (int) $db->query("
            SELECT COUNT(DISTINCT u.id)
            FROM users u
            LEFT JOIN services s ON u.id = s.user_id
            LEFT JOIN service_requests r ON s.id = r.service_id
            WHERE u.role = 'provider'
            AND u.active = 1
            AND (r.status IS NULL OR r.status NOT IN ('pending', 'in_progress', 'on_the_way'))
        ")->fetchColumn();

        // Tickets abiertos
        $openTickets = (int) $db->query("
            SELECT COUNT(*) FROM support_tickets
            WHERE status = 'open'
        ")->fetchColumn();

        echo json_encode([
            'online_users' => $onlineUsers,
            'active_requests' => $activeRequests,
            'available_providers' => $availableProviders,
            'open_tickets' => $openTickets,
            'timestamp' => date('Y-m-d H:i:s')
        ]);
    }

    /* ---------- Gestión de Usuarios ---------- */
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

    /* ---------- SEGURIDAD: SESIONES ACTIVAS ---------- */
    public function getActiveSessions(): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $db = $this->conn;

        // Obtener sesiones activas (últimas 24 horas)
        $stmt = $db->prepare("
            SELECT
                s.id,
                s.user_id,
                u.name as user_name,
                u.email,
                u.role,
                s.ip_address,
                s.user_agent,
                s.last_activity,
                s.created_at,
                TIMESTAMPDIFF(MINUTE, s.last_activity, NOW()) as minutes_inactive
            FROM sessions s
            JOIN users u ON u.id = s.user_id
            WHERE s.last_activity >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
            ORDER BY s.last_activity DESC
            LIMIT 100
        ");

        $stmt->execute();
        $sessions = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode([
            'sessions' => $sessions,
            'total' => count($sessions),
            'timestamp' => date('Y-m-d H:i:s')
        ]);
    }

    /* ---------- SEGURIDAD: TERMINAR SESIÓN ---------- */
    public function terminateSession(): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $input = json_decode(file_get_contents('php://input'), true);
        $sessionId = $input['session_id'] ?? null;
        $userId = $input['user_id'] ?? null;

        if (!$sessionId && !$userId) {
            http_response_code(400);
            echo json_encode(['error' => 'Se requiere session_id o user_id']);
            return;
        }

        $db = $this->conn;

        if ($sessionId) {
            // Terminar sesión específica
            $stmt = $db->prepare("DELETE FROM sessions WHERE id = ?");
            $stmt->execute([$sessionId]);
            $affected = $stmt->rowCount();
        } else {
            // Terminar todas las sesiones de un usuario
            $stmt = $db->prepare("DELETE FROM sessions WHERE user_id = ?");
            $stmt->execute([$userId]);
            $affected = $stmt->rowCount();
        }

        echo json_encode([
            'success' => true,
            'message' => "Sesión(es) terminadas: $affected",
            'affected' => $affected
        ]);
    }

    /* ---------- SEGURIDAD: LOGS DE AUDITORÍA ---------- */
    public function getAuditLogs(): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $page = max(1, (int)($_GET['page'] ?? 1));
        $limit = 50;
        $offset = ($page - 1) * $limit;

        $search = $_GET['search'] ?? '';
        $type = $_GET['type'] ?? '';
        $user_id = $_GET['user_id'] ?? '';
        $date_from = $_GET['date_from'] ?? '';
        $date_to = $_GET['date_to'] ?? '';

        $db = $this->conn;

        // Construir WHERE clause
        $where = ["1=1"];
        $params = [];

        if ($search) {
            $where[] = "(action LIKE ? OR details LIKE ? OR ip_address LIKE ?)";
            $params[] = "%$search%";
            $params[] = "%$search%";
            $params[] = "%$search%";
        }

        if ($type) {
            $where[] = "action_type = ?";
            $params[] = $type;
        }

        if ($user_id) {
            $where[] = "user_id = ?";
            $params[] = $user_id;
        }

        if ($date_from) {
            $where[] = "created_at >= ?";
            $params[] = $date_from;
        }

        if ($date_to) {
            $where[] = "created_at <= ?";
            $params[] = $date_to . ' 23:59:59';
        }

        $whereClause = implode(' AND ', $where);

        // Contar total
        $countStmt = $db->prepare("SELECT COUNT(*) FROM audit_logs WHERE $whereClause");
        $countStmt->execute($params);
        $total = $countStmt->fetchColumn();

        // Obtener logs
        $stmt = $db->prepare("
            SELECT
                al.*,
                u.name as user_name,
                u.email,
                u.role
            FROM audit_logs al
            LEFT JOIN users u ON u.id = al.user_id
            WHERE $whereClause
            ORDER BY al.created_at DESC
            LIMIT ? OFFSET ?
        ");

                // Preparar la consulta
        $stmt = $db->prepare("
            SELECT 
                al.*,
                u.name as user_name,
                u.email,
                u.role
            FROM audit_logs al
            LEFT JOIN users u ON u.id = al.user_id
            WHERE $whereClause
            ORDER BY al.created_at DESC
            LIMIT ? OFFSET ?
        ");

        // Bind de parámetros: los de $params como strings, limit/offset como enteros
        $paramIndex = 1;
        foreach ($params as $param) {
            $stmt->bindValue($paramIndex++, $param, is_int($param) ? PDO::PARAM_INT : PDO::PARAM_STR);
        }
        // Bind explícito de limit y offset como enteros
        $stmt->bindValue($paramIndex++, (int)$limit, PDO::PARAM_INT);
        $stmt->bindValue($paramIndex++, (int)$offset, PDO::PARAM_INT);
        
        $stmt->execute();
        $logs = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // Tipos de acción disponibles
        $actionTypes = $db->query("
            SELECT DISTINCT action_type
            FROM audit_logs
            ORDER BY action_type
        ")->fetchAll(PDO::FETCH_COLUMN);

        echo json_encode([
            'logs' => $logs,
            'pagination' => [
                'current_page' => $page,
                'last_page' => ceil($total / $limit),
                'total' => $total,
                'per_page' => $limit
            ],
            'action_types' => $actionTypes,
            'filters' => [
                'search' => $search,
                'type' => $type,
                'user_id' => $user_id,
                'date_from' => $date_from,
                'date_to' => $date_to
            ]
        ]);
    }

    /* ---------- SEGURIDAD: IPs BLOQUEADAS ---------- */
    public function getBlockedIPs(): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $db = $this->conn;

        $stmt = $db->query("
            SELECT
                id,
                ip_address,
                reason,
                blocked_by,
                created_at,
                expires_at,
                is_active,
                CASE
                    WHEN expires_at IS NULL THEN 'permanent'
                    WHEN expires_at > NOW() THEN 'active'
                    ELSE 'expired'
                END as status
            FROM blocked_ips
            ORDER BY created_at DESC
        ");

        $ips = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode([
            'blocked_ips' => $ips,
            'total' => count($ips),
            'active' => count(array_filter($ips, fn($ip) => $ip['status'] === 'active'))
        ]);
    }

    public function blockIP(): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $input = json_decode(file_get_contents('php://input'), true);
        $ip = $input['ip_address'] ?? '';
        $reason = $input['reason'] ?? '';
        $expires_at = $input['expires_at'] ?? null;

        if (!$ip) {
            http_response_code(400);
            echo json_encode(['error' => 'IP address requerida']);
            return;
        }

        // Validar IP
        if (!filter_var($ip, FILTER_VALIDATE_IP)) {
            http_response_code(400);
            echo json_encode(['error' => 'IP address inválida']);
            return;
        }

        $db = $this->conn;

        // Verificar si ya está bloqueada
        $checkStmt = $db->prepare("SELECT id FROM blocked_ips WHERE ip_address = ? AND is_active = 1");
        $checkStmt->execute([$ip]);

        if ($checkStmt->fetch()) {
            http_response_code(400);
            echo json_encode(['error' => 'IP ya está bloqueada']);
            return;
        }

        // Insertar bloqueo
        $stmt = $db->prepare("
            INSERT INTO blocked_ips (ip_address, reason, blocked_by, expires_at, created_at)
            VALUES (?, ?, 'admin', ?, NOW())
        ");

        $stmt->execute([$ip, $reason, $expires_at]);
        $id = $db->lastInsertId();

        echo json_encode([
            'success' => true,
            'message' => 'IP bloqueada exitosamente',
            'id' => $id
        ]);
    }

    public function unblockIP(): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $input = json_decode(file_get_contents('php://input'), true);
        $id = $input['id'] ?? null;

        if (!$id) {
            http_response_code(400);
            echo json_encode(['error' => 'ID requerido']);
            return;
        }

        $db = $this->conn;

        $stmt = $db->prepare("UPDATE blocked_ips SET is_active = 0 WHERE id = ?");
        $stmt->execute([$id]);

        echo json_encode([
            'success' => true,
            'message' => 'IP desbloqueada exitosamente',
            'affected' => $stmt->rowCount()
        ]);
    }

    /* ---------- SEGURIDAD: CONFIGURACIÓN SSL/DOMINIO ---------- */
    public function getSecurityConfig(): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $db = $this->conn;

        // Obtener configuración de seguridad desde system_config
        $stmt = $db->prepare("
            SELECT
                system_host,
                allow_user_registration,
                max_login_attempts,
                session_timeout_minutes,
                password_expiration_days
            FROM system_config
            WHERE id = 1
        ");
        $stmt->execute();
        $config = $stmt->fetch(PDO::FETCH_ASSOC);

        // Verificar SSL
        $sslStatus = $this->checkSSLStatus($config['system_host'] ?? '');

        // Estadísticas de seguridad
        $failedLogins = (int) $db->query("
            SELECT COUNT(*) FROM login_attempts
            WHERE success = 0 AND created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
        ")->fetchColumn();

        $blockedUsers = (int) $db->query("
            SELECT COUNT(*) FROM users
            WHERE login_attempts >= (SELECT max_login_attempts FROM system_config WHERE id = 1)
            AND active = 1
        ")->fetchColumn();

        echo json_encode([
            'ssl_status' => $sslStatus,
            'security_config' => $config,
            'stats' => [
                'failed_logins_7d' => $failedLogins,
                'blocked_users' => $blockedUsers,
                'active_sessions' => (int) $db->query("SELECT COUNT(*) FROM sessions WHERE last_activity >= DATE_SUB(NOW(), INTERVAL 15 MINUTE)")->fetchColumn()
            ],
            'checks' => [
                'ssl_enabled' => $sslStatus['valid'],
                'https_redirect' => strpos($config['system_host'] ?? '', 'https://') === 0,
                'strong_passwords' => true, // Asumir que sí por ahora
                'session_secure' => true
            ]
        ]);
    }

    /* ---------- SEGURIDAD: ACTUALIZAR CONFIGURACIÓN ---------- */
    public function updateSecurityConfig(): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $input = json_decode(file_get_contents('php://input'), true);

        $allowedFields = [
            'max_login_attempts',
            'session_timeout_minutes',
            'password_expiration_days',
            'allow_user_registration'
        ];

        $updates = [];
        $params = [];

        foreach ($allowedFields as $field) {
            if (isset($input[$field])) {
                $updates[] = "$field = ?";
                $params[] = $input[$field];
            }
        }

        if (empty($updates)) {
            http_response_code(400);
            echo json_encode(['error' => 'No hay campos para actualizar']);
            return;
        }

        $params[] = 1; // WHERE id = 1

        $db = $this->conn;
        $sql = "UPDATE system_config SET " . implode(', ', $updates) . " WHERE id = ?";
        $stmt = $db->prepare($sql);
        $stmt->execute($params);

        echo json_encode([
            'success' => true,
            'message' => 'Configuración de seguridad actualizada',
            'affected' => $stmt->rowCount()
        ]);
    }

    /* ---------- Métodos para pasarelas de pago ---------- */
    public function getPaymentGateways(): void {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $stmt = $this->conn->query("SELECT * FROM payment_gateways ORDER BY sort_order, id");
        $gateways = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // Ocultar información sensible
        foreach ($gateways as &$gateway) {
            if ($gateway['api_key_secret']) {
                $gateway['api_key_secret'] = '••••••••' . substr($gateway['api_key_secret'], -4);
            }
            if ($gateway['api_key_extra']) {
                $gateway['api_key_extra'] = '••••••••' . substr($gateway['api_key_extra'], -4);
            }
            if ($gateway['mercadopago_access_token']) {
                $gateway['mercadopago_access_token'] = '••••••••' . substr($gateway['mercadopago_access_token'], -4);
            }
        }

        echo json_encode(['gateways' => $gateways]);
    }

    public function getPaymentGateway($id): void {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $stmt = $this->conn->prepare("SELECT * FROM payment_gateways WHERE id = ?");
        $stmt->execute([$id]);
        $gateway = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$gateway) {
            http_response_code(404);
            echo json_encode(['error' => 'Pasarela no encontrada']);
            return;
        }

        echo json_encode(['gateway' => $gateway]);
    }

    public function updatePaymentGateway($id): void {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $input = json_decode(file_get_contents('php://input'), true);

        // Validar campos requeridos
        $validationError = $this->validatePaymentGateway($input);
        if ($validationError) {
            http_response_code(400);
            echo json_encode(['error' => $validationError]);
            return;
        }

        // Obtener gateway actual
        $stmt = $this->conn->prepare("SELECT * FROM payment_gateways WHERE id = ?");
        $stmt->execute([$id]);
        $current = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$current) {
            http_response_code(404);
            echo json_encode(['error' => 'Pasarela no encontrada']);
            return;
        }

        // Preparar campos para actualizar
        $fields = [
            'display_name', 'description', 'is_active', 'is_test_mode',
            'paypal_email', 'mercadopago_access_token', 'bank_name',
            'bank_account', 'bank_holder', 'bank_id_type', 'bank_id_number',
            'mobile_phone', 'mobile_operator', 'zelle_email',
            'commission_rate', 'fixed_commission', 'instructions',
            'sort_order'
        ];

        $updates = [];
        $params = [];

        foreach ($fields as $field) {
            if (isset($input[$field])) {
                $updates[] = "$field = ?";
                $params[] = $input[$field];
            }
        }

        // Manejar API keys solo si se proporcionan
        if (isset($input['api_key_public']) && $input['api_key_public'] !== '••••••••') {
            $updates[] = "api_key_public = ?";
            $params[] = $input['api_key_public'];
        }

        if (isset($input['api_key_secret']) && !str_starts_with($input['api_key_secret'], '••••••••')) {
            $updates[] = "api_key_secret = ?";
            $params[] = $input['api_key_secret'];
        }

        if (isset($input['api_key_extra']) && !str_starts_with($input['api_key_extra'], '••••••••')) {
            $updates[] = "api_key_extra = ?";
            $params[] = $input['api_key_extra'];
        }

        if (isset($input['mercadopago_access_token']) && !str_starts_with($input['mercadopago_access_token'], '••••••••')) {
            $updates[] = "mercadopago_access_token = ?";
            $params[] = $input['mercadopago_access_token'];
        }

        if (empty($updates)) {
            http_response_code(400);
            echo json_encode(['error' => 'No hay campos para actualizar']);
            return;
        }

        $params[] = $id;
        $sql = "UPDATE payment_gateways SET " . implode(', ', $updates) . " WHERE id = ?";

        $stmt = $this->conn->prepare($sql);
        $stmt->execute($params);

        echo json_encode(['message' => 'Pasarela actualizada correctamente']);
    }

   public function getPaymentStats(): void {
    $this->requireAdmin();                                     
    header('Content-Type: application/json');

    $db = $this->conn;
    
    try {
        // Estadísticas del día
        $today = date('Y-m-d');
        
        // Ingresos hoy (JOIN con service_requests para obtener el precio)
        $stmt = $db->prepare("
            SELECT 
                COALESCE(SUM(r.price), 0) as revenue_today,
                COUNT(*) as transactions_today
            FROM payments p
            INNER JOIN service_requests r ON p.service_request_id = r.id
            WHERE DATE(p.created_at) = ? 
            AND p.status = 'paid'
        ");
        $stmt->execute([$today]);                                  
        $todayStats = $stmt->fetch(PDO::FETCH_ASSOC);

        // Si no hay resultados, inicializar con 0
        if (!$todayStats) {
            $todayStats = ['revenue_today' => 0, 'transactions_today' => 0];
        }

        // Total por pasarela de pago (JOIN con service_requests)
        $stmt = $db->query("
            SELECT 
                p.gateway_name,
                COUNT(*) as total_transactions,
                COALESCE(SUM(CASE WHEN p.status = 'paid' THEN r.price ELSE 0 END), 0) as total_amount,
                ROUND(
                    SUM(CASE WHEN p.status = 'paid' THEN 1 ELSE 0 END) * 100.0 / 
                    NULLIF(COUNT(*), 0),
                    2
                ) as success_rate
            FROM payments p
            INNER JOIN service_requests r ON p.service_request_id = r.id
            WHERE p.gateway_name IS NOT NULL
            GROUP BY p.gateway_name
        ");
        $gatewayStats = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // Transacciones recientes (con JOIN para obtener el precio y nombre del usuario)
        $stmt = $db->query("
            SELECT 
                p.*, 
                u.name as user_name,
                r.price as amount
            FROM payments p
            LEFT JOIN users u ON p.user_id = u.id
            LEFT JOIN service_requests r ON p.service_request_id = r.id
            ORDER BY p.created_at DESC 
            LIMIT 10
        ");
        $recentTransactions = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode([
            'success' => true,
            'today_revenue' => (float)$todayStats['revenue_today'],
            'today_transactions' => (int)$todayStats['transactions_today'],
            'gateway_stats' => $gatewayStats,
            'recent_transactions' => $recentTransactions
        ]);
        
    } catch (Exception $e) {
        error_log("Error en getPaymentStats: " . $e->getMessage());
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'error' => 'Error al obtener estadísticas: ' . $e->getMessage()
        ]);
    }
}
    public function updatePaymentSettings(): void {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $input = json_decode(file_get_contents('php://input'), true);

        $fields = ['payment_default_commission', 'payment_min_commission', 'payment_currency'];
        $values = [];

        foreach ($fields as $field) {
            if (isset($input[$field])) {
                $values[] = $input[$field];
            } else {
                $values[] = null;
            }
        }

        $values[] = 1; // WHERE id = 1

        $sql = "UPDATE system_config SET
                payment_default_commission = ?,
                payment_min_commission = ?,
                payment_currency = ?
                WHERE id = ?";

        $stmt = $this->conn->prepare($sql);
        $stmt->execute($values);

        echo json_encode(['message' => 'Configuración de pagos actualizada']);
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

    /* ---------- reporte del sistema ---------- */
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

    /* ---------- Configuración del Sistema ---------- */
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

    /* ---------- GESTIÓN DE CATEGORÍAS ---------- */
    public function getCategories(): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $db = $this->conn;
        $stmt = $db->query(
            "SELECT c.*,
                    COUNT(s.id) as service_count
             FROM categories c
             LEFT JOIN services s ON s.category_id = c.id AND s.status = 'active'
             GROUP BY c.id
             ORDER BY c.sort_order ASC, c.name ASC"
        );
        $categories = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode(['categories' => $categories]);
    }

    public function createCategory(): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $input = json_decode(file_get_contents('php://input'), true);
        if (empty($input['name'])) {
            http_response_code(400);
            echo json_encode(['error' => 'El nombre es requerido']);
            return;
        }

        $db = $this->conn;
        $stmt = $db->prepare(
            "INSERT INTO categories (name, description, icon, color, sort_order, is_active)
             VALUES (?, ?, ?, ?, ?, ?)"
        );

        $stmt->execute([
            $input['name'],
            $input['description'] ?? '',
            $input['icon'] ?? '📦',
            $input['color'] ?? '#667eea',
            $input['sort_order'] ?? 0,
            $input['is_active'] ?? 1
        ]);

        $categoryId = $db->lastInsertId();
        $stmt = $db->prepare("SELECT * FROM categories WHERE id = ?");
        $stmt->execute([$categoryId]);
        $category = $stmt->fetch(PDO::FETCH_ASSOC);

        echo json_encode(['category' => $category]);
    }

    public function updateCategory(int $id): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $input = json_decode(file_get_contents('php://input'), true);
        $allowed = ['name', 'description', 'icon', 'color', 'sort_order', 'is_active'];

        $sets = [];
        $params = [];
        foreach ($allowed as $field) {
            if (isset($input[$field])) {
                $sets[] = "$field = ?";
                $params[] = $input[$field];
            }
        }

        if (empty($sets)) {
            http_response_code(400);
            echo json_encode(['error' => 'No hay datos para actualizar']);
            return;
        }

        $params[] = $id;
        $sql = "UPDATE categories SET " . implode(', ', $sets) . " WHERE id = ?";

        $stmt = $this->conn->prepare($sql);
        $stmt->execute($params);

        // Devolver categoría actualizada
        $stmt = $this->conn->prepare("SELECT * FROM categories WHERE id = ?");
        $stmt->execute([$id]);
        $category = $stmt->fetch(PDO::FETCH_ASSOC);

        echo json_encode(['category' => $category]);
    }

    public function deleteCategory(int $id): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $db = $this->conn;

        // Verificar si hay servicios usando esta categoría
        $stmt = $db->prepare("SELECT COUNT(*) FROM services WHERE category_id = ?");
        $stmt->execute([$id]);
        $serviceCount = $stmt->fetchColumn();

        if ($serviceCount > 0) {
            http_response_code(400);
            echo json_encode(['error' => 'No se puede eliminar: hay servicios usando esta categoría']);
            return;
        }

        $stmt = $db->prepare("DELETE FROM categories WHERE id = ?");
        $stmt->execute([$id]);

        echo json_encode(['message' => 'Categoría eliminada']);
    }

    public function updateCategoryStatus(int $id): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $input = json_decode(file_get_contents('php://input'), true);
        $is_active = $input['is_active'] ?? 0;

        $stmt = $this->conn->prepare("UPDATE categories SET is_active = ? WHERE id = ?");
        $stmt->execute([$is_active, $id]);

        echo json_encode(['message' => 'Estado actualizado']);
    }

    public function updateCategoriesOrder(): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $input = json_decode(file_get_contents('php://input'), true);
        if (empty($input['order']) || !is_array($input['order'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Datos de orden inválidos']);
            return;
        }

        $db = $this->conn;
        foreach ($input['order'] as $item) {
            $stmt = $db->prepare("UPDATE categories SET sort_order = ? WHERE id = ?");
            $stmt->execute([$item['sort_order'], $item['id']]);
        }

        echo json_encode(['message' => 'Orden actualizado']);
    }

    /* ---------- GESTIÓN DE PÁGINAS ESTÁTICAS ---------- */
    public function getPages(): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $stmt = $this->conn->query(
            "SELECT * FROM static_pages ORDER BY sort_order ASC, title ASC"
        );
        $pages = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode(['pages' => $pages]);
    }

    public function createPage(): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $input = json_decode(file_get_contents('php://input'), true);
        if (empty($input['title']) || empty($input['slug'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Título y slug son requeridos']);
            return;
        }

        $db = $this->conn;
        $stmt = $db->prepare(
            "INSERT INTO static_pages (title, slug, content, meta_title, meta_description, meta_keywords, is_active, is_in_menu, sort_order)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"
        );

        $stmt->execute([
            $input['title'],
            $input['slug'],
            $input['content'] ?? '',
            $input['meta_title'] ?? '',
            $input['meta_description'] ?? '',
            $input['meta_keywords'] ?? '',
            $input['is_active'] ?? 1,
            $input['is_in_menu'] ?? 0,
            $input['sort_order'] ?? 0
        ]);

        $pageId = $db->lastInsertId();
        $stmt = $db->prepare("SELECT * FROM static_pages WHERE id = ?");
        $stmt->execute([$pageId]);
        $page = $stmt->fetch(PDO::FETCH_ASSOC);

        echo json_encode(['page' => $page]);
    }

    public function updatePage(int $id): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $input = json_decode(file_get_contents('php://input'), true);
        $allowed = ['title', 'slug', 'content', 'meta_title', 'meta_description', 'meta_keywords', 'is_active', 'is_in_menu', 'sort_order'];

        $sets = [];
        $params = [];
        foreach ($allowed as $field) {
            if (isset($input[$field])) {
                $sets[] = "$field = ?";
                $params[] = $input[$field];
            }
        }

        if (empty($sets)) {
            http_response_code(400);
            echo json_encode(['error' => 'No hay datos para actualizar']);
            return;
        }

        $params[] = $id;
        $sql = "UPDATE static_pages SET " . implode(', ', $sets) . " WHERE id = ?";

        $stmt = $this->conn->prepare($sql);
        $stmt->execute($params);

        echo json_encode(['message' => 'Página actualizada']);
    }

    public function deletePage(int $id): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $stmt = $this->conn->prepare("DELETE FROM static_pages WHERE id = ?");
        $stmt->execute([$id]);

        echo json_encode(['message' => 'Página eliminada']);
    }

    public function updatePageStatus(int $id): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $input = json_decode(file_get_contents('php://input'), true);
        $is_active = $input['is_active'] ?? 0;

        $stmt = $this->conn->prepare("UPDATE static_pages SET is_active = ? WHERE id = ?");
        $stmt->execute([$is_active, $id]);

        echo json_encode(['message' => 'Estado actualizado']);
    }

    public function updatePageMenu(int $id): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $input = json_decode(file_get_contents('php://input'), true);
        $is_in_menu = $input['is_in_menu'] ?? 0;

        $stmt = $this->conn->prepare("UPDATE static_pages SET is_in_menu = ? WHERE id = ?");
        $stmt->execute([$is_in_menu, $id]);

        echo json_encode(['message' => 'Menú actualizado']);
    }

    /* ---------- GESTIÓN DE FAQs ---------- */
    public function getFaqs(): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $stmt = $this->conn->query(
            "SELECT * FROM faqs ORDER BY sort_order ASC, id DESC"
        );
        $faqs = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode(['faqs' => $faqs]);
    }

    public function createFaq(): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $input = json_decode(file_get_contents('php://input'), true);
        if (empty($input['question']) || empty($input['answer'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Pregunta y respuesta son requeridos']);
            return;
        }

        $db = $this->conn;
        $stmt = $db->prepare(
            "INSERT INTO faqs (question, answer, sort_order, is_active)
             VALUES (?, ?, ?, ?)"
        );

        $stmt->execute([
            $input['question'],
            $input['answer'],
            $input['sort_order'] ?? 0,
            $input['is_active'] ?? 1
        ]);

        $faqId = $db->lastInsertId();
        $stmt = $db->prepare("SELECT * FROM faqs WHERE id = ?");
        $stmt->execute([$faqId]);
        $faq = $stmt->fetch(PDO::FETCH_ASSOC);

        echo json_encode(['faq' => $faq]);
    }

    public function updateFaq(int $id): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $input = json_decode(file_get_contents('php://input'), true);
        $allowed = ['question', 'answer', 'sort_order', 'is_active'];

        $sets = [];
        $params = [];
        foreach ($allowed as $field) {
            if (isset($input[$field])) {
                $sets[] = "$field = ?";
                $params[] = $input[$field];
            }
        }

        if (empty($sets)) {
            http_response_code(400);
            echo json_encode(['error' => 'No hay datos para actualizar']);
            return;
        }

        $params[] = $id;
        $sql = "UPDATE faqs SET " . implode(', ', $sets) . " WHERE id = ?";

        $stmt = $this->conn->prepare($sql);
        $stmt->execute($params);

        echo json_encode(['message' => 'FAQ actualizada']);
    }

    public function deleteFaq(int $id): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $stmt = $this->conn->prepare("DELETE FROM faqs WHERE id = ?");
        $stmt->execute([$id]);

        echo json_encode(['message' => 'FAQ eliminada']);
    }

    public function updateFaqStatus(int $id): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $input = json_decode(file_get_contents('php://input'), true);
        $is_active = $input['is_active'] ?? 0;

        $stmt = $this->conn->prepare("UPDATE faqs SET is_active = ? WHERE id = ?");
        $stmt->execute([$is_active, $id]);

        echo json_encode(['message' => 'Estado actualizado']);
    }

    public function updateFaqsOrder(): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $input = json_decode(file_get_contents('php://input'), true);
        if (empty($input['order']) || !is_array($input['order'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Datos de orden inválidos']);
            return;
        }

        $db = $this->conn;
        foreach ($input['order'] as $item) {
            $stmt = $db->prepare("UPDATE faqs SET sort_order = ? WHERE id = ?");
            $stmt->execute([$item['sort_order'], $item['id']]);
        }

        echo json_encode(['message' => 'Orden de FAQs actualizado']);
    }

    /* ---------- GESTIÓN DE BLOQUES DE CONTENIDO ---------- */
    public function getBlocks(): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $stmt = $this->conn->query(
            "SELECT * FROM content_blocks ORDER BY id DESC"
        );
        $blocks = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode(['blocks' => $blocks]);
    }

    public function createBlock(): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $input = json_decode(file_get_contents('php://input'), true);
        if (empty($input['name']) || empty($input['identifier'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Nombre e identificador son requeridos']);
            return;
        }

        $db = $this->conn;
        $stmt = $db->prepare(
            "INSERT INTO content_blocks (name, identifier, type, content, settings, is_active)
             VALUES (?, ?, ?, ?, ?, ?)"
        );

        $settings = isset($input['settings']) ? json_encode($input['settings']) : '{}';

        $stmt->execute([
            $input['name'],
            $input['identifier'],
            $input['type'] ?? 'text',
            $input['content'] ?? '',
            $settings,
            $input['is_active'] ?? 1
        ]);

        $blockId = $db->lastInsertId();
        $stmt = $db->prepare("SELECT * FROM content_blocks WHERE id = ?");
        $stmt->execute([$blockId]);
        $block = $stmt->fetch(PDO::FETCH_ASSOC);

        // Decodificar settings JSON
        if ($block['settings']) {
            $block['settings'] = json_decode($block['settings'], true);
        }

        echo json_encode(['block' => $block]);
    }

    public function updateBlock(int $id): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $input = json_decode(file_get_contents('php://input'), true);
        $allowed = ['name', 'identifier', 'type', 'content', 'settings', 'is_active'];

        $sets = [];
        $params = [];
        foreach ($allowed as $field) {
            if (isset($input[$field])) {
                if ($field === 'settings') {
                    $sets[] = "$field = ?";
                    $params[] = json_encode($input[$field]);
                } else {
                    $sets[] = "$field = ?";
                    $params[] = $input[$field];
                }
            }
        }

        if (empty($sets)) {
            http_response_code(400);
            echo json_encode(['error' => 'No hay datos para actualizar']);
            return;
        }

        $params[] = $id;
        $sql = "UPDATE content_blocks SET " . implode(', ', $sets) . " WHERE id = ?";

        $stmt = $this->conn->prepare($sql);
        $stmt->execute($params);

        echo json_encode(['message' => 'Bloque actualizado']);
    }

    public function deleteBlock(int $id): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $stmt = $this->conn->prepare("DELETE FROM content_blocks WHERE id = ?");
        $stmt->execute([$id]);

        echo json_encode(['message' => 'Bloque eliminada']);
    }

    public function updateBlockStatus(int $id): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $input = json_decode(file_get_contents('php://input'), true);
        $is_active = $input['is_active'] ?? 0;

        $stmt = $this->conn->prepare("UPDATE content_blocks SET is_active = ? WHERE id = ?");
        $stmt->execute([$is_active, $id]);

        echo json_encode(['message' => 'Estado actualizado']);
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
