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
-- Table structure for table `activities`
--

DROP TABLE IF EXISTS `activities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `activities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `message_key` varchar(100) NOT NULL,
  `params` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`params`)),
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activities`
--

LOCK TABLES `activities` WRITE;
/*!40000 ALTER TABLE `activities` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `activities` VALUES
(1,'activity.service_created','{\"user\": \"Juan Pérez\"}','2025-08-09 14:59:39'),
(2,'activity.profile_updated','{\"user\": \"María López\"}','2025-08-09 14:59:39'),
(3,'activity.support_ticket_opened',NULL,'2025-08-09 14:59:39'),
(4,'activity.service_accepted','{\"service\": \"Limpieza Hogar\"}','2025-08-09 14:59:39');
/*!40000 ALTER TABLE `activities` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `audit_logs`
--

DROP TABLE IF EXISTS `audit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=115 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_logs`
--

LOCK TABLES `audit_logs` WRITE;
/*!40000 ALTER TABLE `audit_logs` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `audit_logs` VALUES
(1,1,'login','Inicio de sesión','Usuario: Jesús Admin (admin@example.com) - Rol: admin','192.168.142.12','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-20 19:12:01'),
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
(114,2,'login','Inicio de sesión','Usuario: Jesús Díaz Villegas (divijeal@gmail.com) - Rol: user','192.168.246.12','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36','2026-05-28 11:30:09');
/*!40000 ALTER TABLE `audit_logs` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `blocked_ips`
--

DROP TABLE IF EXISTS `blocked_ips`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

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
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `categories` VALUES
(1,'Limpieza','La mejor limpieza','🧹','#667eea',1,1,'2026-02-03 23:32:42','2026-02-03 23:32:42'),
(2,'Transporte','Transporte para viajará','🚗','#667eea',2,1,'2026-02-03 23:44:03','2026-02-03 23:44:03'),
(3,'Fiestas center','Te decoramos todo tipos de fiestas!!','🎉','#00ffff',3,1,'2026-04-28 09:29:32','2026-04-28 09:29:32');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `content_blocks`
--

DROP TABLE IF EXISTS `content_blocks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `content_blocks`
--

