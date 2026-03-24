<?php

// backend/services/WebSocketService.php
namespace Services;

use Exception;
use PDO;

class WebSocketService
{
    private static ?string $baseUrl = null;
    private static int $timeout = 10;

    /**
     * Obtener la URL base del WebSocket (único punto de verdad)
     */
    private static function getBaseUrl(): string
    {
        if (self::$baseUrl !== null) {
            return self::$baseUrl;
        }

        // 1. Variable de entorno del servidor
        $wsUrl = getenv('WS_URL');

        // 2. Si no existe, intentar desde base de datos
        if (empty($wsUrl)) {
            $wsUrl = self::getWebSocketUrlFromDatabase();
        }

        // 3. Si no existe, usar valor por defecto (solo desarrollo)
        if (empty($wsUrl)) {
            $wsUrl = self::isDevelopment() ? 'http://localhost:3001' : 'https://ws.tapclic.com';
            error_log("⚠️ WebSocket URL no configurada, usando: $wsUrl");
        }

        self::$baseUrl = rtrim($wsUrl, '/');
        error_log("✅ WebSocketService usando URL: " . self::$baseUrl);

        return self::$baseUrl;
    }

    /**
     * Obtener URL desde base de datos (api_host)
     */
    private static function getWebSocketUrlFromDatabase(): ?string
    {
        try {
            require_once __DIR__ . '/../config/database.php';
            $database = new \Database();
            $db = $database->getConnection();

            $query = "SELECT api_host FROM system_config WHERE id = 1 LIMIT 1";
            $stmt = $db->prepare($query);
            $stmt->execute();

            if ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                $url = $row['api_host'];
                if (!empty($url)) {
                    return $url;
                }
            }
        } catch (Exception $e) {
            error_log("⚠️ Error al obtener WS_URL de BD: " . $e->getMessage());
        }
        return null;
    }

    /**
     * Verificar si estamos en entorno de desarrollo
     */
    private static function isDevelopment(): bool
    {
        $env = getenv('APP_ENV') ?: 'production';
        return $env === 'development' || $env === 'dev' || $env === 'local';
    }

    /**
     * Emitir evento a través de WebSocket (método unificado)
     */
    public static function emit(string $event, array $payload, ?array $target = null): bool
    {
        try {
            $url = self::getBaseUrl() . '/emit';
            $data = [
                'event' => $event,
                'payload' => $payload
            ];

            // Añadir target si existe (room o usuario específico)
            if ($target) {
                if (isset($target['room'])) {
                    $data['room'] = $target['room'];
                }
                if (isset($target['receiver_id'])) {
                    $data['receiver_id'] = $target['receiver_id'];
                    $data['receiver_role'] = $target['receiver_role'] ?? null;
                }
                if (isset($target['conversation_id'])) {
                    $data['conversation_id'] = $target['conversation_id'];
                }
            }

            $ch = curl_init($url);
            curl_setopt_array($ch, [
                CURLOPT_POST => true,
                CURLOPT_POSTFIELDS => json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_INVALID_UTF8_SUBSTITUTE),
                CURLOPT_HTTPHEADER => [
                    'Content-Type: application/json; charset=utf-8',
                    'Accept: application/json',
                    'X-Internal-Request: true',
                    'X-Server-Name: ' . (gethostname() ?: 'unknown')
                ],
                CURLOPT_RETURNTRANSFER => true,
                CURLOPT_TIMEOUT => self::$timeout,
                CURLOPT_SSL_VERIFYPEER => !self::isDevelopment(),
                CURLOPT_SSL_VERIFYHOST => self::isDevelopment() ? 0 : 2,
                CURLOPT_VERBOSE => false
            ]);

            $response = curl_exec($ch);
            $status = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            $error = curl_error($ch);
            curl_close($ch);

            $success = ($status >= 200 && $status < 300) && empty($error);

            if (!$success && self::isDevelopment()) {
                error_log("❌ WebSocket error: HTTP $status - $error");
                error_log("📦 Data enviada: " . json_encode($data, JSON_PRETTY_PRINT));
            }
            return $success;
        } catch (Exception $e) {
            error_log("❌ Excepción en WebSocketService::emit: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Emitir evento a sala específica
     */
    public static function emitToRoom(string $room, string $event, array $payload): bool
    {
        $target = ['room' => $room];

        // Si es sala de conversación, añadir conversation_id
        if (strpos($room, 'conversation_') === 0) {
            $conversationId = intval(str_replace('conversation_', '', $room));
            if ($conversationId > 0) {
                $target['conversation_id'] = $conversationId;
            }
        }

        if (!isset($payload['conversation_id']) && isset($target['conversation_id'])) {
            $payload['conversation_id'] = $target['conversation_id'];
        }

        return self::emit($event, $payload, $target);
    }

    /**
     * Emitir evento a usuario específico
     */
    public static function emitToUser(string $receiverRole, int $receiverId, string $event, array $payload): bool
    {
        $target = [
            'receiver_id' => $receiverId,
            'receiver_role' => $receiverRole ?? ''
        ];

        if (isset($payload['conversation_id'])) {
            $target['conversation_id'] = $payload['conversation_id'];
        }

        if (!isset($payload['conversation_id']) && isset($target['conversation_id'])) {
            $payload['conversation_id'] = $target['conversation_id'];
        }

        return self::emit($event, $payload, $target);
    }

    /**
     * Enviar notificación a usuario
     */
    public static function sendNotification(
        string $receiverRole,
        int $receiverId,
        string $title,
        string $message,
        array $data = []
    ): bool {
        $payload = [
            'title' => $title,
            'message' => $message,
            'notification_type' => $data['notification_type'] ?? 'general',
            'url' => $data['url'] ?? null,
            'action' => $data['action'] ?? null,
            'conversation_id' => $data['conversation_id'] ?? null,
            'sender_name' => $data['sender_name'] ?? null,
            'timestamp' => time()
        ];

        return self::emitToUser($receiverRole, $receiverId, 'new-notification', $payload);
    }

    /**
     * Verificar estado del servidor WebSocket
     */
    public static function healthCheck(): bool
    {
        try {
            $url = self::getBaseUrl() . '/status';

            $ch = curl_init($url);
            curl_setopt_array($ch, [
                CURLOPT_RETURNTRANSFER => true,
                CURLOPT_TIMEOUT => 3,
                CURLOPT_SSL_VERIFYPEER => !self::isDevelopment(),
                CURLOPT_SSL_VERIFYHOST => self::isDevelopment() ? 0 : 2,
                CURLOPT_HTTPHEADER => ['Accept: application/json']
            ]);

            $response = curl_exec($ch);
            $status = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            curl_close($ch);

            return ($status === 200);

        } catch (Exception $e) {
            if (self::isDevelopment()) {
                error_log("⚠️ WebSocket health check falló: " . $e->getMessage());
            }
            return false;
        }
    }

    /**
     * Configurar URL base manualmente (útil para tests)
     */
    public static function setBaseUrl(string $url): void
    {
        self::$baseUrl = rtrim($url, '/');
    }

    /**
     * Configurar timeout
     */
    public static function setTimeout(int $seconds): void
    {
        self::$timeout = $seconds;
    }
}
