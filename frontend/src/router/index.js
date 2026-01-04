import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/authStore'
import MainLayout from '@/layouts/MainLayout.vue'

const routes = [
  { path: '/login',   component: () => import('@/pages/Login.vue') },
  { path: '/register',component: () => import('@/pages/Register.vue') },

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
      { path: 'services/new', component: () => import('@/pages/services/NewServices.vue') },
      { path: 'chats', component: () => import('@/pages/ChatList.vue') },
      { path: 'chat/:id', component: () => import('@/pages/ChatView.vue') },
      { path: 'services', component: () => import('@/pages/services/Services.vue') },
      { path: 'myservices', component: () => import('@/pages/services/MyServices.vue') },     
      { path: 'payment', component: () => import('@/pages/PaymentMethod.vue') },
      { path: 'admin/users', component: () => import('@/pages/AdminUser.vue') },
      { path: 'admin/services', component: () => import('@/pages/AdminServices.vue') },
      { path: 'admin/reports', component: () => import('@/pages/AdminReports.vue') },
      { path: 'reviews', component: () => import('@/pages/Reviews.vue') },
      { path: 'requests', component: () => import('@/pages/Requests.vue') },
      { path: 'service/:id', component: () => import('@/pages/ServiceDetailPage.vue') },

      /* Dashboards por rol */
      { path: 'dashboard/user',     component: () => import('@/components/DashboardUser.vue'),    meta: { role: 'user' } },
      { path: 'dashboard/admin',    component: () => import('@/components/DashboardAdmin.vue'),   meta: { role: 'admin' } },
      { path: 'dashboard/provider', component: () => import('@/components/DashboardProvider.vue'), meta: { role: 'provider' } },
    ],
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

router.beforeEach((to, from, next) => {
  const auth = useAuthStore()
  const role = auth.user?.role

  /* Si ya está logueado y va a login/register, redirige a su dashboard */
  if ((to.path === '/login' || to.path === '/register') && role) {
    return next(`/dashboard/${role}`)
  }

  /* Ruta protegida y sin token → login */
  if (to.meta.requiresAuth && !auth.token) {
    return next('/login')
  }

  /* Ruta con rol requerido y no coincide → dashboard de su rol */
  if (to.meta.role && role !== to.meta.role) {
    return next(role ? `/dashboard/${role}` : '/login')
  }

  next()
})

export default router
