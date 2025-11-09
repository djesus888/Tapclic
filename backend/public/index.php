<?php
// public/index.php

// --- CONFIGURACIÓN CORS (colocar al inicio del archivo, antes de cualquier salida) ---
$allowed_origins = [
    'http://localhost:8080',
    'http://localhost:5173',
];

$origin = $_SERVER['HTTP_ORIGIN'] ?? '';

if (in_array($origin, $allowed_origins)) {
    header("Access-Control-Allow-Origin: $origin");
} else {
    // Fallback en caso de pruebas locales
    header("Access-Control-Allow-Origin: http://localhost:8080");
}

header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Language");
header("Access-Control-Allow-Credentials: true");

// Manejar solicitudes preflight (OPTIONS)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

/* ---------- Carga helper SystemConfig (antes que nada) ---------- */
require_once __DIR__ . '/../utils/SystemConfig.php';

/* ---------- Mantenimiento global ---------- */
if (\SystemConfig::get('maintenance_mode', false)) {
    http_response_code(503);
    echo json_encode(['error' => 'Sistema en mantenimiento']);
    exit();
}

/* ---------- i18n dinámico (endpoint público) ---------- */
if ($_SERVER['REQUEST_METHOD'] === 'GET' && $_SERVER['REQUEST_URI'] === '/api/system/i18n') {
    $lang = $_SERVER['HTTP_X_LANGUAGE'] ?? 'es';
    $i18n = \SystemConfig::get('i18n', []);
    echo json_encode($i18n[$lang] ?? []);
    exit();
}

/* ---------- Resto de tu aplicación ---------- */
require_once __DIR__ . '/../routes/api.php';
