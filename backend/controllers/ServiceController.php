<?php
// backend/controllers/ServiceController.php
require_once __DIR__ . "/../middleware/Auth.php";
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../models/Service.php';
require_once __DIR__ . '/../utils/jwt.php';
require_once __DIR__ . '/../services/WebSocketService.php';
require_once __DIR__ . '/../utils/AuditLogger.php';
require_once __DIR__ . '/../utils/Uploader.php';
use services\WebSocketService;

class ServiceController
{
    private Service $model;
    private const MAX_IMAGE_SIZE = 2 * 1024 * 1024;
    private const MAX_WIDTH      = 2000;
    private const MAX_HEIGHT     = 2000;

    public function __construct()
    {
        $this->model = new Service();
    }

    /* ----------  AUTH  ---------- */
    private function unauthorized(): void
    {
        http_response_code(401);
        header('Content-Type: application/json');
        echo json_encode(['error' => 'No autorizado']);
    }

    /* ----------  RATE LIMIT  ---------- */
    private function rateLimit(int $userId): bool
    {
        $key = "rate:service:$userId";
        try {
            $redis = new Redis();
            if (!$redis->connect('127.0.0.1')) {
                throw new RedisException("Conexión rechazada");
            }
            $current = $redis->incr($key);
            if ($current === 1) $redis->expire($key, 3600);
            return $current <= 20;
        } catch (RedisException $e) {
            error_log('Redis down: ' . $e->getMessage());
            http_response_code(503);
            header('Content-Type: application/json');
            echo json_encode(['error' => 'Servicio temporalmente no disponible o verifique si redis esta activo']);
            exit;
        }
    }

    /* ----------  ROUTER  ---------- */
    public function handle(string $method): void
    {
        $auth = Auth::verify();
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
            $method === 'GET'  && preg_match('#/api/services/(\d+)$#', $path, $m) => $this->getById((int)$m[1]),
            default => $this->notFound()
        };
    }

    private function notFound(): void
    {
        http_response_code(404);
        header('Content-Type: application/json');
        echo json_encode(['error' => 'Ruta no válida']);
    }

    public function getById(int $id): void
    {
        $service = $this->model->findById($id);

        if (!$service) {
            http_response_code(404);
            header('Content-Type: application/json');
            echo json_encode(['error' => 'Servicio no encontrado']);
            return;
        }

        header('Content-Type: application/json');
        echo json_encode(['data' => $service]);
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

        $db = (new Database())->getConnection();
        $stmt = $db->prepare("SELECT name, avatar_url, average_rating FROM users WHERE id = :id");
        $stmt->execute([':id' => $auth->id]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        $data['provider_name']       = $user['name'] ?? 'Proveedor';
        $data['provider_avatar_url'] = $user['avatar_url'] ?? null;
        $data['provider_rating']     = $user['average_rating'] ?? 5.0;

        // Obtener el ID del servicio creado
        $serviceId = $this->model->create($data);

        if ($serviceId) {
            // LOG
            AuditLogger::log($auth->id, 'service_created', 'Servicio creado', "ID: {$serviceId} - Título: {$data['title']} - Precio: \${$data['price']}");

            // CORREGIDO: Usar sendNotification en lugar de emit() con formato incorrecto
            WebSocketService::sendNotification(
                'admin',
                1,
                'Nuevo servicio pendiente de pago',
                "{$user['name']} creó el servicio '{$data['title']}' - Pendiente de pago",
                [
                    'url' => '/admin/services',
                    'action' => 'review_service',
                    'notification_type' => 'new_service',
                    'service_id' => $serviceId
                ]
            );

            // Devolver ID para redirigir al pago
            echo json_encode([
                'success' => true,
                'message' => 'Servicio creado correctamente',
                'service_id' => (int)$serviceId
            ]);
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
            AuditLogger::log($auth->id, 'service_updated', 'Servicio actualizado', "ID: {$id} - Título: {$data['title']}");

            // CORREGIDO: Usar emitToRole en lugar de emit() con formato incorrecto
            WebSocketService::emitToRole('user', 'new-notification', [
                'title'   => 'Servicio actualizado',
                'message' => 'Un servicio ha sido modificado.',
                'url'     => '/service/' . $id,
                'action'  => 'view_service',
                'notification_type' => 'service_update'
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

        try {
            $service = $this->model->findById((int)$id);
            $title = $service['title'] ?? 'Desconocido';

            $deleted = $this->model->delete((int)$id, $auth->id);
            if (!$deleted) {
                http_response_code(404);
                echo json_encode(['error' => 'Servicio no encontrado.']);
                return;
            }

            AuditLogger::log($auth->id, 'service_deleted', 'Servicio eliminado', "ID: {$id} - Título: {$title}");

            // CORREGIDO: Usar emitToRole en lugar de emit() con formato incorrecto
            WebSocketService::emitToRole('user', 'new-notification', [
                'title'   => 'Servicio eliminado',
                'message' => 'Un servicio ya no está disponible.',
                'url'     => '/dashboard/user',
                'action'  => 'default',
                'notification_type' => 'service_deleted'
            ]);
            echo json_encode(['message' => 'Servicio eliminado correctamente']);
        } catch (PDOException $e) {
            if ($e->getCode() === '23000' || $e->getCode() === '1451') {
                http_response_code(409);
                echo json_encode(['message' => 'No se puede eliminar el servicio porque tiene un servicio activo asociado.']);
            } else {
                http_response_code(500);
                echo json_encode(['error' => 'Error al eliminar el servicio']);
            }
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

        $basePath = __DIR__ . '/../public/uploads';
        $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? 'https://' : 'http://';
        $baseUrl = $protocol . $_SERVER['HTTP_HOST'] . '/uploads';
        $uploader = new \Utils\Uploader($basePath, $baseUrl);
        try {
            return $uploader->saveFile($file, \Utils\Uploader::CAT_SERVICES);
        } catch (\RuntimeException $e) {
            error_log("Error subiendo imagen de servicio: " . $e->getMessage());
            return null;
        }
    }
}
