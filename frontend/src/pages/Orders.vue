<template>
  <div class="orders-page">
    <!-- Header -->
    <div class="header">
      <div class="title-section">
        <h1><span class="orders-icon">📋</span> Mis Pedidos</h1>
        <p>Gestiona tus servicios activos y revisa tu historial</p>
      </div>
    </div>

    <!-- Tabs -->
    <div class="tabs-section">
      <button
        class="tab-button"
        :class="{ active: selectedTab === 'active' }"
        @click="selectedTab = 'active'"
      >
        <span class="tab-icon">⏳</span>
        <span class="tab-text">{{ $t('active') }}</span>
        <span v-if="activeOrders.length > 0" class="tab-badge">
          {{ activeOrders.length }}
        </span>
      </button>
      
      <button
        class="tab-button"
        :class="{ active: selectedTab === 'history' }"
        @click="selectedTab = 'history'"
      >
        <span class="tab-icon">📊</span>
        <span class="tab-text">{{ $t('history') }}</span>
        <span v-if="historyOrders.length > 0" class="tab-badge">
          {{ historyOrders.length }}
        </span>
      </button>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="loading-container">
      <div class="spinner"></div>
      <p>Cargando tus pedidos...</p>
    </div>

    <!-- Main Content -->
    <div v-else>
      <!-- Active Orders Section -->
      <section v-if="selectedTab === 'active'" class="orders-section">
        <div class="section-header">
          <h2>Pedidos Activos</h2>
          <p class="section-subtitle">
            {{ activeOrders.length }} servicio{{ activeOrders.length !== 1 ? 's' : '' }} en progreso
          </p>
        </div>

        <div v-if="!activeOrders.length" class="empty-state">
          <div class="empty-icon">⏳</div>
          <h3>{{ $t('orders.noActive') }}</h3>
          <p>No tienes servicios activos en este momento</p>
        </div>

        <div v-else class="orders-grid">
          <div
            v-for="o in activeOrders"
            :key="o.id"
            class="order-card"
            :class="`status-${o.status}`"
          >
            <div class="card-badge" :class="statusColor(o.status)">
              {{ statusLabel(o.status) }}
            </div>
            
            <div class="card-content">
              <div class="order-header">
                <h3 class="service-title">{{ o.serviceTitle }}</h3>
                <div class="price-tag">
                  <span class="price-amount">{{ o.price ? formatPrice(o.price) : 'Consultar' }}</span>
                </div>
              </div>

              <div class="order-details">
                <div class="detail-item">
                  <span class="detail-icon">👤</span>
                  <span class="detail-text">{{ o.providerName }}</span>
                </div>
                <div class="detail-item">
                  <span class="detail-icon">📅</span>
                  <span class="detail-text">{{ fmtDate(o.createdAt) }}</span>
                </div>
              </div>

              <div class="card-footer">
                <div class="status-indicator">
                  <div class="status-dot" :class="statusColor(o.status)"></div>
                  <span class="status-text">{{ getStatusDescription(o.status) }}</span>
                </div>
                
                <div class="action-buttons">
                  <button
                    v-if="authStore.user?.role === 'provider' && o.status === 'in_progress'"
                    class="btn-action btn-finalise"
                    @click="finaliseOrder(o.id)"
                  >
                    <span class="btn-icon">✅</span>
                    <span class="btn-text">{{ $t('finalized') }}</span>
                  </button>
                  <button
                    v-if="['pending','accepted'].includes(o.status)"
                    class="btn-action btn-cancel"
                    @click="cancelOrder(o.id)"
                  >
                    <span class="btn-icon">❌</span>
                    <span class="btn-text">{{ $t('cancel') }}</span>
                  </button>
                  <button
                    v-if="o.status === 'completed'"
                    class="btn-action btn-review"
                    @click="openReviewModal(o)"
                  >
                    <span class="btn-icon">⭐</span>
                    <span class="btn-text">{{ $t('review') }}</span>
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- History Orders Section -->
      <section v-else class="orders-section">
        <div class="section-header">
          <h2>Historial de Pedidos</h2>
          <p class="section-subtitle">
            {{ historyOrders.length }} servicio{{ historyOrders.length !== 1 ? 's' : '' }} completados
          </p>
        </div>

        <div v-if="!historyOrders.length" class="empty-state">
          <div class="empty-icon">📊</div>
          <h3>{{ $t('orders.noHistory') }}</h3>
          <p>Tu historial de pedidos aparecerá aquí</p>
        </div>

        <div v-else class="orders-grid">
          <div
            v-for="h in historyOrders"
            :key="h.id"
            class="order-card history-card"
          >
            <div class="card-badge completed">
              Completado
            </div>
            
            <div class="card-content">
              <div class="order-header">
                <h3 class="service-title">{{ h.serviceTitle }}</h3>
                <div class="price-tag">
                  <span class="price-amount">{{ h.price ? formatPrice(h.price) : 'Consultar' }}</span>
                </div>
              </div>

              <div class="order-details">
                <div class="detail-item">
                  <span class="detail-icon">👤</span>
                  <span class="detail-text">{{ h.providerName }}</span>
                </div>
                <div class="detail-item">
                  <span class="detail-icon">📅</span>
                  <span class="detail-text">{{ fmtDate(h.finishedAt) }}</span>
                </div>
              </div>

              <div class="card-footer">
                <div class="completion-info">
                  <span class="completion-text">Finalizado {{ fmtDate(h.finishedAt) }}</span>
                </div>
                
                <div class="action-buttons">
                  <button
                    class="btn-action btn-repeat"
                    @click="repeatOrder(h)"
                  >
                    <span class="btn-icon">🔄</span>
                    <span class="btn-text">{{ $t('repeat') }}</span>
                  </button>
                  <button
                    class="btn-action btn-review"
                    @click="openReviewModal(h)"
                  >
                    <span class="btn-icon">⭐</span>
                    <span class="btn-text">{{ $t('review') }}</span>
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
    </div>

    <!-- Modal reseña (MANTENIDO EXACTO) -->
    <Teleport to="body">
      <div
        v-if="reviewModal.open"
        class="modal-overlay"
        @click.self="reviewModal.open = false"
      >
        <div class="modal">
          <div class="modal-header">
            <h2>Nueva reseña</h2>
            <button
              class="modal-close"
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
          <div class="modal-section">
            <label class="modal-label">Calificación *</label>
            <div class="stars-container">
              <button
                v-for="i in 5"
                :key="i"
                class="star-button"
                @click="reviewModal.stars = i"
              >
                <svg
                  class="star-icon"
                  :class="i <= reviewModal.stars ? 'active' : ''"
                  fill="currentColor"
                  viewBox="0 0 20 20"
                >
                  <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                </svg>
              </button>
            </div>
          </div>

          <!-- Comentario -->
          <div class="modal-section">
            <label class="modal-label">Comentario</label>
            <textarea
              v-model="reviewModal.comment"
              rows="4"
              maxlength="500"
              class="modal-textarea"
              placeholder="Cuéntanos tu experiencia..."
            />
            <div class="char-count">
              {{ reviewModal.comment.length }}/500
            </div>
          </div>

          <!-- Tags rápidos -->
          <div class="modal-section">
            <label class="modal-label">Tags rápidos</label>
            <div class="tags-container">
              <button
                v-for="tag in quickTags"
                :key="tag"
                class="tag-button"
                :class="{ active: reviewModal.tags.includes(tag) }"
                @click="toggleTag(tag)"
              >
                {{ tag }}
              </button>
            </div>
          </div>

          <!-- Fotos -->
          <div class="modal-section">
            <label class="modal-label">Fotos (máx. 3)</label>
            <div class="photos-container">
              <div
                v-for="(img, i) in reviewModal.photos"
                :key="i"
                class="photo-item"
              >
                <img
                  :src="getImgSrc(img)"
                  class="photo-image"
                  alt="Foto adjunta"
                >
                <button
                  class="photo-remove"
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
                class="photo-add"
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
                <span>Añadir</span>
              </button>
            </div>
            <input
              ref="fileInput"
              type="file"
              accept="image/*"
              class="file-input"
              @change="handleFile"
            >
          </div>

          <!-- Acciones -->
          <div class="modal-actions">
            <button
              class="btn-modal btn-cancel"
              @click="reviewModal.open = false"
            >
              Cancelar
            </button>
            <button
              :disabled="reviewModal.stars === 0"
              class="btn-modal btn-confirm"
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

