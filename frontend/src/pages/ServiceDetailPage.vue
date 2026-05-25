<template>
  <div class="service-detail-page">
    <!-- Mensaje profesional (con el nuevo estilo) -->
    <transition name="fade">
      <div v-if="msg" class="message-toast" :class="msgType">
        {{ msg }}
      </div>
    </transition>

    <!-- Contenedor principal -->
    <div class="service-detail-container">
      <!-- Header con navegación -->
      <div class="detail-header">
        <button class="back-button" @click="$router.back()">
          ← {{ $t('back') }}
        </button>
        <h1 class="detail-title">{{ $t('service_details') }}</h1>
      </div>

      <!-- Grid principal -->
      <div class="detail-grid">
        <!-- Columna izquierda: Imagen y info básica -->
        <div class="left-column">
          <!-- Imagen del servicio -->
          <div class="service-image-section">
            <div class="image-container">
              <img
                v-if="service.image_url"
                :src="getImageUrl(service.image_url)"
                :alt="service.title || $t('service')"
                class="service-image"
                @error="handleImageError"
              />
              <div v-else class="image-placeholder">
                <span class="placeholder-icon">📸</span>
                <p>{{ $t('no_image_available') }}</p>
              </div>
            </div>
            <div class="image-badge">🖼️ {{ $t('service_image') }}</div>
          </div>

          <!-- Información básica -->
          <div class="basic-info-card">
            <div class="info-header">
              <h2 class="service-title">{{ service.title || $t('service') }}</h2>
              <div class="price-badge">
                <span class="price-amount">${{ Number(service.price || 0).toFixed(2) }}</span>
              </div>
            </div>

            <p class="service-description">{{ service.description }}</p>

            <div class="info-meta">
              <div class="meta-item">
                <span class="meta-icon">📍</span>
                <span class="meta-text">{{ service.location || $t('location_not_specified') }}</span>
              </div>
              <div class="meta-item">
                <span class="meta-icon">🏷️</span>
                <span class="meta-text">{{ service.category || $t('uncategorized') }}</span>
              </div>
            </div>
          </div>
        </div> <!-- Cierre de left-column -->

        <!-- Columna derecha: Proveedor y acciones -->
        <div class="right-column">
          <!-- Tarjeta del proveedor -->
          <div class="provider-card">
            <div class="provider-header">
              <h3 class="provider-title">{{ $t('service_provider') }}</h3>
              <div class="rating-badge">
                <span class="rating-icon">⭐</span>
                <span class="rating-value">{{ Number(service.provider_rating || 0).toFixed(1) }}</span>
              </div>
            </div>

            <div class="provider-info">
              <div class="provider-avatar">
                <img
                  :src="avatar(service.provider_avatar_url)"
                  :alt="service.provider_name"
                  class="avatar-image"
                />
              </div>
              <div class="provider-details">
                <h4 class="provider-name">{{ service.provider_name }}</h4>
                <p class="provider-bio">{{ service.provider_bio || $t('experienced_provider') }}</p>
              </div>
            </div>

            <div class="provider-stats">
              <div class="stat-item">
                <span class="stat-icon">✅</span>
                <div class="stat-content">
                  <p class="stat-value">{{ service.provider_completed_services || '50+' }}</p>
                  <p class="stat-label">{{ $t('services_completed') }}</p>
                </div>
              </div>
              <div class="stat-item">
                <span class="stat-icon">💬</span>
                <div class="stat-content">
                  <p class="stat-value">{{ service.provider_response_rate || '95%' }}</p>
                  <p class="stat-label">{{ $t('response_rate') }}</p>
                </div>
              </div>
            </div>
          </div>

          <!-- Tarjeta de acción principal -->
          <div class="action-card">
            <h3 class="action-title">{{ $t('book_service') }}</h3>
            <p class="action-description">{{ $t('book_service_description') }}</p>

            <button
              @click="requestService"
              class="primary-action-button"
              :disabled="loading"
            >
              <span class="button-icon">📅</span>
              <span class="button-text">{{ $t('request_service') }}</span>
              <span v-if="loading" class="button-spinner"></span>
            </button>

            <div class="action-features">
              <div class="feature-item">
                <span class="feature-icon">✅</span>
                <span class="feature-text">{{ $t('instant_confirmation') }}</span>
              </div>
              <div class="feature-item">
                <span class="feature-icon">🔒</span>
                <span class="feature-text">{{ $t('secure_payment') }}</span>
              </div>
              <div class="feature-item">
                <span class="feature-icon">🔄</span>
                <span class="feature-text">{{ $t('easy_cancellation') }}</span>
              </div>
            </div>
          </div>

          <!-- Métodos de pago (si existen) -->
          <div v-if="service.provider?.paymentInfo" class="payment-card">
            <div class="payment-header">
              <h3 class="payment-title">{{ $t('payment_methods') }}</h3>
              <span class="payment-icon">💳</span>
            </div>

            <div class="payment-methods">
              <!-- Transferencia -->
              <div v-if="service.provider.paymentInfo.transferencia" class="method-item">
                <div class="method-icon">🏦</div>
                <div class="method-details">
                  <h4 class="method-name">{{ $t('bank_transfer') }}</h4>
                  <div class="method-info">
                    <p><strong>{{ $t('bank') }}:</strong> {{ service.provider.paymentInfo.transferencia.banco }}</p>
                    <p><strong>{{ $t('account') }}:</strong> {{ service.provider.paymentInfo.transferencia.cuenta }}</p>
                    <p><strong>C.I.:</strong> {{ service.provider.paymentInfo.transferencia.cedula }}</p>
                  </div>
                </div>
              </div>

              <!-- Pago Móvil -->
              <div v-if="service.provider.paymentInfo.pagoMovil" class="method-item">
                <div class="method-icon">📱</div>
                <div class="method-details">
                  <h4 class="method-name">{{ $t('mobile_payment') }}</h4>
                  <div class="method-info">
                    <p><strong>{{ $t('bank') }}:</strong> {{ service.provider.paymentInfo.pagoMovil.banco }}</p>
                    <p><strong>{{ $t('phone') }}:</strong> {{ service.provider.paymentInfo.pagoMovil.telefono }}</p>
                    <p><strong>C.I.:</strong> {{ service.provider.paymentInfo.pagoMovil.cedula }}</p>
                  </div>
                </div>
              </div>

              <!-- Zelle -->
              <div v-if="service.provider.paymentInfo.zelle" class="method-item">
                <div class="method-icon">🇺🇸</div>
                <div class="method-details">
                  <h4 class="method-name">Zelle</h4>
                  <div class="method-info">
                    <p><strong>Email:</strong> {{ service.provider.paymentInfo.zelle.email }}</p>
                  </div>
                </div>
              </div>

              <!-- PayPal -->
              <div v-if="service.provider.paymentInfo.paypal" class="method-item">
                <div class="method-icon">🌐</div>
                <div class="method-details">
                  <h4 class="method-name">PayPal</h4>
                  <div class="method-info">
                    <p><strong>Email:</strong> {{ service.provider.paymentInfo.paypal.email }}</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div> <!-- Cierre de right-column -->
      </div> <!-- Cierre de detail-grid -->

      <!-- Sección de acciones secundarias -->
      <div class="secondary-actions">
        <button class="secondary-button" @click="openChat">
          <span class="button-icon">💬</span>
          <span class="button-text">{{ $t('contact_provider') }}</span>
        </button>
        <button class="secondary-button" @click="showServiceDetails = true">
          <span class="button-icon">📋</span>
          <span class="button-text">{{ $t('view_details') }}</span>
        </button>
        <button class="secondary-button" @click="openLiveTracking">
          <span class="button-icon">🚚</span>
          <span class="button-text">{{ $t('track_order') }}</span>
        </button>
      </div>
    </div> <!-- Cierre de service-detail-container -->

    <!-- MODALES -->
    <!-- 1. Detalle del servicio -->
    <ServiceDetailsModal
      v-if="modalService"
      v-model:is-open="showServiceDetails"
      :request="modalService"
      @on-request-service="goToRequestConfirmation"
      @on-open-change="(v) => (showServiceDetails = v)"
      @on-start-chat="openChat"
    />

    <!-- 2. Confirmar solicitud -->
    <RequestConfirmationModal
      v-if="modalService"
      v-model:is-open="showRequestConfirmation"
      :service-details="modalService"
      @confirm="onConfirmRequest"
      @on-open-change="(v) => (showRequestConfirmation = v)"
    />

    <!-- 3. Contactar proveedor -->
    <ProviderContactModal
      v-if="showProviderContact && modalService"
      ref="providerContactModal"
      v-model:is-open="showProviderContact"
      :provider-name="modalService.provider?.name"
      :request-id="modalService.requestId"
      @on-provider-response="onProviderResponse"
      @cancel="resetFlow"
      @openPayment="openPaymentModal"
      @retry-request="handleRetry"
    />

    <!-- 4. Pagar -->
    <PaymentModal
      v-if="modalService"
      v-model:is-open="showPayment"
      :request="modalService"
      @on-payment-submit="handlePaymentSubmit"
      @on-open-change="(v) => (showPayment = v)"
    />

    <!-- 5. Chat -->
    <ChatRoomModal
      v-if="chatTarget"
      :target="chatTarget"
      @close="chatTarget = null"
    />

    <!-- 6. Seguimiento en vivo -->
    <LiveOrderTracking
      v-if="showLiveTracking && liveOrder"
      :order="liveOrder"
      @close="showLiveTracking = false"
      @open-chat="openChat"
    />
  </div> <!-- Cierre de service-detail-page -->
