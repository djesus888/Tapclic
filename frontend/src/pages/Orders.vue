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
    <div
      v-if="loading"
      class="space-y-4"
    >
      <div
        v-for="i in 3"
        :key="i"
        class="p-4 border rounded animate-pulse"
      >
        <div class="h-5 bg-gray-300 rounded w-1/3 mb-2" />
        <div class="h-4 bg-gray-200 rounded w-2/3" />
      </div>
    </div>

    <!-- Activas -->
    <section v-else-if="selectedTab === 'active'">
      <p
        v-if="!activeOrders.length"
        class="text-center text-gray-500"
      >
        {{ $t('orders.noActive') }}
      </p>
      <div
        v-for="o in activeOrders"
        :key="o.id"
        class="p-4 border rounded mb-3 shadow-sm flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3"
      >
        <!-- Información -->
        <div class="min-w-0 flex-1">
          <p class="font-semibold truncate">
            {{ o.serviceTitle }}
          </p>
          <p class="text-sm text-gray-500 truncate">
            {{ o.providerName }}
          </p>
          <p
            :class="statusColor(o.status)"
            class="text-xs font-medium mt-1"
          >
            {{ statusLabel(o.status) }}
          </p>
        </div>

        <!-- Botones -->
        <div class="flex flex-wrap gap-2">
          <button
            v-if="authStore.user?.role === 'provider' && o.status === 'in_progress'"
            class="bg-green-600 text-white px-3 py-1 rounded hover:bg-green-700"
            @click="finaliseOrder(o.id)"
          >
            {{ $t('finalized') }}
          </button>
          <button
            v-if="['pending','accepted'].includes(o.status)"
            class="bg-red-600 text-white px-3 py-1 rounded hover:bg-red-700"
            @click="cancelOrder(o.id)"
          >
            {{ $t('cancel') }}
          </button>
          <button
            v-if="o.status === 'completed'"
            class="bg-blue-600 text-white px-3 py-1 rounded hover:bg-blue-700"
            @click="openReviewModal(o)"
          >
            {{ $t('review') }}
          </button>
        </div>
      </div>
    </section>

    <!-- Historial -->
    <section v-else>
      <p
        v-if="!historyOrders.length"
        class="text-center text-gray-500"
      >
        {{ $t('orders.noHistory') }}
      </p>
      <div
        v-for="h in historyOrders"
        :key="h.id"
        class="p-4 border rounded mb-2 shadow-sm hover:bg-gray-50 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3"
      >
        <!-- Información -->
        <div class="min-w-0 flex-1">
          <p class="font-semibold truncate">
            {{ h.serviceTitle }}
          </p>
          <p class="text-sm text-gray-500 truncate">
            {{ h.providerName }} – {{ fmtDate(h.finishedAt) }}
          </p>
        </div>

        <!-- Botones -->
        <div class="flex flex-wrap gap-2">
          <button
            class="bg-indigo-600 text-white px-3 py-1 rounded hover:bg-indigo-700"
            @click="repeatOrder(h)"
          >
            {{ $t('repeat') }}
          </button>
          <button
            class="bg-blue-600 text-white px-3 py-1 rounded hover:bg-blue-700"
            @click="openReviewModal(h)"
          >
            {{ $t('review') }}
          </button>
        </div>
      </div>
    </section>

    <!-- Modal reseña -->
    <Teleport to="body">
      <div
        v-if="reviewModal.open"
        class="fixed inset-0 z-50 flex items-end justify-center bg-black/40 md:items-center"
        @click.self="reviewModal.open = false"
      >
        <div class="w-full max-w-2xl bg-white rounded-t-2xl md:rounded-2xl p-6 max-h-[90vh] overflow-y-auto">
          <div class="flex items-center justify-between mb-4">
            <h2 class="text-lg font-semibold">
              Nueva reseña
            </h2>
            <button
              class="text-gray-500 hover:text-gray-800"
              @click="reviewModal.open = false"
            >
              <svg
                class="w-6 h-6"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M6 18L18 6M6 6l12 12"
                />
              </svg>
            </button>
          </div>

          <!-- Estrellas -->
          <div class="mb-4">
            <label class="block text-sm font-medium mb-2">Calificación *</label>
            <div class="flex gap-2">
              <button
                v-for="i in 5"
                :key="i"
                class="transition-transform hover:scale-110"
                @click="reviewModal.stars = i"
              >
                <svg
                  class="w-8 h-8"
                  :class="i <= reviewModal.stars ? 'text-yellow-400' : 'text-gray-300'"
                  fill="currentColor"
                  viewBox="0 0 20 20"
                >
                  <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                </svg>
              </button>
            </div>
          </div>

          <!-- Comentario -->
          <div class="mb-4">
            <label class="block text-sm font-medium mb-2">Comentario</label>
            <textarea
              v-model="reviewModal.comment"
              rows="4"
              maxlength="500"
              class="w-full border rounded-lg p-2 resize-none"
              placeholder="Cuéntanos tu experiencia..."
            />
            <div class="text-right text-xs text-gray-400 mt-1">
              {{ reviewModal.comment.length }}/500
            </div>
          </div>

          <!-- Tags rápidos -->
          <div class="mb-4">
            <label class="block text-sm font-medium mb-2">Tags rápidos</label>
            <div class="flex flex-wrap gap-2">
              <button
                v-for="tag in quickTags"
                :key="tag"
                class="px-3 py-1 text-sm border rounded-full transition"
                :class="reviewModal.tags.includes(tag) ? 'bg-blue-600 text-white border-blue-600' : 'bg-white text-gray-700 border-gray-300'"
                @click="toggleTag(tag)"
              >
                {{ tag }}
              </button>
            </div>
          </div>

          <!-- Fotos -->
          <div class="mb-4">
            <label class="block text-sm font-medium mb-2">Fotos (máx. 3)</label>
            <div class="flex gap-2 mb-2">
              <div
                v-for="(img, i) in reviewModal.photos"
                :key="i"
                class="relative"
              >
                <img
                  :src="getImgSrc(img)"
                  class="w-20 h-20 object-cover rounded border"
                  alt="Foto adjunta"
                >
                <button
                  class="absolute -top-2 -right-2 bg-red-600 text-white rounded-full w-6 h-6 grid place-items-center"
                  @click="removePhoto(i)"
                >
                  <svg
                    class="w-4 h-4"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  ><path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M6 18L18 6M6 6l12 12"
                  /></svg>
                </button>
              </div>
              <button
                v-if="reviewModal.photos.length < 3"
                class="w-20 h-20 border-2 border-dashed border-gray-300 rounded flex flex-col items-center justify-center text-gray-500 hover:text-gray-800"
                @click="openFilePicker"
              >
                <svg
                  class="w-6 h-6 mb-1"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                ><path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 4v16m8-8H4"
                /></svg>
                <span class="text-xs">Añadir</span>
              </button>
            </div>
            <input
              ref="fileInput"
              type="file"
              accept="image/*"
              class="hidden"
              @change="handleFile"
            >
          </div>

          <!-- Acciones -->
          <div class="flex gap-2">
            <button
              class="flex-1 border py-2 rounded-lg"
              @click="reviewModal.open = false"
            >
              Cancelar
            </button>
            <button
              :disabled="reviewModal.stars === 0"
              class="flex-1 bg-blue-600 text-white py-2 rounded-lg disabled:opacity-50"
              @click="sendReview"
            >
              Enviar
            </button>
          </div>
        </div>
      </div>
    </Teleport>
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
  comment: '',
  tags: [],
  photos: []
})

