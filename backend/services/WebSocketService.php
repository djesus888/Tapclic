<?php

// backend/services/WebSocketService.php
namespace Services;

use Exception;
use PDO;


// Cargar .env si no está cargado
if (!getenv('WS_URL') && file_exists(__DIR__ . '/../.env')) {
    $lines = file(__DIR__ . '/../.env', FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos(trim($line), '#') === 0) continue;
        if (strpos($line, '=') !== false) {
            list($key, $value) = explode('=', $line, 2);
            $key = trim($key);
            $value = trim($value);
            if (!getenv($key)) {
                putenv("$key=$value");
                $_ENV[$key] = $value;
            }
        }
    }
    error_log("🔧 [WS] .env cargado manualmente");
}


class WebSocketService
{
    private static ?string $baseUrl = null;
    private static int $timeout = 10;

    /**
     * Obtener la URL base del WebSocket (único punto de verdad)
     * Prioridad: DB (ws_host) → .env (WS_URL) → API_BASE_URL → fallback
     */
    private static function getBaseUrl(): string
    {
        if (self::$baseUrl !== null) {
            return self::$baseUrl;
        }

        // 1. PRIORIDAD: Base de datos (campo ws_host)
        $wsUrl = self::getWebSocketUrlFromDatabase();

        // 2. FALLBACK: Variable de entorno .env (WS_URL)
        if (empty($wsUrl)) {
            $wsUrl = getenv('WS_URL');
            if (!empty($wsUrl)) {
                error_log("🔧 [WS] URL obtenida desde .env: $wsUrl");
            }
        }

        // 3. Si no existe, construir desde API_BASE_URL
        if (empty($wsUrl)) {
            $apiUrl = getenv('API_BASE_URL');
            if (!empty($apiUrl)) {
                $wsUrl = preg_replace('/^http(s?):\/\//', 'ws$1://', $apiUrl);
                error_log("🔧 [WS] URL construida desde API_BASE_URL: $wsUrl");
            }
        }

        // 4. Fallback final
        if (empty($wsUrl)) {
            $wsUrl = self::isDevelopment() ? 'http://localhost:3001' : 'https://ws.tapclic.com';
            error_log("⚠️ [WS] URL no configurada en DB ni .env, usando fallback: $wsUrl");
        }

        // Asegurar http:// o https:// (no ws://)
        // Porque las peticiones CURL van al endpoint HTTP /emit
        if (strpos($wsUrl, 'ws://') === 0) {
            $wsUrl = preg_replace('/^ws:/', 'http:', $wsUrl);
        } elseif (strpos($wsUrl, 'wss://') === 0) {
            $wsUrl = preg_replace('/^wss:/', 'https:', $wsUrl);
        }

        self::$baseUrl = rtrim($wsUrl, '/');
        error_log("✅ [WS] WebSocketService usando URL: " . self::$baseUrl);

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
                    return $url;
                }
            }
        } catch (Exception $e) {
            error_log("⚠️ [WS] Error al obtener WS_URL de BD: " . $e->getMessage());
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

            return $httpCode >= 200 && $httpCode < 400;
        } catch (Exception $e) {
            if (self::isDevelopment()) {
                error_log("⚠️ [WS] WebSocket reachability check falló: " . $e->getMessage());
            }
            return false;
        }
    }

    /**
     * Emitir evento a través de WebSocket (método unificado)
     *
     * @param string $event Nombre del evento
     * @param array $payload Datos del evento
     * @param array|null $target Destino (room, usuario, rol)
     * @return array Resultado con éxito, mensaje y código HTTP
     */
    public static function emit(string $event, array $payload, ?array $target = null): array
    {
        $result = [
            'success' => false,
            'http_code' => null,
            'message' => '',
            'event' => $event
        ];

        try {
            $baseUrl = self::getBaseUrl();
            $url = $baseUrl . '/emit';

            $data = [
                'event' => $event,
                'payload' => $payload,
                'timestamp' => time()
            ];

            // Añadir target si existe
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
                if (isset($target['broadcast_role'])) {
                    $data['broadcast_role'] = $target['broadcast_role'];
                }
            }

            $jsonData = json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_INVALID_UTF8_SUBSTITUTE);

            if ($jsonData === false) {
                $result['message'] = 'Error al codificar JSON: ' . json_last_error_msg();
                error_log("❌ [WS] {$result['message']}");
                return $result;
            }

            // Log detallado para debugging
            error_log("📤 [WS] Emitiendo evento '$event' a URL: $url");
            error_log("📦 [WS] Payload: " . json_encode([
                'event' => $event,
                'target' => $target ? array_keys($target) : 'broadcast',
                'payload_keys' => array_keys($payload),
                'payload_size' => strlen($jsonData) . ' bytes'
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
            $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            $curlError = curl_error($ch);
            $curlErrno = curl_errno($ch);
            $responseBody = $response ? substr($response, 0, 500) : '';
            curl_close($ch);

            $result['http_code'] = $httpCode;

            // Evaluar resultado
            if ($curlErrno) {
                // Error de conexión/red (servidor caído, timeout, DNS, etc.)
                switch ($curlErrno) {
                    case CURLE_COULDNT_CONNECT:
                        $result['message'] = "No se pudo conectar al servidor WebSocket en $baseUrl";
                        break;
                    case CURLE_OPERATION_TIMEOUTED:
                        $result['message'] = "Timeout al conectar con WebSocket (más de " . self::$timeout . "s)";
                        break;
                    case CURLE_SSL_CONNECT_ERROR:
                        $result['message'] = "Error SSL al conectar con WebSocket";
                        break;
                    default:
                        $result['message'] = "Error CURL ($curlErrno): $curlError";
                }
                error_log("❌ [WS] Error de conexión: {$result['message']}");

            } elseif ($httpCode >= 200 && $httpCode < 300) {
                // Éxito
                $result['success'] = true;
                $result['message'] = 'Evento enviado correctamente';

                // Verificar respuesta JSON del servidor Node.js
                $responseData = json_decode($responseBody, true);
                if ($responseData && isset($responseData['status']) && $responseData['status'] !== 'ok') {
                    error_log("⚠️ [WS] Servidor respondió pero con estado inesperado: " . json_encode($responseData));
                }

                error_log("✅ [WS] Evento '$event' enviado correctamente (HTTP $httpCode)");

            } elseif ($httpCode >= 500) {
                // Error del servidor Node.js
                $result['message'] = "Error interno del servidor WebSocket (HTTP $httpCode)";
                error_log("❌ [WS] {$result['message']}");
                error_log("📦 [WS] Respuesta: $responseBody");

            } elseif ($httpCode >= 400) {
                // Error del cliente (payload mal formado, etc.)
                $result['message'] = "Error en la petición al WebSocket (HTTP $httpCode)";
                error_log("❌ [WS] {$result['message']}");
                error_log("📦 [WS] Data enviada: " . substr($jsonData, 0, 500));
                error_log("📦 [WS] Respuesta: $responseBody");

            } else {
                // Código inesperado (3xx, etc.)
                $result['message'] = "Respuesta inesperada del WebSocket (HTTP $httpCode)";
                error_log("⚠️ [WS] {$result['message']}");
            }

            return $result;

        } catch (Exception $e) {
            $result['message'] = 'Excepción: ' . $e->getMessage();
            error_log("❌ [WS] Excepción en emit: " . $e->getMessage());
            error_log("❌ [WS] Trace: " . $e->getTraceAsString());
            return $result;
        }
    }

    /**
     * Emitir evento a sala específica
     *
     * @return array Resultado con éxito, mensaje y código HTTP
     */
    public static function emitToRoom(string $room, string $event, array $payload): array
    {
        $target = ['room' => $room];

        error_log("📡 [WS] Emitiendo a sala {$room}: {$event}");

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
     *
     * @return array Resultado con éxito, mensaje y código HTTP
     */
    public static function emitToUser(string $receiverRole, int $receiverId, string $event, array $payload): array
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

        // Timestamp si no existe
        if (!isset($payload['timestamp'])) {
            $payload['timestamp'] = time();
        }

        error_log("📤 [WS] Emitiendo '$event' a {$receiverRole}_{$receiverId}");

        return self::emit($event, $payload, $target);
    }

    /**
     * Emitir evento a todos los usuarios de un rol específico
     *
     * @return array Resultado con éxito, mensaje y código HTTP
     */
    public static function emitToRole(string $receiverRole, string $event, array $payload): array
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
     *
     * @return array Resultado con éxito, mensaje y código HTTP
     */
    public static function sendNotification(
        string $receiverRole,
        int $receiverId,
        string $title,
        string $message,
        array $data = []
    ): array {
        $payload = [
            'event' => $data['event'] ?? 'status_changed',
            'title' => $title,
            'message' => $message,
            'notification_type' => $data['notification_type'] ?? 'general',
            'url' => $data['url'] ?? null,
            'action' => $data['action'] ?? null,
            'conversation_id' => $data['conversation_id'] ?? null,
            'sender_name' => $data['sender_name'] ?? null,
            'request_id' => $data['request_id'] ?? null,
            'service_id' => $data['service_id'] ?? null,
            'timestamp' => time()
        ];

        error_log("📢 [WS] Enviando notificación a {$receiverRole}_{$receiverId}: $title");

        $result = self::emitToUser($receiverRole, $receiverId, 'new-notification', $payload);

        if (!$result['success']) {
            error_log("⚠️ [WS] Notificación no enviada a {$receiverRole}_{$receiverId}: {$result['message']}");
        }

        return $result;
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
