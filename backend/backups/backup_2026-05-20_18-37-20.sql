-- Backup generado el 2026-05-20 18:37:20
-- Base de datos: tapclic_db

DROP TABLE IF EXISTS `activities`;
CREATE TABLE `activities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `message_key` varchar(100) NOT NULL,
  `params` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`params`)),
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

INSERT INTO `activities` VALUES ('1', 'activity.service_created', '{\"user\": \"Juan Pérez\"}', '2025-08-09 10:59:39');
INSERT INTO `activities` VALUES ('2', 'activity.profile_updated', '{\"user\": \"María López\"}', '2025-08-09 10:59:39');
INSERT INTO `activities` VALUES ('3', 'activity.support_ticket_opened', NULL, '2025-08-09 10:59:39');
INSERT INTO `activities` VALUES ('4', 'activity.service_accepted', '{\"service\": \"Limpieza Hogar\"}', '2025-08-09 10:59:39');

DROP TABLE IF EXISTS `audit_logs`;
CREATE TABLE `audit_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `action_type` varchar(50) NOT NULL,
  `action` varchar(255) NOT NULL,
  `details` text DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_action_type` (`action_type`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `audit_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;


DROP TABLE IF EXISTS `blocked_ips`;
CREATE TABLE `blocked_ips` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ip_address` varchar(45) NOT NULL,
  `reason` varchar(255) DEFAULT NULL,
  `blocked_by` varchar(100) DEFAULT 'admin',
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `expires_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ip_address` (`ip_address`),
  KEY `idx_ip_address` (`ip_address`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_expires_at` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;


DROP TABLE IF EXISTS `categories`;
CREATE TABLE `categories` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `icon` varchar(50) DEFAULT '?',
  `color` varchar(20) DEFAULT '#667eea',
  `sort_order` int(11) DEFAULT 0,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

INSERT INTO `categories` VALUES ('1', 'Limpieza', 'La mejor limpieza', '🧹', '#667eea', '1', '1', '2026-02-03 19:32:42', '2026-02-03 19:32:42');
INSERT INTO `categories` VALUES ('2', 'Transporte', 'Transporte para viajará', '🚗', '#667eea', '2', '1', '2026-02-03 19:44:03', '2026-02-03 19:44:03');
INSERT INTO `categories` VALUES ('3', 'Fiestas center', 'Te decoramos todo tipos de fiestas!!', '🎉', '#00ffff', '3', '1', '2026-04-28 05:29:32', '2026-04-28 05:29:32');

