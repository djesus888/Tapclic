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
        $data = json_decode(file_get_contents("php://input"), true);
        $identifier = trim($data['identifier'] ?? '');
        $password = $data['password'] ?? '';

        if (empty($identifier) || empty($password)) {
            http_response_code(400);
            echo json_encode(["message" => "Faltan el identificador o la contraseña."]);
            return;
        }

        $user = $this->userModel->findByEmailOrPhone($identifier);
        if (!$user || !password_verify($password, $user['password'])) {
            http_response_code(401);
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

        echo json_encode([
            "success" => true,
            "token"   => $newToken,
            "user"    => $user
        ]);
    }
}
