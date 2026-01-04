<?php
// Cargar controladores
require_once __DIR__ . '/../controllers/AuthController.php';
require_once __DIR__ . '/../controllers/UserController.php';
require_once __DIR__ . '/../controllers/ServiceController.php';
require_once __DIR__ . '/../controllers/MessageController.php';
require_once __DIR__ . '/../controllers/NotificationController.php';
require_once __DIR__ . '/../controllers/RequestController.php';
require_once __DIR__ . '/../controllers/AdminController.php';
require_once __DIR__ . '/../controllers/PaymentController.php';
require_once __DIR__ . '/../controllers/SupportController.php';
require_once __DIR__ . '/../controllers/HistoryController.php';
require_once __DIR__ . '/../controllers/SystemController.php';
require_once __DIR__ . '/../controllers/ConversationController.php';
require_once __DIR__ . '/../controllers/ProviderPaymentController.php';

$request = $_SERVER['REQUEST_URI'];
$method  = $_SERVER['REQUEST_METHOD'];

// --- RUTAS AUTENTICACIÓN ---
if (preg_match('~/api/login~', $request)) {
    (new AuthController())->login();
} elseif (preg_match('~/api/register~', $request)) {
    (new AuthController())->register();
} elseif ($request === '/api/me') {
    (new AuthController())->me();
} elseif ($request === '/api/refresh-token' && $method === 'POST') {
    (new AuthController())->refreshToken();

// --- RUTA INDIVIDUAL POR ID ---
} elseif (preg_match('~/api/services/(\d+)$~', $request, $m) && $method === 'GET') {
    $id = (int)$m[1];
    (new ServiceController())->getById($id);

// --- RUTAS SERVICIOS ---
} elseif (
    preg_match('~/api/services/create~', $request) ||
    preg_match('~/api/services/mine~', $request) ||
    preg_match('~/api/services/all~', $request) ||
    preg_match('~/api/services/update~', $request) ||
    preg_match('~/api/services/delete~', $request) ||
    preg_match('~/api/services/?$~', $request) ||
    preg_match('~/api/services~', $request)
) {
    (new ServiceController())->handle($method);

// --- RUTAS SOLICITUDES (REQUESTS) ---
} elseif (
    preg_match('~/api/requests/create~', $request) ||
    preg_match('~/api/requests/completed~', $request) ||
    preg_match('~/api/requests/finalized~', $request) ||
    preg_match('~/api/requests/mine~', $request) ||
    preg_match('~/api/requests/pending~', $request) ||
    preg_match('~/api/requests/active~', $request) ||
    preg_match('~/api/requests/accept~', $request) ||
    preg_match('~/api/requests/cancel~', $request) ||
    preg_match('~/api/requests/status/\d+~', $request) ||
    preg_match('~/api/requests/reject~', $request) ||
    preg_match('~/api/requests/busy~', $request) ||
    preg_match('~/api/requests/in_progress~', $request) ||
    preg_match('~/api/requests/on_the_way~', $request) ||
    preg_match('~/api/requests/arrived~', $request) ||
    preg_match('~/api/requests/confirm-payment~', $request) ||
    preg_match('~/api/requests~', $request)
) {
    (new RequestController())->handle($method);

// --- RUTAS HISTORIAL (NUEVAS) ---
} elseif (
    preg_match('~/api/history/?$~', $request) ||
    preg_match('~/api/history/rate/?$~', $request) ||
    preg_match('~/api/history/rate-user/?$~', $request) ||
    preg_match('~/api/reviews/received/?$~', $request) ||
    preg_match('~/api/history/by-request/\d+$~', $request)
) {
    (new HistoryController())->handle($method);


// --- RUTAS NOTIFICACIONES ---
} elseif (
    preg_match('~/api/notifications/send~', $request) ||
    preg_match('~/api/notifications/mine~', $request) ||
    preg_match('~/api/notifications/read~', $request) ||
    preg_match('~/api/notifications/?$~', $request)
) {
    (new NotificationController())->handle($method);

/* --- RUTAS ÚTILES / REPORTES / RESPUESTA --- */
} elseif ($method === 'POST' && preg_match('~/api/reviews/helpful/?$~', $request)) {
    (new HistoryController())->markHelpful();
} elseif ($method === 'POST' && preg_match('~/api/reviews/report/?$~', $request)) {
    (new HistoryController())->report();
} elseif ($method === 'PUT' && preg_match('~/api/reviews/(\d+)/reply/?$~', $request, $m)) {
    (new HistoryController())->reply((int)$m[1]);
} elseif ($method === 'POST' && preg_match('~/api/reviews/(\d+)/reply/?$~', $request, $m)) {
    (new HistoryController())->createReply((int)$m[1]);
} elseif ($method === 'PUT' && preg_match('~/api/reviews/(\d+)/?$~', $request, $m)) {
    (new HistoryController())->updateReview((int)$m[1]);

// --- RUTAS PERFIL USUARIO ---
} elseif (preg_match('~/api/profile/update~', $request)) {
    (new UserController())->updateProfile();
} elseif (preg_match('~/api/profile/password~', $request)) {
    (new UserController())->changePassword();
} elseif (preg_match('~/api/profile/avatar~', $request)) {
    (new UserController())->uploadAvatar();
} elseif (preg_match('~/api/profile/preferences~', $request)) {
    (new UserController())->updatePreferences();
} elseif (preg_match('~/api/profile$~', $request)) {
    (new UserController())->getProfile();

// --- RUTAS PROVEEDOR ---
} elseif (preg_match('~/api/provider/update~', $request)) {
    (new UserController())->updateProviderData();
} elseif (preg_match('~/api/provider/\d+~', $request)) {
    $parts = explode('/', trim($request, '/'));
    $id = $parts[2] ?? null;
    if ($id) {
        (new UserController())->getProvider($id);
    } else {
        http_response_code(400);
        echo json_encode(["error" => "ID de proveedor no proporcionado"]);
    }

// --- RUTAS ADMIN ---
} elseif (preg_match('~/api/admin/reports~', $request) && $method === 'GET') {
    (new AdminController())->reports();
} elseif (preg_match('~/api/admin/stats~', $request)) {
    (new AdminController())->stats();
} elseif (preg_match('~/api/admin/users~', $request)) {
    (new AdminController())->users();
/* --- RUTAS ADMIN (servicios) --- */
} elseif (preg_match('~/api/admin/services~', $request) && $method === 'GET') {
    (new AdminController())->listServices();
} elseif (preg_match('~/api/admin/services/update~', $request) && $method === 'PUT') {
    (new AdminController())->updateService();
} elseif (preg_match('~/api/admin/services/delete~', $request) && $method === 'DELETE') {
    (new AdminController())->deleteService();

// --- RUTAS PAGO (usuario paga) y MÉTODOS DE PAGO (proveedor) ---
} elseif (preg_match('~/api/payments~', $request)) {
    (new PaymentController())->handle($method);
} elseif (preg_match('#^/api/provider/(\d+)/payment-methods$#', $request, $m)) {
    $providerId = (int)$m[1];
    (new ProviderPaymentController())->getPublicMethods($providerId);
} elseif (preg_match('#^/api/provider/payment-methods(/(\d+))?$#', $request, $m)) {
    $id = isset($m[2]) ? (int)$m[2] : null;
    switch ($method) {
        case 'GET':
            (new ProviderPaymentController())->getMyMethods();
            break;
        case 'POST':
            (new ProviderPaymentController())->createMethod();
            break;
        case 'PUT':
            if (!$id) { http_response_code(400); exit; }
            (new ProviderPaymentController())->updateMethod($id);
            break;
        case 'DELETE':
            if (!$id) { http_response_code(400); exit; }
            (new ProviderPaymentController())->deleteMethod($id);
            break;
        default:
            http_response_code(405);
            echo json_encode(['error' => 'Método no permitido']);
    }

// --- RUTAS CONVERSACIONES ---
} elseif (preg_match('~/api/conversations~', $request)) {
    (new ConversationController())->handle($method);

// --- RUTAS MENSAJES / CHAT ---
} elseif (preg_match('~/api/upload/image~', $request)) {
    (new MessageController())->uploadMessageImage();
} elseif (preg_match('#/api/messages/(\d+)/([a-z]+)$#', $request, $m)) {
    $data = ['target_id' => (int)$m[1], 'target_role' => $m[2]];
    (new MessageController())->getMessages($data);
} elseif (preg_match('~/api/messages/conversation~', $request)) {
    $data = json_decode(file_get_contents("php://input"), true) ?? $_GET;
    (new MessageController())->getMessages($data);
} elseif (preg_match('~/api/messages/send~', $request)) {
    $data = json_decode(file_get_contents("php://input"), true) ?? $_POST;
    (new MessageController())->sendMessage($data);
} elseif (preg_match('~/api/messages/read~', $request)) {
    $data = json_decode(file_get_contents("php://input"), true) ?? $_POST;
    (new MessageController())->markAsRead($data);

// --- RUTAS SOPORTE ---
} elseif (
    preg_match('~/api/support/faq~', $request) ||
    preg_match('~/api/support/tickets~', $request) ||
    preg_match('~/api/support/tickets/create~', $request)
) {
    (new SupportController())->handle($method);

// --- RUTAS CONFIGURACIÓN DEL SISTEMA (NUEVAS) ---
} elseif (preg_match('~/api/admin/system-config$~', $request) && $method === 'GET') {
    (new AdminController())->getSystemConfig();
} elseif (preg_match('~/api/admin/system-config$~', $request) && $method === 'PUT') {
    (new AdminController())->updateSystemConfig();
} elseif (preg_match('~/api/admin/upload-logo$~', $request) && $method === 'POST') {
    (new AdminController())->uploadLogo();
} elseif (preg_match('~/api/admin/upload-favicon$~', $request) && $method === 'POST') {
    (new AdminController())->uploadFavicon();

// --- RUTA GET DEL SISTEMA ---
} elseif (preg_match('~/api/system~', $request)) {
    (new SystemController())->handle($method);

// --- RUTA POR DEFECTO ---
} else {
    http_response_code(404);
    echo json_encode(["error" => "Ruta no encontrada"]);
}