</template>

<script setup lang="ts">
/* -------------------------------------------------- */
/*  Imports (MANTENIDOS EXACTAMENTE IGUAL)           */
/* -------------------------------------------------- */
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import api from '@/axios'
import { useAuthStore } from '@/stores/authStore'
import { sanitize } from '@/utils/sanitize'
import { formatDate } from '@/utils/formatDate'

/* modales (MANTENIDOS EXACTAMENTE IGUAL) */
import ServiceDetailsModal from '@/components/ServiceDetailsModal.vue'
import RequestConfirmationModal from '@/components/RequestConfirmationModal.vue'
import ProviderContactModal from '@/components/ProviderContactModal.vue'
import PaymentModal from '@/components/PaymentModal.vue'
import ChatRoomModal from '@/components/ChatRoomModal.vue'
import LiveOrderTracking from '@/components/LiveOrderTracking.vue'

/* ---------- infra (MANTENIDO EXACTAMENTE IGUAL) ---------- */
const route     = useRoute()
const router    = useRouter()
const { t }     = useI18n()
const authStore = useAuthStore()

/* ---------- estado (MANTENIDO EXACTAMENTE IGUAL) ---------- */
const service     = ref<Record<string, any>>({})
const modalService = ref<Record<string, any> | null>(null)
const showRequestConfirmation = ref(false)
const showProviderContact = ref(false)
const showPayment = ref(false)
const showLiveTracking = ref(false)
const showServiceDetails = ref(false)
const chatTarget = ref(null)
const liveOrder = ref(null)
const lastSpecDetails = ref('')
const requestId = ref<number | null>(null)
const loading = ref(false)

