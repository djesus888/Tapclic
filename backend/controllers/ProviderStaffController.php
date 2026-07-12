<?php
require_once __DIR__ . '/../models/ProviderStaff.php';
require_once __DIR__ . '/../middleware/Auth.php';
require_once __DIR__ . '/../utils/AuditLogger.php';
require_once __DIR__ . '/../utils/jwt.php';

use Firebase\JWT\JWT;
use Firebase\JWT\Key;

class ProviderStaffController {
    private $model;
    private $jwtSecret;

    public function __construct() {
        $this->model = new ProviderStaff();
        $this->jwtSecret = getenv('JWT_SECRET') ?: 'tu_secreto_jwt_aqui';
    }

    public function handle(string $method): void {
        $auth = Auth::verify();
        if (!$auth) {
            http_response_code(401);
            echo json_encode(['error' => 'No autorizado']);
            return;
        }

        // Solo proveedores pueden gestionar su staff
        if ($auth->role !== 'provider') {
            http_response_code(403);
            echo json_encode(['error' => 'Solo proveedores pueden gestionar personal']);
            return;
        }

        $uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

        if ($method === 'GET' && preg_match('/\/api\/provider\/staff\/?$/', $uri)) {
            $this->listStaff($auth->id);
        } elseif ($method === 'POST' && preg_match('/\/api\/provider\/staff\/create/', $uri)) {
            $this->createStaff($auth->id);
        } elseif ($method === 'POST' && preg_match('/\/api\/provider\/staff\/update/', $uri)) {
            $this->updateStaff($auth->id);
        } elseif ($method === 'POST' && preg_match('/\/api\/provider\/staff\/delete/', $uri)) {
            $this->deleteStaff($auth->id);
        } else {
            http_response_code(404);
            echo json_encode(['error' => 'Ruta no encontrada']);
        }
    }

    // ========== LOGIN DE STAFF ==========

    public function login(): void {
        $data = json_decode(file_get_contents('php://input'), true);
        $email = trim($data['email'] ?? '');
        $password = $data['password'] ?? '';

        if (empty($email) || empty($password)) {
            http_response_code(400);
            echo json_encode(['error' => 'Email y contraseña requeridos']);
            return;
        }

        $staff = $this->model->findByEmail($email);
        if (!$staff || !password_verify($password, $staff['password'])) {
            http_response_code(401);
            echo json_encode(['error' => 'Credenciales incorrectas']);
            return;
        }

        if (!$staff['active']) {
            http_response_code(403);
            echo json_encode(['error' => 'Cuenta desactivada']);
            return;
        }

        // Generar JWT para staff
        $payload = [
            'id'          => $staff['id'],
            'staff_id'    => $staff['id'],
            'provider_id' => $staff['provider_id'],
            'role'        => 'staff_' . $staff['role'],
            'exp'         => time() + (3600 * 24 * 7)
        ];
        $token = JwtHandler::encode($payload);

        // ✅ NUEVO: Marcar como online al hacer login
        $this->model->updateOnlineStatus($staff['id'], true);
        $this->model->updateHeartbeat($staff['id']);

        unset($staff['password']);
        echo json_encode([
            'success' => true,
            'token'   => $token,
            'staff'   => $staff
        ]);
    }

    // ✅ NUEVO: LOGOUT DE STAFF
public function logout(): void {
    $auth = $this->verifyStaffToken();
    if ($auth && isset($auth->staff_id)) {
        $this->model->updateOnlineStatus($auth->staff_id, false);
        AuditLogger::log($auth->staff_id, 'staff_logout', 'Staff cerró sesión');
        $this->notifyPresence($auth->staff_id, $auth->role ?? 'staff_delivery', 'offline');
        
        // ✅ AÑADE ESTO: Invalidar el token actual
        $headers = getallheaders();
        $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? '';
        if (preg_match('/Bearer\s+(.+)/', $authHeader, $matches)) {
            $token = $matches[1];
            $decoded = JwtHandler::decode($token);
            $expiresAt = $decoded && isset($decoded->exp) 
                ? date('Y-m-d H:i:s', $decoded->exp) 
                : date('Y-m-d H:i:s', time() + 86400);
            Auth::addToBlacklist($token, $expiresAt);
        }
    }
    echo json_encode(['success' => true, 'message' => 'Sesión cerrada correctamente']);
}


