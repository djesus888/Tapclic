<?php

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../middleware/Auth.php';
require_once __DIR__ . '/../utils/Uploader.php';

use Utils\Uploader;

class WalletController
{
    private \PDO $conn;
    private $user;
    private Uploader $uploader;

    public function __construct()
    {
        $this->conn = (new Database())->getConnection();
        $auth = Auth::verify();
        $this->user = $auth;

        $basePath = __DIR__ . '/../public/uploads';
        $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? 'https://' : 'http://';
        $baseUrl = $protocol . $_SERVER['HTTP_HOST'] . '/uploads';
        $this->uploader = new Uploader($basePath, $baseUrl);
    }

    // ============= MÉTODOS PÚBLICOS (USUARIO) =============

    // GET /api/wallet
    public function getWallet(): void
    {
        try {
            $stmt = $this->conn->prepare("SELECT * FROM wallets WHERE user_id = ?");
            $stmt->execute([$this->user->id]);
            $wallet = $stmt->fetch();

            if (!$wallet) {
                http_response_code(404);
                echo json_encode(['error' => 'Wallet no encontrado']);
                return;
            }

            echo json_encode([
                'id' => $wallet['id'],
                'balance' => (float)$wallet['balance'],
                'created_at' => $wallet['created_at']
            ]);
        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Error al obtener wallet']);
        }
    }

    // POST /api/wallet
    public function create(): void
    {
        try {
            $stmt = $this->conn->prepare("SELECT id FROM wallets WHERE user_id = ?");
            $stmt->execute([$this->user->id]);
            if ($stmt->fetch()) {
                http_response_code(400);
                echo json_encode(['error' => 'Wallet ya existe']);
                return;
            }

            $stmt = $this->conn->prepare("INSERT INTO wallets (user_id, balance) VALUES (?, 0)");
            $stmt->execute([$this->user->id]);

            echo json_encode(['success' => true, 'message' => 'Wallet creado exitosamente']);
        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Error al crear wallet']);
        }
    }

    // GET /api/wallet/balance
    public function getBalance(): void
    {
        try {
            $stmt = $this->conn->prepare("SELECT balance FROM wallets WHERE user_id = ?");
            $stmt->execute([$this->user->id]);
            $wallet = $stmt->fetch();

            if (!$wallet) {
                http_response_code(404);
                echo json_encode(['error' => 'Wallet no encontrado']);
                return;
            }

            echo json_encode(['balance' => (float)$wallet['balance']]);
        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Error al obtener balance']);
        }
    }