/* mensaje profesional (MANTENIDO EXACTAMENTE IGUAL) */
const msg     = ref('')
const msgType = ref<'success' | 'error'>('success')
const msgClass = computed(() =>
  msgType.value === 'success'
    ? 'bg-green-100 text-green-800 border-green-200'
    : 'bg-red-100 text-red-800 border-red-200'
)

function setMessage(text: string, type: 'success' | 'error' = 'success') {
  msg.value     = text
  msgType.value = type
  setTimeout(() => (msg.value = ''), 4000)
}

/* ---------- normalización (MANTENIDO EXACTAMENTE IGUAL) ---------- */
function normalizeService(s: any) {
  const p = s.provider && typeof s.provider === 'object' ? s.provider : {}
  let paymentInfo: any = {}
  try {
    const methods = typeof s.payment_methods === 'string' ? JSON.parse(s.payment_methods) : s.payment_methods || []
    methods.forEach((m: any) => {
      if (m.method_type === 'pago_movil') {
        paymentInfo.pagoMovil = { banco: m.bank_name, telefono: m.phone_number, cedula: m.id_number }
      }
      if (m.method_type === 'transferencia') {
        paymentInfo.transferencia = { banco: m.bank_name, cuenta: m.account_number, cedula: m.id_number }
      }
      if (m.method_type === 'paypal') {
        paymentInfo.paypal = { email: m.email }
      }
      if (m.method_type === 'zelle') {
        paymentInfo.zelle = { email: m.email }
      }
    })
  } catch (e) {
    console.warn('Error parseando payment_methods:', e)
  }
  return {
    ...s,
    service_details: s.service_details || '',
    provider: {
      id: p.id || s.provider_id || s.user_id || null,
      name: p.name || s.provider_name || '—',
      avatar_url: p.avatar_url || s.provider_avatar_url || '',
      rating: p.rating ?? s.provider_rating ?? null,
      paymentInfo: Object.keys(paymentInfo).length ? paymentInfo : undefined,
    },
  }
}

