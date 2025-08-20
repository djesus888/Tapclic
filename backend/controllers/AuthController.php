<?php
// Habilitar CORS
header("Access-Control-Allow-Origin: http://localhost:5173");
header("Access-Control-Allow-Headers: Origin, X-Requested-With, Content-Type, Accept, Authorization");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once __DIR__ . '/../models/User.php';
require_once __DIR__ . '/../utils/jwt.php';

class AuthController {
    private $userModel;

    public function __construct() {
        $this->userModel = new User();
    }

    public function login() {
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

        $payload = [
            "id"   => $user['id'],
            "role" => $user['role'],
            "exp"  => time() + (3600 * 24 * 7) // 7 días
        ];

        $token = JwtHandler::encode($payload);
        unset($user['password']);

        echo json_encode([
            "success" => true,
            "token" => $token,
            "user" => $user
        ]);
    }

    public function register() {
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

        if (!in_array($data['role'], ['admin', 'user', 'driver'])) {
            http_response_code(400);
            echo json_encode(["message" => "Rol no permitido"]);
            return;
        }

        // Verificar si el email ya está registrado
        if ($this->userModel->findByEmail($data['email'])) {
            http_response_code(409);
            echo json_encode(["message" => "El correo electrónico ya está registrado."]);
            return;
        }

        // Verificar si el teléfono ya está registrado
        if ($this->userModel->findByPhone($data['phone'])) {
            http_response_code(409);
            echo json_encode(["message" => "El número de teléfono ya está registrado."]);
            return;
        }

        $userId = $this->userModel->create($data);
        $user = $this->userModel->findById($userId);

        $payload = [
            "id" => $userId,
            "role" => $user['role'],
            "exp" => time() + (3600 * 24 * 7)
        ];

        $token = JwtHandler::encode($payload);
        unset($user['password']);

        echo json_encode([
            "success" => true,
            "token" => $token,
            "user" => $user
        ]);
    }

    public function me() {
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

        $user = $this->userModel->findById($decoded->id);
        if (!$user) {
            http_response_code(404);
            echo json_encode(["message" => "Usuario no encontrado"]);
            return;
        }

        unset($user['password']);
        echo json_encode([
            "success" => true,
            "user" => $user
        ]);
    }
}
