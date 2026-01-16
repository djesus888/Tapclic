<?php
require_once __DIR__ . "/../middleware/Auth.php";
require_once __DIR__ . '/../models/User.php';
require_once __DIR__ . '/../utils/jwt.php';

class AuthController
{
    private User $userModel;

    public function __construct()
    {
        $this->userModel = new User();
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
            header('Content-Type: application/json');
            echo json_encode(["message" => "Faltan el identificador o la contraseña."]);
            return;
        }

        $user = $this->userModel->findByEmailOrPhone($identifier);

if (!$user || !isset($user['password'])) {
    http_response_code(401);
    header('Content-Type: application/json');
    echo json_encode(["message" => "Credenciales incorrectas"]);
    return;
}

if (!password_verify($password, $user['password'])) {
    http_response_code(401);
    header('Content-Type: application/json');
    echo json_encode(["message" => "Credenciales incorrectas"]);
    return;
}        

        // Actualizar última actividad
        $this->userModel->updateLastSeen($user['id']);

        $payload = [
            "id"   => $user['id'],
            "role" => $user['role'],
            "exp"  => time() + (3600 * 24 * 7) // 7 días
        ];

        $token = JwtHandler::encode($payload);
        unset($user['password']);

        header('Content-Type: application/json');
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
                header('Content-Type: application/json');
                echo json_encode(["message" => "Falta el campo: $field"]);
                return;
            }
        }

        if (!filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
            http_response_code(400);
            header('Content-Type: application/json');
            echo json_encode(["message" => "Email no válido"]);
            return;
        }

        if (!preg_match('/^[0-9]{8,15}$/', $data['phone'])) {
            http_response_code(400);
            header('Content-Type: application/json');
            echo json_encode(["message" => "Teléfono inválido"]);
            return;
        }

        if (strlen($data['password']) < 6) {
            http_response_code(400);
            header('Content-Type: application/json');
            echo json_encode(["message" => "La contraseña debe tener al menos 6 caracteres"]);
            return;
        }

        if (!in_array($data['role'], ['admin', 'user', 'provider'], true)) {
            http_response_code(400);
            header('Content-Type: application/json');
            echo json_encode(["message" => "Rol no permitido"]);
            return;
        }

        if ($this->userModel->findByEmail($data['email'])) {
            http_response_code(409);
            header('Content-Type: application/json');
            echo json_encode(["message" => "El correo electrónico ya está registrado."]);
            return;
        }

        if ($this->userModel->findByPhone($data['phone'])) {
            http_response_code(409);
            header('Content-Type: application/json');
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

        header('Content-Type: application/json');
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
            header('Content-Type: application/json');
            echo json_encode(["message" => "Token no proporcionado"]);
            return;
        }

        $token = str_replace("Bearer ", "", $auth);
        $decoded = JwtHandler::decode($token);

        if (!$decoded || !isset($decoded->id)) {
            http_response_code(401);
            header('Content-Type: application/json');
            echo json_encode(["message" => "Token inválido o expirado"]);
            return;
        }

        $userId = $decoded->id;

        // Actualizar última actividad
        $this->userModel->updateLastSeen($userId);

        $user = $this->userModel->findById($userId);
        if (!$user) {
            http_response_code(404);
            header('Content-Type: application/json');
            echo json_encode(["message" => "Usuario no encontrado"]);
            return;
        }

        unset($user['password']);
        header('Content-Type: application/json');
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
        header('Content-Type: application/json');
        echo json_encode(["message" => "Método o valor inválido"]);
        return;
    }

    $user = $method === 'email'
        ? $this->userModel->findByEmail($value)
        : $this->userModel->findByPhone($value);

    // No revelar si el usuario existe o no
    if (!$user) {
        header('Content-Type: application/json');
        echo json_encode([
            "success" => true,
            "message" => "Si existe el usuario, se ha enviado un código"
        ]);
        return;
    }

    // Generar token seguro y expiración
    $token = bin2hex(random_bytes(32));
    $expires_at = date('Y-m-d H:i:s', strtotime('+15 minutes'));

    $this->userModel->setResetToken($user['id'], $token, $expires_at);

    // Enviar correo o SMS
    if ($method === 'email') {
        $reset_link = "https://tusitio.com/reset-password?token=$token";
        $subject = "Recupera tu contraseña";
        $message = "Hola,\n\nHaz clic en este enlace para cambiar tu contraseña:\n$reset_link\n\nEste enlace expira en 15 minutos.";
        $headers = "From: no-reply@tusitio.com\r\n";
        mail($user['email'], $subject, $message, $headers);
    } else {

require_once __DIR__ . '/../utils/SMS.php';

if ($method === 'phone') {
    $smsMessage = "Tu código de recuperación es: $token";
    $sent = SMS::send($user['phone'], $smsMessage);
    if (!$sent) {
        http_response_code(500);
        header('Content-Type: application/json');
        echo json_encode(["message" => "No se pudo enviar el SMS"]);
        return;
    }
}


    }

    header('Content-Type: application/json');
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
        header('Content-Type: application/json');
        echo json_encode(["message" => "Token o contraseña no enviados"]);
        return;
    }

    if (strlen($newPassword) < 6) {
        http_response_code(400);
        header('Content-Type: application/json');
        echo json_encode(["message" => "La contraseña debe tener al menos 6 caracteres"]);
        return;
    }

    $user = $this->userModel->findByResetToken($token);

    if (!$user || strtotime($user['reset_password_expires_at']) < time()) {
        http_response_code(400);
        header('Content-Type: application/json');
        echo json_encode(["message" => "Token inválido o expirado"]);
        return;
    }

    $this->userModel->updatePassword($user['id'], $newPassword);

    // Limpiar token
    $this->userModel->setResetToken($user['id'], null, null);

    header('Content-Type: application/json');
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
            header('Content-Type: application/json');
            echo json_encode(["message" => "Token no proporcionado"]);
            return;
        }

        $token = str_replace("Bearer ", "", $auth);
        $decoded = JwtHandler::decode($token);

        if (!$decoded || !isset($decoded->id)) {
            http_response_code(401);
            header('Content-Type: application/json');
            echo json_encode(["message" => "Token inválido o expirado"]);
            return;
        }

        $userId = $decoded->id;
        $user = $this->userModel->findById($userId);

        if (!$user) {
            http_response_code(404);
            header('Content-Type: application/json');
            echo json_encode(["message" => "Usuario no encontrado"]);
            return;
        }

        // Actualizar última actividad
        $this->userModel->updateLastSeen($userId);

        // Generar nuevo token
        $payload = [
            "id"   => $user['id'],
            "role" => $user['role'],
            "exp"  => time() + (3600 * 24 * 7) // 7 días
        ];

        $newToken = JwtHandler::encode($payload);
        unset($user['password']);

        header('Content-Type: application/json');
        echo json_encode([
            "success" => true,
            "token"   => $newToken,
            "user"    => $user
        ]);
    }
}
