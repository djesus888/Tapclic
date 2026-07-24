import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/authStore'
import MainLayout from '@/layouts/MainLayout.vue'

const routes = [
  { path: '/page/:slug', component: () => import('@/pages/StaticPage.vue') },
  { path: '/login',   component: () => import('@/pages/Login.vue') },
  { path: '/register',component: () => import('@/pages/Register.vue') },
  { path: '/forgot-password', component: () => import('@/pages/ForgotPassword.vue') },
  { path: '/reset-password',  component: () => import('@/pages/ResetPassword.vue') },
  { path: '/staff/login', component: () => import('@/pages/StaffLogin.vue') },

  
/* Ruta real para /dashboard que evita el doble redirect */
  {
    path: '/dashboard',
    redirect: () => {
      const auth = useAuthStore()
      const role = auth.user?.role
      return role ? `/dashboard/${role}` : '/login'
    }
  },

  /* Redirige la raíz al dashboard sin bucles */
  { path: '/', redirect: '/dashboard' },

  /* Layout protegido */
  {
    path: '/',
    component: MainLayout,
    meta: { requiresAuth: true },
    children: [
      { path: 'dashboard', component: () => import('@/pages/Dashboard.vue') },
      { path: 'profile', component: () => import('@/pages/Profile.vue') },
      { path: 'wallet', component: () => import('@/pages/Wallet.vue') },
      { path: 'config', component: () => import('@/pages/Config.vue') },
      { path: 'orders', component: () => import('@/pages/Orders.vue') },
      { path: 'orders/:id', component: () => import('@/pages/OrderDetail.vue') },  // ← NUEVA
      { path: 'services/new', component: () => import('@/pages/services/NewServices.vue') },
      { path: 'chats', component: () => import('@/pages/ChatList.vue') },
      { path: 'chat/:id', component: () => import('@/pages/ChatView.vue') },
      { path: 'services', component: () => import('@/pages/services/Services.vue') },
      { path: 'routes', component: () =>  import('@/pages/Routes.vue') },
      { path: 'myservices', component: () => import('@/pages/services/MyServices.vue') },     
      { path: 'payment', component: () => import('@/pages/PaymentMethod.vue'), meta: { role: 'provider' } },
      { path: 'admin/users', component: () => import('@/pages/AdminUser.vue') },
      { path: 'provider', component: () => import('@/pages/AdminProviders.vue'), meta: { role: 'admin' } },
      { path: 'service/:id/publish', component: () => import('@/pages/services/ServicePublish.vue'), meta: { role: 'provider' } },
      { path: 'admin/services', component: () => import('@/pages/AdminServices.vue') },
      { path: 'admin/service-payments', component: () => import('@/pages/AdminServicePayments.vue'), meta: { role: 'admin' } },
      { path: 'admin/reports', component: () => import('@/pages/AdminReports.vue'), meta: { role: 'admin' } },
      { path: 'admin/system', component: () => import('@/pages/admin/SystemSettings.vue'),  meta: { role: 'admin' }},
      { path: 'admin/content', component: () => import('@/pages/admin/ContentManager.vue'),  meta: { role: 'admin' }},
      { path: 'admin/payments', component: () => import('@/pages/admin/PaymentGateways.vue'),  meta: { role: 'admin' }},
      { path: 'admin/security', component: () => import('@/pages/admin/SecuritySettings.vue'),meta: { role: 'admin' }},
      { path: 'admin/analytics', component: () => import('@/pages/admin/Analytics.vue'),meta: { role: 'admin' }},
      { path: 'admin/backups', component: () => import('@/pages/AdminBackups.vue'), meta: { role: 'admin' } },
      { path: 'admin/monetization', component: () => import('@/pages/admin/Monetization.vue'), meta: { role: 'admin' } },
      { path: 'admin/billing', component: () => import('@/pages/AdminBilling.vue'), meta: { role: 'admin' } },
      { path: 'admin/update', component: () => import('@/pages/AdminUpdate.vue'), meta: { role: 'admin' } },
      { path: 'admin/logs', component: () => import('@/pages/AdminLogs.vue'), meta: { role: 'admin' } },
      { path: 'admin/adminwallet', component: () => import('@/pages/AdminWallet.vue'), meta: { requiresAuth: true, role: 'admin', permission: 'manage_wallet' }},
      { path: 'admin/system-config', component: () => import('@/pages/admin/SystemConfig.vue'), meta: { role: 'admin' } },
      { path: 'earnings', component: () => import('@/pages/Earnings.vue') },
      { path: 'provider/billing', component: () => import('@/pages/ProviderBilling.vue'), meta: { role: 'provider' } },
      { path: 'reviews', component: () => import('@/pages/Reviews.vue') },
      { path: 'requests', component: () => import('@/pages/Requests.vue') },
      { path: 'service/:id', component: () => import('@/pages/ServiceDetailPage.vue') },
      { path: 'admin/tickets', component: () => import('@/pages/AdminTickets.vue') },
      { path: 'provider/staff', component: () => import('@/pages/ProviderStaff.vue'), meta: { role: 'provider' } },
      { path: 'delivery/orders', component: () => import('@/pages/DeliveryOrders.vue') },
      { path: 'company', component: () => import('@/pages/CompanyView.vue') },


      /* Dashboards por rol */
      { path: 'dashboard/user',     component: () => import('@/components/DashboardUser.vue'),    meta: { role: 'user' } },
      { path: 'dashboard/admin',    component: () => import('@/components/DashboardAdmin.vue'),   meta: { role: 'admin' } },
      { path: 'dashboard/provider', component: () => import('@/components/DashboardProvider.vue'), meta: { role: 'provider' } },
//      { path: 'dashboard/delivery', component: () => import('@/components/DashboardDelivery.vue') },

       // Ruta 404 -  Dentro del layout protegido
       { path: '/:pathMatch(.*)*', component: () => import('@/pages/NotFound.vue') },
    ],
  },
// Ruta 404 -  para  rutas no protegidas
{ path: '/:pathMatch(.*)*', component: () => import('@/pages/NotFound.vue') },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

router.beforeEach((to, from, next) => {
  const staffToken = localStorage.getItem('staff_token')
  const isStaff = !!staffToken

  if (isStaff) {
    if (to.path === '/staff/login') return next('/delivery/orders')
    
    // ✅ Permitir acceso a delivery, chats, profile, config y routes
    if (to.path.startsWith('/delivery') || 
        to.path === '/chats' ||
        to.path === '/chat' ||
        to.path.startsWith('/chat/') ||
        to.path === '/profile' ||
        to.path === '/config' ||
        to.path === '/routes') {
      return next()
    }
    
    return next('/delivery/orders')
}

  // USUARIO NORMAL
  const auth = useAuthStore()
  const role = auth.user?.role

  if ((to.path === '/login' || to.path === '/register') && role) {
    return next(`/dashboard/${role}`)
  }
  if (to.meta.requiresAuth && !auth.token) {
    return next('/login')
  }
  if (to.meta.role && role !== to.meta.role) {
    return next(role ? `/dashboard/${role}` : '/login')
  }

  next()
})

export default router
