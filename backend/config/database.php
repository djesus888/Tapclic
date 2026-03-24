<?php
// config/database.php

class Database {
    private $host = "127.0.0.1";
    private $db_name = "tapclic_db";
    private $username = "root";
    private $password = "";
    public $conn;

    public function getConnection(){
        $this->conn = null;

        try {
            $this->conn = new PDO("mysql:host=" . $this->host . ";dbname=" . $this->db_name . ";charset=utf8mb4",
                                  $this->username,
                                  $this->password);
            $this->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            $this->conn->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
            $this->conn->exec("SET NAMES utf8mb4");
        } catch(PDOException $exception){
            error_log("Error de conexión: " . $exception->getMessage());
            echo "Error de conexión a la base de datos";
        }

        return $this->conn;
    }
}
