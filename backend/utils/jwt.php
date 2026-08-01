<?php
// utils/jwt.php

require_once __DIR__ . '/../vendor/autoload.php';
use Firebase\JWT\JWT;
use Firebase\JWT\Key;

class JwtHandler {
    private static $secret_key = "T4pCl1c_2026_S3cur3_K3y_DvjA_25_30_No_1987";

   public static function encode($payload) {
    if (!isset($payload['iat'])) {
        $payload['iat'] = time();
    }
    return JWT::encode($payload, self::$secret_key, 'HS256');
}

    public static function decode($token) {
        try {
            return JWT::decode($token, new Key(self::$secret_key, 'HS256'));
        } catch (Exception $e) {
            return null;
        }
    }
}
