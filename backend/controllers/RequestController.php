<?php
// controllers/RequestController.php
require_once __DIR__ . '/../models/ServiceRequest.php';
require_once __DIR__ . '/../utils/jwt.php';
require_once __DIR__ . '/../services/WebSocketService.php';

use services\WebSocketService;

class RequestController
{
    private $model;

    public function __construct()
    {
        $this->model = new ServiceRequest();
    }

    private function auth()
    {
        $headers = getallheaders();
        $auth = $headers['Authorization'] ?? '';
        if (!str_starts_with($auth, 'Bearer ')) return null;
        return JwtHandler::decode(str_replace("Bearer ", "", $auth));
    }

    public function handle($method)
    {
        $auth = $this->auth();
        if (!$auth) return $this->unauthorized();

        $path = $_SERVER['REQUEST_URI'];

        if (preg_match('/\/api\/requests\/confirm-payment/', $path) && $method === 'POST') {
            (new PaymentController())->handle('confirm-payment');
            return;
        }

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
        } elseif (preg_match('/\/api\/requests\/arrived/', $path) && $method === 'POST') {
            $this->arrived($auth);
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
        } elseif (preg_match('/\/api\/requests\/in_progress/', $path) && $method === 'POST') {
            $this->in_progress($auth);
        } elseif (preg_match('/\/api\/requests\/on_the_way/', $path) && $method === 'POST') {
            $this->on_the_way($auth);
        } else {
            echo json_encode(["error" => "Ruta no válida"]);
        }
    }

    private function updateStatus($auth, string $newStatus)
    {
        $data = json_decode(file_get_contents("php://input"), true);
        $requestId = $data['id'] ?? null;

        if (!$requestId) {
            echo json_encode(["success" => false, "message" => "Falta ID"]);
            return;
        }

        $updated = $this->model->updateStatus($requestId, $auth->id, $newStatus);
        $request = $this->model->getById($requestId);

        if ($updated && $request) {
            // Notificación al usuario
            WebSocketService::notify(
                $request['user_id'],
                'user',
                'Estado actualizado',
                "Tu solicitud cambió a: $newStatus",
                ['request_id' => (int)$requestId, 'status' => $newStatus]
            );

            echo json_encode(["success" => true]);
        } else {
            echo json_encode(["success" => false, "message" => "No autorizado"]);
        }
    }

    private function archiveAndClean(int $requestId, string $finalStatus): void
    {
        $this->model->close($requestId, $finalStatus);
    }

    private function create($auth)
    {
        // Lee los datos de la solicitud
        $data = json_decode(file_get_contents("php://input"), true);
        $data['user_id'] = $auth->id;
        $userId = $auth->id;
        $serviceId = $data['service_id'] ?? null;
        $providerId = $data['provider_id'] ?? null;

        // Validación básica
        if (!$serviceId || !$providerId) {
            http_response_code(400);
            echo json_encode(["success" => false, "error" => "Faltan datos obligatorios"]);
            return;
        }

        // Verifica si ya existe una solicitud activa
        $exists = $this->model->existsOpenRequest($userId, $serviceId, $providerId);
        if ($exists) {
            http_response_code(409);
            echo json_encode([
                "success" => false,
                "error" => "Ya tienes una solicitud activa para este servicio con este proveedor."
            ]);
            return;
        }

        // ✅ CREA LA SOLICITUD PRIMERO (esto es lo más importante)
        try {
            $newId = $this->model->create($data);
            if (!$newId) {
                throw new Exception("El método create() no devolvió un ID válido");
            }
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(["success" => false, "error" => "Error en la base de datos: " . $e->getMessage()]);
            return;
        }

        // ✅ OBTENER DATOS DEL SERVICIO (opcional, con logging)
        $serviceData = null;
        try {
            $serviceData = $this->model->getServiceDetailsForRequest($serviceId);
            error_log("DEBUG: Service details for ID $serviceId: " . json_encode($serviceData));
        } catch (Exception $e) {
            error_log("⚠️ No se pudo obtener datos del servicio para WebSocket: " . $e->getMessage());
        }

        // ✅ PREPARAR DATOS PARA WEBSOCKET (SIEMPRE, con valores seguros)
        $wsPayload = [
            'request_id' => (int)$newId,
            'service_id' => $serviceId,
            'service_title' => $serviceData['title'] ?? 'Servicio disponible',
            'service_description' => $serviceData['description'] ?? '',
            'service_price' => $serviceData['price'] ?? ($data['price'] ?? 0),
            'service_image_url' => $serviceData['image_url'] ?? null,
            'service_location' => $serviceData['location'] ?? 'Ubicación no especificada',
            'user_id' => $userId,
            'user_name' => $auth->name ?? 'Usuario',
            'user_phone' => $auth->phone ?? null,
            'status' => 'pending',
            'payment_status' => 'pending',
            'additional_details' => $data['additional_details'] ?? '',
            'created_at' => date('Y-m-d H:i:s')
        ];

        // ✅ EMITIR WEBSOCKET (SIEMPRE, con verificación de éxito)
        try {
            error_log("DEBUG: Emitiendo evento 'new_request_created' a provider_$providerId");
            $success = WebSocketService::emitEvent('provider', $providerId, 'new_request_created', $wsPayload);
            error_log("DEBUG: Resultado de emitEvent: " . ($success ? "✅ Éxito" : "❌ Falló"));
        } catch (Exception $e) {
            error_log("⚠️ Excepción en emitEvent: " . $e->getMessage());
        }

        // ✅ GUARDAR NOTIFICACIÓN EN BD (esto también es importante)
        try {
            $this->model->saveNotification([
                'sender_id' => $auth->id,
                'receiver_id' => $providerId,
                'receiver_role' => 'provider',
                'title' => 'Nueva solicitud',
                'message' => 'Tienes una nueva solicitud pendiente',
                'data_json' => json_encode([
                    'url' => '/dashboard/provider',
                    'action' => 'view_request',
                    'notification_type' => 'new_request'
                ])
            ]);
        } catch (Exception $e) {
            error_log("⚠️ No se pudo guardar notificación: " . $e->getMessage());
        }

        // ✅ RESPUESTA EXITOSA (lo más importante)
        echo json_encode([
            "success" => true,
            "requestId" => (int)$newId,
            "status" => "pending",
            "message" => "Solicitud creada correctamente"
        ]);
    }

    private function mine($auth)
    {
        $result = $this->model->getByUser($auth->id);
        echo json_encode(["success" => true, "data" => $result]);
    }

    private function completed($auth)
    {
        $result = $this->model->getCompletedByUser($auth->id);
        echo json_encode(["success" => true, "data" => $result]);
    }

    private function completedByProvider($auth)
    {
        $result = $this->model->getCompletedByProvider($auth->id);
        echo json_encode(["success" => true, "data" => $result]);
    }

    private function active($auth)
    {
        if ($auth->role === 'provider') {
            $result = $this->model->getActiveByProvider($auth->id);
        } else {
            $result = $this->model->getActiveByUser($auth->id);
        }
        echo json_encode(["success" => true, "data" => $result]);
    }

    private function busy($auth)
    {
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
                'message' => 'El proveedor está ocupado temporalmente',
                'data_json' => json_encode([
                    'url' => '/requests',
                    'action' => 'view_request',
                    'notification_type' => 'general'
                ])
            ]);

            WebSocketService::notify(
                $request['user_id'],
                'user',
                'Proveedor ocupado',
                'El proveedor está ocupado temporalmente'
            );

            // ✅ FIX: Emitir evento request_updated para cerrar el modal del cliente
            WebSocketService::emitEvent(
                'user',
                $request['user_id'],
                'request_updated',
                [
                    'request_id' => (int)$requestId,
                    'status' => 'busy',
                    'updated_at' => date('Y-m-d H:i:s')
                ]
            );
        }

        echo json_encode(["success" => $updated]);
    }

