<?php
// public/index.php

/* ---------- CORS (ajusta a tu puerto de Vue) ---------- */
header("Access-Control-Allow-Origin: http://localhost:5173");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Language");
header("Access-Control-Allow-Credentials: true");
header("Content-Type: application/json");

/* ---------- OPTIONS (preflight) ---------- */
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
    $lang = $_SERVER['HTTP_X_LANGUAGE'] ?? 'es';               // idioma que envía Vue
    $i18n = \SystemConfig::get('i18n', []);                    // JSON completo
    echo json_encode($i18n[$lang] ?? []);                      // solo el idioma pedido
    exit();
}

/* ---------- Resto de tu aplicación ---------- */
require_once __DIR__ . '/../routes/api.php';
