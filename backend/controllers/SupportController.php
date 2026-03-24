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

            // ------------ NUEVAS FUNCIONES ------------
            case $method === 'POST' && preg_match('/\/api\/support\/tickets\/close$/', $uri):
                $this->closeTicket();
                break;

            case $method === 'PUT' && preg_match('/\/api\/support\/tickets\/update$/', $uri):
                $this->updateTicket();
                break;

            case $method === 'POST' && preg_match('/\/api\/support\/tickets\/reply$/', $uri):
                $this->replyTicket();
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
     *  NUEVAS FUNCIONES
     * ----------------------------------------------------------- */

    /**
     * Cerrar un ticket
     */
    private function closeTicket() {
        $user = $this->getAuthenticatedUser();
        if (!$user) return;

        $data = json_decode(file_get_contents("php://input"), true);
        $ticket_id = (int)($data['ticket_id'] ?? 0);

        if (!$ticket_id) {
            http_response_code(400);
            echo json_encode(["message" => "ID de ticket requerido"]);
            return;
        }

        // Verificar que el ticket existe
        $ticket = $this->supportModel->getTicketById($ticket_id);
        if (!$ticket) {
            http_response_code(404);
            echo json_encode(["message" => "Ticket no encontrado"]);
            return;
        }

        // Verificar que el ticket pertenece al usuario
        if ($ticket['user_id'] != $user['id']) {
            http_response_code(403);
            echo json_encode(["message" => "No autorizado para cerrar este ticket"]);
            return;
        }

        // Verificar que el ticket no esté ya cerrado
        if ($ticket['status'] === 'closed' || $ticket['status'] === 'cancelled') {
            echo json_encode([
                "success" => true,
                "message" => "El ticket ya estaba cerrado"
            ]);
            return;
        }

        // Usar la función updateStatus que YA EXISTE en el modelo
        $success = $this->supportModel->updateStatus($ticket_id, 'closed');

        echo json_encode([
            "success" => $success,
            "message" => $success ? "Ticket cerrado exitosamente" : "Error al cerrar el ticket"
        ]);
    }

    /**
     * Actualizar un ticket (subject, description, category)
     */
    private function updateTicket() {
        $user = $this->getAuthenticatedUser();
        if (!$user) return;

        $data = json_decode(file_get_contents("php://input"), true);
        $ticket_id = (int)($data['ticket_id'] ?? 0);
        $subject = trim($data['subject'] ?? '');
        $description = trim($data['description'] ?? '');
        $category = trim($data['category'] ?? '');

        if (!$ticket_id) {
            http_response_code(400);
            echo json_encode(["message" => "ID de ticket requerido"]);
            return;
        }

        // Verificar que el ticket existe
        $ticket = $this->supportModel->getTicketById($ticket_id);
        if (!$ticket) {
            http_response_code(404);
            echo json_encode(["message" => "Ticket no encontrado"]);
            return;
        }

        // Verificar que el ticket pertenece al usuario
        if ($ticket['user_id'] != $user['id']) {
            http_response_code(403);
            echo json_encode(["message" => "No autorizado para actualizar este ticket"]);
            return;
        }

        // Verificar que el ticket no esté cerrado
        if ($ticket['status'] === 'closed' || $ticket['status'] === 'cancelled') {
            http_response_code(400);
            echo json_encode(["message" => "No se puede actualizar un ticket cerrado"]);
            return;
        }

        // Construir array de actualización solo con campos proporcionados
        $updateData = [];
        if (!empty($subject)) $updateData['subject'] = $subject;
        if (!empty($description)) $updateData['description'] = $description;
        if (!empty($category)) $updateData['category'] = $category;

        if (empty($updateData)) {
            http_response_code(400);
            echo json_encode(["message" => "No hay datos para actualizar"]);
            return;
        }

        $success = $this->supportModel->updateTicket($ticket_id, $updateData);

        echo json_encode([
            "success" => $success,
            "message" => $success ? "Ticket actualizado exitosamente" : "Error al actualizar el ticket"
        ]);
    }

    /**
     * Responder a un ticket (agregar mensaje)
     */
    private function replyTicket() {
        $user = $this->getAuthenticatedUser();
        if (!$user) return;

        $data = json_decode(file_get_contents("php://input"), true);
        $ticket_id = (int)($data['ticket_id'] ?? 0);
        $message = trim($data['message'] ?? '');

        if (!$ticket_id) {
            http_response_code(400);
            echo json_encode(["message" => "ID de ticket requerido"]);
            return;
        }

        if (!$message) {
            http_response_code(400);
            echo json_encode(["message" => "El mensaje es requerido"]);
            return;
        }

        // Verificar que el ticket existe
        $ticket = $this->supportModel->getTicketById($ticket_id);
        if (!$ticket) {
            http_response_code(404);
            echo json_encode(["message" => "Ticket no encontrado"]);
            return;
        }

        // Verificar que el ticket pertenece al usuario
        if ($ticket['user_id'] != $user['id']) {
            http_response_code(403);
            echo json_encode(["message" => "No autorizado para responder este ticket"]);
            return;
        }

        // Verificar que el ticket no esté cerrado
        if ($ticket['status'] === 'closed' || $ticket['status'] === 'cancelled') {
            http_response_code(400);
            echo json_encode(["message" => "No se puede responder a un ticket cerrado"]);
            return;
        }

        // Agregar la respuesta (necesitarás crear esta función en el modelo)
        $replyId = $this->supportModel->addReply($ticket_id, $user['id'], $message);

        // Actualizar el updated_at del ticket
        $this->supportModel->updateTimestamp($ticket_id);

        echo json_encode([
            "success" => true,
            "replyId" => $replyId,
            "message" => "Respuesta enviada exitosamente"
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