/* ---------- carga inicial (MANTENIDO EXACTAMENTE IGUAL) ---------- */
onMounted(async () => {
  try {
    const res = await api.get(`/api/services/${route.params.id}`, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    service.value = normalizeService(res.data?.data || {})
    modalService.value = service.value
  } catch (e: any) {
    console.error('Error al cargar servicio:', e)
    setMessage(e?.response?.data?.error || t('service_not_found'), 'error')
  }
})

/* ---------- solicitud (MANTENIDO EXACTAMENTE IGUAL) ---------- */
async function requestService() {
  loading.value = true
  try {
    const payload = {
      service_id:  service.value.id,
      provider_id: service.value.provider?.id,
      price:       Number(service.value.price || 0),
    }
    console.log('Payload enviado:', payload)
    const res = await api.post('/api/requests/create', payload, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })

    /* ➜ Si el backend devolvió success:false, mostramos su texto */
    if (!res.data?.success) {
      const msg = res.data?.error || t('request_failed')
      setMessage(msg, 'error')
      return   // ← salimos sin entrar al catch
    }

    requestId.value = res.data.requestId
    modalService.value = { ...service.value, requestId: res.data.requestId, status: res.data.status || 'pending' }
    setMessage(t('request_created_confirm'), 'success')
    showRequestConfirmation.value = true

  } catch (e: any) {
    /* ➜ Errores de red o 500: mostramos lo que venga del backend */
    const msg = e?.response?.data?.error || t('error_creating_request')
    setMessage(msg, 'error')
  } finally {
    loading.value = false
  }
}

/* ---------- confirmación → contacto (MANTENIDO EXACTAMENTE IGUAL) ---------- */
function onConfirmRequest(specDetails = '') {
  lastSpecDetails.value = specDetails
  showRequestConfirmation.value = false
  showProviderContact.value = true
}

/* ---------- respuesta del proveedor (MANTENIDO EXACTAMENTE IGUAL) ---------- */
function onProviderResponse(status: string) {
  if (status === 'accepted') {
    openPaymentModal()
  } else {
    setMessage(
      status === 'rejected' ? t('provider_rejected') : t('provider_busy'),
      'error'
    )
  }
  showProviderContact.value = false
}

