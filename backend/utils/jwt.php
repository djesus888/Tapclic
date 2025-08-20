<?php
// utils/jwt.php

require_once __DIR__ . '/../vendor/autoload.php';
use Firebase\JWT\JWT;
use Firebase\JWT\Key;

class JwtHandler {
    private static $secret_key = "clave_secreta_tapclic";

    public static function encode($payload) {
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
