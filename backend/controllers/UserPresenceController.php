<?php
// controllers/UserPresenceController.php

require_once __DIR__ . '/../models/User.php';
require_once __DIR__ . '/../models/ProviderStaff.php';
require_once __DIR__ . '/../middleware/Auth.php';

class UserPresenceController
{
    private $user;
    private $staff;
    private $db;

    public function __construct()
    {
        $this->user = new User();
        $this->staff = new ProviderStaff();
        $this->db = $this->user->getDb();
    }

    /**
     * Endpoint para heartbeat de usuarios y staff online
     */
public function heartbeat()
{
    try {
        $this->staff->markOfflineByTimeout(5);

        $decoded = Auth::verify();

        if (!$decoded) {
            $decoded = $this->verifyStaffToken();
        }

        if (!$decoded) {
            http_response_code(401);
            echo json_encode(['error' => 'No autenticado']);
            return;
        }

        $userId = $decoded->id ?? $decoded->staff_id ?? null;
        $isStaff = isset($decoded->staff_id) || strpos($decoded->role ?? '', 'staff_') === 0;

        if (!$userId) {
            error_log("Heartbeat - No se encontró id en el token");
            http_response_code(401);
            echo json_encode(['error' => 'Token inválido']);
            return;
        }

        if ($isStaff) {
            $this->staff->updateHeartbeat($userId);
            $this->staff->updateOnlineStatus($userId, true);
            
            // ✅ Notificar al WebSocket que el staff está online
            $this->notifyPresence($userId, $decoded->role ?? 'staff_delivery', 'online');
        } else {
            $this->user->updateLastSeen($userId);
        }

        $onlineUsers = $this->getOnlineUsers($userId);

        echo json_encode([
            'success' => true,
            'timestamp' => time(),
            'online_users' => $onlineUsers,
            'user_id' => $userId,
            'is_staff' => $isStaff
        ]);

    } catch (Exception $e) {
        error_log("Heartbeat error: " . $e->getMessage());
        http_response_code(500);
        echo json_encode(['error' => 'Error interno del servidor']);
    }
}

/**
 * ✅ NUEVO: Notificar presencia al WebSocket
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

    /**
     * Verificar si un usuario o staff específico está online
     */
    public function checkUserOnline($userId)
    {
        try {
            $decoded = Auth::verify();
            if (!$decoded) {
                // ✅ Intentar verificar como staff
                $decoded = $this->verifyStaffToken();
            }

            if (!$decoded) {
                http_response_code(401);
                echo json_encode(['error' => 'No autenticado']);
                return;
            }

            $userId = (int)$userId;
            if ($userId <= 0) {
                http_response_code(400);
                echo json_encode(['error' => 'ID de usuario inválido']);
                return;
            }

            // ✅ Buscar primero en users, luego en provider_staff
            $user = $this->findUserOnlineStatus($userId);

            if (!$user) {
                http_response_code(404);
                echo json_encode(['error' => 'Usuario no encontrado']);
                return;
            }

            echo json_encode([
                'success' => true,
                'user_id' => (int)$user['id'],
                'online' => (bool)$user['is_online'],
                'last_seen' => $user['last_seen'] ? (int)$user['last_seen'] : null,
                'name' => $user['name'],
                'role' => $user['role'],
                'avatar' => $user['avatar_url'] ?? null
            ]);

        } catch (Exception $e) {
            error_log("Error en checkUserOnline: " . $e->getMessage());
            http_response_code(500);
            echo json_encode(['error' => 'Error interno del servidor']);
        }
    }

    /**
     * Obtener lista de usuarios y staff online
     */
    private function getOnlineUsers($currentUserId = null)
    {
        try {
            $onlineUsers = [];

            // ✅ Usuarios normales online
            $sql = "SELECT
                        id,
                        name,
                        avatar_url,
                        role,
                        UNIX_TIMESTAMP(last_seen_at) as last_seen
                    FROM users
                    WHERE last_seen_at > DATE_SUB(NOW(), INTERVAL 2 MINUTE)
                    ORDER BY last_seen_at DESC";

            $stmt = $this->db->prepare($sql);
            $stmt->execute();
            $users = $stmt->fetchAll(PDO::FETCH_ASSOC);

            foreach ($users as $user) {
                $onlineUsers[] = [
                    'id' => (int)$user['id'],
                    'name' => $user['name'],
                    'avatar' => $user['avatar_url'],
                    'role' => $user['role'],
                    'last_seen' => (int)$user['last_seen'],
                    'is_current' => $user['id'] == $currentUserId,
                    'type' => 'user'
                ];
            }

            // ✅ Staff online (de la tabla provider_staff)
            $sqlStaff = "SELECT
                            ps.id,
                            ps.name,
                            ps.avatar_url,
                            CONCAT('staff_', ps.role) as role,
                            ps.provider_id,
                            UNIX_TIMESTAMP(ps.last_seen) as last_seen
                        FROM provider_staff ps
                        WHERE ps.is_online = 1
                        AND ps.active = 1
                        AND ps.last_heartbeat > DATE_SUB(NOW(), INTERVAL 2 MINUTE)
                        ORDER BY ps.last_seen DESC";

            $stmtStaff = $this->db->prepare($sqlStaff);
            $stmtStaff->execute();
            $staffUsers = $stmtStaff->fetchAll(PDO::FETCH_ASSOC);

            foreach ($staffUsers as $staff) {
                $onlineUsers[] = [
                    'id' => (int)$staff['id'],
                    'name' => $staff['name'],
                    'avatar' => $staff['avatar_url'],
                    'role' => $staff['role'],
                    'last_seen' => (int)$staff['last_seen'],
                    'is_current' => $staff['id'] == $currentUserId,
                    'type' => 'staff',
                    'provider_id' => $staff['provider_id']
                ];
            }

            return $onlineUsers;

        } catch (Exception $e) {
            error_log("Error obteniendo online users: " . $e->getMessage());
            return [];
        }
    }

