<template>
  <div class="max-w-5xl mx-auto p-6 bg-white rounded-xl shadow-md mt-8">

    <!-- Tabs -->
    <div class="flex space-x-4 border-b mb-6">
      <button
        class="pb-2 px-4"
        :class="selectedTab === 'active' ? 'border-b-2 border-blue-600 text-blue-600 font-semibold' : 'text-gray-600'"
        @click="selectedTab = 'active'"
      >
        {{ $t('active') }}
      </button>
      <button
        class="pb-2 px-4"
        :class="selectedTab === 'history' ? 'border-b-2 border-blue-600 text-blue-600 font-semibold' : 'text-gray-600'"
        @click="selectedTab = 'history'"
      >
        {{ $t('history') }}
      </button>
    </div>

    <!-- Pedidos activos -->
    <div v-if="selectedTab === 'active'" class="space-y-4">
      <div v-if="activeOrders.length > 0">
        <div
          v-for="order in activeOrders"
          :key="order.id"
          class="p-4 border rounded-md shadow-sm flex flex-col sm:flex-row justify-between items-start sm:items-center"
        >
          <div>
            <p class="font-semibold">{{ order.service_name }}</p>
            <p class="text-sm text-gray-500">{{ order.provider_name }}</p>
            <!-- ✅ STATUS VISIBLE Y ACTUALIZADO -->
            <p :class="statusColor(order.status)" class="text-xs font-medium mt-1">
              {{ statusLabel(order.status) }}
            </p>
          </div>
          <div class="flex space-x-2 mt-2 sm:mt-0">
            <button
              class="bg-green-600 text-white px-3 py-1 rounded hover:bg-green-700"
              @click="markAsCompleted(order.id)"
            >
              {{ $t('orders.complete') }}
            </button>
            <button
              class="bg-blue-600 text-white px-3 py-1 rounded hover:bg-blue-700"
              @click="startChat(order.provider_name)"
            >
              {{ $t('orders.chat') }}
            </button>
          </div>
        </div>
      </div>
      <p v-else class="text-center text-gray-500">{{ $t('noActive') }}</p>
    </div>

    <!-- Historial -->
    <div v-if="selectedTab === 'history'" class="space-y-4">
      <div v-if="historyOrders.length > 0">
        <div
          v-for="order in historyOrders"
          :key="order.id"
          class="p-4 border rounded-md shadow-sm cursor-pointer hover:bg-gray-50"
          @click="openHistoryModal(order)"
        >
          <p class="font-semibold">{{ order.service_name }}</p>
          <p class="text-sm text-gray-500">{{ order.provider_name }}</p>
        </div>
      </div>
      <p v-else class="text-center text-gray-500">{{ $t('orders.noHistory') }}</p>
    </div>

    <!-- Modal historial -->
    <div
      v-if="isModalOpen"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4"
    >
      <div class="bg-white rounded-lg shadow-lg w-full max-w-lg p-6 relative">
        <button
          class="absolute top-2 right-2 text-gray-500 hover:text-gray-700"
          @click="isModalOpen = false"
        >
          ✕
        </button>
        <h3 class="text-xl font-semibold mb-4">{{ selectedOrder?.service_name }}</h3>
        <p><strong>{{ $t('orders.provider') }}:</strong> {{ selectedOrder?.provider_name }}</p>
        <p><strong>{{ $t('orders.date') }}:</strong> {{ selectedOrder?.date }}</p>
        <p><strong>{{ $t('orders.status') }}:</strong> {{ selectedOrder?.status }}</p>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted, watch } from 'vue'
import api from '@/axio'
import Swal from 'sweetalert2'
import { useAuthStore } from '@/stores/authStore'
import { useI18n } from 'vue-i18n'
import { useSocketStore } from '@/stores/socketStore'

