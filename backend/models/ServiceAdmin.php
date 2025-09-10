<?php
// models/ServiceAdmin.php

require_once __DIR__ . '/../config/database.php';

class ServiceAdmin
{
    private \PDO $conn;

    public function __construct()
    {
        $this->conn = (new Database())->getConnection();
    }

    /* Listado con filtros opcionales */
    public function list(array $filters = []): array
    {
        $search = $filters['search'] ?? '';
        $status = $filters['status'] ?? '';

        $sql = "SELECT * FROM services WHERE 1=1";
        if ($search !== '') {
            $sql .= " AND (title LIKE :search OR description LIKE :search)";
        }
        if ($status !== '') {
            $sql .= " AND status = :status";
        }
        $sql .= " ORDER BY id DESC";

        $stmt = $this->db->prepare($sql);
        if ($search !== '') {
            $stmt->bindValue(':search', "%$search%");
        }
        if ($status !== '') {
            $stmt->bindValue(':status', $status);
        }
        $stmt->execute();
        return $stmt->fetchAll(\PDO::FETCH_ASSOC);
    }

    /* Update solo campos permitidos */
    public function update(int $id, array $data): int
    {
        $allowed = ['title','description','category','price','location','status','provider_rating'];
        $sets = [];
        $params = ['id' => $id];
        foreach ($allowed as $col) {
            if (array_key_exists($col, $data)) {
                $sets[] = "$col = :$col";
                $params[$col] = $data[$col];
            }
        }
        if (!$sets) {
            return 0;
        }
        $sql = "UPDATE services SET " . implode(', ', $sets) . " WHERE id = :id";
        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);
        return $stmt->rowCount();
    }

    /* Delete físico */
    public function delete(int $id): int
    {
        $stmt = $this->db->prepare("DELETE FROM services WHERE id = :id");
        $stmt->execute(['id' => $id]);
        return $stmt->rowCount();
    }
}
