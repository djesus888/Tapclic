<template>
  <div class="requests-view p-2 sm:p-4 max-w-5xl mx-auto">

    <!-- Título + nueva solicitud -->
    <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between mb-4 gap-2">
      <h1 class="text-lg sm:text-2xl font-bold text-gray-800">{{ $t('my_requests') }}</h1>
      <router-link to="/" class="bg-blue-600 text-white px-3 py-2 rounded text-sm hover:bg-blue-700">
        + {{ $t('new_service') }}
      </router-link>
    </div>

    <!-- Tabs horizontales SCROLL en móvil -->
    <div class="overflow-x-auto mb-4">
      <div class="flex space-x-2 border-b min-w-max">
        <button v-for="tab in tabs" :key="tab.key" @click="filterStatus = tab.key" :class="tabClass(tab.key)">
          {{ tab.label }}
        </button>
      </div>
    </div>

    <!-- Buscador -->
    <div class="mb-4">
      <input v-model="search" type="text" :placeholder="$t('search_service_provider')"
        class="w-full sm:w-1/2 lg:w-1/3 px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 text-sm" />
    </div>

    <!-- Listado -->
    <div v-if="loading" class="text-center py-10 text-sm">{{ $t('loading') }}...</div>
    <div v-else-if="!filtered.length" class="text-center text-gray-500 py-10 text-sm">{{ $t('no_requests') }}</div>

    <!-- Cards: 1 columna móvil / 2 tablet / 3 desktop -->
    <div v-else class="grid gap-3 sm:gap-4 grid-cols-1 sm:grid-cols-2 lg:grid-cols-3">
      <div v-for="req in filtered" :key="req.id"
        class="bg-white rounded-lg shadow hover:shadow-lg transition p-3 sm:p-4 flex flex-col justify-between text-xs sm:text-sm">

        <!-- Cabecera -->
        <div>
          <div class="flex justify-between items-start mb-2 gap-2">
            <span :class="statusBadge(req.status)">{{ statusLabel(req.status) }}</span>
            <span class="text-xs text-gray-500 whitespace-nowrap">{{ formatDate(req.created_at) }}</span>
          </div>
          <h2 class="font-semibold text-sm sm:text-base">{{ sanitize(req.service_title) }}</h2>
          <p class="text-gray-600 mb-2 break-words">{{ sanitize(req.service_description) }}</p>

          <!-- Proveedor -->
          <div class="flex items-center gap-2 mb-3">
            <img :src="avatar(req.provider_avatar_url)" class="w-8 h-8 rounded-full object-cover" />
            <div class="min-w-0">
              <p class="font-medium truncate">{{ sanitize(req.provider_name) }}</p>
              <p v-if="req.provider_rating" class="text-yellow-500 text-xs">⭐ {{ req.provider_rating }}</p>
            </div>
          </div>

          <!-- Precio -->
          <p class="text-base sm:text-lg font-bold text-green-600">${{ Number(req.service_price || 0).toFixed(2) }}</p>
        </div>

        <!-- Acciones: icono + texto, se apilan si no caben -->
        <div class="mt-4 flex flex-wrap gap-2">
          <button @click="openDetail(req)" class="btn-action btn-indigo">👁️ {{ $t('detail') }}</button>
          <button v-if="canCancel(req.status)" @click="cancel(req)" class="btn-action btn-red">❌ {{ $t('cancel') }}</button>
          <button v-if="canTrack(req.status)" @click="openTracking(req)" class="btn-action btn-green">🗺️ {{ $t('track') }}</button>
          <button @click="openChat(req)" class="btn-action btn-gray">💬 {{ $t('chat') }}</button>
          <button v-if="req.status === 'completed' && !req.reviewed" @click="openReview(req)" class="btn-action btn-yellow">⭐ {{ $t('review') }}</button>
          <button v-if="req.status === 'completed'" @click="rehire(req)" class="btn-action btn-blue">🔁 {{ $t('rehire') }}</button>
        </div>
      </div>
    </div>

    <!-- Paginación -->
    <div v-if="totalPages > 1" class="flex justify-center mt-6 gap-2 flex-wrap">
      <button v-for="p in totalPages" :key="p" @click="page = p" :class="pageClass(p)">
        {{ p }}
      </button>
    </div>

    <!-- Modales re-utilizables -->
    <ServiceDetailsModal
      v-if="detailRequest"
      :request="detailRequest"
      :is-open="showDetail"
      @on-open-change="showDetail = $event"
      @on-start-chat="openChatFromModal"
      @on-request-service="onRequestService"
    />
    <LiveOrderTracking  v-if="trackingRequest" :order="trackingRequest" v-model:is-open="showTracking" @close="trackingRequest = null" />
    <ReviewFormModal    v-if="reviewRequest" :request="reviewRequest" v-model:is-open="showReview" @close="reviewRequest = null" @review-sent="fetchRequests" />
    <ChatRoomModal      v-if="chatTarget" :target="chatTarget" @close="chatTarget = null" />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'