/* ---------- pago (MANTENIDO EXACTAMENTE IGUAL) ---------- */
function openPaymentModal() {
  if (!modalService.value) return
  showPayment.value = true
}

function handlePaymentSubmit(method: string) {
  setMessage(t('payment_registered', { method }), 'success')
  showPayment.value = false
}

/* ---------- chat (MANTENIDO EXACTAMENTE IGUAL) ---------- */
function openChat(target?: any) {
  chatTarget.value = target || {
    id: service.value.provider?.id,
    name: service.value.provider?.name,
    role: 'provider',
    avatarUrl: service.value.provider?.avatar_url,
  }
}

/* ---------- seguimiento en vivo (MANTENIDO EXACTAMENTE IGUAL) ---------- */
function openLiveTracking() {
  if (!modalService.value) return
  liveOrder.value = {
    id: modalService.value.requestId,
    serviceName: modalService.value.title,
    description: modalService.value.description,
    price: Number(modalService.value.price || 0),
    payment_method: 'efectivo',
    created_at: modalService.value.created_at || new Date().toISOString(),
    address: modalService.value.location || t('location_not_specified'),
    provider: {
      name: modalService.value.provider?.name,
      avatar_url: modalService.value.provider?.avatar_url,
      rating: modalService.value.provider?.rating,
      phone: modalService.value.provider?.phone || null,
      current_address: modalService.value.location || t('location_not_specified'),
    },
    requestId: modalService.value.requestId,
    provider_id: modalService.value.provider?.id,
    user_id: useAuthStore().user?.id,
    status: modalService.value.status || 'pending',
    payment_methods: modalService.value.payment_methods || [],
  }
  showLiveTracking.value = true
}

/* ---------- helpers ---------- */
function avatar(url?: string) {
  return url ? getImageUrl(`/uploads/${url}`) : '/img/default-provider.png'
}

/* ---------- nuevo helper para manejar errores de imagen ---------- */
function handleImageError(event: Event) {
  const img = event.target as HTMLImageElement
  img.src = '/img/default-service.png'
}

/* ---------- nuevo helper para traducciones (si no existen) ---------- */
const defaultTranslations = {
  back: 'Volver',
  service_details: 'Detalles del Servicio',
  no_image_available: 'No hay imagen disponible',
  service_image: 'Imagen del servicio',
  uncategorized: 'Sin categoría',
  service_provider: 'Proveedor del Servicio',
  experienced_provider: 'Proveedor con experiencia',
  services_completed: 'Servicios completados',
  response_rate: 'Tasa de respuesta',
  book_service: 'Reservar Servicio',
  book_service_description: 'Reserva este servicio ahora y coordina los detalles con el proveedor',
  instant_confirmation: 'Confirmación instantánea',
  secure_payment: 'Pago seguro',
  easy_cancellation: 'Cancelación fácil',
  bank: 'Banco',
  account: 'Cuenta',
  phone: 'Teléfono',
  contact_provider: 'Contactar Proveedor',
  view_details: 'Ver Detalles',
  track_order: 'Seguir Pedido'
}
</script>

<style scoped>
/* Estilos principales con el nuevo diseño */
.service-detail-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #f5f7fa 0%, #e4edf5 100%);
  padding: 20px;
}

.message-toast {
  position: fixed;
  top: 20px;
  right: 20px;
  padding: 16px 24px;
  border-radius: 12px;
  font-weight: 600;
  z-index: 1000;
  animation: slideIn 0.3s ease-out;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
  max-width: 400px;
}

.message-toast.success {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
  color: white;
}

