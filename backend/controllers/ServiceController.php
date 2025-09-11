<?php
// backend/controllers/ServiceController.php

require_once __DIR__ . '/../models/Service.php';
require_once __DIR__ . '/../utils/jwt.php';

class ServiceController
{
    private Service $model;
    private const MAX_IMAGE_SIZE = 2 * 1024 * 1024;
    private const MAX_WIDTH      = 2000;
    private const MAX_HEIGHT     = 2000;
    private const UPLOAD_DIR     = __DIR__ . '/../public/uploads/services/';

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
        if (!$redis->connect('127.0.0.1')) return true;
        $current = $redis->incr($key);
        if ($current === 1) $redis->expire($key, 3600);
        return $current <= 20;
    }

    /* ----------  WS NOTIFICATION  ---------- */
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

    /* ----------  ROUTER  ---------- */
    public function handle(string $method): void
    {
        $auth = $this->auth();
        if (!$auth) {
            $this->unauthorized();
            return;
        }

        $path = $_SERVER['REQUEST_URI'];

        match (true) {
            $method === 'POST' && preg_match('#/api/services/?$#', $path)        => $this->create($auth),
            $method === 'GET'  && preg_match('#/api/services/mine/?$#', $path)   => $this->mine($auth),
            $method === 'GET'  && preg_match('#/api/services/all/?$#', $path)    => $this->all($auth),
            $method === 'POST' && preg_match('#/api/services/update/?$#', $path) => $this->update($auth),
            $method === 'POST' && preg_match('#/api/services/delete/?$#', $path) => $this->delete($auth),
            $method === 'GET'  && preg_match('#/api/services/?$#', $path)        => $this->available($auth),
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

        if (!$this->rateLimit($auth->id)) {
            http_response_code(429);
            echo json_encode(['error' => 'Demasiadas peticiones']);
            return;
        }

        $data = $this->extractServiceDataFromRequest();

        if (!$data) return;

        $data['user_id'] = $auth->id;
        $data['image_url'] = $this->handleImageUpload();

        if ($this->model->create($data)) {
            $this->emitWs([
                'receiver_role' => 'user',
                'receiver_id'   => 0,
                'title'         => 'Nuevo servicio disponible',
                'message'       => 'Se ha añadido un nuevo servicio.'
            ]);
            echo json_encode(['message' => 'Servicio creado correctamente']);
        } else {
            http_response_code(500);
            echo json_encode(['error' => 'Error al guardar el servicio']);
        }
    }

    /* ----------  READ  ---------- */
    private function mine(object $auth): void
    {
        header('Content-Type: application/json');
        echo json_encode($this->model->getByUser($auth->id));
    }

    private function all(object $auth): void
    {
        header('Content-Type: application/json');
        if (($auth->role ?? '') !== 'admin') {
            $this->unauthorized();
            return;
        }
        echo json_encode($this->model->getAll());
    }

    private function available(object $auth): void
    {
        header('Content-Type: application/json');
        echo json_encode($this->model->getAvailable($auth->id));
    }

    /* ----------  UPDATE  ---------- */
    private function update(object $auth): void
    {
        header('Content-Type: application/json');

        $id = $_POST['id'] ?? null;
        if (!$id) {
            http_response_code(400);
            echo json_encode(['error' => 'ID requerido']);
            return;
        }

        $data = $this->extractServiceDataFromRequest();
        if (!$data) return;

        $imageUrl = $this->handleImageUpload();
        if ($imageUrl) $data['image_url'] = $imageUrl;

        if ($this->model->update((int)$id, $auth->id, $data)) {
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

    /* ----------  DELETE  ---------- */
    private function delete(object $auth): void
    {
        header('Content-Type: application/json');

        $input = json_decode(file_get_contents('php://input'), true);
        $id    = $input['id'] ?? null;
        if (!$id) {
            http_response_code(400);
            echo json_encode(['error' => 'ID requerido']);
            return;
        }

        if ($this->model->delete((int)$id, $auth->id)) {
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

    /* ----------  HELPERS  ---------- */
    private function extractServiceDataFromRequest(): ?array
    {
        $required = ['title', 'description', 'price', 'category', 'location'];
        foreach ($required as $f) {
            if (empty($_POST[$f])) {
                http_response_code(400);
                echo json_encode(['error' => "Falta el campo obligatorio: $f"]);
                return null;
            }
        }

        return [
            'title'           => htmlspecialchars(trim($_POST['title']), ENT_QUOTES, 'UTF-8'),
            'description'     => htmlspecialchars(trim($_POST['description']), ENT_QUOTES, 'UTF-8'),
            'service_details' => htmlspecialchars(trim($_POST['service_details'] ?? ''), ENT_QUOTES, 'UTF-8'),
            'price'           => max(0, (int)$_POST['price']),
            'category'        => htmlspecialchars(trim($_POST['category']), ENT_QUOTES, 'UTF-8'),
            'location'        => htmlspecialchars(trim($_POST['location']), ENT_QUOTES, 'UTF-8'),
            'status'          => 'pending',
            'isAvailable'     => 1,
        ];
    }

    private function handleImageUpload(): ?string
    {
        if (empty($_FILES['image']['name'])) return null;

        $file = $_FILES['image'];
        if ($file['error'] !== UPLOAD_ERR_OK) return null;
        if ($file['size'] > self::MAX_IMAGE_SIZE) return null;

        [$width, $height] = getimagesize($file['tmp_name']);
        if (!$width || $width > self::MAX_WIDTH || $height > self::MAX_HEIGHT) return null;

        $allowed = ['image/jpeg', 'image/png', 'image/webp'];
        if (!in_array($file['type'], $allowed, true)) return null;

        if (!is_dir(self::UPLOAD_DIR)) mkdir(self::UPLOAD_DIR, 0755, true);

        $ext      = pathinfo($file['name'], PATHINFO_EXTENSION);
        $filename = uniqid('service_', true) . '.' . $ext;
        $target   = self::UPLOAD_DIR . $filename;

        return move_uploaded_file($file['tmp_name'], $target)
            ? '/uploads/services/' . $filename
            : null;
    }
}
