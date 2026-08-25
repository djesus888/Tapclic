<?php
require_once __DIR__ . "/../middleware/Auth.php";
require_once __DIR__ . '/../models/User.php';
require_once __DIR__ . '/../utils/jwt.php';
require_once __DIR__ . '/../utils/AuditLogger.php';
require_once __DIR__ . '/../utils/Uploader.php';

class UserController {
    private $userModel;
    private $db;

    public function __construct() {
        $this->userModel = new User();
        $this->db = $this->userModel->getDb();
    }

    private function isValidEmail($email) {
        return filter_var($email, FILTER_VALIDATE_EMAIL) !== false;
    }

    private function isValidPhone($phone) {
        return preg_match('/^[+]?[\d\s\-]{7,15}$/', $phone);
    }

    public function updateProfile() {
        $auth = Auth::verify();
        if (!$auth) {
            http_response_code(401);
            echo json_encode(["error" => "No autorizado"]);
            return;
        }

        $contentType = $_SERVER['CONTENT_TYPE'] ?? '';
        $data = [];
        $avatarFileName = null;

        if (strpos($contentType, 'application/json') !== false) {
            $data = json_decode(file_get_contents("php://input"), true);
        } else if (strpos($contentType, 'multipart/form-data') !== false) {
            $data = $_POST;
            if (isset($_FILES['avatar']) && $_FILES['avatar']['error'] === UPLOAD_ERR_OK) {
                $basePath = __DIR__ . '/../public/uploads';
                $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? 'https://' : 'http://';
                $baseUrl = $protocol . $_SERVER['HTTP_HOST'] . '/uploads';
                $uploader = new \Utils\Uploader($basePath, $baseUrl);
                try {
                    $avatarUrl = $uploader->saveFile($_FILES['avatar'], \Utils\Uploader::CAT_AVATARS);
                    $avatarFileName = basename($avatarUrl);
                } catch (\RuntimeException $e) {
                    error_log("Error subiendo avatar: " . $e->getMessage());
                    http_response_code(500);
                    echo json_encode(["error" => "Error al guardar archivo avatar"]);
                    return;
                }
            }
        } else {
            http_response_code(400);
            echo json_encode(["error" => "Tipo de contenido no soportado"]);
            return;
        }

        $name = trim($data['name'] ?? '');
        $email = trim($data['email'] ?? '');
        $phone = trim($data['phone'] ?? '');
        $address = trim($data['address'] ?? '');
        $business_address = trim($data['business_address'] ?? '');
        $service_categories = trim($data['service_categories'] ?? '');
        $coverage_area = trim($data['coverage_area'] ?? '');
        $preferences = trim($data['preferences'] ?? '');
        $bio = trim($data['bio'] ?? '');
        $linkedin_url = trim($data['linkedin_url'] ?? '');
        $twitter_url = trim($data['twitter_url'] ?? '');

        if ($email !== '' && !$this->isValidEmail($email)) {
            http_response_code(400);
            echo json_encode(["error" => "Email inválido"]);
            return;
        }

        if ($phone !== '' && !$this->isValidPhone($phone)) {
            http_response_code(400);
            echo json_encode(["error" => "Teléfono inválido"]);
            return;
        }

        if ($email !== '') {
            $userByEmail = $this->userModel->findByEmail($email);
            if ($userByEmail && $userByEmail['id'] != $auth->id) {
                http_response_code(409);
                echo json_encode(["error" => "Email ya está en uso"]);
                return;
            }
        }

        if ($phone !== '') {
            $userByPhone = $this->userModel->findByPhone($phone);
            if ($userByPhone && $userByPhone['id'] != $auth->id) {
                http_response_code(409);
                echo json_encode(["error" => "Teléfono ya está en uso"]);
                return;
            }
        }

        $ok = $this->userModel->updateProfile($auth->id, [
            'name' => $name,
            'email' => $email,
            'phone' => $phone,
            'address' => $address,
            'business_address' => $business_address,
            'service_categories' => $service_categories,
            'preferences' => $preferences,
            'coverage_area' => $coverage_area,
            'bio' => $bio,
            'linkedin_url' => $linkedin_url,
            'twitter_url' => $twitter_url
        ]);

        if ($avatarFileName) {
            $this->userModel->updateAvatar($auth->id, $avatarFileName);
        }

        if ($ok) {
            AuditLogger::log($auth->id, 'profile_updated', 'Perfil actualizado', "Nombre: {$name}");
            echo json_encode(["success" => true]);
        } else {
            http_response_code(500);
            echo json_encode(["error" => "Error al actualizar perfil"]);
        }
    }

