<?php

class Encryption
{
    private static string $key;
    private static string $cipher = 'aes-256-cbc';

    private static function getKey(): string
    {
        if (isset(self::$key)) return self::$key;

        // Obtener clave desde .env o usar una por defecto
        $envFile = __DIR__ . '/../.env';
        $key = '';

        if (file_exists($envFile)) {
            $lines = file($envFile, FILE_IGNORE_NEW_LINES);
            foreach ($lines as $line) {
                if (str_starts_with($line, 'ENCRYPTION_KEY=')) {
                    $key = trim(explode('=', $line, 2)[1]);
                    break;
                }
            }
        }

        if (empty($key)) {
            // Clave por defecto (CAMBIAR EN PRODUCCIÓN)
            $key = 'TapClic_Security_Key_2026_Change_Me!';
        }

        // Asegurar que la clave tenga 32 bytes para AES-256
        self::$key = hash('sha256', $key, true);
        return self::$key;
    }

    public static function encrypt(?string $data): ?string
    {
        if (empty($data)) return null;

        $iv = openssl_random_pseudo_bytes(openssl_cipher_iv_length(self::$cipher));
        $encrypted = openssl_encrypt($data, self::$cipher, self::getKey(), 0, $iv);
        return base64_encode($iv . $encrypted);
    }

    public static function decrypt(?string $encryptedData): ?string
    {
        if (empty($encryptedData)) return null;

        $decoded = base64_decode($encryptedData);
        $ivLength = openssl_cipher_iv_length(self::$cipher);
        $iv = substr($decoded, 0, $ivLength);
        $encrypted = substr($decoded, $ivLength);

        return openssl_decrypt($encrypted, self::$cipher, self::getKey(), 0, $iv);
    }
}
