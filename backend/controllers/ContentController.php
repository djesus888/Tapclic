<?php
// backend/controllers/ContentController.php
require_once __DIR__ . "/../middleware/Auth.php";
require_once __DIR__ . '/../config/database.php';

class ContentController
{
    private \PDO $conn;

    public function __construct()
    {
        $this->conn = (new Database())->getConnection();
    }

    private function requireAdmin(): void
    {
        $auth = Auth::verify();
        if (($auth->role ?? '') !== 'admin') {
            http_response_code(401);
            echo json_encode(['error' => 'No autorizado']);
            exit;
        }
    }

    /* ---------- CATEGORÍAS ---------- */
    public function listCategories(): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $stmt = $this->conn->query("
            SELECT c.*, COUNT(s.id) as service_count
            FROM categories c
            LEFT JOIN services s ON s.category = c.name
            GROUP BY c.id
            ORDER BY c.sort_order ASC, c.name ASC
        ");
        $categories = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode(['categories' => $categories]);
    }

    public function createCategory(): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $input = json_decode(file_get_contents('php://input'), true);
        $required = ['name'];
        
        foreach ($required as $field) {
            if (empty($input[$field])) {
                http_response_code(400);
                echo json_encode(['error' => "Falta el campo: $field"]);
                return;
            }
        }

        // Obtener último sort_order
        $stmt = $this->conn->query("SELECT MAX(sort_order) as max_order FROM categories");
        $maxOrder = (int)$stmt->fetchColumn();

        $sql = "INSERT INTO categories (name, description, icon, color, sort_order, created_at) 
                VALUES (:name, :description, :icon, :color, :sort_order, NOW())";
        
        $stmt = $this->conn->prepare($sql);
        $success = $stmt->execute([
            ':name' => $input['name'],
            ':description' => $input['description'] ?? '',
            ':icon' => $input['icon'] ?? '📦',
            ':color' => $input['color'] ?? '#667eea',
            ':sort_order' => $maxOrder + 1
        ]);

