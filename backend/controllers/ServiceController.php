<?php
// controllers/ServiceController.php

require_once __DIR__ . '/../models/Service.php';
require_once __DIR__ . '/../utils/jwt.php';

class ServiceController
{
    private const MAX_IMAGE_SIZE  = 2 * 1024 * 1024; // 2 MB
    private const MAX_WIDTH       = 2000;
    private const MAX_HEIGHT      = 2000;
    private const MAX_PER_HOUR    = 20;               // servicios por usuario/hora
    private const UPLOAD_DIR      = __DIR__ . '/../public/uploads/services/';

    private Service $model;

    public function __construct()
    {
        $this->model = new Service();
    }

    /* ----------  AUTH  ---------- */
    private function auth(): ?object
    {
        $headers = getallheaders();
        $auth    = $headers['Authorization'] ?? '';
        if (!str_starts_with($auth, 'Bearer ')) return null;
        return JwtHandler::decode(str_replace('Bearer ', '', $auth));
    }

    private function unauthorized(): void
    {
        http_response_code(401);
        header('Content-Type: application/json');
        echo json_encode(['error' => 'No autorizado']);
    }

    /* ----------  RATE LIMIT  ---------- */
    private function rateLimit(int $userId): bool
    {
        $key   = "rate:service:$userId";
        $redis = new Redis();
        if (!$redis->connect('127.0.0.1')) return true; // Redis falla: dejamos pasar
        $current = $redis->incr($key);
        if ($current === 1) $redis->expire($key, 3600);
        return $current <= self::MAX_PER_HOUR;
    }

    /* ----------  NOTIFICACIÓN SOCKET  ---------- */
    private function emitWs(array $payload): void
    {
        $ch = curl_init('http://localhost:3001/emit');
        curl_setopt_array($ch, [
            CURLOPT_POST           => true,
            CURLOPT_POSTFIELDS     => json_encode($payload),
            CURLOPT_HTTPHEADER     => ['Content-Type: application/json'],
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT        => 2
        ]);
        curl_exec($ch);
        curl_close($ch);
    }

    /* ----------  HANDLE  ---------- */
    public function handle(string $method): void
    {
        $auth = $this->auth();
        if (!$auth) {
            $this->unauthorized();
            return;
        }

        $path = $_SERVER['REQUEST_URI'];

        match (true) {
    $method === 'POST' && preg_match('#/api/services/?$#', $path) => $this->create($auth),
    $method === 'GET'  && preg_match('#/api/services/mine/?$#', $path) => $this->mine($auth),
    $method === 'GET'  && preg_match('#/api/services/all/?$#', $path) => $this->all($auth),
    $method === 'POST' && preg_match('#/api/services/update/?$#', $path) => $this->update($auth),
    $method === 'POST' && preg_match('#/api/services/delete/?$#', $path) => $this->delete($auth),
    $method === 'GET'  && preg_match('#/api/services/?$#', $path) => $this->available($auth),
    default => $this->notFound()
   };

    }

    private function notFound(): void
    {
        http_response_code(404);
        header('Content-Type: application/json');
        echo json_encode(['error' => 'Ruta no válida']);
    }

