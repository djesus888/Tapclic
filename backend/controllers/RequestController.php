<?php
// controllers/RequestController.php
require_once __DIR__ . '/../models/ServiceRequest.php';
require_once __DIR__ . '/../utils/jwt.php';
require_once __DIR__ . '/../services/WebSocketService.php';
require_once __DIR__ . '/../utils/AuditLogger.php';
require_once __DIR__ . '/../middleware/Auth.php';


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
            // ✅ Guardar notificación en BD y obtener el ID real
            $notifId = $this->model->saveNotificationReturnId([
                'sender_id' => $auth->id,
                'receiver_id' => $request['user_id'],
                'receiver_role' => 'user',
                'title' => 'Estado actualizado',
                'message' => "Tu solicitud cambió a: $newStatus",
                'data_json' => json_encode([
                    'request_id' => (int)$requestId,
                    'status' => $newStatus,
                    'notification_type' => 'status_updated'
                ])
            ]);

            // Notificación al usuario con ID real de BD
            WebSocketService::sendNotification(
                'user',
                $request['user_id'],
                'Estado actualizado',
                "Tu solicitud cambió a: $newStatus",
                [
                    'notification_id' => $notifId,
                    'request_id' => (int)$requestId,
                    'status' => $newStatus
                ]
            );

            WebSocketService::emitToUser(
                'user',
                $request['user_id'],
                'request_updated',
                [
                    'request' => [
                        'id' => (int)$requestId,
                        'status' => $newStatus,
                        'updated_at' => date('Y-m-d H:i:s')
                    ]
                ]
            );

            if ($request['provider_id']) {
                WebSocketService::emitToUser(
                    'provider',
                    $request['provider_id'],
                    'request_updated',
                    [
                        'request' => [
                            'id' => (int)$requestId,
                            'status' => $newStatus,
                            'updated_at' => date('Y-m-d H:i:s')
                        ]
                    ]
                );
            }

            echo json_encode(["success" => true]);
        } else {
            echo json_encode(["success" => false, "message" => "No autorizado"]);
        }
    }

    private function archiveAndClean(int $requestId, string $finalStatus): void
    {
        $this->model->close($requestId, $finalStatus);
    }

    public function getDeliveryOrders() {
        $auth = Auth::verify();
        if (!$auth || !isset($auth->staff_id)) {
            http_response_code(403);
            echo json_encode(["error" => "No autorizado"]);
            return;
        }
        $orders = $this->model->getByStaffId($auth->staff_id);
        echo json_encode(["success" => true, "orders" => $orders]);
    }

    public function getDeliveryHistory() {
        $auth = Auth::verify();
        if (!isset($auth->staff_id)) {
            http_response_code(403);
            echo json_encode(["error" => "Solo personal autorizado"]);
            return;
        }
        $orders = $this->model->getHistoryByStaffId($auth->staff_id);
        echo json_encode(["success" => true, "orders" => $orders]);
    }

    public function updateDeliveryStatus() {
        $auth = Auth::verify();
        // Verificar que sea un staff (delivery)
        if (!isset($auth->staff_id)) {
            http_response_code(403);
            echo json_encode(["error" => "Solo personal autorizado"]);
            return;
        }

        $data = json_decode(file_get_contents("php://input"), true);
        $requestId = $data['request_id'] ?? null;
        $newStatus = $data['status'] ?? null;

        $validStatuses = ['in_progress', 'on_the_way', 'arrived', 'finalized', 'completed'];
        if (!$requestId || !in_array($newStatus, $validStatuses)) {
            http_response_code(400);
            echo json_encode(["error" => "Datos inválidos"]);
            return;
        }

        // Verificar que el pedido está asignado a este staff
        $request = $this->model->getById($requestId);
        if (!$request || $request['assigned_staff_id'] != $auth->staff_id) {
            http_response_code(403);
            echo json_encode(["error" => "Este pedido no te está asignado"]);
            return;
        }

        $ok = $this->model->updateStatus($requestId, $auth->staff_id, $newStatus);

        if ($ok) {
            // ✅ RESTAURADO: Emitir WebSocket con prefijo 'staff_'
            try {
                require_once __DIR__ . '/../services/WebSocketService.php';
                \Services\WebSocketService::emitToUser('staff_' . ($staff['role'] ?? 'delivery'), $auth->staff_id, 'request_updated', [
                    'request_id' => $requestId,
                    'status' => $newStatus,
                    'updated_at' => date('Y-m-d H:i:s')
                ]);
            } catch (\Exception $e) {
                error_log("⚠️ No se pudo emitir WebSocket: " . $e->getMessage());
            }

            // Mensajes según el estado
            $statusMessages = [
                'in_progress' => '🚛 El delivery ha iniciado la entrega',
                'on_the_way'  => '🛵 El delivery va en camino',
                'arrived'     => '📍 El delivery ha llegado al destino',
                'finalized'   => '✅ El delivery ha entregado el pedido',
                'completed'   => '✅ Entrega completada',
            ];
            $message = $statusMessages[$newStatus] ?? "Estado actualizado: {$newStatus}";

            // ✅ Notificar al cliente (user)
            try {
                $this->model->saveNotification([
                    'sender_id' => $auth->staff_id,
                    'receiver_id' => $request['user_id'],
                    'receiver_role' => 'user',
                    'title' => '📦 Actualización de tu pedido',
                    'message' => $message,
                    'data_json' => json_encode([
                        'url' => '/orders/' . $requestId,
                        'action' => 'view_request',
                        'notification_type' => 'status_updated',
                        'request_id' => $requestId,
                        'status' => $newStatus
                    ])
                ]);
            } catch (Exception $e) {
                error_log("⚠️ No se pudo notificar al cliente: " . $e->getMessage());
            }

            // ✅ Notificar al proveedor
            try {
                $this->model->saveNotification([
                    'sender_id' => $auth->staff_id,
                    'receiver_id' => $request['provider_id'],
                    'receiver_role' => 'provider',
                    'title' => '📦 Delivery actualizó estado',
                    'message' => $message,
                    'data_json' => json_encode([
                        'url' => '/orders/' . $requestId,
                        'action' => 'view_request',
                        'notification_type' => 'status_updated',
                        'request_id' => $requestId,
                        'status' => $newStatus
                    ])
                ]);
            } catch (Exception $e) {
                error_log("⚠️ No se pudo notificar al proveedor: " . $e->getMessage());
            }

            echo json_encode(["success" => true, "message" => "Estado actualizado"]);
        } else {
            http_response_code(500);
            echo json_encode(["error" => "Error al actualizar"]);
        }
    }

    public function assignDelivery() {
        $auth = Auth::verify();
        $data = json_decode(file_get_contents("php://input"), true);
        $requestId = $data['request_id'] ?? null;
        $staffId = $data['staff_id'] ?? null;

        if (!$requestId || !$staffId) {
            http_response_code(400);
            echo json_encode(["error" => "Faltan request_id o staff_id"]);
            return;
        }

        // Verificar que el pedido es del proveedor
        $request = $this->model->getById($requestId);
        if (!$request || $request['provider_id'] != $auth->id) {
            http_response_code(403);
            echo json_encode(["error" => "No autorizado"]);
            return;
        }

        // Verificar que el staff pertenece al proveedor
        require_once __DIR__ . '/../models/ProviderStaff.php';
        $staffModel = new ProviderStaff();
        $staff = $staffModel->findById($staffId);
        if (!$staff || $staff['provider_id'] != $auth->id) {
            http_response_code(403);
            echo json_encode(["error" => "Delivery no válido"]);
            return;
        }

        // Asignar delivery
        $ok = $this->model->assignStaff($requestId, $staffId);

        if ($ok) {
            AuditLogger::log($auth->id, 'delivery_assigned', 'Delivery asignado', "Pedido: {$requestId} → Staff: {$staffId}");

            // ✅ RESTAURADO: Emitir evento WebSocket al staff asignado con prefijo 'staff_'
            try {
                require_once __DIR__ . '/../services/WebSocketService.php';
                \Services\WebSocketService::emitToUser('staff_' . ($staff['role'] ?? 'delivery'), $staffId, 'new-notification', [
                    'event' => 'delivery_assigned',
                    'title' => '🚚 Nuevo pedido asignado',
                    'message' => "Se te ha asignado un nuevo pedido #{$requestId}",
                    'notification_type' => 'delivery_assigned',
                    'url' => '/delivery/orders',
                    'action' => 'view_delivery',
                    'request_id' => $requestId,
                    'timestamp' => date('Y-m-d H:i:s')
                ]);

                // También emitir request_updated al staff
                \Services\WebSocketService::emitToUser('staff_' . ($staff['role'] ?? 'delivery'), $staffId, 'request_updated', [
                    'request_id' => $requestId,
                    'status' => $request['status'],
                    'updated_at' => date('Y-m-d H:i:s')
                ]);
            } catch (\Exception $e) {
                error_log("⚠️ No se pudo emitir WebSocket al staff: " . $e->getMessage());
            }

            echo json_encode(["success" => true, "message" => "Delivery asignado correctamente"]);

            // ✅ RESTAURADO: Notificar al staff asignado con prefijo 'staff_' en receiver_role
            try {
                $staffData = $staffModel->findById($staffId);
                $this->model->saveNotification([
                    'sender_id' => $auth->id,
                    'receiver_id' => $staffId,
                    'receiver_role' => 'staff_' . ($staffData['role'] ?? 'delivery'),
                    'title' => '🚚 Nuevo pedido asignado',
                    'message' => "Se te ha asignado un nuevo pedido # {$requestId}",
                    'data_json' => json_encode([
                        'url' => '/delivery/orders',
                        'action' => 'view_delivery',
                        'notification_type' => 'delivery_assigned',
                        'request_id' => $requestId
                    ])
                ]);
            } catch (Exception $e) {
                error_log("⚠️ No se pudo notificar al staff: " . $e->getMessage());
            }

        } else {
            http_response_code(500);
            echo json_encode(["error" => "Error al asignar delivery"]);
        }
    }

    private function create($auth)
    {
        $data = json_decode(file_get_contents("php://input"), true);
        $data['user_id'] = $auth->id;
        $userId = $auth->id;
        $serviceId = $data['service_id'] ?? null;
        $providerId = $data['provider_id'] ?? null;

        if (!$serviceId || !$providerId) {
            http_response_code(400);
            echo json_encode(["success" => false, "error" => "Faltan datos obligatorios"]);
            return;
        }

        $exists = $this->model->existsOpenRequest($userId, $serviceId, $providerId);
        if ($exists) {
            http_response_code(409);
            echo json_encode([
                "success" => false,
                "error" => "Ya tienes una solicitud activa para este servicio con este proveedor."
            ]);
            return;
        }

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

        // ✅ LOG
        AuditLogger::log($auth->id, 'request_created', 'Solicitud creada', "ID: {$newId} - Servicio: {$serviceId} - Proveedor: {$providerId}");

        $serviceData = null;
        try {
            $serviceData = $this->model->getServiceDetailsForRequest($serviceId);
        } catch (Exception $e) {
            error_log("⚠️ No se pudo obtener datos del servicio para WebSocket: " . $e->getMessage());
        }

        // 1. Emitir evento new_request_created al proveedor (datos de la solicitud)
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

        $wsResult = WebSocketService::emitToUser('provider', $providerId, 'new_request_created', $wsPayload);
        if (!$wsResult['success']) {
            error_log("⚠️ [RequestController] No se notificó al proveedor {$providerId}: {$wsResult['message']}");
        }

        // 2. Guardar notificación en BD y enviar por WebSocket con ID real
        try {
            $notifData = [
                'sender_id' => $auth->id,
                'receiver_id' => $providerId,
                'receiver_role' => 'provider',
                'title' => 'Nueva solicitud',
                'message' => 'Tienes una nueva solicitud pendiente',
                'data_json' => json_encode([
                    'url' => '/orders/' . $newId,
                    'action' => 'view_request',
                    'notification_type' => 'new_request'
                ])
            ];

            // ✅ Obtener el ID real de BD
            $notifId = $this->model->saveNotificationReturnId($notifData);

            WebSocketService::sendNotification(
                'provider',
                $providerId,
                $notifData['title'],
                $notifData['message'],
                [
                    'notification_id' => $notifId,
                    'notification_type' => 'new_request',
                    'url' => '/orders/' . $newId,
                    'action' => 'view_request',
                    'request_id' => (int)$newId,
                    'service_id' => $serviceId
                ]
            );
        } catch (Exception $e) {
            error_log("⚠️ No se pudo guardar/enviar notificación: " . $e->getMessage());
        }

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
            // ✅ LOG
            AuditLogger::log($auth->id, 'request_busy', 'Proveedor ocupado', "Solicitud ID: {$requestId}");

            // ✅ Guardar y obtener ID real de BD
            $notifId = $this->model->saveNotificationReturnId([
                'sender_id' => $auth->id,
                'receiver_id' => $request['user_id'],
                'receiver_role' => 'user',
                'title' => 'Proveedor ocupado',
                'message' => 'El proveedor está ocupado temporalmente',
                'data_json' => json_encode([
                    'url' => '/orders/' . $requestId,
                    'action' => 'view_request',
                    'notification_type' => 'general'
                ])
            ]);

            WebSocketService::sendNotification(
                'user',
                $request['user_id'],
                'Proveedor ocupado',
                'El proveedor está ocupado temporalmente',
                [
                    'notification_id' => $notifId,
                    'notification_type' => 'general',
                    'url' => '/orders/' . $requestId,
                    'action' => 'view_request',
                    'request_id' => (int)$requestId
                ]
            );

            WebSocketService::emitToUser('user', $request['user_id'], 'request_updated', ['request' => ['id' => (int)$requestId, 'status' => 'busy', 'updated_at' => date('Y-m-d H:i:s')]]);
            WebSocketService::emitToUser('provider', $auth->id, 'request_updated', ['request' => ['id' => (int)$requestId, 'status' => 'busy', 'updated_at' => date('Y-m-d H:i:s')]]);
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
            // ✅ LOG
            AuditLogger::log($auth->id, 'request_accepted', 'Solicitud aceptada', "Solicitud ID: {$requestId}");

            $activeRequests = $this->model->getActiveByProvider($auth->id);
            $request = null;
            foreach ($activeRequests as $r) {
                if ((int)$r['id'] === (int)$requestId) { $request = $r; break; }
            }

            if ($request) {
                // ✅ Guardar y obtener ID real de BD
                $notifId = $this->model->saveNotificationReturnId([
                    'sender_id' => $auth->id,
                    'receiver_id' => $request['user_id'],
                    'receiver_role' => 'user',
                    'title' => 'Solicitud aceptada',
                    'message' => 'Tu solicitud fue aceptada por el proveedor',
                    'data_json' => json_encode(['url' => '/service/' . $request['service_id'], 'action' => 'view_service', 'notification_type' => 'service_update', 'service_id' => $request['service_id']])
                ]);

                WebSocketService::sendNotification(
                    'user',
                    $request['user_id'],
                    'Solicitud aceptada',
                    'Tu solicitud fue aceptada por el proveedor',
                    [
                        'notification_id' => $notifId,
                        'notification_type' => 'service_update',
                        'url' => '/service/' . $request['service_id'],
                        'action' => 'view_service',
                        'service_id' => $request['service_id']
                    ]
                );

                WebSocketService::emitToUser('user', $request['user_id'], 'request_updated', ['request' => ['id' => (int)$requestId, 'status' => 'accepted', 'updated_at' => date('Y-m-d H:i:s'), 'service_id' => $request['service_id']]]);
                WebSocketService::emitToUser('provider', $auth->id, 'request_updated', ['request' => ['id' => (int)$requestId, 'status' => 'accepted', 'updated_at' => date('Y-m-d H:i:s'), 'service_id' => $request['service_id']]]);
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

            if (($request['payment_status'] ?? 'pending') !== 'paid') {
                http_response_code(403);
                echo json_encode(["success" => false, "message" => "No se puede finalizar el servicio sin pago confirmado"]);
                return;
            }

            $updated = $this->model->updateStatus($requestId, $auth->id, 'completed');
            if (!$updated) {
                echo json_encode(["success" => false, "message" => "No se pudo finalizar"]);
                return;
            }

            // ✅ LOG
            AuditLogger::log($auth->id, 'request_completed', 'Servicio finalizado', "Solicitud ID: {$requestId}");

            $request = $this->model->getById($requestId);
            if ($request) {
                // 1. Guardar notificación en BD (solo una vez) y obtener ID real
                $notifId = $this->model->saveNotificationReturnId([
                    'sender_id' => $auth->id,
                    'receiver_id' => $request['user_id'],
                    'receiver_role' => 'user',
                    'title' => 'Servicio finalizado - ¡Califica tu experiencia!',
                    'message' => 'El proveedor marcó el servicio como finalizado.',
                    'data_json' => json_encode([
                        'type' => 'rating',
                        'notification_type' => 'open_rating',
                        'url' => '/orders/' . $requestId,
                        'action' => 'open_rating_modal',
                        'request_id' => (int)$requestId,
                        'provider_id' => $auth->id,
                        'from_role' => $auth->role
                    ])
                ]);

                // 2. Emitir evento open_rating_modal al USUARIO con notification_id
                try {
                    WebSocketService::emitToUser(
                        'user',
                        $request['user_id'],
                        'open_rating_modal',
                        [
                            'notification_id' => $notifId,
                            'title' => 'Servicio finalizado - ¡Califica tu experiencia!',
                            'message' => 'El proveedor marcó el servicio como finalizado. ¿Quieres dejar una reseña?',
                            'request_id' => (int)$requestId,
                            'provider_id' => $auth->id,
                            'from_role' => $auth->role,
                            'target_role' => 'provider',
                            'url' => '/orders/' . $requestId,
                            'action' => 'open_rating_modal',
                            'notification_type' => 'open_rating'
                        ]
                    );
                } catch (Exception $e) {
                    error_log("❌ [Finalized] Error notificando al user: " . $e->getMessage());
                }

                // 3. Emitir evento open_rating_modal al PROVEEDOR
                try {
                    WebSocketService::emitToUser(
                        'provider',
                        $auth->id,
                        'open_rating_modal',
                        [
                            'notification_id' => $notifId,
                            'title' => 'Servicio finalizado - ¡Califica al cliente!',
                            'message' => 'Has completado el servicio. ¿Quieres calificar a tu cliente?',
                            'request_id' => (int)$requestId,
                            'provider_id' => $auth->id,
                            'from_role' => $auth->role,
                            'target_role' => 'user',
                            'url' => '/orders/' . $requestId,
                            'action' => 'open_rating_modal',
                            'notification_type' => 'open_rating'
                        ]
                    );
                } catch (Exception $e) {
                    error_log("❌ [Finalized] Error notificando al provider: " . $e->getMessage());
                }

                // 4. Emitir request_updated a AMBOS
                $payload = [
                    'request' => [
                        'id' => (int)$requestId,
                        'status' => 'completed',
                        'updated_at' => date('Y-m-d H:i:s')
                    ]
                ];

                try {
                    WebSocketService::emitToUser('user', $request['user_id'], 'request_updated', $payload);
                } catch (Exception $e) {
                    error_log("❌ [Finalized] Error emit user: " . $e->getMessage());
                }

                try {
                    WebSocketService::emitToUser('provider', $auth->id, 'request_updated', $payload);
                } catch (Exception $e) {
                    error_log("❌ [Finalized] Error emit provider: " . $e->getMessage());
                }

                // 5. Notificar al ADMIN
                try {
                    WebSocketService::emitToRole('admin', 'request_updated', $payload);
                } catch (Exception $e) {
                    error_log("❌ [Finalized] Error notificando admin: " . $e->getMessage());
                }
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
        if (!$requestId) { echo json_encode(["success" => false, "message" => "Falta el ID"]); return; }

        $updated = $this->model->updateStatus($requestId, $auth->id, 'in_progress');
        $request = $this->model->getById($requestId);

        if ($updated && $request) {
            // ✅ Guardar y obtener ID real de BD
            $notifId = $this->model->saveNotificationReturnId([
                'sender_id' => $auth->id,
                'receiver_id' => $request['user_id'],
                'receiver_role' => 'user',
                'title' => 'Servicio en progreso',
                'message' => 'El proveedor ha comenzado el servicio',
                'data_json' => json_encode([
                    'url' => '/orders/' . $requestId,
                    'action' => 'view_request',
                    'notification_type' => 'status_updated',
                    'request_id' => (int)$requestId,
                    'status' => 'in_progress'
                ])
            ]);

            WebSocketService::sendNotification(
                'user',
                $request['user_id'],
                'Servicio en progreso',
                'El proveedor ha comenzado el servicio',
                [
                    'notification_id' => $notifId,
                    'notification_type' => 'status_updated',
                    'url' => '/orders/' . $requestId,
                    'action' => 'view_request',
                    'request_id' => (int)$requestId,
                    'status' => 'in_progress'
                ]
            );

            WebSocketService::emitToUser('user', $request['user_id'], 'request_updated', ['request' => ['id' => (int)$requestId, 'status' => 'in_progress', 'updated_at' => date('Y-m-d H:i:s')]]);
            WebSocketService::emitToUser('provider', $auth->id, 'request_updated', ['request' => ['id' => (int)$requestId, 'status' => 'in_progress', 'updated_at' => date('Y-m-d H:i:s')]]);
        }
        echo json_encode(["success" => $updated]);
    }

    private function on_the_way($auth)
    {
        $input = json_decode(file_get_contents("php://input"), true);
        $requestId = $input['id'] ?? null;
        if (!$requestId) { echo json_encode(["success" => false, "message" => "Falta el ID"]); return; }

        $updated = $this->model->updateStatus($requestId, $auth->id, 'on_the_way');
        $request = $this->model->getById($requestId);

        if ($updated && $request) {
            // ✅ Guardar y obtener ID real de BD
            $notifId = $this->model->saveNotificationReturnId([
                'sender_id' => $auth->id,
                'receiver_id' => $request['user_id'],
                'receiver_role' => 'user',
                'title' => 'Proveedor en camino',
                'message' => 'El proveedor está en camino',
                'data_json' => json_encode([
                    'url' => '/orders/' . $requestId,
                    'action' => 'view_request',
                    'notification_type' => 'status_updated',
                    'request_id' => (int)$requestId,
                    'status' => 'on_the_way'
                ])
            ]);

            WebSocketService::sendNotification(
                'user',
                $request['user_id'],
                'Proveedor en camino',
                'El proveedor está en camino',
                [
                    'notification_id' => $notifId,
                    'notification_type' => 'status_updated',
                    'url' => '/orders/' . $requestId,
                    'action' => 'view_request',
                    'request_id' => (int)$requestId,
                    'status' => 'on_the_way'
                ]
            );

            WebSocketService::emitToUser('user', $request['user_id'], 'request_updated', ['request' => ['id' => (int)$requestId, 'status' => 'on_the_way', 'updated_at' => date('Y-m-d H:i:s')]]);
            WebSocketService::emitToUser('provider', $auth->id, 'request_updated', ['request' => ['id' => (int)$requestId, 'status' => 'on_the_way', 'updated_at' => date('Y-m-d H:i:s')]]);
        }
        echo json_encode(["success" => $updated]);
    }

    private function arrived($auth)
    {
        $input = json_decode(file_get_contents("php://input"), true);
        $requestId = $input['id'] ?? null;
        if (!$requestId) { echo json_encode(["success" => false, "message" => "Falta el ID"]); return; }

        $updated = $this->model->updateStatus($requestId, $auth->id, 'arrived');
        $request = $this->model->getById($requestId);

        if ($updated && $request) {
            // ✅ Guardar y obtener ID real de BD
            $notifId = $this->model->saveNotificationReturnId([
                'sender_id' => $auth->id,
                'receiver_id' => $request['user_id'],
                'receiver_role' => 'user',
                'title' => 'Proveedor llegó',
                'message' => 'El proveedor ha llegado',
                'data_json' => json_encode([
                    'url' => '/orders/' . $requestId,
                    'action' => 'view_request',
                    'notification_type' => 'status_updated',
                    'request_id' => (int)$requestId,
                    'status' => 'arrived'
                ])
            ]);

            WebSocketService::sendNotification(
                'user',
                $request['user_id'],
                'Proveedor llegó',
                'El proveedor ha llegado',
                [
                    'notification_id' => $notifId,
                    'notification_type' => 'status_updated',
                    'url' => '/orders/' . $requestId,
                    'action' => 'view_request',
                    'request_id' => (int)$requestId,
                    'status' => 'arrived'
                ]
            );

            WebSocketService::emitToUser('user', $request['user_id'], 'request_updated', ['request' => ['id' => (int)$requestId, 'status' => 'arrived', 'updated_at' => date('Y-m-d H:i:s')]]);
            WebSocketService::emitToUser('provider', $auth->id, 'request_updated', ['request' => ['id' => (int)$requestId, 'status' => 'arrived', 'updated_at' => date('Y-m-d H:i:s')]]);
        }
        echo json_encode(["success" => $updated]);
    }

    private function reject($auth)
    {
        $data = json_decode(file_get_contents("php://input"), true);
        $requestId = $data['id'] ?? null;
        if (!$requestId) { echo json_encode(["success" => false, "message" => "Falta el ID"]); return; }

        try {
            $ok = $this->model->updateStatus($requestId, $auth->id, 'rejected');
            if (!$ok) { echo json_encode(["success" => false, "message" => "No se pudo rechazar"]); return; }

            // ✅ LOG
            AuditLogger::log($auth->id, 'request_rejected', 'Solicitud rechazada', "Solicitud ID: {$requestId}");

            $request = $this->model->getById($requestId);
            if ($request) {
                // ✅ Guardar y obtener ID real de BD
                $notifId = $this->model->saveNotificationReturnId([
                    'sender_id' => $auth->id,
                    'receiver_id' => $request['user_id'],
                    'receiver_role' => 'user',
                    'title' => 'Solicitud rechazada',
                    'message' => 'Tu solicitud fue rechazada',
                    'data_json' => json_encode([
                        'url' => '/orders/' . $requestId,
                        'action' => 'view_request',
                        'notification_type' => 'status_updated',
                        'request_id' => (int)$requestId,
                        'status' => 'rejected'
                    ])
                ]);

                // Notificaciones independientes
                $wsResults = [];

                try {
                    $wsResults['notif'] = WebSocketService::sendNotification(
                        'user',
                        $request['user_id'],
                        'Solicitud rechazada',
                        'Tu solicitud fue rechazada',
                        [
                            'notification_id' => $notifId,
                            'notification_type' => 'status_updated',
                            'url' => '/orders/' . $requestId,
                            'action' => 'view_request',
                            'request_id' => (int)$requestId,
                            'status' => 'rejected'
                        ]
                    );
                } catch (Exception $e) {
                    error_log("❌ [Reject] Error en sendNotification: " . $e->getMessage());
                }

                try {
                    $wsResults['emit_user'] = WebSocketService::emitToUser('user', $request['user_id'], 'request_updated', ['request' => ['id' => (int)$requestId, 'status' => 'rejected', 'updated_at' => date('Y-m-d H:i:s')]]);
                } catch (Exception $e) {
                    error_log("❌ [Reject] Error en emitToUser(user): " . $e->getMessage());
                }

                try {
                    $wsResults['emit_provider'] = WebSocketService::emitToUser('provider', $auth->id, 'request_updated', ['request' => ['id' => (int)$requestId, 'status' => 'rejected', 'updated_at' => date('Y-m-d H:i:s')]]);
                } catch (Exception $e) {
                    error_log("❌ [Reject] Error en emitToUser(provider): " . $e->getMessage());
                }

                $failed = array_filter($wsResults, fn($r) => is_array($r) && !$r['success']);
                if (!empty($failed)) {
                    error_log("⚠️ [Reject] Algunas notificaciones WS fallaron: " . json_encode(array_keys($failed)));
                }
            }
            $this->archiveAndClean((int)$requestId, 'rejected');
            echo json_encode(["success" => true, "message" => "Solicitud rechazada"]);
        } catch (Exception $e) {
            echo json_encode(["success" => false, "message" => $e->getMessage()]);
        }
    }

    private function cancel($auth)
    {
        $input = json_decode(file_get_contents("php://input"), true);
        $requestId = $input['id'] ?? null;
        if (!$requestId) { echo json_encode(["success" => false, "message" => "Falta el ID"]); return; }

        $actorRole = ($auth->role === 'provider') ? 'provider' : 'user';

        try {
            $cancelled = $this->model->cancel((int)$requestId, $auth->id, $actorRole);
            if (!$cancelled) { echo json_encode(["success" => false, "message" => "No se pudo cancelar"]); return; }

            // ✅ LOG
            AuditLogger::log($auth->id, 'request_cancelled', 'Solicitud cancelada', "Solicitud ID: {$requestId} - Por: {$actorRole}");

            $request = $this->model->getById($requestId);
            if ($request) {
                $otherRole = ($actorRole === 'provider') ? 'user' : 'provider';
                $otherId = ($actorRole === 'provider') ? $request['user_id'] : $request['provider_id'];

                // ✅ Guardar y obtener ID real de BD para el otro usuario
                $notifId = $this->model->saveNotificationReturnId([
                    'sender_id' => $auth->id,
                    'receiver_id' => $otherId,
                    'receiver_role' => $otherRole,
                    'title' => 'Solicitud cancelada',
                    'message' => "Cancelada por el {$actorRole}",
                    'data_json' => json_encode([
                        'url' => '/orders/' . $requestId,
                        'action' => 'view_request',
                        'notification_type' => 'status_updated',
                        'request_id' => (int)$requestId,
                        'status' => 'cancelled',
                        'cancelled_by' => $actorRole
                    ])
                ]);

                // Datos comunes del payload
                $payload = [
                    'request' => [
                        'id' => (int)$requestId,
                        'status' => 'cancelled',
                        'updated_at' => date('Y-m-d H:i:s'),
                        'cancelled_by' => $actorRole
                    ]
                ];

                // Notificar a AMBOS usuarios de forma independiente
                // Si uno falla, el otro se intenta igual
                $wsResults = [];

                // 1. Notificar al otro usuario
                try {
                    $wsResults['notif_other'] = WebSocketService::sendNotification(
                        $otherRole,
                        $otherId,
                        'Solicitud cancelada',
                        "Cancelada por el {$actorRole}",
                        [
                            'notification_id' => $notifId,
                            'notification_type' => 'status_updated',
                            'url' => '/orders/' . $requestId,
                            'action' => 'view_request',
                            'request_id' => (int)$requestId,
                            'status' => 'cancelled',
                            'cancelled_by' => $actorRole
                        ]
                    );
                } catch (Exception $e) {
                    error_log("❌ [Cancel] Error en sendNotification a {$otherRole}_{$otherId}: " . $e->getMessage());
                }

                try {
                    $wsResults['emit_other'] = WebSocketService::emitToUser(
                        $otherRole,
                        $otherId,
                        'request_updated',
                        $payload
                    );
                } catch (Exception $e) {
                    error_log("❌ [Cancel] Error en emitToUser a {$otherRole}_{$otherId}: " . $e->getMessage());
                }

                // 2. Notificar al actor (quien canceló)
                try {
                    $wsResults['emit_actor'] = WebSocketService::emitToUser(
                        $actorRole,
                        $auth->id,
                        'request_updated',
                        $payload
                    );
                } catch (Exception $e) {
                    error_log("❌ [Cancel] Error en emitToUser a {$actorRole}_{$auth->id}: " . $e->getMessage());
                }

                // Log de resultados
                $failed = array_filter($wsResults, fn($r) => is_array($r) && !$r['success']);
                if (!empty($failed)) {
                    error_log("⚠️ [Cancel] Algunas notificaciones WS fallaron: " . json_encode(array_keys($failed)));
                }
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
            http_response_code(400); echo json_encode(['error' => 'ID de solicitud inválido']); return;
        }
        $requestId = $matches[1];
        $request = $this->model->getById($requestId);
        if (!$request) { http_response_code(404); echo json_encode(['error' => 'Solicitud no encontrada']); return; }
        if ($request['user_id'] != $auth->id && $request['provider_id'] != $auth->id &&
            (!isset($auth->staff_id) || $request['assigned_staff_id'] != $auth->staff_id)) {
            http_response_code(403); echo json_encode(['error' => 'No autorizado']); return;
        }

        // ✅ Obtener datos del servicio
        $serviceData = null;
        try {
            $serviceData = $this->model->getServiceDetailsForRequest($request['service_id']);
        } catch (\Exception $e) {
            error_log("⚠️ Error obteniendo servicio: " . $e->getMessage());
        }

        // ✅ Obtener datos del proveedor
        $providerData = null;
        try {
            $stmt = $this->model->conn->prepare("SELECT id, name, phone, avatar_url FROM users WHERE id = ?");
            $stmt->execute([$request['provider_id']]);
            $providerData = $stmt->fetch(\PDO::FETCH_ASSOC);
        } catch (\Exception $e) {
            error_log("⚠️ Error obteniendo proveedor: " . $e->getMessage());
        }

        $response = [
            'status' => $request['status'],
            'id' => (int)$request['id'],
            'service_id' => (int)$request['service_id'],
            'service_title' => $serviceData['title'] ?? null,
            'service_description' => $serviceData['description'] ?? null,
            'service_image_url' => $serviceData['image_url'] ?? null,
            'service_price' => $serviceData['price'] ?? null,
            'provider_id' => (int)$request['provider_id'],
            'provider_name' => $providerData['name'] ?? null,
            'provider_phone' => $providerData['phone'] ?? null,
            'provider_avatar_url' => $providerData['avatar_url'] ?? null,
            'user_id' => (int)$request['user_id'],
            'payment_status' => $request['payment_status'] ?? 'pending',
            'price' => $request['price'] ?? ($serviceData['price'] ?? null),
            'created_at' => $request['created_at'] ?? null,
            'updated_at' => $request['updated_at'] ?? null,
            'finished_at' => $request['finished_at'] ?? null,
            'additional_details' => $request['additional_details'] ?? null,
        ];

        // ✅ Si tiene staff asignado, incluir sus datos
        if (!empty($request['assigned_staff_id'])) {
            require_once __DIR__ . '/../models/ProviderStaff.php';
            $staffModel = new ProviderStaff();
            $staff = $staffModel->findById($request['assigned_staff_id']);
            if ($staff) {
                $response['delivery'] = [
                    'id' => $staff['id'],
                    'name' => $staff['name'],
                    'phone' => $staff['phone']
                ];
            }
        }

        echo json_encode($response);
    }

    private function unauthorized()
    {
        http_response_code(401);
        echo json_encode(["error" => "No autorizado"]);
    }
}
