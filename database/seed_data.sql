Enter password: 
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
-- Dumping data for table `activities`
--

LOCK TABLES `activities` WRITE;
/*!40000 ALTER TABLE `activities` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `activities` (`id`, `message_key`, `params`, `created_at`) VALUES (1,'activity.service_created','{\"user\": \"Juan Pérez\"}','2025-08-09 14:59:39'),
(2,'activity.profile_updated','{\"user\": \"María López\"}','2025-08-09 14:59:39'),
(3,'activity.support_ticket_opened',NULL,'2025-08-09 14:59:39'),
(4,'activity.service_accepted','{\"service\": \"Limpieza Hogar\"}','2025-08-09 14:59:39');
/*!40000 ALTER TABLE `activities` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `audit_logs`
--

LOCK TABLES `audit_logs` WRITE;
/*!40000 ALTER TABLE `audit_logs` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `audit_logs` (`id`, `user_id`, `action_type`, `action`, `details`, `ip_address`, `user_agent`, `created_at`) VALUES (1,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.142.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-20 19:12:01'),
(2,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-21 22:36:10'),
(3,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-21 22:36:16'),
(4,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-21 22:37:16'),
(5,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-21 23:41:35'),
(6,10,'register','Nuevo registro','Usuario: Angie Gutiérrez (angie@gmail.com) - Rol: provider','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 01:48:50'),
(7,10,'service_created','Servicio creado','Título: Reparación de televisión a domicilio - Precio: $10','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 02:36:54'),
(8,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.21.41','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 02:39:50'),
(9,10,'service_deleted','Servicio eliminado','ID: 13 - Título: Reparación de televisión a domicilio','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 10:24:49'),
(10,10,'service_created','Servicio creado','ID: 139 - Título: Reparación de televisión a domicilio - Precio: $18','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 10:28:31'),
(11,10,'service_created','Servicio creado','ID: 140 - Título: Reparación de televisión a domicilio - Precio: $18','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 10:34:48'),
(12,10,'service_created','Servicio creado','ID: 141 - Título: Reparación de televisión a domicilio - Precio: $18','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 10:35:11'),
(13,10,'service_created','Servicio creado','ID: 142 - Título: Reparación de televisión en la puerta de su casa - Precio: $18','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 11:00:53'),
(14,10,'service_created','Servicio creado','ID: 143 - Título: Reparación de televisión en la puerta de su casa - Precio: $18','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 11:01:54'),
(15,10,'service_created','Servicio creado','ID: 144 - Título: Reparación de televisión en la puerta de su casa - Precio: $18','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 11:01:57'),
(16,10,'service_created','Servicio creado','ID: 145 - Título: Reparación de televisión en la puerta de su casa - Precio: $18','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 11:02:01'),
(17,10,'service_created','Servicio creado','ID: 146 - Título: Reparación de televisión en la puerta de su casa - Precio: $18','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 11:02:05'),
(18,10,'service_created','Servicio creado','ID: 147 - Título: Reparación de televisión en la puerta de su casa - Precio: $18','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 11:02:09'),
(19,10,'service_created','Servicio creado','ID: 148 - Título: Reparación de televisión en la puerta de su casa - Precio: $18','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 11:02:12'),
(20,10,'service_created','Servicio creado','ID: 149 - Título: Reparación de televisión - Precio: $10','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 11:08:37'),
(21,10,'service_deleted','Servicio eliminado','ID: 24 - Título: Reparación de televisión','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 11:23:15'),
(22,10,'service_deleted','Servicio eliminado','ID: 23 - Título: Reparación de televisión en la puerta de su casa','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 11:23:41'),
(23,10,'service_deleted','Servicio eliminado','ID: 22 - Título: Reparación de televisión en la puerta de su casa','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 11:23:45'),
(24,10,'service_deleted','Servicio eliminado','ID: 21 - Título: Reparación de televisión en la puerta de su casa','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 11:23:49'),
(25,10,'service_deleted','Servicio eliminado','ID: 20 - Título: Reparación de televisión en la puerta de su casa','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 11:23:52'),
(26,10,'service_deleted','Servicio eliminado','ID: 19 - Título: Reparación de televisión en la puerta de su casa','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 11:23:56'),
(27,10,'service_deleted','Servicio eliminado','ID: 18 - Título: Reparación de televisión en la puerta de su casa','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 11:23:59'),
(28,10,'service_deleted','Servicio eliminado','ID: 17 - Título: Reparación de televisión en la puerta de su casa','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 11:24:05'),
(29,10,'service_deleted','Servicio eliminado','ID: 16 - Título: Reparación de televisión a domicilio','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 11:24:08'),
(30,10,'service_deleted','Servicio eliminado','ID: 15 - Título: Reparación de televisión a domicilio','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 11:24:12'),
(31,10,'service_deleted','Servicio eliminado','ID: 14 - Título: Reparación de televisión a domicilio','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 11:24:15'),
(32,10,'service_created','Servicio creado','ID: 150 - Título: Reparación de televisión - Precio: $18','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 11:26:31'),
(33,10,'service_deleted','Servicio eliminado','ID: 25 - Título: Reparación de televisión','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 11:43:05'),
(34,10,'service_created','Servicio creado','ID: 151 - Título: Reparación de televisión - Precio: $10','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 11:46:05'),
(35,10,'service_deleted','Servicio eliminado','ID: 26 - Título: Reparación de televisión','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 17:03:09'),
(36,10,'service_created','Servicio creado','ID: 27 - Título: Reparación - Precio: $10','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 17:45:48'),
(37,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-23 15:14:27'),
(38,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-23 15:38:55'),
(39,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-23 15:40:07'),
(40,10,'login','Inicio de sesión','Usuario: Angie Gutiérrez (angie@gmail.com) - Rol: provider','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-23 15:40:41'),
(41,10,'service_deleted','Servicio eliminado','ID: 27 - Título: Reparación','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-23 15:41:35'),
(42,10,'service_created','Servicio creado','ID: 28 - Título: Reparación de televisión - Precio: $18','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-23 15:46:48'),
(43,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-23 15:48:15'),
(44,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-23 18:20:57'),
(45,10,'login','Inicio de sesión','Usuario: Angie Gutiérrez (angie@gmail.com) - Rol: provider','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-23 18:21:37'),
(46,10,'service_deleted','Servicio eliminado','ID: 28 - Título: Reparación de televisión','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 02:20:03'),
(47,10,'service_created','Servicio creado','ID: 29 - Título: Reparación de tv - Precio: $50','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 02:22:07'),
(48,10,'service_deleted','Servicio eliminado','ID: 29 - Título: Reparación de tv','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 09:45:05'),
(49,10,'service_created','Servicio creado','ID: 30 - Título: Reparación de tv - Precio: $25','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 09:46:44'),
(50,10,'service_deleted','Servicio eliminado','ID: 30 - Título: Reparación de tv','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 10:08:54'),
(51,10,'service_created','Servicio creado','ID: 31 - Título: Reparación de televisión - Precio: $68','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 10:10:11'),
(52,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64; rv:150.0) Gecko/20100101 Firefox/150.0','2026-05-24 10:12:49'),
(53,10,'service_deleted','Servicio eliminado','ID: 31 - Título: Reparación de televisión','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 10:16:11'),
(54,10,'service_created','Servicio creado','ID: 32 - Título: Reparación de televisión - Precio: $15','192.168.21.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 10:17:27'),
(55,10,'login','Inicio de sesión','Usuario: Angie Gutiérrez (angie@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 12:50:05'),
(56,10,'login','Inicio de sesión','Usuario: Angie Gutiérrez (angie@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 12:50:11'),
(57,10,'service_deleted','Servicio eliminado','ID: 32 - Título: Reparación de televisión','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 12:50:32'),
(58,10,'service_created','Servicio creado','ID: 33 - Título: Reparación de televisión - Precio: $15','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 12:51:51'),
(59,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64; rv:150.0) Gecko/20100101 Firefox/150.0','2026-05-24 12:53:05'),
(60,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 13:21:23'),
(61,2,'request_created','Solicitud creada','ID: 73 - Servicio: 33 - Proveedor: 10','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 13:21:58'),
(62,10,'request_accepted','Solicitud aceptada','Solicitud ID: 73','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 13:22:34'),
(63,2,'payment_created','Pago registrado','Solicitud ID: 73 - Método: efectivo - Pago ID: 67','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 13:22:58'),
(64,10,'payment_confirmed','Pago confirmado','Solicitud ID: 73 - Pago ID: 67','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 13:23:14'),
(65,10,'request_completed','Servicio finalizado','Solicitud ID: 73','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 13:23:40'),
(66,2,'request_created','Solicitud creada','ID: 74 - Servicio: 33 - Proveedor: 10','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 14:06:22'),
(67,10,'request_accepted','Solicitud aceptada','Solicitud ID: 74','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 14:06:30'),
(68,2,'payment_created','Pago registrado','Solicitud ID: 74 - Método: efectivo - Pago ID: 68','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 14:06:34'),
(69,10,'request_completed','Servicio finalizado','Solicitud ID: 74','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 14:07:05'),
(70,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 14:21:38'),
(71,2,'request_created','Solicitud creada','ID: 75 - Servicio: 12 - Proveedor: 6','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 14:21:50'),
(72,6,'request_accepted','Solicitud aceptada','Solicitud ID: 75','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 14:21:52'),
(73,2,'payment_created','Pago registrado','Solicitud ID: 75 - Método: pago-movil - Pago ID: 69','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 14:22:20'),
(74,6,'request_completed','Servicio finalizado','Solicitud ID: 75','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 14:23:12'),
(75,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.53','curl/8.17.0','2026-05-24 14:41:33'),
(76,6,'request_accepted','Solicitud aceptada','Solicitud ID: 50','192.168.31.53','curl/8.17.0','2026-05-24 14:41:33'),
(77,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','curl/8.17.0','2026-05-24 14:44:08'),
(78,2,'payment_created','Pago registrado','Solicitud ID: 50 - Método: transferencia - Pago ID: 70','192.168.31.53','curl/8.17.0','2026-05-24 14:44:08'),
(79,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.53','curl/8.17.0','2026-05-24 14:46:23'),
(80,6,'request_completed','Servicio finalizado','Solicitud ID: 50','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 15:01:12'),
(81,2,'request_created','Solicitud creada','ID: 76 - Servicio: 12 - Proveedor: 6','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 15:01:23'),
(82,6,'request_accepted','Solicitud aceptada','Solicitud ID: 76','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 15:01:28'),
(83,2,'payment_created','Pago registrado','Solicitud ID: 76 - Método: pago-movil - Pago ID: 71','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 15:01:59'),
(84,6,'payment_confirmed','Pago confirmado','Solicitud ID: 76 - Pago ID: 71','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 15:02:18'),
(85,6,'request_completed','Servicio finalizado','Solicitud ID: 76','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 15:02:35'),
(86,10,'login','Inicio de sesión','Usuario: Angie Gutiérrez (angie@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 15:27:54'),
(87,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 15:29:04'),
(88,10,'login','Inicio de sesión','Usuario: Angie Gutiérrez (angie@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 15:38:33'),
(89,10,'login','Inicio de sesión','Usuario: Angie Gutiérrez (angie@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 15:40:13'),
(90,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 15:40:41'),
(91,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 15:41:13'),
(92,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 16:00:33'),
(93,10,'login','Inicio de sesión','Usuario: Angie Gutiérrez (angie@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 16:01:55'),
(94,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 16:08:31'),
(95,10,'login','Inicio de sesión','Usuario: Angie Gutiérrez (angie@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 17:34:45'),
(96,10,'service_created','Servicio creado','ID: 34 - Título: Reparación de televisión - Precio: $25','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 17:40:28'),
(97,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64; rv:150.0) Gecko/20100101 Firefox/150.0','2026-05-24 18:15:34'),
(98,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 19:30:16'),
(99,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 19:44:45'),
(100,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 20:30:20'),
(101,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 20:55:56'),
(102,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 21:10:31'),
(103,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-24 21:16:38'),
(104,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-05-25 09:56:42'),
(105,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.206.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-26 19:04:09'),
(106,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.192.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-27 05:34:07'),
(107,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.192.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-27 10:15:23'),
(108,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.192.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-27 10:16:41'),
(109,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.192.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-27 10:52:23'),
(110,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.192.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-27 17:46:39'),
(111,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.192.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-27 18:01:07'),
(112,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.192.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-27 18:02:04'),
(113,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.115.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-28 01:13:37'),
(114,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.246.12','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36','2026-05-28 11:30:09'),
(115,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.246.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-28 20:04:51'),
(116,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.246.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-28 20:06:21'),
(117,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.246.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-29 07:20:07'),
(118,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.246.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/148.0.7778.120 Mobile Safari/537.36','2026-05-29 07:26:39'),
(119,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.246.46','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-29 08:05:48'),
(120,2,'request_created','Solicitud creada','ID: 77 - Servicio: 34 - Proveedor: 10','192.168.246.46','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-29 08:06:12'),
(121,2,'request_created','Solicitud creada','ID: 78 - Servicio: 11 - Proveedor: 6','192.168.246.46','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-29 08:07:12'),
(122,6,'request_accepted','Solicitud aceptada','Solicitud ID: 78','192.168.246.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-29 08:07:27'),
(123,2,'payment_created','Pago registrado','Solicitud ID: 78 - Método: pago-movil - Pago ID: 73','192.168.246.46','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-29 08:07:55'),
(124,6,'payment_confirmed','Pago confirmado','Solicitud ID: 78 - Pago ID: 73','192.168.246.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-29 08:08:18'),
(125,6,'request_completed','Servicio finalizado','Solicitud ID: 78','192.168.246.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-29 08:08:36'),
(126,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.246.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-29 08:41:48'),
(127,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.246.12','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-05-29 11:46:52'),
(128,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.246.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-29 11:54:30'),
(129,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.246.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-29 12:01:52'),
(130,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-30 12:30:18'),
(131,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-31 23:37:54'),
(132,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-31 23:40:30'),
(133,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-01 00:43:19'),
(134,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-01 01:59:38'),
(135,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-01 02:23:22'),
(136,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-01 02:23:49'),
(137,2,'request_created','Solicitud creada','ID: 79 - Servicio: 12 - Proveedor: 6','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-01 02:25:12'),
(138,6,'request_accepted','Solicitud aceptada','Solicitud ID: 79','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-01 02:25:26'),
(139,2,'payment_created','Pago registrado','Solicitud ID: 79 - Método: efectivo - Pago ID: 74','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-01 02:25:32'),
(140,6,'payment_confirmed','Pago confirmado','Solicitud ID: 79 - Pago ID: 74','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-01 02:25:43'),
(141,6,'request_completed','Servicio finalizado','Solicitud ID: 79','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-01 02:25:53'),
(142,2,'request_created','Solicitud creada','ID: 80 - Servicio: 10 - Proveedor: 6','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-01 02:47:34'),
(143,6,'request_accepted','Solicitud aceptada','Solicitud ID: 80','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-01 02:47:37'),
(144,2,'payment_created','Pago registrado','Solicitud ID: 80 - Método: efectivo - Pago ID: 75','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-01 02:47:41'),
(145,6,'payment_confirmed','Pago confirmado','Solicitud ID: 80 - Pago ID: 75','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-01 02:47:50'),
(146,6,'request_completed','Servicio finalizado','Solicitud ID: 80','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-01 02:48:09'),
(147,2,'request_created','Solicitud creada','ID: 81 - Servicio: 10 - Proveedor: 6','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-01 03:39:07'),
(148,6,'request_accepted','Solicitud aceptada','Solicitud ID: 81','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-01 03:39:13'),
(149,2,'payment_created','Pago registrado','Solicitud ID: 81 - Método: efectivo - Pago ID: 76','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-01 03:39:24'),
(150,6,'payment_confirmed','Pago confirmado','Solicitud ID: 81 - Pago ID: 76','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-01 03:39:35'),
(151,6,'request_completed','Servicio finalizado','Solicitud ID: 81','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-01 03:39:54'),
(152,2,'request_created','Solicitud creada','ID: 82 - Servicio: 11 - Proveedor: 6','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-01 03:41:37'),
(153,6,'request_accepted','Solicitud aceptada','Solicitud ID: 82','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-01 03:41:44'),
(154,2,'payment_created','Pago registrado','Solicitud ID: 82 - Método: efectivo - Pago ID: 77','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-01 03:41:50'),
(155,6,'payment_confirmed','Pago confirmado','Solicitud ID: 82 - Pago ID: 77','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-01 03:41:56'),
(156,6,'request_completed','Servicio finalizado','Solicitud ID: 82','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-01 03:42:09'),
(157,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.246.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-02 13:01:58'),
(158,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.246.46','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-02 13:03:33'),
(159,2,'request_created','Solicitud creada','ID: 83 - Servicio: 11 - Proveedor: 6','192.168.246.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-02 13:08:32'),
(160,6,'request_accepted','Solicitud aceptada','Solicitud ID: 83','192.168.246.46','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-02 13:08:37'),
(161,2,'payment_created','Pago registrado','Solicitud ID: 83 - Método: efectivo - Pago ID: 78','192.168.246.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-02 13:08:43'),
(162,6,'payment_confirmed','Pago confirmado','Solicitud ID: 83 - Pago ID: 78','192.168.246.46','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-02 13:09:02'),
(163,6,'request_completed','Servicio finalizado','Solicitud ID: 83','192.168.246.46','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-02 13:09:32'),
(164,2,'request_created','Solicitud creada','ID: 84 - Servicio: 11 - Proveedor: 6','192.168.246.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-02 13:26:57'),
(165,6,'request_accepted','Solicitud aceptada','Solicitud ID: 84','192.168.246.46','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-02 13:27:06'),
(166,2,'payment_created','Pago registrado','Solicitud ID: 84 - Método: efectivo - Pago ID: 79','192.168.246.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-02 13:27:14'),
(167,6,'payment_confirmed','Pago confirmado','Solicitud ID: 84 - Pago ID: 79','192.168.246.46','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-02 13:32:25'),
(168,6,'request_completed','Servicio finalizado','Solicitud ID: 84','192.168.246.46','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-02 13:32:45'),
(169,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.246.12','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-03 11:10:37'),
(170,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.1.102','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/148.0.7778.178 Mobile Safari/537.36','2026-06-04 11:07:13'),
(171,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.1.102','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-04 11:08:09'),
(172,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.1.103','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-04 11:27:23'),
(173,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.1.103','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-04 11:28:22'),
(174,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.1.103','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-04 11:28:57'),
(175,2,'request_created','Solicitud creada','ID: 85 - Servicio: 11 - Proveedor: 6','192.168.1.102','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-04 11:29:37'),
(176,6,'request_accepted','Solicitud aceptada','Solicitud ID: 85','192.168.1.103','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-04 11:29:39'),
(177,2,'payment_created','Pago registrado','Solicitud ID: 85 - Método: efectivo - Pago ID: 80','192.168.1.102','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-04 11:29:47'),
(178,6,'payment_confirmed','Pago confirmado','Solicitud ID: 85 - Pago ID: 80','192.168.1.103','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-04 11:30:01'),
(179,6,'request_completed','Servicio finalizado','Solicitud ID: 85','192.168.1.103','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-04 11:30:50'),
(180,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.1.100','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 10:20:39'),
(181,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.1.100','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-05 10:21:28'),
(182,2,'request_created','Solicitud creada','ID: 86 - Servicio: 12 - Proveedor: 6','192.168.1.100','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 10:21:51'),
(183,6,'request_accepted','Solicitud aceptada','Solicitud ID: 86','192.168.1.100','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-05 10:21:59'),
(184,2,'payment_created','Pago registrado','Solicitud ID: 86 - Método: efectivo - Pago ID: 81','192.168.1.100','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 10:22:07'),
(185,6,'payment_confirmed','Pago confirmado','Solicitud ID: 86 - Pago ID: 81','192.168.1.100','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-05 10:22:17'),
(186,6,'request_completed','Servicio finalizado','Solicitud ID: 86','192.168.1.100','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-05 10:22:30'),
(187,2,'request_created','Solicitud creada','ID: 87 - Servicio: 12 - Proveedor: 6','192.168.1.100','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 10:41:47'),
(188,6,'request_accepted','Solicitud aceptada','Solicitud ID: 87','192.168.1.100','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-05 10:41:58'),
(189,2,'payment_created','Pago registrado','Solicitud ID: 87 - Método: efectivo - Pago ID: 82','192.168.1.100','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 10:42:05'),
(190,6,'payment_confirmed','Pago confirmado','Solicitud ID: 87 - Pago ID: 82','192.168.1.100','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-05 10:42:16'),
(191,6,'request_completed','Servicio finalizado','Solicitud ID: 87','192.168.1.100','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-05 10:42:27'),
(192,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 15:01:44'),
(193,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 15:02:05'),
(194,2,'request_created','Solicitud creada','ID: 88 - Servicio: 10 - Proveedor: 6','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 15:05:17'),
(195,2,'request_cancelled','Solicitud cancelada','Solicitud ID: 88 - Por: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 15:21:10'),
(196,2,'request_cancelled','Solicitud cancelada','Solicitud ID: 88 - Por: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 15:21:25'),
(197,2,'request_cancelled','Solicitud cancelada','Solicitud ID: 88 - Por: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 15:21:25'),
(198,2,'request_cancelled','Solicitud cancelada','Solicitud ID: 88 - Por: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 15:21:26'),
(199,2,'request_cancelled','Solicitud cancelada','Solicitud ID: 88 - Por: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 15:21:26'),
(200,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 16:47:15'),
(201,2,'request_created','Solicitud creada','ID: 89 - Servicio: 10 - Proveedor: 6','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 16:52:44'),
(202,6,'request_accepted','Solicitud aceptada','Solicitud ID: 89','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 16:53:07'),
(203,6,'request_accepted','Solicitud aceptada','Solicitud ID: 89','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 16:53:20'),
(204,2,'payment_created','Pago registrado','Solicitud ID: 89 - Método: efectivo - Pago ID: 83','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 16:54:02'),
(205,6,'payment_confirmed','Pago confirmado','Solicitud ID: 89 - Pago ID: 83','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 16:55:46'),
(206,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 17:04:33'),
(207,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 17:05:02'),
(208,6,'request_completed','Servicio finalizado','Solicitud ID: 89','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 17:05:48'),
(209,2,'request_created','Solicitud creada','ID: 90 - Servicio: 10 - Proveedor: 6','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 17:07:35'),
(210,6,'request_accepted','Solicitud aceptada','Solicitud ID: 90','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 17:07:53'),
(211,6,'request_accepted','Solicitud aceptada','Solicitud ID: 90','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 17:08:03'),
(212,2,'payment_created','Pago registrado','Solicitud ID: 90 - Método: efectivo - Pago ID: 84','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 17:11:37'),
(213,6,'payment_confirmed','Pago confirmado','Solicitud ID: 90 - Pago ID: 84','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 17:11:56'),
(214,6,'request_completed','Servicio finalizado','Solicitud ID: 90','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 17:12:17'),
(215,2,'request_created','Solicitud creada','ID: 91 - Servicio: 10 - Proveedor: 6','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 17:23:56'),
(216,6,'request_accepted','Solicitud aceptada','Solicitud ID: 91','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 17:24:01'),
(217,2,'payment_created','Pago registrado','Solicitud ID: 91 - Método: efectivo - Pago ID: 85','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 17:24:07'),
(218,6,'payment_confirmed','Pago confirmado','Solicitud ID: 91 - Pago ID: 85','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 17:24:17'),
(219,6,'request_completed','Servicio finalizado','Solicitud ID: 91','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 17:24:38'),
(220,2,'request_created','Solicitud creada','ID: 92 - Servicio: 10 - Proveedor: 6','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 18:25:33'),
(221,6,'request_accepted','Solicitud aceptada','Solicitud ID: 92','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 18:25:37'),
(222,2,'payment_created','Pago registrado','Solicitud ID: 92 - Método: efectivo - Pago ID: 86','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 18:25:41'),
(223,6,'payment_confirmed','Pago confirmado','Solicitud ID: 92 - Pago ID: 86','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 18:25:50'),
(224,6,'request_completed','Servicio finalizado','Solicitud ID: 92','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 18:26:06'),
(225,2,'request_created','Solicitud creada','ID: 93 - Servicio: 10 - Proveedor: 6','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 18:42:24'),
(226,6,'request_accepted','Solicitud aceptada','Solicitud ID: 93','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 18:42:39'),
(227,2,'payment_created','Pago registrado','Solicitud ID: 93 - Método: efectivo - Pago ID: 87','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 18:42:46'),
(228,6,'payment_confirmed','Pago confirmado','Solicitud ID: 93 - Pago ID: 87','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 18:42:55'),
(229,6,'request_completed','Servicio finalizado','Solicitud ID: 93','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 18:43:19'),
(230,2,'request_created','Solicitud creada','ID: 94 - Servicio: 10 - Proveedor: 6','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 20:57:50'),
(231,6,'request_accepted','Solicitud aceptada','Solicitud ID: 94','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 20:57:53'),
(232,2,'payment_created','Pago registrado','Solicitud ID: 94 - Método: efectivo - Pago ID: 88','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 20:57:57'),
(233,6,'payment_confirmed','Pago confirmado','Solicitud ID: 94 - Pago ID: 88','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 20:58:16'),
(234,6,'request_completed','Servicio finalizado','Solicitud ID: 94','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 20:58:31'),
(235,2,'request_created','Solicitud creada','ID: 95 - Servicio: 10 - Proveedor: 6','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 22:40:50'),
(236,6,'request_accepted','Solicitud aceptada','Solicitud ID: 95','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 22:40:53'),
(237,2,'payment_created','Pago registrado','Solicitud ID: 95 - Método: efectivo - Pago ID: 89','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 22:40:58'),
(238,6,'payment_confirmed','Pago confirmado','Solicitud ID: 95 - Pago ID: 89','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 22:41:10'),
(239,6,'request_completed','Servicio finalizado','Solicitud ID: 95','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 22:41:27'),
(240,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 22:44:48'),
(241,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 22:45:26'),
(242,2,'request_created','Solicitud creada','ID: 96 - Servicio: 10 - Proveedor: 6','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 22:46:11'),
(243,6,'request_accepted','Solicitud aceptada','Solicitud ID: 96','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 22:46:14'),
(244,2,'payment_created','Pago registrado','Solicitud ID: 96 - Método: efectivo - Pago ID: 90','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 22:46:18'),
(245,6,'payment_confirmed','Pago confirmado','Solicitud ID: 96 - Pago ID: 90','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 22:46:28'),
(246,6,'request_completed','Servicio finalizado','Solicitud ID: 96','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-05 22:46:46'),
(247,2,'request_created','Solicitud creada','ID: 97 - Servicio: 10 - Proveedor: 6','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-06 00:13:20'),
(248,6,'request_accepted','Solicitud aceptada','Solicitud ID: 97','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-06 00:13:24'),
(249,2,'payment_created','Pago registrado','Solicitud ID: 97 - Método: efectivo - Pago ID: 91','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-06 00:13:38'),
(250,6,'payment_confirmed','Pago confirmado','Solicitud ID: 97 - Pago ID: 91','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-06 00:13:53'),
(251,6,'request_completed','Servicio finalizado','Solicitud ID: 97','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-06 00:14:10'),
(252,2,'request_created','Solicitud creada','ID: 98 - Servicio: 10 - Proveedor: 6','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-06 01:05:48'),
(253,6,'request_accepted','Solicitud aceptada','Solicitud ID: 98','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-06 01:05:56'),
(254,2,'payment_created','Pago registrado','Solicitud ID: 98 - Método: efectivo - Pago ID: 92','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-06 01:06:04'),
(255,6,'payment_confirmed','Pago confirmado','Solicitud ID: 98 - Pago ID: 92','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-06 01:06:14'),
(256,6,'request_completed','Servicio finalizado','Solicitud ID: 98','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-06 01:06:33'),
(257,2,'request_created','Solicitud creada','ID: 99 - Servicio: 11 - Proveedor: 6','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-06 01:53:19'),
(258,6,'request_accepted','Solicitud aceptada','Solicitud ID: 99','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-06 01:53:22'),
(259,2,'payment_created','Pago registrado','Solicitud ID: 99 - Método: efectivo - Pago ID: 93','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-06 01:53:33'),
(260,6,'payment_confirmed','Pago confirmado','Solicitud ID: 99 - Pago ID: 93','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-06 01:53:38'),
(261,6,'request_completed','Servicio finalizado','Solicitud ID: 99','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-06 01:53:59'),
(262,2,'request_created','Solicitud creada','ID: 100 - Servicio: 10 - Proveedor: 6','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-06 21:27:13'),
(263,6,'request_accepted','Solicitud aceptada','Solicitud ID: 100','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-06 21:27:17'),
(264,2,'payment_created','Pago registrado','Solicitud ID: 100 - Método: efectivo - Pago ID: 94','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-06 21:27:24'),
(265,6,'payment_confirmed','Pago confirmado','Solicitud ID: 100 - Pago ID: 94','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-06 21:27:33'),
(266,6,'request_completed','Servicio finalizado','Solicitud ID: 100','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-06 21:27:53'),
(267,10,'login','Inicio de sesión','Usuario: Angie Gutiérrez (angie@gmail.com) - Rol: provider','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-08 22:08:07'),
(268,10,'request_rejected','Solicitud rechazada','Solicitud ID: 77','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-08 23:14:14'),
(269,10,'request_accepted','Solicitud aceptada','Solicitud ID: 77','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-08 23:14:18'),
(270,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.110.108','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-08 23:14:53'),
(271,2,'payment_created','Pago registrado','Solicitud ID: 77 - Método: efectivo - Pago ID: 95','192.168.110.108','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 00:44:27'),
(272,2,'payment_created','Pago registrado','Solicitud ID: 77 - Método: efectivo - Pago ID: 96','192.168.110.108','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 01:00:43'),
(273,10,'payment_confirmed','Pago confirmado','Solicitud ID: 77 - Pago ID: 96','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 01:01:25'),
(274,10,'request_completed','Servicio finalizado','Solicitud ID: 77','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 01:01:57'),
(275,2,'request_created','Solicitud creada','ID: 101 - Servicio: 33 - Proveedor: 10','192.168.110.108','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 01:04:09'),
(276,10,'request_rejected','Solicitud rechazada','Solicitud ID: 101','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 01:08:06'),
(277,10,'request_rejected','Solicitud rechazada','Solicitud ID: 101','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 01:08:08'),
(278,10,'request_rejected','Solicitud rechazada','Solicitud ID: 101','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 01:08:10'),
(279,10,'request_rejected','Solicitud rechazada','Solicitud ID: 101','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 01:08:11'),
(280,2,'request_created','Solicitud creada','ID: 102 - Servicio: 33 - Proveedor: 10','192.168.110.108','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 01:09:09'),
(281,10,'request_rejected','Solicitud rechazada','Solicitud ID: 102','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 01:09:50'),
(282,10,'request_rejected','Solicitud rechazada','Solicitud ID: 102','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 01:09:52'),
(283,2,'request_created','Solicitud creada','ID: 103 - Servicio: 33 - Proveedor: 10','192.168.110.108','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 01:19:49'),
(284,10,'request_rejected','Solicitud rechazada','Solicitud ID: 103','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 01:21:24'),
(285,2,'request_created','Solicitud creada','ID: 104 - Servicio: 33 - Proveedor: 10','192.168.110.108','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 02:57:10'),
(286,10,'request_rejected','Solicitud rechazada','Solicitud ID: 104','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 02:57:37'),
(287,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 03:01:27'),
(288,2,'request_created','Solicitud creada','ID: 105 - Servicio: 10 - Proveedor: 6','192.168.110.108','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 03:02:26'),
(289,2,'request_cancelled','Solicitud cancelada','Solicitud ID: 105 - Por: user','192.168.110.108','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 03:07:37'),
(290,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 03:09:41'),
(291,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.110.108','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 03:10:43'),
(292,2,'request_created','Solicitud creada','ID: 106 - Servicio: 11 - Proveedor: 6','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 03:11:51'),
(293,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.110.108','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 13:36:33'),
(294,6,'request_rejected','Solicitud rechazada','Solicitud ID: 106','192.168.110.108','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 13:36:51'),
(295,2,'request_created','Solicitud creada','ID: 107 - Servicio: 11 - Proveedor: 6','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 13:37:06'),
(296,6,'request_accepted','Solicitud aceptada','Solicitud ID: 107','192.168.110.108','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 13:37:11'),
(297,2,'payment_created','Pago registrado','Solicitud ID: 107 - Método: efectivo - Pago ID: 97','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 13:37:17'),
(298,6,'payment_confirmed','Pago confirmado','Solicitud ID: 107 - Pago ID: 97','192.168.110.108','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 13:37:25'),
(299,6,'request_completed','Servicio finalizado','Solicitud ID: 107','192.168.110.108','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 13:37:39'),
(300,2,'request_created','Solicitud creada','ID: 108 - Servicio: 12 - Proveedor: 6','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 13:39:12'),
(301,6,'request_accepted','Solicitud aceptada','Solicitud ID: 108','192.168.110.108','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 13:39:29'),
(302,2,'payment_created','Pago registrado','Solicitud ID: 108 - Método: efectivo - Pago ID: 98','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 13:39:39'),
(303,6,'payment_confirmed','Pago confirmado','Solicitud ID: 108 - Pago ID: 98','192.168.110.108','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 13:40:43'),
(304,6,'request_completed','Servicio finalizado','Solicitud ID: 108','192.168.110.108','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 13:41:47'),
(305,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 15:18:14'),
(306,6,'profile_updated','Perfil actualizado','Nombre: María Villegas','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 15:22:12'),
(307,6,'profile_updated','Perfil actualizado','Nombre: María Villegas','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 15:23:17'),
(308,6,'profile_updated','Perfil actualizado','Nombre: María Villegas','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 16:21:14'),
(309,6,'profile_updated','Perfil actualizado','Nombre: María Villegas','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 16:37:59'),
(310,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 20:41:16'),
(311,2,'profile_updated','Perfil actualizado','Nombre: Jesús Díaz Villegas','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 20:42:10'),
(312,2,'profile_updated','Perfil actualizado','Nombre: Jesús Díaz Villegas','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 21:14:02'),
(313,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.110.33','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/148.0.7778.215 Mobile Safari/537.36','2026-06-09 21:19:21'),
(314,2,'profile_updated','Perfil actualizado','Nombre: Jesús Díaz Villegas','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-09 22:03:39'),
(315,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-10 00:36:32'),
(316,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-10 00:40:42'),
(317,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-10 00:49:08'),
(318,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.110.108','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-10 12:56:01'),
(319,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.110.108','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-10 12:57:11'),
(320,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.110.108','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-10 13:02:29'),
(321,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-10 13:17:53'),
(322,11,'register','Nuevo registro','Usuario: Yeximar Escalona (yeximar@gmail.com) - Rol: user','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-10 13:58:16'),
(323,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-10 13:59:23'),
(324,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-12 10:55:49'),
(325,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-13 05:46:45'),
(326,6,'staff_created','Personal creado','ID: 1 - María kuica - Rol: delivery','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-13 06:05:12'),
(327,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.1.103','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-14 01:51:42'),
(328,6,'staff_created','Personal creado','ID: 2 - Juan colmenarez - Rol: delivery','192.168.1.103','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-14 01:59:34'),
(329,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.1.103','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-14 02:51:58'),
(330,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.1.103','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-14 20:01:27'),
(331,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.1.103','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-14 20:05:33'),
(332,2,'request_created','Solicitud creada','ID: 109 - Servicio: 12 - Proveedor: 6','192.168.1.103','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-14 20:05:57'),
(333,6,'request_accepted','Solicitud aceptada','Solicitud ID: 109','192.168.1.103','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-14 20:06:05'),
(334,2,'payment_created','Pago registrado','Solicitud ID: 109 - Método: efectivo - Pago ID: 99','192.168.1.103','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-14 20:06:39'),
(335,6,'payment_confirmed','Pago confirmado','Solicitud ID: 109 - Pago ID: 99','192.168.1.103','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-14 20:06:47'),
(336,6,'request_completed','Servicio finalizado','Solicitud ID: 109','192.168.1.103','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-14 20:06:59'),
(337,2,'request_created','Solicitud creada','ID: 110 - Servicio: 10 - Proveedor: 6','192.168.1.103','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-14 20:07:29'),
(338,6,'request_accepted','Solicitud aceptada','Solicitud ID: 110','192.168.1.103','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-14 20:08:08'),
(339,2,'payment_created','Pago registrado','Solicitud ID: 110 - Método: efectivo - Pago ID: 100','192.168.1.103','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-14 20:08:30'),
(340,6,'payment_confirmed','Pago confirmado','Solicitud ID: 110 - Pago ID: 100','192.168.1.103','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-14 20:08:38'),
(341,6,'request_completed','Servicio finalizado','Solicitud ID: 110','192.168.1.103','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-14 20:08:57'),
(342,2,'request_created','Solicitud creada','ID: 111 - Servicio: 11 - Proveedor: 6','192.168.1.103','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-14 20:14:24'),
(343,6,'request_accepted','Solicitud aceptada','Solicitud ID: 111','192.168.1.103','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-14 20:14:59'),
(344,2,'payment_created','Pago registrado','Solicitud ID: 111 - Método: efectivo - Pago ID: 101','192.168.1.103','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-14 20:15:23'),
(345,6,'payment_confirmed','Pago confirmado','Solicitud ID: 111 - Pago ID: 101','192.168.1.103','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-14 20:18:00'),
(346,2,'payment_created','Pago registrado','Solicitud ID: 111 - Método: efectivo - Pago ID: 102','192.168.1.103','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-14 20:44:02'),
(347,6,'payment_confirmed','Pago confirmado','Solicitud ID: 111 - Pago ID: 102','192.168.1.103','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-14 20:44:34'),
(348,6,'request_completed','Servicio finalizado','Solicitud ID: 111','192.168.1.103','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-14 20:44:48'),
(349,2,'request_created','Solicitud creada','ID: 112 - Servicio: 12 - Proveedor: 6','192.168.1.103','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-14 20:45:09'),
(350,6,'request_accepted','Solicitud aceptada','Solicitud ID: 112','192.168.1.103','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-14 23:19:15'),
(351,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.99.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-15 10:30:58'),
(352,6,'delivery_assigned','Delivery asignado','Pedido: 112 → Staff: 2','192.168.99.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-15 11:04:13'),
(353,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.99.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-15 15:08:15'),
(354,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.99.12','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-15 16:00:24'),
(355,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.99.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-15 16:02:42'),
(356,2,'payment_created','Pago registrado','Solicitud ID: 112 - Método: efectivo - Pago ID: 103','192.168.99.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-15 16:03:04'),
(357,6,'payment_confirmed','Pago confirmado','Solicitud ID: 112 - Pago ID: 103','192.168.99.12','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-15 16:03:15'),
(358,6,'request_completed','Servicio finalizado','Solicitud ID: 112','192.168.99.12','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-15 16:03:19'),
(359,2,'request_created','Solicitud creada','ID: 113 - Servicio: 11 - Proveedor: 6','192.168.99.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-15 16:03:42'),
(360,6,'request_accepted','Solicitud aceptada','Solicitud ID: 113','192.168.99.12','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-15 16:03:48'),
(361,6,'delivery_assigned','Delivery asignado','Pedido: 113 → Staff: 2','192.168.99.12','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-15 16:04:01'),
(362,2,'payment_created','Pago registrado','Solicitud ID: 113 - Método: efectivo - Pago ID: 104','192.168.99.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-15 16:04:12'),
(363,6,'payment_confirmed','Pago confirmado','Solicitud ID: 113 - Pago ID: 104','192.168.99.12','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-15 16:04:55'),
(364,6,'request_completed','Servicio finalizado','Solicitud ID: 113','192.168.99.12','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-15 16:04:58'),
(365,2,'request_created','Solicitud creada','ID: 114 - Servicio: 10 - Proveedor: 6','192.168.99.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-15 16:05:20'),
(366,6,'request_accepted','Solicitud aceptada','Solicitud ID: 114','192.168.99.12','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-15 16:05:31'),
(367,6,'delivery_assigned','Delivery asignado','Pedido: 114 → Staff: 2','192.168.99.12','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-15 16:05:40'),
(368,2,'payment_created','Pago registrado','Solicitud ID: 114 - Método: efectivo - Pago ID: 105','192.168.99.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-15 16:05:47'),
(369,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.99.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-16 11:07:10'),
(370,6,'payment_confirmed','Pago confirmado','Solicitud ID: 114 - Pago ID: 105','192.168.99.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-16 11:07:50'),
(371,6,'request_completed','Servicio finalizado','Solicitud ID: 114','192.168.99.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-16 11:08:00'),
(372,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.99.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-16 12:23:09'),
(373,2,'request_created','Solicitud creada','ID: 115 - Servicio: 10 - Proveedor: 6','192.168.99.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-16 12:23:47'),
(374,6,'request_accepted','Solicitud aceptada','Solicitud ID: 115','192.168.99.12','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-16 12:24:06'),
(375,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.99.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-16 12:25:24'),
(376,2,'payment_created','Pago registrado','Solicitud ID: 115 - Método: efectivo - Pago ID: 106','192.168.99.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-16 12:28:21'),
(377,6,'payment_confirmed','Pago confirmado','Solicitud ID: 115 - Pago ID: 106','192.168.99.12','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-16 12:28:36'),
(378,6,'delivery_assigned','Delivery asignado','Pedido: 115 → Staff: 2','192.168.99.12','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-16 12:28:41'),
(379,6,'request_completed','Servicio finalizado','Solicitud ID: 115','192.168.99.12','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-16 12:34:25'),
(380,2,'request_created','Solicitud creada','ID: 116 - Servicio: 10 - Proveedor: 6','192.168.99.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-16 16:00:50'),
(381,6,'request_accepted','Solicitud aceptada','Solicitud ID: 116','192.168.99.12','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-16 16:00:56'),
(382,2,'payment_created','Pago registrado','Solicitud ID: 116 - Método: efectivo - Pago ID: 107','192.168.99.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-16 16:01:07'),
(383,6,'payment_confirmed','Pago confirmado','Solicitud ID: 116 - Pago ID: 107','192.168.99.12','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-16 16:15:24'),
(384,6,'delivery_assigned','Delivery asignado','Pedido: 116 → Staff: 2','192.168.99.12','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-16 16:15:55'),
(385,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-17 13:38:21'),
(386,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-17 13:45:50'),
(387,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-17 14:30:35'),
(388,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-17 14:32:55'),
(389,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-17 14:35:23'),
(390,6,'request_completed','Servicio finalizado','Solicitud ID: 116','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-17 14:36:02'),
(391,2,'request_created','Solicitud creada','ID: 117 - Servicio: 10 - Proveedor: 6','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-17 14:50:13'),
(392,6,'request_accepted','Solicitud aceptada','Solicitud ID: 117','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-17 14:50:19'),
(393,6,'delivery_assigned','Delivery asignado','Pedido: 117 → Staff: 2','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-17 14:50:28'),
(394,2,'payment_created','Pago registrado','Solicitud ID: 117 - Método: efectivo - Pago ID: 108','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-17 14:50:38'),
(395,6,'payment_confirmed','Pago confirmado','Solicitud ID: 117 - Pago ID: 108','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-17 14:51:22'),
(396,10,'login','Inicio de sesión','Usuario: Angie Gutiérrez (angie@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0','2026-06-18 04:02:19'),
(397,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-21 11:31:46'),
(398,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.110.108','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-22 10:32:42'),
(399,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-22 10:40:05'),
(400,10,'login','Inicio de sesión','Usuario: Angie Gutiérrez (angie@gmail.com) - Rol: provider','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-22 10:42:16'),
(401,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-22 10:45:02'),
(402,10,'login','Inicio de sesión','Usuario: Angie Gutiérrez (angie@gmail.com) - Rol: provider','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-22 10:45:49'),
(403,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.110.33','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-22 10:47:53'),
(404,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.110.108','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-22 10:48:03'),
(405,10,'login','Inicio de sesión','Usuario: Angie Gutiérrez (angie@gmail.com) - Rol: provider','192.168.110.108','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-22 10:48:27'),
(406,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.110.108','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-22 11:45:08'),
(407,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.232.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-22 17:24:07'),
(408,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.232.247','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-22 17:25:44'),
(409,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.232.247','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-22 17:29:28'),
(410,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.232.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-22 20:06:14'),
(411,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-27 16:31:06'),
(412,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64; rv:152.0) Gecko/20100101 Firefox/152.0','2026-06-27 16:32:05'),
(413,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-27 16:40:39'),
(414,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-27 16:52:07'),
(415,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64; rv:152.0) Gecko/20100101 Firefox/152.0','2026-06-27 16:52:38'),
(416,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-28 10:40:54'),
(417,2,'request_created','Solicitud creada','ID: 1 - Servicio: 11 - Proveedor: 6','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-28 10:42:08'),
(418,6,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64; rv:152.0) Gecko/20100101 Firefox/152.0','2026-06-28 10:42:24'),
(419,6,'delivery_assigned','Delivery asignado','Pedido: 1 → Staff: 2','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64; rv:152.0) Gecko/20100101 Firefox/152.0','2026-06-28 10:42:37'),
(420,2,'payment_created','Pago registrado','Solicitud ID: 1 - Método: efectivo - Pago ID: 1','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-28 10:42:59'),
(421,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-28 19:29:12'),
(422,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64; rv:152.0) Gecko/20100101 Firefox/152.0','2026-06-28 19:29:57'),
(423,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-28 19:34:12'),
(424,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-28 19:40:35'),
(425,2,'request_created','Solicitud creada','ID: 1 - Servicio: 11 - Proveedor: 6','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-28 19:41:04'),
(426,6,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64; rv:152.0) Gecko/20100101 Firefox/152.0','2026-06-28 19:41:28'),
(427,6,'delivery_assigned','Delivery asignado','Pedido: 1 → Staff: 2','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64; rv:152.0) Gecko/20100101 Firefox/152.0','2026-06-28 19:41:37'),
(428,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-29 01:53:57'),
(429,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-29 01:56:28'),
(430,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-29 01:58:48'),
(431,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-29 02:22:05'),
(432,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-29 10:08:56'),
(433,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64; rv:152.0) Gecko/20100101 Firefox/152.0','2026-06-29 10:11:36'),
(434,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-30 11:23:53'),
(435,2,'request_created','Solicitud creada','ID: 1 - Servicio: 10 - Proveedor: 6','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-30 11:26:30'),
(436,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64; rv:152.0) Gecko/20100101 Firefox/152.0','2026-06-30 11:27:05'),
(437,6,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64; rv:152.0) Gecko/20100101 Firefox/152.0','2026-06-30 11:27:13'),
(438,2,'payment_created','Pago registrado','Solicitud ID: 1 - Método: efectivo - Pago ID: 1','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-30 11:27:44'),
(439,6,'payment_confirmed','Pago confirmado','Solicitud ID: 1 - Pago ID: 1','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64; rv:152.0) Gecko/20100101 Firefox/152.0','2026-06-30 11:28:11'),
(440,6,'delivery_assigned','Delivery asignado','Pedido: 1 → Staff: 2','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64; rv:152.0) Gecko/20100101 Firefox/152.0','2026-06-30 11:29:29'),
(441,2,'request_created','Solicitud creada','ID: 1 - Servicio: 10 - Proveedor: 6','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-30 11:42:41'),
(442,6,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64; rv:152.0) Gecko/20100101 Firefox/152.0','2026-06-30 11:42:46'),
(443,2,'payment_created','Pago registrado','Solicitud ID: 1 - Método: efectivo - Pago ID: 1','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-30 11:42:54'),
(444,6,'payment_confirmed','Pago confirmado','Solicitud ID: 1 - Pago ID: 1','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64; rv:152.0) Gecko/20100101 Firefox/152.0','2026-06-30 11:43:13'),
(445,6,'delivery_assigned','Delivery asignado','Pedido: 1 → Staff: 2','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64; rv:152.0) Gecko/20100101 Firefox/152.0','2026-06-30 11:43:19'),
(446,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.43.2','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-02 02:49:29'),
(447,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-03 11:22:40'),
(448,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.43.1','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/149.0.7827.164 Mobile Safari/537.36','2026-07-03 11:26:00'),
(449,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-03 12:44:39'),
(450,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64; rv:152.0) Gecko/20100101 Firefox/152.0','2026-07-03 14:12:35'),
(451,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.43.1','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/149.0.7827.164 Mobile Safari/537.36','2026-07-03 14:14:21'),
(452,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-03 16:19:50'),
(453,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-04 20:15:09'),
(454,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64; rv:152.0) Gecko/20100101 Firefox/152.0','2026-07-04 20:15:52'),
(455,2,'request_created','Solicitud creada','ID: 1 - Servicio: 11 - Proveedor: 6','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-04 20:16:18'),
(456,6,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64; rv:152.0) Gecko/20100101 Firefox/152.0','2026-07-04 20:16:24'),
(457,2,'payment_created','Pago registrado','Solicitud ID: 1 - Método: efectivo - Pago ID: 1','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-04 20:16:31'),
(458,6,'payment_confirmed','Pago confirmado','Solicitud ID: 1 - Pago ID: 1','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64; rv:152.0) Gecko/20100101 Firefox/152.0','2026-07-04 20:16:42'),
(459,6,'delivery_assigned','Delivery asignado','Pedido: 1 → Staff: 2','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64; rv:152.0) Gecko/20100101 Firefox/152.0','2026-07-04 20:16:47'),
(460,2,'staff_logout','Staff cerró sesión',NULL,'192.168.43.1','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/149.0.7827.164 Mobile Safari/537.36','2026-07-05 10:30:03'),
(461,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-05 18:32:00'),
(462,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-05 18:32:07'),
(463,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-05 19:46:08'),
(464,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-05 20:18:17'),
(465,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-05 20:39:00'),
(466,2,'staff_logout','Staff cerró sesión',NULL,'192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-05 20:43:17'),
(467,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-05 21:17:56'),
(468,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-05 21:21:19'),
(469,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-05 21:34:59'),
(470,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-05 21:48:01'),
(471,2,'staff_logout','Staff cerró sesión',NULL,'192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-05 22:12:42'),
(472,2,'staff_logout','Staff cerró sesión',NULL,'192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-05 22:13:19'),
(473,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-05 22:38:11'),
(474,2,'staff_logout','Staff cerró sesión',NULL,'192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-05 22:40:36'),
(475,2,'staff_logout','Staff cerró sesión',NULL,'192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-05 22:42:12'),
(476,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-05 22:49:04'),
(477,2,'staff_logout','Staff cerró sesión',NULL,'192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-05 23:19:54'),
(478,2,'staff_logout','Staff cerró sesión',NULL,'192.168.31.53','curl/8.17.0','2026-07-05 23:22:48'),
(479,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-06 02:43:29'),
(480,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-06 02:44:01'),
(481,2,'staff_logout','Staff cerró sesión',NULL,'192.168.31.53','curl/8.17.0','2026-07-06 03:01:04'),
(482,2,'staff_logout','Staff cerró sesión',NULL,'192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-06 03:15:11'),
(483,2,'staff_logout','Staff cerró sesión',NULL,'192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-06 04:40:53'),
(484,2,'staff_logout','Staff cerró sesión',NULL,'192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-06 04:41:51'),
(485,2,'staff_logout','Staff cerró sesión',NULL,'192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-06 04:44:10'),
(486,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-06 04:45:35'),
(487,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-06 04:47:02'),
(488,2,'staff_logout','Staff cerró sesión',NULL,'192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-06 05:02:35'),
(489,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-06 05:02:54'),
(490,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-06 05:22:25'),
(491,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-08 17:37:10'),
(492,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.43.2','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-08 17:37:32'),
(493,2,'staff_logout','Staff cerró sesión',NULL,'192.168.43.2','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-08 17:52:26'),
(494,2,'staff_logout','Staff cerró sesión',NULL,'192.168.43.2','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-08 17:55:11'),
(495,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.43.2','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-08 17:56:06'),
(496,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.43.1','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/149.0.7827.164 Mobile Safari/537.36','2026-07-09 11:00:43'),
(497,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.43.2','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-09 13:25:30'),
(498,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-09 16:47:31'),
(499,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.43.2','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-09 16:48:14'),
(500,2,'staff_logout','Staff cerró sesión',NULL,'192.168.43.2','Mozilla/5.0 (Android 13; Mobile; rv:152.0) Gecko/152.0 Firefox/152.0','2026-07-09 16:50:08'),
(501,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.43.2','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-09 16:54:24'),
(502,2,'staff_logout','Staff cerró sesión',NULL,'192.168.43.2','Mozilla/5.0 (Android 13; Mobile; rv:152.0) Gecko/152.0 Firefox/152.0','2026-07-09 16:55:00'),
(503,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-09 16:56:39'),
(504,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.43.2','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-09 16:59:48'),
(505,2,'staff_logout','Staff cerró sesión',NULL,'192.168.43.2','Mozilla/5.0 (Android 13; Mobile; rv:152.0) Gecko/152.0 Firefox/152.0','2026-07-09 17:01:08'),
(506,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.43.2','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-09 17:05:03'),
(507,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-09 17:07:38'),
(508,2,'staff_logout','Staff cerró sesión',NULL,'192.168.43.2','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-09 17:44:39'),
(509,2,'staff_logout','Staff cerró sesión',NULL,'192.168.43.2','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-09 17:50:03'),
(510,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.43.2','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-09 18:08:03'),
(511,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-09 18:52:40'),
(512,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.43.2','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-09 18:54:22'),
(513,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.43.2','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-09 18:56:55'),
(514,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-09 18:57:30'),
(515,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.43.2','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-09 18:57:40'),
(516,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.43.2','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-09 18:58:40'),
(517,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64; rv:152.0) Gecko/20100101 Firefox/152.0','2026-07-09 19:07:07'),
(518,2,'staff_logout','Staff cerró sesión',NULL,'192.168.43.1','Mozilla/5.0 (X11; Linux x86_64; rv:152.0) Gecko/20100101 Firefox/152.0','2026-07-09 19:22:55'),
(519,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64; rv:152.0) Gecko/20100101 Firefox/152.0','2026-07-09 19:49:47'),
(520,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64; rv:152.0) Gecko/20100101 Firefox/152.0','2026-07-09 19:50:41'),
(521,2,'staff_logout','Staff cerró sesión',NULL,'192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-10 16:32:25'),
(522,2,'staff_logout','Staff cerró sesión',NULL,'192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-10 16:33:07'),
(523,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-10 16:33:38'),
(524,2,'staff_logout','Staff cerró sesión',NULL,'192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-10 16:34:38'),
(525,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-11 05:28:40'),
(526,2,'request_cancelled','Solicitud cancelada','Solicitud ID: 1 - Por: user','192.168.43.2','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-11 05:44:02'),
(527,2,'profile_updated','Perfil actualizado','Nombre: Jesús Díaz Villegas','192.168.43.2','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-11 06:14:18'),
(528,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-11 06:18:27'),
(529,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.43.2','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-11 07:01:33'),
(530,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-11 07:25:37'),
(531,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-11 07:27:11'),
(532,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-11 07:28:33'),
(533,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.43.2','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-11 07:54:08'),
(534,2,'request_created','Solicitud creada','ID: 1 - Servicio: 10 - Proveedor: 6','192.168.43.2','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-11 07:54:35'),
(535,6,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-11 07:54:59'),
(536,2,'payment_created','Pago registrado','Solicitud ID: 1 - Método: efectivo - Pago ID: 1','192.168.43.2','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-11 07:55:10'),
(537,6,'payment_confirmed','Pago confirmado','Solicitud ID: 1 - Pago ID: 1','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-11 07:56:34'),
(538,6,'request_completed','Servicio finalizado','Solicitud ID: 1','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-11 07:56:38'),
(539,2,'request_created','Solicitud creada','ID: 1 - Servicio: 10 - Proveedor: 6','192.168.43.2','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-11 07:59:14'),
(540,6,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-11 07:59:26'),
(541,2,'payment_created','Pago registrado','Solicitud ID: 1 - Método: efectivo - Pago ID: 1','192.168.43.2','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-11 07:59:32'),
(542,6,'payment_confirmed','Pago confirmado','Solicitud ID: 1 - Pago ID: 1','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-11 07:59:39'),
(543,6,'request_completed','Servicio finalizado','Solicitud ID: 1','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-11 07:59:48'),
(544,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','127.0.0.1','curl/8.17.0','2026-07-11 21:40:31'),
(545,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','127.0.0.1','curl/8.17.0','2026-07-11 21:57:57'),
(546,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','127.0.0.1','curl/8.17.0','2026-07-12 16:14:11'),
(547,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','127.0.0.1','curl/8.17.0','2026-07-12 16:15:56'),
(548,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-12 19:07:17'),
(549,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-12 19:07:20'),
(550,2,'request_created','Solicitud creada','ID: 2 - Servicio: 11 - Proveedor: 6','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-12 19:08:01'),
(551,6,'request_accepted','Solicitud aceptada','Solicitud ID: 2','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-12 19:08:21'),
(552,2,'payment_created','Pago registrado','Solicitud ID: 2 - Método: efectivo - Pago ID: 2','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-12 19:08:28'),
(553,6,'payment_confirmed','Pago confirmado','Solicitud ID: 2 - Pago ID: 2','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-12 19:08:42'),
(554,6,'request_completed','Servicio finalizado','Solicitud ID: 2','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-12 19:09:38'),
(555,2,'request_created','Solicitud creada','ID: 3 - Servicio: 10 - Proveedor: 6','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-12 19:10:23'),
(556,6,'request_accepted','Solicitud aceptada','Solicitud ID: 3','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-12 19:11:06'),
(557,2,'payment_created','Pago registrado','Solicitud ID: 3 - Método: efectivo - Pago ID: 3','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-12 19:12:13'),
(558,6,'payment_confirmed','Pago confirmado','Solicitud ID: 3 - Pago ID: 3','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-12 19:12:35'),
(559,6,'request_completed','Servicio finalizado','Solicitud ID: 3','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-12 19:12:47'),
(560,2,'request_created','Solicitud creada','ID: 4 - Servicio: 11 - Proveedor: 6','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-12 19:13:32'),
(561,6,'request_rejected','Solicitud rechazada','Solicitud ID: 4','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-12 19:51:37'),
(562,2,'request_created','Solicitud creada','ID: 5 - Servicio: 11 - Proveedor: 6','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-12 19:51:50'),
(563,6,'request_accepted','Solicitud aceptada','Solicitud ID: 5','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-12 19:51:58'),
(564,2,'payment_created','Pago registrado','Solicitud ID: 5 - Método: efectivo - Pago ID: 4','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-12 19:52:02'),
(565,6,'payment_confirmed','Pago confirmado','Solicitud ID: 5 - Pago ID: 4','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-12 19:52:10'),
(566,6,'request_completed','Servicio finalizado','Solicitud ID: 5','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-12 19:52:28'),
(567,2,'request_created','Solicitud creada','ID: 6 - Servicio: 11 - Proveedor: 6','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-12 19:52:49'),
(568,6,'request_accepted','Solicitud aceptada','Solicitud ID: 6','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-12 19:52:53'),
(569,2,'payment_created','Pago registrado','Solicitud ID: 6 - Método: efectivo - Pago ID: 5','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-12 19:53:01'),
(570,6,'payment_confirmed','Pago confirmado','Solicitud ID: 6 - Pago ID: 5','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-12 19:53:11'),
(571,6,'request_completed','Servicio finalizado','Solicitud ID: 6','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-12 19:53:24'),
(572,2,'request_created','Solicitud creada','ID: 7 - Servicio: 12 - Proveedor: 6','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-12 19:59:21'),
(573,6,'request_accepted','Solicitud aceptada','Solicitud ID: 7','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-12 19:59:38'),
(574,2,'payment_created','Pago registrado','Solicitud ID: 7 - Método: efectivo - Pago ID: 6','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-12 19:59:41'),
(575,6,'payment_confirmed','Pago confirmado','Solicitud ID: 7 - Pago ID: 6','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-12 19:59:50'),
(576,6,'request_completed','Servicio finalizado','Solicitud ID: 7','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-12 20:00:12'),
(577,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-12 20:02:14'),
(578,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/149.0.7827.164 Mobile Safari/537.36','2026-07-12 20:03:24'),
(579,2,'request_created','Solicitud creada','ID: 8 - Servicio: 11 - Proveedor: 6','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-12 20:03:46'),
(580,6,'request_accepted','Solicitud aceptada','Solicitud ID: 8','192.168.31.53','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/149.0.7827.164 Mobile Safari/537.36','2026-07-12 20:03:50'),
(581,2,'payment_created','Pago registrado','Solicitud ID: 8 - Método: efectivo - Pago ID: 7','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-12 20:03:57'),
(582,6,'payment_confirmed','Pago confirmado','Solicitud ID: 8 - Pago ID: 7','192.168.31.53','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/149.0.7827.164 Mobile Safari/537.36','2026-07-12 20:04:12'),
(583,6,'request_completed','Servicio finalizado','Solicitud ID: 8','192.168.31.53','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/149.0.7827.164 Mobile Safari/537.36','2026-07-12 20:04:34'),
(584,2,'request_created','Solicitud creada','ID: 9 - Servicio: 11 - Proveedor: 6','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-12 22:01:10'),
(585,6,'request_accepted','Solicitud aceptada','Solicitud ID: 9','192.168.31.53','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/149.0.7827.164 Mobile Safari/537.36','2026-07-12 22:01:19'),
(586,2,'payment_created','Pago registrado','Solicitud ID: 9 - Método: efectivo - Pago ID: 8','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-12 22:01:24'),
(587,6,'payment_confirmed','Pago confirmado','Solicitud ID: 9 - Pago ID: 8','192.168.31.53','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/149.0.7827.164 Mobile Safari/537.36','2026-07-12 22:01:44'),
(588,6,'request_completed','Servicio finalizado','Solicitud ID: 9','192.168.31.53','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/149.0.7827.164 Mobile Safari/537.36','2026-07-12 22:02:03'),
(589,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','127.0.0.1','curl/8.17.0','2026-07-12 22:58:27'),
(590,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','127.0.0.1','curl/8.17.0','2026-07-12 22:58:40'),
(591,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','127.0.0.1','curl/8.17.0','2026-07-13 00:53:32'),
(592,2,'request_created','Solicitud creada','ID: 10 - Servicio: 10 - Proveedor: 6','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-13 01:33:03'),
(593,6,'request_accepted','Solicitud aceptada','Solicitud ID: 10','192.168.31.53','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/149.0.7827.164 Mobile Safari/537.36','2026-07-13 01:33:10'),
(594,2,'payment_created','Pago registrado','Solicitud ID: 10 - Método: efectivo - Pago ID: 9','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-13 01:33:16'),
(595,6,'payment_confirmed','Pago confirmado','Solicitud ID: 10 - Pago ID: 9','192.168.31.53','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/149.0.7827.164 Mobile Safari/537.36','2026-07-13 01:33:39'),
(596,6,'request_completed','Servicio finalizado','Solicitud ID: 10','192.168.31.53','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/149.0.7827.164 Mobile Safari/537.36','2026-07-13 01:34:00'),
(597,2,'request_created','Solicitud creada','ID: 11 - Servicio: 10 - Proveedor: 6','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-13 01:37:54'),
(598,6,'request_accepted','Solicitud aceptada','Solicitud ID: 11','192.168.31.53','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/149.0.7827.164 Mobile Safari/537.36','2026-07-13 01:37:56'),
(599,2,'payment_created','Pago registrado','Solicitud ID: 11 - Método: efectivo - Pago ID: 10','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-13 01:38:00'),
(600,6,'payment_confirmed','Pago confirmado','Solicitud ID: 11 - Pago ID: 10','192.168.31.53','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/149.0.7827.164 Mobile Safari/537.36','2026-07-13 01:38:10'),
(601,6,'request_completed','Servicio finalizado','Solicitud ID: 11','192.168.31.53','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/149.0.7827.164 Mobile Safari/537.36','2026-07-13 01:38:22'),
(602,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-13 02:29:11'),
(603,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-13 02:29:34'),
(604,2,'request_created','Solicitud creada','ID: 12 - Servicio: 11 - Proveedor: 6','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-13 02:31:10'),
(605,6,'request_accepted','Solicitud aceptada','Solicitud ID: 12','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-13 02:31:13'),
(606,2,'payment_created','Pago registrado','Solicitud ID: 12 - Método: efectivo - Pago ID: 11','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-13 02:31:41'),
(607,6,'payment_confirmed','Pago confirmado','Solicitud ID: 12 - Pago ID: 11','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-13 02:31:47'),
(608,6,'request_completed','Servicio finalizado','Solicitud ID: 12','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-13 02:32:25'),
(609,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-13 02:36:57'),
(610,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-13 02:37:01'),
(611,2,'request_created','Solicitud creada','ID: 13 - Servicio: 11 - Proveedor: 6','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-13 02:37:19'),
(612,6,'request_accepted','Solicitud aceptada','Solicitud ID: 13','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-13 02:37:25'),
(613,2,'payment_created','Pago registrado','Solicitud ID: 13 - Método: efectivo - Pago ID: 12','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-13 02:37:31'),
(614,6,'payment_confirmed','Pago confirmado','Solicitud ID: 13 - Pago ID: 12','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-13 02:37:36'),
(615,6,'request_completed','Servicio finalizado','Solicitud ID: 13','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-13 02:37:54'),
(616,2,'request_created','Solicitud creada','ID: 14 - Servicio: 11 - Proveedor: 6','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-13 10:55:31'),
(617,6,'request_accepted','Solicitud aceptada','Solicitud ID: 14','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-13 10:55:35'),
(618,2,'payment_created','Pago registrado','Solicitud ID: 14 - Método: efectivo - Pago ID: 13','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-13 10:55:39'),
(619,6,'payment_confirmed','Pago confirmado','Solicitud ID: 14 - Pago ID: 13','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-13 10:55:49'),
(620,6,'request_completed','Servicio finalizado','Solicitud ID: 14','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-13 10:56:07'),
(621,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.100.6','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-14 18:21:32'),
(622,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.100.9','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-15 10:10:33'),
(623,2,'request_created','Solicitud creada','ID: 1 - Servicio: 11 - Proveedor: 6','192.168.100.6','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-15 10:27:19'),
(624,6,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.100.9','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-15 10:27:23'),
(625,2,'payment_created','Pago registrado','Solicitud ID: 1 - Método: efectivo - Pago ID: 1','192.168.100.6','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-15 10:27:28'),
(626,6,'payment_confirmed','Pago confirmado','Solicitud ID: 1 - Pago ID: 1','192.168.100.9','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-15 10:27:41'),
(627,6,'request_completed','Servicio finalizado','Solicitud ID: 1','192.168.100.9','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-15 10:28:36'),
(628,2,'request_created','Solicitud creada','ID: 2 - Servicio: 10 - Proveedor: 6','192.168.100.6','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-15 10:30:09'),
(629,6,'request_accepted','Solicitud aceptada','Solicitud ID: 2','192.168.100.9','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-15 10:30:16'),
(630,2,'payment_created','Pago registrado','Solicitud ID: 2 - Método: efectivo - Pago ID: 2','192.168.100.6','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-15 10:30:23'),
(631,6,'payment_confirmed','Pago confirmado','Solicitud ID: 2 - Pago ID: 2','192.168.100.9','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-15 10:30:32'),
(632,6,'request_completed','Servicio finalizado','Solicitud ID: 2','192.168.100.9','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-15 10:30:50'),
(633,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-15 14:14:57'),
(634,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.43.2','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-15 14:25:00'),
(635,2,'request_created','Solicitud creada','ID: 1 - Servicio: 10 - Proveedor: 6','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-15 14:25:22'),
(636,6,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.43.2','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-15 14:25:27'),
(637,2,'payment_created','Pago registrado','Solicitud ID: 1 - Método: efectivo - Pago ID: 1','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-15 14:25:48'),
(638,6,'payment_confirmed','Pago confirmado','Solicitud ID: 1 - Pago ID: 1','192.168.43.2','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-15 14:26:17'),
(639,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64; rv:152.0) Gecko/20100101 Firefox/152.0','2026-07-15 14:37:29'),
(640,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.1.26','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-15 15:59:20'),
(641,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.1.26','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-15 16:27:58'),
(642,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.1.26','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-15 19:10:14'),
(643,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-16 00:24:34'),
(644,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-16 09:48:46'),
(645,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.43.1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.101 Safari/537.36','2026-07-16 09:57:03'),
(646,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.101 Safari/537.36','2026-07-17 16:57:06'),
(647,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.101 Safari/537.36','2026-07-17 16:57:09'),
(648,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.101 Safari/537.36','2026-07-17 17:04:22'),
(649,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.101 Safari/537.36','2026-07-17 17:07:29'),
(650,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.101 Safari/537.36','2026-07-17 17:11:03'),
(651,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/149.0.7827.164 Mobile Safari/537.36','2026-07-17 17:22:04'),
(652,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (Linux; Android 10; Redmi 8) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.101 Mobile Safari/537.36','2026-07-17 17:23:26'),
(653,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-17 17:26:42'),
(654,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-17 17:27:01'),
(655,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.31.53','curl/8.17.0','2026-07-18 05:27:36'),
(656,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.53','curl/8.17.0','2026-07-18 05:33:46'),
(657,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-18 13:09:34'),
(658,2,'request_created','Solicitud creada','ID: 1 - Servicio: 10 - Proveedor: 6','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-18 13:09:54'),
(659,6,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-18 13:09:57'),
(660,2,'payment_created','Pago registrado','Solicitud ID: 1 - Método: efectivo - Pago ID: 1','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-18 13:10:05'),
(661,6,'payment_confirmed','Pago confirmado','Solicitud ID: 1 - Pago ID: 1','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-18 13:14:18'),
(662,6,'request_completed','Servicio finalizado','Solicitud ID: 1','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-18 13:16:54'),
(663,2,'request_created','Solicitud creada','ID: 2 - Servicio: 10 - Proveedor: 6','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-18 13:23:47'),
(664,6,'request_accepted','Solicitud aceptada','Solicitud ID: 2','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-18 13:23:49'),
(665,2,'payment_created','Pago registrado','Solicitud ID: 2 - Método: efectivo - Pago ID: 2','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-18 13:23:54'),
(666,6,'payment_confirmed','Pago confirmado','Solicitud ID: 2 - Pago ID: 2','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-18 13:24:36'),
(667,6,'request_completed','Servicio finalizado','Solicitud ID: 2','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-18 13:25:02'),
(668,2,'request_created','Solicitud creada','ID: 1 - Servicio: 10 - Proveedor: 6','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-18 13:52:31'),
(669,6,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-18 13:53:18'),
(670,2,'payment_created','Pago registrado','Solicitud ID: 1 - Método: efectivo - Pago ID: 1','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-18 13:53:28'),
(671,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-18 13:56:21'),
(672,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-18 13:56:24'),
(673,6,'payment_confirmed','Pago confirmado','Solicitud ID: 1 - Pago ID: 1','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-18 13:57:04'),
(674,2,'request_created','Solicitud creada','ID: 1 - Servicio: 10 - Proveedor: 6','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-18 13:59:10'),
(675,2,'request_created','Solicitud creada','ID: 1 - Servicio: 10 - Proveedor: 6','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-18 15:14:17'),
(676,2,'request_created','Solicitud creada','ID: 1 - Servicio: 10 - Proveedor: 6','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-18 16:09:39'),
(677,6,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-18 16:09:46'),
(678,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-18 17:40:10'),
(679,2,'payment_created','Pago registrado','Solicitud ID: 1 - Método: efectivo - Pago ID: 1','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-18 17:42:50'),
(680,6,'payment_confirmed','Pago confirmado','Solicitud ID: 1 - Pago ID: 1','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-18 17:42:54'),
(681,6,'request_completed','Servicio finalizado','Solicitud ID: 1','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-18 17:43:00'),
(682,2,'request_created','Solicitud creada','ID: 2 - Servicio: 10 - Proveedor: 6','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-18 17:44:59'),
(683,6,'request_cancelled','Solicitud cancelada','Solicitud ID: 2 - Por: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-18 17:45:57'),
(684,2,'request_created','Solicitud creada','ID: 3 - Servicio: 10 - Proveedor: 6','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-18 17:46:51'),
(685,6,'request_accepted','Solicitud aceptada','Solicitud ID: 3','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-18 17:47:44'),
(686,2,'payment_created','Pago registrado','Solicitud ID: 3 - Método: efectivo - Pago ID: 2','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-18 17:47:50'),
(687,2,'request_created','Solicitud creada','ID: 1 - Servicio: 10 - Proveedor: 6','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-18 17:49:54'),
(688,2,'request_created','Solicitud creada','ID: 1 - Servicio: 10 - Proveedor: 6','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-18 17:51:00'),
(689,2,'request_created','Solicitud creada','ID: 1 - Servicio: 10 - Proveedor: 6','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-18 23:26:29'),
(690,2,'request_created','Solicitud creada','ID: 1 - Servicio: 10 - Proveedor: 6','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-18 23:33:35'),
(691,2,'request_created','Solicitud creada','ID: 1 - Servicio: 10 - Proveedor: 6','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-19 00:11:43'),
(692,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-19 00:12:30'),
(693,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-19 00:13:20'),
(694,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-19 00:13:40'),
(695,2,'request_created','Solicitud creada','ID: 1 - Servicio: 10 - Proveedor: 6','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-19 00:14:11'),
(696,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-19 00:15:04'),
(697,2,'request_created','Solicitud creada','ID: 1 - Servicio: 10 - Proveedor: 6','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-19 00:15:40'),
(698,2,'request_created','Solicitud creada','ID: 1 - Servicio: 10 - Proveedor: 6','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-19 00:19:56'),
(699,2,'request_created','Solicitud creada','ID: 1 - Servicio: 10 - Proveedor: 6','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-19 00:48:59'),
(700,2,'request_created','Solicitud creada','ID: 1 - Servicio: 10 - Proveedor: 6','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-19 00:52:43'),
(701,2,'request_created','Solicitud creada','ID: 1 - Servicio: 11 - Proveedor: 6','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-19 00:54:03'),
(702,2,'request_created','Solicitud creada','ID: 1 - Servicio: 11 - Proveedor: 6','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-19 09:32:07'),
(703,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.177.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.48 Mobile Safari/537.36','2026-07-19 22:06:13'),
(704,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.177.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.48 Mobile Safari/537.36','2026-07-19 22:16:05'),
(705,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.177.174','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36','2026-07-19 22:23:23'),
(706,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.100.6','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.48 Mobile Safari/537.36','2026-07-20 00:13:08'),
(707,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.100.6','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36','2026-07-20 11:23:27'),
(708,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.177.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-20 23:56:04'),
(709,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.177.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-21 10:55:17'),
(710,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.177.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-21 10:56:09'),
(711,6,'request_cancelled','Solicitud cancelada','Solicitud ID: 1 - Por: provider','192.168.177.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-21 10:56:46'),
(712,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.177.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-21 11:03:24'),
(713,2,'staff_logout','Staff cerró sesión',NULL,'192.168.177.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-21 12:20:50'),
(714,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.177.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-21 12:21:44'),
(715,2,'request_created','Solicitud creada','ID: 1 - Servicio: 12 - Proveedor: 6','192.168.177.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-21 12:31:34'),
(716,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.177.174','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-21 12:34:45'),
(717,2,'request_created','Solicitud creada','ID: 1 - Servicio: 10 - Proveedor: 6','192.168.177.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-21 12:35:06'),
(718,2,'request_created','Solicitud creada','ID: 1 - Servicio: 11 - Proveedor: 6','192.168.177.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-21 12:36:51'),
(719,2,'request_created','Solicitud creada','ID: 1 - Servicio: 10 - Proveedor: 6','192.168.177.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-21 12:38:25'),
(720,2,'request_created','Solicitud creada','ID: 1 - Servicio: 12 - Proveedor: 6','192.168.177.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-21 12:42:30'),
(721,2,'request_created','Solicitud creada','ID: 1 - Servicio: 10 - Proveedor: 6','192.168.177.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-21 12:43:26'),
(722,2,'request_created','Solicitud creada','ID: 1 - Servicio: 10 - Proveedor: 6','192.168.177.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-21 13:01:39'),
(723,2,'request_created','Solicitud creada','ID: 1 - Servicio: 10 - Proveedor: 6','192.168.177.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-21 21:32:38'),
(724,6,'request_cancelled','Solicitud cancelada','Solicitud ID: 1 - Por: provider','192.168.177.174','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-21 21:32:55'),
(725,2,'request_cancelled','Solicitud cancelada','Solicitud ID: 1 - Por: user','192.168.177.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-21 21:34:10'),
(726,2,'request_created','Solicitud creada','ID: 2 - Servicio: 10 - Proveedor: 6','192.168.177.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-21 21:34:45'),
(727,6,'request_rejected','Solicitud rechazada','Solicitud ID: 2','192.168.177.174','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-21 21:34:58'),
(728,2,'request_created','Solicitud creada','ID: 3 - Servicio: 10 - Proveedor: 6','192.168.177.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-21 21:35:10'),
(729,2,'request_created','Solicitud creada','ID: 1 - Servicio: 10 - Proveedor: 6','192.168.177.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-21 22:04:07'),
(730,6,'request_rejected','Solicitud rechazada','Solicitud ID: 1','192.168.177.174','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-21 22:04:15'),
(731,2,'request_created','Solicitud creada','ID: 2 - Servicio: 10 - Proveedor: 6','192.168.177.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-21 22:04:23'),
(732,6,'request_accepted','Solicitud aceptada','Solicitud ID: 2','192.168.177.174','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-21 22:04:34'),
(733,2,'payment_created','Pago registrado','Solicitud ID: 2 - Método: efectivo - Pago ID: 1','192.168.177.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-21 22:04:40'),
(734,6,'payment_confirmed','Pago confirmado','Solicitud ID: 2 - Pago ID: 1','192.168.177.174','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-21 22:05:12'),
(735,6,'request_completed','Servicio finalizado','Solicitud ID: 2','192.168.177.174','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-21 22:06:56'),
(736,2,'profile_updated','Perfil actualizado','Nombre: Jesús Díaz Villegas','192.168.177.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-22 13:17:18'),
(737,2,'profile_updated','Perfil actualizado','Nombre: Jesús Díaz Villegas','192.168.177.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-22 13:17:23'),
(738,2,'profile_updated','Perfil actualizado','Nombre: Jesús Díaz Villegas','192.168.177.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-22 13:17:28'),
(739,2,'profile_updated','Perfil actualizado','Nombre: Jesús Díaz Villegas','192.168.177.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-22 13:24:49'),
(740,2,'profile_updated','Perfil actualizado','Nombre: Jesús Díaz Villegas','192.168.177.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-22 13:25:31'),
(741,2,'profile_updated','Perfil actualizado','Nombre: Jesús Díaz Villegas','192.168.177.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-22 13:26:18'),
(742,2,'profile_updated','Perfil actualizado','Nombre: Jesús Díaz Villegas','192.168.177.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-22 13:34:49'),
(743,2,'profile_updated','Perfil actualizado','Nombre: Jesús Díaz Villegas','192.168.177.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-22 13:34:54'),
(744,2,'profile_updated','Perfil actualizado','Nombre: Jesús Díaz Villegas','192.168.177.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-22 13:35:46'),
(745,2,'profile_updated','Perfil actualizado','Nombre: Jesús Díaz Villegas','192.168.177.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-22 13:35:51'),
(746,2,'profile_updated','Perfil actualizado','Nombre: Jesús Díaz Villegas','192.168.177.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-22 13:47:53'),
(747,2,'profile_updated','Perfil actualizado','Nombre: Jesús Díaz Villegas','192.168.177.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-22 13:48:35'),
(748,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.177.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-22 16:41:02'),
(749,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.177.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.126 Mobile Safari/537.36','2026-07-23 13:03:58'),
(750,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-26 12:46:02'),
(751,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.244.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.126 Mobile Safari/537.36','2026-07-26 13:08:48'),
(752,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-26 13:33:17'),
(753,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-26 13:59:16'),
(754,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-27 11:43:02'),
(755,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-27 15:55:38'),
(756,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-27 15:58:52'),
(757,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-27 15:59:42'),
(758,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-27 22:12:00'),
(759,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-27 22:13:21'),
(760,2,'request_created','Solicitud creada','ID: 3 - Servicio: 11 - Proveedor: 6','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-27 22:15:10'),
(761,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.244.239','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36','2026-07-27 22:16:44'),
(762,6,'request_accepted','Solicitud aceptada','Solicitud ID: 3','192.168.244.239','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-27 22:17:32'),
(763,6,'request_rejected','Solicitud rechazada','Solicitud ID: 3','192.168.244.239','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-27 22:17:33'),
(764,2,'request_cancelled','Solicitud cancelada','Solicitud ID: 3 - Por: user','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-27 22:17:37'),
(765,2,'request_created','Solicitud creada','ID: 4 - Servicio: 11 - Proveedor: 6','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-27 22:18:01'),
(766,6,'request_accepted','Solicitud aceptada','Solicitud ID: 4','192.168.244.239','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-27 22:18:10'),
(767,2,'payment_created','Pago registrado','Solicitud ID: 4 - Método: efectivo - Pago ID: 2','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-27 22:18:21'),
(768,6,'payment_confirmed','Pago confirmado','Solicitud ID: 4 - Pago ID: 2','192.168.244.239','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-27 22:19:12'),
(769,6,'request_completed','Servicio finalizado','Solicitud ID: 4','192.168.244.239','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-27 22:19:52'),
(770,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 02:30:00'),
(771,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 02:30:28'),
(772,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 02:33:23'),
(773,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 07:10:40'),
(774,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 08:12:23'),
(775,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 12:13:10'),
(776,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 13:29:29'),
(777,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 13:29:49'),
(778,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 13:31:57'),
(779,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 13:32:28'),
(780,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 13:59:18'),
(781,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 13:59:41'),
(782,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 14:09:17'),
(783,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 14:11:04'),
(784,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 14:11:31'),
(785,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 14:27:02'),
(786,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 14:40:32'),
(787,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 14:58:33'),
(788,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 15:08:14'),
(789,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 15:08:51'),
(790,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 15:21:52'),
(791,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 15:25:37'),
(792,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 15:26:04'),
(793,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 15:37:12'),
(794,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 15:38:03'),
(795,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 15:41:19'),
(796,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.63.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 19:03:25'),
(797,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.63.137','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 19:04:04'),
(798,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.63.137','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 20:49:34'),
(799,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.63.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 20:57:52'),
(800,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.63.137','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 21:03:34'),
(801,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.63.137','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 21:04:15'),
(802,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.63.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 21:04:41'),
(803,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.63.137','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 21:08:15'),
(804,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.63.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 21:08:37'),
(805,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.63.137','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 21:09:43'),
(806,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.63.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 21:10:30'),
(807,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.63.137','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 21:11:05'),
(808,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.63.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 21:11:27'),
(809,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.63.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 23:49:46'),
(810,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.63.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 23:50:08'),
(811,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.63.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 23:50:39'),
(812,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.63.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-29 00:06:45'),
(813,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.63.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-29 00:47:13'),
(814,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.63.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-29 00:47:42'),
(815,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.63.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-29 00:52:44'),
(816,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.63.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-29 00:57:50'),
(817,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.63.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-29 03:09:09'),
(818,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-29 23:08:40'),
(819,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-29 23:45:30'),
(820,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-30 02:32:10'),
(821,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-30 10:57:05'),
(822,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-30 11:43:50'),
(823,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-30 18:10:52'),
(824,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-30 20:47:23'),
(825,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-30 22:48:33'),
(826,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-31 01:06:19'),
(827,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-31 01:24:07'),
(828,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-31 01:57:39'),
(829,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-31 05:09:47'),
(830,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-31 06:08:46'),
(831,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-31 13:16:56'),
(832,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-31 13:17:22'),
(833,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-31 13:18:29'),
(834,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-31 13:18:57'),
(835,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-31 13:19:31'),
(836,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-07-31 13:20:35'),
(837,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-07-31 13:21:29'),
(838,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-07-31 13:49:55'),
(839,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-31 13:52:19'),
(840,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-31 13:52:37'),
(841,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-07-31 14:03:42'),
(842,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.169','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36','2026-07-31 14:06:33'),
(843,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-07-31 14:08:24'),
(844,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-31 14:08:59'),
(845,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-31 14:12:53'),
(846,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-31 14:14:18'),
(847,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','curl/8.17.0','2026-07-31 14:20:13'),
(848,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','curl/8.17.0','2026-07-31 14:20:24'),
(849,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-31 15:34:35'),
(850,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-31 15:34:58'),
(851,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-31 15:35:33'),
(852,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-31 15:48:34'),
(853,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-31 15:48:53'),
(854,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-31 16:02:04'),
(855,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-31 19:05:51'),
(856,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-31 19:06:23'),
(857,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-31 19:07:09'),
(858,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-31 19:07:51'),
(859,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-31 19:08:25'),
(860,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 11:53:07'),
(861,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 11:53:38'),
(862,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 11:54:28'),
(863,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 11:54:58'),
(864,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 11:57:15'),
(865,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 11:57:40'),
(866,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 12:36:42'),
(867,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 12:36:58'),
(868,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 12:37:20'),
(869,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 12:37:37'),
(870,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 12:38:20'),
(871,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 12:38:42'),
(872,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 12:38:57'),
(873,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 12:39:17'),
(874,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 12:39:40'),
(875,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 12:40:01'),
(876,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 12:40:17'),
(877,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 12:40:42'),
(878,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 12:41:48'),
(879,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 12:42:09'),
(880,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 12:43:06'),
(881,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 12:43:41'),
(882,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 12:44:28'),
(883,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 12:44:59'),
(884,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 12:45:21'),
(885,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 12:45:59'),
(886,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 12:46:33'),
(887,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 12:46:49'),
(888,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 12:47:14'),
(889,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 12:48:02'),
(890,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 12:48:35'),
(891,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-08-01 12:49:48'),
(892,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 12:51:22'),
(893,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-08-01 12:52:21'),
(894,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 13:12:40'),
(895,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 13:13:00'),
(896,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 13:14:19'),
(897,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 13:14:44'),
(898,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 13:30:37'),
(899,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 13:31:03'),
(900,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','curl/8.17.0','2026-08-01 13:51:12'),
(901,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 14:08:21'),
(902,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 14:08:45'),
(903,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 14:09:07'),
(904,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 14:09:30'),
(905,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 14:09:52'),
(906,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 14:23:32'),
(907,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 14:24:05'),
(908,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 14:24:35'),
(909,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 14:25:10'),
(910,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 14:26:01'),
(911,12,'register','Nuevo registro','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 17:34:05'),
(912,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 17:41:03'),
(913,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 17:50:07'),
(914,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 17:51:22'),
(915,12,'service_created','Servicio creado','ID: 35 - Título: Don perrito 🐕 - Precio: $10','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 18:02:53'),
(916,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 20:05:43'),
(917,12,'service_created','Servicio creado','ID: 36 - Título: Don 🐕🐕 - Precio: $5','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 20:08:21'),
(918,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 21:31:39'),
(919,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 21:35:39'),
(920,12,'service_deleted','Servicio eliminado','ID: 36 - Título: Don 🐕🐕','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 21:36:01'),
(921,12,'service_deleted','Servicio eliminado','ID: 35 - Título: Don perrito 🐕','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 21:36:06'),
(922,12,'service_created','Servicio creado','ID: 37 - Título: Don perrito 🐕 - Precio: $10','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 21:38:09'),
(923,12,'service_created','Servicio creado','ID: 38 - Título: Test imagen - Precio: $10','192.168.25.12','curl/8.17.0','2026-08-01 21:51:21'),
(924,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.25.12','curl/8.17.0','2026-08-01 21:55:27'),
(925,12,'service_created','Servicio creado','ID: 39 - Título: Test con imagen real - Precio: $10','192.168.25.12','curl/8.17.0','2026-08-01 21:55:56'),
(926,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-08-01 22:01:49'),
(927,12,'service_deleted','Servicio eliminado','ID: 39 - Título: Test con imagen real','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-08-01 22:02:18'),
(928,12,'service_deleted','Servicio eliminado','ID: 38 - Título: Test imagen','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-08-01 22:02:23'),
(929,12,'service_deleted','Servicio eliminado','ID: 37 - Título: Don perrito 🐕','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-08-01 22:02:32'),
(930,12,'service_created','Servicio creado','ID: 40 - Título: Prueba - Precio: $10','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-08-01 22:04:00'),
(931,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-08-01 22:51:15'),
(932,12,'service_deleted','Servicio eliminado','ID: 40 - Título: Prueba','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-08-01 22:51:42'),
(933,12,'service_created','Servicio creado','ID: 41 - Título: Todo don perro - Precio: $10','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-08-01 22:56:19'),
(934,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 22:57:54'),
(935,12,'service_deleted','Servicio eliminado','ID: 41 - Título: Todo don perro','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 22:59:02'),
(936,12,'service_created','Servicio creado','ID: 42 - Título: Don 🐶 - Precio: $10','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 23:02:25'),
(937,12,'service_deleted','Servicio eliminado','ID: 42 - Título: Don 🐶','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 23:04:40'),
(938,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 23:07:09'),
(939,12,'service_created','Servicio creado','ID: 43 - Título: Hola - Precio: $50','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 23:08:12'),
(940,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 23:09:57'),
(941,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-01 23:47:50'),
(942,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.25.169','Mozilla/5.0 (Android 13; Mobile; rv:153.0) Gecko/153.0 Firefox/153.0','2026-08-02 00:08:57'),
(943,12,'profile_updated','Perfil actualizado','Nombre: Carlos Bravo','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64; rv:153.0) Gecko/20100101 Firefox/153.0','2026-08-02 00:17:19'),
(944,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64; rv:153.0) Gecko/20100101 Firefox/153.0','2026-08-02 00:20:02'),
(945,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-02 00:23:37'),
(946,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.25.12','curl/8.17.0','2026-08-02 00:30:05'),
(947,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-02 01:20:03'),
(948,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-02 01:44:09'),
(949,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.25.12','curl/8.17.0','2026-08-02 01:51:42'),
(950,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-02 02:05:25'),
(951,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-02 02:29:46'),
(952,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.25.12','curl/8.17.0','2026-08-02 02:31:43'),
(953,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.25.12','curl/8.17.0','2026-08-02 02:35:10'),
(954,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-02 02:37:17'),
(955,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-02 03:01:05'),
(956,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64; rv:153.0) Gecko/20100101 Firefox/153.0','2026-08-02 03:54:24'),
(957,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.25.169','Mozilla/5.0 (Android 13; Mobile; rv:153.0) Gecko/153.0 Firefox/153.0','2026-08-02 07:14:38'),
(958,12,'service_deleted','Servicio eliminado','ID: 43 - Título: Hola','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-02 11:47:01'),
(959,12,'service_created','Servicio creado','ID: 44 - Título: Reparo yo - Precio: $15','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-02 11:52:53'),
(962,1,'featured','featured_activated','Servicio ID: 44. Destacado por 7 días. Expira: 2026-08-09 13:08:46. Pago ID: 27',NULL,NULL,'2026-08-02 13:08:46'),
(963,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-02 13:41:55'),
(964,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64; rv:153.0) Gecko/20100101 Firefox/153.0','2026-08-02 14:16:25'),
(965,6,'service_created','Servicio creado','ID: 45 - Título: cuenta bloqueada - Precio: $30','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64; rv:153.0) Gecko/20100101 Firefox/153.0','2026-08-02 14:21:24'),
(966,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-02 15:54:29'),
(967,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64; rv:153.0) Gecko/20100101 Firefox/153.0','2026-08-02 15:56:23'),
(968,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64; rv:153.0) Gecko/20100101 Firefox/153.0','2026-08-02 18:35:24'),
(969,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-03 11:12:28'),
(970,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-03 11:12:48'),
(971,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-03 11:13:28'),
(972,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-03 11:17:11'),
(973,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64; rv:153.0) Gecko/20100101 Firefox/153.0','2026-08-03 11:49:38'),
(974,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-08-03 12:06:50'),
(975,2,'request_created','Solicitud creada','ID: 5 - Servicio: 44 - Proveedor: 12','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-08-03 12:09:01'),
(976,12,'request_rejected','Solicitud rechazada','Solicitud ID: 5','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64; rv:153.0) Gecko/20100101 Firefox/153.0','2026-08-03 12:09:13'),
(977,2,'request_cancelled','Solicitud cancelada','Solicitud ID: 5 - Por: user','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-08-03 12:09:20'),
(978,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-08-03 12:09:41'),
(979,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-08-03 12:29:00'),
(980,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-03 12:30:37'),
(981,8,'login','Inicio de sesión','Usuario: Pedro Perez (pedro@gmail.com) - Rol: provider','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-03 12:32:11'),
(982,8,'login','Inicio de sesión','Usuario: Pedro Perez (pedro@gmail.com) - Rol: provider','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-03 12:35:11'),
(983,8,'login','Inicio de sesión','Usuario: Pedro Perez (pedro@gmail.com) - Rol: provider','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-03 12:36:44'),
(984,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-08 11:23:30'),
(985,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.241.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-08-08 11:28:33'),
(986,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-08 11:35:53'),
(987,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-08 11:37:55'),
(988,6,'request_created','Solicitud creada','ID: 6 - Servicio: 44 - Proveedor: 12','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-08 11:51:34'),
(989,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64; rv:153.0) Gecko/20100101 Firefox/153.0','2026-08-08 11:53:58'),
(990,12,'request_accepted','Solicitud aceptada','Solicitud ID: 6','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64; rv:153.0) Gecko/20100101 Firefox/153.0','2026-08-08 11:54:19'),
(991,6,'request_created','Solicitud creada','ID: 1 - Servicio: 44 - Proveedor: 12','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-08 12:01:13'),
(992,12,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64; rv:153.0) Gecko/20100101 Firefox/153.0','2026-08-08 12:01:25'),
(993,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.241.63','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-08 12:06:41'),
(994,6,'request_created','Solicitud creada','ID: 1 - Servicio: 44 - Proveedor: 12','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-08 12:13:06'),
(995,6,'request_created','Solicitud creada','ID: 1 - Servicio: 44 - Proveedor: 12','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-08 12:20:07'),
(996,12,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.241.63','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-08 12:20:12'),
(997,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-08 17:37:28'),
(998,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-08 17:37:51'),
(999,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-08 17:39:48'),
(1000,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-08 17:40:21'),
(1001,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.241.63','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-08 17:41:12'),
(1002,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-08 17:44:27'),
(1003,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.241.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-08-08 17:45:28'),
(1004,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-08 17:46:05'),
(1005,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-08 17:46:24'),
(1006,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.241.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-08-08 17:46:42'),
(1007,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.241.63','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-08 17:47:30'),
(1008,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.241.63','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-08 17:47:38'),
(1009,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.241.63','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-08 17:48:06'),
(1010,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.241.63','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-08 17:48:34'),
(1011,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-08 17:49:04'),
(1012,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-08 17:49:22'),
(1013,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-08 18:07:28'),
(1014,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-08 18:07:45'),
(1015,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-08 18:30:43'),
(1016,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-08 18:32:00'),
(1017,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-09 15:12:27'),
(1018,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-09 15:13:24'),
(1019,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-09 15:25:43'),
(1020,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-09 15:26:12'),
(1021,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-09 15:29:05'),
(1022,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-09 15:30:03'),
(1023,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-09 15:30:46'),
(1024,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-09 15:31:24'),
(1025,6,'request_created','Solicitud creada','ID: 1 - Servicio: 44 - Proveedor: 12','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-09 15:47:27'),
(1026,12,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-09 15:47:31'),
(1027,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-09 17:42:44'),
(1028,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-09 17:46:29'),
(1029,6,'request_created','Solicitud creada','ID: 1 - Servicio: 44 - Proveedor: 12','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-09 17:47:46'),
(1030,12,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-09 17:47:51'),
(1031,12,'request_created','Solicitud creada','ID: 1 - Servicio: 44 - Proveedor: 12','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-09 18:41:25'),
(1032,6,'request_created','Solicitud creada','ID: 1 - Servicio: 44 - Proveedor: 12','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-09 18:43:26'),
(1033,12,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-09 18:43:29'),
(1034,6,'request_created','Solicitud creada','ID: 1 - Servicio: 44 - Proveedor: 12','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-09 20:19:44'),
(1035,12,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-09 20:19:47'),
(1036,6,'payment_created','Pago registrado','Solicitud ID: 1 - Método: efectivo - Pago ID: 1','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-09 20:19:54'),
(1037,12,'payment_confirmed','Pago confirmado','Solicitud ID: 1 - Pago ID: 1','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-10 11:05:36'),
(1038,12,'request_completed','Servicio finalizado','Solicitud ID: 1','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-10 11:05:45'),
(1039,6,'request_created','Solicitud creada','ID: 1 - Servicio: 44 - Proveedor: 12','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-11 04:29:43'),
(1040,12,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-11 04:29:46'),
(1041,6,'payment_created','Pago registrado','Solicitud ID: 1 - Método: efectivo - Pago ID: 1','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-11 04:29:54'),
(1042,6,'request_created','Solicitud creada','ID: 1 - Servicio: 44 - Proveedor: 12','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-11 04:31:56'),
(1043,12,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-11 04:32:01'),
(1044,6,'payment_created','Pago registrado','Solicitud ID: 1 - Método: efectivo - Pago ID: 1','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-11 04:32:11'),
(1045,12,'payment_confirmed','Pago confirmado','Solicitud ID: 1 - Pago ID: 1','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-11 04:32:53'),
(1046,12,'request_completed','Servicio finalizado','Solicitud ID: 1','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-11 04:33:40'),
(1047,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.169.92','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-11 13:31:15'),
(1048,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.169.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-11 13:31:46'),
(1049,6,'request_created','Solicitud creada','ID: 1 - Servicio: 44 - Proveedor: 12','192.168.169.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-11 13:32:28'),
(1050,12,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.169.92','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-11 13:32:40'),
(1051,6,'payment_created','Pago registrado','Solicitud ID: 1 - Método: efectivo - Pago ID: 1','192.168.169.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-11 13:32:46'),
(1052,12,'payment_confirmed','Pago confirmado','Solicitud ID: 1 - Pago ID: 1','192.168.169.92','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-11 13:33:35'),
(1053,12,'request_completed','Servicio finalizado','Solicitud ID: 1','192.168.169.92','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-11 13:33:50'),
(1054,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.169.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-11 13:45:05'),
(1055,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.169.92','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-11 13:45:48'),
(1056,6,'request_created','Solicitud creada','ID: 2 - Servicio: 44 - Proveedor: 12','192.168.169.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-11 13:46:29'),
(1057,12,'request_accepted','Solicitud aceptada','Solicitud ID: 2','192.168.169.92','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-11 13:46:32'),
(1058,6,'payment_created','Pago registrado','Solicitud ID: 2 - Método: efectivo - Pago ID: 2','192.168.169.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-11 13:46:40'),
(1059,12,'payment_confirmed','Pago confirmado','Solicitud ID: 2 - Pago ID: 2','192.168.169.92','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-11 13:46:52'),
(1060,12,'request_completed','Servicio finalizado','Solicitud ID: 2','192.168.169.92','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-11 13:47:38'),
(1061,6,'request_created','Solicitud creada','ID: 1 - Servicio: 44 - Proveedor: 12','192.168.169.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-11 13:56:45'),
(1062,12,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.169.92','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-11 13:56:57'),
(1063,6,'payment_created','Pago registrado','Solicitud ID: 1 - Método: efectivo - Pago ID: 1','192.168.169.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-11 13:57:02'),
(1064,12,'payment_confirmed','Pago confirmado','Solicitud ID: 1 - Pago ID: 1','192.168.169.92','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-11 13:57:18'),
(1065,12,'request_completed','Servicio finalizado','Solicitud ID: 1','192.168.169.92','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-11 13:57:57'),
(1066,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.169.92','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-11 14:22:29'),
(1067,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.169.92','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-11 14:52:34'),
(1068,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.169.92','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-11 14:53:01'),
(1069,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.169.92','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-11 16:19:09'),
(1070,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.169.92','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-11 16:20:02'),
(1071,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.169.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-11 16:21:17'),
(1072,6,'request_created','Solicitud creada','ID: 1 - Servicio: 44 - Proveedor: 12','192.168.169.92','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-11 16:21:39'),
(1073,12,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.169.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-11 16:22:35'),
(1074,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.93.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-12 15:14:12'),
(1075,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.93.149','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-12 16:59:18'),
(1076,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.105.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-14 10:29:48'),
(1077,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.105.122','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-14 11:06:43'),
(1078,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.105.122','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-14 11:08:28'),
(1079,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.105.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-14 13:18:48'),
(1080,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.105.122','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-14 13:19:11'),
(1081,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.105.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-16 01:40:27'),
(1082,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-16 19:59:02'),
(1083,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-16 20:21:52'),
(1084,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-16 20:22:44'),
(1085,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-16 20:23:49'),
(1086,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-16 20:24:59'),
(1087,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-16 20:40:19'),
(1088,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-16 20:40:28'),
(1089,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-16 20:40:37'),
(1090,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-16 20:40:57'),
(1091,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-16 21:13:10'),
(1092,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-16 22:07:44'),
(1093,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-16 22:16:11'),
(1094,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 00:01:53'),
(1095,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 00:04:55'),
(1096,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 00:06:37'),
(1097,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 00:07:06'),
(1098,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 00:08:24'),
(1099,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 00:08:59'),
(1100,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-08-17 00:15:52'),
(1101,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-08-17 00:38:03'),
(1102,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-08-17 01:22:48'),
(1103,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 01:25:14'),
(1104,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 01:29:59'),
(1105,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 01:32:00'),
(1106,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 01:32:07'),
(1107,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 01:33:08'),
(1108,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 02:42:29'),
(1109,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 02:43:27'),
(1110,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 02:45:05'),
(1111,6,'request_created','Solicitud creada','ID: 1 - Servicio: 44 - Proveedor: 12','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 02:57:05'),
(1112,12,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 02:57:08'),
(1113,6,'payment_created','Pago registrado','Solicitud ID: 1 - Método: efectivo - Pago ID: 1','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 02:57:11'),
(1114,12,'payment_confirmed','Pago confirmado','Solicitud ID: 1 - Pago ID: 1','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 02:58:40'),
(1115,12,'request_completed','Servicio finalizado','Solicitud ID: 1','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 02:59:34'),
(1116,6,'request_created','Solicitud creada','ID: 1 - Servicio: 44 - Proveedor: 12','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 04:25:26'),
(1117,12,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 04:25:29'),
(1118,12,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 04:25:32'),
(1119,12,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 04:25:36'),
(1120,12,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 04:25:40'),
(1121,12,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 04:25:43'),
(1122,12,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 04:25:51'),
(1123,12,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 04:25:51'),
(1124,12,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 04:25:52'),
(1125,12,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 04:25:54'),
(1126,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 04:27:59'),
(1127,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 04:29:42'),
(1128,6,'request_created','Solicitud creada','ID: 1 - Servicio: 44 - Proveedor: 12','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 04:31:04'),
(1129,12,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 04:31:08'),
(1130,6,'request_created','Solicitud creada','ID: 1 - Servicio: 44 - Proveedor: 12','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 04:32:59'),
(1131,12,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 04:33:05'),
(1132,6,'request_created','Solicitud creada','ID: 1 - Servicio: 44 - Proveedor: 12','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 04:43:02'),
(1133,12,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 04:43:24'),
(1134,6,'payment_created','Pago registrado','Solicitud ID: 1 - Método: efectivo - Pago ID: 1','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 04:43:45'),
(1135,12,'payment_confirmed','Pago confirmado','Solicitud ID: 1 - Pago ID: 1','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 04:44:12'),
(1136,12,'request_completed','Servicio finalizado','Solicitud ID: 1','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-17 04:44:24'),
(1137,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.53','curl/8.17.0','2026-08-17 05:13:55'),
(1138,6,'request_completed','Servicio finalizado','Solicitud ID: 1','192.168.31.53','curl/8.17.0','2026-08-17 05:14:55'),
(1139,6,'request_completed','Servicio finalizado','Solicitud ID: 1','192.168.31.53','curl/8.17.0','2026-08-17 05:18:00'),
(1140,6,'request_completed','Servicio finalizado','Solicitud ID: 1','192.168.31.53','curl/8.17.0','2026-08-17 05:28:10'),
(1141,6,'request_completed','Servicio finalizado','Solicitud ID: 1','192.168.31.53','curl/8.17.0','2026-08-17 05:31:08'),
(1142,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.205.12','curl/8.17.0','2026-08-17 20:49:15'),
(1143,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.205.12','curl/8.17.0','2026-08-17 20:50:15'),
(1144,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.205.12','curl/8.17.0','2026-08-17 20:51:53'),
(1145,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.31.53','curl/8.17.0','2026-08-18 00:53:56'),
(1146,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 01:42:12'),
(1147,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-08-18 01:44:32'),
(1148,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 04:39:48'),
(1149,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 04:40:43'),
(1150,2,'request_created','Solicitud creada','ID: 2 - Servicio: 44 - Proveedor: 12','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 04:41:19'),
(1151,2,'request_created','Solicitud creada','ID: 1 - Servicio: 44 - Proveedor: 12','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 04:43:28'),
(1152,12,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 04:43:33'),
(1153,2,'payment_created','Pago registrado','Solicitud ID: 1 - Método: efectivo - Pago ID: 1','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 04:43:38'),
(1154,12,'payment_confirmed','Pago confirmado','Solicitud ID: 1 - Pago ID: 1','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 04:43:55'),
(1155,2,'request_created','Solicitud creada','ID: 2 - Servicio: 44 - Proveedor: 12','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 04:50:58'),
(1156,12,'request_accepted','Solicitud aceptada','Solicitud ID: 2','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 04:51:03'),
(1157,2,'payment_created','Pago registrado','Solicitud ID: 2 - Método: efectivo - Pago ID: 2','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 04:51:07'),
(1158,12,'payment_confirmed','Pago confirmado','Solicitud ID: 2 - Pago ID: 2','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 04:51:17'),
(1159,12,'request_completed','Servicio finalizado','Solicitud ID: 2','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 04:51:30'),
(1160,2,'request_created','Solicitud creada','ID: 3 - Servicio: 44 - Proveedor: 12','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 04:55:12'),
(1161,12,'request_accepted','Solicitud aceptada','Solicitud ID: 3','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 04:55:14'),
(1162,2,'payment_created','Pago registrado','Solicitud ID: 3 - Método: efectivo - Pago ID: 3','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 04:55:21'),
(1163,12,'payment_confirmed','Pago confirmado','Solicitud ID: 3 - Pago ID: 3','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 04:55:36'),
(1164,12,'request_completed','Servicio finalizado','Solicitud ID: 3','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 04:55:45'),
(1165,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.205.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 13:53:19'),
(1166,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.205.6','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 13:54:35'),
(1167,6,'request_created','Solicitud creada','ID: 4 - Servicio: 44 - Proveedor: 12','192.168.205.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 13:55:03'),
(1168,12,'request_accepted','Solicitud aceptada','Solicitud ID: 4','192.168.205.6','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 13:55:33'),
(1169,6,'payment_created','Pago registrado','Solicitud ID: 4 - Método: efectivo - Pago ID: 4','192.168.205.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 13:55:41'),
(1170,12,'payment_confirmed','Pago confirmado','Solicitud ID: 4 - Pago ID: 4','192.168.205.6','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 13:56:24'),
(1171,12,'request_completed','Servicio finalizado','Solicitud ID: 4','192.168.205.6','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 13:57:47'),
(1172,6,'request_created','Solicitud creada','ID: 1 - Servicio: 44 - Proveedor: 12','192.168.205.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 14:15:47'),
(1173,12,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.205.6','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 14:15:51'),
(1174,6,'payment_created','Pago registrado','Solicitud ID: 1 - Método: efectivo - Pago ID: 1','192.168.205.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 14:15:59'),
(1175,12,'payment_confirmed','Pago confirmado','Solicitud ID: 1 - Pago ID: 1','192.168.205.6','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 14:16:39'),
(1176,12,'request_completed','Servicio finalizado','Solicitud ID: 1','192.168.205.6','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 14:17:44'),
(1177,6,'request_created','Solicitud creada','ID: 2 - Servicio: 44 - Proveedor: 12','192.168.205.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 15:28:35'),
(1178,12,'request_accepted','Solicitud aceptada','Solicitud ID: 2','192.168.205.6','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 15:28:40'),
(1179,6,'payment_created','Pago registrado','Solicitud ID: 2 - Método: efectivo - Pago ID: 2','192.168.205.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 15:28:51'),
(1180,12,'payment_confirmed','Pago confirmado','Solicitud ID: 2 - Pago ID: 2','192.168.205.6','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 15:29:13'),
(1181,12,'request_completed','Servicio finalizado','Solicitud ID: 2','192.168.205.6','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 15:29:28'),
(1182,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.205.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 18:59:23'),
(1183,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.205.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 19:06:44'),
(1184,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.205.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-08-18 19:07:50'),
(1185,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.205.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 19:09:29'),
(1186,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.205.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-08-18 19:10:52'),
(1187,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.205.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-08-18 19:11:22'),
(1188,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.205.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-08-18 19:12:05'),
(1189,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.205.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-18 19:15:27'),
(1190,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.11.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-20 14:20:58'),
(1191,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.11.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-20 16:32:31'),
(1192,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.11.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-20 16:35:59'),
(1193,6,'login','Inicio de sesión','Usuario: María Villegas (maria@gmail.com) - Rol: provider','192.168.11.218','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-20 16:41:33'),
(1194,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.11.218','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-20 16:42:48'),
(1195,1,'request_created','Solicitud creada','ID: 1 - Servicio: 44 - Proveedor: 12','192.168.11.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-20 16:43:23'),
(1196,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.11.218','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-20 18:14:35'),
(1197,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.11.218','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-20 18:30:44'),
(1198,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.11.218','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-20 18:31:39'),
(1199,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.11.218','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-21 18:20:36'),
(1200,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.11.218','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-21 18:22:09'),
(1201,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.11.218','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-21 18:22:39'),
(1202,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.11.218','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-21 18:40:19'),
(1203,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.11.218','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-21 18:40:46'),
(1204,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.11.218','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-21 20:34:18'),
(1205,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.11.218','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-21 20:35:59'),
(1206,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.11.218','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-21 20:36:26'),
(1207,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.11.218','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-21 20:36:55'),
(1208,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.5.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-22 14:05:53'),
(1209,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.5.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-22 15:59:25'),
(1210,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.5.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-22 17:37:11'),
(1211,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.5.13','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-08-22 17:43:25'),
(1212,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.5.13','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-08-22 17:44:46'),
(1213,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-23 13:16:56'),
(1214,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-23 13:17:05'),
(1215,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-23 13:17:22'),
(1216,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-23 19:09:52'),
(1217,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-23 19:11:28'),
(1218,2,'request_created','Solicitud creada','ID: 2 - Servicio: 44 - Proveedor: 12','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-23 19:11:48'),
(1219,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-23 19:12:26'),
(1220,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-23 19:12:42'),
(1221,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-23 22:56:39'),
(1222,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-23 23:04:57'),
(1223,12,'request_busy','Proveedor ocupado','Solicitud ID: 1','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-23 23:05:10'),
(1224,12,'request_busy','Proveedor ocupado','Solicitud ID: 2','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-23 23:05:12'),
(1225,2,'request_created','Solicitud creada','ID: 3 - Servicio: 44 - Proveedor: 12','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-23 23:05:33'),
(1226,12,'request_accepted','Solicitud aceptada','Solicitud ID: 3','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-23 23:05:37'),
(1227,2,'payment_created','Pago registrado','Solicitud ID: 3 - Método: efectivo - Pago ID: 1','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-23 23:05:45'),
(1228,12,'payment_confirmed','Pago confirmado','Solicitud ID: 3 - Pago ID: 1','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-23 23:06:33'),
(1229,12,'request_completed','Servicio finalizado','Solicitud ID: 3','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-23 23:07:33'),
(1230,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-23 23:11:27'),
(1231,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-23 23:11:46'),
(1232,2,'request_created','Solicitud creada','ID: 1 - Servicio: 44 - Proveedor: 12','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-23 23:12:07'),
(1233,12,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-23 23:12:10'),
(1234,2,'request_created','Solicitud creada','ID: 1 - Servicio: 44 - Proveedor: 12','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-23 23:14:44'),
(1235,12,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-23 23:14:47'),
(1236,2,'payment_created','Pago registrado','Solicitud ID: 1 - Método: efectivo - Pago ID: 1','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-23 23:14:54'),
(1237,12,'payment_confirmed','Pago confirmado','Solicitud ID: 1 - Pago ID: 1','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-23 23:15:31'),
(1238,12,'request_completed','Servicio finalizado','Solicitud ID: 1','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-23 23:15:46'),
(1239,2,'request_created','Solicitud creada','ID: 2 - Servicio: 44 - Proveedor: 12','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-23 23:36:41'),
(1240,12,'request_accepted','Solicitud aceptada','Solicitud ID: 2','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-23 23:36:46'),
(1241,2,'payment_created','Pago registrado','Solicitud ID: 2 - Método: efectivo - Pago ID: 2','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-23 23:36:52'),
(1242,12,'payment_confirmed','Pago confirmado','Solicitud ID: 2 - Pago ID: 2','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-23 23:37:04'),
(1243,12,'request_completed','Servicio finalizado','Solicitud ID: 2','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-23 23:37:26'),
(1244,2,'request_created','Solicitud creada','ID: 3 - Servicio: 44 - Proveedor: 12','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 02:24:28'),
(1245,12,'request_accepted','Solicitud aceptada','Solicitud ID: 3','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 02:24:33'),
(1246,2,'payment_created','Pago registrado','Solicitud ID: 3 - Método: efectivo - Pago ID: 3','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 02:24:38'),
(1247,12,'payment_confirmed','Pago confirmado','Solicitud ID: 3 - Pago ID: 3','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 02:24:48'),
(1248,12,'request_completed','Servicio finalizado','Solicitud ID: 3','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 02:25:03'),
(1249,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 02:29:02'),
(1250,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 02:32:23'),
(1251,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 09:44:34'),
(1252,2,'request_created','Solicitud creada','ID: 4 - Servicio: 44 - Proveedor: 12','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 09:47:32'),
(1253,12,'request_accepted','Solicitud aceptada','Solicitud ID: 4','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 09:47:37'),
(1254,2,'payment_created','Pago registrado','Solicitud ID: 4 - Método: pago-movil - Pago ID: 4','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 09:52:15'),
(1255,12,'payment_confirmed','Pago confirmado','Solicitud ID: 4 - Pago ID: 4','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 11:20:42'),
(1256,12,'request_completed','Servicio finalizado','Solicitud ID: 4','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 11:46:40'),
(1257,2,'request_created','Solicitud creada','ID: 1 - Servicio: 44 - Proveedor: 12','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 11:51:53'),
(1258,12,'request_accepted','Solicitud aceptada','Solicitud ID: 1','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 11:51:55'),
(1259,2,'payment_created','Pago registrado','Solicitud ID: 1 - Método: efectivo - Pago ID: 1','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 11:52:04'),
(1260,12,'payment_confirmed','Pago confirmado','Solicitud ID: 1 - Pago ID: 1','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 11:52:24'),
(1261,12,'request_completed','Servicio finalizado','Solicitud ID: 1','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 12:02:51'),
(1262,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.5.13','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 13:26:16'),
(1263,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.5.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 13:27:40'),
(1264,2,'request_created','Solicitud creada','ID: 2 - Servicio: 44 - Proveedor: 12','192.168.5.13','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 13:28:28'),
(1265,12,'request_accepted','Solicitud aceptada','Solicitud ID: 2','192.168.5.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 13:28:33'),
(1266,2,'payment_created','Pago registrado','Solicitud ID: 2 - Método: efectivo - Pago ID: 2','192.168.5.13','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 13:28:38'),
(1267,12,'payment_confirmed','Pago confirmado','Solicitud ID: 2 - Pago ID: 2','192.168.5.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 13:28:58'),
(1268,12,'request_completed','Servicio finalizado','Solicitud ID: 2','192.168.5.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 13:29:53'),
(1269,2,'request_created','Solicitud creada','ID: 3 - Servicio: 44 - Proveedor: 12','192.168.5.13','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 13:30:30'),
(1270,12,'request_accepted','Solicitud aceptada','Solicitud ID: 3','192.168.5.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 13:30:35'),
(1271,2,'payment_created','Pago registrado','Solicitud ID: 3 - Método: efectivo - Pago ID: 3','192.168.5.13','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 13:30:39'),
(1272,12,'payment_confirmed','Pago confirmado','Solicitud ID: 3 - Pago ID: 3','192.168.5.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 13:30:49'),
(1273,12,'request_completed','Servicio finalizado','Solicitud ID: 3','192.168.5.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 13:31:05'),
(1274,2,'request_created','Solicitud creada','ID: 4 - Servicio: 44 - Proveedor: 12','192.168.5.13','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 13:35:28'),
(1275,12,'request_accepted','Solicitud aceptada','Solicitud ID: 4','192.168.5.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 13:35:31'),
(1276,2,'payment_created','Pago registrado','Solicitud ID: 4 - Método: efectivo - Pago ID: 4','192.168.5.13','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 13:35:36'),
(1277,12,'payment_confirmed','Pago confirmado','Solicitud ID: 4 - Pago ID: 4','192.168.5.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 13:35:44'),
(1278,12,'request_completed','Servicio finalizado','Solicitud ID: 4','192.168.5.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 13:35:57'),
(1279,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.5.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 15:45:06'),
(1280,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.5.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 15:45:30'),
(1281,12,'login','Inicio de sesión','Usuario: Carlos Bravo (bravo@gmail.com) - Rol: provider','192.168.5.13','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 15:45:58'),
(1282,2,'request_created','Solicitud creada','ID: 5 - Servicio: 44 - Proveedor: 12','192.168.5.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 15:46:15'),
(1283,12,'request_accepted','Solicitud aceptada','Solicitud ID: 5','192.168.5.13','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 15:46:19'),
(1284,2,'payment_created','Pago registrado','Solicitud ID: 5 - Método: efectivo - Pago ID: 5','192.168.5.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 18:07:30'),
(1285,12,'payment_confirmed','Pago confirmado','Solicitud ID: 5 - Pago ID: 5','192.168.5.13','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 18:07:50'),
(1286,12,'request_completed','Servicio finalizado','Solicitud ID: 5','192.168.5.13','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 18:07:56'),
(1287,2,'request_created','Solicitud creada','ID: 6 - Servicio: 44 - Proveedor: 12','192.168.5.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 18:27:26'),
(1288,12,'request_accepted','Solicitud aceptada','Solicitud ID: 6','192.168.5.13','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 18:27:31'),
(1289,2,'payment_created','Pago registrado','Solicitud ID: 6 - Método: efectivo - Pago ID: 6','192.168.5.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 18:27:35'),
(1290,12,'payment_rejected','Pago rechazado','Solicitud ID: 6 - Pago ID: 6','192.168.5.13','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 18:27:48'),
(1291,2,'payment_created','Pago registrado','Solicitud ID: 6 - Método: efectivo - Pago ID: 7','192.168.5.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 18:28:36'),
(1292,12,'payment_confirmed','Pago confirmado','Solicitud ID: 6 - Pago ID: 7','192.168.5.13','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 18:28:58'),
(1293,12,'request_completed','Servicio finalizado','Solicitud ID: 6','192.168.5.13','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 18:29:15'),
(1294,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.5.13','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-08-24 19:57:20'),
(1295,2,'request_created','Solicitud creada','ID: 7 - Servicio: 44 - Proveedor: 12','192.168.5.13','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-08-24 19:57:37'),
(1296,12,'request_accepted','Solicitud aceptada','Solicitud ID: 7','192.168.5.13','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 19:57:46'),
(1297,2,'payment_created','Pago registrado','Solicitud ID: 7 - Método: efectivo - Pago ID: 8','192.168.5.13','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-08-24 19:57:53'),
(1298,12,'payment_confirmed','Pago confirmado','Solicitud ID: 7 - Pago ID: 8','192.168.5.13','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 19:58:02'),
(1299,12,'request_completed','Servicio finalizado','Solicitud ID: 7','192.168.5.13','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 19:58:16'),
(1300,2,'request_created','Solicitud creada','ID: 8 - Servicio: 44 - Proveedor: 12','192.168.5.13','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-08-24 20:00:08'),
(1301,12,'request_accepted','Solicitud aceptada','Solicitud ID: 8','192.168.5.13','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 20:00:14'),
(1302,2,'payment_created','Pago registrado','Solicitud ID: 8 - Método: efectivo - Pago ID: 9','192.168.5.13','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-08-24 20:00:21'),
(1303,12,'payment_confirmed','Pago confirmado','Solicitud ID: 8 - Pago ID: 9','192.168.5.13','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 20:00:38'),
(1304,12,'request_completed','Servicio finalizado','Solicitud ID: 8','192.168.5.13','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 20:00:51'),
(1305,2,'request_created','Solicitud creada','ID: 9 - Servicio: 44 - Proveedor: 12','192.168.5.13','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-08-24 20:20:46'),
(1306,12,'request_accepted','Solicitud aceptada','Solicitud ID: 9','192.168.5.13','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 20:20:52'),
(1307,2,'payment_created','Pago registrado','Solicitud ID: 9 - Método: efectivo - Pago ID: 10','192.168.5.13','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36','2026-08-24 20:20:59'),
(1308,12,'payment_confirmed','Pago confirmado','Solicitud ID: 9 - Pago ID: 10','192.168.5.13','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 20:21:14'),
(1309,12,'request_completed','Servicio finalizado','Solicitud ID: 9','192.168.5.13','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 20:21:27'),
(1310,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.5.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','2026-08-24 20:34:36');
/*!40000 ALTER TABLE `audit_logs` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `blocked_ips`
--

LOCK TABLES `blocked_ips` WRITE;
/*!40000 ALTER TABLE `blocked_ips` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `blocked_ips` ENABLE KEYS */;
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
-- Dumping data for table `company_milestones`
--

