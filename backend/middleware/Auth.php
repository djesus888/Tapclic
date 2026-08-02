<?php
require_once __DIR__ . '/../utils/jwt.php';
require_once __DIR__ . '/../config/database.php';

class Auth {
    public static function verify(): ?object
    {
        $headers = function_exists('getallheaders') ? getallheaders() : [];

        if (empty($headers) && function_exists('apache_request_headers')) {
            $headers = apache_request_headers();
        }

        error_log("Auth::verify() - Headers completos: " . json_encode($headers));

        $auth = '';

        foreach ($headers as $key => $value) {
            if (strtolower($key) === 'authorization') {
                $auth = $value;
                error_log("Token encontrado en header: $key = $value");
                break;
            }
        }

        if (empty($auth)) {
            $serverKeys = [
                'HTTP_AUTHORIZATION',
                'REDIRECT_HTTP_AUTHORIZATION',
                'Authorization',
                'REDIRECT_Authorization'
            ];

            foreach ($serverKeys as $key) {
                if (!empty($_SERVER[$key])) {
                    $auth = $_SERVER[$key];
                    error_log("Token encontrado en \$_SERVER[$key] = $auth");
                    break;
                }
            }
        }

        error_log("Auth header final: " . $auth);

        if (empty($auth)) {
            error_log("No se encontró header de autorización");
            return null;
        }

        if (strpos($auth, 'Bearer ') === 0) {
            $token = substr($auth, 7);
        } elseif (strpos($auth, 'bearer ') === 0) {
            $token = substr($auth, 7);
        } else {
            $token = $auth;
        }

        error_log("Token extraído: " . substr($token, 0, 20) . "...");

        if (self::isTokenBlacklisted($token)) {
            error_log("Token revocado detectado: " . substr($token, 0, 20) . "...");
            return null;
        }

        $decoded = JwtHandler::decode($token);

        if (!$decoded) {
            error_log("JWT inválido o expirado");
            return null;
        }

        error_log("Token decodificado exitosamente: " . json_encode($decoded));

        // ✅ Verificar que la sesión y dispositivo sean válidos
        $sessionCheck = self::isSessionValid($decoded, $token);
        if (!$sessionCheck['valid']) {
            error_log("Sesión o dispositivo no válido para usuario ID: " . ($decoded->id ?? 'desconocido') . " - Razón: " . $sessionCheck['reason']);
            
            // ✅ Establecer header con el motivo del rechazo
            header('X-Session-Rejected: ' . $sessionCheck['reason']);
            
            return null;
        }

    // ✅ Verificar inactividad (session_timeout_minutes configurable)
$db = (new Database())->getConnection();
$stmt = $db->query("SELECT system_active, maintenance_mode, session_timeout_enabled, session_timeout_minutes FROM system_config WHERE id = 1");
$config = $stmt->fetch(PDO::FETCH_ASSOC);
$userRole = $decoded->role ?? '';

// Verificar timeout de sesión por inactividad (solo si está activado)
$timeoutEnabled = (int)($config['session_timeout_enabled'] ?? 1);
$timeoutMinutes = (int)($config['session_timeout_minutes'] ?? 30);
if ($timeoutEnabled && $timeoutMinutes > 0 && isset($decoded->iat)) {
    $elapsedMinutes = (time() - $decoded->iat) / 60;
    if ($elapsedMinutes > $timeoutMinutes) {
        error_log("Sesión expirada por inactividad: {$elapsedMinutes} min (límite: {$timeoutMinutes})");
        return null;
    }
}

        // Sistema inactivo - solo admin puede acceder
        if ($config && $config['system_active'] == 0) {
            if ($userRole !== 'admin' && $userRole !== 'super_admin') {
                error_log("Acceso denegado - Sistema inactivo. Rol: {$userRole}");
                return null;
            }
            error_log("Acceso permitido - Sistema inactivo. Admin: {$userRole}");
        }

        // Modo mantenimiento - solo admin puede acceder
        if ($config && $config['maintenance_mode'] == 1) {
            if ($userRole !== 'admin' && $userRole !== 'super_admin') {
                error_log("Acceso denegado - Modo mantenimiento activo. Rol: {$userRole}");
                return null;
            }
            error_log("Acceso permitido en mantenimiento - Rol admin: {$userRole}");
        }

        return $decoded;
    }

