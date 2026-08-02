<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../services/WebSocketService.php';

use services\WebSocketService;

$db = (new Database())->getConnection();

echo "=== INICIO CHECK BILLING: " . date('Y-m-d H:i:s') . " ===\n";

// 1. Actualizar fechas de vencimiento
$db->exec("UPDATE provider_billing SET due_date = DATE_ADD(period_end, INTERVAL 15 DAY) WHERE due_date IS NULL");
echo "✅ Fechas actualizadas\n";

// 2. Marcar vencidas
$stmt = $db->prepare("SELECT id, provider_id, total_commission, period_end FROM provider_billing WHERE status = 'pending' AND due_date < CURDATE()");
$stmt->execute();
$overdue = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($overdue as $bill) {
    $db->prepare("UPDATE provider_billing SET status = 'overdue' WHERE id = ?")->execute([$bill['id']]);
    $db->prepare("INSERT INTO notifications (receiver_id, receiver_role, title, message, data_json, created_at) VALUES (?, 'provider', ?, ?, ?, NOW())")->execute([$bill['provider_id'], '🚫 Factura vencida', "Factura {$bill['period_end']} por \${$bill['total_commission']} vencida.", json_encode(['url' => '/account-blocked', 'action' => 'view_blocked_info'])]);
}
echo "✅ " . count($overdue) . " vencidas\n";

// 3. Próximas a vencer
$stmt = $db->prepare("SELECT id, provider_id, total_commission, period_end, due_date FROM provider_billing WHERE status = 'pending' AND due_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 3 DAY)");
$stmt->execute();
$upcoming = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($upcoming as $bill) {
    $daysLeft = (new DateTime($bill['due_date']))->diff(new DateTime())->days;
    $db->prepare("INSERT INTO notifications (receiver_id, receiver_role, title, message, data_json, created_at) VALUES (?, 'provider', ?, ?, ?, NOW())")->execute([$bill['provider_id'], '⚠️ Próxima a vencer', "Vence en $daysLeft días: \${$bill['total_commission']}", json_encode(['url' => '/account-blocked', 'action' => 'view_blocked_info'])]);
}
echo "✅ " . count($upcoming) . " próximas\n";

// 4. Bloquear morosos
$stmt = $db->prepare("SELECT DISTINCT pb.provider_id, u.name, COUNT(pb.id) as bills, SUM(pb.total_commission) as total FROM provider_billing pb JOIN users u ON u.id = pb.provider_id WHERE pb.status = 'overdue' AND pb.due_date < DATE_SUB(CURDATE(), INTERVAL 7 DAY) AND u.active = 1 GROUP BY pb.provider_id");
$stmt->execute();
$morosos = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($morosos as $m) {
    $db->prepare("UPDATE users SET active = 0 WHERE id = ?")->execute([$m['provider_id']]);
    $db->prepare("INSERT INTO notifications (receiver_id, receiver_role, title, message, data_json, created_at) VALUES (?, 'provider', ?, ?, ?, NOW())")->execute([$m['provider_id'], '🚫 Cuenta bloqueada', "Deuda: \${$m['total']}", json_encode(['url' => '/account-blocked', 'action' => 'view_blocked_info'])]);
}
echo "✅ " . count($morosos) . " bloqueados\n";

echo "=== FIN ===\n";
