import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/authStore'

import MainLayout from '@/layouts/MainLayout.vue'
import Login from '@/pages/Login.vue'
import Register from '@/pages/Register.vue'
import Dashboard from '@/pages/Dashboard.vue'
import Profile from '@/pages/Profile.vue'
import Wallet from '@/pages/Wallet.vue'
import Config from '@/pages/config.vue'
import Orders from '@/pages/orders.vue'
import New from '@/pages/services/New.vue'
import Services from '@/pages/services/Services.vue'
import ChatList from '@/pages/ChatList.vue'
import ChatView from '@/pages/ChatView.vue'
import PaymentMethod from '@/pages/PaymentMethod.vue'
import AdminUser from '@/pages/AdminUser.vue'
import AdminServices from '@/pages/AdminServices.vue'
import AdminReports from '@/pages/AdminReports.vue'

import DashboardUser from '@/components/DashboardUser.vue'
import DashboardAdmin from '@/components/DashboardAdmin.vue'
import DashboardProvider from '@/components/DashboardProvider.vue'

const routes = [
  { path: '/', redirect: '/dashboard' },
  { path: '/login', component: Login },
  { path: '/register', component: Register },
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
      { path: 'payment', component: PaymentMethod },
      { path: 'admin/users', component: AdminUser }, 
      { path: 'admin/services', component: AdminServices },
      { path: 'admin/reports', component: AdminReports },

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

router.beforeEach((to, from, next) => {
  const auth = useAuthStore()
  const role = auth.user?.role

  // Redirige a dashboard según rol si ya está logueado
  if ((to.path === '/login' || to.path === '/register') && role) {
    return next(`/dashboard/${role}`)
  }

  // Requiere auth
  if (to.meta.requiresAuth && !auth.token) {
    return next('/login')
  }

  // Protección por rol
  if (to.meta.role && role !== to.meta.role) {
    return next(role ? `/dashboard/${role}` : '/login')
  }

  next()
})

export default router
