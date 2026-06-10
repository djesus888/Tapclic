<?php
// controllers/PaymentMethodController.php

require_once __DIR__ . '/../models/PaymentMethod.php';
require_once __DIR__ . '/../utils/jwt.php';

class PaymentMethodController {
    private PaymentMethod $paymentMethod;

    public function __construct() {
        $this->paymentMethod = new PaymentMethod();
    }

    /**
     * GET /api/payment-methods
     * Obtener todos los métodos de pago activos
     */
    public function index(): void {
        header('Content-Type: application/json');
        
        try {
            // Verificar autenticación igual que en AuthController->me()
            $user = $this->authenticate();
            if (!$user) {
                return;
            }

            // Obtener métodos de pago activos
            $result = $this->paymentMethod->getActiveMethods();
            
            echo json_encode([
                'success' => true,
                'methods' => $result['methods'],
                'details' => $result['details']
            ], JSON_UNESCAPED_UNICODE);

        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'error' => 'Error al cargar métodos de pago',
                'message' => $e->getMessage()
            ]);
        }
    }

/**
 * GET /api/provider/payment-methods
 * Obtener métodos de pago personales del proveedor autenticado
 */
public function providerIndex(): void
{
    header('Content-Type: application/json');

    try {
        $user = $this->authenticate();
        if (!$user) return;

        $stmt = $this->paymentMethod->getConnection()->prepare("
            SELECT * FROM provider_payment_methods 
            WHERE provider_id = ? 
            ORDER BY id ASC
        ");
        $stmt->execute([$user['id']]);
        $methods = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode([
            'success' => true,
            'methods' => $methods
        ], JSON_UNESCAPED_UNICODE);
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(['success' => false, 'error' => $e->getMessage()]);
    }
}

    /**
     * POST /api/provider/payment-methods
     * Crear método de pago del proveedor
     */
    public function providerStore(): void
    {
        header('Content-Type: application/json');

        try {
            $user = $this->authenticate();
            if (!$user) return;

            $input = json_decode(file_get_contents('php://input'), true);
            if (!$input) {
                http_response_code(400);
                echo json_encode(['success' => false, 'error' => 'Datos inválidos']);
                return;
            }

            if (empty($input['method_type'])) {
                http_response_code(400);
                echo json_encode(['success' => false, 'error' => 'method_type es requerido']);
                return;
            }

            require_once __DIR__ . '/../models/ProviderPayment.php';
            $providerPayment = new ProviderPayment();
            $id = $providerPayment->create($user['id'], $input);

            http_response_code(201);
            echo json_encode([
                'success' => true,
                'message' => 'Método de pago creado exitosamente',
                'id' => $id
            ], JSON_UNESCAPED_UNICODE);

        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'error' => 'Error al crear método de pago',
                'message' => $e->getMessage()
            ]);
        }
    }


    /**
     * GET /api/payment-methods/{value}
     * Obtener un método de pago específico
     */
    public function show($value): void {
        header('Content-Type: application/json');
        
        try {
            // Verificar autenticación
            $user = $this->authenticate();
            if (!$user) {
                return;
            }

            // Obtener método específico
            $method = $this->paymentMethod->findByValue($value);
            
            if (!$method) {
                http_response_code(404);
                echo json_encode([
                    'success' => false,
                    'error' => 'Método de pago no encontrado'
                ]);
                return;
            }

            echo json_encode([
                'success' => true,
                'data' => $method
            ], JSON_UNESCAPED_UNICODE);

        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'error' => 'Error al cargar método de pago',
                'message' => $e->getMessage()
            ]);
        }
    }

    /**
     * GET /api/admin/payment-methods
     * Obtener todos los métodos de pago (admin)
     */
    public function adminIndex(): void {
        header('Content-Type: application/json');
        
        try {
            // Verificar autenticación y rol admin
            $user = $this->authenticate(true);
            if (!$user) {
                return;
            }

            // Obtener todos los métodos (incluyendo inactivos)
            $methods = $this->paymentMethod->getAllMethods();
            
            echo json_encode([
                'success' => true,
                'data' => $methods
            ], JSON_UNESCAPED_UNICODE);

        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'error' => 'Error al cargar métodos de pago',
                'message' => $e->getMessage()
            ]);
        }
    }

    /**
     * POST /api/admin/payment-methods
     * Crear un nuevo método de pago (solo admin)
     */
    public function store(): void {
        header('Content-Type: application/json');
        
        try {
            // Verificar autenticación y rol admin
            $user = $this->authenticate(true);
            if (!$user) {
                return;
            }

            // Obtener datos del cuerpo de la petición
            $input = json_decode(file_get_contents('php://input'), true);
            
            if (!$input) {
                http_response_code(400);
                echo json_encode([
                    'success' => false,
                    'error' => 'Datos inválidos'
                ]);
                return;
            }

            // Validar campos requeridos
            $required = ['value', 'label'];
            foreach ($required as $field) {
                if (empty($input[$field])) {
                    http_response_code(400);
                    echo json_encode([
                        'success' => false,
                        'error' => "El campo '$field' es requerido"
                    ]);
                    return;
                }
            }

            // Crear método de pago
            $id = $this->paymentMethod->create($input);
            
            http_response_code(201);
            echo json_encode([
                'success' => true,
                'message' => 'Método de pago creado exitosamente',
                'id' => $id
            ], JSON_UNESCAPED_UNICODE);

        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'error' => 'Error al crear método de pago',
                'message' => $e->getMessage()
            ]);
        }
    }

    /**
     * PUT /api/admin/payment-methods/{id}
     * Actualizar un método de pago (solo admin)
     */
    public function update($id): void {
        header('Content-Type: application/json');
        
        try {
            // Verificar autenticación y rol admin
            $user = $this->authenticate(true);
            if (!$user) {
                return;
            }

            // Obtener datos del cuerpo de la petición
            $input = json_decode(file_get_contents('php://input'), true);
            
            if (!$input) {
                http_response_code(400);
                echo json_encode([
                    'success' => false,
                    'error' => 'Datos inválidos'
                ]);
                return;
            }

            // Actualizar método de pago
            $success = $this->paymentMethod->update((int)$id, $input);
            
            if ($success) {
                echo json_encode([
                    'success' => true,
                    'message' => 'Método de pago actualizado exitosamente'
                ], JSON_UNESCAPED_UNICODE);
            } else {
                http_response_code(400);
                echo json_encode([
                    'success' => false,
                    'error' => 'No se pudo actualizar el método de pago'
                ]);
            }

        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'error' => 'Error al actualizar método de pago',
                'message' => $e->getMessage()
            ]);
        }
    }

    /**
     * DELETE /api/admin/payment-methods/{id}
     * Eliminar (desactivar) un método de pago (solo admin)
     */
    public function destroy($id): void {
        header('Content-Type: application/json');
        
        try {
            // Verificar autenticación y rol admin
            $user = $this->authenticate(true);
            if (!$user) {
                return;
            }

            // Eliminar método de pago
            $success = $this->paymentMethod->delete((int)$id);
            
            if ($success) {
                echo json_encode([
                    'success' => true,
                    'message' => 'Método de pago eliminado exitosamente'
                ], JSON_UNESCAPED_UNICODE);
            } else {
                http_response_code(400);
                echo json_encode([
                    'success' => false,
                    'error' => 'No se pudo eliminar el método de pago'
                ]);
            }

        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'error' => 'Error al eliminar método de pago',
                'message' => $e->getMessage()
            ]);
        }
    }

    /**
     * Función de autenticación IDÉNTICA a la lógica de AuthController->me()
     */
    private function authenticate(bool $requireAdmin = false) {
        $headers = getallheaders();
        $auth = $headers['Authorization'] ?? '';

        if (!str_starts_with($auth, "Bearer ")) {
            http_response_code(401);
            echo json_encode(["message" => "Token no proporcionado"]);
            return false;
        }

        $token = str_replace("Bearer ", "", $auth);
        $decoded = JwtHandler::decode($token);

        if (!$decoded || !isset($decoded->id)) {
            http_response_code(401);
            echo json_encode(["message" => "Token inválido o expirado"]);
            return false;
        }

        $userId = $decoded->id;

        // Obtener usuario de la base de datos
        require_once __DIR__ . '/../models/User.php';
        $userModel = new User();
        $user = $userModel->findById($userId);

        if (!$user) {
            http_response_code(404);
            echo json_encode(["message" => "Usuario no encontrado"]);
            return false;
        }

        // Verificar si requiere rol admin
        if ($requireAdmin && $user['role'] !== 'admin') {
            http_response_code(403);
            echo json_encode([
                "success" => false,
                "message" => "Se requieren permisos de administrador"
            ]);
            return false;
        }

        // Actualizar última actividad (igual que en AuthController)
        $userModel->updateLastSeen($userId);

        return $user;
    }
}
