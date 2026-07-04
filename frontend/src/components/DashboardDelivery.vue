<template>
  <div class="delivery-dashboard">
    <div class="dashboard-header">
      <h1>🛵 Panel de Entregas</h1>
      <p>Bienvenido, {{ staff?.name || 'Repartidor' }}</p>
      <button class="btn-logout" @click="logout">🚪 Cerrar sesión</button>
    </div>

    <DeliveryOrders />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import api from '@/axios'
import DeliveryOrders from '@/pages/DeliveryOrders.vue'

const router = useRouter()
const staff = ref(null)

onMounted(() => {
  const stored = localStorage.getItem('staff')
  if (stored) staff.value = JSON.parse(stored)
})

const logout = () => {
  localStorage.removeItem('staff_token')
  localStorage.removeItem('staff')
  window.location.href = '/staff/login'
}
</script>

<style scoped>
.delivery-dashboard { padding: 20px; }
.dashboard-header {
  display: flex; justify-content: space-between; align-items: center;
  background: linear-gradient(135deg, #ff9800, #f57c00);
  color: white; padding: 20px; border-radius: 12px; margin-bottom: 20px;
}
.btn-logout {
  background: rgba(255,255,255,0.2); color: white; border: none;
  padding: 10px 20px; border-radius: 8px; cursor: pointer; font-weight: 600;
}
</style>
