<template>
  <div class="dashboard-user p-4">
    <!-- Pestañas -->
    <div class="mb-6 border-b border-gray-300 bg-white sticky top-16 z-20" style="padding-bottom: 0.25rem;">
      <nav class="flex space-x-2 justify-center max-w-md mx-auto" aria-label="Tabs">
        <button @click="selectedTab = 'services'" :class="tabClass('services')">{{ $t('services') }}</button>
        <button @click="selectedTab = 'activeRequests'" :class="tabClass('activeRequests')">{{ $t('active') }}</button>
        <button @click="selectedTab = 'support'" :class="tabClass('support')">{{ $t('support') }}</button>
        <button @click="selectedTab = 'history'" :class="tabClass('history')">{{ $t('history') }}</button>
      </nav>
    </div>

    <!-- Contenido pestañas -->
    <div v-if="selectedTab === 'services'">
      <div v-if="loading" class="text-center py-10">{{ $t('loading') }}...</div>
      <div v-else class="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        <div v-for="service in services" :key="service.id" class="card shadow rounded-lg overflow-hidden cursor-pointer hover:shadow-lg transition" @click="openServiceDetails(service)">
          <div class="p-4 flex justify-between items-start bg-gray-100">
            <div>
              <h2 class="font-bold text-lg">{{ service.title }}</h2>
              <p class="text-sm text-gray-600">{{ service.description }}</p>
            </div>
            <div class="text-right ml-4">
              <p class="font-semibold">{{ formatDate(service.created_at) }}</p>
              <span :class="service.status === 'available' ? 'text-green-600' : 'text-red-600'" class="text-xs font-medium">
                {{ service.status === 'available' ? $t('available') : $t('not_available') }}
              </span>
            </div>
          </div>

          <div class="p-4 flex justify-between items-center bg-white">
            <div class="flex items-center gap-3">
              <img :src="service.provider?.avatar_url || '/img/default-provider.png'" :alt="service.provider?.name || 'Desconocido'" class="w-10 h-10 rounded-full object-cover"/>
              <div>
                <p class="font-semibold">{{ service.provider?.name || 'Desconocido' }}</p>
                <p v-if="service.provider?.rating" class="text-yellow-500 text-sm">⭐ {{ service.provider.rating }}</p>
              </div>
            </div>
            <div class="flex items-center gap-2">
              <span class="text-lg font-bold text-primary">$ {{ service.price }}</span>
            </div>
          </div>
        </div>
      </div>
      <div v-if="!loading && services.length === 0" class="text-center text-gray-500 py-10">{{ $t('no_services_available') }}</div>
    </div>

    <div v-if="selectedTab === 'activeRequests'">
      <div v-if="activeRequestsLoading" class="text-center py-10">{{ $t('loading') }}...</div>
      <div v-else>
        <div v-if="activeRequests.length === 0" class="text-center text-gray-500 py-10">{{ $t('no_active_requests') }}</div>
        <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          <div v-for="request in activeRequests" :key="request.id" class="card shadow rounded-lg overflow-hidden cursor-pointer hover:shadow-lg transition">
            <div class="p-4 flex justify-between items-start bg-gray-100">
              <div>
                <h2 class="font-bold text-lg">{{request.service_title || 'Servicio Activo' }}</h2>
                <p class="text-sm text-gray-600">{{ request.service_description || '-' }}</p>
              </div>
              <div class="text-right ml-4">
                <p class="font-semibold">{{ formatDate(request.created_at) }}</p>
                <span :class="request.status === 'accepted' ? 'text-green-600' : 'text-yellow-600'" class="text-xs font-medium">
                  {{ request.status === 'accepted' ? $t('accepted') : $t('pending') }}
                </span>
              </div>
            </div>

            <div class="p-4 flex justify-between items-center bg-white">
              <div class="flex items-center gap-3">
                <img :src="request.service_image || '/img/default-provider.png'" :alt="request.service_name || 'Ads'" class="w-10 h-10 rounded-full object-cover"/>
                <div>
                  <p class="font-semibold">{{ request.service_name || 'Ads' }}</p>
                  <p v-if="request.provider_rating" class="text-yellow-500 text-sm">⭐ {{ request.service_rating }}</p>
                </div>
              </div>
              <div class="flex items-center gap-2">
                <span class="text-lg font-bold text-primary">$ {{ request.service_price || '-' }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-if="selectedTab === 'support'" class="text-center py-10 text-gray-600">{{ $t('support_placeholder') }}</div>
    <div v-if="selectedTab === 'history'" class="text-center py-10 text-gray-600">{{ $t('history_placeholder') }}</div>

    <!-- Modales -->
    <ServiceDetailsModal v-if="modalService" :is-open="showServiceDetails" :request="modalService" @on-request-service="goToRequestConfirmation" @on-open-change="val => showServiceDetails = val" @on-start-chat="openChat"/>
    <ChatRoomModal v-if="chatProviderId" :provider-id="chatProviderId" @close="chatProviderId = null"/>
    <RequestConfirmationModal v-if="modalService" :is-open="showRequestConfirmation" @confirm="onConfirmRequest" @on-open-change="val => showRequestConfirmation = val"/>
    <ProviderContactModal v-if="showProviderContact && modalService" :is-open="showProviderContact" :provider-name="modalService.provider?.name" :request-id="modalService.requestId" @on-provider-response="onProviderResponse" @on-open-change="val => showProviderContact = val" @openPayment="openPaymentModal" ref="providerContactModal"/>
    <PaymentModal v-if="modalService" v-model:isOpen="showPayment" :is-open="showPayment" :request="modalService" @on-payment-submit="handlePaymentSubmit" @on-open-change="val => showPayment = val"/>
  </div>
</template>

<script>
import { formatDate as utilFormatDate } from '@/utils/formatDate'
import api from '@/axio'
import { useAuthStore } from '@/stores/authStore'
import { useSocketStore } from '@/stores/socketStore'
import ServiceDetailsModal from './ServiceDetailsModal.vue'
import RequestConfirmationModal from './RequestConfirmationModal.vue'
import ProviderContactModal from './ProviderContactModal.vue'
import PaymentModal from './PaymentModal.vue'
import ChatRoomModal from './ChatRoomModal.vue'

export default {
  name: 'DashboardUser',
  components: { 
    ServiceDetailsModal, 
    RequestConfirmationModal, 
    ProviderContactModal, 
    PaymentModal, 
    ChatRoomModal 
  },
  data() {
    return {
      services: [],
      loading: true,
      selectedTab: 'services',

      // Estados de modales
      modalService: null,
      showServiceDetails: false,
      showRequestConfirmation: false,
      showProviderContact: false,
      showPayment: false,

      // Solicitudes activas
      activeRequests: [],
      activeRequestsLoading: true,

      // Extras
      notificationSound: new Audio('/sounds/notification.mp3'),
      chatProviderId: null
    }
  },
  methods: {
    formatDate(date) { return utilFormatDate(date) },
    openChat(providerId) { this.chatProviderId = providerId },

    // ✅ Limpieza completa del flujo
    resetFlow() {
      this.showServiceDetails = false
      this.showRequestConfirmation = false
      this.showProviderContact = false
      this.showPayment = false
      this.chatProviderId = null
      this.modalService = null

      // detener timers de ProviderContactModal si existen
      const providerModal = this.$refs.providerContactModal
      if (providerModal && typeof providerModal.stopProcess === 'function') {
        providerModal.stopProcess()
      }
    },

    normalizeService(s) {
      const p = s.provider && typeof s.provider === 'object' ? s.provider : {}
      return {
        ...s,
        provider: {
          id: p.id || s.provider_id || s.providerId || s.user_id || null,
          name: p.name || s.provider_name || '—',
          avatar_url: p.avatar_url || s.provider_avatar_url || '',
          rating: p.rating ?? s.provider_rating ?? null
        }
      }
    },

    buildPath(resource) {
      const base = api.defaults?.baseURL || ''
      const hasApi = base.endsWith('/api') || base.includes('/api')
      return hasApi ? `/${resource}` : `/api/${resource}`
    },

    async fetchServices() {
      this.loading = true
      try {
        const authStore = useAuthStore()
        const res = await api.get(this.buildPath('services'), {
          headers: authStore?.token ? { Authorization: `Bearer ${authStore.token}` } : {}
        })
        const raw = Array.isArray(res.data) ? res.data : Array.isArray(res.data?.services) ? res.data.services : []
        this.services = raw.map(s => this.normalizeService(s))
      } catch (err) { 
        console.error(err) 
      } finally { 
        this.loading = false 
      }
    },

    async fetchActiveRequests() {
      this.activeRequestsLoading = true
      try {
        const authStore = useAuthStore()
        const res = await api.get(this.buildPath('requests/active'), {
          headers: authStore?.token ? { Authorization: `Bearer ${authStore.token}` } : {}
        })
        const requests = Array.isArray(res.data) 
          ? res.data 
          : Array.isArray(res.data?.requests) 
            ? res.data.requests 
            : Array.isArray(res.data?.data) 
              ? res.data.data 
              : []

        if (requests.length > 0 && this.activeRequests.length < requests.length) {
          this.notificationSound.play().catch(() => {})
        }
        this.activeRequests = requests
      } catch (err) { 
        console.error("Error cargando solicitudes activas:", err) 
      } finally { 
        this.activeRequestsLoading = false 
      }
    },

    // ✅ Limpieza antes de abrir un flujo nuevo
    openServiceDetails(service) {
      this.resetFlow()
      this.$nextTick(() => {
        this.modalService = this.normalizeService(service)
        this.showServiceDetails = true
      })
    },

    goToRequestConfirmation() {
      this.showServiceDetails = false
      this.showRequestConfirmation = true
    },

    async onConfirmRequest(specDetails) {
      try {
        const authStore = useAuthStore()
        const serviceId = this.modalService?.id
        const providerId = this.modalService?.provider?.id || this.modalService?.user_id

        if (!serviceId || !providerId) {
          console.error('Faltan IDs de service o provider', { serviceId, providerId })
          this.$swal?.fire({
            icon: 'error',
            title: this.$t('error') || 'Error',
            text: this.$t('service_no_provider') || 'El servicio seleccionado no tiene proveedor asignado'
          })
          return
        }

        const payload = {
          service_id: serviceId,
          provider_id: providerId,
          price: Number(this.modalService.price) || 0,
          payment_method: 'efectivo',
          additional_details: specDetails || ''
        }

        const res = await api.post(this.buildPath('requests/create'), payload, {
          headers: authStore?.token ? { Authorization: `Bearer ${authStore.token}` } : {}
        })

        if (!res.data?.success) throw new Error(res.data?.error || 'No se pudo crear la solicitud')

        // ⚡ Guardamos requestId real y estado
        this.modalService.requestId = res.data.requestId
        this.modalService.status = res.data.status || 'pending'

        this.showRequestConfirmation = false
        this.showProviderContact = true

        this.$nextTick(() => {
          const providerModal = this.$refs.providerContactModal
          if (providerModal) {
            providerModal.status = this.modalService.status
            providerModal.startProcess()
          }
        })
      } catch (err) {
        console.error(err)
        this.$swal?.fire({ icon: 'error', title: this.$t('error') || 'Error', text: err.message })
      }
    },

    // ✅ Ahora limpia si el proveedor rechaza
    onProviderResponse(status) {
      this.showProviderContact = false
      if (status === 'accepted' && this.modalService?.requestId) {
        this.openPaymentModal()
      } else {
        this.$swal.fire({
          icon: status === 'rejected' ? 'error' : 'warning',
          title: status === 'rejected' ? this.$t('request_rejected') : this.$t('provider_busy')
        })
        this.resetFlow()
      }
    },

    // ✅ Garantiza que solo quede abierto el de pago
    openPaymentModal() {
      this.showServiceDetails = false
      this.showRequestConfirmation = false
      this.showProviderContact = false
      this.showPayment = true
    },

    // ✅ Cierra ciclo completo tras pagar
    handlePaymentSubmit(method) {
      if (!this.modalService?.requestId) {
        console.error('No requestId disponible para el pago')
        return
      }

      this.resetFlow()
      this.$swal.fire({
        icon: 'success',
        title: this.$t('payment_completed'),
        text: `${this.modalService?.title || ''} - ${method}`,
        timer: 2000,
        showConfirmButton: false
      })

      this.fetchServices()
      this.fetchActiveRequests()
    },

    tabClass(tab) {
      return [
        'px-4 py-2 rounded-md font-semibold cursor-pointer text-sm',
        this.selectedTab === tab 
          ? 'bg-blue-600 text-white shadow-md' 
          : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
      ]
    }
  },
  computed: {
    notifications() { return useSocketStore().notifications },
    unreadNotifications() { return useSocketStore().unreadCount }
  },
  mounted() {
    this.fetchServices()
    this.fetchActiveRequests()
    useSocketStore().init()
  }
}
</script>
<style scoped>
.dashboard-user { padding-top: 1rem; }
</style>
