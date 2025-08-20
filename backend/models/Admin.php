<?php
// models/Admin.php

require_once __DIR__ . '/../utils/jwt.php';
require_once __DIR__ . '/../config/database.php'; // conexión a la base de datos

class Admin {
    private $db;

    public function __construct() {
        $dbInstance = new Database();  // Crear instancia de Database
        $this->db = $dbInstance->getConnection();  // Obtener conexión PDO
    }

    public function getTotalUsers() {
        $stmt = $this->db->query("SELECT COUNT(*) as total FROM users");
        return $stmt->fetch()['total'] ?? 0;
    }

    public function getTotalServices() {
        $stmt = $this->db->query("SELECT COUNT(*) as total FROM services");
        return $stmt->fetch()['total'] ?? 0;
    }

    public function getTotalNotifications() {
        $stmt = $this->db->query("SELECT COUNT(*) as total FROM notifications");
        return $stmt->fetch()['total'] ?? 0;
    }

    /**
     * Obtiene las últimas actividades con message_key y params para traducción.
     * @param int $limit Cantidad máxima de registros
     * @return array Array de actividades, cada una con keys: message_key, params (array)
     */
    public function getLatestActivities($limit = 5) {
        $limit = (int)$limit; // Sanitizar parámetro
        $sql = "SELECT message_key, params FROM activities ORDER BY created_at DESC LIMIT $limit";
        $stmt = $this->db->query($sql);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC) ?: [];

        // Decodificar params JSON en array asociativo
        foreach ($results as &$activity) {
            $activity['params'] = $activity['params'] ? json_decode($activity['params'], true) : [];
        }
        return $results;
    }
}