    public function changePassword() {
        $auth = Auth::verify();
        if (!$auth) return $this->unauthorized();

        $data = json_decode(file_get_contents("php://input"), true);

        $user = $this->userModel->findById($auth->id);

        if (!password_verify($data['current_password'], $user['password'])) {
            echo json_encode(["error" => "Contraseña actual incorrecta"]);
            return;
        }

        $ok = $this->userModel->updatePassword($auth->id, $data['new_password']);

        if ($ok) {
            AuditLogger::log($auth->id, 'password_changed', 'Contraseña cambiada', 'El usuario cambió su contraseña');
        }

        echo json_encode(["success" => $ok]);
    }

    public function updatePreferences() {
        $auth = Auth::verify();
        if (!$auth) return $this->unauthorized();

        $data = json_decode(file_get_contents("php://input"), true);
        $ok = $this->userModel->updatePreferences($auth->id, $data);
        echo json_encode(["success" => $ok]);
    }

    public function uploadAvatar() {
        $auth = Auth::verify();
        if (!$auth) return $this->unauthorized();

        $input = json_decode(file_get_contents("php://input"), true);
        $url = $input['avatar_url'] ?? '';

        if (!$url) {
            echo json_encode(["error" => "URL no proporcionada"]);
            return;
        }

        $ok = $this->userModel->updateAvatar($auth->id, $url);

        if ($ok) {
            AuditLogger::log($auth->id, 'avatar_updated', 'Avatar actualizado', 'El usuario cambió su foto de perfil');
        }

        echo json_encode(["success" => $ok]);
    }

    public function updateProviderData() {
        $auth = Auth::verify();
        if (!$auth || $auth->role !== 'driver') return $this->unauthorized();

        $data = json_decode(file_get_contents("php://input"), true);
        $ok = $this->userModel->updateProviderData($auth->id, $data);
        echo json_encode(["success" => $ok]);
    }

    public function deleteAccount() {
        $auth = Auth::verify();
        if (!$auth) {
            http_response_code(401);
            echo json_encode(["error" => "No autorizado"]);
            return;
        }

        $input = json_decode(file_get_contents("php://input"), true);
        $password = $input["password"] ?? null;

        if (!$password) {
            http_response_code(400);
            echo json_encode(["error" => "La contraseña es obligatoria para eliminar la cuenta"]);
            return;
        }

        try {
            $this->userModel->deleteAccount($auth->id, $password);
            echo json_encode(["success" => true, "message" => "Cuenta eliminada correctamente"]);
        } catch (Exception $e) {
            http_response_code(400);
            echo json_encode(["error" => $e->getMessage()]);
        }
    }

    public function getUserActivity() {
        $auth = Auth::verify();
        if (!$auth) {
            http_response_code(401);
            echo json_encode(["error" => "No autorizado"]);
            return;
        }

        $limit = isset($_GET["limit"]) ? (int)$_GET["limit"] : 10;
        $limit = min($limit, 50);

        $stmt = $this->db->prepare("SELECT id, action_type, action, created_at FROM audit_logs WHERE user_id = ? ORDER BY created_at DESC LIMIT ?");
        $stmt->bindValue(1, $auth->id, PDO::PARAM_INT);
        $stmt->bindValue(2, $limit, PDO::PARAM_INT);
        $stmt->execute();
        $activities = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode(["success" => true, "activities" => $activities]);
    }

    public function getProfile() {
        $auth = Auth::verify();
        if (!$auth) {
            http_response_code(401);
            echo json_encode(["error" => "No autorizado"]);
            return;
        }

        $user = $this->userModel->findById($auth->id);
        header('Content-Type: application/json');
        echo json_encode(['user' => $user]);
    }

    private function unauthorized() {
        http_response_code(401);
        echo json_encode(["error" => "No autorizado"]);
    }