.message-toast.error {
  background: linear-gradient(135deg, #ff7675 0%, #d63031 100%);
  color: white;
}

@keyframes slideIn {
  from {
    transform: translateX(100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

.service-detail-container {
  max-width: 1400px;
  margin: 0 auto;
  background: white;
  border-radius: 24px;
  overflow: hidden;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.1);
}

.detail-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 24px 32px;
  display: flex;
  align-items: center;
  gap: 20px;
}

.back-button {
  background: rgba(255, 255, 255, 0.2);
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s;
}

.back-button:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: translateX(-5px);
}

.detail-title {
  color: white;
  font-size: 2rem;
  margin: 0;
  font-weight: 700;
}

.detail-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 32px;
  padding: 32px;
}

@media (max-width: 1024px) {
  .detail-grid {
    grid-template-columns: 1fr;
  }
}

/* Columna izquierda */
.left-column {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.service-image-section {
  position: relative;
  border-radius: 20px;
  overflow: hidden;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
}

.image-container {
  height: 400px;
  background: #f8f9fa;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}

.service-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.5s;
}

.service-image:hover {
  transform: scale(1.05);
}

.image-placeholder {
  text-align: center;
  padding: 40px;
}

.placeholder-icon {
  font-size: 64px;
  margin-bottom: 16px;
  display: block;
  opacity: 0.5;
}

.image-badge {
  position: absolute;
  top: 16px;
  left: 16px;
  background: rgba(0, 0, 0, 0.7);
  color: white;
  padding: 6px 16px;
  border-radius: 20px;
  font-size: 0.9rem;
  font-weight: 600;
}

.basic-info-card {
  background: white;
  padding: 32px;
  border-radius: 20px;
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.08);
  border: 1px solid #f1f2f6;
}

.info-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 20px;
}

.service-title {
  font-size: 1.8rem;
  color: #2d3436;
  margin: 0;
  line-height: 1.3;
  flex: 1;
}

.price-badge {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
  color: white;
  padding: 12px 24px;
  border-radius: 12px;
  font-weight: 700;
  font-size: 1.5rem;
  box-shadow: 0 4px 15px rgba(0, 184, 148, 0.3);
}

.price-amount {
  display: block;
  text-align: center;
}

.service-description {
  color: #636e72;
  font-size: 1.1rem;
  line-height: 1.6;
  margin-bottom: 24px;
}

.info-meta {
  display: flex;
  gap: 20px;
  flex-wrap: wrap;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 8px;
  background: #f8f9fa;
  padding: 10px 16px;
  border-radius: 10px;
}

.meta-icon {
  font-size: 1.2rem;
}

.meta-text {
  color: #2d3436;
  font-weight: 500;
}

/* Columna derecha */
.right-column {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.provider-card, .action-card, .payment-card {
  background: white;
  padding: 28px;
  border-radius: 20px;
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.08);
  border: 1px solid #f1f2f6;
}

.provider-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.provider-title {
  font-size: 1.5rem;
  color: #2d3436;
  margin: 0;
}

.rating-badge {
  background: #fdcb6e;
  color: #2d3436;
  padding: 8px 16px;
  border-radius: 20px;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 6px;
}

.rating-icon {
  font-size: 1.2rem;
}

.rating-value {
  font-size: 1.1rem;
}

.provider-info {
  display: flex;
  align-items: center;
  gap: 20px;
  margin-bottom: 24px;
}

.provider-avatar {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  overflow: hidden;
  border: 4px solid #74b9ff;
}

.avatar-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.provider-details {
  flex: 1;
}

.provider-name {
  font-size: 1.4rem;
  color: #2d3436;
  margin: 0 0 8px 0;
}

.provider-bio {
  color: #636e72;
  font-size: 0.95rem;
  line-height: 1.5;
  margin: 0;
}

.provider-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
  gap: 16px;
  background: #f8f9fa;
  padding: 20px;
  border-radius: 16px;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 12px;
}

.stat-icon {
  font-size: 1.8rem;
  width: 50px;
  height: 50px;
  background: white;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
}

.stat-content {
  display: flex;
  flex-direction: column;
}

.stat-value {
  font-size: 1.3rem;
  font-weight: 700;
  color: #2d3436;
  margin: 0;
}

