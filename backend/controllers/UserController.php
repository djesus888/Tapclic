<?php
require_once __DIR__ . "/../middleware/Auth.php";
// controllers/UserController.php

require_once __DIR__ . '/../models/User.php';
require_once __DIR__ . '/../utils/jwt.php';
require_once __DIR__ . '/../utils/AuditLogger.php';

class UserController {
    private $userModel;
    private $db;

    public function __construct() {
        $this->userModel = new User();
        // Obtener conexión a la base de datos del modelo
        $this->db = $this->userModel->getDb();
    }

    private function isValidEmail($email) {
        return filter_var($email, FILTER_VALIDATE_EMAIL) !== false;
    }

    private function isValidPhone($phone) {
        // Puedes ajustar la expresión según formato que quieras permitir
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
                $uploadDir = __DIR__ . '/../public/uploads/avatars/';
                if (!is_dir($uploadDir)) {
                    mkdir($uploadDir, 0755, true);
                }

                $tmpName = $_FILES['avatar']['tmp_name'];
                $originalName = $_FILES['avatar']['name'];
                $ext = pathinfo($originalName, PATHINFO_EXTENSION);
                $fileName = 'avatar_' . time() . '.' . $ext;
                $destination = $uploadDir . $fileName;

                if (move_uploaded_file($tmpName, $destination)) {
                    $avatarFileName = $fileName;
                } else {
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
            'coverage_area' => $coverage_area
        ]);

        if ($avatarFileName) {
            $this->userModel->updateAvatar($auth->id, $avatarFileName);
        }

        if ($ok) {
    // ✅ LOG
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
      // ✅ LOG
      if ($ok) AuditLogger::log($auth->id, 'password_changed', 'Contraseña cambiada', 'El usuario cambió su contraseña');
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
// ✅ LOG
if ($ok) AuditLogger::log($auth->id, 'avatar_updated', 'Avatar actualizado', 'El usuario cambió su foto de perfil');
echo json_encode(["success" => $ok]);
    }

