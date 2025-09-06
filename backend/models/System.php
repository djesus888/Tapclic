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
            $query = "SELECT * FROM {$this->table} ORDER BY id DESC LIMIT 1";
            $stmt = $this->conn->prepare($query);
        }

        $stmt->execute();
        return $stmt->fetch(PDO::FETCH_ASSOC);
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
            updated_at = CURRENT_TIMESTAMP
            WHERE id = :id";

        $stmt = $this->conn->prepare($query);

        return $stmt->execute($data);
    }

    // Crear nueva configuración (en caso de que no exista)
    public function createConfig($data) {
        $query = "INSERT INTO {$this->table} (
            system_name, system_host, system_active, system_version,
            system_logo, system_favicon, default_language, timezone,
            currency, support_email, support_phone, company_name,
            company_address, maintenance_mode, max_login_attempts,
            password_expiration_days, session_timeout_minutes, items_per_page,
            theme_color, allow_user_registration
        ) VALUES (
            :system_name, :system_host, :system_active, :system_version,
            :system_logo, :system_favicon, :default_language, :timezone,
            :currency, :support_email, :support_phone, :company_name,
            :company_address, :maintenance_mode, :max_login_attempts,
            :password_expiration_days, :session_timeout_minutes, :items_per_page,
            :theme_color, :allow_user_registration
        )";

        $stmt = $this->conn->prepare($query);

        return $stmt->execute($data);
    }
}
