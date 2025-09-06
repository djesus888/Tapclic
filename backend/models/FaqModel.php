<?php
require_once __DIR__ . '/../config/database.php';

class FaqModel {
    private $conn;
    private $table = 'faqs';

    public function __construct() {
        $this->conn = (new Database())->getConnection();
    }

    /**
     * Obtener todas las FAQs activas
     */
    public function getAll(): array {
        $query = "SELECT question, answer
                  FROM {$this->table}
                  WHERE is_active = 1
                  ORDER BY sort_order ASC";

        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Agregar FAQ (opcional para admin)
     */
    public function create(string $question, string $answer, int $order = 0): int {
        $query = "INSERT INTO {$this->table} (question, answer, sort_order, is_active)
                  VALUES (:question, :answer, :order, 1)";

        $stmt = $this->conn->prepare($query);
        $stmt->execute([
            ':question' => $question,
            ':answer'   => $answer,
            ':order'    => $order
        ]);

        return $this->conn->lastInsertId();
    }

    /**
     * Eliminar FAQ (opcional para admin)
     */
    public function delete(int $id): bool {
        $query = "DELETE FROM {$this->table} WHERE id = :id";
        $stmt = $this->conn->prepare($query);
        return $stmt->execute([':id' => $id]);
    }
}
