import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/authStore'

// Layout principal5
import MainLayout from '@/layouts/MainLayout.vue'

// Páginas públicas
import Login from '@/pages/Login.vue'
import Register from '@/pages/Register.vue'

// Páginas protegidas
import Dashboard from '@/pages/Dashboard.vue'
import Profile from '@/pages/Profile.vue'
import Wallet from '@/pages/Wallet.vue'
import Config from '@/pages/config.vue'
import Orders from '@/pages/orders.vue'
import New from '@/pages/services/New.vue'
import Services from '@/pages/services/Services.vue'
import ChatList from '@/pages/ChatList.vue'
import ChatView from '@/pages/ChatView.vue'


// Dashboards por rol
import DashboardUser from '@/components/DashboardUser.vue'
import DashboardAdmin from '@/components/DashboardAdmin.vue'
import DashboardProvider from '@/components/DashboardProvider.vue'

const routes = [
  { path: '/', redirect: '/dashboard' },

  // Rutas públicas sin layout
  { path: '/login', component: Login },
  { path: '/register', component: Register },

  // Rutas protegidas bajo MainLayout
  {
    path: '/',
    component: MainLayout,
    meta: { requiresAuth: true },
    children: [
      { path: 'dashboard', component: Dashboard },
      { path: 'profile', component: Profile },
      { path: 'wallet', component: Wallet },
      { path: 'config', component: Config },
      { path: 'orders', component: Orders },
      { path: 'services/new', component: New },      
      { path: 'chats', component: ChatList },
      { path: 'chat/:id', component: ChatView },
      { path: 'services', component: Services },


// Dashboards específicos por rol
      { path: 'dashboard/user', component: DashboardUser, meta: { role: 'user' } },
      { path: 'dashboard/admin', component: DashboardAdmin, meta: { role: 'admin' } },
      { path: 'dashboard/provider', component: DashboardProvider, meta: { role: 'provider' } },
   
 ]
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

// Middleware de autenticación y protección por rol
router.beforeEach((to, from, next) => {
  const auth = useAuthStore()

  // Si ya está autenticado y va a login/register, redirigir al dashboard
  if ((to.path === '/login' || to.path === '/register') && auth.token) {
    return next(`/dashboard/${auth.user?.role || ''}`)
  }

  // Si requiere autenticación y no tiene token, ir al login
  if (to.meta.requiresAuth && !auth.token) {
    return next('/login')
  }

  // Verificación de rol si está especificado
  if (to.meta.role && auth.user?.role !== to.meta.role) {
    return next(`/dashboard/${auth.user?.role || ''}`)
  }

  next()
})
export default router
