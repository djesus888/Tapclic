<?php
require_once __DIR__ . '/../config/database.php';

class FavoritesController
{
    private $conn;

    public function __construct()
    {
        $database = new Database();
        $this->conn = $database->getConnection();
    }

    private function getUserId(): int
    {
        $headers = getallheaders();
        $token = str_replace('Bearer ', '', $headers['Authorization'] ?? '');
        
        if (!$token) {
            http_response_code(401);
            echo json_encode(['error' => 'Token no proporcionado']);
            exit;
        }

        $parts = explode('.', $token);
        if (count($parts) !== 3) {
            http_response_code(401);
            echo json_encode(['error' => 'Token inválido']);
            exit;
        }

        $payload = json_decode(base64_decode($parts[1]), true);
        return (int)($payload['id'] ?? 0);
    }

    // GET /api/favorites
    public function index(): void
    {
        header("Content-Type: application/json; charset=UTF-8");
        
        try {
            $userId = $this->getUserId();
            
            $stmt = $this->conn->prepare("
                SELECT f.id, f.service_id, f.created_at as addedAt,
                       s.title as name, s.description, s.price,
                       s.category, s.image_url as image,
                       s.user_id as providerId, s.provider_name as providerName
                FROM favorites f
                JOIN services s ON f.service_id = s.id
                WHERE f.user_id = :userId
                ORDER BY f.created_at DESC
            ");
            $stmt->execute([':userId' => $userId]);
            $favorites = $stmt->fetchAll(PDO::FETCH_ASSOC);

            // Formatear datos
            foreach ($favorites as &$fav) {
                $fav['price'] = (float)($fav['price'] ?? 0);
                $fav['image'] = $fav['image'] ?? null;
                $fav['category'] = $fav['category'] ?? 'Sin categoría';
                $fav['providerName'] = $fav['providerName'] ?? 'Anónimo';
                $fav['providerId'] = (int)($fav['providerId'] ?? 0);
            }

            echo json_encode(array_values($favorites));
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Error al obtener favoritos: ' . $e->getMessage()]);
        }
    }

    // POST /api/favorites
    public function store(): void
    {
        header("Content-Type: application/json; charset=UTF-8");
        
        try {
            $userId = $this->getUserId();
            $input = json_decode(file_get_contents("php://input"), true);
            $serviceId = (int)($input['serviceId'] ?? 0);

            if (!$serviceId) {
                http_response_code(400);
                echo json_encode(['error' => 'ID de servicio requerido']);
                return;
            }

            $stmt = $this->conn->prepare("
                INSERT IGNORE INTO favorites (user_id, service_id) 
                VALUES (:userId, :serviceId)
            ");
            $stmt->execute([
                ':userId' => $userId,
                ':serviceId' => $serviceId
            ]);

            echo json_encode([
                'success' => true,
                'message' => 'Agregado a favoritos',
                'serviceId' => $serviceId
            ]);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Error al agregar favorito: ' . $e->getMessage()]);
        }
    }

    // DELETE /api/favorites/{serviceId}
    public function destroy(int $serviceId): void
    {
        header("Content-Type: application/json; charset=UTF-8");
        
        try {
            $userId = $this->getUserId();

            $stmt = $this->conn->prepare("
                DELETE FROM favorites 
                WHERE user_id = :userId AND service_id = :serviceId
            ");
            $stmt->execute([
                ':userId' => $userId,
                ':serviceId' => $serviceId
            ]);

            echo json_encode([
                'success' => true,
                'message' => 'Eliminado de favoritos'
            ]);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Error al eliminar favorito: ' . $e->getMessage()]);
        }
    }

    // DELETE /api/favorites (todos)
    public function clearAll(): void
    {
        header("Content-Type: application/json; charset=UTF-8");
        
        try {
            $userId = $this->getUserId();

            $stmt = $this->conn->prepare("DELETE FROM favorites WHERE user_id = :userId");
            $stmt->execute([':userId' => $userId]);

            echo json_encode([
                'success' => true,
                'message' => 'Todos los favoritos eliminados'
            ]);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Error al eliminar favoritos: ' . $e->getMessage()]);
        }
    }

    // GET /api/favorites/check/{serviceId}
    public function check(int $serviceId): void
    {
        header("Content-Type: application/json; charset=UTF-8");
        
        try {
            $userId = $this->getUserId();

            $stmt = $this->conn->prepare("
                SELECT id FROM favorites 
                WHERE user_id = :userId AND service_id = :serviceId
            ");
            $stmt->execute([
                ':userId' => $userId,
                ':serviceId' => $serviceId
            ]);

            echo json_encode([
                'isFavorite' => (bool)$stmt->fetch()
            ]);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Error al verificar favorito: ' . $e->getMessage()]);
        }
    }
}