LOCK TABLES `content_blocks` WRITE;
/*!40000 ALTER TABLE `content_blocks` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `content_blocks` VALUES
(1,'Banner Principal','home_banner','banner','{\"title\": \"Encuentra el servicio que necesitas\", \"subtitle\": \"Profesionales confiables a tu alcance\", \"button_text\": \"Explorar Servicios\", \"button_link\": \"/services\"}','{\"background\": \"#667eea\", \"text_color\": \"#ffffff\"}',1,'2026-02-01 01:35:00','2026-02-01 01:35:00'),
(2,'Texto de Bienvenida','welcome_text','text','<h2>Bienvenido a TapClic</h2><p>La plataforma que conecta a usuarios con profesionales confiables.</p>','\"{\\\"alignment\\\": \\\"center\\\"}\"',1,'2026-02-01 01:35:00','2026-02-03 23:40:52'),
(3,'Footer Info','footer_info','text','<p>© 2024 TapClic. Todos los derechos reservados.</p>','{}',1,'2026-02-01 01:35:00','2026-02-01 01:35:00'),
(4,'Segurojajajaja','Homejjjjh','text','Jgcgjjjhvv','\"{}\"',1,'2026-02-03 23:57:32','2026-02-03 23:57:32');
/*!40000 ALTER TABLE `content_blocks` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `conversations`
--

DROP TABLE IF EXISTS `conversations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `conversations`
--

LOCK TABLES `conversations` WRITE;
/*!40000 ALTER TABLE `conversations` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `conversations` VALUES
(1,2,'user',6,'provider','2026-03-27 16:11:32','2026-03-27 16:11:32'),
(2,6,'provider',1,'admin','2026-04-27 09:56:34','2026-04-27 09:56:34'),
(3,6,'provider',6,'provider','2026-04-27 10:02:36','2026-04-27 10:02:36'),
(4,2,'user',10,'provider','2026-05-24 22:51:48','2026-05-24 22:51:48'),
(5,2,'user',1,'admin','2026-05-24 22:52:42','2026-05-24 22:52:42');
/*!40000 ALTER TABLE `conversations` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `conversations_backup`
--

DROP TABLE IF EXISTS `conversations_backup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `conversations_backup` (
  `id` bigint(20) NOT NULL DEFAULT 0,
  `user_id` int(11) NOT NULL,
  `provider_id` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

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
-- Table structure for table `device_revocation_log`
--

DROP TABLE IF EXISTS `device_revocation_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `device_revocation_log`
--

LOCK TABLES `device_revocation_log` WRITE;
/*!40000 ALTER TABLE `device_revocation_log` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `device_revocation_log` VALUES
(1,2,13,'💻 Linux - Chrome','2026-02-22 16:12:43','192.168.1.47',2),
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
-- Table structure for table `faqs`
--

DROP TABLE IF EXISTS `faqs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `faqs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `question` varchar(255) NOT NULL,
  `answer` text NOT NULL,
  `sort_order` int(11) DEFAULT 0,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `faqs`
--

LOCK TABLES `faqs` WRITE;
/*!40000 ALTER TABLE `faqs` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `faqs` VALUES
(1,'¿Cómo solicito un servicio?','Busca el servicio que necesitas, revisa la disponibilidad y precio, luego haz clic en \"Solicitar\". Completa los detalles y espera la confirmación del proveedor.',1,1,'2025-08-28 17:31:43'),
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
-- Table structure for table `favorites`
--

DROP TABLE IF EXISTS `favorites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `favorites` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `service_id` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_favorite` (`user_id`,`service_id`),
  KEY `service_id` (`service_id`),
  CONSTRAINT `favorites_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `favorites_ibfk_2` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `favorites`
--

LOCK TABLES `favorites` WRITE;
/*!40000 ALTER TABLE `favorites` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `favorites` VALUES
(1,6,33,'2026-05-28 01:14:45'),
(3,6,10,'2026-05-28 01:16:34'),
(11,6,34,'2026-05-28 01:46:30'),
(12,2,34,'2026-05-28 11:30:39');
/*!40000 ALTER TABLE `favorites` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `jwt_tokens`
--

DROP TABLE IF EXISTS `jwt_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

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
-- Table structure for table `login_attempts`
--

DROP TABLE IF EXISTS `login_attempts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `login_attempts`
--

LOCK TABLES `login_attempts` WRITE;
/*!40000 ALTER TABLE `login_attempts` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `login_attempts` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `message_status`
--

DROP TABLE IF EXISTS `message_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=437 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `message_status`
--

LOCK TABLES `message_status` WRITE;
/*!40000 ALTER TABLE `message_status` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `message_status` VALUES
(1,1,2,'user',0,0,NULL,NULL,'2026-03-27 16:13:40',1,'2026-03-27 20:13:40'),
(2,1,6,'provider',0,1,'2026-03-27 16:14:51',NULL,'2026-03-27 16:13:40',1,'2026-03-27 16:14:15'),
(3,2,6,'provider',0,0,NULL,NULL,'2026-03-27 16:15:46',1,'2026-03-27 20:15:46'),
(4,2,2,'user',0,1,'2026-03-27 16:17:37',NULL,'2026-03-27 16:15:46',1,'2026-03-27 16:16:51'),
(5,3,6,'provider',0,0,NULL,NULL,'2026-03-27 16:16:31',1,'2026-03-27 20:16:31'),
(6,3,2,'user',0,1,'2026-03-27 16:17:37',NULL,'2026-03-27 16:16:31',1,'2026-03-27 16:16:51'),
(7,4,2,'user',0,0,NULL,NULL,'2026-03-27 16:18:15',1,'2026-03-27 20:18:15'),
(8,4,6,'provider',0,1,'2026-03-27 16:20:30',NULL,'2026-03-27 16:18:15',1,'2026-03-27 16:20:13'),
(9,5,6,'provider',0,0,NULL,NULL,'2026-03-27 16:19:18',1,'2026-03-27 20:19:18'),
(10,5,2,'user',0,1,'2026-03-27 16:21:56',NULL,'2026-03-27 16:19:18',1,'2026-03-27 16:21:26'),
(11,6,2,'user',0,0,NULL,NULL,'2026-03-27 16:19:22',1,'2026-03-27 20:19:22'),
(12,6,6,'provider',0,1,'2026-03-27 16:20:30',NULL,'2026-03-27 16:19:22',1,'2026-03-27 16:20:13'),
(13,7,2,'user',0,0,NULL,NULL,'2026-03-27 16:19:33',1,'2026-03-27 20:19:33'),
(14,7,6,'provider',0,1,'2026-03-27 16:20:30',NULL,'2026-03-27 16:19:33',1,'2026-03-27 16:20:13'),
(15,8,2,'user',0,0,NULL,NULL,'2026-03-27 16:19:45',1,'2026-03-27 20:19:45'),
(16,8,6,'provider',0,1,'2026-03-27 16:20:30',NULL,'2026-03-27 16:19:45',1,'2026-03-27 16:20:13'),
(17,9,2,'user',0,0,NULL,NULL,'2026-03-27 16:20:02',1,'2026-03-27 20:20:02'),
(18,9,6,'provider',0,1,'2026-03-27 16:20:30',NULL,'2026-03-27 16:20:02',1,'2026-03-27 16:20:13'),
(19,10,2,'user',0,0,NULL,NULL,'2026-03-27 16:22:09',1,'2026-03-27 20:22:09'),
(20,10,6,'provider',0,1,'2026-03-28 10:25:16',NULL,'2026-03-27 16:22:09',1,'2026-03-27 16:22:40'),
(21,11,2,'user',0,0,NULL,NULL,'2026-03-27 16:22:17',1,'2026-03-27 20:22:17'),
(22,11,6,'provider',0,1,'2026-03-28 10:25:16',NULL,'2026-03-27 16:22:17',1,'2026-03-27 16:22:40'),
(23,12,2,'user',0,0,NULL,NULL,'2026-03-28 05:11:37',1,'2026-03-28 09:11:37'),
(24,12,6,'provider',0,1,'2026-03-28 10:25:16',NULL,'2026-03-28 05:11:37',1,'2026-03-28 10:25:00'),
(25,13,2,'user',0,0,NULL,NULL,'2026-03-28 05:11:42',1,'2026-03-28 09:11:42'),
(26,13,6,'provider',0,1,'2026-03-28 10:25:16',NULL,'2026-03-28 05:11:42',1,'2026-03-28 10:25:00'),
(27,14,2,'user',0,0,NULL,NULL,'2026-03-28 05:11:52',1,'2026-03-28 09:11:52'),
(28,14,6,'provider',0,1,'2026-03-28 10:25:16',NULL,'2026-03-28 05:11:52',1,'2026-03-28 10:25:00'),
(29,15,6,'provider',0,0,NULL,NULL,'2026-03-28 10:25:54',1,'2026-03-28 14:25:54'),
(30,15,2,'user',0,1,'2026-03-28 10:40:32',NULL,'2026-03-28 10:25:54',1,'2026-03-28 10:39:53'),
(31,16,6,'provider',0,0,NULL,NULL,'2026-03-28 10:26:42',1,'2026-03-28 14:26:42'),
(32,16,2,'user',0,1,'2026-03-28 10:40:32',NULL,'2026-03-28 10:26:42',1,'2026-03-28 10:39:53'),
(33,17,2,'user',0,0,NULL,NULL,'2026-03-28 10:46:11',1,'2026-03-28 14:46:11'),
(34,17,6,'provider',0,1,'2026-03-28 10:46:49',NULL,'2026-03-28 10:46:11',1,'2026-03-28 10:46:34'),
(35,18,2,'user',0,0,NULL,NULL,'2026-03-28 10:46:17',1,'2026-03-28 14:46:17'),
(36,18,6,'provider',0,1,'2026-03-28 10:46:49',NULL,'2026-03-28 10:46:17',1,'2026-03-28 10:46:34'),
(37,19,2,'user',0,0,NULL,NULL,'2026-03-28 10:47:13',1,'2026-03-28 14:47:13'),
(38,19,6,'provider',0,1,'2026-03-29 16:03:39',NULL,'2026-03-28 10:47:13',1,'2026-03-29 16:02:59'),
(39,20,2,'user',0,0,NULL,NULL,'2026-03-28 10:47:49',1,'2026-03-28 14:47:49'),
(40,20,6,'provider',0,1,'2026-03-29 16:03:39',NULL,'2026-03-28 10:47:49',1,'2026-03-29 16:02:59'),
(41,21,6,'provider',0,0,NULL,NULL,'2026-03-29 16:04:02',1,'2026-03-29 20:04:02'),
(42,21,2,'user',0,1,'2026-03-30 03:47:34',NULL,'2026-03-29 16:04:02',1,'2026-03-30 03:47:22'),
(43,22,2,'user',0,0,NULL,NULL,'2026-03-29 16:04:11',1,'2026-03-29 20:04:11'),
(44,22,6,'provider',0,1,'2026-03-29 16:24:29',NULL,'2026-03-29 16:04:11',1,'2026-03-29 16:06:34'),
(45,23,2,'user',0,0,NULL,NULL,'2026-03-29 16:04:23',1,'2026-03-29 20:04:23'),
(46,23,6,'provider',0,1,'2026-03-29 16:24:29',NULL,'2026-03-29 16:04:23',1,'2026-03-29 16:06:34'),
(47,24,6,'provider',0,0,NULL,NULL,'2026-03-29 16:04:52',1,'2026-03-29 20:04:52'),
(48,24,2,'user',0,1,'2026-03-30 03:47:34',NULL,'2026-03-29 16:04:52',1,'2026-03-30 03:47:22'),
(49,25,6,'provider',0,0,NULL,NULL,'2026-03-29 16:05:14',1,'2026-03-29 20:05:14'),
(50,25,2,'user',0,1,'2026-03-30 03:47:34',NULL,'2026-03-29 16:05:14',1,'2026-03-30 03:47:22'),
(51,26,6,'provider',0,0,NULL,NULL,'2026-03-30 03:48:53',1,'2026-03-30 03:56:17'),
(52,26,2,'user',0,1,'2026-03-30 03:49:33',NULL,'2026-03-30 03:48:53',1,'2026-03-30 03:49:12'),
(53,27,2,'user',0,0,NULL,NULL,'2026-03-30 03:49:07',1,'2026-03-30 03:49:12'),
(54,27,6,'provider',0,1,'2026-03-30 03:56:34',NULL,'2026-03-30 03:49:07',1,'2026-03-30 03:56:17'),
(55,28,6,'provider',0,0,NULL,NULL,'2026-03-31 12:40:47',1,'2026-03-31 12:41:33'),
(56,28,2,'user',0,1,'2026-03-31 12:41:18',NULL,'2026-03-31 12:40:47',1,'2026-03-31 12:40:58'),
(57,29,2,'user',0,0,NULL,NULL,'2026-03-31 12:42:02',1,'2026-03-31 12:42:28'),
(58,29,6,'provider',0,1,'2026-03-31 14:43:36',NULL,'2026-03-31 12:42:02',1,'2026-03-31 14:07:29'),
(59,30,6,'provider',0,0,NULL,NULL,'2026-03-31 12:42:15',1,'2026-03-31 14:07:29'),
(60,30,2,'user',0,1,'2026-03-31 12:42:45',NULL,'2026-03-31 12:42:15',1,'2026-03-31 12:42:28'),
(61,31,6,'provider',0,0,NULL,NULL,'2026-03-31 14:43:55',1,'2026-03-31 14:44:18'),
(62,31,2,'user',0,1,'2026-03-31 14:45:09',NULL,'2026-03-31 14:43:55',1,'2026-03-31 14:45:08'),
(63,32,6,'provider',0,0,NULL,NULL,'2026-03-31 14:44:08',1,'2026-03-31 14:44:18'),
(64,32,2,'user',0,1,'2026-03-31 14:45:09',NULL,'2026-03-31 14:44:08',1,'2026-03-31 14:45:08'),
(65,33,2,'user',0,0,NULL,NULL,'2026-03-31 14:45:27',1,'2026-03-31 15:49:20'),
(66,33,6,'provider',0,1,'2026-03-31 15:48:31',NULL,'2026-03-31 14:45:27',1,'2026-03-31 15:48:30'),
(67,34,6,'provider',0,0,NULL,NULL,'2026-03-31 14:45:38',1,'2026-03-31 15:48:30'),
(68,34,2,'user',0,1,'2026-03-31 15:49:21',NULL,'2026-03-31 14:45:38',1,'2026-03-31 15:49:20'),
(69,35,2,'user',0,0,NULL,NULL,'2026-03-31 15:48:11',1,'2026-03-31 15:49:20'),
(70,35,6,'provider',0,1,'2026-03-31 15:48:31',NULL,'2026-03-31 15:48:11',1,'2026-03-31 15:48:30'),
(71,36,2,'user',0,0,NULL,NULL,'2026-03-31 15:48:44',1,'2026-03-31 15:49:20'),
(72,36,6,'provider',0,1,'2026-03-31 15:50:13',NULL,'2026-03-31 15:48:44',1,'2026-03-31 15:50:12'),
(73,37,2,'user',0,0,NULL,NULL,'2026-03-31 15:50:36',1,'2026-03-31 15:50:42'),
(74,37,6,'provider',0,1,'2026-03-31 19:33:33',NULL,'2026-03-31 15:50:36',1,'2026-03-31 19:33:31'),
(75,38,2,'user',0,0,NULL,NULL,'2026-03-31 19:33:45',1,'2026-03-31 19:34:22'),
(76,38,6,'provider',0,1,'2026-03-31 19:34:15',NULL,'2026-03-31 19:33:45',1,'2026-03-31 19:34:14'),
(77,39,6,'provider',0,0,NULL,NULL,'2026-03-31 19:34:02',1,'2026-03-31 19:34:14'),
(78,39,2,'user',0,1,'2026-03-31 19:34:23',NULL,'2026-03-31 19:34:02',1,'2026-03-31 19:34:22'),
(79,40,6,'provider',0,0,NULL,NULL,'2026-03-31 19:34:36',1,'2026-04-01 00:01:42'),
(80,40,2,'user',0,1,'2026-03-31 19:35:00',NULL,'2026-03-31 19:34:36',1,'2026-03-31 19:34:59'),
(81,41,6,'provider',0,0,NULL,NULL,'2026-04-01 00:01:52',1,'2026-04-01 00:02:16'),
(82,41,2,'user',0,1,'2026-04-01 00:02:33',NULL,'2026-04-01 00:01:52',1,'2026-04-01 00:02:33'),
(83,42,2,'user',0,0,NULL,NULL,'2026-04-01 00:02:10',1,'2026-04-01 00:02:33'),
(84,42,6,'provider',0,1,'2026-04-01 00:02:17',NULL,'2026-04-01 00:02:10',1,'2026-04-01 00:02:16'),
(85,43,6,'provider',0,0,NULL,NULL,'2026-04-01 00:02:41',1,'2026-04-01 00:03:00'),
(86,43,2,'user',0,1,'2026-04-01 00:04:29',NULL,'2026-04-01 00:02:41',1,'2026-04-01 00:04:28'),
(87,44,2,'user',0,0,NULL,NULL,'2026-04-01 00:02:51',1,'2026-04-01 00:04:28'),
(88,44,6,'provider',0,1,'2026-04-01 00:03:01',NULL,'2026-04-01 00:02:51',1,'2026-04-01 00:03:00'),
(89,45,6,'provider',0,0,NULL,NULL,'2026-04-01 00:06:15',1,'2026-04-01 00:06:39'),
(90,45,2,'user',0,1,'2026-04-01 00:06:46',NULL,'2026-04-01 00:06:15',1,'2026-04-01 00:06:45'),
(91,46,2,'user',0,0,NULL,NULL,'2026-04-01 00:06:27',1,'2026-04-01 00:06:45'),
(92,46,6,'provider',0,1,'2026-04-01 00:06:40',NULL,'2026-04-01 00:06:27',1,'2026-04-01 00:06:39'),
(93,47,6,'provider',0,0,NULL,NULL,'2026-04-01 00:38:17',1,'2026-04-01 00:38:36'),
(94,47,2,'user',0,1,'2026-04-01 00:38:41',NULL,'2026-04-01 00:38:17',1,'2026-04-01 00:38:40'),
(95,48,2,'user',0,0,NULL,NULL,'2026-04-01 00:38:28',1,'2026-04-01 00:38:40'),
(96,48,6,'provider',0,1,'2026-04-01 00:38:36',NULL,'2026-04-01 00:38:28',1,'2026-04-01 00:38:36'),
(97,49,2,'user',0,0,NULL,NULL,'2026-04-01 00:38:48',1,'2026-04-01 02:20:16'),
(98,49,6,'provider',0,1,'2026-04-01 02:20:39',NULL,'2026-04-01 00:38:48',1,'2026-04-01 02:20:38'),
(99,50,6,'provider',0,0,NULL,NULL,'2026-04-01 00:39:02',1,'2026-04-01 02:20:38'),
(100,50,2,'user',0,1,'2026-04-01 02:20:17',NULL,'2026-04-01 00:39:02',1,'2026-04-01 02:20:16'),
(101,51,6,'provider',0,0,NULL,NULL,'2026-04-01 02:21:05',1,'2026-04-01 02:21:24'),
(102,51,2,'user',0,1,'2026-04-01 02:21:33',NULL,'2026-04-01 02:21:05',1,'2026-04-01 02:21:32'),
(103,52,2,'user',0,0,NULL,NULL,'2026-04-01 02:21:17',1,'2026-04-01 02:21:32'),
(104,52,6,'provider',0,1,'2026-04-01 02:21:24',NULL,'2026-04-01 02:21:17',1,'2026-04-01 02:21:24'),
(105,53,2,'user',0,0,NULL,NULL,'2026-04-01 02:21:46',1,'2026-04-01 04:36:40'),
(106,53,6,'provider',0,1,'2026-04-01 04:39:54',NULL,'2026-04-01 02:21:46',1,'2026-04-01 04:39:53'),
(107,54,6,'provider',0,0,NULL,NULL,'2026-04-01 02:22:01',1,'2026-04-01 04:39:53'),
(108,54,2,'user',0,1,'2026-04-01 04:36:41',NULL,'2026-04-01 02:22:01',1,'2026-04-01 04:36:40'),
(109,55,6,'provider',0,0,NULL,NULL,'2026-04-01 04:40:19',1,'2026-04-01 04:40:27'),
(110,55,2,'user',0,1,'2026-04-01 04:40:41',NULL,'2026-04-01 04:40:19',1,'2026-04-01 04:40:40'),
(111,56,6,'provider',0,0,NULL,NULL,'2026-04-01 04:40:51',1,'2026-04-01 05:01:31'),
(112,56,2,'user',0,1,'2026-04-01 05:01:09',NULL,'2026-04-01 04:40:51',1,'2026-04-01 05:01:07'),
(113,57,2,'user',0,0,NULL,NULL,'2026-04-01 04:41:21',1,'2026-04-01 05:01:07'),
(114,57,6,'provider',0,1,'2026-04-01 05:01:32',NULL,'2026-04-01 04:41:21',1,'2026-04-01 05:01:31'),
(115,58,6,'provider',0,0,NULL,NULL,'2026-04-01 04:41:37',1,'2026-04-01 05:01:31'),
(116,58,2,'user',0,1,'2026-04-01 05:01:09',NULL,'2026-04-01 04:41:37',1,'2026-04-01 05:01:07'),
(117,59,2,'user',0,0,NULL,NULL,'2026-04-01 04:41:49',1,'2026-04-01 05:01:07'),
(118,59,6,'provider',0,1,'2026-04-01 05:01:32',NULL,'2026-04-01 04:41:49',1,'2026-04-01 05:01:31'),
(119,60,6,'provider',0,0,NULL,NULL,'2026-04-01 05:01:51',1,'2026-04-01 05:05:59'),
(120,60,2,'user',0,1,'2026-04-01 05:03:57',NULL,'2026-04-01 05:01:51',1,'2026-04-01 05:03:56'),
(121,61,6,'provider',0,0,NULL,NULL,'2026-04-01 05:02:05',1,'2026-04-01 05:05:59'),
(122,61,2,'user',0,1,'2026-04-01 05:03:57',NULL,'2026-04-01 05:02:05',1,'2026-04-01 05:03:56'),
(123,62,6,'provider',0,0,NULL,NULL,'2026-04-01 05:02:16',1,'2026-04-01 05:05:59'),
(124,62,2,'user',0,1,'2026-04-01 05:03:57',NULL,'2026-04-01 05:02:16',1,'2026-04-01 05:03:56'),
(125,63,2,'user',0,0,NULL,NULL,'2026-04-01 05:03:43',1,'2026-04-01 05:03:56'),
(126,63,6,'provider',0,1,'2026-04-01 05:06:00',NULL,'2026-04-01 05:03:43',1,'2026-04-01 05:05:59'),
(127,64,6,'provider',0,0,NULL,NULL,'2026-04-01 05:03:49',1,'2026-04-01 05:05:59'),
(128,64,2,'user',0,1,'2026-04-01 05:03:57',NULL,'2026-04-01 05:03:49',1,'2026-04-01 05:03:56'),
(129,65,2,'user',0,0,NULL,NULL,'2026-04-01 05:05:24',1,'2026-04-01 05:05:46'),
(130,65,6,'provider',0,1,'2026-04-01 05:06:00',NULL,'2026-04-01 05:05:24',1,'2026-04-01 05:05:59'),
(131,66,6,'provider',0,0,NULL,NULL,'2026-04-01 05:05:39',1,'2026-04-01 05:05:59'),
(132,66,2,'user',0,1,'2026-04-01 05:05:47',NULL,'2026-04-01 05:05:39',1,'2026-04-01 05:05:46'),
(133,67,6,'provider',0,0,NULL,NULL,'2026-04-01 05:07:56',1,'2026-04-01 05:14:50'),
(134,67,2,'user',0,1,'2026-04-01 05:14:28',NULL,'2026-04-01 05:07:56',1,'2026-04-01 05:14:28'),
(135,68,6,'provider',0,0,NULL,NULL,'2026-04-01 05:08:02',1,'2026-04-01 05:14:50'),
(136,68,2,'user',0,1,'2026-04-01 05:14:28',NULL,'2026-04-01 05:08:02',1,'2026-04-01 05:14:28'),
(137,69,2,'user',0,0,NULL,NULL,'2026-04-01 05:15:05',1,'2026-04-01 05:15:29'),
(138,69,6,'provider',0,1,'2026-04-01 05:15:24',NULL,'2026-04-01 05:15:05',1,'2026-04-01 05:15:24'),
(139,70,6,'provider',0,0,NULL,NULL,'2026-04-01 05:15:18',1,'2026-04-01 05:15:24'),
(140,70,2,'user',0,1,'2026-04-01 05:15:30',NULL,'2026-04-01 05:15:18',1,'2026-04-01 05:15:29'),
(141,71,6,'provider',0,0,NULL,NULL,'2026-04-01 05:16:46',1,'2026-04-01 05:17:27'),
(142,71,2,'user',0,1,'2026-04-01 05:44:26',NULL,'2026-04-01 05:16:46',1,'2026-04-01 05:44:25'),
(143,72,6,'provider',0,0,NULL,NULL,'2026-04-01 05:16:55',1,'2026-04-01 05:17:27'),
(144,72,2,'user',0,1,'2026-04-01 05:44:26',NULL,'2026-04-01 05:16:55',1,'2026-04-01 05:44:25'),
(145,73,2,'user',0,0,NULL,NULL,'2026-04-01 05:17:03',1,'2026-04-01 05:44:25'),
(146,73,6,'provider',0,1,'2026-04-01 05:17:28',NULL,'2026-04-01 05:17:03',1,'2026-04-01 05:17:27'),
(147,74,2,'user',0,0,NULL,NULL,'2026-04-01 05:17:18',1,'2026-04-01 05:44:25'),
(148,74,6,'provider',0,1,'2026-04-01 05:17:28',NULL,'2026-04-01 05:17:18',1,'2026-04-01 05:17:27'),
(149,75,6,'provider',0,0,NULL,NULL,'2026-04-01 05:17:45',1,'2026-04-01 05:44:53'),
(150,75,2,'user',0,1,'2026-04-01 05:44:26',NULL,'2026-04-01 05:17:45',1,'2026-04-01 05:44:25'),
(151,76,2,'user',0,0,NULL,NULL,'2026-04-01 05:17:57',1,'2026-04-01 05:44:25'),
(152,76,6,'provider',0,1,'2026-04-01 05:44:54',NULL,'2026-04-01 05:17:57',1,'2026-04-01 05:44:53'),
(153,77,6,'provider',0,0,NULL,NULL,'2026-04-01 05:45:05',1,'2026-04-01 05:45:13'),
(154,77,2,'user',0,1,'2026-04-02 11:43:32',NULL,'2026-04-01 05:45:05',1,'2026-04-02 11:43:32'),
(155,78,6,'provider',0,0,NULL,NULL,'2026-04-01 05:45:27',1,'2026-04-02 11:57:59'),
(156,78,2,'user',0,1,'2026-04-02 11:43:32',NULL,'2026-04-01 05:45:27',1,'2026-04-02 11:43:32'),
(157,79,2,'user',0,0,NULL,NULL,'2026-04-01 10:53:12',1,'2026-04-02 11:43:32'),
(158,79,6,'provider',0,1,'2026-04-02 11:58:02',NULL,'2026-04-01 10:53:12',1,'2026-04-02 11:57:59'),
(159,80,2,'user',0,0,NULL,NULL,'2026-04-01 10:53:18',1,'2026-04-02 11:43:32'),
(160,80,6,'provider',0,1,'2026-04-02 11:58:02',NULL,'2026-04-01 10:53:18',1,'2026-04-02 11:57:59'),
(161,81,2,'user',0,0,NULL,NULL,'2026-04-01 10:53:26',1,'2026-04-02 11:43:32'),
(162,81,6,'provider',0,1,'2026-04-02 11:58:02',NULL,'2026-04-01 10:53:26',1,'2026-04-02 11:57:59'),
(163,82,2,'user',0,0,NULL,NULL,'2026-04-01 10:53:32',1,'2026-04-02 11:43:32'),
(164,82,6,'provider',0,1,'2026-04-02 11:58:02',NULL,'2026-04-01 10:53:32',1,'2026-04-02 11:57:59'),
(165,83,2,'user',0,0,NULL,NULL,'2026-04-01 10:53:38',1,'2026-04-02 11:43:32'),
(166,83,6,'provider',0,1,'2026-04-02 11:58:02',NULL,'2026-04-01 10:53:38',1,'2026-04-02 11:57:59'),
(167,84,2,'user',0,0,NULL,NULL,'2026-04-02 11:43:47',1,'2026-04-02 11:59:04'),
(168,84,6,'provider',0,1,'2026-04-02 11:58:02',NULL,'2026-04-02 11:43:47',1,'2026-04-02 11:57:59'),
(169,85,2,'user',0,0,NULL,NULL,'2026-04-02 11:43:57',1,'2026-04-02 11:59:04'),
(170,85,6,'provider',0,1,'2026-04-02 11:58:02',NULL,'2026-04-02 11:43:57',1,'2026-04-02 11:57:59'),
(171,86,6,'provider',0,0,NULL,NULL,'2026-04-02 11:58:29',1,'2026-04-02 12:01:45'),
(172,86,2,'user',0,1,'2026-04-02 11:59:05',NULL,'2026-04-02 11:58:30',1,'2026-04-02 11:59:04'),
(173,87,6,'provider',0,0,NULL,NULL,'2026-04-02 11:59:31',1,'2026-04-02 12:01:45'),
(174,87,2,'user',0,1,'2026-04-02 12:01:30',NULL,'2026-04-02 11:59:31',1,'2026-04-02 12:01:29'),
(175,88,2,'user',0,0,NULL,NULL,'2026-04-02 11:59:52',1,'2026-04-02 12:01:29'),
(176,88,6,'provider',0,1,'2026-04-02 12:01:46',NULL,'2026-04-02 11:59:52',1,'2026-04-02 12:01:45'),
(177,89,6,'provider',0,0,NULL,NULL,'2026-04-02 12:01:59',1,'2026-04-02 13:08:18'),
(178,89,2,'user',0,1,'2026-04-02 13:07:50',NULL,'2026-04-02 12:01:59',1,'2026-04-02 13:07:49'),
(179,90,2,'user',0,0,NULL,NULL,'2026-04-02 13:07:58',1,'2026-04-02 23:40:53'),
(180,90,6,'provider',0,1,'2026-04-02 13:08:30',NULL,'2026-04-02 13:07:58',1,'2026-04-02 13:08:18'),
(181,91,6,'provider',0,0,NULL,NULL,'2026-04-02 13:08:40',1,'2026-04-03 09:52:57'),
(182,91,2,'user',0,1,'2026-04-02 23:40:54',NULL,'2026-04-02 13:08:40',1,'2026-04-02 23:40:53'),
(183,92,2,'user',0,0,NULL,NULL,'2026-04-02 23:41:02',1,'2026-04-02 23:42:51'),
(184,92,6,'provider',0,1,'2026-04-03 09:52:58',NULL,'2026-04-02 23:41:02',1,'2026-04-03 09:52:57'),
(185,93,6,'provider',0,0,NULL,NULL,'2026-04-03 09:53:09',1,'2026-04-03 09:53:46'),
(186,93,2,'user',0,1,'2026-04-03 09:53:56',NULL,'2026-04-03 09:53:09',1,'2026-04-03 09:53:55'),
(187,94,2,'user',0,0,NULL,NULL,'2026-04-03 09:53:27',1,'2026-04-03 09:53:55'),
(188,94,6,'provider',0,1,'2026-04-03 09:53:47',NULL,'2026-04-03 09:53:27',1,'2026-04-03 09:53:46'),
(189,95,6,'provider',0,0,NULL,NULL,'2026-04-03 09:55:32',1,'2026-04-03 10:01:56'),
(190,95,2,'user',0,1,'2026-04-03 10:01:41',NULL,'2026-04-03 09:55:32',1,'2026-04-03 10:01:40'),
(191,96,6,'provider',0,0,NULL,NULL,'2026-04-03 10:02:12',1,'2026-04-06 20:09:11'),
(192,96,2,'user',0,1,'2026-04-06 19:58:49',NULL,'2026-04-03 10:02:12',1,'2026-04-06 19:58:48'),
(193,97,6,'provider',0,0,NULL,NULL,'2026-04-03 10:02:26',1,'2026-04-06 20:09:11'),
(194,97,2,'user',0,1,'2026-04-06 19:58:49',NULL,'2026-04-03 10:02:26',1,'2026-04-06 19:58:48'),
(195,98,6,'provider',0,0,NULL,NULL,'2026-04-03 10:02:35',1,'2026-04-06 20:09:11'),
(196,98,2,'user',0,1,'2026-04-06 19:58:49',NULL,'2026-04-03 10:02:35',1,'2026-04-06 19:58:48'),
(197,99,6,'provider',0,0,NULL,NULL,'2026-04-03 10:02:45',1,'2026-04-06 20:09:11'),
(198,99,2,'user',0,1,'2026-04-06 19:58:49',NULL,'2026-04-03 10:02:45',1,'2026-04-06 19:58:48'),
(199,100,6,'provider',0,0,NULL,NULL,'2026-04-06 20:09:38',1,'2026-04-06 22:50:36'),
(200,100,2,'user',0,1,'2026-04-06 20:11:38',NULL,'2026-04-06 20:09:38',1,'2026-04-06 20:11:38'),
(201,101,6,'provider',0,0,NULL,NULL,'2026-04-06 20:09:52',1,'2026-04-06 22:50:36'),
(202,101,2,'user',0,1,'2026-04-06 20:11:38',NULL,'2026-04-06 20:09:52',1,'2026-04-06 20:11:38'),
(203,102,2,'user',0,0,NULL,NULL,'2026-04-06 20:10:04',1,'2026-04-06 20:11:38'),
(204,102,6,'provider',0,1,'2026-04-06 22:50:38',NULL,'2026-04-06 20:10:04',1,'2026-04-06 22:50:36'),
(205,103,2,'user',0,0,NULL,NULL,'2026-04-06 20:10:14',1,'2026-04-06 20:11:38'),
(206,103,6,'provider',0,1,'2026-04-06 22:50:38',NULL,'2026-04-06 20:10:14',1,'2026-04-06 22:50:36'),
(207,104,6,'provider',0,0,NULL,NULL,'2026-04-06 20:10:26',1,'2026-04-06 22:50:36'),
(208,104,2,'user',0,1,'2026-04-06 20:11:38',NULL,'2026-04-06 20:10:26',1,'2026-04-06 20:11:38'),
(209,105,6,'provider',0,0,NULL,NULL,'2026-04-06 20:11:00',1,'2026-04-06 22:50:36'),
(210,105,2,'user',0,1,'2026-04-06 20:11:38',NULL,'2026-04-06 20:11:00',1,'2026-04-06 20:11:38'),
(211,106,6,'provider',0,0,NULL,NULL,'2026-04-06 20:11:19',1,'2026-04-06 22:50:36'),
(212,106,2,'user',0,1,'2026-04-06 20:11:38',NULL,'2026-04-06 20:11:19',1,'2026-04-06 20:11:38'),
(213,107,6,'provider',0,0,NULL,NULL,'2026-04-06 20:11:50',1,'2026-04-06 22:50:36'),
(214,107,2,'user',0,1,'2026-04-06 20:12:30',NULL,'2026-04-06 20:11:50',1,'2026-04-06 20:12:29'),
(215,108,6,'provider',0,0,NULL,NULL,'2026-04-06 22:51:20',1,'2026-04-06 22:51:40'),
(216,108,2,'user',0,1,'2026-04-06 22:51:48',NULL,'2026-04-06 22:51:20',1,'2026-04-06 22:51:47'),
(217,109,2,'user',0,0,NULL,NULL,'2026-04-06 22:51:28',1,'2026-04-06 22:51:47'),
(218,109,6,'provider',0,1,'2026-04-06 22:51:42',NULL,'2026-04-06 22:51:28',1,'2026-04-06 22:51:40'),
(219,110,2,'user',0,0,NULL,NULL,'2026-04-06 22:51:57',1,'2026-04-06 22:53:40'),
(220,110,6,'provider',0,1,'2026-04-06 23:31:56',NULL,'2026-04-06 22:51:57',1,'2026-04-06 23:31:54'),
(221,111,6,'provider',0,0,NULL,NULL,'2026-04-06 22:52:05',1,'2026-04-06 23:31:54'),
(222,111,2,'user',0,1,'2026-04-06 22:53:41',NULL,'2026-04-06 22:52:05',1,'2026-04-06 22:53:40'),
(223,112,6,'provider',0,0,NULL,NULL,'2026-04-06 22:52:21',1,'2026-04-06 23:31:54'),
(224,112,2,'user',0,1,'2026-04-06 22:53:41',NULL,'2026-04-06 22:52:21',1,'2026-04-06 22:53:40'),
(225,113,6,'provider',0,0,NULL,NULL,'2026-04-06 22:53:17',1,'2026-04-06 23:31:54'),
(226,113,2,'user',0,1,'2026-04-06 22:53:41',NULL,'2026-04-06 22:53:17',1,'2026-04-06 22:53:40'),
(227,114,6,'provider',0,0,NULL,NULL,'2026-04-06 22:54:10',1,'2026-04-06 23:31:54'),
(228,114,2,'user',0,1,'2026-04-06 22:54:18',NULL,'2026-04-06 22:54:10',1,'2026-04-06 22:54:17'),
(229,115,6,'provider',0,0,NULL,NULL,'2026-04-06 23:32:04',1,'2026-04-06 23:33:42'),
(230,115,2,'user',0,1,'2026-04-06 23:33:16',NULL,'2026-04-06 23:32:04',1,'2026-04-06 23:33:15'),
(231,116,2,'user',0,0,NULL,NULL,'2026-04-06 23:32:12',1,'2026-04-06 23:33:15'),
(232,116,6,'provider',0,1,'2026-04-06 23:33:43',NULL,'2026-04-06 23:32:12',1,'2026-04-06 23:33:42'),
(233,117,6,'provider',0,0,NULL,NULL,'2026-04-06 23:32:24',1,'2026-04-06 23:33:42'),
(234,117,2,'user',0,1,'2026-04-06 23:33:16',NULL,'2026-04-06 23:32:24',1,'2026-04-06 23:33:15'),
(235,118,2,'user',0,0,NULL,NULL,'2026-04-06 23:32:31',1,'2026-04-06 23:33:15'),
(236,118,6,'provider',0,1,'2026-04-06 23:33:43',NULL,'2026-04-06 23:32:31',1,'2026-04-06 23:33:42'),
(237,119,2,'user',0,0,NULL,NULL,'2026-04-06 23:32:40',1,'2026-04-06 23:33:15'),
(238,119,6,'provider',0,1,'2026-04-06 23:33:43',NULL,'2026-04-06 23:32:40',1,'2026-04-06 23:33:42'),
(239,120,6,'provider',0,0,NULL,NULL,'2026-04-06 23:32:59',1,'2026-04-06 23:33:42'),
(240,120,2,'user',0,1,'2026-04-06 23:33:16',NULL,'2026-04-06 23:32:59',1,'2026-04-06 23:33:15'),
(241,121,2,'user',0,0,NULL,NULL,'2026-04-06 23:33:33',1,'2026-04-06 23:51:44'),
(242,121,6,'provider',0,1,'2026-04-06 23:33:43',NULL,'2026-04-06 23:33:33',1,'2026-04-06 23:33:42'),
(243,122,2,'user',0,0,NULL,NULL,'2026-04-06 23:33:49',1,'2026-04-06 23:51:44'),
(244,122,6,'provider',0,1,'2026-04-06 23:34:36',NULL,'2026-04-06 23:33:49',1,'2026-04-06 23:34:35'),
(245,123,6,'provider',0,0,NULL,NULL,'2026-04-06 23:34:01',1,'2026-04-06 23:34:35'),
(246,123,2,'user',0,1,'2026-04-06 23:51:45',NULL,'2026-04-06 23:34:01',1,'2026-04-06 23:51:44'),
(247,124,2,'user',0,0,NULL,NULL,'2026-04-06 23:34:20',1,'2026-04-06 23:51:44'),
(248,124,6,'provider',0,1,'2026-04-06 23:34:36',NULL,'2026-04-06 23:34:20',1,'2026-04-06 23:34:35'),
(249,125,2,'user',0,0,NULL,NULL,'2026-04-06 23:34:47',1,'2026-04-06 23:51:44'),
(250,125,6,'provider',0,1,'2026-04-06 23:35:02',NULL,'2026-04-06 23:34:47',1,'2026-04-06 23:35:00'),
(251,126,2,'user',0,0,NULL,NULL,'2026-04-06 23:35:48',1,'2026-04-06 23:51:44'),
(252,126,6,'provider',0,1,'2026-04-06 23:36:49',NULL,'2026-04-06 23:35:48',1,'2026-04-06 23:36:48'),
(253,127,2,'user',0,0,NULL,NULL,'2026-04-06 23:36:00',1,'2026-04-06 23:51:44'),
(254,127,6,'provider',0,1,'2026-04-06 23:36:49',NULL,'2026-04-06 23:36:00',1,'2026-04-06 23:36:48'),
(255,128,2,'user',0,0,NULL,NULL,'2026-04-07 10:42:42',1,'2026-04-07 19:06:27'),
(256,128,6,'provider',0,1,'2026-04-08 02:43:20',NULL,'2026-04-07 10:42:42',1,'2026-04-08 02:43:19'),
(257,129,6,'provider',0,0,NULL,NULL,'2026-04-08 02:43:38',1,'2026-04-08 02:45:06'),
(258,129,2,'user',0,1,'2026-04-08 02:44:42',NULL,'2026-04-08 02:43:38',1,'2026-04-08 02:44:41'),
(259,130,6,'provider',0,0,NULL,NULL,'2026-04-08 02:45:21',1,'2026-04-08 02:46:04'),
(260,130,2,'user',0,1,'2026-04-08 02:45:53',NULL,'2026-04-08 02:45:21',1,'2026-04-08 02:45:52'),
(261,131,6,'provider',0,0,NULL,NULL,'2026-04-08 02:45:31',1,'2026-04-08 02:46:04'),
(262,131,2,'user',0,1,'2026-04-08 02:45:53',NULL,'2026-04-08 02:45:31',1,'2026-04-08 02:45:52'),
(263,132,2,'user',0,0,NULL,NULL,'2026-04-08 02:45:43',1,'2026-04-08 02:45:52'),
(264,132,6,'provider',0,1,'2026-04-08 02:46:05',NULL,'2026-04-08 02:45:43',1,'2026-04-08 02:46:04'),
(265,133,6,'provider',0,0,NULL,NULL,'2026-04-08 02:46:14',1,'2026-04-08 02:49:50'),
(266,133,2,'user',0,1,'2026-04-08 02:50:25',NULL,'2026-04-08 02:46:14',1,'2026-04-08 02:50:24'),
(267,134,2,'user',0,0,NULL,NULL,'2026-04-08 02:46:22',1,'2026-04-08 02:50:24'),
(268,134,6,'provider',0,1,'2026-04-08 02:49:52',NULL,'2026-04-08 02:46:22',1,'2026-04-08 02:49:50'),
(269,135,2,'user',0,0,NULL,NULL,'2026-04-08 02:46:34',1,'2026-04-08 02:50:24'),
(270,135,6,'provider',0,1,'2026-04-08 02:49:52',NULL,'2026-04-08 02:46:34',1,'2026-04-08 02:49:50'),
(271,136,6,'provider',0,0,NULL,NULL,'2026-04-08 02:46:45',1,'2026-04-08 02:49:50'),
(272,136,2,'user',0,1,'2026-04-08 02:50:25',NULL,'2026-04-08 02:46:45',1,'2026-04-08 02:50:24'),
(273,137,2,'user',0,0,NULL,NULL,'2026-04-08 02:46:50',1,'2026-04-08 02:50:24'),
(274,137,6,'provider',0,1,'2026-04-08 02:49:52',NULL,'2026-04-08 02:46:50',1,'2026-04-08 02:49:50'),
(275,138,2,'user',0,0,NULL,NULL,'2026-04-08 02:47:03',1,'2026-04-08 02:50:24'),
(276,138,6,'provider',0,1,'2026-04-08 02:49:52',NULL,'2026-04-08 02:47:03',1,'2026-04-08 02:49:50'),
(277,139,6,'provider',0,0,NULL,NULL,'2026-04-08 02:47:15',1,'2026-04-08 02:49:50'),
(278,139,2,'user',0,1,'2026-04-08 02:50:25',NULL,'2026-04-08 02:47:15',1,'2026-04-08 02:50:24'),
(279,140,6,'provider',0,0,NULL,NULL,'2026-04-08 02:50:41',1,'2026-04-08 02:54:40'),
(280,140,2,'user',0,1,'2026-04-08 02:55:23',NULL,'2026-04-08 02:50:41',1,'2026-04-08 02:55:22'),
(281,141,2,'user',0,0,NULL,NULL,'2026-04-08 02:50:47',1,'2026-04-08 02:55:22'),
(282,141,6,'provider',0,1,'2026-04-08 02:54:42',NULL,'2026-04-08 02:50:47',1,'2026-04-08 02:54:40'),
(283,142,2,'user',0,0,NULL,NULL,'2026-04-08 02:50:57',1,'2026-04-08 02:55:22'),
(284,142,6,'provider',0,1,'2026-04-08 02:54:42',NULL,'2026-04-08 02:50:57',1,'2026-04-08 02:54:40'),
(285,143,6,'provider',0,0,NULL,NULL,'2026-04-08 02:51:06',1,'2026-04-08 02:54:40'),
(286,143,2,'user',0,1,'2026-04-08 02:55:23',NULL,'2026-04-08 02:51:06',1,'2026-04-08 02:55:22'),
(287,144,6,'provider',0,0,NULL,NULL,'2026-04-08 02:54:51',1,'2026-04-08 02:55:41'),
(288,144,2,'user',0,1,'2026-04-08 02:55:23',NULL,'2026-04-08 02:54:51',1,'2026-04-08 02:55:22'),
(289,145,6,'provider',0,0,NULL,NULL,'2026-04-08 02:55:00',1,'2026-04-08 02:55:41'),
(290,145,2,'user',0,1,'2026-04-08 02:55:23',NULL,'2026-04-08 02:55:00',1,'2026-04-08 02:55:22'),
(291,146,2,'user',0,0,NULL,NULL,'2026-04-08 02:55:07',1,'2026-04-08 02:55:22'),
(292,146,6,'provider',0,1,'2026-04-08 02:55:43',NULL,'2026-04-08 02:55:07',1,'2026-04-08 02:55:41'),
(293,147,6,'provider',0,0,NULL,NULL,'2026-04-08 03:44:04',1,'2026-04-08 04:25:55'),
(294,147,2,'user',0,1,'2026-04-08 04:25:24',NULL,'2026-04-08 03:44:04',1,'2026-04-08 04:25:21'),
(295,148,2,'user',0,0,NULL,NULL,'2026-04-08 03:44:31',1,'2026-04-08 04:25:21'),
(296,148,6,'provider',0,1,'2026-04-08 04:25:57',NULL,'2026-04-08 03:44:31',1,'2026-04-08 04:25:55'),
(297,149,6,'provider',0,0,NULL,NULL,'2026-04-08 04:26:44',1,'2026-04-10 20:52:23'),
(298,149,2,'user',0,1,'2026-04-10 20:09:49',NULL,'2026-04-08 04:26:44',1,'2026-04-10 20:09:47'),
(299,150,2,'user',0,0,NULL,NULL,'2026-04-08 04:26:57',1,'2026-04-10 20:09:47'),
(300,150,6,'provider',0,1,'2026-04-10 20:52:24',NULL,'2026-04-08 04:26:57',1,'2026-04-10 20:52:23'),
(301,151,6,'provider',0,0,NULL,NULL,'2026-04-08 04:27:21',1,'2026-04-10 20:52:23'),
(302,151,2,'user',0,1,'2026-04-10 20:09:49',NULL,'2026-04-08 04:27:21',1,'2026-04-10 20:09:47'),
(303,152,2,'user',0,0,NULL,NULL,'2026-04-08 04:27:30',1,'2026-04-10 20:09:47'),
(304,152,6,'provider',0,1,'2026-04-10 20:52:24',NULL,'2026-04-08 04:27:30',1,'2026-04-10 20:52:23'),
(305,153,6,'provider',0,0,NULL,NULL,'2026-04-08 04:27:42',1,'2026-04-10 20:52:23'),
(306,153,2,'user',0,1,'2026-04-10 20:09:49',NULL,'2026-04-08 04:27:42',1,'2026-04-10 20:09:47'),
(307,154,2,'user',0,0,NULL,NULL,'2026-04-08 04:27:51',1,'2026-04-10 20:09:47'),
(308,154,6,'provider',0,1,'2026-04-10 20:52:24',NULL,'2026-04-08 04:27:51',1,'2026-04-10 20:52:23'),
(309,155,6,'provider',0,0,NULL,NULL,'2026-04-08 04:27:59',1,'2026-04-10 20:52:23'),
(310,155,2,'user',0,1,'2026-04-10 20:09:49',NULL,'2026-04-08 04:27:59',1,'2026-04-10 20:09:47'),
(311,156,2,'user',0,0,NULL,NULL,'2026-04-08 04:28:06',1,'2026-04-10 20:09:47'),
(312,156,6,'provider',0,1,'2026-04-10 20:52:24',NULL,'2026-04-08 04:28:06',1,'2026-04-10 20:52:23'),
(313,157,6,'provider',0,0,NULL,NULL,'2026-04-08 04:29:30',1,'2026-04-10 20:52:23'),
(314,157,2,'user',0,1,'2026-04-10 20:09:49',NULL,'2026-04-08 04:29:30',1,'2026-04-10 20:09:47'),
(315,158,2,'user',0,0,NULL,NULL,'2026-04-08 04:29:37',1,'2026-04-10 20:09:47'),
(316,158,6,'provider',0,1,'2026-04-10 20:52:24',NULL,'2026-04-08 04:29:37',1,'2026-04-10 20:52:23'),
(317,159,6,'provider',0,0,NULL,NULL,'2026-04-08 04:29:47',1,'2026-04-10 20:52:23'),
(318,159,2,'user',0,1,'2026-04-10 20:09:49',NULL,'2026-04-08 04:29:47',1,'2026-04-10 20:09:47'),
(319,160,2,'user',0,0,NULL,NULL,'2026-04-08 04:29:54',1,'2026-04-10 20:09:47'),
(320,160,6,'provider',0,1,'2026-04-10 20:52:24',NULL,'2026-04-08 04:29:54',1,'2026-04-10 20:52:23'),
(321,161,2,'user',0,0,NULL,NULL,'2026-04-10 20:10:34',1,'2026-04-11 17:10:58'),
(322,161,6,'provider',0,1,'2026-04-10 20:52:24',NULL,'2026-04-10 20:10:34',1,'2026-04-10 20:52:23'),
(323,162,2,'user',0,0,NULL,NULL,'2026-04-10 20:52:40',1,'2026-04-11 17:10:58'),
(324,162,6,'provider',0,1,'2026-04-10 21:11:18',NULL,'2026-04-10 20:52:40',1,'2026-04-10 21:11:08'),
(325,163,6,'provider',0,0,NULL,NULL,'2026-04-10 20:52:54',1,'2026-04-10 21:11:08'),
(326,163,2,'user',0,1,'2026-04-11 17:11:00',NULL,'2026-04-10 20:52:54',1,'2026-04-11 17:10:58'),
(327,164,2,'user',0,0,NULL,NULL,'2026-04-10 20:53:21',1,'2026-04-11 17:10:58'),
(328,164,6,'provider',0,1,'2026-04-10 21:11:18',NULL,'2026-04-10 20:53:21',1,'2026-04-10 21:11:08'),
(329,165,6,'provider',0,0,NULL,NULL,'2026-04-10 20:53:34',1,'2026-04-10 21:11:08'),
(330,165,2,'user',0,1,'2026-04-11 17:11:00',NULL,'2026-04-10 20:53:34',1,'2026-04-11 17:10:58'),
(331,166,2,'user',0,0,NULL,NULL,'2026-04-10 20:53:48',1,'2026-04-11 17:10:58'),
(332,166,6,'provider',0,1,'2026-04-10 21:11:18',NULL,'2026-04-10 20:53:48',1,'2026-04-10 21:11:08'),
(333,167,2,'user',0,0,NULL,NULL,'2026-04-10 20:54:02',1,'2026-04-11 17:10:58'),
(334,167,6,'provider',0,1,'2026-04-10 21:11:18',NULL,'2026-04-10 20:54:02',1,'2026-04-10 21:11:08'),
(335,168,6,'provider',0,0,NULL,NULL,'2026-04-10 20:54:14',1,'2026-04-10 21:11:08'),
(336,168,2,'user',0,1,'2026-04-11 17:11:00',NULL,'2026-04-10 20:54:14',1,'2026-04-11 17:10:58'),
(337,169,6,'provider',0,0,NULL,NULL,'2026-04-10 20:54:22',1,'2026-04-10 21:11:08'),
(338,169,2,'user',0,1,'2026-04-11 17:11:00',NULL,'2026-04-10 20:54:22',1,'2026-04-11 17:10:58'),
(339,170,6,'provider',0,0,NULL,NULL,'2026-04-10 20:54:32',1,'2026-04-10 21:11:08'),
(340,170,2,'user',0,1,'2026-04-11 17:11:00',NULL,'2026-04-10 20:54:32',1,'2026-04-11 17:10:58'),
(341,171,6,'provider',0,0,NULL,NULL,'2026-04-10 20:54:43',1,'2026-04-10 21:11:08'),
(342,171,2,'user',0,1,'2026-04-11 17:11:00',NULL,'2026-04-10 20:54:43',1,'2026-04-11 17:10:58'),
(343,172,6,'provider',0,0,NULL,NULL,'2026-04-10 20:54:50',1,'2026-04-10 21:11:08'),
(344,172,2,'user',0,1,'2026-04-11 17:11:00',NULL,'2026-04-10 20:54:50',1,'2026-04-11 17:10:58'),
(345,173,2,'user',0,0,NULL,NULL,'2026-04-10 20:54:58',1,'2026-04-11 17:10:58'),
(346,173,6,'provider',0,1,'2026-04-10 21:11:18',NULL,'2026-04-10 20:54:58',1,'2026-04-10 21:11:08'),
(347,174,2,'user',0,0,NULL,NULL,'2026-04-10 20:55:06',1,'2026-04-11 17:10:58'),
(348,174,6,'provider',0,1,'2026-04-10 21:11:18',NULL,'2026-04-10 20:55:06',1,'2026-04-10 21:11:08'),
(349,175,2,'user',0,0,NULL,NULL,'2026-04-10 20:55:14',1,'2026-04-11 17:10:58'),
(350,175,6,'provider',0,1,'2026-04-10 21:11:18',NULL,'2026-04-10 20:55:14',1,'2026-04-10 21:11:08'),
(351,176,2,'user',0,0,NULL,NULL,'2026-04-10 20:55:24',1,'2026-04-11 17:10:58'),
(352,176,6,'provider',0,1,'2026-04-10 21:11:18',NULL,'2026-04-10 20:55:24',1,'2026-04-10 21:11:08'),
(353,177,2,'user',0,0,NULL,NULL,'2026-04-10 20:55:31',1,'2026-04-11 17:10:58'),
(354,177,6,'provider',0,1,'2026-04-10 21:11:18',NULL,'2026-04-10 20:55:31',1,'2026-04-10 21:11:08'),
(355,178,2,'user',0,0,NULL,NULL,'2026-04-10 20:55:41',1,'2026-04-11 17:10:58'),
(356,178,6,'provider',0,1,'2026-04-10 21:11:18',NULL,'2026-04-10 20:55:41',1,'2026-04-10 21:11:08'),
(357,179,6,'provider',0,0,NULL,NULL,'2026-04-10 20:55:48',1,'2026-04-10 21:11:08'),
(358,179,2,'user',0,1,'2026-04-11 17:11:00',NULL,'2026-04-10 20:55:48',1,'2026-04-11 17:10:58'),
(359,180,6,'provider',0,0,NULL,NULL,'2026-04-10 20:55:56',1,'2026-04-10 21:11:08'),
(360,180,2,'user',0,1,'2026-04-11 17:11:00',NULL,'2026-04-10 20:55:56',1,'2026-04-11 17:10:58'),
(361,181,2,'user',0,0,NULL,NULL,'2026-04-10 20:56:08',1,'2026-04-11 17:10:58'),
(362,181,6,'provider',0,1,'2026-04-10 21:11:18',NULL,'2026-04-10 20:56:08',1,'2026-04-10 21:11:08'),
(363,182,6,'provider',0,0,NULL,NULL,'2026-04-10 20:56:15',1,'2026-04-10 21:11:08'),
(364,182,2,'user',0,1,'2026-04-11 17:11:00',NULL,'2026-04-10 20:56:15',1,'2026-04-11 17:10:58'),
(365,183,6,'provider',0,0,NULL,NULL,'2026-04-11 17:26:09',1,'2026-04-11 17:27:53'),
(366,183,2,'user',0,1,'2026-04-11 17:27:50',NULL,'2026-04-11 17:26:09',1,'2026-04-11 17:27:48'),
(367,184,2,'user',0,0,NULL,NULL,'2026-04-11 17:26:28',1,'2026-04-11 17:27:48'),
(368,184,6,'provider',0,1,'2026-04-11 17:27:54',NULL,'2026-04-11 17:26:28',1,'2026-04-11 17:27:53'),
(369,185,6,'provider',0,0,NULL,NULL,'2026-04-11 17:26:38',1,'2026-04-11 17:27:53'),
(370,185,2,'user',0,1,'2026-04-11 17:27:50',NULL,'2026-04-11 17:26:38',1,'2026-04-11 17:27:48'),
(371,186,2,'user',0,0,NULL,NULL,'2026-04-11 17:26:46',1,'2026-04-11 17:27:48'),
(372,186,6,'provider',0,1,'2026-04-11 17:27:54',NULL,'2026-04-11 17:26:46',1,'2026-04-11 17:27:53'),
(373,187,2,'user',0,0,NULL,NULL,'2026-04-11 17:26:53',1,'2026-04-11 17:27:48'),
(374,187,6,'provider',0,1,'2026-04-11 17:27:54',NULL,'2026-04-11 17:26:53',1,'2026-04-11 17:27:53'),
(375,188,2,'user',0,0,NULL,NULL,'2026-04-11 17:27:00',1,'2026-04-11 17:27:48'),
(376,188,6,'provider',0,1,'2026-04-11 17:27:54',NULL,'2026-04-11 17:27:00',1,'2026-04-11 17:27:53'),
(377,189,2,'user',0,0,NULL,NULL,'2026-04-11 17:27:12',1,'2026-04-11 17:27:48'),
(378,189,6,'provider',0,1,'2026-04-11 17:27:54',NULL,'2026-04-11 17:27:12',1,'2026-04-11 17:27:53'),
(379,190,6,'provider',0,0,NULL,NULL,'2026-04-11 17:27:22',1,'2026-04-11 17:27:53'),
(380,190,2,'user',0,1,'2026-04-11 17:27:50',NULL,'2026-04-11 17:27:22',1,'2026-04-11 17:27:48'),
(381,191,2,'user',0,0,NULL,NULL,'2026-04-11 17:27:34',1,'2026-04-11 17:27:48'),
(382,191,6,'provider',0,1,'2026-04-11 17:27:54',NULL,'2026-04-11 17:27:34',1,'2026-04-11 17:27:53'),
(383,192,6,'provider',0,0,NULL,NULL,'2026-04-11 17:28:13',1,'2026-04-11 17:28:55'),
(384,192,2,'user',0,1,'2026-04-11 17:29:31',NULL,'2026-04-11 17:28:13',1,'2026-04-11 17:29:30'),
(385,193,2,'user',0,0,NULL,NULL,'2026-04-11 17:28:27',1,'2026-04-11 17:29:30'),
(386,193,6,'provider',0,1,'2026-04-11 17:28:56',NULL,'2026-04-11 17:28:27',1,'2026-04-11 17:28:55'),
(387,194,2,'user',0,0,NULL,NULL,'2026-04-11 17:29:14',1,'2026-04-11 17:29:30'),
(388,194,6,'provider',0,1,'2026-04-11 17:30:03',NULL,'2026-04-11 17:29:14',1,'2026-04-11 17:30:01'),
(389,195,2,'user',0,0,NULL,NULL,'2026-04-11 17:30:09',1,'2026-04-26 22:21:23'),
(390,195,6,'provider',0,1,'2026-04-11 17:34:08',NULL,'2026-04-11 17:30:09',1,'2026-04-11 17:34:07'),
(391,196,6,'provider',0,0,NULL,NULL,'2026-04-11 17:30:18',1,'2026-04-11 17:34:07'),
(392,196,2,'user',0,1,'2026-04-26 22:21:24',NULL,'2026-04-11 17:30:18',1,'2026-04-26 22:21:23'),
(393,197,2,'user',0,0,NULL,NULL,'2026-04-11 17:30:24',1,'2026-04-26 22:21:23'),
(394,197,6,'provider',0,1,'2026-04-11 17:34:08',NULL,'2026-04-11 17:30:24',1,'2026-04-11 17:34:07'),
(395,198,6,'provider',0,0,NULL,NULL,'2026-04-11 17:30:43',1,'2026-04-11 17:34:07'),
(396,198,2,'user',0,1,'2026-04-26 22:21:24',NULL,'2026-04-11 17:30:43',1,'2026-04-26 22:21:23'),
(397,199,6,'provider',0,0,NULL,NULL,'2026-04-11 17:30:54',1,'2026-04-11 17:34:07'),
(398,199,2,'user',0,1,'2026-04-26 22:21:24',NULL,'2026-04-11 17:30:54',1,'2026-04-26 22:21:23'),
(399,200,6,'provider',0,0,NULL,NULL,'2026-04-11 17:31:07',1,'2026-04-11 17:34:07'),
(400,200,2,'user',0,1,'2026-04-26 22:21:24',NULL,'2026-04-11 17:31:07',1,'2026-04-26 22:21:23'),
(401,201,6,'provider',0,0,NULL,NULL,'2026-04-11 17:31:19',1,'2026-04-11 17:34:07'),
(402,201,2,'user',0,1,'2026-04-26 22:21:24',NULL,'2026-04-11 17:31:19',1,'2026-04-26 22:21:23'),
(403,202,6,'provider',0,0,NULL,NULL,'2026-04-11 17:31:28',1,'2026-04-11 17:34:07'),
(404,202,2,'user',0,1,'2026-04-26 22:21:24',NULL,'2026-04-11 17:31:28',1,'2026-04-26 22:21:23'),
(405,203,6,'provider',0,0,NULL,NULL,'2026-04-11 17:31:41',1,'2026-04-11 17:34:07'),
(406,203,2,'user',0,1,'2026-04-26 22:21:24',NULL,'2026-04-11 17:31:41',1,'2026-04-26 22:21:23'),
(407,204,6,'provider',0,0,NULL,NULL,'2026-04-11 17:31:50',1,'2026-04-11 17:34:07'),
(408,204,2,'user',0,1,'2026-04-26 22:21:24',NULL,'2026-04-11 17:31:50',1,'2026-04-26 22:21:23'),
(409,205,6,'provider',0,0,NULL,NULL,'2026-04-11 17:32:06',1,'2026-04-11 17:34:07'),
(410,205,2,'user',0,1,'2026-04-26 22:21:24',NULL,'2026-04-11 17:32:06',1,'2026-04-26 22:21:23'),
(411,206,2,'user',0,0,NULL,NULL,'2026-04-11 17:32:17',1,'2026-04-26 22:21:23'),
(412,206,6,'provider',0,1,'2026-04-11 17:34:08',NULL,'2026-04-11 17:32:17',1,'2026-04-11 17:34:07'),
(413,207,2,'user',0,0,NULL,NULL,'2026-04-11 17:32:24',1,'2026-04-26 22:21:23'),
(414,207,6,'provider',0,1,'2026-04-11 17:34:08',NULL,'2026-04-11 17:32:24',1,'2026-04-11 17:34:07'),
(415,208,2,'user',0,0,NULL,NULL,'2026-04-11 17:32:32',1,'2026-04-26 22:21:23'),
(416,208,6,'provider',0,1,'2026-04-11 17:34:08',NULL,'2026-04-11 17:32:32',1,'2026-04-11 17:34:07'),
(417,209,2,'user',0,0,NULL,NULL,'2026-04-11 17:32:45',1,'2026-04-26 22:21:23'),
(418,209,6,'provider',0,1,'2026-04-11 17:34:08',NULL,'2026-04-11 17:32:45',1,'2026-04-11 17:34:07'),
(419,210,2,'user',0,0,NULL,NULL,'2026-04-11 17:32:53',1,'2026-04-26 22:21:23'),
(420,210,6,'provider',0,1,'2026-04-11 17:34:08',NULL,'2026-04-11 17:32:53',1,'2026-04-11 17:34:07'),
(421,211,2,'user',0,0,NULL,NULL,'2026-04-11 17:33:20',1,'2026-04-26 22:21:23'),
(422,211,6,'provider',0,1,'2026-04-11 17:34:08',NULL,'2026-04-11 17:33:20',1,'2026-04-11 17:34:07'),
(423,212,2,'user',0,0,NULL,NULL,'2026-04-11 17:33:31',1,'2026-04-26 22:21:23'),
(424,212,6,'provider',0,1,'2026-04-11 17:34:08',NULL,'2026-04-11 17:33:31',1,'2026-04-11 17:34:07'),
(425,213,2,'user',0,0,NULL,NULL,'2026-04-11 17:33:41',1,'2026-04-26 22:21:23'),
(426,213,6,'provider',0,1,'2026-04-11 17:34:08',NULL,'2026-04-11 17:33:41',1,'2026-04-11 17:34:07'),
(427,214,2,'user',0,0,NULL,NULL,'2026-04-11 17:33:49',1,'2026-04-26 22:21:23'),
(428,214,6,'provider',0,1,'2026-04-11 17:34:08',NULL,'2026-04-11 17:33:49',1,'2026-04-11 17:34:07'),
(429,215,2,'user',0,0,NULL,NULL,'2026-04-11 17:34:01',1,'2026-04-26 22:21:23'),
(430,215,6,'provider',0,1,'2026-04-11 17:34:08',NULL,'2026-04-11 17:34:01',1,'2026-04-11 17:34:07'),
(431,216,2,'user',0,0,NULL,NULL,'2026-04-11 17:34:17',1,'2026-04-26 22:21:23'),
(432,216,6,'provider',0,1,'2026-04-11 17:34:41',NULL,'2026-04-11 17:34:17',1,'2026-04-11 17:34:39'),
(433,217,2,'user',0,0,NULL,NULL,'2026-04-11 17:34:32',1,'2026-04-26 22:21:23'),
(434,217,6,'provider',0,1,'2026-04-11 17:34:41',NULL,'2026-04-11 17:34:32',1,'2026-04-11 17:34:39'),
(435,218,2,'user',0,0,NULL,NULL,'2026-05-24 22:53:46',1,'2026-05-24 22:54:02'),
(436,218,1,'admin',0,1,'2026-05-27 05:36:43',NULL,'2026-05-24 22:53:46',1,'2026-05-27 05:36:43');
/*!40000 ALTER TABLE `message_status` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=219 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `messages`
--

LOCK TABLES `messages` WRITE;
/*!40000 ALTER TABLE `messages` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `messages` VALUES
(1,1,2,6,'Hola cómo estás ?','text',NULL,'sent',NULL,'2026-03-27 16:13:40','2026-03-27 16:13:40',NULL,NULL,'user','provider'),
(2,1,6,2,'Hola buen. Día','text',NULL,'sent',NULL,'2026-03-27 16:15:46','2026-03-27 16:15:46',NULL,NULL,'provider','user'),
(3,1,6,2,'En qué puedo ayudarte','text',NULL,'sent',NULL,'2026-03-27 16:16:31','2026-03-27 16:16:31',NULL,NULL,'provider','user'),
(4,1,2,6,'En nada','text',NULL,'sent',NULL,'2026-03-27 16:18:15','2026-03-27 16:18:15',NULL,NULL,'user','provider'),
(5,1,6,2,'Holggg','text',NULL,'sent',NULL,'2026-03-27 16:19:18','2026-03-27 16:19:18',NULL,NULL,'provider','user'),
(6,1,2,6,'Gsggf','text',NULL,'sent',NULL,'2026-03-27 16:19:22','2026-03-27 16:19:22',NULL,NULL,'user','provider'),
(7,1,2,6,'123456','text',NULL,'sent',NULL,'2026-03-27 16:19:33','2026-03-27 16:19:33',NULL,NULL,'user','provider'),
(8,1,2,6,'Ggggg','text',NULL,'sent',NULL,'2026-03-27 16:19:45','2026-03-27 16:19:45',NULL,NULL,'user','provider'),
(9,1,2,6,'Hhggg','text',NULL,'sent',NULL,'2026-03-27 16:20:02','2026-03-27 16:20:02',NULL,NULL,'user','provider'),
(10,1,2,6,'Hols','text',NULL,'sent',NULL,'2026-03-27 16:22:09','2026-03-27 16:22:09',NULL,NULL,'user','provider'),
(11,1,2,6,'Hplzkfkj','text',NULL,'sent',NULL,'2026-03-27 16:22:17','2026-03-27 16:22:17',NULL,NULL,'user','provider'),
(12,1,2,6,'Holabd','text',NULL,'sent',NULL,'2026-03-28 05:11:37','2026-03-28 05:11:37',NULL,NULL,'user','provider'),
(13,1,2,6,'Udkkddjfhf','text',NULL,'sent',NULL,'2026-03-28 05:11:42','2026-03-28 05:11:42',NULL,NULL,'user','provider'),
(14,1,2,6,'Jsjdjfhfhffbrrbbrbrb','text',NULL,'sent',NULL,'2026-03-28 05:11:52','2026-03-28 05:11:52',NULL,NULL,'user','provider'),
(15,1,6,2,'Hola prueba de error','text',NULL,'sent',NULL,'2026-03-28 10:25:54','2026-03-28 10:25:54',NULL,NULL,'provider','user'),
(16,1,6,2,'Otra prueba','text',NULL,'sent',NULL,'2026-03-28 10:26:42','2026-03-28 10:26:42',NULL,NULL,'provider','user'),
(17,1,2,6,'Hola','text',NULL,'sent',NULL,'2026-03-28 10:46:11','2026-03-28 10:46:11',NULL,NULL,'user','provider'),
(18,1,2,6,'Hola','text',NULL,'sent',NULL,'2026-03-28 10:46:17','2026-03-28 10:46:17',NULL,NULL,'user','provider'),
(19,1,2,6,'Ttttttt','text',NULL,'sent',NULL,'2026-03-28 10:47:13','2026-03-28 10:47:13',NULL,NULL,'user','provider'),
(20,1,2,6,'Jkjjj','text',NULL,'sent',NULL,'2026-03-28 10:47:49','2026-03-28 10:47:49',NULL,NULL,'user','provider'),
(21,1,6,2,'Hola','text',NULL,'sent',NULL,'2026-03-29 16:04:02','2026-03-29 16:04:02',NULL,NULL,'provider','user'),
(22,1,2,6,'Holaas','text',NULL,'sent',NULL,'2026-03-29 16:04:11','2026-03-29 16:04:11',NULL,NULL,'user','provider'),
(23,1,2,6,'Hola','text',NULL,'sent',NULL,'2026-03-29 16:04:23','2026-03-29 16:04:23',NULL,NULL,'user','provider'),
(24,1,6,2,'Hora de 💧','text',NULL,'sent',NULL,'2026-03-29 16:04:52','2026-03-29 16:04:52',NULL,NULL,'provider','user'),
(25,1,6,2,'Niños','text',NULL,'sent',NULL,'2026-03-29 16:05:14','2026-03-29 16:05:14',NULL,NULL,'provider','user'),
(26,1,6,2,'Gato','text',NULL,'sent',NULL,'2026-03-30 03:48:53','2026-03-30 03:48:53',NULL,NULL,'provider','user'),
(27,1,2,6,'Hpla','text',NULL,'sent',NULL,'2026-03-30 03:49:07','2026-03-30 03:49:07',NULL,NULL,'user','provider'),
(28,1,6,2,'Holaasss','text',NULL,'sent',NULL,'2026-03-31 12:40:47','2026-03-31 12:40:47',NULL,NULL,'provider','user'),
(29,1,2,6,'Holaaa','text',NULL,'sent',NULL,'2026-03-31 12:42:02','2026-03-31 12:42:02',NULL,NULL,'user','provider'),
(30,1,6,2,'Holssssdvgr','text',NULL,'sent',NULL,'2026-03-31 12:42:15','2026-03-31 12:42:15',NULL,NULL,'provider','user'),
(31,1,6,2,'Holaaas','text',NULL,'sent',NULL,'2026-03-31 14:43:55','2026-03-31 14:43:55',NULL,NULL,'provider','user'),
(32,1,6,2,'Holaas','text',NULL,'sent',NULL,'2026-03-31 14:44:08','2026-03-31 14:44:08',NULL,NULL,'provider','user'),
(33,1,2,6,'😘😘😘😘😘😔😔','text',NULL,'sent',NULL,'2026-03-31 14:45:27','2026-03-31 14:45:27',NULL,NULL,'user','provider'),
(34,1,6,2,'Jjjjjj','text',NULL,'sent',NULL,'2026-03-31 14:45:38','2026-03-31 14:45:38',NULL,NULL,'provider','user'),
(35,1,2,6,'Kilo','text',NULL,'sent',NULL,'2026-03-31 15:48:11','2026-03-31 15:48:11',NULL,NULL,'user','provider'),
(36,1,2,6,'Hola','text',NULL,'sent',NULL,'2026-03-31 15:48:44','2026-03-31 15:48:44',NULL,NULL,'user','provider'),
(37,1,2,6,'Hola','text',NULL,'sent',NULL,'2026-03-31 15:50:36','2026-03-31 15:50:36',NULL,NULL,'user','provider'),
(38,1,2,6,'Hol','text',NULL,'sent',NULL,'2026-03-31 19:33:45','2026-03-31 19:33:45',NULL,NULL,'user','provider'),
(39,1,6,2,'Holaa','text',NULL,'sent',NULL,'2026-03-31 19:34:02','2026-03-31 19:34:02',NULL,NULL,'provider','user'),
(40,1,6,2,'Tttttttt','text',NULL,'sent',NULL,'2026-03-31 19:34:36','2026-03-31 19:34:36',NULL,NULL,'provider','user'),
(41,1,6,2,'Hola','text',NULL,'sent',NULL,'2026-04-01 00:01:52','2026-04-01 00:01:52',NULL,NULL,'provider','user'),
(42,1,2,6,'Holaa','text',NULL,'sent',NULL,'2026-04-01 00:02:10','2026-04-01 00:02:10',NULL,NULL,'user','provider'),
(43,1,6,2,'Gggghhh','text',NULL,'sent',NULL,'2026-04-01 00:02:41','2026-04-01 00:02:41',NULL,NULL,'provider','user'),
(44,1,2,6,'Jjjjjjgh','text',NULL,'sent',NULL,'2026-04-01 00:02:51','2026-04-01 00:02:51',NULL,NULL,'user','provider'),
(45,1,6,2,'Holaaa','text',NULL,'sent',NULL,'2026-04-01 00:06:15','2026-04-01 00:06:15',NULL,NULL,'provider','user'),
(46,1,2,6,'Holass','text',NULL,'sent',NULL,'2026-04-01 00:06:27','2026-04-01 00:06:27',NULL,NULL,'user','provider'),
(47,1,6,2,'Pendejo','text',NULL,'sent',NULL,'2026-04-01 00:38:17','2026-04-01 00:38:17',NULL,NULL,'provider','user'),
(48,1,2,6,'Pendejo','text',NULL,'sent',NULL,'2026-04-01 00:38:28','2026-04-01 00:38:28',NULL,NULL,'user','provider'),
(49,1,2,6,'Kkkkkkl','text',NULL,'sent',NULL,'2026-04-01 00:38:48','2026-04-01 00:38:48',NULL,NULL,'user','provider'),
(50,1,6,2,'Hol','text',NULL,'sent',NULL,'2026-04-01 00:39:02','2026-04-01 00:39:02',NULL,NULL,'provider','user'),
(51,1,6,2,'Hola prueba final','text',NULL,'sent',NULL,'2026-04-01 02:21:05','2026-04-01 02:21:05',NULL,NULL,'provider','user'),
(52,1,2,6,'Hola 😘👋🏾','text',NULL,'sent',NULL,'2026-04-01 02:21:17','2026-04-01 02:21:17',NULL,NULL,'user','provider'),
(53,1,2,6,'Robbin','text',NULL,'sent',NULL,'2026-04-01 02:21:46','2026-04-01 02:21:46',NULL,NULL,'user','provider'),
(54,1,6,2,'Lo necesito','text',NULL,'sent',NULL,'2026-04-01 02:22:01','2026-04-01 02:22:01',NULL,NULL,'provider','user'),
(55,1,6,2,'Holass','text',NULL,'sent',NULL,'2026-04-01 04:40:19','2026-04-01 04:40:19',NULL,NULL,'provider','user'),
(56,1,6,2,'Jate','text',NULL,'sent',NULL,'2026-04-01 04:40:51','2026-04-01 04:40:51',NULL,NULL,'provider','user'),
(57,1,2,6,'Juejua','text',NULL,'sent',NULL,'2026-04-01 04:41:21','2026-04-01 04:41:21',NULL,NULL,'user','provider'),
(58,1,6,2,'Pendejo','text',NULL,'sent',NULL,'2026-04-01 04:41:37','2026-04-01 04:41:37',NULL,NULL,'provider','user'),
(59,1,2,6,'Pendejo','text',NULL,'sent',NULL,'2026-04-01 04:41:49','2026-04-01 04:41:49',NULL,NULL,'user','provider'),
(60,1,6,2,'Terminect','text',NULL,'sent',NULL,'2026-04-01 05:01:51','2026-04-01 05:01:51',NULL,NULL,'provider','user'),
(61,1,6,2,'Hola','text',NULL,'sent',NULL,'2026-04-01 05:02:05','2026-04-01 05:02:05',NULL,NULL,'provider','user'),
(62,1,6,2,'Uuuu','text',NULL,'sent',NULL,'2026-04-01 05:02:16','2026-04-01 05:02:16',NULL,NULL,'provider','user'),
(63,1,2,6,'Holssss','text',NULL,'sent',NULL,'2026-04-01 05:03:43','2026-04-01 05:03:43',NULL,NULL,'user','provider'),
(64,1,6,2,'Holxdf','text',NULL,'sent',NULL,'2026-04-01 05:03:49','2026-04-01 05:03:49',NULL,NULL,'provider','user'),
(65,1,2,6,'Holaas','text',NULL,'sent',NULL,'2026-04-01 05:05:24','2026-04-01 05:05:24',NULL,NULL,'user','provider'),
(66,1,6,2,'Honhhj','text',NULL,'sent',NULL,'2026-04-01 05:05:39','2026-04-01 05:05:39',NULL,NULL,'provider','user'),
(67,1,6,2,'Jjj','text',NULL,'sent',NULL,'2026-04-01 05:07:56','2026-04-01 05:07:56',NULL,NULL,'provider','user'),
(68,1,6,2,'Uuuu','text',NULL,'sent',NULL,'2026-04-01 05:08:02','2026-04-01 05:08:02',NULL,NULL,'provider','user'),
(69,1,2,6,'Holass','text',NULL,'sent',NULL,'2026-04-01 05:15:05','2026-04-01 05:15:05',NULL,NULL,'user','provider'),
(70,1,6,2,'Holbfg','text',NULL,'sent',NULL,'2026-04-01 05:15:18','2026-04-01 05:15:18',NULL,NULL,'provider','user'),
(71,1,6,2,'Majestad','text',NULL,'sent',NULL,'2026-04-01 05:16:46','2026-04-01 05:16:46',NULL,NULL,'provider','user'),
(72,1,6,2,'Jjjjj','text',NULL,'sent',NULL,'2026-04-01 05:16:55','2026-04-01 05:16:55',NULL,NULL,'provider','user'),
(73,1,2,6,'Jujggh','text',NULL,'sent',NULL,'2026-04-01 05:17:03','2026-04-01 05:17:03',NULL,NULL,'user','provider'),
(74,1,2,6,'Yyyyyyrvcdf','text',NULL,'sent',NULL,'2026-04-01 05:17:18','2026-04-01 05:17:18',NULL,NULL,'user','provider'),
(75,1,6,2,'Kjjjhh','text',NULL,'sent',NULL,'2026-04-01 05:17:45','2026-04-01 05:17:45',NULL,NULL,'provider','user'),
(76,1,2,6,'Jshdhdhhfdbev','text',NULL,'sent',NULL,'2026-04-01 05:17:57','2026-04-01 05:17:57',NULL,NULL,'user','provider'),
(77,1,6,2,'Hola','text',NULL,'sent',NULL,'2026-04-01 05:45:05','2026-04-01 05:45:05',NULL,NULL,'provider','user'),
(78,1,6,2,'Hola','text',NULL,'sent',NULL,'2026-04-01 05:45:27','2026-04-01 05:45:27',NULL,NULL,'provider','user'),
(79,1,2,6,'Hola','text',NULL,'sent',NULL,'2026-04-01 10:53:12','2026-04-01 10:53:12',NULL,NULL,'user','provider'),
(80,1,2,6,'Hola','text',NULL,'sent',NULL,'2026-04-01 10:53:18','2026-04-01 10:53:18',NULL,NULL,'user','provider'),
(81,1,2,6,'Holahoa','text',NULL,'sent',NULL,'2026-04-01 10:53:26','2026-04-01 10:53:26',NULL,NULL,'user','provider'),
(82,1,2,6,'Hola','text',NULL,'sent',NULL,'2026-04-01 10:53:32','2026-04-01 10:53:32',NULL,NULL,'user','provider'),
(83,1,2,6,'Hola','text',NULL,'sent',NULL,'2026-04-01 10:53:38','2026-04-01 10:53:38',NULL,NULL,'user','provider'),
(84,1,2,6,'Holaaa','text',NULL,'sent',NULL,'2026-04-02 11:43:47','2026-04-02 11:43:47',NULL,NULL,'user','provider'),
(85,1,2,6,'Hollhgggg','text',NULL,'sent',NULL,'2026-04-02 11:43:57','2026-04-02 11:43:57',NULL,NULL,'user','provider'),
(86,1,6,2,'Holaas','text',NULL,'sent',NULL,'2026-04-02 11:58:29','2026-04-02 11:58:29',NULL,NULL,'provider','user'),
(87,1,6,2,'Holaaas','text',NULL,'sent',NULL,'2026-04-02 11:59:31','2026-04-02 11:59:31',NULL,NULL,'provider','user'),
(88,1,2,6,'Hkfkdjfjfjfbf','text',NULL,'sent',NULL,'2026-04-02 11:59:52','2026-04-02 11:59:52',NULL,NULL,'user','provider'),
(89,1,6,2,'Ghluggjyt','text',NULL,'sent',NULL,'2026-04-02 12:01:59','2026-04-02 12:01:59',NULL,NULL,'provider','user'),
(90,1,2,6,'Holaaaa','text',NULL,'sent',NULL,'2026-04-02 13:07:58','2026-04-02 13:07:58',NULL,NULL,'user','provider'),
(91,1,6,2,'Gfxffh','text',NULL,'sent',NULL,'2026-04-02 13:08:40','2026-04-02 13:08:40',NULL,NULL,'provider','user'),
(92,1,2,6,'Holaas','text',NULL,'sent',NULL,'2026-04-02 23:41:02','2026-04-02 23:41:02',NULL,NULL,'user','provider'),
(93,1,6,2,'Yyyyyyyyyyy','text',NULL,'sent',NULL,'2026-04-03 09:53:09','2026-04-03 09:53:09',NULL,NULL,'provider','user'),
(94,1,2,6,'Hjjhhhhh','text',NULL,'sent',NULL,'2026-04-03 09:53:27','2026-04-03 09:53:27',NULL,NULL,'user','provider'),
(95,1,6,2,'Holjhgh','text',NULL,'sent',NULL,'2026-04-03 09:55:32','2026-04-03 09:55:32',NULL,NULL,'provider','user'),
(96,1,6,2,'Gatoooo','text',NULL,'sent',NULL,'2026-04-03 10:02:12','2026-04-03 10:02:12',NULL,NULL,'provider','user'),
(97,1,6,2,'Endejooo','text',NULL,'sent',NULL,'2026-04-03 10:02:26','2026-04-03 10:02:26',NULL,NULL,'provider','user'),
(98,1,6,2,'Ooooii','text',NULL,'sent',NULL,'2026-04-03 10:02:35','2026-04-03 10:02:35',NULL,NULL,'provider','user'),
(99,1,6,2,'Jjjjhhg','text',NULL,'sent',NULL,'2026-04-03 10:02:45','2026-04-03 10:02:45',NULL,NULL,'provider','user'),
(100,1,6,2,'Holyhxbdjffjfjfjjfjf','text',NULL,'sent',NULL,'2026-04-06 20:09:38','2026-04-06 20:09:38',NULL,NULL,'provider','user'),
(101,1,6,2,'Holdndjdjfjffj','text',NULL,'sent',NULL,'2026-04-06 20:09:52','2026-04-06 20:09:52',NULL,NULL,'provider','user'),
(102,1,2,6,'Hghhhhghh','text',NULL,'sent',NULL,'2026-04-06 20:10:04','2026-04-06 20:10:04',NULL,NULL,'user','provider'),
(103,1,2,6,'Holasggg','text',NULL,'sent',NULL,'2026-04-06 20:10:14','2026-04-06 20:10:14',NULL,NULL,'user','provider'),
(104,1,6,2,'Kqqwwqqqqqqqqqqqq','text',NULL,'sent',NULL,'2026-04-06 20:10:26','2026-04-06 20:10:26',NULL,NULL,'provider','user'),
(105,1,6,2,'Hola','text',NULL,'sent',NULL,'2026-04-06 20:11:00','2026-04-06 20:11:00',NULL,NULL,'provider','user'),
(106,1,6,2,'Holaaaaaa','text',NULL,'sent',NULL,'2026-04-06 20:11:19','2026-04-06 20:11:19',NULL,NULL,'provider','user'),
(107,1,6,2,'Jjjjj','text',NULL,'sent',NULL,'2026-04-06 20:11:50','2026-04-06 20:11:50',NULL,NULL,'provider','user'),
(108,1,6,2,'Hag','text',NULL,'sent',NULL,'2026-04-06 22:51:20','2026-04-06 22:51:20',NULL,NULL,'provider','user'),
(109,1,2,6,'Ooooooooo','text',NULL,'sent',NULL,'2026-04-06 22:51:28','2026-04-06 22:51:28',NULL,NULL,'user','provider'),
(110,1,2,6,'Kkkkkkm','text',NULL,'sent',NULL,'2026-04-06 22:51:57','2026-04-06 22:51:57',NULL,NULL,'user','provider'),
(111,1,6,2,'Jhhhhhh','text',NULL,'sent',NULL,'2026-04-06 22:52:05','2026-04-06 22:52:05',NULL,NULL,'provider','user'),
(112,1,6,2,'Yyyyly','text',NULL,'sent',NULL,'2026-04-06 22:52:21','2026-04-06 22:52:21',NULL,NULL,'provider','user'),
(113,1,6,2,'Gggggh','text',NULL,'sent',NULL,'2026-04-06 22:53:17','2026-04-06 22:53:17',NULL,NULL,'provider','user'),
(114,1,6,2,'Hhhhgf','text',NULL,'sent',NULL,'2026-04-06 22:54:10','2026-04-06 22:54:10',NULL,NULL,'provider','user'),
(115,1,6,2,'Hhhhhhh','text',NULL,'sent',NULL,'2026-04-06 23:32:04','2026-04-06 23:32:04',NULL,NULL,'provider','user'),
(116,1,2,6,'Hhjjjjj','text',NULL,'sent',NULL,'2026-04-06 23:32:12','2026-04-06 23:32:12',NULL,NULL,'user','provider'),
(117,1,6,2,'Bhhhhh','text',NULL,'sent',NULL,'2026-04-06 23:32:24','2026-04-06 23:32:24',NULL,NULL,'provider','user'),
(118,1,2,6,'Oooooooooooooo','text',NULL,'sent',NULL,'2026-04-06 23:32:31','2026-04-06 23:32:31',NULL,NULL,'user','provider'),
(119,1,2,6,'Jjjjjjh','text',NULL,'sent',NULL,'2026-04-06 23:32:40','2026-04-06 23:32:40',NULL,NULL,'user','provider'),
(120,1,6,2,'Yyyyyyyy','text',NULL,'sent',NULL,'2026-04-06 23:32:59','2026-04-06 23:32:59',NULL,NULL,'provider','user'),
(121,1,2,6,'Hhhol','text',NULL,'sent',NULL,'2026-04-06 23:33:33','2026-04-06 23:33:33',NULL,NULL,'user','provider'),
(122,1,2,6,'Iiiii','text',NULL,'sent',NULL,'2026-04-06 23:33:49','2026-04-06 23:33:49',NULL,NULL,'user','provider'),
(123,1,6,2,'Uuuuuu','text',NULL,'sent',NULL,'2026-04-06 23:34:01','2026-04-06 23:34:01',NULL,NULL,'provider','user'),
(124,1,2,6,'Oopopo','text',NULL,'sent',NULL,'2026-04-06 23:34:20','2026-04-06 23:34:20',NULL,NULL,'user','provider'),
(125,1,2,6,'Uujkhhh','text',NULL,'sent',NULL,'2026-04-06 23:34:47','2026-04-06 23:34:47',NULL,NULL,'user','provider'),
(126,1,2,6,'Oooooo','text',NULL,'sent',NULL,'2026-04-06 23:35:48','2026-04-06 23:35:48',NULL,NULL,'user','provider'),
(127,1,2,6,'Ooooo','text',NULL,'sent',NULL,'2026-04-06 23:36:00','2026-04-06 23:36:00',NULL,NULL,'user','provider'),
(128,1,2,6,'Hola','text',NULL,'sent',NULL,'2026-04-07 10:42:42','2026-04-07 10:42:42',NULL,NULL,'user','provider'),
(129,1,6,2,'Hhhjhhgghg','text',NULL,'sent',NULL,'2026-04-08 02:43:38','2026-04-08 02:43:38',NULL,NULL,'provider','user'),
(130,1,6,2,'Holjgggtttt','text',NULL,'sent',NULL,'2026-04-08 02:45:21','2026-04-08 02:45:21',NULL,NULL,'provider','user'),
(131,1,6,2,'Jesus','text',NULL,'sent',NULL,'2026-04-08 02:45:31','2026-04-08 02:45:31',NULL,NULL,'provider','user'),
(132,1,2,6,'Que pasó vivi','text',NULL,'sent',NULL,'2026-04-08 02:45:43','2026-04-08 02:45:43',NULL,NULL,'user','provider'),
(133,1,6,2,'Ffff','text',NULL,'sent',NULL,'2026-04-08 02:46:14','2026-04-08 02:46:14',NULL,NULL,'provider','user'),
(134,1,2,6,'Olol','text',NULL,'sent',NULL,'2026-04-08 02:46:22','2026-04-08 02:46:22',NULL,NULL,'user','provider'),
(135,1,2,6,'Hey','text',NULL,'sent',NULL,'2026-04-08 02:46:34','2026-04-08 02:46:34',NULL,NULL,'user','provider'),
(136,1,6,2,'Hlsgg','text',NULL,'sent',NULL,'2026-04-08 02:46:45','2026-04-08 02:46:45',NULL,NULL,'provider','user'),
(137,1,2,6,'Kkkkk','text',NULL,'sent',NULL,'2026-04-08 02:46:50','2026-04-08 02:46:50',NULL,NULL,'user','provider'),
(138,1,2,6,'Llllll','text',NULL,'sent',NULL,'2026-04-08 02:47:03','2026-04-08 02:47:03',NULL,NULL,'user','provider'),
(139,1,6,2,'Jjjjj','text',NULL,'sent',NULL,'2026-04-08 02:47:15','2026-04-08 02:47:15',NULL,NULL,'provider','user'),
(140,1,6,2,'Holass','text',NULL,'sent',NULL,'2026-04-08 02:50:41','2026-04-08 02:50:41',NULL,NULL,'provider','user'),
(141,1,2,6,'Llllll','text',NULL,'sent',NULL,'2026-04-08 02:50:47','2026-04-08 02:50:47',NULL,NULL,'user','provider'),
(142,1,2,6,'Llloplpoo','text',NULL,'sent',NULL,'2026-04-08 02:50:57','2026-04-08 02:50:57',NULL,NULL,'user','provider'),
(143,1,6,2,'Holjgggf','text',NULL,'sent',NULL,'2026-04-08 02:51:06','2026-04-08 02:51:06',NULL,NULL,'provider','user'),
(144,1,6,2,'Hhjhgfggg','text',NULL,'sent',NULL,'2026-04-08 02:54:51','2026-04-08 02:54:51',NULL,NULL,'provider','user'),
(145,1,6,2,'Jjjjfhhtt','text',NULL,'sent',NULL,'2026-04-08 02:55:00','2026-04-08 02:55:00',NULL,NULL,'provider','user'),
(146,1,2,6,'Jjghjhhh','text',NULL,'sent',NULL,'2026-04-08 02:55:07','2026-04-08 02:55:07',NULL,NULL,'user','provider'),
(147,1,6,2,'Holjhh😒😒😒👺👺👺👺👺','text',NULL,'sent',NULL,'2026-04-08 03:44:04','2026-04-08 03:44:04',NULL,NULL,'provider','user'),
(148,1,2,6,'Jlkknnbnnlk💘💘💘💘💘💘💘','text',NULL,'sent',NULL,'2026-04-08 03:44:31','2026-04-08 03:44:31',NULL,NULL,'user','provider'),
(149,1,6,2,'Holfggfghgxc😍🎂🎂😍🎂','text',NULL,'sent',NULL,'2026-04-08 04:26:44','2026-04-08 04:26:44',NULL,NULL,'provider','user'),
(150,1,2,6,'❤️🐊🐊❤️❤️🐊❤️','text',NULL,'sent',NULL,'2026-04-08 04:26:57','2026-04-08 04:26:57',NULL,NULL,'user','provider'),
(151,1,6,2,'Hobfjghhffv','text',NULL,'sent',NULL,'2026-04-08 04:27:21','2026-04-08 04:27:21',NULL,NULL,'provider','user'),
(152,1,2,6,'Holavfbvdbvg','text',NULL,'sent',NULL,'2026-04-08 04:27:30','2026-04-08 04:27:30',NULL,NULL,'user','provider'),
(153,1,6,2,'Gbgjhfbgg','text',NULL,'sent',NULL,'2026-04-08 04:27:42','2026-04-08 04:27:42',NULL,NULL,'provider','user'),
(154,1,2,6,'Hljkhgnhv','text',NULL,'sent',NULL,'2026-04-08 04:27:51','2026-04-08 04:27:51',NULL,NULL,'user','provider'),
(155,1,6,2,'Yuyghgrgt','text',NULL,'sent',NULL,'2026-04-08 04:27:59','2026-04-08 04:27:59',NULL,NULL,'provider','user'),
(156,1,2,6,'Hkjgbbdhhrrfv','text',NULL,'sent',NULL,'2026-04-08 04:28:06','2026-04-08 04:28:06',NULL,NULL,'user','provider'),
(157,1,6,2,'Gjgxjuuuuuu','text',NULL,'sent',NULL,'2026-04-08 04:29:30','2026-04-08 04:29:30',NULL,NULL,'provider','user'),
(158,1,2,6,'Uyghgfhhh','text',NULL,'sent',NULL,'2026-04-08 04:29:37','2026-04-08 04:29:37',NULL,NULL,'user','provider'),
(159,1,6,2,'Hkjhgbvg','text',NULL,'sent',NULL,'2026-04-08 04:29:47','2026-04-08 04:29:47',NULL,NULL,'provider','user'),
(160,1,2,6,'Kkhkncb','text',NULL,'sent',NULL,'2026-04-08 04:29:54','2026-04-08 04:29:54',NULL,NULL,'user','provider'),
(161,1,2,6,'Holaa','text',NULL,'sent',NULL,'2026-04-10 20:10:34','2026-04-10 20:10:34',NULL,NULL,'user','provider'),
(162,1,2,6,'Holaas','text',NULL,'sent',NULL,'2026-04-10 20:52:40','2026-04-10 20:52:40',NULL,NULL,'user','provider'),
(163,1,6,2,'Holassss','text',NULL,'sent',NULL,'2026-04-10 20:52:54','2026-04-10 20:52:54',NULL,NULL,'provider','user'),
(164,1,2,6,'Ggtkhfbgrkkkk','text',NULL,'sent',NULL,'2026-04-10 20:53:21','2026-04-10 20:53:21',NULL,NULL,'user','provider'),
(165,1,6,2,'Yyyuuu','text',NULL,'sent',NULL,'2026-04-10 20:53:34','2026-04-10 20:53:34',NULL,NULL,'provider','user'),
(166,1,2,6,'Tuyhfggd😍😍😍😍😍','text',NULL,'sent',NULL,'2026-04-10 20:53:48','2026-04-10 20:53:48',NULL,NULL,'user','provider'),
(167,1,2,6,'Oooooohc😡😡😡😡','text',NULL,'sent',NULL,'2026-04-10 20:54:02','2026-04-10 20:54:02',NULL,NULL,'user','provider'),
(168,1,6,2,'Llljj','text',NULL,'sent',NULL,'2026-04-10 20:54:14','2026-04-10 20:54:14',NULL,NULL,'provider','user'),
(169,1,6,2,'Oooyhhg','text',NULL,'sent',NULL,'2026-04-10 20:54:22','2026-04-10 20:54:22',NULL,NULL,'provider','user'),
(170,1,6,2,'Kkhhhcvv','text',NULL,'sent',NULL,'2026-04-10 20:54:32','2026-04-10 20:54:32',NULL,NULL,'provider','user'),
(171,1,6,2,'Hhgggcvv','text',NULL,'sent',NULL,'2026-04-10 20:54:43','2026-04-10 20:54:43',NULL,NULL,'provider','user'),
(172,1,6,2,'Khjhcc v','text',NULL,'sent',NULL,'2026-04-10 20:54:50','2026-04-10 20:54:50',NULL,NULL,'provider','user'),
(173,1,2,6,'Hkhgghff','text',NULL,'sent',NULL,'2026-04-10 20:54:58','2026-04-10 20:54:58',NULL,NULL,'user','provider'),
(174,1,2,6,'Jjjjj','text',NULL,'sent',NULL,'2026-04-10 20:55:06','2026-04-10 20:55:06',NULL,NULL,'user','provider'),
(175,1,2,6,'Jjjjjggff','text',NULL,'sent',NULL,'2026-04-10 20:55:14','2026-04-10 20:55:14',NULL,NULL,'user','provider'),
(176,1,2,6,'Hhgggg','text',NULL,'sent',NULL,'2026-04-10 20:55:24','2026-04-10 20:55:24',NULL,NULL,'user','provider'),
(177,1,2,6,'Hhgggg','text',NULL,'sent',NULL,'2026-04-10 20:55:31','2026-04-10 20:55:31',NULL,NULL,'user','provider'),
(178,1,2,6,'Hhggggg','text',NULL,'sent',NULL,'2026-04-10 20:55:41','2026-04-10 20:55:41',NULL,NULL,'user','provider'),
(179,1,6,2,'Nmjhhjh','text',NULL,'sent',NULL,'2026-04-10 20:55:48','2026-04-10 20:55:48',NULL,NULL,'provider','user'),
(180,1,6,2,'Kkhvcv','text',NULL,'sent',NULL,'2026-04-10 20:55:56','2026-04-10 20:55:56',NULL,NULL,'provider','user'),
(181,1,2,6,'Jhhfchgf','text',NULL,'sent',NULL,'2026-04-10 20:56:08','2026-04-10 20:56:08',NULL,NULL,'user','provider'),
(182,1,6,2,'Kkkkvcvhgh','text',NULL,'sent',NULL,'2026-04-10 20:56:15','2026-04-10 20:56:15',NULL,NULL,'provider','user'),
(183,1,6,2,'Holaass','text',NULL,'sent',NULL,'2026-04-11 17:26:09','2026-04-11 17:26:09',NULL,NULL,'provider','user'),
(184,1,2,6,'Holsssss','text',NULL,'sent',NULL,'2026-04-11 17:26:28','2026-04-11 17:26:28',NULL,NULL,'user','provider'),
(185,1,6,2,'Holass','text',NULL,'sent',NULL,'2026-04-11 17:26:38','2026-04-11 17:26:38',NULL,NULL,'provider','user'),
(186,1,2,6,'Holaasssss','text',NULL,'sent',NULL,'2026-04-11 17:26:46','2026-04-11 17:26:46',NULL,NULL,'user','provider'),
(187,1,2,6,'Hhhhhh','text',NULL,'sent',NULL,'2026-04-11 17:26:53','2026-04-11 17:26:53',NULL,NULL,'user','provider'),
(188,1,2,6,'Iiiiiiiytty','text',NULL,'sent',NULL,'2026-04-11 17:27:00','2026-04-11 17:27:00',NULL,NULL,'user','provider'),
(189,1,2,6,'Uututhjgg','text',NULL,'sent',NULL,'2026-04-11 17:27:12','2026-04-11 17:27:12',NULL,NULL,'user','provider'),
(190,1,6,2,'Tjgtuytgguh','text',NULL,'sent',NULL,'2026-04-11 17:27:22','2026-04-11 17:27:22',NULL,NULL,'provider','user'),
(191,1,2,6,'Gato','text',NULL,'sent',NULL,'2026-04-11 17:27:34','2026-04-11 17:27:34',NULL,NULL,'user','provider'),
(192,1,6,2,'👺👺👺👺👺👺👺','text',NULL,'sent',NULL,'2026-04-11 17:28:13','2026-04-11 17:28:13',NULL,NULL,'provider','user'),
(193,1,2,6,'🌎🌎🌎🌎🌎','text',NULL,'sent',NULL,'2026-04-11 17:28:27','2026-04-11 17:28:27',NULL,NULL,'user','provider'),
(194,1,2,6,'J👌🏾👌🏾👌🏾👌🏾👌🏾👌🏾👌🏾👌🏾','text',NULL,'sent',NULL,'2026-04-11 17:29:14','2026-04-11 17:29:14',NULL,NULL,'user','provider'),
(195,1,2,6,'Uuyjhh','text',NULL,'sent',NULL,'2026-04-11 17:30:09','2026-04-11 17:30:09',NULL,NULL,'user','provider'),
(196,1,6,2,'Yyyyyyf','text',NULL,'sent',NULL,'2026-04-11 17:30:18','2026-04-11 17:30:18',NULL,NULL,'provider','user'),
(197,1,2,6,'Jhjgcg','text',NULL,'sent',NULL,'2026-04-11 17:30:24','2026-04-11 17:30:24',NULL,NULL,'user','provider'),
(198,1,6,2,'Ygdgghgf','text',NULL,'sent',NULL,'2026-04-11 17:30:43','2026-04-11 17:30:43',NULL,NULL,'provider','user'),
(199,1,6,2,'Ttttttttt','text',NULL,'sent',NULL,'2026-04-11 17:30:54','2026-04-11 17:30:54',NULL,NULL,'provider','user'),
(200,1,6,2,'Uyjtgcdgffxvv','text',NULL,'sent',NULL,'2026-04-11 17:31:07','2026-04-11 17:31:07',NULL,NULL,'provider','user'),
(201,1,6,2,'Hoolss','text',NULL,'sent',NULL,'2026-04-11 17:31:19','2026-04-11 17:31:19',NULL,NULL,'provider','user'),
(202,1,6,2,'Jjffggfdc','text',NULL,'sent',NULL,'2026-04-11 17:31:28','2026-04-11 17:31:28',NULL,NULL,'provider','user'),
(203,1,6,2,'Kkjjhggvgf','text',NULL,'sent',NULL,'2026-04-11 17:31:41','2026-04-11 17:31:41',NULL,NULL,'provider','user'),
(204,1,6,2,'Iolpiugfrcf','text',NULL,'sent',NULL,'2026-04-11 17:31:50','2026-04-11 17:31:50',NULL,NULL,'provider','user'),
(205,1,6,2,'Hggthgrrth','text',NULL,'sent',NULL,'2026-04-11 17:32:06','2026-04-11 17:32:06',NULL,NULL,'provider','user'),
(206,1,2,6,'Hjhggcvbh','text',NULL,'sent',NULL,'2026-04-11 17:32:17','2026-04-11 17:32:17',NULL,NULL,'user','provider'),
(207,1,2,6,'Ljkuhvv','text',NULL,'sent',NULL,'2026-04-11 17:32:24','2026-04-11 17:32:24',NULL,NULL,'user','provider'),
(208,1,2,6,'Jjghjhhh','text',NULL,'sent',NULL,'2026-04-11 17:32:32','2026-04-11 17:32:32',NULL,NULL,'user','provider'),
(209,1,2,6,'Hkjggjhff','text',NULL,'sent',NULL,'2026-04-11 17:32:45','2026-04-11 17:32:45',NULL,NULL,'user','provider'),
(210,1,2,6,'Ujhggvgg','text',NULL,'sent',NULL,'2026-04-11 17:32:53','2026-04-11 17:32:53',NULL,NULL,'user','provider'),
(211,1,2,6,'Holdjhdfh','text',NULL,'sent',NULL,'2026-04-11 17:33:20','2026-04-11 17:33:20',NULL,NULL,'user','provider'),
(212,1,2,6,'Hok','text',NULL,'sent',NULL,'2026-04-11 17:33:31','2026-04-11 17:33:31',NULL,NULL,'user','provider'),
(213,1,2,6,'Hjfofbfbfbfb','text',NULL,'sent',NULL,'2026-04-11 17:33:41','2026-04-11 17:33:41',NULL,NULL,'user','provider'),
(214,1,2,6,'Hdkdodfjfjf','text',NULL,'sent',NULL,'2026-04-11 17:33:49','2026-04-11 17:33:49',NULL,NULL,'user','provider'),
(215,1,2,6,'Jdjdhhdyfhdh','text',NULL,'sent',NULL,'2026-04-11 17:34:01','2026-04-11 17:34:01',NULL,NULL,'user','provider'),
(216,1,2,6,'Hgdjdhh','text',NULL,'sent',NULL,'2026-04-11 17:34:17','2026-04-11 17:34:17',NULL,NULL,'user','provider'),
(217,1,2,6,'Holsjsdhdhf','text',NULL,'sent',NULL,'2026-04-11 17:34:32','2026-04-11 17:34:32',NULL,NULL,'user','provider'),
(218,5,2,1,'Holasss','text',NULL,'sent',NULL,'2026-05-24 22:53:46','2026-05-24 22:53:46',NULL,NULL,'user','admin');
/*!40000 ALTER TABLE `messages` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=196 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `notifications` VALUES
(1,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-04 15:05:15'),
(2,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-04 15:08:44'),
(3,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-04 15:10:53'),
(4,6,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/10\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":10}',1,'2026-05-04 15:11:05'),
(5,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-04 15:12:35'),
(6,6,2,'user','Proveedor ocupado','El proveedor está ocupado temporalmente','{\"url\":\"\\/requests\",\"action\":\"view_request\",\"notification_type\":\"general\"}',1,'2026-05-04 15:12:50'),
(7,6,2,'user','Proveedor ocupado','El proveedor está ocupado temporalmente','{\"url\":\"\\/requests\",\"action\":\"view_request\",\"notification_type\":\"general\"}',1,'2026-05-04 15:12:50'),
(8,6,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/12\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":12}',1,'2026-05-04 15:12:52'),
(9,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-04 15:17:17'),
(10,2,6,'provider','Pago registrado','El cliente pagará en efectivo','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"default\",\"notification_type\":\"general\",\"request_id\":\"25\"}',1,'2026-05-05 03:01:05'),
(11,2,6,'provider','Pago registrado','Cliente subió comprobante – verifica el pago','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"default\",\"notification_type\":\"general\",\"request_id\":\"24\"}',1,'2026-05-05 03:02:22'),
(12,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-07 04:35:17'),
(13,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-10 10:11:34'),
(14,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-10 10:19:19'),
(15,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-10 10:22:04'),
(16,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-10 10:53:31'),
(17,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-10 10:55:48'),
(18,6,2,'user','Proveedor ocupado','El proveedor está ocupado temporalmente','{\"url\":\"\\/requests\",\"action\":\"view_request\",\"notification_type\":\"general\"}',1,'2026-05-10 10:56:16'),
(19,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-12 14:45:18'),
(20,6,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/12\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":12}',1,'2026-05-12 14:45:48'),
(21,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-13 01:33:07'),
(22,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-13 01:40:05'),
(23,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-13 01:54:07'),
(24,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-13 04:05:50'),
(25,6,2,'user','Proveedor ocupado','El proveedor está ocupado temporalmente','{\"url\":\"\\/requests\",\"action\":\"view_request\",\"notification_type\":\"general\"}',1,'2026-05-13 04:06:12'),
(26,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-13 04:27:05'),
(27,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-13 04:29:06'),
(28,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-13 10:40:00'),
(29,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-13 10:41:40'),
(30,6,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/10\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":10}',1,'2026-05-13 10:51:22'),
(31,2,6,'provider','Pago registrado','El cliente pagará en efectivo','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"default\",\"notification_type\":\"general\",\"request_id\":\"41\"}',1,'2026-05-15 13:00:01'),
(32,2,6,'provider','Pago registrado','El cliente pagará en efectivo','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"default\",\"notification_type\":\"general\",\"request_id\":\"41\"}',1,'2026-05-15 13:03:22'),
(33,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-15 13:06:07'),
(34,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-15 18:13:51'),
(35,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-15 18:17:50'),
(36,6,2,'user','Proveedor ocupado','El proveedor está ocupado temporalmente','{\"url\":\"\\/requests\",\"action\":\"view_request\",\"notification_type\":\"general\"}',1,'2026-05-15 18:17:57'),
(37,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-15 19:13:20'),
(38,6,2,'user','Proveedor ocupado','El proveedor está ocupado temporalmente','{\"url\":\"\\/requests\",\"action\":\"view_request\",\"notification_type\":\"general\"}',1,'2026-05-15 19:14:02'),
(39,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-16 13:54:16'),
(40,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-16 14:26:40'),
(41,6,2,'user','Proveedor ocupado','El proveedor está ocupado temporalmente','{\"url\":\"\\/requests\",\"action\":\"view_request\",\"notification_type\":\"general\"}',1,'2026-05-16 14:26:48'),
(42,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-16 14:35:20'),
(43,6,2,'user','Proveedor ocupado','El proveedor está ocupado temporalmente','{\"url\":\"\\/requests\",\"action\":\"view_request\",\"notification_type\":\"general\"}',1,'2026-05-16 14:35:23'),
(44,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-16 16:51:45'),
(45,6,2,'user','Proveedor ocupado','El proveedor está ocupado temporalmente','{\"url\":\"\\/requests\",\"action\":\"view_request\",\"notification_type\":\"general\"}',1,'2026-05-16 16:51:49'),
(46,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-16 16:52:02'),
(47,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-16 16:52:20'),
(48,6,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/11\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":11}',1,'2026-05-16 16:52:22'),
(49,2,6,'provider','Pago registrado','El cliente pagará en efectivo','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"default\",\"notification_type\":\"general\",\"request_id\":\"51\"}',1,'2026-05-16 16:52:32'),
(50,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-16 18:42:28'),
(51,6,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/12\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":12}',1,'2026-05-16 18:42:32'),
(52,2,6,'provider','Pago registrado','El cliente pagará en efectivo','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"default\",\"notification_type\":\"general\",\"request_id\":\"52\"}',1,'2026-05-16 18:42:41'),
(53,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-16 19:06:21'),
(54,6,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/11\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":11}',1,'2026-05-16 19:06:30'),
(55,2,6,'provider','Pago registrado','El cliente pagará en efectivo','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"default\",\"notification_type\":\"general\",\"request_id\":\"53\"}',1,'2026-05-16 19:06:37'),
(56,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-17 01:51:03'),
(57,6,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/11\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":11}',1,'2026-05-17 01:51:12'),
(58,2,6,'provider','Pago registrado','El cliente pagará en efectivo','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"default\",\"notification_type\":\"general\",\"request_id\":\"54\"}',1,'2026-05-17 01:51:17'),
(59,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-17 02:50:19'),
(60,6,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/11\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":11}',1,'2026-05-17 02:50:24'),
(61,2,6,'provider','Pago registrado','El cliente pagará en efectivo','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"default\",\"notification_type\":\"general\",\"request_id\":\"55\"}',1,'2026-05-17 02:50:30'),
(62,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-17 10:15:42'),
(63,6,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/11\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":11}',1,'2026-05-17 10:16:01'),
(64,2,6,'provider','Pago registrado','El cliente pagará en efectivo','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"default\",\"notification_type\":\"general\",\"request_id\":\"56\"}',1,'2026-05-17 10:16:16'),
(65,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-17 10:21:21'),
(66,6,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/11\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":11}',1,'2026-05-17 10:21:46'),
(67,2,6,'provider','Pago registrado','El cliente pagará en efectivo','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"default\",\"notification_type\":\"general\",\"request_id\":\"57\"}',1,'2026-05-17 10:22:03'),
(68,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-17 12:42:48'),
(69,6,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/11\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":11}',1,'2026-05-17 12:42:53'),
(70,2,6,'provider','Pago registrado','El cliente pagará en efectivo','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/dashboard\\/provider\",\"action\":\"verify_payment\",\"request_id\":58,\"payment_id\":52}',1,'2026-05-17 12:42:58'),
(71,6,2,'user','Pago confirmado','El proveedor certificó que recibió tu pago','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/58\",\"action\":\"view_order\",\"request_id\":58,\"payment_id\":52}',1,'2026-05-17 12:43:26'),
(72,NULL,6,'provider','¡Tienes una nueva evaluación!','Un cliente te calificó con 4 estrellas.','{\"route\":\"\\/reviews\"}',1,'2026-05-17 12:44:06'),
(73,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-17 12:58:53'),
(74,6,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/12\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":12}',1,'2026-05-17 12:59:01'),
(75,2,6,'provider','Pago registrado','El cliente pagará en efectivo','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/dashboard\\/provider\",\"action\":\"verify_payment\",\"request_id\":59,\"payment_id\":53}',1,'2026-05-17 12:59:06'),
(76,6,2,'user','Pago confirmado','El proveedor certificó que recibió tu pago','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/59\",\"action\":\"view_order\",\"request_id\":59,\"payment_id\":53}',1,'2026-05-17 12:59:25'),
(77,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-17 13:57:09'),
(78,6,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/11\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":11}',1,'2026-05-17 13:57:13'),
(79,2,6,'provider','Pago registrado','El cliente pagará en efectivo','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/dashboard\\/provider\",\"action\":\"verify_payment\",\"request_id\":60,\"payment_id\":54}',1,'2026-05-17 13:57:23'),
(80,6,2,'user','Pago confirmado','El proveedor certificó que recibió tu pago','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/60\",\"action\":\"view_order\",\"request_id\":60,\"payment_id\":54}',1,'2026-05-17 13:58:24'),
(81,NULL,6,'provider','¡Tienes una nueva evaluación!','Un cliente te calificó con 3 estrellas.','{\"route\":\"\\/reviews\"}',1,'2026-05-17 13:59:03'),
(82,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-17 14:40:08'),
(83,6,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/12\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":12}',1,'2026-05-17 14:40:15'),
(84,2,6,'provider','Pago registrado','El cliente pagará en efectivo','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/dashboard\\/provider\",\"action\":\"verify_payment\",\"request_id\":61,\"payment_id\":55}',1,'2026-05-17 14:40:22'),
(85,6,2,'user','Pago confirmado','El proveedor certificó que recibió tu pago','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/61\",\"action\":\"view_order\",\"request_id\":61,\"payment_id\":55}',1,'2026-05-17 15:06:53'),
(86,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-17 22:51:29'),
(87,6,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/11\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":11}',1,'2026-05-17 22:51:40'),
(88,2,6,'provider','Pago registrado','El cliente pagará en efectivo','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/dashboard\\/provider\",\"action\":\"verify_payment\",\"request_id\":62,\"payment_id\":56}',1,'2026-05-17 22:53:30'),
(89,6,2,'user','Pago confirmado','El proveedor certificó que recibió tu pago','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/62\",\"action\":\"view_order\",\"request_id\":62,\"payment_id\":56}',1,'2026-05-17 22:53:44'),
(90,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-17 22:54:49'),
(91,6,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/12\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":12}',1,'2026-05-17 22:55:00'),
(92,2,6,'provider','Pago registrado','El cliente pagará en efectivo','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/dashboard\\/provider\",\"action\":\"verify_payment\",\"request_id\":63,\"payment_id\":57}',1,'2026-05-17 22:55:10'),
(93,6,2,'user','Pago confirmado','El proveedor certificó que recibió tu pago','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/63\",\"action\":\"view_order\",\"request_id\":63,\"payment_id\":57}',1,'2026-05-17 22:55:44'),
(94,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-17 23:53:05'),
(95,6,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/12\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":12}',1,'2026-05-17 23:53:11'),
(96,2,6,'provider','Pago registrado','El cliente pagará en efectivo','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/dashboard\\/provider\",\"action\":\"verify_payment\",\"request_id\":64,\"payment_id\":58}',1,'2026-05-17 23:53:18'),
(97,6,2,'user','Pago confirmado','El proveedor certificó que recibió tu pago','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/64\",\"action\":\"view_order\",\"request_id\":64,\"payment_id\":58}',1,'2026-05-17 23:53:59'),
(98,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-18 00:09:08'),
(99,6,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/12\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":12}',1,'2026-05-18 00:09:19'),
(100,2,6,'provider','Pago registrado','El cliente pagará en efectivo','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/dashboard\\/provider\",\"action\":\"verify_payment\",\"request_id\":65,\"payment_id\":59}',1,'2026-05-18 00:09:23'),
(101,6,2,'user','Pago confirmado','El proveedor certificó que recibió tu pago','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/65\",\"action\":\"view_order\",\"request_id\":65,\"payment_id\":59}',1,'2026-05-18 00:09:33'),
(102,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-18 00:52:05'),
(103,6,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/12\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":12}',1,'2026-05-18 00:52:09'),
(104,2,6,'provider','Pago registrado','El cliente pagará en efectivo','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/dashboard\\/provider\",\"action\":\"verify_payment\",\"request_id\":66,\"payment_id\":60}',1,'2026-05-18 00:52:18'),
(105,6,2,'user','Pago confirmado','El proveedor certificó que recibió tu pago','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/66\",\"action\":\"view_order\",\"request_id\":66,\"payment_id\":60}',1,'2026-05-18 00:52:29'),
(106,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-18 01:16:47'),
(107,6,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/11\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":11}',1,'2026-05-18 01:16:50'),
(108,2,6,'provider','Pago registrado','El cliente pagará en efectivo','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/dashboard\\/provider\",\"action\":\"verify_payment\",\"request_id\":67,\"payment_id\":61}',1,'2026-05-18 01:16:57'),
(109,6,2,'user','Pago confirmado','El proveedor certificó que recibió tu pago','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/67\",\"action\":\"view_order\",\"request_id\":67,\"payment_id\":61}',1,'2026-05-18 01:17:05'),
(110,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-18 01:43:17'),
(111,6,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/12\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":12}',1,'2026-05-18 01:43:20'),
(112,2,6,'provider','Pago registrado','El cliente pagará en efectivo','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/dashboard\\/provider\",\"action\":\"verify_payment\",\"request_id\":68,\"payment_id\":62}',1,'2026-05-18 01:43:26'),
(113,6,2,'user','Pago confirmado','El proveedor certificó que recibió tu pago','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/68\",\"action\":\"view_order\",\"request_id\":68,\"payment_id\":62}',1,'2026-05-18 01:43:33'),
(114,6,6,'provider','¡Tienes una nueva evaluación!','Un cliente te calificó con 3 estrellas.','{\"type\":\"review\",\"notification_type\":\"review_received\",\"route\":\"\\/reviews\",\"url\":\"\\/dashboard\\/provider\\/reviews\",\"action\":\"view_reviews\"}',1,'2026-05-18 01:44:01'),
(115,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-18 02:05:30'),
(116,6,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/11\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":11}',1,'2026-05-18 02:05:33'),
(117,2,6,'provider','Pago registrado','El cliente pagará en efectivo','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/dashboard\\/provider\",\"action\":\"verify_payment\",\"request_id\":69,\"payment_id\":63}',1,'2026-05-18 02:06:32'),
(118,6,2,'user','Pago confirmado','El proveedor certificó que recibió tu pago','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/69\",\"action\":\"view_order\",\"request_id\":69,\"payment_id\":63}',1,'2026-05-18 02:06:39'),
(119,6,2,'user','Servicio finalizado - ¡Califica tu experiencia!','El proveedor marcó el servicio como finalizado. Deja una reseña sobre tu experiencia.','{\"type\":\"rating\",\"notification_type\":\"open_rating\",\"url\":\"\\/orders\\/69\",\"action\":\"open_rating_modal\",\"request_id\":69,\"provider_id\":6,\"from_role\":\"provider\"}',1,'2026-05-18 02:06:46'),
(120,6,6,'provider','¡Tienes una nueva evaluación!','Un cliente te calificó con 3 estrellas.','{\"type\":\"review\",\"notification_type\":\"review_received\",\"route\":\"\\/reviews\",\"url\":\"\\/dashboard\\/provider\\/reviews\",\"action\":\"view_reviews\"}',1,'2026-05-18 02:07:02'),
(121,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-18 02:26:32'),
(122,6,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/11\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":11}',0,'2026-05-18 02:26:34'),
(123,2,6,'provider','Pago registrado','El cliente pagará en efectivo','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/dashboard\\/provider\",\"action\":\"verify_payment\",\"request_id\":70,\"payment_id\":64}',1,'2026-05-18 02:26:38'),
(124,6,2,'user','Pago confirmado','El proveedor certificó que recibió tu pago','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/70\",\"action\":\"view_order\",\"request_id\":70,\"payment_id\":64}',0,'2026-05-18 02:26:46'),
(125,6,2,'user','Servicio finalizado - ¡Califica tu experiencia!','El proveedor marcó el servicio como finalizado. Deja una reseña sobre tu experiencia.','{\"type\":\"rating\",\"notification_type\":\"open_rating\",\"url\":\"\\/orders\\/70\",\"action\":\"open_rating_modal\",\"request_id\":70,\"provider_id\":6,\"from_role\":\"provider\"}',0,'2026-05-18 02:26:56'),
(126,6,2,'user','Servicio finalizado','El proveedor ha finalizado el servicio. ¿Quieres calificarlo?','{\"type\":\"rating\",\"notification_type\":\"review_request\",\"url\":\"/dashboard/user\",\"action\":\"open_rating\",\"request_id\":69}',0,'2026-05-18 10:51:33'),
(127,6,2,'user','Servicio finalizado','El proveedor ha finalizado el servicio. ¿Quieres calificarlo?','{\"type\":\"rating\",\"notification_type\":\"review_request\",\"url\":\"/dashboard/user\",\"action\":\"open_rating\",\"request_id\":69}',0,'2026-05-18 10:52:07'),
(128,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-18 12:26:03'),
(129,6,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/11\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":11}',0,'2026-05-18 12:26:07'),
(130,2,6,'provider','Pago registrado','El cliente pagará en efectivo','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/dashboard\\/provider\",\"action\":\"verify_payment\",\"request_id\":71,\"payment_id\":65}',1,'2026-05-18 12:26:17'),
(131,6,2,'user','Pago confirmado','El proveedor certificó que recibió tu pago','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/71\",\"action\":\"view_order\",\"request_id\":71,\"payment_id\":65}',0,'2026-05-18 12:26:53'),
(132,6,2,'user','Servicio finalizado - ¡Califica tu experiencia!','El proveedor marcó el servicio como finalizado. Deja una reseña sobre tu experiencia.','{\"type\":\"rating\",\"notification_type\":\"open_rating\",\"url\":\"\\/orders\\/71\",\"action\":\"open_rating_modal\",\"request_id\":71,\"provider_id\":6,\"from_role\":\"provider\"}',0,'2026-05-18 12:27:10'),
(133,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',1,'2026-05-18 12:30:49'),
(134,6,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/12\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":12}',0,'2026-05-18 12:30:56'),
(135,2,6,'provider','Pago registrado','El cliente pagará en efectivo','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/dashboard\\/provider\",\"action\":\"verify_payment\",\"request_id\":72,\"payment_id\":66}',1,'2026-05-18 12:31:00'),
(136,6,2,'user','Pago confirmado','El proveedor certificó que recibió tu pago','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/72\",\"action\":\"view_order\",\"request_id\":72,\"payment_id\":66}',0,'2026-05-18 12:31:11'),
(137,6,2,'user','Servicio finalizado - ¡Califica tu experiencia!','El proveedor marcó el servicio como finalizado. Deja una reseña sobre tu experiencia.','{\"type\":\"rating\",\"notification_type\":\"open_rating\",\"url\":\"\\/orders\\/72\",\"action\":\"open_rating_modal\",\"request_id\":72,\"provider_id\":6,\"from_role\":\"provider\"}',0,'2026-05-18 12:31:30'),
(138,10,1,'admin','Nueva solicitud de servicio','El proveedor #10 ha creado el servicio \"Reparación de televisión a domicilio\". Revisa la solicitud para aprobacion',NULL,1,'2026-05-22 02:36:54'),
(139,10,1,'admin','Nueva solicitud de servicio','El proveedor #10 ha creado el servicio \"Reparación de televisión a domicilio\". Revisa la solicitud para aprobacion',NULL,1,'2026-05-22 10:28:31'),
(140,10,1,'admin','Nueva solicitud de servicio','El proveedor #10 ha creado el servicio \"Reparación de televisión a domicilio\". Revisa la solicitud para aprobacion',NULL,1,'2026-05-22 10:34:48'),
(141,10,1,'admin','Nueva solicitud de servicio','El proveedor #10 ha creado el servicio \"Reparación de televisión a domicilio\". Revisa la solicitud para aprobacion',NULL,1,'2026-05-22 10:35:11'),
(142,10,1,'admin','Nueva solicitud de servicio','El proveedor #10 ha creado el servicio \"Reparación de televisión en la puerta de su casa\". Revisa la solicitud para aprobacion',NULL,1,'2026-05-22 11:00:53'),
(143,10,1,'admin','Nueva solicitud de servicio','El proveedor #10 ha creado el servicio \"Reparación de televisión en la puerta de su casa\". Revisa la solicitud para aprobacion',NULL,1,'2026-05-22 11:01:54'),
(144,10,1,'admin','Nueva solicitud de servicio','El proveedor #10 ha creado el servicio \"Reparación de televisión en la puerta de su casa\". Revisa la solicitud para aprobacion',NULL,1,'2026-05-22 11:01:57'),
(145,10,1,'admin','Nueva solicitud de servicio','El proveedor #10 ha creado el servicio \"Reparación de televisión en la puerta de su casa\". Revisa la solicitud para aprobacion',NULL,1,'2026-05-22 11:02:01'),
(146,10,1,'admin','Nueva solicitud de servicio','El proveedor #10 ha creado el servicio \"Reparación de televisión en la puerta de su casa\". Revisa la solicitud para aprobacion',NULL,1,'2026-05-22 11:02:05'),
(147,10,1,'admin','Nueva solicitud de servicio','El proveedor #10 ha creado el servicio \"Reparación de televisión en la puerta de su casa\". Revisa la solicitud para aprobacion',NULL,1,'2026-05-22 11:02:09'),
(148,10,1,'admin','Nueva solicitud de servicio','El proveedor #10 ha creado el servicio \"Reparación de televisión en la puerta de su casa\". Revisa la solicitud para aprobacion',NULL,1,'2026-05-22 11:02:12'),
(149,10,1,'admin','Nueva solicitud de servicio','El proveedor #10 ha creado el servicio \"Reparación de televisión\". Revisa la solicitud para aprobacion',NULL,1,'2026-05-22 11:08:37'),
(150,10,1,'admin','Nueva solicitud de servicio','El proveedor #10 ha creado el servicio \"Reparación de televisión\". Revisa la solicitud para aprobacion',NULL,1,'2026-05-22 11:26:31'),
(151,10,1,'admin','Nueva solicitud de servicio','El proveedor #10 ha creado el servicio \"Reparación de televisión\". Revisa la solicitud para aprobacion',NULL,1,'2026-05-22 11:46:05'),
(152,10,1,'admin','Nueva solicitud de servicio','El proveedor #10 ha creado el servicio \"Reparación\". Revisa la solicitud para aprobacion',NULL,1,'2026-05-22 17:45:48'),
(153,NULL,1,'admin','📎 Nuevo comprobante de publicación','Angie Gutiérrez subió comprobante para \'Reparación\' - $5','{\"url\":\"\\/admin\\/service-payments\",\"action\":\"review_payment\",\"service_id\":27}',1,'2026-05-23 15:13:09'),
(154,NULL,10,'provider','❌ Comprobante rechazado','Tu comprobante para \'Reparación\' fue rechazado. Sube uno nuevo.','{\"url\":\"\\/myservices\",\"action\":\"view_services\"}',1,'2026-05-23 15:26:39'),
(155,NULL,10,'provider','❌ Comprobante rechazado','Tu comprobante para \'Reparación\' fue rechazado. Sube uno nuevo.','{\"url\":\"\\/myservices\",\"action\":\"view_services\"}',1,'2026-05-23 15:26:46'),
(156,NULL,10,'provider','❌ Comprobante rechazado','Tu comprobante para \'Reparación\' fue rechazado. Sube uno nuevo.','{\"url\":\"\\/myservices\",\"action\":\"view_services\"}',1,'2026-05-23 15:26:54'),
(157,NULL,10,'provider','❌ Comprobante rechazado','Tu comprobante para \'Reparación\' fue rechazado. Sube uno nuevo.','{\"url\":\"\\/myservices\",\"action\":\"view_services\"}',1,'2026-05-23 15:26:57'),
(158,10,1,'admin','Nueva solicitud de servicio','El proveedor #10 ha creado el servicio \"Reparación de televisión\". Revisa la solicitud para aprobacion',NULL,1,'2026-05-23 15:46:48'),
(159,NULL,1,'admin','📎 Nuevo comprobante de publicación','Angie Gutiérrez subió comprobante para \'Reparación de televisión\' - $5','{\"url\":\"\\/admin\\/service-payments\",\"action\":\"review_payment\",\"service_id\":28}',1,'2026-05-23 15:47:40'),
(160,10,1,'admin','Nueva solicitud de servicio','El proveedor #10 ha creado el servicio \"Reparación de tv\". Revisa la solicitud para aprobacion',NULL,1,'2026-05-24 02:22:07'),
(161,NULL,1,'admin','📎 Nuevo comprobante de publicación','Angie Gutiérrez subió comprobante para \'Reparación de tv\' - $5','{\"url\":\"\\/admin\\/service-payments\",\"action\":\"review_payment\",\"service_id\":29}',1,'2026-05-24 02:23:08'),
(162,10,1,'admin','Nueva solicitud de servicio','El proveedor #10 ha creado el servicio \"Reparación de tv\". Revisa la solicitud para aprobacion',NULL,1,'2026-05-24 09:46:44'),
(163,NULL,1,'admin','📎 Nuevo comprobante de publicación','Angie Gutiérrez subió comprobante para \'Reparación de tv\' - $5','{\"url\":\"\\/admin\\/service-payments\",\"action\":\"review_payment\",\"service_id\":30}',1,'2026-05-24 09:47:07'),
(164,10,1,'admin','Nueva solicitud de servicio','El proveedor #10 ha creado el servicio \"Reparación de televisión\". Revisa la solicitud para aprobacion',NULL,1,'2026-05-24 10:10:11'),
(165,NULL,1,'admin','📎 Nuevo comprobante de publicación','Angie Gutiérrez subió comprobante para \'Reparación de televisión\' - $5','{\"url\":\"\\/admin\\/service-payments\",\"action\":\"review_payment\",\"service_id\":31}',1,'2026-05-24 10:10:36'),
(166,10,1,'admin','Nueva solicitud de servicio','El proveedor #10 ha creado el servicio \"Reparación de televisión\". Revisa la solicitud para aprobacion',NULL,1,'2026-05-24 10:17:27'),
(167,NULL,1,'admin','📎 Nuevo comprobante de publicación','Angie Gutiérrez subió comprobante para \'Reparación de televisión\' - $5','{\"url\":\"\\/admin\\/service-payments\",\"action\":\"review_payment\",\"service_id\":32}',1,'2026-05-24 10:17:48'),
(168,NULL,10,'provider','✅ Pago aprobado','Tu comprobante para \'Reparación de televisión\' fue aprobado. El servicio ya está activo.','{\"url\":\"\\/myservices\",\"action\":\"view_services\"}',0,'2026-05-24 10:18:39'),
(169,10,1,'admin','Nueva solicitud de servicio','El proveedor #10 ha creado el servicio \"Reparación de televisión\". Revisa la solicitud para aprobacion',NULL,1,'2026-05-24 12:51:51'),
(170,NULL,1,'admin','📎 Nuevo comprobante de publicación','Angie Gutiérrez subió comprobante para \'Reparación de televisión\' - $5','{\"url\":\"\\/admin\\/service-payments\",\"action\":\"review_payment\",\"service_id\":33}',1,'2026-05-24 12:52:11'),
(171,NULL,10,'provider','✅ Pago aprobado','Tu comprobante para \'Reparación de televisión\' fue aprobado. El servicio ya está activo.','{\"url\":\"\\/myservices\",\"action\":\"view_services\"}',0,'2026-05-24 12:53:38'),
(172,2,10,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',0,'2026-05-24 13:21:58'),
(173,10,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/33\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":33}',0,'2026-05-24 13:22:34'),
(174,2,10,'provider','Pago registrado','El cliente pagará en efectivo','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/dashboard\\/provider\",\"action\":\"verify_payment\",\"request_id\":73,\"payment_id\":67}',0,'2026-05-24 13:22:58'),
(175,10,2,'user','Pago confirmado','El proveedor certificó que recibió tu pago','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/73\",\"action\":\"view_order\",\"request_id\":73,\"payment_id\":67}',0,'2026-05-24 13:23:14'),
(176,10,2,'user','Servicio finalizado - ¡Califica tu experiencia!','El proveedor marcó el servicio como finalizado.','{\"type\":\"rating\",\"notification_type\":\"open_rating\",\"url\":\"\\/orders\\/73\",\"action\":\"open_rating_modal\",\"request_id\":73,\"provider_id\":10,\"from_role\":\"provider\"}',0,'2026-05-24 13:23:40'),
(177,2,10,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',0,'2026-05-24 14:06:22'),
(178,10,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/33\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":33}',0,'2026-05-24 14:06:30'),
(179,2,10,'provider','Pago registrado','El cliente pagará en efectivo','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/dashboard\\/provider\",\"action\":\"verify_payment\",\"request_id\":74,\"payment_id\":68}',0,'2026-05-24 14:06:34'),
(180,10,2,'user','Servicio finalizado - ¡Califica tu experiencia!','El proveedor marcó el servicio como finalizado.','{\"type\":\"rating\",\"notification_type\":\"open_rating\",\"url\":\"\\/orders\\/74\",\"action\":\"open_rating_modal\",\"request_id\":74,\"provider_id\":10,\"from_role\":\"provider\"}',0,'2026-05-24 14:07:05'),
(181,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',0,'2026-05-24 14:21:50'),
(182,6,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/12\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":12}',0,'2026-05-24 14:21:52'),
(183,2,6,'provider','Pago registrado','Cliente subió comprobante – verifica el pago','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/dashboard\\/provider\",\"action\":\"verify_payment\",\"request_id\":75,\"payment_id\":69}',0,'2026-05-24 14:22:20'),
(184,6,2,'user','Servicio finalizado - ¡Califica tu experiencia!','El proveedor marcó el servicio como finalizado.','{\"type\":\"rating\",\"notification_type\":\"open_rating\",\"url\":\"\\/orders\\/75\",\"action\":\"open_rating_modal\",\"request_id\":75,\"provider_id\":6,\"from_role\":\"provider\"}',0,'2026-05-24 14:23:12'),
(185,6,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/11\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":11}',0,'2026-05-24 14:41:33'),
(186,2,6,'provider','Pago registrado','Cliente subió comprobante – verifica el pago','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/dashboard\\/provider\",\"action\":\"verify_payment\",\"request_id\":50,\"payment_id\":70}',0,'2026-05-24 14:44:08'),
(187,6,2,'user','Servicio finalizado - ¡Califica tu experiencia!','El proveedor marcó el servicio como finalizado.','{\"type\":\"rating\",\"notification_type\":\"open_rating\",\"url\":\"\\/orders\\/50\",\"action\":\"open_rating_modal\",\"request_id\":50,\"provider_id\":6,\"from_role\":\"provider\"}',0,'2026-05-24 15:01:12'),
(188,2,6,'provider','Nueva solicitud','Tienes una nueva solicitud pendiente','{\"url\":\"\\/dashboard\\/provider\",\"action\":\"view_request\",\"notification_type\":\"new_request\"}',0,'2026-05-24 15:01:23'),
(189,6,2,'user','Solicitud aceptada','Tu solicitud fue aceptada por el proveedor','{\"url\":\"\\/service\\/12\",\"action\":\"view_service\",\"notification_type\":\"service_update\",\"service_id\":12}',0,'2026-05-24 15:01:28'),
(190,2,6,'provider','Pago registrado','Cliente subió comprobante – verifica el pago','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/dashboard\\/provider\",\"action\":\"verify_payment\",\"request_id\":76,\"payment_id\":71}',0,'2026-05-24 15:01:59'),
(191,6,2,'user','Pago confirmado','El proveedor certificó que recibió tu pago','{\"type\":\"payment\",\"notification_type\":\"payment_received\",\"url\":\"\\/orders\\/76\",\"action\":\"view_order\",\"request_id\":76,\"payment_id\":71}',0,'2026-05-24 15:02:18'),
(192,6,2,'user','Servicio finalizado - ¡Califica tu experiencia!','El proveedor marcó el servicio como finalizado.','{\"type\":\"rating\",\"notification_type\":\"open_rating\",\"url\":\"\\/orders\\/76\",\"action\":\"open_rating_modal\",\"request_id\":76,\"provider_id\":6,\"from_role\":\"provider\"}',0,'2026-05-24 15:02:35'),
(193,10,1,'admin','Nueva solicitud de servicio','El proveedor #10 ha creado el servicio \"Reparación de televisión\". Revisa la solicitud para aprobacion',NULL,1,'2026-05-24 17:40:28'),
(194,NULL,1,'admin','📎 Nuevo comprobante de publicación','Angie Gutiérrez subió comprobante para \'Reparación de televisión\' - $5','{\"url\":\"\\/admin\\/service-payments\",\"action\":\"review_payment\",\"service_id\":34}',1,'2026-05-24 17:40:59'),
(195,NULL,10,'provider','✅ Pago aprobado','Tu comprobante para \'Reparación de televisión\' fue aprobado. El servicio ya está activo.','{\"url\":\"\\/myservices\",\"action\":\"view_services\"}',0,'2026-05-24 17:43:42');
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `payment_gateways`
--

DROP TABLE IF EXISTS `payment_gateways`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_gateways`
--

LOCK TABLES `payment_gateways` WRITE;
/*!40000 ALTER TABLE `payment_gateways` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `payment_gateways` VALUES
(1,'paypal','PayPal','Pagos seguros con PayPal',0,1,1,'18673920','djesus888',NULL,'divijeal@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,5.00,3.00,0,0.00,0.00,NULL,'🅿️',1,'2026-02-04 18:00:19','2026-05-24 17:46:53'),
(2,'mercadopago','MercadoPago','Pagos en Latinoamérica',0,1,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0.00,0.00,0,0.00,0.00,NULL,'🇦🇷',0,'2026-02-04 18:00:19','2026-05-24 17:46:48'),
(3,'bank_transfer','Transferencia Bancaria','Transferencia directa a cuenta bancaria',0,1,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0.00,0.00,0,0.00,0.00,NULL,'🏦',0,'2026-02-04 18:00:19','2026-05-24 17:46:42'),
(4,'mobile_payment','Pago Móvil','Pago desde tu teléfono móvil',1,1,0,NULL,NULL,NULL,NULL,NULL,'Banco de Venezuela (0102)',NULL,NULL,NULL,'18673920','04120761886','digitel',NULL,5.00,3.00,0,0.00,0.00,NULL,'📱',0,'2026-02-04 18:00:19','2026-05-24 19:29:20'),
(5,'zelle','Zelle','Transferencias bancarias en USA',1,1,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'divijeal@gmail.com',0.00,0.00,0,0.00,0.00,NULL,'🇺🇸',0,'2026-02-04 18:00:19','2026-04-28 09:49:38');
/*!40000 ALTER TABLE `payment_gateways` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `payment_methods`
--

DROP TABLE IF EXISTS `payment_methods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_methods`
--

LOCK TABLES `payment_methods` WRITE;
/*!40000 ALTER TABLE `payment_methods` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `payment_methods` VALUES
(1,'transferencia','🏦 Transferencia bancaria','🏦 Datos para transferencia','{\"Banco\": \"Banco de Venezuela\", \"Titular\": \"Tapclic Services C.A.\", \"RIF\": \"J-123456789\", \"Cuenta Corriente\": \"0102-0123-45-12345678\", \"CI\": \"V-12345678\"}','RECARGA',1,'2026-02-14 03:27:59','2026-02-14 03:27:59'),
(2,'pago_movil','📱 Pago móvil','📱 Datos para Pago Móvil','{\"Banco\": \"Banesco\", \"Cédula/RIF\": \"V-12345678\", \"Teléfono\": \"0412-1234567\", \"Banco receptor\": \"Banesco\"}','RECARGA',1,'2026-02-14 03:27:59','2026-04-28 09:42:00'),
(3,'paypal','🌐 PayPal','🌐 Datos de PayPal','{\"Email\": \"pagos@tapclic.com\", \"Nombre\": \"Tapclic Services\"}','RECARGA',1,'2026-02-14 03:27:59','2026-02-14 03:27:59'),
(4,'zelle','💵 Zelle','💵 Datos para Zelle','{\"Email\": \"pagos@tapclic.com\", \"Nombre\": \"Tapclic Services\", \"Banco\": \"Bank of America\"}','RECARGA',1,'2026-02-14 03:27:59','2026-02-14 03:27:59'),
(5,'binance','🪙 Binance','🪙 Datos de Binance','{\"ID\": \"123456789\", \"Email\": \"binance@tapclic.com\"}','RECARGA',1,'2026-02-14 03:27:59','2026-02-14 03:27:59'),
(6,'efectivo','💵 Efectivo','💵 Pago en efectivo','{\"Punto de pago\": \"Consultar con administrador\"}','RECARGA',1,'2026-02-14 03:27:59','2026-02-14 03:27:59');
/*!40000 ALTER TABLE `payment_methods` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=73 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

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
-- Table structure for table `platform_earnings`
--

DROP TABLE IF EXISTS `platform_earnings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `platform_earnings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(50) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `reference_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_type` (`type`),
  KEY `idx_created` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `platform_earnings`
--

LOCK TABLES `platform_earnings` WRITE;
/*!40000 ALTER TABLE `platform_earnings` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `platform_earnings` VALUES
(1,'service_publish',5.00,33,10,'2026-05-24 12:53:38'),
(2,'transaction_commission',0.20,50,6,'2026-05-24 14:57:37'),
(3,'transaction_commission',0.20,76,6,'2026-05-24 15:02:18'),
(4,'service_publish',5.00,34,10,'2026-05-24 17:43:42');
/*!40000 ALTER TABLE `platform_earnings` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `provider_billing`
--

DROP TABLE IF EXISTS `provider_billing`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `provider_billing` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `provider_id` int(11) NOT NULL,
  `period_start` date NOT NULL,
  `period_end` date NOT NULL,
  `total_commission` decimal(10,2) DEFAULT 0.00,
  `total_services` int(11) DEFAULT 0,
  `total_transactions` int(11) DEFAULT 0,
  `status` enum('pending','reported','paid','overdue') DEFAULT 'pending',
  `payment_proof` varchar(255) DEFAULT NULL,
  `reported_at` timestamp NULL DEFAULT NULL,
  `paid_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_provider` (`provider_id`),
  KEY `idx_status` (`status`),
  KEY `idx_period` (`period_end`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `provider_billing`
--

LOCK TABLES `provider_billing` WRITE;
/*!40000 ALTER TABLE `provider_billing` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `provider_billing` VALUES
(1,6,'2026-05-01','2026-05-31',0.40,1,2,'pending',NULL,NULL,NULL,'2026-05-24 14:57:37');
/*!40000 ALTER TABLE `provider_billing` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `provider_payment_methods`
--

DROP TABLE IF EXISTS `provider_payment_methods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `provider_payment_methods`
--

LOCK TABLES `provider_payment_methods` WRITE;
/*!40000 ALTER TABLE `provider_payment_methods` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `provider_payment_methods` VALUES
(1,6,'pago_movil','Venezuela ','Jesús Diaz ','18673920','04120761886','01020287463528934678',NULL,NULL,1,'2025-09-07 11:57:06','2025-09-07 11:59:32'),
(2,6,'transferencia','Bicentenario ','Jesús Diaz ','18673920','','01029876542345764567','','',1,'2025-09-07 14:45:18','2025-09-07 14:57:14'),
(3,6,'paypal','','Jesús Diaz ','18673920','','','divijeal@gmail.com','',1,'2025-09-07 14:59:01','2025-09-07 14:59:01'),
(4,6,'zelle','','18673920','18673920','','','divijeal@gmail.com','',1,'2025-09-07 14:59:31','2025-09-07 14:59:31');
/*!40000 ALTER TABLE `provider_payment_methods` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `requests`
--

DROP TABLE IF EXISTS `requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `service_id` int(11) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `receiver_id` int(11) NOT NULL,
  `status` enum('pending','accepted','rejected') DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

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
-- Table structure for table `review_helpful`
--

DROP TABLE IF EXISTS `review_helpful`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `review_helpful`
--

LOCK TABLES `review_helpful` WRITE;
/*!40000 ALTER TABLE `review_helpful` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `review_helpful` VALUES
(1,2,2,'2025-12-18 13:27:44'),
(2,10,6,'2025-12-18 06:35:28'),
(13,1,6,'2025-12-18 13:28:47'),
(14,1,2,'2025-12-18 13:27:46'),
(16,9,6,'2025-12-18 12:52:38'),
(19,7,6,'2025-12-18 13:28:09'),
(20,8,6,'2025-12-18 13:28:10'),
(21,2,6,'2025-12-18 13:28:46'),
(28,3,6,'2025-12-18 13:28:56'),
(29,3,2,'2025-12-19 17:42:54'),
(35,4,6,'2025-12-19 20:49:15');
/*!40000 ALTER TABLE `review_helpful` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `review_messages`
--

DROP TABLE IF EXISTS `review_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `review_messages`
--

LOCK TABLES `review_messages` WRITE;
/*!40000 ALTER TABLE `review_messages` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `review_messages` VALUES
(8,1,'provider',6,'Más nada 😉🙂','2025-12-04 14:01:06'),
(10,2,'provider',6,'Que fue hombre ? Jesús te ama 🙏🏾','2025-12-04 16:56:28'),
(11,3,'provider',6,'Pepón','2025-12-16 06:20:25'),
(12,1,'user',2,'Que pasó','2025-12-21 11:43:20'),
(13,4,'user',2,'Hyt tú','2025-12-25 15:43:25'),
(14,9,'user',2,'Hhhjh','2025-12-25 15:43:46'),
(15,6,'user',2,'Yyyyyyyyyyyy','2025-12-25 15:45:39'),
(16,2,'user',2,'Naruto','2025-12-25 15:46:27'),
(17,7,'user',2,'@#€4555666654221','2025-12-25 16:08:56'),
(18,3,'user',2,'Hola pezcado','2025-12-25 16:14:17'),
(19,8,'user',2,'Uuuuuuu','2025-12-25 16:17:28'),
(20,5,'user',2,'Hijo mío','2025-12-25 16:31:50'),
(21,15,'provider',6,'Mijo palante','2025-12-26 08:57:55'),
(22,10,'user',2,'Gato feliz pendejo','2025-12-26 09:34:56'),
(23,18,'user',2,'Hola 😘👋🏾👋🏾👋🏾','2026-02-15 18:28:59');
/*!40000 ALTER TABLE `review_messages` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `review_reports`
--

DROP TABLE IF EXISTS `review_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `review_reports`
--

LOCK TABLES `review_reports` WRITE;
/*!40000 ALTER TABLE `review_reports` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `review_reports` VALUES
(1,2,2,'2025-12-18 05:16:39'),
(15,1,2,'2025-12-18 05:17:11');
/*!40000 ALTER TABLE `review_reports` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `service_history`
--

DROP TABLE IF EXISTS `service_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=250 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_history`
--

LOCK TABLES `service_history` WRITE;
/*!40000 ALTER TABLE `service_history` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `service_history` VALUES
(1,2,10,1,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2025-10-06 10:44:45',6),
(2,6,10,3,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-11-21 00:16:34',6),
(3,2,10,2,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-11-21 00:16:47',6),
(4,2,10,4,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','verifying','efectivo',NULL,'2025-11-21 01:45:11',6),
(5,2,12,5,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-08 19:21:43',6),
(6,2,10,6,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-10 07:34:40',6),
(7,2,10,7,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-11 06:48:21',6),
(8,2,10,8,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','paid','efectivo',NULL,'2025-12-15 07:41:39',6),
(9,2,10,10,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-15 07:56:58',6),
(10,2,10,11,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2025-12-15 08:00:04',6),
(11,2,10,12,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2025-12-15 08:04:08',6),
(12,2,10,13,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-15 14:19:10',6),
(13,2,10,14,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-15 14:50:30',6),
(14,2,10,15,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','verifying','efectivo',NULL,'2025-12-15 15:11:27',6),
(15,2,10,16,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-15 15:25:46',6),
(16,2,10,17,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','verifying','efectivo',NULL,'2025-12-15 15:28:41',6),
(17,2,10,18,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','verifying','efectivo',NULL,'2025-12-15 15:38:41',6),
(18,2,10,19,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-15 15:49:52',6),
(19,2,10,20,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','verifying','efectivo',NULL,'2025-12-15 18:16:21',6),
(20,2,10,21,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-15 20:47:45',6),
(21,2,10,22,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-16 05:31:59',6),
(22,2,10,23,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2025-12-16 05:37:13',6),
(23,2,10,24,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2025-12-16 10:04:13',6),
(24,2,10,25,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-16 14:44:21',6),
(25,2,10,26,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2025-12-16 14:48:28',6),
(26,2,10,27,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2025-12-16 14:50:36',6),
(27,2,10,28,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-16 14:55:55',6),
(28,2,10,29,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','verifying','efectivo',NULL,'2025-12-16 15:01:29',6),
(29,2,10,30,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-16 15:27:22',6),
(30,2,10,31,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-16 15:34:04',6),
(31,2,10,32,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-16 15:46:12',6),
(32,2,10,33,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-16 16:11:16',6),
(33,2,10,34,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-16 16:23:07',6),
(34,2,10,35,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-16 16:35:35',6),
(35,2,10,36,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-16 16:40:48',6),
(36,2,10,37,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-16 16:47:39',6),
(37,2,10,38,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-16 17:05:56',6),
(38,2,10,39,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-16 18:09:01',6),
(39,2,10,40,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-16 18:11:48',6),
(40,2,10,41,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-16 18:17:56',6),
(41,2,10,42,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-16 18:42:24',6),
(42,2,10,43,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-16 18:43:19',6),
(43,2,10,44,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-16 18:44:38',6),
(44,2,10,45,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-16 18:45:51',6),
(45,2,10,46,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-16 18:50:53',6),
(46,2,10,47,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-16 18:54:56',6),
(47,2,10,48,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-16 18:56:33',6),
(48,2,10,49,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-16 19:45:29',6),
(49,2,10,50,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-16 19:50:08',6),
(50,2,10,51,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-16 20:02:20',6),
(51,2,10,52,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-16 20:28:17',6),
(52,2,10,53,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-16 20:30:09',6),
(53,2,10,54,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-16 20:46:29',6),
(54,2,10,55,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-16 21:29:59',6),
(55,2,10,56,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-16 21:31:33',6),
(56,2,10,57,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-16 21:32:47',6),
(57,2,10,58,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-16 22:01:50',6),
(58,2,10,59,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-17 07:15:58',6),
(59,2,10,60,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-17 07:20:56',6),
(60,2,10,61,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-17 07:25:56',6),
(61,2,10,62,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-17 07:26:43',6),
(62,2,10,63,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-17 07:30:41',6),
(63,2,10,64,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-17 14:09:21',6),
(64,2,10,65,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-17 14:25:12',6),
(65,2,10,66,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-17 14:26:17',6),
(66,2,10,67,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-17 17:15:45',6),
(67,2,10,68,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-17 17:32:23',6),
(68,2,10,69,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-17 17:33:14',6),
(69,2,10,70,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-17 17:35:35',6),
(70,2,10,71,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-17 21:27:04',6),
(71,2,10,72,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-17 21:28:08',6),
(72,2,10,73,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-17 21:56:59',6),
(73,2,10,74,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-17 21:58:06',6),
(74,2,10,75,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-17 22:00:01',6),
(75,2,10,76,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-17 22:04:25',6),
(76,2,10,77,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-17 22:45:55',6),
(77,2,10,78,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2025-12-17 23:00:02',6),
(78,2,10,79,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-17 23:01:11',6),
(79,2,10,80,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-17 23:03:25',6),
(80,2,10,81,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-17 23:08:04',6),
(81,2,10,82,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-17 23:10:06',6),
(82,2,10,83,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-17 23:14:25',6),
(83,2,10,84,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-18 00:07:44',6),
(84,2,10,85,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-19 06:52:39',6),
(85,2,10,86,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-19 06:54:25',6),
(86,2,10,87,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-19 06:56:23',6),
(87,2,10,88,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-19 20:54:05',6),
(88,2,10,89,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-19 20:55:15',6),
(89,2,10,90,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-21 11:48:33',6),
(90,2,10,91,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-22 06:51:53',6),
(91,2,10,92,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-22 07:15:34',6),
(92,2,10,93,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-22 07:23:17',6),
(93,2,10,94,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-22 07:24:31',6),
(94,2,10,95,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-22 07:28:43',6),
(95,2,10,96,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-22 07:30:21',6),
(96,2,10,97,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-22 07:31:35',6),
(97,2,10,98,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-22 07:32:40',6),
(98,2,10,99,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-22 22:11:50',6),
(99,2,10,100,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-22 22:33:17',6),
(100,2,10,101,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2025-12-22 22:43:31',6),
(101,2,10,102,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-22 22:44:31',6),
(102,2,10,103,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-23 06:58:55',6),
(103,2,10,104,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-23 07:10:30',6),
(104,2,10,105,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-23 07:13:10',6),
(105,2,10,106,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-23 15:01:22',6),
(106,2,10,107,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2025-12-23 15:02:18',6),
(107,2,10,108,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-23 15:03:00',6),
(108,2,10,109,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-23 15:29:15',6),
(109,2,10,110,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-23 15:30:38',6),
(110,2,10,111,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-23 15:31:29',6),
(111,2,10,112,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','pending','efectivo',NULL,'2025-12-26 08:55:22',6),
(112,2,10,113,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','verifying','efectivo',NULL,'2025-12-26 15:45:03',6),
(113,2,10,114,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2025-12-27 20:13:43',6),
(114,2,10,115,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2025-12-28 05:52:53',6),
(115,2,10,116,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2025-12-28 12:46:12',6),
(116,2,10,117,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2025-12-28 15:07:48',6),
(117,2,10,118,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2025-12-29 03:00:11',6),
(118,2,10,119,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2026-01-02 12:38:08',6),
(119,2,10,120,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-02 16:18:16',6),
(120,2,10,121,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2026-01-02 16:24:04',6),
(121,2,10,122,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','paid','efectivo',NULL,'2026-01-02 16:27:34',6),
(122,2,10,123,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2026-01-02 17:36:37',6),
(123,2,10,124,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2026-01-02 17:40:23',6),
(124,2,10,125,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','verifying','efectivo',NULL,'2026-01-02 17:52:55',6),
(125,2,10,126,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2026-01-07 12:19:39',6),
(126,2,10,127,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2026-01-07 12:28:48',6),
(127,2,10,129,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-07 12:45:59',6),
(128,2,10,130,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-07 12:55:21',6),
(129,2,10,131,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-07 12:57:33',6),
(130,2,10,132,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-07 13:11:01',6),
(131,2,10,133,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-07 13:15:07',6),
(132,2,10,134,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-07 13:15:50',6),
(133,2,10,135,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-07 14:03:36',6),
(134,2,10,137,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-07 14:15:18',6),
(135,2,10,138,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-07 14:38:26',6),
(136,2,10,140,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-07 14:42:52',6),
(137,2,10,141,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-07 16:07:31',6),
(138,2,10,142,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-07 16:08:30',6),
(139,2,10,143,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-07 16:13:25',6),
(140,2,10,144,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-09 01:06:58',6),
(141,2,10,145,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-09 05:43:07',6),
(142,2,10,146,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-09 05:46:07',6),
(143,2,10,147,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-09 05:49:27',6),
(144,2,10,148,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-09 06:17:38',6),
(145,2,10,149,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-09 15:04:20',6),
(146,2,10,150,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-09 15:05:24',6),
(147,2,10,151,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-09 23:37:57',6),
(148,2,10,152,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-09 23:38:30',6),
(149,2,10,153,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-09 23:39:29',6),
(150,2,10,155,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-10 01:05:24',6),
(151,2,10,156,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-10 01:06:47',6),
(152,2,10,157,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-10 18:39:57',6),
(153,2,10,158,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-10 18:41:38',6),
(154,2,10,159,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-10 18:44:21',6),
(155,2,10,160,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','verifying','efectivo',NULL,'2026-01-10 21:53:23',6),
(156,2,10,161,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2026-01-10 21:55:48',6),
(157,2,10,165,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-11 14:07:46',6),
(158,2,10,169,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','verifying','efectivo',NULL,'2026-01-12 00:09:37',6),
(159,2,10,171,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-12 06:59:47',6),
(160,2,10,173,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-12 07:01:55',6),
(161,2,10,174,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-12 07:53:53',6),
(162,2,10,177,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','verifying','efectivo',NULL,'2026-01-12 11:16:22',6),
(163,2,10,179,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-12 11:19:00',6),
(164,2,10,183,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-12 18:39:24',6),
(165,2,10,184,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-12 18:40:19',6),
(166,2,10,191,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-13 08:33:39',6),
(167,2,10,195,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-13 08:47:01',6),
(168,2,10,199,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-13 08:48:49',6),
(169,2,10,206,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-13 09:50:59',6),
(170,2,10,16,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-14 23:06:13',6),
(171,2,10,18,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-14 23:25:46',6),
(172,2,10,37,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-15 09:14:30',6),
(173,2,10,38,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','verifying','efectivo',NULL,'2026-01-15 09:14:33',6),
(174,2,10,39,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-15 09:19:30',6),
(175,2,10,40,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','verifying','efectivo',NULL,'2026-01-15 09:20:38',6),
(176,2,10,48,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-15 09:52:24',6),
(177,2,10,52,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-15 09:55:14',6),
(178,2,10,56,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-15 10:25:59',6),
(179,2,10,58,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-15 22:44:46',6),
(180,2,10,59,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-15 22:45:43',6),
(181,2,10,62,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-15 23:33:36',6),
(182,2,10,65,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-16 06:43:23',6),
(183,2,10,66,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-16 07:31:32',6),
(184,2,10,67,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-16 07:36:01',6),
(185,2,10,69,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-16 10:47:33',6),
(186,2,10,70,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-16 11:07:39',6),
(187,2,10,71,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-16 11:09:03',6),
(188,2,10,72,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-16 11:27:50',6),
(189,2,10,73,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-16 11:49:42',6),
(190,2,10,74,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-16 11:51:19',6),
(191,2,10,75,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-16 19:43:38',6),
(192,2,10,76,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-16 20:01:39',6),
(193,2,10,1,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-16 20:41:57',6),
(194,2,10,2,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-16 20:45:25',6),
(195,2,10,3,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-17 09:18:10',6),
(196,2,10,4,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-17 09:20:56',6),
(197,2,10,5,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-17 09:22:33',6),
(198,2,10,6,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-17 09:24:48',6),
(199,2,10,7,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-17 10:35:46',6),
(200,2,10,8,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-17 20:57:15',6),
(201,2,10,9,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-25 12:45:44',6),
(202,2,10,11,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-25 12:49:47',6),
(203,2,10,12,'Airline',NULL,35.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-26 17:23:22',6),
(204,2,12,13,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-27 23:22:44',6),
(205,2,12,15,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2026-01-29 19:38:59',6),
(206,2,12,19,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-01-30 05:24:00',6),
(207,2,11,17,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2026-01-30 05:29:04',6),
(208,2,12,14,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2026-01-30 05:29:10',6),
(209,2,12,20,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-02-18 18:35:10',6),
(210,2,12,25,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2026-05-04 23:16:52',6),
(211,2,10,24,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2026-05-05 00:10:52',6),
(212,2,11,28,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-05-10 06:15:59',6),
(213,2,12,29,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-05-10 06:20:54',6),
(214,2,12,30,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-05-10 06:23:41',6),
(215,2,12,31,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-05-10 06:55:33',6),
(216,2,12,33,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-05-12 10:46:56',6),
(217,2,12,40,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-05-13 06:41:31',6),
(218,2,10,41,'Airline',NULL,35.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2026-05-15 09:05:05',6),
(219,2,12,43,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-05-15 14:15:47',6),
(220,2,11,44,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-05-15 14:19:22',6),
(221,2,12,46,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-05-16 09:55:48',6),
(222,2,12,47,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','cancelled','pending','efectivo',NULL,'2026-05-16 10:26:57',6),
(223,2,11,51,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2026-05-16 12:53:18',6),
(224,2,12,52,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2026-05-16 14:43:39',6),
(225,2,11,53,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2026-05-16 15:07:22',6),
(226,2,11,54,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2026-05-16 21:51:58',6),
(227,2,11,55,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2026-05-16 22:51:33',6),
(228,2,11,56,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2026-05-17 06:17:41',6),
(229,2,11,57,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2026-05-17 06:23:19',6),
(230,2,11,58,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2026-05-17 08:43:55',6),
(231,2,12,59,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2026-05-17 08:59:48',6),
(232,2,11,60,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2026-05-17 09:58:50',6),
(233,2,12,61,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2026-05-17 11:07:41',6),
(234,2,11,62,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2026-05-17 18:54:07',6),
(235,2,12,63,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2026-05-17 18:56:00',6),
(236,2,12,64,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2026-05-17 19:54:30',6),
(237,2,12,65,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2026-05-17 20:09:43',6),
(238,2,12,66,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2026-05-17 20:52:48',6),
(239,2,11,67,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2026-05-17 21:17:15',6),
(240,2,12,68,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2026-05-17 21:43:45',6),
(241,2,11,69,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2026-05-17 22:06:46',6),
(242,2,11,70,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2026-05-17 22:26:56',6),
(243,2,11,71,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2026-05-18 08:27:10',6),
(244,2,12,72,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2026-05-18 08:31:30',6),
(245,2,33,73,'Reparación de televisión',NULL,15.00,NULL,NULL,'Angie Gutiérrez','completed','paid','efectivo',NULL,'2026-05-24 09:23:40',10),
(246,2,33,74,'Reparación de televisión',NULL,15.00,NULL,NULL,'Angie Gutiérrez','completed','paid','efectivo',NULL,'2026-05-24 10:07:05',10),
(247,2,12,75,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2026-05-24 10:23:12',6),
(248,2,11,50,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2026-05-24 11:01:13',6),
(249,2,12,76,'Lavado general',NULL,10.00,NULL,NULL,'María Villegas','completed','paid','efectivo',NULL,'2026-05-24 11:02:35',6);
/*!40000 ALTER TABLE `service_history` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `service_payment_proofs`
--

DROP TABLE IF EXISTS `service_payment_proofs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `service_payment_proofs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `service_id` int(11) NOT NULL,
  `provider_id` int(11) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `payment_method` varchar(50) DEFAULT NULL,
  `reference` varchar(100) DEFAULT NULL,
  `proof_url` varchar(255) DEFAULT NULL,
  `status` enum('pending','approved','rejected') DEFAULT 'pending',
  `reviewed_by` int(11) DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_service` (`service_id`),
  KEY `idx_provider` (`provider_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_payment_proofs`
--

LOCK TABLES `service_payment_proofs` WRITE;
/*!40000 ALTER TABLE `service_payment_proofs` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `service_payment_proofs` VALUES
(1,27,10,5.00,'mercadopago','0987654321','/uploads/payments/service_pay_27_1779542162.jpg','rejected',NULL,'2026-05-23 15:26:39','2026-05-23 13:16:02'),
(2,27,10,5.00,'mercadopago','867544555','/uploads/payments/service_pay_27_1779542671.jpg','rejected',NULL,'2026-05-23 15:26:46','2026-05-23 13:24:31'),
(3,27,10,5.00,'mercadopago','1234567890','/uploads/payments/service_pay_27_1779543676.jpg','rejected',NULL,'2026-05-23 15:26:54','2026-05-23 13:41:16'),
(4,27,10,5.00,'mercadopago','13363747','/uploads/payments/service_pay_27_1779549189.png','rejected',NULL,'2026-05-23 15:26:57','2026-05-23 15:13:09'),
(5,28,10,5.00,'mobile_payment','1837377373463','/uploads/payments/service_pay_28_1779551260.jpg','approved',NULL,'2026-05-23 15:49:09','2026-05-23 15:47:40'),
(6,29,10,5.00,'mobile_payment','2234567890','/uploads/payments/service_pay_29_1779589388.jpg','approved',NULL,'2026-05-24 02:23:49','2026-05-24 02:23:08'),
(7,30,10,5.00,'mobile_payment','1465345677656','/uploads/payments/service_pay_30_1779616027.jpg','approved',NULL,'2026-05-24 09:50:20','2026-05-24 09:47:07'),
(8,31,10,5.00,'mobile_payment','123456789',NULL,'approved',1,'2026-05-24 10:13:16','2026-05-24 10:10:36'),
(9,32,10,5.00,'mobile_payment','123456789','/uploads/payments/service_pay_32_1779617868.jpg','approved',1,'2026-05-24 10:18:39','2026-05-24 10:17:48'),
(10,33,10,5.00,'mobile_payment','12345666','/uploads/payments/service_pay_33_1779627131.jpg','approved',1,'2026-05-24 12:53:38','2026-05-24 12:52:11'),
(11,34,10,5.00,'mobile_payment','1234567890','/uploads/payments/service_pay_34_1779644459.jpg','approved',1,'2026-05-24 17:43:42','2026-05-24 17:40:59');
/*!40000 ALTER TABLE `service_payment_proofs` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `service_requests`
--

DROP TABLE IF EXISTS `service_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=77 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_requests`
--

LOCK TABLES `service_requests` WRITE;
/*!40000 ALTER TABLE `service_requests` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `service_requests` VALUES
(10,10,2,6,'busy',NULL,35.00,'efectivo','','2026-01-25 16:46:42','2026-01-25 16:47:48','pending',NULL),
(16,11,2,6,'rejected',NULL,10.00,'efectivo','','2026-01-29 19:28:38','2026-01-29 22:25:11','pending',NULL),
(18,12,2,6,'busy',NULL,10.00,'efectivo','','2026-01-29 23:36:51','2026-01-29 23:38:06','pending',NULL),
(21,12,2,6,'rejected',NULL,10.00,'efectivo','','2026-05-04 13:54:50','2026-05-04 15:10:14','pending',NULL),
(22,10,2,6,'rejected',NULL,35.00,'efectivo','','2026-05-04 15:05:14','2026-05-04 15:10:12','pending',NULL),
(23,11,2,6,'rejected',NULL,10.00,'efectivo','','2026-05-04 15:08:43','2026-05-04 15:10:11','pending',NULL),
(26,11,2,6,'rejected',NULL,10.00,'efectivo','','2026-05-04 15:17:17','2026-05-04 15:18:14','pending',NULL),
(27,12,2,6,'rejected',NULL,10.00,'efectivo','','2026-05-07 04:35:17','2026-05-10 10:18:39','pending',NULL),
(32,12,2,6,'busy',NULL,10.00,'efectivo','','2026-05-10 10:55:48','2026-05-10 10:56:16','pending',NULL),
(34,12,2,6,'rejected',NULL,10.00,'efectivo','','2026-05-13 01:33:07','2026-05-13 01:33:17','pending',NULL),
(35,12,2,6,'rejected',NULL,10.00,'efectivo','','2026-05-13 01:40:05','2026-05-13 01:41:22','pending',NULL),
(36,12,2,6,'rejected',NULL,10.00,'efectivo','','2026-05-13 01:54:07','2026-05-13 04:05:24','pending',NULL),
(37,12,2,6,'busy',NULL,10.00,'efectivo','','2026-05-13 04:05:50','2026-05-13 04:06:12','pending',NULL),
(38,12,2,6,'rejected',NULL,10.00,'efectivo','','2026-05-13 04:27:05','2026-05-13 04:28:32','pending',NULL),
(39,12,2,6,'rejected',NULL,10.00,'efectivo','','2026-05-13 04:29:06','2026-05-13 04:30:27','pending',NULL),
(42,12,2,6,'rejected',NULL,10.00,'efectivo','','2026-05-15 13:06:07','2026-05-15 13:06:16','pending',NULL),
(45,10,2,6,'busy',NULL,35.00,'efectivo','','2026-05-15 19:13:20','2026-05-15 19:14:02','pending',NULL),
(48,12,2,6,'busy',NULL,10.00,'efectivo','','2026-05-16 14:35:20','2026-05-16 14:35:23','pending',NULL),
(49,11,2,6,'busy',NULL,10.00,'efectivo','','2026-05-16 16:51:45','2026-05-16 16:51:49','pending',NULL);
/*!40000 ALTER TABLE `service_requests` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `service_reviews`
--

DROP TABLE IF EXISTS `service_reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_reviews`
--

LOCK TABLES `service_reviews` WRITE;
/*!40000 ALTER TABLE `service_reviews` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `service_reviews` VALUES
(1,1,2,6,3,'Que pasó ramon','2025-11-09 05:35:07','[]','[]'),
(2,4,2,6,5,'Hola me gustó tu trato 😉☺️','2025-12-03 19:56:32','[]','[]'),
(3,22,2,6,3,'Encantado ','2025-12-16 05:39:36','[]','[]'),
(4,19,2,6,4,'Uhiufyfuuufuugufufufuufu','2025-12-16 09:50:03','[]','[]'),
(5,12,2,6,4,'Holhhggh','2025-12-16 09:58:26','[]','[]'),
(6,23,2,6,4,'','2025-12-16 12:09:04','[]','[\"http:\\/\\/localhost:8000\\/uploads\\/reviews\\/23\\/5440660f20f31ca8.jpg\"]'),
(7,27,2,6,5,'Hola','2025-12-16 14:57:15','[]','[\"http:\\/\\/localhost:8000\\/uploads\\/reviews\\/27\\/0ca2fde4f530cced.jpg\"]'),
(8,68,2,6,3,'Hola','2025-12-17 17:33:47','[\"Profesional\"]','[\"http:\\/\\/localhost:8000\\/uploads\\/reviews\\/68\\/4b8d0fa834f2129c.jpg\"]'),
(9,69,2,6,4,'Hhhjh chuta','2025-12-17 17:36:24','[]','[\"http:\\/\\/localhost:8000\\/uploads\\/reviews\\/69\\/34116c21e463b243.jpg\"]'),
(10,75,2,6,4,'Gato feliz pendejo ','2025-12-17 22:44:44','[]','[\"http:\\/\\/localhost:8000\\/uploads\\/reviews\\/75\\/16d7e8aa0fcb5a5a.jpg\"]'),
(11,84,2,6,4,'Pendejo tú','2025-12-19 06:53:21','[\"Profesional\",\"Puntual\"]','[\"http:\\/\\/localhost:8000\\/uploads\\/reviews\\/84\\/f4b0cf4972469926.jpg\"]'),
(12,88,2,6,5,'Para adelante bartolo','2025-12-19 20:56:37','[\"Puntual\",\"Profesional\",\"Calidad\",\"Limpio\",\"Buen precio\",\"Amable\"]','[\"http:\\/\\/localhost:8000\\/uploads\\/reviews\\/88\\/60f7ce5b87e18d9b.jpg\"]'),
(13,107,2,6,4,'Q','2025-12-23 15:10:16','[]','[]'),
(14,108,2,6,5,'Hdhdjddjjf','2025-12-23 15:29:40','[]','[]'),
(15,111,2,6,3,'Todo fino mano','2025-12-26 08:56:44','[\"Buen precio\"]','[\"http:\\/\\/localhost:8000\\/uploads\\/reviews\\/111\\/ff6a65c5b89d73eb.jpg\"]'),
(16,113,2,6,5,'Gracias por tu servicio','2025-12-27 20:14:52','[\"Puntual\"]','[\"http:\\/\\/localhost:8000\\/uploads\\/reviews\\/113\\/c5d242f1248094b5.jpg\"]'),
(17,114,2,6,5,'Pendejo tú','2025-12-28 05:53:31','[]','[]'),
(18,115,2,6,5,'Hulooo','2025-12-28 12:49:42','[\"Calidad\"]','[]'),
(19,117,2,6,5,'Cabron!?','2025-12-29 03:00:55','[\"Limpio\"]','[]'),
(20,57,6,6,4,'','2026-05-17 08:44:06','[\"Calidad\"]','[]'),
(21,59,6,6,3,'','2026-05-17 09:59:03','[\"Calidad\"]','[]'),
(22,67,6,6,3,'Hola','2026-05-17 21:44:01','[\"Puntual\"]','[]'),
(23,68,6,6,3,'','2026-05-17 22:07:02','[]','[]');
/*!40000 ALTER TABLE `service_reviews` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `services`
--

DROP TABLE IF EXISTS `services`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `services` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `title` varchar(100) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `status` enum('pending','active','inactive','completed') DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `published_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `services`
--

LOCK TABLES `services` WRITE;
/*!40000 ALTER TABLE `services` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `services` VALUES
(10,6,'Airline','Viene con nosotros','active','2025-09-15 03:22:35',NULL,NULL,35,'Promotora','San felipe',NULL,'María Villegas','avatar_1755532362.jpg',0.0,1,'A\r\nB\r\nC\r\nD'),
(11,6,'Lavado general','Servicio de lavado completo','active','2025-12-08 17:00:49',NULL,NULL,10,'Automóvil','San Felipe',NULL,'María Villegas','avatar_1755532362.jpg',4.0,1,''),
(12,6,'Lavado general','Servicio de lavado completo','active','2025-12-08 17:01:45',NULL,NULL,10,'Automóvil','San Felipe',NULL,'María Villegas','avatar_1755532362.jpg',4.0,1,''),
(33,10,'Reparación de televisión','Te dije que no te había dicho nada','active','2026-05-24 12:51:51','2026-05-24 12:53:38','2026-06-23 16:53:38',15,'Clases','Yaracuy, chivacoa','/uploads/services/service_6a12f4670e6351.50217007.jpg','Angie Gutiérrez',NULL,0.0,1,'Te dije que no te había dicho nada de eso no te preocupes que no te preocupes que no te preocupes que no te preocupes que'),
(34,10,'Reparación de televisión','Hola tengo un problema en el frontend de','active','2026-05-24 17:40:28','2026-05-24 17:43:42','2026-06-23 21:43:42',25,'Reparaciones','Yaracuy, chivacoa','/uploads/services/service_6a13380c55ab85.74203959.jpg','Angie Gutiérrez',NULL,0.0,1,'Hola tengo un problema en el frontend de la puerta de la calle de');
/*!40000 ALTER TABLE `services` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `static_pages`
--

DROP TABLE IF EXISTS `static_pages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `static_pages`
--

LOCK TABLES `static_pages` WRITE;
/*!40000 ALTER TABLE `static_pages` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `static_pages` VALUES
(1,'Términos y Condiciones','terms','<div style=\"max-width:800px;margin:0 auto;font-family:\'Inter\',sans-serif;color:#2d3748;line-height:1.8\">\n  \n  <div style=\"background:linear-gradient(135deg,#667eea,#764ba2);color:white;padding:30px;border-radius:16px;margin-bottom:30px;text-align:center\">\n    <span style=\"font-size:48px\">📋</span>\n    <h1 style=\"margin:12px 0 0;font-size:2rem\">Términos y Condiciones</h1>\n    <p style=\"opacity:0.9;margin:8px 0 0\">Última actualización: 2026</p>\n  </div>\n\n  <div style=\"background:#f7fafc;padding:20px;border-radius:12px;margin-bottom:20px;border-left:4px solid #667eea\">\n    <p style=\"margin:0;font-weight:500\">📌 Al utilizar TapClic, aceptas los siguientes términos. Por favor, léelos detenidamente.</p>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#667eea;font-size:1.4rem;margin-top:0;display:flex;align-items:center;gap:8px\">🤝 1. Aceptación de los Términos</h2>\n    <p>Al acceder y utilizar TapClic, aceptas estar sujeto a estos Términos y Condiciones. Si no estás de acuerdo con alguna parte, no podrás usar nuestros servicios.</p>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#667eea;font-size:1.4rem;margin-top:0;display:flex;align-items:center;gap:8px\">📱 2. Descripción del Servicio</h2>\n    <p>TapClic es una plataforma que conecta a clientes con proveedores de servicios. Actuamos como intermediarios tecnológicos y no somos responsables directos por la calidad del servicio prestado.</p>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#667eea;font-size:1.4rem;margin-top:0;display:flex;align-items:center;gap:8px\">👤 3. Cuentas de Usuario</h2>\n    <p>Eres responsable de mantener la confidencialidad de tu cuenta. Debes notificarnos inmediatamente sobre cualquier uso no autorizado. TapClic no se hace responsable por pérdidas derivadas del uso no autorizado de tu cuenta.</p>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#667eea;font-size:1.4rem;margin-top:0;display:flex;align-items:center;gap:8px\">🛠️ 4. Proveedores de Servicios</h2>\n    <p>Los proveedores se comprometen a:</p>\n    <ul style=\"padding-left:20px\">\n      <li>Ofrecer servicios de calidad profesional</li>\n      <li>Cumplir con los acuerdos pactados con los clientes</li>\n      <li>Mantener una comunicación clara y oportuna</li>\n      <li>Respetar las políticas de precios y pagos de la plataforma</li>\n    </ul>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#667eea;font-size:1.4rem;margin-top:0;display:flex;align-items:center;gap:8px\">💳 5. Pagos y Comisiones</h2>\n    <p>TapClic puede cobrar una comisión por transacción. Todos los pagos se procesan de forma segura a través de nuestros métodos autorizados: transferencia bancaria, pago móvil, Zelle y PayPal.</p>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#667eea;font-size:1.4rem;margin-top:0;display:flex;align-items:center;gap:8px\">🔄 6. Cancelaciones</h2>\n    <p>Las políticas de cancelación varían según el servicio. Los reembolsos se procesarán según lo acordado entre las partes involucradas.</p>\n  </div>\n\n  <div style=\"background:linear-gradient(135deg,#667eea,#764ba2);color:white;padding:24px;border-radius:12px;text-align:center\">\n    <p style=\"margin:0;font-size:1.1rem\">📧 ¿Dudas? Contáctanos en <strong>soporte@tapclic.com</strong></p>\n  </div>\n\n</div>','Términos y Condiciones - TapClic','Términos y condiciones de uso de la plataforma TapClic',NULL,1,1,1,'2026-02-01 01:35:00','2026-05-27 17:25:59'),
(2,'Política de Privacidad','privacy','<div style=\"max-width:800px;margin:0 auto;font-family:\'Inter\',sans-serif;color:#2d3748;line-height:1.8\">\n  \n  <div style=\"background:linear-gradient(135deg,#0ea5e9,#3b82f6);color:white;padding:30px;border-radius:16px;margin-bottom:30px;text-align:center\">\n    <span style=\"font-size:48px\">🔒</span>\n    <h1 style=\"margin:12px 0 0;font-size:2rem\">Política de Privacidad</h1>\n    <p style=\"opacity:0.9;margin:8px 0 0\">Tu privacidad es nuestra prioridad</p>\n  </div>\n\n  <div style=\"background:#f0fdf4;padding:20px;border-radius:12px;margin-bottom:20px;border-left:4px solid #22c55e\">\n    <p style=\"margin:0;font-weight:500\">✅ Nos comprometemos a proteger tus datos personales y a ser transparentes sobre cómo los utilizamos.</p>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#0ea5e9;font-size:1.4rem;margin-top:0;display:flex;align-items:center;gap:8px\">📊 1. Datos que Recopilamos</h2>\n    <p>Al registrarte en TapClic, recopilamos:</p>\n    <ul style=\"padding-left:20px\">\n      <li><strong>Datos de identificación:</strong> Nombre, email, teléfono</li>\n      <li><strong>Datos de ubicación:</strong> Ciudad, dirección</li>\n      <li><strong>Datos de uso:</strong> Interacciones con la plataforma</li>\n      <li><strong>Datos de pago:</strong> Información de transacciones</li>\n    </ul>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#0ea5e9;font-size:1.4rem;margin-top:0;display:flex;align-items:center;gap:8px\">🎯 2. Uso de tus Datos</h2>\n    <p>Utilizamos tu información para:</p>\n    <ul style=\"padding-left:20px\">\n      <li>Conectarte con proveedores de servicios</li>\n      <li>Procesar pagos de forma segura</li>\n      <li>Mejorar tu experiencia en la plataforma</li>\n      <li>Enviar notificaciones relevantes</li>\n    </ul>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#0ea5e9;font-size:1.4rem;margin-top:0;display:flex;align-items:center;gap:8px\">🛡️ 3. Protección de Datos</h2>\n    <p>Implementamos cifrado SSL, autenticación segura y medidas técnicas para proteger tu información contra accesos no autorizados.</p>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#0ea5e9;font-size:1.4rem;margin-top:0;display:flex;align-items:center;gap:8px\">🤝 4. No Vendemos tus Datos</h2>\n    <p>No vendemos ni compartimos tu información personal con terceros sin tu consentimiento explícito.</p>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#0ea5e9;font-size:1.4rem;margin-top:0;display:flex;align-items:center;gap:8px\">🍪 5. Cookies</h2>\n    <p>Usamos cookies esenciales para el funcionamiento de la plataforma. Puedes desactivarlas en tu navegador, pero algunas funciones podrían no estar disponibles.</p>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#0ea5e9;font-size:1.4rem;margin-top:0;display:flex;align-items:center;gap:8px\">✍️ 6. Tus Derechos</h2>\n    <p>Tienes derecho a acceder, rectificar y eliminar tus datos personales. Para ejercer estos derechos, contáctanos a <strong>privacidad@tapclic.com</strong>.</p>\n  </div>\n\n  <div style=\"background:linear-gradient(135deg,#0ea5e9,#3b82f6);color:white;padding:24px;border-radius:12px;text-align:center\">\n    <p style=\"margin:0;font-size:1.1rem\">🔐 Tus datos están seguros con nosotros</p>\n  </div>\n\n</div>','Política de Privacidad - TapClic','Política de privacidad y protección de datos de TapClic',NULL,1,1,2,'2026-02-01 01:35:00','2026-05-27 17:27:06'),
(3,'Acerca de Nosotros','about','<div style=\"max-width:800px;margin:0 auto;font-family:\'Inter\',sans-serif;color:#2d3748;line-height:1.8\">\n  \n  <div style=\"background:linear-gradient(135deg,#8b5cf6,#a855f7);color:white;padding:30px;border-radius:16px;margin-bottom:30px;text-align:center\">\n    <span style=\"font-size:48px\">🚀</span>\n    <h1 style=\"margin:12px 0 0;font-size:2rem\">Acerca de TapClic</h1>\n    <p style=\"opacity:0.9;margin:8px 0 0\">Conectando personas, simplificando servicios</p>\n  </div>\n\n  <div style=\"background:white;padding:30px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px;text-align:center\">\n    <h2 style=\"color:#8b5cf6;font-size:1.6rem;margin-top:0\">✨ Nuestra Misión</h2>\n    <p style=\"font-size:1.15rem\">Simplificar la conexión entre clientes y proveedores de servicios, creando una plataforma confiable, rápida y segura donde todos ganan.</p>\n  </div>\n\n  <div style=\"display:grid;grid-template-columns:1fr 1fr;gap:20px;margin-bottom:20px\">\n    <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);text-align:center\">\n      <span style=\"font-size:40px\">👥</span>\n      <h3 style=\"color:#8b5cf6;margin:8px 0\">Para Clientes</h3>\n      <p style=\"margin:0\">Encuentra el servicio que necesitas en segundos. Compara, contrata y paga de forma segura.</p>\n    </div>\n    <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);text-align:center\">\n      <span style=\"font-size:40px\">🛠️</span>\n      <h3 style=\"color:#8b5cf6;margin:8px 0\">Para Proveedores</h3>\n      <p style=\"margin:0\">Haz crecer tu negocio. Publica tus servicios, recibe clientes y genera ingresos.</p>\n    </div>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#8b5cf6;font-size:1.4rem;margin-top:0;text-align:center\">⚡ ¿Cómo Funciona?</h2>\n    <div style=\"display:flex;justify-content:space-around;flex-wrap:wrap;gap:16px;margin-top:16px\">\n      <div style=\"text-align:center;flex:1;min-width:120px\">\n        <div style=\"background:#f3e8ff;width:60px;height:60px;border-radius:50%;display:flex;align-items:center;justify-content:center;margin:0 auto 8px;font-size:24px\">1️⃣</div>\n        <p style=\"font-weight:600;margin:4px 0\">Publica</p>\n        <p style=\"font-size:13px;color:#64748b\">Tu servicio o necesidad</p>\n      </div>\n      <div style=\"text-align:center;flex:1;min-width:120px\">\n        <div style=\"background:#f3e8ff;width:60px;height:60px;border-radius:50%;display:flex;align-items:center;justify-content:center;margin:0 auto 8px;font-size:24px\">2️⃣</div>\n        <p style=\"font-weight:600;margin:4px 0\">Conecta</p>\n        <p style=\"font-size:13px;color:#64748b\">Con la persona ideal</p>\n      </div>\n      <div style=\"text-align:center;flex:1;min-width:120px\">\n        <div style=\"background:#f3e8ff;width:60px;height:60px;border-radius:50%;display:flex;align-items:center;justify-content:center;margin:0 auto 8px;font-size:24px\">3️⃣</div>\n        <p style=\"font-weight:600;margin:4px 0\">Acuerda</p>\n        <p style=\"font-size:13px;color:#64748b\">Detalles y pago seguro</p>\n      </div>\n      <div style=\"text-align:center;flex:1;min-width:120px\">\n        <div style=\"background:#f3e8ff;width:60px;height:60px;border-radius:50%;display:flex;align-items:center;justify-content:center;margin:0 auto 8px;font-size:24px\">4️⃣</div>\n        <p style=\"font-weight:600;margin:4px 0\">Califica</p>\n        <p style=\"font-size:13px;color:#64748b\">Tu experiencia</p>\n      </div>\n    </div>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#8b5cf6;font-size:1.4rem;margin-top:0;text-align:center\">💎 Nuestros Valores</h2>\n    <div style=\"display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-top:16px\">\n      <div style=\"background:#faf5ff;padding:16px;border-radius:8px;text-align:center\">🤝 <strong>Confianza</strong></div>\n      <div style=\"background:#faf5ff;padding:16px;border-radius:8px;text-align:center\">🔍 <strong>Transparencia</strong></div>\n      <div style=\"background:#faf5ff;padding:16px;border-radius:8px;text-align:center\">⭐ <strong>Calidad</strong></div>\n      <div style=\"background:#faf5ff;padding:16px;border-radius:8px;text-align:center\">💜 <strong>Comunidad</strong></div>\n    </div>\n  </div>\n\n  <div style=\"background:linear-gradient(135deg,#8b5cf6,#a855f7);color:white;padding:24px;border-radius:12px;text-align:center\">\n    <p style=\"margin:0;font-size:1.1rem\">🌟 Únete a nuestra comunidad en crecimiento</p>\n  </div>\n\n</div>','Acerca de Nosotros - TapClic','Conoce más sobre TapClic, la plataforma que conecta clientes con proveedores de servicios',NULL,1,1,3,'2026-02-01 01:35:00','2026-05-27 17:28:07'),
(4,'Ayuda y Soporte','help','<div style=\"max-width:800px;margin:0 auto;font-family:\'Inter\',sans-serif;color:#2d3748;line-height:1.8\">\n  \n  <div style=\"background:linear-gradient(135deg,#f59e0b,#f97316);color:white;padding:30px;border-radius:16px;margin-bottom:30px;text-align:center\">\n    <span style=\"font-size:48px\">💡</span>\n    <h1 style=\"margin:12px 0 0;font-size:2rem\">Ayuda y Soporte</h1>\n    <p style=\"opacity:0.9;margin:8px 0 0\">Estamos aquí para ayudarte</p>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#f59e0b;font-size:1.4rem;margin-top:0;display:flex;align-items:center;gap:8px\">🙋 1. Para Clientes</h2>\n    \n    <div style=\"background:#fffbeb;padding:16px;border-radius:8px;margin-bottom:12px\">\n      <p style=\"font-weight:600;margin:0 0 4px\">📌 ¿Cómo solicito un servicio?</p>\n      <p style=\"margin:0;font-size:14px\">Explora los servicios disponibles, elige el que necesitas y haz clic en \"Solicitar Servicio\". El proveedor recibirá tu solicitud al instante.</p>\n    </div>\n    \n    <div style=\"background:#fffbeb;padding:16px;border-radius:8px;margin-bottom:12px\">\n      <p style=\"font-weight:600;margin:0 0 4px\">💳 ¿Cómo pago?</p>\n      <p style=\"margin:0;font-size:14px\">Aceptamos transferencia bancaria, pago móvil, Zelle y PayPal. Elige tu método preferido al confirmar el servicio.</p>\n    </div>\n    \n    <div style=\"background:#fffbeb;padding:16px;border-radius:8px;margin-bottom:12px\">\n      <p style=\"font-weight:600;margin:0 0 4px\">❌ ¿Puedo cancelar?</p>\n      <p style=\"margin:0;font-size:14px\">Sí, puedes cancelar antes de que el proveedor confirme. Revisa nuestra política de cancelación para más detalles.</p>\n    </div>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#f59e0b;font-size:1.4rem;margin-top:0;display:flex;align-items:center;gap:8px\">🛠️ 2. Para Proveedores</h2>\n    \n    <div style=\"background:#fffbeb;padding:16px;border-radius:8px;margin-bottom:12px\">\n      <p style=\"font-weight:600;margin:0 0 4px\">📝 ¿Cómo me registro como proveedor?</p>\n      <p style=\"margin:0;font-size:14px\">Regístrate normalmente y completa tu perfil de proveedor con tus datos, servicios ofrecidos y métodos de pago.</p>\n    </div>\n    \n    <div style=\"background:#fffbeb;padding:16px;border-radius:8px;margin-bottom:12px\">\n      <p style=\"font-weight:600;margin:0 0 4px\">💰 ¿Cómo recibo mis pagos?</p>\n      <p style=\"margin:0;font-size:14px\">Los pagos se procesan a través de la plataforma. Configura tus métodos de cobro en tu panel de proveedor.</p>\n    </div>\n  </div>\n\n  <div style=\"background:linear-gradient(135deg,#f59e0b,#f97316);color:white;padding:24px;border-radius:12px;margin-bottom:20px\">\n    <h2 style=\"margin-top:0;text-align:center\">📞 Contacto Directo</h2>\n    <div style=\"display:grid;grid-template-columns:1fr 1fr 1fr;gap:16px;margin-top:16px;text-align:center\">\n      <div>\n        <span style=\"font-size:28px\">📧</span>\n        <p style=\"margin:4px 0;font-weight:600\">Email</p>\n        <p style=\"margin:0;font-size:14px\">soporte@tapclic.com</p>\n      </div>\n      <div>\n        <span style=\"font-size:28px\">📱</span>\n        <p style=\"margin:4px 0;font-weight:600\">WhatsApp</p>\n        <p style=\"margin:0;font-size:14px\">+58 412-0000000</p>\n      </div>\n      <div>\n        <span style=\"font-size:28px\">💬</span>\n        <p style=\"margin:4px 0;font-weight:600\">Chat en vivo</p>\n        <p style=\"margin:0;font-size:14px\">En la plataforma</p>\n      </div>\n    </div>\n  </div>\n\n</div>','Ayuda y Soporte - TapClic','Centro de ayuda y soporte de TapClic. Encuentra respuestas y contacta con nosotros',NULL,1,0,4,'2026-02-01 01:35:00','2026-05-27 17:49:22'),
(5,'Contacto','contact','<div style=\"max-width:800px;margin:0 auto;font-family:\'Inter\',sans-serif;color:#2d3748;line-height:1.8\">\n  \n  <div style=\"background:linear-gradient(135deg,#10b981,#059669);color:white;padding:30px;border-radius:16px;margin-bottom:30px;text-align:center\">\n    <span style=\"font-size:48px\">📬</span>\n    <h1 style=\"margin:12px 0 0;font-size:2rem\">Contacto</h1>\n    <p style=\"opacity:0.9;margin:8px 0 0\">Estamos aquí para ti</p>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#10b981;font-size:1.4rem;margin-top:0;text-align:center\">¿Cómo podemos ayudarte?</h2>\n    <p style=\"text-align:center\">Elige el canal de comunicación que prefieras. Te responderemos lo antes posible.</p>\n  </div>\n\n  <div style=\"display:grid;grid-template-columns:1fr 1fr;gap:20px;margin-bottom:20px\">\n    <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);text-align:center\">\n      <div style=\"background:#d1fae5;width:64px;height:64px;border-radius:50%;display:flex;align-items:center;justify-content:center;margin:0 auto 12px;font-size:28px\">📧</div>\n      <h3 style=\"color:#10b981;margin:0 0 8px\">Correo Electrónico</h3>\n      <p style=\"margin:0;font-size:14px\"><strong>Servicio al Cliente:</strong><br>soporte@tapclic.com</p>\n      <p style=\"margin:8px 0 0;font-size:14px\"><strong>Proveedores:</strong><br>proveedores@tapclic.com</p>\n    </div>\n    \n    <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);text-align:center\">\n      <div style=\"background:#d1fae5;width:64px;height:64px;border-radius:50%;display:flex;align-items:center;justify-content:center;margin:0 auto 12px;font-size:28px\">📱</div>\n      <h3 style=\"color:#10b981;margin:0 0 8px\">Teléfono</h3>\n      <p style=\"margin:0;font-size:14px\"><strong>WhatsApp:</strong><br>+58 412-0000000</p>\n      <p style=\"margin:8px 0 0;font-size:14px\"><strong>Atención Telefónica:</strong><br>+58 212-0000000</p>\n    </div>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#10b981;font-size:1.4rem;margin-top:0;text-align:center\">🕐 Horario de Atención</h2>\n    <div style=\"text-align:center;background:#f0fdf4;padding:16px;border-radius:8px\">\n      <p style=\"font-weight:600;margin:0\">Lunes a Viernes</p>\n      <p style=\"margin:4px 0 0;font-size:14px\">8:00 AM - 6:00 PM (Hora de Venezuela)</p>\n    </div>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px\">\n    <h2 style=\"color:#10b981;font-size:1.4rem;margin-top:0;text-align:center\">📍 Ubicación</h2>\n    <p style=\"text-align:center\">Caracas, Venezuela</p>\n  </div>\n\n  <div style=\"background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin-bottom:20px;text-align:center\">\n    <h2 style=\"color:#10b981;font-size:1.4rem;margin-top:0\">🌐 Síguenos</h2>\n    <div style=\"display:flex;justify-content:center;gap:20px;margin-top:16px\">\n      <div style=\"text-align:center\">📸 <strong>Instagram</strong><br><span style=\"font-size:14px\">@tapclic</span></div>\n      <div style=\"text-align:center\">👍 <strong>Facebook</strong><br><span style=\"font-size:14px\">/tapclic</span></div>\n      <div style=\"text-align:center\">🐦 <strong>Twitter</strong><br><span style=\"font-size:14px\">@tapclic</span></div>\n    </div>\n  </div>\n\n  <div style=\"background:linear-gradient(135deg,#10b981,#059669);color:white;padding:24px;border-radius:12px;text-align:center\">\n    <p style=\"margin:0;font-size:1.1rem\">💚 ¡Gracias por confiar en TapClic!</p>\n  </div>\n\n</div>',NULL,NULL,NULL,1,1,5,'2026-02-01 01:35:00','2026-05-27 17:28:27');
/*!40000 ALTER TABLE `static_pages` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `support_tickets`
--

DROP TABLE IF EXISTS `support_tickets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `support_tickets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `category` varchar(50) DEFAULT 'other',
  `priority` enum('low','medium','high','urgent') DEFAULT 'medium',
  `status` enum('open','in_progress','pending','resolved','closed') DEFAULT 'open',
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `support_tickets`
--

LOCK TABLES `support_tickets` WRITE;
/*!40000 ALTER TABLE `support_tickets` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `support_tickets` VALUES
(1,6,'problema','No me pagaron','payment','high','in_progress',1,NULL,4,'2026-05-25 01:24:53','2025-10-03 08:22:14','2026-05-25 01:24:53'),
(2,2,'Problema dos','Tengo un dedito pantu culito','account','medium','open',1,NULL,0,NULL,'2026-01-17 20:28:48','2026-04-27 07:10:34'),
(3,2,'Problema','No me pagaron','payment','medium','open',NULL,NULL,0,NULL,'2026-01-25 12:53:30','2026-01-25 12:53:30'),
(4,6,'No me devolvieron','Después me pagas','technical','low','closed',NULL,'[{\"name\":\"Gggh\",\"color\":\"blue\"}]',0,NULL,'2026-01-25 12:54:08','2026-02-21 15:04:13');
/*!40000 ALTER TABLE `support_tickets` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `system_config`
--

DROP TABLE IF EXISTS `system_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
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
  `service_publish_cost` decimal(10,2) DEFAULT 0.00,
  `service_publish_duration` int(11) DEFAULT 30,
  `monetization_model` enum('commission','publish','both') DEFAULT 'commission',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_config`
--

LOCK TABLES `system_config` WRITE;
/*!40000 ALTER TABLE `system_config` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `system_config` VALUES
(1,'TapClic','http://192.168.246.12:5173','http://192.168.246.12:3001',1,'1.0.0','/assets/logo.png','/assets/favicon.ico','es','America/Caracas','USD','soporte@tapclic.com','+58 123 456 7890','smtp.gmail.com',587,'tls',NULL,NULL,'notificaciones@tapclic.com','TapClic',NULL,NULL,NULL,'TapClic C.A.','Yaracuy, Venezuela',0,5,90,30,20,'#409EFF',1,0,1,1,1,1,NULL,'2025-08-17 21:44:41','2026-05-28 11:26:46',2.00,0.00,NULL,5.00,30,'both');
/*!40000 ALTER TABLE `system_config` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `ticket_replies`
--

DROP TABLE IF EXISTS `ticket_replies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ticket_replies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ticket_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `user_type` enum('user','admin') NOT NULL,
  `message` text NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `is_internal` tinyint(1) DEFAULT 0,
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  `is_admin` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `idx_ticket` (`ticket_id`),
  CONSTRAINT `ticket_replies_ibfk_1` FOREIGN KEY (`ticket_id`) REFERENCES `support_tickets` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ticket_replies_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ticket_replies`
--

LOCK TABLES `ticket_replies` WRITE;
/*!40000 ALTER TABLE `ticket_replies` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `ticket_replies` VALUES
(1,1,1,'admin','Tytfhhffghjjjj vggffhhgg','2026-05-24 21:38:35',0,NULL,0),
(2,1,1,'admin','Hola tengo un problema en el frontend de la puerta de la calle de ','2026-05-25 00:39:48',0,NULL,0),
(3,1,1,'admin','Holjhhjjhhggggghhjj','2026-05-25 00:40:29',0,NULL,0),
(4,1,1,'admin','Comentario de prueba','2026-05-25 01:05:14',0,NULL,1),
(5,1,1,'admin','Prueba ','2026-05-25 01:10:14',0,NULL,0),
(6,1,1,'admin','123456789','2026-05-25 01:22:27',0,NULL,0),
(7,1,1,'admin','Hay ','2026-05-25 01:24:43',0,NULL,0),
(8,1,1,'admin','Hola ','2026-05-25 01:24:53',0,NULL,0);
/*!40000 ALTER TABLE `ticket_replies` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `token_blacklist`
--

DROP TABLE IF EXISTS `token_blacklist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `token_blacklist`
--

LOCK TABLES `token_blacklist` WRITE;
/*!40000 ALTER TABLE `token_blacklist` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `token_blacklist` VALUES
(3,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3NzM0MDQ3Njd9.2t67mqo9JOYkMoVaoNXRkk0U7iD8RGkZ44gfCz7nM8I',NULL,'2026-04-27 09:51:17','192.168.0.100'),
(6,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3NzkwMTUwNTh9.-dcUjD1otxZlPfrl_BQyt580c0nVDulf9ZUh-W5vmHU',NULL,'2026-05-17 22:37:20','192.168.46.12'),
(7,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3Nzc4NDU2MzZ9.vp4uZiUSYeeBO2AtKfgSYRzx-7OoptU9CmVztr0a-9E',NULL,'2026-05-17 22:37:26','192.168.46.12'),
(8,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3Nzc5NzUxNDB9.Dn_sTR5sDbtOCqJtEbB5Bhsni0FiDPBXi7a9qh9Gsuk',NULL,'2026-05-17 22:37:32','192.168.46.12'),
(9,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3Nzg1MTI2MTZ9.paPHkdnHtXIWHzj5wnXqUm6qIJZq_whL5iSBBTBO8bo',NULL,'2026-05-17 22:37:37','192.168.46.12'),
(10,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3Nzg1OTAwMjZ9.u8yfJSUCF-tycSE2ERjYsuzFC8c5eaIQxCXJjEv9QUw',NULL,'2026-05-17 22:37:41','192.168.46.12'),
(11,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3Nzg1OTAyODd9.Y4_Mv0X0xA3Q0-i1OxTosLPMy3CvRlPEMQbOdOHuipo',NULL,'2026-05-17 22:37:45','192.168.46.12'),
(12,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3NzkwMTIzNjN9.W1RB6U0WtXz6IYZwxKDnIuKTBgjBJ60JDW5Ed5yG5pc',NULL,'2026-05-17 22:37:48','192.168.46.12');
/*!40000 ALTER TABLE `token_blacklist` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `user_devices`
--

DROP TABLE IF EXISTS `user_devices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=83 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_devices`
--

LOCK TABLES `user_devices` WRITE;
/*!40000 ALTER TABLE `user_devices` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `user_devices` VALUES
(5,1,'💻 Linux - Chrome','desktop','Chrome','Linux','d11d9f2490f98b31139a2744b8668cf2','192.168.1.248',NULL,'2026-02-23 18:31:47',0,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MSwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzcyNDc2MzA3fQ.wNcPKKLV42qDTIhk_05utc-GvoXf7r5WtSQYHAdDLdA','2026-02-17 17:48:55','2026-04-27 11:08:20'),
(6,1,'💻 Desconocido - Desconocido','desktop','Desconocido','Desconocido','edea46c721b25f1c04097ebf315a06ad','192.168.1.248',NULL,'2026-02-23 02:24:15',0,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MSwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzcyNDE4MjU1fQ._Q8ho0albMsGwjodGo764DawjXAWDWMHyuQU4GaJY04','2026-02-18 03:05:46','2026-02-23 18:31:47'),
(44,1,'💻 Linux - Chrome','desktop','Chrome','Linux','98dfabfd8eb66054824a069370f90231','192.168.0.100',NULL,'2026-04-27 11:08:20',0,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MSwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzc3ODkyOTAwfQ.4r3Wk96lZ9xJMYDrWsnue-EtEQTxlPASPulkisO1ziI','2026-04-27 11:08:20','2026-05-18 13:40:00'),
(54,6,'💻 Linux - Chrome','desktop','Chrome','Linux','3fade4641353aaab70d2476d3b1a69b3','192.168.31.219',NULL,'2026-05-24 21:16:38',0,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Niwicm9sZSI6InByb3ZpZGVyIiwiZXhwIjoxNzgwMjYyMTk4fQ.m4FR6QM-ajjaKDudwcRE2zMgSZTHOGbRMaV_qPQSgzQ','2026-05-12 14:45:00','2026-05-27 18:02:04'),
(55,6,'💻 Linux - Chrome','desktop','Chrome','Linux','6266caa5e94e644eb2d56143c783b158','192.168.31.53',NULL,'2026-05-24 19:30:16',0,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Niwicm9sZSI6InByb3ZpZGVyIiwiZXhwIjoxNzgwMjU1ODE2fQ.ni5_w4yQtxhB7E2xYcfb7tWPlaaJorxFt8fH9GTF7h0','2026-05-13 10:49:07','2026-05-24 21:16:38'),
(58,6,'💻 Linux - Chrome','desktop','Chrome','Linux','ada144e45306bfe0c8dd8159ac43ffda','192.168.46.220',NULL,'2026-05-17 10:19:50',0,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Niwicm9sZSI6InByb3ZpZGVyIiwiZXhwIjoxNzc5NjE3OTkwfQ.scyg30PDPjvXO5YFF5ehI2Z2ZorKhzltm37Q1vt67kc','2026-05-15 13:02:42','2026-05-17 10:19:54'),
(59,6,'💻 Linux - Chrome','desktop','Chrome','Linux','25c009cae2a22231f81d20cb01db5a82','192.168.46.12',NULL,'2026-05-17 10:19:54',0,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Niwicm9sZSI6InByb3ZpZGVyIiwiZXhwIjoxNzc5NjE3OTk0fQ.Nr_rEOWQAdmL9X034DE1Upe283AIIODuGmtT4CvfheE','2026-05-17 10:19:54','2026-05-19 10:15:49'),
(60,2,'💻 Linux - Chrome','desktop','Chrome','Linux','25c009cae2a22231f81d20cb01db5a82','192.168.46.12',NULL,'2026-05-17 10:21:08',0,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3Nzk2MTgwNjh9.hAYSP9IJ_BH0qKzMXxGe4XXpl2excoe-P9CRybvzYnY','2026-05-17 10:21:08','2026-05-19 10:27:31'),
(61,1,'💻 Linux - Chrome','desktop','Chrome','Linux','25c009cae2a22231f81d20cb01db5a82','192.168.46.12',NULL,'2026-05-18 13:40:00',0,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MSwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzc5NzE2NDAwfQ.eiM6EkHhnsTqd__W54OjF0CTthfg0WDiO8UsHSBqjpI','2026-05-18 13:40:00','2026-05-19 10:16:59'),
(62,6,'💻 Linux - Chrome','desktop','Chrome','Linux','e514e28eabd6e4a29650809fb73d71d7','192.168.142.12',NULL,'2026-05-19 10:15:49',0,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Niwicm9sZSI6InByb3ZpZGVyIiwiZXhwIjoxNzc5NzkwNTQ5fQ.O24v3TW4204KO34AsZqbqrSMn8JAI_NYGzo51rp05zM','2026-05-19 10:15:49','2026-05-19 10:29:09'),
(63,1,'💻 Linux - Chrome','desktop','Chrome','Linux','e514e28eabd6e4a29650809fb73d71d7','192.168.142.12',NULL,'2026-05-20 19:12:01',0,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MSwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzc5OTA5MTIxfQ.WGLNg_jGQT8Hsllz2uJwIIQs6Z3kJAkOjESppsKFfo8','2026-05-19 10:16:59','2026-05-21 23:41:35'),
(64,2,'💻 Linux - Chrome','desktop','Chrome','Linux','0452ac37d8eecc772b4d378a38a7edf4','192.168.142.24',NULL,'2026-05-19 10:27:31',0,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3Nzk3OTEyNTF9.cjfjAZUYM3U_9nRLo4ULRx2KKTv3_oxQIaHADF8LvQI','2026-05-19 10:27:31','2026-05-24 13:21:23'),
(65,6,'💻 Linux - Chrome','desktop','Chrome','Linux','0452ac37d8eecc772b4d378a38a7edf4','192.168.142.24',NULL,'2026-05-19 10:29:27',0,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Niwicm9sZSI6InByb3ZpZGVyIiwiZXhwIjoxNzc5NzkxMzY3fQ.hlsbbjZAJ1Wkz04NTC-KajXV3sRQRb7ar_lZm6tFz8c','2026-05-19 10:29:09','2026-05-21 22:36:10'),
(66,6,'💻 Linux - Chrome','desktop','Chrome','Linux','caeba47f5a52c2862adb3ab8157fa9c5','192.168.21.12',NULL,'2026-05-23 18:20:57',0,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Niwicm9sZSI6InByb3ZpZGVyIiwiZXhwIjoxNzgwMTY1MjU3fQ.ajNSJgyW0UQhfdP--rTZHPsWsM4U0rTFrLLgIzqc9Lw','2026-05-21 22:36:10','2026-05-24 14:21:38'),
(67,1,'💻 Linux - Chrome','desktop','Chrome','Linux','caeba47f5a52c2862adb3ab8157fa9c5','192.168.21.12',NULL,'2026-05-23 15:48:15',0,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MSwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzgwMTU2MDk1fQ.e3Kdp2qjsnOGn1hoEQLImMxDkOpjmCHa-hks5434tWU','2026-05-21 23:41:35','2026-05-24 10:12:49'),
(68,10,'💻 Linux - Chrome','desktop','Chrome','Linux','caeba47f5a52c2862adb3ab8157fa9c5','192.168.21.12',NULL,'2026-05-23 18:21:37',0,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MTAsInJvbGUiOiJwcm92aWRlciIsImV4cCI6MTc4MDE2NTI5N30.Tr15P-H4_gyNlmThXPto8QUOyJIN0n62IM4AYmm2I7w','2026-05-22 01:48:50','2026-05-24 12:50:05'),
(69,1,'💻 Linux - Chrome','desktop','Chrome','Linux','e5efaf03fe081bb8e796b125378d47e9','192.168.21.41',NULL,'2026-05-22 02:39:50',0,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MSwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzgwMDIyMzkwfQ.rer1NDzgaZzH0imOn-IK4zGOQt6jwIeel25Yr1424g8','2026-05-22 02:39:50','2026-05-23 15:14:27'),
(70,1,'💻 Linux - Firefox','desktop','Firefox','Linux','4eb133256642127a539cb4503125320d','192.168.21.12',NULL,'2026-05-24 10:12:49',0,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MSwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzgwMjIyMzY5fQ.DXK0F8taFyNKrpiiEiJgFoz7x4AiA82AIO8tM7Q3ETs','2026-05-24 10:12:49','2026-05-24 12:53:05'),
(71,10,'💻 Linux - Chrome','desktop','Chrome','Linux','6266caa5e94e644eb2d56143c783b158','192.168.31.53',NULL,'2026-05-24 17:34:45',1,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MTAsInJvbGUiOiJwcm92aWRlciIsImV4cCI6MTc4MDI0ODg4NX0.XLQnxQ4hAAH5_c5s-g4hdfDIKI1hBpbMoeVminTHDdg','2026-05-24 12:50:05','2026-05-24 17:34:45'),
(72,1,'💻 Linux - Firefox','desktop','Firefox','Linux','3d26b256f8a35e1110e8989285cdb17f','192.168.31.53',NULL,'2026-05-25 09:56:42',0,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MSwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzgwMzA3ODAyfQ.sXF65wfTrawvodPUPyBsEr4_XGVUIQgX3xaDUZORfSU','2026-05-24 12:53:05','2026-05-27 05:34:07'),
(73,2,'💻 Linux - Chrome','desktop','Chrome','Linux','3fade4641353aaab70d2476d3b1a69b3','192.168.31.219',NULL,'2026-05-24 13:21:23',0,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODAyMzM2ODN9.-te120vfZFGOXj1MQlMgTQ9J4hp8p5TlqPIm9MYdj10','2026-05-24 13:21:23','2026-05-24 14:44:08'),
(74,6,'💻 Desconocido - Desconocido','desktop','Desconocido','Desconocido','b8164478fe9edd1e52ae9de7c9be9c9f','192.168.31.53',NULL,'2026-05-24 14:46:23',0,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Niwicm9sZSI6InByb3ZpZGVyIiwiZXhwIjoxNzgwMjM4NzgzfQ.3rc9I5EBEV0ql1o2YOvXwGTryKnx-isuDRUcGI60cjU','2026-05-24 14:41:33','2026-05-24 15:29:04'),
(75,2,'💻 Desconocido - Desconocido','desktop','Desconocido','Desconocido','b8164478fe9edd1e52ae9de7c9be9c9f','192.168.31.53',NULL,'2026-05-24 14:44:08',0,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODAyMzg2NDh9.kKG1RwwwktcWxNLcVLpaVdhIQVUGeiVwRi2ktip1uUI','2026-05-24 14:44:08','2026-05-24 19:44:45'),
(76,2,'💻 Linux - Chrome','desktop','Chrome','Linux','6266caa5e94e644eb2d56143c783b158','192.168.31.53',NULL,'2026-05-24 21:10:30',0,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODAyNjE4MzB9.RRfP3OBAAUAIcz_ka6CQDYypnLk91LVlO3bfgdqJaG8','2026-05-24 19:44:45','2026-05-26 19:04:09'),
(77,2,'💻 Linux - Chrome','desktop','Chrome','Linux','5218bf5bc2fc71dfc6b5b5e262412518','192.168.206.12',NULL,'2026-05-26 19:04:09',0,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODA0MjcwNDl9.GXsoG69lNGr-xFT08nzzG9f-_y0kFU5PEggk01-KKdk','2026-05-26 19:04:09','2026-05-27 18:01:07'),
(78,1,'💻 Linux - Chrome','desktop','Chrome','Linux','c6b562a2381c8cc5870216ae9d3f02ac','192.168.192.12',NULL,'2026-05-27 17:46:39',1,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MSwicm9sZSI6ImFkbWluIiwiZXhwIjoxNzgwNTA4Nzk5fQ.jJ3b7JEPcby9ZWWWQENdPGSn3UIofBdrIxjCfs70CS8','2026-05-27 05:34:07','2026-05-27 17:46:39'),
(79,2,'💻 Linux - Chrome','desktop','Chrome','Linux','c6b562a2381c8cc5870216ae9d3f02ac','192.168.192.12',NULL,'2026-05-27 18:01:07',0,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODA1MDk2Njd9.C4izRbONu5dCoau6OUX40bohHoR5QyPuRuy4_lTtlzs','2026-05-27 18:01:07','2026-05-28 11:30:09'),
(80,6,'💻 Linux - Chrome','desktop','Chrome','Linux','c6b562a2381c8cc5870216ae9d3f02ac','192.168.192.12',NULL,'2026-05-27 18:02:04',0,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Niwicm9sZSI6InByb3ZpZGVyIiwiZXhwIjoxNzgwNTA5NzI0fQ.1qSrQBa-MZHa_s5bz3OHgXe6FPkRSYSA-vPy7tH3lxA','2026-05-27 18:02:04','2026-05-28 01:13:37'),
(81,6,'💻 Linux - Chrome','desktop','Chrome','Linux','3c69900ed464f4d7df4bedfb825cc0ed','192.168.115.12',NULL,'2026-05-28 01:13:37',1,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Niwicm9sZSI6InByb3ZpZGVyIiwiZXhwIjoxNzgwNTM1NjE3fQ.rXSxU0QB7CFAEQFQXdfVbKysaBUaCnOMk2bJDF3YWXA','2026-05-28 01:13:37','2026-05-28 01:13:37'),
(82,2,'📱 Android - Chrome','mobile','Chrome','Android','0160b7a068f7695ae0ec47f881a27b55','192.168.246.12',NULL,'2026-05-28 11:30:09',1,'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Miwicm9sZSI6InVzZXIiLCJleHAiOjE3ODA1NzI2MDl9.VaJEbKJPOJ6A38MAohMd1kW-a26WvsOl-aGUVC5X7Ok','2026-05-28 11:30:09','2026-05-28 11:30:09');
/*!40000 ALTER TABLE `user_devices` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `user_reviews`
--

DROP TABLE IF EXISTS `user_reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_reviews`
--

LOCK TABLES `user_reviews` WRITE;
/*!40000 ALTER TABLE `user_reviews` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `user_reviews` VALUES
(1,82,6,2,4,'Le dieron a la tadio','2025-12-18 03:14:50','[\"http:\\/\\/localhost:8000\\/uploads\\/user-reviews\\/82\\/99e1b3e042d55d7b.png\"]','[]'),
(2,83,6,2,4,'Itachi ichija','2025-12-18 04:08:18','[\"http:\\/\\/localhost:8000\\/uploads\\/user-reviews\\/83\\/ecbac003bc648180.jpg\"]','[]'),
(3,86,6,2,3,'Hola de nuevo','2025-12-19 10:56:50','[\"http:\\/\\/localhost:8000\\/uploads\\/user-reviews\\/86\\/071d445f1b580248.jpg\"]','[]'),
(4,88,6,2,5,'Para adelante funciona','2025-12-20 00:55:47','[\"http:\\/\\/localhost:8000\\/uploads\\/user-reviews\\/88\\/99f5dd205e9c7cb9.jpg\"]','[]'),
(5,89,6,2,1,'Pendejo juego de programación','2025-12-21 15:49:03','[\"http:\\/\\/localhost:8000\\/uploads\\/user-reviews\\/89\\/5bc22e04e3ded17f.jpg\"]','[\"Buen precio\"]'),
(6,90,6,2,2,'Hola','2025-12-22 10:52:16','[\"http:\\/\\/localhost:8000\\/uploads\\/user-reviews\\/90\\/cd7fb1f676e7b14d.png\"]','[\"Amable\"]'),
(7,91,6,2,5,'12345678','2025-12-22 11:15:59','[\"http:\\/\\/localhost:8000\\/uploads\\/user-reviews\\/91\\/a7d705a48d3b7077.jpg\"]','[\"Puntual\",\"Limpio\"]'),
(8,97,6,2,5,'Hjhggvbhh','2025-12-22 11:32:49','[]','[]'),
(9,110,6,2,5,'','2025-12-23 19:31:46','[\"http:\\/\\/localhost:8000\\/uploads\\/user-reviews\\/110\\/6b7a14a9f2ba9436.jpg\"]','[\"Buen precio\"]'),
(10,111,6,2,3,'Todo cálida en verduras','2025-12-26 12:55:53','[\"http:\\/\\/localhost:8000\\/uploads\\/user-reviews\\/111\\/d2b03fba345952a2.jpg\"]','[\"Puntual\"]'),
(11,112,6,2,4,'Paga en efectivo','2025-12-26 19:45:22','[]','[\"Amable\"]'),
(12,113,6,2,5,'Super fino','2025-12-28 00:14:02','[\"http:\\/\\/localhost:8000\\/uploads\\/user-reviews\\/113\\/0cf00213457b3501.jpg\"]','[\"Profesional\"]'),
(13,114,6,2,5,'Poendejo','2025-12-28 09:53:07','[]','[]'),
(14,115,6,2,5,'Yholtuholdsvh','2025-12-28 16:46:26','[]','[]'),
(15,116,6,2,5,'123456','2025-12-28 19:08:02','[]','[\"Profesional\",\"Calidad\"]'),
(16,117,6,2,5,'Holaaa','2025-12-29 07:00:27','[]','[\"Calidad\"]'),
(17,118,6,2,5,'Hooolllwsggth','2026-01-02 16:38:29','[]','[\"Limpio\"]'),
(18,120,6,2,4,'','2026-01-02 20:24:15','[]','[\"Profesional\"]'),
(19,122,6,2,3,'','2026-01-02 21:36:47','[]','[\"Calidad\"]');
/*!40000 ALTER TABLE `user_reviews` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `users` VALUES
(1,'Jesús Admin',NULL,'admin@example.com','04120761886','','$2y$12$WqOP3xcaqC/4CMNJXhTohOZVS/KRr2Q8Fi8NgUYE8eEXA6qpqUg76','admin','2025-08-06 02:27:23','avatar_1755006875.jpg',0.0,'{\"notifications\":{\"email\":true,\"sms\":true,\"push\":false,\"updated_at\":\"2026-02-17 20:52:25\"}}','','','',1,'2026-05-27 18:00:48','pending',NULL,NULL,NULL,NULL,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,0,0),
(2,'Jesús Díaz Villegas',NULL,'divijeal@gmail.com','04125048497','Valles de Aroa','$2y$12$/4gCdLLdSzDPtycV9yjLC.W2B1ls5XdcWBPnaxbcTx.YNOwFJy8qG','user','2025-08-05 02:36:22','avatar_1755746538.jpg',0.0,'{\"language\":\"es\",\"dark\":false,\"notifications\":{\"email\":true,\"sms\":true}}','','','',1,'2026-05-28 11:30:55','pending',NULL,NULL,NULL,NULL,0,0,0,NULL,NULL,'cc9762ca6f6ade9d39e246b4e14043b7475860dfef8862cbb932dcd0f1d8891a','2026-04-28 14:13:17',0,NULL,NULL,0,0),
(4,'Jesús diaz',NULL,'divina@gmail.com','04120761887',NULL,'$2y$12$crK52/FINTXytwHaK/hZduSShsh3y53nxosv3KRPAXXyCUr4Ny71G','user','2025-08-05 02:36:49',NULL,0.0,NULL,NULL,NULL,NULL,1,NULL,'pending',NULL,NULL,NULL,NULL,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,0,0),
(6,'María Villegas',NULL,'maria@gmail.com','04120761889','Dirección 1','$2y$12$ZgEhIEHYgLS/kK/lXYGbbe4uekhkYODGMIMTFVTYCPcxDxq7NWRzK','provider','2025-08-05 14:59:16','avatar_1755532362.jpg',4.0,'{\"language\":\"es\",\"dark\":true,\"notifications\":{\"email\":true,\"sms\":true}}','Dirección 2','Acompañamiento','Cuidad central .',1,'2026-05-28 02:01:22','pending',NULL,NULL,NULL,NULL,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,0,0),
(8,'Pedro Perez',NULL,'pedro@gmail.com','04125048499',NULL,'$2y$12$pf1whO0Jjw3x0mDBvTX.FOfKZ5tZ1rmF6EKftPJDKxDgX29fFzG2a','provider','2025-08-26 03:42:27',NULL,0.0,NULL,NULL,NULL,NULL,1,NULL,'pending',NULL,NULL,NULL,NULL,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,0,0),
(9,'Viviana Alvarado ',NULL,'vivianaalvarado233@gmail.com','04160761886',NULL,'$2y$12$YzDhzEGEjKz8eju2FBwyueOJvXJV.UbsBJiBGvsctWZEPcmY6p5ry','provider','2025-09-11 11:22:10',NULL,0.0,NULL,NULL,NULL,NULL,1,NULL,'pending',NULL,NULL,NULL,NULL,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,0,0),
(10,'Angie Gutiérrez',NULL,'angie@gmail.com','04120761881',NULL,'$2y$12$uQx7VCmTA/QmZC.WyKkv7uT.omsCct0CXQgOoSiS5iIswF9DuGCUe','provider','2026-05-22 01:48:50',NULL,0.0,NULL,NULL,NULL,NULL,1,'2026-05-24 19:30:11','pending',NULL,NULL,NULL,NULL,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,0,0);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `wallet_transactions`
--

DROP TABLE IF EXISTS `wallet_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wallet_transactions`
--

LOCK TABLES `wallet_transactions` WRITE;
/*!40000 ALTER TABLE `wallet_transactions` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `wallet_transactions` VALUES
(1,1,'credit',20.00,'Recarga de saldo','RECH-20260212-698D1B761CF28',NULL,NULL,NULL,NULL,'completed','2026-02-12 00:14:46'),
(2,1,'credit',20.00,'Solicitud de recarga #RECH-20260212-89373','3654788554667',NULL,'paypal',1,'2026-02-12 21:50:50','completed','2026-02-12 21:09:43'),
(3,1,'credit',20.00,'Solicitud de recarga #RECH-20260214-50041','3736362636','http://192.168.31.53:8000/uploads/payments/2026/02/dce81ef6894668df.jpg','transferencia',1,'2026-02-14 12:08:48','completed','2026-02-14 11:57:50'),
(4,2,'credit',20.00,'Solicitud de recarga #RECH-20260215-50144','Ffkfjfj',NULL,'zelle',1,'2026-04-28 09:41:24','completed','2026-02-15 23:01:19');
/*!40000 ALTER TABLE `wallet_transactions` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `wallets`
--

DROP TABLE IF EXISTS `wallets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `wallets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `balance` decimal(10,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `wallets_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wallets`
--

LOCK TABLES `wallets` WRITE;
/*!40000 ALTER TABLE `wallets` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `wallets` VALUES
(1,4,0.00,'2026-02-11 11:19:40','2026-02-11 11:19:40'),
(2,8,0.00,'2026-02-11 11:19:40','2026-02-11 11:19:40'),
(3,9,0.00,'2026-02-11 11:19:40','2026-02-11 11:19:40'),
(4,6,0.00,'2026-02-11 11:19:40','2026-02-11 11:19:40'),
(5,2,20.00,'2026-02-11 11:19:40','2026-04-28 09:41:24'),
(6,1,60.00,'2026-02-11 11:19:40','2026-02-14 12:08:48'),
(8,10,0.00,'2026-05-22 17:46:28','2026-05-22 17:46:28');
/*!40000 ALTER TABLE `wallets` ENABLE KEYS */;
UNLOCK TABLES;
commit;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2026-05-28 14:34:58
