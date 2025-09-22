<?php
require_once __DIR__ . '/../config/database.php';

class History
{
    private PDO $conn;
    private string $table = 'service_history';

    public function __construct()
    {
        $this->conn = (new Database())->getConnection();
    }

    /**
     * Historial de servicios para un usuario final
     * (ahora incluye rating y comentario de reseña)
     */
    public function getHistoryByUser(int $userId): array
    {
        $sql = "SELECT
                    sh.id,
                    sh.service_title,
                    sh.service_price,
                    sh.provider_name,
                    sh.status,
                    sh.finished_at,
                    s.image_url AS service_image,
                    sr.rating,
                    sr.comment  AS review_comment
                FROM {$this->table} sh
                JOIN services s ON s.id = sh.service_id
                LEFT JOIN service_reviews sr ON sr.service_history_id = sh.id
                WHERE sh.user_id = :uid
                ORDER BY sh.finished_at DESC";

        $stmt = $this->conn->prepare($sql);
        $stmt->execute([':uid' => $userId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Historial de servicios para un proveedor
     * (ahora incluye rating y comentario de reseña)
     */
    public function getHistoryByProvider(int $providerId): array
    {
        $sql = "SELECT
                    sh.id,
                    sh.service_title,
                    sh.service_price,
                    sh.status,
                    sh.finished_at,
                    u.name   AS user_name,
                    u.avatar_url AS user_avatar,
                    sr.rating,
                    sr.comment  AS review_comment
                FROM {$this->table} sh
                JOIN users u ON u.id = sh.user_id
                LEFT JOIN service_reviews sr ON sr.service_history_id = sh.id
                WHERE sh.provider_id = :pid
                ORDER BY sh.finished_at DESC";

        $stmt = $this->conn->prepare($sql);
        $stmt->execute([':pid' => $providerId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}
