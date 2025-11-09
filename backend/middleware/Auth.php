<?php
require_once __DIR__ . '/../utils/jwt.php';

class Auth {
    public static function verify(): ?object
    {
        $headers = getallheaders();

        $auth = $headers['Authorization']
            ?? $headers['authorization']
            ?? $_SERVER['HTTP_AUTHORIZATION']
            ?? $_SERVER['REDIRECT_HTTP_AUTHORIZATION']
            ?? '';

        if (!str_starts_with($auth, 'Bearer ')) {
            return null;
        }

        $token = trim(str_replace('Bearer ', '', $auth));
        $decoded = JwtHandler::decode($token);

        if (!$decoded) {
            error_log("JWT inválido o expirado");
            return null;
        }

        return $decoded;
    }
}
