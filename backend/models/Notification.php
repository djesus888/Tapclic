<?php
require_once __DIR__ . '/../config/database.php';

class Notification {
    private $conn;
    private $table = 'notifications';

    public function __construct() {
        $this->conn = (new Database())->getConnection();
    }

    public function send($data) {
        // ✅ NUEVO: Verificar duplicado antes de insertar (misma notificación en los últimos 10 segundos)
        if ($this->isDuplicate($data)) {
            error_log("Notificación duplicada detectada, omitiendo inserción");
            return true; // Retornar true para no romper el flujo
        }

        $query = "INSERT INTO {$this->table}
                  (sender_id, receiver_id, receiver_role, title, message, data_json, is_read, created_at)
                  VALUES (:sender_id, :receiver_id, :receiver_role, :title, :message, :data_json, 0, NOW())";

        $stmt = $this->conn->prepare($query);
        return $stmt->execute([
            ':sender_id'     => $data['sender_id'],
            ':receiver_id'   => $data['receiver_id'],
            ':receiver_role' => $data['receiver_role'],
            ':title'         => $data['title'],
            ':message'       => $data['message'],
            ':data_json'     => $data['data_json'] ?? null
        ]);
    }

    // ✅ NUEVO: Método para detectar duplicados en BD
    private function isDuplicate($data) {
        $query = "SELECT COUNT(*) as count FROM {$this->table}
                  WHERE receiver_id = :receiver_id
                  AND receiver_role = :receiver_role
                  AND title = :title
                  AND message = :message
                  AND created_at > DATE_SUB(NOW(), INTERVAL 10 SECOND)";

        $stmt = $this->conn->prepare($query);
        $stmt->execute([
            ':receiver_id'   => $data['receiver_id'],
            ':receiver_role' => $data['receiver_role'],
            ':title'         => $data['title'],
            ':message'       => $data['message']
        ]);

        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        return $result['count'] > 0;
    }

    // ================================================================
    // ✅ NUEVO: Broadcast masivo a todos los usuarios o por rol
    // ================================================================
    public function broadcastToAll($data) {
        try {
            $this->conn->beginTransaction();

            $targetRole = $data['target_role'] ?? null;
            $senderId = $data['sender_id'];
            $title = $data['title'];
            $message = $data['message'];
            $notificationType = $data['notification_type'] ?? 'broadcast';
            $dataJson = $data['data_json'] ?? null;

            // Obtener todos los usuarios destino
            if ($targetRole) {
                // Broadcast a un rol específico
                $usersQuery = "SELECT id, role FROM users WHERE role = :role AND is_active = 1";
                $stmt = $this->conn->prepare($usersQuery);
                $stmt->execute([':role' => $targetRole]);
            } else {
                // Broadcast a TODOS los usuarios
                $usersQuery = "SELECT id, role FROM users WHERE is_active = 1";
                $stmt = $this->conn->prepare($usersQuery);
                $stmt->execute();
            }

            $users = $stmt->fetchAll(PDO::FETCH_ASSOC);

            if (empty($users)) {
                $this->conn->rollBack();
                return 0; // No hay usuarios para notificar
            }

            // Insertar una notificación por cada usuario
            $insertQuery = "INSERT INTO {$this->table}
                            (sender_id, receiver_id, receiver_role, title, message, data_json, is_read, created_at)
                            VALUES (:sender_id, :receiver_id, :receiver_role, :title, :message, :data_json, 0, NOW())";

            $insertStmt = $this->conn->prepare($insertQuery);
            $insertedCount = 0;

            foreach ($users as $user) {
                // No notificarse a sí mismo (opcional)
                if ($user['id'] == $senderId) {
                    continue;
                }

                $insertStmt->execute([
                    ':sender_id'     => $senderId,
                    ':receiver_id'   => $user['id'],
                    ':receiver_role' => $user['role'],
                    ':title'         => $title,
                    ':message'       => $message,
                    ':data_json'     => $dataJson
                ]);

                $insertedCount++;
            }

            $this->conn->commit();

            // Retornar el ID de la última notificación insertada
            $lastId = $this->conn->lastInsertId();
            error_log("Broadcast enviado a {$insertedCount} usuarios. Último ID: {$lastId}");

            return $lastId;

        } catch (Exception $e) {
            $this->conn->rollBack();
            error_log("Error en broadcastToAll: " . $e->getMessage());
            throw $e;
        }
    }

    // ✅ NUEVO: Obtener notificaciones de tipo broadcast para un usuario
    public function getBroadcastsForUser($userId, $role) {
        $query = "SELECT id, sender_id, title, message, data_json, is_read, created_at
                  FROM {$this->table}
                  WHERE receiver_id = :id
                  AND receiver_role = :role
                  AND data_json LIKE '%\"broadcast\":true%'
                  ORDER BY created_at DESC
                  LIMIT 20";

        $stmt = $this->conn->prepare($query);
        $stmt->execute([
            ':id'   => $userId,
            ':role' => $role
        ]);

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getForUser($userId, $role) {
        $query = "SELECT id, sender_id, title, message, data_json, is_read, created_at
          FROM {$this->table}
          WHERE receiver_id = :id AND receiver_role = :role
          ORDER BY created_at DESC
          LIMIT 50";
        $stmt = $this->conn->prepare($query);
        $stmt->execute([
            ':id'   => $userId,
            ':role' => $role
        ]);

        $notifications = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // Asegurar formato limpio para frontend
        foreach ($notifications as &$n) {
            $n['is_read'] = (bool) $n['is_read'];
            $n['created_at'] = $n['created_at'] ? date('c', strtotime($n['created_at'])) : null;
            $n['title'] = $n['title'] ?? '';
            $n['message'] = $n['message'] ?? '';
            $n['data_json'] = $n['data_json'] ?? null;
        }

        return $notifications;
    }

    // ✅ NUEVO: Método para obtener solo el contador de no leídas
    public function getUnreadCount($userId, $role) {
        $query = "SELECT COUNT(*) as count FROM {$this->table}
                  WHERE receiver_id = :id
                  AND receiver_role = :role
                  AND is_read = 0";

        $stmt = $this->conn->prepare($query);
        $stmt->execute([
            ':id'   => $userId,
            ':role' => $role
        ]);

        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        return (int) $result['count'];
    }

    public function markAllAsRead($userId, $role = null) {
        $query = "UPDATE {$this->table}
                  SET is_read = 1
                  WHERE receiver_id = :uid AND is_read = 0";

        $params = [':uid' => $userId];

        // ✅ CORREGIDO: Filtrar por rol si se proporciona
        if ($role) {
            $query .= " AND receiver_role = :role";
            $params[':role'] = $role;
        }

        $stmt = $this->conn->prepare($query);
        return $stmt->execute($params);
    }

    public function markAsRead($id, $userId) {
        $query = "UPDATE {$this->table}
                  SET is_read = 1
                  WHERE id = :id AND receiver_id = :uid";

        $stmt = $this->conn->prepare($query);
        return $stmt->execute([
            ':id'  => $id,
            ':uid' => $userId
        ]);
    }
}
?>
