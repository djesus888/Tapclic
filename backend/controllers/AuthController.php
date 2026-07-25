<?php
require_once __DIR__ . "/../middleware/Auth.php";
require_once __DIR__ . '/../models/User.php';
require_once __DIR__ . '/../utils/jwt.php';
require_once __DIR__ . '/../utils/AuditLogger.php';
require_once __DIR__ . '/UserController.php';

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

    // ✅ Rate limiting configurable desde system_config
    $ip = $_SERVER['REMOTE_ADDR'] ?? '0.0.0.0';
    $stmt = $this->conn->prepare("SELECT COUNT(*) FROM login_attempts WHERE ip_address = ? AND success = 0 AND created_at > DATE_SUB(NOW(), INTERVAL 15 MINUTE)");
    $stmt->execute([$ip]);
    $failedAttempts = (int)$stmt->fetchColumn();

    // ✅ Obtener límite configurable desde system_config
    $configStmt = $this->conn->query("SELECT max_login_attempts FROM system_config WHERE id = 1");
    $maxAttempts = (int)($configStmt->fetchColumn() ?: 5);

    if ($failedAttempts >= $maxAttempts) {
        http_response_code(429);
        echo json_encode(["message" => "Demasiados intentos. Espere 15 minutos. (Límite: $maxAttempts)"]);
        return;
    }

    $user = $this->userModel->findByEmailOrPhone($identifier);

    if (!$user || !isset($user['password'])) {
        // ✅ Registrar intento fallido
        $stmt = $this->conn->prepare("INSERT INTO login_attempts (user_id, email, identifier, ip_address, user_agent, success) VALUES (?, ?, ?, ?, ?, 0)");
        $stmt->execute([null, $identifier, $identifier, $ip, $_SERVER['HTTP_USER_AGENT'] ?? 'Desconocido']);

        http_response_code(401);
        echo json_encode(["message" => "Credenciales incorrectas"]);
        return;
    }

    if (!password_verify($password, $user['password'])) {
        // ✅ Registrar intento fallido
        $stmt = $this->conn->prepare("INSERT INTO login_attempts (user_id, email, identifier, ip_address, user_agent, success) VALUES (?, ?, ?, ?, ?, 0)");
        $stmt->execute([$user['id'], $user['email'], $identifier, $ip, $_SERVER['HTTP_USER_AGENT'] ?? 'Desconocido']);

        http_response_code(401);
        echo json_encode(["message" => "Credenciales incorrectas"]);
        return;
    }

    // ✅ Registrar intento exitoso
    $stmt = $this->conn->prepare("INSERT INTO login_attempts (user_id, email, identifier, ip_address, user_agent, success) VALUES (?, ?, ?, ?, ?, 1)");
    $stmt->execute([$user['id'], $user['email'], $identifier, $ip, $_SERVER['HTTP_USER_AGENT'] ?? 'Desconocido']);

    // Actualizar última actividad
    $this->userModel->updateLastSeen($user['id']);

    $payload = [
        "id"   => $user['id'],
        "role" => $user['role'],
        "exp"  => time() + (3600 * 24 * 7) // 7 días
    ];

    $token = JwtHandler::encode($payload);
    unset($user['password']);

    // Registrar el dispositivo
    $userController = new UserController();
    $userController->registerDevice($user['id'], $token);

    // LOG: Inicio de sesión exitoso
    AuditLogger::log($user['id'], 'login', 'Inicio de sesión', "Usuario: {$user['name']} ({$user['email']}) - Rol: {$user['role']}");

    echo json_encode([
        "success" => true,
        "token"   => $token,
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

        if (strlen($data['password']) < 6) {
            http_response_code(400);
            echo json_encode(["message" => "La contraseña debe tener al menos 6 caracteres"]);
            return;
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

        $payload = [
            "id"   => $userId,
            "role" => $user['role'],
            "exp"  => time() + (3600 * 24 * 7)
        ];

        $token = JwtHandler::encode($payload);
        unset($user['password']);

        // Registrar el dispositivo después del registro
        $userController = new UserController();
        $userController->registerDevice($userId, $token);

        // LOG: Registro exitoso
        AuditLogger::log($userId, 'register', 'Nuevo registro', "Usuario: {$user['name']} ({$user['email']}) - Rol: {$user['role']}");

        echo json_encode([
            "success" => true,
            "token"   => $token,
            "user"    => $user
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
        $userController->registerDevice($userId, $newToken);

        echo json_encode([
            "success" => true,
            "token"   => $newToken,
            "user"    => $user
        ]);
    }

    /* ---------- LOGOUT ---------- */
    public function logout(): void {
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