import api from '@/axios'
import { useAuthStore } from '@/stores/authStore'
import { sanitize } from '@/utils/sanitize'
import { formatDate } from '@/utils/formatDate'

import ServiceDetailsModal from '@/components/ServiceDetailsModal.vue'
import LiveOrderTracking   from '@/components/LiveOrderTracking.vue'
import ReviewFormModal     from '@/components/ReviewFormModal.vue'
import ChatRoomModal       from '@/components/ChatRoomModal.vue'

const { t } = useI18n()
const authStore = useAuthStore()

const requests      = ref([])
const loading       = ref(true)
const search        = ref('')
const filterStatus  = ref('all')
const page          = ref(1)
const perPage       = 12

/* modales */
const detailRequest  = ref(null)
const trackingRequest= ref(null)
const reviewRequest  = ref(null)
const chatTarget     = ref(null)
const showDetail     = ref(false)
const showTracking   = ref(false)
const showReview     = ref(false)

/* Tabs con "rejected" incluido */
const tabs = computed(() => [
  { key: 'all',        label: t('all') },
  { key: 'pending',    label: t('pending') },
  { key: 'accepted',   label: t('accepted') },
  { key: 'in_progress',label: t('in_progress') },
  { key: 'completed',  label: t('completed') },
  { key: 'cancelled',  label: t('cancelled') },
  { key: 'rejected',   label: t('rejected') }
])

onMounted(() => fetchRequests())