    // ✅ NUEVO: HEARTBEAT DE STAFF
    public function heartbeat(): void {
        $auth = $this->verifyStaffToken();
        
        if (!$auth || !isset($auth->staff_id)) {
            http_response_code(401);
            echo json_encode(['error' => 'No autorizado']);
            return;
        }

        $this->model->updateHeartbeat($auth->staff_id);
        $this->model->updateOnlineStatus($auth->staff_id, true);

        echo json_encode(['success' => true, 'message' => 'Heartbeat recibido']);
    }

    // ========== PERFIL DE STAFF (AUTENTICADO COMO STAFF) ==========
    public function getProfile(): void {
    $auth = $this->verifyStaffToken();
    if (!$auth) {
        http_response_code(401);
        echo json_encode(['error' => 'No autorizado']);
        return;
    }

    $staff = $this->model->findById($auth->staff_id);
    if (!$staff) {
        http_response_code(404);
        echo json_encode(['error' => 'Staff no encontrado']);
        return;
    }

    // ✅ Verificar si realmente está online basado en el heartbeat
    $isActuallyOnline = false;
    if ($staff['is_online'] && !empty($staff['last_heartbeat'])) {
        $lastHeartbeat = strtotime($staff['last_heartbeat']);
        $now = time();
        $isActuallyOnline = ($now - $lastHeartbeat) < 300; // 5 minutos
    }
    
    // Actualizar en DB si hay discrepancia
    if ($staff['is_online'] && !$isActuallyOnline) {
        $this->model->updateOnlineStatus($staff['id'], false);
        $staff['is_online'] = false;
    }

    unset($staff['password']);
    echo json_encode(['success' => true, 'staff' => $staff]);
}

    public function updateProfile(): void {
        $auth = $this->verifyStaffToken();
        if (!$auth) {
            http_response_code(401);
            echo json_encode(['error' => 'No autorizado']);
            return;
        }

        $staff = $this->model->findById($auth->staff_id);
        if (!$staff) {
            http_response_code(404);
            echo json_encode(['error' => 'Staff no encontrado']);
            return;
        }

        $data = json_decode(file_get_contents('php://input'), true);

        // También permitir multipart/form-data (para avatar)
        if (empty($data)) {
            $data = $_POST;
        }

        $updateData = [
            'name'   => $data['name'] ?? $staff['name'],
            'phone'  => $data['phone'] ?? $staff['phone'],
            'role'   => $staff['role'],
            'active' => $staff['active'],
        ];

        if (!empty($data['email']) && $data['email'] !== $staff['email']) {
            $existing = $this->model->findByEmail($data['email']);
            if ($existing && $existing['id'] != $auth->staff_id) {
                http_response_code(409);
                echo json_encode(['error' => 'El email ya está en uso']);
                return;
            }
            $updateData['email'] = $data['email'];
        }

        if (isset($_FILES['avatar'])) {
            $avatarPath = $this->uploadAvatar($_FILES['avatar'], $auth->staff_id);
            if ($avatarPath) {
                $updateData['avatar_url'] = $avatarPath;
            }
        }

        $ok = $this->model->updateProfile($auth->staff_id, $updateData);
        if ($ok) {
            $staff = $this->model->findById($auth->staff_id);
            unset($staff['password']);
            echo json_encode(['success' => true, 'staff' => $staff, 'message' => 'Perfil actualizado']);
        } else {
            http_response_code(500);
            echo json_encode(['error' => 'Error al actualizar perfil']);
        }
    }