const quickTags = ['Puntual', 'Profesional', 'Calidad', 'Limpio', 'Buen precio', 'Amable']
const fileInput = ref()

const statusLabel = s =>
  ({ pending: 'Pendiente', accepted: 'Aceptada', in_progress: 'En progreso', on_the_way: 'En camino', arrived: 'Llegó', completed: 'Completada', cancelled: 'Cancelada' }[s] || s)

const statusColor = s =>
  ({ pending: 'text-yellow-600', accepted: 'text-green-600', in_progress: 'text-blue-600', on_the_way: 'text-indigo-600', arrived: 'text-purple-600', completed: 'text-green-700', cancelled: 'text-red-600' }[s] || 'text-gray-600')

const tabClass = tab =>
  selectedTab.value === tab
    ? 'border-b-2 border-blue-600 text-blue-600 font-semibold'
    : 'text-gray-600'

const fmtDate = d => dayjs(d).fromNow()
const getImgSrc = (img) => {
  return img instanceof File ? URL.createObjectURL(img) : img
}

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
  reviewModal.tags = []
  reviewModal.photos = []
  reviewModal.open = true
}

function toggleTag (tag) {
  if (reviewModal.tags.includes(tag)) {
    reviewModal.tags = reviewModal.tags.filter(t => t !== tag)
  } else {
    reviewModal.tags.push(tag)
  }
}

function removePhoto (idx) {
  reviewModal.photos.splice(idx, 1)
}

function openFilePicker () {
  fileInput.value?.click()
}

async function handleFile (e) {
  const file = e.target.files?.[0]
  if (!file) return
  if (reviewModal.photos.length >= 3) return

  reviewModal.photos.push(file)
  e.target.value = ''
}

async function sendReview () {
  if (reviewModal.stars === 0) return
  try {
    const payload = {
      id: Number(reviewModal.order.id),
      stars: Number(reviewModal.stars),
      comment: reviewModal.comment,
      tags: reviewModal.tags.join(','),
      photos: reviewModal.photos.filter(p => !(p instanceof File)).join(',')
    }

    const headers = {
      Authorization: `Bearer ${authStore.token}`,
      'Content-Type': 'application/json'
    }

    const hasFilePhotos = reviewModal.photos.some(p => p instanceof File)

    if (hasFilePhotos) {
      const form = new FormData()
      Object.keys(payload).forEach(k => form.append(k, payload[k]))
      reviewModal.photos.forEach((file, idx) => {
        if (file instanceof File) {
          form.append('images[]', file)
        }
      })
      await api.post('/api/history/rate', form, {
        headers: { Authorization: `Bearer ${authStore.token}` }
      })
    } else {
      await api.post('/api/history/rate', payload, { headers })
    }

    reviewModal.open = false
    Swal.fire(t('orders.reviewSent'), '', 'success')
  } catch (err) {
    if (err.response && err.response.status === 409) {
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