// Métodos existentes (MANTENIDOS EXACTAMENTE IGUAL)
const statusLabel = s =>
  ({ pending: 'Pendiente', accepted: 'Aceptada', in_progress: 'En progreso', on_the_way: 'En camino', arrived: 'Llegó', completed: 'Completada', cancelled: 'Cancelada' }[s] || s)

const statusColor = s =>
  ({ pending: 'status-yellow', accepted: 'status-green', in_progress: 'status-blue', on_the_way: 'status-indigo', arrived: 'status-purple', completed: 'status-green', cancelled: 'status-red' }[s] || 'status-gray')

const getStatusDescription = s => {
  const descriptions = {
    pending: 'Esperando confirmación del proveedor',
    accepted: 'Servicio confirmado',
    in_progress: 'Trabajo en curso',
    on_the_way: 'Proveedor en camino',
    arrived: 'Proveedor llegó al lugar',
    completed: 'Servicio finalizado',
    cancelled: 'Pedido cancelado'
  }
  return descriptions[s] || 'Estado desconocido'
}

const fmtDate = d => dayjs(d).fromNow()
const getImgSrc = (img) => {
  return img instanceof File ? URL.createObjectURL(img) : img
}

const formatPrice = (price) => {
  if (!price) return 'Consultar'
  return new Intl.NumberFormat('es-ES', {
    style: 'currency',
    currency: 'USD'
  }).format(price)
}

