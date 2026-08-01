<?php
require_once __DIR__ . '/../config/database.php';

$db = (new Database())->getConnection();

echo "=== CHECK EXPIRING SERVICES: " . date('Y-m-d H:i:s') . " ===\n";

// 1. Notificar servicios próximos a vencer (3 días antes)
$stmt = $db->query("
    SELECT s.id, s.title, s.expires_at, s.user_id, u.name, u.email
    FROM services s
    JOIN users u ON u.id = s.user_id
    WHERE s.status = 'active'
      AND s.expires_at IS NOT NULL
      AND s.expires_at <= DATE_ADD(NOW(), INTERVAL 3 DAY)
      AND s.expires_at > NOW()
      AND s.notified_expiry = 0
");
$expiring = $stmt->fetchAll(PDO::FETCH_ASSOC);

foreach ($expiring as $service) {
    $daysLeft = ceil((strtotime($service['expires_at']) - time()) / 86400);
    
    $db->prepare("
        INSERT INTO notifications (receiver_id, receiver_role, title, message, data_json, created_at)
        VALUES (?, 'provider', ?, ?, ?, NOW())
    ")->execute([
        $service['user_id'],
        '⏰ Servicio por vencer',
        "Tu servicio '{$service['title']}' vence en {$daysLeft} días. Renuévalo para mantenerlo activo.",
        json_encode(['url' => '/myservices', 'service_id' => $service['id']])
    ]);

    $db->prepare("UPDATE services SET notified_expiry = 1 WHERE id = ?")->execute([$service['id']]);
}
echo "✅ Notificados: " . count($expiring) . " servicios\n";

// 2. Desactivar servicios vencidos
$stmt = $db->query("
    UPDATE services 
    SET status = 'inactive', isAvailable = 0, is_featured = 0 
    WHERE status = 'active' 
      AND expires_at IS NOT NULL 
      AND expires_at < NOW()
");
$expired = $stmt->rowCount();
echo "✅ Desactivados: {$expired} servicios vencidos\n";

// 3. Desactivar destacados vencidos
$stmt = $db->query("
    UPDATE services 
    SET is_featured = 0 
    WHERE is_featured = 1 
      AND featured_expires_at IS NOT NULL 
      AND featured_expires_at < NOW()
");
$expiredFeatured = $stmt->rowCount();
echo "✅ Destacados expirados: {$expiredFeatured}\n";

// 4. Limpiar tokens expirados
$db->exec("DELETE FROM token_blacklist WHERE expires_at < NOW()");
echo "✅ Tokens expirados limpiados\n";

echo "=== FIN ===\n";
