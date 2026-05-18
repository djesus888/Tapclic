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

        // 3. Si no existe, construir desde API_URL
        if (empty($wsUrl)) {
            $apiUrl = getenv('API_URL');
            if (!empty($apiUrl)) {
                // Convertir http:// a ws://, https:// a wss://
                $wsUrl = preg_replace('/^http(s?):\/\//', 'ws$1://', $apiUrl);
                error_log("🔧 WebSocket URL construida desde API_URL: $wsUrl");
            }
        }

        // 4. Fallback final
        // Usar protocolo HTTP correcto para el endpoint /emit
        // El servidor Node.js expone endpoints HTTP (POST /emit, GET /status)
        if (empty($wsUrl)) {
            if (self::isDevelopment()) {
                $wsUrl = 'http://localhost:3001';
            } else {
                // En producción, mantener https:// si el dominio tiene SSL
                $wsUrl = 'https://ws.tapclic.com';
            }
            error_log("⚠️ WebSocket URL no configurada, usando fallback: $wsUrl");
        }

        // Asegurar que usamos http:// o https:// (no ws://)
        // Porque las peticiones CURL van al endpoint HTTP /emit
        if (strpos($wsUrl, 'ws://') === 0) {
            $wsUrl = preg_replace('/^ws:/', 'http:', $wsUrl);
        } elseif (strpos($wsUrl, 'wss://') === 0) {
            $wsUrl = preg_replace('/^wss:/', 'https:', $wsUrl);
        }

        self::$baseUrl = rtrim($wsUrl, '/');
        error_log("✅ WebSocketService usando URL: " . self::$baseUrl);

        return self::$baseUrl;
    }

    /**
     * Obtener URL desde base de datos (ws_host)
     */
    private static function getWebSocketUrlFromDatabase(): ?string
    {
        try {
            require_once __DIR__ . '/../config/database.php';
            $database = new \Database();
            $db = $database->getConnection();

            $query = "SELECT ws_host FROM system_config WHERE id = 1 LIMIT 1";
            $stmt = $db->prepare($query);
            $stmt->execute();

            if ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                $url = $row['ws_host'];
                if (!empty($url)) {
                    // Mantener como http/https para CURL
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
     * Verificar si la URL es accesible
     */
    private static function isUrlReachable(string $url): bool
    {
        try {
            $ch = curl_init($url);
            curl_setopt_array($ch, [
                CURLOPT_RETURNTRANSFER => true,
                CURLOPT_TIMEOUT => 3,
                CURLOPT_NOBODY => true,
                CURLOPT_SSL_VERIFYPEER => !self::isDevelopment(),
                CURLOPT_SSL_VERIFYHOST => self::isDevelopment() ? 0 : 2
            ]);
            curl_exec($ch);
            $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            curl_close($ch);

            // Aceptamos cualquier código 2xx o 3xx
            return $httpCode >= 200 && $httpCode < 400;
        } catch (Exception $e) {
            if (self::isDevelopment()) {
                error_log("⚠️ WebSocket reachability check falló: " . $e->getMessage());
            }
            return false;
        }
    }

    /**
     * Emitir evento a través de WebSocket (método unificado)
     */
    public static function emit(string $event, array $payload, ?array $target = null): bool
    {
        try {
            $baseUrl = self::getBaseUrl();
            $url = $baseUrl . '/emit';

            // Verificar reachability pero NO bloquear el envío
            if (!self::isUrlReachable($baseUrl)) {
                error_log("⚠️ WebSocket server no reachable: " . $baseUrl . " - Intentando enviar de todas formas...");
            }

            $data = [
                'event' => $event,
                'payload' => $payload,
                'timestamp' => time() // ✅ AGREGADO: timestamp para debugging
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
                // ✅ AGREGADO: soporte para broadcast a rol completo
                if (isset($target['broadcast_role'])) {
                    $data['broadcast_role'] = $target['broadcast_role'];
                }
            }

            $jsonData = json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_INVALID_UTF8_SUBSTITUTE);

            // ✅ AGREGADO: Log detallado para debugging
            error_log("📤 [WS] Emitiendo evento '$event' a URL: $url");
            error_log("📦 [WS] Payload: " . json_encode([
                'event' => $event,
                'target' => $target ? array_keys($target) : 'broadcast',
                'payload_keys' => array_keys($payload)
            ]));

            $ch = curl_init($url);
            curl_setopt_array($ch, [
                CURLOPT_POST => true,
                CURLOPT_POSTFIELDS => $jsonData,
                CURLOPT_HTTPHEADER => [
                    'Content-Type: application/json; charset=utf-8',
                    'Accept: application/json',
                    'X-Internal-Request: true',
                    'X-Server-Name: ' . (gethostname() ?: 'unknown'),
                    'Content-Length: ' . strlen($jsonData)
                ],
                CURLOPT_RETURNTRANSFER => true,
                CURLOPT_TIMEOUT => self::$timeout,
                CURLOPT_CONNECTTIMEOUT => 5,
                CURLOPT_SSL_VERIFYPEER => !self::isDevelopment(),
                CURLOPT_SSL_VERIFYHOST => self::isDevelopment() ? 0 : 2,
                CURLOPT_VERBOSE => false
            ]);

            $response = curl_exec($ch);
            $status = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            $error = curl_error($ch);
            curl_close($ch);

            $success = ($status >= 200 && $status < 300) && empty($error);

            if (!$success) {
                error_log("❌ [WS] Error HTTP $status: $error");
                error_log("📦 [WS] Data enviada: " . substr($jsonData, 0, 500));
            } else {
                error_log("✅ [WS] Evento '$event' enviado correctamente (HTTP $status)");
            }

            return $success;
        } catch (Exception $e) {
            error_log("❌ [WS] Excepción en emit: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Emitir evento a sala específica
     */
    public static function emitToRoom(string $room, string $event, array $payload): bool
    {
        $target = ['room' => $room];

        error_log("📡 Emitiendo a sala {$room}: {$event}");

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

        // Agregar timestamp para depuración
        if (!isset($payload['timestamp'])) {
            $payload['timestamp'] = time();
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

        // ✅ AGREGADO: timestamp si no existe
        if (!isset($payload['timestamp'])) {
            $payload['timestamp'] = time();
        }

        error_log("📤 [WS] Emitiendo '$event' a {$receiverRole}_{$receiverId}");

        return self::emit($event, $payload, $target);
    }

    /**
     * ✅ NUEVO: Emitir evento a todos los usuarios de un rol específico
     */
    public static function emitToRole(string $receiverRole, string $event, array $payload): bool
    {
        $target = [
            'broadcast_role' => $receiverRole
        ];

        if (!isset($payload['timestamp'])) {
            $payload['timestamp'] = time();
        }

        error_log("📤 [WS] Emitiendo '$event' a todos los usuarios con rol: {$receiverRole}");

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
            'event' => $data['event'] ?? 'status_changed', // ✅ CORRECCIÓN: Incluir event para el switch en socketStore
            'title' => $title,
            'message' => $message,
            'notification_type' => $data['notification_type'] ?? 'general',
            'url' => $data['url'] ?? null,
            'action' => $data['action'] ?? null,
            'conversation_id' => $data['conversation_id'] ?? null,
            'sender_name' => $data['sender_name'] ?? null,
            'request_id' => $data['request_id'] ?? null, // ✅ AGREGADO
            'service_id' => $data['service_id'] ?? null, // ✅ AGREGADO
            'timestamp' => time()
        ];

        // ✅ AGREGADO: Log para debugging
        error_log("📢 [WS] Enviando notificación a {$receiverRole}_{$receiverId}: $title");

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

            if ($status === 200) {
                error_log("✅ [WS] Health check OK");
                return true;
            } else {
                error_log("⚠️ [WS] Health check falló: HTTP $status");
                return false;
            }

        } catch (Exception $e) {
            error_log("⚠️ [WS] Health check excepción: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Configurar URL base manualmente (útil para tests)
     */
    public static function setBaseUrl(string $url): void
    {
        self::$baseUrl = rtrim($url, '/');
        error_log("🔧 [WS] URL base configurada manualmente: " . self::$baseUrl);
    }

    /**
     * Configurar timeout
     */
    public static function setTimeout(int $seconds): void
    {
        self::$timeout = $seconds;
    }
}