    /* ----------  CREATE  ---------- */
    private function create(object $auth): void
    {
        header('Content-Type: application/json');

        // Rate-limit
        if (!$this->rateLimit($auth->id)) {
            http_response_code(429);
            echo json_encode(['error' => 'Demasiadas peticiones']);
            return;
        }

        // Leer datos
        $data = $_POST;
        $required = ['title', 'description', 'price', 'category', 'location'];
        foreach ($required as $f) {
            if (empty($data[$f])) {
                http_response_code(400);
                echo json_encode(['error' => "Falta el campo obligatorio: $f"]);
                return;
            }
        }

        // Obtener datos del usuario
        require_once __DIR__ . '/../models/User.php';
        $user = (new User())->find($auth->id);
        if (!$user) {
            http_response_code(404);
            echo json_encode(['error' => 'Usuario no encontrado']);
            return;
        }

        // Preparar payload con TODAS las columnas
        $payload = [
            'user_id'             => $user['id'],
            'title'               => htmlspecialchars(trim($data['title']), ENT_QUOTES, 'UTF-8'),
            'description'         => htmlspecialchars(trim($data['description']), ENT_QUOTES, 'UTF-8'),
            'price'               => max(0, (int) $data['price']),
            'category'            => htmlspecialchars(trim($data['category']), ENT_QUOTES, 'UTF-8'),
            'location'            => htmlspecialchars(trim($data['location']), ENT_QUOTES, 'UTF-8'),
            'image_url'           => null,
            'provider_name'       => htmlspecialchars($user['name'] ?? 'Anónimo', ENT_QUOTES, 'UTF-8'),
            'provider_avatar_url' => $user['avatar_url'] ?? null,
            'provider_rating'     => (float) ($user['average_rating'] ?? 5.0),
            'status'              => 'pending',
            'isAvailable'         => 1,
        ];

        // Guardar imagen si existe
        if (!empty($_FILES['image']['name'])) {
            $file = $_FILES['image'];
            if ($file['error'] !== UPLOAD_ERR_OK) {
                http_response_code(400);
                echo json_encode(['error' => 'Error al subir imagen']);
                return;
            }
            if ($file['size'] > self::MAX_IMAGE_SIZE) {
                http_response_code(400);
                echo json_encode(['error' => 'Imagen demasiado pesada (máx 2 MB)']);
                return;
            }
            [$width, $height] = getimagesize($file['tmp_name']);
            if (!$width || $width > self::MAX_WIDTH || $height > self::MAX_HEIGHT) {
                http_response_code(400);
                echo json_encode(['error' => 'Dimensiones de imagen no válidas']);
                return;
            }
            $allowed = ['image/jpeg', 'image/png', 'image/webp'];
            if (!in_array($file['type'], $allowed, true)) {
                http_response_code(400);
                echo json_encode(['error' => 'Formato de imagen no permitido']);
                return;
            }
            if (!is_dir(self::UPLOAD_DIR)) {
                mkdir(self::UPLOAD_DIR, 0755, true);
            }
            $ext      = pathinfo($file['name'], PATHINFO_EXTENSION);
            $filename = uniqid('service_', true) . '.' . $ext;
            $target   = self::UPLOAD_DIR . $filename;
            if (!move_uploaded_file($file['tmp_name'], $target)) {
                http_response_code(500);
                echo json_encode(['error' => 'No se pudo guardar la imagen']);
                return;
            }
            $payload['image_url'] = '/uploads/services/' . $filename;
        }

        // Persistir
        if ($this->model->create($payload)) {
            $this->emitWs([
                'receiver_role' => 'user',
                'receiver_id'   => 0,
                'title'         => 'Nuevo servicio disponible',
                'message'       => 'Se ha añadido un nuevo servicio.'
            ]);
            http_response_code(201);
            echo json_encode(['message' => 'Servicio creado correctamente']);
        } else {
            http_response_code(500);
            echo json_encode(['error' => 'Error al guardar el servicio']);
        }
    }

    /* ----------  RESTO DE MÉTODOS  ---------- */
    private function mine(object $auth): void
    {
        header('Content-Type: application/json');
        echo json_encode($this->model->getByUser($auth->id));
    }

    private function all(object $auth): void
    {
        header('Content-Type: application/json');
        if ($auth->role !== 'admin') {
            $this->unauthorized();
            return;
        }
        echo json_encode($this->model->getAll());
    }

    private function update(object $auth): void
    {
        header('Content-Type: application/json');
        $data = json_decode(file_get_contents('php://input'), true);
        if (empty($data['id'])) {
            http_response_code(400);
            echo json_encode(['error' => 'ID requerido']);
            return;
        }
        $ok = $this->model->update($data['id'], $auth->id, $data);
        if ($ok) {
            $this->emitWs([
                'receiver_role' => 'user',
                'receiver_id'   => 0,
                'title'         => 'Servicio actualizado',
                'message'       => 'Un servicio ha sido modificado.'
            ]);
            echo json_encode(['message' => 'Servicio actualizado correctamente']);
        } else {
            http_response_code(500);
            echo json_encode(['error' => 'Error al actualizar el servicio']);
        }
    }

    private function delete(object $auth): void
    {
        header('Content-Type: application/json');
        $data = json_decode(file_get_contents('php://input'), true);
        if (empty($data['id'])) {
            http_response_code(400);
            echo json_encode(['error' => 'ID requerido']);
            return;
        }
        $ok = $this->model->delete($data['id'], $auth->id);
        if ($ok) {
            $this->emitWs([
                'receiver_role' => 'user',
                'receiver_id'   => 0,
                'title'         => 'Servicio eliminado',
                'message'       => 'Un servicio ya no está disponible.'
            ]);
            echo json_encode(['message' => 'Servicio eliminado correctamente']);
        } else {
            http_response_code(500);
            echo json_encode(['error' => 'Error al eliminar el servicio']);
        }
    }

    private function available(object $auth): void
    {
        header('Content-Type: application/json');
        echo json_encode($this->model->getAvailable($auth->id));
    }
}