private function accept($auth)
{
    $data = json_decode(file_get_contents("php://input"), true);
    $requestId = $data['id'] ?? null;

    if (!$requestId) {
        echo json_encode(["success" => false, "message" => "Falta el ID"]);
        return;
    }

    $ok = $this->model->updateStatus($requestId, $auth->id, 'accepted');

    if ($ok) {
        
// Obtener datos completos como los usa /requests/active
$activeRequests = $this->model->getActiveByProvider($auth->id);

$request = null;
foreach ($activeRequests as $r) {
    if ((int)$r['id'] === (int)$requestId) {
        $request = $r;
        break;
    }
}


        if ($request) {
            // Notificación al usuario
            $this->model->saveNotification([
                'sender_id' => $auth->id,
                'receiver_id' => $request['user_id'],
                'receiver_role' => 'user',
                'title' => 'Solicitud aceptada',
                'message' => 'Tu solicitud fue aceptada por el proveedor',
                'data_json' => json_encode([
                    'url' => '/service/' . $request['service_id'],
                    'action' => 'view_service',
                    'notification_type' => 'service_update',
                    'service_id' => $request['service_id']
                ])
            ]);

            // ✅ EVENTO AL USUARIO (datos básicos)
            WebSocketService::emitEvent(
                'user',
                $request['user_id'],
                'request_updated',
                [
                    'request_id' => (int)$requestId,
                    'status' => 'accepted',
                    'updated_at' => date('Y-m-d H:i:s'),
                    'service_id' => $request['service_id']
                ]
            );

            // ✅ FIX: EVENTO AL PROVEEDOR con TODOS los datos necesarios
            WebSocketService::emitEvent(
                'provider',
                $auth->id,
                'request_updated',
                [
                    'request_id' => (int)$requestId,
                    'status' => 'accepted',
                    'updated_at' => date('Y-m-d H:i:s'),
                    // ✅ Datos completos para la tarjeta
                    'id' => (int)$requestId,
                    'service_id' => $request['service_id'],
                    'service_title' => $request['service_title'] ?? 'Servicio',
                    'service_description' => $request['service_description'] ?? '',
                    'service_price' => $request['service_price'] ?? 0,
                    'service_image_url' => $request['service_image_url'] ?? null,
                    'service_location' => $request['service_location'] ?? 'Ubicación no especificada',
                    'user_id' => $request['user_id'],
                    'user_name' => $request['user_name'] ?? 'Usuario',
                    'user_phone' => $request['user_phone'] ?? null,
                    'payment_status' => $request['payment_status'] ?? 'pending',
                    'additional_details' => $request['additional_details'] ?? '',
                    'created_at' => $request['created_at'] ?? date('Y-m-d H:i:s')
                ]
            );
        }
    }

    echo json_encode(["success" => $ok]);
}


    private function finalized($auth)
    {
        try {
            $input = json_decode(file_get_contents("php://input"), true);
            $requestId = $input['id'] ?? null;

            if (!$requestId) {
                echo json_encode(["success" => false, "message" => "Falta el ID"]);
                return;
            }

            $request = $this->model->getById($requestId);
            if (!$request) {
                echo json_encode(["success" => false, "message" => "Solicitud no encontrada"]);
                return;
            }

            // Validación de pago
            if (($request['payment_status'] ?? 'pending') !== 'paid') {
                http_response_code(403);
                echo json_encode([
                    "success" => false,
                    "message" => "No se puede finalizar el servicio sin pago confirmado"
                ]);
                return;
            }

            $updated = $this->model->updateStatus($requestId, $auth->id, 'completed');
            if (!$updated) {
                echo json_encode(["success" => false, "message" => "No se pudo finalizar"]);
                return;
            }

            $request = $this->model->getById($requestId);
            if ($request) {
                // Notificación al usuario
                WebSocketService::notify(
                    $request['user_id'],
                    'user',
                    'Servicio finalizado',
                    'El proveedor marcó el servicio como finalizado',
                    ['service_id' => $request['service_id']]
                );

                // Evento para abrir modal de calificación
                WebSocketService::emitEvent(
                    'user',
                    $request['user_id'],
                    'open_rating_modal',
                    [
                        'request_id' => $requestId,
                        'from_id' => $auth->id,
                        'from_role' => $auth->role,
                        'message' => 'Solicitar calificación'
                    ]
                );
            }

            $this->archiveAndClean((int)$requestId, 'completed');
            echo json_encode(["success" => true]);
        } catch (Exception $e) {
            echo json_encode(["success" => false, "message" => $e->getMessage()]);
        }
    }

    private function in_progress($auth)
    {
        $input = json_decode(file_get_contents("php://input"), true);
        $requestId = $input['id'] ?? null;

        if (!$requestId) {
            echo json_encode(["success" => false, "message" => "Falta el ID de la solicitud"]);
            return;
        }

        $updated = $this->model->updateStatus($requestId, $auth->id, 'in_progress');
        $request = $this->model->getById($requestId);

        if ($updated && $request) {
            // Notificación al usuario
            WebSocketService::notify(
                $request['user_id'],
                'user',
                'Servicio en progreso',
                'El proveedor ha comenzado el servicio'
            );

            // Evento al usuario
            WebSocketService::emitEvent(
                'user',
                $request['user_id'],
                'request_updated',
                [
                    'request_id' => (int)$requestId,
                    'status' => 'in_progress',
                    'updated_at' => date('Y-m-d H:i:s')
                ]
            );

            // Evento al provider (para sincronizar su dashboard)
            WebSocketService::emitEvent(
                'provider',
                $auth->id,
                'request_updated',
                [
                    'request_id' => (int)$requestId,
                    'status' => 'in_progress',
                    'updated_at' => date('Y-m-d H:i:s')
                ]
            );
        }

        echo json_encode(["success" => $updated]);
    }

    private function on_the_way($auth)
    {
        $input = json_decode(file_get_contents("php://input"), true);
        $requestId = $input['id'] ?? null;

        if (!$requestId) {
            echo json_encode(["success" => false, "message" => "Falta el ID de la solicitud"]);
            return;
        }

        $updated = $this->model->updateStatus($requestId, $auth->id, 'on_the_way');
        $request = $this->model->getById($requestId);

        if ($updated && $request) {
            // Notificación al usuario
            WebSocketService::notify(
                $request['user_id'],
                'user',
                'Proveedor en camino',
                'El proveedor está en camino a tu ubicación'
            );

            // Evento al usuario
            WebSocketService::emitEvent(
                'user',
                $request['user_id'],
                'request_updated',
                [
                    'request_id' => (int)$requestId,
                    'status' => 'on_the_way',
                    'updated_at' => date('Y-m-d H:i:s')
                ]
            );

            // Evento al provider
            WebSocketService::emitEvent(
                'provider',
                $auth->id,
                'request_updated',
                [
                    'request_id' => (int)$requestId,
                    'status' => 'on_the_way',
                    'updated_at' => date('Y-m-d H:i:s')
                ]
            );
        }

        echo json_encode(["success" => $updated]);
    }

    private function arrived($auth)
    {
        $input = json_decode(file_get_contents("php://input"), true);
        $requestId = $input['id'] ?? null;

        if (!$requestId) {
            echo json_encode(["success" => false, "message" => "Falta el ID de la solicitud"]);
            return;
        }

        $updated = $this->model->updateStatus($requestId, $auth->id, 'arrived');
        $request = $this->model->getById($requestId);

        if ($updated && $request) {
            // Notificación al usuario
            WebSocketService::notify(
                $request['user_id'],
                'user',
                'Proveedor llegó',
                'El proveedor ha llegado a tu ubicación'
            );

            // Evento al usuario
            WebSocketService::emitEvent(
                'user',
                $request['user_id'],
                'request_updated',
                [
                    'request_id' => (int)$requestId,
                    'status' => 'arrived',
                    'updated_at' => date('Y-m-d H:i:s')
                ]
            );

            // Evento al provider
            WebSocketService::emitEvent(
                'provider',
                $auth->id,
                'request_updated',
                [
                    'request_id' => (int)$requestId,
                    'status' => 'arrived',
                    'updated_at' => date('Y-m-d H:i:s')
                ]
            );
        }

        echo json_encode(["success" => $updated]);
    }

    private function reject($auth)
    {
        $data = json_decode(file_get_contents("php://input"), true);
        $requestId = $data['id'] ?? null;

        if (!$requestId) {
            echo json_encode(["success" => false, "message" => "Falta el ID"]);
            return;
        }

        try {
            $ok = $this->model->updateStatus($requestId, $auth->id, 'rejected');

            if (!$ok) {
                echo json_encode(["success" => false, "message" => "No se pudo rechazar"]);
                return;
            }

            $request = $this->model->getById($requestId);
            if ($request) {
                // Notificación al usuario
                WebSocketService::notify(
                    $request['user_id'],
                    'user',
                    'Solicitud rechazada',
                    'Tu solicitud fue rechazada por el proveedor'
                );

                // ✅ FIX: Estructura corregida para coincidir con 'accept'
                WebSocketService::emitEvent(
                    'user',
                    $request['user_id'],
                    'request_updated',
                    [
                        'request_id' => (int)$requestId,
                        'status' => 'rejected',
                        'updated_at' => date('Y-m-d H:i:s')
                    ]
                );

                // ✅ Evento al PROVEEDOR
                WebSocketService::emitEvent(
                    'provider',
                    $auth->id,
                    'request_updated',
                    [
                        'request_id' => (int)$requestId,
                        'status' => 'rejected',
                        'updated_at' => date('Y-m-d H:i:s')
                    ]
                );
            }

            // ✅ Ejecutar limpieza en segundo plano sin interrumpir la respuesta
            try {
                $this->archiveAndClean((int)$requestId, 'rejected');
            } catch (Exception $e) {
                error_log("⚠️ archiveAndClean falló en reject (no crítico): " . $e->getMessage());
            }

            echo json_encode(["success" => true, "message" => "Solicitud rechazada"]);
        } catch (Exception $e) {
            echo json_encode(["success" => false, "message" => $e->getMessage()]);
        }
    }

    private function cancel($auth)
    {
        $input = json_decode(file_get_contents("php://input"), true);
        $requestId = $input['id'] ?? null;

        if (!$requestId) {
            echo json_encode(["success" => false, "message" => "Falta el ID"]);
            return;
        }

        $actorRole = ($auth->role === 'provider') ? 'provider' : 'user';

        try {
            $cancelled = $this->model->cancel((int)$requestId, $auth->id, $actorRole);

            if (!$cancelled) {
                echo json_encode(["success" => false, "message" => "No se pudo cancelar"]);
                return;
            }

            $request = $this->model->getById($requestId);
            if ($request) {
                $otherRole = ($actorRole === 'provider') ? 'user' : 'provider';
                $otherId = ($actorRole === 'provider') ? $request['user_id'] : $request['provider_id'];

                // Notificación al otro actor
                WebSocketService::notify(
                    $otherId,
                    $otherRole,
                    'Solicitud cancelada',
                    "La solicitud fue cancelada por el {$actorRole}"
                );

                // Evento al otro actor
                WebSocketService::emitEvent(
                    $otherRole,
                    $otherId,
                    'request_updated',
                    [
                        'request_id' => (int)$requestId,
                        'status' => 'cancelled',
                        'updated_at' => date('Y-m-d H:i:s'),
                        'cancelled_by' => $actorRole
                    ]
                );
            }

            $this->archiveAndClean((int)$requestId, 'cancelled');
            echo json_encode(["success" => true]);
        } catch (Exception $e) {
            echo json_encode(["success" => false, "message" => $e->getMessage()]);
        }
    }

    private function getStatus($auth)
    {
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

    private function unauthorized()
    {
        http_response_code(401);
        echo json_encode(["error" => "No autorizado"]);
    }
}
