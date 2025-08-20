<?php
// controllers/AdminController.php

require_once __DIR__ . '/../models/Admin.php';
require_once __DIR__ . '/../utils/jwt.php';

class AdminController {
    private $model;

    public function __construct() {
        $this->model = new Admin();
    }

    private function auth() {
        $headers = getallheaders();
        $authHeader = $headers['Authorization'] ?? '';
        if (!str_starts_with($authHeader, 'Bearer ')) return null;
        return JwtHandler::decode(str_replace("Bearer ", "", $authHeader));
    }

    public function stats() {
        $auth = $this->auth();

        header('Content-Type: application/json');

        if (!$auth || $auth->role !== 'admin') {
            http_response_code(401);
            echo json_encode(["error" => "No autorizado"]);
            return;
        }

        $data = [
            "totalUsers" => $this->model->getTotalUsers(),
            "totalServices" => $this->model->getTotalServices(),
            "totalNotifications" => $this->model->getTotalNotifications(),
            "latestActivities" => $this->model->getLatestActivities(),
        ];

        echo json_encode($data);
    }
}
