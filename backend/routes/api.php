<?php
// Habilitar CORS (¡debe ir antes de cualquier salida!)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Origin, X-Requested-With, Content-Type, Accept, Authorization");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Credentials: true");

// Manejo para solicitudes OPTIONS (preflight)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

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

$request = $_SERVER['REQUEST_URI'];
$method  = $_SERVER['REQUEST_METHOD'];

// --- RUTAS AUTENTICACIÓN ---
if (preg_match('/\/api\/login/', $request)) {
    (new AuthController())->login();
} elseif (preg_match('/\/api\/register/', $request)) {
    (new AuthController())->register();
// Antes
//} elseif (preg_match('/\/api\/me/', $request)) {

// Después
} elseif ($request === '/api/me') {
    (new AuthController())->me();


// --- RUTAS SERVICIOS ---
} elseif (
    preg_match('/\/api\/services\/create/', $request) ||
    preg_match('/\/api\/services\/mine/', $request) ||
    preg_match('/\/api\/services\/all/', $request) ||
    preg_match('/\/api\/services\/update/', $request) ||
    preg_match('/\/api\/services\/delete/', $request) ||
    preg_match('/\/api\/services\/?$/', $request) ||
    preg_match('/\/api\/services/', $request)
) {
    (new ServiceController())->handle($method);

// --- RUTAS SOLICITUDES (REQUESTS) ---
} elseif (
    preg_match('/\/api\/requests\/create/', $request) ||
    preg_match('/\/api\/requests\/completed/', $request) ||
    preg_match('/\/api\/requests\/finalized/', $request) ||
    preg_match('/\/api\/requests\/mine/', $request) ||
    preg_match('/\/api\/requests\/pending/', $request) ||
    preg_match('/\/api\/requests\/active/', $request) ||
    preg_match('/\/api\/requests\/accept/', $request) ||
    preg_match('/\/api\/requests\/cancel/', $request) ||
    preg_match('/\/api\/requests\/status\/\d+/', $request) ||
    preg_match('/\/api\/requests\/reject/', $request) ||
    preg_match('/\/api\/requests\/busy/', $request) ||
    preg_match('/\/api\/requests\/history/', $request) ||
    preg_match('/\/api\/requests/', $request)
) {
    (new RequestController())->handle($method);


// --- RUTAS NOTIFICACIONES ---
} elseif (
    preg_match('/\/api\/notifications\/send/', $request) ||
    preg_match('/\/api\/notifications\/mine/', $request) ||
    preg_match('/\/api\/notifications\/read/', $request) ||
    preg_match('/\/api\/notifications\/?$/', $request)
) {
    (new NotificationController())->handle($method);

// --- RUTAS PERFIL USUARIO ---
} elseif (preg_match('/\/api\/profile\/update/', $request)) {
    (new UserController())->updateProfile();
} elseif (preg_match('/\/api\/profile\/password/', $request)) {
    (new UserController())->changePassword();
} elseif (preg_match('/\/api\/profile\/avatar/', $request)) {
    (new UserController())->uploadAvatar();
} elseif (preg_match('/\/api\/profile\/preferences/', $request)) {
    (new UserController())->updatePreferences();
} elseif (preg_match('/\/api\/profile$/', $request)) {
    (new UserController())->getProfile();

// --- RUTAS PROVEEDOR ---
} elseif (preg_match('/\/api\/provider\/update/', $request)) {
    (new UserController())->updateProviderData();
} elseif (preg_match('/\/api\/provider\/\d+/', $request)) {
    $parts = explode('/', trim($request, '/'));
    $id = $parts[2] ?? null;
    if ($id) {
        (new UserController())->getProvider($id);
    } else {
        http_response_code(400);
        echo json_encode(["error" => "ID de proveedor no proporcionado"]);
    }

// --- RUTAS ADMIN ---
} elseif (preg_match('/\/api\/admin\/stats/', $request)) {
    (new AdminController())->stats();

// --- RUTAS PAGO ---
} elseif (preg_match('/\/api\/payments/', $request)) {
    (new PaymentController())->handle($method);

// --- RUTAS CONVERSACIONES (nuevas) ---
} elseif (preg_match('/\/api\/conversations/', $request)) {
    (new ConversationController())->handle($method);


// --- RUTAS MENSAJES / IMG  ---
} elseif (preg_match('/\/api\/upload\/image/', $request)) {
    (new MessageController())->uploadMessageImage();

// --- RUTAS MENSAJES / CHAT ---
} elseif (preg_match('#/api/messages/(\d+)/([a-z]+)$#', $request, $m)) {
    $data = ['target_id' => (int)$m[1], 'target_role' => $m[2]];
    (new MessageController())->getMessages($data);
} elseif (preg_match('/\/api\/messages\/conversation/', $request)) {
    $data = json_decode(file_get_contents("php://input"), true) ?? $_GET;
    (new MessageController())->getMessages($data);
} elseif (preg_match('/\/api\/messages\/send/', $request)) {
    $data = json_decode(file_get_contents("php://input"), true) ?? $_POST;
    (new MessageController())->sendMessage($data);
} elseif (preg_match('/\/api\/messages\/read/', $request)) {
    $data = json_decode(file_get_contents("php://input"), true) ?? $_POST;
    (new MessageController())->markAsRead($data);

// --- RUTAS SOPORTE ---
} elseif (
    preg_match('/\/api\/support\/faq/', $request) ||
    preg_match('/\/api\/support\/tickets/', $request) ||
    preg_match('/\/api\/support\/tickets\/create/', $request)
) {
    (new SupportController())->handle($method);


// --- RUTAS CONFIGURACIÓN DEL SISTEMA ---
} elseif (preg_match('/\/api\/system\/config/', $request)) {
    (new SystemController())->handle($method);

// --- RUTA POR DEFECTO ---
} else {
    http_response_code(404);
    echo json_encode(["error" => "Ruta no encontrada"]);
}
