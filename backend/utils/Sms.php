<?php
// backend/utils/sms.php

require_once __DIR__ . '/../vendor/autoload.php';
require_once __DIR__ . '/../models/System.php';

use Twilio\Rest\Client;

class SMS {
    private static $config = null;

    /**
     * Cargar configuración desde la base de datos
     */
    private static function loadConfig() {
        if (self::$config === null) {
            $system = new System();
            self::$config = $system->getSMSConfig();
        }
        return self::$config;
    }

    /**
     * Obtener cliente de Twilio (singleton)
     */
    private static function getClient() {
        $config = self::loadConfig();
        
        if (empty($config['twilio_sid']) || empty($config['twilio_token'])) {
            throw new \Exception('Twilio no está configurado en la base de datos');
        }

        static $client = null;
        if ($client === null) {
            $client = new Client($config['twilio_sid'], $config['twilio_token']);
        }
        return $client;
    }

    /**
     * Enviar SMS
     * 
     * @param string $to Número de teléfono destino (formato internacional: +584241234567)
     * @param string $message Mensaje a enviar
     * @return bool
     */
    public static function send(string $to, string $message): bool {
        try {
            $config = self::loadConfig();
            
            // Validar configuración
            if (empty($config['twilio_phone'])) {
                error_log("Error SMS: Número de Twilio no configurado");
                return false;
            }

            // Validar número destino
            if (empty($to)) {
                error_log("Error SMS: Número destino vacío");
                return false;
            }

            // Formatear número si es necesario
            $to = self::formatPhoneNumber($to);
            
            $client = self::getClient();
            
            $client->messages->create(
                $to,
                [
                    'from' => $config['twilio_phone'],
                    'body' => $message
                ]
            );
            
            // Log para tracking
            error_log("SMS enviado exitosamente a: $to");
            
            return true;
            
        } catch (\Exception $e) {
            error_log("Error enviando SMS: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Enviar SMS con validación previa
     * 
     * @param string $to Número de teléfono destino
     * @param string $message Mensaje a enviar
     * @return array Respuesta con éxito y mensaje
     */
    public static function sendWithResponse(string $to, string $message): array {
        try {
            // Verificar configuración
            $config = self::loadConfig();
            
            if (empty($config['twilio_sid']) || empty($config['twilio_token']) || empty($config['twilio_phone'])) {
                return [
                    'success' => false,
                    'error' => 'Twilio no está completamente configurado en el sistema'
                ];
            }

            // Validar número
            if (!self::validatePhoneNumber($to)) {
                return [
                    'success' => false,
                    'error' => 'Número de teléfono inválido'
                ];
            }

            // Enviar SMS
            $sent = self::send($to, $message);
            
            if ($sent) {
                return [
                    'success' => true,
                    'message' => 'SMS enviado correctamente'
                ];
            } else {
                return [
                    'success' => false,
                    'error' => 'Error al enviar SMS'
                ];
            }
            
        } catch (\Exception $e) {
            return [
                'success' => false,
                'error' => 'Error: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Validar formato de número telefónico
     * 
     * @param string $phone
     * @return bool
     */
    public static function validatePhoneNumber(string $phone): bool {
        // Formato internacional: +584241234567
        return (bool) preg_match('/^\+?[\d]{10,15}$/', preg_replace('/[\s\-\(\)]/', '', $phone));
    }

    /**
     * Formatear número telefónico
     * 
     * @param string $phone
     * @return string
     */
    public static function formatPhoneNumber(string $phone): string {
        // Eliminar espacios, guiones y paréntesis
        $clean = preg_replace('/[\s\-\(\)]/', '', $phone);
        
        // Asegurar formato internacional
        if (substr($clean, 0, 1) !== '+') {
            // Si no tiene +, asumimos código de país (ajustar según tu país)
            // Por ejemplo, para Venezuela: +58
            if (substr($clean, 0, 2) === '04') {
                // Número venezolano: 0412 -> +58412
                $clean = '+58' . substr($clean, 1);
            } else {
                $clean = '+' . $clean;
            }
        }
        
        return $clean;
    }

    /**
     * Verificar si Twilio está configurado
     * 
     * @return bool
     */
    public static function isConfigured(): bool {
        $config = self::loadConfig();
        return !empty($config['twilio_sid']) && 
               !empty($config['twilio_token']) && 
               !empty($config['twilio_phone']);
    }

    /**
     * Obtener información de la cuenta (saldo, etc.)
     * 
     * @return array|null
     */
    public static function getAccountInfo() {
        try {
            if (!self::isConfigured()) {
                return null;
            }
            
            $client = self::getClient();
            $account = $client->api->v2010->account->fetch();
            
            return [
                'sid' => $account->sid,
                'name' => $account->friendlyName,
                'status' => $account->status,
                'type' => $account->type,
                'created' => $account->dateCreated->format('Y-m-d H:i:s')
            ];
            
        } catch (\Exception $e) {
            error_log("Error obteniendo info de Twilio: " . $e->getMessage());
            return null;
        }
    }
}
