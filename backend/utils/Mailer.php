<?php
// backend/utils/Mailer.php

require_once __DIR__ . '/../vendor/autoload.php';
require_once __DIR__ . '/../models/System.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

class Mailer {
    private $mail;
    private $config;

    public function __construct() {
        // Obtener configuración desde la base de datos
        $systemModel = new System();
        $this->config = $systemModel->getMailConfig();
        
        $this->mail = new PHPMailer(true);

        // Configuración del servidor SMTP desde la DB
        $this->mail->isSMTP();
        $this->mail->Host = $this->config['host'] ?? 'smtp.gmail.com';
        $this->mail->SMTPAuth = true;
        $this->mail->Username = $this->config['username'] ?? '';
        $this->mail->Password = $this->config['password'] ?? '';
        $this->mail->SMTPSecure = $this->config['encryption'] ?? 'tls';
        $this->mail->Port = $this->config['port'] ?? 587;

        // Configuración por defecto
        $fromEmail = $this->config['from'] ?? 'notificaciones@tapclic.com';
        $fromName = $this->config['from_name'] ?? 'TapClic';
        
        $this->mail->setFrom($fromEmail, $fromName);
        $this->mail->isHTML(true);
        $this->mail->CharSet = 'UTF-8';
    }

    public function send($to, $subject, $htmlBody, $altBody = '') {
        try {
            // Verificar que hay configuración de email
            if (empty($this->config['username']) || empty($this->config['password'])) {
                throw new Exception('Configuración de email incompleta en la base de datos');
            }

            // Limpiar direcciones anteriores
            $this->mail->clearAddresses();
            
            // Agregar destinatario
            $this->mail->addAddress($to);
            $this->mail->Subject = $subject;
            $this->mail->Body = $htmlBody;
            $this->mail->AltBody = $altBody ?: strip_tags($htmlBody);

            return $this->mail->send();
        } catch (Exception $e) {
            error_log("Error enviando email: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Verificar si la configuración de email es válida
     */
    public function isConfigured() {
        return !empty($this->config['username']) && 
               !empty($this->config['password']) && 
               !empty($this->config['host']);
    }

    /**
     * Probar conexión SMTP
     */
    public function testConnection() {
        try {
            $this->mail->smtpConnect();
            $this->mail->smtpClose();
            return ['success' => true, 'message' => 'Conexión SMTP exitosa'];
        } catch (Exception $e) {
            return ['success' => false, 'message' => $e->getMessage()];
        }
    }
}
