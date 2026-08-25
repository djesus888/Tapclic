<?php
require_once __DIR__ . "/../middleware/Auth.php";
require_once __DIR__ . '/../models/User.php';
require_once __DIR__ . '/../utils/jwt.php';
require_once __DIR__ . '/../utils/AuditLogger.php';
require_once __DIR__ . '/UserController.php';
require_once __DIR__ . '/../utils/Mailer.php';

class AuthController
{
    private User $userModel;
    private $conn;

    public function __construct()
    {
        $this->userModel = new User();
        $this->conn = (new Database())->getConnection();
    }

    /* ---------- LOGIN ---------- */
    public function login(): void
    {
        header('Content-Type: application/json');

        $data = json_decode(file_get_contents("php://input"), true);
        $identifier = trim($data['identifier'] ?? '');
        $password = $data['password'] ?? '';

        if (empty($identifier) || empty($password)) {
            http_response_code(400);
            echo json_encode(["message" => "Faltan el identificador o la contraseña."]);
            return;
        }

        // Verificar estado del sistema ANTES de validar credenciales
        $sysStmt = $this->conn->query("SELECT system_active, maintenance_mode FROM system_config WHERE id = 1");
        $sysConfig = $sysStmt->fetch(PDO::FETCH_ASSOC);

        // Buscar usuario para verificar su rol (se usa en ambos casos)
        $userCheck = $this->userModel->findByEmailOrPhone($identifier);

        // Sistema inactivo - solo admin puede acceder
        if ($sysConfig && $sysConfig['system_active'] == 0) {
            if (!$userCheck || ($userCheck['role'] !== 'admin' && $userCheck['role'] !== 'super_admin')) {
                http_response_code(503);
                echo json_encode([
                    "message" => "El sistema se encuentra inactivo en este momento. Solo administradores pueden acceder.",
                    "maintenance" => true
                ]);
                return;
            }
        }

        // Modo mantenimiento - solo admin puede acceder
        if ($sysConfig && $sysConfig['maintenance_mode'] == 1) {
            if (!$userCheck || ($userCheck['role'] !== 'admin' && $userCheck['role'] !== 'super_admin')) {
                http_response_code(503);
                echo json_encode([
                    "message" => "El sistema se encuentra en mantenimiento. Solo administradores pueden acceder en este momento.",
                    "maintenance" => true
                ]);
                return;
            }
        }

        // Rate limiting configurable desde system_config
        $ip = $_SERVER['REMOTE_ADDR'] ?? '0.0.0.0';
        $stmt = $this->conn->prepare("SELECT COUNT(*) FROM login_attempts WHERE ip_address = ? AND success = 0 AND created_at > DATE_SUB(NOW(), INTERVAL 15 MINUTE)");
        $stmt->execute([$ip]);
        $failedAttempts = (int)$stmt->fetchColumn();

        // Obtener límite configurable desde system_config
        $configStmt = $this->conn->query("SELECT max_login_attempts FROM system_config WHERE id = 1");
        $maxAttempts = (int)($configStmt->fetchColumn() ?: 5);

        if ($failedAttempts >= $maxAttempts) {
            http_response_code(429);
            echo json_encode(["message" => "Demasiados intentos. Espere 15 minutos. (Límite: $maxAttempts)"]);
            return;
        }

        $user = $this->userModel->findByEmailOrPhone($identifier);

        if (!$user || !isset($user['password'])) {
            $stmt = $this->conn->prepare("INSERT INTO login_attempts (user_id, email, identifier, ip_address, user_agent, success) VALUES (?, ?, ?, ?, ?, 0)");
            $stmt->execute([null, $identifier, $identifier, $ip, $_SERVER['HTTP_USER_AGENT'] ?? 'Desconocido']);

            http_response_code(401);
            echo json_encode(["message" => "Credenciales incorrectas"]);
            return;
        }

        if (!password_verify($password, $user['password'])) {
            $stmt = $this->conn->prepare("INSERT INTO login_attempts (user_id, email, identifier, ip_address, user_agent, success) VALUES (?, ?, ?, ?, ?, 0)");
            $stmt->execute([$user['id'], $user['email'], $identifier, $ip, $_SERVER['HTTP_USER_AGENT'] ?? 'Desconocido']);

            http_response_code(401);
            echo json_encode(["message" => "Credenciales incorrectas"]);
            return;
        }

        // Registrar intento exitoso
        $stmt = $this->conn->prepare("INSERT INTO login_attempts (user_id, email, identifier, ip_address, user_agent, success) VALUES (?, ?, ?, ?, ?, 1)");
        $stmt->execute([$user['id'], $user['email'], $identifier, $ip, $_SERVER['HTTP_USER_AGENT'] ?? 'Desconocido']);

        // Verificar email si está activada la verificación
        $verifyStmt = $this->conn->query("SELECT email_verification FROM system_config WHERE id = 1");
        $emailVerification = (int)($verifyStmt->fetchColumn() ?: 0);

        if ($emailVerification == 1 && empty($user['email_verified_at'])) {
            http_response_code(403);
            echo json_encode([
                "message" => "Debes verificar tu email antes de iniciar sesión. Revisa tu bandeja de entrada.",
                "email_not_verified" => true
            ]);
            return;
        }

        // Actualizar última actividad
        $this->userModel->updateLastSeen($user['id']);

        $payload = [
            "id"   => $user['id'],
            "role" => $user['role'],
            "exp"  => time() + (3600 * 24 * 7), // 7 días
            "iat"  => time()
        ];

        $token = JwtHandler::encode($payload);
        unset($user['password']);

        // Verificar expiración de contraseña
        $pwdStmt = $this->conn->query("SELECT password_expiration_days FROM system_config WHERE id = 1");
        $pwdDays = (int)($pwdStmt->fetchColumn() ?: 0);

        if ($pwdDays > 0 && !empty($user['password_updated_at'])) {
            $lastChange = strtotime($user['password_updated_at']);
            $daysSinceChange = (time() - $lastChange) / 86400;

            if ($daysSinceChange > $pwdDays) {
                echo json_encode([
                    "success" => true,
                    "token" => $token,
                    "user" => $user,
                    "password_expired" => true,
                    "message" => "Tu contraseña ha expirado después de {$pwdDays} días. Debes cambiarla."
                ]);
                return;
            }
        }

        // Verificar configuración de sesiones múltiples
        $multiStmt = $this->conn->query("SELECT multiple_sessions FROM system_config WHERE id = 1");
        $multipleSessions = (int)($multiStmt->fetchColumn() ?: 0);

        $sessionCleanupDone = false;
        $userController = new UserController();

        // 🔥 CORRECCIÓN: 1. PRIMERO registrar el nuevo dispositivo
        $deviceId = $userController->registerDevice($user['id'], $token, false);

        // 🔥 CORRECCIÓN: 2. LUEGO cerrar sesiones anteriores, pasando el nuevo device_id
        if ($multipleSessions == 0) {
            $userController->closeOtherSessions($user['id'], $token, $user['name'], $user['role'], $deviceId);
        }

        // LOG: Inicio de sesión exitoso
        AuditLogger::log($user['id'], 'login', 'Inicio de sesión', "Usuario: {$user['name']} ({$user['email']}) - Rol: {$user['role']}");

        echo json_encode([
            "success" => true,
            "token"   => $token,
            "device_id" => $deviceId,
            "user"    => $user
        ]);
    }