    public function updateProviderData() {
        $auth = Auth::verify();
        if (!$auth || $auth->role !== 'driver') return $this->unauthorized();

        $data = json_decode(file_get_contents("php://input"), true);
        $ok = $this->userModel->updateProviderData($auth->id, $data);
        echo json_encode(["success" => $ok]);
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

        // Obtener todos los dispositivos del usuario
        $query = "SELECT id, device_name, device_type, browser, platform,
                         ip_address, location, last_active, device_fingerprint,
                         CASE WHEN refresh_token = ? THEN 1 ELSE 0 END as is_current
                  FROM user_devices
                  WHERE user_id = ?
                  ORDER BY is_current DESC, last_active DESC";

        $stmt = $this->db->prepare($query);
        $stmt->execute([$currentToken, $userId]);
        $devices = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // Formatear la información para el frontend
        foreach ($devices as &$device) {
            // Guardar fecha original
            $device['last_active_raw'] = $device['last_active'];
            
            // Formatear tiempo relativo
            $device['last_active'] = $this->timeAgo($device['last_active']);
            
            // Formato ISO para el frontend
            $device['last_active_iso'] = date('c', strtotime($device['last_active_raw']));
            
            // Nombre amigable del dispositivo
            $device['name'] = $this->formatDeviceName($device);
            
            // Obtener ubicación si no existe
            if (empty($device['location'])) {
                $device['location'] = $this->getLocationFromIp($device['ip_address']);
            }
            
            // Determinar si es el dispositivo actual
            $device['is_current'] = (bool)$device['is_current'];
            
            // Agregar información adicional útil
            $device['device_info'] = [
                'browser' => $device['browser'],
                'platform' => $device['platform'],
                'type' => $device['device_type']
            ];
        }

        // Estadísticas de dispositivos
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

        // Verificar que el dispositivo pertenece al usuario y obtener más información
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

        // No permitir revocar el dispositivo actual
        $currentToken = $this->getBearerToken();
        if ($device['refresh_token'] === $currentToken) {
            http_response_code(400);
            echo json_encode(['error' => 'No puedes revocar el dispositivo actual']);
            return;
        }

        // 1. Eliminar de user_devices
        $query = "DELETE FROM user_devices WHERE id = ? AND user_id = ?";
        $stmt = $this->db->prepare($query);
        $stmt->execute([$deviceId, $userId]);

        // 2. Invalidar el refresh token en jwt_tokens
        if ($device['refresh_token']) {
            $query = "DELETE FROM jwt_tokens WHERE token = ?";
            $stmt = $this->db->prepare($query);
            $stmt->execute([$device['refresh_token']]);

            // 3. Añadir token a blacklist para invalidación inmediata
            // CAMBIO IMPORTANTE: Usar el método estático de Auth
            $decoded = JwtHandler::decode($device['refresh_token']);
            $expires_at = null;
            if ($decoded && isset($decoded->exp)) {
                $expires_at = date('Y-m-d H:i:s', $decoded->exp);
            }
            Auth::addToBlacklist($device['refresh_token'], $expires_at);
        }

        // 4. Registrar la revocación para auditoría
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
 * Añadir token a lista negra para invalidación inmediata
 */
private function addToBlacklist($token) {
    try {
        // Crear tabla de blacklist si no existe
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

        // Limpiar tokens expirados automáticamente
        $this->db->exec("DELETE FROM token_blacklist WHERE expires_at < NOW()");

        // Decodificar token para obtener expiración
        $decoded = JwtHandler::decode($token);
        $expires_at = null;
        
        if ($decoded && isset($decoded->exp)) {
            $expires_at = date('Y-m-d H:i:s', $decoded->exp);
        }

        // Obtener IP que realizó la revocación
        $ipAddress = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '0.0.0.0';

        // Insertar en blacklist
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
        // Crear tabla de log si no existe
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
        
        // Asegurar que la tabla existe
        $db->exec("CREATE TABLE IF NOT EXISTS token_blacklist (
            id INT AUTO_INCREMENT PRIMARY KEY,
            token VARCHAR(512) NOT NULL,
            expires_at TIMESTAMP NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_token (token(255))
        )");
        
        // Limpiar tokens expirados
        $db->exec("DELETE FROM token_blacklist WHERE expires_at < NOW()");
        
        // Verificar si token está en blacklist
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
        return false; // Por seguridad, si hay error, permitimos la petición
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

        // Obtener todos los dispositivos excepto el actual
        $query = "SELECT id, refresh_token, device_name, device_type 
                  FROM user_devices 
                  WHERE user_id = ? AND refresh_token != ? AND refresh_token IS NOT NULL";
        $stmt = $this->db->prepare($query);
        $stmt->execute([$userId, $currentToken]);
        $devices = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        $revokedCount = 0;
        $revokedDevices = [];

        // Para cada dispositivo, eliminar y añadir a blacklist
        foreach ($devices as $device) {
            
            // 1. Eliminar de user_devices
            $query = "DELETE FROM user_devices WHERE id = ? AND user_id = ?";
            $stmt = $this->db->prepare($query);
            $stmt->execute([$device['id'], $userId]);
            
            // 2. Eliminar de jwt_tokens y añadir a blacklist
            if ($device['refresh_token']) {
                $query = "DELETE FROM jwt_tokens WHERE token = ?";
                $stmt = $this->db->prepare($query);
                $stmt->execute([$device['refresh_token']]);
                
                // 3. Añadir a blacklist
                $decoded = JwtHandler::decode($device['refresh_token']);
                $expires_at = null;
                if ($decoded && isset($decoded->exp)) {
                    $expires_at = date('Y-m-d H:i:s', $decoded->exp);
                }
                Auth::addToBlacklist($device['refresh_token'], $expires_at);
            }
            
            // 4. Registrar en log
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
public function registerDevice($userId, $refreshToken) {
    try {
        $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? 'Desconocido';
        $ipAddress = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '0.0.0.0';
        
        // Generar fingerprint único del dispositivo
        $fingerprintData = $userAgent . $ipAddress;
        // Incluir headers adicionales si existen para mejor precisión
        if (isset($_SERVER['HTTP_ACCEPT_LANGUAGE'])) {
            $fingerprintData .= $_SERVER['HTTP_ACCEPT_LANGUAGE'];
        }
        if (isset($_SERVER['HTTP_ACCEPT_ENCODING'])) {
            $fingerprintData .= $_SERVER['HTTP_ACCEPT_ENCODING'];
        }
        
        $deviceFingerprint = md5($fingerprintData);
        
        // Detectar información del dispositivo
        $deviceInfo = $this->parseUserAgent($userAgent);
        
        // Log para depuración
        error_log("=== REGISTER DEVICE FINGERPRINT ===");
        error_log("UserID: " . $userId);
        error_log("Fingerprint: " . $deviceFingerprint);
        error_log("IP: " . $ipAddress);
        
        // Buscar por fingerprint primero (más preciso)
        $query = "SELECT id FROM user_devices 
                  WHERE user_id = ? AND device_fingerprint = ?";
        $stmt = $this->db->prepare($query);
        $stmt->execute([$userId, $deviceFingerprint]);
        $existing = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($existing) {
            // Mismo dispositivo - actualizar
            error_log("Dispositivo existente encontrado por fingerprint. Actualizando ID: " . $existing['id']);
            
            $query = "UPDATE user_devices 
                      SET last_active = NOW(), 
                          ip_address = ?, 
                          refresh_token = ?, 
                          is_current = 1,
                          device_name = ?,
                          browser = ?,
                          platform = ?,
                          device_type = ?
                      WHERE id = ?";
            $stmt = $this->db->prepare($query);
            $stmt->execute([
                $ipAddress,
                $refreshToken,
                $deviceInfo['device_name'],
                $deviceInfo['browser'],
                $deviceInfo['platform'],
                $deviceInfo['device_type'],
                $existing['id']
            ]);
        } else {
            // Buscar por combinación de IP y UserAgent como respaldo
            $query = "SELECT id FROM user_devices 
                      WHERE user_id = ? AND ip_address = ? AND device_name = ?";
            $stmt = $this->db->prepare($query);
            $stmt->execute([$userId, $ipAddress, $deviceInfo['device_name']]);
            $existing = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if ($existing) {
                // Mismo dispositivo detectado por IP/Name - actualizar y agregar fingerprint
                error_log("Dispositivo existente encontrado por IP/Name. Actualizando ID: " . $existing['id']);
                
                $query = "UPDATE user_devices 
                          SET last_active = NOW(),
                              refresh_token = ?,
                              is_current = 1,
                              device_fingerprint = ?,
                              browser = ?,
                              platform = ?,
                              device_type = ?
                          WHERE id = ?";
                $stmt = $this->db->prepare($query);
                $stmt->execute([
                    $refreshToken,
                    $deviceFingerprint,
                    $deviceInfo['browser'],
                    $deviceInfo['platform'],
                    $deviceInfo['device_type'],
                    $existing['id']
                ]);
            } else {
                // Nuevo dispositivo - crear registro
                error_log("Nuevo dispositivo detectado. Creando registro...");
                
                // Limitar número de dispositivos (ej: máximo 10)
                $query = "SELECT COUNT(*) as count FROM user_devices WHERE user_id = ?";
                $stmt = $this->db->prepare($query);
                $stmt->execute([$userId]);
                $count = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
                
                if ($count >= 10) {
                    // Eliminar el dispositivo más antiguo (no actual)
                    $query = "DELETE FROM user_devices 
                              WHERE user_id = ? AND is_current = 0 
                              ORDER BY last_active ASC LIMIT 1";
                    $stmt = $this->db->prepare($query);
                    $stmt->execute([$userId]);
                }
                
                // Insertar nuevo dispositivo
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
                
                error_log("Nuevo dispositivo creado con ID: " . $this->db->lastInsertId());
            }
        }
        
        // Marcar este dispositivo como actual y los demás como no actuales
        $query = "UPDATE user_devices SET is_current = 0 
                  WHERE user_id = ? AND refresh_token != ?";
        $stmt = $this->db->prepare($query);
        $stmt->execute([$userId, $refreshToken]);
        
        error_log("=== FIN REGISTER DEVICE ===\n");
        
    } catch (Exception $e) {
        error_log("ERROR CRÍTICO en registerDevice: " . $e->getMessage());
        error_log("Stack trace: " . $e->getTraceAsString());
    }
}

/**
 * Parsear User Agent para obtener información del dispositivo (VERSIÓN MEJORADA)
 */
private function parseUserAgent($userAgent) {
    $userAgent = strtolower($userAgent);
    
    // Detectar tipo de dispositivo (MEJORADO)
    $deviceType = 'desktop';
    $isMobile = preg_match('/(android|iphone|ipod|blackberry|windows phone|opera mini|iemobile|mobile)/i', $userAgent);
    $isTablet = preg_match('/(ipad|tablet|kindle|silk)/i', $userAgent);
    
    if ($isTablet) {
        $deviceType = 'tablet';
    } elseif ($isMobile) {
        $deviceType = 'mobile';
    }
    
    // Detectar sistema operativo (MEJORADO)
    $platform = 'Desconocido';
    if (strpos($userAgent, 'windows') !== false) {
        $platform = 'Windows';
    } elseif (strpos($userAgent, 'mac') !== false) {
        $platform = 'macOS';
    } elseif (strpos($userAgent, 'linux') !== false) {
        // Verificar si es Android (también basado en Linux)
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
    
    // Detectar navegador (MEJORADO)
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
    
    // Detectar modelo del dispositivo (NUEVO)
    $deviceModel = $this->detectDeviceModel($userAgent);
    
    // Crear nombre amigable del dispositivo (MEJORADO)
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
 * Detectar modelo específico del dispositivo (NUEVO)
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
 * Formatear nombre del dispositivo para mostrar (VERSIÓN MEJORADA)
 */
private function formatDeviceName($device) {
    $icons = [
        'mobile' => '📱',
        'tablet' => '📟',
        'desktop' => '💻',
        'unknown' => '❓'
    ];
    
    $icon = $icons[$device['device_type']] ?? $icons['unknown'];
    
    // Si tenemos modelo, usarlo
    if (!empty($device['model'])) {
        return $icon . ' ' . $device['model'] . ' - ' . $device['browser'];
    }
    
    return $icon . ' ' . $device['platform'] . ' - ' . $device['browser'];
}

      /**
 * Formatear tiempo desde última actividad (VERSIÓN MEJORADA)
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
    // Si es IP local
    if ($ip === '::1' || $ip === '127.0.0.1' || strpos($ip, '192.168.') === 0) {
        return 'Red local';
    }
    
    // Usar API gratuita de geolocalización (ej: ip-api.com)
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
}
