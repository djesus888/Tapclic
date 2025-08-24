<template>
  <component :is="dashboardComponent" />
</template>

<script>
import { useAuthStore } from '@/stores/authStore'
import DashboardUser from '@/components/DashboardUser.vue'
import DashboardAdmin from '@/components/DashboardAdmin.vue'
import DashboardProvider from '@/components/DashboardProvider.vue'

export default {
  components: { DashboardUser, DashboardAdmin, DashboardProvider },
  computed: {
    dashboardComponent() {
      const role = useAuthStore().user?.role
      if (role === 'admin') return 'DashboardAdmin'
      if (role === 'provider') return 'DashboardProvider'
      return 'DashboardUser'
    }
  }
}
</script>