    /* ---------- REGISTRO ---------- */
    public function register(): void
    {
        $data = json_decode(file_get_contents("php://input"), true);
        $required = ['name', 'email', 'phone', 'password', 'role'];

        foreach ($required as $field) {
            if (empty($data[$field])) {
                http_response_code(400);
                echo json_encode(["message" => "Falta el campo: $field"]);
                return;
            }
        }

        // Verificar si el registro está permitido
        $sysStmt = $this->conn->query("SELECT allow_user_registration, system_active, maintenance_mode FROM system_config WHERE id = 1");
        $sysConfig = $sysStmt->fetch(PDO::FETCH_ASSOC);

        if ($sysConfig && $sysConfig['system_active'] == 0) {
            http_response_code(503);
            echo json_encode(["message" => "El sistema se encuentra inactivo en este momento."]);
            return;
        }

        if ($sysConfig && $sysConfig['maintenance_mode'] == 1) {
            http_response_code(503);
            echo json_encode(["message" => "El sistema se encuentra en mantenimiento. No se permiten nuevos registros en este momento."]);
            return;
        }

        if ($sysConfig && $sysConfig['allow_user_registration'] == 0) {
            http_response_code(403);
            echo json_encode(["message" => "El registro de nuevos usuarios está deshabilitado."]);
            return;
        }

        if (!filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
            http_response_code(400);
            echo json_encode(["message" => "Email no válido"]);
            return;
        }

        if (!preg_match('/^[0-9]{8,15}$/', $data['phone'])) {
            http_response_code(400);
            echo json_encode(["message" => "Teléfono inválido"]);
            return;
        }

        $pwdStmt = $this->conn->query("SELECT strong_passwords FROM system_config WHERE id = 1");
        $strongPasswords = (int)($pwdStmt->fetchColumn() ?: 0);

        if ($strongPasswords == 1) {
            if (strlen($data['password']) < 8 ||
                !preg_match('/[A-Z]/', $data['password']) ||
                !preg_match('/[a-z]/', $data['password']) ||
                !preg_match('/[0-9]/', $data['password'])) {
                http_response_code(400);
                echo json_encode(["message" => "La contraseña debe tener al menos 8 caracteres, una mayúscula, una minúscula y un número."]);
                return;
            }
        } else {
            if (strlen($data['password']) < 6) {
                http_response_code(400);
                echo json_encode(["message" => "La contraseña debe tener al menos 6 caracteres"]);
                return;
            }
        }

        if (!in_array($data['role'], ['admin', 'user', 'provider'], true)) {
            http_response_code(400);
            echo json_encode(["message" => "Rol no permitido"]);
            return;
        }

        if ($this->userModel->findByEmail($data['email'])) {
            http_response_code(409);
            echo json_encode(["message" => "El correo electrónico ya está registrado."]);
            return;
        }

        if ($this->userModel->findByPhone($data['phone'])) {
            http_response_code(409);
            echo json_encode(["message" => "El número de teléfono ya está registrado."]);
            return;
        }

        $userId = $this->userModel->create($data);
        $user = $this->userModel->findById($userId);

        // Actualizar última actividad
        $this->userModel->updateLastSeen($userId);

        // Actualizar fecha de cambio de contraseña
        $this->conn->prepare("UPDATE users SET password_updated_at = NOW() WHERE id = ?")->execute([$userId]);

        // Email verification (si está activada en system_config)
        $verifyStmt = $this->conn->query("SELECT email_verification FROM system_config WHERE id = 1");
        $emailVerification = (int)($verifyStmt->fetchColumn() ?: 0);

        if ($emailVerification == 1) {
            $verifyToken = bin2hex(random_bytes(32));
            $this->conn->prepare("UPDATE users SET verification_token = ? WHERE id = ?")->execute([$verifyToken, $userId]);

            // Obtener host del sistema para el link
            $sysStmt = $this->conn->query("SELECT system_host, system_name FROM system_config WHERE id = 1");
            $sysConfig = $sysStmt->fetch(PDO::FETCH_ASSOC);
            $verifyLink = ($sysConfig['system_host'] ?? 'http://localhost:5173') . "/verify-email?token={$verifyToken}";

            $subject = "Verifica tu cuenta - " . ($sysConfig['system_name'] ?? 'TapClic');
            $message = "Hola {$user['name']},\n\nGracias por registrarte. Verifica tu email haciendo clic aquí:\n{$verifyLink}\n\nEste enlace expira en 24 horas.";

            // Usar PHPMailer configurado
            try {
                $mailer = new Mailer();
                $htmlMessage = "<h2>Verifica tu cuenta</h2><p>Hola {$user['name']},</p><p>Gracias por registrarte en " . ($sysConfig['system_name'] ?? 'TapClic') . ".</p><p>Haz clic en el siguiente enlace para verificar tu email:</p><p><a href='{$verifyLink}' style='background:#667eea;color:white;padding:12px 24px;border-radius:8px;text-decoration:none;'>Verificar Email</a></p><p>Este enlace expira en 24 horas.</p>";
                $mailer->sendWithResponse($user['email'], $subject, $htmlMessage);
            } catch (Exception $e) {
                error_log("Error enviando email de verificación: " . $e->getMessage());
            }

            echo json_encode([
                "success" => true,
                "message" => "Registro exitoso. Revisa tu email para verificar tu cuenta."
            ]);
            return;
        }

        $payload = [
            "id"   => $userId,
            "role" => $user['role'],
            "exp"  => time() + (3600 * 24 * 7)
        ];

        $token = JwtHandler::encode($payload);
        unset($user['password']);

        // Registrar el dispositivo después del registro
        $userController = new UserController();
        $deviceId = $userController->registerDevice($userId, $token);

        // LOG: Registro exitoso
        AuditLogger::log($userId, 'register', 'Nuevo registro', "Usuario: {$user['name']} ({$user['email']}) - Rol: {$user['role']}");

        echo json_encode([
            "success" => true,
            "token"   => $token,
            "device_id" => $deviceId,
            "user"    => $user
        ]);
    }

