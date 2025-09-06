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
        $url = 'http://localhost:3001/emit';      // Puerto corregido 3001
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
            if ($auth->role === 'provider') {
                $this->completedByProvider($auth);
            } else {
                $this->completed($auth);
            }
        } elseif (preg_match('/\/api\/requests\/pending/', $path) && $method === 'GET') {
            if ($auth->role === 'provider') {
                $result = $this->model->getPendingByProvider($auth->id);
            } elseif ($auth->role === 'user') {
                $result = $this->model->getPendingByUser($auth->id);
            } else {
                $result = $this->model->getPending();
            }
            echo json_encode(["success" => true, "data" => $result]);
        } elseif (preg_match('/\/api\/requests\/accept/', $path) && $method === 'POST') {
            $this->accept($auth);
        } elseif (preg_match('/\/api\/requests\/finalized/', $path) && $method === 'POST') {
            $this->finalized($auth);
        } elseif (preg_match('/\/api\/requests\/busy/', $path) && $method === 'POST') {
            $this->busy($auth);
        } elseif (preg_match('/\/api\/requests\/active/', $path) && $method === 'GET') {
            $this->active($auth);
        } elseif (preg_match('/\/api\/requests\/reject/', $path) && $method === 'POST') {
            $this->reject($auth);
        } elseif (preg_match('/\/api\/requests\/cancel/', $path) && $method === 'POST') {
            $this->cancel($auth);
        } elseif (preg_match('/\/api\/requests\/status\/\d+/', $path) && $method === 'GET') {
            $this->getStatus($auth);
        } elseif (preg_match('/\/api\/requests\/history/', $path) && $method === 'GET') {
            if ($auth->role === 'provider') {
                $this->historyByProvider($auth);
            } else {
                $this->historyUser($auth);
            }
        } else {
            echo json_encode(["error" => "Ruta no válida"]);
        }
    }

    private function create($auth) {
        $data = json_decode(file_get_contents("php://input"), true);
        $data['user_id'] = $auth->id;
        $newId = $this->model->create($data);
        if ($newId) {
            $providerId = $data['provider_id'] ?? null;
            if ($providerId) {
                $this->model->saveNotification([
                    'sender_id' => $auth->id,
                    'receiver_id' => $providerId,
                    'receiver_role' => 'provider',
                    'title' => 'Nueva solicitud',
                    'message' => 'Tienes una nueva solicitud pendiente'
                ]);
                $this->emitWs([
                    'receiver_id' => $providerId,
                    'receiver_role' => 'provider',
                    'title' => 'Nueva solicitud',
                    'message' => 'Tienes una nueva solicitud pendiente'
                ]);
            }
            echo json_encode(["success" => true, "requestId" => (int)$newId, "status" => "pending"]);
        } else {
            echo json_encode(["success" => false, "error" => "No se pudo crear la solicitud"]);
        }
    }

    private function mine($auth) {
        $result = $this->model->getByUser($auth->id);
        echo json_encode(["success" => true, "data" => $result]);
    }

    private function completed($auth) {
        $result = $this->model->getCompletedByUser($auth->id);
        echo json_encode(["success" => true, "data" => $result]);
    }

    private function completedByProvider($auth) {
        $result = $this->model->getCompletedByProvider($auth->id);
        echo json_encode(["success" => true, "data" => $result]);
    }

    private function active($auth) {
        if ($auth->role === 'provider') {
            $result = $this->model->getActiveByProvider($auth->id);
        } else {
            $result = $this->model->getActiveByUser($auth->id);
        }
        echo json_encode(["success" => true, "data" => $result]);
    }

    private function busy($auth) {
        $input = json_decode(file_get_contents("php://input"), true);
        $requestId = $input['id'] ?? null;
        if (!$requestId) {
            echo json_encode(["success" => false, "message" => "Falta el ID"]);
            return;
        }
        $updated = $this->model->updateStatus($requestId, $auth->id, 'busy');
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

    private function finalized($auth) {
        $input = json_decode(file_get_contents("php://input"), true);
        $requestId = $input['id'] ?? null;
        if (!$requestId) {
            echo json_encode(["success" => false, "message" => "Falta el ID"]);
            return;
        }
        $updated = $this->model->updateStatus($requestId, $auth->id, 'completed');
        $request = $this->model->getById($requestId);
        if ($updated && $request) {
            $this->model->saveNotification([
                'sender_id' => $auth->id,
                'receiver_id' => $request['user_id'],
                'receiver_role' => 'user',
                'title' => 'Servicio finalizado',
                'message' => 'El proveedor marcó el servicio como finalizado'
            ]);
            $this->emitWs([
                'receiver_id' => $request['user_id'],
                'receiver_role' => 'user',
                'title' => 'Servicio finalizado',
                'message' => 'El proveedor marcó el servicio como finalizado'
            ]);
        }
        echo json_encode(["success" => $updated]);
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

    private function cancel($auth) {
        $input = json_decode(file_get_contents("php://input"), true);
        $requestId = $input['id'] ?? null;
        if (!$requestId) {
            echo json_encode(["success" => false, "message" => "Falta el ID"]);
            return;
        }
        $actorRole = ($auth->role === 'provider') ? 'provider' : 'user';
        try {
            $cancelled = $this->model->cancel((int)$requestId, $auth->id, $actorRole);
            if ($cancelled) {
                $request = $this->model->getById($requestId);
                if ($request) {
                    $otherRole = ($actorRole === 'provider') ? 'user' : 'provider';
                    $otherId   = ($actorRole === 'provider') ? $request['user_id'] : $request['provider_id'];

                    $this->model->saveNotification([
                        'sender_id'     => $auth->id,
                        'receiver_id'   => $otherId,
                        'receiver_role' => $otherRole,
                        'title'         => 'Solicitud cancelada',
                        'message'       => "La solicitud fue cancelada por el {$actorRole}"
                    ]);
                    $this->emitWs([
                        'receiver_id'   => $otherId,
                        'receiver_role' => $otherRole,
                        'title'         => 'Solicitud cancelada',
                        'message'       => "La solicitud fue cancelada por el {$actorRole}"
                    ]);
                }
                echo json_encode(["success" => true]);
            } else {
                echo json_encode(["success" => false, "message" => "No se pudo cancelar"]);
            }
        } catch (Exception $e) {
            echo json_encode(["success" => false, "message" => $e->getMessage()]);
        }
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

    private function historyUser($auth) {
        $result = $this->model->getHistoryByUser($auth->id);
        echo json_encode(["success" => true, "data" => $result]);
    }

    private function historyByProvider($auth) {
        $result = $this->model->getHistoryByProvider($auth->id);
        echo json_encode(["success" => true, "data" => $result]);
    }

    private function unauthorized() {
        http_response_code(401);
        echo json_encode(["error" => "No autorizado"]);
    }
}