    /**
     * Obtener dispositivos conectados del usuario
     */
    public function getDevices() {
        try {
            $auth = Auth::verify();
            if (!$auth) {
                http_response_code(401);
                echo json_encode(['error' => 'No autorizado']);
                return;
            }

            $userId = $auth->id;
            $currentToken = $this->getBearerToken();

            $query = "SELECT id, device_name, device_type, browser, platform,
                             ip_address, location, last_active, device_fingerprint,
                             CASE WHEN refresh_token = ? THEN 1 ELSE 0 END as is_current
                      FROM user_devices
                      WHERE user_id = ?
                      ORDER BY is_current DESC, last_active DESC";

            $stmt = $this->db->prepare($query);
            $stmt->execute([$currentToken, $userId]);
            $devices = $stmt->fetchAll(PDO::FETCH_ASSOC);

            foreach ($devices as &$device) {
                $device['last_active_raw'] = $device['last_active'];
                $device['last_active'] = $this->timeAgo($device['last_active']);
                $device['last_active_iso'] = date('c', strtotime($device['last_active_raw']));
                $device['name'] = $this->formatDeviceName($device);

                if (empty($device['location'])) {
                    $device['location'] = $this->getLocationFromIp($device['ip_address']);
                }

                $device['is_current'] = (bool)$device['is_current'];
                $device['device_info'] = [
                    'browser' => $device['browser'],
                    'platform' => $device['platform'],
                    'type' => $device['device_type']
                ];
            }

            $stats = [
                'total' => count($devices),
                'current' => count(array_filter($devices, fn($d) => $d['is_current'])),
                'mobile' => count(array_filter($devices, fn($d) => $d['device_type'] === 'mobile')),
                'desktop' => count(array_filter($devices, fn($d) => $d['device_type'] === 'desktop')),
                'tablet' => count(array_filter($devices, fn($d) => $d['device_type'] === 'tablet'))
            ];

            echo json_encode([
                'success' => true,
                'devices' => $devices,
                'stats' => $stats
            ]);

        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'error' => 'Error al obtener dispositivos',
                'message' => $e->getMessage()
            ]);
        }
    }

    /**
     * Revocar un dispositivo específico y cerrar su sesión
     */
    public function revokeDevice() {
        try {
            $auth = Auth::verify();
            if (!$auth) {
                http_response_code(401);
                echo json_encode(['error' => 'No autorizado']);
                return;
            }

            $userId = $auth->id;
            $input = json_decode(file_get_contents('php://input'), true);
            $deviceId = $input['device_id'] ?? null;

            if (!$deviceId) {
                http_response_code(400);
                echo json_encode(['error' => 'ID de dispositivo requerido']);
                return;
            }

            $query = "SELECT id, refresh_token, device_name, device_type, browser, platform
                      FROM user_devices WHERE id = ? AND user_id = ?";
            $stmt = $this->db->prepare($query);
            $stmt->execute([$deviceId, $userId]);
            $device = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$device) {
                http_response_code(404);
                echo json_encode(['error' => 'Dispositivo no encontrado']);
                return;
            }

            $currentToken = $this->getBearerToken();
            if ($device['refresh_token'] === $currentToken) {
                http_response_code(400);
                echo json_encode(['error' => 'No puedes revocar el dispositivo actual']);
                return;
            }

            $query = "DELETE FROM user_devices WHERE id = ? AND user_id = ?";
            $stmt = $this->db->prepare($query);
            $stmt->execute([$deviceId, $userId]);

            if ($device['refresh_token']) {
                $query = "DELETE FROM jwt_tokens WHERE token = ?";
                $stmt = $this->db->prepare($query);
                $stmt->execute([$device['refresh_token']]);

                $decoded = JwtHandler::decode($device['refresh_token']);
                $expires_at = null;
                if ($decoded && isset($decoded->exp)) {
                    $expires_at = date('Y-m-d H:i:s', $decoded->exp);
                }
                Auth::addToBlacklist($device['refresh_token'], $expires_at);
            }

            $this->logDeviceRevocation($userId, $deviceId, $device['device_name']);

            echo json_encode([
                'success' => true,
                'message' => 'Dispositivo revocado exitosamente. La sesión se ha cerrado.',
                'device' => [
                    'id' => $deviceId,
                    'name' => $device['device_name'],
                    'type' => $device['device_type']
                ]
            ]);

        } catch (Exception $e) {
            error_log("Error en revokeDevice: " . $e->getMessage());
            http_response_code(500);
            echo json_encode(['error' => 'Error al revocar dispositivo: ' . $e->getMessage()]);
        }
    }

    /**
     * Cerrar sesiones anteriores y notificar al dispositivo
     */
    public function closeOtherSessions($userId, $currentToken, $userName, $userRole = 'user', $newDeviceId = null) {
        try {
            $query = "SELECT id, refresh_token, device_name, device_type, browser, platform
                      FROM user_devices
                      WHERE user_id = ? AND refresh_token != ? AND refresh_token IS NOT NULL";
            $stmt = $this->db->prepare($query);
            $stmt->execute([$userId, $currentToken]);
            $oldDevices = $stmt->fetchAll(PDO::FETCH_ASSOC);

            if (empty($oldDevices)) {
                return;
            }

            foreach ($oldDevices as $device) {
                // 🔥 CORRECCIÓN: Notificar al dispositivo viejo ANTES de marcarlo como inactivo
                $this->notifySessionClosed($userId, $device, $userRole, $newDeviceId);

                $query = "UPDATE user_devices SET is_current = 0 WHERE id = ? AND user_id = ?";
                $stmt = $this->db->prepare($query);
                $stmt->execute([$device['id'], $userId]);

                if ($device['refresh_token']) {
                    $decoded = JwtHandler::decode($device['refresh_token']);
                    $expires_at = null;
                    if ($decoded && isset($decoded->exp)) {
                        $expires_at = date('Y-m-d H:i:s', $decoded->exp);
                    }
                    Auth::addToBlacklist($device['refresh_token'], $expires_at);
                }
            }

            error_log("✅ {$userName}: " . count($oldDevices) . " sesiones anteriores cerradas");
        } catch (Exception $e) {
            error_log("Error en closeOtherSessions: " . $e->getMessage());
        }
    }

    /**
     * Notificar al dispositivo que su sesión será cerrada
     */
    private function notifySessionClosed($userId, $device, $userRole = 'user', $newDeviceId = null) {
        try {
            $systemModel = new System();
            $config = $systemModel->getConfig();
            $wsUrl = rtrim($config['ws_host'] ?? 'http://localhost:3001', '/');

            // 🔥 CORRECCIÓN: Incluir device_id y new_device_id correctamente
            $payload = [
                'event' => 'session_closed',
                'receiver_id' => $userId,
                'receiver_role' => $userRole,
                'device_id' => $device['id'],  // ID del dispositivo viejo que será cerrado
                'new_device_id' => $newDeviceId,  // ID del dispositivo nuevo
                'payload' => [
                    'title' => '🔒 Sesión cerrada',
                    'message' => 'Tu cuenta ha sido abierta en otro dispositivo. Esta sesión ha sido cerrada por seguridad.',
                    'device_name' => $device['device_name'] ?? 'Dispositivo desconocido',
                    'browser' => $device['browser'] ?? '',
                    'platform' => $device['platform'] ?? '',
                    'notification_type' => 'session_closed',
                    'timestamp' => date('c')
                ]
            ];

            $ch = curl_init($wsUrl . '/emit');
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
            curl_setopt($ch, CURLOPT_TIMEOUT, 3);
            curl_exec($ch);
            curl_close($ch);

            error_log("📡 Notificación de sesión cerrada enviada a usuario {$userId}, device_id: {$device['id']}, new_device_id: {$newDeviceId}");
        } catch (Exception $e) {
            error_log("Error notificando cierre de sesión: " . $e->getMessage());
        }
    }

    /**
     * Añadir token a lista negra para invalidación inmediata
     */
    private function addToBlacklist($token) {
        try {
            $createTable = "CREATE TABLE IF NOT EXISTS token_blacklist (
                id INT AUTO_INCREMENT PRIMARY KEY,
                token VARCHAR(512) NOT NULL,
                expires_at TIMESTAMP NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                revoked_by_ip VARCHAR(45),
                INDEX idx_token (token(255)),
                INDEX idx_expires (expires_at)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";

            $this->db->exec($createTable);
            $this->db->exec("DELETE FROM token_blacklist WHERE expires_at < NOW()");

            $decoded = JwtHandler::decode($token);
            $expires_at = null;
            if ($decoded && isset($decoded->exp)) {
                $expires_at = date('Y-m-d H:i:s', $decoded->exp);
            }

            $ipAddress = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '0.0.0.0';

            $query = "INSERT INTO token_blacklist (token, expires_at, revoked_by_ip) VALUES (?, ?, ?)";
            $stmt = $this->db->prepare($query);
            $stmt->execute([$token, $expires_at, $ipAddress]);

            error_log("Token añadido a blacklist: " . substr($token, 0, 20) . "...");

        } catch (Exception $e) {
            error_log("Error adding token to blacklist: " . $e->getMessage());
        }
    }

    /**
     * Registrar revocación para auditoría
     */
    private function logDeviceRevocation($userId, $deviceId, $deviceName) {
        try {
            $createTable = "CREATE TABLE IF NOT EXISTS device_revocation_log (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_id INT NOT NULL,
                device_id INT NOT NULL,
                device_name VARCHAR(255),
                revoked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                revoked_by_ip VARCHAR(45),
                revoked_by_user_id INT,
                INDEX idx_user (user_id),
                INDEX idx_revoked_at (revoked_at)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";

            $this->db->exec($createTable);

            $ipAddress = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '0.0.0.0';

            $query = "INSERT INTO device_revocation_log (user_id, device_id, device_name, revoked_by_ip, revoked_by_user_id)
                      VALUES (?, ?, ?, ?, ?)";
            $stmt = $this->db->prepare($query);
            $stmt->execute([$userId, $deviceId, $deviceName, $ipAddress, $userId]);

        } catch (Exception $e) {
            error_log("Error logging device revocation: " . $e->getMessage());
        }
    }

    /**
     * Verificar si un token está en blacklist (para usar en middleware)
     */
    public static function isTokenBlacklisted($token) {
        try {
            $db = (new Database())->getConnection();

            $db->exec("CREATE TABLE IF NOT EXISTS token_blacklist (
                id INT AUTO_INCREMENT PRIMARY KEY,
                token VARCHAR(512) NOT NULL,
                expires_at TIMESTAMP NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_token (token(255))
            )");

            $db->exec("DELETE FROM token_blacklist WHERE expires_at < NOW()");

            $query = "SELECT id FROM token_blacklist WHERE token = ?";
            $stmt = $db->prepare($query);
            $stmt->execute([$token]);

            $isBlacklisted = $stmt->rowCount() > 0;

            if ($isBlacklisted) {
                error_log("Token en blacklist detectado: " . substr($token, 0, 20) . "...");
            }

            return $isBlacklisted;

        } catch (Exception $e) {
            error_log("Error checking blacklist: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Revocar todos los dispositivos excepto el actual
     */
    public function revokeAllDevices() {
        try {
            $auth = Auth::verify();
            if (!$auth) {
                http_response_code(401);
                echo json_encode(['error' => 'No autorizado']);
                return;
            }

            $userId = $auth->id;
            $currentToken = $this->getBearerToken();

            $query = "SELECT id, refresh_token, device_name, device_type
                      FROM user_devices
                      WHERE user_id = ? AND refresh_token != ? AND refresh_token IS NOT NULL";
            $stmt = $this->db->prepare($query);
            $stmt->execute([$userId, $currentToken]);
            $devices = $stmt->fetchAll(PDO::FETCH_ASSOC);

            $revokedCount = 0;
            $revokedDevices = [];

            foreach ($devices as $device) {
                $query = "DELETE FROM user_devices WHERE id = ? AND user_id = ?";
                $stmt = $this->db->prepare($query);
                $stmt->execute([$device['id'], $userId]);

                if ($device['refresh_token']) {
                    $query = "DELETE FROM jwt_tokens WHERE token = ?";
                    $stmt = $this->db->prepare($query);
                    $stmt->execute([$device['refresh_token']]);

                    $decoded = JwtHandler::decode($device['refresh_token']);
                    $expires_at = null;
                    if ($decoded && isset($decoded->exp)) {
                        $expires_at = date('Y-m-d H:i:s', $decoded->exp);
                    }
                    Auth::addToBlacklist($device['refresh_token'], $expires_at);
                }

                $this->logDeviceRevocation($userId, $device['id'], $device['device_name']);

                $revokedCount++;
                $revokedDevices[] = [
                    'id' => $device['id'],
                    'name' => $device['device_name'],
                    'type' => $device['device_type']
                ];
            }

            echo json_encode([
                'success' => true,
                'message' => "Se revocaron {$revokedCount} dispositivos exitosamente",
                'revoked_count' => $revokedCount,
                'revoked_devices' => $revokedDevices
            ]);

        } catch (Exception $e) {
            error_log("Error en revokeAllDevices: " . $e->getMessage());
            http_response_code(500);
            echo json_encode(['error' => 'Error al revocar dispositivos: ' . $e->getMessage()]);
        }
    }

    /**
     * Registrar un nuevo dispositivo usando fingerprint
     */
    public function registerDevice($userId, $refreshToken, $sessionCleanupDone = false) {
        try {
            $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? 'Desconocido';
            $ipAddress = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '0.0.0.0';

            $fingerprintData = $userAgent . $ipAddress;
            if (isset($_SERVER['HTTP_ACCEPT_LANGUAGE'])) {
                $fingerprintData .= $_SERVER['HTTP_ACCEPT_LANGUAGE'];
            }
            if (isset($_SERVER['HTTP_ACCEPT_ENCODING'])) {
                $fingerprintData .= $_SERVER['HTTP_ACCEPT_ENCODING'];
            }
            $deviceFingerprint = md5($fingerprintData);

            $deviceInfo = $this->parseUserAgent($userAgent);

            if (!$sessionCleanupDone) {
                $multiStmt = $this->db->query("SELECT multiple_sessions FROM system_config WHERE id = 1");
                $multipleSessions = (int)($multiStmt->fetchColumn() ?: 0);

                if ($multipleSessions == 0) {
                    $stmt = $this->db->prepare("DELETE FROM user_devices WHERE user_id = ?");
                    $stmt->execute([$userId]);

                    $stmt = $this->db->prepare("DELETE FROM sessions WHERE user_id = ?");
                    $stmt->execute([$userId]);

                    error_log("✅ Todos los dispositivos y sesiones anteriores eliminados para usuario {$userId}");
                }
            } else {
                error_log("ℹ️ Limpieza de sesiones ya realizada en AuthController para usuario {$userId}");
            }

            $query = "INSERT INTO user_devices
                      (user_id, device_name, device_type, browser, platform,
                       device_fingerprint, ip_address, refresh_token, is_current)
                      VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1)";
            $stmt = $this->db->prepare($query);
            $stmt->execute([
                $userId,
                $deviceInfo['device_name'],
                $deviceInfo['device_type'],
                $deviceInfo['browser'],
                $deviceInfo['platform'],
                $deviceFingerprint,
                $ipAddress,
                $refreshToken
            ]);

            $deviceId = $this->db->lastInsertId();
            error_log("Nuevo dispositivo creado con ID: " . $deviceId);

            $sessionId = bin2hex(random_bytes(32));
            $stmt = $this->db->prepare("
                INSERT INTO sessions (id, user_id, ip_address, user_agent, payload, last_activity)
                VALUES (?, ?, ?, ?, ?, UNIX_TIMESTAMP())
            ");
            $stmt->execute([
                $sessionId,
                $userId,
                $ipAddress,
                $userAgent,
                json_encode(['refresh_token' => $refreshToken])
            ]);

            // 🔥 CORRECCIÓN: Retornar el ID del dispositivo
            return $deviceId;

        } catch (Exception $e) {
            error_log("ERROR CRÍTICO en registerDevice: " . $e->getMessage());
            error_log("Stack trace: " . $e->getTraceAsString());
            return null;
        }
    }

    /**
     * Parsear User Agent para obtener información del dispositivo
     */
    private function parseUserAgent($userAgent) {
        $userAgent = strtolower($userAgent);

        $deviceType = 'desktop';
        $isMobile = preg_match('/(android|iphone|ipod|blackberry|windows phone|opera mini|iemobile|mobile)/i', $userAgent);
        $isTablet = preg_match('/(ipad|tablet|kindle|silk)/i', $userAgent);

        if ($isTablet) {
            $deviceType = 'tablet';
        } elseif ($isMobile) {
            $deviceType = 'mobile';
        }

        $platform = 'Desconocido';
        if (strpos($userAgent, 'windows') !== false) {
            $platform = 'Windows';
        } elseif (strpos($userAgent, 'mac') !== false) {
            $platform = 'macOS';
        } elseif (strpos($userAgent, 'linux') !== false) {
            if (strpos($userAgent, 'android') !== false) {
                $platform = 'Android';
            } else {
                $platform = 'Linux';
            }
        } elseif (strpos($userAgent, 'android') !== false) {
            $platform = 'Android';
        } elseif (strpos($userAgent, 'iphone') !== false || strpos($userAgent, 'ipod') !== false) {
            $platform = 'iOS';
        } elseif (strpos($userAgent, 'ipad') !== false) {
            $platform = 'iPadOS';
        }

        $browser = 'Desconocido';
        if (strpos($userAgent, 'edg') !== false || strpos($userAgent, 'edge') !== false) {
            $browser = 'Edge';
        } elseif (strpos($userAgent, 'opr') !== false || strpos($userAgent, 'opera') !== false) {
            $browser = 'Opera';
        } elseif (strpos($userAgent, 'chrome') !== false && strpos($userAgent, 'edg') === false) {
            $browser = 'Chrome';
        } elseif (strpos($userAgent, 'firefox') !== false) {
            $browser = 'Firefox';
        } elseif (strpos($userAgent, 'safari') !== false && strpos($userAgent, 'chrome') === false) {
            $browser = 'Safari';
        }

        $deviceModel = $this->detectDeviceModel($userAgent);

        if ($deviceType === 'mobile') {
            $deviceName = '📱 ' . ($deviceModel ?: $platform) . ' - ' . $browser;
        } elseif ($deviceType === 'tablet') {
            $deviceName = '📟 ' . ($deviceModel ?: $platform) . ' - ' . $browser;
        } else {
            $deviceName = '💻 ' . $platform . ' - ' . $browser;
        }

        return [
            'device_name' => $deviceName,
            'device_type' => $deviceType,
            'browser' => $browser,
            'platform' => $platform,
            'model' => $deviceModel
        ];
    }

    /**
     * Detectar modelo específico del dispositivo
     */
    private function detectDeviceModel($userAgent) {
        $models = [
            'redmi' => 'Xiaomi Redmi',
            'mi ' => 'Xiaomi',
            'iphone' => 'iPhone',
            'ipad' => 'iPad',
            'samsung' => 'Samsung',
            'galaxy' => 'Samsung Galaxy',
            'huawei' => 'Huawei',
            'pixel' => 'Google Pixel',
            'oneplus' => 'OnePlus',
            'motorola' => 'Motorola',
            'lg ' => 'LG',
            'sony' => 'Sony'
        ];

        foreach ($models as $key => $name) {
            if (strpos($userAgent, $key) !== false) {
                return $name;
            }
        }

        return null;
    }

    /**
     * Formatear nombre del dispositivo para mostrar
     */
    private function formatDeviceName($device) {
        $icons = [
            'mobile' => '📱',
            'tablet' => '📟',
            'desktop' => '💻',
            'unknown' => '❓'
        ];

        $icon = $icons[$device['device_type']] ?? $icons['unknown'];

        if (!empty($device['model'])) {
            return $icon . ' ' . $device['model'] . ' - ' . $device['browser'];
        }

        return $icon . ' ' . $device['platform'] . ' - ' . $device['browser'];
    }

    /**
     * Formatear tiempo desde última actividad
     */
    private function timeAgo($datetime) {
        if (!$datetime) {
            return 'Desconocido';
        }

        $time = strtotime($datetime);
        if (!$time) {
            return 'Fecha inválida';
        }

        $now = time();
        $diff = $now - $time;

        if ($diff < 60) {
            return 'justo ahora';
        } elseif ($diff < 3600) {
            $mins = floor($diff / 60);
            return "hace $mins min" . ($mins > 1 ? 's' : '');
        } elseif ($diff < 86400) {
            $hours = floor($diff / 3600);
            return "hace $hours hora" . ($hours > 1 ? 's' : '');
        } elseif ($diff < 2592000) {
            $days = floor($diff / 86400);
            return "hace $days día" . ($days > 1 ? 's' : '');
        } else {
            return date('d/m/Y H:i', $time);
        }
    }

    /**
     * Obtener token del header Authorization
     */
    private function getBearerToken() {
        $headers = getallheaders();
        $auth = $headers['Authorization'] ?? '';

        if (preg_match('/Bearer\s(\S+)/', $auth, $matches)) {
            return $matches[1];
        }
        return null;
    }

    /**
     * Obtener ubicación aproximada por IP
     */
    private function getLocationFromIp($ip) {
        if ($ip === '::1' || $ip === '127.0.0.1' || strpos($ip, '192.168.') === 0) {
            return 'Red local';
        }

        $ch = curl_init("http://ip-api.com/json/{$ip}");
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, 2);
        $response = curl_exec($ch);
        curl_close($ch);

        if ($response) {
            $data = json_decode($response, true);
            if ($data && $data['status'] === 'success') {
                return $data['city'] . ', ' . $data['country'];
            }
        }

        return 'Ubicación desconocida';
    }

    public function getProvider($id) {
        $auth = Auth::verify();
        if (!$auth) {
            http_response_code(401);
            echo json_encode(["error" => "No autorizado"]);
            return;
        }

        $user = $this->userModel->findById($id);
        if (!$user || $user['role'] !== 'provider') {
            http_response_code(404);
            echo json_encode(["error" => "Proveedor no encontrado"]);
            return;
        }

        header('Content-Type: application/json');
        echo json_encode(['provider' => $user]);
    }

    public function getMyEarnings(): void {
        header("Content-Type: application/json; charset=UTF-8");

        try {
            $auth = Auth::verify();
            if (!$auth) {
                http_response_code(401);
                echo json_encode(["error" => "No autorizado"]);
                return;
            }

            $userId = $auth->id;

            $stmt = $this->db->prepare("
                SELECT
                    COALESCE(SUM(sh.service_price), 0) as total_earned,
                    COALESCE(SUM(CASE WHEN sh.payment_status = 'paid' THEN sh.service_price ELSE 0 END), 0) as total_paid,
                    COALESCE(SUM(CASE WHEN sh.payment_status IN ('pending','verifying') THEN sh.service_price ELSE 0 END), 0) as total_pending,
                    COUNT(sh.id) as total_services
                FROM service_history sh
                WHERE sh.provider_id = :uid AND sh.status = 'completed'
            ");
            $stmt->execute(['uid' => $userId]);
            $summary = $stmt->fetch(PDO::FETCH_ASSOC);

            $page = isset($_GET['page']) ? max(1, (int)$_GET['page']) : 1;
            $limit = 20;
            $offset = ($page - 1) * $limit;

            $stmt2 = $this->db->prepare("
                SELECT sh.id, sh.service_id, sh.service_title as service_name,
                       sh.service_price as amount, sh.payment_status as status, sh.finished_at as created_at
                FROM service_history sh
                WHERE sh.provider_id = :uid AND sh.status = 'completed'
                ORDER BY sh.finished_at DESC
                LIMIT :limit OFFSET :offset
            ");
            $stmt2->bindValue(':uid', $userId, PDO::PARAM_INT);
            $stmt2->bindValue(':limit', $limit, PDO::PARAM_INT);
            $stmt2->bindValue(':offset', $offset, PDO::PARAM_INT);
            $stmt2->execute();
            $transactions = $stmt2->fetchAll(PDO::FETCH_ASSOC);

            echo json_encode([
                'success' => true,
                'summary' => $summary,
                'transactions' => $transactions,
                'page' => $page,
                'limit' => $limit,
                'total' => (int)$summary['total_services']
            ]);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => $e->getMessage()]);
        }
    }
}
