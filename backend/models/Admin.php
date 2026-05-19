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
     * Últimas actividades reales del sistema (últimos 7 días)
     * Obtiene datos de las tablas reales: users, services, service_requests, payments, tickets, notifications
     * @param int $limit
     * @return array
     */
    public function getLatestActivities(int $limit = 10): array
    {
        $activities = [];

        // 1. Últimos usuarios registrados
        $stmt = $this->db->prepare(
            "SELECT 
                'user_created' as type,
                name as user_name,
                created_at
             FROM users 
             WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
             ORDER BY created_at DESC 
             LIMIT 5"
        );
        $stmt->execute();
        foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
            $activities[] = [
                'type' => 'user_created',
                'message_key' => 'activity.user_created',
                'params' => ['user' => $row['user_name']],
                'created_at' => $row['created_at']
            ];
        }

        // 2. Últimos servicios creados
        $stmt = $this->db->prepare(
            "SELECT 
                'service_created' as type,
                s.title as service_title,
                u.name as user_name,
                s.created_at
             FROM services s
             JOIN users u ON u.id = s.user_id
             WHERE s.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
             ORDER BY s.created_at DESC 
             LIMIT 5"
        );
        $stmt->execute();
        foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
            $activities[] = [
                'type' => 'service_created',
                'message_key' => 'activity.service_created',
                'params' => ['user' => $row['user_name'], 'service' => $row['service_title']],
                'created_at' => $row['created_at']
            ];
        }

        // 3. Últimas solicitudes creadas
        $stmt = $this->db->prepare(
            "SELECT 
                'request_created' as type,
                s.title as service_title,
                u.name as user_name,
                sr.created_at
             FROM service_requests sr
             JOIN services s ON s.id = sr.service_id
             JOIN users u ON u.id = sr.user_id
             WHERE sr.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
             ORDER BY sr.created_at DESC 
             LIMIT 5"
        );
        $stmt->execute();
        foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
            $activities[] = [
                'type' => 'request_created',
                'message_key' => 'activity.request_created',
                'params' => ['user' => $row['user_name'], 'service' => $row['service_title']],
                'created_at' => $row['created_at']
            ];
        }

        // 4. Últimos pagos completados
        $stmt = $this->db->prepare(
            "SELECT 
                'payment_completed' as type,
                s.title as service_title,
                u.name as user_name,
                p.created_at
             FROM payments p
             JOIN service_requests sr ON sr.id = p.service_request_id
             JOIN services s ON s.id = sr.service_id
             JOIN users u ON u.id = sr.user_id
             WHERE p.status = 'paid' 
               AND p.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
             ORDER BY p.created_at DESC 
             LIMIT 5"
        );
        $stmt->execute();
        foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
            $activities[] = [
                'type' => 'payment_completed',
                'message_key' => 'activity.payment_completed',
                'params' => ['user' => $row['user_name'], 'service' => $row['service_title']],
                'created_at' => $row['created_at']
            ];
        }

        // 5. Últimas reseñas creadas
// 5. Últimas reseñas creadas
$stmt = $this->db->prepare(
    "SELECT 
        'review_created' as type,
        u.name as user_name,
        rv.created_at
     FROM service_reviews rv
     JOIN users u ON u.id = rv.user_id
     WHERE rv.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
     ORDER BY rv.created_at DESC 
     LIMIT 5"
);
        $stmt->execute();
        foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
            $activities[] = [
                'type' => 'review_created',
                'message_key' => 'activity.review_created',
                'params' => ['user' => $row['user_name']],
                'created_at' => $row['created_at']
            ];
        }

        // 6. Últimos tickets de soporte abiertos
        $stmt = $this->db->prepare(
            "SELECT 
                'ticket_created' as type,
                subject,
                created_at
             FROM support_tickets
             WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
             ORDER BY created_at DESC 
             LIMIT 5"
        );
        $stmt->execute();
        foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
            $activities[] = [
                'type' => 'ticket_created',
                'message_key' => 'activity.support_ticket_opened',
                'params' => ['subject' => $row['subject']],
                'created_at' => $row['created_at']
            ];
        }

        // Ordenar todas las actividades por fecha descendente
        usort($activities, function ($a, $b) {
            return strtotime($b['created_at']) - strtotime($a['created_at']);
        });

        // Limitar al número solicitado
        return array_slice($activities, 0, $limit);
    }
}
