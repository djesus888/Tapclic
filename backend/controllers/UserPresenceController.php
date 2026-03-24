<?php
// controllers/UserPresenceController.php

require_once __DIR__ . '/../models/User.php';
require_once __DIR__ . '/../middleware/Auth.php';

class UserPresenceController
{
    private $user;
    private $db;

    public function __construct()
    {
        $this->user = new User();
        $this->db = $this->user->getDb();
    }

    /**
     * Endpoint para heartbeat de usuarios online
     */
    public function heartbeat()
    {
        try {
            // Verificar autenticación - IGUAL que en PaymentController
            $decoded = Auth::verify();
            
            if (!$decoded) {
                http_response_code(401);
                echo json_encode(['error' => 'No autenticado']);
                return;
            }

            // IMPORTANTE: El token usa 'id' no 'user_id'
            $userId = $decoded->id ?? null;
            
            if (!$userId) {
                error_log("Heartbeat - No se encontró id en el token");
                http_response_code(401);
                echo json_encode(['error' => 'Token inválido']);
                return;
            }

            // Actualizar last_seen_at
            $this->user->updateLastSeen($userId);

            // Obtener usuarios online
            $onlineUsers = $this->getOnlineUsers($userId);

            echo json_encode([
                'success' => true,
                'timestamp' => time(),
                'online_users' => $onlineUsers,
                'user_id' => $userId
            ]);

        } catch (Exception $e) {
            error_log("Heartbeat error: " . $e->getMessage());
            http_response_code(500);
            echo json_encode(['error' => 'Error interno del servidor']);
        }
    }

    /**
     * Verificar si un usuario específico está online
     */
    public function checkUserOnline($userId)
    {
        try {
            $decoded = Auth::verify();
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

            $sql = "SELECT
                        id,
                        name,
                        role,
                        avatar_url,
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
                'avatar' => $user['avatar_url']
            ]);

        } catch (Exception $e) {
            error_log("Error en checkUserOnline: " . $e->getMessage());
            http_response_code(500);
            echo json_encode(['error' => 'Error interno del servidor']);
        }
    }

    /**
     * Obtener lista de usuarios online
     */
    private function getOnlineUsers($currentUserId = null)
    {
        try {
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

            return array_map(function($user) use ($currentUserId) {
                return [
                    'id' => (int)$user['id'],
                    'name' => $user['name'],
                    'avatar' => $user['avatar_url'],
                    'role' => $user['role'],
                    'last_seen' => (int)$user['last_seen'],
                    'is_current' => $user['id'] == $currentUserId
                ];
            }, $users);

        } catch (Exception $e) {
            error_log("Error obteniendo online users: " . $e->getMessage());
            return [];
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
                http_response_code(401);
                echo json_encode(['error' => 'No autenticado']);
                return;
            }

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

            echo json_encode([
                'success' => true,
                'stats' => [
                    'total' => (int)$stats['total'],
                    'admins' => (int)$stats['admins'],
                    'providers' => (int)$stats['providers'],
                    'users' => (int)$stats['users']
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