LOCK TABLES `company_milestones` WRITE;
/*!40000 ALTER TABLE `company_milestones` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `company_milestones` (`id`, `year`, `title`, `description`, `icon`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES (1,'2026','Fundación de la empresa','Nacimos con la visión de revolucionar la conexión entre profesionales y clientes.','🚀',1,1,'2026-07-23 10:26:35','2026-07-23 10:26:35'),
(2,'2026','Primeros 100 clientes','Alcanzamos nuestros primeros 100 clientes satisfechos en tiempo récord.','👥',2,1,'2026-07-23 10:26:35','2026-07-23 10:26:35'),
(3,'2026','Expansión de servicios','Ampliamos nuestra oferta a más de 20 categorías de servicios profesionales.','📦',3,1,'2026-07-23 10:26:35','2026-07-23 10:26:35'),
(4,'2026','Innovación continua','Seguimos mejorando nuestra plataforma con tecnología de punta.','💡',4,1,'2026-07-23 10:26:35','2026-07-23 10:26:35');
/*!40000 ALTER TABLE `company_milestones` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `content_blocks`
--

LOCK TABLES `content_blocks` WRITE;
/*!40000 ALTER TABLE `content_blocks` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `content_blocks` (`id`, `name`, `identifier`, `type`, `content`, `settings`, `is_active`, `created_at`, `updated_at`) VALUES (1,'Banner Global Header','global-header-banner','banner','<div style=\"text-align:center;padding:20px;background:linear-gradient(135deg,#667eea,#764ba2);border-radius:12px;color:white;\">\n   <h2 style=\"margin:0 0 8px 0;font-size:1.5rem;\">🔥 Servicios destacados esta semana</h2>\n   <p style=\"margin:0;opacity:0.9;\">Contrata los mejores profesionales al mejor precio</p>\n </div>','{\"background\":\"#667eea\",\"text_color\":\"#ffffff\"}',1,'2026-07-27 15:47:31','2026-07-27 15:47:31'),
(2,'Footer Global','global-footer-block','text','<p style=\"text-align:center;color:#64748b;font-size:14px;\">📱 Disponible en iOS y Android • 💬 Soporte 24/7 • 🔒 Pagos seguros</p>','{}',1,'2026-07-27 15:47:31','2026-07-27 15:47:31'),
(3,'Dashboard Welcome','dashboard-welcome','banner','<div style=\"text-align:center;padding:24px;background:linear-gradient(135deg,#667eea,#764ba2);border-radius:16px;color:white;\">\n   <h2 style=\"margin:0 0 8px 0;font-size:1.6rem;\">👋 Bienvenido a TapClic</h2>\n   <p style=\"margin:0;opacity:0.9;font-size:1rem;\">Gestiona tus servicios, solicitudes y más desde aquí</p>\n </div>','{\"background\":\"#667eea\",\"text_color\":\"#ffffff\"}',1,'2026-07-27 15:47:31','2026-07-27 15:47:31'),
(4,'Login Side Logo','login-side-logo','banner','<h2>✨ TapClic</h2><p>Tu plataforma de servicios de confianza</p>','{}',1,'2026-07-27 15:47:31','2026-07-27 15:47:31'),
(5,'Login Side Promo','login-side-promo','banner','<h3>🌟 ¿Por qué elegirnos?</h3><p>✅ +1000 servicios disponibles<br>✅ Proveedores verificados<br>✅ Soporte 24/7<br>✅ Pago seguro</p>','{}',1,'2026-07-27 15:47:31','2026-07-27 15:47:31'),
(6,'Login Promo','login-promo','banner','<h3>🎉 ¡Oferta especial!</h3><p>Regístrate hoy y obtén 20% de descuento en tu primer servicio</p>','{}',1,'2026-07-27 15:47:31','2026-07-27 15:47:31'),
(7,'Register Promo','register-promo','banner','<h3>🚀 ¡Comienza hoy!</h3><p>Crear tu cuenta es gratis y toma menos de 2 minutos</p>','{}',1,'2026-07-27 15:47:31','2026-07-27 15:47:31'),
(8,'Register Side Promo','register-side-promo','banner','<h3>💡 ¿Sabías que...?</h3><p>Más del 95% de nuestros clientes recomiendan TapClic a sus amigos y familiares.</p>','{}',1,'2026-07-27 15:47:31','2026-07-27 15:47:31'),
(9,'Register Footer','register-footer','text','<p style=\"color:rgba(255,255,255,0.7);font-size:12px;\">Al registrarte aceptas nuestros términos y condiciones. Tus datos están protegidos.</p>','{}',1,'2026-07-27 15:47:31','2026-07-27 15:47:31'),
(10,'Page About Top','page-about-top','banner','<div style=\"text-align:center;padding:16px;background:#f8fafc;border-radius:8px;\">\n   <p style=\"color:#667eea;font-weight:600;\">🌟 Conoce más sobre nosotros</p>\n </div>','{}',1,'2026-07-27 15:47:31','2026-07-27 15:47:31'),
(11,'Page About Bottom','page-about-bottom','banner','<div style=\"text-align:center;padding:20px;background:linear-gradient(135deg,#667eea,#764ba2);border-radius:12px;color:white;\">\n   <h3>¿Listo para empezar?</h3>\n   <p>Únete a los miles de usuarios que ya confían en nosotros</p>\n </div>','{}',1,'2026-07-27 15:47:33','2026-07-27 15:47:33'),
(12,'Logo del Sistema','system-logo','image','/img/logo.png','{\"alt\":\"TapClic Logo\",\"width\":200}',1,'2026-07-27 15:50:32','2026-07-27 15:50:32');
/*!40000 ALTER TABLE `content_blocks` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `conversations`
--

LOCK TABLES `conversations` WRITE;
/*!40000 ALTER TABLE `conversations` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `conversations` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `conversations_backup`
--

LOCK TABLES `conversations_backup` WRITE;
/*!40000 ALTER TABLE `conversations_backup` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `conversations_backup` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `device_revocation_log`
--

LOCK TABLES `device_revocation_log` WRITE;
/*!40000 ALTER TABLE `device_revocation_log` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `device_revocation_log` (`id`, `user_id`, `device_id`, `device_name`, `revoked_at`, `revoked_by_ip`, `revoked_by_user_id`) VALUES (1,2,13,'💻 Linux - Chrome','2026-02-22 16:12:43','192.168.1.47',2),
(2,2,14,'💻 Linux - Chrome','2026-02-22 16:13:27','192.168.1.248',2),
(3,2,29,'📱 Xiaomi Redmi - Chrome','2026-04-27 09:51:17','192.168.0.100',2),
(4,2,57,'📱 Android - Chrome','2026-05-17 22:37:08','192.168.46.12',2),
(5,2,24,'💻 Linux - Chrome','2026-05-17 22:37:16','192.168.46.12',2),
(6,2,52,'💻 Linux - Chrome','2026-05-17 22:37:20','192.168.46.12',2),
(7,2,41,'📱 Android - Chrome','2026-05-17 22:37:26','192.168.46.12',2),
(8,2,42,'💻 Linux - Chrome','2026-05-17 22:37:32','192.168.46.12',2),
(9,2,46,'💻 Linux - Chrome','2026-05-17 22:37:37','192.168.46.12',2),
(10,2,35,'💻 Linux - Chrome','2026-05-17 22:37:41','192.168.46.12',2),
(11,2,48,'📱 Xiaomi Redmi - Chrome','2026-05-17 22:37:45','192.168.46.12',2),
(12,2,50,'💻 Linux - Chrome','2026-05-17 22:37:48','192.168.46.12',2);
/*!40000 ALTER TABLE `device_revocation_log` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `dispute_messages`
--

LOCK TABLES `dispute_messages` WRITE;
/*!40000 ALTER TABLE `dispute_messages` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `dispute_messages` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `disputes`
--

LOCK TABLES `disputes` WRITE;
/*!40000 ALTER TABLE `disputes` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `disputes` ENABLE KEYS */;
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
-- Dumping data for table `favorites`
--

