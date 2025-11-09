<?php
require_once __DIR__ . "/../middleware/Auth.php";
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../utils/jwt.php';
require_once __DIR__ . '/../models/ProviderPayment.php';

class ProviderPaymentController
{
    private $conn;
    private $model;

    public function __construct()
    {
        $this->conn  = (new Database())->getConnection();
        $this->model = new ProviderPayment();
    }

    /* ---------- LISTAR PROPIOS (GET) ---------- */
    public function getMyMethods(): void
    {
        $userId = $this->checkAuth();
        $methods = $this->model->getByProvider($userId);
        echo json_encode(['methods' => $methods]);
    }

    /* ---------- CREAR (POST) ---------- */
    public function createMethod(): void
    {
        $userId = $this->checkAuth();
        $data   = json_decode(file_get_contents('php://input'), true);

        // validación mínima
        if (empty($data['method_type']) || empty($data['holder_name']) || empty($data['id_number'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Faltan campos obligatorios']);
            return;
        }

        $id = $this->model->create($userId, $data);
        echo json_encode(['success' => true, 'id' => $id]);
    }

    /* ---------- ACTUALIZAR (PUT) ---------- */
    public function updateMethod(int $id): void
    {
        $userId = $this->checkAuth();
        $data   = json_decode(file_get_contents('php://input'), true);

        $ok = $this->model->update($id, $userId, $data);
        if (!$ok) {
            http_response_code(404);
            echo json_encode(['error' => 'Método no encontrado o no pertenece al usuario']);
            return;
        }
        echo json_encode(['success' => true]);
    }

    /* ---------- ELIMINAR (DELETE) ---------- */
    public function deleteMethod(int $id): void
    {
        $userId = $this->checkAuth();
        $ok     = $this->model->delete($id, $userId);
        if (!$ok) {
            http_response_code(404);
            echo json_encode(['error' => 'Método no encontrado o no pertenece al usuario']);
            return;
        }
        echo json_encode(['success' => true]);
    }

    /* ---------- MÉTODOS PÚBLICOS DE UN PROVEEDOR (usuarios) ---------- */
    public function getPublicMethods(int $providerId): void
    {
        $rows = $this->model->getActiveByProvider($providerId);

        $formatted = [
            'pagoMovil'     => null,
            'transferencia' => null,
            'zelle'         => null,
            'paypal'        => null,
            'binance'       => null,
        ];

        foreach ($rows as $m) {
            switch ($m['method_type']) {
                case 'pago_movil':
                    $formatted['pagoMovil'] = [
                        'banco'    => $m['bank_name'],
                        'telefono' => $m['phone_number'],
                        'cedula'   => $m['id_number'],
                    ];
                    break;
                case 'transferencia':
                    $formatted['transferencia'] = [
                        'banco'  => $m['bank_name'],
                        'cuenta' => $m['account_number'],
                        'cedula' => $m['id_number'],
                    ];
                    break;
                case 'zelle':
                    $formatted['zelle'] = [
                        'email'   => $m['email'],
                        'titular' => $m['holder_name'],
                    ];
                    break;
                case 'paypal':
                    $formatted['paypal'] = [
                        'email'   => $m['email'],
                        'titular' => $m['holder_name'],
                    ];
                    break;
                case 'binance':
                    $formatted['binance'] = [
                        'email'   => $m['email'],
                        'titular' => $m['holder_name'],
                    ];
                    break;
            }
        }
        echo json_encode(['paymentInfo' => $formatted]);
    }

    /* ---------- helpers ---------- */
    private function checkAuth(): int
    {
        $h = getallheaders();
        if (!isset($h['Authorization'])) {
            http_response_code(401);
            exit(json_encode(['error' => 'No autorizado']));
        }
        $tok = str_replace('Bearer ', '', $h['Authorization']);
        $uid = JwtHandler::decode($tok)->id ?? null;
        if (!$uid) {
            http_response_code(401);
            exit(json_encode(['error' => 'Token inválido']));
        }
        return (int)$uid;
    }
}
