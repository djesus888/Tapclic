<?php
require_once __DIR__ . "/../middleware/Auth.php";
// controllers/NotificationController.php

require_once __DIR__ . '/../models/Notification.php';
require_once __DIR__ . '/../utils/jwt.php';

class NotificationController {
    private $model;

    public function __construct() {
        $this->model = new Notification();
        header("Content-Type: application/json");
    }


    public function handle($method) {
        $auth = Auth::verify();
        $uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH); // limpia ?params

        if ($method === 'POST' && preg_match('/\/api\/notifications\/send/', $uri)) {
            $this->send($auth);
        } elseif ($method === 'GET' && preg_match('/\/api\/notifications\/mine/', $uri)) {
            $this->mine($auth);
        } elseif ($method === 'POST' && preg_match('/\/api\/notifications\/read/', $uri)) {
            $this->markAsRead($auth);
        } elseif ($method === 'GET' && preg_match('/\/api\/notifications$/', $uri)) {
            $this->index($auth); // NUEVO para /api/notifications
        } else {
            http_response_code(404);
            echo json_encode(["error" => "Ruta no válida"]);
        }
    }

    private function send($auth) {
        $data = json_decode(file_get_contents("php://input"), true);

        if (!isset($data['receiver_id'], $data['receiver_role'], $data['title'], $data['message'])) {
            http_response_code(400);
            echo json_encode(["error" => "Faltan campos obligatorios"]);
            return;
        }

        $data['sender_id'] = $auth->id;

        $ok = $this->model->send($data);
        echo json_encode(["success" => $ok]);
    }

    private function mine($auth) {
        $result = $this->model->getForUser($auth->id, $auth->role);
        echo json_encode($result);
    }

    private function markAsRead($auth) {
        $data = json_decode(file_get_contents("php://input"), true);

        if (!isset($data['id'])) {
            http_response_code(400);
            echo json_encode(["error" => "ID de notificación requerido"]);
            return;
        }

        $ok = $this->model->markAsRead($data['id'], $auth->id);
        echo json_encode(["success" => $ok]);
    }

    // NUEVO MÉTODO para /api/notifications
    private function index($auth) {
        $this->mine($auth);
    }
}
