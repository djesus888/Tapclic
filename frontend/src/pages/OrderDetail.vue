<template>
  <div class="order-detail-page">
    <div v-if="loading" class="loading-container">
      <div class="spinner"></div>
      <p>Cargando pedido...</p>
    </div>

    <div v-else-if="error" class="error-state">
      <div class="error-icon">⚠️</div>
      <h3>Error al cargar el pedido</h3>
      <p>{{ error }}</p>
      <button class="btn-primary" @click="$router.push('/orders')">
        Volver a mis pedidos
      </button>
    </div>

    <div v-else-if="order" class="order-content">
      <!-- Header con botón volver -->
      <div class="top-bar">
        <button class="btn-back" @click="$router.push('/orders')">
          ← Volver a pedidos
        </button>
      </div>

      <!-- Sección principal: Imagen + Info -->
      <div class="main-section">
        <!-- Imagen del servicio (izquierda) -->
        <div class="service-image-section">
          <img
            :src="getServiceImage(order)"
            :alt="order.service_title || 'Servicio'"
            class="service-image"
            @error="handleImageError"
          />
          <div class="image-overlay">
            <span class="image-label">Imagen del servicio</span>
          </div>
        </div>

        <!-- Info y botón de aceptar (derecha) -->
        <div class="service-info-section">
          <div class="info-header">
            <h1>Pedido #{{ order.id }}</h1>
            <div class="header-badges">
              <span class="status-badge" :class="statusColor(order.status)">
                {{ statusLabel(order.status) }}
              </span>
              <!-- Botón de SERVICIO ACEPTADO (solo visible cuando está aceptado) -->
              <button
                v-if="order.status === 'accepted'"
                class="btn-accepted-badge"
                @click="handleAcceptedAction"
              >
                <span class="badge-icon">✅</span>
                Servicio Aceptado
              </button>
            </div>
          </div>

          <h2 class="service-title">{{ order.service_title }}</h2>
          <p class="description">{{ order.service_description || 'Sin descripción disponible' }}</p>

          <div class="info-grid">
            <div class="info-item">
              <span class="label">Proveedor</span>
              <span class="value">{{ order.provider_name || 'No especificado' }}</span>
            </div>
            <div class="info-item">
              <span class="label">Precio</span>
              <span class="value price">${{ formatPrice(order.price) }}</span>
            </div>
            <div class="info-item">
              <span class="label">Estado</span>
              <span class="value status-text" :class="statusColor(order.status)">
                {{ statusLabel(order.status) }}
              </span>
            </div>
            <div class="info-item">
              <span class="label">Pago</span>
              <PaymentPill :status="order.payment_status" />
            </div>
            <div class="info-item">
              <span class="label">Fecha de solicitud</span>
              <span class="value">{{ formatDate(order.created_at) }}</span>
            </div>
            <div class="info-item" v-if="order.finished_at">
              <span class="label">Finalizado</span>
              <span class="value">{{ formatDate(order.finished_at) }}</span>
            </div>
            <div class="info-item" v-if="order.updated_at && order.updated_at !== order.created_at">
              <span class="label">Última actualización</span>
              <span class="value">{{ formatDate(order.updated_at) }}</span>
            </div>
          </div>

          <!-- Timeline de estados -->
          <div class="status-timeline">
            <h3 class="timeline-title">Progreso del servicio</h3>
            <div class="timeline-steps">
              <div
                v-for="step in timelineSteps"
                :key="step.status"
                class="timeline-step"
                :class="{
                  active: isStepActive(step.status),
                  completed: isStepCompleted(step.status),
                  current: order.status === step.status
                }"
              >
                <div class="step-dot">
                  <span class="step-icon">{{ step.icon }}</span>
                </div>
                <div class="step-info">
                  <span class="step-label">{{ step.label }}</span>
                  <span class="step-date" v-if="getStepDate(step.status)">
                    {{ formatDate(getStepDate(step.status)) }}
                  </span>
                </div>
                <div class="step-line" v-if="!step.isLast"></div>
              </div>
            </div>
          </div>

          <!-- Acciones rápidas -->
          <div class="action-buttons" v-if="showActionButtons">
            <button
              v-if="order.status === 'pending'"
              class="btn-action btn-cancel"
              @click="handleCancel"
            >
              ❌ Cancelar solicitud
            </button>
            <button
              v-if="canChat"
              class="btn-action btn-chat"
              @click="handleChat"
            >
              💬 Chatear con el proveedor
            </button>
            <button
              v-if="order.payment_status === 'pending' && order.status === 'accepted'"
              class="btn-action btn-pay"
              @click="handlePayment"
            >
              💳 Realizar pago
            </button>
            <button
              v-if="canReview"
              class="btn-action btn-review"
              @click="handleReview"
            >
              ⭐ Dejar reseña
            </button>
            <button
              v-if="canDispute"
              class="btn-action btn-dispute"
              @click="handleDispute"
            >
              ⚖️ Abrir disputa
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/authStore'
import axios from 'axios'
import PaymentPill from '@/components/PaymentPill.vue'
import Swal from 'sweetalert2'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const api = axios.create({ baseURL: import.meta.env.VITE_API_URL })

