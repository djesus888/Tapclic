<?php
require_once __DIR__ . "/../middleware/Auth.php";
require_once __DIR__ . '/../models/System.php';
require_once __DIR__ . '/../utils/Mailer.php';
require_once __DIR__ . '/../utils/Sms.php';

class SystemController {
    private $system;

    public function __construct() {
        $this->system = new System();
    }

    public function handle($method) {
        $uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
        
        // GET /api/system/config - PÚBLICO (no requiere autenticación)
        // Esto permite que el login cargue la configuración antes de autenticarse
        if ($method === 'GET' && preg_match('/\/api\/system\/config/', $uri)) {
            $this->getConfig();
            return;
        }
        
        // GET /api/system/status - PÚBLICO (opcional, para ver estado de servicios)
        if ($method === 'GET' && preg_match('/\/api\/system\/status/', $uri)) {
            $this->getStatus();
            return;
        }

        // A partir de aquí, todas las demás rutas requieren autenticación
        $auth = Auth::verify();
        if (!$auth) {
            http_response_code(401);
            echo json_encode(["error" => "No autorizado"]);
            return;
        }

        // Verificar que sea admin (solo administradores pueden modificar sistema)
        if ($auth->role !== 'admin') {
            http_response_code(403);
            echo json_encode(["error" => "Acceso denegado. Se requieren permisos de administrador"]);
            return;
        }

        // POST /api/system/config (actualizar) - REQUIERE ADMIN
        if ($method === 'POST' && preg_match('/\/api\/system\/config/', $uri)) {
            $this->updateConfig();
        }
        // POST /api/system/test-email - REQUIERE ADMIN
        elseif ($method === 'POST' && preg_match('/\/api\/system\/test-email/', $uri)) {
            $this->testEmail();
        }
        // POST /api/system/test-sms - REQUIERE ADMIN
        elseif ($method === 'POST' && preg_match('/\/api\/system\/test-sms/', $uri)) {
            $this->testSMS();
        }
        else {
            http_response_code(404);
            echo json_encode(["error" => "Ruta no válida"]);
        }
    }

    /**
     * Obtener configuración del sistema
     */
    private function getConfig() {
        $config = $this->system->getConfig();

        if ($config) {
            // No enviar datos sensibles completos
            if (isset($config['mail_password']) && !empty($config['mail_password'])) {
                $config['mail_password'] = '********';
            }
            if (isset($config['twilio_token']) && !empty($config['twilio_token'])) {
                $config['twilio_token'] = '********';
            }

            echo json_encode([
                'success' => true,
                'config' => $config
            ]);
        } else {
            http_response_code(404);
            echo json_encode(["error" => "No hay configuración"]);
        }
    }

    /**
     * Actualizar configuración del sistema
     */
    private function updateConfig() {
        $data = json_decode(file_get_contents("php://input"), true);

        // Obtener configuración actual para mantener el ID
        $currentConfig = $this->system->getConfig();
        $data['id'] = $currentConfig['id'] ?? 1;

        // No sobrescribir contraseñas si vienen vacías
        if (empty($data['mail_password']) && isset($currentConfig['mail_password'])) {
            $data['mail_password'] = $currentConfig['mail_password'];
        }
        if (empty($data['twilio_token']) && isset($currentConfig['twilio_token'])) {
            $data['twilio_token'] = $currentConfig['twilio_token'];
        }
        if ($this->system->updateConfig($data)) {
            echo json_encode([
                "success" => true,
                "message" => "Configuración actualizada correctamente"
            ]);
        } else {
            http_response_code(500);
            echo json_encode(["error" => "Error al actualizar la configuración"]);
        }
    }

    /**
     * Crear nueva configuración (solo si no existe)
     */
    private function createConfig() {
        // Verificar si ya existe configuración
        $existing = $this->system->getConfig();
        if ($existing) {
            http_response_code(400);
            echo json_encode(["error" => "Ya existe una configuración. Use PUT para actualizar"]);
            return;
        }

        $data = json_decode(file_get_contents("php://input"), true);
        if ($this->system->createConfig($data)) {
            echo json_encode([
                "success" => true,
                "message" => "Configuración creada correctamente"
            ]);
        } else {
            http_response_code(500);
            echo json_encode(["error" => "Error al crear configuración"]);
        }
    }

    /**
     * Probar configuración de email
     */
    private function testEmail() {
        $input = json_decode(file_get_contents("php://input"), true);
        $testEmail = $input['test_email'] ?? null;
        if (!$testEmail) {
            http_response_code(400);
            echo json_encode(["error" => "Email de prueba requerido"]);
            return;
        }

        // Validar email
        if (!filter_var($testEmail, FILTER_VALIDATE_EMAIL)) {
            http_response_code(400);
            echo json_encode(["error" => "Email inválido"]);
            return;
        }
        // Verificar configuración
        if (!Mailer::isConfigured()) {
            http_response_code(500);
            echo json_encode(["error" => "El sistema de correo no está configurado"]);
            return;
        }

        // Obtener configuración para el nombre de la empresa
        $config = $this->system->getConfig();
        $companyName = $config['company_name'] ?? 'TapClic';

        $subject = "Prueba de configuración - " . $companyName;
        $message = "
        <h1>Prueba exitosa</h1>
        <p>La configuración de correo electrónico está funcionando correctamente.</p>
        <p><strong>Fecha:</strong> " . date('Y-m-d H:i:s') . "</p>
        <p><strong>Servidor:</strong> " . ($config['mail_host'] ?? 'N/A') . "</p>
        ";
        try {
            $result = Mailer::sendWithResponse($testEmail, $subject, $message);
            if ($result['success']) {
                echo json_encode([
                    'success' => true,
                    'message' => 'Email de prueba enviado correctamente'
                ]);
            } else {
                http_response_code(500);
                echo json_encode(['error' => $result['error'] ?? 'Error al enviar email']);
            }
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Error: ' . $e->getMessage()]);
        }
    }

    /**
     * Probar configuración de SMS
     */
    private function testSMS() {
        $input = json_decode(file_get_contents("php://input"), true);
        $testPhone = $input['test_phone'] ?? null;
        if (!$testPhone) {
            http_response_code(400);
            echo json_encode(["error" => "Número de teléfono de prueba requerido"]);
            return;
        }

        // Validar teléfono
        if (!SMS::validatePhoneNumber($testPhone)) {
            http_response_code(400);
            echo json_encode(["error" => "Teléfono inválido. Use formato internacional: +584241234567"]);
            return;
        }
        // Verificar configuración
        if (!SMS::isConfigured()) {
            http_response_code(500);
            echo json_encode(["error" => "El sistema de SMS no está configurado"]);
            return;
        }

        $message = "TapClic: Prueba de configuración exitosa. Fecha: " . date('Y-m-d H:i:s');

        try {
            $result = SMS::sendWithResponse($testPhone, $message);

            if ($result['success']) {
                echo json_encode([
                    'success' => true,
                    'message' => 'SMS de prueba enviado correctamente'
                ]);
            } else {
                http_response_code(500);
                echo json_encode(['error' => $result['error'] ?? 'Error al enviar SMS']);
            }
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Error: ' . $e->getMessage()]);
        }
    }

    /**
     * Obtener estado de los servicios
     */
    public function getStatus() {
        $config = $this->system->getConfig();

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
}
