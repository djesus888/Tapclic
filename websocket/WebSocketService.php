<?php
// backend/services/WebSocketService.php

namespace Services;

class WebSocketService
{
    private static string $baseUrl = '';
    private static int $timeout = 5;

    private static function getBaseUrl(): string
    {
        if (empty(self::$baseUrl)) {
            $envUrl = getenv('WS_URL') ?: 'http://192.168.1.248:3001';
            self::$baseUrl = rtrim($envUrl, '/');
        }
        return self::$baseUrl;
    }

    /**
     * Emite una notificación al WebSocket
     */
    public static function emit(array $payload, string $endpoint = '/emit'): bool
    {
        $url = self::getBaseUrl() . $endpoint;
        
        // Estructura que espera tu websocket
        $data = [
            'receiver_id' => $payload['receiver_id'] ?? null,
            'receiver_role' => $payload['receiver_role'] ?? null,
            'title' => $payload['title'] ?? 'Notificación',
            'message' => $payload['message'] ?? '',
            'event' => $payload['event'] ?? null,
            'payload' => $payload['data_json'] ?? $payload['payload'] ?? null
        ];

        $ch = curl_init($url);
        curl_setopt_array($ch, [
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => json_encode($data),
            CURLOPT_HTTPHEADER => ['Content-Type: application/json'],
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT => self::$timeout,
            CURLOPT_SSL_VERIFYPEER => false,
        ]);

        $response = curl_exec($ch);
        $status = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $error = curl_error($ch);
        curl_close($ch);

        $success = ($status >= 200 && $status < 300) && empty($error);
        
        if (!$success) {
            error_log("WebSocket error: HTTP $status - $error");
        }

        return $success;
    }

    /**
     * Emite un evento específico
     */
    public static function emitEvent(string $receiverRole, int $receiverId, string $event, array $payload): bool
    {
        return self::emit([
            'receiver_id' => $receiverId,
            'receiver_role' => $receiverRole,
            'event' => $event,
            'payload' => $payload
        ], '/emit-event');
    }
}