    /*------ Email verification -----*/
    public function verifyEmail(): void
    {
        header('Content-Type: application/json');

        $data = json_decode(file_get_contents("php://input"), true);
        $token = $data['token'] ?? '';

        if (empty($token)) {
            http_response_code(400);
            echo json_encode(["message" => "Token requerido"]);
            return;
        }

        $stmt = $this->conn->prepare("SELECT id, name FROM users WHERE verification_token = ?");
        $stmt->execute([$token]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$user) {
            http_response_code(400);
            echo json_encode(["message" => "Token inválido o expirado"]);
            return;
        }

        $this->conn->prepare("UPDATE users SET email_verified_at = NOW(), verification_token = NULL WHERE id = ?")->execute([$user['id']]);

        echo json_encode([
            "success" => true,
            "message" => "Email verificado correctamente. Ya puedes iniciar sesión."
        ]);
    }

    /* ---------- ME (cada petición autenticada) ---------- */
    public function me(): void
    {
        $headers = getallheaders();
        $auth = $headers['Authorization'] ?? '';

        if (!str_starts_with($auth, "Bearer ")) {
            http_response_code(401);
            echo json_encode(["message" => "Token no proporcionado"]);
            return;
        }

        $token = str_replace("Bearer ", "", $auth);
        $decoded = JwtHandler::decode($token);

        if (!$decoded || !isset($decoded->id)) {
            http_response_code(401);
            echo json_encode(["message" => "Token inválido o expirado"]);
            return;
        }

        $userId = $decoded->id;

        // Actualizar última actividad
        $this->userModel->updateLastSeen($userId);

        // Actualizar último acceso del dispositivo
        $userController = new UserController();
        $userController->registerDevice($userId, $token);

        $user = $this->userModel->findById($userId);
        if (!$user) {
            http_response_code(404);
            echo json_encode(["message" => "Usuario no encontrado"]);
            return;
        }

        unset($user['password']);
        echo json_encode([
            "success" => true,
            "user"    => $user
        ]);
    }