DROP TABLE IF EXISTS `content_blocks`;
CREATE TABLE `content_blocks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `identifier` varchar(100) NOT NULL,
  `type` enum('text','html','image','banner','carousel') DEFAULT 'text',
  `content` longtext DEFAULT NULL,
  `settings` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`settings`)),
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `identifier` (`identifier`),
  KEY `idx_identifier` (`identifier`),
  KEY `idx_active` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

INSERT INTO `content_blocks` VALUES ('1', 'Banner Principal', 'home_banner', 'banner', '{\"title\": \"Encuentra el servicio que necesitas\", \"subtitle\": \"Profesionales confiables a tu alcance\", \"button_text\": \"Explorar Servicios\", \"button_link\": \"/services\"}', '{\"background\": \"#667eea\", \"text_color\": \"#ffffff\"}', '1', '2026-01-31 21:35:00', '2026-01-31 21:35:00');
INSERT INTO `content_blocks` VALUES ('2', 'Texto de Bienvenida', 'welcome_text', 'text', '<h2>Bienvenido a TapClic</h2><p>La plataforma que conecta a usuarios con profesionales confiables.</p>', '\"{\\\"alignment\\\": \\\"center\\\"}\"', '1', '2026-01-31 21:35:00', '2026-02-03 19:40:52');
INSERT INTO `content_blocks` VALUES ('3', 'Footer Info', 'footer_info', 'text', '<p>© 2024 TapClic. Todos los derechos reservados.</p>', '{}', '1', '2026-01-31 21:35:00', '2026-01-31 21:35:00');
INSERT INTO `content_blocks` VALUES ('4', 'Segurojajajaja', 'Homejjjjh', 'text', 'Jgcgjjjhvv', '\"{}\"', '1', '2026-02-03 19:57:32', '2026-02-03 19:57:32');

DROP TABLE IF EXISTS `conversations`;
CREATE TABLE `conversations` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `participant1_id` int(11) NOT NULL,
  `participant1_type` enum('user','provider','admin','support') NOT NULL,
  `participant2_id` int(11) NOT NULL,
  `participant2_type` enum('user','provider','admin','support') NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_participants` (`participant1_id`,`participant2_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `conversations` VALUES ('1', '2', 'user', '6', 'provider', '2026-03-27 12:11:32', '2026-03-27 12:11:32');
INSERT INTO `conversations` VALUES ('2', '6', 'provider', '1', 'admin', '2026-04-27 05:56:34', '2026-04-27 05:56:34');
INSERT INTO `conversations` VALUES ('3', '6', 'provider', '6', 'provider', '2026-04-27 06:02:36', '2026-04-27 06:02:36');

DROP TABLE IF EXISTS `conversations_backup`;
CREATE TABLE `conversations_backup` (
  `id` bigint(20) NOT NULL DEFAULT 0,
  `user_id` int(11) NOT NULL,
  `provider_id` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;


DROP TABLE IF EXISTS `device_revocation_log`;
CREATE TABLE `device_revocation_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `device_id` int(11) NOT NULL,
  `device_name` varchar(255) DEFAULT NULL,
  `revoked_at` timestamp NULL DEFAULT current_timestamp(),
  `revoked_by_ip` varchar(45) DEFAULT NULL,
  `revoked_by_user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_revoked_at` (`revoked_at`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `device_revocation_log` VALUES ('1', '2', '13', '💻 Linux - Chrome', '2026-02-22 12:12:43', '192.168.1.47', '2');
INSERT INTO `device_revocation_log` VALUES ('2', '2', '14', '💻 Linux - Chrome', '2026-02-22 12:13:27', '192.168.1.248', '2');
INSERT INTO `device_revocation_log` VALUES ('3', '2', '29', '📱 Xiaomi Redmi - Chrome', '2026-04-27 05:51:17', '192.168.0.100', '2');
INSERT INTO `device_revocation_log` VALUES ('4', '2', '57', '📱 Android - Chrome', '2026-05-17 18:37:08', '192.168.46.12', '2');
INSERT INTO `device_revocation_log` VALUES ('5', '2', '24', '💻 Linux - Chrome', '2026-05-17 18:37:16', '192.168.46.12', '2');
INSERT INTO `device_revocation_log` VALUES ('6', '2', '52', '💻 Linux - Chrome', '2026-05-17 18:37:20', '192.168.46.12', '2');
INSERT INTO `device_revocation_log` VALUES ('7', '2', '41', '📱 Android - Chrome', '2026-05-17 18:37:26', '192.168.46.12', '2');
INSERT INTO `device_revocation_log` VALUES ('8', '2', '42', '💻 Linux - Chrome', '2026-05-17 18:37:32', '192.168.46.12', '2');
INSERT INTO `device_revocation_log` VALUES ('9', '2', '46', '💻 Linux - Chrome', '2026-05-17 18:37:37', '192.168.46.12', '2');
INSERT INTO `device_revocation_log` VALUES ('10', '2', '35', '💻 Linux - Chrome', '2026-05-17 18:37:41', '192.168.46.12', '2');
INSERT INTO `device_revocation_log` VALUES ('11', '2', '48', '📱 Xiaomi Redmi - Chrome', '2026-05-17 18:37:45', '192.168.46.12', '2');
INSERT INTO `device_revocation_log` VALUES ('12', '2', '50', '💻 Linux - Chrome', '2026-05-17 18:37:48', '192.168.46.12', '2');

DROP TABLE IF EXISTS `faqs`;
CREATE TABLE `faqs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `question` varchar(255) NOT NULL,
  `answer` text NOT NULL,
  `sort_order` int(11) DEFAULT 0,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

INSERT INTO `faqs` VALUES ('1', '¿Cómo solicito un servicio?', 'Busca el servicio que necesitas, revisa la disponibilidad y precio, luego haz clic en \"Solicitar\". Completa los detalles y espera la confirmación del proveedor.', '1', '1', '2025-08-28 17:31:43');
INSERT INTO `faqs` VALUES ('2', '¿Qué métodos de pago aceptan?', 'Aceptamos efectivo, transferencia bancaria y tarjetas de crédito/débito. El pago se realiza después de que el proveedor confirme tu solicitud.', '2', '1', '2025-08-28 17:31:43');
INSERT INTO `faqs` VALUES ('3', '¿Puedo cancelar una solicitud?', 'Sí, puedes cancelar desde la sección \"Solicitudes Activas\" antes de que el proveedor la acepte. Si ya fue aceptada, contacta al soporte.', '3', '1', '2025-08-28 17:31:43');
INSERT INTO `faqs` VALUES ('4', '¿Cómo sé si mi solicitud fue aceptada?', 'Recibirás una notificación en la app y un email. También verás el estado cambiar a \"Aceptado\" en \"Solicitudes Activas\".', '4', '1', '2025-08-28 17:31:43');
INSERT INTO `faqs` VALUES ('5', '¿Qué hago si el proveedor no llega?', 'Primero contacta al proveedor por el chat. Si no hay respuesta en 30 minutos, reporta el incidente en Soporte para que te ayudemos.', '5', '1', '2025-08-28 17:31:43');
INSERT INTO `faqs` VALUES ('6', '¿Cómo dejo una reseña?', 'Después de que el servicio se complete, aparecerá la opción de calificar al proveedor en tu historial de servicios.', '6', '1', '2025-08-28 17:31:43');
INSERT INTO `faqs` VALUES ('7', '¿Es seguro compartir mi ubicación?', 'Sí, tu ubicación solo se comparte con el proveedor una vez que acepta tu solicitud. No se almacena permanentemente.', '7', '1', '2025-08-28 17:31:43');
INSERT INTO `faqs` VALUES ('8', '¿Puedo modificar una solicitud después de enviarla?', 'No puedes editar los detalles, pero puedes cancelarla y crear una nueva con la información correcta.', '8', '1', '2025-08-28 17:31:43');
INSERT INTO `faqs` VALUES ('9', '¿Qué pasa si no estoy satisfecho con el servicio?', 'Contacta al soporte dentro de las 24 horas posteriores al servicio. Investigaremos el caso y aplicaremos nuestras políticas de garantía.', '9', '1', '2025-08-28 17:31:43');
INSERT INTO `faqs` VALUES ('10', '¿Cómo me registro como proveedor?', 'Ve a Configuración > Convertirme en Proveedor. Completa tu perfil profesional, sube tus documentos y espera nuestra aprobación.', '10', '1', '2025-08-28 17:31:43');
INSERT INTO `faqs` VALUES ('11', '¿Cómo registro mi servicio?', 'Para registrar tu servicio, inicia sesión y haz clic en \"Publicar Servicio\" en tu dashboard. Completa el formulario con los detalles de tu servicio.', '1', '1', '2026-01-31 21:35:05');
INSERT INTO `faqs` VALUES ('12', '¿Cómo puedo pagar por un servicio?', 'Aceptamos múltiples métodos de pago: efectivo, transferencia bancaria, Pago Móvil, PayPal y Zelle.', '2', '1', '2026-01-31 21:35:05');
INSERT INTO `faqs` VALUES ('13', '¿Qué hago si tengo un problema con un proveedor?', 'Puedes reportar el problema desde la sección de \"Mis Solicitudes\" o contactando a nuestro soporte.', '3', '1', '2026-01-31 21:35:05');
INSERT INTO `faqs` VALUES ('14', '¿Puedo cancelar un servicio contratado?', 'Sí, puedes cancelar siempre que el proveedor no haya iniciado el servicio. Consulta nuestros términos para más detalles.', '4', '1', '2026-01-31 21:35:05');

DROP TABLE IF EXISTS `jwt_tokens`;
CREATE TABLE `jwt_tokens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `token` text NOT NULL,
  `device_name` varchar(255) DEFAULT NULL,
  `device_id` varchar(255) DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `jwt_tokens_user_id_foreign` (`user_id`),
  KEY `jwt_tokens_token_index` (`token`(255)),
  CONSTRAINT `jwt_tokens_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


DROP TABLE IF EXISTS `login_attempts`;
CREATE TABLE `login_attempts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL,
  `ip_address` varchar(45) NOT NULL,
  `user_agent` text DEFAULT NULL,
  `success` tinyint(1) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_email` (`email`),
  KEY `idx_ip_address` (`ip_address`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_success` (`success`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;


DROP TABLE IF EXISTS `message_status`;
CREATE TABLE `message_status` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `message_id` bigint(20) NOT NULL,
  `user_id` int(11) NOT NULL,
  `user_type` enum('user','provider','admin','support') NOT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `is_read` tinyint(1) DEFAULT 0,
  `read_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `is_delivered` tinyint(1) DEFAULT 0,
  `delivered_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_message_user` (`message_id`,`user_id`,`user_type`),
  KEY `idx_message` (`message_id`),
  KEY `idx_user` (`user_id`,`user_type`),
  KEY `idx_deleted` (`is_deleted`),
  CONSTRAINT `message_status_ibfk_1` FOREIGN KEY (`message_id`) REFERENCES `messages` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=435 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `message_status` VALUES ('1', '1', '2', 'user', '0', '0', NULL, NULL, '2026-03-27 12:13:40', '1', '2026-03-27 16:13:40');
INSERT INTO `message_status` VALUES ('2', '1', '6', 'provider', '0', '1', '2026-03-27 12:14:51', NULL, '2026-03-27 12:13:40', '1', '2026-03-27 12:14:15');
INSERT INTO `message_status` VALUES ('3', '2', '6', 'provider', '0', '0', NULL, NULL, '2026-03-27 12:15:46', '1', '2026-03-27 16:15:46');
INSERT INTO `message_status` VALUES ('4', '2', '2', 'user', '0', '1', '2026-03-27 12:17:37', NULL, '2026-03-27 12:15:46', '1', '2026-03-27 12:16:51');
INSERT INTO `message_status` VALUES ('5', '3', '6', 'provider', '0', '0', NULL, NULL, '2026-03-27 12:16:31', '1', '2026-03-27 16:16:31');
INSERT INTO `message_status` VALUES ('6', '3', '2', 'user', '0', '1', '2026-03-27 12:17:37', NULL, '2026-03-27 12:16:31', '1', '2026-03-27 12:16:51');
INSERT INTO `message_status` VALUES ('7', '4', '2', 'user', '0', '0', NULL, NULL, '2026-03-27 12:18:15', '1', '2026-03-27 16:18:15');
INSERT INTO `message_status` VALUES ('8', '4', '6', 'provider', '0', '1', '2026-03-27 12:20:30', NULL, '2026-03-27 12:18:15', '1', '2026-03-27 12:20:13');
INSERT INTO `message_status` VALUES ('9', '5', '6', 'provider', '0', '0', NULL, NULL, '2026-03-27 12:19:18', '1', '2026-03-27 16:19:18');
INSERT INTO `message_status` VALUES ('10', '5', '2', 'user', '0', '1', '2026-03-27 12:21:56', NULL, '2026-03-27 12:19:18', '1', '2026-03-27 12:21:26');
INSERT INTO `message_status` VALUES ('11', '6', '2', 'user', '0', '0', NULL, NULL, '2026-03-27 12:19:22', '1', '2026-03-27 16:19:22');
INSERT INTO `message_status` VALUES ('12', '6', '6', 'provider', '0', '1', '2026-03-27 12:20:30', NULL, '2026-03-27 12:19:22', '1', '2026-03-27 12:20:13');
INSERT INTO `message_status` VALUES ('13', '7', '2', 'user', '0', '0', NULL, NULL, '2026-03-27 12:19:33', '1', '2026-03-27 16:19:33');
INSERT INTO `message_status` VALUES ('14', '7', '6', 'provider', '0', '1', '2026-03-27 12:20:30', NULL, '2026-03-27 12:19:33', '1', '2026-03-27 12:20:13');
INSERT INTO `message_status` VALUES ('15', '8', '2', 'user', '0', '0', NULL, NULL, '2026-03-27 12:19:45', '1', '2026-03-27 16:19:45');
INSERT INTO `message_status` VALUES ('16', '8', '6', 'provider', '0', '1', '2026-03-27 12:20:30', NULL, '2026-03-27 12:19:45', '1', '2026-03-27 12:20:13');
INSERT INTO `message_status` VALUES ('17', '9', '2', 'user', '0', '0', NULL, NULL, '2026-03-27 12:20:02', '1', '2026-03-27 16:20:02');
INSERT INTO `message_status` VALUES ('18', '9', '6', 'provider', '0', '1', '2026-03-27 12:20:30', NULL, '2026-03-27 12:20:02', '1', '2026-03-27 12:20:13');
INSERT INTO `message_status` VALUES ('19', '10', '2', 'user', '0', '0', NULL, NULL, '2026-03-27 12:22:09', '1', '2026-03-27 16:22:09');
INSERT INTO `message_status` VALUES ('20', '10', '6', 'provider', '0', '1', '2026-03-28 06:25:16', NULL, '2026-03-27 12:22:09', '1', '2026-03-27 12:22:40');
INSERT INTO `message_status` VALUES ('21', '11', '2', 'user', '0', '0', NULL, NULL, '2026-03-27 12:22:17', '1', '2026-03-27 16:22:17');
INSERT INTO `message_status` VALUES ('22', '11', '6', 'provider', '0', '1', '2026-03-28 06:25:16', NULL, '2026-03-27 12:22:17', '1', '2026-03-27 12:22:40');
INSERT INTO `message_status` VALUES ('23', '12', '2', 'user', '0', '0', NULL, NULL, '2026-03-28 01:11:37', '1', '2026-03-28 05:11:37');
INSERT INTO `message_status` VALUES ('24', '12', '6', 'provider', '0', '1', '2026-03-28 06:25:16', NULL, '2026-03-28 01:11:37', '1', '2026-03-28 06:25:00');
INSERT INTO `message_status` VALUES ('25', '13', '2', 'user', '0', '0', NULL, NULL, '2026-03-28 01:11:42', '1', '2026-03-28 05:11:42');
INSERT INTO `message_status` VALUES ('26', '13', '6', 'provider', '0', '1', '2026-03-28 06:25:16', NULL, '2026-03-28 01:11:42', '1', '2026-03-28 06:25:00');
INSERT INTO `message_status` VALUES ('27', '14', '2', 'user', '0', '0', NULL, NULL, '2026-03-28 01:11:52', '1', '2026-03-28 05:11:52');
INSERT INTO `message_status` VALUES ('28', '14', '6', 'provider', '0', '1', '2026-03-28 06:25:16', NULL, '2026-03-28 01:11:52', '1', '2026-03-28 06:25:00');
INSERT INTO `message_status` VALUES ('29', '15', '6', 'provider', '0', '0', NULL, NULL, '2026-03-28 06:25:54', '1', '2026-03-28 10:25:54');
INSERT INTO `message_status` VALUES ('30', '15', '2', 'user', '0', '1', '2026-03-28 06:40:32', NULL, '2026-03-28 06:25:54', '1', '2026-03-28 06:39:53');
INSERT INTO `message_status` VALUES ('31', '16', '6', 'provider', '0', '0', NULL, NULL, '2026-03-28 06:26:42', '1', '2026-03-28 10:26:42');
INSERT INTO `message_status` VALUES ('32', '16', '2', 'user', '0', '1', '2026-03-28 06:40:32', NULL, '2026-03-28 06:26:42', '1', '2026-03-28 06:39:53');
INSERT INTO `message_status` VALUES ('33', '17', '2', 'user', '0', '0', NULL, NULL, '2026-03-28 06:46:11', '1', '2026-03-28 10:46:11');
INSERT INTO `message_status` VALUES ('34', '17', '6', 'provider', '0', '1', '2026-03-28 06:46:49', NULL, '2026-03-28 06:46:11', '1', '2026-03-28 06:46:34');
INSERT INTO `message_status` VALUES ('35', '18', '2', 'user', '0', '0', NULL, NULL, '2026-03-28 06:46:17', '1', '2026-03-28 10:46:17');
INSERT INTO `message_status` VALUES ('36', '18', '6', 'provider', '0', '1', '2026-03-28 06:46:49', NULL, '2026-03-28 06:46:17', '1', '2026-03-28 06:46:34');
INSERT INTO `message_status` VALUES ('37', '19', '2', 'user', '0', '0', NULL, NULL, '2026-03-28 06:47:13', '1', '2026-03-28 10:47:13');
INSERT INTO `message_status` VALUES ('38', '19', '6', 'provider', '0', '1', '2026-03-29 12:03:39', NULL, '2026-03-28 06:47:13', '1', '2026-03-29 12:02:59');
INSERT INTO `message_status` VALUES ('39', '20', '2', 'user', '0', '0', NULL, NULL, '2026-03-28 06:47:49', '1', '2026-03-28 10:47:49');
INSERT INTO `message_status` VALUES ('40', '20', '6', 'provider', '0', '1', '2026-03-29 12:03:39', NULL, '2026-03-28 06:47:49', '1', '2026-03-29 12:02:59');
INSERT INTO `message_status` VALUES ('41', '21', '6', 'provider', '0', '0', NULL, NULL, '2026-03-29 12:04:02', '1', '2026-03-29 16:04:02');
INSERT INTO `message_status` VALUES ('42', '21', '2', 'user', '0', '1', '2026-03-29 23:47:34', NULL, '2026-03-29 12:04:02', '1', '2026-03-29 23:47:22');
INSERT INTO `message_status` VALUES ('43', '22', '2', 'user', '0', '0', NULL, NULL, '2026-03-29 12:04:11', '1', '2026-03-29 16:04:11');
INSERT INTO `message_status` VALUES ('44', '22', '6', 'provider', '0', '1', '2026-03-29 12:24:29', NULL, '2026-03-29 12:04:11', '1', '2026-03-29 12:06:34');
INSERT INTO `message_status` VALUES ('45', '23', '2', 'user', '0', '0', NULL, NULL, '2026-03-29 12:04:23', '1', '2026-03-29 16:04:23');
INSERT INTO `message_status` VALUES ('46', '23', '6', 'provider', '0', '1', '2026-03-29 12:24:29', NULL, '2026-03-29 12:04:23', '1', '2026-03-29 12:06:34');
INSERT INTO `message_status` VALUES ('47', '24', '6', 'provider', '0', '0', NULL, NULL, '2026-03-29 12:04:52', '1', '2026-03-29 16:04:52');
INSERT INTO `message_status` VALUES ('48', '24', '2', 'user', '0', '1', '2026-03-29 23:47:34', NULL, '2026-03-29 12:04:52', '1', '2026-03-29 23:47:22');
INSERT INTO `message_status` VALUES ('49', '25', '6', 'provider', '0', '0', NULL, NULL, '2026-03-29 12:05:14', '1', '2026-03-29 16:05:14');
INSERT INTO `message_status` VALUES ('50', '25', '2', 'user', '0', '1', '2026-03-29 23:47:34', NULL, '2026-03-29 12:05:14', '1', '2026-03-29 23:47:22');
INSERT INTO `message_status` VALUES ('51', '26', '6', 'provider', '0', '0', NULL, NULL, '2026-03-29 23:48:53', '1', '2026-03-29 23:56:17');
INSERT INTO `message_status` VALUES ('52', '26', '2', 'user', '0', '1', '2026-03-29 23:49:33', NULL, '2026-03-29 23:48:53', '1', '2026-03-29 23:49:12');
INSERT INTO `message_status` VALUES ('53', '27', '2', 'user', '0', '0', NULL, NULL, '2026-03-29 23:49:07', '1', '2026-03-29 23:49:12');
INSERT INTO `message_status` VALUES ('54', '27', '6', 'provider', '0', '1', '2026-03-29 23:56:34', NULL, '2026-03-29 23:49:07', '1', '2026-03-29 23:56:17');
INSERT INTO `message_status` VALUES ('55', '28', '6', 'provider', '0', '0', NULL, NULL, '2026-03-31 08:40:47', '1', '2026-03-31 08:41:33');
INSERT INTO `message_status` VALUES ('56', '28', '2', 'user', '0', '1', '2026-03-31 08:41:18', NULL, '2026-03-31 08:40:47', '1', '2026-03-31 08:40:58');
INSERT INTO `message_status` VALUES ('57', '29', '2', 'user', '0', '0', NULL, NULL, '2026-03-31 08:42:02', '1', '2026-03-31 08:42:28');
INSERT INTO `message_status` VALUES ('58', '29', '6', 'provider', '0', '1', '2026-03-31 10:43:36', NULL, '2026-03-31 08:42:02', '1', '2026-03-31 10:07:29');
INSERT INTO `message_status` VALUES ('59', '30', '6', 'provider', '0', '0', NULL, NULL, '2026-03-31 08:42:15', '1', '2026-03-31 10:07:29');
INSERT INTO `message_status` VALUES ('60', '30', '2', 'user', '0', '1', '2026-03-31 08:42:45', NULL, '2026-03-31 08:42:15', '1', '2026-03-31 08:42:28');
INSERT INTO `message_status` VALUES ('61', '31', '6', 'provider', '0', '0', NULL, NULL, '2026-03-31 10:43:55', '1', '2026-03-31 10:44:18');
INSERT INTO `message_status` VALUES ('62', '31', '2', 'user', '0', '1', '2026-03-31 10:45:09', NULL, '2026-03-31 10:43:55', '1', '2026-03-31 10:45:08');
INSERT INTO `message_status` VALUES ('63', '32', '6', 'provider', '0', '0', NULL, NULL, '2026-03-31 10:44:08', '1', '2026-03-31 10:44:18');
INSERT INTO `message_status` VALUES ('64', '32', '2', 'user', '0', '1', '2026-03-31 10:45:09', NULL, '2026-03-31 10:44:08', '1', '2026-03-31 10:45:08');
INSERT INTO `message_status` VALUES ('65', '33', '2', 'user', '0', '0', NULL, NULL, '2026-03-31 10:45:27', '1', '2026-03-31 11:49:20');
INSERT INTO `message_status` VALUES ('66', '33', '6', 'provider', '0', '1', '2026-03-31 11:48:31', NULL, '2026-03-31 10:45:27', '1', '2026-03-31 11:48:30');
INSERT INTO `message_status` VALUES ('67', '34', '6', 'provider', '0', '0', NULL, NULL, '2026-03-31 10:45:38', '1', '2026-03-31 11:48:30');
INSERT INTO `message_status` VALUES ('68', '34', '2', 'user', '0', '1', '2026-03-31 11:49:21', NULL, '2026-03-31 10:45:38', '1', '2026-03-31 11:49:20');
INSERT INTO `message_status` VALUES ('69', '35', '2', 'user', '0', '0', NULL, NULL, '2026-03-31 11:48:11', '1', '2026-03-31 11:49:20');
INSERT INTO `message_status` VALUES ('70', '35', '6', 'provider', '0', '1', '2026-03-31 11:48:31', NULL, '2026-03-31 11:48:11', '1', '2026-03-31 11:48:30');
INSERT INTO `message_status` VALUES ('71', '36', '2', 'user', '0', '0', NULL, NULL, '2026-03-31 11:48:44', '1', '2026-03-31 11:49:20');
INSERT INTO `message_status` VALUES ('72', '36', '6', 'provider', '0', '1', '2026-03-31 11:50:13', NULL, '2026-03-31 11:48:44', '1', '2026-03-31 11:50:12');
INSERT INTO `message_status` VALUES ('73', '37', '2', 'user', '0', '0', NULL, NULL, '2026-03-31 11:50:36', '1', '2026-03-31 11:50:42');
INSERT INTO `message_status` VALUES ('74', '37', '6', 'provider', '0', '1', '2026-03-31 15:33:33', NULL, '2026-03-31 11:50:36', '1', '2026-03-31 15:33:31');
INSERT INTO `message_status` VALUES ('75', '38', '2', 'user', '0', '0', NULL, NULL, '2026-03-31 15:33:45', '1', '2026-03-31 15:34:22');
INSERT INTO `message_status` VALUES ('76', '38', '6', 'provider', '0', '1', '2026-03-31 15:34:15', NULL, '2026-03-31 15:33:45', '1', '2026-03-31 15:34:14');
INSERT INTO `message_status` VALUES ('77', '39', '6', 'provider', '0', '0', NULL, NULL, '2026-03-31 15:34:02', '1', '2026-03-31 15:34:14');
INSERT INTO `message_status` VALUES ('78', '39', '2', 'user', '0', '1', '2026-03-31 15:34:23', NULL, '2026-03-31 15:34:02', '1', '2026-03-31 15:34:22');
INSERT INTO `message_status` VALUES ('79', '40', '6', 'provider', '0', '0', NULL, NULL, '2026-03-31 15:34:36', '1', '2026-03-31 20:01:42');
INSERT INTO `message_status` VALUES ('80', '40', '2', 'user', '0', '1', '2026-03-31 15:35:00', NULL, '2026-03-31 15:34:36', '1', '2026-03-31 15:34:59');
INSERT INTO `message_status` VALUES ('81', '41', '6', 'provider', '0', '0', NULL, NULL, '2026-03-31 20:01:52', '1', '2026-03-31 20:02:16');
INSERT INTO `message_status` VALUES ('82', '41', '2', 'user', '0', '1', '2026-03-31 20:02:33', NULL, '2026-03-31 20:01:52', '1', '2026-03-31 20:02:33');
INSERT INTO `message_status` VALUES ('83', '42', '2', 'user', '0', '0', NULL, NULL, '2026-03-31 20:02:10', '1', '2026-03-31 20:02:33');
INSERT INTO `message_status` VALUES ('84', '42', '6', 'provider', '0', '1', '2026-03-31 20:02:17', NULL, '2026-03-31 20:02:10', '1', '2026-03-31 20:02:16');
INSERT INTO `message_status` VALUES ('85', '43', '6', 'provider', '0', '0', NULL, NULL, '2026-03-31 20:02:41', '1', '2026-03-31 20:03:00');
INSERT INTO `message_status` VALUES ('86', '43', '2', 'user', '0', '1', '2026-03-31 20:04:29', NULL, '2026-03-31 20:02:41', '1', '2026-03-31 20:04:28');
INSERT INTO `message_status` VALUES ('87', '44', '2', 'user', '0', '0', NULL, NULL, '2026-03-31 20:02:51', '1', '2026-03-31 20:04:28');
INSERT INTO `message_status` VALUES ('88', '44', '6', 'provider', '0', '1', '2026-03-31 20:03:01', NULL, '2026-03-31 20:02:51', '1', '2026-03-31 20:03:00');
INSERT INTO `message_status` VALUES ('89', '45', '6', 'provider', '0', '0', NULL, NULL, '2026-03-31 20:06:15', '1', '2026-03-31 20:06:39');
INSERT INTO `message_status` VALUES ('90', '45', '2', 'user', '0', '1', '2026-03-31 20:06:46', NULL, '2026-03-31 20:06:15', '1', '2026-03-31 20:06:45');
INSERT INTO `message_status` VALUES ('91', '46', '2', 'user', '0', '0', NULL, NULL, '2026-03-31 20:06:27', '1', '2026-03-31 20:06:45');
INSERT INTO `message_status` VALUES ('92', '46', '6', 'provider', '0', '1', '2026-03-31 20:06:40', NULL, '2026-03-31 20:06:27', '1', '2026-03-31 20:06:39');
INSERT INTO `message_status` VALUES ('93', '47', '6', 'provider', '0', '0', NULL, NULL, '2026-03-31 20:38:17', '1', '2026-03-31 20:38:36');
INSERT INTO `message_status` VALUES ('94', '47', '2', 'user', '0', '1', '2026-03-31 20:38:41', NULL, '2026-03-31 20:38:17', '1', '2026-03-31 20:38:40');
INSERT INTO `message_status` VALUES ('95', '48', '2', 'user', '0', '0', NULL, NULL, '2026-03-31 20:38:28', '1', '2026-03-31 20:38:40');
INSERT INTO `message_status` VALUES ('96', '48', '6', 'provider', '0', '1', '2026-03-31 20:38:36', NULL, '2026-03-31 20:38:28', '1', '2026-03-31 20:38:36');
INSERT INTO `message_status` VALUES ('97', '49', '2', 'user', '0', '0', NULL, NULL, '2026-03-31 20:38:48', '1', '2026-03-31 22:20:16');
INSERT INTO `message_status` VALUES ('98', '49', '6', 'provider', '0', '1', '2026-03-31 22:20:39', NULL, '2026-03-31 20:38:48', '1', '2026-03-31 22:20:38');
INSERT INTO `message_status` VALUES ('99', '50', '6', 'provider', '0', '0', NULL, NULL, '2026-03-31 20:39:02', '1', '2026-03-31 22:20:38');
INSERT INTO `message_status` VALUES ('100', '50', '2', 'user', '0', '1', '2026-03-31 22:20:17', NULL, '2026-03-31 20:39:02', '1', '2026-03-31 22:20:16');
INSERT INTO `message_status` VALUES ('101', '51', '6', 'provider', '0', '0', NULL, NULL, '2026-03-31 22:21:05', '1', '2026-03-31 22:21:24');
INSERT INTO `message_status` VALUES ('102', '51', '2', 'user', '0', '1', '2026-03-31 22:21:33', NULL, '2026-03-31 22:21:05', '1', '2026-03-31 22:21:32');
INSERT INTO `message_status` VALUES ('103', '52', '2', 'user', '0', '0', NULL, NULL, '2026-03-31 22:21:17', '1', '2026-03-31 22:21:32');
INSERT INTO `message_status` VALUES ('104', '52', '6', 'provider', '0', '1', '2026-03-31 22:21:24', NULL, '2026-03-31 22:21:17', '1', '2026-03-31 22:21:24');
INSERT INTO `message_status` VALUES ('105', '53', '2', 'user', '0', '0', NULL, NULL, '2026-03-31 22:21:46', '1', '2026-04-01 00:36:40');
INSERT INTO `message_status` VALUES ('106', '53', '6', 'provider', '0', '1', '2026-04-01 00:39:54', NULL, '2026-03-31 22:21:46', '1', '2026-04-01 00:39:53');
INSERT INTO `message_status` VALUES ('107', '54', '6', 'provider', '0', '0', NULL, NULL, '2026-03-31 22:22:01', '1', '2026-04-01 00:39:53');
INSERT INTO `message_status` VALUES ('108', '54', '2', 'user', '0', '1', '2026-04-01 00:36:41', NULL, '2026-03-31 22:22:01', '1', '2026-04-01 00:36:40');
INSERT INTO `message_status` VALUES ('109', '55', '6', 'provider', '0', '0', NULL, NULL, '2026-04-01 00:40:19', '1', '2026-04-01 00:40:27');
INSERT INTO `message_status` VALUES ('110', '55', '2', 'user', '0', '1', '2026-04-01 00:40:41', NULL, '2026-04-01 00:40:19', '1', '2026-04-01 00:40:40');
INSERT INTO `message_status` VALUES ('111', '56', '6', 'provider', '0', '0', NULL, NULL, '2026-04-01 00:40:51', '1', '2026-04-01 01:01:31');
INSERT INTO `message_status` VALUES ('112', '56', '2', 'user', '0', '1', '2026-04-01 01:01:09', NULL, '2026-04-01 00:40:51', '1', '2026-04-01 01:01:07');
INSERT INTO `message_status` VALUES ('113', '57', '2', 'user', '0', '0', NULL, NULL, '2026-04-01 00:41:21', '1', '2026-04-01 01:01:07');
INSERT INTO `message_status` VALUES ('114', '57', '6', 'provider', '0', '1', '2026-04-01 01:01:32', NULL, '2026-04-01 00:41:21', '1', '2026-04-01 01:01:31');
INSERT INTO `message_status` VALUES ('115', '58', '6', 'provider', '0', '0', NULL, NULL, '2026-04-01 00:41:37', '1', '2026-04-01 01:01:31');
INSERT INTO `message_status` VALUES ('116', '58', '2', 'user', '0', '1', '2026-04-01 01:01:09', NULL, '2026-04-01 00:41:37', '1', '2026-04-01 01:01:07');
INSERT INTO `message_status` VALUES ('117', '59', '2', 'user', '0', '0', NULL, NULL, '2026-04-01 00:41:49', '1', '2026-04-01 01:01:07');
INSERT INTO `message_status` VALUES ('118', '59', '6', 'provider', '0', '1', '2026-04-01 01:01:32', NULL, '2026-04-01 00:41:49', '1', '2026-04-01 01:01:31');
INSERT INTO `message_status` VALUES ('119', '60', '6', 'provider', '0', '0', NULL, NULL, '2026-04-01 01:01:51', '1', '2026-04-01 01:05:59');
INSERT INTO `message_status` VALUES ('120', '60', '2', 'user', '0', '1', '2026-04-01 01:03:57', NULL, '2026-04-01 01:01:51', '1', '2026-04-01 01:03:56');
INSERT INTO `message_status` VALUES ('121', '61', '6', 'provider', '0', '0', NULL, NULL, '2026-04-01 01:02:05', '1', '2026-04-01 01:05:59');
INSERT INTO `message_status` VALUES ('122', '61', '2', 'user', '0', '1', '2026-04-01 01:03:57', NULL, '2026-04-01 01:02:05', '1', '2026-04-01 01:03:56');
INSERT INTO `message_status` VALUES ('123', '62', '6', 'provider', '0', '0', NULL, NULL, '2026-04-01 01:02:16', '1', '2026-04-01 01:05:59');
INSERT INTO `message_status` VALUES ('124', '62', '2', 'user', '0', '1', '2026-04-01 01:03:57', NULL, '2026-04-01 01:02:16', '1', '2026-04-01 01:03:56');
INSERT INTO `message_status` VALUES ('125', '63', '2', 'user', '0', '0', NULL, NULL, '2026-04-01 01:03:43', '1', '2026-04-01 01:03:56');
INSERT INTO `message_status` VALUES ('126', '63', '6', 'provider', '0', '1', '2026-04-01 01:06:00', NULL, '2026-04-01 01:03:43', '1', '2026-04-01 01:05:59');
INSERT INTO `message_status` VALUES ('127', '64', '6', 'provider', '0', '0', NULL, NULL, '2026-04-01 01:03:49', '1', '2026-04-01 01:05:59');
INSERT INTO `message_status` VALUES ('128', '64', '2', 'user', '0', '1', '2026-04-01 01:03:57', NULL, '2026-04-01 01:03:49', '1', '2026-04-01 01:03:56');
INSERT INTO `message_status` VALUES ('129', '65', '2', 'user', '0', '0', NULL, NULL, '2026-04-01 01:05:24', '1', '2026-04-01 01:05:46');
INSERT INTO `message_status` VALUES ('130', '65', '6', 'provider', '0', '1', '2026-04-01 01:06:00', NULL, '2026-04-01 01:05:24', '1', '2026-04-01 01:05:59');
INSERT INTO `message_status` VALUES ('131', '66', '6', 'provider', '0', '0', NULL, NULL, '2026-04-01 01:05:39', '1', '2026-04-01 01:05:59');
INSERT INTO `message_status` VALUES ('132', '66', '2', 'user', '0', '1', '2026-04-01 01:05:47', NULL, '2026-04-01 01:05:39', '1', '2026-04-01 01:05:46');
INSERT INTO `message_status` VALUES ('133', '67', '6', 'provider', '0', '0', NULL, NULL, '2026-04-01 01:07:56', '1', '2026-04-01 01:14:50');
INSERT INTO `message_status` VALUES ('134', '67', '2', 'user', '0', '1', '2026-04-01 01:14:28', NULL, '2026-04-01 01:07:56', '1', '2026-04-01 01:14:28');
INSERT INTO `message_status` VALUES ('135', '68', '6', 'provider', '0', '0', NULL, NULL, '2026-04-01 01:08:02', '1', '2026-04-01 01:14:50');
INSERT INTO `message_status` VALUES ('136', '68', '2', 'user', '0', '1', '2026-04-01 01:14:28', NULL, '2026-04-01 01:08:02', '1', '2026-04-01 01:14:28');
INSERT INTO `message_status` VALUES ('137', '69', '2', 'user', '0', '0', NULL, NULL, '2026-04-01 01:15:05', '1', '2026-04-01 01:15:29');
INSERT INTO `message_status` VALUES ('138', '69', '6', 'provider', '0', '1', '2026-04-01 01:15:24', NULL, '2026-04-01 01:15:05', '1', '2026-04-01 01:15:24');
INSERT INTO `message_status` VALUES ('139', '70', '6', 'provider', '0', '0', NULL, NULL, '2026-04-01 01:15:18', '1', '2026-04-01 01:15:24');
INSERT INTO `message_status` VALUES ('140', '70', '2', 'user', '0', '1', '2026-04-01 01:15:30', NULL, '2026-04-01 01:15:18', '1', '2026-04-01 01:15:29');
INSERT INTO `message_status` VALUES ('141', '71', '6', 'provider', '0', '0', NULL, NULL, '2026-04-01 01:16:46', '1', '2026-04-01 01:17:27');
INSERT INTO `message_status` VALUES ('142', '71', '2', 'user', '0', '1', '2026-04-01 01:44:26', NULL, '2026-04-01 01:16:46', '1', '2026-04-01 01:44:25');
INSERT INTO `message_status` VALUES ('143', '72', '6', 'provider', '0', '0', NULL, NULL, '2026-04-01 01:16:55', '1', '2026-04-01 01:17:27');
INSERT INTO `message_status` VALUES ('144', '72', '2', 'user', '0', '1', '2026-04-01 01:44:26', NULL, '2026-04-01 01:16:55', '1', '2026-04-01 01:44:25');
INSERT INTO `message_status` VALUES ('145', '73', '2', 'user', '0', '0', NULL, NULL, '2026-04-01 01:17:03', '1', '2026-04-01 01:44:25');
INSERT INTO `message_status` VALUES ('146', '73', '6', 'provider', '0', '1', '2026-04-01 01:17:28', NULL, '2026-04-01 01:17:03', '1', '2026-04-01 01:17:27');
INSERT INTO `message_status` VALUES ('147', '74', '2', 'user', '0', '0', NULL, NULL, '2026-04-01 01:17:18', '1', '2026-04-01 01:44:25');
INSERT INTO `message_status` VALUES ('148', '74', '6', 'provider', '0', '1', '2026-04-01 01:17:28', NULL, '2026-04-01 01:17:18', '1', '2026-04-01 01:17:27');
INSERT INTO `message_status` VALUES ('149', '75', '6', 'provider', '0', '0', NULL, NULL, '2026-04-01 01:17:45', '1', '2026-04-01 01:44:53');
INSERT INTO `message_status` VALUES ('150', '75', '2', 'user', '0', '1', '2026-04-01 01:44:26', NULL, '2026-04-01 01:17:45', '1', '2026-04-01 01:44:25');
INSERT INTO `message_status` VALUES ('151', '76', '2', 'user', '0', '0', NULL, NULL, '2026-04-01 01:17:57', '1', '2026-04-01 01:44:25');
INSERT INTO `message_status` VALUES ('152', '76', '6', 'provider', '0', '1', '2026-04-01 01:44:54', NULL, '2026-04-01 01:17:57', '1', '2026-04-01 01:44:53');
INSERT INTO `message_status` VALUES ('153', '77', '6', 'provider', '0', '0', NULL, NULL, '2026-04-01 01:45:05', '1', '2026-04-01 01:45:13');
INSERT INTO `message_status` VALUES ('154', '77', '2', 'user', '0', '1', '2026-04-02 07:43:32', NULL, '2026-04-01 01:45:05', '1', '2026-04-02 07:43:32');
INSERT INTO `message_status` VALUES ('155', '78', '6', 'provider', '0', '0', NULL, NULL, '2026-04-01 01:45:27', '1', '2026-04-02 07:57:59');
INSERT INTO `message_status` VALUES ('156', '78', '2', 'user', '0', '1', '2026-04-02 07:43:32', NULL, '2026-04-01 01:45:27', '1', '2026-04-02 07:43:32');
INSERT INTO `message_status` VALUES ('157', '79', '2', 'user', '0', '0', NULL, NULL, '2026-04-01 06:53:12', '1', '2026-04-02 07:43:32');
INSERT INTO `message_status` VALUES ('158', '79', '6', 'provider', '0', '1', '2026-04-02 07:58:02', NULL, '2026-04-01 06:53:12', '1', '2026-04-02 07:57:59');
INSERT INTO `message_status` VALUES ('159', '80', '2', 'user', '0', '0', NULL, NULL, '2026-04-01 06:53:18', '1', '2026-04-02 07:43:32');
INSERT INTO `message_status` VALUES ('160', '80', '6', 'provider', '0', '1', '2026-04-02 07:58:02', NULL, '2026-04-01 06:53:18', '1', '2026-04-02 07:57:59');
INSERT INTO `message_status` VALUES ('161', '81', '2', 'user', '0', '0', NULL, NULL, '2026-04-01 06:53:26', '1', '2026-04-02 07:43:32');
INSERT INTO `message_status` VALUES ('162', '81', '6', 'provider', '0', '1', '2026-04-02 07:58:02', NULL, '2026-04-01 06:53:26', '1', '2026-04-02 07:57:59');
INSERT INTO `message_status` VALUES ('163', '82', '2', 'user', '0', '0', NULL, NULL, '2026-04-01 06:53:32', '1', '2026-04-02 07:43:32');
INSERT INTO `message_status` VALUES ('164', '82', '6', 'provider', '0', '1', '2026-04-02 07:58:02', NULL, '2026-04-01 06:53:32', '1', '2026-04-02 07:57:59');
INSERT INTO `message_status` VALUES ('165', '83', '2', 'user', '0', '0', NULL, NULL, '2026-04-01 06:53:38', '1', '2026-04-02 07:43:32');
INSERT INTO `message_status` VALUES ('166', '83', '6', 'provider', '0', '1', '2026-04-02 07:58:02', NULL, '2026-04-01 06:53:38', '1', '2026-04-02 07:57:59');
INSERT INTO `message_status` VALUES ('167', '84', '2', 'user', '0', '0', NULL, NULL, '2026-04-02 07:43:47', '1', '2026-04-02 07:59:04');
INSERT INTO `message_status` VALUES ('168', '84', '6', 'provider', '0', '1', '2026-04-02 07:58:02', NULL, '2026-04-02 07:43:47', '1', '2026-04-02 07:57:59');
INSERT INTO `message_status` VALUES ('169', '85', '2', 'user', '0', '0', NULL, NULL, '2026-04-02 07:43:57', '1', '2026-04-02 07:59:04');
INSERT INTO `message_status` VALUES ('170', '85', '6', 'provider', '0', '1', '2026-04-02 07:58:02', NULL, '2026-04-02 07:43:57', '1', '2026-04-02 07:57:59');
INSERT INTO `message_status` VALUES ('171', '86', '6', 'provider', '0', '0', NULL, NULL, '2026-04-02 07:58:29', '1', '2026-04-02 08:01:45');
INSERT INTO `message_status` VALUES ('172', '86', '2', 'user', '0', '1', '2026-04-02 07:59:05', NULL, '2026-04-02 07:58:30', '1', '2026-04-02 07:59:04');
INSERT INTO `message_status` VALUES ('173', '87', '6', 'provider', '0', '0', NULL, NULL, '2026-04-02 07:59:31', '1', '2026-04-02 08:01:45');
INSERT INTO `message_status` VALUES ('174', '87', '2', 'user', '0', '1', '2026-04-02 08:01:30', NULL, '2026-04-02 07:59:31', '1', '2026-04-02 08:01:29');
INSERT INTO `message_status` VALUES ('175', '88', '2', 'user', '0', '0', NULL, NULL, '2026-04-02 07:59:52', '1', '2026-04-02 08:01:29');
INSERT INTO `message_status` VALUES ('176', '88', '6', 'provider', '0', '1', '2026-04-02 08:01:46', NULL, '2026-04-02 07:59:52', '1', '2026-04-02 08:01:45');
INSERT INTO `message_status` VALUES ('177', '89', '6', 'provider', '0', '0', NULL, NULL, '2026-04-02 08:01:59', '1', '2026-04-02 09:08:18');
INSERT INTO `message_status` VALUES ('178', '89', '2', 'user', '0', '1', '2026-04-02 09:07:50', NULL, '2026-04-02 08:01:59', '1', '2026-04-02 09:07:49');
INSERT INTO `message_status` VALUES ('179', '90', '2', 'user', '0', '0', NULL, NULL, '2026-04-02 09:07:58', '1', '2026-04-02 19:40:53');
INSERT INTO `message_status` VALUES ('180', '90', '6', 'provider', '0', '1', '2026-04-02 09:08:30', NULL, '2026-04-02 09:07:58', '1', '2026-04-02 09:08:18');
INSERT INTO `message_status` VALUES ('181', '91', '6', 'provider', '0', '0', NULL, NULL, '2026-04-02 09:08:40', '1', '2026-04-03 05:52:57');
INSERT INTO `message_status` VALUES ('182', '91', '2', 'user', '0', '1', '2026-04-02 19:40:54', NULL, '2026-04-02 09:08:40', '1', '2026-04-02 19:40:53');
INSERT INTO `message_status` VALUES ('183', '92', '2', 'user', '0', '0', NULL, NULL, '2026-04-02 19:41:02', '1', '2026-04-02 19:42:51');
INSERT INTO `message_status` VALUES ('184', '92', '6', 'provider', '0', '1', '2026-04-03 05:52:58', NULL, '2026-04-02 19:41:02', '1', '2026-04-03 05:52:57');
INSERT INTO `message_status` VALUES ('185', '93', '6', 'provider', '0', '0', NULL, NULL, '2026-04-03 05:53:09', '1', '2026-04-03 05:53:46');
INSERT INTO `message_status` VALUES ('186', '93', '2', 'user', '0', '1', '2026-04-03 05:53:56', NULL, '2026-04-03 05:53:09', '1', '2026-04-03 05:53:55');
INSERT INTO `message_status` VALUES ('187', '94', '2', 'user', '0', '0', NULL, NULL, '2026-04-03 05:53:27', '1', '2026-04-03 05:53:55');
INSERT INTO `message_status` VALUES ('188', '94', '6', 'provider', '0', '1', '2026-04-03 05:53:47', NULL, '2026-04-03 05:53:27', '1', '2026-04-03 05:53:46');
INSERT INTO `message_status` VALUES ('189', '95', '6', 'provider', '0', '0', NULL, NULL, '2026-04-03 05:55:32', '1', '2026-04-03 06:01:56');
INSERT INTO `message_status` VALUES ('190', '95', '2', 'user', '0', '1', '2026-04-03 06:01:41', NULL, '2026-04-03 05:55:32', '1', '2026-04-03 06:01:40');
INSERT INTO `message_status` VALUES ('191', '96', '6', 'provider', '0', '0', NULL, NULL, '2026-04-03 06:02:12', '1', '2026-04-06 16:09:11');
INSERT INTO `message_status` VALUES ('192', '96', '2', 'user', '0', '1', '2026-04-06 15:58:49', NULL, '2026-04-03 06:02:12', '1', '2026-04-06 15:58:48');
INSERT INTO `message_status` VALUES ('193', '97', '6', 'provider', '0', '0', NULL, NULL, '2026-04-03 06:02:26', '1', '2026-04-06 16:09:11');
INSERT INTO `message_status` VALUES ('194', '97', '2', 'user', '0', '1', '2026-04-06 15:58:49', NULL, '2026-04-03 06:02:26', '1', '2026-04-06 15:58:48');
INSERT INTO `message_status` VALUES ('195', '98', '6', 'provider', '0', '0', NULL, NULL, '2026-04-03 06:02:35', '1', '2026-04-06 16:09:11');
INSERT INTO `message_status` VALUES ('196', '98', '2', 'user', '0', '1', '2026-04-06 15:58:49', NULL, '2026-04-03 06:02:35', '1', '2026-04-06 15:58:48');
INSERT INTO `message_status` VALUES ('197', '99', '6', 'provider', '0', '0', NULL, NULL, '2026-04-03 06:02:45', '1', '2026-04-06 16:09:11');
INSERT INTO `message_status` VALUES ('198', '99', '2', 'user', '0', '1', '2026-04-06 15:58:49', NULL, '2026-04-03 06:02:45', '1', '2026-04-06 15:58:48');
INSERT INTO `message_status` VALUES ('199', '100', '6', 'provider', '0', '0', NULL, NULL, '2026-04-06 16:09:38', '1', '2026-04-06 18:50:36');
INSERT INTO `message_status` VALUES ('200', '100', '2', 'user', '0', '1', '2026-04-06 16:11:38', NULL, '2026-04-06 16:09:38', '1', '2026-04-06 16:11:38');
INSERT INTO `message_status` VALUES ('201', '101', '6', 'provider', '0', '0', NULL, NULL, '2026-04-06 16:09:52', '1', '2026-04-06 18:50:36');
INSERT INTO `message_status` VALUES ('202', '101', '2', 'user', '0', '1', '2026-04-06 16:11:38', NULL, '2026-04-06 16:09:52', '1', '2026-04-06 16:11:38');
INSERT INTO `message_status` VALUES ('203', '102', '2', 'user', '0', '0', NULL, NULL, '2026-04-06 16:10:04', '1', '2026-04-06 16:11:38');
INSERT INTO `message_status` VALUES ('204', '102', '6', 'provider', '0', '1', '2026-04-06 18:50:38', NULL, '2026-04-06 16:10:04', '1', '2026-04-06 18:50:36');
INSERT INTO `message_status` VALUES ('205', '103', '2', 'user', '0', '0', NULL, NULL, '2026-04-06 16:10:14', '1', '2026-04-06 16:11:38');
INSERT INTO `message_status` VALUES ('206', '103', '6', 'provider', '0', '1', '2026-04-06 18:50:38', NULL, '2026-04-06 16:10:14', '1', '2026-04-06 18:50:36');
INSERT INTO `message_status` VALUES ('207', '104', '6', 'provider', '0', '0', NULL, NULL, '2026-04-06 16:10:26', '1', '2026-04-06 18:50:36');
INSERT INTO `message_status` VALUES ('208', '104', '2', 'user', '0', '1', '2026-04-06 16:11:38', NULL, '2026-04-06 16:10:26', '1', '2026-04-06 16:11:38');
INSERT INTO `message_status` VALUES ('209', '105', '6', 'provider', '0', '0', NULL, NULL, '2026-04-06 16:11:00', '1', '2026-04-06 18:50:36');
INSERT INTO `message_status` VALUES ('210', '105', '2', 'user', '0', '1', '2026-04-06 16:11:38', NULL, '2026-04-06 16:11:00', '1', '2026-04-06 16:11:38');
INSERT INTO `message_status` VALUES ('211', '106', '6', 'provider', '0', '0', NULL, NULL, '2026-04-06 16:11:19', '1', '2026-04-06 18:50:36');
INSERT INTO `message_status` VALUES ('212', '106', '2', 'user', '0', '1', '2026-04-06 16:11:38', NULL, '2026-04-06 16:11:19', '1', '2026-04-06 16:11:38');
INSERT INTO `message_status` VALUES ('213', '107', '6', 'provider', '0', '0', NULL, NULL, '2026-04-06 16:11:50', '1', '2026-04-06 18:50:36');
INSERT INTO `message_status` VALUES ('214', '107', '2', 'user', '0', '1', '2026-04-06 16:12:30', NULL, '2026-04-06 16:11:50', '1', '2026-04-06 16:12:29');
INSERT INTO `message_status` VALUES ('215', '108', '6', 'provider', '0', '0', NULL, NULL, '2026-04-06 18:51:20', '1', '2026-04-06 18:51:40');
INSERT INTO `message_status` VALUES ('216', '108', '2', 'user', '0', '1', '2026-04-06 18:51:48', NULL, '2026-04-06 18:51:20', '1', '2026-04-06 18:51:47');
INSERT INTO `message_status` VALUES ('217', '109', '2', 'user', '0', '0', NULL, NULL, '2026-04-06 18:51:28', '1', '2026-04-06 18:51:47');
INSERT INTO `message_status` VALUES ('218', '109', '6', 'provider', '0', '1', '2026-04-06 18:51:42', NULL, '2026-04-06 18:51:28', '1', '2026-04-06 18:51:40');
INSERT INTO `message_status` VALUES ('219', '110', '2', 'user', '0', '0', NULL, NULL, '2026-04-06 18:51:57', '1', '2026-04-06 18:53:40');
INSERT INTO `message_status` VALUES ('220', '110', '6', 'provider', '0', '1', '2026-04-06 19:31:56', NULL, '2026-04-06 18:51:57', '1', '2026-04-06 19:31:54');
INSERT INTO `message_status` VALUES ('221', '111', '6', 'provider', '0', '0', NULL, NULL, '2026-04-06 18:52:05', '1', '2026-04-06 19:31:54');
INSERT INTO `message_status` VALUES ('222', '111', '2', 'user', '0', '1', '2026-04-06 18:53:41', NULL, '2026-04-06 18:52:05', '1', '2026-04-06 18:53:40');
INSERT INTO `message_status` VALUES ('223', '112', '6', 'provider', '0', '0', NULL, NULL, '2026-04-06 18:52:21', '1', '2026-04-06 19:31:54');
INSERT INTO `message_status` VALUES ('224', '112', '2', 'user', '0', '1', '2026-04-06 18:53:41', NULL, '2026-04-06 18:52:21', '1', '2026-04-06 18:53:40');
INSERT INTO `message_status` VALUES ('225', '113', '6', 'provider', '0', '0', NULL, NULL, '2026-04-06 18:53:17', '1', '2026-04-06 19:31:54');
INSERT INTO `message_status` VALUES ('226', '113', '2', 'user', '0', '1', '2026-04-06 18:53:41', NULL, '2026-04-06 18:53:17', '1', '2026-04-06 18:53:40');
INSERT INTO `message_status` VALUES ('227', '114', '6', 'provider', '0', '0', NULL, NULL, '2026-04-06 18:54:10', '1', '2026-04-06 19:31:54');
INSERT INTO `message_status` VALUES ('228', '114', '2', 'user', '0', '1', '2026-04-06 18:54:18', NULL, '2026-04-06 18:54:10', '1', '2026-04-06 18:54:17');
INSERT INTO `message_status` VALUES ('229', '115', '6', 'provider', '0', '0', NULL, NULL, '2026-04-06 19:32:04', '1', '2026-04-06 19:33:42');
INSERT INTO `message_status` VALUES ('230', '115', '2', 'user', '0', '1', '2026-04-06 19:33:16', NULL, '2026-04-06 19:32:04', '1', '2026-04-06 19:33:15');
INSERT INTO `message_status` VALUES ('231', '116', '2', 'user', '0', '0', NULL, NULL, '2026-04-06 19:32:12', '1', '2026-04-06 19:33:15');
INSERT INTO `message_status` VALUES ('232', '116', '6', 'provider', '0', '1', '2026-04-06 19:33:43', NULL, '2026-04-06 19:32:12', '1', '2026-04-06 19:33:42');
INSERT INTO `message_status` VALUES ('233', '117', '6', 'provider', '0', '0', NULL, NULL, '2026-04-06 19:32:24', '1', '2026-04-06 19:33:42');
INSERT INTO `message_status` VALUES ('234', '117', '2', 'user', '0', '1', '2026-04-06 19:33:16', NULL, '2026-04-06 19:32:24', '1', '2026-04-06 19:33:15');
INSERT INTO `message_status` VALUES ('235', '118', '2', 'user', '0', '0', NULL, NULL, '2026-04-06 19:32:31', '1', '2026-04-06 19:33:15');
INSERT INTO `message_status` VALUES ('236', '118', '6', 'provider', '0', '1', '2026-04-06 19:33:43', NULL, '2026-04-06 19:32:31', '1', '2026-04-06 19:33:42');
INSERT INTO `message_status` VALUES ('237', '119', '2', 'user', '0', '0', NULL, NULL, '2026-04-06 19:32:40', '1', '2026-04-06 19:33:15');
INSERT INTO `message_status` VALUES ('238', '119', '6', 'provider', '0', '1', '2026-04-06 19:33:43', NULL, '2026-04-06 19:32:40', '1', '2026-04-06 19:33:42');
INSERT INTO `message_status` VALUES ('239', '120', '6', 'provider', '0', '0', NULL, NULL, '2026-04-06 19:32:59', '1', '2026-04-06 19:33:42');
INSERT INTO `message_status` VALUES ('240', '120', '2', 'user', '0', '1', '2026-04-06 19:33:16', NULL, '2026-04-06 19:32:59', '1', '2026-04-06 19:33:15');
INSERT INTO `message_status` VALUES ('241', '121', '2', 'user', '0', '0', NULL, NULL, '2026-04-06 19:33:33', '1', '2026-04-06 19:51:44');
INSERT INTO `message_status` VALUES ('242', '121', '6', 'provider', '0', '1', '2026-04-06 19:33:43', NULL, '2026-04-06 19:33:33', '1', '2026-04-06 19:33:42');
INSERT INTO `message_status` VALUES ('243', '122', '2', 'user', '0', '0', NULL, NULL, '2026-04-06 19:33:49', '1', '2026-04-06 19:51:44');
INSERT INTO `message_status` VALUES ('244', '122', '6', 'provider', '0', '1', '2026-04-06 19:34:36', NULL, '2026-04-06 19:33:49', '1', '2026-04-06 19:34:35');
INSERT INTO `message_status` VALUES ('245', '123', '6', 'provider', '0', '0', NULL, NULL, '2026-04-06 19:34:01', '1', '2026-04-06 19:34:35');
INSERT INTO `message_status` VALUES ('246', '123', '2', 'user', '0', '1', '2026-04-06 19:51:45', NULL, '2026-04-06 19:34:01', '1', '2026-04-06 19:51:44');
INSERT INTO `message_status` VALUES ('247', '124', '2', 'user', '0', '0', NULL, NULL, '2026-04-06 19:34:20', '1', '2026-04-06 19:51:44');
INSERT INTO `message_status` VALUES ('248', '124', '6', 'provider', '0', '1', '2026-04-06 19:34:36', NULL, '2026-04-06 19:34:20', '1', '2026-04-06 19:34:35');
INSERT INTO `message_status` VALUES ('249', '125', '2', 'user', '0', '0', NULL, NULL, '2026-04-06 19:34:47', '1', '2026-04-06 19:51:44');
INSERT INTO `message_status` VALUES ('250', '125', '6', 'provider', '0', '1', '2026-04-06 19:35:02', NULL, '2026-04-06 19:34:47', '1', '2026-04-06 19:35:00');
INSERT INTO `message_status` VALUES ('251', '126', '2', 'user', '0', '0', NULL, NULL, '2026-04-06 19:35:48', '1', '2026-04-06 19:51:44');
INSERT INTO `message_status` VALUES ('252', '126', '6', 'provider', '0', '1', '2026-04-06 19:36:49', NULL, '2026-04-06 19:35:48', '1', '2026-04-06 19:36:48');
INSERT INTO `message_status` VALUES ('253', '127', '2', 'user', '0', '0', NULL, NULL, '2026-04-06 19:36:00', '1', '2026-04-06 19:51:44');
INSERT INTO `message_status` VALUES ('254', '127', '6', 'provider', '0', '1', '2026-04-06 19:36:49', NULL, '2026-04-06 19:36:00', '1', '2026-04-06 19:36:48');
INSERT INTO `message_status` VALUES ('255', '128', '2', 'user', '0', '0', NULL, NULL, '2026-04-07 06:42:42', '1', '2026-04-07 15:06:27');
INSERT INTO `message_status` VALUES ('256', '128', '6', 'provider', '0', '1', '2026-04-07 22:43:20', NULL, '2026-04-07 06:42:42', '1', '2026-04-07 22:43:19');
INSERT INTO `message_status` VALUES ('257', '129', '6', 'provider', '0', '0', NULL, NULL, '2026-04-07 22:43:38', '1', '2026-04-07 22:45:06');
INSERT INTO `message_status` VALUES ('258', '129', '2', 'user', '0', '1', '2026-04-07 22:44:42', NULL, '2026-04-07 22:43:38', '1', '2026-04-07 22:44:41');
INSERT INTO `message_status` VALUES ('259', '130', '6', 'provider', '0', '0', NULL, NULL, '2026-04-07 22:45:21', '1', '2026-04-07 22:46:04');
INSERT INTO `message_status` VALUES ('260', '130', '2', 'user', '0', '1', '2026-04-07 22:45:53', NULL, '2026-04-07 22:45:21', '1', '2026-04-07 22:45:52');
INSERT INTO `message_status` VALUES ('261', '131', '6', 'provider', '0', '0', NULL, NULL, '2026-04-07 22:45:31', '1', '2026-04-07 22:46:04');
INSERT INTO `message_status` VALUES ('262', '131', '2', 'user', '0', '1', '2026-04-07 22:45:53', NULL, '2026-04-07 22:45:31', '1', '2026-04-07 22:45:52');
INSERT INTO `message_status` VALUES ('263', '132', '2', 'user', '0', '0', NULL, NULL, '2026-04-07 22:45:43', '1', '2026-04-07 22:45:52');
INSERT INTO `message_status` VALUES ('264', '132', '6', 'provider', '0', '1', '2026-04-07 22:46:05', NULL, '2026-04-07 22:45:43', '1', '2026-04-07 22:46:04');
INSERT INTO `message_status` VALUES ('265', '133', '6', 'provider', '0', '0', NULL, NULL, '2026-04-07 22:46:14', '1', '2026-04-07 22:49:50');
INSERT INTO `message_status` VALUES ('266', '133', '2', 'user', '0', '1', '2026-04-07 22:50:25', NULL, '2026-04-07 22:46:14', '1', '2026-04-07 22:50:24');
INSERT INTO `message_status` VALUES ('267', '134', '2', 'user', '0', '0', NULL, NULL, '2026-04-07 22:46:22', '1', '2026-04-07 22:50:24');
INSERT INTO `message_status` VALUES ('268', '134', '6', 'provider', '0', '1', '2026-04-07 22:49:52', NULL, '2026-04-07 22:46:22', '1', '2026-04-07 22:49:50');
INSERT INTO `message_status` VALUES ('269', '135', '2', 'user', '0', '0', NULL, NULL, '2026-04-07 22:46:34', '1', '2026-04-07 22:50:24');
INSERT INTO `message_status` VALUES ('270', '135', '6', 'provider', '0', '1', '2026-04-07 22:49:52', NULL, '2026-04-07 22:46:34', '1', '2026-04-07 22:49:50');
INSERT INTO `message_status` VALUES ('271', '136', '6', 'provider', '0', '0', NULL, NULL, '2026-04-07 22:46:45', '1', '2026-04-07 22:49:50');
INSERT INTO `message_status` VALUES ('272', '136', '2', 'user', '0', '1', '2026-04-07 22:50:25', NULL, '2026-04-07 22:46:45', '1', '2026-04-07 22:50:24');
INSERT INTO `message_status` VALUES ('273', '137', '2', 'user', '0', '0', NULL, NULL, '2026-04-07 22:46:50', '1', '2026-04-07 22:50:24');
INSERT INTO `message_status` VALUES ('274', '137', '6', 'provider', '0', '1', '2026-04-07 22:49:52', NULL, '2026-04-07 22:46:50', '1', '2026-04-07 22:49:50');
INSERT INTO `message_status` VALUES ('275', '138', '2', 'user', '0', '0', NULL, NULL, '2026-04-07 22:47:03', '1', '2026-04-07 22:50:24');
INSERT INTO `message_status` VALUES ('276', '138', '6', 'provider', '0', '1', '2026-04-07 22:49:52', NULL, '2026-04-07 22:47:03', '1', '2026-04-07 22:49:50');
INSERT INTO `message_status` VALUES ('277', '139', '6', 'provider', '0', '0', NULL, NULL, '2026-04-07 22:47:15', '1', '2026-04-07 22:49:50');
INSERT INTO `message_status` VALUES ('278', '139', '2', 'user', '0', '1', '2026-04-07 22:50:25', NULL, '2026-04-07 22:47:15', '1', '2026-04-07 22:50:24');
INSERT INTO `message_status` VALUES ('279', '140', '6', 'provider', '0', '0', NULL, NULL, '2026-04-07 22:50:41', '1', '2026-04-07 22:54:40');
INSERT INTO `message_status` VALUES ('280', '140', '2', 'user', '0', '1', '2026-04-07 22:55:23', NULL, '2026-04-07 22:50:41', '1', '2026-04-07 22:55:22');
INSERT INTO `message_status` VALUES ('281', '141', '2', 'user', '0', '0', NULL, NULL, '2026-04-07 22:50:47', '1', '2026-04-07 22:55:22');
INSERT INTO `message_status` VALUES ('282', '141', '6', 'provider', '0', '1', '2026-04-07 22:54:42', NULL, '2026-04-07 22:50:47', '1', '2026-04-07 22:54:40');
INSERT INTO `message_status` VALUES ('283', '142', '2', 'user', '0', '0', NULL, NULL, '2026-04-07 22:50:57', '1', '2026-04-07 22:55:22');
INSERT INTO `message_status` VALUES ('284', '142', '6', 'provider', '0', '1', '2026-04-07 22:54:42', NULL, '2026-04-07 22:50:57', '1', '2026-04-07 22:54:40');
INSERT INTO `message_status` VALUES ('285', '143', '6', 'provider', '0', '0', NULL, NULL, '2026-04-07 22:51:06', '1', '2026-04-07 22:54:40');
INSERT INTO `message_status` VALUES ('286', '143', '2', 'user', '0', '1', '2026-04-07 22:55:23', NULL, '2026-04-07 22:51:06', '1', '2026-04-07 22:55:22');
INSERT INTO `message_status` VALUES ('287', '144', '6', 'provider', '0', '0', NULL, NULL, '2026-04-07 22:54:51', '1', '2026-04-07 22:55:41');
INSERT INTO `message_status` VALUES ('288', '144', '2', 'user', '0', '1', '2026-04-07 22:55:23', NULL, '2026-04-07 22:54:51', '1', '2026-04-07 22:55:22');
INSERT INTO `message_status` VALUES ('289', '145', '6', 'provider', '0', '0', NULL, NULL, '2026-04-07 22:55:00', '1', '2026-04-07 22:55:41');
INSERT INTO `message_status` VALUES ('290', '145', '2', 'user', '0', '1', '2026-04-07 22:55:23', NULL, '2026-04-07 22:55:00', '1', '2026-04-07 22:55:22');
INSERT INTO `message_status` VALUES ('291', '146', '2', 'user', '0', '0', NULL, NULL, '2026-04-07 22:55:07', '1', '2026-04-07 22:55:22');
INSERT INTO `message_status` VALUES ('292', '146', '6', 'provider', '0', '1', '2026-04-07 22:55:43', NULL, '2026-04-07 22:55:07', '1', '2026-04-07 22:55:41');
INSERT INTO `message_status` VALUES ('293', '147', '6', 'provider', '0', '0', NULL, NULL, '2026-04-07 23:44:04', '1', '2026-04-08 00:25:55');
INSERT INTO `message_status` VALUES ('294', '147', '2', 'user', '0', '1', '2026-04-08 00:25:24', NULL, '2026-04-07 23:44:04', '1', '2026-04-08 00:25:21');
INSERT INTO `message_status` VALUES ('295', '148', '2', 'user', '0', '0', NULL, NULL, '2026-04-07 23:44:31', '1', '2026-04-08 00:25:21');
INSERT INTO `message_status` VALUES ('296', '148', '6', 'provider', '0', '1', '2026-04-08 00:25:57', NULL, '2026-04-07 23:44:31', '1', '2026-04-08 00:25:55');
INSERT INTO `message_status` VALUES ('297', '149', '6', 'provider', '0', '0', NULL, NULL, '2026-04-08 00:26:44', '1', '2026-04-10 16:52:23');
INSERT INTO `message_status` VALUES ('298', '149', '2', 'user', '0', '1', '2026-04-10 16:09:49', NULL, '2026-04-08 00:26:44', '1', '2026-04-10 16:09:47');
INSERT INTO `message_status` VALUES ('299', '150', '2', 'user', '0', '0', NULL, NULL, '2026-04-08 00:26:57', '1', '2026-04-10 16:09:47');
INSERT INTO `message_status` VALUES ('300', '150', '6', 'provider', '0', '1', '2026-04-10 16:52:24', NULL, '2026-04-08 00:26:57', '1', '2026-04-10 16:52:23');
INSERT INTO `message_status` VALUES ('301', '151', '6', 'provider', '0', '0', NULL, NULL, '2026-04-08 00:27:21', '1', '2026-04-10 16:52:23');
INSERT INTO `message_status` VALUES ('302', '151', '2', 'user', '0', '1', '2026-04-10 16:09:49', NULL, '2026-04-08 00:27:21', '1', '2026-04-10 16:09:47');
INSERT INTO `message_status` VALUES ('303', '152', '2', 'user', '0', '0', NULL, NULL, '2026-04-08 00:27:30', '1', '2026-04-10 16:09:47');
INSERT INTO `message_status` VALUES ('304', '152', '6', 'provider', '0', '1', '2026-04-10 16:52:24', NULL, '2026-04-08 00:27:30', '1', '2026-04-10 16:52:23');
INSERT INTO `message_status` VALUES ('305', '153', '6', 'provider', '0', '0', NULL, NULL, '2026-04-08 00:27:42', '1', '2026-04-10 16:52:23');
INSERT INTO `message_status` VALUES ('306', '153', '2', 'user', '0', '1', '2026-04-10 16:09:49', NULL, '2026-04-08 00:27:42', '1', '2026-04-10 16:09:47');
INSERT INTO `message_status` VALUES ('307', '154', '2', 'user', '0', '0', NULL, NULL, '2026-04-08 00:27:51', '1', '2026-04-10 16:09:47');
INSERT INTO `message_status` VALUES ('308', '154', '6', 'provider', '0', '1', '2026-04-10 16:52:24', NULL, '2026-04-08 00:27:51', '1', '2026-04-10 16:52:23');
INSERT INTO `message_status` VALUES ('309', '155', '6', 'provider', '0', '0', NULL, NULL, '2026-04-08 00:27:59', '1', '2026-04-10 16:52:23');
INSERT INTO `message_status` VALUES ('310', '155', '2', 'user', '0', '1', '2026-04-10 16:09:49', NULL, '2026-04-08 00:27:59', '1', '2026-04-10 16:09:47');
INSERT INTO `message_status` VALUES ('311', '156', '2', 'user', '0', '0', NULL, NULL, '2026-04-08 00:28:06', '1', '2026-04-10 16:09:47');
INSERT INTO `message_status` VALUES ('312', '156', '6', 'provider', '0', '1', '2026-04-10 16:52:24', NULL, '2026-04-08 00:28:06', '1', '2026-04-10 16:52:23');
INSERT INTO `message_status` VALUES ('313', '157', '6', 'provider', '0', '0', NULL, NULL, '2026-04-08 00:29:30', '1', '2026-04-10 16:52:23');
INSERT INTO `message_status` VALUES ('314', '157', '2', 'user', '0', '1', '2026-04-10 16:09:49', NULL, '2026-04-08 00:29:30', '1', '2026-04-10 16:09:47');
INSERT INTO `message_status` VALUES ('315', '158', '2', 'user', '0', '0', NULL, NULL, '2026-04-08 00:29:37', '1', '2026-04-10 16:09:47');
INSERT INTO `message_status` VALUES ('316', '158', '6', 'provider', '0', '1', '2026-04-10 16:52:24', NULL, '2026-04-08 00:29:37', '1', '2026-04-10 16:52:23');
INSERT INTO `message_status` VALUES ('317', '159', '6', 'provider', '0', '0', NULL, NULL, '2026-04-08 00:29:47', '1', '2026-04-10 16:52:23');
INSERT INTO `message_status` VALUES ('318', '159', '2', 'user', '0', '1', '2026-04-10 16:09:49', NULL, '2026-04-08 00:29:47', '1', '2026-04-10 16:09:47');
INSERT INTO `message_status` VALUES ('319', '160', '2', 'user', '0', '0', NULL, NULL, '2026-04-08 00:29:54', '1', '2026-04-10 16:09:47');
INSERT INTO `message_status` VALUES ('320', '160', '6', 'provider', '0', '1', '2026-04-10 16:52:24', NULL, '2026-04-08 00:29:54', '1', '2026-04-10 16:52:23');
INSERT INTO `message_status` VALUES ('321', '161', '2', 'user', '0', '0', NULL, NULL, '2026-04-10 16:10:34', '1', '2026-04-11 13:10:58');
INSERT INTO `message_status` VALUES ('322', '161', '6', 'provider', '0', '1', '2026-04-10 16:52:24', NULL, '2026-04-10 16:10:34', '1', '2026-04-10 16:52:23');
INSERT INTO `message_status` VALUES ('323', '162', '2', 'user', '0', '0', NULL, NULL, '2026-04-10 16:52:40', '1', '2026-04-11 13:10:58');
INSERT INTO `message_status` VALUES ('324', '162', '6', 'provider', '0', '1', '2026-04-10 17:11:18', NULL, '2026-04-10 16:52:40', '1', '2026-04-10 17:11:08');
INSERT INTO `message_status` VALUES ('325', '163', '6', 'provider', '0', '0', NULL, NULL, '2026-04-10 16:52:54', '1', '2026-04-10 17:11:08');
INSERT INTO `message_status` VALUES ('326', '163', '2', 'user', '0', '1', '2026-04-11 13:11:00', NULL, '2026-04-10 16:52:54', '1', '2026-04-11 13:10:58');
INSERT INTO `message_status` VALUES ('327', '164', '2', 'user', '0', '0', NULL, NULL, '2026-04-10 16:53:21', '1', '2026-04-11 13:10:58');
INSERT INTO `message_status` VALUES ('328', '164', '6', 'provider', '0', '1', '2026-04-10 17:11:18', NULL, '2026-04-10 16:53:21', '1', '2026-04-10 17:11:08');
INSERT INTO `message_status` VALUES ('329', '165', '6', 'provider', '0', '0', NULL, NULL, '2026-04-10 16:53:34', '1', '2026-04-10 17:11:08');
INSERT INTO `message_status` VALUES ('330', '165', '2', 'user', '0', '1', '2026-04-11 13:11:00', NULL, '2026-04-10 16:53:34', '1', '2026-04-11 13:10:58');
INSERT INTO `message_status` VALUES ('331', '166', '2', 'user', '0', '0', NULL, NULL, '2026-04-10 16:53:48', '1', '2026-04-11 13:10:58');
INSERT INTO `message_status` VALUES ('332', '166', '6', 'provider', '0', '1', '2026-04-10 17:11:18', NULL, '2026-04-10 16:53:48', '1', '2026-04-10 17:11:08');
INSERT INTO `message_status` VALUES ('333', '167', '2', 'user', '0', '0', NULL, NULL, '2026-04-10 16:54:02', '1', '2026-04-11 13:10:58');
INSERT INTO `message_status` VALUES ('334', '167', '6', 'provider', '0', '1', '2026-04-10 17:11:18', NULL, '2026-04-10 16:54:02', '1', '2026-04-10 17:11:08');
INSERT INTO `message_status` VALUES ('335', '168', '6', 'provider', '0', '0', NULL, NULL, '2026-04-10 16:54:14', '1', '2026-04-10 17:11:08');
INSERT INTO `message_status` VALUES ('336', '168', '2', 'user', '0', '1', '2026-04-11 13:11:00', NULL, '2026-04-10 16:54:14', '1', '2026-04-11 13:10:58');
INSERT INTO `message_status` VALUES ('337', '169', '6', 'provider', '0', '0', NULL, NULL, '2026-04-10 16:54:22', '1', '2026-04-10 17:11:08');
INSERT INTO `message_status` VALUES ('338', '169', '2', 'user', '0', '1', '2026-04-11 13:11:00', NULL, '2026-04-10 16:54:22', '1', '2026-04-11 13:10:58');
INSERT INTO `message_status` VALUES ('339', '170', '6', 'provider', '0', '0', NULL, NULL, '2026-04-10 16:54:32', '1', '2026-04-10 17:11:08');
INSERT INTO `message_status` VALUES ('340', '170', '2', 'user', '0', '1', '2026-04-11 13:11:00', NULL, '2026-04-10 16:54:32', '1', '2026-04-11 13:10:58');
INSERT INTO `message_status` VALUES ('341', '171', '6', 'provider', '0', '0', NULL, NULL, '2026-04-10 16:54:43', '1', '2026-04-10 17:11:08');
INSERT INTO `message_status` VALUES ('342', '171', '2', 'user', '0', '1', '2026-04-11 13:11:00', NULL, '2026-04-10 16:54:43', '1', '2026-04-11 13:10:58');
INSERT INTO `message_status` VALUES ('343', '172', '6', 'provider', '0', '0', NULL, NULL, '2026-04-10 16:54:50', '1', '2026-04-10 17:11:08');
INSERT INTO `message_status` VALUES ('344', '172', '2', 'user', '0', '1', '2026-04-11 13:11:00', NULL, '2026-04-10 16:54:50', '1', '2026-04-11 13:10:58');
INSERT INTO `message_status` VALUES ('345', '173', '2', 'user', '0', '0', NULL, NULL, '2026-04-10 16:54:58', '1', '2026-04-11 13:10:58');
INSERT INTO `message_status` VALUES ('346', '173', '6', 'provider', '0', '1', '2026-04-10 17:11:18', NULL, '2026-04-10 16:54:58', '1', '2026-04-10 17:11:08');
INSERT INTO `message_status` VALUES ('347', '174', '2', 'user', '0', '0', NULL, NULL, '2026-04-10 16:55:06', '1', '2026-04-11 13:10:58');
INSERT INTO `message_status` VALUES ('348', '174', '6', 'provider', '0', '1', '2026-04-10 17:11:18', NULL, '2026-04-10 16:55:06', '1', '2026-04-10 17:11:08');
INSERT INTO `message_status` VALUES ('349', '175', '2', 'user', '0', '0', NULL, NULL, '2026-04-10 16:55:14', '1', '2026-04-11 13:10:58');
INSERT INTO `message_status` VALUES ('350', '175', '6', 'provider', '0', '1', '2026-04-10 17:11:18', NULL, '2026-04-10 16:55:14', '1', '2026-04-10 17:11:08');
INSERT INTO `message_status` VALUES ('351', '176', '2', 'user', '0', '0', NULL, NULL, '2026-04-10 16:55:24', '1', '2026-04-11 13:10:58');
INSERT INTO `message_status` VALUES ('352', '176', '6', 'provider', '0', '1', '2026-04-10 17:11:18', NULL, '2026-04-10 16:55:24', '1', '2026-04-10 17:11:08');
INSERT INTO `message_status` VALUES ('353', '177', '2', 'user', '0', '0', NULL, NULL, '2026-04-10 16:55:31', '1', '2026-04-11 13:10:58');
INSERT INTO `message_status` VALUES ('354', '177', '6', 'provider', '0', '1', '2026-04-10 17:11:18', NULL, '2026-04-10 16:55:31', '1', '2026-04-10 17:11:08');
INSERT INTO `message_status` VALUES ('355', '178', '2', 'user', '0', '0', NULL, NULL, '2026-04-10 16:55:41', '1', '2026-04-11 13:10:58');
INSERT INTO `message_status` VALUES ('356', '178', '6', 'provider', '0', '1', '2026-04-10 17:11:18', NULL, '2026-04-10 16:55:41', '1', '2026-04-10 17:11:08');
INSERT INTO `message_status` VALUES ('357', '179', '6', 'provider', '0', '0', NULL, NULL, '2026-04-10 16:55:48', '1', '2026-04-10 17:11:08');
INSERT INTO `message_status` VALUES ('358', '179', '2', 'user', '0', '1', '2026-04-11 13:11:00', NULL, '2026-04-10 16:55:48', '1', '2026-04-11 13:10:58');
INSERT INTO `message_status` VALUES ('359', '180', '6', 'provider', '0', '0', NULL, NULL, '2026-04-10 16:55:56', '1', '2026-04-10 17:11:08');
INSERT INTO `message_status` VALUES ('360', '180', '2', 'user', '0', '1', '2026-04-11 13:11:00', NULL, '2026-04-10 16:55:56', '1', '2026-04-11 13:10:58');
INSERT INTO `message_status` VALUES ('361', '181', '2', 'user', '0', '0', NULL, NULL, '2026-04-10 16:56:08', '1', '2026-04-11 13:10:58');
INSERT INTO `message_status` VALUES ('362', '181', '6', 'provider', '0', '1', '2026-04-10 17:11:18', NULL, '2026-04-10 16:56:08', '1', '2026-04-10 17:11:08');
INSERT INTO `message_status` VALUES ('363', '182', '6', 'provider', '0', '0', NULL, NULL, '2026-04-10 16:56:15', '1', '2026-04-10 17:11:08');
INSERT INTO `message_status` VALUES ('364', '182', '2', 'user', '0', '1', '2026-04-11 13:11:00', NULL, '2026-04-10 16:56:15', '1', '2026-04-11 13:10:58');
INSERT INTO `message_status` VALUES ('365', '183', '6', 'provider', '0', '0', NULL, NULL, '2026-04-11 13:26:09', '1', '2026-04-11 13:27:53');
INSERT INTO `message_status` VALUES ('366', '183', '2', 'user', '0', '1', '2026-04-11 13:27:50', NULL, '2026-04-11 13:26:09', '1', '2026-04-11 13:27:48');
INSERT INTO `message_status` VALUES ('367', '184', '2', 'user', '0', '0', NULL, NULL, '2026-04-11 13:26:28', '1', '2026-04-11 13:27:48');
INSERT INTO `message_status` VALUES ('368', '184', '6', 'provider', '0', '1', '2026-04-11 13:27:54', NULL, '2026-04-11 13:26:28', '1', '2026-04-11 13:27:53');
INSERT INTO `message_status` VALUES ('369', '185', '6', 'provider', '0', '0', NULL, NULL, '2026-04-11 13:26:38', '1', '2026-04-11 13:27:53');
INSERT INTO `message_status` VALUES ('370', '185', '2', 'user', '0', '1', '2026-04-11 13:27:50', NULL, '2026-04-11 13:26:38', '1', '2026-04-11 13:27:48');
INSERT INTO `message_status` VALUES ('371', '186', '2', 'user', '0', '0', NULL, NULL, '2026-04-11 13:26:46', '1', '2026-04-11 13:27:48');
INSERT INTO `message_status` VALUES ('372', '186', '6', 'provider', '0', '1', '2026-04-11 13:27:54', NULL, '2026-04-11 13:26:46', '1', '2026-04-11 13:27:53');
INSERT INTO `message_status` VALUES ('373', '187', '2', 'user', '0', '0', NULL, NULL, '2026-04-11 13:26:53', '1', '2026-04-11 13:27:48');
INSERT INTO `message_status` VALUES ('374', '187', '6', 'provider', '0', '1', '2026-04-11 13:27:54', NULL, '2026-04-11 13:26:53', '1', '2026-04-11 13:27:53');
INSERT INTO `message_status` VALUES ('375', '188', '2', 'user', '0', '0', NULL, NULL, '2026-04-11 13:27:00', '1', '2026-04-11 13:27:48');
INSERT INTO `message_status` VALUES ('376', '188', '6', 'provider', '0', '1', '2026-04-11 13:27:54', NULL, '2026-04-11 13:27:00', '1', '2026-04-11 13:27:53');
INSERT INTO `message_status` VALUES ('377', '189', '2', 'user', '0', '0', NULL, NULL, '2026-04-11 13:27:12', '1', '2026-04-11 13:27:48');
INSERT INTO `message_status` VALUES ('378', '189', '6', 'provider', '0', '1', '2026-04-11 13:27:54', NULL, '2026-04-11 13:27:12', '1', '2026-04-11 13:27:53');
INSERT INTO `message_status` VALUES ('379', '190', '6', 'provider', '0', '0', NULL, NULL, '2026-04-11 13:27:22', '1', '2026-04-11 13:27:53');
INSERT INTO `message_status` VALUES ('380', '190', '2', 'user', '0', '1', '2026-04-11 13:27:50', NULL, '2026-04-11 13:27:22', '1', '2026-04-11 13:27:48');
INSERT INTO `message_status` VALUES ('381', '191', '2', 'user', '0', '0', NULL, NULL, '2026-04-11 13:27:34', '1', '2026-04-11 13:27:48');
INSERT INTO `message_status` VALUES ('382', '191', '6', 'provider', '0', '1', '2026-04-11 13:27:54', NULL, '2026-04-11 13:27:34', '1', '2026-04-11 13:27:53');
INSERT INTO `message_status` VALUES ('383', '192', '6', 'provider', '0', '0', NULL, NULL, '2026-04-11 13:28:13', '1', '2026-04-11 13:28:55');
INSERT INTO `message_status` VALUES ('384', '192', '2', 'user', '0', '1', '2026-04-11 13:29:31', NULL, '2026-04-11 13:28:13', '1', '2026-04-11 13:29:30');
INSERT INTO `message_status` VALUES ('385', '193', '2', 'user', '0', '0', NULL, NULL, '2026-04-11 13:28:27', '1', '2026-04-11 13:29:30');
INSERT INTO `message_status` VALUES ('386', '193', '6', 'provider', '0', '1', '2026-04-11 13:28:56', NULL, '2026-04-11 13:28:27', '1', '2026-04-11 13:28:55');
INSERT INTO `message_status` VALUES ('387', '194', '2', 'user', '0', '0', NULL, NULL, '2026-04-11 13:29:14', '1', '2026-04-11 13:29:30');
INSERT INTO `message_status` VALUES ('388', '194', '6', 'provider', '0', '1', '2026-04-11 13:30:03', NULL, '2026-04-11 13:29:14', '1', '2026-04-11 13:30:01');
INSERT INTO `message_status` VALUES ('389', '195', '2', 'user', '0', '0', NULL, NULL, '2026-04-11 13:30:09', '1', '2026-04-26 18:21:23');
INSERT INTO `message_status` VALUES ('390', '195', '6', 'provider', '0', '1', '2026-04-11 13:34:08', NULL, '2026-04-11 13:30:09', '1', '2026-04-11 13:34:07');
INSERT INTO `message_status` VALUES ('391', '196', '6', 'provider', '0', '0', NULL, NULL, '2026-04-11 13:30:18', '1', '2026-04-11 13:34:07');
INSERT INTO `message_status` VALUES ('392', '196', '2', 'user', '0', '1', '2026-04-26 18:21:24', NULL, '2026-04-11 13:30:18', '1', '2026-04-26 18:21:23');
INSERT INTO `message_status` VALUES ('393', '197', '2', 'user', '0', '0', NULL, NULL, '2026-04-11 13:30:24', '1', '2026-04-26 18:21:23');
INSERT INTO `message_status` VALUES ('394', '197', '6', 'provider', '0', '1', '2026-04-11 13:34:08', NULL, '2026-04-11 13:30:24', '1', '2026-04-11 13:34:07');
INSERT INTO `message_status` VALUES ('395', '198', '6', 'provider', '0', '0', NULL, NULL, '2026-04-11 13:30:43', '1', '2026-04-11 13:34:07');
INSERT INTO `message_status` VALUES ('396', '198', '2', 'user', '0', '1', '2026-04-26 18:21:24', NULL, '2026-04-11 13:30:43', '1', '2026-04-26 18:21:23');
INSERT INTO `message_status` VALUES ('397', '199', '6', 'provider', '0', '0', NULL, NULL, '2026-04-11 13:30:54', '1', '2026-04-11 13:34:07');
INSERT INTO `message_status` VALUES ('398', '199', '2', 'user', '0', '1', '2026-04-26 18:21:24', NULL, '2026-04-11 13:30:54', '1', '2026-04-26 18:21:23');
INSERT INTO `message_status` VALUES ('399', '200', '6', 'provider', '0', '0', NULL, NULL, '2026-04-11 13:31:07', '1', '2026-04-11 13:34:07');
INSERT INTO `message_status` VALUES ('400', '200', '2', 'user', '0', '1', '2026-04-26 18:21:24', NULL, '2026-04-11 13:31:07', '1', '2026-04-26 18:21:23');
INSERT INTO `message_status` VALUES ('401', '201', '6', 'provider', '0', '0', NULL, NULL, '2026-04-11 13:31:19', '1', '2026-04-11 13:34:07');
INSERT INTO `message_status` VALUES ('402', '201', '2', 'user', '0', '1', '2026-04-26 18:21:24', NULL, '2026-04-11 13:31:19', '1', '2026-04-26 18:21:23');
INSERT INTO `message_status` VALUES ('403', '202', '6', 'provider', '0', '0', NULL, NULL, '2026-04-11 13:31:28', '1', '2026-04-11 13:34:07');
INSERT INTO `message_status` VALUES ('404', '202', '2', 'user', '0', '1', '2026-04-26 18:21:24', NULL, '2026-04-11 13:31:28', '1', '2026-04-26 18:21:23');
INSERT INTO `message_status` VALUES ('405', '203', '6', 'provider', '0', '0', NULL, NULL, '2026-04-11 13:31:41', '1', '2026-04-11 13:34:07');
INSERT INTO `message_status` VALUES ('406', '203', '2', 'user', '0', '1', '2026-04-26 18:21:24', NULL, '2026-04-11 13:31:41', '1', '2026-04-26 18:21:23');
INSERT INTO `message_status` VALUES ('407', '204', '6', 'provider', '0', '0', NULL, NULL, '2026-04-11 13:31:50', '1', '2026-04-11 13:34:07');
INSERT INTO `message_status` VALUES ('408', '204', '2', 'user', '0', '1', '2026-04-26 18:21:24', NULL, '2026-04-11 13:31:50', '1', '2026-04-26 18:21:23');
INSERT INTO `message_status` VALUES ('409', '205', '6', 'provider', '0', '0', NULL, NULL, '2026-04-11 13:32:06', '1', '2026-04-11 13:34:07');
INSERT INTO `message_status` VALUES ('410', '205', '2', 'user', '0', '1', '2026-04-26 18:21:24', NULL, '2026-04-11 13:32:06', '1', '2026-04-26 18:21:23');
INSERT INTO `message_status` VALUES ('411', '206', '2', 'user', '0', '0', NULL, NULL, '2026-04-11 13:32:17', '1', '2026-04-26 18:21:23');
INSERT INTO `message_status` VALUES ('412', '206', '6', 'provider', '0', '1', '2026-04-11 13:34:08', NULL, '2026-04-11 13:32:17', '1', '2026-04-11 13:34:07');
INSERT INTO `message_status` VALUES ('413', '207', '2', 'user', '0', '0', NULL, NULL, '2026-04-11 13:32:24', '1', '2026-04-26 18:21:23');
INSERT INTO `message_status` VALUES ('414', '207', '6', 'provider', '0', '1', '2026-04-11 13:34:08', NULL, '2026-04-11 13:32:24', '1', '2026-04-11 13:34:07');
INSERT INTO `message_status` VALUES ('415', '208', '2', 'user', '0', '0', NULL, NULL, '2026-04-11 13:32:32', '1', '2026-04-26 18:21:23');
INSERT INTO `message_status` VALUES ('416', '208', '6', 'provider', '0', '1', '2026-04-11 13:34:08', NULL, '2026-04-11 13:32:32', '1', '2026-04-11 13:34:07');
INSERT INTO `message_status` VALUES ('417', '209', '2', 'user', '0', '0', NULL, NULL, '2026-04-11 13:32:45', '1', '2026-04-26 18:21:23');
INSERT INTO `message_status` VALUES ('418', '209', '6', 'provider', '0', '1', '2026-04-11 13:34:08', NULL, '2026-04-11 13:32:45', '1', '2026-04-11 13:34:07');
INSERT INTO `message_status` VALUES ('419', '210', '2', 'user', '0', '0', NULL, NULL, '2026-04-11 13:32:53', '1', '2026-04-26 18:21:23');
INSERT INTO `message_status` VALUES ('420', '210', '6', 'provider', '0', '1', '2026-04-11 13:34:08', NULL, '2026-04-11 13:32:53', '1', '2026-04-11 13:34:07');
INSERT INTO `message_status` VALUES ('421', '211', '2', 'user', '0', '0', NULL, NULL, '2026-04-11 13:33:20', '1', '2026-04-26 18:21:23');
INSERT INTO `message_status` VALUES ('422', '211', '6', 'provider', '0', '1', '2026-04-11 13:34:08', NULL, '2026-04-11 13:33:20', '1', '2026-04-11 13:34:07');
INSERT INTO `message_status` VALUES ('423', '212', '2', 'user', '0', '0', NULL, NULL, '2026-04-11 13:33:31', '1', '2026-04-26 18:21:23');
INSERT INTO `message_status` VALUES ('424', '212', '6', 'provider', '0', '1', '2026-04-11 13:34:08', NULL, '2026-04-11 13:33:31', '1', '2026-04-11 13:34:07');
INSERT INTO `message_status` VALUES ('425', '213', '2', 'user', '0', '0', NULL, NULL, '2026-04-11 13:33:41', '1', '2026-04-26 18:21:23');
INSERT INTO `message_status` VALUES ('426', '213', '6', 'provider', '0', '1', '2026-04-11 13:34:08', NULL, '2026-04-11 13:33:41', '1', '2026-04-11 13:34:07');
INSERT INTO `message_status` VALUES ('427', '214', '2', 'user', '0', '0', NULL, NULL, '2026-04-11 13:33:49', '1', '2026-04-26 18:21:23');
INSERT INTO `message_status` VALUES ('428', '214', '6', 'provider', '0', '1', '2026-04-11 13:34:08', NULL, '2026-04-11 13:33:49', '1', '2026-04-11 13:34:07');
INSERT INTO `message_status` VALUES ('429', '215', '2', 'user', '0', '0', NULL, NULL, '2026-04-11 13:34:01', '1', '2026-04-26 18:21:23');
INSERT INTO `message_status` VALUES ('430', '215', '6', 'provider', '0', '1', '2026-04-11 13:34:08', NULL, '2026-04-11 13:34:01', '1', '2026-04-11 13:34:07');
INSERT INTO `message_status` VALUES ('431', '216', '2', 'user', '0', '0', NULL, NULL, '2026-04-11 13:34:17', '1', '2026-04-26 18:21:23');
INSERT INTO `message_status` VALUES ('432', '216', '6', 'provider', '0', '1', '2026-04-11 13:34:41', NULL, '2026-04-11 13:34:17', '1', '2026-04-11 13:34:39');
INSERT INTO `message_status` VALUES ('433', '217', '2', 'user', '0', '0', NULL, NULL, '2026-04-11 13:34:32', '1', '2026-04-26 18:21:23');
INSERT INTO `message_status` VALUES ('434', '217', '6', 'provider', '0', '1', '2026-04-11 13:34:41', NULL, '2026-04-11 13:34:32', '1', '2026-04-11 13:34:39');

DROP TABLE IF EXISTS `messages`;
CREATE TABLE `messages` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `conversation_id` bigint(20) unsigned DEFAULT NULL,
  `sender_id` int(11) NOT NULL,
  `receiver_id` int(11) NOT NULL,
  `text` text DEFAULT NULL,
  `type` enum('text','image','file','audio','video','system') DEFAULT 'text',
  `attachment_url` varchar(500) DEFAULT NULL,
  `status` enum('sent','delivered','read') DEFAULT 'sent',
  `parent_id` bigint(20) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `read_at` timestamp NULL DEFAULT NULL,
  `metadata` longtext DEFAULT NULL,
  `sender_type` enum('user','provider','admin') NOT NULL,
  `receiver_type` enum('user','provider','admin') NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_chat` (`sender_id`,`receiver_id`,`created_at`),
  KEY `idx_status` (`status`),
  KEY `conversation_id` (`conversation_id`),
  KEY `idx_conversation_id` (`conversation_id`),
  KEY `idx_sender_id` (`sender_id`),
  KEY `idx_receiver_id` (`receiver_id`),
  CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `messages_ibfk_2` FOREIGN KEY (`receiver_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=218 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `messages` VALUES ('1', '1', '2', '6', 'Hola cómo estás ?', 'text', NULL, 'sent', NULL, '2026-03-27 12:13:40', '2026-03-27 12:13:40', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('2', '1', '6', '2', 'Hola buen. Día', 'text', NULL, 'sent', NULL, '2026-03-27 12:15:46', '2026-03-27 12:15:46', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('3', '1', '6', '2', 'En qué puedo ayudarte', 'text', NULL, 'sent', NULL, '2026-03-27 12:16:31', '2026-03-27 12:16:31', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('4', '1', '2', '6', 'En nada', 'text', NULL, 'sent', NULL, '2026-03-27 12:18:15', '2026-03-27 12:18:15', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('5', '1', '6', '2', 'Holggg', 'text', NULL, 'sent', NULL, '2026-03-27 12:19:18', '2026-03-27 12:19:18', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('6', '1', '2', '6', 'Gsggf', 'text', NULL, 'sent', NULL, '2026-03-27 12:19:22', '2026-03-27 12:19:22', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('7', '1', '2', '6', '123456', 'text', NULL, 'sent', NULL, '2026-03-27 12:19:33', '2026-03-27 12:19:33', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('8', '1', '2', '6', 'Ggggg', 'text', NULL, 'sent', NULL, '2026-03-27 12:19:45', '2026-03-27 12:19:45', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('9', '1', '2', '6', 'Hhggg', 'text', NULL, 'sent', NULL, '2026-03-27 12:20:02', '2026-03-27 12:20:02', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('10', '1', '2', '6', 'Hols', 'text', NULL, 'sent', NULL, '2026-03-27 12:22:09', '2026-03-27 12:22:09', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('11', '1', '2', '6', 'Hplzkfkj', 'text', NULL, 'sent', NULL, '2026-03-27 12:22:17', '2026-03-27 12:22:17', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('12', '1', '2', '6', 'Holabd', 'text', NULL, 'sent', NULL, '2026-03-28 01:11:37', '2026-03-28 01:11:37', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('13', '1', '2', '6', 'Udkkddjfhf', 'text', NULL, 'sent', NULL, '2026-03-28 01:11:42', '2026-03-28 01:11:42', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('14', '1', '2', '6', 'Jsjdjfhfhffbrrbbrbrb', 'text', NULL, 'sent', NULL, '2026-03-28 01:11:52', '2026-03-28 01:11:52', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('15', '1', '6', '2', 'Hola prueba de error', 'text', NULL, 'sent', NULL, '2026-03-28 06:25:54', '2026-03-28 06:25:54', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('16', '1', '6', '2', 'Otra prueba', 'text', NULL, 'sent', NULL, '2026-03-28 06:26:42', '2026-03-28 06:26:42', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('17', '1', '2', '6', 'Hola', 'text', NULL, 'sent', NULL, '2026-03-28 06:46:11', '2026-03-28 06:46:11', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('18', '1', '2', '6', 'Hola', 'text', NULL, 'sent', NULL, '2026-03-28 06:46:17', '2026-03-28 06:46:17', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('19', '1', '2', '6', 'Ttttttt', 'text', NULL, 'sent', NULL, '2026-03-28 06:47:13', '2026-03-28 06:47:13', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('20', '1', '2', '6', 'Jkjjj', 'text', NULL, 'sent', NULL, '2026-03-28 06:47:49', '2026-03-28 06:47:49', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('21', '1', '6', '2', 'Hola', 'text', NULL, 'sent', NULL, '2026-03-29 12:04:02', '2026-03-29 12:04:02', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('22', '1', '2', '6', 'Holaas', 'text', NULL, 'sent', NULL, '2026-03-29 12:04:11', '2026-03-29 12:04:11', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('23', '1', '2', '6', 'Hola', 'text', NULL, 'sent', NULL, '2026-03-29 12:04:23', '2026-03-29 12:04:23', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('24', '1', '6', '2', 'Hora de 💧', 'text', NULL, 'sent', NULL, '2026-03-29 12:04:52', '2026-03-29 12:04:52', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('25', '1', '6', '2', 'Niños', 'text', NULL, 'sent', NULL, '2026-03-29 12:05:14', '2026-03-29 12:05:14', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('26', '1', '6', '2', 'Gato', 'text', NULL, 'sent', NULL, '2026-03-29 23:48:53', '2026-03-29 23:48:53', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('27', '1', '2', '6', 'Hpla', 'text', NULL, 'sent', NULL, '2026-03-29 23:49:07', '2026-03-29 23:49:07', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('28', '1', '6', '2', 'Holaasss', 'text', NULL, 'sent', NULL, '2026-03-31 08:40:47', '2026-03-31 08:40:47', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('29', '1', '2', '6', 'Holaaa', 'text', NULL, 'sent', NULL, '2026-03-31 08:42:02', '2026-03-31 08:42:02', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('30', '1', '6', '2', 'Holssssdvgr', 'text', NULL, 'sent', NULL, '2026-03-31 08:42:15', '2026-03-31 08:42:15', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('31', '1', '6', '2', 'Holaaas', 'text', NULL, 'sent', NULL, '2026-03-31 10:43:55', '2026-03-31 10:43:55', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('32', '1', '6', '2', 'Holaas', 'text', NULL, 'sent', NULL, '2026-03-31 10:44:08', '2026-03-31 10:44:08', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('33', '1', '2', '6', '😘😘😘😘😘😔😔', 'text', NULL, 'sent', NULL, '2026-03-31 10:45:27', '2026-03-31 10:45:27', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('34', '1', '6', '2', 'Jjjjjj', 'text', NULL, 'sent', NULL, '2026-03-31 10:45:38', '2026-03-31 10:45:38', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('35', '1', '2', '6', 'Kilo', 'text', NULL, 'sent', NULL, '2026-03-31 11:48:11', '2026-03-31 11:48:11', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('36', '1', '2', '6', 'Hola', 'text', NULL, 'sent', NULL, '2026-03-31 11:48:44', '2026-03-31 11:48:44', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('37', '1', '2', '6', 'Hola', 'text', NULL, 'sent', NULL, '2026-03-31 11:50:36', '2026-03-31 11:50:36', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('38', '1', '2', '6', 'Hol', 'text', NULL, 'sent', NULL, '2026-03-31 15:33:45', '2026-03-31 15:33:45', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('39', '1', '6', '2', 'Holaa', 'text', NULL, 'sent', NULL, '2026-03-31 15:34:02', '2026-03-31 15:34:02', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('40', '1', '6', '2', 'Tttttttt', 'text', NULL, 'sent', NULL, '2026-03-31 15:34:36', '2026-03-31 15:34:36', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('41', '1', '6', '2', 'Hola', 'text', NULL, 'sent', NULL, '2026-03-31 20:01:52', '2026-03-31 20:01:52', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('42', '1', '2', '6', 'Holaa', 'text', NULL, 'sent', NULL, '2026-03-31 20:02:10', '2026-03-31 20:02:10', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('43', '1', '6', '2', 'Gggghhh', 'text', NULL, 'sent', NULL, '2026-03-31 20:02:41', '2026-03-31 20:02:41', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('44', '1', '2', '6', 'Jjjjjjgh', 'text', NULL, 'sent', NULL, '2026-03-31 20:02:51', '2026-03-31 20:02:51', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('45', '1', '6', '2', 'Holaaa', 'text', NULL, 'sent', NULL, '2026-03-31 20:06:15', '2026-03-31 20:06:15', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('46', '1', '2', '6', 'Holass', 'text', NULL, 'sent', NULL, '2026-03-31 20:06:27', '2026-03-31 20:06:27', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('47', '1', '6', '2', 'Pendejo', 'text', NULL, 'sent', NULL, '2026-03-31 20:38:17', '2026-03-31 20:38:17', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('48', '1', '2', '6', 'Pendejo', 'text', NULL, 'sent', NULL, '2026-03-31 20:38:28', '2026-03-31 20:38:28', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('49', '1', '2', '6', 'Kkkkkkl', 'text', NULL, 'sent', NULL, '2026-03-31 20:38:48', '2026-03-31 20:38:48', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('50', '1', '6', '2', 'Hol', 'text', NULL, 'sent', NULL, '2026-03-31 20:39:02', '2026-03-31 20:39:02', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('51', '1', '6', '2', 'Hola prueba final', 'text', NULL, 'sent', NULL, '2026-03-31 22:21:05', '2026-03-31 22:21:05', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('52', '1', '2', '6', 'Hola 😘👋🏾', 'text', NULL, 'sent', NULL, '2026-03-31 22:21:17', '2026-03-31 22:21:17', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('53', '1', '2', '6', 'Robbin', 'text', NULL, 'sent', NULL, '2026-03-31 22:21:46', '2026-03-31 22:21:46', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('54', '1', '6', '2', 'Lo necesito', 'text', NULL, 'sent', NULL, '2026-03-31 22:22:01', '2026-03-31 22:22:01', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('55', '1', '6', '2', 'Holass', 'text', NULL, 'sent', NULL, '2026-04-01 00:40:19', '2026-04-01 00:40:19', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('56', '1', '6', '2', 'Jate', 'text', NULL, 'sent', NULL, '2026-04-01 00:40:51', '2026-04-01 00:40:51', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('57', '1', '2', '6', 'Juejua', 'text', NULL, 'sent', NULL, '2026-04-01 00:41:21', '2026-04-01 00:41:21', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('58', '1', '6', '2', 'Pendejo', 'text', NULL, 'sent', NULL, '2026-04-01 00:41:37', '2026-04-01 00:41:37', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('59', '1', '2', '6', 'Pendejo', 'text', NULL, 'sent', NULL, '2026-04-01 00:41:49', '2026-04-01 00:41:49', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('60', '1', '6', '2', 'Terminect', 'text', NULL, 'sent', NULL, '2026-04-01 01:01:51', '2026-04-01 01:01:51', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('61', '1', '6', '2', 'Hola', 'text', NULL, 'sent', NULL, '2026-04-01 01:02:05', '2026-04-01 01:02:05', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('62', '1', '6', '2', 'Uuuu', 'text', NULL, 'sent', NULL, '2026-04-01 01:02:16', '2026-04-01 01:02:16', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('63', '1', '2', '6', 'Holssss', 'text', NULL, 'sent', NULL, '2026-04-01 01:03:43', '2026-04-01 01:03:43', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('64', '1', '6', '2', 'Holxdf', 'text', NULL, 'sent', NULL, '2026-04-01 01:03:49', '2026-04-01 01:03:49', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('65', '1', '2', '6', 'Holaas', 'text', NULL, 'sent', NULL, '2026-04-01 01:05:24', '2026-04-01 01:05:24', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('66', '1', '6', '2', 'Honhhj', 'text', NULL, 'sent', NULL, '2026-04-01 01:05:39', '2026-04-01 01:05:39', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('67', '1', '6', '2', 'Jjj', 'text', NULL, 'sent', NULL, '2026-04-01 01:07:56', '2026-04-01 01:07:56', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('68', '1', '6', '2', 'Uuuu', 'text', NULL, 'sent', NULL, '2026-04-01 01:08:02', '2026-04-01 01:08:02', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('69', '1', '2', '6', 'Holass', 'text', NULL, 'sent', NULL, '2026-04-01 01:15:05', '2026-04-01 01:15:05', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('70', '1', '6', '2', 'Holbfg', 'text', NULL, 'sent', NULL, '2026-04-01 01:15:18', '2026-04-01 01:15:18', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('71', '1', '6', '2', 'Majestad', 'text', NULL, 'sent', NULL, '2026-04-01 01:16:46', '2026-04-01 01:16:46', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('72', '1', '6', '2', 'Jjjjj', 'text', NULL, 'sent', NULL, '2026-04-01 01:16:55', '2026-04-01 01:16:55', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('73', '1', '2', '6', 'Jujggh', 'text', NULL, 'sent', NULL, '2026-04-01 01:17:03', '2026-04-01 01:17:03', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('74', '1', '2', '6', 'Yyyyyyrvcdf', 'text', NULL, 'sent', NULL, '2026-04-01 01:17:18', '2026-04-01 01:17:18', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('75', '1', '6', '2', 'Kjjjhh', 'text', NULL, 'sent', NULL, '2026-04-01 01:17:45', '2026-04-01 01:17:45', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('76', '1', '2', '6', 'Jshdhdhhfdbev', 'text', NULL, 'sent', NULL, '2026-04-01 01:17:57', '2026-04-01 01:17:57', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('77', '1', '6', '2', 'Hola', 'text', NULL, 'sent', NULL, '2026-04-01 01:45:05', '2026-04-01 01:45:05', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('78', '1', '6', '2', 'Hola', 'text', NULL, 'sent', NULL, '2026-04-01 01:45:27', '2026-04-01 01:45:27', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('79', '1', '2', '6', 'Hola', 'text', NULL, 'sent', NULL, '2026-04-01 06:53:12', '2026-04-01 06:53:12', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('80', '1', '2', '6', 'Hola', 'text', NULL, 'sent', NULL, '2026-04-01 06:53:18', '2026-04-01 06:53:18', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('81', '1', '2', '6', 'Holahoa', 'text', NULL, 'sent', NULL, '2026-04-01 06:53:26', '2026-04-01 06:53:26', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('82', '1', '2', '6', 'Hola', 'text', NULL, 'sent', NULL, '2026-04-01 06:53:32', '2026-04-01 06:53:32', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('83', '1', '2', '6', 'Hola', 'text', NULL, 'sent', NULL, '2026-04-01 06:53:38', '2026-04-01 06:53:38', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('84', '1', '2', '6', 'Holaaa', 'text', NULL, 'sent', NULL, '2026-04-02 07:43:47', '2026-04-02 07:43:47', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('85', '1', '2', '6', 'Hollhgggg', 'text', NULL, 'sent', NULL, '2026-04-02 07:43:57', '2026-04-02 07:43:57', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('86', '1', '6', '2', 'Holaas', 'text', NULL, 'sent', NULL, '2026-04-02 07:58:29', '2026-04-02 07:58:29', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('87', '1', '6', '2', 'Holaaas', 'text', NULL, 'sent', NULL, '2026-04-02 07:59:31', '2026-04-02 07:59:31', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('88', '1', '2', '6', 'Hkfkdjfjfjfbf', 'text', NULL, 'sent', NULL, '2026-04-02 07:59:52', '2026-04-02 07:59:52', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('89', '1', '6', '2', 'Ghluggjyt', 'text', NULL, 'sent', NULL, '2026-04-02 08:01:59', '2026-04-02 08:01:59', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('90', '1', '2', '6', 'Holaaaa', 'text', NULL, 'sent', NULL, '2026-04-02 09:07:58', '2026-04-02 09:07:58', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('91', '1', '6', '2', 'Gfxffh', 'text', NULL, 'sent', NULL, '2026-04-02 09:08:40', '2026-04-02 09:08:40', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('92', '1', '2', '6', 'Holaas', 'text', NULL, 'sent', NULL, '2026-04-02 19:41:02', '2026-04-02 19:41:02', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('93', '1', '6', '2', 'Yyyyyyyyyyy', 'text', NULL, 'sent', NULL, '2026-04-03 05:53:09', '2026-04-03 05:53:09', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('94', '1', '2', '6', 'Hjjhhhhh', 'text', NULL, 'sent', NULL, '2026-04-03 05:53:27', '2026-04-03 05:53:27', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('95', '1', '6', '2', 'Holjhgh', 'text', NULL, 'sent', NULL, '2026-04-03 05:55:32', '2026-04-03 05:55:32', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('96', '1', '6', '2', 'Gatoooo', 'text', NULL, 'sent', NULL, '2026-04-03 06:02:12', '2026-04-03 06:02:12', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('97', '1', '6', '2', 'Endejooo', 'text', NULL, 'sent', NULL, '2026-04-03 06:02:26', '2026-04-03 06:02:26', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('98', '1', '6', '2', 'Ooooii', 'text', NULL, 'sent', NULL, '2026-04-03 06:02:35', '2026-04-03 06:02:35', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('99', '1', '6', '2', 'Jjjjhhg', 'text', NULL, 'sent', NULL, '2026-04-03 06:02:45', '2026-04-03 06:02:45', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('100', '1', '6', '2', 'Holyhxbdjffjfjfjjfjf', 'text', NULL, 'sent', NULL, '2026-04-06 16:09:38', '2026-04-06 16:09:38', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('101', '1', '6', '2', 'Holdndjdjfjffj', 'text', NULL, 'sent', NULL, '2026-04-06 16:09:52', '2026-04-06 16:09:52', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('102', '1', '2', '6', 'Hghhhhghh', 'text', NULL, 'sent', NULL, '2026-04-06 16:10:04', '2026-04-06 16:10:04', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('103', '1', '2', '6', 'Holasggg', 'text', NULL, 'sent', NULL, '2026-04-06 16:10:14', '2026-04-06 16:10:14', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('104', '1', '6', '2', 'Kqqwwqqqqqqqqqqqq', 'text', NULL, 'sent', NULL, '2026-04-06 16:10:26', '2026-04-06 16:10:26', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('105', '1', '6', '2', 'Hola', 'text', NULL, 'sent', NULL, '2026-04-06 16:11:00', '2026-04-06 16:11:00', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('106', '1', '6', '2', 'Holaaaaaa', 'text', NULL, 'sent', NULL, '2026-04-06 16:11:19', '2026-04-06 16:11:19', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('107', '1', '6', '2', 'Jjjjj', 'text', NULL, 'sent', NULL, '2026-04-06 16:11:50', '2026-04-06 16:11:50', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('108', '1', '6', '2', 'Hag', 'text', NULL, 'sent', NULL, '2026-04-06 18:51:20', '2026-04-06 18:51:20', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('109', '1', '2', '6', 'Ooooooooo', 'text', NULL, 'sent', NULL, '2026-04-06 18:51:28', '2026-04-06 18:51:28', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('110', '1', '2', '6', 'Kkkkkkm', 'text', NULL, 'sent', NULL, '2026-04-06 18:51:57', '2026-04-06 18:51:57', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('111', '1', '6', '2', 'Jhhhhhh', 'text', NULL, 'sent', NULL, '2026-04-06 18:52:05', '2026-04-06 18:52:05', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('112', '1', '6', '2', 'Yyyyly', 'text', NULL, 'sent', NULL, '2026-04-06 18:52:21', '2026-04-06 18:52:21', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('113', '1', '6', '2', 'Gggggh', 'text', NULL, 'sent', NULL, '2026-04-06 18:53:17', '2026-04-06 18:53:17', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('114', '1', '6', '2', 'Hhhhgf', 'text', NULL, 'sent', NULL, '2026-04-06 18:54:10', '2026-04-06 18:54:10', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('115', '1', '6', '2', 'Hhhhhhh', 'text', NULL, 'sent', NULL, '2026-04-06 19:32:04', '2026-04-06 19:32:04', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('116', '1', '2', '6', 'Hhjjjjj', 'text', NULL, 'sent', NULL, '2026-04-06 19:32:12', '2026-04-06 19:32:12', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('117', '1', '6', '2', 'Bhhhhh', 'text', NULL, 'sent', NULL, '2026-04-06 19:32:24', '2026-04-06 19:32:24', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('118', '1', '2', '6', 'Oooooooooooooo', 'text', NULL, 'sent', NULL, '2026-04-06 19:32:31', '2026-04-06 19:32:31', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('119', '1', '2', '6', 'Jjjjjjh', 'text', NULL, 'sent', NULL, '2026-04-06 19:32:40', '2026-04-06 19:32:40', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('120', '1', '6', '2', 'Yyyyyyyy', 'text', NULL, 'sent', NULL, '2026-04-06 19:32:59', '2026-04-06 19:32:59', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('121', '1', '2', '6', 'Hhhol', 'text', NULL, 'sent', NULL, '2026-04-06 19:33:33', '2026-04-06 19:33:33', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('122', '1', '2', '6', 'Iiiii', 'text', NULL, 'sent', NULL, '2026-04-06 19:33:49', '2026-04-06 19:33:49', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('123', '1', '6', '2', 'Uuuuuu', 'text', NULL, 'sent', NULL, '2026-04-06 19:34:01', '2026-04-06 19:34:01', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('124', '1', '2', '6', 'Oopopo', 'text', NULL, 'sent', NULL, '2026-04-06 19:34:20', '2026-04-06 19:34:20', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('125', '1', '2', '6', 'Uujkhhh', 'text', NULL, 'sent', NULL, '2026-04-06 19:34:47', '2026-04-06 19:34:47', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('126', '1', '2', '6', 'Oooooo', 'text', NULL, 'sent', NULL, '2026-04-06 19:35:48', '2026-04-06 19:35:48', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('127', '1', '2', '6', 'Ooooo', 'text', NULL, 'sent', NULL, '2026-04-06 19:36:00', '2026-04-06 19:36:00', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('128', '1', '2', '6', 'Hola', 'text', NULL, 'sent', NULL, '2026-04-07 06:42:42', '2026-04-07 06:42:42', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('129', '1', '6', '2', 'Hhhjhhgghg', 'text', NULL, 'sent', NULL, '2026-04-07 22:43:38', '2026-04-07 22:43:38', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('130', '1', '6', '2', 'Holjgggtttt', 'text', NULL, 'sent', NULL, '2026-04-07 22:45:21', '2026-04-07 22:45:21', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('131', '1', '6', '2', 'Jesus', 'text', NULL, 'sent', NULL, '2026-04-07 22:45:31', '2026-04-07 22:45:31', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('132', '1', '2', '6', 'Que pasó vivi', 'text', NULL, 'sent', NULL, '2026-04-07 22:45:43', '2026-04-07 22:45:43', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('133', '1', '6', '2', 'Ffff', 'text', NULL, 'sent', NULL, '2026-04-07 22:46:14', '2026-04-07 22:46:14', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('134', '1', '2', '6', 'Olol', 'text', NULL, 'sent', NULL, '2026-04-07 22:46:22', '2026-04-07 22:46:22', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('135', '1', '2', '6', 'Hey', 'text', NULL, 'sent', NULL, '2026-04-07 22:46:34', '2026-04-07 22:46:34', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('136', '1', '6', '2', 'Hlsgg', 'text', NULL, 'sent', NULL, '2026-04-07 22:46:45', '2026-04-07 22:46:45', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('137', '1', '2', '6', 'Kkkkk', 'text', NULL, 'sent', NULL, '2026-04-07 22:46:50', '2026-04-07 22:46:50', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('138', '1', '2', '6', 'Llllll', 'text', NULL, 'sent', NULL, '2026-04-07 22:47:03', '2026-04-07 22:47:03', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('139', '1', '6', '2', 'Jjjjj', 'text', NULL, 'sent', NULL, '2026-04-07 22:47:15', '2026-04-07 22:47:15', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('140', '1', '6', '2', 'Holass', 'text', NULL, 'sent', NULL, '2026-04-07 22:50:41', '2026-04-07 22:50:41', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('141', '1', '2', '6', 'Llllll', 'text', NULL, 'sent', NULL, '2026-04-07 22:50:47', '2026-04-07 22:50:47', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('142', '1', '2', '6', 'Llloplpoo', 'text', NULL, 'sent', NULL, '2026-04-07 22:50:57', '2026-04-07 22:50:57', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('143', '1', '6', '2', 'Holjgggf', 'text', NULL, 'sent', NULL, '2026-04-07 22:51:06', '2026-04-07 22:51:06', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('144', '1', '6', '2', 'Hhjhgfggg', 'text', NULL, 'sent', NULL, '2026-04-07 22:54:51', '2026-04-07 22:54:51', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('145', '1', '6', '2', 'Jjjjfhhtt', 'text', NULL, 'sent', NULL, '2026-04-07 22:55:00', '2026-04-07 22:55:00', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('146', '1', '2', '6', 'Jjghjhhh', 'text', NULL, 'sent', NULL, '2026-04-07 22:55:07', '2026-04-07 22:55:07', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('147', '1', '6', '2', 'Holjhh😒😒😒👺👺👺👺👺', 'text', NULL, 'sent', NULL, '2026-04-07 23:44:04', '2026-04-07 23:44:04', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('148', '1', '2', '6', 'Jlkknnbnnlk💘💘💘💘💘💘💘', 'text', NULL, 'sent', NULL, '2026-04-07 23:44:31', '2026-04-07 23:44:31', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('149', '1', '6', '2', 'Holfggfghgxc😍🎂🎂😍🎂', 'text', NULL, 'sent', NULL, '2026-04-08 00:26:44', '2026-04-08 00:26:44', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('150', '1', '2', '6', '❤️🐊🐊❤️❤️🐊❤️', 'text', NULL, 'sent', NULL, '2026-04-08 00:26:57', '2026-04-08 00:26:57', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('151', '1', '6', '2', 'Hobfjghhffv', 'text', NULL, 'sent', NULL, '2026-04-08 00:27:21', '2026-04-08 00:27:21', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('152', '1', '2', '6', 'Holavfbvdbvg', 'text', NULL, 'sent', NULL, '2026-04-08 00:27:30', '2026-04-08 00:27:30', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('153', '1', '6', '2', 'Gbgjhfbgg', 'text', NULL, 'sent', NULL, '2026-04-08 00:27:42', '2026-04-08 00:27:42', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('154', '1', '2', '6', 'Hljkhgnhv', 'text', NULL, 'sent', NULL, '2026-04-08 00:27:51', '2026-04-08 00:27:51', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('155', '1', '6', '2', 'Yuyghgrgt', 'text', NULL, 'sent', NULL, '2026-04-08 00:27:59', '2026-04-08 00:27:59', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('156', '1', '2', '6', 'Hkjgbbdhhrrfv', 'text', NULL, 'sent', NULL, '2026-04-08 00:28:06', '2026-04-08 00:28:06', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('157', '1', '6', '2', 'Gjgxjuuuuuu', 'text', NULL, 'sent', NULL, '2026-04-08 00:29:30', '2026-04-08 00:29:30', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('158', '1', '2', '6', 'Uyghgfhhh', 'text', NULL, 'sent', NULL, '2026-04-08 00:29:37', '2026-04-08 00:29:37', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('159', '1', '6', '2', 'Hkjhgbvg', 'text', NULL, 'sent', NULL, '2026-04-08 00:29:47', '2026-04-08 00:29:47', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('160', '1', '2', '6', 'Kkhkncb', 'text', NULL, 'sent', NULL, '2026-04-08 00:29:54', '2026-04-08 00:29:54', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('161', '1', '2', '6', 'Holaa', 'text', NULL, 'sent', NULL, '2026-04-10 16:10:34', '2026-04-10 16:10:34', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('162', '1', '2', '6', 'Holaas', 'text', NULL, 'sent', NULL, '2026-04-10 16:52:40', '2026-04-10 16:52:40', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('163', '1', '6', '2', 'Holassss', 'text', NULL, 'sent', NULL, '2026-04-10 16:52:54', '2026-04-10 16:52:54', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('164', '1', '2', '6', 'Ggtkhfbgrkkkk', 'text', NULL, 'sent', NULL, '2026-04-10 16:53:21', '2026-04-10 16:53:21', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('165', '1', '6', '2', 'Yyyuuu', 'text', NULL, 'sent', NULL, '2026-04-10 16:53:34', '2026-04-10 16:53:34', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('166', '1', '2', '6', 'Tuyhfggd😍😍😍😍😍', 'text', NULL, 'sent', NULL, '2026-04-10 16:53:48', '2026-04-10 16:53:48', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('167', '1', '2', '6', 'Oooooohc😡😡😡😡', 'text', NULL, 'sent', NULL, '2026-04-10 16:54:02', '2026-04-10 16:54:02', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('168', '1', '6', '2', 'Llljj', 'text', NULL, 'sent', NULL, '2026-04-10 16:54:14', '2026-04-10 16:54:14', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('169', '1', '6', '2', 'Oooyhhg', 'text', NULL, 'sent', NULL, '2026-04-10 16:54:22', '2026-04-10 16:54:22', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('170', '1', '6', '2', 'Kkhhhcvv', 'text', NULL, 'sent', NULL, '2026-04-10 16:54:32', '2026-04-10 16:54:32', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('171', '1', '6', '2', 'Hhgggcvv', 'text', NULL, 'sent', NULL, '2026-04-10 16:54:43', '2026-04-10 16:54:43', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('172', '1', '6', '2', 'Khjhcc v', 'text', NULL, 'sent', NULL, '2026-04-10 16:54:50', '2026-04-10 16:54:50', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('173', '1', '2', '6', 'Hkhgghff', 'text', NULL, 'sent', NULL, '2026-04-10 16:54:58', '2026-04-10 16:54:58', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('174', '1', '2', '6', 'Jjjjj', 'text', NULL, 'sent', NULL, '2026-04-10 16:55:06', '2026-04-10 16:55:06', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('175', '1', '2', '6', 'Jjjjjggff', 'text', NULL, 'sent', NULL, '2026-04-10 16:55:14', '2026-04-10 16:55:14', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('176', '1', '2', '6', 'Hhgggg', 'text', NULL, 'sent', NULL, '2026-04-10 16:55:24', '2026-04-10 16:55:24', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('177', '1', '2', '6', 'Hhgggg', 'text', NULL, 'sent', NULL, '2026-04-10 16:55:31', '2026-04-10 16:55:31', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('178', '1', '2', '6', 'Hhggggg', 'text', NULL, 'sent', NULL, '2026-04-10 16:55:41', '2026-04-10 16:55:41', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('179', '1', '6', '2', 'Nmjhhjh', 'text', NULL, 'sent', NULL, '2026-04-10 16:55:48', '2026-04-10 16:55:48', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('180', '1', '6', '2', 'Kkhvcv', 'text', NULL, 'sent', NULL, '2026-04-10 16:55:56', '2026-04-10 16:55:56', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('181', '1', '2', '6', 'Jhhfchgf', 'text', NULL, 'sent', NULL, '2026-04-10 16:56:08', '2026-04-10 16:56:08', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('182', '1', '6', '2', 'Kkkkvcvhgh', 'text', NULL, 'sent', NULL, '2026-04-10 16:56:15', '2026-04-10 16:56:15', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('183', '1', '6', '2', 'Holaass', 'text', NULL, 'sent', NULL, '2026-04-11 13:26:09', '2026-04-11 13:26:09', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('184', '1', '2', '6', 'Holsssss', 'text', NULL, 'sent', NULL, '2026-04-11 13:26:28', '2026-04-11 13:26:28', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('185', '1', '6', '2', 'Holass', 'text', NULL, 'sent', NULL, '2026-04-11 13:26:38', '2026-04-11 13:26:38', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('186', '1', '2', '6', 'Holaasssss', 'text', NULL, 'sent', NULL, '2026-04-11 13:26:46', '2026-04-11 13:26:46', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('187', '1', '2', '6', 'Hhhhhh', 'text', NULL, 'sent', NULL, '2026-04-11 13:26:53', '2026-04-11 13:26:53', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('188', '1', '2', '6', 'Iiiiiiiytty', 'text', NULL, 'sent', NULL, '2026-04-11 13:27:00', '2026-04-11 13:27:00', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('189', '1', '2', '6', 'Uututhjgg', 'text', NULL, 'sent', NULL, '2026-04-11 13:27:12', '2026-04-11 13:27:12', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('190', '1', '6', '2', 'Tjgtuytgguh', 'text', NULL, 'sent', NULL, '2026-04-11 13:27:22', '2026-04-11 13:27:22', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('191', '1', '2', '6', 'Gato', 'text', NULL, 'sent', NULL, '2026-04-11 13:27:34', '2026-04-11 13:27:34', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('192', '1', '6', '2', '👺👺👺👺👺👺👺', 'text', NULL, 'sent', NULL, '2026-04-11 13:28:13', '2026-04-11 13:28:13', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('193', '1', '2', '6', '🌎🌎🌎🌎🌎', 'text', NULL, 'sent', NULL, '2026-04-11 13:28:27', '2026-04-11 13:28:27', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('194', '1', '2', '6', 'J👌🏾👌🏾👌🏾👌🏾👌🏾👌🏾👌🏾👌🏾', 'text', NULL, 'sent', NULL, '2026-04-11 13:29:14', '2026-04-11 13:29:14', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('195', '1', '2', '6', 'Uuyjhh', 'text', NULL, 'sent', NULL, '2026-04-11 13:30:09', '2026-04-11 13:30:09', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('196', '1', '6', '2', 'Yyyyyyf', 'text', NULL, 'sent', NULL, '2026-04-11 13:30:18', '2026-04-11 13:30:18', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('197', '1', '2', '6', 'Jhjgcg', 'text', NULL, 'sent', NULL, '2026-04-11 13:30:24', '2026-04-11 13:30:24', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('198', '1', '6', '2', 'Ygdgghgf', 'text', NULL, 'sent', NULL, '2026-04-11 13:30:43', '2026-04-11 13:30:43', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('199', '1', '6', '2', 'Ttttttttt', 'text', NULL, 'sent', NULL, '2026-04-11 13:30:54', '2026-04-11 13:30:54', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('200', '1', '6', '2', 'Uyjtgcdgffxvv', 'text', NULL, 'sent', NULL, '2026-04-11 13:31:07', '2026-04-11 13:31:07', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('201', '1', '6', '2', 'Hoolss', 'text', NULL, 'sent', NULL, '2026-04-11 13:31:19', '2026-04-11 13:31:19', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('202', '1', '6', '2', 'Jjffggfdc', 'text', NULL, 'sent', NULL, '2026-04-11 13:31:28', '2026-04-11 13:31:28', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('203', '1', '6', '2', 'Kkjjhggvgf', 'text', NULL, 'sent', NULL, '2026-04-11 13:31:41', '2026-04-11 13:31:41', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('204', '1', '6', '2', 'Iolpiugfrcf', 'text', NULL, 'sent', NULL, '2026-04-11 13:31:50', '2026-04-11 13:31:50', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('205', '1', '6', '2', 'Hggthgrrth', 'text', NULL, 'sent', NULL, '2026-04-11 13:32:06', '2026-04-11 13:32:06', NULL, NULL, 'provider', 'user');
INSERT INTO `messages` VALUES ('206', '1', '2', '6', 'Hjhggcvbh', 'text', NULL, 'sent', NULL, '2026-04-11 13:32:17', '2026-04-11 13:32:17', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('207', '1', '2', '6', 'Ljkuhvv', 'text', NULL, 'sent', NULL, '2026-04-11 13:32:24', '2026-04-11 13:32:24', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('208', '1', '2', '6', 'Jjghjhhh', 'text', NULL, 'sent', NULL, '2026-04-11 13:32:32', '2026-04-11 13:32:32', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('209', '1', '2', '6', 'Hkjggjhff', 'text', NULL, 'sent', NULL, '2026-04-11 13:32:45', '2026-04-11 13:32:45', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('210', '1', '2', '6', 'Ujhggvgg', 'text', NULL, 'sent', NULL, '2026-04-11 13:32:53', '2026-04-11 13:32:53', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('211', '1', '2', '6', 'Holdjhdfh', 'text', NULL, 'sent', NULL, '2026-04-11 13:33:20', '2026-04-11 13:33:20', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('212', '1', '2', '6', 'Hok', 'text', NULL, 'sent', NULL, '2026-04-11 13:33:31', '2026-04-11 13:33:31', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('213', '1', '2', '6', 'Hjfofbfbfbfb', 'text', NULL, 'sent', NULL, '2026-04-11 13:33:41', '2026-04-11 13:33:41', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('214', '1', '2', '6', 'Hdkdodfjfjf', 'text', NULL, 'sent', NULL, '2026-04-11 13:33:49', '2026-04-11 13:33:49', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('215', '1', '2', '6', 'Jdjdhhdyfhdh', 'text', NULL, 'sent', NULL, '2026-04-11 13:34:01', '2026-04-11 13:34:01', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('216', '1', '2', '6', 'Hgdjdhh', 'text', NULL, 'sent', NULL, '2026-04-11 13:34:17', '2026-04-11 13:34:17', NULL, NULL, 'user', 'provider');
INSERT INTO `messages` VALUES ('217', '1', '2', '6', 'Holsjsdhdhf', 'text', NULL, 'sent', NULL, '2026-04-11 13:34:32', '2026-04-11 13:34:32', NULL, NULL, 'user', 'provider');

DROP TABLE IF EXISTS `notifications`;
CREATE TABLE `notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sender_id` int(11) DEFAULT NULL,
  `receiver_id` int(11) DEFAULT NULL,
  `receiver_role` enum('user','provider','admin') NOT NULL,
  `title` varchar(100) DEFAULT NULL,
  `message` text DEFAULT NULL,
  `data_json` text DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=138 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

INSERT INTO `notifications` VALUES ('1', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-04 11:05:15');
INSERT INTO `notifications` VALUES ('2', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-04 11:08:44');
INSERT INTO `notifications` VALUES ('3', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-04 11:10:53');
INSERT INTO `notifications` VALUES ('4', '6', '2', 'user', 'Solicitud aceptada', 'Tu solicitud fue aceptada por el proveedor', '{\"url\":\"\\/service\\/10\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":10}', '1', '2026-05-04 11:11:05');
INSERT INTO `notifications` VALUES ('5', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-04 11:12:35');
INSERT INTO `notifications` VALUES ('6', '6', '2', 'user', 'Proveedor ocupado', 'El proveedor está ocupado temporalmente', '{\"url\":\"\\/requests\",\"action\":\"view_request\",\"notification_type\":\"general\"}', '1', '2026-05-04 11:12:50');
INSERT INTO `notifications` VALUES ('7', '6', '2', 'user', 'Proveedor ocupado', 'El proveedor está ocupado temporalmente', '{\"url\":\"\\/requests\",\"action\":\"view_request\",\"notification_type\":\"general\"}', '1', '2026-05-04 11:12:50');
INSERT INTO `notifications` VALUES ('8', '6', '2', 'user', 'Solicitud aceptada', 'Tu solicitud fue aceptada por el proveedor', '{\"url\":\"\\/service\\/12\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":12}', '1', '2026-05-04 11:12:52');
INSERT INTO `notifications` VALUES ('9', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-04 11:17:17');
INSERT INTO `notifications` VALUES ('10', '2', '6', 'provider', 'Pago registrado', 'El cliente pagará en efectivo', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"default\",\"notification_type\":\"general\",\"request_id\":\"25\"}', '1', '2026-05-04 23:01:05');
INSERT INTO `notifications` VALUES ('11', '2', '6', 'provider', 'Pago registrado', 'Cliente subió comprobante – verifica el pago', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"default\",\"notification_type\":\"general\",\"request_id\":\"24\"}', '1', '2026-05-04 23:02:22');
INSERT INTO `notifications` VALUES ('12', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-07 00:35:17');
INSERT INTO `notifications` VALUES ('13', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-10 06:11:34');
INSERT INTO `notifications` VALUES ('14', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-10 06:19:19');
INSERT INTO `notifications` VALUES ('15', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-10 06:22:04');
INSERT INTO `notifications` VALUES ('16', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-10 06:53:31');
INSERT INTO `notifications` VALUES ('17', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-10 06:55:48');
INSERT INTO `notifications` VALUES ('18', '6', '2', 'user', 'Proveedor ocupado', 'El proveedor está ocupado temporalmente', '{\"url\":\"\\/requests\",\"action\":\"view_request\",\"notification_type\":\"general\"}', '1', '2026-05-10 06:56:16');
INSERT INTO `notifications` VALUES ('19', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-12 10:45:18');
INSERT INTO `notifications` VALUES ('20', '6', '2', 'user', 'Solicitud aceptada', 'Tu solicitud fue aceptada por el proveedor', '{\"url\":\"\\/service\\/12\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":12}', '1', '2026-05-12 10:45:48');
INSERT INTO `notifications` VALUES ('21', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-12 21:33:07');
INSERT INTO `notifications` VALUES ('22', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-12 21:40:05');
INSERT INTO `notifications` VALUES ('23', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-12 21:54:07');
INSERT INTO `notifications` VALUES ('24', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-13 00:05:50');
INSERT INTO `notifications` VALUES ('25', '6', '2', 'user', 'Proveedor ocupado', 'El proveedor está ocupado temporalmente', '{\"url\":\"\\/requests\",\"action\":\"view_request\",\"notification_type\":\"general\"}', '1', '2026-05-13 00:06:12');
INSERT INTO `notifications` VALUES ('26', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-13 00:27:05');
INSERT INTO `notifications` VALUES ('27', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-13 00:29:06');
INSERT INTO `notifications` VALUES ('28', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-13 06:40:00');
INSERT INTO `notifications` VALUES ('29', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-13 06:41:40');
INSERT INTO `notifications` VALUES ('30', '6', '2', 'user', 'Solicitud aceptada', 'Tu solicitud fue aceptada por el proveedor', '{\"url\":\"\\/service\\/10\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":10}', '1', '2026-05-13 06:51:22');
INSERT INTO `notifications` VALUES ('31', '2', '6', 'provider', 'Pago registrado', 'El cliente pagará en efectivo', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"default\",\"notification_type\":\"general\",\"request_id\":\"41\"}', '1', '2026-05-15 09:00:01');
INSERT INTO `notifications` VALUES ('32', '2', '6', 'provider', 'Pago registrado', 'El cliente pagará en efectivo', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"default\",\"notification_type\":\"general\",\"request_id\":\"41\"}', '1', '2026-05-15 09:03:22');
INSERT INTO `notifications` VALUES ('33', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-15 09:06:07');
INSERT INTO `notifications` VALUES ('34', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-15 14:13:51');
INSERT INTO `notifications` VALUES ('35', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-15 14:17:50');
INSERT INTO `notifications` VALUES ('36', '6', '2', 'user', 'Proveedor ocupado', 'El proveedor está ocupado temporalmente', '{\"url\":\"\\/requests\",\"action\":\"view_request\",\"notification_type\":\"general\"}', '1', '2026-05-15 14:17:57');
INSERT INTO `notifications` VALUES ('37', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-15 15:13:20');
INSERT INTO `notifications` VALUES ('38', '6', '2', 'user', 'Proveedor ocupado', 'El proveedor está ocupado temporalmente', '{\"url\":\"\\/requests\",\"action\":\"view_request\",\"notification_type\":\"general\"}', '1', '2026-05-15 15:14:02');
INSERT INTO `notifications` VALUES ('39', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-16 09:54:16');
INSERT INTO `notifications` VALUES ('40', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-16 10:26:40');
INSERT INTO `notifications` VALUES ('41', '6', '2', 'user', 'Proveedor ocupado', 'El proveedor está ocupado temporalmente', '{\"url\":\"\\/requests\",\"action\":\"view_request\",\"notification_type\":\"general\"}', '1', '2026-05-16 10:26:48');
INSERT INTO `notifications` VALUES ('42', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-16 10:35:20');
INSERT INTO `notifications` VALUES ('43', '6', '2', 'user', 'Proveedor ocupado', 'El proveedor está ocupado temporalmente', '{\"url\":\"\\/requests\",\"action\":\"view_request\",\"notification_type\":\"general\"}', '1', '2026-05-16 10:35:23');
INSERT INTO `notifications` VALUES ('44', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-16 12:51:45');
INSERT INTO `notifications` VALUES ('45', '6', '2', 'user', 'Proveedor ocupado', 'El proveedor está ocupado temporalmente', '{\"url\":\"\\/requests\",\"action\":\"view_request\",\"notification_type\":\"general\"}', '1', '2026-05-16 12:51:49');
INSERT INTO `notifications` VALUES ('46', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-16 12:52:02');
INSERT INTO `notifications` VALUES ('47', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-16 12:52:20');
INSERT INTO `notifications` VALUES ('48', '6', '2', 'user', 'Solicitud aceptada', 'Tu solicitud fue aceptada por el proveedor', '{\"url\":\"\\/service\\/11\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":11}', '1', '2026-05-16 12:52:22');
INSERT INTO `notifications` VALUES ('49', '2', '6', 'provider', 'Pago registrado', 'El cliente pagará en efectivo', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"default\",\"notification_type\":\"general\",\"request_id\":\"51\"}', '1', '2026-05-16 12:52:32');
INSERT INTO `notifications` VALUES ('50', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-16 14:42:28');
INSERT INTO `notifications` VALUES ('51', '6', '2', 'user', 'Solicitud aceptada', 'Tu solicitud fue aceptada por el proveedor', '{\"url\":\"\\/service\\/12\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":12}', '1', '2026-05-16 14:42:32');
INSERT INTO `notifications` VALUES ('52', '2', '6', 'provider', 'Pago registrado', 'El cliente pagará en efectivo', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"default\",\"notification_type\":\"general\",\"request_id\":\"52\"}', '1', '2026-05-16 14:42:41');
INSERT INTO `notifications` VALUES ('53', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-16 15:06:21');
INSERT INTO `notifications` VALUES ('54', '6', '2', 'user', 'Solicitud aceptada', 'Tu solicitud fue aceptada por el proveedor', '{\"url\":\"\\/service\\/11\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":11}', '1', '2026-05-16 15:06:30');
INSERT INTO `notifications` VALUES ('55', '2', '6', 'provider', 'Pago registrado', 'El cliente pagará en efectivo', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"default\",\"notification_type\":\"general\",\"request_id\":\"53\"}', '1', '2026-05-16 15:06:37');
INSERT INTO `notifications` VALUES ('56', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-16 21:51:03');
INSERT INTO `notifications` VALUES ('57', '6', '2', 'user', 'Solicitud aceptada', 'Tu solicitud fue aceptada por el proveedor', '{\"url\":\"\\/service\\/11\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":11}', '1', '2026-05-16 21:51:12');
INSERT INTO `notifications` VALUES ('58', '2', '6', 'provider', 'Pago registrado', 'El cliente pagará en efectivo', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"default\",\"notification_type\":\"general\",\"request_id\":\"54\"}', '1', '2026-05-16 21:51:17');
INSERT INTO `notifications` VALUES ('59', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-16 22:50:19');
INSERT INTO `notifications` VALUES ('60', '6', '2', 'user', 'Solicitud aceptada', 'Tu solicitud fue aceptada por el proveedor', '{\"url\":\"\\/service\\/11\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":11}', '1', '2026-05-16 22:50:24');
INSERT INTO `notifications` VALUES ('61', '2', '6', 'provider', 'Pago registrado', 'El cliente pagará en efectivo', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"default\",\"notification_type\":\"general\",\"request_id\":\"55\"}', '1', '2026-05-16 22:50:30');
INSERT INTO `notifications` VALUES ('62', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-17 06:15:42');
INSERT INTO `notifications` VALUES ('63', '6', '2', 'user', 'Solicitud aceptada', 'Tu solicitud fue aceptada por el proveedor', '{\"url\":\"\\/service\\/11\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":11}', '1', '2026-05-17 06:16:01');
INSERT INTO `notifications` VALUES ('64', '2', '6', 'provider', 'Pago registrado', 'El cliente pagará en efectivo', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"default\",\"notification_type\":\"general\",\"request_id\":\"56\"}', '1', '2026-05-17 06:16:16');
INSERT INTO `notifications` VALUES ('65', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-17 06:21:21');
INSERT INTO `notifications` VALUES ('66', '6', '2', 'user', 'Solicitud aceptada', 'Tu solicitud fue aceptada por el proveedor', '{\"url\":\"\\/service\\/11\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":11}', '1', '2026-05-17 06:21:46');
INSERT INTO `notifications` VALUES ('67', '2', '6', 'provider', 'Pago registrado', 'El cliente pagará en efectivo', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"default\",\"notification_type\":\"general\",\"request_id\":\"57\"}', '1', '2026-05-17 06:22:03');
INSERT INTO `notifications` VALUES ('68', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-17 08:42:48');
INSERT INTO `notifications` VALUES ('69', '6', '2', 'user', 'Solicitud aceptada', 'Tu solicitud fue aceptada por el proveedor', '{\"url\":\"\\/service\\/11\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":11}', '1', '2026-05-17 08:42:53');
INSERT INTO `notifications` VALUES ('70', '2', '6', 'provider', 'Pago registrado', 'El cliente pagará en efectivo', '{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/dashboard\\/provider\",\"action\":\"verify_payment\",\"request_id\":58,\"payment_id\":52}', '1', '2026-05-17 08:42:58');
INSERT INTO `notifications` VALUES ('71', '6', '2', 'user', 'Pago confirmado', 'El proveedor certificó que recibió tu pago', '{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/58\",\"action\":\"view_order\",\"request_id\":58,\"payment_id\":52}', '1', '2026-05-17 08:43:26');
INSERT INTO `notifications` VALUES ('72', NULL, '6', 'provider', '¡Tienes una nueva evaluación!', 'Un cliente te calificó con 4 estrellas.', '{\"route\":\"\\/reviews\"}', '1', '2026-05-17 08:44:06');
INSERT INTO `notifications` VALUES ('73', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-17 08:58:53');
INSERT INTO `notifications` VALUES ('74', '6', '2', 'user', 'Solicitud aceptada', 'Tu solicitud fue aceptada por el proveedor', '{\"url\":\"\\/service\\/12\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":12}', '1', '2026-05-17 08:59:01');
INSERT INTO `notifications` VALUES ('75', '2', '6', 'provider', 'Pago registrado', 'El cliente pagará en efectivo', '{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/dashboard\\/provider\",\"action\":\"verify_payment\",\"request_id\":59,\"payment_id\":53}', '1', '2026-05-17 08:59:06');
INSERT INTO `notifications` VALUES ('76', '6', '2', 'user', 'Pago confirmado', 'El proveedor certificó que recibió tu pago', '{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/59\",\"action\":\"view_order\",\"request_id\":59,\"payment_id\":53}', '1', '2026-05-17 08:59:25');
INSERT INTO `notifications` VALUES ('77', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-17 09:57:09');
INSERT INTO `notifications` VALUES ('78', '6', '2', 'user', 'Solicitud aceptada', 'Tu solicitud fue aceptada por el proveedor', '{\"url\":\"\\/service\\/11\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":11}', '1', '2026-05-17 09:57:13');
INSERT INTO `notifications` VALUES ('79', '2', '6', 'provider', 'Pago registrado', 'El cliente pagará en efectivo', '{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/dashboard\\/provider\",\"action\":\"verify_payment\",\"request_id\":60,\"payment_id\":54}', '1', '2026-05-17 09:57:23');
INSERT INTO `notifications` VALUES ('80', '6', '2', 'user', 'Pago confirmado', 'El proveedor certificó que recibió tu pago', '{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/60\",\"action\":\"view_order\",\"request_id\":60,\"payment_id\":54}', '1', '2026-05-17 09:58:24');
INSERT INTO `notifications` VALUES ('81', NULL, '6', 'provider', '¡Tienes una nueva evaluación!', 'Un cliente te calificó con 3 estrellas.', '{\"route\":\"\\/reviews\"}', '1', '2026-05-17 09:59:03');
INSERT INTO `notifications` VALUES ('82', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-17 10:40:08');
INSERT INTO `notifications` VALUES ('83', '6', '2', 'user', 'Solicitud aceptada', 'Tu solicitud fue aceptada por el proveedor', '{\"url\":\"\\/service\\/12\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":12}', '1', '2026-05-17 10:40:15');
INSERT INTO `notifications` VALUES ('84', '2', '6', 'provider', 'Pago registrado', 'El cliente pagará en efectivo', '{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/dashboard\\/provider\",\"action\":\"verify_payment\",\"request_id\":61,\"payment_id\":55}', '1', '2026-05-17 10:40:22');
INSERT INTO `notifications` VALUES ('85', '6', '2', 'user', 'Pago confirmado', 'El proveedor certificó que recibió tu pago', '{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/61\",\"action\":\"view_order\",\"request_id\":61,\"payment_id\":55}', '1', '2026-05-17 11:06:53');
INSERT INTO `notifications` VALUES ('86', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-17 18:51:29');
INSERT INTO `notifications` VALUES ('87', '6', '2', 'user', 'Solicitud aceptada', 'Tu solicitud fue aceptada por el proveedor', '{\"url\":\"\\/service\\/11\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":11}', '1', '2026-05-17 18:51:40');
INSERT INTO `notifications` VALUES ('88', '2', '6', 'provider', 'Pago registrado', 'El cliente pagará en efectivo', '{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/dashboard\\/provider\",\"action\":\"verify_payment\",\"request_id\":62,\"payment_id\":56}', '1', '2026-05-17 18:53:30');
INSERT INTO `notifications` VALUES ('89', '6', '2', 'user', 'Pago confirmado', 'El proveedor certificó que recibió tu pago', '{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/62\",\"action\":\"view_order\",\"request_id\":62,\"payment_id\":56}', '1', '2026-05-17 18:53:44');
INSERT INTO `notifications` VALUES ('90', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-17 18:54:49');
INSERT INTO `notifications` VALUES ('91', '6', '2', 'user', 'Solicitud aceptada', 'Tu solicitud fue aceptada por el proveedor', '{\"url\":\"\\/service\\/12\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":12}', '1', '2026-05-17 18:55:00');
INSERT INTO `notifications` VALUES ('92', '2', '6', 'provider', 'Pago registrado', 'El cliente pagará en efectivo', '{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/dashboard\\/provider\",\"action\":\"verify_payment\",\"request_id\":63,\"payment_id\":57}', '1', '2026-05-17 18:55:10');
INSERT INTO `notifications` VALUES ('93', '6', '2', 'user', 'Pago confirmado', 'El proveedor certificó que recibió tu pago', '{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/63\",\"action\":\"view_order\",\"request_id\":63,\"payment_id\":57}', '1', '2026-05-17 18:55:44');
INSERT INTO `notifications` VALUES ('94', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '1', '2026-05-17 19:53:05');
INSERT INTO `notifications` VALUES ('95', '6', '2', 'user', 'Solicitud aceptada', 'Tu solicitud fue aceptada por el proveedor', '{\"url\":\"\\/service\\/12\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":12}', '1', '2026-05-17 19:53:11');
INSERT INTO `notifications` VALUES ('96', '2', '6', 'provider', 'Pago registrado', 'El cliente pagará en efectivo', '{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/dashboard\\/provider\",\"action\":\"verify_payment\",\"request_id\":64,\"payment_id\":58}', '1', '2026-05-17 19:53:18');
INSERT INTO `notifications` VALUES ('97', '6', '2', 'user', 'Pago confirmado', 'El proveedor certificó que recibió tu pago', '{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/64\",\"action\":\"view_order\",\"request_id\":64,\"payment_id\":58}', '1', '2026-05-17 19:53:59');
INSERT INTO `notifications` VALUES ('98', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '0', '2026-05-17 20:09:08');
INSERT INTO `notifications` VALUES ('99', '6', '2', 'user', 'Solicitud aceptada', 'Tu solicitud fue aceptada por el proveedor', '{\"url\":\"\\/service\\/12\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":12}', '1', '2026-05-17 20:09:19');
INSERT INTO `notifications` VALUES ('100', '2', '6', 'provider', 'Pago registrado', 'El cliente pagará en efectivo', '{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/dashboard\\/provider\",\"action\":\"verify_payment\",\"request_id\":65,\"payment_id\":59}', '0', '2026-05-17 20:09:23');
INSERT INTO `notifications` VALUES ('101', '6', '2', 'user', 'Pago confirmado', 'El proveedor certificó que recibió tu pago', '{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/65\",\"action\":\"view_order\",\"request_id\":65,\"payment_id\":59}', '1', '2026-05-17 20:09:33');
INSERT INTO `notifications` VALUES ('102', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '0', '2026-05-17 20:52:05');
INSERT INTO `notifications` VALUES ('103', '6', '2', 'user', 'Solicitud aceptada', 'Tu solicitud fue aceptada por el proveedor', '{\"url\":\"\\/service\\/12\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":12}', '1', '2026-05-17 20:52:09');
INSERT INTO `notifications` VALUES ('104', '2', '6', 'provider', 'Pago registrado', 'El cliente pagará en efectivo', '{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/dashboard\\/provider\",\"action\":\"verify_payment\",\"request_id\":66,\"payment_id\":60}', '0', '2026-05-17 20:52:18');
INSERT INTO `notifications` VALUES ('105', '6', '2', 'user', 'Pago confirmado', 'El proveedor certificó que recibió tu pago', '{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/66\",\"action\":\"view_order\",\"request_id\":66,\"payment_id\":60}', '1', '2026-05-17 20:52:29');
INSERT INTO `notifications` VALUES ('106', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '0', '2026-05-17 21:16:47');
INSERT INTO `notifications` VALUES ('107', '6', '2', 'user', 'Solicitud aceptada', 'Tu solicitud fue aceptada por el proveedor', '{\"url\":\"\\/service\\/11\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":11}', '1', '2026-05-17 21:16:50');
INSERT INTO `notifications` VALUES ('108', '2', '6', 'provider', 'Pago registrado', 'El cliente pagará en efectivo', '{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/dashboard\\/provider\",\"action\":\"verify_payment\",\"request_id\":67,\"payment_id\":61}', '0', '2026-05-17 21:16:57');
INSERT INTO `notifications` VALUES ('109', '6', '2', 'user', 'Pago confirmado', 'El proveedor certificó que recibió tu pago', '{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/67\",\"action\":\"view_order\",\"request_id\":67,\"payment_id\":61}', '1', '2026-05-17 21:17:05');
INSERT INTO `notifications` VALUES ('110', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '0', '2026-05-17 21:43:17');
INSERT INTO `notifications` VALUES ('111', '6', '2', 'user', 'Solicitud aceptada', 'Tu solicitud fue aceptada por el proveedor', '{\"url\":\"\\/service\\/12\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":12}', '1', '2026-05-17 21:43:20');
INSERT INTO `notifications` VALUES ('112', '2', '6', 'provider', 'Pago registrado', 'El cliente pagará en efectivo', '{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/dashboard\\/provider\",\"action\":\"verify_payment\",\"request_id\":68,\"payment_id\":62}', '0', '2026-05-17 21:43:26');
INSERT INTO `notifications` VALUES ('113', '6', '2', 'user', 'Pago confirmado', 'El proveedor certificó que recibió tu pago', '{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/68\",\"action\":\"view_order\",\"request_id\":68,\"payment_id\":62}', '1', '2026-05-17 21:43:33');
INSERT INTO `notifications` VALUES ('114', '6', '6', 'provider', '¡Tienes una nueva evaluación!', 'Un cliente te calificó con 3 estrellas.', '{\"type\":\"review\",\"notification_type\":\"review_received\",\"route\":\"\\/reviews\",\"url\":\"\\/dashboard\\/provider\\/reviews\",\"action\":\"view_reviews\"}', '0', '2026-05-17 21:44:01');
INSERT INTO `notifications` VALUES ('115', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '0', '2026-05-17 22:05:30');
INSERT INTO `notifications` VALUES ('116', '6', '2', 'user', 'Solicitud aceptada', 'Tu solicitud fue aceptada por el proveedor', '{\"url\":\"\\/service\\/11\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":11}', '1', '2026-05-17 22:05:33');
INSERT INTO `notifications` VALUES ('117', '2', '6', 'provider', 'Pago registrado', 'El cliente pagará en efectivo', '{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/dashboard\\/provider\",\"action\":\"verify_payment\",\"request_id\":69,\"payment_id\":63}', '0', '2026-05-17 22:06:32');
INSERT INTO `notifications` VALUES ('118', '6', '2', 'user', 'Pago confirmado', 'El proveedor certificó que recibió tu pago', '{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/69\",\"action\":\"view_order\",\"request_id\":69,\"payment_id\":63}', '1', '2026-05-17 22:06:39');
INSERT INTO `notifications` VALUES ('119', '6', '2', 'user', 'Servicio finalizado - ¡Califica tu experiencia!', 'El proveedor marcó el servicio como finalizado. Deja una reseña sobre tu experiencia.', '{\"type\":\"rating\",\"notification_type\":\"open_rating\",\"url\":\"\\/orders\\/69\",\"action\":\"open_rating_modal\",\"request_id\":69,\"provider_id\":6,\"from_role\":\"provider\"}', '1', '2026-05-17 22:06:46');
INSERT INTO `notifications` VALUES ('120', '6', '6', 'provider', '¡Tienes una nueva evaluación!', 'Un cliente te calificó con 3 estrellas.', '{\"type\":\"review\",\"notification_type\":\"review_received\",\"route\":\"\\/reviews\",\"url\":\"\\/dashboard\\/provider\\/reviews\",\"action\":\"view_reviews\"}', '0', '2026-05-17 22:07:02');
INSERT INTO `notifications` VALUES ('121', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '0', '2026-05-17 22:26:32');
INSERT INTO `notifications` VALUES ('122', '6', '2', 'user', 'Solicitud aceptada', 'Tu solicitud fue aceptada por el proveedor', '{\"url\":\"\\/service\\/11\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":11}', '0', '2026-05-17 22:26:34');
INSERT INTO `notifications` VALUES ('123', '2', '6', 'provider', 'Pago registrado', 'El cliente pagará en efectivo', '{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/dashboard\\/provider\",\"action\":\"verify_payment\",\"request_id\":70,\"payment_id\":64}', '0', '2026-05-17 22:26:38');
INSERT INTO `notifications` VALUES ('124', '6', '2', 'user', 'Pago confirmado', 'El proveedor certificó que recibió tu pago', '{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/70\",\"action\":\"view_order\",\"request_id\":70,\"payment_id\":64}', '0', '2026-05-17 22:26:46');
INSERT INTO `notifications` VALUES ('125', '6', '2', 'user', 'Servicio finalizado - ¡Califica tu experiencia!', 'El proveedor marcó el servicio como finalizado. Deja una reseña sobre tu experiencia.', '{\"type\":\"rating\",\"notification_type\":\"open_rating\",\"url\":\"\\/orders\\/70\",\"action\":\"open_rating_modal\",\"request_id\":70,\"provider_id\":6,\"from_role\":\"provider\"}', '0', '2026-05-17 22:26:56');
INSERT INTO `notifications` VALUES ('126', '6', '2', 'user', 'Servicio finalizado', 'El proveedor ha finalizado el servicio. ¿Quieres calificarlo?', '{\"type\":\"rating\",\"notification_type\":\"review_request\",\"url\":\"/dashboard/user\",\"action\":\"open_rating\",\"request_id\":69}', '0', '2026-05-18 06:51:33');
INSERT INTO `notifications` VALUES ('127', '6', '2', 'user', 'Servicio finalizado', 'El proveedor ha finalizado el servicio. ¿Quieres calificarlo?', '{\"type\":\"rating\",\"notification_type\":\"review_request\",\"url\":\"/dashboard/user\",\"action\":\"open_rating\",\"request_id\":69}', '0', '2026-05-18 06:52:07');
INSERT INTO `notifications` VALUES ('128', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '0', '2026-05-18 08:26:03');
INSERT INTO `notifications` VALUES ('129', '6', '2', 'user', 'Solicitud aceptada', 'Tu solicitud fue aceptada por el proveedor', '{\"url\":\"\\/service\\/11\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":11}', '0', '2026-05-18 08:26:07');
INSERT INTO `notifications` VALUES ('130', '2', '6', 'provider', 'Pago registrado', 'El cliente pagará en efectivo', '{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/dashboard\\/provider\",\"action\":\"verify_payment\",\"request_id\":71,\"payment_id\":65}', '0', '2026-05-18 08:26:17');
INSERT INTO `notifications` VALUES ('131', '6', '2', 'user', 'Pago confirmado', 'El proveedor certificó que recibió tu pago', '{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/71\",\"action\":\"view_order\",\"request_id\":71,\"payment_id\":65}', '0', '2026-05-18 08:26:53');
INSERT INTO `notifications` VALUES ('132', '6', '2', 'user', 'Servicio finalizado - ¡Califica tu experiencia!', 'El proveedor marcó el servicio como finalizado. Deja una reseña sobre tu experiencia.', '{\"type\":\"rating\",\"notification_type\":\"open_rating\",\"url\":\"\\/orders\\/71\",\"action\":\"open_rating_modal\",\"request_id\":71,\"provider_id\":6,\"from_role\":\"provider\"}', '0', '2026-05-18 08:27:10');
INSERT INTO `notifications` VALUES ('133', '2', '6', 'provider', 'Nueva solicitud', 'Tienes una nueva solicitud pendiente', '{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}', '0', '2026-05-18 08:30:49');
INSERT INTO `notifications` VALUES ('134', '6', '2', 'user', 'Solicitud aceptada', 'Tu solicitud fue aceptada por el proveedor', '{\"url\":\"\\/service\\/12\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":12}', '0', '2026-05-18 08:30:56');
INSERT INTO `notifications` VALUES ('135', '2', '6', 'provider', 'Pago registrado', 'El cliente pagará en efectivo', '{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/dashboard\\/provider\",\"action\":\"verify_payment\",\"request_id\":72,\"payment_id\":66}', '0', '2026-05-18 08:31:00');
INSERT INTO `notifications` VALUES ('136', '6', '2', 'user', 'Pago confirmado', 'El proveedor certificó que recibió tu pago', '{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/72\",\"action\":\"view_order\",\"request_id\":72,\"payment_id\":66}', '0', '2026-05-18 08:31:11');
INSERT INTO `notifications` VALUES ('137', '6', '2', 'user', 'Servicio finalizado - ¡Califica tu experiencia!', 'El proveedor marcó el servicio como finalizado. Deja una reseña sobre tu experiencia.', '{\"type\":\"rating\",\"notification_type\":\"open_rating\",\"url\":\"\\/orders\\/72\",\"action\":\"open_rating_modal\",\"request_id\":72,\"provider_id\":6,\"from_role\":\"provider\"}', '0', '2026-05-18 08:31:30');

DROP TABLE IF EXISTS `payment_gateways`;
CREATE TABLE `payment_gateways` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `display_name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `is_test_mode` tinyint(1) DEFAULT 1,
  `requires_api_keys` tinyint(1) DEFAULT 0,
  `api_key_public` text DEFAULT NULL,
  `api_key_secret` text DEFAULT NULL,
  `api_key_extra` text DEFAULT NULL,
  `paypal_email` varchar(150) DEFAULT NULL,
  `mercadopago_access_token` text DEFAULT NULL,
  `bank_name` varchar(100) DEFAULT NULL,
  `bank_account` varchar(50) DEFAULT NULL,
  `bank_holder` varchar(150) DEFAULT NULL,
  `bank_id_type` varchar(20) DEFAULT NULL,
  `bank_id_number` varchar(50) DEFAULT NULL,
  `mobile_phone` varchar(20) DEFAULT NULL,
  `mobile_operator` varchar(50) DEFAULT NULL,
  `zelle_email` varchar(150) DEFAULT NULL,
  `commission_rate` decimal(5,2) DEFAULT 0.00,
  `fixed_commission` decimal(10,2) DEFAULT 0.00,
  `total_transactions` int(11) DEFAULT 0,
  `total_amount` decimal(15,2) DEFAULT 0.00,
  `success_rate` decimal(5,2) DEFAULT 0.00,
  `instructions` text DEFAULT NULL,
  `icon` varchar(50) DEFAULT '?',
  `sort_order` int(11) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

INSERT INTO `payment_gateways` VALUES ('1', 'paypal', 'PayPal', 'Pagos seguros con PayPal', '1', '1', '1', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0.00', '0.00', '0', '0.00', '0.00', NULL, '🅿️', '0', '2026-02-04 14:00:19', '2026-02-04 14:00:19');
INSERT INTO `payment_gateways` VALUES ('2', 'mercadopago', 'MercadoPago', 'Pagos en Latinoamérica', '1', '1', '1', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0.00', '0.00', '0', '0.00', '0.00', NULL, '🇦🇷', '0', '2026-02-04 14:00:19', '2026-02-04 14:00:19');
INSERT INTO `payment_gateways` VALUES ('3', 'bank_transfer', 'Transferencia Bancaria', 'Transferencia directa a cuenta bancaria', '1', '1', '0', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0.00', '0.00', '0', '0.00', '0.00', NULL, '🏦', '0', '2026-02-04 14:00:19', '2026-02-04 14:00:19');
INSERT INTO `payment_gateways` VALUES ('4', 'mobile_payment', 'Pago Móvil', 'Pago desde tu teléfono móvil', '1', '1', '0', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0.00', '0.00', '0', '0.00', '0.00', NULL, '📱', '0', '2026-02-04 14:00:19', '2026-02-04 14:00:19');
INSERT INTO `payment_gateways` VALUES ('5', 'zelle', 'Zelle', 'Transferencias bancarias en USA', '1', '1', '0', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'divijeal@gmail.com', '0.00', '0.00', '0', '0.00', '0.00', NULL, '🇺🇸', '0', '2026-02-04 14:00:19', '2026-04-28 05:49:38');

DROP TABLE IF EXISTS `payment_methods`;
CREATE TABLE `payment_methods` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `value` varchar(50) NOT NULL,
  `label` varchar(100) NOT NULL,
  `title` varchar(100) DEFAULT NULL,
  `fields` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`fields`)),
  `concept` varchar(50) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `value` (`value`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

INSERT INTO `payment_methods` VALUES ('1', 'transferencia', '🏦 Transferencia bancaria', '🏦 Datos para transferencia', '{\"Banco\": \"Banco de Venezuela\", \"Titular\": \"Tapclic Services C.A.\", \"RIF\": \"J-123456789\", \"Cuenta Corriente\": \"0102-0123-45-12345678\", \"CI\": \"V-12345678\"}', 'RECARGA', '1', '2026-02-13 23:27:59', '2026-02-13 23:27:59');
INSERT INTO `payment_methods` VALUES ('2', 'pago_movil', '📱 Pago móvil', '📱 Datos para Pago Móvil', '{\"Banco\": \"Banesco\", \"Cédula/RIF\": \"V-12345678\", \"Teléfono\": \"0412-1234567\", \"Banco receptor\": \"Banesco\"}', 'RECARGA', '1', '2026-02-13 23:27:59', '2026-04-28 05:42:00');
INSERT INTO `payment_methods` VALUES ('3', 'paypal', '🌐 PayPal', '🌐 Datos de PayPal', '{\"Email\": \"pagos@tapclic.com\", \"Nombre\": \"Tapclic Services\"}', 'RECARGA', '1', '2026-02-13 23:27:59', '2026-02-13 23:27:59');
INSERT INTO `payment_methods` VALUES ('4', 'zelle', '💵 Zelle', '💵 Datos para Zelle', '{\"Email\": \"pagos@tapclic.com\", \"Nombre\": \"Tapclic Services\", \"Banco\": \"Bank of America\"}', 'RECARGA', '1', '2026-02-13 23:27:59', '2026-02-13 23:27:59');
INSERT INTO `payment_methods` VALUES ('5', 'binance', '🪙 Binance', '🪙 Datos de Binance', '{\"ID\": \"123456789\", \"Email\": \"binance@tapclic.com\"}', 'RECARGA', '1', '2026-02-13 23:27:59', '2026-02-13 23:27:59');
INSERT INTO `payment_methods` VALUES ('6', 'efectivo', '💵 Efectivo', '💵 Pago en efectivo', '{\"Punto de pago\": \"Consultar con administrador\"}', 'RECARGA', '1', '2026-02-13 23:27:59', '2026-02-13 23:27:59');

DROP TABLE IF EXISTS `payments`;
CREATE TABLE `payments` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `service_request_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `payment_method` enum('efectivo','pago-movil','transferencia','zelle','paypal') NOT NULL DEFAULT 'efectivo',
  `reference` varchar(255) DEFAULT NULL,
  `capture_file` varchar(255) DEFAULT NULL,
  `status` enum('pending','verifying','paid','cancelled','rejected','refunded','failed') DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `gateway_name` varchar(50) DEFAULT NULL,
  `gateway_transaction_id` varchar(100) DEFAULT NULL,
  `gateway_response` text DEFAULT NULL,
  `commission_amount` decimal(10,2) DEFAULT 0.00,
  PRIMARY KEY (`id`),
  KEY `service_request_id` (`service_request_id`),
  CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`service_request_id`) REFERENCES `service_requests` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=67 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;


DROP TABLE IF EXISTS `provider_payment_methods`;
CREATE TABLE `provider_payment_methods` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `provider_id` int(11) NOT NULL,
  `method_type` enum('pago_movil','transferencia','zelle','binance','paypal') NOT NULL,
  `bank_name` varchar(100) DEFAULT NULL,
  `holder_name` varchar(100) DEFAULT NULL,
  `id_number` varchar(20) DEFAULT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `account_number` varchar(50) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `qr_url` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `provider_id` (`provider_id`),
  CONSTRAINT `provider_payment_methods_ibfk_1` FOREIGN KEY (`provider_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

INSERT INTO `provider_payment_methods` VALUES ('1', '6', 'pago_movil', 'Venezuela ', 'Jesús Diaz ', '18673920', '04120761886', '01020287463528934678', NULL, NULL, '1', '2025-09-07 07:57:06', '2025-09-07 07:59:32');
INSERT INTO `provider_payment_methods` VALUES ('2', '6', 'transferencia', 'Bicentenario ', 'Jesús Diaz ', '18673920', '', '01029876542345764567', '', '', '1', '2025-09-07 10:45:18', '2025-09-07 10:57:14');
INSERT INTO `provider_payment_methods` VALUES ('3', '6', 'paypal', '', 'Jesús Diaz ', '18673920', '', '', 'divijeal@gmail.com', '', '1', '2025-09-07 10:59:01', '2025-09-07 10:59:01');
INSERT INTO `provider_payment_methods` VALUES ('4', '6', 'zelle', '', '18673920', '18673920', '', '', 'divijeal@gmail.com', '', '1', '2025-09-07 10:59:31', '2025-09-07 10:59:31');

DROP TABLE IF EXISTS `requests`;
CREATE TABLE `requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `service_id` int(11) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `receiver_id` int(11) NOT NULL,
  `status` enum('pending','accepted','rejected') DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;


DROP TABLE IF EXISTS `review_helpful`;
CREATE TABLE `review_helpful` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `review_id` bigint(20) NOT NULL,
  `user_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_helpful` (`review_id`,`user_id`),
  KEY `fk_helpful_user` (`user_id`),
  CONSTRAINT `fk_helpful_review` FOREIGN KEY (`review_id`) REFERENCES `service_reviews` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_helpful_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

INSERT INTO `review_helpful` VALUES ('1', '2', '2', '2025-12-18 13:27:44');
INSERT INTO `review_helpful` VALUES ('2', '10', '6', '2025-12-18 06:35:28');
INSERT INTO `review_helpful` VALUES ('13', '1', '6', '2025-12-18 13:28:47');
INSERT INTO `review_helpful` VALUES ('14', '1', '2', '2025-12-18 13:27:46');
INSERT INTO `review_helpful` VALUES ('16', '9', '6', '2025-12-18 12:52:38');
INSERT INTO `review_helpful` VALUES ('19', '7', '6', '2025-12-18 13:28:09');
INSERT INTO `review_helpful` VALUES ('20', '8', '6', '2025-12-18 13:28:10');
INSERT INTO `review_helpful` VALUES ('21', '2', '6', '2025-12-18 13:28:46');
INSERT INTO `review_helpful` VALUES ('28', '3', '6', '2025-12-18 13:28:56');
INSERT INTO `review_helpful` VALUES ('29', '3', '2', '2025-12-19 17:42:54');
INSERT INTO `review_helpful` VALUES ('35', '4', '6', '2025-12-19 20:49:15');

DROP TABLE IF EXISTS `review_messages`;
CREATE TABLE `review_messages` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `review_id` bigint(20) NOT NULL,
  `sender_type` enum('provider','user','admin') NOT NULL,
  `sender_id` int(11) NOT NULL,
  `message` text NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `fk_review` (`review_id`),
  KEY `fk_sender` (`sender_id`),
  CONSTRAINT `fk_review` FOREIGN KEY (`review_id`) REFERENCES `service_reviews` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

INSERT INTO `review_messages` VALUES ('8', '1', 'provider', '6', 'Más nada 😉🙂', '2025-12-04 14:01:06');
INSERT INTO `review_messages` VALUES ('10', '2', 'provider', '6', 'Que fue hombre ? Jesús te ama 🙏🏾', '2025-12-04 16:56:28');
INSERT INTO `review_messages` VALUES ('11', '3', 'provider', '6', 'Pepón', '2025-12-16 06:20:25');
INSERT INTO `review_messages` VALUES ('12', '1', 'user', '2', 'Que pasó', '2025-12-21 11:43:20');
INSERT INTO `review_messages` VALUES ('13', '4', 'user', '2', 'Hyt tú', '2025-12-25 15:43:25');
INSERT INTO `review_messages` VALUES ('14', '9', 'user', '2', 'Hhhjh', '2025-12-25 15:43:46');
INSERT INTO `review_messages` VALUES ('15', '6', 'user', '2', 'Yyyyyyyyyyyy', '2025-12-25 15:45:39');
INSERT INTO `review_messages` VALUES ('16', '2', 'user', '2', 'Naruto', '2025-12-25 15:46:27');
INSERT INTO `review_messages` VALUES ('17', '7', 'user', '2', '@#€4555666654221', '2025-12-25 16:08:56');
INSERT INTO `review_messages` VALUES ('18', '3', 'user', '2', 'Hola pezcado', '2025-12-25 16:14:17');
INSERT INTO `review_messages` VALUES ('19', '8', 'user', '2', 'Uuuuuuu', '2025-12-25 16:17:28');
INSERT INTO `review_messages` VALUES ('20', '5', 'user', '2', 'Hijo mío', '2025-12-25 16:31:50');
INSERT INTO `review_messages` VALUES ('21', '15', 'provider', '6', 'Mijo palante', '2025-12-26 08:57:55');
INSERT INTO `review_messages` VALUES ('22', '10', 'user', '2', 'Gato feliz pendejo', '2025-12-26 09:34:56');
INSERT INTO `review_messages` VALUES ('23', '18', 'user', '2', 'Hola 😘👋🏾👋🏾👋🏾', '2026-02-15 18:28:59');

DROP TABLE IF EXISTS `review_reports`;
CREATE TABLE `review_reports` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `review_id` bigint(20) NOT NULL,
  `user_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_report` (`review_id`,`user_id`),
  KEY `fk_report_user` (`user_id`),
  CONSTRAINT `fk_report_review` FOREIGN KEY (`review_id`) REFERENCES `service_reviews` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_report_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

INSERT INTO `review_reports` VALUES ('1', '2', '2', '2025-12-18 05:16:39');
INSERT INTO `review_reports` VALUES ('15', '1', '2', '2025-12-18 05:17:11');

DROP TABLE IF EXISTS `service_history`;
CREATE TABLE `service_history` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `service_id` int(10) unsigned DEFAULT NULL,
  `request_id` int(10) unsigned NOT NULL,
  `service_title` varchar(255) NOT NULL,
  `service_description` text DEFAULT NULL,
  `service_price` decimal(10,2) NOT NULL,
  `user_name` varchar(100) DEFAULT NULL,
  `user_avatar` varchar(255) DEFAULT NULL,
  `provider_name` varchar(255) DEFAULT NULL,
  `status` enum('completed','cancelled') NOT NULL,
  `payment_status` varchar(30) DEFAULT 'pending',
  `payment_method` varchar(50) DEFAULT NULL,
  `cancelled_by` varchar(50) DEFAULT NULL,
  `finished_at` datetime DEFAULT current_timestamp(),
  `provider_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_user_date` (`user_id`,`finished_at`),
  KEY `idx_request` (`request_id`)
) ENGINE=InnoDB AUTO_INCREMENT=245 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

INSERT INTO `service_history` VALUES ('1', '2', '10', '1', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2025-10-06 10:44:45', '6');
INSERT INTO `service_history` VALUES ('2', '6', '10', '3', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-11-21 00:16:34', '6');
INSERT INTO `service_history` VALUES ('3', '2', '10', '2', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-11-21 00:16:47', '6');
INSERT INTO `service_history` VALUES ('4', '2', '10', '4', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'verifying', 'efectivo', NULL, '2025-11-21 01:45:11', '6');
INSERT INTO `service_history` VALUES ('5', '2', '12', '5', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-08 19:21:43', '6');
INSERT INTO `service_history` VALUES ('6', '2', '10', '6', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-10 07:34:40', '6');
INSERT INTO `service_history` VALUES ('7', '2', '10', '7', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-11 06:48:21', '6');
INSERT INTO `service_history` VALUES ('8', '2', '10', '8', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'paid', 'efectivo', NULL, '2025-12-15 07:41:39', '6');
INSERT INTO `service_history` VALUES ('9', '2', '10', '10', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-15 07:56:58', '6');
INSERT INTO `service_history` VALUES ('10', '2', '10', '11', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2025-12-15 08:00:04', '6');
INSERT INTO `service_history` VALUES ('11', '2', '10', '12', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2025-12-15 08:04:08', '6');
INSERT INTO `service_history` VALUES ('12', '2', '10', '13', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-15 14:19:10', '6');
INSERT INTO `service_history` VALUES ('13', '2', '10', '14', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-15 14:50:30', '6');
INSERT INTO `service_history` VALUES ('14', '2', '10', '15', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'verifying', 'efectivo', NULL, '2025-12-15 15:11:27', '6');
INSERT INTO `service_history` VALUES ('15', '2', '10', '16', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-15 15:25:46', '6');
INSERT INTO `service_history` VALUES ('16', '2', '10', '17', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'verifying', 'efectivo', NULL, '2025-12-15 15:28:41', '6');
INSERT INTO `service_history` VALUES ('17', '2', '10', '18', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'verifying', 'efectivo', NULL, '2025-12-15 15:38:41', '6');
INSERT INTO `service_history` VALUES ('18', '2', '10', '19', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-15 15:49:52', '6');
INSERT INTO `service_history` VALUES ('19', '2', '10', '20', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'verifying', 'efectivo', NULL, '2025-12-15 18:16:21', '6');
INSERT INTO `service_history` VALUES ('20', '2', '10', '21', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-15 20:47:45', '6');
INSERT INTO `service_history` VALUES ('21', '2', '10', '22', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-16 05:31:59', '6');
INSERT INTO `service_history` VALUES ('22', '2', '10', '23', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2025-12-16 05:37:13', '6');
INSERT INTO `service_history` VALUES ('23', '2', '10', '24', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2025-12-16 10:04:13', '6');
INSERT INTO `service_history` VALUES ('24', '2', '10', '25', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-16 14:44:21', '6');
INSERT INTO `service_history` VALUES ('25', '2', '10', '26', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2025-12-16 14:48:28', '6');
INSERT INTO `service_history` VALUES ('26', '2', '10', '27', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2025-12-16 14:50:36', '6');
INSERT INTO `service_history` VALUES ('27', '2', '10', '28', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-16 14:55:55', '6');
INSERT INTO `service_history` VALUES ('28', '2', '10', '29', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'verifying', 'efectivo', NULL, '2025-12-16 15:01:29', '6');
INSERT INTO `service_history` VALUES ('29', '2', '10', '30', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-16 15:27:22', '6');
INSERT INTO `service_history` VALUES ('30', '2', '10', '31', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-16 15:34:04', '6');
INSERT INTO `service_history` VALUES ('31', '2', '10', '32', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-16 15:46:12', '6');
INSERT INTO `service_history` VALUES ('32', '2', '10', '33', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-16 16:11:16', '6');
INSERT INTO `service_history` VALUES ('33', '2', '10', '34', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-16 16:23:07', '6');
INSERT INTO `service_history` VALUES ('34', '2', '10', '35', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-16 16:35:35', '6');
INSERT INTO `service_history` VALUES ('35', '2', '10', '36', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-16 16:40:48', '6');
INSERT INTO `service_history` VALUES ('36', '2', '10', '37', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-16 16:47:39', '6');
INSERT INTO `service_history` VALUES ('37', '2', '10', '38', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-16 17:05:56', '6');
INSERT INTO `service_history` VALUES ('38', '2', '10', '39', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-16 18:09:01', '6');
INSERT INTO `service_history` VALUES ('39', '2', '10', '40', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-16 18:11:48', '6');
INSERT INTO `service_history` VALUES ('40', '2', '10', '41', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-16 18:17:56', '6');
INSERT INTO `service_history` VALUES ('41', '2', '10', '42', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-16 18:42:24', '6');
INSERT INTO `service_history` VALUES ('42', '2', '10', '43', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-16 18:43:19', '6');
INSERT INTO `service_history` VALUES ('43', '2', '10', '44', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-16 18:44:38', '6');
INSERT INTO `service_history` VALUES ('44', '2', '10', '45', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-16 18:45:51', '6');
INSERT INTO `service_history` VALUES ('45', '2', '10', '46', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-16 18:50:53', '6');
INSERT INTO `service_history` VALUES ('46', '2', '10', '47', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-16 18:54:56', '6');
INSERT INTO `service_history` VALUES ('47', '2', '10', '48', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-16 18:56:33', '6');
INSERT INTO `service_history` VALUES ('48', '2', '10', '49', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-16 19:45:29', '6');
INSERT INTO `service_history` VALUES ('49', '2', '10', '50', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-16 19:50:08', '6');
INSERT INTO `service_history` VALUES ('50', '2', '10', '51', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-16 20:02:20', '6');
INSERT INTO `service_history` VALUES ('51', '2', '10', '52', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-16 20:28:17', '6');
INSERT INTO `service_history` VALUES ('52', '2', '10', '53', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-16 20:30:09', '6');
INSERT INTO `service_history` VALUES ('53', '2', '10', '54', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-16 20:46:29', '6');
INSERT INTO `service_history` VALUES ('54', '2', '10', '55', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-16 21:29:59', '6');
INSERT INTO `service_history` VALUES ('55', '2', '10', '56', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-16 21:31:33', '6');
INSERT INTO `service_history` VALUES ('56', '2', '10', '57', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-16 21:32:47', '6');
INSERT INTO `service_history` VALUES ('57', '2', '10', '58', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-16 22:01:50', '6');
INSERT INTO `service_history` VALUES ('58', '2', '10', '59', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-17 07:15:58', '6');
INSERT INTO `service_history` VALUES ('59', '2', '10', '60', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-17 07:20:56', '6');
INSERT INTO `service_history` VALUES ('60', '2', '10', '61', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-17 07:25:56', '6');
INSERT INTO `service_history` VALUES ('61', '2', '10', '62', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-17 07:26:43', '6');
INSERT INTO `service_history` VALUES ('62', '2', '10', '63', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-17 07:30:41', '6');
INSERT INTO `service_history` VALUES ('63', '2', '10', '64', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-17 14:09:21', '6');
INSERT INTO `service_history` VALUES ('64', '2', '10', '65', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-17 14:25:12', '6');
INSERT INTO `service_history` VALUES ('65', '2', '10', '66', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-17 14:26:17', '6');
INSERT INTO `service_history` VALUES ('66', '2', '10', '67', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-17 17:15:45', '6');
INSERT INTO `service_history` VALUES ('67', '2', '10', '68', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-17 17:32:23', '6');
INSERT INTO `service_history` VALUES ('68', '2', '10', '69', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-17 17:33:14', '6');
INSERT INTO `service_history` VALUES ('69', '2', '10', '70', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-17 17:35:35', '6');
INSERT INTO `service_history` VALUES ('70', '2', '10', '71', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-17 21:27:04', '6');
INSERT INTO `service_history` VALUES ('71', '2', '10', '72', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-17 21:28:08', '6');
INSERT INTO `service_history` VALUES ('72', '2', '10', '73', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-17 21:56:59', '6');
INSERT INTO `service_history` VALUES ('73', '2', '10', '74', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-17 21:58:06', '6');
INSERT INTO `service_history` VALUES ('74', '2', '10', '75', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-17 22:00:01', '6');
INSERT INTO `service_history` VALUES ('75', '2', '10', '76', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-17 22:04:25', '6');
INSERT INTO `service_history` VALUES ('76', '2', '10', '77', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-17 22:45:55', '6');
INSERT INTO `service_history` VALUES ('77', '2', '10', '78', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2025-12-17 23:00:02', '6');
INSERT INTO `service_history` VALUES ('78', '2', '10', '79', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-17 23:01:11', '6');
INSERT INTO `service_history` VALUES ('79', '2', '10', '80', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-17 23:03:25', '6');
INSERT INTO `service_history` VALUES ('80', '2', '10', '81', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-17 23:08:04', '6');
INSERT INTO `service_history` VALUES ('81', '2', '10', '82', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-17 23:10:06', '6');
INSERT INTO `service_history` VALUES ('82', '2', '10', '83', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-17 23:14:25', '6');
INSERT INTO `service_history` VALUES ('83', '2', '10', '84', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-18 00:07:44', '6');
INSERT INTO `service_history` VALUES ('84', '2', '10', '85', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-19 06:52:39', '6');
INSERT INTO `service_history` VALUES ('85', '2', '10', '86', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-19 06:54:25', '6');
INSERT INTO `service_history` VALUES ('86', '2', '10', '87', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-19 06:56:23', '6');
INSERT INTO `service_history` VALUES ('87', '2', '10', '88', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-19 20:54:05', '6');
INSERT INTO `service_history` VALUES ('88', '2', '10', '89', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-19 20:55:15', '6');
INSERT INTO `service_history` VALUES ('89', '2', '10', '90', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-21 11:48:33', '6');
INSERT INTO `service_history` VALUES ('90', '2', '10', '91', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-22 06:51:53', '6');
INSERT INTO `service_history` VALUES ('91', '2', '10', '92', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-22 07:15:34', '6');
INSERT INTO `service_history` VALUES ('92', '2', '10', '93', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-22 07:23:17', '6');
INSERT INTO `service_history` VALUES ('93', '2', '10', '94', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-22 07:24:31', '6');
INSERT INTO `service_history` VALUES ('94', '2', '10', '95', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-22 07:28:43', '6');
INSERT INTO `service_history` VALUES ('95', '2', '10', '96', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-22 07:30:21', '6');
INSERT INTO `service_history` VALUES ('96', '2', '10', '97', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-22 07:31:35', '6');
INSERT INTO `service_history` VALUES ('97', '2', '10', '98', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-22 07:32:40', '6');
INSERT INTO `service_history` VALUES ('98', '2', '10', '99', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-22 22:11:50', '6');
INSERT INTO `service_history` VALUES ('99', '2', '10', '100', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-22 22:33:17', '6');
INSERT INTO `service_history` VALUES ('100', '2', '10', '101', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2025-12-22 22:43:31', '6');
INSERT INTO `service_history` VALUES ('101', '2', '10', '102', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-22 22:44:31', '6');
INSERT INTO `service_history` VALUES ('102', '2', '10', '103', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-23 06:58:55', '6');
INSERT INTO `service_history` VALUES ('103', '2', '10', '104', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-23 07:10:30', '6');
INSERT INTO `service_history` VALUES ('104', '2', '10', '105', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-23 07:13:10', '6');
INSERT INTO `service_history` VALUES ('105', '2', '10', '106', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-23 15:01:22', '6');
INSERT INTO `service_history` VALUES ('106', '2', '10', '107', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2025-12-23 15:02:18', '6');
INSERT INTO `service_history` VALUES ('107', '2', '10', '108', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-23 15:03:00', '6');
INSERT INTO `service_history` VALUES ('108', '2', '10', '109', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-23 15:29:15', '6');
INSERT INTO `service_history` VALUES ('109', '2', '10', '110', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-23 15:30:38', '6');
INSERT INTO `service_history` VALUES ('110', '2', '10', '111', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-23 15:31:29', '6');
INSERT INTO `service_history` VALUES ('111', '2', '10', '112', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'pending', 'efectivo', NULL, '2025-12-26 08:55:22', '6');
INSERT INTO `service_history` VALUES ('112', '2', '10', '113', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'verifying', 'efectivo', NULL, '2025-12-26 15:45:03', '6');
INSERT INTO `service_history` VALUES ('113', '2', '10', '114', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2025-12-27 20:13:43', '6');
INSERT INTO `service_history` VALUES ('114', '2', '10', '115', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2025-12-28 05:52:53', '6');
INSERT INTO `service_history` VALUES ('115', '2', '10', '116', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2025-12-28 12:46:12', '6');
INSERT INTO `service_history` VALUES ('116', '2', '10', '117', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2025-12-28 15:07:48', '6');
INSERT INTO `service_history` VALUES ('117', '2', '10', '118', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2025-12-29 03:00:11', '6');
INSERT INTO `service_history` VALUES ('118', '2', '10', '119', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2026-01-02 12:38:08', '6');
INSERT INTO `service_history` VALUES ('119', '2', '10', '120', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-02 16:18:16', '6');
INSERT INTO `service_history` VALUES ('120', '2', '10', '121', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2026-01-02 16:24:04', '6');
INSERT INTO `service_history` VALUES ('121', '2', '10', '122', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'paid', 'efectivo', NULL, '2026-01-02 16:27:34', '6');
INSERT INTO `service_history` VALUES ('122', '2', '10', '123', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2026-01-02 17:36:37', '6');
INSERT INTO `service_history` VALUES ('123', '2', '10', '124', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2026-01-02 17:40:23', '6');
INSERT INTO `service_history` VALUES ('124', '2', '10', '125', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'verifying', 'efectivo', NULL, '2026-01-02 17:52:55', '6');
INSERT INTO `service_history` VALUES ('125', '2', '10', '126', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2026-01-07 12:19:39', '6');
INSERT INTO `service_history` VALUES ('126', '2', '10', '127', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2026-01-07 12:28:48', '6');
INSERT INTO `service_history` VALUES ('127', '2', '10', '129', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-07 12:45:59', '6');
INSERT INTO `service_history` VALUES ('128', '2', '10', '130', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-07 12:55:21', '6');
INSERT INTO `service_history` VALUES ('129', '2', '10', '131', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-07 12:57:33', '6');
INSERT INTO `service_history` VALUES ('130', '2', '10', '132', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-07 13:11:01', '6');
INSERT INTO `service_history` VALUES ('131', '2', '10', '133', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-07 13:15:07', '6');
INSERT INTO `service_history` VALUES ('132', '2', '10', '134', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-07 13:15:50', '6');
INSERT INTO `service_history` VALUES ('133', '2', '10', '135', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-07 14:03:36', '6');
INSERT INTO `service_history` VALUES ('134', '2', '10', '137', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-07 14:15:18', '6');
INSERT INTO `service_history` VALUES ('135', '2', '10', '138', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-07 14:38:26', '6');
INSERT INTO `service_history` VALUES ('136', '2', '10', '140', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-07 14:42:52', '6');
INSERT INTO `service_history` VALUES ('137', '2', '10', '141', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-07 16:07:31', '6');
INSERT INTO `service_history` VALUES ('138', '2', '10', '142', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-07 16:08:30', '6');
INSERT INTO `service_history` VALUES ('139', '2', '10', '143', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-07 16:13:25', '6');
INSERT INTO `service_history` VALUES ('140', '2', '10', '144', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-09 01:06:58', '6');
INSERT INTO `service_history` VALUES ('141', '2', '10', '145', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-09 05:43:07', '6');
INSERT INTO `service_history` VALUES ('142', '2', '10', '146', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-09 05:46:07', '6');
INSERT INTO `service_history` VALUES ('143', '2', '10', '147', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-09 05:49:27', '6');
INSERT INTO `service_history` VALUES ('144', '2', '10', '148', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-09 06:17:38', '6');
INSERT INTO `service_history` VALUES ('145', '2', '10', '149', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-09 15:04:20', '6');
INSERT INTO `service_history` VALUES ('146', '2', '10', '150', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-09 15:05:24', '6');
INSERT INTO `service_history` VALUES ('147', '2', '10', '151', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-09 23:37:57', '6');
INSERT INTO `service_history` VALUES ('148', '2', '10', '152', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-09 23:38:30', '6');
INSERT INTO `service_history` VALUES ('149', '2', '10', '153', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-09 23:39:29', '6');
INSERT INTO `service_history` VALUES ('150', '2', '10', '155', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-10 01:05:24', '6');
INSERT INTO `service_history` VALUES ('151', '2', '10', '156', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-10 01:06:47', '6');
INSERT INTO `service_history` VALUES ('152', '2', '10', '157', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-10 18:39:57', '6');
INSERT INTO `service_history` VALUES ('153', '2', '10', '158', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-10 18:41:38', '6');
INSERT INTO `service_history` VALUES ('154', '2', '10', '159', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-10 18:44:21', '6');
INSERT INTO `service_history` VALUES ('155', '2', '10', '160', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'verifying', 'efectivo', NULL, '2026-01-10 21:53:23', '6');
INSERT INTO `service_history` VALUES ('156', '2', '10', '161', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2026-01-10 21:55:48', '6');
INSERT INTO `service_history` VALUES ('157', '2', '10', '165', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-11 14:07:46', '6');
INSERT INTO `service_history` VALUES ('158', '2', '10', '169', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'verifying', 'efectivo', NULL, '2026-01-12 00:09:37', '6');
INSERT INTO `service_history` VALUES ('159', '2', '10', '171', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-12 06:59:47', '6');
INSERT INTO `service_history` VALUES ('160', '2', '10', '173', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-12 07:01:55', '6');
INSERT INTO `service_history` VALUES ('161', '2', '10', '174', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-12 07:53:53', '6');
INSERT INTO `service_history` VALUES ('162', '2', '10', '177', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'verifying', 'efectivo', NULL, '2026-01-12 11:16:22', '6');
INSERT INTO `service_history` VALUES ('163', '2', '10', '179', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-12 11:19:00', '6');
INSERT INTO `service_history` VALUES ('164', '2', '10', '183', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-12 18:39:24', '6');
INSERT INTO `service_history` VALUES ('165', '2', '10', '184', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-12 18:40:19', '6');
INSERT INTO `service_history` VALUES ('166', '2', '10', '191', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-13 08:33:39', '6');
INSERT INTO `service_history` VALUES ('167', '2', '10', '195', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-13 08:47:01', '6');
INSERT INTO `service_history` VALUES ('168', '2', '10', '199', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-13 08:48:49', '6');
INSERT INTO `service_history` VALUES ('169', '2', '10', '206', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-13 09:50:59', '6');
INSERT INTO `service_history` VALUES ('170', '2', '10', '16', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-14 23:06:13', '6');
INSERT INTO `service_history` VALUES ('171', '2', '10', '18', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-14 23:25:46', '6');
INSERT INTO `service_history` VALUES ('172', '2', '10', '37', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-15 09:14:30', '6');
INSERT INTO `service_history` VALUES ('173', '2', '10', '38', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'verifying', 'efectivo', NULL, '2026-01-15 09:14:33', '6');
INSERT INTO `service_history` VALUES ('174', '2', '10', '39', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-15 09:19:30', '6');
INSERT INTO `service_history` VALUES ('175', '2', '10', '40', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'verifying', 'efectivo', NULL, '2026-01-15 09:20:38', '6');
INSERT INTO `service_history` VALUES ('176', '2', '10', '48', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-15 09:52:24', '6');
INSERT INTO `service_history` VALUES ('177', '2', '10', '52', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-15 09:55:14', '6');
INSERT INTO `service_history` VALUES ('178', '2', '10', '56', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-15 10:25:59', '6');
INSERT INTO `service_history` VALUES ('179', '2', '10', '58', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-15 22:44:46', '6');
INSERT INTO `service_history` VALUES ('180', '2', '10', '59', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-15 22:45:43', '6');
INSERT INTO `service_history` VALUES ('181', '2', '10', '62', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-15 23:33:36', '6');
INSERT INTO `service_history` VALUES ('182', '2', '10', '65', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-16 06:43:23', '6');
INSERT INTO `service_history` VALUES ('183', '2', '10', '66', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-16 07:31:32', '6');
INSERT INTO `service_history` VALUES ('184', '2', '10', '67', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-16 07:36:01', '6');
INSERT INTO `service_history` VALUES ('185', '2', '10', '69', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-16 10:47:33', '6');
INSERT INTO `service_history` VALUES ('186', '2', '10', '70', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-16 11:07:39', '6');
INSERT INTO `service_history` VALUES ('187', '2', '10', '71', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-16 11:09:03', '6');
INSERT INTO `service_history` VALUES ('188', '2', '10', '72', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-16 11:27:50', '6');
INSERT INTO `service_history` VALUES ('189', '2', '10', '73', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-16 11:49:42', '6');
INSERT INTO `service_history` VALUES ('190', '2', '10', '74', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-16 11:51:19', '6');
INSERT INTO `service_history` VALUES ('191', '2', '10', '75', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-16 19:43:38', '6');
INSERT INTO `service_history` VALUES ('192', '2', '10', '76', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-16 20:01:39', '6');
INSERT INTO `service_history` VALUES ('193', '2', '10', '1', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-16 20:41:57', '6');
INSERT INTO `service_history` VALUES ('194', '2', '10', '2', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-16 20:45:25', '6');
INSERT INTO `service_history` VALUES ('195', '2', '10', '3', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-17 09:18:10', '6');
INSERT INTO `service_history` VALUES ('196', '2', '10', '4', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-17 09:20:56', '6');
INSERT INTO `service_history` VALUES ('197', '2', '10', '5', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-17 09:22:33', '6');
INSERT INTO `service_history` VALUES ('198', '2', '10', '6', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-17 09:24:48', '6');
INSERT INTO `service_history` VALUES ('199', '2', '10', '7', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-17 10:35:46', '6');
INSERT INTO `service_history` VALUES ('200', '2', '10', '8', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-17 20:57:15', '6');
INSERT INTO `service_history` VALUES ('201', '2', '10', '9', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-25 12:45:44', '6');
INSERT INTO `service_history` VALUES ('202', '2', '10', '11', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-25 12:49:47', '6');
INSERT INTO `service_history` VALUES ('203', '2', '10', '12', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-26 17:23:22', '6');
INSERT INTO `service_history` VALUES ('204', '2', '12', '13', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-27 23:22:44', '6');
INSERT INTO `service_history` VALUES ('205', '2', '12', '15', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2026-01-29 19:38:59', '6');
INSERT INTO `service_history` VALUES ('206', '2', '12', '19', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-01-30 05:24:00', '6');
INSERT INTO `service_history` VALUES ('207', '2', '11', '17', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2026-01-30 05:29:04', '6');
INSERT INTO `service_history` VALUES ('208', '2', '12', '14', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2026-01-30 05:29:10', '6');
INSERT INTO `service_history` VALUES ('209', '2', '12', '20', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-02-18 18:35:10', '6');
INSERT INTO `service_history` VALUES ('210', '2', '12', '25', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2026-05-04 23:16:52', '6');
INSERT INTO `service_history` VALUES ('211', '2', '10', '24', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2026-05-05 00:10:52', '6');
INSERT INTO `service_history` VALUES ('212', '2', '11', '28', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-05-10 06:15:59', '6');
INSERT INTO `service_history` VALUES ('213', '2', '12', '29', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-05-10 06:20:54', '6');
INSERT INTO `service_history` VALUES ('214', '2', '12', '30', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-05-10 06:23:41', '6');
INSERT INTO `service_history` VALUES ('215', '2', '12', '31', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-05-10 06:55:33', '6');
INSERT INTO `service_history` VALUES ('216', '2', '12', '33', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-05-12 10:46:56', '6');
INSERT INTO `service_history` VALUES ('217', '2', '12', '40', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-05-13 06:41:31', '6');
INSERT INTO `service_history` VALUES ('218', '2', '10', '41', 'Airline', NULL, '35.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2026-05-15 09:05:05', '6');
INSERT INTO `service_history` VALUES ('219', '2', '12', '43', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-05-15 14:15:47', '6');
INSERT INTO `service_history` VALUES ('220', '2', '11', '44', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-05-15 14:19:22', '6');
INSERT INTO `service_history` VALUES ('221', '2', '12', '46', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-05-16 09:55:48', '6');
INSERT INTO `service_history` VALUES ('222', '2', '12', '47', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'cancelled', 'pending', 'efectivo', NULL, '2026-05-16 10:26:57', '6');
INSERT INTO `service_history` VALUES ('223', '2', '11', '51', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2026-05-16 12:53:18', '6');
INSERT INTO `service_history` VALUES ('224', '2', '12', '52', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2026-05-16 14:43:39', '6');
INSERT INTO `service_history` VALUES ('225', '2', '11', '53', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2026-05-16 15:07:22', '6');
INSERT INTO `service_history` VALUES ('226', '2', '11', '54', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2026-05-16 21:51:58', '6');
INSERT INTO `service_history` VALUES ('227', '2', '11', '55', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2026-05-16 22:51:33', '6');
INSERT INTO `service_history` VALUES ('228', '2', '11', '56', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2026-05-17 06:17:41', '6');
INSERT INTO `service_history` VALUES ('229', '2', '11', '57', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2026-05-17 06:23:19', '6');
INSERT INTO `service_history` VALUES ('230', '2', '11', '58', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2026-05-17 08:43:55', '6');
INSERT INTO `service_history` VALUES ('231', '2', '12', '59', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2026-05-17 08:59:48', '6');
INSERT INTO `service_history` VALUES ('232', '2', '11', '60', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2026-05-17 09:58:50', '6');
INSERT INTO `service_history` VALUES ('233', '2', '12', '61', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2026-05-17 11:07:41', '6');
INSERT INTO `service_history` VALUES ('234', '2', '11', '62', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2026-05-17 18:54:07', '6');
INSERT INTO `service_history` VALUES ('235', '2', '12', '63', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2026-05-17 18:56:00', '6');
INSERT INTO `service_history` VALUES ('236', '2', '12', '64', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2026-05-17 19:54:30', '6');
INSERT INTO `service_history` VALUES ('237', '2', '12', '65', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2026-05-17 20:09:43', '6');
INSERT INTO `service_history` VALUES ('238', '2', '12', '66', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2026-05-17 20:52:48', '6');
INSERT INTO `service_history` VALUES ('239', '2', '11', '67', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2026-05-17 21:17:15', '6');
INSERT INTO `service_history` VALUES ('240', '2', '12', '68', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2026-05-17 21:43:45', '6');
INSERT INTO `service_history` VALUES ('241', '2', '11', '69', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2026-05-17 22:06:46', '6');
INSERT INTO `service_history` VALUES ('242', '2', '11', '70', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2026-05-17 22:26:56', '6');
INSERT INTO `service_history` VALUES ('243', '2', '11', '71', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2026-05-18 08:27:10', '6');
INSERT INTO `service_history` VALUES ('244', '2', '12', '72', 'Lavado general', NULL, '10.00', NULL, NULL, 'María Villegas', 'completed', 'paid', 'efectivo', NULL, '2026-05-18 08:31:30', '6');

DROP TABLE IF EXISTS `service_requests`;
CREATE TABLE `service_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `service_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `provider_id` int(11) NOT NULL,
  `status` enum('pending','accepted','in_progress','on_the_way','arrived','completed','cancelled','rejected','busy') NOT NULL DEFAULT 'pending',
  `cancelled_by` enum('user','provider') DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `payment_method` enum('efectivo','pago-movil','transferencia') DEFAULT 'efectivo',
  `additional_details` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `payment_status` enum('pending','verifying','paid','cancelled','rejected','refunded','partially_refunded','disputed','expired','failed','processing','cancelled_by_user','cancelled_by_provider','on_hold') DEFAULT 'pending',
  `payment_proof_url` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `service_id` (`service_id`),
  KEY `user_id` (`user_id`),
  KEY `provider_id` (`provider_id`),
  KEY `idx_payment_status` (`payment_status`),
  CONSTRAINT `service_requests_ibfk_1` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`),
  CONSTRAINT `service_requests_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `service_requests_ibfk_3` FOREIGN KEY (`provider_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=73 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

INSERT INTO `service_requests` VALUES ('10', '10', '2', '6', 'busy', NULL, '35.00', 'efectivo', '', '2026-01-25 12:46:42', '2026-01-25 12:47:48', 'pending', NULL);
INSERT INTO `service_requests` VALUES ('16', '11', '2', '6', 'rejected', NULL, '10.00', 'efectivo', '', '2026-01-29 15:28:38', '2026-01-29 18:25:11', 'pending', NULL);
INSERT INTO `service_requests` VALUES ('18', '12', '2', '6', 'busy', NULL, '10.00', 'efectivo', '', '2026-01-29 19:36:51', '2026-01-29 19:38:06', 'pending', NULL);
INSERT INTO `service_requests` VALUES ('21', '12', '2', '6', 'rejected', NULL, '10.00', 'efectivo', '', '2026-05-04 09:54:50', '2026-05-04 11:10:14', 'pending', NULL);
INSERT INTO `service_requests` VALUES ('22', '10', '2', '6', 'rejected', NULL, '35.00', 'efectivo', '', '2026-05-04 11:05:14', '2026-05-04 11:10:12', 'pending', NULL);
INSERT INTO `service_requests` VALUES ('23', '11', '2', '6', 'rejected', NULL, '10.00', 'efectivo', '', '2026-05-04 11:08:43', '2026-05-04 11:10:11', 'pending', NULL);
INSERT INTO `service_requests` VALUES ('26', '11', '2', '6', 'rejected', NULL, '10.00', 'efectivo', '', '2026-05-04 11:17:17', '2026-05-04 11:18:14', 'pending', NULL);
INSERT INTO `service_requests` VALUES ('27', '12', '2', '6', 'rejected', NULL, '10.00', 'efectivo', '', '2026-05-07 00:35:17', '2026-05-10 06:18:39', 'pending', NULL);
INSERT INTO `service_requests` VALUES ('32', '12', '2', '6', 'busy', NULL, '10.00', 'efectivo', '', '2026-05-10 06:55:48', '2026-05-10 06:56:16', 'pending', NULL);
INSERT INTO `service_requests` VALUES ('34', '12', '2', '6', 'rejected', NULL, '10.00', 'efectivo', '', '2026-05-12 21:33:07', '2026-05-12 21:33:17', 'pending', NULL);
INSERT INTO `service_requests` VALUES ('35', '12', '2', '6', 'rejected', NULL, '10.00', 'efectivo', '', '2026-05-12 21:40:05', '2026-05-12 21:41:22', 'pending', NULL);
INSERT INTO `service_requests` VALUES ('36', '12', '2', '6', 'rejected', NULL, '10.00', 'efectivo', '', '2026-05-12 21:54:07', '2026-05-13 00:05:24', 'pending', NULL);
INSERT INTO `service_requests` VALUES ('37', '12', '2', '6', 'busy', NULL, '10.00', 'efectivo', '', '2026-05-13 00:05:50', '2026-05-13 00:06:12', 'pending', NULL);
INSERT INTO `service_requests` VALUES ('38', '12', '2', '6', 'rejected', NULL, '10.00', 'efectivo', '', '2026-05-13 00:27:05', '2026-05-13 00:28:32', 'pending', NULL);
INSERT INTO `service_requests` VALUES ('39', '12', '2', '6', 'rejected', NULL, '10.00', 'efectivo', '', '2026-05-13 00:29:06', '2026-05-13 00:30:27', 'pending', NULL);
INSERT INTO `service_requests` VALUES ('42', '12', '2', '6', 'rejected', NULL, '10.00', 'efectivo', '', '2026-05-15 09:06:07', '2026-05-15 09:06:16', 'pending', NULL);
INSERT INTO `service_requests` VALUES ('45', '10', '2', '6', 'busy', NULL, '35.00', 'efectivo', '', '2026-05-15 15:13:20', '2026-05-15 15:14:02', 'pending', NULL);
INSERT INTO `service_requests` VALUES ('48', '12', '2', '6', 'busy', NULL, '10.00', 'efectivo', '', '2026-05-16 10:35:20', '2026-05-16 10:35:23', 'pending', NULL);
INSERT INTO `service_requests` VALUES ('49', '11', '2', '6', 'busy', NULL, '10.00', 'efectivo', '', '2026-05-16 12:51:45', '2026-05-16 12:51:49', 'pending', NULL);
INSERT INTO `service_requests` VALUES ('50', '11', '2', '6', 'rejected', NULL, '10.00', 'efectivo', '', '2026-05-16 12:52:02', '2026-05-16 12:52:04', 'pending', NULL);

DROP TABLE IF EXISTS `service_reviews`;
CREATE TABLE `service_reviews` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `service_history_id` bigint(20) NOT NULL,
  `user_id` int(11) NOT NULL,
  `provider_id` int(11) NOT NULL,
  `rating` tinyint(4) NOT NULL,
  `comment` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `tags` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '[]' CHECK (json_valid(`tags`)),
  `photos` longtext DEFAULT '[]',
  PRIMARY KEY (`id`),
  KEY `service_history_id` (`service_history_id`),
  KEY `user_id` (`user_id`),
  KEY `provider_id` (`provider_id`),
  CONSTRAINT `service_reviews_ibfk_1` FOREIGN KEY (`service_history_id`) REFERENCES `service_history` (`id`),
  CONSTRAINT `service_reviews_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `service_reviews_ibfk_3` FOREIGN KEY (`provider_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

INSERT INTO `service_reviews` VALUES ('1', '1', '2', '6', '3', 'Que pasó ramon', '2025-11-09 05:35:07', '[]', '[]');
INSERT INTO `service_reviews` VALUES ('2', '4', '2', '6', '5', 'Hola me gustó tu trato 😉☺️', '2025-12-03 19:56:32', '[]', '[]');
INSERT INTO `service_reviews` VALUES ('3', '22', '2', '6', '3', 'Encantado ', '2025-12-16 05:39:36', '[]', '[]');
INSERT INTO `service_reviews` VALUES ('4', '19', '2', '6', '4', 'Uhiufyfuuufuugufufufuufu', '2025-12-16 09:50:03', '[]', '[]');
INSERT INTO `service_reviews` VALUES ('5', '12', '2', '6', '4', 'Holhhggh', '2025-12-16 09:58:26', '[]', '[]');
INSERT INTO `service_reviews` VALUES ('6', '23', '2', '6', '4', '', '2025-12-16 12:09:04', '[]', '[\"http:\\/\\/localhost:8000\\/uploads\\/reviews\\/23\\/5440660f20f31ca8.jpg\"]');
INSERT INTO `service_reviews` VALUES ('7', '27', '2', '6', '5', 'Hola', '2025-12-16 14:57:15', '[]', '[\"http:\\/\\/localhost:8000\\/uploads\\/reviews\\/27\\/0ca2fde4f530cced.jpg\"]');
INSERT INTO `service_reviews` VALUES ('8', '68', '2', '6', '3', 'Hola', '2025-12-17 17:33:47', '[\"Profesional\"]', '[\"http:\\/\\/localhost:8000\\/uploads\\/reviews\\/68\\/4b8d0fa834f2129c.jpg\"]');
INSERT INTO `service_reviews` VALUES ('9', '69', '2', '6', '4', 'Hhhjh chuta', '2025-12-17 17:36:24', '[]', '[\"http:\\/\\/localhost:8000\\/uploads\\/reviews\\/69\\/34116c21e463b243.jpg\"]');
INSERT INTO `service_reviews` VALUES ('10', '75', '2', '6', '4', 'Gato feliz pendejo ', '2025-12-17 22:44:44', '[]', '[\"http:\\/\\/localhost:8000\\/uploads\\/reviews\\/75\\/16d7e8aa0fcb5a5a.jpg\"]');
INSERT INTO `service_reviews` VALUES ('11', '84', '2', '6', '4', 'Pendejo tú', '2025-12-19 06:53:21', '[\"Profesional\",\"Puntual\"]', '[\"http:\\/\\/localhost:8000\\/uploads\\/reviews\\/84\\/f4b0cf4972469926.jpg\"]');
INSERT INTO `service_reviews` VALUES ('12', '88', '2', '6', '5', 'Para adelante bartolo', '2025-12-19 20:56:37', '[\"Puntual\",\"Profesional\",\"Calidad\",\"Limpio\",\"Buen precio\",\"Amable\"]', '[\"http:\\/\\/localhost:8000\\/uploads\\/reviews\\/88\\/60f7ce5b87e18d9b.jpg\"]');
INSERT INTO `service_reviews` VALUES ('13', '107', '2', '6', '4', 'Q', '2025-12-23 15:10:16', '[]', '[]');
INSERT INTO `service_reviews` VALUES ('14', '108', '2', '6', '5', 'Hdhdjddjjf', '2025-12-23 15:29:40', '[]', '[]');
INSERT INTO `service_reviews` VALUES ('15', '111', '2', '6', '3', 'Todo fino mano', '2025-12-26 08:56:44', '[\"Buen precio\"]', '[\"http:\\/\\/localhost:8000\\/uploads\\/reviews\\/111\\/ff6a65c5b89d73eb.jpg\"]');
INSERT INTO `service_reviews` VALUES ('16', '113', '2', '6', '5', 'Gracias por tu servicio', '2025-12-27 20:14:52', '[\"Puntual\"]', '[\"http:\\/\\/localhost:8000\\/uploads\\/reviews\\/113\\/c5d242f1248094b5.jpg\"]');
INSERT INTO `service_reviews` VALUES ('17', '114', '2', '6', '5', 'Pendejo tú', '2025-12-28 05:53:31', '[]', '[]');
INSERT INTO `service_reviews` VALUES ('18', '115', '2', '6', '5', 'Hulooo', '2025-12-28 12:49:42', '[\"Calidad\"]', '[]');
INSERT INTO `service_reviews` VALUES ('19', '117', '2', '6', '5', 'Cabron!?', '2025-12-29 03:00:55', '[\"Limpio\"]', '[]');
INSERT INTO `service_reviews` VALUES ('20', '57', '6', '6', '4', '', '2026-05-17 08:44:06', '[\"Calidad\"]', '[]');
INSERT INTO `service_reviews` VALUES ('21', '59', '6', '6', '3', '', '2026-05-17 09:59:03', '[\"Calidad\"]', '[]');
INSERT INTO `service_reviews` VALUES ('22', '67', '6', '6', '3', 'Hola', '2026-05-17 21:44:01', '[\"Puntual\"]', '[]');
INSERT INTO `service_reviews` VALUES ('23', '68', '6', '6', '3', '', '2026-05-17 22:07:02', '[]', '[]');

DROP TABLE IF EXISTS `services`;
CREATE TABLE `services` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `title` varchar(100) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `status` enum('pending','active','inactive','completed') DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `price` int(11) NOT NULL,
  `category` varchar(100) DEFAULT NULL,
  `location` varchar(150) DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `provider_name` varchar(100) DEFAULT NULL,
  `provider_avatar_url` varchar(255) DEFAULT NULL,
  `provider_rating` decimal(2,1) DEFAULT 5.0,
  `isAvailable` tinyint(1) NOT NULL DEFAULT 1,
  `service_details` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

INSERT INTO `services` VALUES ('10', '6', 'Airline', 'Viene con nosotros', 'active', '2025-09-14 23:22:35', '35', 'Promotora', 'San felipe', NULL, 'María Villegas', 'avatar_1755532362.jpg', '0.0', '1', 'A\r\nB\r\nC\r\nD');
INSERT INTO `services` VALUES ('11', '6', 'Lavado general', 'Servicio de lavado completo', 'active', '2025-12-08 13:00:49', '10', 'Automóvil', 'San Felipe', NULL, 'María Villegas', 'avatar_1755532362.jpg', '4.0', '1', '');
INSERT INTO `services` VALUES ('12', '6', 'Lavado general', 'Servicio de lavado completo', 'active', '2025-12-08 13:01:45', '10', 'Automóvil', 'San Felipe', NULL, 'María Villegas', 'avatar_1755532362.jpg', '4.0', '1', '');

DROP TABLE IF EXISTS `sessions`;
CREATE TABLE `sessions` (
  `id` varchar(128) NOT NULL,
  `user_id` int(11) NOT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` text DEFAULT NULL,
  `last_activity` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_last_activity` (`last_activity`),
  CONSTRAINT `sessions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;


DROP TABLE IF EXISTS `static_pages`;
CREATE TABLE `static_pages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(200) NOT NULL,
  `slug` varchar(200) NOT NULL,
  `content` longtext DEFAULT NULL,
  `meta_title` varchar(200) DEFAULT NULL,
  `meta_description` text DEFAULT NULL,
  `meta_keywords` varchar(500) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `is_in_menu` tinyint(1) DEFAULT 0,
  `sort_order` int(11) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`),
  KEY `idx_slug` (`slug`),
  KEY `idx_active` (`is_active`),
  KEY `idx_menu` (`is_in_menu`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

INSERT INTO `static_pages` VALUES ('1', 'Términos y Condiciones', 'terms', '<h1>Términos y Condiciones</h1><p>Contenido de términos y condiciones...</p>', NULL, NULL, NULL, '1', '1', '1', '2026-01-31 21:35:00', '2026-01-31 21:35:00');
INSERT INTO `static_pages` VALUES ('2', 'Política de Privacidad', 'privacy', '<h1>Política de Privacidad</h1><p>Contenido de política de privacidad...</p>', NULL, NULL, NULL, '1', '1', '2', '2026-01-31 21:35:00', '2026-01-31 21:35:00');
INSERT INTO `static_pages` VALUES ('3', 'Acerca de Nosotros', 'about', '<h1>Acerca de TapClic</h1><p>Información sobre nuestra empresa...</p>', NULL, NULL, NULL, '1', '1', '3', '2026-01-31 21:35:00', '2026-01-31 21:35:00');
INSERT INTO `static_pages` VALUES ('4', 'Ayuda y Soporte', 'help', '<h1>Ayuda y Soporte</h1><p>Guías y ayuda para usuarios...</p>', NULL, NULL, NULL, '1', '1', '4', '2026-01-31 21:35:00', '2026-01-31 21:35:00');
INSERT INTO `static_pages` VALUES ('5', 'Contacto', 'contact', '<h1>Contacto</h1><p>Información de contacto...</p>', NULL, NULL, NULL, '1', '1', '5', '2026-01-31 21:35:00', '2026-01-31 21:35:00');

DROP TABLE IF EXISTS `support_tickets`;
CREATE TABLE `support_tickets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `category` varchar(50) DEFAULT 'other',
  `priority` enum('low','medium','high','urgent') DEFAULT 'medium',
  `status` enum('open','pending','closed') DEFAULT 'open',
  `assigned_to` int(11) DEFAULT NULL,
  `tags` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`tags`)),
  `response_count` int(11) DEFAULT 0,
  `last_response_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_assigned_to` (`assigned_to`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

INSERT INTO `support_tickets` VALUES ('1', '6', 'problema', 'No me pagaron', 'payment', 'high', 'closed', '1', NULL, '0', NULL, '2025-10-03 08:22:14', '2026-04-27 05:56:18');
INSERT INTO `support_tickets` VALUES ('2', '2', 'Problema dos', 'Tengo un dedito pantu culito', 'account', 'medium', 'open', '1', NULL, '0', NULL, '2026-01-17 20:28:48', '2026-04-27 07:10:34');
INSERT INTO `support_tickets` VALUES ('3', '2', 'Problema', 'No me pagaron', 'payment', 'medium', 'open', NULL, NULL, '0', NULL, '2026-01-25 12:53:30', '2026-01-25 12:53:30');
INSERT INTO `support_tickets` VALUES ('4', '6', 'No me devolvieron', 'Después me pagas', 'technical', 'low', 'closed', NULL, '[{\"name\":\"Gggh\",\"color\":\"blue\"}]', '0', NULL, '2026-01-25 12:54:08', '2026-02-21 15:04:13');

DROP TABLE IF EXISTS `system_config`;
CREATE TABLE `system_config` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `system_name` varchar(150) NOT NULL,
  `system_host` varchar(255) NOT NULL,
  `ws_host` varchar(255) DEFAULT NULL,
  `system_active` tinyint(1) DEFAULT 1,
  `system_version` varchar(50) NOT NULL,
  `system_logo` varchar(255) DEFAULT NULL,
  `system_favicon` varchar(255) DEFAULT NULL,
  `default_language` varchar(10) DEFAULT 'es',
  `timezone` varchar(100) DEFAULT 'UTC',
  `currency` varchar(10) DEFAULT 'USD',
  `support_email` varchar(150) DEFAULT NULL,
  `support_phone` varchar(50) DEFAULT NULL,
  `mail_host` varchar(255) DEFAULT 'smtp.gmail.com',
  `mail_port` int(11) DEFAULT 587,
  `mail_encryption` varchar(10) DEFAULT 'tls',
  `mail_username` varchar(255) DEFAULT NULL,
  `mail_password` varchar(255) DEFAULT NULL,
  `mail_from` varchar(255) DEFAULT 'notificaciones@tapclic.com',
  `mail_from_name` varchar(150) DEFAULT 'TapClic',
  `twilio_sid` varchar(255) DEFAULT NULL,
  `twilio_token` varchar(255) DEFAULT NULL,
  `twilio_phone` varchar(50) DEFAULT NULL,
  `company_name` varchar(150) DEFAULT NULL,
  `company_address` varchar(255) DEFAULT NULL,
  `maintenance_mode` tinyint(1) DEFAULT 0,
  `max_login_attempts` int(11) DEFAULT 5,
  `password_expiration_days` int(11) DEFAULT 90,
  `session_timeout_minutes` int(11) DEFAULT 30,
  `items_per_page` int(11) DEFAULT 20,
  `theme_color` varchar(20) DEFAULT '#409EFF',
  `allow_user_registration` tinyint(1) DEFAULT 1,
  `wallet_enabled` tinyint(1) DEFAULT 1,
  `reviews_enabled` tinyint(1) DEFAULT 1,
  `chat_enabled` tinyint(1) DEFAULT 1,
  `tickets_enabled` tinyint(1) DEFAULT 1,
  `analytics_enabled` tinyint(1) DEFAULT 1,
  `extra_json` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `payment_default_commission` decimal(5,2) DEFAULT 10.00,
  `payment_min_commission` decimal(10,2) DEFAULT 1.00,
  `payment_currency` varchar(10) DEFAULT 'USD',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

INSERT INTO `system_config` VALUES ('1', 'TapClic', 'http://192.168.142.12:5173', 'http://192.168.142.12:3001', '1', '1.0.0', '/assets/logo.png', '/assets/favicon.ico', 'es', 'America/Caracas', 'USD', 'soporte@tapclic.com', '+58 123 456 7890', 'smtp.gmail.com', '587', 'tls', NULL, NULL, 'notificaciones@tapclic.com', 'TapClic', NULL, NULL, NULL, 'TapClic C.A.', 'Yaracuy, Venezuela', '0', '5', '90', '30', '20', '#409EFF', '1', '0', '1', '1', '1', '1', NULL, '2025-08-17 17:44:41', '2026-05-19 06:25:37', NULL, NULL, NULL);

DROP TABLE IF EXISTS `ticket_replies`;
CREATE TABLE `ticket_replies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ticket_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `user_type` enum('user','admin') NOT NULL,
  `message` text NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `idx_ticket` (`ticket_id`),
  CONSTRAINT `ticket_replies_ibfk_1` FOREIGN KEY (`ticket_id`) REFERENCES `support_tickets` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ticket_replies_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;


DROP TABLE IF EXISTS `token_blacklist`;
CREATE TABLE `token_blacklist` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `token` varchar(512) NOT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `revoked_by_ip` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_token` (`token`(255)),
  KEY `idx_expires` (`expires_at`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `token_blacklist` VALUES ('3', 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3NzM0MDQ3Njd9.2t67mqo9JOYkMoVaoNXRkk0U7iD8RGkZ44gfCz7nM8I', NULL, '2026-04-27 05:51:17', '192.168.0.100');
INSERT INTO `token_blacklist` VALUES ('4', 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3Nzk0NTQ3MjF9.dJ2FbSrw6F2lFNK8Qjqmz67x_IPx9AAnW8omEccUNNU', '2026-05-22 12:58:41', '2026-05-17 18:37:08', '192.168.46.12');
INSERT INTO `token_blacklist` VALUES ('6', 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3NzkwMTUwNTh9.-dcUjD1otxZlPfrl_BQyt580c0nVDulf9ZUh-W5vmHU', NULL, '2026-05-17 18:37:20', '192.168.46.12');
INSERT INTO `token_blacklist` VALUES ('7', 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3Nzc4NDU2MzZ9.vp4uZiUSYeeBO2AtKfgSYRzx-7OoptU9CmVztr0a-9E', NULL, '2026-05-17 18:37:26', '192.168.46.12');
INSERT INTO `token_blacklist` VALUES ('8', 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3Nzc5NzUxNDB9.Dn_sTR5sDbtOCqJtEbB5Bhsni0FiDPBXi7a9qh9Gsuk', NULL, '2026-05-17 18:37:32', '192.168.46.12');
INSERT INTO `token_blacklist` VALUES ('9', 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3Nzg1MTI2MTZ9.paPHkdnHtXIWHzj5wnXqUm6qIJZq_whL5iSBBTBO8bo', NULL, '2026-05-17 18:37:37', '192.168.46.12');
INSERT INTO `token_blacklist` VALUES ('10', 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3Nzg1OTAwMjZ9.u8yfJSUCF-tycSE2ERjYsuzFC8c5eaIQxCXJjEv9QUw', NULL, '2026-05-17 18:37:41', '192.168.46.12');
INSERT INTO `token_blacklist` VALUES ('11', 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3Nzg1OTAyODd9.Y4_Mv0X0xA3Q0-i1OxTosLPMy3CvRlPEMQbOdOHuipo', NULL, '2026-05-17 18:37:45', '192.168.46.12');
INSERT INTO `token_blacklist` VALUES ('12', 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3NzkwMTIzNjN9.W1RB6U0WtXz6IYZwxKDnIuKTBgjBJ60JDW5Ed5yG5pc', NULL, '2026-05-17 18:37:48', '192.168.46.12');

DROP TABLE IF EXISTS `user_devices`;
CREATE TABLE `user_devices` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `device_name` varchar(255) NOT NULL,
  `device_type` varchar(50) DEFAULT 'unknown',
  `browser` varchar(100) DEFAULT NULL,
  `platform` varchar(100) DEFAULT NULL,
  `device_fingerprint` varchar(64) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `last_active` timestamp NULL DEFAULT current_timestamp(),
  `is_current` tinyint(1) DEFAULT 0,
  `refresh_token` varchar(512) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_last_active` (`last_active`),
  KEY `idx_fingerprint` (`device_fingerprint`),
  CONSTRAINT `user_devices_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=66 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

INSERT INTO `user_devices` VALUES ('5', '1', '💻 Linux - Chrome', 'desktop', 'Chrome', 'Linux', 'd11d9f2490f98b31139a2744b8668cf2', '192.168.1.248', NULL, '2026-02-23 14:31:47', '0', 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MSwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzcyNDc2MzA3fQ.wNcPKKLV42qDTIhk_05utc-GvoXf7r5WtSQYHAdDLdA', '2026-02-17 13:48:55', '2026-04-27 07:08:20');
INSERT INTO `user_devices` VALUES ('6', '1', '💻 Desconocido - Desconocido', 'desktop', 'Desconocido', 'Desconocido', 'edea46c721b25f1c04097ebf315a06ad', '192.168.1.248', NULL, '2026-02-22 22:24:15', '0', 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MSwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzcyNDE4MjU1fQ._Q8ho0albMsGwjodGo764DawjXAWDWMHyuQU4GaJY04', '2026-02-17 23:05:46', '2026-02-23 14:31:47');
INSERT INTO `user_devices` VALUES ('9', '1', '📱 Android - Chrome', 'mobile', 'Chrome', 'Android', NULL, '192.168.1.103', NULL, '2026-02-21 11:31:38', '0', 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MSwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzcyMjkyNjk4fQ.IuAmCdLOceQ5uh3lN_juGFW4RNIR82nbziKA1KcaLAs', '2026-02-21 11:31:38', '2026-02-21 13:07:57');
INSERT INTO `user_devices` VALUES ('44', '1', '💻 Linux - Chrome', 'desktop', 'Chrome', 'Linux', '98dfabfd8eb66054824a069370f90231', '192.168.0.100', NULL, '2026-04-27 07:08:20', '0', 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MSwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzc3ODkyOTAwfQ.4r3Wk96lZ9xJMYDrWsnue-EtEQTxlPASPulkisO1ziI', '2026-04-27 07:08:20', '2026-05-18 09:40:00');
INSERT INTO `user_devices` VALUES ('49', '6', '📱 Android - Chrome', 'mobile', 'Chrome', 'Android', '5221370a120750bcf5151970a286680a', '192.168.31.219', NULL, '2026-05-07 00:39:25', '0', 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Niwicm9sZSI6InByb3ZpZGVyIiwiZXhwIjoxNzc4NzMzNTY1fQ.nxNsOv2atMpCeyF2r9rBVw_XM-Rg_7Gu7anGeP5EXME', '2026-05-07 00:39:12', '2026-05-10 06:14:42');
INSERT INTO `user_devices` VALUES ('51', '6', '📱 Android - Chrome', 'mobile', 'Chrome', 'Android', '3de1e17f5aafcbed30ba4f9fe3272e98', '192.168.1.100', NULL, '2026-05-10 06:18:10', '0', 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Niwicm9sZSI6InByb3ZpZGVyIiwiZXhwIjoxNzc5MDEzMDkwfQ.QDuMzGD_86fdt3bSXxjKxkCD4Wq_aAe_0f0TJ8cgSK8', '2026-05-10 06:14:42', '2026-05-10 06:52:36');
INSERT INTO `user_devices` VALUES ('53', '6', '💻 Linux - Chrome', 'desktop', 'Chrome', 'Linux', '10aefd4911d8e40d2002239ab479a34e', '192.168.1.100', NULL, '2026-05-10 06:52:36', '0', 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Niwicm9sZSI6InByb3ZpZGVyIiwiZXhwIjoxNzc5MDE1MTU2fQ.2ono3uj-pDs_o3cGsJm4nu_KZ-NslKEKq3Ersnr_-Gc', '2026-05-10 06:52:36', '2026-05-12 10:45:00');
INSERT INTO `user_devices` VALUES ('54', '6', '💻 Linux - Chrome', 'desktop', 'Chrome', 'Linux', '3fade4641353aaab70d2476d3b1a69b3', '192.168.31.219', NULL, '2026-05-13 06:39:40', '0', 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Niwicm9sZSI6InByb3ZpZGVyIiwiZXhwIjoxNzc5MjczNTgwfQ.9tq4_oKegJI533pooJIBcycSi8VFFSw0M3L3pjT_qr4', '2026-05-12 10:45:00', '2026-05-13 06:49:07');
INSERT INTO `user_devices` VALUES ('55', '6', '💻 Linux - Chrome', 'desktop', 'Chrome', 'Linux', '6266caa5e94e644eb2d56143c783b158', '192.168.31.53', NULL, '2026-05-13 06:49:07', '0', 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Niwicm9sZSI6InByb3ZpZGVyIiwiZXhwIjoxNzc5Mjc0MTQ3fQ.1FPJVUhx8k-3hRPOdKv34FP7BVR3u92nSGpxbwqg6Fg', '2026-05-13 06:49:07', '2026-05-15 08:56:53');
INSERT INTO `user_devices` VALUES ('56', '6', '📱 Android - Chrome', 'mobile', 'Chrome', 'Android', '4a4a0daefd365734ee4a329e76626b45', '192.168.46.220', NULL, '2026-05-15 08:56:53', '0', 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Niwicm9sZSI6InByb3ZpZGVyIiwiZXhwIjoxNzc5NDU0NjEzfQ.Zx7AZMaVmBcGxFZ-6BfOi-KkGIkL48-K6yizGdHPQHg', '2026-05-15 08:56:53', '2026-05-15 09:02:42');
INSERT INTO `user_devices` VALUES ('58', '6', '💻 Linux - Chrome', 'desktop', 'Chrome', 'Linux', 'ada144e45306bfe0c8dd8159ac43ffda', '192.168.46.220', NULL, '2026-05-17 06:19:50', '0', 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Niwicm9sZSI6InByb3ZpZGVyIiwiZXhwIjoxNzc5NjE3OTkwfQ.scyg30PDPjvXO5YFF5ehI2Z2ZorKhzltm37Q1vt67kc', '2026-05-15 09:02:42', '2026-05-17 06:19:54');
INSERT INTO `user_devices` VALUES ('59', '6', '💻 Linux - Chrome', 'desktop', 'Chrome', 'Linux', '25c009cae2a22231f81d20cb01db5a82', '192.168.46.12', NULL, '2026-05-17 06:19:54', '0', 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Niwicm9sZSI6InByb3ZpZGVyIiwiZXhwIjoxNzc5NjE3OTk0fQ.Nr_rEOWQAdmL9X034DE1Upe283AIIODuGmtT4CvfheE', '2026-05-17 06:19:54', '2026-05-19 06:15:49');
INSERT INTO `user_devices` VALUES ('60', '2', '💻 Linux - Chrome', 'desktop', 'Chrome', 'Linux', '25c009cae2a22231f81d20cb01db5a82', '192.168.46.12', NULL, '2026-05-17 06:21:08', '0', 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3Nzk2MTgwNjh9.hAYSP9IJ_BH0qKzMXxGe4XXpl2excoe-P9CRybvzYnY', '2026-05-17 06:21:08', '2026-05-19 06:27:31');
INSERT INTO `user_devices` VALUES ('61', '1', '💻 Linux - Chrome', 'desktop', 'Chrome', 'Linux', '25c009cae2a22231f81d20cb01db5a82', '192.168.46.12', NULL, '2026-05-18 09:40:00', '0', 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MSwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzc5NzE2NDAwfQ.eiM6EkHhnsTqd__W54OjF0CTthfg0WDiO8UsHSBqjpI', '2026-05-18 09:40:00', '2026-05-19 06:16:59');
INSERT INTO `user_devices` VALUES ('62', '6', '💻 Linux - Chrome', 'desktop', 'Chrome', 'Linux', 'e514e28eabd6e4a29650809fb73d71d7', '192.168.142.12', NULL, '2026-05-19 06:15:49', '0', 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Niwicm9sZSI6InByb3ZpZGVyIiwiZXhwIjoxNzc5NzkwNTQ5fQ.O24v3TW4204KO34AsZqbqrSMn8JAI_NYGzo51rp05zM', '2026-05-19 06:15:49', '2026-05-19 06:29:09');
INSERT INTO `user_devices` VALUES ('63', '1', '💻 Linux - Chrome', 'desktop', 'Chrome', 'Linux', 'e514e28eabd6e4a29650809fb73d71d7', '192.168.142.12', NULL, '2026-05-20 09:44:30', '1', 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MSwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzc5ODg5NDcwfQ.Qe5jj3Dd5gGVLmiI5GMSiTmP7hT5AXCdLYRnBqgY5TQ', '2026-05-19 06:16:59', '2026-05-20 09:44:30');
INSERT INTO `user_devices` VALUES ('64', '2', '💻 Linux - Chrome', 'desktop', 'Chrome', 'Linux', '0452ac37d8eecc772b4d378a38a7edf4', '192.168.142.24', NULL, '2026-05-19 06:27:31', '1', 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3Nzk3OTEyNTF9.cjfjAZUYM3U_9nRLo4ULRx2KKTv3_oxQIaHADF8LvQI', '2026-05-19 06:27:31', '2026-05-19 06:27:31');
INSERT INTO `user_devices` VALUES ('65', '6', '💻 Linux - Chrome', 'desktop', 'Chrome', 'Linux', '0452ac37d8eecc772b4d378a38a7edf4', '192.168.142.24', NULL, '2026-05-19 06:29:27', '1', 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Niwicm9sZSI6InByb3ZpZGVyIiwiZXhwIjoxNzc5NzkxMzY3fQ.hlsbbjZAJ1Wkz04NTC-KajXV3sRQRb7ar_lZm6tFz8c', '2026-05-19 06:29:09', '2026-05-19 06:29:27');

DROP TABLE IF EXISTS `user_reviews`;
CREATE TABLE `user_reviews` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `service_history_id` bigint(20) NOT NULL,
  `provider_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `rating` tinyint(4) NOT NULL CHECK (`rating` between 1 and 5),
  `comment` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `photos` text DEFAULT '[]',
  `tags` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`tags`)),
  PRIMARY KEY (`id`),
  KEY `service_history_id` (`service_history_id`),
  KEY `provider_id` (`provider_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `user_reviews_ibfk_1` FOREIGN KEY (`service_history_id`) REFERENCES `service_history` (`id`),
  CONSTRAINT `user_reviews_ibfk_2` FOREIGN KEY (`provider_id`) REFERENCES `users` (`id`),
  CONSTRAINT `user_reviews_ibfk_3` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

INSERT INTO `user_reviews` VALUES ('1', '82', '6', '2', '4', 'Le dieron a la tadio', '2025-12-17 23:14:50', '[\"http:\\/\\/localhost:8000\\/uploads\\/user-reviews\\/82\\/99e1b3e042d55d7b.png\"]', '[]');
INSERT INTO `user_reviews` VALUES ('2', '83', '6', '2', '4', 'Itachi ichija', '2025-12-18 00:08:18', '[\"http:\\/\\/localhost:8000\\/uploads\\/user-reviews\\/83\\/ecbac003bc648180.jpg\"]', '[]');
INSERT INTO `user_reviews` VALUES ('3', '86', '6', '2', '3', 'Hola de nuevo', '2025-12-19 06:56:50', '[\"http:\\/\\/localhost:8000\\/uploads\\/user-reviews\\/86\\/071d445f1b580248.jpg\"]', '[]');
INSERT INTO `user_reviews` VALUES ('4', '88', '6', '2', '5', 'Para adelante funciona', '2025-12-19 20:55:47', '[\"http:\\/\\/localhost:8000\\/uploads\\/user-reviews\\/88\\/99f5dd205e9c7cb9.jpg\"]', '[]');
INSERT INTO `user_reviews` VALUES ('5', '89', '6', '2', '1', 'Pendejo juego de programación', '2025-12-21 11:49:03', '[\"http:\\/\\/localhost:8000\\/uploads\\/user-reviews\\/89\\/5bc22e04e3ded17f.jpg\"]', '[\"Buen precio\"]');
INSERT INTO `user_reviews` VALUES ('6', '90', '6', '2', '2', 'Hola', '2025-12-22 06:52:16', '[\"http:\\/\\/localhost:8000\\/uploads\\/user-reviews\\/90\\/cd7fb1f676e7b14d.png\"]', '[\"Amable\"]');
INSERT INTO `user_reviews` VALUES ('7', '91', '6', '2', '5', '12345678', '2025-12-22 07:15:59', '[\"http:\\/\\/localhost:8000\\/uploads\\/user-reviews\\/91\\/a7d705a48d3b7077.jpg\"]', '[\"Puntual\",\"Limpio\"]');
INSERT INTO `user_reviews` VALUES ('8', '97', '6', '2', '5', 'Hjhggvbhh', '2025-12-22 07:32:49', '[]', '[]');
INSERT INTO `user_reviews` VALUES ('9', '110', '6', '2', '5', '', '2025-12-23 15:31:46', '[\"http:\\/\\/localhost:8000\\/uploads\\/user-reviews\\/110\\/6b7a14a9f2ba9436.jpg\"]', '[\"Buen precio\"]');
INSERT INTO `user_reviews` VALUES ('10', '111', '6', '2', '3', 'Todo cálida en verduras', '2025-12-26 08:55:53', '[\"http:\\/\\/localhost:8000\\/uploads\\/user-reviews\\/111\\/d2b03fba345952a2.jpg\"]', '[\"Puntual\"]');
INSERT INTO `user_reviews` VALUES ('11', '112', '6', '2', '4', 'Paga en efectivo', '2025-12-26 15:45:22', '[]', '[\"Amable\"]');
INSERT INTO `user_reviews` VALUES ('12', '113', '6', '2', '5', 'Super fino', '2025-12-27 20:14:02', '[\"http:\\/\\/localhost:8000\\/uploads\\/user-reviews\\/113\\/0cf00213457b3501.jpg\"]', '[\"Profesional\"]');
INSERT INTO `user_reviews` VALUES ('13', '114', '6', '2', '5', 'Poendejo', '2025-12-28 05:53:07', '[]', '[]');
INSERT INTO `user_reviews` VALUES ('14', '115', '6', '2', '5', 'Yholtuholdsvh', '2025-12-28 12:46:26', '[]', '[]');
INSERT INTO `user_reviews` VALUES ('15', '116', '6', '2', '5', '123456', '2025-12-28 15:08:02', '[]', '[\"Profesional\",\"Calidad\"]');
INSERT INTO `user_reviews` VALUES ('16', '117', '6', '2', '5', 'Holaaa', '2025-12-29 03:00:27', '[]', '[\"Calidad\"]');
INSERT INTO `user_reviews` VALUES ('17', '118', '6', '2', '5', 'Hooolllwsggth', '2026-01-02 12:38:29', '[]', '[\"Limpio\"]');
INSERT INTO `user_reviews` VALUES ('18', '120', '6', '2', '4', '', '2026-01-02 16:24:15', '[]', '[\"Profesional\"]');
INSERT INTO `user_reviews` VALUES ('19', '122', '6', '2', '3', '', '2026-01-02 17:36:47', '[]', '[\"Calidad\"]');

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `username` varchar(50) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `password` text DEFAULT NULL,
  `role` enum('provider','user','admin') NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `avatar_url` text DEFAULT NULL,
  `average_rating` decimal(2,1) DEFAULT 0.0,
  `preferences` text DEFAULT NULL,
  `business_address` text DEFAULT NULL,
  `service_categories` text DEFAULT NULL,
  `coverage_area` text DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `last_seen_at` timestamp NULL DEFAULT NULL,
  `status_verification` enum('pending','verified','rejected') DEFAULT 'pending',
  `document_number` varchar(50) DEFAULT NULL,
  `documents_url` text DEFAULT NULL,
  `provider_description` text DEFAULT NULL,
  `pricing_info` text DEFAULT NULL,
  `experience_years` int(11) DEFAULT 0,
  `completed_jobs` int(11) DEFAULT 0,
  `cancelled_jobs` int(11) DEFAULT 0,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `phone_verified_at` timestamp NULL DEFAULT NULL,
  `reset_password_token` varchar(255) DEFAULT NULL,
  `reset_password_expires_at` timestamp NULL DEFAULT NULL,
  `login_attempts` int(11) DEFAULT 0,
  `last_login_attempt` timestamp NULL DEFAULT NULL,
  `locked_until` timestamp NULL DEFAULT NULL,
  `failed_login_attempts` int(11) DEFAULT 0,
  `account_locked` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `phone` (`phone`),
  UNIQUE KEY `uniq_username` (`username`),
  KEY `idx_last_seen_at` (`last_seen_at`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

INSERT INTO `users` VALUES ('1', 'Jesús Admin', NULL, 'admin@example.com', '04120761886', '', '$2y$12$WqOP3xcaqC/4CMNJXhTohOZVS/KRr2Q8Fi8NgUYE8eEXA6qpqUg76', 'admin', '2025-08-05 22:27:23', 'avatar_1755006875.jpg', '0.0', '{\"notifications\":{\"email\":true,\"sms\":true,\"push\":false,\"updated_at\":\"2026-02-17 20:52:25\"}}', '', '', '', '1', '2026-05-20 14:37:03', 'pending', NULL, NULL, NULL, NULL, '0', '0', '0', NULL, NULL, NULL, NULL, '0', NULL, NULL, '0', '0');
INSERT INTO `users` VALUES ('2', 'Jesús Díaz Villegas', NULL, 'divijeal@gmail.com', '04125048497', 'Valles de Aroa', '$2y$12$/4gCdLLdSzDPtycV9yjLC.W2B1ls5XdcWBPnaxbcTx.YNOwFJy8qG', 'user', '2025-08-04 22:36:22', 'avatar_1755746538.jpg', '0.0', '{\"language\":\"es\",\"dark\":false,\"notifications\":{\"email\":true,\"sms\":true}}', '', '', '', '1', '2026-05-19 06:28:32', 'pending', NULL, NULL, NULL, NULL, '0', '0', '0', NULL, NULL, 'cc9762ca6f6ade9d39e246b4e14043b7475860dfef8862cbb932dcd0f1d8891a', '2026-04-28 10:13:17', '0', NULL, NULL, '0', '0');
INSERT INTO `users` VALUES ('4', 'Jesús diaz', NULL, 'divina@gmail.com', '04120761887', NULL, '$2y$12$crK52/FINTXytwHaK/hZduSShsh3y53nxosv3KRPAXXyCUr4Ny71G', 'user', '2025-08-04 22:36:49', NULL, '0.0', NULL, NULL, NULL, NULL, '1', NULL, 'pending', NULL, NULL, NULL, NULL, '0', '0', '0', NULL, NULL, NULL, NULL, '0', NULL, NULL, '0', '0');
INSERT INTO `users` VALUES ('6', 'María Villegas', NULL, 'maria@gmail.com', '04120761889', 'Dirección 1', '$2y$12$ZgEhIEHYgLS/kK/lXYGbbe4uekhkYODGMIMTFVTYCPcxDxq7NWRzK', 'provider', '2025-08-05 10:59:16', 'avatar_1755532362.jpg', '4.0', '{\"language\":\"es\",\"dark\":true,\"notifications\":{\"email\":true,\"sms\":true}}', 'Dirección 2', 'Acompañamiento', 'Cuidad central .', '1', '2026-05-19 06:30:28', 'pending', NULL, NULL, NULL, NULL, '0', '0', '0', NULL, NULL, NULL, NULL, '0', NULL, NULL, '0', '0');
INSERT INTO `users` VALUES ('8', 'Pedro Perez', NULL, 'pedro@gmail.com', '04125048499', NULL, '$2y$12$pf1whO0Jjw3x0mDBvTX.FOfKZ5tZ1rmF6EKftPJDKxDgX29fFzG2a', 'provider', '2025-08-25 23:42:27', NULL, '0.0', NULL, NULL, NULL, NULL, '1', NULL, 'pending', NULL, NULL, NULL, NULL, '0', '0', '0', NULL, NULL, NULL, NULL, '0', NULL, NULL, '0', '0');
INSERT INTO `users` VALUES ('9', 'Viviana Alvarado ', NULL, 'vivianaalvarado233@gmail.com', '04160761886', NULL, '$2y$12$YzDhzEGEjKz8eju2FBwyueOJvXJV.UbsBJiBGvsctWZEPcmY6p5ry', 'provider', '2025-09-11 07:22:10', NULL, '0.0', NULL, NULL, NULL, NULL, '1', NULL, 'pending', NULL, NULL, NULL, NULL, '0', '0', '0', NULL, NULL, NULL, NULL, '0', NULL, NULL, '0', '0');

DROP TABLE IF EXISTS `wallet_transactions`;
CREATE TABLE `wallet_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `type` enum('credit','debit') NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `reference` varchar(100) DEFAULT NULL,
  `payment_proof` varchar(255) DEFAULT NULL,
  `payment_method` varchar(50) DEFAULT NULL,
  `reviewed_by` int(11) DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `status` enum('pending','completed','failed','cancelled') DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `reference` (`reference`),
  CONSTRAINT `wallet_transactions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

INSERT INTO `wallet_transactions` VALUES ('1', '1', 'credit', '20.00', 'Recarga de saldo', 'RECH-20260212-698D1B761CF28', NULL, NULL, NULL, NULL, 'completed', '2026-02-11 20:14:46');
INSERT INTO `wallet_transactions` VALUES ('2', '1', 'credit', '20.00', 'Solicitud de recarga #RECH-20260212-89373', '3654788554667', NULL, 'paypal', '1', '2026-02-12 17:50:50', 'completed', '2026-02-12 17:09:43');
INSERT INTO `wallet_transactions` VALUES ('3', '1', 'credit', '20.00', 'Solicitud de recarga #RECH-20260214-50041', '3736362636', 'http://192.168.31.53:8000/uploads/payments/2026/02/dce81ef6894668df.jpg', 'transferencia', '1', '2026-02-14 08:08:48', 'completed', '2026-02-14 07:57:50');
INSERT INTO `wallet_transactions` VALUES ('4', '2', 'credit', '20.00', 'Solicitud de recarga #RECH-20260215-50144', 'Ffkfjfj', NULL, 'zelle', '1', '2026-04-28 05:41:24', 'completed', '2026-02-15 19:01:19');

DROP TABLE IF EXISTS `wallets`;
CREATE TABLE `wallets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `balance` decimal(10,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `wallets_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

INSERT INTO `wallets` VALUES ('1', '4', '0.00', '2026-02-11 07:19:40', '2026-02-11 07:19:40');
INSERT INTO `wallets` VALUES ('2', '8', '0.00', '2026-02-11 07:19:40', '2026-02-11 07:19:40');
INSERT INTO `wallets` VALUES ('3', '9', '0.00', '2026-02-11 07:19:40', '2026-02-11 07:19:40');
INSERT INTO `wallets` VALUES ('4', '6', '0.00', '2026-02-11 07:19:40', '2026-02-11 07:19:40');
INSERT INTO `wallets` VALUES ('5', '2', '20.00', '2026-02-11 07:19:40', '2026-04-28 05:41:24');
INSERT INTO `wallets` VALUES ('6', '1', '60.00', '2026-02-11 07:19:40', '2026-02-14 08:08:48');

