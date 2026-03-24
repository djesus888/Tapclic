<?php
require_once __DIR__ . '/services/WebSocketService.php';

use Services\WebSocketService;

// Forzar URL específica para prueba
WebSocketService::setBaseUrl('http://localhost:3001');

echo "🧪 Probando conexión WebSocket...\n";

// Prueba 1: Health check
$health = WebSocketService::healthCheck();
echo "Health check: " . ($health ? "✅ OK" : "❌ FALLÓ") . "\n";

// Prueba 2: Emitir evento
$result = WebSocketService::emitToRoom(
    "conversation_1",
    "new_message",
    [
        'conversation_id' => 1,
        'message' => ['text' => 'Mensaje de prueba PHP', 'id' => 999],
        'temp_id' => 'test_' . time(),
        'status' => 'sent'
    ]
);

echo "Emit resultado: " . ($result ? "✅ EXITO" : "❌ FALLO") . "\n";