LOCK TABLES `favorites` WRITE;
/*!40000 ALTER TABLE `favorites` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `favorites` (`id`, `user_id`, `service_id`, `created_at`) VALUES (24,6,34,'2026-07-16 09:31:32'),
(27,2,34,'2026-07-22 10:58:39'),
(28,2,33,'2026-07-22 10:58:40'),
(29,6,44,'2026-08-03 10:30:45');
/*!40000 ALTER TABLE `favorites` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `fcm_tokens`
--

LOCK TABLES `fcm_tokens` WRITE;
/*!40000 ALTER TABLE `fcm_tokens` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `fcm_tokens` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `jwt_tokens`
--

LOCK TABLES `jwt_tokens` WRITE;
/*!40000 ALTER TABLE `jwt_tokens` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `jwt_tokens` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `login_attempts`
--

LOCK TABLES `login_attempts` WRITE;
/*!40000 ALTER TABLE `login_attempts` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `login_attempts` (`id`, `user_id`, `email`, `identifier`, `ip_address`, `user_agent`, `success`, `created_at`) VALUES (1,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-26 12:46:02'),
(2,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.244.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.126 Mobile Safari/537.36',1,'2026-07-26 13:08:48'),
(3,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-26 13:33:17'),
(4,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-26 13:59:16'),
(5,1,'admin@example.com','admin@example.com','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-27 11:43:02'),
(6,1,'admin@example.com','admin@example.com','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-27 15:55:38'),
(7,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-27 15:58:52'),
(8,1,'admin@example.com','admin@example.com','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-27 15:59:42'),
(9,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-27 22:12:00'),
(10,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-27 22:13:21'),
(11,6,'maria@gmail.com','Maria@gmail.com','192.168.244.239','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36',1,'2026-07-27 22:16:44'),
(12,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 02:30:00'),
(13,1,'admin@example.com','admin@example.com','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 02:30:28'),
(14,1,'admin@example.com','admin@example.com','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 02:33:23'),
(15,1,'admin@example.com','admin@example.com','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 07:10:40'),
(16,1,'admin@example.com','admin@example.com','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 08:12:23'),
(17,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 12:13:09'),
(18,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 13:29:29'),
(19,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 13:29:49'),
(20,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 13:31:57'),
(21,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 13:32:28'),
(22,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 13:59:18'),
(23,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 13:59:41'),
(24,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 14:09:17'),
(25,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 14:11:04'),
(26,6,'maria@gmail.com','Maria@gmail.com','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 14:11:31'),
(27,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 14:27:02'),
(28,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 14:40:32'),
(29,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 14:58:33'),
(30,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 15:08:14'),
(31,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 15:08:51'),
(32,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 15:21:51'),
(33,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 15:25:37'),
(34,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 15:26:04'),
(35,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 15:37:12'),
(36,6,'maria@gmail.com','maria@gmail.com','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 15:38:03'),
(37,1,'admin@example.com','admin@example.com','192.168.244.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 15:41:19'),
(38,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.63.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 19:03:25'),
(39,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.63.137','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 19:04:04'),
(40,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.63.137','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 20:44:39'),
(41,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.63.137','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 20:44:53'),
(42,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.63.137','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 20:49:33'),
(43,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.63.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 20:57:52'),
(44,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.63.137','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 21:03:34'),
(45,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.63.137','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 21:04:15'),
(46,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.63.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 21:04:41'),
(47,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.63.137','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 21:08:15'),
(48,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.63.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 21:08:36'),
(49,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.63.137','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 21:09:43'),
(50,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.63.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 21:10:30'),
(51,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.63.137','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 21:11:05'),
(52,1,'admin@example.com','admin@example.com','192.168.63.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 21:11:26'),
(53,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.63.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 23:49:46'),
(54,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.63.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 23:50:08'),
(55,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.63.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-28 23:50:39'),
(56,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.63.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-29 00:06:45'),
(57,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.63.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-29 00:47:13'),
(58,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.63.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-29 00:47:42'),
(59,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.63.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-29 00:52:44'),
(60,1,'admin@example.com','admin@example.com','192.168.63.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-29 00:57:50'),
(61,1,'admin@example.com','admin@example.com','192.168.63.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-29 03:09:09'),
(62,1,'admin@example.com','admin@example.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-29 23:08:39'),
(63,1,'admin@example.com','admin@example.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-29 23:08:39'),
(64,1,'admin@example.com','admin@example.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-29 23:45:30'),
(65,1,'admin@example.com','admin@example.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-29 23:45:30'),
(66,1,'admin@example.com','admin@example.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-30 02:32:09'),
(67,1,'admin@example.com','admin@example.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-30 02:32:09'),
(68,1,'admin@example.com','admin@example.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-30 10:57:05'),
(69,1,'admin@example.com','admin@example.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-30 10:57:05'),
(70,1,'admin@example.com','admin@example.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-30 11:43:50'),
(71,1,'admin@example.com','admin@example.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-30 11:43:50'),
(72,1,'admin@example.com','admin@example.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-30 18:10:52'),
(73,1,'admin@example.com','admin@example.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-30 18:10:52'),
(74,1,'admin@example.com','admin@example.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-30 20:47:23'),
(75,1,'admin@example.com','admin@example.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-30 20:47:23'),
(76,1,'admin@example.com','admin@example.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-30 22:48:33'),
(77,1,'admin@example.com','admin@example.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-30 22:48:33'),
(78,1,'admin@example.com','admin@example.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 01:06:19'),
(79,1,'admin@example.com','admin@example.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 01:06:19'),
(80,1,'admin@example.com','admin@example.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 01:24:07'),
(81,1,'admin@example.com','admin@example.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 01:24:07'),
(82,1,'admin@example.com','admin@example.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 01:57:39'),
(83,1,'admin@example.com','admin@example.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 01:57:39'),
(84,1,'admin@example.com','admin@example.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 05:09:47'),
(85,1,'admin@example.com','admin@example.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 05:09:47'),
(86,1,'admin@example.com','admin@example.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 06:08:46'),
(87,1,'admin@example.com','admin@example.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 06:08:46'),
(88,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 13:16:56'),
(89,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 13:16:56'),
(90,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 13:17:21'),
(91,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 13:17:21'),
(92,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 13:18:29'),
(93,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 13:18:29'),
(94,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 13:18:57'),
(95,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 13:18:57'),
(96,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 13:19:30'),
(97,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 13:19:30'),
(98,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36',1,'2026-07-31 13:20:35'),
(99,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36',1,'2026-07-31 13:20:35'),
(100,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36',1,'2026-07-31 13:21:29'),
(101,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36',1,'2026-07-31 13:21:29'),
(102,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36',1,'2026-07-31 13:49:55'),
(103,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36',1,'2026-07-31 13:49:55'),
(104,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 13:52:19'),
(105,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 13:52:19'),
(106,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 13:52:37'),
(107,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 13:52:37'),
(108,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36',1,'2026-07-31 14:03:42'),
(109,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36',1,'2026-07-31 14:03:42'),
(110,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.169','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36',1,'2026-07-31 14:06:33'),
(111,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.169','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36',1,'2026-07-31 14:06:33'),
(112,1,'admin@example.com','admin@example.com','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36',1,'2026-07-31 14:08:24'),
(113,1,'admin@example.com','admin@example.com','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36',1,'2026-07-31 14:08:24'),
(114,1,'admin@example.com','admin@example.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 14:08:59'),
(115,1,'admin@example.com','admin@example.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 14:08:59'),
(116,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 14:12:53'),
(117,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 14:12:53'),
(118,1,'admin@example.com','Admin@example.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 14:14:18'),
(119,1,'admin@example.com','Admin@example.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 14:14:18'),
(120,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','curl/8.17.0',0,'2026-07-31 14:19:54'),
(121,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','curl/8.17.0',1,'2026-07-31 14:20:13'),
(122,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','curl/8.17.0',1,'2026-07-31 14:20:13'),
(123,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','curl/8.17.0',1,'2026-07-31 14:20:24'),
(124,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','curl/8.17.0',1,'2026-07-31 14:20:24'),
(125,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 15:34:35'),
(126,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 15:34:35'),
(127,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 15:34:58'),
(128,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 15:34:58'),
(129,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 15:35:33'),
(130,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 15:35:33'),
(131,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 15:48:34'),
(132,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 15:48:53'),
(133,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 16:02:03'),
(134,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 19:05:51'),
(135,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 19:06:23'),
(136,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 19:07:09'),
(137,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 19:07:51'),
(138,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-07-31 19:08:24'),
(139,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 11:53:07'),
(140,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 11:53:38'),
(141,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 11:54:28'),
(142,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 11:54:57'),
(143,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 11:57:15'),
(144,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 11:57:40'),
(145,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 12:36:41'),
(146,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 12:36:58'),
(147,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 12:37:20'),
(148,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 12:37:36'),
(149,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 12:38:20'),
(150,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 12:38:41'),
(151,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 12:38:57'),
(152,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 12:39:17'),
(153,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 12:39:40'),
(154,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 12:40:01'),
(155,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 12:40:17'),
(156,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 12:40:42'),
(157,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 12:41:47'),
(158,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 12:42:08'),
(159,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 12:43:06'),
(160,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 12:43:41'),
(161,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 12:44:28'),
(162,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 12:44:59'),
(163,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 12:45:21'),
(164,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 12:45:59'),
(165,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 12:46:32'),
(166,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 12:46:49'),
(167,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 12:47:14'),
(168,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 12:48:02'),
(169,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 12:48:34'),
(170,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36',1,'2026-08-01 12:49:48'),
(171,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 12:51:22'),
(172,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36',1,'2026-08-01 12:52:21'),
(173,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 13:12:39'),
(174,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 13:13:00'),
(175,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 13:14:19'),
(176,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 13:14:44'),
(177,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 13:30:36'),
(178,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 13:31:03'),
(179,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','curl/8.17.0',1,'2026-08-01 13:51:12'),
(180,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 14:08:21'),
(181,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 14:08:45'),
(182,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 14:09:07'),
(183,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 14:09:30'),
(184,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 14:09:52'),
(185,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 14:23:31'),
(186,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 14:24:04'),
(187,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 14:24:35'),
(188,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 14:25:10'),
(189,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 14:26:01'),
(190,1,'admin@example.com','admin@example.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 17:41:02'),
(191,NULL,'Barvo@gmail.com','Barvo@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0,'2026-08-01 17:49:07'),
(192,NULL,'Barvo@gmail.com','Barvo@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0,'2026-08-01 17:49:28'),
(193,NULL,'Barvo@gmail.com','Barvo@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0,'2026-08-01 17:49:33'),
(194,1,'admin@example.com','admin@example.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 17:50:07'),
(195,12,'bravo@gmail.com','bravo@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 17:51:22'),
(196,12,'bravo@gmail.com','Bravo@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 20:05:43'),
(197,1,'admin@example.com','admin@example.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 21:31:39'),
(198,12,'bravo@gmail.com','bravo@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0,'2026-08-01 21:35:18'),
(199,12,'bravo@gmail.com','bravo@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 21:35:38'),
(200,12,'bravo@gmail.com','bravo@gmail.com','192.168.25.12','curl/8.17.0',0,'2026-08-01 21:53:51'),
(201,12,'bravo@gmail.com','bravo@gmail.com','192.168.25.12','curl/8.17.0',1,'2026-08-01 21:55:27'),
(202,12,'bravo@gmail.com','bravo@gmail.com','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36',1,'2026-08-01 22:01:49'),
(203,NULL,'Brava@gmail.com','Brava@gmail.com','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36',0,'2026-08-01 22:50:39'),
(204,NULL,'Brava@gmail.com','Brava@gmail.com','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36',0,'2026-08-01 22:50:52'),
(205,12,'bravo@gmail.com','Bravo@gmail.com','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36',1,'2026-08-01 22:51:14'),
(206,12,'bravo@gmail.com','bravo@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0,'2026-08-01 22:57:38'),
(207,12,'bravo@gmail.com','bravo@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 22:57:54'),
(208,12,'bravo@gmail.com','bravo@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 23:07:09'),
(209,1,'admin@example.com','Admin@example.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 23:09:56'),
(210,1,'admin@example.com','Admin@example.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-01 23:47:49'),
(211,12,'bravo@gmail.com','bravo@gmail.com','192.168.25.169','Mozilla/5.0 (Android 13; Mobile; rv:153.0) Gecko/153.0 Firefox/153.0',1,'2026-08-02 00:08:57'),
(212,12,'bravo@gmail.com','bravo@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64; rv:153.0) Gecko/20100101 Firefox/153.0',1,'2026-08-02 00:20:02'),
(213,12,'bravo@gmail.com','Bravo@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0,'2026-08-02 00:23:27'),
(214,12,'bravo@gmail.com','Bravo@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-02 00:23:37'),
(215,1,'admin@example.com','admin@example.com','192.168.25.12','curl/8.17.0',1,'2026-08-02 00:30:04'),
(216,1,'admin@example.com','Admin@example.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-02 01:20:02'),
(217,1,'admin@example.com','Admin@example.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-02 01:44:09'),
(218,1,'admin@example.com','admin@example.com','192.168.25.12','curl/8.17.0',0,'2026-08-02 01:49:01'),
(219,1,'admin@example.com','admin@example.com','192.168.25.12','curl/8.17.0',1,'2026-08-02 01:51:42'),
(220,1,'admin@example.com','Admin@example.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-02 02:05:25'),
(221,1,'admin@example.com','Admin@example.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-02 02:29:46'),
(222,1,'admin@example.com','admin@example.com','192.168.25.12','curl/8.17.0',1,'2026-08-02 02:31:43'),
(223,1,'admin@example.com','admin@example.com','192.168.25.12','curl/8.17.0',1,'2026-08-02 02:35:10'),
(224,1,'admin@example.com','Admin@example.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-02 02:37:17'),
(225,12,'bravo@gmail.com','bravo@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0,'2026-08-02 03:00:49'),
(226,12,'bravo@gmail.com','bravo@gmail.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-02 03:01:05'),
(227,1,'admin@example.com','admin@example.com','192.168.25.169','Mozilla/5.0 (X11; Linux x86_64; rv:153.0) Gecko/20100101 Firefox/153.0',1,'2026-08-02 03:54:24'),
(228,1,'admin@example.com','admin@example.com','192.168.25.169','Mozilla/5.0 (Android 13; Mobile; rv:153.0) Gecko/153.0 Firefox/153.0',1,'2026-08-02 07:14:38'),
(229,1,'admin@example.com','admin@example.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-02 13:41:55'),
(230,6,'maria@gmail.com','maria@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64; rv:153.0) Gecko/20100101 Firefox/153.0',1,'2026-08-02 14:16:24'),
(231,6,'maria@gmail.com','maria@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-02 15:54:29'),
(232,1,'admin@example.com','admin@example.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64; rv:153.0) Gecko/20100101 Firefox/153.0',1,'2026-08-02 15:56:22'),
(233,1,'admin@example.com','admin@example.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64; rv:153.0) Gecko/20100101 Firefox/153.0',1,'2026-08-02 18:35:24'),
(234,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-03 11:12:27'),
(235,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-03 11:12:48'),
(236,12,'bravo@gmail.com','bravo@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-03 11:13:28'),
(237,6,'maria@gmail.com','maria@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-03 11:17:11'),
(238,12,'bravo@gmail.com','bravo@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64; rv:153.0) Gecko/20100101 Firefox/153.0',1,'2026-08-03 11:49:38'),
(239,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36',1,'2026-08-03 12:06:50'),
(240,6,'maria@gmail.com','maria@gmail.com','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36',1,'2026-08-03 12:09:41'),
(241,1,'admin@example.com','admin@example.com','192.168.25.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36',1,'2026-08-03 12:29:00'),
(242,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-03 12:30:37'),
(243,8,'pedro@gmail.com','Pedro@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-03 12:32:11'),
(244,8,'pedro@gmail.com','Pedro@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-03 12:35:11'),
(245,8,'pedro@gmail.com','Pedro@gmail.com','192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-03 12:36:44'),
(246,6,'maria@gmail.com','maria@gmail.com','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-08 11:23:27'),
(247,6,'maria@gmail.com','maria@gmail.com','192.168.241.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36',1,'2026-08-08 11:28:30'),
(248,1,'admin@example.com','admin@example.com','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-08 11:35:50'),
(249,6,'maria@gmail.com','maria@gmail.com','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-08 11:37:52'),
(250,12,'bravo@gmail.com','bravo@gmail.com','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64; rv:153.0) Gecko/20100101 Firefox/153.0',1,'2026-08-08 11:53:55'),
(251,12,'bravo@gmail.com','bravo@gmail.com','192.168.241.63','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-08 12:06:41'),
(252,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-08 17:37:27'),
(253,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-08 17:37:51'),
(254,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-08 17:39:48'),
(255,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-08 17:40:20'),
(256,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.241.63','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-08 17:41:12'),
(257,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-08 17:44:27'),
(258,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.241.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36',1,'2026-08-08 17:45:28'),
(259,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-08 17:46:05'),
(260,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-08 17:46:23'),
(261,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.241.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36',1,'2026-08-08 17:46:41'),
(262,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.241.63','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-08 17:47:30'),
(263,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.241.63','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-08 17:47:38'),
(264,6,'maria@gmail.com','maria@gmail.com','192.168.241.63','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-08 17:48:06'),
(265,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.241.63','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-08 17:48:34'),
(266,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-08 17:49:04'),
(267,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-08 17:49:22'),
(268,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-08 18:07:28'),
(269,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-08 18:07:44'),
(270,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-08 18:30:42'),
(271,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.241.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-08 18:32:00'),
(272,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-09 15:12:26'),
(273,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-09 15:13:24'),
(274,6,'maria@gmail.com','María@gmail.com','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-09 15:25:42'),
(275,6,'maria@gmail.com','María@gmail.com','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-09 15:26:12'),
(276,12,'bravo@gmail.com','Bravo@gmail.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-09 15:29:05'),
(277,12,'bravo@gmail.com','bravo@gmail.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-09 15:30:02'),
(278,12,'bravo@gmail.com','bravo@gmail.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-09 15:30:46'),
(279,12,'bravo@gmail.com','bravo@gmail.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-09 15:31:24'),
(280,6,'maria@gmail.com','María@gmail.com','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-09 17:42:44'),
(281,12,'bravo@gmail.com','bravo@gmail.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0,'2026-08-09 17:46:14'),
(282,12,'bravo@gmail.com','bravo@gmail.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-09 17:46:29'),
(283,12,'bravo@gmail.com','bravo@gmail.com','192.168.169.92','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-11 13:31:15'),
(284,6,'maria@gmail.com','maria@gmail.com','192.168.169.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-11 13:31:46'),
(285,6,'maria@gmail.com','maria@gmail.com','192.168.169.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-11 13:45:05'),
(286,12,'bravo@gmail.com','bravo@gmail.com','192.168.169.92','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0,'2026-08-11 13:45:30'),
(287,12,'bravo@gmail.com','bravo@gmail.com','192.168.169.92','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-11 13:45:48'),
(288,12,'bravo@gmail.com','bravo@gmail.com','192.168.169.92','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-11 14:22:29'),
(289,NULL,'Maria@gmai.com','Maria@gmai.com','192.168.169.92','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0,'2026-08-11 14:52:10'),
(290,NULL,'Maria@gmal.com','Maria@gmal.com','192.168.169.92','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0,'2026-08-11 14:52:21'),
(291,6,'maria@gmail.com','Maria@gmail.com','192.168.169.92','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-11 14:52:33'),
(292,6,'maria@gmail.com','Maria@gmail.com','192.168.169.92','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-11 14:53:01'),
(293,6,'maria@gmail.com','Maria@gmail.com','192.168.169.92','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-11 16:19:09'),
(294,6,'maria@gmail.com','María@gmail.com','192.168.169.92','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-11 16:20:02'),
(295,12,'bravo@gmail.com','bravo@gmail.com','192.168.169.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-11 16:21:17'),
(296,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.93.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-12 15:14:09'),
(297,6,'maria@gmail.com','Maria@gmail.com','192.168.93.149','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-12 16:59:15'),
(298,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.105.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-14 10:29:48'),
(299,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.105.122','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-14 11:06:42'),
(300,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.105.122','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-14 11:08:28'),
(301,12,'bravo@gmail.com','bravo@gmail.com','192.168.105.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-14 13:18:48'),
(302,6,'maria@gmail.com','Maria@gmail.com','192.168.105.122','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',1,'2026-08-14 13:19:11'),
(303,12,'bravo@gmail.com','Bravo@gmail.com','192.168.105.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-16 01:40:27'),
(304,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-16 19:59:02'),
(305,6,'maria@gmail.com','María@gmail.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-16 20:21:51'),
(306,1,'admin@example.com','04120761886','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-16 20:22:44'),
(307,6,'maria@gmail.com','María@gmail.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-16 20:23:49'),
(308,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-16 20:24:59'),
(309,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-16 20:40:19'),
(310,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-16 20:40:28'),
(311,6,'maria@gmail.com','María@gmail.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-16 20:40:37'),
(312,6,'maria@gmail.com','María@gmail.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-16 20:40:57'),
(313,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-16 21:13:10'),
(314,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-16 22:07:44'),
(315,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-16 22:16:11'),
(316,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-17 00:01:53'),
(317,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-17 00:04:55'),
(318,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-17 00:06:36'),
(319,6,'maria@gmail.com','María@gmail.com','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-17 00:07:06'),
(320,6,'maria@gmail.com','María@gmail.com','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-17 00:08:24'),
(321,6,'maria@gmail.com','María@gmail.com','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-17 00:08:59'),
(322,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.31.53','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36',1,'2026-08-17 00:15:52'),
(323,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.31.53','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36',1,'2026-08-17 00:38:02'),
(324,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.31.53','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36',1,'2026-08-17 01:22:48'),
(325,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-17 01:25:14'),
(326,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-17 01:29:59'),
(327,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-17 01:31:59'),
(328,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-17 01:32:07'),
(329,12,'bravo@gmail.com','bravo@gmail.com','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',0,'2026-08-17 01:32:56'),
(330,12,'bravo@gmail.com','bravo@gmail.com','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-17 01:33:08'),
(331,12,'bravo@gmail.com','bravo@gmail.com','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-17 02:42:29'),
(332,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-17 02:43:27'),
(333,6,'maria@gmail.com','María@gmail.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-17 02:45:05'),
(334,6,'maria@gmail.com','María@gmail.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-17 04:27:59'),
(335,12,'bravo@gmail.com','bravo@gmail.com','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-17 04:29:42'),
(336,6,'maria@gmail.com','maria@gmail.com','192.168.31.53','curl/8.17.0',1,'2026-08-17 05:13:55'),
(337,6,'maria@gmail.com','maria@gmail.com','192.168.205.12','curl/8.17.0',1,'2026-08-17 20:49:14'),
(338,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.205.12','curl/8.17.0',1,'2026-08-17 20:50:15'),
(339,1,'admin@example.com','admin@example.com','192.168.205.12','curl/8.17.0',1,'2026-08-17 20:51:53'),
(340,12,'bravo@gmail.com','bravo@gmail.com','192.168.31.53','curl/8.17.0',1,'2026-08-18 00:53:53'),
(341,6,'maria@gmail.com','María@gmail.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-18 01:42:09'),
(342,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.31.53','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36',1,'2026-08-18 01:44:29'),
(343,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-18 04:39:45'),
(344,12,'bravo@gmail.com','Bravo@gmail.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-18 04:40:40'),
(345,6,'maria@gmail.com','María@gmail.com','192.168.205.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-18 13:53:19'),
(346,12,'bravo@gmail.com','bravo@gmail.com','192.168.205.6','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-18 13:54:35'),
(347,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.205.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-18 18:59:22'),
(348,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.205.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-18 19:06:44'),
(349,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.205.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36',1,'2026-08-18 19:07:50'),
(350,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.205.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-18 19:09:29'),
(351,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.205.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36',1,'2026-08-18 19:10:52'),
(352,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.205.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36',1,'2026-08-18 19:11:21'),
(353,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.205.12','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36',1,'2026-08-18 19:12:05'),
(354,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.205.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-18 19:15:27'),
(355,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.11.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-20 14:20:55'),
(356,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.11.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-20 16:32:31'),
(357,1,'admin@example.com','admin@example.com','192.168.11.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-20 16:35:59'),
(358,6,'maria@gmail.com','Maria@gmail.com','192.168.11.218','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-20 16:41:33'),
(359,12,'bravo@gmail.com','bravo@gmail.com','192.168.11.218','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-20 16:42:48'),
(360,12,'bravo@gmail.com','bravo@gmail.com','192.168.11.218','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-20 18:14:35'),
(361,12,'bravo@gmail.com','bravo@gmail.com','192.168.11.218','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',0,'2026-08-20 18:30:25'),
(362,12,'bravo@gmail.com','bravo@gmail.com','192.168.11.218','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-20 18:30:43'),
(363,12,'bravo@gmail.com','bravo@gmail.com','192.168.11.218','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-20 18:31:39'),
(364,12,'bravo@gmail.com','bravo@gmail.com','192.168.11.218','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-21 18:20:36'),
(365,12,'bravo@gmail.com','bravo@gmail.com','192.168.11.218','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-21 18:22:09'),
(366,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.11.218','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-21 18:22:39'),
(367,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.11.218','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-21 18:40:19'),
(368,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.11.218','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-21 18:40:46'),
(369,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.11.218','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-21 20:34:17'),
(370,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.11.218','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-21 20:35:59'),
(371,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.11.218','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-21 20:36:26'),
(372,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.11.218','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-21 20:36:55'),
(373,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.5.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-22 14:05:53'),
(374,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.5.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-22 15:59:24'),
(375,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.5.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-22 17:37:11'),
(376,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.5.13','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36',1,'2026-08-22 17:43:25'),
(377,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.5.13','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36',1,'2026-08-22 17:44:46'),
(378,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-23 13:16:56'),
(379,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-23 13:17:05'),
(380,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-23 13:17:22'),
(381,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-23 19:09:52'),
(382,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-23 19:11:28'),
(383,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-23 19:12:25'),
(384,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-23 19:12:42'),
(385,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-23 22:56:39'),
(386,12,'bravo@gmail.com','bravo@gmail.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-23 23:04:57'),
(387,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-23 23:11:27'),
(388,12,'bravo@gmail.com','bravo@gmail.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-23 23:11:46'),
(389,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-24 02:29:02'),
(390,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.31.219','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-24 02:32:23'),
(391,12,'bravo@gmail.com','bravo@gmail.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',0,'2026-08-24 09:44:18'),
(392,12,'bravo@gmail.com','bravo@gmail.com','192.168.31.53','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-24 09:44:34'),
(393,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.5.13','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-24 13:26:16'),
(394,12,'bravo@gmail.com','bravo@gmail.com','192.168.5.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-24 13:27:39'),
(395,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.5.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-24 15:45:02'),
(396,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.5.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-24 15:45:30'),
(397,12,'bravo@gmail.com','bravo@gmail.com','192.168.5.13','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-24 15:45:58'),
(398,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.5.13','Mozilla/5.0 (Linux; Android 10; Redmi 8 Build/QKQ1.191014.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/150.0.7871.181 Mobile Safari/537.36',1,'2026-08-24 19:57:20'),
(399,2,'divijeal@gmail.com','divijeal@gmail.com','192.168.5.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36',1,'2026-08-24 20:34:36');
/*!40000 ALTER TABLE `login_attempts` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `message_status`
--

LOCK TABLES `message_status` WRITE;
/*!40000 ALTER TABLE `message_status` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `message_status` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `messages`
--

LOCK TABLES `messages` WRITE;
/*!40000 ALTER TABLE `messages` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `messages` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `notifications` (`id`, `sender_id`, `receiver_id`, `receiver_role`, `title`, `message`, `data_json`, `is_read`, `created_at`) VALUES (1,2,12,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/orders\\/1\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',0,'2026-08-24 11:51:53'),
(2,12,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/44\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":44}',1,'2026-08-24 11:51:55'),
(3,2,12,'provider','Pago registrado','El cliente pagará en efectivo','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/1\",\"action\":\"verify_payment\",\"request_id\":1,\"payment_id\":1}',0,'2026-08-24 11:52:04'),
(4,12,2,'user','Pago confirmado','El proveedor certificó que recibió tu pago','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/1\",\"action\":\"view_order\",\"request_id\":1,\"payment_id\":1}',1,'2026-08-24 11:52:24'),
(5,12,2,'user','Servicio en progreso','El proveedor ha comenzado el servicio','{\"url\":\"\\/orders\\/1\",\"action\":\"view_request\",\"notification_type\":\"status_updated\",\"request_id\":1,\"status\":\"in_progress\"}',1,'2026-08-24 12:02:34'),
(6,12,2,'user','Proveedor en camino','El proveedor está en camino','{\"url\":\"\\/orders\\/1\",\"action\":\"view_request\",\"notification_type\":\"status_updated\",\"request_id\":1,\"status\":\"on_the_way\"}',1,'2026-08-24 12:02:41'),
(7,12,2,'user','Proveedor llegó','El proveedor ha llegado','{\"url\":\"\\/orders\\/1\",\"action\":\"view_request\",\"notification_type\":\"status_updated\",\"request_id\":1,\"status\":\"arrived\"}',1,'2026-08-24 12:02:47'),
(8,12,2,'user','Servicio finalizado - ¡Califica tu experiencia!','El proveedor marcó el servicio como finalizado.','{\"type\":\"rating\",\"notification_type\":\"open_rating\",\"url\":\"\\/orders\\/1\",\"action\":\"open_rating_modal\",\"request_id\":1,\"provider_id\":12,\"from_role\":\"provider\"}',1,'2026-08-24 12:02:51'),
(9,2,12,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/orders\\/2\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',0,'2026-08-24 13:28:28'),
(10,12,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/44\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":44}',1,'2026-08-24 13:28:33'),
(11,2,12,'provider','Pago registrado','El cliente pagará en efectivo','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/2\",\"action\":\"verify_payment\",\"request_id\":2,\"payment_id\":2}',1,'2026-08-24 13:28:38'),
(12,12,2,'user','Pago confirmado','El proveedor certificó que recibió tu pago','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/2\",\"action\":\"view_order\",\"request_id\":2,\"payment_id\":2}',1,'2026-08-24 13:28:58'),
(13,12,2,'user','Servicio en progreso','El proveedor ha comenzado el servicio','{\"url\":\"\\/orders\\/2\",\"action\":\"view_request\",\"notification_type\":\"status_updated\",\"request_id\":2,\"status\":\"in_progress\"}',0,'2026-08-24 13:29:38'),
(14,12,2,'user','Proveedor en camino','El proveedor está en camino','{\"url\":\"\\/orders\\/2\",\"action\":\"view_request\",\"notification_type\":\"status_updated\",\"request_id\":2,\"status\":\"on_the_way\"}',0,'2026-08-24 13:29:44'),
(15,12,2,'user','Proveedor llegó','El proveedor ha llegado','{\"url\":\"\\/orders\\/2\",\"action\":\"view_request\",\"notification_type\":\"status_updated\",\"request_id\":2,\"status\":\"arrived\"}',0,'2026-08-24 13:29:48'),
(16,12,2,'user','Servicio finalizado - ¡Califica tu experiencia!','El proveedor marcó el servicio como finalizado.','{\"type\":\"rating\",\"notification_type\":\"open_rating\",\"url\":\"\\/orders\\/2\",\"action\":\"open_rating_modal\",\"request_id\":2,\"provider_id\":12,\"from_role\":\"provider\"}',0,'2026-08-24 13:29:53'),
(17,2,12,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/orders\\/3\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',0,'2026-08-24 13:30:30'),
(18,12,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/44\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":44}',0,'2026-08-24 13:30:35'),
(19,2,12,'provider','Pago registrado','El cliente pagará en efectivo','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/3\",\"action\":\"verify_payment\",\"request_id\":3,\"payment_id\":3}',1,'2026-08-24 13:30:39'),
(20,12,2,'user','Pago confirmado','El proveedor certificó que recibió tu pago','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/3\",\"action\":\"view_order\",\"request_id\":3,\"payment_id\":3}',0,'2026-08-24 13:30:49'),
(21,12,2,'user','Servicio en progreso','El proveedor ha comenzado el servicio','{\"url\":\"\\/orders\\/3\",\"action\":\"view_request\",\"notification_type\":\"status_updated\",\"request_id\":3,\"status\":\"in_progress\"}',0,'2026-08-24 13:30:56'),
(22,12,2,'user','Proveedor en camino','El proveedor está en camino','{\"url\":\"\\/orders\\/3\",\"action\":\"view_request\",\"notification_type\":\"status_updated\",\"request_id\":3,\"status\":\"on_the_way\"}',0,'2026-08-24 13:30:59'),
(23,12,2,'user','Proveedor llegó','El proveedor ha llegado','{\"url\":\"\\/orders\\/3\",\"action\":\"view_request\",\"notification_type\":\"status_updated\",\"request_id\":3,\"status\":\"arrived\"}',0,'2026-08-24 13:31:02'),
(24,12,2,'user','Servicio finalizado - ¡Califica tu experiencia!','El proveedor marcó el servicio como finalizado.','{\"type\":\"rating\",\"notification_type\":\"open_rating\",\"url\":\"\\/orders\\/3\",\"action\":\"open_rating_modal\",\"request_id\":3,\"provider_id\":12,\"from_role\":\"provider\"}',0,'2026-08-24 13:31:05'),
(25,12,2,'user','¡Tienes una nueva evaluación!','Un proveedor te calificó con 4 estrellas.','{\"type\":\"review\",\"notification_type\":\"review_received\",\"route\":\"\\/my-reviews\",\"url\":\"\\/reviews\",\"action\":\"view_reviews\"}',0,'2026-08-24 13:31:18'),
(26,2,12,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/orders\\/4\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',0,'2026-08-24 13:35:28'),
(27,12,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/44\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":44}',0,'2026-08-24 13:35:31'),
(28,2,12,'provider','Pago registrado','El cliente pagará en efectivo','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/4\",\"action\":\"verify_payment\",\"request_id\":4,\"payment_id\":4}',1,'2026-08-24 13:35:36'),
(29,12,2,'user','Pago confirmado','El proveedor certificó que recibió tu pago','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/4\",\"action\":\"view_order\",\"request_id\":4,\"payment_id\":4}',0,'2026-08-24 13:35:44'),
(30,12,2,'user','Servicio en progreso','El proveedor ha comenzado el servicio','{\"url\":\"\\/orders\\/4\",\"action\":\"view_request\",\"notification_type\":\"status_updated\",\"request_id\":4,\"status\":\"in_progress\"}',0,'2026-08-24 13:35:47'),
(31,12,2,'user','Proveedor en camino','El proveedor está en camino','{\"url\":\"\\/orders\\/4\",\"action\":\"view_request\",\"notification_type\":\"status_updated\",\"request_id\":4,\"status\":\"on_the_way\"}',0,'2026-08-24 13:35:50'),
(32,12,2,'user','Proveedor llegó','El proveedor ha llegado','{\"url\":\"\\/orders\\/4\",\"action\":\"view_request\",\"notification_type\":\"status_updated\",\"request_id\":4,\"status\":\"arrived\"}',0,'2026-08-24 13:35:53'),
(33,12,2,'user','Servicio finalizado - ¡Califica tu experiencia!','El proveedor marcó el servicio como finalizado.','{\"type\":\"rating\",\"notification_type\":\"open_rating\",\"url\":\"\\/orders\\/4\",\"action\":\"open_rating_modal\",\"request_id\":4,\"provider_id\":12,\"from_role\":\"provider\"}',0,'2026-08-24 13:35:57'),
(34,12,2,'user','¡Tienes una nueva evaluación!','Un proveedor te calificó con 4 estrellas.','{\"type\":\"review\",\"notification_type\":\"review_received\",\"route\":\"\\/my-reviews\",\"url\":\"\\/reviews\",\"action\":\"view_reviews\"}',0,'2026-08-24 13:36:13'),
(35,2,12,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/orders\\/5\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-08-24 15:46:16'),
(36,12,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/44\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":44}',0,'2026-08-24 15:46:19'),
(37,12,2,'user','Servicio en progreso','El proveedor ha comenzado el servicio','{\"url\":\"\\/orders\\/5\",\"action\":\"view_request\",\"notification_type\":\"status_updated\",\"request_id\":5,\"status\":\"in_progress\"}',0,'2026-08-24 15:47:03'),
(38,12,2,'user','Proveedor en camino','El proveedor está en camino','{\"url\":\"\\/orders\\/5\",\"action\":\"view_request\",\"notification_type\":\"status_updated\",\"request_id\":5,\"status\":\"on_the_way\"}',0,'2026-08-24 15:47:05'),
(39,12,2,'user','Proveedor llegó','El proveedor ha llegado','{\"url\":\"\\/orders\\/5\",\"action\":\"view_request\",\"notification_type\":\"status_updated\",\"request_id\":5,\"status\":\"arrived\"}',0,'2026-08-24 15:47:08'),
(40,2,12,'provider','Pago registrado','El cliente pagará en efectivo','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/5\",\"action\":\"verify_payment\",\"request_id\":5,\"payment_id\":5}',0,'2026-08-24 18:07:30'),
(41,12,2,'user','Pago confirmado','El proveedor certificó que recibió tu pago','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/5\",\"action\":\"view_order\",\"request_id\":5,\"payment_id\":5}',0,'2026-08-24 18:07:50'),
(42,12,2,'user','Servicio finalizado - ¡Califica tu experiencia!','El proveedor marcó el servicio como finalizado.','{\"type\":\"rating\",\"notification_type\":\"open_rating\",\"url\":\"\\/orders\\/5\",\"action\":\"open_rating_modal\",\"request_id\":5,\"provider_id\":12,\"from_role\":\"provider\"}',0,'2026-08-24 18:07:56'),
(43,12,2,'user','¡Tienes una nueva evaluación!','Un proveedor te calificó con 4 estrellas.','{\"type\":\"review\",\"notification_type\":\"review_received\",\"route\":\"\\/my-reviews\",\"url\":\"\\/reviews\",\"action\":\"view_reviews\"}',1,'2026-08-24 18:08:28'),
(44,2,12,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/orders\\/6\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',0,'2026-08-24 18:27:26'),
(45,12,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/44\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":44}',0,'2026-08-24 18:27:31'),
(46,2,12,'provider','Pago registrado','El cliente pagará en efectivo','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/6\",\"action\":\"verify_payment\",\"request_id\":6,\"payment_id\":6}',0,'2026-08-24 18:27:35'),
(47,12,2,'user','Pago rechazado','El proveedor rechazó tu comprobante de pago.','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/6\",\"action\":\"view_order\",\"request_id\":6,\"payment_id\":6}',0,'2026-08-24 18:27:48'),
(48,2,12,'provider','Pago registrado','El cliente pagará en efectivo','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/6\",\"action\":\"verify_payment\",\"request_id\":6,\"payment_id\":7}',0,'2026-08-24 18:28:36'),
(49,12,2,'user','Pago confirmado','El proveedor certificó que recibió tu pago','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/6\",\"action\":\"view_order\",\"request_id\":6,\"payment_id\":7}',0,'2026-08-24 18:28:58'),
(50,12,2,'user','Servicio en progreso','El proveedor ha comenzado el servicio','{\"url\":\"\\/orders\\/6\",\"action\":\"view_request\",\"notification_type\":\"status_updated\",\"request_id\":6,\"status\":\"in_progress\"}',0,'2026-08-24 18:29:07'),
(51,12,2,'user','Proveedor en camino','El proveedor está en camino','{\"url\":\"\\/orders\\/6\",\"action\":\"view_request\",\"notification_type\":\"status_updated\",\"request_id\":6,\"status\":\"on_the_way\"}',0,'2026-08-24 18:29:10'),
(52,12,2,'user','Proveedor llegó','El proveedor ha llegado','{\"url\":\"\\/orders\\/6\",\"action\":\"view_request\",\"notification_type\":\"status_updated\",\"request_id\":6,\"status\":\"arrived\"}',0,'2026-08-24 18:29:12'),
(53,12,2,'user','Servicio finalizado - ¡Califica tu experiencia!','El proveedor marcó el servicio como finalizado.','{\"type\":\"rating\",\"notification_type\":\"open_rating\",\"url\":\"\\/orders\\/6\",\"action\":\"open_rating_modal\",\"request_id\":6,\"provider_id\":12,\"from_role\":\"provider\"}',0,'2026-08-24 18:29:15'),
(54,12,2,'user','¡Tienes una nueva evaluación!','Un proveedor te calificó con 4 estrellas.','{\"type\":\"review\",\"notification_type\":\"review_received\",\"route\":\"\\/my-reviews\",\"url\":\"\\/reviews\",\"action\":\"view_reviews\"}',0,'2026-08-24 18:29:30'),
(55,2,12,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/orders\\/7\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',0,'2026-08-24 19:57:37'),
(56,12,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/44\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":44}',0,'2026-08-24 19:57:46'),
(57,2,12,'provider','Pago registrado','El cliente pagará en efectivo','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/7\",\"action\":\"verify_payment\",\"request_id\":7,\"payment_id\":8}',0,'2026-08-24 19:57:53'),
(58,12,2,'user','Pago confirmado','El proveedor certificó que recibió tu pago','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/7\",\"action\":\"view_order\",\"request_id\":7,\"payment_id\":8}',0,'2026-08-24 19:58:02'),
(59,12,2,'user','Servicio en progreso','El proveedor ha comenzado el servicio','{\"url\":\"\\/orders\\/7\",\"action\":\"view_request\",\"notification_type\":\"status_updated\",\"request_id\":7,\"status\":\"in_progress\"}',0,'2026-08-24 19:58:06'),
(60,12,2,'user','Proveedor en camino','El proveedor está en camino','{\"url\":\"\\/orders\\/7\",\"action\":\"view_request\",\"notification_type\":\"status_updated\",\"request_id\":7,\"status\":\"on_the_way\"}',0,'2026-08-24 19:58:10'),
(61,12,2,'user','Proveedor llegó','El proveedor ha llegado','{\"url\":\"\\/orders\\/7\",\"action\":\"view_request\",\"notification_type\":\"status_updated\",\"request_id\":7,\"status\":\"arrived\"}',0,'2026-08-24 19:58:14'),
(62,12,2,'user','Servicio finalizado - ¡Califica tu experiencia!','El proveedor marcó el servicio como finalizado.','{\"type\":\"rating\",\"notification_type\":\"open_rating\",\"url\":\"\\/orders\\/7\",\"action\":\"open_rating_modal\",\"request_id\":7,\"provider_id\":12,\"from_role\":\"provider\"}',0,'2026-08-24 19:58:16'),
(63,2,12,'provider','¡Tienes una nueva evaluación!','Un cliente te calificó con 4 estrellas.','{\"type\":\"review\",\"notification_type\":\"review_received\",\"route\":\"\\/reviews\",\"url\":\"\\/reviews\",\"action\":\"view_reviews\"}',0,'2026-08-24 19:58:57'),
(64,2,12,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/orders\\/8\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',0,'2026-08-24 20:00:08'),
(65,12,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/44\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":44}',0,'2026-08-24 20:00:14'),
(66,2,12,'provider','Pago registrado','El cliente pagará en efectivo','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/8\",\"action\":\"verify_payment\",\"request_id\":8,\"payment_id\":9}',0,'2026-08-24 20:00:21'),
(67,12,2,'user','Pago confirmado','El proveedor certificó que recibió tu pago','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/8\",\"action\":\"view_order\",\"request_id\":8,\"payment_id\":9}',0,'2026-08-24 20:00:38'),
(68,12,2,'user','Servicio en progreso','El proveedor ha comenzado el servicio','{\"url\":\"\\/orders\\/8\",\"action\":\"view_request\",\"notification_type\":\"status_updated\",\"request_id\":8,\"status\":\"in_progress\"}',0,'2026-08-24 20:00:42'),
(69,12,2,'user','Proveedor en camino','El proveedor está en camino','{\"url\":\"\\/orders\\/8\",\"action\":\"view_request\",\"notification_type\":\"status_updated\",\"request_id\":8,\"status\":\"on_the_way\"}',0,'2026-08-24 20:00:44'),
(70,12,2,'user','Proveedor llegó','El proveedor ha llegado','{\"url\":\"\\/orders\\/8\",\"action\":\"view_request\",\"notification_type\":\"status_updated\",\"request_id\":8,\"status\":\"arrived\"}',0,'2026-08-24 20:00:47'),
(71,12,2,'user','Servicio finalizado - ¡Califica tu experiencia!','El proveedor marcó el servicio como finalizado.','{\"type\":\"rating\",\"notification_type\":\"open_rating\",\"url\":\"\\/orders\\/8\",\"action\":\"open_rating_modal\",\"request_id\":8,\"provider_id\":12,\"from_role\":\"provider\"}',0,'2026-08-24 20:00:51'),
(72,12,2,'user','¡Tienes una nueva evaluación!','Un proveedor te calificó con 3 estrellas.','{\"type\":\"review\",\"notification_type\":\"review_received\",\"route\":\"\\/my-reviews\",\"url\":\"\\/reviews\",\"action\":\"view_reviews\"}',0,'2026-08-24 20:01:09'),
(73,2,12,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/orders\\/9\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',0,'2026-08-24 20:20:46'),
(74,12,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/44\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":44}',0,'2026-08-24 20:20:52'),
(75,2,12,'provider','Pago registrado','El cliente pagará en efectivo','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/9\",\"action\":\"verify_payment\",\"request_id\":9,\"payment_id\":10}',0,'2026-08-24 20:20:59'),
(76,12,2,'user','Pago confirmado','El proveedor certificó que recibió tu pago','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/9\",\"action\":\"view_order\",\"request_id\":9,\"payment_id\":10}',0,'2026-08-24 20:21:14'),
(77,12,2,'user','Servicio en progreso','El proveedor ha comenzado el servicio','{\"url\":\"\\/orders\\/9\",\"action\":\"view_request\",\"notification_type\":\"status_updated\",\"request_id\":9,\"status\":\"in_progress\"}',0,'2026-08-24 20:21:19'),
(78,12,2,'user','Proveedor en camino','El proveedor está en camino','{\"url\":\"\\/orders\\/9\",\"action\":\"view_request\",\"notification_type\":\"status_updated\",\"request_id\":9,\"status\":\"on_the_way\"}',0,'2026-08-24 20:21:22'),
(79,12,2,'user','Proveedor llegó','El proveedor ha llegado','{\"url\":\"\\/orders\\/9\",\"action\":\"view_request\",\"notification_type\":\"status_updated\",\"request_id\":9,\"status\":\"arrived\"}',0,'2026-08-24 20:21:25'),
(80,12,2,'user','Servicio finalizado - ¡Califica tu experiencia!','El proveedor marcó el servicio como finalizado.','{\"type\":\"rating\",\"notification_type\":\"open_rating\",\"url\":\"\\/orders\\/9\",\"action\":\"open_rating_modal\",\"request_id\":9,\"provider_id\":12,\"from_role\":\"provider\"}',0,'2026-08-24 20:21:27'),
(81,12,2,'user','¡Tienes una nueva evaluación!','Un proveedor te calificó con 5 estrellas.','{\"type\":\"review\",\"notification_type\":\"review_received\",\"route\":\"\\/my-reviews\",\"url\":\"\\/reviews\",\"action\":\"view_reviews\"}',0,'2026-08-24 20:21:36'),
(82,2,12,'provider','¡Tienes una nueva evaluación!','Un cliente te calificó con 5 estrellas.','{\"type\":\"review\",\"notification_type\":\"review_received\",\"route\":\"\\/reviews\",\"url\":\"\\/reviews\",\"action\":\"view_reviews\"}',0,'2026-08-24 20:21:56');
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
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
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `platform_earnings`
--

LOCK TABLES `platform_earnings` WRITE;
/*!40000 ALTER TABLE `platform_earnings` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `platform_earnings` (`id`, `type`, `amount`, `reference_id`, `user_id`, `created_at`) VALUES (1,'service_publish',5.00,33,10,'2026-05-24 12:53:38'),
(2,'transaction_commission',0.20,50,6,'2026-05-24 14:57:37'),
(3,'transaction_commission',0.20,76,6,'2026-05-24 15:02:18'),
(4,'service_publish',5.00,34,10,'2026-05-24 17:43:42'),
(5,'transaction_commission',0.20,78,6,'2026-05-29 08:08:18'),
(6,'transaction_commission',0.20,79,6,'2026-06-01 02:25:43'),
(7,'transaction_commission',0.70,80,6,'2026-06-01 02:47:50'),
(8,'transaction_commission',0.70,81,6,'2026-06-01 03:39:35'),
(9,'transaction_commission',0.20,82,6,'2026-06-01 03:41:56'),
(10,'transaction_commission',0.20,83,6,'2026-06-02 13:09:02'),
(11,'transaction_commission',0.20,84,6,'2026-06-02 13:32:25'),
(12,'transaction_commission',0.20,85,6,'2026-06-04 11:30:01'),
(13,'transaction_commission',0.20,86,6,'2026-06-05 10:22:17'),
(14,'transaction_commission',0.20,87,6,'2026-06-05 10:42:16'),
(15,'transaction_commission',0.70,89,6,'2026-06-05 16:55:46'),
(16,'transaction_commission',0.70,90,6,'2026-06-05 17:11:56'),
(17,'transaction_commission',0.70,91,6,'2026-06-05 17:24:17'),
(18,'transaction_commission',0.70,92,6,'2026-06-05 18:25:50'),
(19,'transaction_commission',0.70,93,6,'2026-06-05 18:42:55'),
(20,'transaction_commission',0.70,94,6,'2026-06-05 20:58:16'),
(21,'transaction_commission',0.70,95,6,'2026-06-05 22:41:10'),
(22,'transaction_commission',0.70,96,6,'2026-06-05 22:46:28'),
(23,'transaction_commission',0.70,97,6,'2026-06-06 00:13:53'),
(24,'transaction_commission',0.70,98,6,'2026-06-06 01:06:14'),
(25,'transaction_commission',0.20,99,6,'2026-06-06 01:53:38'),
(26,'transaction_commission',0.70,100,6,'2026-06-06 21:27:33'),
(27,'transaction_commission',0.50,77,10,'2026-06-09 01:01:25'),
(28,'transaction_commission',0.20,107,6,'2026-06-09 13:37:25'),
(29,'transaction_commission',0.20,108,6,'2026-06-09 13:40:43'),
(30,'transaction_commission',0.20,109,6,'2026-06-14 20:06:47'),
(31,'transaction_commission',0.70,110,6,'2026-06-14 20:08:38'),
(32,'transaction_commission',0.20,111,6,'2026-06-14 20:18:00'),
(33,'transaction_commission',0.20,111,6,'2026-06-14 20:44:34'),
(34,'transaction_commission',0.20,112,6,'2026-06-15 16:03:15'),
(35,'transaction_commission',0.20,113,6,'2026-06-15 16:04:55'),
(36,'transaction_commission',0.70,114,6,'2026-06-16 11:07:50'),
(37,'transaction_commission',0.70,115,6,'2026-06-16 12:28:36'),
(38,'transaction_commission',0.70,116,6,'2026-06-16 16:15:24'),
(39,'transaction_commission',0.70,117,6,'2026-06-17 14:51:22'),
(40,'transaction_commission',0.70,1,6,'2026-06-30 11:28:11'),
(41,'transaction_commission',0.70,1,6,'2026-06-30 11:43:13'),
(42,'transaction_commission',0.20,1,6,'2026-07-04 20:16:42'),
(43,'transaction_commission',0.70,1,6,'2026-07-11 07:56:34'),
(44,'transaction_commission',0.70,1,6,'2026-07-11 07:59:39'),
(45,'transaction_commission',0.20,2,6,'2026-07-12 19:08:42'),
(46,'transaction_commission',0.70,3,6,'2026-07-12 19:12:35'),
(47,'transaction_commission',0.20,5,6,'2026-07-12 19:52:10'),
(48,'transaction_commission',0.20,6,6,'2026-07-12 19:53:11'),
(49,'transaction_commission',0.20,7,6,'2026-07-12 19:59:50'),
(50,'transaction_commission',0.20,8,6,'2026-07-12 20:04:12'),
(51,'transaction_commission',0.20,9,6,'2026-07-12 22:01:44'),
(52,'transaction_commission',0.70,10,6,'2026-07-13 01:33:39'),
(53,'transaction_commission',0.70,11,6,'2026-07-13 01:38:10'),
(54,'transaction_commission',0.20,12,6,'2026-07-13 02:31:47'),
(55,'transaction_commission',0.20,13,6,'2026-07-13 02:37:36'),
(56,'transaction_commission',0.20,14,6,'2026-07-13 10:55:49'),
(57,'transaction_commission',0.20,1,6,'2026-07-15 10:27:41'),
(58,'transaction_commission',0.70,2,6,'2026-07-15 10:30:32'),
(59,'transaction_commission',0.70,1,6,'2026-07-15 14:26:17'),
(60,'transaction_commission',0.70,1,6,'2026-07-18 13:14:18'),
(61,'transaction_commission',0.70,2,6,'2026-07-18 13:24:36'),
(62,'transaction_commission',0.70,1,6,'2026-07-18 13:57:04'),
(63,'transaction_commission',0.70,1,6,'2026-07-18 17:42:54'),
(64,'transaction_commission',0.70,2,6,'2026-07-21 22:05:12'),
(65,'transaction_commission',0.20,4,6,'2026-07-27 22:19:12'),
(66,'service_publish',5.00,43,12,'2026-08-01 23:11:23'),
(67,'service_publish',5.00,43,12,'2026-08-02 06:21:13'),
(68,'service_publish',5.00,43,12,'2026-08-02 07:11:25'),
(69,'service_publish',5.00,43,12,'2026-08-02 07:11:28'),
(70,'service_publish',5.00,43,12,'2026-08-02 07:11:31'),
(71,'service_publish',5.00,43,12,'2026-08-02 07:17:10'),
(72,'service_publish',5.00,44,12,'2026-08-02 11:53:31'),
(73,'service_publish',5.00,44,12,'2026-08-02 11:55:17'),
(75,'service_publish',5.00,44,12,'2026-08-02 12:30:03'),
(78,'featured',5.00,44,12,'2026-08-02 13:08:46'),
(79,'service_publish',5.00,45,6,'2026-08-02 15:57:16'),
(80,'transaction_commission',0.45,1,12,'2026-08-10 11:05:36'),
(81,'transaction_commission',0.45,1,12,'2026-08-11 04:32:53'),
(82,'transaction_commission',0.45,1,12,'2026-08-11 13:33:35'),
(83,'transaction_commission',0.45,2,12,'2026-08-11 13:46:52'),
(84,'transaction_commission',0.45,1,12,'2026-08-11 13:57:18'),
(85,'transaction_commission',0.45,1,12,'2026-08-17 02:58:40'),
(86,'transaction_commission',0.45,1,12,'2026-08-17 04:44:12'),
(87,'transaction_commission',0.45,1,12,'2026-08-18 04:43:55'),
(88,'transaction_commission',0.45,2,12,'2026-08-18 04:51:17'),
(89,'transaction_commission',0.45,3,12,'2026-08-18 04:55:36'),
(90,'transaction_commission',0.45,4,12,'2026-08-18 13:56:24'),
(91,'transaction_commission',0.45,1,12,'2026-08-18 14:16:39'),
(92,'transaction_commission',0.45,2,12,'2026-08-18 15:29:13'),
(93,'transaction_commission',0.45,3,12,'2026-08-23 23:06:33'),
(94,'transaction_commission',0.45,1,12,'2026-08-23 23:15:31'),
(95,'transaction_commission',0.45,2,12,'2026-08-23 23:37:04'),
(96,'transaction_commission',0.45,3,12,'2026-08-24 02:24:48'),
(97,'transaction_commission',0.45,4,12,'2026-08-24 11:20:42'),
(98,'transaction_commission',0.45,1,12,'2026-08-24 11:52:24'),
(99,'transaction_commission',0.45,2,12,'2026-08-24 13:28:58'),
(100,'transaction_commission',0.45,3,12,'2026-08-24 13:30:49'),
(101,'transaction_commission',0.45,4,12,'2026-08-24 13:35:44'),
(102,'transaction_commission',0.45,5,12,'2026-08-24 18:07:50'),
(103,'transaction_commission',0.45,6,12,'2026-08-24 18:28:58'),
(104,'transaction_commission',0.45,7,12,'2026-08-24 19:58:02'),
(105,'transaction_commission',0.45,8,12,'2026-08-24 20:00:38'),
(106,'transaction_commission',0.45,9,12,'2026-08-24 20:21:14');
/*!40000 ALTER TABLE `platform_earnings` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `provider_billing`
--

LOCK TABLES `provider_billing` WRITE;
/*!40000 ALTER TABLE `provider_billing` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `provider_billing` (`id`, `provider_id`, `period_start`, `period_end`, `due_date`, `total_commission`, `total_services`, `total_transactions`, `status`, `payment_method`, `payment_reference`, `payment_proof`, `reported_at`, `paid_at`, `created_at`) VALUES (1,6,'2026-05-01','2026-05-31','2026-06-15',0.60,1,3,'paid','mobile_payment','3847747447','http://192.168.25.12:8000/uploads/billing/d4298647173367e5.jpg',NULL,'2026-08-02 17:44:25','2026-05-24 14:57:37'),
(2,6,'2026-06-01','2026-06-30','2026-07-15',17.00,1,35,'verifying','transferencia','123456',NULL,NULL,'2026-08-02 16:49:10','2026-06-01 02:25:43'),
(3,10,'2026-06-01','2026-06-30','2026-07-15',0.50,1,1,'overdue',NULL,NULL,NULL,NULL,NULL,'2026-06-09 01:01:25'),
(4,6,'2026-07-01','2026-07-31','2026-08-15',10.80,1,24,'pending',NULL,NULL,NULL,NULL,NULL,'2026-07-04 20:16:42'),
(5,6,'2026-07-18','2026-08-02',NULL,0.20,1,1,'pending',NULL,NULL,NULL,NULL,NULL,'2026-08-02 16:57:55'),
(6,12,'2026-08-01','2026-08-31',NULL,12.15,1,27,'pending',NULL,NULL,NULL,NULL,NULL,'2026-08-10 11:05:36');
/*!40000 ALTER TABLE `provider_billing` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `provider_payment_methods`
--

LOCK TABLES `provider_payment_methods` WRITE;
/*!40000 ALTER TABLE `provider_payment_methods` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `provider_payment_methods` (`id`, `provider_id`, `method_type`, `bank_name`, `holder_name`, `id_number`, `phone_number`, `account_number`, `email`, `qr_url`, `is_active`, `created_at`, `updated_at`) VALUES (2,6,'transferencia','Bicentenario ','Jesús Diaz ','18673920','','01029876542345764567','','',1,'2025-09-07 14:45:18','2026-05-28 22:17:12'),
(3,6,'paypal','','Jesús Diaz ','18673920','','','divijeal@gmail.com','',1,'2025-09-07 14:59:01','2026-05-28 22:17:11'),
(4,6,'zelle',NULL,'18673920','18673920',NULL,NULL,'divijeal@gmail.com',NULL,1,'2025-09-07 14:59:31','2026-05-28 22:17:14'),
(6,6,'pago_movil','Bicentenario ','Jesús Diaz ','18673920','04120761886','','','',1,'2026-05-28 21:31:48','2026-05-28 22:17:08'),
(7,10,'pago_movil','Venezuela ','Jesús Diaz ','18673920','04120761886','','','',1,'2026-06-09 00:42:29','2026-06-09 00:42:29'),
(8,12,'pago_movil','Venezuela  (0102)','Jesús Diaz','18673920','04120761886','','','',1,'2026-08-24 09:50:33','2026-08-24 09:50:33');
/*!40000 ALTER TABLE `provider_payment_methods` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `provider_staff`
--

LOCK TABLES `provider_staff` WRITE;
/*!40000 ALTER TABLE `provider_staff` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `provider_staff` (`id`, `provider_id`, `name`, `email`, `phone`, `password`, `role`, `active`, `is_online`, `last_seen`, `last_heartbeat`, `created_at`, `avatar_url`) VALUES (1,6,'María kuica','divijeal@gmail.com','04120767080','$2y$12$Ewhn/aLQoEbMIc0F2aP23.o1cMcFH56UfxbtdwMJ7K1h/7cbvRv6a','staff',0,0,NULL,NULL,'2026-06-13 06:05:12',NULL),
(2,6,'Juan colmenarez','Juancolmenarez@gmail.com','04125048497','$2y$12$z931Yj5WTy3tTlR6YHPmAeM.IQ58wjpnb3EHSlBLqu4/bH9b/5Meq','delivery',1,0,'2026-07-21 08:20:50','2026-07-21 08:20:46','2026-06-14 01:59:34',NULL);
/*!40000 ALTER TABLE `provider_staff` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `requests`
--

LOCK TABLES `requests` WRITE;
/*!40000 ALTER TABLE `requests` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `requests` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `review_helpful`
--

LOCK TABLES `review_helpful` WRITE;
/*!40000 ALTER TABLE `review_helpful` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `review_helpful` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `review_messages`
--

LOCK TABLES `review_messages` WRITE;
/*!40000 ALTER TABLE `review_messages` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `review_messages` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `review_reports`
--

LOCK TABLES `review_reports` WRITE;
/*!40000 ALTER TABLE `review_reports` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `review_reports` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `service_history`
--

LOCK TABLES `service_history` WRITE;
/*!40000 ALTER TABLE `service_history` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `service_history` (`id`, `user_id`, `service_id`, `request_id`, `service_title`, `service_description`, `service_price`, `user_name`, `user_avatar`, `provider_name`, `status`, `payment_status`, `payment_method`, `cancelled_by`, `finished_at`, `provider_id`, `assigned_staff_id`) VALUES (1,2,44,1,'Reparo yo',NULL,15.00,NULL,NULL,'Carlos Bravo','completed','paid','efectivo',NULL,'2026-08-24 08:02:51',12,NULL),
(2,2,44,2,'Reparo yo',NULL,15.00,NULL,NULL,'Carlos Bravo','completed','paid','efectivo',NULL,'2026-08-24 09:29:53',12,NULL),
(3,2,44,3,'Reparo yo',NULL,15.00,NULL,NULL,'Carlos Bravo','completed','paid','efectivo',NULL,'2026-08-24 09:31:05',12,NULL),
(4,2,44,4,'Reparo yo',NULL,15.00,NULL,NULL,'Carlos Bravo','completed','paid','efectivo',NULL,'2026-08-24 09:35:57',12,NULL),
(5,2,44,5,'Reparo yo',NULL,15.00,NULL,NULL,'Carlos Bravo','completed','paid','efectivo',NULL,'2026-08-24 14:07:55',12,NULL),
(6,2,44,6,'Reparo yo',NULL,15.00,NULL,NULL,'Carlos Bravo','completed','paid','efectivo',NULL,'2026-08-24 14:29:15',12,NULL),
(7,2,44,7,'Reparo yo',NULL,15.00,NULL,NULL,'Carlos Bravo','completed','paid','efectivo',NULL,'2026-08-24 15:58:16',12,NULL),
(8,2,44,8,'Reparo yo',NULL,15.00,NULL,NULL,'Carlos Bravo','completed','paid','efectivo',NULL,'2026-08-24 16:00:51',12,NULL),
(9,2,44,9,'Reparo yo',NULL,15.00,NULL,NULL,'Carlos Bravo','completed','paid','efectivo',NULL,'2026-08-24 16:21:27',12,NULL);
/*!40000 ALTER TABLE `service_history` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `service_payment_proofs`
--

LOCK TABLES `service_payment_proofs` WRITE;
/*!40000 ALTER TABLE `service_payment_proofs` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `service_payment_proofs` (`id`, `service_id`, `provider_id`, `amount`, `payment_method`, `reference`, `proof_url`, `payment_type`, `status`, `reviewed_by`, `reviewed_at`, `created_at`) VALUES (1,27,10,5.00,'mercadopago','0987654321','/uploads/payments/service_pay_27_1779542162.jpg',NULL,'rejected',NULL,'2026-05-23 15:26:39','2026-05-23 13:16:02'),
(2,27,10,5.00,'mercadopago','867544555','/uploads/payments/service_pay_27_1779542671.jpg',NULL,'rejected',NULL,'2026-05-23 15:26:46','2026-05-23 13:24:31'),
(3,27,10,5.00,'mercadopago','1234567890','/uploads/payments/service_pay_27_1779543676.jpg',NULL,'rejected',NULL,'2026-05-23 15:26:54','2026-05-23 13:41:16'),
(4,27,10,5.00,'mercadopago','13363747','/uploads/payments/service_pay_27_1779549189.png',NULL,'rejected',NULL,'2026-05-23 15:26:57','2026-05-23 15:13:09'),
(5,28,10,5.00,'mobile_payment','1837377373463','/uploads/payments/service_pay_28_1779551260.jpg',NULL,'approved',NULL,'2026-05-23 15:49:09','2026-05-23 15:47:40'),
(6,29,10,5.00,'mobile_payment','2234567890','/uploads/payments/service_pay_29_1779589388.jpg',NULL,'approved',NULL,'2026-05-24 02:23:49','2026-05-24 02:23:08'),
(7,30,10,5.00,'mobile_payment','1465345677656','/uploads/payments/service_pay_30_1779616027.jpg',NULL,'approved',NULL,'2026-05-24 09:50:20','2026-05-24 09:47:07'),
(8,31,10,5.00,'mobile_payment','123456789',NULL,NULL,'approved',1,'2026-05-24 10:13:16','2026-05-24 10:10:36'),
(9,32,10,5.00,'mobile_payment','123456789','/uploads/payments/service_pay_32_1779617868.jpg',NULL,'approved',1,'2026-05-24 10:18:39','2026-05-24 10:17:48'),
(10,33,10,5.00,'mobile_payment','12345666','/uploads/payments/service_pay_33_1779627131.jpg',NULL,'approved',1,'2026-05-24 12:53:38','2026-05-24 12:52:11'),
(11,34,10,5.00,'mobile_payment','1234567890','/uploads/payments/service_pay_34_1779644459.jpg',NULL,'approved',1,'2026-05-24 17:43:42','2026-05-24 17:40:59'),
(12,36,12,5.00,'mobile_payment','12345768','http://192.168.25.12:8000/uploads/payments/2f24f4be827ab2b6.jpg',NULL,'pending',NULL,NULL,'2026-08-01 20:09:58'),
(13,37,12,5.00,'mobile_payment','27466444646223','http://192.168.25.12:8000/uploads/payments/f6dd9129ebe93d77.jpg',NULL,'pending',NULL,NULL,'2026-08-01 21:38:54'),
(14,41,12,5.00,'mobile_payment','86556775678','http://192.168.25.12:8000/uploads/payments/729f5c21cbece7f0.jpg',NULL,'pending',NULL,NULL,'2026-08-01 22:56:55'),
(15,42,12,5.00,'mobile_payment','8754335677','http://192.168.25.12:8000/uploads/payments/4ed0c6c1416ff476.jpg',NULL,'pending',NULL,NULL,'2026-08-01 23:02:46'),
(16,43,12,5.00,'mobile_payment','576434456','http://192.168.25.12:8000/uploads/payments/c9c992948c5f31b8.jpg',NULL,'approved',1,'2026-08-01 23:11:23','2026-08-01 23:08:28'),
(17,43,12,5.00,'mobile_payment','039347474728','http://192.168.25.12:8000/uploads/payments/bf06ebeb9dd3f1e8.jpg',NULL,'rejected',1,'2026-08-02 06:18:24','2026-08-02 03:53:09'),
(18,43,12,5.00,'mobile_payment','03938484474','http://192.168.25.12:8000/uploads/payments/fb5d6b20bd992c3a.jpg',NULL,'approved',1,'2026-08-02 06:21:13','2026-08-02 06:20:48'),
(19,43,12,5.00,'mobile_payment','Look',NULL,'featured','rejected',1,'2026-08-02 07:11:25','2026-08-02 07:00:24'),
(20,43,12,5.00,'mobile_payment','887776568765',NULL,'featured','rejected',1,'2026-08-02 07:11:28','2026-08-02 07:09:33'),
(21,43,12,5.00,'mobile_payment','84847474',NULL,'featured','rejected',1,'2026-08-02 07:11:31','2026-08-02 07:10:37'),
(22,43,12,5.00,'mobile_payment','999999',NULL,'featured','rejected',1,'2026-08-02 07:17:10','2026-08-02 07:16:52'),
(23,44,12,5.00,'transferencia','',NULL,NULL,'approved',1,'2026-08-02 11:53:31','2026-08-02 11:53:08'),
(25,44,12,5.00,'mobile_payment','4837373',NULL,'featured','rejected',1,'2026-08-02 12:30:02','2026-08-02 12:29:32'),
(26,44,12,5.00,'mobile_payment','838474367373',NULL,'featured','rejected',1,'2026-08-02 12:55:18','2026-08-02 12:54:04'),
(27,44,12,5.00,'mobile_payment','Djdjdj',NULL,'featured','approved',1,'2026-08-02 13:08:46','2026-08-02 13:06:39'),
(28,45,6,5.00,'transferencia','',NULL,NULL,'approved',1,'2026-08-02 15:57:16','2026-08-02 14:22:23');
/*!40000 ALTER TABLE `service_payment_proofs` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `service_requests`
--

LOCK TABLES `service_requests` WRITE;
/*!40000 ALTER TABLE `service_requests` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `service_requests` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `service_reviews`
--

LOCK TABLES `service_reviews` WRITE;
/*!40000 ALTER TABLE `service_reviews` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `service_reviews` (`id`, `service_history_id`, `user_id`, `provider_id`, `rating`, `comment`, `created_at`, `tags`, `photos`, `is_deleted`, `deleted_at`) VALUES (1,7,2,12,4,'','2026-08-24 15:58:57','[\"Profesional\"]','[]',0,NULL),
(2,9,2,12,5,'','2026-08-24 16:21:56','[\"Calidad\",\"Amable\"]','[]',0,NULL);
/*!40000 ALTER TABLE `service_reviews` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `services`
--

LOCK TABLES `services` WRITE;
/*!40000 ALTER TABLE `services` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `services` (`id`, `user_id`, `title`, `description`, `status`, `service_type`, `created_at`, `published_at`, `expires_at`, `notified_expiry`, `notified_featured_expiry`, `price`, `category`, `location`, `image_url`, `provider_name`, `provider_avatar_url`, `provider_rating`, `isAvailable`, `is_featured`, `featured_at`, `featured_expires_at`, `service_details`) VALUES (10,6,'Airline','Viene con nosotros','active','fijo','2025-09-15 03:22:35',NULL,NULL,0,0,35,'Promotora','San felipe',NULL,'María Villegas','avatar_1755532362.jpg',0.0,1,0,NULL,NULL,'A\r\nB\r\nC\r\nD'),
(11,6,'Lavado general','Servicio de lavado completo','active','fijo','2025-12-08 17:00:49',NULL,NULL,0,0,10,'Automóvil','San Felipe',NULL,'María Villegas','avatar_1755532362.jpg',4.0,1,0,NULL,NULL,''),
(12,6,'Lavado general','Servicio de lavado completo','active','fijo','2025-12-08 17:01:45',NULL,NULL,0,0,10,'Automóvil','San Felipe',NULL,'María Villegas','avatar_1755532362.jpg',4.0,1,0,NULL,NULL,''),
(33,10,'Reparación de televisión','Te dije que no te había dicho nada','active','fijo','2026-05-24 12:51:51','2026-05-24 12:53:38','2026-06-23 16:53:38',0,0,15,'Clases','Yaracuy, chivacoa','/uploads/services/service_6a12f4670e6351.50217007.jpg','Angie Gutiérrez',NULL,0.0,1,0,NULL,NULL,'Te dije que no te había dicho nada de eso no te preocupes que no te preocupes que no te preocupes que no te preocupes que'),
(34,10,'Reparación de televisión','Hola tengo un problema en el frontend de','active','fijo','2026-05-24 17:40:28','2026-05-24 17:43:42','2026-06-23 21:43:42',0,0,25,'Reparaciones','Yaracuy, chivacoa','/uploads/services/service_6a13380c55ab85.74203959.jpg','Angie Gutiérrez',NULL,0.0,1,0,NULL,NULL,'Hola tengo un problema en el frontend de la puerta de la calle de'),
(44,12,'Reparo yo','Yo reparo','active','fijo','2026-08-02 11:52:53','2026-08-02 12:30:03','2026-09-01 16:30:02',0,0,15,'Limpieza','Ciudad, Zona','http://192.168.25.12:8000/uploads/services/1e1296e82db849ec.jpg','Carlos Bravo',NULL,0.0,1,1,'2026-08-02 13:08:46','2026-08-09 17:08:46','Djhxbbxn\r\nDjdjdjd\r\nDjdjdjd\r\nZjdjd\r\nZjdjdjd\r\nShdjddj'),
(45,6,'cuenta bloqueada','Vamos hacer un archivo de','active','fijo','2026-08-02 14:21:24','2026-08-02 15:57:16','2026-09-01 19:57:16',0,0,30,'Limpieza','Ciudad, Zona',NULL,'María Villegas','597afbe3297e667b.jpg',3.0,1,0,NULL,NULL,'Jffjfj\r\nFjjfjf\r\nDjhfjf\r\nDhdjfh\r\nDjdjf');
/*!40000 ALTER TABLE `services` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`, `created_at`) VALUES ('363e803adcb2d44fbd8a2435ab7d2ba0b3905f209c9cfc29710f93d2695e2f4e',8,'192.168.25.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','{\"refresh_token\":\"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6OCwicm9sZSI6InByb3ZpZGVyIiwiZXhwIjoxNzg2MzY1NDA0LCJpYXQiOjE3ODU3NjA2MDR9.0YyXgZmBaosHJZlj9jJz3ACIkm4felD1C1xAA3WPAAY\"}',1785761024,'2026-08-03 12:36:44'),
('3db452553330eea9ce1a1294159e1e64af883cbfd673961b1325f2d7e5347b8d',1,'192.168.11.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','{\"refresh_token\":\"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MSwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzg3ODQ4NTU5LCJpYXQiOjE3ODcyNDM3NTl9.WKagftDJolUmg8Tfwxddi_bhkBCNxGDnCqFAIpFXfxw\"}',1787249580,'2026-08-20 16:35:59'),
('6d1a4f1cd09fbce68760d5131b8bbcc3892c9b11d8c92f97b924f46f6284878b',6,'192.168.11.218','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','{\"refresh_token\":\"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Niwicm9sZSI6InByb3ZpZGVyIiwiZXhwIjoxNzg3ODQ4ODkzLCJpYXQiOjE3ODcyNDQwOTN9.7t0CMeK76ibBErMn0IFBlEXzP4g9pDX73TEDYWsfkO8\"}',1787244124,'2026-08-20 16:41:33'),
('8c9a0d0e236888cecb8aefbde384f04e5c34ac4f39d7a739deb5f5d9415e2d44',2,'192.168.5.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','{\"refresh_token\":\"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODgyMDg0NzYsImlhdCI6MTc4NzYwMzY3Nn0.1QSXJvNx4CdHP4vOTgg0-eRopEskVwR7yIKWAKNGCNU\"}',1787606510,'2026-08-24 20:34:36'),
('97a673f96a48be92f7c9aace7c0985e9182cbd918967f95aa461f77251ed94b2',12,'192.168.5.13','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36','{\"refresh_token\":\"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MTIsInJvbGUiOiJwcm92aWRlciIsImV4cCI6MTc4ODE5MTE1OCwiaWF0IjoxNzg3NTg2MzU4fQ.cARvQEgKdd-TkOrEIx6cYuAs6F4E3_WHzuUHQ4tpyXY\"}',1787606557,'2026-08-24 15:45:58');
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `static_pages`
--

LOCK TABLES `static_pages` WRITE;
/*!40000 ALTER TABLE `static_pages` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `static_pages` (`id`, `title`, `slug`, `content`, `meta_title`, `meta_description`, `meta_keywords`, `is_active`, `is_in_menu`, `sort_order`, `created_at`, `updated_at`) VALUES (1,'Términos y Condiciones','terms','<div style=\"max-width:800px;margin:0 auto;font-family:\'Inter\',sans-serif;color:#2d3748;line-height:1.8\">\n\n  <div style=\"background:linear-gradient(135deg,#667eea,#764ba2);color:white;padding:30px;border-radius:16px;margin-bottom:30px;text-align:center\">\n    <span style=\"font-size:48px\">📋</span>\n    <h1 style=\"margin:12px 0 0;font-size:2rem\">Términos y Condiciones de Uso</h1>\n    <p style=\"opacity:0.9;margin:8px 0 0\">Última actualización: Julio 2026</p>\n  </div>\n\n  <div style=\"background:#f7fafc;padding:20px;border-radius:12px;margin-bottom:20px;border-left:4px solid #667eea\">\n    <p style=\"margin:0;font-weight:500\">📌 Al acceder y utilizar TapClic, aceptas los siguientes términos y condiciones. Te recomendamos leerlos detenidamente antes de usar nuestros servicios.</p>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#667eea;font-size:1.3rem;margin-top:0\">1. Definiciones</h2>\n    <p><strong>Plataforma:</strong> TapClic, aplicación web y móvil que conecta clientes con proveedores de servicios.</p>\n    <p><strong>Usuario:</strong> Toda persona natural o jurídica que se registra y utiliza la Plataforma.</p>\n    <p><strong>Cliente:</strong> Usuario que solicita y contrata servicios a través de la Plataforma.</p>\n    <p><strong>Proveedor:</strong> Usuario que ofrece y presta servicios profesionales a través de la Plataforma.</p>\n    <p><strong>Repartidor:</strong> Personal autorizado por un Proveedor para realizar entregas físicas.</p>\n    <p><strong>Servicio:</strong> Cualquier actividad profesional ofrecida por un Proveedor a través de la Plataforma.</p>\n    <p><strong>Wallet:</strong> Billetera digital integrada para gestionar pagos, recargas y transferencias.</p>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#667eea;font-size:1.3rem;margin-top:0\">2. Aceptación de los Términos</h2>\n    <p>Al registrarte, acceder o utilizar TapClic, manifiestas tu aceptación expresa e inequívoca de estos Términos y Condiciones. Si no estás de acuerdo con alguna parte, debes abstenerte de usar la Plataforma.</p>\n    <p>Nos reservamos el derecho de modificar estos términos en cualquier momento. Los cambios entrarán en vigor inmediatamente después de su publicación. El uso continuado de la Plataforma constituye la aceptación de los términos modificados.</p>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#667eea;font-size:1.3rem;margin-top:0\">3. Descripción del Servicio</h2>\n    <p>TapClic es una plataforma tecnológica de intermediación que:</p>\n    <ul style=\"padding-left:20px\">\n      <li>Facilita la conexión entre Clientes y Proveedores de servicios</li>\n      <li>Proporciona un sistema de chat en tiempo real para comunicación</li>\n      <li>Ofrece una billetera digital (Wallet) para gestión de pagos</li>\n      <li>Permite el seguimiento de servicios y entregas en tiempo real</li>\n      <li>Procesa pagos a través de métodos autorizados (transferencia, Zelle, PayPal, pago móvil)</li>\n      <li>NO es responsable directo por la calidad, seguridad o legalidad de los servicios prestados por los Proveedores</li>\n    </ul>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#667eea;font-size:1.3rem;margin-top:0\">4. Registro y Cuentas de Usuario</h2>\n    <p><strong>4.1 Elegibilidad:</strong> Debes ser mayor de 18 años y tener capacidad legal para contratar.</p>\n    <p><strong>4.2 Datos verdaderos:</strong> Te comprometes a proporcionar información precisa, actualizada y completa durante el registro.</p>\n    <p><strong>4.3 Confidencialidad:</strong> Eres responsable de mantener la seguridad de tu contraseña. Notifica inmediatamente cualquier uso no autorizado de tu cuenta.</p>\n    <p><strong>4.4 Una cuenta por persona:</strong> No está permitido crear múltiples cuentas. TapClic se reserva el derecho de suspender cuentas duplicadas.</p>\n    <p><strong>4.5 Verificación:</strong> Podremos solicitar verificación de identidad para Proveedores, incluyendo documentos de identificación y comprobantes de domicilio.</p>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#667eea;font-size:1.3rem;margin-top:0\">5. Roles y Responsabilidades</h2>\n    <p><strong>5.1 Clientes:</strong></p>\n    <ul style=\"padding-left:20px\">\n      <li>Proporcionar información precisa sobre el servicio requerido</li>\n      <li>Respetar los acuerdos de precio y tiempo pactados con el Proveedor</li>\n      <li>Realizar los pagos a través de los métodos autorizados por la Plataforma</li>\n      <li>Calificar honestamente el servicio recibido</li>\n      <li>No contactar a Proveedores fuera de la Plataforma para evadir comisiones</li>\n    </ul>\n    <p><strong>5.2 Proveedores:</strong></p>\n    <ul style=\"padding-left:20px\">\n      <li>Ofrecer servicios de calidad profesional con descripciones precisas</li>\n      <li>Cumplir con los tiempos y precios acordados con el Cliente</li>\n      <li>Mantener actualizada su disponibilidad y datos de contacto</li>\n      <li>Responder oportunamente a las solicitudes y mensajes</li>\n      <li>No solicitar pagos por fuera de la Plataforma</li>\n      <li>Ser responsable por la calidad y seguridad del servicio prestado</li>\n    </ul>\n    <p><strong>5.3 Repartidores (Staff):</strong></p>\n    <ul style=\"padding-left:20px\">\n      <li>Cumplir con las rutas y tiempos de entrega asignados</li>\n      <li>Mantener actualizado el estado del delivery en la Plataforma</li>\n      <li>Tratar con respeto a Clientes y Proveedores</li>\n    </ul>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#667eea;font-size:1.3rem;margin-top:0\">6. Pagos, Comisiones y Wallet</h2>\n    <p><strong>6.1 Métodos de pago:</strong> La Plataforma acepta transferencia bancaria, Zelle, PayPal, pago móvil y otros métodos disponibles en tu región.</p>\n    <p><strong>6.2 Comisiones:</strong> TapClic cobra una comisión por cada transacción completada. El porcentaje es visible antes de confirmar el pago.</p>\n    <p><strong>6.3 Publicación de servicios:</strong> Los Proveedores pueden publicar servicios de forma gratuita. La publicación destacada puede tener un costo adicional.</p>\n    <p><strong>6.4 Wallet:</strong> La billetera digital permite recargar saldo, pagar servicios y recibir pagos. Los fondos están sujetos a verificación.</p>\n    <p><strong>6.5 Reembolsos:</strong> Las solicitudes de reembolso se evaluarán caso por caso según la política de cancelación acordada.</p>\n    <p><strong>6.6 Facturación:</strong> Los Proveedores recibirán facturación periódica por las comisiones de la Plataforma.</p>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#667eea;font-size:1.3rem;margin-top:0\">7. Cancelaciones y Reembolsos</h2>\n    <p><strong>7.1 Por el Cliente:</strong> Puedes cancelar una solicitud antes de que el Proveedor la acepte sin penalización. Después de aceptada, aplican las políticas de cancelación del Proveedor.</p>\n    <p><strong>7.2 Por el Proveedor:</strong> Si cancelas un servicio ya aceptado sin causa justificada, tu calificación puede verse afectada y podrías estar sujeto a penalizaciones.</p>\n    <p><strong>7.3 Reembolsos:</strong> Se procesarán según el método de pago original en un plazo de 5 a 15 días hábiles.</p>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#667eea;font-size:1.3rem;margin-top:0\">8. Calificaciones y Reseñas</h2>\n    <p>Los Clientes pueden calificar y dejar reseñas después de completar un servicio. Las reseñas deben ser honestas y basadas en la experiencia real. TapClic se reserva el derecho de eliminar reseñas falsas, ofensivas o que violen estos términos.</p>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#667eea;font-size:1.3rem;margin-top:0\">9. Conducta Prohibida</h2>\n    <p>Está estrictamente prohibido:</p>\n    <ul style=\"padding-left:20px\">\n      <li>Usar la Plataforma para actividades ilegales o fraudulentas</li>\n      <li>Contactar a usuarios fuera de la Plataforma para evadir comisiones</li>\n      <li>Publicar contenido falso, engañoso, ofensivo o difamatorio</li>\n      <li>Suplantar la identidad de otra persona o entidad</li>\n      <li>Intentar hackear, descompilar o realizar ingeniería inversa de la Plataforma</li>\n      <li>Usar bots, scrapers o herramientas automatizadas sin autorización</li>\n      <li>Acosar, intimidar o discriminar a otros usuarios</li>\n    </ul>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#667eea;font-size:1.3rem;margin-top:0\">10. Propiedad Intelectual</h2>\n    <p>TapClic, su logotipo, diseño, código fuente y contenido son propiedad exclusiva de TapClic. No se permite la reproducción, distribución o modificación sin autorización expresa.</p>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#667eea;font-size:1.3rem;margin-top:0\">11. Limitación de Responsabilidad</h2>\n    <div style=\"background:#fff5f5;border:2px solid #fc8181;padding:20px;border-radius:12px;margin-bottom:20px\">\n      <h2 style=\"color:#c53030;font-size:1.2rem;margin-top:0;text-transform:uppercase\">⚠️ EXONERACIÓN DE RESPONSABILIDAD POR PAGOS EXTERNOS</h2>\n      <p style=\"font-weight:bold;color:#c53030\">NUESTRA PLATAFORMA ES EXCLUSIVAMENTE UN DIRECTORIO DE CONTACTO ENTRE CLIENTES Y PROVEEDORES. LA PLATAFORMA NO PROCESA, RETIENE, NI INTERMEDIA EN LOS PAGOS REALIZADOS FUERA DEL SISTEMA DE WALLET INTEGRADO. CUALQUIER TRANSACCIÓN REALIZADA A TRAVÉS DE PAGO MÓVIL, ZELLE, BINANCE, TRANSFERENCIA BANCARIA DIRECTA U OTRO MEDIO EXTERNO OCURRE BAJO LA TOTAL RESPONSABILIDAD DE LAS PARTES INVOLUCRADAS. LA PLATAFORMA NO SE HACE RESPONSABLE POR ESTAFAS, FRAUDES, REVERSIONES DE PAGO, DISPUTAS COMERCIALES O PÉRDIDAS FINANCIERAS ENTRE USUARIOS.</p>\n      <p style=\"margin-bottom:0\"><strong>ADVERTENCIA:</strong> Si un usuario te solicita realizar un pago fuera de la Plataforma, reporta inmediatamente. No compartas tus datos de pago con desconocidos.</p>\n    </div>\n\n    <p>TapClic actúa como intermediario tecnológico. No somos responsables por:</p>\n    <ul style=\"padding-left:20px\">\n      <li>La calidad, seguridad o legalidad de los servicios prestados por Proveedores</li>\n      <li>Daños directos o indirectos derivados del uso de la Plataforma</li>\n      <li>Pérdida de datos, ingresos o oportunidades de negocio</li>\n      <li>Conflictos entre Clientes y Proveedores (aunque ofrecemos mediación)</li>\n    </ul>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#667eea;font-size:1.3rem;margin-top:0\">12. Suspensión y Terminación</h2>\n    <p>TapClic se reserva el derecho de suspender o cancelar cuentas que violen estos términos, sin previo aviso y sin responsabilidad para la Plataforma.</p>\n    <p>Puedes dar de baja tu cuenta en cualquier momento desde la configuración de perfil. Los datos se conservarán según lo establecido en la Política de Privacidad.</p>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#667eea;font-size:1.3rem;margin-top:0\">13. Ley Aplicable y Jurisdicción</h2>\n    <p>Estos términos se rigen por las leyes de la República Bolivariana de Venezuela. Cualquier disputa será resuelta ante los tribunales competentes de la ciudad de Caracas.</p>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#667eea;font-size:1.3rem;margin-top:0\">14. Contacto</h2>\n    <p>Para dudas, reclamos o sugerencias sobre estos Términos y Condiciones:</p>\n    <ul style=\"padding-left:20px\">\n      <li>📧 Email: <strong>soporte@tapclic.com</strong></li>\n      <li>📞 Teléfono: <strong>+58 412-5048497</strong></li>\n      <li>💬 Chat de soporte en la Plataforma</li>\n    </ul>\n  </div>\n\n  <div style=\"background:linear-gradient(135deg,#667eea,#764ba2);color:white;padding:24px;border-radius:12px;text-align:center\">\n    <p style=\"margin:0;font-size:1.1rem\">✅ Al usar TapClic, confirmas que has leído y aceptas estos Términos y Condiciones.</p>\n  </div>\n\n</div>','Términos y Condiciones - TapClic','Términos y condiciones de uso de la plataforma TapClic',NULL,1,1,1,'2026-02-01 01:35:00','2026-08-26 21:29:27'),
(2,'Política de Privacidad','privacy','<div style=\"max-width:800px;margin:0 auto;font-family:\'Inter\',sans-serif;color:#2d3748;line-height:1.8\">\n\n  <div style=\"background:linear-gradient(135deg,#0ea5e9,#3b82f6);color:white;padding:30px;border-radius:16px;margin-bottom:30px;text-align:center\">\n    <span style=\"font-size:48px\">🔒</span>\n    <h1 style=\"margin:12px 0 0;font-size:2rem\">Política de Privacidad</h1>\n    <p style=\"opacity:0.9;margin:8px 0 0\">Última actualización: Julio 2026</p>\n  </div>\n\n  <div style=\"background:#f0fdf4;padding:20px;border-radius:12px;margin-bottom:20px;border-left:4px solid #22c55e\">\n    <p style=\"margin:0;font-weight:500\">✅ En TapClic nos tomamos muy en serio la privacidad y protección de tus datos personales. Esta política explica qué datos recopilamos, cómo los usamos y qué derechos tienes sobre ellos.</p>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#0ea5e9;font-size:1.3rem;margin-top:0\">1. Responsable del Tratamiento</h2>\n    <p><strong>Razón Social:</strong> TapClic</p>\n    <p><strong>Email de contacto:</strong> privacidad@tapclic.com</p>\n    <p><strong>Teléfono:</strong> +58 412-5048497</p>\n    <p><strong>Sitio web:</strong> https://tapclic.com</p>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#0ea5e9;font-size:1.3rem;margin-top:0\">2. Datos que Recopilamos</h2>\n    <p><strong>2.1 Datos de registro:</strong></p>\n    <ul style=\"padding-left:20px\">\n      <li>Nombre completo</li>\n      <li>Correo electrónico</li>\n      <li>Número de teléfono</li>\n      <li>Contraseña (encriptada, nunca almacenada en texto plano)</li>\n      <li>Rol dentro de la Plataforma (Cliente, Proveedor)</li>\n    </ul>\n    <p><strong>2.2 Datos de perfil:</strong></p>\n    <ul style=\"padding-left:20px\">\n      <li>Foto de perfil / Avatar</li>\n      <li>Dirección personal y/o fiscal</li>\n      <li>Categorías de servicio (Proveedores)</li>\n      <li>Área de cobertura geográfica</li>\n      <li>Biografía y redes sociales (opcional)</li>\n    </ul>\n    <p><strong>2.3 Datos de uso de la Plataforma:</strong></p>\n    <ul style=\"padding-left:20px\">\n      <li>Servicios solicitados y contratados</li>\n      <li>Historial de transacciones y pagos</li>\n      <li>Mensajes de chat con otros usuarios</li>\n      <li>Calificaciones y reseñas realizadas</li>\n      <li>Dirección IP y tipo de dispositivo</li>\n      <li>Páginas visitadas y acciones dentro de la Plataforma</li>\n    </ul>\n    <p><strong>2.4 Datos de ubicación:</strong></p>\n    <ul style=\"padding-left:20px\">\n      <li>Ubicación aproximada para servicios que requieren geolocalización (solo con tu permiso)</li>\n      <li>Seguimiento de entregas en tiempo real (Repartidores, solo durante el servicio activo)</li>\n    </ul>\n    <p><strong>2.5 Datos de pago:</strong></p>\n    <ul style=\"padding-left:20px\">\n      <li>Método de pago seleccionado (no almacenamos datos completos de tarjetas)</li>\n      <li>Historial de transacciones en la Wallet</li>\n      <li>Comprobantes de pago subidos para verificación</li>\n    </ul>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#0ea5e9;font-size:1.3rem;margin-top:0\">3. Finalidad del Tratamiento</h2>\n    <p>Utilizamos tus datos para las siguientes finalidades:</p>\n    <ul style=\"padding-left:20px\">\n      <li><strong>Prestación del servicio:</strong> Conectarte con Proveedores, procesar pagos, facilitar el chat en tiempo real</li>\n      <li><strong>Gestión de cuenta:</strong> Autenticación, recuperación de contraseña, notificaciones del sistema</li>\n      <li><strong>Wallet y pagos:</strong> Gestionar recargas, transferencias y pagos entre usuarios</li>\n      <li><strong>Comunicación:</strong> Enviar notificaciones sobre solicitudes, mensajes y actualizaciones de servicios</li>\n      <li><strong>Mejora del servicio:</strong> Analizar el uso de la Plataforma para optimizar la experiencia</li>\n      <li><strong>Soporte técnico:</strong> Atender tickets, reclamos y solicitudes de ayuda</li>\n      <li><strong>Cumplimiento legal:</strong> Responder a requerimientos de autoridades competentes</li>\n      <li><strong>Marketing:</strong> Enviar promociones y ofertas (solo con tu consentimiento explícito)</li>\n    </ul>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#0ea5e9;font-size:1.3rem;margin-top:0\">4. Base Legal del Tratamiento</h2>\n    <p>El tratamiento de tus datos se basa en:</p>\n    <ul style=\"padding-left:20px\">\n      <li><strong>Ejecución del contrato:</strong> Datos necesarios para prestarte el servicio de intermediación</li>\n      <li><strong>Consentimiento explícito:</strong> Para comunicaciones de marketing, geolocalización y cookies no esenciales</li>\n      <li><strong>Interés legítimo:</strong> Mejora de la Plataforma, prevención de fraude, seguridad</li>\n      <li><strong>Obligación legal:</strong> Facturación, requerimientos judiciales, prevención de lavado de dinero</li>\n    </ul>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#0ea5e9;font-size:1.3rem;margin-top:0\">5. Medidas de Seguridad</h2>\n    <p>Implementamos medidas técnicas y organizativas para proteger tus datos:</p>\n    <ul style=\"padding-left:20px\">\n      <li>🔐 <strong>Cifrado SSL/TLS:</strong> Todas las comunicaciones entre tu navegador y nuestros servidores están encriptadas</li>\n      <li>🔑 <strong>Contraseñas hasheadas:</strong> Usamos bcrypt con salt para almacenar contraseñas (nunca en texto plano)</li>\n      <li>🛡️ <strong>Autenticación JWT:</strong> Tokens de acceso con expiración para sesiones seguras</li>\n      <li>🚫 <strong>Rate limiting:</strong> Protección contra ataques de fuerza bruta y denegación de servicio</li>\n      <li>📋 <strong>Auditoría:</strong> Registro de accesos y acciones en el sistema</li>\n      <li>🔄 <strong>Backups periódicos:</strong> Respaldos automáticos para recuperación ante desastres</li>\n      <li>👥 <strong>Acceso restringido:</strong> Solo personal autorizado accede a datos sensibles</li>\n    </ul>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#0ea5e9;font-size:1.3rem;margin-top:0\">6. Conservación de Datos</h2>\n    <p>Conservamos tus datos personales durante el tiempo que mantengas tu cuenta activa. Al darte de baja:</p>\n    <ul style=\"padding-left:20px\">\n      <li>Datos de perfil: Eliminados o anonimizados en 30 días</li>\n      <li>Historial de transacciones: Conservado por 5 años (obligación legal/fiscal)</li>\n      <li>Mensajes de chat: Eliminados en 90 días</li>\n      <li>Calificaciones: Anonimizadas pero conservadas para integridad del sistema</li>\n    </ul>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#0ea5e9;font-size:1.3rem;margin-top:0\">7. Compartición de Datos con Terceros</h2>\n    <p><strong>No vendemos tus datos personales.</strong> Solo compartimos información en estos casos:</p>\n    <ul style=\"padding-left:20px\">\n      <li><strong>Proveedores de servicios:</strong> Datos necesarios para completar el servicio solicitado (nombre, ubicación, contacto)</li>\n      <li><strong>Procesadores de pago:</strong> Información de transacciones para procesar pagos (PayPal, Zelle, etc.)</li>\n      <li><strong>Autoridades legales:</strong> Cuando sea requerido por ley u orden judicial</li>\n      <li><strong>Servicios de hosting y base de datos:</strong> Datos almacenados en servidores seguros</li>\n    </ul>\n    <p>Todos los terceros con los que compartimos datos están obligados contractualmente a proteger tu información con estándares equivalentes a esta política.</p>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#0ea5e9;font-size:1.3rem;margin-top:0\">8. Transferencias Internacionales</h2>\n    <p>Tus datos pueden ser almacenados en servidores ubicados dentro y fuera de Venezuela. En todos los casos, aseguramos un nivel adecuado de protección conforme a los estándares internacionales de seguridad de datos.</p>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#0ea5e9;font-size:1.3rem;margin-top:0\">9. Cookies y Tecnologías Similares</h2>\n    <p><strong>9.1 Cookies esenciales:</strong> Necesarias para el funcionamiento de la Plataforma (sesión, seguridad, carrito). No requieren consentimiento.</p>\n    <p><strong>9.2 Cookies de análisis:</strong> Nos ayudan a entender cómo usas la Plataforma para mejorarla. Puedes desactivarlas.</p>\n    <p><strong>9.3 Cookies de marketing:</strong> Utilizadas para mostrar promociones relevantes. Solo se activan con tu consentimiento.</p>\n    <p>Puedes gestionar tus preferencias de cookies desde la configuración de tu navegador.</p>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#0ea5e9;font-size:1.3rem;margin-top:0\">10. Chat y Mensajería en Tiempo Real</h2>\n    <p>Los mensajes enviados a través del chat de TapClic se transmiten encriptados mediante WebSocket seguro (WSS). Los mensajes se almacenan temporalmente para su entrega y se conservan en tu historial de conversaciones hasta que elimines tu cuenta.</p>\n    <p>No accedemos al contenido de tus conversaciones privadas, excepto cuando sea necesario para:</p>\n    <ul style=\"padding-left:20px\">\n      <li>Investigar reportes de abuso o violación de términos</li>\n      <li>Cumplir con requerimientos legales</li>\n      <li>Resolver problemas técnicos</li>\n    </ul>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#0ea5e9;font-size:1.3rem;margin-top:0\">11. Geolocalización</h2>\n    <p>Solicitamos acceso a tu ubicación solo cuando es necesario para:</p>\n    <ul style=\"padding-left:20px\">\n      <li>Servicios que requieren presencia física (domicilio, reparaciones)</li>\n      <li>Seguimiento de entregas en tiempo real (Repartidores)</li>\n      <li>Mostrar servicios cercanos a tu ubicación</li>\n    </ul>\n    <p>Puedes denegar el acceso a tu ubicación en cualquier momento desde los ajustes de tu dispositivo. La Plataforma seguirá funcionando, pero algunas funciones podrían no estar disponibles.</p>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#0ea5e9;font-size:1.3rem;margin-top:0\">12. Notificaciones Push</h2>\n    <p>Podemos enviarte notificaciones push a tu navegador o dispositivo móvil sobre:</p>\n    <ul style=\"padding-left:20px\">\n      <li>Nuevas solicitudes de servicio</li>\n      <li>Mensajes de chat no leídos</li>\n      <li>Actualizaciones de estado de servicios</li>\n      <li>Promociones y ofertas (opcional)</li>\n    </ul>\n    <p>Puedes desactivar las notificaciones push en cualquier momento desde la configuración de la Plataforma o de tu dispositivo.</p>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#0ea5e9;font-size:1.3rem;margin-top:0\">13. Derechos del Usuario (ARCO)</h2>\n    <p>Tienes los siguientes derechos sobre tus datos personales:</p>\n    <ul style=\"padding-left:20px\">\n      <li>🔍 <strong>Acceso:</strong> Solicitar una copia de los datos que tenemos sobre ti</li>\n      <li>✏️ <strong>Rectificación:</strong> Corregir datos inexactos o incompletos</li>\n      <li>❌ <strong>Cancelación:</strong> Solicitar la eliminación de tus datos (cuando ya no sean necesarios)</li>\n      <li>🚫 <strong>Oposición:</strong> Oponerte al tratamiento de tus datos para fines específicos</li>\n      <li>📤 <strong>Portabilidad:</strong> Recibir tus datos en un formato estructurado y transferirlos a otro responsable</li>\n    </ul>\n    <p>Para ejercer tus derechos ARCO, envía un email a <strong>privacidad@tapclic.com</strong> con el asunto \"Solicitud ARCO\". Responderemos en un plazo máximo de 15 días hábiles.</p>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#0ea5e9;font-size:1.3rem;margin-top:0\">14. Menores de Edad</h2>\n    <p>TapClic no está dirigido a menores de 18 años. No recopilamos intencionalmente datos de menores. Si eres padre/madre y crees que tu hijo nos ha proporcionado datos, contáctanos para eliminarlos.</p>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#0ea5e9;font-size:1.3rem;margin-top:0\">15. Cambios en esta Política</h2>\n    <p>Podemos actualizar esta Política de Privacidad periódicamente. Te notificaremos sobre cambios significativos a través de:</p>\n    <ul style=\"padding-left:20px\">\n      <li>Un aviso en la Plataforma</li>\n      <li>Un email a la dirección registrada</li>\n      <li>La fecha de \"Última actualización\" al inicio de esta página</li>\n    </ul>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#0ea5e9;font-size:1.3rem;margin-top:0\">16. Contacto</h2>\n    <p>Para cualquier duda, reclamo o solicitud sobre esta Política de Privacidad:</p>\n    <ul style=\"padding-left:20px\">\n      <li>📧 <strong>Email:</strong> privacidad@tapclic.com</li>\n      <li>📞 <strong>Teléfono:</strong> +58 412-5048497</li>\n      <li>💬 <strong>Chat de soporte:</strong> Disponible en la Plataforma</li>\n    </ul>\n  </div>\n\n  <div style=\"background:linear-gradient(135deg,#0ea5e9,#3b82f6);color:white;padding:24px;border-radius:12px;text-align:center\">\n    <p style=\"margin:0;font-size:1.1rem\">🔒 Tus datos están protegidos. Tu confianza es nuestra prioridad.</p>\n  </div>\n\n</div>','Política de Privacidad - TapClic','Política de privacidad y protección de datos personales de TapClic. Conoce cómo recopilamos, usamos y protegemos tu información.',NULL,1,1,2,'2026-02-01 01:35:00','2026-07-28 12:11:16'),
(3,'Acerca de Nosotros','about','<div style=\"max-width:800px;margin:0 auto;font-family:\'Inter\',sans-serif;color:#2d3748;line-height:1.8\">\n  \n  <div style=\"background:linear-gradient(135deg,#8b5cf6,#a855f7);color:white;padding:30px;border-radius:16px;margin-bottom:30px;text-align:center\">\n    <span style=\"font-size:48px\">🚀</span>\n    <h1 style=\"margin:12px 0 0;font-size:2rem\">Acerca de TapClic</h1>\n    <p style=\"opacity:0.9;margin:8px 0 0\">Conectando personas, simplificando servicios</p>\n  </div>\n\n  <div style=\"background:white;padding:30px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px;text-align:center\">\n    <h2 style=\"color:#8b5cf6;font-size:1.6rem;margin-top:0\">✨ Nuestra Misión</h2>\n    <p style=\"font-size:1.15rem\">Simplificar la conexión entre clientes y proveedores de servicios, creando una plataforma confiable, rápida y segura donde todos ganan.</p>\n  </div>\n\n  <div style=\"display:grid;grid-template-columns:1fr 1fr;gap:20px;margin-bottom:20px\">\n    <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);text-align:center\">\n      <span style=\"font-size:40px\">👥</span>\n      <h3 style=\"color:#8b5cf6;margin:8px 0\">Para Clientes</h3>\n      <p style=\"margin:0\">Encuentra el servicio que necesitas en segundos. Compara, contrata y paga de forma segura.</p>\n    </div>\n    <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);text-align:center\">\n      <span style=\"font-size:40px\">🛠️</span>\n      <h3 style=\"color:#8b5cf6;margin:8px 0\">Para Proveedores</h3>\n      <p style=\"margin:0\">Haz crecer tu negocio. Publica tus servicios, recibe clientes y genera ingresos.</p>\n    </div>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#8b5cf6;font-size:1.4rem;margin-top:0;text-align:center\">⚡ ¿Cómo Funciona?</h2>\n    <div style=\"display:flex;justify-content:space-around;flex-wrap:wrap;gap:16px;margin-top:16px\">\n      <div style=\"text-align:center;flex:1;min-width:120px\">\n        <div style=\"background:#f3e8ff;width:60px;height:60px;border-radius:50%;display:flex;align-items:center;justify-content:center;margin:0 auto 8px;font-size:24px\">1️⃣</div>\n        <p style=\"font-weight:600;margin:4px 0\">Publica</p>\n        <p style=\"font-size:13px;color:#64748b\">Tu servicio o necesidad</p>\n      </div>\n      <div style=\"text-align:center;flex:1;min-width:120px\">\n        <div style=\"background:#f3e8ff;width:60px;height:60px;border-radius:50%;display:flex;align-items:center;justify-content:center;margin:0 auto 8px;font-size:24px\">2️⃣</div>\n        <p style=\"font-weight:600;margin:4px 0\">Conecta</p>\n        <p style=\"font-size:13px;color:#64748b\">Con la persona ideal</p>\n      </div>\n      <div style=\"text-align:center;flex:1;min-width:120px\">\n        <div style=\"background:#f3e8ff;width:60px;height:60px;border-radius:50%;display:flex;align-items:center;justify-content:center;margin:0 auto 8px;font-size:24px\">3️⃣</div>\n        <p style=\"font-weight:600;margin:4px 0\">Acuerda</p>\n        <p style=\"font-size:13px;color:#64748b\">Detalles y pago seguro</p>\n      </div>\n      <div style=\"text-align:center;flex:1;min-width:120px\">\n        <div style=\"background:#f3e8ff;width:60px;height:60px;border-radius:50%;display:flex;align-items:center;justify-content:center;margin:0 auto 8px;font-size:24px\">4️⃣</div>\n        <p style=\"font-weight:600;margin:4px 0\">Califica</p>\n        <p style=\"font-size:13px;color:#64748b\">Tu experiencia</p>\n      </div>\n    </div>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#8b5cf6;font-size:1.4rem;margin-top:0;text-align:center\">💎 Nuestros Valores</h2>\n    <div style=\"display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-top:16px\">\n      <div style=\"background:#faf5ff;padding:16px;border-radius:8px;text-align:center\">🤝 <strong>Confianza</strong></div>\n      <div style=\"background:#faf5ff;padding:16px;border-radius:8px;text-align:center\">🔍 <strong>Transparencia</strong></div>\n      <div style=\"background:#faf5ff;padding:16px;border-radius:8px;text-align:center\">⭐ <strong>Calidad</strong></div>\n      <div style=\"background:#faf5ff;padding:16px;border-radius:8px;text-align:center\">💜 <strong>Comunidad</strong></div>\n    </div>\n  </div>\n\n  <div style=\"background:linear-gradient(135deg,#8b5cf6,#a855f7);color:white;padding:24px;border-radius:12px;text-align:center\">\n    <p style=\"margin:0;font-size:1.1rem\">🌟 Únete a nuestra comunidad en crecimiento</p>\n  </div>\n\n</div>','Acerca de Nosotros - TapClic','Conoce más sobre TapClic, la plataforma que conecta clientes con proveedores de servicios',NULL,1,1,3,'2026-02-01 01:35:00','2026-05-27 17:28:07'),
(4,'Ayuda y Soporte','help','<div style=\"max-width:800px;margin:0 auto;font-family:\'Inter\',sans-serif;color:#2d3748;line-height:1.8\">\n  \n  <div style=\"background:linear-gradient(135deg,#f59e0b,#f97316);color:white;padding:30px;border-radius:16px;margin-bottom:30px;text-align:center\">\n    <span style=\"font-size:48px\">💡</span>\n    <h1 style=\"margin:12px 0 0;font-size:2rem\">Ayuda y Soporte</h1>\n    <p style=\"opacity:0.9;margin:8px 0 0\">Estamos aquí para ayudarte</p>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#f59e0b;font-size:1.4rem;margin-top:0;display:flex;align-items:center;gap:8px\">🙋 1. Para Clientes</h2>\n    \n    <div style=\"background:#fffbeb;padding:16px;border-radius:8px;margin-bottom:12px\">\n      <p style=\"font-weight:600;margin:0 0 4px\">📌 ¿Cómo solicito un servicio?</p>\n      <p style=\"margin:0;font-size:14px\">Explora los servicios disponibles, elige el que necesitas y haz clic en \"Solicitar Servicio\". El proveedor recibirá tu solicitud al instante.</p>\n    </div>\n    \n    <div style=\"background:#fffbeb;padding:16px;border-radius:8px;margin-bottom:12px\">\n      <p style=\"font-weight:600;margin:0 0 4px\">💳 ¿Cómo pago?</p>\n      <p style=\"margin:0;font-size:14px\">Aceptamos transferencia bancaria, pago móvil, Zelle y PayPal. Elige tu método preferido al confirmar el servicio.</p>\n    </div>\n    \n    <div style=\"background:#fffbeb;padding:16px;border-radius:8px;margin-bottom:12px\">\n      <p style=\"font-weight:600;margin:0 0 4px\">❌ ¿Puedo cancelar?</p>\n      <p style=\"margin:0;font-size:14px\">Sí, puedes cancelar antes de que el proveedor confirme. Revisa nuestra política de cancelación para más detalles.</p>\n    </div>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#f59e0b;font-size:1.4rem;margin-top:0;display:flex;align-items:center;gap:8px\">🛠️ 2. Para Proveedores</h2>\n    \n    <div style=\"background:#fffbeb;padding:16px;border-radius:8px;margin-bottom:12px\">\n      <p style=\"font-weight:600;margin:0 0 4px\">📝 ¿Cómo me registro como proveedor?</p>\n      <p style=\"margin:0;font-size:14px\">Regístrate normalmente y completa tu perfil de proveedor con tus datos, servicios ofrecidos y métodos de pago.</p>\n    </div>\n    \n    <div style=\"background:#fffbeb;padding:16px;border-radius:8px;margin-bottom:12px\">\n      <p style=\"font-weight:600;margin:0 0 4px\">💰 ¿Cómo recibo mis pagos?</p>\n      <p style=\"margin:0;font-size:14px\">Los pagos se procesan a través de la plataforma. Configura tus métodos de cobro en tu panel de proveedor.</p>\n    </div>\n  </div>\n\n  <div style=\"background:linear-gradient(135deg,#f59e0b,#f97316);color:white;padding:24px;border-radius:12px;margin-bottom:20px\">\n    <h2 style=\"margin-top:0;text-align:center\">📞 Contacto Directo</h2>\n    <div style=\"display:grid;grid-template-columns:1fr 1fr 1fr;gap:16px;margin-top:16px;text-align:center\">\n      <div>\n        <span style=\"font-size:28px\">📧</span>\n        <p style=\"margin:4px 0;font-weight:600\">Email</p>\n        <p style=\"margin:0;font-size:14px\">soporte@tapclic.com</p>\n      </div>\n      <div>\n        <span style=\"font-size:28px\">📱</span>\n        <p style=\"margin:4px 0;font-weight:600\">WhatsApp</p>\n        <p style=\"margin:0;font-size:14px\">+58 412-0000000</p>\n      </div>\n      <div>\n        <span style=\"font-size:28px\">💬</span>\n        <p style=\"margin:4px 0;font-weight:600\">Chat en vivo</p>\n        <p style=\"margin:0;font-size:14px\">En la plataforma</p>\n      </div>\n    </div>\n  </div>\n\n</div>','Ayuda y Soporte - TapClic','Centro de ayuda y soporte de TapClic. Encuentra respuestas y contacta con nosotros',NULL,1,0,4,'2026-02-01 01:35:00','2026-05-27 17:49:22'),
(5,'Contacto','contact','<div style=\"max-width:800px;margin:0 auto;font-family:\'Inter\',sans-serif;color:#2d3748;line-height:1.8\">\n  \n  <div style=\"background:linear-gradient(135deg,#10b981,#059669);color:white;padding:30px;border-radius:16px;margin-bottom:30px;text-align:center\">\n    <span style=\"font-size:48px\">📬</span>\n    <h1 style=\"margin:12px 0 0;font-size:2rem\">Contacto</h1>\n    <p style=\"opacity:0.9;margin:8px 0 0\">Estamos aquí para ti</p>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#10b981;font-size:1.4rem;margin-top:0;text-align:center\">¿Cómo podemos ayudarte?</h2>\n    <p style=\"text-align:center\">Elige el canal de comunicación que prefieras. Te responderemos lo antes posible.</p>\n  </div>\n\n  <div style=\"display:grid;grid-template-columns:1fr 1fr;gap:20px;margin-bottom:20px\">\n    <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);text-align:center\">\n      <div style=\"background:#d1fae5;width:64px;height:64px;border-radius:50%;display:flex;align-items:center;justify-content:center;margin:0 auto 12px;font-size:28px\">📧</div>\n      <h3 style=\"color:#10b981;margin:0 0 8px\">Correo Electrónico</h3>\n      <p style=\"margin:0;font-size:14px\"><strong>Servicio al Cliente:</strong><br>soporte@tapclic.com</p>\n      <p style=\"margin:8px 0 0;font-size:14px\"><strong>Proveedores:</strong><br>proveedores@tapclic.com</p>\n    </div>\n    \n    <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);text-align:center\">\n      <div style=\"background:#d1fae5;width:64px;height:64px;border-radius:50%;display:flex;align-items:center;justify-content:center;margin:0 auto 12px;font-size:28px\">📱</div>\n      <h3 style=\"color:#10b981;margin:0 0 8px\">Teléfono</h3>\n      <p style=\"margin:0;font-size:14px\"><strong>WhatsApp:</strong><br>+58 412-0000000</p>\n      <p style=\"margin:8px 0 0;font-size:14px\"><strong>Atención Telefónica:</strong><br>+58 212-0000000</p>\n    </div>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#10b981;font-size:1.4rem;margin-top:0;text-align:center\">🕐 Horario de Atención</h2>\n    <div style=\"text-align:center;background:#f0fdf4;padding:16px;border-radius:8px\">\n      <p style=\"font-weight:600;margin:0\">Lunes a Viernes</p>\n      <p style=\"margin:4px 0 0;font-size:14px\">8:00 AM - 6:00 PM (Hora de Venezuela)</p>\n    </div>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#10b981;font-size:1.4rem;margin-top:0;text-align:center\">📍 Ubicación</h2>\n    <p style=\"text-align:center\">Caracas, Venezuela</p>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px;text-align:center\">\n    <h2 style=\"color:#10b981;font-size:1.4rem;margin-top:0\">🌐 Síguenos</h2>\n    <div style=\"display:flex;justify-content:center;gap:20px;margin-top:16px\">\n      <div style=\"text-align:center\">📸 <strong>Instagram</strong><br><span style=\"font-size:14px\">@tapclic</span></div>\n      <div style=\"text-align:center\">👍 <strong>Facebook</strong><br><span style=\"font-size:14px\">/tapclic</span></div>\n      <div style=\"text-align:center\">🐦 <strong>Twitter</strong><br><span style=\"font-size:14px\">@tapclic</span></div>\n    </div>\n  </div>\n\n  <div style=\"background:linear-gradient(135deg,#10b981,#059669);color:white;padding:24px;border-radius:12px;text-align:center\">\n    <p style=\"margin:0;font-size:1.1rem\">💚 ¡Gracias por confiar en TapClic!</p>\n  </div>\n\n</div>',NULL,NULL,NULL,1,1,5,'2026-02-01 01:35:00','2026-05-27 17:28:27'),
(9,'Política de Cookies y Almacenamiento Local','cookies','<div style=\"max-width:800px;margin:0 auto;font-family:\'Inter\',sans-serif;color:#2d3748;line-height:1.8\">\n\n  <div style=\"background:linear-gradient(135deg,#d97706,#f59e0b);color:white;padding:30px;border-radius:16px;margin-bottom:30px;text-align:center\">\n    <span style=\"font-size:48px\">🍪</span>\n    <h1 style=\"margin:12px 0 0;font-size:2rem\">Política de Cookies y Almacenamiento Local</h1>\n    <p style=\"opacity:0.9;margin:8px 0 0\">Última actualización: Julio 2026</p>\n  </div>\n\n  <div style=\"background:#fef3c7;padding:20px;border-radius:12px;margin-bottom:20px;border-left:4px solid #f59e0b\">\n    <p style=\"margin:0;font-weight:500\">🍪 Esta página explica cómo TapClic utiliza tecnologías de almacenamiento en tu dispositivo para ofrecerte una mejor experiencia.</p>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#d97706;font-size:1.3rem;margin-top:0\">1. Tecnologías que Utilizamos</h2>\n    <p>TapClic utiliza las siguientes tecnologías de almacenamiento en tu navegador:</p>\n    <ul style=\"padding-left:20px\">\n      <li><strong>localStorage:</strong> Almacena tu sesión, token de acceso, preferencias de idioma y configuración. Esta información persiste al cerrar el navegador.</li>\n      <li><strong>sessionStorage:</strong> Almacena datos temporales como el estado de la sesión actual. Se borra automáticamente al cerrar la pestaña.</li>\n    </ul>\n    <p>Estas tecnologías son necesarias para el funcionamiento de la Plataforma y no pueden ser desactivadas sin afectar la experiencia de uso.</p>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#d97706;font-size:1.3rem;margin-top:0\">2. Datos que Almacenamos</h2>\n    <p><strong>2.1 Datos de autenticación:</strong></p>\n    <ul style=\"padding-left:20px\">\n      <li>Token JWT de acceso (encriptado)</li>\n      <li>Información básica del perfil (nombre, email, rol)</li>\n      <li>Rol del usuario (admin, proveedor, cliente, staff)</li>\n    </ul>\n    <p><strong>2.2 Preferencias del usuario:</strong></p>\n    <ul style=\"padding-left:20px\">\n      <li>Idioma seleccionado (español/inglés)</li>\n      <li>Preferencia de cookies (esenciales/todas)</li>\n      <li>Estado del splash de bienvenida</li>\n    </ul>\n    <p><strong>2.3 Datos técnicos:</strong></p>\n    <ul style=\"padding-left:20px\">\n      <li>Identificador de dispositivo (fingerprint)</li>\n      <li>Última actividad registrada</li>\n    </ul>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#d97706;font-size:1.3rem;margin-top:0\">3. Datos que NO Almacenamos</h2>\n    <ul style=\"padding-left:20px\">\n      <li>No almacenamos contraseñas en texto plano (usamos hash bcrypt)</li>\n      <li>No almacenamos datos de tarjetas de crédito/débito</li>\n      <li>No almacenamos cookies de seguimiento de terceros</li>\n      <li>No compartimos tus datos con empresas externas</li>\n    </ul>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#d97706;font-size:1.3rem;margin-top:0\">4. Cómo Gestionar estos Datos</h2>\n    <p><strong>4.1 Desde la Plataforma:</strong></p>\n    <ul style=\"padding-left:20px\">\n      <li>Al hacer clic en \"Cerrar Sesión\", se eliminan todos los datos locales de tu sesión</li>\n      <li>Puedes borrar tu cuenta desde la configuración de perfil</li>\n    </ul>\n    <p><strong>4.2 Desde tu navegador:</strong></p>\n    <ul style=\"padding-left:20px\">\n      <li>Puedes borrar los datos de almacenamiento local desde la configuración de tu navegador</li>\n      <li>Chrome: Configuración → Privacidad → Borrar datos de navegación → Almacenamiento local</li>\n      <li>Firefox: Opciones → Privacidad → Cookies y datos del sitio → Limpiar datos</li>\n    </ul>\n    <p>Nota: Al borrar estos datos, deberás iniciar sesión nuevamente.</p>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#d97706;font-size:1.3rem;margin-top:0\">5. Finalidad del Almacenamiento</h2>\n    <p>Utilizamos estos datos exclusivamente para:</p>\n    <ul style=\"padding-left:20px\">\n      <li>🔐 Mantener tu sesión iniciada de forma segura</li>\n      <li>🌐 Recordar tu idioma y preferencias</li>\n      <li>🛡️ Proteger tu cuenta contra accesos no autorizados</li>\n      <li>📱 Sincronizar tu experiencia entre pestañas del mismo dispositivo</li>\n      <li>⚡ Mejorar la velocidad de carga de la Plataforma</li>\n    </ul>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#d97706;font-size:1.3rem;margin-top:0\">6. Cambios en esta Política</h2>\n    <p>Podemos actualizar esta política periódicamente. Te notificaremos sobre cambios significativos a través de un aviso en la Plataforma.</p>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#d97706;font-size:1.3rem;margin-top:0\">7. Contacto</h2>\n    <p>Si tienes dudas sobre esta política:</p>\n    <ul style=\"padding-left:20px\">\n      <li>📧 <strong>Email:</strong> privacidad@tapclic.com</li>\n      <li>💬 <strong>Chat de soporte:</strong> Disponible en la Plataforma</li>\n    </ul>\n  </div>\n\n  <div style=\"background:linear-gradient(135deg,#d97706,#f59e0b);color:white;padding:24px;border-radius:12px;text-align:center\">\n    <p style=\"margin:0;font-size:1.1rem\">🍪 Gracias por confiar en TapClic. Tu privacidad y seguridad son nuestra prioridad.</p>\n  </div>\n\n</div>','Política de Cookies y Almacenamiento Local - TapClic','Política de cookies y almacenamiento local de TapClic. Conoce qué datos almacenamos en tu dispositivo y cómo gestionarlos.',NULL,1,1,6,'2026-07-30 11:42:22','2026-07-30 11:42:22');
/*!40000 ALTER TABLE `static_pages` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `support_tickets`
--

LOCK TABLES `support_tickets` WRITE;
/*!40000 ALTER TABLE `support_tickets` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `support_tickets` (`id`, `user_id`, `subject`, `description`, `category`, `priority`, `status`, `assigned_to`, `tags`, `response_count`, `last_response_at`, `created_at`, `updated_at`) VALUES (1,6,'Problema 1','Prueba de problemas 1','payment','urgent','open',1,'[{\"name\":\"primero\",\"color\":\"blue\"}]',0,NULL,'2026-05-30 11:26:04','2026-05-31 20:48:15'),
(2,6,'Menrobaron','No quise roborte','technical','medium','in_progress',1,NULL,1,'2026-05-31 19:25:21','2026-05-31 10:11:19','2026-05-31 21:58:08'),
(3,2,'Tercer problema','Problema número 3','technical','medium','open',1,NULL,0,NULL,'2026-05-31 19:38:46','2026-05-31 20:26:50'),
(4,2,'Problema cuatro','Problema 4','account','medium','in_progress',2,NULL,1,'2026-05-31 20:44:51','2026-05-31 19:39:09','2026-05-31 20:46:08');
/*!40000 ALTER TABLE `support_tickets` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `system_config`
--

LOCK TABLES `system_config` WRITE;
/*!40000 ALTER TABLE `system_config` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `system_config` (`id`, `system_name`, `system_host`, `ws_host`, `system_active`, `system_version`, `system_logo`, `system_favicon`, `default_language`, `timezone`, `currency`, `support_email`, `support_phone`, `mail_host`, `mail_port`, `mail_encryption`, `mail_username`, `mail_password`, `mail_from`, `mail_from_name`, `twilio_sid`, `twilio_token`, `twilio_phone`, `company_name`, `company_email`, `company_phone`, `company_address`, `maintenance_mode`, `max_login_attempts`, `password_expiration_days`, `session_timeout_minutes`, `session_timeout_enabled`, `items_per_page`, `theme_color`, `allow_user_registration`, `email_verification`, `strong_passwords`, `multiple_sessions`, `wallet_enabled`, `reviews_enabled`, `chat_enabled`, `tickets_enabled`, `analytics_enabled`, `extra_json`, `created_at`, `updated_at`, `payment_default_commission`, `payment_min_commission`, `payment_currency`, `service_publish_cost`, `service_publish_duration`, `featured_cost`, `featured_duration_days`, `monetization_model`, `company_mission`, `company_vision`, `company_years`, `company_founded`, `company_clients`, `max_featured_services`) VALUES (1,'TapClic','http://192.168.5.13:5173','http://192.168.5.13:3001',1,'1.0.0','/assets/logo.png','/assets/favicon.ico','es','America/Caracas','USD','soporte@tapclic.com','+58','smtp.gmail.com',587,'tls','a','a','a','a',NULL,NULL,NULL,'TapClic C.A.','info@tapclic.com','+58','Yaracuy',0,5,90,120,0,20,'#409EFF',1,0,0,0,0,1,1,1,1,NULL,'2025-08-17 21:44:41','2026-08-24 13:24:24',3.00,0.00,NULL,5.00,30,5.00,30,'both','m','v','5+','2026',150,10);
/*!40000 ALTER TABLE `system_config` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `ticket_replies`
--

LOCK TABLES `ticket_replies` WRITE;
/*!40000 ALTER TABLE `ticket_replies` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `ticket_replies` (`id`, `ticket_id`, `user_id`, `user_type`, `message`, `created_at`, `is_internal`, `updated_at`, `is_admin`) VALUES (1,1,6,'user','Excelente me gusta mucho \n😅','2026-05-31 19:15:44',0,NULL,0),
(2,2,6,'user','00000011111','2026-05-31 19:16:47',0,NULL,0),
(3,2,1,'admin','Agarra hay locote ','2026-05-31 19:25:21',0,NULL,0),
(4,2,6,'user','11111111','2026-05-31 20:33:38',0,NULL,0),
(5,2,6,'user','Hola','2026-05-31 20:34:42',0,NULL,0),
(6,4,2,'user','Hdkdjf','2026-05-31 20:43:37',0,NULL,0),
(7,4,1,'admin','Piche pendejo','2026-05-31 20:44:51',0,NULL,0);
/*!40000 ALTER TABLE `ticket_replies` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `token_blacklist`
--

LOCK TABLES `token_blacklist` WRITE;
/*!40000 ALTER TABLE `token_blacklist` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `token_blacklist` (`id`, `token`, `expires_at`, `created_at`, `revoked_by_ip`) VALUES (3,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3NzM0MDQ3Njd9.2t67mqo9JOYkMoVaoNXRkk0U7iD8RGkZ44gfCz7nM8I',NULL,'2026-04-27 09:51:17','192.168.0.100'),
(6,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3NzkwMTUwNTh9.-dcUjD1otxZlPfrl_BQyt580c0nVDulf9ZUh-W5vmHU',NULL,'2026-05-17 22:37:20','192.168.46.12'),
(7,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3Nzc4NDU2MzZ9.vp4uZiUSYeeBO2AtKfgSYRzx-7OoptU9CmVztr0a-9E',NULL,'2026-05-17 22:37:26','192.168.46.12'),
(8,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3Nzc5NzUxNDB9.Dn_sTR5sDbtOCqJtEbB5Bhsni0FiDPBXi7a9qh9Gsuk',NULL,'2026-05-17 22:37:32','192.168.46.12'),
(9,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3Nzg1MTI2MTZ9.paPHkdnHtXIWHzj5wnXqUm6qIJZq_whL5iSBBTBO8bo',NULL,'2026-05-17 22:37:37','192.168.46.12'),
(10,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3Nzg1OTAwMjZ9.u8yfJSUCF-tycSE2ERjYsuzFC8c5eaIQxCXJjEv9QUw',NULL,'2026-05-17 22:37:41','192.168.46.12'),
(11,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3Nzg1OTAyODd9.Y4_Mv0X0xA3Q0-i1OxTosLPMy3CvRlPEMQbOdOHuipo',NULL,'2026-05-17 22:37:45','192.168.46.12'),
(12,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3NzkwMTIzNjN9.W1RB6U0WtXz6IYZwxKDnIuKTBgjBJ60JDW5Ed5yG5pc',NULL,'2026-05-17 22:37:48','192.168.46.12'),
(74,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODQ5MTQwMDJ9.9X_qnWH00eYtApNN7myYYnsidGl7zsdEMUT4ocUyo9M',NULL,'2026-07-28 20:49:34','192.168.63.137'),
(75,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODUwMjQ4MjB9.IAdnqtQRfN66mhcSLiNcZ8x1QaiC1YwvyNMkZfPAmp0',NULL,'2026-07-28 20:49:34','192.168.63.137'),
(76,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODQ3NjYyNzR9.PeZ-DmUv410Pd55Ub54wVGvxqSQBBp70XTE3F6fAz7o',NULL,'2026-07-28 20:49:34','192.168.63.137'),
(77,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODQ5MTM4MDZ9.dAiB-Cp0BgcWHG0Yk3cGIqbXPO8EBkNF22VaJQQXVfU',NULL,'2026-07-28 20:49:34','192.168.63.137'),
(78,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODUxMDM1NzN9.QXFRVKAuogmgg_Hun63s4baUnosTXMahshpINMdeRFk',NULL,'2026-07-28 20:49:34','192.168.63.137'),
(79,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODUyNDEzMDR9.1cnwoK2tRDFSzWF8Yfr6qEXMFSBkuRxRNQrJJ6pkyJY',NULL,'2026-07-28 20:49:34','192.168.63.137'),
(81,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODU2NzYxMjh9.uLAYnIKlRSexfO3cLKAg-hVnKv6DmDQcrk6-6dd2Dew',NULL,'2026-07-28 20:49:34','192.168.63.137'),
(92,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MSwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzgxNzAxMzQ5fQ.XPnndCyhRv4Txf1LAgFBIPXm8C97mNHGHzBYwXJDVOM',NULL,'2026-07-28 21:11:26','192.168.63.12'),
(93,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MSwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzgxNzA0NzYzfQ.S8my6B76NoirmRXtKcoyOiVW8G2nQrNy360bnfv8bxU',NULL,'2026-07-28 21:11:26','192.168.63.12'),
(94,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MSwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzgyNzUzOTQ0fQ.Hw2g2imFAtb8Krd1Ln67fAS9KaYq_4R86cgaLNI2y7k',NULL,'2026-07-28 21:11:26','192.168.63.12'),
(95,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MSwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzg0MzU1NTA3fQ.UQYXC2MrL8VHknI7lE-M1Cbyg8yKqHcj4eIHj4RZR7U',NULL,'2026-07-28 21:11:27','192.168.63.12'),
(96,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MSwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzg0NTAxOTA2fQ.Nwpi8OX68ci0bNxjXtvhn_GYG98ic5AdkImAN-qkVAU',NULL,'2026-07-28 21:11:27','192.168.63.12'),
(97,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MSwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzg0OTU3MjU1fQ.kcM9AY9-tCQb3665mCsP79YG2ykNrOuChA-l0G4tKCY',NULL,'2026-07-28 21:11:27','192.168.63.12'),
(98,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MSwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzg1MzQzMjYyfQ.v0-609ugJhagt0_5OnGJhqptKTnq7SIakFCI9fm7peU',NULL,'2026-07-28 21:11:27','192.168.63.12'),
(99,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MSwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzg1NDE2NjM4fQ.VqOf1CRbIA7ga2mkhx5gr5vUrG76IaBmvmLflpcoXLI',NULL,'2026-07-28 21:11:27','192.168.63.12'),
(295,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Niwicm9sZSI6InByb3ZpZGVyIiwiZXhwIjoxNzg1MDI0ODAwfQ.XKK1B3jXdCt4bgSu2VPMnFFGYRw5ZokG6mggElOZugQ',NULL,'2026-08-02 14:16:24','192.168.25.12'),
(296,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Niwicm9sZSI6InByb3ZpZGVyIiwiZXhwIjoxNzg1MDI0OTAzfQ.F4EjhPXdc2Y108-3tx_hzsxVqaxilqn7jYiuG8N1CxI',NULL,'2026-08-02 14:16:24','192.168.25.12'),
(297,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Niwicm9sZSI6InByb3ZpZGVyIiwiZXhwIjoxNzg1MTA0MTY1fQ.-4jyzoZrKf6wawsWw7ysiaENGQrKQJEad8-GguECUoA',NULL,'2026-08-02 14:16:25','192.168.25.12'),
(298,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Niwicm9sZSI6InByb3ZpZGVyIiwiZXhwIjoxNzg1MTA0NjAzfQ.CS3FuQHds9L5JA4YR8A7oaft5WjvLnaWh1PCKdJjrUA',NULL,'2026-08-02 14:16:25','192.168.25.12'),
(299,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Niwicm9sZSI6InByb3ZpZGVyIiwiZXhwIjoxNzg1MTExMTg4fQ.pY85jW4LhAPWLNnHwp9eUj66bVo53qXU_JRUMFHWeqY',NULL,'2026-08-02 14:16:25','192.168.25.12'),
(300,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Niwicm9sZSI6InByb3ZpZGVyIiwiZXhwIjoxNzg1MTUxNDA3fQ.Qx_uf9lhCtvXorI8ujy_bDuVdRFi7ZCsu3YU7aUQMW0',NULL,'2026-08-02 14:16:25','192.168.25.12'),
(301,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Niwicm9sZSI6InByb3ZpZGVyIiwiZXhwIjoxNzg1MjM2MTY5fQ.lm1ekJEG5EZxTKjQpgU5EnumE02M-5nwd4x2nhFcJdg',NULL,'2026-08-02 14:16:25','192.168.25.12'),
(302,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Niwicm9sZSI6InByb3ZpZGVyIiwiZXhwIjoxNzg1MjQyMDg1fQ.iAmpeDaJsle2-1UAE6Vk_v94RVybISWUqWPiolLX6Ls',NULL,'2026-08-02 14:16:25','192.168.25.12'),
(396,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MSwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzg2NzkzNzUwLCJpYXQiOjE3ODYxODg5NTB9.5TECq-fm9xlcqqbECsuEi5M3oq506wDgzT7QRfyfSq8',NULL,'2026-08-16 20:22:44','192.168.31.53'),
(446,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Niwicm9sZSI6InByb3ZpZGVyIiwiZXhwIjoxNzg3NjA0NTU0LCJpYXQiOjE3ODY5OTk3NTR9.G_Yp4vXMmxIOS29exwH3J9KMD5D2Xevzx9O4vrNn-3g','2026-08-25 00:49:14','2026-08-18 01:42:12','192.168.31.53'),
(447,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Niwicm9sZSI6InByb3ZpZGVyIiwiZXhwIjoxNzg3NjIyMTI5LCJpYXQiOjE3ODcwMTczMjl9.VFR6kkp_heqkPhXmYBnFp5rAOcwQq3O8pn3WJblM45Q','2026-08-25 05:42:09','2026-08-18 01:43:25','192.168.31.53'),
(448,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODc2MDQ2MTUsImlhdCI6MTc4Njk5OTgxNX0.5TPiNsEmBkFK7u_1WwvTqtWJ9lAOAsxlrwvp_FjvYpk','2026-08-25 00:50:15','2026-08-18 01:44:32','192.168.31.53'),
(449,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODc2MjIyNjksImlhdCI6MTc4NzAxNzQ2OX0.tFxuj3dJPk34dqkExG5fIRA3HFamXR3vmGxr3dd1ESI','2026-08-25 05:44:29','2026-08-18 01:45:04','192.168.31.53'),
(450,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODc2MjIyNjksImlhdCI6MTc4NzAxNzQ2OX0.tFxuj3dJPk34dqkExG5fIRA3HFamXR3vmGxr3dd1ESI','2026-08-25 05:44:29','2026-08-18 04:39:48','192.168.31.219'),
(451,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MTIsInJvbGUiOiJwcm92aWRlciIsImV4cCI6MTc4NzYxOTIzMywiaWF0IjoxNzg3MDE0NDMzfQ.bE_5k-LaisYQjDhQOx3sp2XowDxM04fj1aGvmu4Q8Gs','2026-08-25 04:53:53','2026-08-18 04:40:43','192.168.31.53'),
(452,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Niwicm9sZSI6InByb3ZpZGVyIiwiZXhwIjoxNzg3NjIyMTI5LCJpYXQiOjE3ODcwMTczMjl9.VFR6kkp_heqkPhXmYBnFp5rAOcwQq3O8pn3WJblM45Q','2026-08-25 05:42:09','2026-08-18 13:53:19','192.168.205.12'),
(453,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MTIsInJvbGUiOiJwcm92aWRlciIsImV4cCI6MTc4NzYzMjg0MCwiaWF0IjoxNzg3MDI4MDQwfQ.hOyE27ltbCuHS2OxggQANepYHmFpO5TysukKLdRDzLQ','2026-08-25 08:40:40','2026-08-18 13:54:35','192.168.205.6'),
(454,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Niwicm9sZSI6InByb3ZpZGVyIiwiZXhwIjoxNzg3NjY1OTk5LCJpYXQiOjE3ODcwNjExOTl9.KRn-PLpzrx8SPMdR8YMzN--opTmpTSW7yGnNVJ208NQ','2026-08-25 17:53:19','2026-08-18 18:49:02','192.168.205.12'),
(455,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODc2MzI3ODUsImlhdCI6MTc4NzAyNzk4NX0.oNuwAizqAh7lPjCdT2I91bX7WXjkJz-AUZS7ui6LUJ0','2026-08-25 08:39:45','2026-08-18 18:59:22','192.168.205.12'),
(456,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODc2ODQzNjIsImlhdCI6MTc4NzA3OTU2Mn0.zDti8PyzI707g6U1FF2rg6fWn5GylLf8_NI1XsuudVA','2026-08-25 22:59:22','2026-08-18 19:06:44','192.168.205.12'),
(457,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODc2ODQ4MDQsImlhdCI6MTc4NzA4MDAwNH0.X5et0_o28rNV4nDwxQwrPTUkRNOMfhwxdV7Aoln9nG0','2026-08-25 23:06:44','2026-08-18 19:07:50','192.168.205.12'),
(458,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODc2ODQ4NzAsImlhdCI6MTc4NzA4MDA3MH0.94Ik6GznZOB6rlzLgpe6kuIuBT1bfhriCVC_WDyUi2w','2026-08-25 23:07:50','2026-08-18 19:09:29','192.168.205.12'),
(459,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODc2ODQ5NjksImlhdCI6MTc4NzA4MDE2OX0.VFjG5AcZXHJIuXG1p7oNFMSYLolkLazWbryHo46tvp4','2026-08-25 23:09:29','2026-08-18 19:10:52','192.168.205.12'),
(460,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODc2ODUwNTIsImlhdCI6MTc4NzA4MDI1Mn0.WyLNQARK7CF8qTB7feYUcXMJWEtP7ZhjyuExQMBNKoo','2026-08-25 23:10:52','2026-08-18 19:11:04','192.168.205.12'),
(461,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODc2ODUwNTIsImlhdCI6MTc4NzA4MDI1Mn0.WyLNQARK7CF8qTB7feYUcXMJWEtP7ZhjyuExQMBNKoo','2026-08-25 23:10:52','2026-08-18 19:11:21','192.168.205.12'),
(462,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODc2ODUwODEsImlhdCI6MTc4NzA4MDI4MX0.y8bGsqxBeG-gkVoCreiFeU-NrmL2TOOZG9WWy9t85Gg','2026-08-25 23:11:21','2026-08-18 19:12:05','192.168.205.12'),
(463,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODc2ODUxMjUsImlhdCI6MTc4NzA4MDMyNX0.38zKKgx3KozV_2pEqB7gpjC1KULM9RAIOQKM-Yhw2U8','2026-08-25 23:12:05','2026-08-18 19:15:27','192.168.205.12'),
(464,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODc2ODUzMjcsImlhdCI6MTc4NzA4MDUyN30.MqWrmVcwjHKSbX7WbKK7eqF-o2cMRTh-6z6LyHE5SWQ','2026-08-25 23:15:27','2026-08-20 14:20:58','192.168.11.12'),
(465,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODc4NDA0NTUsImlhdCI6MTc4NzIzNTY1NX0.equLx_RLxTqzJ8awIi4dGC4A8ElV8f8fC9BfND704mU','2026-08-27 18:20:55','2026-08-20 16:30:34','192.168.11.12'),
(466,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODc4NDA0NTUsImlhdCI6MTc4NzIzNTY1NX0.equLx_RLxTqzJ8awIi4dGC4A8ElV8f8fC9BfND704mU','2026-08-27 18:20:55','2026-08-20 16:32:31','192.168.11.12'),
(467,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODc4NDgzNTEsImlhdCI6MTc4NzI0MzU1MX0.uE4v1jqm1KTXsBfUM_8tZNAxynI23mPIYW7_aFbM7Ow','2026-08-27 20:32:31','2026-08-20 16:35:07','192.168.11.12'),
(468,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MSwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzg3NjA0NzEzLCJpYXQiOjE3ODY5OTk5MTN9.URdMCQpdcTAVW_P0WIFL4NUypcQzx60B9Dh1g9byCLE','2026-08-25 00:51:53','2026-08-20 16:35:59','192.168.11.12'),
(469,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Niwicm9sZSI6InByb3ZpZGVyIiwiZXhwIjoxNzg3NjY1OTk5LCJpYXQiOjE3ODcwNjExOTl9.KRn-PLpzrx8SPMdR8YMzN--opTmpTSW7yGnNVJ208NQ','2026-08-25 17:53:19','2026-08-20 16:41:33','192.168.11.218'),
(470,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Niwicm9sZSI6InByb3ZpZGVyIiwiZXhwIjoxNzg3ODQ4ODkzLCJpYXQiOjE3ODcyNDQwOTN9.7t0CMeK76ibBErMn0IFBlEXzP4g9pDX73TEDYWsfkO8','2026-08-27 20:41:33','2026-08-20 16:42:05','192.168.11.218'),
(471,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MTIsInJvbGUiOiJwcm92aWRlciIsImV4cCI6MTc4NzY2NjA3NSwiaWF0IjoxNzg3MDYxMjc1fQ.OUylqMrzzr7Xzpp4eA9hPvuUpVvU5cdbyRAFRnIDGSk','2026-08-25 17:54:35','2026-08-20 16:42:48','192.168.11.218'),
(472,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MTIsInJvbGUiOiJwcm92aWRlciIsImV4cCI6MTc4Nzg0ODk2OCwiaWF0IjoxNzg3MjQ0MTY4fQ.ZJzOm58D0tRUdJesKPKnckvVkdFRHu6iR-UYADo1acc','2026-08-27 20:42:48','2026-08-20 18:14:35','192.168.11.218'),
(473,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MTIsInJvbGUiOiJwcm92aWRlciIsImV4cCI6MTc4Nzg1NDQ3NSwiaWF0IjoxNzg3MjQ5Njc1fQ.Vq_H3gL2I_bfNQG7za3QNof1uk71TT9I-3cbosY2EKQ','2026-08-27 22:14:35','2026-08-20 18:29:42','192.168.11.218'),
(474,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MTIsInJvbGUiOiJwcm92aWRlciIsImV4cCI6MTc4Nzg1NDQ3NSwiaWF0IjoxNzg3MjQ5Njc1fQ.Vq_H3gL2I_bfNQG7za3QNof1uk71TT9I-3cbosY2EKQ','2026-08-27 22:14:35','2026-08-20 18:30:44','192.168.11.218'),
(475,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MTIsInJvbGUiOiJwcm92aWRlciIsImV4cCI6MTc4Nzg1NTQ0MywiaWF0IjoxNzg3MjUwNjQzfQ.EeTdEL8ayKp1LpjdJsjf7864fXCivO0pevokPUhNgZk','2026-08-27 22:30:43','2026-08-20 18:30:54','192.168.11.218'),
(476,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MTIsInJvbGUiOiJwcm92aWRlciIsImV4cCI6MTc4Nzg1NTQ0MywiaWF0IjoxNzg3MjUwNjQzfQ.EeTdEL8ayKp1LpjdJsjf7864fXCivO0pevokPUhNgZk','2026-08-27 22:30:43','2026-08-20 18:31:39','192.168.11.218'),
(477,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MTIsInJvbGUiOiJwcm92aWRlciIsImV4cCI6MTc4Nzg1NTQ5OSwiaWF0IjoxNzg3MjUwNjk5fQ.9fSUpQ1RHB6d8bvmJtqGX-f-IOWFF5JIAzp28echgrE','2026-08-27 22:31:39','2026-08-21 18:20:36','192.168.11.218'),
(478,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MTIsInJvbGUiOiJwcm92aWRlciIsImV4cCI6MTc4Nzk0MTIzNiwiaWF0IjoxNzg3MzM2NDM2fQ.-6pJRpq_Ou9yWCKSvVhT5zfrWAkiXXmHCoR2j-Pn_zA','2026-08-28 22:20:36','2026-08-21 18:22:09','192.168.11.218'),
(479,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MTIsInJvbGUiOiJwcm92aWRlciIsImV4cCI6MTc4Nzk0MTMyOSwiaWF0IjoxNzg3MzM2NTI5fQ.sHqvaiZWJ5_2MeoNJY_KyJorfQZBF7f2xf5XYJCBHS4','2026-08-28 22:22:09','2026-08-21 18:22:20','192.168.11.218'),
(480,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODc4NDgzNTEsImlhdCI6MTc4NzI0MzU1MX0.uE4v1jqm1KTXsBfUM_8tZNAxynI23mPIYW7_aFbM7Ow','2026-08-27 20:32:31','2026-08-21 18:22:39','192.168.11.218'),
(481,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODc5NDEzNTksImlhdCI6MTc4NzMzNjU1OX0.t_38pjRxhoXh0BnpSoBB0rL-zoPK2UaSNNlhwXYjYwg','2026-08-28 22:22:39','2026-08-21 18:40:19','192.168.11.218'),
(482,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODc5NDI0MTksImlhdCI6MTc4NzMzNzYxOX0.E0DOnj_or8KUxpvAoIgaptm47qYpo7qqTfu3XzLt0eI','2026-08-28 22:40:19','2026-08-21 18:40:29','192.168.11.218'),
(483,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODc5NDI0MTksImlhdCI6MTc4NzMzNzYxOX0.E0DOnj_or8KUxpvAoIgaptm47qYpo7qqTfu3XzLt0eI','2026-08-28 22:40:19','2026-08-21 18:40:46','192.168.11.218'),
(484,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODc5NDI0NDYsImlhdCI6MTc4NzMzNzY0Nn0.YbvX-Omi1Q9WiPSbmURkXhvJGccCf0f-nLrV40NqOrE','2026-08-28 22:40:46','2026-08-21 18:40:56','192.168.11.218'),
(485,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODc5NDI0NDYsImlhdCI6MTc4NzMzNzY0Nn0.YbvX-Omi1Q9WiPSbmURkXhvJGccCf0f-nLrV40NqOrE','2026-08-28 22:40:46','2026-08-21 20:34:18','192.168.11.218'),
(486,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODc5NDkyNTcsImlhdCI6MTc4NzM0NDQ1N30.JsHVQkoR78xNuC2EOkWOzkvGafaZDTEUvurLyBq07nc','2026-08-29 00:34:17','2026-08-21 20:35:59','192.168.11.218'),
(487,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODc5NDkzNTksImlhdCI6MTc4NzM0NDU1OX0.8jObJzvZiyNUyqexRmz1gfAtQYKjqrMnjvIgCLk5i1U','2026-08-29 00:35:59','2026-08-21 20:36:09','192.168.11.218'),
(488,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODc5NDkzNTksImlhdCI6MTc4NzM0NDU1OX0.8jObJzvZiyNUyqexRmz1gfAtQYKjqrMnjvIgCLk5i1U','2026-08-29 00:35:59','2026-08-21 20:36:26','192.168.11.218'),
(489,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODc5NDkzODYsImlhdCI6MTc4NzM0NDU4Nn0.bFbd56jT11nB5ZWFgswD-MbhM42nks9PAOMdGg7ze1Y','2026-08-29 00:36:26','2026-08-21 20:36:44','192.168.11.218'),
(490,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODc5NDkzODYsImlhdCI6MTc4NzM0NDU4Nn0.bFbd56jT11nB5ZWFgswD-MbhM42nks9PAOMdGg7ze1Y','2026-08-29 00:36:26','2026-08-21 20:36:55','192.168.11.218'),
(491,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODc5NDk0MTUsImlhdCI6MTc4NzM0NDYxNX0.FP5ulmICKyg3JzuPTAI5GIU1Tk3vEDGSoTTrLc66_x0','2026-08-29 00:36:55','2026-08-22 14:05:53','192.168.5.12'),
(492,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODgwMTIzNTMsImlhdCI6MTc4NzQwNzU1M30.TTgY3a5rFiGeS7rDuVawidP6wFyN9xBLeg_cBwnvgwU','2026-08-29 18:05:53','2026-08-22 15:58:53','192.168.5.12'),
(493,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODgwMTIzNTMsImlhdCI6MTc4NzQwNzU1M30.TTgY3a5rFiGeS7rDuVawidP6wFyN9xBLeg_cBwnvgwU','2026-08-29 18:05:53','2026-08-22 15:59:25','192.168.5.12'),
(494,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODgwMTkxNjQsImlhdCI6MTc4NzQxNDM2NH0.NP-k4N0oungPoF_YfJB4jK26STJ8hRhYEq5CbSPHNJk','2026-08-29 19:59:24','2026-08-22 17:36:41','192.168.5.12'),
(495,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODgwMjU0MDUsImlhdCI6MTc4NzQyMDYwNX0.a1iKsP6PrOfUxwn6xEgQEMqqYzOyMP_Tfoi9lu8_yCc','2026-08-29 21:43:25','2026-08-22 17:43:59','192.168.5.13'),
(496,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MTIsInJvbGUiOiJwcm92aWRlciIsImV4cCI6MTc4ODE5MTE1OCwiaWF0IjoxNzg3NTg2MzU4fQ.cARvQEgKdd-TkOrEIx6cYuAs6F4E3_WHzuUHQ4tpyXY','2026-08-31 19:45:58','2026-08-24 21:23:13','192.168.5.13');
/*!40000 ALTER TABLE `token_blacklist` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `user_devices`
--

LOCK TABLES `user_devices` WRITE;
/*!40000 ALTER TABLE `user_devices` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `user_devices` (`id`, `user_id`, `device_name`, `device_type`, `browser`, `platform`, `device_fingerprint`, `ip_address`, `location`, `last_active`, `is_current`, `refresh_token`, `created_at`, `updated_at`) VALUES (68,10,'💻 Linux - Chrome','desktop','Chrome','Linux','caeba47f5a52c2862adb3ab8157fa9c5','192.168.21.12',NULL,'2026-05-23 18:21:37',0,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MTAsInJvbGUiOiJwcm92aWRlciIsImV4cCI6MTc4MDE2NTI5N30.Tr15P-H4_gyNlmThXPto8QUOyJIN0n62IM4AYmm2I7w','2026-05-22 01:48:50','2026-05-24 12:50:05'),
(71,10,'💻 Linux - Chrome','desktop','Chrome','Linux','6266caa5e94e644eb2d56143c783b158','192.168.31.53',NULL,'2026-05-24 17:34:45',0,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MTAsInJvbGUiOiJwcm92aWRlciIsImV4cCI6MTc4MDI0ODg4NX0.XLQnxQ4hAAH5_c5s-g4hdfDIKI1hBpbMoeVminTHDdg','2026-05-24 12:50:05','2026-06-08 22:08:07'),
(95,10,'💻 Linux - Chrome','desktop','Chrome','Linux','b514389a3b90ad1b911258d187f57631','192.168.110.33',NULL,'2026-06-22 10:45:49',0,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MTAsInJvbGUiOiJwcm92aWRlciIsImV4cCI6MTc4MjcyOTk0OX0.i2EgIryiiIpV3fB6i_qUnmobVHJvxTs5KUo7rLDCOiM','2026-06-08 22:08:07','2026-06-22 10:48:27'),
(103,11,'💻 Linux - Chrome','desktop','Chrome','Linux','b514389a3b90ad1b911258d187f57631','192.168.110.33',NULL,'2026-06-10 13:58:16',1,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6IjExIiwicm9sZSI6InVzZXIiLCJleHAiOjE3ODE3MDQ2OTZ9.ZMKrnp02uvYTclbpQxCnkXfkZQFyEktwBwCZm-YqN0Q','2026-06-10 13:58:16','2026-06-10 13:58:16'),
(111,10,'💻 Linux - Firefox','desktop','Firefox','Linux','3d26b256f8a35e1110e8989285cdb17f','192.168.31.53',NULL,'2026-06-18 04:02:19',0,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MTAsInJvbGUiOiJwcm92aWRlciIsImV4cCI6MTc4MjM2MDEzOX0.XdoLZAU-dDMqek-NaDxblTdPDAQKwZT5JATQe_FL2Bw','2026-06-18 04:02:19','2026-06-22 10:42:16'),
(112,10,'💻 Linux - Chrome','desktop','Chrome','Linux','73cc0963d9613bd4d0d7a79a60be9c8f','192.168.110.108',NULL,'2026-06-22 10:48:27',1,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MTAsInJvbGUiOiJwcm92aWRlciIsImV4cCI6MTc4MjczMDEwN30.FyBbK7L3YkfY6RWcDvHRY-TWL-LcQTTBtMcks3PfWas','2026-06-22 10:48:27','2026-06-22 10:48:27'),
(228,8,'💻 Linux - Chrome','desktop','Chrome','Linux','15f5a2f7c6bd411acbf1fb4fdddf4db2','192.168.25.12',NULL,'2026-08-03 12:36:44',1,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6OCwicm9sZSI6InByb3ZpZGVyIiwiZXhwIjoxNzg2MzY1NDA0LCJpYXQiOjE3ODU3NjA2MDR9.0YyXgZmBaosHJZlj9jJz3ACIkm4felD1C1xAA3WPAAY','2026-08-03 12:36:44','2026-08-03 12:36:44'),
(335,1,'💻 Linux - Chrome','desktop','Chrome','Linux','fc638b2df4d814ddc7197d6318969546','192.168.11.12',NULL,'2026-08-20 16:35:59',1,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MSwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzg3ODQ4NTU5LCJpYXQiOjE3ODcyNDM3NTl9.WKagftDJolUmg8Tfwxddi_bhkBCNxGDnCqFAIpFXfxw','2026-08-20 16:35:59','2026-08-20 16:35:59'),
(336,6,'💻 Linux - Chrome','desktop','Chrome','Linux','4ac9851fcc7adcfe27d71037f4ffd15d','192.168.11.218',NULL,'2026-08-20 16:41:33',1,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Niwicm9sZSI6InByb3ZpZGVyIiwiZXhwIjoxNzg3ODQ4ODkzLCJpYXQiOjE3ODcyNDQwOTN9.7t0CMeK76ibBErMn0IFBlEXzP4g9pDX73TEDYWsfkO8','2026-08-20 16:41:33','2026-08-20 16:41:33'),
(373,12,'💻 Linux - Chrome','desktop','Chrome','Linux','eafa7b95418dd56b690233f23da9b5bb','192.168.5.13',NULL,'2026-08-24 15:45:58',1,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MTIsInJvbGUiOiJwcm92aWRlciIsImV4cCI6MTc4ODE5MTE1OCwiaWF0IjoxNzg3NTg2MzU4fQ.cARvQEgKdd-TkOrEIx6cYuAs6F4E3_WHzuUHQ4tpyXY','2026-08-24 15:45:58','2026-08-24 15:45:58'),
(375,2,'💻 Linux - Chrome','desktop','Chrome','Linux','c9dbd05948181fabd46616165886d22e','192.168.5.12',NULL,'2026-08-24 20:34:36',1,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODgyMDg0NzYsImlhdCI6MTc4NzYwMzY3Nn0.1QSXJvNx4CdHP4vOTgg0-eRopEskVwR7yIKWAKNGCNU','2026-08-24 20:34:36','2026-08-24 20:34:36');
/*!40000 ALTER TABLE `user_devices` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `user_reports`
--

LOCK TABLES `user_reports` WRITE;
/*!40000 ALTER TABLE `user_reports` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `user_reports` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `user_reviews`
--

LOCK TABLES `user_reviews` WRITE;
/*!40000 ALTER TABLE `user_reviews` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `user_reviews` (`id`, `service_history_id`, `provider_id`, `user_id`, `rating`, `comment`, `created_at`, `photos`, `tags`, `is_deleted`, `deleted_at`) VALUES (1,3,12,2,4,'Fgefgfdd','2026-08-24 09:31:18','[]','[\"Calidad\"]',0,NULL),
(2,4,12,2,4,'Uyyggg','2026-08-24 09:36:13','[]','[\"Calidad\"]',0,NULL),
(3,5,12,2,4,'Vhhhhh','2026-08-24 14:08:28','[]','[\"Calidad\"]',0,NULL),
(4,6,12,2,4,'','2026-08-24 14:29:30','[]','[\"Calidad\"]',0,NULL),
(5,8,12,2,3,'Proveedor a users','2026-08-24 16:01:09','[]','[]',0,NULL),
(6,9,12,2,5,'','2026-08-24 16:21:36','[]','[\"Calidad\"]',0,NULL);
/*!40000 ALTER TABLE `user_reviews` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `users` (`id`, `name`, `username`, `email`, `phone`, `address`, `password`, `password_updated_at`, `role`, `created_at`, `avatar_url`, `average_rating`, `preferences`, `business_address`, `service_categories`, `coverage_area`, `active`, `last_seen_at`, `status_verification`, `document_number`, `documents_url`, `provider_description`, `pricing_info`, `experience_years`, `completed_jobs`, `cancelled_jobs`, `email_verified_at`, `verification_token`, `phone_verified_at`, `reset_password_token`, `reset_password_expires_at`, `login_attempts`, `last_login_attempt`, `locked_until`, `failed_login_attempts`, `account_locked`, `bio`, `position`, `linkedin_url`, `twitter_url`, `is_active`) VALUES (1,'Jesús Admin',NULL,'admin@example.com','04120761886','','$2y$12$WqOP3xcaqC/4CMNJXhTohOZVS/KRr2Q8Fi8NgUYE8eEXA6qpqUg76',NULL,'admin','2025-08-06 02:27:23','avatar_1755006875.jpg',0.0,'','','','',1,'2026-08-20 16:35:59','pending',NULL,NULL,NULL,NULL,0,0,0,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,0,0,NULL,'founder',NULL,NULL,1),
(2,'Jesús Díaz Villegas',NULL,'divijeal@gmail.com','04125048497','','$2y$12$/4gCdLLdSzDPtycV9yjLC.W2B1ls5XdcWBPnaxbcTx.YNOwFJy8qG',NULL,'user','2025-08-05 02:36:22','2f3e50b31d534b30.jpg',0.0,'','','','',1,'2026-08-24 21:21:50','pending',NULL,NULL,NULL,NULL,0,0,0,NULL,NULL,NULL,'cc9762ca6f6ade9d39e246b4e14043b7475860dfef8862cbb932dcd0f1d8891a','2026-04-28 14:13:17',0,NULL,NULL,0,0,NULL,NULL,NULL,NULL,1),
(4,'Jesús diaz',NULL,'divina@gmail.com','04120761887',NULL,'$2y$12$crK52/FINTXytwHaK/hZduSShsh3y53nxosv3KRPAXXyCUr4Ny71G',NULL,'user','2025-08-05 02:36:49',NULL,0.0,NULL,NULL,NULL,NULL,1,NULL,'pending',NULL,NULL,NULL,NULL,0,0,0,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,0,0,NULL,'team',NULL,NULL,1),
(6,'María Villegas',NULL,'maria@gmail.com','04120761889','Dirección 1','$2y$12$ZgEhIEHYgLS/kK/lXYGbbe4uekhkYODGMIMTFVTYCPcxDxq7NWRzK',NULL,'provider','2025-08-05 14:59:16','597afbe3297e667b.jpg',3.0,'{\"language\":\"es\",\"dark\":true,\"notifications\":{\"email\":true,\"sms\":true}}','Dirección 2','Acompañamiento','Cuidad central .',0,'2026-08-20 16:42:05','pending',NULL,NULL,NULL,NULL,0,0,0,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,0,0,NULL,'team',NULL,NULL,1),
(8,'Pedro Perez',NULL,'pedro@gmail.com','04125048499',NULL,'$2y$12$pf1whO0Jjw3x0mDBvTX.FOfKZ5tZ1rmF6EKftPJDKxDgX29fFzG2a',NULL,'provider','2025-08-26 03:42:27',NULL,0.0,'{\"notifications\":false}',NULL,NULL,NULL,1,'2026-08-03 12:43:44','pending',NULL,NULL,NULL,NULL,0,0,0,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,0,0,NULL,'team',NULL,NULL,1),
(9,'Viviana Alvarado ',NULL,'vivianaalvarado233@gmail.com','04160761886',NULL,'$2y$12$YzDhzEGEjKz8eju2FBwyueOJvXJV.UbsBJiBGvsctWZEPcmY6p5ry',NULL,'provider','2025-09-11 11:22:10',NULL,0.0,NULL,NULL,NULL,NULL,1,NULL,'pending',NULL,NULL,NULL,NULL,0,0,0,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,0,0,NULL,'team',NULL,NULL,1),
(10,'Angie Gutiérrez',NULL,'angie@gmail.com','04120761881','','$2y$12$uQx7VCmTA/QmZC.WyKkv7uT.omsCct0CXQgOoSiS5iIswF9DuGCUe',NULL,'provider','2026-05-22 01:48:50','3c59e8fd8a81e09f.jpg',0.0,'','','','',0,'2026-06-22 11:45:03','pending',NULL,NULL,NULL,NULL,0,0,0,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,0,0,NULL,'team',NULL,NULL,1),
(11,'Yeximar Escalona',NULL,'yeximar@gmail.com','04125048490','null','$2y$12$SgEsqdEKKevzui/wWWWf7uEE661ewQQcxjn17T6rnkfjnVJhOaId2',NULL,'user','2026-06-10 13:58:16',NULL,0.0,'','null','null','null',1,'2026-06-10 13:59:00','pending',NULL,NULL,NULL,NULL,0,0,0,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,0,0,NULL,'subdirector',NULL,NULL,1),
(12,'Carlos Bravo',NULL,'bravo@gmail.com','04120768618','','$2y$12$lCfmz0DbrrfrDNSTyeHth.clvyBXZtfcnz1NaLzJDBTReXjO3lHsi','2026-08-01 17:34:05','provider','2026-08-01 17:34:04',NULL,4.5,'','','Comida Rapida','',1,'2026-08-24 21:23:13','pending',NULL,NULL,NULL,NULL,0,0,0,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,0,0,'','team','','',1);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `wallet_transactions`
--

LOCK TABLES `wallet_transactions` WRITE;
/*!40000 ALTER TABLE `wallet_transactions` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `wallet_transactions` (`id`, `user_id`, `type`, `amount`, `description`, `bank_name`, `account_number`, `phone`, `reference`, `payment_proof`, `payment_method`, `reviewed_by`, `reviewed_at`, `status`, `created_at`) VALUES (1,1,'credit',20.00,'Recarga de saldo',NULL,NULL,NULL,'RECH-20260212-698D1B761CF28',NULL,NULL,NULL,NULL,'completed','2026-02-12 00:14:46'),
(2,1,'credit',20.00,'Solicitud de recarga #RECH-20260212-89373',NULL,NULL,NULL,'3654788554667',NULL,'paypal',1,'2026-02-12 21:50:50','completed','2026-02-12 21:09:43'),
(3,1,'credit',20.00,'Solicitud de recarga #RECH-20260214-50041',NULL,NULL,NULL,'3736362636','http://192.168.31.53:8000/uploads/payments/2026/02/dce81ef6894668df.jpg','transferencia',1,'2026-02-14 12:08:48','completed','2026-02-14 11:57:50'),
(4,2,'credit',20.00,'Solicitud de recarga #RECH-20260215-50144',NULL,NULL,NULL,'Ffkfjfj',NULL,'zelle',1,'2026-04-28 09:41:24','completed','2026-02-15 23:01:19'),
(5,2,'debit',10.00,'Retiro #WDR-20260712-04189','Banco de Venezuela','123456789',NULL,'WDR-20260712-04189',NULL,NULL,NULL,NULL,'pending','2026-07-12 12:50:44');
/*!40000 ALTER TABLE `wallet_transactions` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `wallets`
--

LOCK TABLES `wallets` WRITE;
/*!40000 ALTER TABLE `wallets` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `wallets` (`id`, `user_id`, `balance`, `created_at`, `updated_at`) VALUES (1,4,0.00,'2026-02-11 11:19:40','2026-02-11 11:19:40'),
(2,8,0.00,'2026-02-11 11:19:40','2026-02-11 11:19:40'),
(3,9,0.00,'2026-02-11 11:19:40','2026-02-11 11:19:40'),
(4,6,0.00,'2026-02-11 11:19:40','2026-02-11 11:19:40'),
(5,2,10.00,'2026-02-11 11:19:40','2026-07-12 12:50:44'),
(6,1,60.00,'2026-02-11 11:19:40','2026-02-14 12:08:48'),
(8,10,0.00,'2026-05-22 17:46:28','2026-05-22 17:46:28');
/*!40000 ALTER TABLE `wallets` ENABLE KEYS */;
UNLOCK TABLES;
commit;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2026-08-26 19:30:47