    /* ---------- RECUPERAR CONTRASEÑA ---------- */
    public function forgotPassword(): void
    {
        $data = json_decode(file_get_contents("php://input"), true);
        $method = $data['method'] ?? '';
        $value  = trim($data['value'] ?? '');

        if (!in_array($method, ['email', 'phone'], true) || empty($value)) {
            http_response_code(400);
            echo json_encode(["message" => "Método o valor inválido"]);
            return;
        }

        $user = $method === 'email'
            ? $this->userModel->findByEmail($value)
            : $this->userModel->findByPhone($value);

        if (!$user) {
            echo json_encode([
                "success" => true,
                "message" => "Si existe el usuario, se ha enviado un código"
            ]);
            return;
        }

        $token = bin2hex(random_bytes(32));
        $expires_at = date('Y-m-d H:i:s', strtotime('+15 minutes'));

        $this->userModel->setResetToken($user['id'], $token, $expires_at);

        if ($method === 'email') {
            $reset_link = "https://tusitio.com/reset-password?token=$token";
            $subject = "Recupera tu contraseña";
            $message = "Hola,\n\nHaz clic en este enlace para cambiar tu contraseña:\n$reset_link\n\nEste enlace expira en 15 minutos.";
            $headers = "From: no-reply@tusitio.com\r\n";
            mail($user['email'], $subject, $message, $headers);
        } else {
            require_once __DIR__ . '/../utils/SMS.php';
            $smsMessage = "Tu código de recuperación es: $token";
            $sent = SMS::send($user['phone'], $smsMessage);
            if (!$sent) {
                http_response_code(500);
                echo json_encode(["message" => "No se pudo enviar el SMS"]);
                return;
            }
        }

        echo json_encode([
            "success" => true,
            "message" => "Si existe el usuario, se ha enviado un código"
        ]);
    }

