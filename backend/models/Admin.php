<?php
// models/Admin.php

require_once __DIR__ . '/../config/database.php';

class Admin
{
    private $db;

    public function __construct()
    {
        $dbInstance = new Database();
        $this->db = $dbInstance->getConnection();
    }

    public function getTotalUsers(): int
    {
        $stmt = $this->db->query("SELECT COUNT(*) as total FROM users");
        return (int) ($stmt->fetch(PDO::FETCH_ASSOC)['total'] ?? 0);
    }

    public function getTotalServices(): int
    {
        $stmt = $this->db->query("SELECT COUNT(*) as total FROM services");
        return (int) ($stmt->fetch(PDO::FETCH_ASSOC)['total'] ?? 0);
    }

    public function getTotalNotifications(): int
    {
        $stmt = $this->db->query("SELECT COUNT(*) as total FROM notifications");
        return (int) ($stmt->fetch(PDO::FETCH_ASSOC)['total'] ?? 0);
    }

    /**
     * Últimas actividades con clave de mensaje y parámetros para traducción.
     * @param int $limit
     * @return array
     */
    public function getLatestActivities(int $limit = 5): array
    {
        $stmt = $this->db->prepare(
            "SELECT message_key, params FROM activities ORDER BY created_at DESC LIMIT :limit"
        );
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->execute();
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC) ?: [];

        foreach ($results as &$activity) {
            $activity['params'] = json_decode($activity['params'] ?? '', true) ?: [];
        }
        return $results;
    }
}
