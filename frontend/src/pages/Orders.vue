<template>
  <div class="max-w-5xl mx-auto p-4 sm:p-6 bg-white rounded-xl shadow-md mt-8">

    <!-- Tabs -->
    <div class="flex space-x-4 border-b mb-6">
      <button
        class="pb-2 px-4"
        :class="tabClass('active')"
        @click="selectedTab = 'active'"
      >
        {{ $t('active') }}
      </button>
      <button
        class="pb-2 px-4"
        :class="tabClass('history')"
        @click="selectedTab = 'history'"
      >
        {{ $t('history') }}
      </button>
    </div>

    <!-- Skeleton -->
    <div v-if="loading" class="space-y-4">
      <div v-for="i in 3" :key="i" class="p-4 border rounded animate-pulse">
        <div class="h-5 bg-gray-300 rounded w-1/3 mb-2"/>
        <div class="h-4 bg-gray-200 rounded w-2/3"/>
      </div>
    </div>

    <!-- Activas -->
    <section v-else-if="selectedTab === 'active'">
      <p v-if="!activeOrders.length" class="text-center text-gray-500">{{ $t('orders.noActive') }}</p>
      <div
        v-for="o in activeOrders"
        :key="o.id"
        class="p-4 border rounded mb-3 shadow-sm flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3"
      >
        <!-- Información -->
        <div class="min-w-0 flex-1">
          <p class="font-semibold truncate">{{ o.serviceTitle }}</p>
          <p class="text-sm text-gray-500 truncate">{{ o.providerName }}</p>
          <p :class="statusColor(o.status)" class="text-xs font-medium mt-1">{{ statusLabel(o.status) }}</p>
        </div>

        <!-- Botones -->
        <div class="flex flex-wrap gap-2">
          <button
            v-if="authStore.user?.role === 'provider' && o.status === 'in_progress'"
            @click="finaliseOrder(o.id)"
            class="bg-green-600 text-white px-3 py-1 rounded hover:bg-green-700"
          >
            {{ $t('finalized') }}
          </button>
          <button
            v-if="['pending','accepted'].includes(o.status)"
            @click="cancelOrder(o.id)"
            class="bg-red-600 text-white px-3 py-1 rounded hover:bg-red-700"
          >
            {{ $t('cancel') }}
          </button>
          <button
            v-if="o.status === 'completed'"
            @click="openReviewModal(o)"
            class="bg-blue-600 text-white px-3 py-1 rounded hover:bg-blue-700"
          >
            {{ $t('review') }}
          </button>
        </div>
      </div>
    </section>

    <!-- Historial -->
    <section v-else>
      <p v-if="!historyOrders.length" class="text-center text-gray-500">{{ $t('orders.noHistory') }}</p>
      <div
        v-for="h in historyOrders"
        :key="h.id"
        class="p-4 border rounded mb-2 shadow-sm hover:bg-gray-50 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3"
      >
        <!-- Información -->
        <div class="min-w-0 flex-1">
          <p class="font-semibold truncate">{{ h.serviceTitle }}</p>
          <p class="text-sm text-gray-500 truncate">{{ h.providerName }} – {{ fmtDate(h.finishedAt) }}</p>
        </div>

        <!-- Botones -->
        <div class="flex flex-wrap gap-2">
          <button
            @click="repeatOrder(h)"
            class="bg-indigo-600 text-white px-3 py-1 rounded hover:bg-indigo-700"
          >
            {{ $t('repeat') }}
          </button>
          <button
            @click="openReviewModal(h)"
            class="bg-blue-600 text-white px-3 py-1 rounded hover:bg-blue-700"
          >
            {{ $t('review') }}
          </button>
        </div>
      </div>
    </section>

    <!-- Modal reseña -->
    <div
      v-if="reviewModal.open"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50"
    >
      <div class="bg-white rounded-lg shadow-lg w-full max-w-md p-6">
        <h3 class="text-lg font-semibold mb-4">{{ $t('reviewOrder') }}</h3>
        <div class="flex justify-center gap-2 mb-4">
          <button
            v-for="n in 5"
            :key="n"
            @click="reviewModal.stars = n"
            class="text-3xl"
            :class="n <= reviewModal.stars ? 'text-yellow-400' : 'text-gray-300'"
          >
            ★
          </button>
        </div>
        <textarea
          v-model="reviewModal.comment"
          class="w-full border rounded p-2"
          rows="3"
          :placeholder="$t('orders.commentPlaceholder')"
        />
        <div class="flex justify-end gap-2 mt-4">
          <button @click="reviewModal.open = false" class="px-4 py-2 rounded border">
            {{ $t('cancel') }}
          </button>
          <button @click="sendReview" class="px-4 py-2 rounded bg-blue-600 text-white">
            {{ $t('send') }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onUnmounted } from 'vue'
import { useAuthStore } from '@/stores/authStore'
import { useSocketStore } from '@/stores/socketStore'
import { useI18n } from 'vue-i18n'
import Swal from 'sweetalert2'
import dayjs from 'dayjs'
import relativeTime from 'dayjs/plugin/relativeTime'
import 'dayjs/locale/es'
dayjs.extend(relativeTime)
dayjs.locale('es')