export default {
  name: 'Orders',
  setup() {
    const authStore = useAuthStore()
    const { t } = useI18n()
    const socketStore = useSocketStore()

    const activeOrders = ref([])
    const historyOrders = ref([])
    const selectedTab = ref('active')
    const isModalOpen = ref(false)
    const selectedOrder = ref(null)

    // ✅ STATUS FUNCTIONS
    const statusLabel = (status) => {
      const map = {
        pending: t('orders.pending') || 'Pendiente',
        accepted: t('orders.accepted') || 'Aceptada',
        in_progress: t('orders.inProgress') || 'En progreso',
        on_the_way: t('orders.onTheWay') || 'En camino',
        arrived: t('orders.arrived') || 'Llegó',
        completed: t('orders.completed') || 'Completada',
        cancelled: t('orders.cancelled') || 'Cancelada',
      }
      return map[status] || status
    }

    const statusColor = (status) => {
      const map = {
        pending: 'text-yellow-600',
        accepted: 'text-green-600',
        in_progress: 'text-blue-600',
        on_the_way: 'text-indigo-600',
        arrived: 'text-purple-600',
        completed: 'text-green-700',
        cancelled: 'text-red-600',
      }
      return map[status] || 'text-gray-600'
    }

    // ✅ FETCH ORDERS
    const fetchOrders = async () => {
  try {
    const authStore = useAuthStore()
    
    // ✅ Pedidos activos
    const activeRes = await api.get('/api/requests/active', {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    const activeRaw = Array.isArray(activeRes.data)
      ? activeRes.data
      : activeRes.data?.requests || activeRes.data?.data || []
    
    // ✅ Historial
    const historyRes = await api.get('/api/requests/history', {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    const historyRaw = Array.isArray(historyRes.data)
      ? historyRes.data
      : historyRes.data?.data || []

    // ✅ Mapea al formato que espera orders.vue
    activeOrders.value = activeRaw.map(r => ({
      id: r.id,
      service_name: r.service_title || 'Servicio',
      provider_name: r.service_provider_name || 'Proveedor',
      status: r.status || 'pending'
    }))

    historyOrders.value = historyRaw.map(r => ({
      id: r.id,
      service_name: r.service_title || 'Servicio',
      provider_name: r.service_provider_name || 'Proveedor',
      status: r.status || 'completed',
      date: r.created_at || r.date
    }))

  } catch (err) {
    console.error('Error al obtener pedidos:', err)
    Swal.fire(t('orders.error'), t('orders.loadFailed'), 'error')
  }
}

    // ✅ COMPLETE ORDER
    const markAsCompleted = async (orderId) => {
      try {
        await api.post(`/orders/${orderId}/complete`, {}, {
          headers: { Authorization: `Bearer ${authStore.token}` }
        })
        Swal.fire(t('orders.successTitle'), t('orders.completedMessage'), 'success')
        await fetchOrders()
      } catch (err) {
        console.error('Error al completar pedido:', err)
        Swal.fire(t('orders.error'), t('orders.completeFailed'), 'error')
      }
    }

    // ✅ CHAT & MODAL
    const startChat = (providerName) => {
      window.location.href = `/chat/${encodeURIComponent(providerName)}`
    }

    const openHistoryModal = (order) => {
      selectedOrder.value = order
      isModalOpen.value = true
    }

    // ✅ WEBSOCKET – ACTUALIZACIÓN EN TIEMPO REAL
    watch(
      () => socketStore.notifications,
      (newVal) => {
        const last = newVal[0]
        if (last?.event === 'status_changed') {
          const order = activeOrders.value.find(o => o.id === last.request_id)
          if (order) order.status = last.status
        }
      },
      { deep: true }
    )

    onMounted(fetchOrders)

    return {
      t,
      activeOrders,
      historyOrders,
      selectedTab,
      isModalOpen,
      selectedOrder,
      statusLabel,
      statusColor,
      markAsCompleted,
      startChat,
      openHistoryModal
    }
  }
}
</script>