    /**
     * ✅ NUEVO: Buscar estado online de un usuario o staff
     */
   private function findUserOnlineStatus($userId)
{
    // Buscar en users
    $sql = "SELECT id, name, role, avatar_url,
                   UNIX_TIMESTAMP(last_seen_at) as last_seen,
                   CASE
                       WHEN last_seen_at > DATE_SUB(NOW(), INTERVAL 2 MINUTE)
                       THEN 1 ELSE 0
                   END as is_online
            FROM users
            WHERE id = ?";

    $stmt = $this->db->prepare($sql);
    $stmt->execute([$userId]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($user) {
        return $user;
    }

    // ✅ Buscar en provider_staff con verificación de heartbeat
    $sqlStaff = "SELECT id, name,
                        CONCAT('staff_', role) as role,
                        avatar_url,
                        UNIX_TIMESTAMP(COALESCE(last_seen, created_at)) as last_seen,
                        CASE
                            WHEN is_online = 1 
                            AND last_heartbeat > DATE_SUB(NOW(), INTERVAL 5 MINUTE)
                            THEN 1 ELSE 0
                        END as is_online
                 FROM provider_staff
                 WHERE id = ? AND active = 1";

    $stmtStaff = $this->db->prepare($sqlStaff);
    $stmtStaff->execute([$userId]);
    $staff = $stmtStaff->fetch(PDO::FETCH_ASSOC);

    return $staff ?: null;
}

    /**
     * ✅ NUEVO: Verificar token de staff
     */
    private function verifyStaffToken(): ?object
    {
        $headers = getallheaders();
        $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? '';

        if (!preg_match('/Bearer\s+(.+)/', $authHeader, $matches)) {
            return null;
        }

        $token = $matches[1];

        try {
            require_once __DIR__ . '/../utils/jwt.php';
            $decoded = JwtHandler::decode($token);

            if (!isset($decoded->staff_id) || strpos($decoded->role ?? '', 'staff_') !== 0) {
                return null;
            }

            return $decoded;
        } catch (\Exception $e) {
            return null;
        }
    }

    /**
     * Obtener estadísticas de usuarios online
     */
    public function getOnlineStats()
    {
        try {
            $decoded = Auth::verify();
            if (!$decoded) {
                // ✅ Intentar verificar como staff
                $decoded = $this->verifyStaffToken();
            }

            if (!$decoded) {
                http_response_code(401);
                echo json_encode(['error' => 'No autenticado']);
                return;
            }

            // ✅ Usuarios normales
            $sql = "SELECT
                        COUNT(*) as total,
                        SUM(CASE WHEN role = 'admin' THEN 1 ELSE 0 END) as admins,
                        SUM(CASE WHEN role = 'provider' THEN 1 ELSE 0 END) as providers,
                        SUM(CASE WHEN role = 'user' THEN 1 ELSE 0 END) as users
                    FROM users
                    WHERE last_seen_at > DATE_SUB(NOW(), INTERVAL 2 MINUTE)";

            $stmt = $this->db->prepare($sql);
            $stmt->execute();
            $stats = $stmt->fetch(PDO::FETCH_ASSOC);

            // ✅ Staff online
            $sqlStaff = "SELECT COUNT(*) as total_staff
                        FROM provider_staff
                        WHERE is_online = 1
                        AND active = 1
                        AND last_heartbeat > DATE_SUB(NOW(), INTERVAL 2 MINUTE)";

            $stmtStaff = $this->db->prepare($sqlStaff);
            $stmtStaff->execute();
            $staffStats = $stmtStaff->fetch(PDO::FETCH_ASSOC);

            echo json_encode([
                'success' => true,
                'stats' => [
                    'total' => (int)$stats['total'] + (int)$staffStats['total_staff'],
                    'admins' => (int)$stats['admins'],
                    'providers' => (int)$stats['providers'],
                    'users' => (int)$stats['users'],
                    'staff' => (int)$staffStats['total_staff']
                ],
                'timestamp' => time()
            ]);

        } catch (Exception $e) {
            error_log("Error en getOnlineStats: " . $e->getMessage());
            http_response_code(500);
            echo json_encode(['error' => 'Error interno del servidor']);
        }
    }
}
