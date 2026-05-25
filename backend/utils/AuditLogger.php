<?php
// utils/AuditLogger.php

require_once __DIR__ . '/../config/database.php';

class AuditLogger
{
    /**
     * Registrar acción en la tabla audit_logs
     */
    public static function log(int $userId, string $actionType, string $action, ?string $details = null): void
    {
        try {
            $db = (new Database())->getConnection();
            $ip = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '127.0.0.1';
            $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? '';

            $stmt = $db->prepare("
                INSERT INTO audit_logs (user_id, action_type, action, details, ip_address, user_agent, created_at)
                VALUES (:user_id, :action_type, :action, :details, :ip, :user_agent, NOW())
            ");
            $stmt->execute([
                ':user_id' => $userId,
                ':action_type' => $actionType,
                ':action' => $action,
                ':details' => $details,
                ':ip' => $ip,
                ':user_agent' => $userAgent
            ]);
        } catch (Exception $e) {
            error_log("AuditLogger error: " . $e->getMessage());
        }
    }
}
