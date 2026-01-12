<?php
// backend/services/WebSocketService.php

namespace Services;

class WebSocketService
{
    private static string $baseUrl = '';
    private static int $timeout = 5;
    private static int $connectTimeout = 2;

    /**
     * Obtiene la URL base del WebSocket desde .env
     */
    private static function getBaseUrl(): string
    {
        if (empty(self::$baseUrl)) {
            // Intenta WS_URL primero (preferida para backend)
            $envUrl = getenv('WS_URL');
            
            // Fallback a VITE_WS_URL si WS_URL no está definida
            if ($envUrl === false) {
                $envUrl = getenv('VITE_WS_URL');
            }
            
            // Valor por defecto si ninguna variable está definida
            self::$baseUrl = $envUrl ? rtrim($envUrl, '/') : 'http://localhost:3001';
        }
        return self::$baseUrl;
    }

    /**
     * Emite una notificación clásica al WebSocket
     *
     * @param array $payload Datos de la notificación
     * @param string $endpoint Endpoint del WebSocket (/emit por defecto)
     * @return bool true si se envió correctamente, false si hubo error
     */
    public static function emit(array $payload, string $endpoint = '/emit'): bool
    {
        $url = self::getBaseUrl() . $endpoint;
        $json = json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);

        if ($json === false) {
            error_log("WebSocketService: JSON_ERROR – " . json_last_error_msg());
            return false;
        }

        $ch = curl_init($url);
        curl_setopt_array($ch, [
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => $json,
            CURLOPT_HTTPHEADER => ['Content-Type: application/json'],
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT => self::$timeout,
            CURLOPT_CONNECTTIMEOUT => self::$connectTimeout,
            CURLOPT_SSL_VERIFYPEER => false,
            CURLOPT_SSL_VERIFYHOST => false,
            CURLOPT_HEADER => true,
        ]);

        $response = curl_exec($ch);
        $status = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $error = curl_error($ch);
        curl_close($ch);

        $success = ($status >= 200 && $status < 300) && empty($error);

        if (!$success) {
            error_log("WebSocketService ERROR – HTTP $status – cURL: $error – payload: $json");
        } else {
            error_log("WebSocketService OK – HTTP $status – payload: $json");
        }
        
        return $success;
    }

    /**
     * Emite un evento nombrado al WebSocket
     *
     * @param string $receiverRole Rol del receptor (user/provider/admin)
     * @param int $receiverId ID del usuario receptor
     * @param string $event Nombre del evento (ej: 'payment_updated', 'request_updated')
     * @param array $payload Datos específicos del evento
     * @return bool true si se envió correctamente
     */
    public static function emitEvent(string $receiverRole, int $receiverId, string $event, array $payload): bool
    {
        return self::emit([
            'event' => $event,
            'payload' => $payload,
            'receiver_id' => $receiverId,
            'receiver_role' => $receiverRole
        ], '/emit-event');
    }

    /**
     * Emite una notificación clásica (wrapper)
     *
     * @param int $receiverId ID del usuario receptor
     * @param string $receiverRole Rol del receptor
     * @param string $title Título de la notificación
     * @param string $message Cuerpo del mensaje
     * @param array $extraData Datos adicionales opcionales
     * @return bool
     */
    public static function notify(int $receiverId, string $receiverRole, string $title, string $message, array $extraData = []): bool
    {
        $payload = array_merge([
            'receiver_id' => $receiverId,
            'receiver_role' => $receiverRole,
            'title' => $title,
            'message' => $message,
        ], $extraData);

        return self::emit($payload, '/emit');
    }

    /**
     * Configura la URL base del WebSocket (útil para testing)
     */
    public static function setBaseUrl(string $url): void
    {
        self::$baseUrl = rtrim($url, '/');
    }

    /**
     * Configura timeouts para las peticiones cURL
     */
    public static function setTimeout(int $timeout, int $connectTimeout): void
    {
        self::$timeout = $timeout;
        self::$connectTimeout = $connectTimeout;
    }
}