        if ($success) {
            $id = $this->conn->lastInsertId();
            $stmt = $this->conn->query("SELECT * FROM categories WHERE id = $id");
            $category = $stmt->fetch(PDO::FETCH_ASSOC);
            echo json_encode(['category' => $category]);
        } else {
            http_response_code(500);
            echo json_encode(['error' => 'Error al crear categoría']);
        }
    }

    public function updateCategory(int $id): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $input = json_decode(file_get_contents('php://input'), true);
        
        $allowed = ['name', 'description', 'icon', 'color', 'is_active'];
        $sets = [];
        $params = [':id' => $id];

        foreach ($allowed as $field) {
            if (isset($input[$field])) {
                $sets[] = "$field = :$field";
                $params[":$field"] = $input[$field];
            }
        }

        if (empty($sets)) {
            http_response_code(400);
            echo json_encode(['error' => 'No hay campos para actualizar']);
            return;
        }

        $sql = "UPDATE categories SET " . implode(', ', $sets) . " WHERE id = :id";
        $stmt = $this->conn->prepare($sql);
        $success = $stmt->execute($params);

        if ($success) {
            $stmt = $this->conn->query("SELECT * FROM categories WHERE id = $id");
            $category = $stmt->fetch(PDO::FETCH_ASSOC);
            echo json_encode(['category' => $category]);
        } else {
            http_response_code(500);
            echo json_encode(['error' => 'Error al actualizar categoría']);
        }
    }

    public function deleteCategory(int $id): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        // Verificar si hay servicios en esta categoría
        $stmt = $this->conn->prepare("SELECT name FROM categories WHERE id = :id");
        $stmt->execute([':id' => $id]);
        $category = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($category) {
            // Contar servicios en esta categoría
            $stmt = $this->conn->prepare("SELECT COUNT(*) FROM services WHERE category = :category");
            $stmt->execute([':category' => $category['name']]);
            $serviceCount = $stmt->fetchColumn();

            if ($serviceCount > 0) {
                http_response_code(400);
                echo json_encode(['error' => 'No se puede eliminar: hay servicios en esta categoría']);
                return;
            }

            $stmt = $this->conn->prepare("DELETE FROM categories WHERE id = :id");
            $success = $stmt->execute([':id' => $id]);

            if ($success) {
                echo json_encode(['message' => 'Categoría eliminada']);
            } else {
                http_response_code(500);
                echo json_encode(['error' => 'Error al eliminar categoría']);
            }
        }
    }

    public function updateCategoryStatus(int $id): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $input = json_decode(file_get_contents('php://input'), true);
        $is_active = $input['is_active'] ?? 0;

        $stmt = $this->conn->prepare("UPDATE categories SET is_active = :is_active WHERE id = :id");
        $success = $stmt->execute([':is_active' => $is_active, ':id' => $id]);

        if ($success) {
            echo json_encode(['message' => 'Estado actualizado']);
        } else {
            http_response_code(500);
            echo json_encode(['error' => 'Error al actualizar estado']);
        }
    }

    public function updateCategoriesOrder(): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $input = json_decode(file_get_contents('php://input'), true);
        $order = $input['order'] ?? [];

        $this->conn->beginTransaction();
        try {
            foreach ($order as $item) {
                $stmt = $this->conn->prepare("UPDATE categories SET sort_order = :sort_order WHERE id = :id");
                $stmt->execute([
                    ':sort_order' => $item['sort_order'],
                    ':id' => $item['id']
                ]);
            }
            $this->conn->commit();
            echo json_encode(['message' => 'Orden actualizado']);
        } catch (Exception $e) {
            $this->conn->rollBack();
            http_response_code(500);
            echo json_encode(['error' => 'Error al actualizar orden: ' . $e->getMessage()]);
        }
    }

    /* ---------- PÁGINAS ESTÁTICAS ---------- */
    public function listPages(): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $stmt = $this->conn->query("SELECT * FROM static_pages ORDER BY sort_order ASC, title ASC");
        $pages = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode(['pages' => $pages]);
    }

    public function createPage(): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $input = json_decode(file_get_contents('php://input'), true);
        $required = ['title', 'slug'];
        
        foreach ($required as $field) {
            if (empty($input[$field])) {
                http_response_code(400);
                echo json_encode(['error' => "Falta el campo: $field"]);
                return;
            }
        }

        // Verificar slug único
        $stmt = $this->conn->prepare("SELECT id FROM static_pages WHERE slug = :slug");
        $stmt->execute([':slug' => $input['slug']]);
        if ($stmt->fetch()) {
            http_response_code(400);
            echo json_encode(['error' => 'El slug ya existe']);
            return;
        }

        $sql = "INSERT INTO static_pages (title, slug, content, meta_title, meta_description, meta_keywords, created_at) 
                VALUES (:title, :slug, :content, :meta_title, :meta_description, :meta_keywords, NOW())";
        
        $stmt = $this->conn->prepare($sql);
        $success = $stmt->execute([
            ':title' => $input['title'],
            ':slug' => $input['slug'],
            ':content' => $input['content'] ?? '',
            ':meta_title' => $input['meta_title'] ?? '',
            ':meta_description' => $input['meta_description'] ?? '',
            ':meta_keywords' => $input['meta_keywords'] ?? ''
        ]);

        if ($success) {
            $id = $this->conn->lastInsertId();
            $stmt = $this->conn->query("SELECT * FROM static_pages WHERE id = $id");
            $page = $stmt->fetch(PDO::FETCH_ASSOC);
            echo json_encode(['page' => $page]);
        } else {
            http_response_code(500);
            echo json_encode(['error' => 'Error al crear página']);
        }
    }

    public function updatePage(int $id): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $input = json_decode(file_get_contents('php://input'), true);
        
        $allowed = ['title', 'slug', 'content', 'meta_title', 'meta_description', 'meta_keywords', 'is_active', 'is_in_menu'];
        $sets = [];
        $params = [':id' => $id];

        foreach ($allowed as $field) {
            if (isset($input[$field])) {
                $sets[] = "$field = :$field";
                $params[":$field"] = $input[$field];
            }
        }

        if (empty($sets)) {
            http_response_code(400);
            echo json_encode(['error' => 'No hay campos para actualizar']);
            return;
        }

        // Verificar slug único (excepto para el mismo registro)
        if (isset($input['slug'])) {
            $stmt = $this->conn->prepare("SELECT id FROM static_pages WHERE slug = :slug AND id != :id");
            $stmt->execute([':slug' => $input['slug'], ':id' => $id]);
            if ($stmt->fetch()) {
                http_response_code(400);
                echo json_encode(['error' => 'El slug ya existe']);
                return;
            }
        }

        $sql = "UPDATE static_pages SET " . implode(', ', $sets) . " WHERE id = :id";
        $stmt = $this->conn->prepare($sql);
        $success = $stmt->execute($params);

        if ($success) {
            $stmt = $this->conn->query("SELECT * FROM static_pages WHERE id = $id");
            $page = $stmt->fetch(PDO::FETCH_ASSOC);
            echo json_encode(['page' => $page]);
        } else {
            http_response_code(500);
            echo json_encode(['error' => 'Error al actualizar página']);
        }
    }

    public function deletePage(int $id): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        // No permitir eliminar páginas por defecto
        $stmt = $this->conn->prepare("SELECT slug FROM static_pages WHERE id = :id");
        $stmt->execute([':id' => $id]);
        $page = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($page) {
            $defaultPages = ['terms', 'privacy', 'about', 'help', 'contact'];
            if (in_array($page['slug'], $defaultPages)) {
                http_response_code(400);
                echo json_encode(['error' => 'No se puede eliminar una página por defecto']);
                return;
            }

            $stmt = $this->conn->prepare("DELETE FROM static_pages WHERE id = :id");
            $success = $stmt->execute([':id' => $id]);

            if ($success) {
                echo json_encode(['message' => 'Página eliminada']);
            } else {
                http_response_code(500);
                echo json_encode(['error' => 'Error al eliminar página']);
            }
        }
    }

    public function updatePageStatus(int $id): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $input = json_decode(file_get_contents('php://input'), true);
        $is_active = $input['is_active'] ?? 0;

        $stmt = $this->conn->prepare("UPDATE static_pages SET is_active = :is_active WHERE id = :id");
        $success = $stmt->execute([':is_active' => $is_active, ':id' => $id]);

        if ($success) {
            echo json_encode(['message' => 'Estado actualizado']);
        } else {
            http_response_code(500);
            echo json_encode(['error' => 'Error al actualizar estado']);
        }
    }

    public function updatePageMenu(int $id): void
{
    $this->requireAdmin();
    header('Content-Type: application/json');
    
    try {
        // Obtener y validar datos
        $input = json_decode(file_get_contents('php://input'), true);
        
        if (json_last_error() !== JSON_ERROR_NONE) {
            http_response_code(400);
            echo json_encode([
                'success' => false,
                'message' => 'JSON inválido'
            ]);
            return;
        }
        
        // Validar que is_in_menu esté presente
        if (!isset($input['is_in_menu'])) {
            http_response_code(400);
            echo json_encode([
                'success' => false,
                'message' => 'El campo is_in_menu es requerido'
            ]);
            return;
        }
        
        // Buscar página
        $page = Page::find($id);
        
        if (!$page) {
            http_response_code(404);
            echo json_encode([
                'success' => false,
                'message' => 'Página no encontrada'
            ]);
            return;
        }
        
        // Actualizar
        $page->is_in_menu = (bool) $input['is_in_menu'];
        $page->save();
        
        echo json_encode([
            'success' => true,
            'message' => 'Estado del menú actualizado correctamente',
            'data' => [
                'id' => $page->id,
                'title' => $page->title,
                'is_in_menu' => $page->is_in_menu
            ]
        ]);
        
    } catch (\Exception $e) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Error interno del servidor: ' . $e->getMessage()
        ]);
    }
}
    /* ---------- BLOQUES DE CONTENIDO ---------- */
    public function listBlocks(): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $stmt = $this->conn->query("SELECT * FROM content_blocks ORDER BY created_at DESC");
        $blocks = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode(['blocks' => $blocks]);
    }

    public function createBlock(): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $input = json_decode(file_get_contents('php://input'), true);
        $required = ['name', 'identifier', 'type'];
        
        foreach ($required as $field) {
            if (empty($input[$field])) {
                http_response_code(400);
                echo json_encode(['error' => "Falta el campo: $field"]);
                return;
            }
        }

        // Verificar identifier único
        $stmt = $this->conn->prepare("SELECT id FROM content_blocks WHERE identifier = :identifier");
        $stmt->execute([':identifier' => $input['identifier']]);
        if ($stmt->fetch()) {
            http_response_code(400);
            echo json_encode(['error' => 'El identificador ya existe']);
            return;
        }

        $sql = "INSERT INTO content_blocks (name, identifier, type, content, settings, created_at) 
                VALUES (:name, :identifier, :type, :content, :settings, NOW())";
        
        $stmt = $this->conn->prepare($sql);
        $success = $stmt->execute([
            ':name' => $input['name'],
            ':identifier' => $input['identifier'],
            ':type' => $input['type'],
            ':content' => $input['content'] ?? '',
            ':settings' => isset($input['settings']) ? json_encode($input['settings']) : '{}'
        ]);

        if ($success) {
            $id = $this->conn->lastInsertId();
            $stmt = $this->conn->query("SELECT * FROM content_blocks WHERE id = $id");
            $block = $stmt->fetch(PDO::FETCH_ASSOC);
            
            // Decodificar settings JSON
            if ($block['settings']) {
                $block['settings'] = json_decode($block['settings'], true);
            }
            
            echo json_encode(['block' => $block]);
        } else {
            http_response_code(500);
            echo json_encode(['error' => 'Error al crear bloque']);
        }
    }

    public function updateBlock(int $id): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $input = json_decode(file_get_contents('php://input'), true);
        
        $allowed = ['name', 'identifier', 'type', 'content', 'settings', 'is_active'];
        $sets = [];
        $params = [':id' => $id];

        foreach ($allowed as $field) {
            if (isset($input[$field])) {
                if ($field === 'settings') {
                    $sets[] = "$field = :$field";
                    $params[":$field"] = json_encode($input[$field]);
                } else {
                    $sets[] = "$field = :$field";
                    $params[":$field"] = $input[$field];
                }
            }
        }

        if (empty($sets)) {
            http_response_code(400);
            echo json_encode(['error' => 'No hay campos para actualizar']);
            return;
        }

        // Verificar identifier único (excepto para el mismo registro)
        if (isset($input['identifier'])) {
            $stmt = $this->conn->prepare("SELECT id FROM content_blocks WHERE identifier = :identifier AND id != :id");
            $stmt->execute([':identifier' => $input['identifier'], ':id' => $id]);
            if ($stmt->fetch()) {
                http_response_code(400);
                echo json_encode(['error' => 'El identificador ya existe']);
                return;
            }
        }

        $sql = "UPDATE content_blocks SET " . implode(', ', $sets) . " WHERE id = :id";
        $stmt = $this->conn->prepare($sql);
        $success = $stmt->execute($params);

        if ($success) {
            $stmt = $this->conn->query("SELECT * FROM content_blocks WHERE id = $id");
            $block = $stmt->fetch(PDO::FETCH_ASSOC);
            
            // Decodificar settings JSON
            if ($block['settings']) {
                $block['settings'] = json_decode($block['settings'], true);
            }
            
            echo json_encode(['block' => $block]);
        } else {
            http_response_code(500);
            echo json_encode(['error' => 'Error al actualizar bloque']);
        }
    }

    public function deleteBlock(int $id): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $stmt = $this->conn->prepare("DELETE FROM content_blocks WHERE id = :id");
        $success = $stmt->execute([':id' => $id]);

        if ($success) {
            echo json_encode(['message' => 'Bloque eliminado']);
        } else {
            http_response_code(500);
            echo json_encode(['error' => 'Error al eliminar bloque']);
        }
    }

    public function updateBlockStatus(int $id): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $input = json_decode(file_get_contents('php://input'), true);
        $is_active = $input['is_active'] ?? 0;

        $stmt = $this->conn->prepare("UPDATE content_blocks SET is_active = :is_active WHERE id = :id");
        $success = $stmt->execute([':is_active' => $is_active, ':id' => $id]);

        if ($success) {
            echo json_encode(['message' => 'Estado actualizado']);
        } else {
            http_response_code(500);
            echo json_encode(['error' => 'Error al actualizar estado']);
        }
    }

    /* ---------- HANDLE METHOD ---------- */
    public function handle(string $method): void
    {
        $path = $_SERVER['REQUEST_URI'];
        
        // Rutas para categorías
        if (preg_match('~/api/admin/content/categories/?$~', $path)) {
            if ($method === 'GET') {
                $this->listCategories();
            } elseif ($method === 'POST') {
                $this->createCategory();
            } elseif ($method === 'PUT' && strpos($path, '/order') !== false) {
                $this->updateCategoriesOrder();
            }
        } elseif (preg_match('~/api/admin/content/categories/(\d+)/status~', $path, $matches)) {
            if ($method === 'PUT') {
                $this->updateCategoryStatus((int)$matches[1]);
            }
        } elseif (preg_match('~/api/admin/content/categories/(\d+)~', $path, $matches)) {
            $id = (int)$matches[1];
            if ($method === 'PUT') {
                $this->updateCategory($id);
            } elseif ($method === 'DELETE') {
                $this->deleteCategory($id);
            }
        }
        
        // Rutas para páginas
        elseif (preg_match('~/api/admin/content/pages/?$~', $path)) {
            if ($method === 'GET') {
                $this->listPages();
            } elseif ($method === 'POST') {
                $this->createPage();
            }
        } elseif (preg_match('~/api/admin/content/pages/(\d+)/status~', $path, $matches)) {
            if ($method === 'PUT') {
                $this->updatePageStatus((int)$matches[1]);
            }
        } elseif (preg_match('~/api/admin/content/pages/(\d+)/menu~', $path, $matches)) {
            if ($method === 'PUT') {
                $this->updatePageMenu((int)$matches[1]);
            }
        } elseif (preg_match('~/api/admin/content/pages/(\d+)~', $path, $matches)) {
            $id = (int)$matches[1];
            if ($method === 'PUT') {
                $this->updatePage($id);
            } elseif ($method === 'DELETE') {
                $this->deletePage($id);
            }
        }
        
        // Rutas para bloques
        elseif (preg_match('~/api/admin/content/blocks/?$~', $path)) {
            if ($method === 'GET') {
                $this->listBlocks();
            } elseif ($method === 'POST') {
                $this->createBlock();
            }
        } elseif (preg_match('~/api/admin/content/blocks/(\d+)/status~', $path, $matches)) {
            if ($method === 'PUT') {
                $this->updateBlockStatus((int)$matches[1]);
            }
        } elseif (preg_match('~/api/admin/content/blocks/(\d+)~', $path, $matches)) {
            $id = (int)$matches[1];
            if ($method === 'PUT') {
                $this->updateBlock($id);
            } elseif ($method === 'DELETE') {
                $this->deleteBlock($id);
            }
        }
        
        // Rutas para FAQs (si las agregas)
        elseif (preg_match('~/api/admin/content/faqs/?$~', $path)) {
            if ($method === 'GET') {
                $this->listFaqs();
            } elseif ($method === 'POST') {
                $this->createFaq();
            } elseif ($method === 'PUT' && strpos($path, '/order') !== false) {
                $this->updateFaqsOrder();
            }
        } elseif (preg_match('~/api/admin/content/faqs/(\d+)/status~', $path, $matches)) {
            if ($method === 'PUT') {
                $this->updateFaqStatus((int)$matches[1]);
            }
        } elseif (preg_match('~/api/admin/content/faqs/(\d+)~', $path, $matches)) {
            $id = (int)$matches[1];
            if ($method === 'PUT') {
                $this->updateFaq($id);
            } elseif ($method === 'DELETE') {
                $this->deleteFaq($id);
            }
        }
        
        else {
            http_response_code(404);
            echo json_encode(['error' => 'Ruta no encontrada']);
        }
    }

    /* ---------- MÉTODOS PARA FAQs (si decides agregarlos) ---------- */
    public function listFaqs(): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $stmt = $this->conn->query("SELECT * FROM faqs ORDER BY sort_order ASC, created_at DESC");
        $faqs = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode(['faqs' => $faqs]);
    }

    public function createFaq(): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $input = json_decode(file_get_contents('php://input'), true);
        $required = ['question', 'answer'];
        
        foreach ($required as $field) {
            if (empty($input[$field])) {
                http_response_code(400);
                echo json_encode(['error' => "Falta el campo: $field"]);
                return;
            }
        }

        // Obtener último sort_order
        $stmt = $this->conn->query("SELECT MAX(sort_order) as max_order FROM faqs");
        $maxOrder = (int)$stmt->fetchColumn();

        $sql = "INSERT INTO faqs (question, answer, sort_order, created_at) 
                VALUES (:question, :answer, :sort_order, NOW())";
        
        $stmt = $this->conn->prepare($sql);
        $success = $stmt->execute([
            ':question' => $input['question'],
            ':answer' => $input['answer'],
            ':sort_order' => $maxOrder + 1
        ]);

        if ($success) {
            $id = $this->conn->lastInsertId();
            $stmt = $this->conn->query("SELECT * FROM faqs WHERE id = $id");
            $faq = $stmt->fetch(PDO::FETCH_ASSOC);
            echo json_encode(['faq' => $faq]);
        } else {
            http_response_code(500);
            echo json_encode(['error' => 'Error al crear FAQ']);
        }
    }

    public function updateFaq(int $id): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $input = json_decode(file_get_contents('php://input'), true);
        
        $allowed = ['question', 'answer', 'is_active'];
        $sets = [];
        $params = [':id' => $id];

        foreach ($allowed as $field) {
            if (isset($input[$field])) {
                $sets[] = "$field = :$field";
                $params[":$field"] = $input[$field];
            }
        }

        if (empty($sets)) {
            http_response_code(400);
            echo json_encode(['error' => 'No hay campos para actualizar']);
            return;
        }

        $sql = "UPDATE faqs SET " . implode(', ', $sets) . " WHERE id = :id";
        $stmt = $this->conn->prepare($sql);
        $success = $stmt->execute($params);

        if ($success) {
            $stmt = $this->conn->query("SELECT * FROM faqs WHERE id = $id");
            $faq = $stmt->fetch(PDO::FETCH_ASSOC);
            echo json_encode(['faq' => $faq]);
        } else {
            http_response_code(500);
            echo json_encode(['error' => 'Error al actualizar FAQ']);
        }
    }

    public function deleteFaq(int $id): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $stmt = $this->conn->prepare("DELETE FROM faqs WHERE id = :id");
        $success = $stmt->execute([':id' => $id]);

        if ($success) {
            echo json_encode(['message' => 'FAQ eliminada']);
        } else {
            http_response_code(500);
            echo json_encode(['error' => 'Error al eliminar FAQ']);
        }
    }

    public function updateFaqStatus(int $id): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $input = json_decode(file_get_contents('php://input'), true);
        $is_active = $input['is_active'] ?? 0;

        $stmt = $this->conn->prepare("UPDATE faqs SET is_active = :is_active WHERE id = :id");
        $success = $stmt->execute([':is_active' => $is_active, ':id' => $id]);

        if ($success) {
            echo json_encode(['message' => 'Estado actualizado']);
        } else {
            http_response_code(500);
            echo json_encode(['error' => 'Error al actualizar estado']);
        }
    }

    public function updateFaqsOrder(): void
    {
        $this->requireAdmin();
        header('Content-Type: application/json');

        $input = json_decode(file_get_contents('php://input'), true);
        $order = $input['order'] ?? [];

        $this->conn->beginTransaction();
        try {
            foreach ($order as $item) {
                $stmt = $this->conn->prepare("UPDATE faqs SET sort_order = :sort_order WHERE id = :id");
                $stmt->execute([
                    ':sort_order' => $item['sort_order'],
                    ':id' => $item['id']
                ]);
            }
            $this->conn->commit();
            echo json_encode(['message' => 'Orden actualizado']);
        } catch (Exception $e) {
            $this->conn->rollBack();
            http_response_code(500);
            echo json_encode(['error' => 'Error al actualizar orden: ' . $e->getMessage()]);
        }
    }
}
