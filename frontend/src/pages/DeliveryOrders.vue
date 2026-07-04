<template>
  <div class="delivery-container">
    <!-- Header -->
    <div class="delivery-header">
      <div class="header-content">
        <h1><span class="header-icon">🛵</span> Mis Entregas</h1>
        <p>Gestiona tus pedidos asignados</p>
      </div>
    </div>

    <!-- Tabs -->
    <div class="tabs">
      <button
        :class="['tab', { active: activeTab === 'active' }]"
        @click="activeTab = 'active'">
        📋 Activos
        <span v-if="activeOrders.length" class="tab-count">{{ activeOrders.length }}</span>
      </button>
      <button
        :class="['tab', { active: activeTab === 'history' }]"
        @click="activeTab = 'history'; fetchHistory()">
        📜 Historial
        <span v-if="historyOrders.length" class="tab-count">{{ historyOrders.length }}</span>
      </button>
    </div>

    <!-- Tab Activos -->
    <div v-if="activeTab === 'active'">
      <div v-if="activeOrders.length === 0" class="empty">
        <div class="empty-icon">🎉</div>
        <h3>No tienes pedidos activos</h3>
        <p>Cuando te asignen un pedido, aparecerá aquí</p>
      </div>

      <div v-for="order in activeOrders" :key="order.id" class="order-card" :class="'status-' + order.status">
        <div class="order-header">
          <span class="order-id">#{{ order.id }}</span>
          <span class="status-badge" :class="order.status">{{ statusLabel(order.status) }}</span>
        </div>

        <div class="order-body">
          <h3>{{ order.service_title || 'Pedido sin título' }}</h3>

          <div class="info-row">
            <span class="info-icon">📍</span>
            <span>{{ order.service_location || order.location || 'Sin dirección' }}</span>
          </div>
          <div class="info-row">
            <span class="info-icon">👤</span>
            <span>{{ order.user_name || 'N/A' }}</span>
          </div>
          <div class="info-row">
            <span class="info-icon">📱</span>
            <a :href="'tel:' + order.user_phone" class="phone-link">{{ order.user_phone || 'N/A' }}</a>
          </div>
        </div>

        <!-- Timeline de progreso -->
        <div class="progress-timeline">
          <div class="progress-step" :class="{ done: isStepDone(order.status, 'accepted') }">✅</div>
          <div class="progress-line" :class="{ done: isStepDone(order.status, 'in_progress') }"></div>
          <div class="progress-step" :class="{ done: isStepDone(order.status, 'in_progress') }">🛵</div>
          <div class="progress-line" :class="{ done: isStepDone(order.status, 'on_the_way') }"></div>
          <div class="progress-step" :class="{ done: isStepDone(order.status, 'on_the_way') }">🚗</div>
          <div class="progress-line" :class="{ done: isStepDone(order.status, 'arrived') }"></div>
          <div class="progress-step" :class="{ done: isStepDone(order.status, 'arrived') }">📍</div>
          <div class="progress-line" :class="{ done: isStepDone(order.status, 'finalized') }"></div>
          <div class="progress-step" :class="{ done: isStepDone(order.status, 'finalized') }">🏁</div>
        </div>

        <div class="order-actions">
          <button
            v-if="order.status === 'accepted'"
            @click="updateStatus(order.id, 'in_progress')"
            class="btn-action primary">
            🛵 Iniciar entrega
          </button>
          <button
            v-if="order.status === 'in_progress'"
            @click="updateStatus(order.id, 'on_the_way')"
            class="btn-action warning">
            🚗 Voy en camino
          </button>
          <button
            v-if="order.status === 'on_the_way'"
            @click="updateStatus(order.id, 'arrived')"
            class="btn-action info">
            📍 He llegado
          </button>
          <button
            v-if="order.status === 'arrived'"
            @click="updateStatus(order.id, 'finalized')"
            class="btn-action success">
            ✅ Entregado
          </button>
          <a v-if="order.user_phone" :href="'tel:' + order.user_phone" class="btn-action call">
            📞 Llamar
          </a>
         <button v-if="order.user_id" @click="openChatWithUser(order.user_id, order.user_name)" class="btn-action chat">
          💬 Chat
         </button>
        </div>
      </div>
    </div>

    <!-- Tab Historial -->
    <div v-if="activeTab === 'history'">
      <div v-if="historyOrders.length === 0" class="empty">
        <div class="empty-icon">📭</div>
        <h3>Sin historial</h3>
        <p>Tus entregas completadas aparecerán aquí</p>
      </div>

      <div v-for="order in historyOrders" :key="'h-' + order.id" class="order-card history-card">
        <div class="order-header">
          <span class="order-id">#{{ order.id }}</span>
          <span class="status-badge" :class="order.status">{{ statusLabel(order.status) }}</span>
        </div>
        <div class="order-body">
          <h3>{{ order.service_title || 'Pedido sin título' }}</h3>
          <div class="info-row">
            <span class="info-icon">👤</span>
            <span>{{ order.user_name || 'N/A' }}</span>
          </div>
          <div class="info-row">
            <span class="info-icon">📅</span>
            <span>{{ formatDate(order.updated_at || order.finished_at) }}</span>
          </div>
          <div class="info-row">
            <span class="info-icon">💰</span>
            <span>${{ Number(order.price || 0).toFixed(2) }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import api from '@/axios'
import { useSocketStore } from '@/stores/socketStore'
import { useNotificationStore } from '@/stores/notificationStore'
import { useRouter } from 'vue-router'



const orders = ref([])
const historyOrders = ref([])
const activeTab = ref('active')
const token = localStorage.getItem('staff_token') || ''
const socketStore = useSocketStore()
const notificationStore = useNotificationStore()
const router = useRouter()



// Handlers para WebSocket
let requestUpdatedHandler = null
let newNotificationHandler = null

const activeOrders = computed(() =>
  orders.value.filter(o => !['completed', 'cancelled', 'finalized'].includes(o.status))
)

const statusLabel = (status) => {
  const labels = {
    'accepted': 'Aceptado',
    'in_progress': 'En proceso',
    'on_the_way': 'En camino',
    'arrived': 'En destino',
    'finalized': 'Finalizado',
    'completed': 'Completado',
    'cancelled': 'Cancelado'
  }
  return labels[status] || status
}

const isStepDone = (currentStatus, step) => {
  const order = ['accepted', 'in_progress', 'on_the_way', 'arrived', 'finalized', 'completed']
  return order.indexOf(currentStatus) >= order.indexOf(step)
}

const formatDate = (d) => {
  if (!d) return 'N/A'
  return new Date(d).toLocaleDateString('es', { year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' })
}

const fetchOrders = async () => {
  try {
    const { data } = await api.get('/delivery/orders', {
      headers: { Authorization: `Bearer ${token}` }
    })
    orders.value = data.orders || []
  } catch (err) {
    console.error('Error cargando pedidos:', err)
  }
}

const fetchHistory = async () => {
  if (historyOrders.value.length > 0) return
  try {
    const { data } = await api.get('/delivery/history', {
      headers: { Authorization: `Bearer ${token}` }
    })
    historyOrders.value = data.orders || []
  } catch (err) {
    console.error('Error cargando historial:', err)
  }
}

const updateStatus = async (requestId, status) => {
  try {
    await api.post('/delivery/update-status', { request_id: requestId, status }, {
      headers: { Authorization: `Bearer ${token}` }
    })
    await fetchOrders()
  } catch (err) {
    console.error('Error actualizando estado:', err)
  }
}

// ============ WEBSOCKET TIEMPO REAL ============
const setupSocketListeners = () => {
  // Inicializar socket si no está conectado
  if (!socketStore.isConnected) {
    socketStore.init().then(() => {
      socketStore.connect(token)
    })
  }

  // Escuchar cambios de estado de pedidos
  requestUpdatedHandler = (payload) => {
    const requestId = payload?.request_id || payload?.id
    const newStatus = payload?.status
    if (!requestId) return

    // Actualizar pedido en la lista si existe
    const index = orders.value.findIndex(o => o.id == requestId)
    if (index !== -1) {
      if (['completed', 'cancelled', 'finalized'].includes(newStatus)) {
        // Movido a historial - quitarlo de activos
        const completed = orders.value[index]
        orders.value.splice(index, 1)
        // Agregar al historial
        historyOrders.value.unshift({ ...completed, status: newStatus })
      } else {
        // Actualizar estado
        orders.value[index] = { ...orders.value[index], status: newStatus }
      }
    } else if (newStatus && !['completed', 'cancelled', 'finalized'].includes(newStatus)) {
      // Nuevo pedido asignado - recargar
      fetchOrders()
    }
  }

  // Escuchar nuevas notificaciones (nuevo pedido asignado)
  newNotificationHandler = (notification) => {
    if (notification?.notification_type === 'delivery_assigned' || 
        notification?.action === 'view_delivery') {
      // Recargar pedidos cuando llega nueva asignación
      fetchOrders()
      // También recargar notificaciones
      notificationStore.loadNotificationsFromAPI?.()
    }
  }

  socketStore.on('request_updated', requestUpdatedHandler)
  socketStore.on('new-notification', newNotificationHandler)
}

const removeSocketListeners = () => {
  if (requestUpdatedHandler) socketStore.off('request_updated', requestUpdatedHandler)
  if (newNotificationHandler) socketStore.off('new-notification', newNotificationHandler)
}

const openChatWithUser = async (userId, userName) => {
  try {
    const res = await api.post('/conversations/create', {
      participant_id: userId,
      participant_role: 'user'
    }, {
      headers: { Authorization: `Bearer ${token}` }
    })
    if (res.data?.id) {
      router.push(`/chat/${res.data.id}`)
    } else if (res.data?.conversation_id) {
      router.push(`/chat/${res.data.conversation_id}`)
    }
  } catch (err) {
    console.error('Error abriendo chat:', err)
  }
}

onMounted(() => {
  fetchOrders()
  setupSocketListeners()
})

onBeforeUnmount(() => {
  removeSocketListeners()
})
</script>

<style scoped>
.delivery-container { max-width: 700px; margin: 0 auto; padding: 16px; }
.delivery-header { background: linear-gradient(135deg, #10B981 0%, #059669 100%); border-radius: 16px; padding: 24px; margin-bottom: 20px; color: white; box-shadow: 0 4px 15px rgba(16, 185, 129, 0.3); }
.header-content h1 { font-size: 1.8rem; margin: 0 0 4px; display: flex; align-items: center; gap: 10px; }
.header-content p { opacity: 0.9; margin: 0; font-size: 0.95rem; }
.header-icon { font-size: 2rem; }
.tabs { display: flex; gap: 8px; margin-bottom: 16px; background: white; border-radius: 12px; padding: 6px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); }
.tab { flex: 1; padding: 12px; border: none; border-radius: 10px; cursor: pointer; font-weight: 600; font-size: 0.9rem; background: transparent; color: #666; transition: all 0.2s; display: flex; align-items: center; justify-content: center; gap: 6px; }
.tab.active { background: #10B981; color: white; box-shadow: 0 2px 8px rgba(16, 185, 129, 0.3); }
.tab-count { background: rgba(255,255,255,0.3); padding: 2px 8px; border-radius: 10px; font-size: 0.8rem; }
.tab.active .tab-count { background: rgba(255,255,255,0.3); }
.empty { text-align: center; padding: 50px 20px; background: white; border-radius: 16px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); }
.empty-icon { font-size: 3rem; margin-bottom: 10px; }
.empty h3 { color: #333; margin: 0 0 5px; }
.empty p { color: #999; margin: 0; }
.order-card { background: white; border-radius: 16px; padding: 20px; margin-bottom: 16px; box-shadow: 0 2px 12px rgba(0,0,0,0.06); border-left: 4px solid #e5e7eb; transition: all 0.3s; }
.order-card:hover { box-shadow: 0 4px 20px rgba(0,0,0,0.1); transform: translateY(-2px); }
.status-accepted { border-left-color: #3b82f6; }
.status-in_progress { border-left-color: #f59e0b; }
.status-on_the_way { border-left-color: #f59e0b; }
.status-arrived { border-left-color: #8b5cf6; }
.status-finalized { border-left-color: #10B981; }
.status-completed { border-left-color: #10B981; }
.status-cancelled { border-left-color: #ef4444; }
.order-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; }
.order-id { font-weight: 700; color: #333; font-size: 0.9rem; }
.status-badge { padding: 4px 12px; border-radius: 20px; font-size: 0.8rem; font-weight: 600; background: #f0f0f0; color: #666; }
.status-badge.accepted { background: #dbeafe; color: #1d4ed8; }
.status-badge.in_progress { background: #fef3c7; color: #92400e; }
.status-badge.on_the_way { background: #fef3c7; color: #92400e; }
.status-badge.arrived { background: #ede9fe; color: #5b21b6; }
.status-badge.finalized { background: #d1fae5; color: #065f46; }
.status-badge.completed { background: #d1fae5; color: #065f46; }
.status-badge.cancelled { background: #fee2e2; color: #991b1b; }
.order-body h3 { margin: 0 0 12px; font-size: 1.1rem; color: #1f2937; }
.info-row { display: flex; align-items: center; gap: 8px; margin-bottom: 6px; color: #6b7280; font-size: 0.9rem; }
.info-icon { width: 20px; text-align: center; }
.phone-link { color: #10B981; text-decoration: none; font-weight: 500; }
.phone-link:hover { text-decoration: underline; }
.progress-timeline { display: flex; align-items: center; justify-content: center; gap: 0; margin: 16px 0; padding: 8px 0; }
.progress-step { width: 32px; height: 32px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 0.8rem; background: #e5e7eb; transition: all 0.3s; }
.progress-step.done { background: #10B981; color: white; }
.progress-line { width: 30px; height: 3px; background: #e5e7eb; transition: all 0.3s; }
.progress-line.done { background: #10B981; }
.order-actions { display: flex; gap: 8px; flex-wrap: wrap; margin-top: 4px; }
.btn-action { padding: 10px 18px; border: none; border-radius: 10px; cursor: pointer; font-weight: 600; font-size: 0.85rem; text-decoration: none; transition: all 0.2s; display: inline-flex; align-items: center; gap: 6px; }
.btn-action:hover { opacity: 0.9; transform: translateY(-1px); }
.btn-action.primary { background: #3b82f6; color: white; }
.btn-action.warning { background: #f59e0b; color: white; }
.btn-action.info { background: #8b5cf6; color: white; }
.btn-action.success { background: #10B981; color: white; }
.btn-action.call { background: #f0fdf4; color: #10B981; border: 1px solid #10B981; }
.btn-action.chat { background: #6366f1; color: white; }
.history-card { opacity: 0.85; border-left-color: #d1d5db; }
.history-card:hover { opacity: 1; }
@media (max-width: 480px) {
  .delivery-container { padding: 10px; }
  .delivery-header { padding: 18px; }
  .header-content h1 { font-size: 1.4rem; }
  .progress-line { width: 20px; }
  .progress-step { width: 28px; height: 28px; font-size: 0.7rem; }
  .btn-action { padding: 8px 14px; font-size: 0.8rem; }
}
</style>
