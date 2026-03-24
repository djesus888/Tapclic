<?php
// test_auth.php - Script de prueba para ver headers

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: http://192.168.1.248:5173');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, Accept');
header('Access-Control-Allow-Credentials: true');

// Si es OPTIONS, responder OK
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$response = [
    'method' => $_SERVER['REQUEST_METHOD'],
    'headers' => getallheaders(),
    'server' => [
        'HTTP_AUTHORIZATION' => $_SERVER['HTTP_AUTHORIZATION'] ?? null,
        'REDIRECT_HTTP_AUTHORIZATION' => $_SERVER['REDIRECT_HTTP_AUTHORIZATION'] ?? null,
        'Authorization' => $_SERVER['Authorization'] ?? null,
    ],
    'token' => null
];

// Buscar el token en diferentes lugares
$authHeader = $response['headers']['Authorization'] ?? 
              $response['headers']['authorization'] ?? 
              $_SERVER['HTTP_AUTHORIZATION'] ?? 
              $_SERVER['REDIRECT_HTTP_AUTHORIZATION'] ?? 
              null;

if ($authHeader && strpos($authHeader, 'Bearer ') === 0) {
    $response['token'] = substr($authHeader, 7);
}

echo json_encode($response, JSON_PRETTY_PRINT);
