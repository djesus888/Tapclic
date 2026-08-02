<template>
  <router-view />
</template>

<script setup>
import { watch } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()

const titles = {
  // Páginas públicas
  '/login': 'Iniciar Sesión',
  '/register': 'Crear Cuenta',
  '/forgot-password': 'Recuperar Contraseña',
  '/reset-password': 'Cambiar Contraseña',
  '/staff/login': 'Staff - Iniciar Sesión',
  '/maintenance': 'En Mantenimiento',
  '/error-500': 'Error del Servidor',
  '/company': 'Nuestra Empresa',
  '/': 'Bienvenido',
  
  // Dashboard
  '/dashboard': 'Panel de Control',
  '/dashboard/user': 'Panel de Control',
  '/dashboard/admin': 'Panel de Administración',
  '/dashboard/provider': 'Panel de Proveedor',
  '/dashboard/delivery': 'Panel de Delivery',
  
  // Usuario
  '/profile': 'Mi Perfil',
  '/wallet': 'Mi Billetera',
  '/config': 'Configuración',
  '/orders': 'Mis Órdenes',
  '/orders/:id': 'Detalle de Orden',
  '/services': 'Servicios',
  '/services/new': 'Nuevo Servicio',
  '/myservices': 'Mis Servicios',
  '/chats': 'Conversaciones',
  '/chat/:id': 'Chat',
  '/routes': 'Mis Rutas',
  '/requests': 'Solicitudes',
  '/reviews': 'Reseñas',
  '/earnings': 'Mis Ganancias',
  '/payment': 'Métodos de Pago',
  '/service/:id': 'Servicio',
  '/service/:id/publish': 'Publicar Servicio',
  
  // Admin
  '/admin/users': 'Gestión de Usuarios',
  '/admin/services': 'Gestión de Servicios',
  '/admin/service-payments': 'Verificación de Pagos',
  '/admin/reports': 'Reportes',
  '/admin/system': 'Configuración del Sistema',
  '/admin/system-config': 'Configuración del Sistema',
  '/admin/content': 'Gestor de Contenido',
  '/admin/payments': 'Pasarelas de Pago',
  '/admin/security': 'Seguridad',
  '/admin/analytics': 'Analytics',
  '/admin/backups': 'Backups',
  '/admin/monetization': 'Monetización',
  '/admin/billing': 'Facturación',
  '/admin/update': 'Actualizar Sistema',
  '/admin/logs': 'Logs del Sistema',
  '/admin/adminwallet': 'Admin Wallet',
  '/admin/tickets': 'Tickets de Soporte',
  '/account-blocked': 'Cuenta Bloqueada',
  '/provider': 'Proveedores',
  '/provider/billing': 'Facturación Proveedor',
  '/provider/staff': 'Mi Staff',
  '/delivery/orders': 'Entregas',
}

watch(() => route.path, (path) => {
  let title = titles[path]
  
  if (!title) {
    if (path.startsWith('/chat/')) title = 'Chat'
    else if (path.startsWith('/page/')) title = 'Información'
    else if (path.startsWith('/services/')) title = 'Servicio'
    else if (path.startsWith('/orders/')) title = 'Detalle de Orden'
    else if (path.startsWith('/service/')) title = 'Servicio'
    else title = 'TapClic'
  }
  
  document.title = `${title} - TapClic`
}, { immediate: true })
</script>

<style>
#app {
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
</style>