const authStore = useAuthStore()
const socketStore = useSocketStore()
const { t } = useI18n()

const selectedTab = ref('active')
const loading = ref(true)
const activeOrders = ref([])
const historyOrders = ref([])
const reviewModal = reactive({
  open: false,
  order: null,
  stars: 0,
  comment: ''
})

const statusLabel = s =>
  ({ pending: 'Pendiente', accepted: 'Aceptada', in_progress: 'En progreso', on_the_way: 'En camino', arrived: 'Llegó', completed: 'Completada', cancelled: 'Cancelada' }[s] || s)

const statusColor = s =>
  ({ pending: 'text-yellow-600', accepted: 'text-green-600', in_progress: 'text-blue-600', on_the_way: 'text-indigo-600', arrived: 'text-purple-600', completed: 'text-green-700', cancelled: 'text-red-600' }[s] || 'text-gray-600')

const tabClass = tab =>
  selectedTab.value === tab
    ? 'border-b-2 border-blue-600 text-blue-600 font-semibold'
    : 'text-gray-600'

const fmtDate = d => dayjs(d).fromNow()

async function fetchOrders () {
  loading.value = true
  try {
    const [activeRes, historyRes] = await Promise.all([
      api.get('/api/requests/active', { headers: { Authorization: `Bearer ${authStore.token}` } }),
      api.get('/api/history', { headers: { Authorization: `Bearer ${authStore.token}` } })
    ])
    activeOrders.value = (activeRes.data?.data || []).map(mapRequest)
    historyOrders.value = (historyRes.data?.history || []).map(mapHistory)
  } catch (e) {
    Swal.fire(t('error'), t('orders.loadFailed'), 'error')
  } finally {
    loading.value = false
  }
}

const mapRequest = r => ({
  id: r.id,
  serviceTitle: r.service_title || 'Servicio',
  providerName: r.service_provider_name || 'Proveedor',
  status: r.status,
  createdAt: r.created_at,
  price: r.price
})

const mapHistory = h => ({
  id: h.id,
  serviceTitle: h.service_title || 'Servicio',
  providerName: h.provider_name || 'Proveedor',
  status: h.status,
  finishedAt: h.finished_at,
  price: h.service_price
})

async function cancelOrder (id) {
  const { isConfirmed } = await Swal.fire({
    title: t('orders.cancelTitle'),
    text: t('orders.cancelText'),
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: t('yes'),
    cancelButtonText: t('no')
  })
  if (!isConfirmed) return
  try {
    await api.post('/api/requests/cancel', { id }, { headers: { Authorization: `Bearer ${authStore.token}` } })
    await fetchOrders()
    Swal.fire(t('orders.cancelled'), '', 'success')
  } catch {
    Swal.fire(t('error'), t('orders.cancelFailed'), 'error')
  }
}

async function finaliseOrder (id) {
  try {
    await api.post('/api/requests/finalized', { id }, { headers: { Authorization: `Bearer ${authStore.token}` } })
    await fetchOrders()
  } catch {
    Swal.fire(t('error'), t('orders.finaliseFailed'), 'error')
  }
}

function openReviewModal (order) {
  reviewModal.order = order
  reviewModal.stars = 0
  reviewModal.comment = ''
  reviewModal.open = true
}

async function sendReview () {
  try {
    await api.post('/api/history/rate', {
      id: reviewModal.order.id,
      stars: reviewModal.stars,
      comment: reviewModal.comment
    }, { headers: { Authorization: `Bearer ${authStore.token}` } })
    reviewModal.open = false
    Swal.fire(t('orders.reviewSent'), '', 'success')
  } catch (err) {
    if (err.response && err.response.status === 422 && err.response.data.message === 'already_rated') {
      Swal.fire(t('orders.alreadyVoted'), '', 'info')
    } else {
      Swal.fire(t('error'), t('orders.reviewFailed'), 'error')
    }
  }
}

async function repeatOrder (historyItem) {
  try {
    const payload = { repeat_from: historyItem.id }
    const { data } = await api.post('/api/requests/create', payload, { headers: { Authorization: `Bearer ${authStore.token}` } })
    Swal.fire(t('orders.repeated'), `ID ${data.requestId}`, 'success')
    selectedTab.value = 'active'
    await fetchOrders()
  } catch (err) {
    Swal.fire(t('error'), t('orders.repeatFailed'), 'error')
  }
}

let unsub = null
onMounted(() => {
  unsub = socketStore.$onAction(({ name, args }) => {
    if (name === 'pushNotification' && args[0]?.event === 'status_changed') {
      const { request_id, status } = args[0]
      const order = activeOrders.value.find(o => o.id === request_id)
      if (order) order.status = status
    }
  })
  fetchOrders()
})
onUnmounted(() => unsub && unsub())

import axios from 'axios'
const api = axios.create({ baseURL: import.meta.env.VITE_API_URL || 'http://localhost:8000' })
</script>

<style scoped>
button:focus {
  outline: 2px solid #3b82f6;
}
</style>
