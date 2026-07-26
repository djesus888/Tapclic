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
-- Dumping data for table `system_config`
--

LOCK TABLES `system_config` WRITE;
/*!40000 ALTER TABLE `system_config` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `system_config` VALUES
(1,'TapClic','https://tapclic.com','https://ws.tapclic.com',1,'1.0.0','/assets/logo.png','/assets/favicon.ico','es','America/Caracas','USD','soporte@tapclic.com','+58 123 456 7890','smtp.gmail.com',587,'tls',NULL,NULL,'notificaciones@tapclic.com','TapClic',NULL,NULL,NULL,'TapClic C.A.','info@tapclic.com','+58 4120761886','Yaracuy, Venezuela',0,5,90,30,20,'#409EFF',1,0,1,1,1,1,NULL,'2025-08-17 21:44:41','2026-07-25 05:33:46',2.00,0.00,NULL,5.00,30,'both','Misión papa','Visión papa ','5+','2026',150);
/*!40000 ALTER TABLE `system_config` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `company_milestones`
--

LOCK TABLES `company_milestones` WRITE;
/*!40000 ALTER TABLE `company_milestones` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `company_milestones` VALUES
(1,'2026','Fundación de la empresa','Nacimos con la visión de revolucionar la conexión entre profesionales y clientes.','🚀',1,1,'2026-07-23 10:26:35','2026-07-23 10:26:35'),
(2,'2026','Primeros 100 clientes','Alcanzamos nuestros primeros 100 clientes satisfechos en tiempo récord.','👥',2,1,'2026-07-23 10:26:35','2026-07-23 10:26:35'),
(3,'2026','Expansión de servicios','Ampliamos nuestra oferta a más de 20 categorías de servicios profesionales.','📦',3,1,'2026-07-23 10:26:35','2026-07-23 10:26:35'),
(4,'2026','Innovación continua','Seguimos mejorando nuestra plataforma con tecnología de punta.','💡',4,1,'2026-07-23 10:26:35','2026-07-23 10:26:35');
/*!40000 ALTER TABLE `company_milestones` ENABLE KEYS */;
UNLOCK TABLES;
commit;

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
-- Dumping data for table `provider_payment_methods`
--

LOCK TABLES `provider_payment_methods` WRITE;
/*!40000 ALTER TABLE `provider_payment_methods` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `provider_payment_methods` VALUES
(2,6,'transferencia','Bicentenario ','Jesús Diaz ','18673920','','01029876542345764567','','',1,'2025-09-07 14:45:18','2026-05-28 22:17:12'),
(3,6,'paypal','','Jesús Diaz ','18673920','','','divijeal@gmail.com','',1,'2025-09-07 14:59:01','2026-05-28 22:17:11'),
(4,6,'zelle',NULL,'18673920','18673920',NULL,NULL,'divijeal@gmail.com',NULL,1,'2025-09-07 14:59:31','2026-05-28 22:17:14'),
(6,6,'pago_movil','Bicentenario ','Jesús Diaz ','18673920','04120761886','','','',1,'2026-05-28 21:31:48','2026-05-28 22:17:08'),
(7,10,'pago_movil','Venezuela ','Jesús Diaz ','18673920','04120761886','','','',1,'2026-06-09 00:42:29','2026-06-09 00:42:29');
/*!40000 ALTER TABLE `provider_payment_methods` ENABLE KEYS */;
UNLOCK TABLES;
commit;

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
-- Dumping data for table `content_blocks`
--

LOCK TABLES `content_blocks` WRITE;
/*!40000 ALTER TABLE `content_blocks` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `content_blocks` VALUES
(1,'Banner Principal','home_banner','banner','{\"title\": \"Encuentra el servicio que necesitas\", \"subtitle\": \"Profesionales confiables a tu alcance\", \"button_text\": \"Explorar Servicios\", \"button_link\": \"/services\"}','{\"background\": \"#667eea\", \"text_color\": \"#ffffff\"}',1,'2026-02-01 01:35:00','2026-02-01 01:35:00'),
(2,'Texto de Bienvenida','welcome_text','text','<h2>Bienvenido a TapClic</h2><p>La plataforma que conecta a usuarios con profesionales confiables.</p>','\"{\\\"alignment\\\": \\\"center\\\"}\"',1,'2026-02-01 01:35:00','2026-02-03 23:40:52'),
(3,'Footer Info','footer_info','text','<p>© 2024 TapClic. Todos los derechos reservados.</p>','{}',1,'2026-02-01 01:35:00','2026-02-01 01:35:00');
/*!40000 ALTER TABLE `content_blocks` ENABLE KEYS */;
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
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2026-07-26  6:09:31
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
-- WHERE:  id=1

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `users` VALUES
(1,'Jesús Diaz',NULL,'divijeal@gmail.com','04120761886','','$2y$12$WqOP3xcaqC/4CMNJXhTohOZVS/KRr2Q8Fi8NgUYE8eEXA6qpqUg76','admin','2025-08-06 02:27:23','avatar_1755006875.jpg',0.0,'','','','',1,'2026-07-23 18:58:32','pending',NULL,NULL,NULL,NULL,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,0,0,NULL,'founder',NULL,NULL,1);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
commit;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2026-07-26  6:09:31