    public function changePassword(): void {
        $auth = $this->verifyStaffToken();
        if (!$auth) {
            http_response_code(401);
            echo json_encode(['error' => 'No autorizado']);
            return;
        }

        $data = json_decode(file_get_contents('php://input'), true);

        if (empty($data['current_password']) || empty($data['new_password'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Contraseña actual y nueva son requeridas']);
            return;
        }

        if (strlen($data['new_password']) < 8) {
            http_response_code(400);
            echo json_encode(['error' => 'La nueva contraseña debe tener al menos 8 caracteres']);
            return;
        }

        $staff = $this->model->findById($auth->staff_id);
        if (!$staff) {
            http_response_code(404);
            echo json_encode(['error' => 'Staff no encontrado']);
            return;
        }

        if (!password_verify($data['current_password'], $staff['password'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Contraseña actual incorrecta']);
            return;
        }

        $ok = $this->model->updatePassword($auth->staff_id, $data['new_password']);
        if ($ok) {
            AuditLogger::log($auth->staff_id, 'password_changed', 'Staff cambió contraseña');
            echo json_encode(['success' => true, 'message' => 'Contraseña actualizada']);
        } else {
            http_response_code(500);
            echo json_encode(['error' => 'Error al cambiar contraseña']);
        }
    }

    // ========== MÉTODOS PRIVADOS ==========

/**
 * ✅ Notificar presencia al WebSocket
 */
private function notifyPresence($userId, $role, $status)
{
    try {
        $wsUrl = 'http://localhost:3001/presence';
        $payload = json_encode([
            'user_id' => $userId,
            'role' => $role,
            'status' => $status,
            'broadcast_role' => $role
        ]);
        
        $ch = curl_init($wsUrl);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $payload);
        curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, 2);
        curl_exec($ch);
        curl_close($ch);
        
        error_log("Presencia notificada: user={$userId} role={$role} status={$status}");
    } catch (\Exception $e) {
        error_log("Error notificando presencia: " . $e->getMessage());
    }
}

    private function verifyStaffToken(): ?object {
        $headers = getallheaders();
        $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? '';

        if (!preg_match('/Bearer\s+(.+)/', $authHeader, $matches)) {
            return null;
        }

        $token = $matches[1];

        try {
            $decoded = JwtHandler::decode($token);

            if (!isset($decoded->staff_id) || strpos($decoded->role ?? '', 'staff_') !== 0) {
                return null;
            }

            return $decoded;
        } catch (\Exception $e) {
            return null;
        }
    }

    private function uploadAvatar(array $file, int $staffId): ?string {
        $allowed = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];

        if (!in_array($file['type'], $allowed)) {
            return null;
        }

        if ($file['size'] > 5 * 1024 * 1024) {
            return null;
        }

        $ext = pathinfo($file['name'], PATHINFO_EXTENSION);
        $filename = 'staff_' . $staffId . '_' . time() . '.' . $ext;
        $uploadDir = __DIR__ . '/../public/uploads/avatars/';

        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, 0755, true);
        }

        $path = $uploadDir . $filename;

        if (move_uploaded_file($file['tmp_name'], $path)) {
            return '/uploads/avatars/' . $filename;
        }

        return null;
    }

    // ========== MÉTODOS ORIGINALES PARA PROVEEDORES ==========

    private function listStaff(int $providerId): void {
        $staff = $this->model->findByProvider($providerId);
        echo json_encode(['success' => true, 'staff' => $staff]);
    }

    private function createStaff(int $providerId): void {
        $data = json_decode(file_get_contents('php://input'), true);

        if (empty($data['name']) || empty($data['password'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Nombre y contraseña requeridos']);
            return;
        }

        if (!empty($data['email']) && $this->model->findByEmail($data['email'])) {
            http_response_code(409);
            echo json_encode(['error' => 'El email ya está registrado']);
            return;
        }

        $data['provider_id'] = $providerId;
        $data['role'] = $data['role'] ?? 'delivery';

        $id = $this->model->create($data);
        if ($id) {
            AuditLogger::log($providerId, 'staff_created', 'Personal creado', "ID: {$id} - {$data['name']} - Rol: {$data['role']}");
            echo json_encode(['success' => true, 'id' => $id, 'message' => 'Personal creado correctamente']);
        } else {
            http_response_code(500);
            echo json_encode(['error' => 'Error al crear personal']);
        }
    }

    private function updateStaff(int $providerId): void {
        $data = json_decode(file_get_contents('php://input'), true);

        if (empty($data['id'])) {
            http_response_code(400);
            echo json_encode(['error' => 'ID de personal requerido']);
            return;
        }

        $staff = $this->model->findById($data['id']);
        if (!$staff || $staff['provider_id'] != $providerId) {
            http_response_code(403);
            echo json_encode(['error' => 'No tienes permiso para editar este personal']);
            return;
        }

        $ok = $this->model->update($data['id'], $data);
        echo json_encode(['success' => $ok]);
    }

    private function deleteStaff(int $providerId): void {
        $data = json_decode(file_get_contents('php://input'), true);

        if (empty($data['id'])) {
            http_response_code(400);
            echo json_encode(['error' => 'ID de personal requerido']);
            return;
        }

        $staff = $this->model->findById($data['id']);
        if (!$staff || $staff['provider_id'] != $providerId) {
            http_response_code(403);
            echo json_encode(['error' => 'No tienes permiso para eliminar este personal']);
            return;
        }

        $ok = $this->model->delete($data['id']);
        echo json_encode(['success' => $ok]);
    }
}
