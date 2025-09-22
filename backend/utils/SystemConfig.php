<?php
require_once __DIR__ . '/../config/database.php';   // ← esto faltaba

class SystemConfig
{
    private static ?array $cache = null;            // ← nullable explícito

    public static function get(?string $key = null, $default = null) // ← nullable
    {
        if (self::$cache === null) {
            $db = (new Database())->getConnection();
            $row = $db->query("SELECT * FROM system_config WHERE id = 1")->fetch(PDO::FETCH_ASSOC);
            $row['extra_json'] = json_decode($row['extra_json'] ?? '{}', true);
            self::$cache = $row;
        }
        return $key === null ? self::$cache : (self::$cache['extra_json'][$key] ?? $default);
    }
}