const order = ref(null)
const loading = ref(true)
const error = ref(null)

// ============ TIMELINE ============
const timelineSteps = computed(() => {
  const steps = [
    { status: 'pending', label: 'Solicitado', icon: '📝', isLast: false },
    { status: 'accepted', label: 'Aceptado', icon: '✅', isLast: false },
    { status: 'in_progress', label: 'En progreso', icon: '🚀', isLast: false },
    { status: 'on_the_way', label: 'En camino', icon: '🛵', isLast: false },
    { status: 'arrived', label: 'Llegó', icon: '📍', isLast: false },
    { status: 'completed', label: 'Completado', icon: '🏁', isLast: true },
  ]
  return steps
})

const statusOrder = {
  pending: 0,
  accepted: 1,
  in_progress: 2,
  on_the_way: 3,
  arrived: 4,
  completed: 5,
  cancelled: -1,
  rejected: -1
}

const isStepActive = (stepStatus) => {
  if (!order.value) return false
  const current = statusOrder[order.value.status] ?? -1
  const step = statusOrder[stepStatus] ?? -1
  return step <= current && current >= 0
}

const isStepCompleted = (stepStatus) => {
  if (!order.value) return false
  const current = statusOrder[order.value.status] ?? -1
  const step = statusOrder[stepStatus] ?? -1
  return step < current && current >= 0
}

const getStepDate = (stepStatus) => {
  // Adapta esto según los datos que devuelva tu API
  if (stepStatus === 'pending') return order.value?.created_at
  if (stepStatus === 'completed') return order.value?.finished_at
  if (stepStatus === order.value?.status) return order.value?.updated_at
  return null
}

// ============ PERMISOS ============
const showActionButtons = computed(() => {
  if (!order.value) return false
  const hideStatuses = ['cancelled', 'rejected', 'completed']
  return !hideStatuses.includes(order.value.status)
})

const canChat = computed(() => {
  if (!order.value) return false
  return ['accepted', 'in_progress', 'on_the_way', 'arrived'].includes(order.value.status)
})

const canReview = computed(() => {
  if (!order.value) return false
  return order.value.status === 'completed'
})

const canDispute = computed(() => {
  if (!order.value) return false
  const userRole = authStore.user?.role
  if (userRole !== 'user' && userRole !== 'client') return false
  return ['accepted', 'in_progress', 'on_the_way', 'arrived', 'completed'].includes(order.value.status)
})

// ============ MÉTODOS ============
const statusLabel = (s) => {
  const labels = {
    pending: 'Pendiente', accepted: 'Aceptado', in_progress: 'En progreso',
    on_the_way: 'En camino', arrived: 'Llegó', completed: 'Completado',
    cancelled: 'Cancelado', rejected: 'Rechazado'
  }
  return labels[s] || s
}

const statusColor = (s) => {
  const colors = {
    pending: 'status-yellow', accepted: 'status-green', in_progress: 'status-blue',
    on_the_way: 'status-indigo', arrived: 'status-purple',
    completed: 'status-green', cancelled: 'status-red', rejected: 'status-red'
  }
  return colors[s] || 'status-gray'
}

const formatDate = (date) => {
  if (!date) return 'No disponible'
  return new Date(date).toLocaleDateString('es-ES', {
    year: 'numeric', month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit'
  })
}

