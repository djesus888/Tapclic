<?php
require_once __DIR__ . '/../config/database.php';

$db = (new Database())->getConnection();

echo "=== CHECK EXPIRING SERVICES: " . date('Y-m-d H:i:s') . " ===\n";

// ============================================
// 1. NOTIFICAR SERVICIOS PRÓXIMOS A VENCER (3 días antes)
// ============================================
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
echo "✅ Notificados servicios por vencer: " . count($expiring) . "\n";

// ============================================
// 2. DESACTIVAR SERVICIOS VENCIDOS
// ============================================
$stmt = $db->query("
    UPDATE services
    SET status = 'inactive', isAvailable = 0, is_featured = 0
    WHERE status = 'active'
      AND expires_at IS NOT NULL
      AND expires_at < NOW()
");
$expired = $stmt->rowCount();
echo "✅ Desactivados servicios vencidos: {$expired}\n";

// ============================================
// 3. NOTIFICAR DESTACADOS PRÓXIMOS A VENCER (3 días antes)
// ============================================
$stmt = $db->query("
    SELECT s.id, s.title, s.user_id, s.featured_expires_at
    FROM services s
    WHERE s.is_featured = 1
      AND s.featured_expires_at IS NOT NULL
      AND s.featured_expires_at <= DATE_ADD(NOW(), INTERVAL 3 DAY)
      AND s.featured_expires_at > NOW()
      AND s.notified_featured_expiry = 0
");
$expiringFeatured = $stmt->fetchAll(PDO::FETCH_ASSOC);

foreach ($expiringFeatured as $service) {
    $daysLeft = ceil((strtotime($service['featured_expires_at']) - time()) / 86400);

    $db->prepare("
        INSERT INTO notifications (receiver_id, receiver_role, title, message, data_json, created_at)
        VALUES (?, 'provider', ?, ?, ?, NOW())
    ")->execute([
        $service['user_id'],
        '⚠️ Destacado por vencer',
        "Tu servicio '{$service['title']}' perderá el DESTACADO en {$daysLeft} días. Renueva para mantenerlo en los primeros lugares.",
        json_encode([
            'url' => '/myservices',
            'action' => 'renew_featured',
            'service_id' => $service['id']
        ])
    ]);

    // Marcar como notificado para no duplicar
    $db->prepare("
        UPDATE services
        SET notified_featured_expiry = 1
        WHERE id = ?
    ")->execute([$service['id']]);
}
echo "✅ Notificados destacados por vencer: " . count($expiringFeatured) . "\n";

// ============================================
// 4. OBTENER DESTACADOS EXPI RADOS (ANTES de desactivar)
// ============================================
$stmt = $db->query("
    SELECT s.id, s.title, s.user_id, s.featured_expires_at
    FROM services s
    WHERE s.is_featured = 1
      AND s.featured_expires_at IS NOT NULL
      AND s.featured_expires_at < NOW()
      AND s.notified_featured_expiry = 0
");
$expiredFeaturedServices = $stmt->fetchAll(PDO::FETCH_ASSOC);

// ============================================
// 5. DESACTIVAR DESTACADOS VENCIDOS
// ============================================
$stmt = $db->query("
    UPDATE services
    SET is_featured = 0
    WHERE is_featured = 1
      AND featured_expires_at IS NOT NULL
      AND featured_expires_at < NOW()
");
$expiredFeatured = $stmt->rowCount();
echo "✅ Destacados expirados desactivados: {$expiredFeatured}\n";

// ============================================
// 6. NOTIFICAR DESTACADOS QUE YA EXPI RARON
// ============================================
if (count($expiredFeaturedServices) > 0) {
    foreach ($expiredFeaturedServices as $service) {
        $db->prepare("
            INSERT INTO notifications (receiver_id, receiver_role, title, message, data_json, created_at)
            VALUES (?, 'provider', ?, ?, ?, NOW())
        ")->execute([
            $service['user_id'],
            '⏰ Destacado expirado',
            "Tu servicio '{$service['title']}' ya no está DESTACADO. Puedes renovarlo desde el panel de control.",
            json_encode([
                'url' => '/myservices',
                'action' => 'renew_featured',
                'service_id' => $service['id']
            ])
        ]);

        // Marcar como notificado para no duplicar
        $db->prepare("
            UPDATE services
            SET notified_featured_expiry = 1
            WHERE id = ?
        ")->execute([$service['id']]);
    }

    echo "✅ Notificados destacados expirados: " . count($expiredFeaturedServices) . "\n";
}

// ============================================
// 7. LIMPIAR TOKENS EXPI RADOS
// ============================================
$db->exec("DELETE FROM token_blacklist WHERE expires_at < NOW()");
echo "✅ Tokens expirados limpiados\n";

echo "=== FIN ===\n";
