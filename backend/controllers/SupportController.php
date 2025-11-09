<?php
require_once __DIR__ . "/../middleware/Auth.php";
require_once __DIR__ . '/../models/SupportModel.php';
require_once __DIR__ . '/../models/FaqModel.php';
require_once __DIR__ . '/../utils/jwt.php';

class SupportController {
    private $supportModel;
    private $faqModel;

    public function __construct() {
        $this->supportModel = new SupportModel();
        $this->faqModel     = new FaqModel();
    }

    /**
     * Dispatcher: decide qué acción realizar según el método y la URI.
     */
    public function handle(string $method) {
        $uri = $_SERVER['REQUEST_URI'];

        switch (true) {
            // ------------ FAQ ------------
            case $method === 'GET' && preg_match('/\/api\/support\/faq$/', $uri):
                $this->getFaq();
                break;

            // ------------ TICKETS ------------
            case $method === 'GET' && preg_match('/\/api\/support\/tickets$/', $uri):
                $this->getTickets();
                break;

            case $method === 'POST' && preg_match('/\/api\/support\/tickets\/create$/', $uri):
                $this->createTicket();
                break;

            default:
                http_response_code(404);
                echo json_encode(["error" => "Ruta no encontrada"]);
        }
    }

    /* -----------------------------------------------------------
     *  FAQ
     * ----------------------------------------------------------- */
    private function getFaq() {
        $faq = $this->faqModel->getAll();
        echo json_encode(["success" => true, "faq" => $faq]);
    }

    /* -----------------------------------------------------------
     *  TICKETS
     * ----------------------------------------------------------- */
    private function getTickets() {
        $user = $this->getAuthenticatedUser();
        if (!$user) return;

        $tickets = $this->supportModel->getTicketsByUser($user['id']);
        echo json_encode(["success" => true, "tickets" => $tickets]);
    }

    private function createTicket() {
        $user = $this->getAuthenticatedUser();
        if (!$user) return;

        $data = json_decode(file_get_contents("php://input"), true);
        $subject = trim($data['subject'] ?? '');
        $description = trim($data['description'] ?? '');
        $category = trim($data['category'] ?? 'other');

        if (!$subject || !$description) {
            http_response_code(400);
            echo json_encode(["message" => "Faltan campos obligatorios"]);
            return;
        }

        $id = $this->supportModel->createTicket([
            'user_id'     => $user['id'],
            'subject'     => $subject,
            'description' => $description,
            'category'    => $category
        ]);

        echo json_encode([
            "success" => true,
            "ticketId" => $id,
            "message" => "Ticket creado exitosamente"
        ]);
    }

    /* -----------------------------------------------------------
     *  AUTENTICACIÓN RÁPIDA
     * ----------------------------------------------------------- */
    private function getAuthenticatedUser(): ?array {
        $headers = getallheaders();
        $auth = $headers['Authorization'] ?? '';
        if (!str_starts_with($auth, "Bearer ")) {
            http_response_code(401);
            echo json_encode(["message" => "Token no proporcionado"]);
            return null;
        }

        $token = str_replace("Bearer ", "", $auth);
        $decoded = JwtHandler::decode($token);
        if (!$decoded || !isset($decoded->id)) {
            http_response_code(401);
            echo json_encode(["message" => "Token inválido o expirado"]);
            return null;
        }

        require_once __DIR__ . '/../models/User.php';
        $userModel = new User();
        return $userModel->findById($decoded->id);
    }
}
