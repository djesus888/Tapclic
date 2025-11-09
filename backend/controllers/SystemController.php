<?php
require_once __DIR__ . "/../middleware/Auth.php";
require_once __DIR__ . '/../models/System.php';

class SystemController {
    private $system;

    public function __construct() {
        $this->system = new System();
    }

    public function handle($method) {
        switch ($method) {
            case 'GET':
                $this->getConfig();
                break;
            case 'PUT':
                $this->updateConfig();
                break;
            case 'POST':
                $this->createConfig();
                break;
            default:
                echo json_encode(["error" => "Método no permitido"]);
        }
    }

    private function getConfig() {
        $config = $this->system->getConfig();
        echo $config ? json_encode($config) : json_encode(["error" => "No hay configuración"]);
    }

    private function updateConfig() {
        $data = json_decode(file_get_contents("php://input"), true);
        $data['id'] = $data['id'] ?? 1; // registro principal

        if ($this->system->updateConfig($data)) {
            echo json_encode(["message" => "Configuración actualizada"]);
        } else {
            echo json_encode(["error" => "Error al actualizar"]);
        }
    }

    private function createConfig() {
        $data = json_decode(file_get_contents("php://input"), true);

        if ($this->system->createConfig($data)) {
            echo json_encode(["message" => "Configuración creada"]);
        } else {
            echo json_encode(["error" => "Error al crear configuración"]);
        }
    }
}