const formatPrice = (price) => {
  if (!price && price !== 0) return '0.00'
  const num = Number(price)
  return isNaN(num) ? '0.00' : num.toFixed(2)
}

const getServiceImage = (order) => {
  if (order?.service_image_url) {
    if (order.service_image_url.startsWith('http')) {
      return order.service_image_url
    }
    return `${import.meta.env.VITE_API_URL || ''}${order.service_image_url}`
  }
  return 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=600&h=400&fit=crop'
}

const handleImageError = (e) => {
  e.target.src = 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=600&h=400&fit=crop'
}

// ============ ACCIONES ============
const handleAcceptedAction = () => {
  Swal.fire({
    icon: 'success',
    title: '¡Servicio Aceptado!',
    text: 'El proveedor ha aceptado tu solicitud. Puedes proceder con el pago.',
    confirmButtonText: 'Entendido'
  })
}

const handleCancel = async () => {
  const { isConfirmed } = await Swal.fire({
    title: '¿Cancelar solicitud?',
    text: 'Esta acción no se puede deshacer.',
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Sí, cancelar',
    cancelButtonText: 'No, mantener'
  })
  if (!isConfirmed) return

  try {
    await api.post('/requests/cancel', { id: order.value.id }, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    order.value.status = 'cancelled'
    Swal.fire('Cancelado', 'La solicitud ha sido cancelada.', 'success')
  } catch (e) {
    Swal.fire('Error', 'No se pudo cancelar la solicitud.', 'error')
  }
}

const handleChat = () => {
  router.push(`/chat/${order.value.provider_id || order.value.id}`)
}

const handlePayment = () => {
  router.push('/payment')
}

const handleReview = () => {
  // Emitir evento o abrir modal de reseña
  Swal.fire({
    title: 'Reseña',
    text: 'Funcionalidad de reseña en desarrollo.',
    icon: 'info'
  })
}

const handleDispute = () => {
  router.push('/orders')
}

// ============ LIFECYCLE ============
onMounted(async () => {
  try {
    const requestId = route.params.id
    const { data } = await api.get(`/requests/status/${requestId}`, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })

    // Mapear los datos según la respuesta de tu API
    const raw = data.request || data
    order.value = {
      id: raw.id || requestId,
      service_title: raw.service_title || raw.title || 'Servicio',
      service_description: raw.service_description || raw.description || '',
      service_image_url: raw.service_image_url || raw.image_url || null,
      provider_name: raw.provider_name || raw.service_provider_name || 'Proveedor',
      provider_id: raw.provider_id || raw.service_provider_id || null,
      price: raw.price || raw.service_price || 0,
      status: raw.status || 'pending',
      payment_status: raw.payment_status || 'pending',
      created_at: raw.created_at || null,
      updated_at: raw.updated_at || null,
      finished_at: raw.finished_at || raw.completed_at || null
    }
  } catch (e) {
    error.value = 'No se pudo cargar la información del pedido.'
    console.error('Error cargando orden:', e)
  } finally {
    loading.value = false
  }
})
</script>

