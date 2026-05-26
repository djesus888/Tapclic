/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19-12.0.2-MariaDB, for Android (aarch64)
--
-- Host: localhost    Database: tapclic_db
-- ------------------------------------------------------
-- Server version	12.0.2-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `users` (`id`, `name`, `username`, `email`, `phone`, `address`, `password`, `role`, `created_at`, `avatar_url`, `average_rating`, `preferences`, `business_address`, `service_categories`, `coverage_area`, `active`, `last_seen_at`, `status_verification`, `document_number`, `documents_url`, `provider_description`, `pricing_info`, `experience_years`, `completed_jobs`, `cancelled_jobs`, `email_verified_at`, `phone_verified_at`, `reset_password_token`, `reset_password_expires_at`, `login_attempts`, `last_login_attempt`, `locked_until`, `failed_login_attempts`, `account_locked`) VALUES (1,'Jesús Admin',NULL,'admin@example.com','04120761886','','$2y$12$WqOP3xcaqC/4CMNJXhTohOZVS/KRr2Q8Fi8NgUYE8eEXA6qpqUg76','admin','2025-08-06 02:27:23','avatar_1755006875.jpg',0.0,'{\"notifications\":{\"email\":true,\"sms\":true,\"push\":false,\"updated_at\":\"2026-02-17 20:52:25\"}}','','','',1,'2026-05-25 09:56:44','pending',NULL,NULL,NULL,NULL,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,0,0),
(2,'Jesús Díaz Villegas',NULL,'divijeal@gmail.com','04125048497','Valles de Aroa','$2y$12$/4gCdLLdSzDPtycV9yjLC.W2B1ls5XdcWBPnaxbcTx.YNOwFJy8qG','user','2025-08-05 02:36:22','avatar_1755746538.jpg',0.0,'{\"language\":\"es\",\"dark\":false,\"notifications\":{\"email\":true,\"sms\":true}}','','','',1,'2026-05-25 20:27:37','pending',NULL,NULL,NULL,NULL,0,0,0,NULL,NULL,'cc9762ca6f6ade9d39e246b4e14043b7475860dfef8862cbb932dcd0f1d8891a','2026-04-28 14:13:17',0,NULL,NULL,0,0),
(4,'Jesús diaz',NULL,'divina@gmail.com','04120761887',NULL,'$2y$12$crK52/FINTXytwHaK/hZduSShsh3y53nxosv3KRPAXXyCUr4Ny71G','user','2025-08-05 02:36:49',NULL,0.0,NULL,NULL,NULL,NULL,1,NULL,'pending',NULL,NULL,NULL,NULL,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,0,0),
(6,'María Villegas',NULL,'maria@gmail.com','04120761889','Dirección 1','$2y$12$ZgEhIEHYgLS/kK/lXYGbbe4uekhkYODGMIMTFVTYCPcxDxq7NWRzK','provider','2025-08-05 14:59:16','avatar_1755532362.jpg',4.0,'{\"language\":\"es\",\"dark\":true,\"notifications\":{\"email\":true,\"sms\":true}}','Dirección 2','Acompañamiento','Cuidad central .',1,'2026-05-25 14:29:04','pending',NULL,NULL,NULL,NULL,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,0,0),
(8,'Pedro Perez',NULL,'pedro@gmail.com','04125048499',NULL,'$2y$12$pf1whO0Jjw3x0mDBvTX.FOfKZ5tZ1rmF6EKftPJDKxDgX29fFzG2a','provider','2025-08-26 03:42:27',NULL,0.0,NULL,NULL,NULL,NULL,1,NULL,'pending',NULL,NULL,NULL,NULL,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,0,0),
(9,'Viviana Alvarado ',NULL,'vivianaalvarado233@gmail.com','04160761886',NULL,'$2y$12$YzDhzEGEjKz8eju2FBwyueOJvXJV.UbsBJiBGvsctWZEPcmY6p5ry','provider','2025-09-11 11:22:10',NULL,0.0,NULL,NULL,NULL,NULL,1,NULL,'pending',NULL,NULL,NULL,NULL,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,0,0),
(10,'Angie Gutiérrez',NULL,'angie@gmail.com','04120761881',NULL,'$2y$12$uQx7VCmTA/QmZC.WyKkv7uT.omsCct0CXQgOoSiS5iIswF9DuGCUe','provider','2026-05-22 01:48:50',NULL,0.0,NULL,NULL,NULL,NULL,1,'2026-05-24 19:30:11','pending',NULL,NULL,NULL,NULL,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,0,0);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `categories` (`id`, `name`, `description`, `icon`, `color`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES (1,'Limpieza','La mejor limpieza','🧹','#667eea',1,1,'2026-02-03 23:32:42','2026-02-03 23:32:42'),
(2,'Transporte','Transporte para viajará','🚗','#667eea',2,1,'2026-02-03 23:44:03','2026-02-03 23:44:03'),
(3,'Fiestas center','Te decoramos todo tipos de fiestas!!','🎉','#00ffff',3,1,'2026-04-28 09:29:32','2026-04-28 09:29:32');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `static_pages`
--

LOCK TABLES `static_pages` WRITE;
/*!40000 ALTER TABLE `static_pages` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `static_pages` (`id`, `title`, `slug`, `content`, `meta_title`, `meta_description`, `meta_keywords`, `is_active`, `is_in_menu`, `sort_order`, `created_at`, `updated_at`) VALUES (1,'Términos y Condiciones','terms','<h1>Términos y Condiciones</h1><p>Contenido de términos y condiciones...</p>',NULL,NULL,NULL,1,1,1,'2026-02-01 01:35:00','2026-02-01 01:35:00'),
(2,'Política de Privacidad','privacy','<h1>Política de Privacidad</h1><p>Contenido de política de privacidad...</p>',NULL,NULL,NULL,1,1,2,'2026-02-01 01:35:00','2026-02-01 01:35:00'),
(3,'Acerca de Nosotros','about','<h1>Acerca de TapClic</h1><p>Información sobre nuestra empresa...</p>',NULL,NULL,NULL,1,1,3,'2026-02-01 01:35:00','2026-02-01 01:35:00'),
(4,'Ayuda y Soporte','help','<h1>Ayuda y Soporte</h1><p>Guías y ayuda para usuarios...</p>',NULL,NULL,NULL,1,1,4,'2026-02-01 01:35:00','2026-02-01 01:35:00'),
(5,'Contacto','contact','<h1>Contacto</h1><p>Información de contacto...</p>',NULL,NULL,NULL,1,1,5,'2026-02-01 01:35:00','2026-02-01 01:35:00');
/*!40000 ALTER TABLE `static_pages` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `faqs`
--

LOCK TABLES `faqs` WRITE;
/*!40000 ALTER TABLE `faqs` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `faqs` (`id`, `question`, `answer`, `sort_order`, `is_active`, `created_at`) VALUES (1,'¿Cómo solicito un servicio?','Busca el servicio que necesitas, revisa la disponibilidad y precio, luego haz clic en \"Solicitar\". Completa los detalles y espera la confirmación del proveedor.',1,1,'2025-08-28 17:31:43'),
(2,'¿Qué métodos de pago aceptan?','Aceptamos efectivo, transferencia bancaria y tarjetas de crédito/débito. El pago se realiza después de que el proveedor confirme tu solicitud.',2,1,'2025-08-28 17:31:43'),
(3,'¿Puedo cancelar una solicitud?','Sí, puedes cancelar desde la sección \"Solicitudes Activas\" antes de que el proveedor la acepte. Si ya fue aceptada, contacta al soporte.',3,1,'2025-08-28 17:31:43'),
(4,'¿Cómo sé si mi solicitud fue aceptada?','Recibirás una notificación en la app y un email. También verás el estado cambiar a \"Aceptado\" en \"Solicitudes Activas\".',4,1,'2025-08-28 17:31:43'),
(5,'¿Qué hago si el proveedor no llega?','Primero contacta al proveedor por el chat. Si no hay respuesta en 30 minutos, reporta el incidente en Soporte para que te ayudemos.',5,1,'2025-08-28 17:31:43'),
(6,'¿Cómo dejo una reseña?','Después de que el servicio se complete, aparecerá la opción de calificar al proveedor en tu historial de servicios.',6,1,'2025-08-28 17:31:43'),
(7,'¿Es seguro compartir mi ubicación?','Sí, tu ubicación solo se comparte con el proveedor una vez que acepta tu solicitud. No se almacena permanentemente.',7,1,'2025-08-28 17:31:43'),
(8,'¿Puedo modificar una solicitud después de enviarla?','No puedes editar los detalles, pero puedes cancelarla y crear una nueva con la información correcta.',8,1,'2025-08-28 17:31:43'),
(9,'¿Qué pasa si no estoy satisfecho con el servicio?','Contacta al soporte dentro de las 24 horas posteriores al servicio. Investigaremos el caso y aplicaremos nuestras políticas de garantía.',9,1,'2025-08-28 17:31:43'),
(10,'¿Cómo me registro como proveedor?','Ve a Configuración > Convertirme en Proveedor. Completa tu perfil profesional, sube tus documentos y espera nuestra aprobación.',10,1,'2025-08-28 17:31:43'),
(11,'¿Cómo registro mi servicio?','Para registrar tu servicio, inicia sesión y haz clic en \"Publicar Servicio\" en tu dashboard. Completa el formulario con los detalles de tu servicio.',1,1,'2026-01-31 21:35:05'),
(12,'¿Cómo puedo pagar por un servicio?','Aceptamos múltiples métodos de pago: efectivo, transferencia bancaria, Pago Móvil, PayPal y Zelle.',2,1,'2026-01-31 21:35:05'),
(13,'¿Qué hago si tengo un problema con un proveedor?','Puedes reportar el problema desde la sección de \"Mis Solicitudes\" o contactando a nuestro soporte.',3,1,'2026-01-31 21:35:05'),
(14,'¿Puedo cancelar un servicio contratado?','Sí, puedes cancelar siempre que el proveedor no haya iniciado el servicio. Consulta nuestros términos para más detalles.',4,1,'2026-01-31 21:35:05');
/*!40000 ALTER TABLE `faqs` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `system_config`
--

LOCK TABLES `system_config` WRITE;
/*!40000 ALTER TABLE `system_config` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `system_config` (`id`, `system_name`, `system_host`, `ws_host`, `system_active`, `system_version`, `system_logo`, `system_favicon`, `default_language`, `timezone`, `currency`, `support_email`, `support_phone`, `mail_host`, `mail_port`, `mail_encryption`, `mail_username`, `mail_password`, `mail_from`, `mail_from_name`, `twilio_sid`, `twilio_token`, `twilio_phone`, `company_name`, `company_address`, `maintenance_mode`, `max_login_attempts`, `password_expiration_days`, `session_timeout_minutes`, `items_per_page`, `theme_color`, `allow_user_registration`, `wallet_enabled`, `reviews_enabled`, `chat_enabled`, `tickets_enabled`, `analytics_enabled`, `extra_json`, `created_at`, `updated_at`, `payment_default_commission`, `payment_min_commission`, `payment_currency`, `service_publish_cost`, `service_publish_duration`, `monetization_model`) VALUES (1,'TapClic','http://192.168.31.52:5173','http://192.168.31.53:3001',1,'1.0.0','/assets/logo.png','/assets/favicon.ico','es','America/Caracas','USD','soporte@tapclic.com','+58 123 456 7890','smtp.gmail.com',587,'tls',NULL,NULL,'notificaciones@tapclic.com','TapClic',NULL,NULL,NULL,'TapClic C.A.','Yaracuy, Venezuela',0,5,90,30,20,'#409EFF',1,0,1,1,1,1,NULL,'2025-08-17 21:44:41','2026-05-24 13:46:18',2.00,0.00,NULL,5.00,30,'both');
/*!40000 ALTER TABLE `system_config` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `payment_gateways`
--

LOCK TABLES `payment_gateways` WRITE;
/*!40000 ALTER TABLE `payment_gateways` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `payment_gateways` (`id`, `name`, `display_name`, `description`, `is_active`, `is_test_mode`, `requires_api_keys`, `api_key_public`, `api_key_secret`, `api_key_extra`, `paypal_email`, `mercadopago_access_token`, `bank_name`, `bank_account`, `bank_holder`, `bank_id_type`, `bank_id_number`, `mobile_phone`, `mobile_operator`, `zelle_email`, `commission_rate`, `fixed_commission`, `total_transactions`, `total_amount`, `success_rate`, `instructions`, `icon`, `sort_order`, `created_at`, `updated_at`) VALUES (1,'paypal','PayPal','Pagos seguros con PayPal',0,1,1,'18673920','djesus888',NULL,'divijeal@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,5.00,3.00,0,0.00,0.00,NULL,'🅿️',1,'2026-02-04 18:00:19','2026-05-24 17:46:53'),
(2,'mercadopago','MercadoPago','Pagos en Latinoamérica',0,1,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0.00,0.00,0,0.00,0.00,NULL,'🇦🇷',0,'2026-02-04 18:00:19','2026-05-24 17:46:48'),
(3,'bank_transfer','Transferencia Bancaria','Transferencia directa a cuenta bancaria',0,1,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0.00,0.00,0,0.00,0.00,NULL,'🏦',0,'2026-02-04 18:00:19','2026-05-24 17:46:42'),
(4,'mobile_payment','Pago Móvil','Pago desde tu teléfono móvil',1,1,0,NULL,NULL,NULL,NULL,NULL,'Banco de Venezuela (0102)',NULL,NULL,NULL,'18673920','04120761886','digitel',NULL,5.00,3.00,0,0.00,0.00,NULL,'📱',0,'2026-02-04 18:00:19','2026-05-24 19:29:20'),
(5,'zelle','Zelle','Transferencias bancarias en USA',1,1,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'divijeal@gmail.com',0.00,0.00,0,0.00,0.00,NULL,'🇺🇸',0,'2026-02-04 18:00:19','2026-04-28 09:49:38');
/*!40000 ALTER TABLE `payment_gateways` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `payment_methods`
--

LOCK TABLES `payment_methods` WRITE;
/*!40000 ALTER TABLE `payment_methods` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `payment_methods` (`id`, `value`, `label`, `title`, `fields`, `concept`, `is_active`, `created_at`, `updated_at`) VALUES (1,'transferencia','🏦 Transferencia bancaria','🏦 Datos para transferencia','{\"Banco\": \"Banco de Venezuela\", \"Titular\": \"Tapclic Services C.A.\", \"RIF\": \"J-123456789\", \"Cuenta Corriente\": \"0102-0123-45-12345678\", \"CI\": \"V-12345678\"}','RECARGA',1,'2026-02-14 03:27:59','2026-02-14 03:27:59'),
(2,'pago_movil','📱 Pago móvil','📱 Datos para Pago Móvil','{\"Banco\": \"Banesco\", \"Cédula/RIF\": \"V-12345678\", \"Teléfono\": \"0412-1234567\", \"Banco receptor\": \"Banesco\"}','RECARGA',1,'2026-02-14 03:27:59','2026-04-28 09:42:00'),
(3,'paypal','🌐 PayPal','🌐 Datos de PayPal','{\"Email\": \"pagos@tapclic.com\", \"Nombre\": \"Tapclic Services\"}','RECARGA',1,'2026-02-14 03:27:59','2026-02-14 03:27:59'),
(4,'zelle','💵 Zelle','💵 Datos para Zelle','{\"Email\": \"pagos@tapclic.com\", \"Nombre\": \"Tapclic Services\", \"Banco\": \"Bank of America\"}','RECARGA',1,'2026-02-14 03:27:59','2026-02-14 03:27:59'),
(5,'binance','🪙 Binance','🪙 Datos de Binance','{\"ID\": \"123456789\", \"Email\": \"binance@tapclic.com\"}','RECARGA',1,'2026-02-14 03:27:59','2026-02-14 03:27:59'),
(6,'efectivo','💵 Efectivo','💵 Pago en efectivo','{\"Punto de pago\": \"Consultar con administrador\"}','RECARGA',1,'2026-02-14 03:27:59','2026-02-14 03:27:59');
/*!40000 ALTER TABLE `payment_methods` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `content_blocks`
--

LOCK TABLES `content_blocks` WRITE;
/*!40000 ALTER TABLE `content_blocks` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `content_blocks` (`id`, `name`, `identifier`, `type`, `content`, `settings`, `is_active`, `created_at`, `updated_at`) VALUES (1,'Banner Principal','home_banner','banner','{\"title\": \"Encuentra el servicio que necesitas\", \"subtitle\": \"Profesionales confiables a tu alcance\", \"button_text\": \"Explorar Servicios\", \"button_link\": \"/services\"}','{\"background\": \"#667eea\", \"text_color\": \"#ffffff\"}',1,'2026-02-01 01:35:00','2026-02-01 01:35:00'),
(2,'Texto de Bienvenida','welcome_text','text','<h2>Bienvenido a TapClic</h2><p>La plataforma que conecta a usuarios con profesionales confiables.</p>','\"{\\\"alignment\\\": \\\"center\\\"}\"',1,'2026-02-01 01:35:00','2026-02-03 23:40:52'),
(3,'Footer Info','footer_info','text','<p>© 2024 TapClic. Todos los derechos reservados.</p>','{}',1,'2026-02-01 01:35:00','2026-02-01 01:35:00'),
(4,'Segurojajajaja','Homejjjjh','text','Jgcgjjjhvv','\"{}\"',1,'2026-02-03 23:57:32','2026-02-03 23:57:32');
/*!40000 ALTER TABLE `content_blocks` ENABLE KEYS */;
UNLOCK TABLES;
commit;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2026-05-26 10:13:10