.stat-label {
  color: #636e72;
  font-size: 0.9rem;
  margin: 0;
}

/* Action Card */
.action-title {
  font-size: 1.5rem;
  color: #2d3436;
  margin: 0 0 12px 0;
}

.action-description {
  color: #636e72;
  font-size: 1rem;
  line-height: 1.5;
  margin-bottom: 24px;
}

.primary-action-button {
  width: 100%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 18px 32px;
  border-radius: 12px;
  font-size: 1.2rem;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  transition: all 0.3s;
  margin-bottom: 24px;
}

.primary-action-button:hover:not(:disabled) {
  transform: translateY(-3px);
  box-shadow: 0 10px 25px rgba(102, 126, 234, 0.4);
}

.primary-action-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.button-icon {
  font-size: 1.5rem;
}

.button-spinner {
  width: 20px;
  height: 20px;
  border: 3px solid rgba(255, 255, 255, 0.3);
  border-top: 3px solid white;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.action-features {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 16px;
  padding: 20px;
  background: #f8f9fa;
  border-radius: 16px;
}

.feature-item {
  display: flex;
  align-items: center;
  gap: 10px;
}

.feature-icon {
  font-size: 1.2rem;
}

.feature-text {
  color: #2d3436;
  font-size: 0.95rem;
  font-weight: 500;
}

/* Payment Card */
.payment-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.payment-title {
  font-size: 1.5rem;
  color: #2d3436;
  margin: 0;
}

.payment-icon {
  font-size: 2rem;
}

.payment-methods {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.method-item {
  display: flex;
  align-items: flex-start;
  gap: 16px;
  padding: 20px;
  background: #f8f9fa;
  border-radius: 16px;
  border: 2px solid transparent;
  transition: all 0.3s;
}

.method-item:hover {
  border-color: #74b9ff;
  transform: translateY(-2px);
}

.method-icon {
  font-size: 2rem;
  width: 60px;
  height: 60px;
  background: white;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
  flex-shrink: 0;
}

.method-details {
  flex: 1;
}

.method-name {
  font-size: 1.2rem;
  color: #2d3436;
  margin: 0 0 12px 0;
}

.method-info {
  color: #636e72;
  font-size: 0.95rem;
  line-height: 1.5;
}

.method-info p {
  margin: 4px 0;
}

/* Secondary Actions */
.secondary-actions {
  display: flex;
  gap: 16px;
  padding: 24px 32px;
  background: #f8f9fa;
  border-top: 1px solid #e0e6ed;
}

.secondary-button {
  flex: 1;
  background: white;
  border: 2px solid #dfe6e9;
  padding: 16px 24px;
  border-radius: 12px;
  font-size: 1rem;
  font-weight: 600;
  color: #2d3436;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  transition: all 0.3s;
}

.secondary-button:hover {
  border-color: #3498db;
  color: #3498db;
  transform: translateY(-2px);
}

/* Responsive Design */
@media (max-width: 768px) {
  .service-detail-page {
    padding: 10px;
  }
  
  .detail-grid {
    padding: 20px;
    gap: 20px;
  }
  
  .image-container {
    height: 300px;
  }
  
  .info-header {
    flex-direction: column;
    gap: 16px;
  }
  
  .provider-info {
    flex-direction: column;
    text-align: center;
  }
  
  .secondary-actions {
    flex-direction: column;
  }
  
  .action-features {
    grid-template-columns: 1fr;
  }
  
  .provider-stats {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 480px) {
  .detail-header {
    padding: 16px 20px;
    flex-direction: column;
    align-items: stretch;
    text-align: center;
  }
  
  .back-button {
    align-self: flex-start;
  }
  
  .detail-title {
    font-size: 1.5rem;
  }
  
  .basic-info-card,
  .provider-card,
  .action-card,
  .payment-card {
    padding: 20px;
  }
}
</style>