    // GET /api/wallet/stats
    public function getStats(): void
    {
        try {
            $stmt = $this->conn->prepare("SELECT balance FROM wallets WHERE user_id = ?");
            $stmt->execute([$this->user->id]);
            $wallet = $stmt->fetch();

            if (!$wallet) {
                http_response_code(404);
                echo json_encode(['error' => 'Wallet no encontrado']);
                return;
            }

            $stmt = $this->conn->prepare("
                SELECT
                    COUNT(*) as total_transactions,
                    COALESCE(SUM(CASE WHEN type = 'credit' AND status = 'completed' THEN amount END), 0) as total_recharged,
                    COALESCE(SUM(CASE WHEN type = 'debit' AND status = 'completed' THEN amount END), 0) as total_spent
                FROM wallet_transactions WHERE user_id = ?
            ");
            $stmt->execute([$this->user->id]);
            $stats = $stmt->fetch();

            echo json_encode([
                'current_balance' => (float)$wallet['balance'],
                'total_transactions' => (int)$stats['total_transactions'],
                'total_recharged' => (float)$stats['total_recharged'],
                'total_spent' => (float)$stats['total_spent']
            ]);
        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Error al obtener estadísticas']);
        }
    }

    // GET /api/wallet/transactions
    public function getTransactions(): void
    {
        try {
            $stmt = $this->conn->prepare("SELECT * FROM wallet_transactions WHERE user_id = ? ORDER BY created_at DESC");
            $stmt->execute([$this->user->id]);
            $transactions = $stmt->fetchAll();

            foreach ($transactions as &$tx) {
                $tx['amount'] = (float)$tx['amount'];
            }

            echo json_encode($transactions);
        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Error al obtener transacciones']);
        }
    }

    // POST /api/wallet/recharge - DESHABILITADO (usar rechargeRequest)
    public function recharge(): void
    {
        http_response_code(405);
        echo json_encode([
            'error' => 'Recarga directa deshabilitada',
            'message' => 'Usa /api/wallet/recharge-request para solicitar una recarga con comprobante'
        ]);
    }

    // POST /api/wallet/withdraw - CORREGIDO: Requiere método y datos, estado pending
    public function withdraw(): void
    {
        try {
            $data = json_decode(file_get_contents('php://input'), true);

            if (!isset($data['amount']) || $data['amount'] <= 0) {
                http_response_code(400);
                echo json_encode(['error' => 'Monto inválido']);
                return;
            }

            if (!isset($data['method']) || empty($data['method'])) {
                http_response_code(400);
                echo json_encode(['error' => 'Método de retiro requerido (bank, mobile)']);
                return;
            }

            $bankName = $data['bank_name'] ?? null;
            $accountNumber = $data['account_number'] ?? null;
            $phone = $data['phone'] ?? null;

            if ($data['method'] === 'bank' && (!$bankName || !$accountNumber)) {
                http_response_code(400);
                echo json_encode(['error' => 'Datos bancarios requeridos']);
                return;
            }

            if ($data['method'] === 'mobile' && !$phone) {
                http_response_code(400);
                echo json_encode(['error' => 'Número de teléfono requerido']);
                return;
            }

            $this->conn->beginTransaction();

            $stmt = $this->conn->prepare("SELECT balance FROM wallets WHERE user_id = ? FOR UPDATE");
            $stmt->execute([$this->user->id]);
            $wallet = $stmt->fetch();

            if (!$wallet || $wallet['balance'] < $data['amount']) {
                $this->conn->rollBack();
                http_response_code(400);
                echo json_encode(['error' => 'Saldo insuficiente']);
                return;
            }

            $newBalance = $wallet['balance'] - $data['amount'];
            $stmt = $this->conn->prepare("UPDATE wallets SET balance = ?, updated_at = NOW() WHERE user_id = ?");
            $stmt->execute([$newBalance, $this->user->id]);

            $reference = 'WDR-' . date('Ymd') . '-' . str_pad(random_int(1, 99999), 5, '0', STR_PAD_LEFT);
            $stmt = $this->conn->prepare("
                INSERT INTO wallet_transactions
                    (user_id, type, amount, description, bank_name, account_number, phone, reference, status, created_at)
                VALUES (?, 'debit', ?, ?, ?, ?, ?, ?, 'pending', NOW())
            ");
            $stmt->execute([
                $this->user->id,
                $data['amount'],
                "Retiro #$reference",
                $bankName,
                $accountNumber,
                $phone,
                $reference
            ]);

            $this->conn->commit();

            $this->createAdminNotification(
                '💸 Nueva solicitud de retiro',
                "Usuario solicita retiro de \${$data['amount']} - Ref: {$reference}",
                'wallet_withdraw',
                $this->conn->lastInsertId()
            );

            echo json_encode([
                'success' => true,
                'balance' => $newBalance,
                'reference' => $reference,
                'message' => 'Solicitud de retiro enviada. Un administrador la procesará.'
            ]);

        } catch (\Exception $e) {
            $this->conn->rollBack();
            http_response_code(500);
            echo json_encode(['error' => 'Error al procesar retiro']);
        }
    }

    // POST /api/wallet/transfer
    public function transfer(): void
    {
        http_response_code(501);
        echo json_encode(['error' => 'Método no implementado']);
    }

    // ============= MÉTODOS DE SOLICITUDES =============

    // POST /api/wallet/recharge-request
    public function rechargeRequest(): void
    {
        try {
            $data = json_decode(file_get_contents('php://input'), true);

            if (empty($data) && !empty($_POST)) {
                $data = $_POST;
            }

            if (!isset($data['amount']) || $data['amount'] <= 0) {
                http_response_code(400);
                echo json_encode(['error' => 'Monto inválido']);
                return;
            }

            if (!isset($data['reference']) || empty($data['reference'])) {
                http_response_code(400);
                echo json_encode(['error' => 'Número de referencia requerido']);
                return;
            }

            if (!isset($data['payment_method']) || empty($data['payment_method'])) {
                http_response_code(400);
                echo json_encode(['error' => 'Método de pago requerido']);
                return;
            }

            $proofUrl = null;
            if (isset($_FILES['payment_proof'])) {
                try {
                    $proofUrl = $this->uploader->saveFile($_FILES['payment_proof'], Uploader::CAT_PAYMENTS . '/' . date('Y/m'));
                } catch (\RuntimeException $e) {
                    error_log("Error subiendo comprobante: " . $e->getMessage());
                }
            }

            $requestNumber = 'RECH-' . date('Ymd') . '-' . str_pad(random_int(1, 99999), 5, '0', STR_PAD_LEFT);

            $stmt = $this->conn->prepare("
                INSERT INTO wallet_transactions
                    (user_id, type, amount, description, reference, payment_proof, payment_method, status, created_at)
                VALUES (?, 'credit', ?, ?, ?, ?, ?, 'pending', NOW())
            ");

            $description = "Solicitud de recarga #$requestNumber";
            $stmt->execute([
                $this->user->id,
                $data['amount'],
                $description,
                $data['reference'],
                $proofUrl,
                $data['payment_method']
            ]);

            $transactionId = $this->conn->lastInsertId();

            $this->createAdminNotification(
                '💰 Nueva solicitud de recarga',
                "Usuario solicita recarga de {$data['amount']}€ - Ref: {$data['reference']}",
                'wallet_request',
                $transactionId
            );

            echo json_encode([
                'success' => true,
                'message' => 'Solicitud de recarga enviada exitosamente',
                'request_number' => $requestNumber,
                'transaction_id' => $transactionId,
                'proof_url' => $proofUrl
            ]);

        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Error al procesar solicitud: ' . $e->getMessage()]);
        }
    }

    // GET /api/wallet/my-requests
    public function getMyRequests(): void
    {
        try {
            $stmt = $this->conn->prepare("
                SELECT * FROM wallet_transactions
                WHERE user_id = ? AND type = 'credit' AND status = 'pending'
                ORDER BY created_at DESC
            ");
            $stmt->execute([$this->user->id]);
            $requests = $stmt->fetchAll();

            foreach ($requests as &$req) {
                $req['amount'] = (float)$req['amount'];
            }

            echo json_encode($requests);
        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Error al obtener solicitudes']);
        }
    }

    // PUT /api/wallet/requests/{id}/proof
    public function updateProof(int $id): void
    {
        try {
            $stmt = $this->conn->prepare("SELECT * FROM wallet_transactions WHERE id = ? AND user_id = ? AND status = 'pending'");
            $stmt->execute([$id, $this->user->id]);
            $request = $stmt->fetch();

            if (!$request) {
                http_response_code(404);
                echo json_encode(['error' => 'Solicitud no encontrada']);
                return;
            }

            if (!isset($_FILES['payment_proof'])) {
                http_response_code(400);
                echo json_encode(['error' => 'Comprobante requerido']);
                return;
            }

            $proofUrl = $this->uploader->saveFile($_FILES['payment_proof'], Uploader::CAT_PAYMENTS . '/' . date('Y/m'));

            $stmt = $this->conn->prepare("UPDATE wallet_transactions SET payment_proof = ?, updated_at = NOW() WHERE id = ?");
            $stmt->execute([$proofUrl, $id]);

            echo json_encode(['success' => true, 'message' => 'Comprobante actualizado', 'proof_url' => $proofUrl]);

        } catch (\RuntimeException $e) {
            http_response_code(400);
            echo json_encode(['error' => 'Error al subir archivo: ' . $e->getMessage()]);
        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Error al actualizar comprobante']);
        }
    }

    // PUT /api/wallet/requests/{id}/cancel
    public function cancelRequest(int $id): void
    {
        try {
            $stmt = $this->conn->prepare("UPDATE wallet_transactions SET status = 'cancelled', updated_at = NOW() WHERE id = ? AND user_id = ? AND status = 'pending'");
            $stmt->execute([$id, $this->user->id]);

            if ($stmt->rowCount() === 0) {
                http_response_code(404);
                echo json_encode(['error' => 'Solicitud no encontrada o ya procesada']);
                return;
            }

            echo json_encode(['success' => true, 'message' => 'Solicitud cancelada exitosamente']);

        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Error al cancelar solicitud']);
        }
    }

    // ============= MÉTODOS DE ADMINISTRACIÓN =============

    // GET /api/admin/wallet/requests
    public function adminGetRequests(): void
    {
        $this->requireAdmin();

        try {
            $status = $_GET['status'] ?? 'pending';

            $stmt = $this->conn->prepare("
                SELECT wt.*, u.name as user_name, u.email, u.phone
                FROM wallet_transactions wt
                JOIN users u ON wt.user_id = u.id
                WHERE wt.status = ?
                ORDER BY wt.created_at DESC
            ");
            $stmt->execute([$status]);
            $requests = $stmt->fetchAll();

            foreach ($requests as &$req) {
                $req['amount'] = (float)$req['amount'];
            }

            echo json_encode($requests);
        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Error al obtener solicitudes']);
        }
    }

    // PUT /api/admin/wallet/approve/{id}
    public function adminApproveRequest(int $id): void
    {
        $this->requireAdmin();

        try {
            $this->conn->beginTransaction();

            $stmt = $this->conn->prepare("SELECT * FROM wallet_transactions WHERE id = ? AND status = 'pending' FOR UPDATE");
            $stmt->execute([$id]);
            $request = $stmt->fetch();

            if (!$request) {
                $this->conn->rollBack();
                http_response_code(404);
                echo json_encode(['error' => 'Solicitud no encontrada']);
                return;
            }

            if ($request['type'] === 'credit') {
                $stmt = $this->conn->prepare("SELECT * FROM wallets WHERE user_id = ? FOR UPDATE");
                $stmt->execute([$request['user_id']]);
                $wallet = $stmt->fetch();

                if (!$wallet) {
                    $this->conn->rollBack();
                    http_response_code(404);
                    echo json_encode(['error' => 'Wallet no encontrado']);
                    return;
                }

                $newBalance = $wallet['balance'] + $request['amount'];
                $stmt = $this->conn->prepare("UPDATE wallets SET balance = ?, updated_at = NOW() WHERE user_id = ?");
                $stmt->execute([$newBalance, $request['user_id']]);
            }

            $stmt = $this->conn->prepare("UPDATE wallet_transactions SET status = 'completed', reviewed_by = ?, reviewed_at = NOW() WHERE id = ?");
            $stmt->execute([$this->user->id, $id]);

            $this->conn->commit();

            $title = $request['type'] === 'credit' ? '✅ Recarga aprobada' : '✅ Retiro aprobado';
            $msg = $request['type'] === 'credit'
                ? "Tu recarga de {$request['amount']}€ ha sido aprobada."
                : "Tu retiro de {$request['amount']}€ ha sido aprobado.";

            $this->createUserNotification($request['user_id'], $title, $msg, 'wallet_approved', $id);

            echo json_encode(['success' => true, 'message' => 'Solicitud aprobada']);

        } catch (\Exception $e) {
            $this->conn->rollBack();
            http_response_code(500);
            echo json_encode(['error' => 'Error al aprobar solicitud']);
        }
    }

    // PUT /api/admin/wallet/reject/{id}
    public function adminRejectRequest(int $id): void
    {
        $this->requireAdmin();

        try {
            $data = json_decode(file_get_contents('php://input'), true);
            $reason = $data['reason'] ?? 'No especificada';

            $stmt = $this->conn->prepare("SELECT * FROM wallet_transactions WHERE id = ? AND status = 'pending'");
            $stmt->execute([$id]);
            $request = $stmt->fetch();

            if (!$request) {
                http_response_code(404);
                echo json_encode(['error' => 'Solicitud no encontrada']);
                return;
            }

            if ($request['type'] === 'debit') {
                $stmt = $this->conn->prepare("UPDATE wallets SET balance = balance + ?, updated_at = NOW() WHERE user_id = ?");
                $stmt->execute([$request['amount'], $request['user_id']]);
            }

            $stmt = $this->conn->prepare("UPDATE wallet_transactions SET status = 'cancelled', reviewed_by = ?, reviewed_at = NOW() WHERE id = ?");
            $stmt->execute([$this->user->id, $id]);

            $title = $request['type'] === 'credit' ? '❌ Recarga rechazada' : '❌ Retiro rechazado';
            $msg = "Tu solicitud de {$request['amount']}€ ha sido rechazada. Motivo: $reason";

            $this->createUserNotification($request['user_id'], $title, $msg, 'wallet_rejected', $id);

            echo json_encode(['success' => true, 'message' => 'Solicitud rechazada']);

        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Error al rechazar solicitud']);
        }
    }

    // GET /api/admin/wallet/stats
    public function adminGetStats(): void
    {
        $this->requireAdmin();

        try {
            $stmt = $this->conn->prepare("SELECT COUNT(*) as total_wallets, COALESCE(SUM(balance), 0) as total_balance, COALESCE(AVG(balance), 0) as avg_balance FROM wallets");
            $stmt->execute();
            $walletStats = $stmt->fetch();

            $stmt = $this->conn->prepare("SELECT COUNT(*) as pending_requests, COALESCE(SUM(amount), 0) as pending_amount FROM wallet_transactions WHERE status = 'pending'");
            $stmt->execute();
            $pendingStats = $stmt->fetch();

            $stmt = $this->conn->prepare("
                SELECT
                    COALESCE(SUM(CASE WHEN type = 'credit' AND status = 'completed' THEN amount END), 0) as total_recharged_month,
                    COALESCE(SUM(CASE WHEN type = 'debit' AND status = 'completed' THEN amount END), 0) as total_spent_month
                FROM wallet_transactions WHERE created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
            ");
            $stmt->execute();
            $volumeStats = $stmt->fetch();

            echo json_encode([
                'total_wallets' => (int)$walletStats['total_wallets'],
                'total_balance' => (float)$walletStats['total_balance'],
                'avg_balance' => (float)$walletStats['avg_balance'],
                'pending_requests' => (int)$pendingStats['pending_requests'],
                'pending_amount' => (float)$pendingStats['pending_amount'],
                'recharged_month' => (float)$volumeStats['total_recharged_month'],
                'spent_month' => (float)$volumeStats['total_spent_month']
            ]);

        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Error al obtener estadísticas']);
        }
    }

    // ============= HELPERS =============

    private function requireAdmin(): void
    {
        if (($this->user->role ?? '') !== 'admin') {
            http_response_code(401);
            echo json_encode(['error' => 'No autorizado']);
            exit;
        }
    }

    private function createAdminNotification(string $title, string $message, string $type, int $referenceId): void
    {
        try {
            $stmt = $this->conn->prepare("
                INSERT INTO notifications (user_id, title, message, type, reference_id, is_admin, created_at)
                SELECT id, ?, ?, ?, ?, 1, NOW() FROM users WHERE role = 'admin'
            ");
            $stmt->execute([$title, $message, $type, $referenceId]);
        } catch (\Exception $e) {
            error_log("Error creating admin notification: " . $e->getMessage());
        }
    }

    private function createUserNotification(int $userId, string $title, string $message, string $type, int $referenceId): void
    {
        try {
            $stmt = $this->conn->prepare("
                INSERT INTO notifications (user_id, title, message, type, reference_id, is_admin, created_at)
                VALUES (?, ?, ?, ?, ?, 0, NOW())
            ");
            $stmt->execute([$userId, $title, $message, $type, $referenceId]);
        } catch (\Exception $e) {
            error_log("Error creating user notification: " . $e->getMessage());
        }
    }
}
