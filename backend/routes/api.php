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
require_once __DIR__ . '/../controllers/ContentController.php';
require_once __DIR__ . '/../controllers/WalletController.php';
require_once __DIR__ . '/../controllers/PaymentMethodController.php';
require_once __DIR__ . '/../controllers/UserPresenceController.php';
require_once __DIR__ . '/../controllers/ProviderStaffController.php';
require_once __DIR__ . '/../controllers/BillingController.php';
require_once __DIR__ . '/../utils/AuditLogger.php';
require_once __DIR__ . '/../controllers/MonetizationController.php';
require_once __DIR__ . "/../controllers/FavoritesController.php";


//$request = $_SERVER['REQUEST_URI'];
$request = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
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
} elseif ($request === '/api/forgot-password' && $method === 'POST') {
    (new AuthController())->forgotPassword();
} elseif ($request === '/api/reset-password' && $method === 'POST') {
    (new AuthController())->resetPassword();
} elseif ($request === '/api/logout' && $method === 'POST') {
    (new AuthController())->logout();

// --- RUTAS DE PRESENCIA ONLINE ---
} elseif ($request === '/api/user/heartbeat' && $method === 'POST') {
    (new UserPresenceController())->heartbeat();
} elseif (preg_match('~/api/user/(\d+)/online$~', $request, $m) && $method === 'GET') {
    (new UserPresenceController())->checkUserOnline((int)$m[1]);

// --- RUTA INDIVIDUAL POR ID ---
} elseif (preg_match('~/api/services/(\d+)$~', $request, $m) && $method === 'GET') {
    $id = (int)$m[1];
    (new ServiceController())->getById($id);

// --- RUTA PUBLICAR SERVICIO (PAGO) ---
} elseif (preg_match('~/api/services/(\d+)/publish-external~', $request, $m) && $method === 'POST') {
    (new MonetizationController())->payToPublishExternal((int)$m[1]);
} elseif (preg_match('~/api/services/(\d+)/publish~', $request, $m) && $method === 'POST') {
    (new MonetizationController())->payToPublish((int)$m[1]);

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

// --- RUTAS PAGOS (NUEVAS) ---
} elseif (
    preg_match('~/api/payments/create~', $request) ||
    preg_match('~/api/payments/mine~', $request) ||
    preg_match('~/api/payments/public~', $request) ||
    preg_match('~/api/payments/confirm-payment~', $request) ||
    preg_match('~/api/payments/reject-payment~', $request) ||
    preg_match('~/api/payments/proof~', $request)
) {
    (new PaymentController())->handle($method);

// --- RUTAS DELIVERY (STAFF) - DEBEN IR ANTES DEL BLOQUE requests ---
} elseif ($request === '/api/delivery/orders' && $method === 'GET') {
    (new RequestController())->getDeliveryOrders();
} elseif ($request === '/api/delivery/update-status' && $method === 'POST') {
    (new RequestController())->updateDeliveryStatus();
} elseif ($request === '/api/requests/assign-delivery' && $method === 'POST') {
    (new RequestController())->assignDelivery();
} elseif ($request === '/api/delivery/history' && $method === 'GET') {
    (new RequestController())->getDeliveryHistory();


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

// --- RUTAS HISTORIAL ---
} elseif (
    preg_match('~/api/history/?$~', $request) ||
    preg_match('~/api/history/rate/?$~', $request) ||
    preg_match('~/api/history/rate-user/?$~', $request) ||
    preg_match('~/api/reviews/received/?$~', $request) ||
    preg_match('~/api/history/by-request/\d+$~', $request)
) {
    (new HistoryController())->handle($method);

// --- RUTAS NOTIFICACIONES ---
// ✅ CORREGIDO: Añadida ruta unread-count
} elseif (
    preg_match('~/api/notifications/send~', $request) ||
    preg_match('~/api/notifications/mine~', $request) ||
    preg_match('~/api/notifications/unread-count~', $request) ||
    preg_match('~/api/notifications/read~', $request) ||
    preg_match('~/api/notifications/read-all~', $request) ||
    preg_match('~/api/notifications/email~', $request) ||
    preg_match('~/api/notifications/sms~', $request) ||
    preg_match('~/api/notifications/preferences~', $request) ||
    preg_match('~/api/notifications/?$~', $request)
) {
    (new NotificationController())->handle($method);

// --- RUTAS ÚTILES / REPORTES / RESPUESTA ---
} elseif ($method === 'POST' && preg_match('~/api/reviews/image/?$~', $request)) {
    (new HistoryController())->uploadReviewImage();
} elseif ($method === 'POST' && preg_match('~/api/reviews/helpful/?$~', $request)) {
    (new HistoryController())->handle($method);
} elseif ($method === 'POST' && preg_match('~/api/reviews/report/?$~', $request)) {
    (new HistoryController())->handle($method);
} elseif ($method === 'POST' && preg_match('~/api/reviews/report-content/?$~', $request)) {
    (new HistoryController())->handle($method);
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

// --- RUTAS PARA DISPOSITIVOS ---
} elseif (preg_match('~/api/profile/devices~', $request) && $_SERVER['REQUEST_METHOD'] === 'GET') {
    (new UserController())->getDevices();
} elseif (preg_match('~/api/profile/revoke-device~', $request) && $_SERVER['REQUEST_METHOD'] === 'POST') {
    (new UserController())->revokeDevice();
} elseif (preg_match('~/api/profile/revoke-all-devices~', $request) && $_SERVER['REQUEST_METHOD'] === 'POST') {
    (new UserController())->revokeAllDevices();

// --- RUTAS PROVEEDOR ---
} elseif (preg_match('~/api/provider/update~', $request)) {
    (new UserController())->updateProviderData();
} elseif (preg_match('~/api/provider/(\d+)$~', $request, $m) && $method === 'GET') {
    (new UserController())->getProvider((int)$m[1]);
} elseif ($request === '/api/provider/payment-methods' && $method === 'GET') {
    (new PaymentMethodController())->providerIndex();
} elseif ($request === '/api/provider/payment-methods' && $method === 'POST') {
    (new PaymentMethodController())->providerStore();

// --- RUTAS MÉTODOS DE PAGO ---
} elseif ($request === '/api/payment-methods' && $method === 'GET') {
    (new PaymentMethodController())->index();
} elseif (preg_match('~/api/payment-methods/([a-zA-Z_]+)$~', $request, $m) && $method === 'GET') {
    (new PaymentMethodController())->show($m[1]);

// --- RUTAS ADMIN (GESTIÓN DE LA PLATAFORMA) ---
} elseif ($request === '/api/admin/payment-methods' && $method === 'GET') {
    (new PaymentMethodController())->adminIndex();
} elseif ($request === '/api/admin/payment-methods' && $method === 'POST') {
    (new PaymentMethodController())->store();
} elseif (preg_match('~/api/admin/payment-methods/(\d+)$~', $request, $m) && $method === 'PUT') {
    (new PaymentMethodController())->update((int)$m[1]);
} elseif (preg_match('~/api/admin/payment-methods/(\d+)$~', $request, $m) && $method === 'DELETE') {
    (new PaymentMethodController())->destroy((int)$m[1]);

// --- RUTAS ADMIN (REPORTES Y ESTADÍSTICAS) ---
} elseif (preg_match('~/api/admin/reports~', $request) && $method === 'GET') {
    (new AdminController())->reports();
} elseif (preg_match('~/api/admin/stats~', $request)) {
    (new AdminController())->stats();
} elseif (preg_match('~/api/admin/users~', $request)) {
    (new AdminController())->users();
} elseif (preg_match('~/api/admin/users/admins~', $request) && $method === 'GET') {
    (new AdminController())->getAdmins();

// --- RUTAS ADMIN (SERVICIOS) ---
} elseif (preg_match('~/api/admin/services~', $request) && $method === 'GET') {
    (new AdminController())->listServices();
} elseif (preg_match('~/api/admin/services/update~', $request) && $method === 'PUT') {
    (new AdminController())->updateService();
} elseif (preg_match('~/api/admin/services/delete~', $request) && $method === 'DELETE') {
    (new AdminController())->deleteService();

// --- RUTAS ADMIN (ANALYTICS) ---
} elseif (preg_match('~/api/admin/analytics/overview~', $request) && $method === 'GET') {
    (new AdminController())->getAnalyticsOverview();
} elseif (preg_match('~/api/admin/analytics/charts~', $request) && $method === 'GET') {
    (new AdminController())->getAnalyticsCharts();
} elseif (preg_match('~/api/admin/analytics/realtime~', $request) && $method === 'GET') {
    (new AdminController())->getAnalyticsRealTime();
} elseif (preg_match('~/api/admin/analytics/export~', $request) && $method === 'GET') {
    (new AdminController())->exportAnalytics();

// --- RUTAS ADMIN (CONTENIDO) ---
} elseif (preg_match('~/api/admin/content~', $request)) {
    (new ContentController())->handle($method);
} elseif (preg_match('~/api/admin/tickets/(\d+)/comments~', $request, $m) && $method === 'GET') {
    (new AdminController())->getTicketReplies((int)$m[1]);
} elseif (preg_match('~/api/admin/tickets/(\d+)/comments~', $request, $m) && $method === 'POST') {
    (new AdminController())->addTicketReply((int)$m[1]);

// --- RUTAS ADMIN (PAGOS) ---
} elseif (preg_match('~/api/admin/payment-gateways/(\d+)$~', $request, $m)) {
    $id = (int)$m[1];
    if ($method === 'GET') {
        (new AdminController())->getPaymentGateway($id);
    } elseif ($method === 'PUT') {
        (new AdminController())->updatePaymentGateway($id);
    }
} elseif (preg_match('~/api/admin/payment-gateways$~', $request) && $method === 'GET') {
    (new AdminController())->getPaymentGateways();
} elseif (preg_match('~/api/admin/payment-stats$~', $request) && $method === 'GET') {
    (new AdminController())->getPaymentStats();
} elseif (preg_match('~/api/admin/payment-settings$~', $request) && $method === 'PUT') {
    (new AdminController())->updatePaymentSettings();
} elseif (preg_match('~/api/payments/admin-methods~', $request) && $method === 'GET') {
    (new AdminController())->getAdminPaymentMethods();

// --- RUTAS ADMIN (BACKUPS) ---
} elseif (preg_match('~/api/admin/backups/list~', $request) && $method === 'GET') {
    (new AdminController())->listBackups();
} elseif (preg_match('~/api/admin/backups/create~', $request) && $method === 'POST') {
    (new AdminController())->createBackup();
} elseif (preg_match('~/api/admin/backups/download~', $request) && $method === 'GET') {
    (new AdminController())->downloadBackup();
} elseif (preg_match('~/api/admin/backups/restore~', $request) && $method === 'POST') {
    (new AdminController())->restoreBackup();
} elseif (preg_match('~/api/admin/backups/delete~', $request) && $method === 'POST') {
    (new AdminController())->deleteBackup();


// --- RUTAS ADMIN (SEGURIDAD) ---
} elseif (preg_match('~/api/admin/security/sessions~', $request) && $method === 'GET') {
    (new AdminController())->getActiveSessions();
} elseif (preg_match('~/api/admin/security/sessions/terminate~', $request) && $method === 'POST') {
    (new AdminController())->terminateSession();
} elseif (preg_match('~/api/admin/security/audit-logs~', $request) && $method === 'GET') {
    (new AdminController())->getAuditLogs();
} elseif (preg_match('~/api/admin/security/blocked-ips~', $request)) {
    if ($method === 'GET') {
        (new AdminController())->getBlockedIPs();
    } elseif ($method === 'POST') {
        (new AdminController())->blockIP();
    }
} elseif (preg_match('~/api/admin/security/blocked-ips/unblock~', $request) && $method === 'POST') {
    (new AdminController())->unblockIP();
} elseif (preg_match('~/api/admin/security/config~', $request)) {
    if ($method === 'GET') {
        (new AdminController())->getSecurityConfig();
    } elseif ($method === 'PUT') {
        (new AdminController())->updateSecurityConfig();
    }


// --- RUTAS ADMIN (CONFIGURACIÓN DEL SISTEMA) ---
} elseif (preg_match('~/api/admin/system-config~', $request)) {
    if ($method === 'GET') {
        (new AdminController())->getSystemConfig();
    } elseif ($method === 'PUT') {
        (new AdminController())->updateSystemConfig();
    }

// --- RUTAS ADMIN (ACTUALIZACIÓN) ---
} elseif (preg_match('~/api/admin/update/upload~', $request) && $method === 'POST') {
    (new AdminController())->uploadUpdate();

// --- RUTAS FACTURACIÓN (BILLING) ---
} elseif (preg_match('~/api/admin/billing/generate~', $request) && $method === 'POST') {
    (new BillingController())->generateBilling();
} elseif (preg_match('~/api/admin/billing$~', $request) && $method === 'GET') {
    (new BillingController())->getAllBilling();
} elseif (preg_match('~/api/admin/billing/(\d+)/verify~', $request, $m) && $method === 'POST') {
    (new BillingController())->verifyPayment((int)$m[1]);
} elseif (preg_match('~/api/admin/billing/block/(\d+)~', $request, $m) && $method === 'POST') {
    (new BillingController())->toggleBlock((int)$m[1]);
} elseif (preg_match('~/api/provider/billing$~', $request) && $method === 'GET') {
    (new BillingController())->getMyBilling();
} elseif (preg_match('~/api/provider/billing/(\d+)/pay~', $request, $m) && $method === 'POST') {
    (new BillingController())->payBill((int)$m[1]);

// --- RUTAS DEL SISTEMA ---
} elseif (preg_match('~/api/system$~', $request)) {
    (new SystemController())->handle($method);
} elseif (preg_match('~/api/system/config~', $request) && $method === 'GET') {
    (new SystemController())->handle($method);
} elseif (preg_match('~/api/system/config~', $request) && $method === 'POST') {
    (new SystemController())->handle($method);
} elseif (preg_match('~/api/system/test-email~', $request) && $method === 'POST') {
    (new SystemController())->handle($method);
} elseif (preg_match('~/api/system/test-sms~', $request) && $method === 'POST') {
    (new SystemController())->handle($method);
} elseif (preg_match('~/api/system/status~', $request) && $method === 'GET') {
    (new SystemController())->getStatus();

// --- RUTAS WALLET PRODUCCIÓN ---
} elseif ($request === '/api/wallet' && $method === 'GET') {
    (new WalletController())->getWallet();
} elseif ($request === '/api/wallet' && $method === 'POST') {
    (new WalletController())->create();
} elseif ($request === '/api/wallet/balance' && $method === 'GET') {
    (new WalletController())->getBalance();
} elseif ($request === '/api/wallet/stats' && $method === 'GET') {
    (new WalletController())->getStats();
} elseif ($request === '/api/wallet/transactions' && $method === 'GET') {
    (new WalletController())->getTransactions();
} elseif ($request === '/api/wallet/recharge' && $method === 'POST') {
    (new WalletController())->recharge();
} elseif ($request === '/api/wallet/withdraw' && $method === 'POST') {
    (new WalletController())->withdraw();
} elseif ($request === '/api/wallet/transfer' && $method === 'POST') {
    (new WalletController())->transfer();

// --- RUTAS WALLET SOLICITUDES ---
} elseif ($request === '/api/wallet/recharge-request' && $method === 'POST') {
    (new WalletController())->rechargeRequest();
} elseif ($request === '/api/wallet/my-requests' && $method === 'GET') {
    (new WalletController())->getMyRequests();
} elseif (preg_match('~/api/wallet/requests/(\d+)/proof$~', $request, $m) && $method === 'PUT') {
    (new WalletController())->updateProof((int)$m[1]);
} elseif (preg_match('~/api/wallet/requests/(\d+)/cancel$~', $request, $m) && $method === 'PUT') {
    (new WalletController())->cancelRequest((int)$m[1]);

// --- RUTAS ADMIN WALLET ---
} elseif (preg_match('~/api/admin/wallet/requests~', $request) && $method === 'GET') {
    (new WalletController())->adminGetRequests();
} elseif (preg_match('~/api/admin/wallet/approve/(\d+)$~', $request, $m) && $method === 'PUT') {
    (new WalletController())->adminApproveRequest((int)$m[1]);
} elseif (preg_match('~/api/admin/wallet/reject/(\d+)$~', $request, $m) && $method === 'PUT') {
    (new WalletController())->adminRejectRequest((int)$m[1]);
} elseif ($request === '/api/admin/wallet/stats' && $method === 'GET') {
    (new WalletController())->adminGetStats();


// --- RUTAS VERIFICACIÓN DE PAGOS DE SERVICIOS ---
} elseif (preg_match('~/api/admin/service-payments~', $request) && $method === 'GET') {
    (new AdminController())->getServicePayments();
} elseif (preg_match('~/api/admin/service-payments/(\d+)/verify~', $request, $m) && $method === 'POST') {
    (new AdminController())->verifyServicePayment((int)$m[1]);


// --- RUTAS MONETIZACIÓN ---
} elseif (preg_match('~/api/admin/monetization/config~', $request) && $method === 'GET') {
    (new MonetizationController())->getConfig();
} elseif (preg_match('~/api/admin/monetization/config~', $request) && $method === 'PUT') {
    (new MonetizationController())->updateConfig();
} elseif (preg_match('~/api/admin/monetization/earnings~', $request) && $method === 'GET') {
    (new MonetizationController())->getEarnings();
} elseif (preg_match('~/api/monetization/publish-cost~', $request) && $method === 'GET') {
    (new MonetizationController())->getPublishCost();

// ========== RUTAS DE MENSAJERÍA Y CONVERSACIONES ==========
// --- RUTAS MENSAJES / CHAT ---
} elseif (preg_match('~/api/messages/(\d+)/status$~', $request, $m) && $method === 'GET') {
    (new MessageController())->getMessageStatuses((int)$m[1]);
} elseif (preg_match('~/api/upload/image~', $request)) {
    (new MessageController())->uploadMessageImage();
} elseif (preg_match('~/api/messages/(\d+)/for-me$~', $request, $m) && $method === 'DELETE') {
    (new MessageController())->deleteMessageForUser((int)$m[1]);
} elseif (preg_match('~/api/messages/(\d+)$~', $request, $m) && $method === 'GET') {
    (new MessageController())->getMessagesByConversation((int)$m[1]);
} elseif (preg_match('#/api/messages/(\d+)/([a-z]+)$#', $request, $m) && $method === 'GET') {
    $data = ['target_id' => (int)$m[1], 'target_role' => $m[2]];
    (new MessageController())->getMessages($data);
} elseif (preg_match('~/api/messages/conversation/(\d+)/delivered$~', $request, $m) && $method === 'POST') {
    (new MessageController())->markConversationAsDelivered((int)$m[1]);
} elseif (preg_match('~/api/messages/conversation~', $request)) {
    $data = json_decode(file_get_contents("php://input"), true) ?? $_GET;
    (new MessageController())->getMessages($data);
} elseif (preg_match('~/api/messages/send~', $request)) {
    $data = json_decode(file_get_contents("php://input"), true) ?? $_POST;
    (new MessageController())->sendMessage($data);
} elseif (preg_match('~/api/messages/read~', $request)) {
    $data = json_decode(file_get_contents("php://input"), true) ?? $_POST;
    (new MessageController())->markAsRead($data);
} elseif (preg_match('~/api/messages/(\d+)$~', $request, $m) && $method === 'DELETE') {
} elseif (preg_match('~/api/conversations/find/(-?\d+)/([a-z]+)$~', $request, $m) && $method === 'GET') {
    (new ConversationController())->findByParticipants((int)$m[1], $m[2]);
} elseif (preg_match('~/api/conversations/create$~', $request) && $method === 'POST') {
    (new ConversationController())->create();
} elseif (preg_match('~/api/conversations/(\d+)$~', $request, $m) && $method === 'GET') {
    (new ConversationController())->getById((int)$m[1]);
} elseif (preg_match('~/api/conversations/(\d+)$~', $request, $m) && $method === 'DELETE') {
    (new MessageController())->deleteConversation((int)$m[1]);
} elseif (preg_match('~/api/conversations/(\d+)/messages$~', $request, $m) && $method === 'DELETE') {
    (new MessageController())->deleteConversationMessages((int)$m[1]);
} elseif (preg_match('~/api/conversations$~', $request)) {
    (new ConversationController())->handle($method);

// --- RUTAS SOPORTE ---
} elseif (
    preg_match('~/api/support/faq~', $request) ||
    preg_match('~/api/support/tickets~', $request) ||
    preg_match('~/api/support/tickets/create~', $request) ||
    preg_match('~/api/support/tickets/close~', $request) ||
    preg_match('~/api/support/tickets/update~', $request) ||
    preg_match('~/api/support/tickets/(\d+)/replies$~', $request, $m) && $method === 'GET' ||
    preg_match('~/api/support/tickets/reply~', $request)
) {
    (new SupportController())->handle($method);

// --- RUTAS ADMIN TICKETS ---
} elseif (preg_match('~/api/admin/tickets$~', $request) && $method === 'GET') {
    (new AdminController())->getAllTickets();
} elseif (preg_match('~/api/admin/tickets/(\d+)$~', $request, $m) && $method === 'GET') {
    (new AdminController())->getTicket((int)$m[1]);
} elseif (preg_match('~/api/admin/tickets/(\d+)/respond$~', $request, $m) && $method === 'POST') {
    (new AdminController())->respondToTicket((int)$m[1]);
} elseif (preg_match('~/api/admin/tickets/(\d+)/status$~', $request, $m) && $method === 'PUT') {
    (new AdminController())->updateTicketStatus((int)$m[1]);
} elseif (preg_match('~/api/admin/tickets/stats$~', $request) && $method === 'GET') {
    (new AdminController())->getTicketStats();

// --- RUTAS ADMIN TICKETS (ACCIONES MASIVAS) ---
} elseif (preg_match('~/api/admin/tickets/bulk/assign~', $request) && $method === 'POST') {
    (new AdminController())->bulkAssign();
} elseif (preg_match('~/api/admin/tickets/bulk/status~', $request) && $method === 'POST') {
    (new AdminController())->bulkStatus();
} elseif (preg_match('~/api/admin/tickets/bulk/priority~', $request) && $method === 'POST') {
    (new AdminController())->bulkPriority();
} elseif (preg_match('~/api/admin/tickets/bulk/delete~', $request) && $method === 'POST') {
    (new AdminController())->bulkDelete();
} elseif (preg_match('~/api/admin/tickets/bulk/tag~', $request) && $method === 'POST') {
    (new AdminController())->bulkTag();
} elseif (preg_match('~/api/admin/tickets/(\d+)/replies~', $request, $m) && $method === 'GET') {
    (new AdminController())->getTicketReplies((int)$m[1]);
} elseif (preg_match('~/api/admin/tickets/(\d+)/reopen~', $request, $m) && $method === 'POST') {
    (new AdminController())->reopenTicket((int)$m[1]);

// --- RUTAS FAVORITOS ---
} elseif ($request === "/api/favorites" && $method === "GET") {
    (new FavoritesController())->index();
} elseif ($request === "/api/favorites" && $method === "POST") {
    (new FavoritesController())->store();
} elseif ($request === "/api/favorites" && $method === "DELETE") {
    (new FavoritesController())->clearAll();
} elseif (preg_match("~/api/favorites/(\d+)$~", $request, $m) && $method === "DELETE") {
    (new FavoritesController())->destroy((int)$m[1]);
} elseif (preg_match("~/api/favorites/check/(d+)$~", $request, $m) && $method === "GET") {
    (new FavoritesController())->check((int)$m[1]);

// --- RUTA PÁGINAS ESTÁTICAS (PÚBLICO) ---
} elseif (preg_match("~/api/page\/([a-z0-9_-]+)$~", $request, $m) && $method === "GET") {
    (new ContentController())->getPageBySlug($m[1]);

// --- RUTAS PERSONAL DEL PROVEEDOR ---
} elseif ($request === '/api/provider/staff/login' && $method === 'POST') {
    (new ProviderStaffController())->login();
} elseif (preg_match('~/api/provider/staff~', $request)) {
    (new ProviderStaffController())->handle($method);

// --- RUTAS PERFIL DE STAFF (AUTENTICADO COMO STAFF) ---
} elseif ($request === '/api/staff/profile' && $method === 'GET') {
    (new ProviderStaffController())->getProfile();
} elseif ($request === '/api/staff/profile/update' && $method === 'POST') {
    (new ProviderStaffController())->updateProfile();
} elseif ($request === '/api/staff/change-password' && $method === 'POST') {
    (new ProviderStaffController())->changePassword();

// --- RUTA POR DEFECTO ---
} else {
    http_response_code(404);
    echo json_encode(["error" => "Ruta no encontrada"]);
}
?>
