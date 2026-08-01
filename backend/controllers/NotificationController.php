<?php
require_once __DIR__ . "/../middleware/Auth.php";
require_once __DIR__ . '/../models/Notification.php';
require_once __DIR__ . '/../models/User.php';
require_once __DIR__ . '/../models/System.php';
require_once __DIR__ . '/../utils/jwt.php';
require_once __DIR__ . '/../utils/Mailer.php';
require_once __DIR__ . '/../utils/Sms.php';

class NotificationController {
    private $model;
    private $userModel;
    private $systemModel;

    public function __construct() {
        $this->model = new Notification();
        $this->userModel = new User();
        $this->systemModel = new System();
        header("Content-Type: application/json");
    }

    public function handle($method) {
        $auth = Auth::verify();
        $uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

        if ($method === 'POST' && preg_match('/\/api\/notifications\/send/', $uri)) {
            $this->send($auth);
        } elseif ($method === 'GET' && preg_match('/\/api\/notifications\/mine/', $uri)) {
            $this->mine($auth);
        } elseif ($method === 'POST' && preg_match('/\/api\/notifications\/read-all/', $uri)) {
            $this->markAllAsRead($auth);
        } elseif ($method === 'POST' && preg_match('/\/api\/notifications\/read/', $uri)) {
            $this->markAsRead($auth);
        } elseif ($method === 'GET' && preg_match('/\/api\/notifications$/', $uri)) {
            $this->index($auth);
        }
        // ✅ NUEVA RUTA: Contador de notificaciones sin leer
        elseif ($method === 'GET' && preg_match('/\/api\/notifications\/unread-count/', $uri)) {
            $this->unreadCount($auth);
        }
        // ✅ NUEVA RUTA: Broadcast masivo a todos los usuarios
        elseif ($method === 'POST' && preg_match('/\/api\/notifications\/broadcast/', $uri)) {
            $this->broadcastToAll($auth);
        }
        // --- RUTAS REALES DE PRODUCCIÓN ---
        elseif ($method === 'POST' && preg_match('/\/api\/notifications\/email/', $uri)) {
            $this->sendEmailNotification($auth);
        } elseif ($method === 'POST' && preg_match('/\/api\/notifications\/sms/', $uri)) {
            $this->sendSMSNotification($auth);
        } elseif ($method === 'GET' && preg_match('/\/api\/notifications\/preferences/', $uri)) {
            $this->getPreferences($auth);
        } elseif ($method === 'POST' && preg_match('/\/api\/notifications\/preferences/', $uri)) {
            $this->savePreferences($auth);
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

        $data['sender_id'] = $auth->staff_id ?? $auth->id;

        $ok = $this->model->send($data);
        echo json_encode(["success" => $ok]);
    }

    private function mine($auth) {
        $userId = $auth->staff_id ?? $auth->id;
        $result = $this->model->getForUser($userId, $auth->role);
        echo json_encode($result);
    }

    // ✅ NUEVO: Endpoint para obtener solo el contador de no leídas
    private function unreadCount($auth) {
        $userId = $auth->staff_id ?? $auth->id;
        $count = $this->model->getUnreadCount($userId, $auth->role);
        echo json_encode([
            'success' => true,
            'unread_count' => $count
        ]);
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

    private function markAllAsRead($auth) {
        // ✅ CORREGIDO: Pasar el rol para filtrar correctamente
        $ok = $this->model->markAllAsRead($auth->id, $auth->role);
        echo json_encode(["success" => $ok]);
    }

    private function index($auth) {
        $this->mine($auth);
    }

    // ================================================================
    // ✅ NUEVO: Broadcast masivo a TODOS los usuarios
    // ================================================================
    private function broadcastToAll($auth) {
        // Solo administradores pueden enviar broadcast
        if (!$auth || ($auth->role !== 'admin' && $auth->role !== 'super_admin')) {
            http_response_code(403);
            echo json_encode(['error' => 'No autorizado. Solo administradores pueden enviar notificaciones masivas.']);
            return;
        }

        $data = json_decode(file_get_contents("php://input"), true);

        // Validar campos obligatorios
        if (!isset($data['title']) || !isset($data['message'])) {
            http_response_code(400);
            echo json_encode(["error" => "Faltan campos obligatorios: title, message"]);
            return;
        }

        $title = trim($data['title']);
        $message = trim($data['message']);
        $notificationType = $data['notification_type'] ?? 'broadcast';
        $targetRole = $data['target_role'] ?? null; // null = todos, 'user', 'worker', etc.
        $sendEmail = $data['send_email'] ?? false;
        $sendSms = $data['send_sms'] ?? false;

        // Validar longitud
        if (strlen($title) > 255) {
            http_response_code(400);
            echo json_encode(["error" => "El título no puede exceder 255 caracteres"]);
            return;
        }

        if (strlen($message) > 2000) {
            http_response_code(400);
            echo json_encode(["error" => "El mensaje no puede exceder 2000 caracteres"]);
            return;
        }

        $senderId = $auth->staff_id ?? $auth->id;
        $senderName = $auth->name ?? 'Administrador';

        try {
            // 1. Guardar notificación en BD para TODOS los usuarios
            $notificationId = $this->model->broadcastToAll([
                'sender_id' => $senderId,
                'title' => $title,
                'message' => $message,
                'notification_type' => $notificationType,
                'target_role' => $targetRole,
                'data_json' => json_encode([
                    'broadcast' => true,
                    'sent_by' => $senderName,
                    'sent_at' => date('Y-m-d H:i:s')
                ])
            ]);

            // 2. Emitir por WebSocket a usuarios conectados
            $wsPayload = [
                'id' => $notificationId,
                'title' => $title,
                'message' => $message,
                'notification_type' => $notificationType,
                'broadcast' => true,
                'sent_by' => $senderName,
                'created_at' => date('Y-m-d H:i:s'),
                'data_json' => json_encode([
                    'broadcast' => true,
                    'sent_by' => $senderName,
                    'target_role' => $targetRole
                ])
            ];

            // Determinar endpoint de WebSocket
            if ($targetRole) {
                // Si es para un rol específico, usar /emit con broadcast_role
                $this->emitToWebSocket('/emit', [
                    'event' => 'new-notification',
                    'broadcast_role' => $targetRole,
                    'payload' => $wsPayload
                ]);
                $wsLog = "Broadcast a rol: {$targetRole}";
            } else {
                // Si es para todos, usar /broadcast-all
                $this->emitToWebSocket('/broadcast-all', [
                    'event' => 'new-notification',
                    'payload' => $wsPayload,
                    'title' => $title,
                    'message' => $message,
                    'notification_type' => $notificationType
                ]);
                $wsLog = "Broadcast a TODOS los usuarios";
            }

            // 3. Enviar emails si se solicita
            $emailResults = [];
            if ($sendEmail) {
                $emailResults = $this->sendBroadcastEmails($targetRole, $title, $message, $senderName);
            }

            // 4. Enviar SMS si se solicita
            $smsResults = [];
            if ($sendSms) {
                $smsResults = $this->sendBroadcastSms($targetRole, $message);
            }

            $response = [
                'success' => true,
                'notification_id' => $notificationId,
                'websocket' => $wsLog,
                'timestamp' => date('Y-m-d H:i:s')
            ];

            if ($sendEmail) {
                $response['email'] = [
                    'sent' => $emailResults['sent'] ?? 0,
                    'failed' => $emailResults['failed'] ?? 0
                ];
            }

            if ($sendSms) {
                $response['sms'] = [
                    'sent' => $smsResults['sent'] ?? 0,
                    'failed' => $smsResults['failed'] ?? 0
                ];
            }

            echo json_encode($response);

        } catch (Exception $e) {
            error_log("Error en broadcastToAll: " . $e->getMessage());
            http_response_code(500);
            echo json_encode(['error' => 'Error al enviar broadcast: ' . $e->getMessage()]);
        }
    }

    // ✅ NUEVO: Enviar emails masivos para broadcast
    private function sendBroadcastEmails($targetRole, $title, $message, $senderName) {
        $sent = 0;
        $failed = 0;

        try {
            // Obtener usuarios según el rol objetivo
            $users = $targetRole 
                ? $this->userModel->getUsersByRole($targetRole)
                : $this->userModel->getAllUsers();

            if (!$users || count($users) === 0) {
                return ['sent' => 0, 'failed' => 0];
            }

            foreach ($users as $user) {
                if (!empty($user['email']) && filter_var($user['email'], FILTER_VALIDATE_EMAIL)) {
                    try {
                        $htmlMessage = $this->formatEmailMessage(
                            "📢 {$title}\n\n{$message}\n\nEnviado por: {$senderName}",
                            $user['name'] ?? 'Usuario'
                        );
                        $result = Mailer::sendWithResponse($user['email'], $title, $htmlMessage);
                        if ($result['success']) {
                            $sent++;
                        } else {
                            $failed++;
                        }
                    } catch (Exception $e) {
                        $failed++;
                        error_log("Error enviando email broadcast a {$user['email']}: " . $e->getMessage());
                    }
                }
            }
        } catch (Exception $e) {
            error_log("Error en sendBroadcastEmails: " . $e->getMessage());
        }

        return ['sent' => $sent, 'failed' => $failed];
    }

    // ✅ NUEVO: Enviar SMS masivos para broadcast
    private function sendBroadcastSms($targetRole, $message) {
        $sent = 0;
        $failed = 0;

        try {
            $users = $targetRole
                ? $this->userModel->getUsersByRole($targetRole)
                : $this->userModel->getAllUsers();

            if (!$users || count($users) === 0) {
                return ['sent' => 0, 'failed' => 0];
            }

            foreach ($users as $user) {
                if (!empty($user['phone']) && SMS::validatePhoneNumber($user['phone'])) {
                    try {
                        $result = SMS::sendWithResponse($user['phone'], $message);
                        if ($result['success']) {
                            $sent++;
                        } else {
                            $failed++;
                        }
                    } catch (Exception $e) {
                        $failed++;
                        error_log("Error enviando SMS broadcast a {$user['phone']}: " . $e->getMessage());
                    }
                }
            }
        } catch (Exception $e) {
            error_log("Error en sendBroadcastSms: " . $e->getMessage());
        }

        return ['sent' => $sent, 'failed' => $failed];
    }

    // ✅ NUEVO: Helper para emitir al WebSocket
    private function emitToWebSocket($endpoint, $data) {
        try {
            $wsUrl = $this->systemModel->getConfig()['ws_host'] ?? 'http://localhost:3001';
            $wsUrl = rtrim($wsUrl, '/') . $endpoint;

            $ch = curl_init($wsUrl);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_HTTPHEADER, [
                'Content-Type: application/json',
                'Accept: application/json'
            ]);
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
            curl_setopt($ch, CURLOPT_TIMEOUT, 5);

            $response = curl_exec($ch);
            $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            curl_close($ch);

            if ($httpCode !== 200) {
                error_log("WebSocket emit falló [{$httpCode}] a {$endpoint}: {$response}");
            }

            return $response;
        } catch (Exception $e) {
            error_log("Error emitiendo a WebSocket {$endpoint}: " . $e->getMessage());
            return null;
        }
    }

    // --- MÉTODOS REALES DE PRODUCCIÓN CON INTEGRACIÓN COMPLETA ---

    /**
     * Enviar notificación por email real con PHPMailer
     */
    private function sendEmailNotification($auth) {
        if (!$auth) {
            http_response_code(401);
            echo json_encode(['error' => 'No autorizado']);
            return;
        }

        $input = json_decode(file_get_contents('php://input'), true);
        $to = $input['to'] ?? '';
        $subject = $input['subject'] ?? '';
        $message = $input['message'] ?? '';
        $type = $input['type'] ?? 'general';

        if (empty($to) || empty($subject) || empty($message)) {
            http_response_code(400);
            echo json_encode(['error' => 'Faltan campos requeridos']);
            return;
        }

        // Validar email
        if (!filter_var($to, FILTER_VALIDATE_EMAIL)) {
            http_response_code(400);
            echo json_encode(['error' => 'Email inválido']);
            return;
        }

        // Verificar configuración de email
        if (!Mailer::isConfigured()) {
            http_response_code(500);
            echo json_encode(['error' => 'El sistema de correo no está configurado']);
            return;
        }

        // ✅ CORREGIDO: Primero intentar enviar email, luego guardar en BD solo si fue exitoso
        try {
            $htmlMessage = $this->formatEmailMessage($message, $auth->name);
            $result = Mailer::sendWithResponse($to, $subject, $htmlMessage);

            if ($result['success']) {
                // Guardar en base de datos solo si el email se envió correctamente
                $notificationData = [
                    'receiver_id' => $auth->id,
                    'receiver_role' => $auth->role,
                    'sender_id' => $auth->id,
                    'title' => $subject,
                    'message' => $message,
                    'data_json' => json_encode(['to' => $to, 'type' => $type])
                ];
                $this->model->send($notificationData);

                echo json_encode(['success' => true, 'message' => 'Email enviado correctamente']);
            } else {
                http_response_code(500);
                echo json_encode(['error' => $result['error'] ?? 'Error al enviar email']);
            }
        } catch (Exception $e) {
            error_log("Error en sendEmailNotification: " . $e->getMessage());
            http_response_code(500);
            echo json_encode(['error' => 'Error en el servidor de correo: ' . $e->getMessage()]);
        }
    }

    /**
     * Enviar notificación por SMS real con Twilio
     */
    private function sendSMSNotification($auth) {
        if (!$auth) {
            http_response_code(401);
            echo json_encode(['error' => 'No autorizado']);
            return;
        }

        $input = json_decode(file_get_contents('php://input'), true);
        $to = $input['to'] ?? '';
        $message = $input['message'] ?? '';

        if (empty($to) || empty($message)) {
            http_response_code(400);
            echo json_encode(['error' => 'Faltan campos requeridos']);
            return;
        }

        // Validar teléfono
        if (!SMS::validatePhoneNumber($to)) {
            http_response_code(400);
            echo json_encode(['error' => 'Teléfono inválido. Use formato internacional: +584241234567']);
            return;
        }

        // Verificar configuración de SMS
        if (!SMS::isConfigured()) {
            http_response_code(500);
            echo json_encode(['error' => 'El sistema de SMS no está configurado']);
            return;
        }

        // ✅ CORREGIDO: Primero intentar enviar SMS, luego guardar en BD solo si fue exitoso
        try {
            $result = SMS::sendWithResponse($to, $message);

            if ($result['success']) {
                // Guardar en base de datos solo si el SMS se envió correctamente
                $notificationData = [
                    'receiver_id' => $auth->id,
                    'receiver_role' => $auth->role,
                    'sender_id' => $auth->id,
                    'title' => 'Notificación SMS',
                    'message' => $message,
                    'data_json' => json_encode(['to' => $to])
                ];
                $this->model->send($notificationData);

                echo json_encode(['success' => true, 'message' => 'SMS enviado correctamente']);
            } else {
                http_response_code(500);
                echo json_encode(['error' => $result['error'] ?? 'Error al enviar SMS']);
            }
        } catch (Exception $e) {
            error_log("Error en sendSMSNotification: " . $e->getMessage());
            http_response_code(500);
            echo json_encode(['error' => 'Error en el servicio de SMS: ' . $e->getMessage()]);
        }
    }

    /**
     * Guardar preferencias de notificaciones
     */
    private function savePreferences($auth) {
        if (!$auth) {
            http_response_code(401);
            echo json_encode(['error' => 'No autorizado']);
            return;
        }

        $input = json_decode(file_get_contents('php://input'), true);

        $emailEnabled = $input['email'] ?? false;
        $smsEnabled = $input['sms'] ?? false;
        $pushEnabled = $input['push'] ?? false;

        // Obtener preferencias actuales
        $user = $this->userModel->findById($auth->id);
        $preferences = json_decode($user['preferences'] ?? '{}', true);

        // Actualizar notificaciones
        if (!isset($preferences['notifications'])) {
            $preferences['notifications'] = [];
        }

        $preferences['notifications']['email'] = $emailEnabled;
        $preferences['notifications']['sms'] = $smsEnabled;
        $preferences['notifications']['push'] = $pushEnabled;
        $preferences['notifications']['updated_at'] = date('Y-m-d H:i:s');

        // Guardar
        $ok = $this->userModel->updatePreferences($auth->id, $preferences);

        echo json_encode([
            'success' => $ok,
            'notifications' => $preferences['notifications']
        ]);
    }

    /**
     * Obtener preferencias de notificaciones
     */
    private function getPreferences($auth) {
        if (!$auth) {
            http_response_code(401);
            echo json_encode(['error' => 'No autorizado']);
            return;
        }

        $user = $this->userModel->findById($auth->id);
        $preferences = json_decode($user['preferences'] ?? '{}', true);

        $notifications = $preferences['notifications'] ?? [
            'email' => true,
            'sms' => false,
            'push' => true
        ];

        echo json_encode([
            'success' => true,
            'notifications' => $notifications
        ]);
    }

    /**
     * Verificar estado de los servicios de notificación
     */
    public function checkStatus($auth) {
        if (!$auth || $auth->role !== 'admin') {
            http_response_code(403);
            echo json_encode(['error' => 'No autorizado']);
            return;
        }

        $config = $this->systemModel->getConfig();

        echo json_encode([
            'success' => true,
            'email_configured' => Mailer::isConfigured(),
            'sms_configured' => SMS::isConfigured(),
            'mail_config' => [
                'host' => $config['mail_host'] ?? null,
                'port' => $config['mail_port'] ?? null,
                'encryption' => $config['mail_encryption'] ?? null,
                'from' => $config['mail_from'] ?? null,
                'has_username' => !empty($config['mail_username']),
                'has_password' => !empty($config['mail_password'])
            ],
            'twilio_config' => [
                'has_sid' => !empty($config['twilio_sid']),
                'has_token' => !empty($config['twilio_token']),
                'phone' => $config['twilio_phone'] ?? null
            ]
        ]);
    }

    // --- MÉTODOS PRIVADOS DE SERVICIO ---

    /**
     * Formatear mensaje de email con HTML
     */
    private function formatEmailMessage($message, $userName) {
        $year = date('Y');
        $config = $this->systemModel->getConfig();
        $companyName = $config['company_name'] ?? 'TapClic';

        return "
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset='UTF-8'>
            <meta name='viewport' content='width=device-width, initial-scale=1.0'>
            <style>
                body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; }
                .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                .header { background: #4F46E5; color: white; padding: 20px; text-align: center; border-radius: 10px 10px 0 0; }
                .content { padding: 30px; background: #f9f9f9; border: 1px solid #ddd; border-top: none; }
                .footer { text-align: center; padding: 20px; font-size: 12px; color: #666; border-top: 1px solid #ddd; background: #f5f5f5; }
                .button { background: #4F46E5; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; display: inline-block; margin: 20px 0; }
                .button:hover { background: #4338CA; }
            </style>
        </head>
        <body>
            <div class='container'>
                <div class='header'>
                    <h2>🔔 " . htmlspecialchars($companyName) . "</h2>
                </div>
                <div class='content'>
                    <h3>Hola " . htmlspecialchars($userName) . ",</h3>
                    <p>" . nl2br(htmlspecialchars($message)) . "</p>
                </div>
                <div class='footer'>
                    <p>&copy; $year " . htmlspecialchars($companyName) . ". Todos los derechos reservados.</p>
                    <p>Este es un correo automático, por favor no responder.</p>
                </div>
            </div>
        </body>
        </html>
        ";
    }
}
