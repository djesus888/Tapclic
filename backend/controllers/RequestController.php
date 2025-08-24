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

    private function emitWs($payload) {
        $url = 'http://localhost:3000/emit';
        $ch = curl_init($url);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
        curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_exec($ch);
        curl_close($ch);
    }

    public function handle($method) {
        $auth = $this->auth();
        if (!$auth) return $this->unauthorized();

        $path = $_SERVER['REQUEST_URI'];

        if (preg_match('/\/api\/requests\/create/', $path) && $method === 'POST') {
            $this->create($auth);
        } elseif (preg_match('/\/api\/requests\/mine/', $path) && $method === 'GET') {
            $this->mine($auth);
       } elseif (preg_match('/\/api\/requests\/completed/', $path) && $method === 'GET') {
            $this->completed($auth);
       } elseif (preg_match('/\/api\/requests\/pending/', $path) && $method === 'GET') {
            $this->pending($auth);
        } elseif (preg_match('/\/api\/requests\/accept/', $path) && $method === 'POST') {
            $this->accept($auth);
        } elseif (preg_match('/\/api\/requests\/busy/', $path) && $method === 'POST') {
            $this->busy($auth);
        } elseif (preg_match('/\/api\/requests\/active/', $path) && $method === 'GET') {
            $this->active($auth);
        } elseif (preg_match('/\/api\/requests\/reject/', $path) && $method === 'POST') {
            $this->reject($auth);
        } elseif (preg_match('/\/api\/requests\/status\/\d+/', $path) && $method === 'GET') {
            $this->getStatus($auth);
        } elseif (preg_match('/\/api\/requests\/history\/provider/', $path) && $method === 'GET') {
            $this->historyProvider($auth);
        } else {
            echo json_encode(["error" => "Ruta no válida"]);
        }
    }

    private function create($auth) {
        $data = json_decode(file_get_contents("php://input"), true);
        $data['user_id'] = $auth->id; // cliente que solicita
        $newId = $this->model->create($data);

        if ($newId) {
            $providerId = $data['provider_id'] ?? null;
            if ($providerId) {
                // 1. Guardar notificación en DB
                $this->model->saveNotification([
                    'sender_id' => $auth->id,
                    'receiver_id' => $providerId,
                    'receiver_role' => 'provider', // corregido
                    'title' => 'Nueva solicitud',
                    'message' => 'Tienes una nueva solicitud pendiente'
                ]);

                // 2. Emitir notificación a WebSocket server
                $this->emitWs([
                    'receiver_id' => $providerId,
                    'receiver_role' => 'provider',
                    'title' => 'Nueva solicitud',
                    'message' => 'Tienes una nueva solicitud pendiente'
                ]);
            }

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
        echo json_encode([
            "success" => true,
            "data" => $result
        ]);
    }

    private function pending($auth) {
        if ($auth->role === 'provider') {
            $result = $this->model->getPendingByProvider($auth->id);
        } elseif ($auth->role === 'user') {
            $result = $this->model->getPendingByUser($auth->id);
        } else {
            $result = $this->model->getPending();
        }

        echo json_encode([
            "success" => true,
            "data" => $result
        ]);
    }

    private function active($auth) {
        $result = $this->model->getActiveByUser($auth->id);
        echo json_encode([
            "success" => true,
            "data" => $result
        ]);
    }

    public function busy($auth) {
        $input = json_decode(file_get_contents("php://input"), true);
        $requestId = $input['id'] ?? null;

        if (!$requestId) {
            echo json_encode(["success" => false, "message" => "Falta el ID"]);
            return;
        }

        $updated = $this->model->updateStatus($requestId, $auth->id, 'busy');

        // Notificar al usuario
        $request = $this->model->getById($requestId);
        if ($updated && $request) {
            $this->model->saveNotification([
                'sender_id' => $auth->id,
                'receiver_id' => $request['user_id'],
                'receiver_role' => 'user',
                'title' => 'Proveedor ocupado',
                'message' => 'El proveedor está ocupado temporalmente'
            ]);
            $this->emitWs([
                'receiver_id' => $request['user_id'],
                'receiver_role' => 'user',
                'title' => 'Proveedor ocupado',
                'message' => 'El proveedor está ocupado temporalmente'
            ]);
        }

        echo json_encode(["success" => $updated]);
    }

    private function accept($auth) {
        $data = json_decode(file_get_contents("php://input"), true);
        $ok = $this->model->updateStatus($data['id'], $auth->id, 'accepted');

        if ($ok) {
            $request = $this->model->getById($data['id']);
            if ($request) {
                $this->model->saveNotification([
                    'sender_id' => $auth->id,
                    'receiver_id' => $request['user_id'],
                    'receiver_role' => 'user',
                    'title' => 'Solicitud aceptada',
                    'message' => 'Tu solicitud fue aceptada por el proveedor'
                ]);
                $this->emitWs([
                    'receiver_id' => $request['user_id'],
                    'receiver_role' => 'user',
                    'title' => 'Solicitud aceptada',
                    'message' => 'Tu solicitud fue aceptada'
                ]);
            }
        }

        echo json_encode(["success" => $ok]);
    }

    private function reject($auth) {
        $data = json_decode(file_get_contents("php://input"), true);
        $ok = $this->model->updateStatus($data['id'], $auth->id, 'rejected');

        if ($ok) {
            $request = $this->model->getById($data['id']);
            if ($request) {
                $this->model->saveNotification([
                    'sender_id' => $auth->id,
                    'receiver_id' => $request['user_id'],
                    'receiver_role' => 'user',
                    'title' => 'Solicitud rechazada',
                    'message' => 'Tu solicitud fue rechazada por el proveedor'
                ]);
                $this->emitWs([
                    'receiver_id' => $request['user_id'],
                    'receiver_role' => 'user',
                    'title' => 'Solicitud rechazada',
                    'message' => 'Tu solicitud fue rechazada'
                ]);
            }
        }

        echo json_encode(["success" => $ok]);
    }

    private function completed($auth) {
        $result = $this->model->getCompletedByUser($auth->id);
        echo json_encode([
            "success" => true,
            "data" => $result
        ]);
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

        if ($request['user_id'] != $auth->id && $request['provider_id'] != $auth->id) {
            http_response_code(403);
       echo json_encode(['error' => 'No autorizado']);
        return;
    }

    echo json_encode(['status' => $request['status']]);
}

// cerrar clase RequestController
}
