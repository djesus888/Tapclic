<template>
  <div class="service-detail-page p-2 sm:p-4 max-w-4xl mx-auto">

    <!-- Mensaje profesional (sin alert) -->
    <transition name="fade">
      <div v-if="msg" class="mb-4 px-4 py-2 rounded text-sm border" :class="msgClass">
        {{ msg }}
      </div>
    </transition>

    <!-- IMAGEN -->
    <img
      v-if="service.image_url"
      :src="`http://localhost:8000/uploads/${service.image_url}`"
      alt="Imagen del servicio"
      class="w-full h-48 sm:h-64 object-cover rounded mb-4"
    />

    <!-- TÍTULO + DESCRIPCIÓN -->
    <h1 class="text-xl sm:text-2xl font-bold mb-2">{{ service.title || $t('service') }}</h1>
    <p class="text-gray-700 mb-2">{{ service.description }}</p>
    <p class="text-lg font-semibold text-green-600">${{ Number(service.price || 0).toFixed(2) }}</p>
    <p class="text-sm text-gray-500">📍 {{ service.location || $t('location_not_specified') }}</p>

    <!-- PROVEEDOR -->
    <div class="flex items-center gap-3 mt-4">
      <img
        :src="avatar(service.provider_avatar_url)"
        class="w-12 h-12 rounded-full object-cover"
      />
      <div>
        <p class="font-semibold">{{ service.provider_name }}</p>
        <p class="text-sm text-yellow-500">⭐ {{ Number(service.provider_rating || 0).toFixed(1) }}</p>
      </div>
    </div>

    <!-- BOTÓN PRINCIPAL -->
    <button
      @click="requestService"
      class="mt-6 w-full bg-blue-600 text-white py-3 rounded hover:bg-blue-700 text-sm sm:text-base"
    >
      {{ $t('request_service') }}
    </button>

    <!-- SECCIONES OPCIONALES -->
    <!-- Métodos de pago del proveedor -->
    <div v-if="service.provider?.paymentInfo" class="mt-6 bg-gray-50 rounded p-4">
      <h3 class="font-semibold mb-2">{{ $t('payment_methods') }}</h3>
      <div class="space-y-2 text-sm">
        <div v-if="service.provider.paymentInfo.transferencia">
          <p><strong>{{ $t('bank_transfer') }}:</strong></p>
          <p>Banco: {{ service.provider.paymentInfo.transferencia.banco }}</p>
          <p>Cuenta: {{ service.provider.paymentInfo.transferencia.cuenta }}</p>
          <p>C.I.: {{ service.provider.paymentInfo.transferencia.cedula }}</p>
        </div>
        <div v-if="service.provider.paymentInfo.pagoMovil">
          <p><strong>{{ $t('mobile_payment') }}:</strong></p>
          <p>Banco: {{ service.provider.paymentInfo.pagoMovil.banco }}</p>
          <p>Teléfono: {{ service.provider.paymentInfo.pagoMovil.telefono }}</p>
          <p>C.I.: {{ service.provider.paymentInfo.pagoMovil.cedula }}</p>
        </div>
        <div v-if="service.provider.paymentInfo.zelle">
          <p><strong>Zelle:</strong></p>
          <p>Email: {{ service.provider.paymentInfo.zelle.email }}</p>
        </div>
        <div v-if="service.provider.paymentInfo.paypal">
          <p><strong>PayPal:</strong></p>
          <p>Email: {{ service.provider.paymentInfo.paypal.email }}</p>
        </div>
      </div>
    </div>

    <!-- MODALES (mismos que DashboardUser) -->
    <!-- 1. Detalle del servicio (solo si quieres re-usarlo aquí) -->
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
  </div>
</template>

<script setup lang="ts">
/* -------------------------------------------------- */
/*  Imports                                           */
/* -------------------------------------------------- */
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import api from '@/axios'
import { useAuthStore } from '@/stores/authStore'
import { sanitize } from '@/utils/sanitize'
import { formatDate } from '@/utils/formatDate'

/* modales */
import ServiceDetailsModal from '@/components/ServiceDetailsModal.vue'
import RequestConfirmationModal from '@/components/RequestConfirmationModal.vue'
import ProviderContactModal from '@/components/ProviderContactModal.vue'
import PaymentModal from '@/components/PaymentModal.vue'
import ChatRoomModal from '@/components/ChatRoomModal.vue'
import LiveOrderTracking from '@/components/LiveOrderTracking.vue'

/* ---------- infra ---------- */
const route     = useRoute()
const router    = useRouter()
const { t }     = useI18n()
const authStore = useAuthStore()

/* ---------- estado ---------- */
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

/* mensaje profesional */
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

/* ---------- normalización (igual que DashboardUser) ---------- */
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

/* ---------- carga inicial ---------- */
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

/* ---------- solicitud ---------- */
async function requestService() {
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
  }
}

/* ---------- confirmación → contacto ---------- */
function onConfirmRequest(specDetails = '') {
  lastSpecDetails.value = specDetails
  showRequestConfirmation.value = false
  showProviderContact.value = true
}

/* ---------- respuesta del proveedor ---------- */
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

/* ---------- pago ---------- */
function openPaymentModal() {
  if (!modalService.value) return
  showPayment.value = true
}

function handlePaymentSubmit(method: string) {
  setMessage(t('payment_registered', { method }), 'success')
  showPayment.value = false
}

/* ---------- chat ---------- */
function openChat(target?: any) {
  chatTarget.value = target || {
    id: service.value.provider?.id,
    name: service.value.provider?.name,
    role: 'provider',
    avatarUrl: service.value.provider?.avatar_url,
  }
}

/* ---------- seguimiento en vivo ---------- */
function openLiveTracking() {
  if (!modalService.value) return
  liveOrder.value = {
    id: modalService.value.requestId,
    serviceName: modalService.value.title,
    description: modalService.value.description,
    price: Number(modalService.value.price || 0),
    payment_method: 'efectivo', // o el que tengas
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
  return url ? `http://localhost:8000/uploads/${url}` : '/img/default-provider.png'
}

/* ---------- estilos ---------- */
</script>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