<style scoped>
.order-detail-page {
  max-width: 1400px;
  margin: 0 auto;
  padding: 24px;
  min-height: 100vh;
  background: linear-gradient(135deg, #f5f7fa 0%, #e4edf5 100%);
}

/* ============ LOADING ============ */
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

.loading-container p {
  color: #636e72;
  font-size: 1.1rem;
}

/* ============ ERROR ============ */
.error-state {
  text-align: center;
  padding: 80px 20px;
  background: white;
  border-radius: 24px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
}

.error-icon {
  font-size: 64px;
  margin-bottom: 20px;
}

.error-state h3 {
  color: #2d3436;
  margin-bottom: 12px;
  font-size: 1.5rem;
}

.error-state p {
  color: #636e72;
  font-size: 1.1rem;
  margin-bottom: 24px;
}

.btn-primary {
  padding: 14px 28px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
}

/* ============ CONTENT ============ */
.order-content {
  animation: fadeInUp 0.5s ease-out;
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* ============ TOP BAR ============ */
.top-bar {
  margin-bottom: 24px;
}

.btn-back {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 12px 24px;
  background: white;
  border: 2px solid #dfe6e9;
  border-radius: 12px;
  color: #2d3436;
  font-weight: 600;
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-back:hover {
  background: #f8f9fa;
  border-color: #b2bec3;
  transform: translateX(-4px);
}

/* ============ MAIN SECTION ============ */
.main-section {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 32px;
  align-items: start;
}

@media (max-width: 1024px) {
  .main-section {
    grid-template-columns: 1fr;
  }
}

/* ============ IMAGEN DEL SERVICIO (IZQUIERDA) ============ */
.service-image-section {
  position: relative;
  border-radius: 24px;
  overflow: hidden;
  box-shadow: 0 15px 40px rgba(0, 0, 0, 0.12);
  aspect-ratio: 4/3;
  background: #f1f2f6;
}

.service-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
  transition: transform 0.5s;
}

.service-image-section:hover .service-image {
  transform: scale(1.05);
}

.image-overlay {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 16px 20px;
  background: linear-gradient(transparent, rgba(0, 0, 0, 0.7));
}

.image-label {
  color: white;
  font-size: 0.85rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 1px;
}

/* ============ INFO SECTION (DERECHA) ============ */
.service-info-section {
  background: white;
  border-radius: 24px;
  padding: 32px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
}

.info-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  flex-wrap: wrap;
  gap: 12px;
  margin-bottom: 16px;
}

.info-header h1 {
  font-size: 1.8rem;
  color: #2d3436;
  margin: 0;
}

.header-badges {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

/* Badge de estado */
.status-badge {
  padding: 8px 20px;
  border-radius: 20px;
  font-size: 0.9rem;
  font-weight: 600;
  color: white;
}

/* BOTÓN DE SERVICIO ACEPTADO (NUEVO - DERECHA) */
.btn-accepted-badge {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 10px 22px;
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
  color: white;
  border: none;
  border-radius: 25px;
  font-size: 0.9rem;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.3s;
  box-shadow: 0 4px 15px rgba(0, 184, 148, 0.3);
  animation: pulseBadge 2s infinite;
}

.btn-accepted-badge:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(0, 184, 148, 0.4);
}

.btn-accepted-badge:active {
  transform: scale(0.95);
}

.badge-icon {
  font-size: 1.1rem;
}

@keyframes pulseBadge {
  0%, 100% {
    box-shadow: 0 4px 15px rgba(0, 184, 148, 0.3);
  }
  50% {
    box-shadow: 0 4px 25px rgba(0, 184, 148, 0.6);
  }
}

/* Colores de badges */
.status-yellow { background: linear-gradient(135deg, #fdcb6e 0%, #e17055 100%); }
.status-green { background: linear-gradient(135deg, #00b894 0%, #00a085 100%); }
.status-blue { background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%); }
.status-indigo { background: linear-gradient(135deg, #a29bfe 0%, #6c5ce7 100%); }
.status-purple { background: linear-gradient(135deg, #fd79a8 0%, #e84393 100%); }
.status-red { background: linear-gradient(135deg, #ff7675 0%, #d63031 100%); }
.status-gray { background: linear-gradient(135deg, #636e72 0%, #2d3436 100%); }

.service-title {
  font-size: 1.6rem;
  color: #2d3436;
  margin: 0 0 12px 0;
  line-height: 1.3;
}

.description {
  color: #636e72;
  font-size: 1.05rem;
  line-height: 1.6;
  margin-bottom: 24px;
  padding-bottom: 20px;
  border-bottom: 1px solid #f1f2f6;
}

/* ============ INFO GRID ============ */
.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 16px;
  margin-bottom: 28px;
}

.info-item {
  background: #f8f9fa;
  padding: 16px 20px;
  border-radius: 14px;
  display: flex;
  flex-direction: column;
  gap: 6px;
  transition: all 0.3s;
}

.info-item:hover {
  transform: translateY(-3px);
  box-shadow: 0 6px 15px rgba(0, 0, 0, 0.06);
}

.label {
  font-size: 0.8rem;
  font-weight: 600;
  color: #636e72;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.value {
  font-size: 1.05rem;
  color: #2d3436;
  font-weight: 500;
}

.value.price {
  font-weight: 700;
  color: #00b894;
  font-size: 1.2rem;
}

.status-text.status-green { color: #00b894; }
.status-text.status-blue { color: #0984e3; }
.status-text.status-yellow { color: #e17055; }
.status-text.status-red { color: #d63031; }

/* ============ TIMELINE ============ */
.status-timeline {
  margin: 28px 0;
  padding-top: 20px;
  border-top: 1px solid #f1f2f6;
}

.timeline-title {
  font-size: 1rem;
  font-weight: 700;
  color: #2d3436;
  margin-bottom: 20px;
}

.timeline-steps {
  display: flex;
  justify-content: space-between;
  position: relative;
  overflow-x: auto;
  padding-bottom: 8px;
}

.timeline-step {
  display: flex;
  flex-direction: column;
  align-items: center;
  position: relative;
  flex: 1;
  min-width: 70px;
  opacity: 0.4;
  transition: all 0.3s;
}

.timeline-step.active {
  opacity: 1;
}

.timeline-step.completed .step-dot {
  background: #00b894;
  border-color: #00b894;
  color: white;
}

.timeline-step.current .step-dot {
  background: #0984e3;
  border-color: #0984e3;
  color: white;
  transform: scale(1.2);
  box-shadow: 0 0 0 6px rgba(9, 132, 227, 0.15);
}

.step-dot {
  width: 44px;
  height: 44px;
  border-radius: 50%;
  background: #f1f2f6;
  border: 3px solid #dfe6e9;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 8px;
  transition: all 0.3s;
  z-index: 1;
}

.step-icon {
  font-size: 1.2rem;
}

.step-info {
  text-align: center;
}

.step-label {
  font-size: 0.75rem;
  font-weight: 600;
  color: #2d3436;
  display: block;
}

.step-date {
  font-size: 0.65rem;
  color: #636e72;
  display: block;
  margin-top: 2px;
}

/* ============ ACTION BUTTONS ============ */
.action-buttons {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  margin-top: 24px;
  padding-top: 20px;
  border-top: 1px solid #f1f2f6;
}

.btn-action {
  padding: 12px 20px;
  border: 2px solid #dfe6e9;
  border-radius: 12px;
  background: white;
  font-weight: 600;
  font-size: 0.95rem;
  cursor: pointer;
  transition: all 0.3s;
  display: inline-flex;
  align-items: center;
  gap: 8px;
}

.btn-action:hover {
  transform: translateY(-2px);
}

.btn-cancel {
  border-color: #ff7675;
  color: #d63031;
}

.btn-cancel:hover {
  background: #ffeaa7;
  border-color: #d63031;
}

.btn-chat {
  border-color: #74b9ff;
  color: #0984e3;
}

.btn-chat:hover {
  background: #dfe6e9;
}

.btn-pay {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
  color: white;
  border-color: transparent;
}

.btn-pay:hover {
  box-shadow: 0 4px 15px rgba(0, 184, 148, 0.3);
}

.btn-review {
  border-color: #fdcb6e;
  color: #e17055;
}

.btn-review:hover {
  background: #fff3cd;
}

.btn-dispute {
  border-color: #e17055;
  color: #d63031;
}

.btn-dispute:hover {
  background: #ffeaa7;
}

/* ============ RESPONSIVE ============ */
@media (max-width: 768px) {
  .order-detail-page {
    padding: 16px;
  }

  .main-section {
    gap: 20px;
  }

  .service-info-section {
    padding: 24px;
  }

  .info-header {
    flex-direction: column;
  }

  .info-header h1 {
    font-size: 1.4rem;
  }

  .service-title {
    font-size: 1.3rem;
  }

  .info-grid {
    grid-template-columns: 1fr;
    gap: 10px;
  }

  .timeline-steps {
    gap: 4px;
  }

  .step-dot {
    width: 36px;
    height: 36px;
  }

  .step-icon {
    font-size: 1rem;
  }

  .step-label {
    font-size: 0.7rem;
  }

  .action-buttons {
    flex-direction: column;
  }

  .btn-action {
    width: 100%;
    justify-content: center;
  }
}

@media (max-width: 480px) {
  .service-info-section {
    padding: 18px;
  }

  .btn-accepted-badge {
    font-size: 0.8rem;
    padding: 8px 16px;
  }
}
</style>
