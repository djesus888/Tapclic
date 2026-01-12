<template>
  <div class="p-4">
    <!-- LISTADO DE SERVICIOS (copia exacta del DashboardUser) -->
    <div
      v-if="loading"
      class="text-center py-10"
    >
      {{ $t('loading') }}…
    </div>
    <div
      v-else
      class="grid gap-4 md:grid-cols-2 lg:grid-cols-3"
    >
      <div
        v-for="service in services"
        :key="service.id"
        class="card shadow rounded-lg overflow-hidden cursor-pointer hover:shadow-lg transition"
        @click="openServiceDetails(service)"
      >
        <div class="p-4 flex justify-between items-start bg-gray-100">
          <div>
            <h2 class="font-bold text-lg">
              {{ sanitize(service.title) }}
            </h2>
            <p class="text-sm text-gray-600">
              {{ sanitize(service.description) }}
            </p>
          </div>
          <div class="text-right ml-4">
            <p class="font-semibold">
              {{ formatDate(service.created_at) }}
            </p>
            <span
              :class="service.isAvailable === 1 && service.status === 'active' ? 'text-green-600' : 'text-red-600'"
              class="text-xs font-medium"
            >
              {{ service.isAvailable === 1 && service.status === 'active' ? $t('available') : $t('not_available') }}
            </span>
          </div>
        </div>
        <div class="p-4 flex justify-between items-center bg-white">
          <div class="flex items-center gap-3">
            <img
              :src="service.image_url ? `http://localhost:8000${service.image_url}` : '/img/default-provider.png'"
              :alt="service.provider?.name || 'Ads'"
              class="w-10 h-10 rounded-full object-cover"
            >
            <div>
              <p class="font-semibold">
                {{ sanitize(service.provider?.name || 'Desconocido') }}
              </p>
              <p
                v-if="service.provider?.rating"
                class="text-yellow-500 text-sm"
              >
                ⭐ {{ service.provider.rating }}
              </p>
            </div>
          </div>
          <div class="flex items-center gap-2">
            <span class="text-lg font-bold text-primary">$ {{ service.price }}</span>
          </div>
        </div>
      </div>
    </div>
    <div
      v-if="!loading && services.length === 0"
      class="text-center text-gray-500 py-10"
    >
      {{ $t('no_services_available') }}
    </div>

    <!-- MODALES (iguales a DashboardUser) -->
    <ServiceDetailsModal
      v-if="modalService"
      :is-open="showServiceDetails"
      :request="modalService"
      @on-request-service="goToRequestConfirmation"
      @on-open-change="(val) => (showServiceDetails = val)"
      @on-start-chat="openChat"
    />
    <RequestConfirmationModal
      v-if="modalService"
      :is-open="showRequestConfirmation"
      :service-details="modalService"
      @confirm="onConfirmRequest"
      @on-open-change="(val) => (showRequestConfirmation = val)"
    />
    <ProviderContactModal
      v-if="showProviderContact && modalService"
      ref="providerContactModal"
      :is-open="showProviderContact"
      :provider-name="modalService.provider?.name"
      :request-id="modalService.requestId"
      @on-provider-response="onProviderResponse"
      @cancel="resetFlow"
      @open-payment="openPaymentModal"
      @retry-request="handleRetry"
    />
    <PaymentModal
      v-if="modalService"
      v-model:is-open="showPayment"
      :is-open="showPayment"
      :request="modalService"
      @on-payment-submit="handlePaymentSubmit"
      @on-open-change="(val) => (showPayment = val)"
    />
    <ChatRoomModal
      v-if="chatTarget"
      :target="chatTarget"
      @close="chatTarget = null"
    />
  </div>
</template>

<script>
/* -------  IMPORTS Y LÓGICA IDÉNTICOS A DashboardUser.vue  ------- */
import { formatDate as utilFormatDate } from '@/utils/formatDate'
import api from '@/axios'
import { useAuthStore } from '@/stores/authStore'
import ServiceDetailsModal from '@/components/ServiceDetailsModal.vue'
import RequestConfirmationModal from '@/components/RequestConfirmationModal.vue'
import ProviderContactModal from '@/components/ProviderContactModal.vue'
import PaymentModal from '@/components/PaymentModal.vue'
import ChatRoomModal from '@/components/ChatRoomModal.vue'

