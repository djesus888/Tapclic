<template>
  <component :is="dashboardComponent" />
</template>

<script>
import { useAuthStore } from '@/stores/authStore'
import DashboardUser from '@/components/DashboardUser.vue'
import DashboardAdmin from '@/components/DashboardAdmin.vue'
import DashboardProvider from '@/components/DashboardProvider.vue'
import DashboardDelivery from '@/components/DashboardDelivery.vue'

export default {
  components: { DashboardUser, DashboardAdmin, DashboardProvider, DashboardDelivery },
  computed: {
    dashboardComponent() {
      // Detectar si es staff
      const staffToken = localStorage.getItem('staff_token')
      if (staffToken) return 'DashboardDelivery'
      
      const role = useAuthStore().user?.role
      if (role === 'admin') return 'DashboardAdmin'
      if (role === 'provider') return 'DashboardProvider'
      return 'DashboardUser'
    }
  }
}
</script>
