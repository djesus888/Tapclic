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
        return $decoded;
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