export default {
  name: 'ServicesPage',
  components: {
    ServiceDetailsModal,
    RequestConfirmationModal,
    ProviderContactModal,
    PaymentModal,
    ChatRoomModal,
  },
  data() {
    return {
      services: [],
      loading: true,
      modalService: null,
      showServiceDetails: false,
      showRequestConfirmation: false,
      showProviderContact: false,
      showPayment: false,
      chatTarget: null,
      lastSpecDetails: '',
    }
  },
  mounted() {
    this.fetchServices()
  },
  methods: {
    formatDate(date) {
      return utilFormatDate(date)
    },
    sanitize(str) {
      if (!str || typeof str !== 'string') return str
      return str.replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
    },
    resetFlow() {
      this.showServiceDetails = false
      this.showRequestConfirmation = false
      this.showProviderContact = false
      this.showPayment = false
      this.chatTarget = null
      this.modalService = null
      this.lastSpecDetails = ''
      const providerModal = this.$refs.providerContactModal
      if (providerModal && typeof providerModal.stopProcess === 'function') {
        providerModal.stopProcess()
      }
    },
    normalizeService(s) {
      const p = s.provider && typeof s.provider === 'object' ? s.provider : {}
      let paymentInfo = {}
      try {
        const methods = typeof s.payment_methods === 'string' ? JSON.parse(s.payment_methods) : s.payment_methods || []
        methods.forEach((m) => {
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
          id: p.id || s.provider_id || s.providerId || s.user_id || null,
          name: p.name || s.provider_name || '—',
          avatar_url: p.avatar_url || s.provider_avatar_url || '',
          rating: p.rating ?? s.provider_rating ?? null,
          paymentInfo: Object.keys(paymentInfo).length ? paymentInfo : undefined,
        },
      }
    },
    buildPath(resource) {
      const base = api.defaults?.baseURL || ''
      const hasApi = base.endsWith('/api') || base.includes('/api')
      return hasApi ? `/${resource}` : `/api/${resource}`
    },
    async fetchServices() {
      if (this.services.length) return
      this.loading = true
      try {
        const authStore = useAuthStore()
        const res = await api.get(this.buildPath('services'), {
          headers: authStore?.token ? { Authorization: `Bearer ${authStore.token}` } : {},
        })
        const raw = Array.isArray(res.data) ? res.data : Array.isArray(res.data?.services) ? res.data.services : []
        this.services = raw.map((s) => this.normalizeService(s))
      } catch (err) {
        console.error(err)
      } finally {
        this.loading = false
      }
    },
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
        if (!serviceId || !providerId) return
        const payload = {
          service_id: serviceId,
          provider_id: providerId,
          price: Number(this.modalService.price) || 0,
          payment_method: 'efectivo',
          additional_details: specDetails || '',
        }
        const res = await api.post(this.buildPath('requests/create'), payload, {
          headers: authStore?.token ? { Authorization: `Bearer ${authStore.token}` } : {},
        })
        if (!res.data?.success) throw new Error(res.data?.error || 'No se pudo crear la solicitud')
        this.modalService.requestId = res.data.requestId
        this.modalService.status = res.data.status || 'pending'
        this.lastSpecDetails = specDetails
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
    async onProviderResponse(status) {
      this.showProviderContact = false
      if (status === 'accepted' && this.modalService?.requestId) {
        this.openPaymentModal()
      } else {
        const { isConfirmed } = await this.$swal.fire({
          icon: status === 'rejected' ? 'error' : 'warning',
          title: status === 'rejected' ? this.$t('request_rejected') : this.$t('provider_busy'),
          showCancelButton: true,
          confirmButtonText: this.$t('try_again'),
          cancelButtonText: this.$t('cancel'),
        })
        if (isConfirmed) {
          this.showRequestConfirmation = true
          this.$nextTick(() => {
            this.onConfirmRequest(this.lastSpecDetails)
          })
        } else {
          this.resetFlow()
        }
      }
    },
    openPaymentModal() {
      this.showServiceDetails = false
      this.showRequestConfirmation = false
      this.showProviderContact = false
      this.showPayment = true
    },
    handlePaymentSubmit(method) {
      if (!this.modalService?.requestId) return
      this.resetFlow()
      this.$swal.fire({
        icon: 'success',
        title: this.$t('payment_completed'),
        text: `${this.modalService?.title || ''} - ${method}`,
        timer: 2000,
        showConfirmButton: false,
      })
      this.fetchServices()
    },
    handleRetry() {
      this.resetFlow()
      this.$nextTick(() => {
        this.onConfirmRequest(this.lastSpecDetails)
      })
    },
    openChat(target) {
      this.chatTarget = target
    },
  },
}
</script>