    // ✅ MODIFICADO: Ahora retorna array con ['valid' => bool, 'reason' => string]
    private static function isSessionValid($decoded, $token): array
    {
        try {
            $db = (new Database())->getConnection();
            $userId = $decoded->id ?? null;

            if (!$userId) {
                error_log("isSessionValid: No se encontró ID de usuario en el token");
                return ['valid' => false, 'reason' => 'invalid_token'];
            }

            // Verificar configuración de sesiones múltiples
            $stmt = $db->query("SELECT multiple_sessions FROM system_config WHERE id = 1");
            $multipleSessions = (int)($stmt->fetchColumn() ?: 0);

            // Buscar el dispositivo asociado a este token
            $stmt = $db->prepare("SELECT id, is_current FROM user_devices WHERE user_id = ? AND refresh_token = ?");
            $stmt->execute([$userId, $token]);
            $device = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$device) {
                error_log("isSessionValid: Dispositivo no encontrado para usuario {$userId} con este token");
                return ['valid' => false, 'reason' => 'device_not_found'];
            }

            // Si sesiones múltiples están desactivadas, verificar que sea el dispositivo actual
            if ($multipleSessions == 0 && $device['is_current'] == 0) {
                error_log("isSessionValid: Dispositivo ID {$device['id']} no es el actual (multiple_sessions = 0)");
                // ✅ ESTA ES LA RAZÓN CLAVE: Sesión reemplazada por otro dispositivo
                return ['valid' => false, 'reason' => 'session_replaced'];
            }

            // Verificar que exista al menos una sesión activa en la tabla sessions
            $stmt = $db->prepare("SELECT id FROM sessions WHERE user_id = ? ORDER BY last_activity DESC LIMIT 1");
            $stmt->execute([$userId]);
            $session = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$session) {
                error_log("isSessionValid: No hay sesiones activas para usuario {$userId}");
                return ['valid' => false, 'reason' => 'no_active_session'];
            }

            // Actualizar última actividad de la sesión
            $stmt = $db->prepare("UPDATE sessions SET last_activity = UNIX_TIMESTAMP() WHERE id = ?");
            $stmt->execute([$session['id']]);

            error_log("isSessionValid: Sesión válida para usuario {$userId}, dispositivo ID: {$device['id']}");
            return ['valid' => true, 'reason' => 'ok'];

        } catch (Exception $e) {
            error_log("Error en isSessionValid: " . $e->getMessage());
            // En caso de error de base de datos, permitir acceso para no bloquear el sistema
            return ['valid' => true, 'reason' => 'error_failsafe'];
        }
    }

    private static function isTokenBlacklisted($token): bool
    {
        try {
            $db = (new Database())->getConnection();

            $db->exec("CREATE TABLE IF NOT EXISTS token_blacklist (
                id INT AUTO_INCREMENT PRIMARY KEY,
                token VARCHAR(512) NOT NULL,
                expires_at TIMESTAMP NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                revoked_by_ip VARCHAR(45),
                INDEX idx_token (token(255)),
                INDEX idx_expires (expires_at)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");

            $db->exec("DELETE FROM token_blacklist WHERE expires_at < NOW()");

            $query = "SELECT id FROM token_blacklist WHERE token = ?";
            $stmt = $db->prepare($query);
            $stmt->execute([$token]);

            $inBlacklist = $stmt->rowCount() > 0;
            error_log("Token in blacklist: " . ($inBlacklist ? 'YES' : 'NO'));

            return $inBlacklist;

        } catch (Exception $e) {
            error_log("Error verificando blacklist: " . $e->getMessage());
            return false;
        }
    }

    public static function addToBlacklist($token, $expires_at = null): bool
    {
        try {
            $db = (new Database())->getConnection();

            $db->exec("CREATE TABLE IF NOT EXISTS token_blacklist (
                id INT AUTO_INCREMENT PRIMARY KEY,
                token VARCHAR(512) NOT NULL,
                expires_at TIMESTAMP NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                revoked_by_ip VARCHAR(45),
                INDEX idx_token (token(255)),
                INDEX idx_expires (expires_at)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");

            $ipAddress = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '0.0.0.0';

            $query = "INSERT INTO token_blacklist (token, expires_at, revoked_by_ip) VALUES (?, ?, ?)";
            $stmt = $db->prepare($query);
            $result = $stmt->execute([$token, $expires_at, $ipAddress]);

            if ($result) {
                error_log("Token añadido a blacklist: " . substr($token, 0, 20) . "...");
            }

            return $result;

        } catch (Exception $e) {
            error_log("Error añadiendo token a blacklist: " . $e->getMessage());
            return false;
        }
    }

    public static function cleanExpiredTokens(): int
    {
        try {
            $db = (new Database())->getConnection();
            $stmt = $db->exec("DELETE FROM token_blacklist WHERE expires_at < NOW()");
            return $stmt;
        } catch (Exception $e) {
            error_log("Error limpiando tokens expirados: " . $e->getMessage());
            return 0;
        }
    }
}
