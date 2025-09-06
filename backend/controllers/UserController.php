<?php
// controllers/UserController.php

require_once __DIR__ . '/../models/User.php';
require_once __DIR__ . '/../utils/jwt.php';

class UserController {
    private $userModel;

    public function __construct() {
        $this->userModel = new User();
    }

    private function authUser() {
        $headers = getallheaders();
        $auth = $headers['Authorization'] ?? '';

        if (!str_starts_with($auth, 'Bearer ')) return null;
        $token = str_replace('Bearer ', '', $auth);
        return JwtHandler::decode($token);
    }

    private function isValidEmail($email) {
        return filter_var($email, FILTER_VALIDATE_EMAIL) !== false;
    }

    private function isValidPhone($phone) {
        // Puedes ajustar la expresión según formato que quieras permitir
        return preg_match('/^[+]?[\d\s\-]{7,15}$/', $phone);
    }

    public function updateProfile() {
        $auth = $this->authUser();
        if (!$auth) {
            http_response_code(401);
            echo json_encode(["error" => "No autorizado"]);
            return;
        }

        $contentType = $_SERVER['CONTENT_TYPE'] ?? '';
        $data = [];
        $avatarFileName = null;

        if (strpos($contentType, 'application/json') !== false) {
            // Si es JSON
            $data = json_decode(file_get_contents("php://input"), true);
            if (isset($data['avatar'])) {
                $avatarFileName = $data['avatar'];
            }
        } else if (strpos($contentType, 'multipart/form-data') !== false) {
            // Si es multipart/form-data
            $data = $_POST;

            if (isset($_FILES['avatar']) && $_FILES['avatar']['error'] === UPLOAD_ERR_OK) {
                $uploadDir = __DIR__ . '/../public/uploads/avatars/';

                if (!is_dir($uploadDir)) {
                    mkdir($uploadDir, 0755, true);
                }

                $tmpName = $_FILES['avatar']['tmp_name'];
                $originalName = $_FILES['avatar']['name'];
                $ext = pathinfo($originalName, PATHINFO_EXTENSION);
                $fileName = 'avatar_' . time() . '.' . $ext;
                $destination = $uploadDir . $fileName;

                if (move_uploaded_file($tmpName, $destination)) {
                    $avatarFileName = $fileName;
                } else {
                    http_response_code(500);
                    echo json_encode(["error" => "Error al guardar archivo avatar"]);
                    return;
                }
            }
        } else {
            http_response_code(400);
            echo json_encode(["error" => "Tipo de contenido no soportado"]);
            return;
        }

        // Validaciones
        $name = trim($data['name'] ?? '');
        $email = trim($data['email'] ?? '');
        $phone = trim($data['phone'] ?? '');

        if ($email !== '' && !$this->isValidEmail($email)) {
            http_response_code(400);
            echo json_encode(["error" => "Email inválido"]);
            return;
        }

        if ($phone !== '' && !$this->isValidPhone($phone)) {
            http_response_code(400);
            echo json_encode(["error" => "Teléfono inválido"]);
            return;
        }

        // Verificar unicidad email
        if ($email !== '') {
            $userByEmail = $this->userModel->findByEmail($email);
            if ($userByEmail && $userByEmail['id'] != $auth->id) {
                http_response_code(409);
                echo json_encode(["error" => "Email ya está en uso"]);
                return;
            }
        }

        // Verificar unicidad teléfono
        if ($phone !== '') {
            $userByPhone = $this->userModel->findByPhone($phone);
            if ($userByPhone && $userByPhone['id'] != $auth->id) {
                http_response_code(409);
                echo json_encode(["error" => "Teléfono ya está en uso"]);
                return;
            }
        }

        // Actualizar datos del perfil
        $ok = $this->userModel->updateProfile($auth->id, [
            'name' => $name,
            'email' => $email,
            'phone' => $phone
        ]);

        // Actualizar avatar si se subió
        if ($avatarFileName) {
            $this->userModel->updateAvatar($auth->id, $avatarFileName);
        }

        if ($ok) {
            echo json_encode(["success" => true]);
        } else {
            http_response_code(500);
            echo json_encode(["error" => "Error al actualizar perfil"]);
        }
    }

    public function changePassword() {
        $auth = $this->authUser();
        if (!$auth) return $this->unauthorized();

        $data = json_decode(file_get_contents("php://input"), true);
        $user = $this->userModel->findById($auth->id);

        if (!password_verify($data['current_password'], $user['password'])) {
            echo json_encode(["error" => "Contraseña actual incorrecta"]);
            return;
        }

        $ok = $this->userModel->updatePassword($auth->id, $data['new_password']);
        echo json_encode(["success" => $ok]);
    }

    public function updatePreferences() {
        $auth = $this->authUser();
        if (!$auth) return $this->unauthorized();

        $data = json_decode(file_get_contents("php://input"), true);
        $ok = $this->userModel->updatePreferences($auth->id, $data);
        echo json_encode(["success" => $ok]);
    }

    public function uploadAvatar() {
        $auth = $this->authUser();
        if (!$auth) return $this->unauthorized();

        $input = json_decode(file_get_contents("php://input"), true);
        $url = $input['avatar_url'] ?? '';

        if (!$url) {
            echo json_encode(["error" => "URL no proporcionada"]);
            return;
        }

        $ok = $this->userModel->updateAvatar($auth->id, $url);
        echo json_encode(["success" => $ok]);
    }

    public function updateProviderData() {
        $auth = $this->authUser();
        if (!$auth || $auth->role !== 'driver') return $this->unauthorized();

        $data = json_decode(file_get_contents("php://input"), true);
        $ok = $this->userModel->updateProviderData($auth->id, $data);
        echo json_encode(["success" => $ok]);
    }

    public function getProfile() {
        $auth = $this->authUser();
        if (!$auth) {
            http_response_code(401);
            echo json_encode(["error" => "No autorizado"]);
            return;
        }

        $user = $this->userModel->findById($auth->id);
        header('Content-Type: application/json');
        echo json_encode(['user' => $user]);
    }

    private function unauthorized() {
        http_response_code(401);
        echo json_encode(["error" => "No autorizado"]);
    }

public function getProvider($id) {
    $auth = $this->authUser();
    if (!$auth) {
        http_response_code(401);
        echo json_encode(["error" => "No autorizado"]);
        return;
    }

    $user = $this->userModel->findById($id);
    if (!$user || $user['role'] !== 'provider') {
        http_response_code(404);
        echo json_encode(["error" => "Proveedor no encontrado"]);
        return;
    }

    header('Content-Type: application/json');
    echo json_encode(['provider' => $user]);
}

}
