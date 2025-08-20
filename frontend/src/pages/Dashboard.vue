<template>
  <component :is="dashboardComponent" />
</template>

<script>
import { useAuthStore } from '@/stores/authStore'
import DashboardUser from '@/components/DashboardUser.vue'
import DashboardAdmin from '@/components/DashboardAdmin.vue'
import DashboardDriver from '@/components/DashboardDriver.vue'

export default {
  components: { DashboardUser, DashboardAdmin, DashboardDriver },
  computed: {
    dashboardComponent() {
      const role = useAuthStore().user?.role
      if (role === 'admin') return 'DashboardAdmin'
      if (role === 'driver') return 'DashboardDriver'
      return 'DashboardUser'
    }
  }
}
</script>
