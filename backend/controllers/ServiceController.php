<?php
// controllers/ServiceController.php

require_once __DIR__ . '/../models/Service.php';
require_once __DIR__ . '/../utils/jwt.php';

class ServiceController {
    private $model;

    public function __construct() {
        $this->model = new Service();
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

        if (preg_match('/\/api\/services\/create/', $path) && $method === 'POST') {
            $this->create($auth);
        } elseif (preg_match('/\/api\/services\/mine/', $path) && $method === 'GET') {
            $this->mine($auth);
        } elseif (preg_match('/\/api\/services\/all/', $path) && $method === 'GET') {
            $this->all($auth);
        } elseif (preg_match('/\/api\/services\/update/', $path) && $method === 'POST') {
            $this->update($auth);
        } elseif (preg_match('/\/api\/services\/delete/', $path) && $method === 'POST') {
            $this->delete($auth);
        } elseif (preg_match('/\/api\/services$/', $path) && $method === 'GET') {
            // NUEVA RUTA PARA /api/services (GET)
            $this->available($auth);
        } else {
            echo json_encode(["error" => "Ruta no válida"]);
        }
    }

    private function create($auth) {
        $data = json_decode(file_get_contents("php://input"), true);
        $data['user_id'] = $auth->id;
        $ok = $this->model->create($data);
        echo json_encode(["success" => $ok]);
    }

    private function mine($auth) {
        $services = $this->model->getByUser($auth->id);
        echo json_encode($services);
    }

    private function all($auth) {
        if ($auth->role !== 'admin') return $this->unauthorized();
        $services = $this->model->getAll();
        echo json_encode($services);
    }

    private function update($auth) {
        $data = json_decode(file_get_contents("php://input"), true);
        $ok = $this->model->update($data['id'], $auth->id, $data);
        echo json_encode(["success" => $ok]);
    }

    private function delete($auth) {
        $data = json_decode(file_get_contents("php://input"), true);
        $ok = $this->model->delete($data['id'], $auth->id);
        echo json_encode(["success" => $ok]);
    }

    private function available($auth) {
        // Devuelve servicios activos de otros usuarios
        $services = $this->model->getAvailable($auth->id);
        echo json_encode($services);
    }

    private function unauthorized() {
        http_response_code(401);
        echo json_encode(["error" => "No autorizado"]);
    }
}
