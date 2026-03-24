<?php
require_once __DIR__ . '/../config/database.php';

class System {
    private $conn;
    private $table = "system_config";

    public function __construct() {
        $this->conn = (new Database())->getConnection();
    }

    // Obtener configuración (último registro activo o por ID)
    public function getConfig($id = null) {
        if ($id) {
            $query = "SELECT * FROM {$this->table} WHERE id = :id LIMIT 1";
            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        } else {
            // Solo registros activos
            $query = "SELECT * FROM {$this->table} WHERE system_active = 1 ORDER BY id DESC LIMIT 1";
            $stmt = $this->conn->prepare($query);
        }

        $stmt->execute();
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    // Obtener todas las configuraciones como array clave-valor (para utilitarios)
    public function getAllConfig() {
        $config = $this->getConfig();
        return $config ?: [];
    }

    // Obtener un valor específico de configuración
    public function getConfigValue($key, $default = null) {
        $config = $this->getConfig();
        return isset($config[$key]) ? $config[$key] : $default;
    }

    // Actualizar configuración
    public function updateConfig($data) {
        $query = "UPDATE {$this->table} SET
            system_name = :system_name,
            system_host = :system_host,
            system_active = :system_active,
            system_version = :system_version,
            system_logo = :system_logo,
            system_favicon = :system_favicon,
            default_language = :default_language,
            timezone = :timezone,
            currency = :currency,
            support_email = :support_email,
            support_phone = :support_phone,
            company_name = :company_name,
            company_address = :company_address,
            maintenance_mode = :maintenance_mode,
            max_login_attempts = :max_login_attempts,
            password_expiration_days = :password_expiration_days,
            session_timeout_minutes = :session_timeout_minutes,
            items_per_page = :items_per_page,
            theme_color = :theme_color,
            allow_user_registration = :allow_user_registration,
            payment_default_commission = :payment_default_commission,
            payment_min_commission = :payment_min_commission,
            payment_currency = :payment_currency,
            -- Nuevos campos de email
            mail_host = :mail_host,
            mail_port = :mail_port,
            mail_encryption = :mail_encryption,
            mail_username = :mail_username,
            mail_password = :mail_password,
            mail_from = :mail_from,
            mail_from_name = :mail_from_name,
            -- Nuevos campos de SMS
            twilio_sid = :twilio_sid,
            twilio_token = :twilio_token,
            twilio_phone = :twilio_phone,
            updated_at = CURRENT_TIMESTAMP
            WHERE id = :id";

        $stmt = $this->conn->prepare($query);

        // Asegurar que todos los campos tengan valores por defecto si no existen
        $defaultData = [
            'payment_default_commission' => 10.00,
            'payment_min_commission' => 1.00,
            'payment_currency' => 'USD',
            'mail_host' => 'smtp.gmail.com',
            'mail_port' => 587,
            'mail_encryption' => 'tls',
            'mail_username' => '',
            'mail_password' => '',
            'mail_from' => 'notificaciones@tapclic.com',
            'mail_from_name' => 'TapClic',
            'twilio_sid' => '',
            'twilio_token' => '',
            'twilio_phone' => ''
        ];

        // Combinar datos recibidos con valores por defecto
        $mergedData = array_merge($defaultData, $data);

        return $stmt->execute($mergedData);
    }

    // Crear nueva configuración (en caso de que no exista)
    public function createConfig($data) {
        $query = "INSERT INTO {$this->table} (
            system_name, system_host, system_active, system_version,
            system_logo, system_favicon, default_language, timezone,
            currency, support_email, support_phone, company_name,
            company_address, maintenance_mode, max_login_attempts,
            password_expiration_days, session_timeout_minutes, items_per_page,
            theme_color, allow_user_registration, payment_default_commission,
            payment_min_commission, payment_currency,
            mail_host, mail_port, mail_encryption, mail_username,
            mail_password, mail_from, mail_from_name,
            twilio_sid, twilio_token, twilio_phone
        ) VALUES (
            :system_name, :system_host, :system_active, :system_version,
            :system_logo, :system_favicon, :default_language, :timezone,
            :currency, :support_email, :support_phone, :company_name,
            :company_address, :maintenance_mode, :max_login_attempts,
            :password_expiration_days, :session_timeout_minutes, :items_per_page,
            :theme_color, :allow_user_registration, :payment_default_commission,
            :payment_min_commission, :payment_currency,
            :mail_host, :mail_port, :mail_encryption, :mail_username,
            :mail_password, :mail_from, :mail_from_name,
            :twilio_sid, :twilio_token, :twilio_phone
        )";

        $stmt = $this->conn->prepare($query);

        // Valores por defecto
        $defaultData = [
            'payment_default_commission' => 10.00,
            'payment_min_commission' => 1.00,
            'payment_currency' => 'USD',
            'mail_host' => 'smtp.gmail.com',
            'mail_port' => 587,
            'mail_encryption' => 'tls',
            'mail_username' => '',
            'mail_password' => '',
            'mail_from' => 'notificaciones@tapclic.com',
            'mail_from_name' => 'TapClic',
            'twilio_sid' => '',
            'twilio_token' => '',
            'twilio_phone' => ''
        ];

        $mergedData = array_merge($defaultData, $data);

        return $stmt->execute($mergedData);
    }

    // Método específico para obtener configuración de email
    public function getMailConfig() {
        $config = $this->getConfig();
        if (!$config) return null;
        
        return [
            'host' => $config['mail_host'] ?? 'smtp.gmail.com',
            'port' => $config['mail_port'] ?? 587,
            'encryption' => $config['mail_encryption'] ?? 'tls',
            'username' => $config['mail_username'] ?? '',
            'password' => $config['mail_password'] ?? '',
            'from' => $config['mail_from'] ?? 'notificaciones@tapclic.com',
            'from_name' => $config['mail_from_name'] ?? 'TapClic'
        ];
    }

    // Método específico para obtener configuración de SMS
    public function getSMSConfig() {
        $config = $this->getConfig();
        if (!$config) return null;
        
        return [
            'twilio_sid' => $config['twilio_sid'] ?? '',
            'twilio_token' => $config['twilio_token'] ?? '',
            'twilio_phone' => $config['twilio_phone'] ?? ''
        ];
    }

    // Verificar si email está configurado
    public function isEmailConfigured() {
        $config = $this->getMailConfig();
        return !empty($config['username']) && !empty($config['password']);
    }

    // Verificar si SMS está configurado
    public function isSMSConfigured() {
        $config = $this->getSMSConfig();
        return !empty($config['twilio_sid']) && 
               !empty($config['twilio_token']) && 
               !empty($config['twilio_phone']);
    }
}