    /* ---------- CAMBIAR CONTRASEÑA ---------- */
    public function resetPassword(): void
    {
        $data = json_decode(file_get_contents("php://input"), true);
        $token = $data['token'] ?? '';
        $newPassword = $data['password'] ?? '';

        if (empty($token) || empty($newPassword)) {
            http_response_code(400);
            echo json_encode(["message" => "Token o contraseña no enviados"]);
            return;
        }

        if (strlen($newPassword) < 6) {
            http_response_code(400);
            echo json_encode(["message" => "La contraseña debe tener al menos 6 caracteres"]);
            return;
        }

        $user = $this->userModel->findByResetToken($token);

        if (!$user || strtotime($user['reset_password_expires_at']) < time()) {
            http_response_code(400);
            echo json_encode(["message" => "Token inválido o expirado"]);
            return;
        }

        $this->userModel->updatePassword($user['id'], $newPassword);

        $this->conn->prepare("UPDATE users SET password_updated_at = NOW() WHERE id = ?")->execute([$user['id']]);

        $this->userModel->setResetToken($user['id'], null, null);

        echo json_encode([
            "success" => true,
            "message" => "Contraseña actualizada correctamente"
        ]);
    }

    /* ---------- REFRESH TOKEN ---------- */
    public function refreshToken(): void
    {
        $headers = getallheaders();
        $auth = $headers['Authorization'] ?? '';

        if (!str_starts_with($auth, "Bearer ")) {
            http_response_code(401);
            echo json_encode(["message" => "Token no proporcionado"]);
            return;
        }

        $token = str_replace("Bearer ", "", $auth);
        $decoded = JwtHandler::decode($token);

        if (!$decoded || !isset($decoded->id)) {
            http_response_code(401);
            echo json_encode(["message" => "Token inválido o expirado"]);
            return;
        }

        $userId = $decoded->id;
        $user = $this->userModel->findById($userId);

        if (!$user) {
            http_response_code(404);
            echo json_encode(["message" => "Usuario no encontrado"]);
            return;
        }

        $this->userModel->updateLastSeen($userId);

        $payload = [
            "id"   => $user['id'],
            "role" => $user['role'],
            "exp"  => time() + (3600 * 24 * 7)
        ];

        $newToken = JwtHandler::encode($payload);
        unset($user['password']);

        $userController = new UserController();
        $deviceId = $userController->registerDevice($userId, $newToken);

        echo json_encode([
            "success" => true,
            "token"   => $newToken,
            "device_id" => $deviceId,
            "user"    => $user
        ]);
    }

    /* ---------- LOGOUT ---------- */
    public function logout(): void
    {
        header('Content-Type: application/json');

        $headers = getallheaders();
        $auth = $headers['Authorization'] ?? '';

        if (str_starts_with($auth, "Bearer ")) {
            $token = str_replace("Bearer ", "", $auth);
            $decoded = JwtHandler::decode($token);

            if ($decoded && isset($decoded->exp)) {
                Auth::addToBlacklist($token, date('Y-m-d H:i:s', $decoded->exp));
            }

            if ($decoded && isset($decoded->id)) {
                $this->userModel->updateLastSeen($decoded->id);
            }
        }

        http_response_code(200);
        echo json_encode([
            "success" => true,
            "message" => "Sesión cerrada correctamente"
        ]);
    }
}
