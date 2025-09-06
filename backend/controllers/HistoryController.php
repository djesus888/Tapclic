<?php
header("Access-Control-Allow-Origin: http://localhost:5173");
header("Access-Control-Allow-Headers: Origin, X-Requested-With, Content-Type, Accept, Authorization");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once __DIR__ . '/../models/ServiceRequest.php';
require_once __DIR__ . '/../utils/jwt.php';

class HistoryController {
    private $serviceRequestModel;

    public function __construct() {
        $this->serviceRequestModel = new ServiceRequest();
    }

    /**
     * GET /api/requests/history
     * Devuelve las solicitudes FINALIZADAS del usuario logueado.
     */
    public function index() {
        // Autenticación
        $headers = getallheaders();
        $auth = $headers['Authorization'] ?? '';
        if (!str_starts_with($auth, "Bearer ")) {
            http_response_code(401);
            echo json_encode(["message" => "Token no proporcionado"]);
            return;
        }

        $token = str_replace("Bearer ", "", $auth);
        $decoded = JwtHandler::decode($token);
        if (!$decoded || !isset($decoded->id)) {
            http_response_code(401);
            echo json_encode(["message" => "Token inválido o expirado"]);
            return;
        }

        // Obtener historial (status finalizados)
        $history = $this->serviceRequestModel->getHistoryByUser($decoded->id);

        echo json_encode([
            "success" => true,
            "history" => $history
        ]);
    }
}
