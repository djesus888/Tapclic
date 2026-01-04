<?php
// public/index.php

// --- CONFIGURACIÓN CORS ---
$allowed_origins = [
    'http://localhost:5173',
    'http://localhost:8080',
    'https://tapclic.com',
    'https://www.tapclic.com',
];

$local_origin_pattern = '/^http:\/\/(192\.168\.\d+\.\d+|10\.\d+\.\d+\.\d+|172\.(1[6-9]|2\d|3[0-1])\.\d+)(:\d+)?$/';
$origin = $_SERVER['HTTP_ORIGIN'] ?? '';

if ($origin && (in_array($origin, $allowed_origins) || preg_match($local_origin_pattern, $origin))) {
    header("Access-Control-Allow-Origin: $origin");
} else {
    // fallback seguro
    header("Access-Control-Allow-Origin: " . $allowed_origins[0]);
}

header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Language");
header("Access-Control-Allow-Credentials: true");

// Manejar preflight OPTIONS sin romper flujo
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    // No hacer exit() para que siga cargando el backend si es necesario
    echo json_encode(['status' => 'ok']);
    return;
}

// ---------- Carga helper SystemConfig ----------
require_once __DIR__ . '/../utils/SystemConfig.php';

// ---------- Mantenimiento global ----------
if (\SystemConfig::get('maintenance_mode', false)) {
    http_response_code(503);
    echo json_encode(['error' => 'Sistema en mantenimiento']);
    return;
}

// ---------- i18n dinámico ----------
if ($_SERVER['REQUEST_METHOD'] === 'GET' && $_SERVER['REQUEST_URI'] === '/api/system/i18n') {
    $lang = $_SERVER['HTTP_X_LANGUAGE'] ?? 'es';
    $i18n = \SystemConfig::get('i18n', []);
    echo json_encode($i18n[$lang] ?? []);
    return;
}

// ---------- Archivos estáticos ----------
if (str_starts_with($_SERVER['REQUEST_URI'], '/uploads')) {
    return false;
}

// ---------- Resto de la aplicación ----------
require_once __DIR__ . '/../routes/api.php';