async function fetchRequests () {
  loading.value = true
  try {
    const res = await api.get('/requests/mine', {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    requests.value = Array.isArray(res.data?.data) ? res.data.data : []
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
}

/* Filtros + búsqueda + paginación */
const filtered = computed(() => {
  let data = requests.value
  if (filterStatus.value !== 'all') data = data.filter(r => r.status === filterStatus.value)
  if (search.value) {
    const q = search.value.toLowerCase()
    data = data.filter(r =>
      r.service_title?.toLowerCase().includes(q) ||
      r.provider_name?.toLowerCase().includes(q)
    )
  }
  const start = (page.value - 1) * perPage
  return data.slice(start, start + perPage)
})

const totalPages = computed(() => Math.ceil(requests.value.length / perPage))

/* Acciones */
function openDetail(r) {
  const service = {
    id: r.id,
    title: r.service_title || 'Sin título',
    description: r.service_description || 'Sin descripción',
    status: r.status || 'unknown',
    price: Number(r.service_price || r.price || 0).toFixed(2),

    // ✅ Location real
    location: r.service_location || 'Ubicación no especificada',

    // ✅ Available real
    isAvailable: Boolean(r.service_is_available),

    // ✅ Provider completo y real
    provider: {
      id: r.provider_id,
      name: r.service_provider_name || 'Proveedor desconocido',
      avatar_url: r.service_image ? `/uploads/${r.service_image}` : null,
      rating: Number(r.service_provider_rating || 0)
    },

    created_at: r.created_at,
    service_id: r.service_id
  }

  console.log("🔍 Servicio completo para modal:", service)
  detailRequest.value = service
  showDetail.value = true
}

function onRequestService() {
  // ✅ Cerrar el modal
  showDetail.value = false

  // ✅ Redirigir al servicio (mismo comportamiento que "Re-contratar")
  if (detailRequest.value?.service_id) {
    window.$router?.push(`/service/${detailRequest.value.service_id}`) || (window.location = `/service/${detailRequest.value.service_id}`)
  } else {
    alert('No se pudo redirigir al servicio')
  }
}

function openTracking(r) {
  trackingRequest.value = {
    id: r.id,
    serviceName: r.service_title || 'Sin título',
    status: r.status || 'unknown',
    provider: {
      name: r.provider_name || 'Proveedor desconocido',
      avatar_url: r.provider_avatar_url
    }
  }
  showTracking.value = true
}

function openChat(r) {
  chatTarget.value = {
    id: r.provider_id,
    name: r.provider_name || 'Proveedor desconocido',
    role: 'provider',
    avatarUrl: r.provider_avatar_url
  }
}

function openChatFromModal(target) {
  chatTarget.value = target
}

function openReview(r) {
  reviewRequest.value = r
  showReview.value = true
}

async function cancel(r) {
  if (!confirm(t('confirm_cancel'))) return
  try {
    await api.put('/requests/cancel', { request_id: r.id }, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    await fetchRequests()
  } catch (e) {
    alert(e?.response?.data?.error || t('error'))
  }
}

function rehire(r) {
  window.$router?.push(`/service/${r.service_id}`) || (window.location = `/service/${r.service_id}`)
}

/* Helpers visuales */
function avatar(url) {
  return url ? `http://localhost:8000${url}` : '/img/default-provider.png'
}
function statusLabel(s) {
  const map = {
    pending: t('pending'),
    accepted: t('accepted'),
    in_progress: t('in_progress'),
    completed: t('completed'),
    cancelled: t('cancelled'),
    rejected: t('rejected')
  }
  return map[s] || s
}
function statusBadge(s) {
  const colors = {
    pending:    'bg-yellow-100 text-yellow-800',
    accepted:   'bg-blue-100 text-blue-800',
    in_progress:'bg-purple-100 text-purple-800',
    completed:  'bg-green-100 text-green-800',
    cancelled:  'bg-red-100 text-red-800',
    rejected:   'bg-gray-100 text-gray-800'
  }
  return `px-2 py-1 rounded-full text-xs font-medium ${colors[s] || 'bg-gray-100 text-gray-800'}`
}
function canCancel(s) {
  return ['pending', 'accepted'].includes(s)
}
function canTrack(s) {
  return ['accepted', 'in_progress', 'arrived', 'on_the_way'].includes(s)
}
function tabClass(k) {
  return filterStatus.value === k
    ? 'border-b-2 border-blue-600 text-blue-600 font-semibold pb-2'
    : 'text-gray-600 hover:text-blue-600 pb-2 whitespace-nowrap'
}
function pageClass(p) {
  return page.value === p
    ? 'px-3 py-1 rounded bg-blue-600 text-white text-xs sm:text-sm'
    : 'px-3 py-1 rounded bg-gray-200 text-gray-700 hover:bg-gray-300 text-xs sm:text-sm'
}
</script>

<style scoped>
/* Botones que se apilan en móvil y se alinean en desktop */
.btn-action {
  @apply px-2 py-1 rounded text-xs sm:text-sm font-medium flex items-center gap-1;
}
.btn-indigo { @apply bg-indigo-600 text-white hover:bg-indigo-700 }
.btn-red    { @apply bg-red-600 text-white hover:bg-red-700 }
.btn-green  { @apply bg-green-600 text-white hover:bg-green-700 }
.btn-gray   { @apply bg-gray-600 text-white hover:bg-gray-700 }
.btn-blue   { @apply bg-blue-600 text-white hover:bg-blue-700 }
.btn-yellow { @apply bg-yellow-500 text-white hover:bg-yellow-600 }

/* Scroll suave en tabs */
::-webkit-scrollbar { height: 4px; }
::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 4px; }
</style>
