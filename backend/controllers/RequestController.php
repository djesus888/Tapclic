<?php
// controllers/RequestController.php

require_once __DIR__ . '/../models/ServiceRequest.php';
require_once __DIR__ . '/../utils/jwt.php';

class RequestController {
    private $model;

    public function __construct() {
        $this->model = new ServiceRequest();
    }

    private function auth() {
        $headers = getallheaders();
        $auth = $headers['Authorization'] ?? '';
        if (!str_starts_with($auth, 'Bearer ')) return null;
        return JwtHandler::decode(str_replace("Bearer ", "", $auth));
    }

    public function handle($method) {
        $auth = $this->auth();
        if (!$auth) return $this->unauthorized();

        $path = $_SERVER['REQUEST_URI'];

        if (preg_match('/\/api\/requests\/create/', $path) && $method === 'POST') {
            $this->create($auth);
        } elseif (preg_match('/\/api\/requests\/mine/', $path) && $method === 'GET') {
            $this->mine($auth);
        } elseif (preg_match('/\/api\/requests\/accept/', $path) && $method === 'POST') {
            $this->accept($auth);
        } elseif (preg_match('/\/api\/requests\/active/', $path) && $method === 'POST') {
            $this->active($auth);
        } elseif (preg_match('/\/api\/requests\/reject/', $path) && $method === 'POST') {
            $this->reject($auth);
        } elseif (preg_match('/\/api\/requests\/status\/\d+/', $path) && $method === 'GET') {
            $this->getStatus($auth);
        } else {
            echo json_encode(["error" => "Ruta no válida"]);
        }
    }

    private function create($auth) {
    $data = json_decode(file_get_contents("php://input"), true);
    $data['user_id'] = $auth->id; // cliente que solicita
    $newId = $this->model->create($data);

    if ($newId) {
        // Devolver objeto con requestId y estado inicial
        echo json_encode([
            "success" => true,
            "requestId" => (int)$newId,
            "status" => "pending"
        ]);
    } else {
        echo json_encode([
            "success" => false,
            "error" => "No se pudo crear la solicitud"
        ]);
    }
  }

    private function mine($auth) {
        $result = $this->model->getByUser($auth->id);
        echo json_encode($result);
    }




    private function active($auth) {
    $result = $this->model->getActiveByUser($auth->id);

    echo json_encode([
        "success" => true,
        "data" => $result
    ]);
}
    private function accept($auth) {
        $data = json_decode(file_get_contents("php://input"), true);
        $ok = $this->model->updateStatus($data['id'], $auth->id, 'accepted');
        echo json_encode(["success" => $ok]);
    }

    private function reject($auth) {
        $data = json_decode(file_get_contents("php://input"), true);
        $ok = $this->model->updateStatus($data['id'], $auth->id, 'rejected');
        echo json_encode(["success" => $ok]);
    }

    private function getStatus($auth) {
        if (!preg_match('/\/api\/requests\/status\/(\d+)/', $_SERVER['REQUEST_URI'], $matches)) {
            http_response_code(400);
            echo json_encode(['error' => 'ID de solicitud inválido']);
            return;
        }

        $requestId = $matches[1];
        $request = $this->model->getById($requestId);

        if (!$request) {
            http_response_code(404);
            echo json_encode(['error' => 'Solicitud no encontrada']);
            return;
        }

        // Solo cliente o proveedor pueden ver el estado
        if ($request['user_id'] != $auth->id && $request['provider_id'] != $auth->id) {
            http_response_code(403);
            echo json_encode(['error' => 'No autorizado']);
            return;
        }

        echo json_encode(['status' => $request['status']]);
    }

    private function unauthorized() {
        http_response_code(401);
        echo json_encode(["error" => "No autorizado"]);
    }
}