async function fetchOrders () {
  loading.value = true
  try {
    const [activeRes, historyRes] = await Promise.all([
      api.get('/requests/active', { headers: { Authorization: `Bearer ${authStore.token}` } }),
      api.get('/history', { headers: { Authorization: `Bearer ${authStore.token}` } })
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
    await api.post('/requests/cancel', { id }, { headers: { Authorization: `Bearer ${authStore.token}` } })
    await fetchOrders()
    Swal.fire(t('orders.cancelled'), '', 'success')
  } catch {
    Swal.fire(t('error'), t('orders.cancelFailed'), 'error')
  }
}

async function finaliseOrder (id) {
  try {
    await api.post('/requests/finalized', { id }, { headers: { Authorization: `Bearer ${authStore.token}` } })
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
      await api.post('/history/rate', form, {
        headers: { Authorization: `Bearer ${authStore.token}` }
      })
    } else {
      await api.post('/history/rate', payload, { headers })
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
const api = axios.create({ baseURL: import.meta.env.VITE_API_URL})
</script>

<style scoped>
.orders-page {
  max-width: 1400px;
  margin: 0 auto;
  padding: 24px;
  min-height: 100vh;
  background: linear-gradient(135deg, #f5f7fa 0%, #e4edf5 100%);
}

/* Header */
.header {
  margin-bottom: 40px;
  text-align: center;
}

.title-section h1 {
  font-size: 2.5rem;
  color: #2d3436;
  margin-bottom: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
}

.orders-icon {
  font-size: 2.2rem;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.1); }
}

.title-section p {
  color: #636e72;
  font-size: 1.1rem;
}

/* Tabs */
.tabs-section {
  display: flex;
  gap: 16px;
  margin-bottom: 40px;
  background: white;
  padding: 8px;
  border-radius: 16px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
  max-width: 500px;
  margin-left: auto;
  margin-right: auto;
}

.tab-button {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 16px 24px;
  border: none;
  background: transparent;
  border-radius: 12px;
  cursor: pointer;
  font-weight: 600;
  color: #636e72;
  transition: all 0.3s;
  position: relative;
}

.tab-button:hover {
  background: #f8f9fa;
  transform: translateY(-2px);
}

.tab-button.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
}

.tab-icon {
  font-size: 1.2rem;
}

.tab-text {
  font-size: 1rem;
}

.tab-badge {
  position: absolute;
  top: -8px;
  right: -8px;
  background: #ff7675;
  color: white;
  font-size: 0.7rem;
  padding: 2px 8px;
  border-radius: 12px;
  min-width: 20px;
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* Loading */
.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 400px;
}

.spinner {
  width: 60px;
  height: 60px;
  border: 4px solid rgba(52, 152, 219, 0.2);
  border-top: 4px solid #3498db;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 20px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* Sections */
.orders-section {
  background: white;
  border-radius: 24px;
  padding: 32px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
  margin-bottom: 32px;
}

.section-header {
  margin-bottom: 32px;
  text-align: center;
}

.section-header h2 {
  font-size: 2rem;
  color: #2d3436;
  margin-bottom: 8px;
}

.section-subtitle {
  color: #636e72;
  font-size: 1.1rem;
}

/* Empty State */
.empty-state {
  text-align: center;
  padding: 60px 20px;
  background: #f8f9fa;
  border-radius: 20px;
  margin: 20px 0;
}

.empty-icon {
  font-size: 64px;
  margin-bottom: 20px;
  opacity: 0.5;
}

.empty-state h3 {
  color: #2d3436;
  margin-bottom: 12px;
  font-size: 1.5rem;
}

.empty-state p {
  color: #636e72;
  font-size: 1.1rem;
  max-width: 400px;
  margin: 0 auto;
}

/* Orders Grid */
.orders-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
  gap: 24px;
}

.order-card {
  background: white;
  border-radius: 20px;
  overflow: hidden;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
  transition: all 0.4s;
  position: relative;
  border: 2px solid #f1f2f6;
}

.order-card:hover {
  transform: translateY(-10px);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
}

.history-card {
  border: 2px dashed #dfe6e9;
}

/* Card Badge */
.card-badge {
  position: absolute;
  top: 16px;
  right: 16px;
  padding: 6px 16px;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
  color: white;
  z-index: 2;
}

.status-yellow { background: linear-gradient(135deg, #fdcb6e 0%, #e17055 100%); }
.status-green { background: linear-gradient(135deg, #00b894 0%, #00a085 100%); }
.status-blue { background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%); }
.status-indigo { background: linear-gradient(135deg, #a29bfe 0%, #6c5ce7 100%); }
.status-purple { background: linear-gradient(135deg, #fd79a8 0%, #e84393 100%); }
.status-red { background: linear-gradient(135deg, #ff7675 0%, #d63031 100%); }
.status-gray { background: linear-gradient(135deg, #636e72 0%, #2d3436 100%); }

.completed {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
}

/* Card Content */
.card-content {
  padding: 24px;
}

.order-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 20px;
  gap: 16px;
}

.service-title {
  font-size: 1.4rem;
  color: #2d3436;
  flex: 1;
  line-height: 1.3;
}

.price-tag {
  background: linear-gradient(135deg, #a8edea 0%, #fed6e3 100%);
  padding: 8px 16px;
  border-radius: 12px;
  text-align: center;
  min-width: 120px;
}

.price-amount {
  font-size: 1.2rem;
  font-weight: 700;
  color: #2d3436;
}

/* Order Details */
.order-details {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 12px;
  margin-bottom: 24px;
  padding: 16px;
  background: #f8f9fa;
  border-radius: 12px;
}

.detail-item {
  display: flex;
  align-items: center;
  gap: 10px;
}

.detail-icon {
  width: 32px;
  height: 32px;
  background: #74b9ff;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 1rem;
}

.detail-text {
  color: #2d3436;
  font-weight: 500;
}

/* Card Footer */
.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 20px;
  border-top: 1px solid #f1f2f6;
}

.status-indicator {
  display: flex;
  align-items: center;
  gap: 8px;
}

.status-dot {
  width: 12px;
  height: 12px;
  border-radius: 50%;
}

.status-text {
  color: #636e72;
  font-size: 0.9rem;
}

.completion-info {
  color: #636e72;
  font-size: 0.9rem;
  font-style: italic;
}

/* Action Buttons */
.action-buttons {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.btn-action {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 10px 20px;
  border: none;
  border-radius: 10px;
  cursor: pointer;
  font-weight: 600;
  font-size: 0.9rem;
  transition: all 0.3s;
}

.btn-finalise {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
  color: white;
}

.btn-cancel {
  background: linear-gradient(135deg, #ff7675 0%, #d63031 100%);
  color: white;
}

.btn-review {
  background: linear-gradient(135deg, #fdcb6e 0%, #e17055 100%);
  color: white;
}

.btn-repeat {
  background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%);
  color: white;
}

.btn-action:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.btn-icon {
  font-size: 1rem;
}

/* Modal Styles (Rediseñado pero funcionalidad igual) */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  backdrop-filter: blur(4px);
}

.modal {
  background: white;
  width: 90%;
  max-width: 500px;
  border-radius: 20px;
  overflow: hidden;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.modal-header h2 {
  font-size: 1.5rem;
  margin: 0;
}

.modal-close {
  background: transparent;
  border: none;
  color: white;
  cursor: pointer;
  padding: 8px;
  border-radius: 8px;
  transition: background 0.3s;
}

.modal-close:hover {
  background: rgba(255, 255, 255, 0.1);
}

.modal-section {
  padding: 20px 24px;
  border-bottom: 1px solid #f1f2f6;
}

.modal-section:last-child {
  border-bottom: none;
}

.modal-label {
  display: block;
  margin-bottom: 12px;
  font-weight: 600;
  color: #2d3436;
}

.stars-container {
  display: flex;
  gap: 8px;
}

.star-button {
  background: transparent;
  border: none;
  cursor: pointer;
  padding: 4px;
  transition: transform 0.2s;
}

.star-button:hover {
  transform: scale(1.2);
}

.star-icon {
  width: 32px;
  height: 32px;
  color: #dfe6e9;
}

.star-icon.active {
  color: #fdcb6e;
}

.modal-textarea {
  width: 100%;
  padding: 12px;
  border: 2px solid #dfe6e9;
  border-radius: 12px;
  resize: vertical;
  font-family: inherit;
  font-size: 1rem;
  transition: border-color 0.3s;
}

.modal-textarea:focus {
  outline: none;
  border-color: #74b9ff;
}

.char-count {
  text-align: right;
  margin-top: 8px;
  color: #636e72;
  font-size: 0.8rem;
}

.tags-container {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.tag-button {
  padding: 8px 16px;
  border: 2px solid #dfe6e9;
  border-radius: 20px;
  background: white;
  color: #2d3436;
  cursor: pointer;
  font-size: 0.9rem;
  transition: all 0.3s;
}

.tag-button:hover {
  border-color: #74b9ff;
  transform: translateY(-2px);
}

.tag-button.active {
  background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%);
  color: white;
  border-color: #0984e3;
}

.photos-container {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}

.photo-item {
  position: relative;
  width: 80px;
  height: 80px;
}

.photo-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 12px;
  border: 2px solid #dfe6e9;
}

.photo-remove {
  position: absolute;
  top: -8px;
  right: -8px;
  width: 24px;
  height: 24px;
  background: #ff7675;
  border: none;
  border-radius: 50%;
  color: white;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0;
}

.photo-add {
  width: 80px;
  height: 80px;
  border: 2px dashed #dfe6e9;
  border-radius: 12px;
  background: white;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: #636e72;
  cursor: pointer;
  transition: all 0.3s;
}

.photo-add:hover {
  border-color: #74b9ff;
  color: #74b9ff;
  transform: scale(1.05);
}

.file-input {
  display: none;
}

.modal-actions {
  display: flex;
  gap: 12px;
  padding: 24px;
  background: #f8f9fa;
}

.btn-modal {
  flex: 1;
  padding: 14px;
  border: none;
  border-radius: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-cancel {
  background: white;
  color: #2d3436;
  border: 2px solid #dfe6e9;
}

.btn-cancel:hover {
  background: #f1f2f6;
}

.btn-confirm {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.btn-confirm:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
}

.btn-confirm:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Responsive Design */
@media (max-width: 1200px) {
  .orders-grid {
    grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  }
}

@media (max-width: 768px) {
  .orders-page {
    padding: 16px;
  }
  
  .title-section h1 {
    font-size: 2rem;
  }
  
  .tabs-section {
    flex-direction: column;
    max-width: 300px;
  }
  
  .orders-grid {
    grid-template-columns: 1fr;
  }
  
  .order-header {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .price-tag {
    align-self: flex-start;
  }
  
  .card-footer {
    flex-direction: column;
    align-items: stretch;
    gap: 16px;
  }
  
  .action-buttons {
    justify-content: flex-end;
  }
}

@media (max-width: 480px) {
  .orders-section {
    padding: 20px;
  }
  
  .section-header h2 {
    font-size: 1.5rem;
  }
  
  .btn-action {
    flex: 1;
    justify-content: center;
  }
  
  .modal {
    width: 95%;
    margin: 0 10px;
  }
  
  .modal-header {
    padding: 16px;
  }
}
</style>
