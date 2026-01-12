<template>
  <div class="dashboard-user p-4">
    <!-- Pestañas -->
    <div class="mb-6 border-b border-gray-300 bg-white sticky top-16 z-20 pb-1">
      <nav
        class="flex space-x-2 justify-center max-w-md mx-auto"
        role="tablist"
        :aria-label="$t('tabs')"
      >
        <button
          role="tab"
          :aria-selected="selectedTab === 'services'"
          :tabindex="selectedTab === 'services' ? 0 : -1"
          aria-controls="panel-services"
          :class="tabClass('services')"
          @click="selectedTab = 'services'"
        >
          {{ $t('services') }}
        </button>
        <button
          role="tab"
          :aria-selected="selectedTab === 'activeRequests'"
          :tabindex="selectedTab === 'activeRequests' ? 0 : -1"
          aria-controls="panel-activeRequests"
          :class="tabClass('activeRequests')"
          @click="selectedTab = 'activeRequests'"
        >
          {{ $t('active') }}
        </button>
        <button
          role="tab"
          :aria-selected="selectedTab === 'support'"
          :tabindex="selectedTab === 'support' ? 0 : -1"
          aria-controls="panel-support"
          :class="tabClass('support')"
          @click="selectedTab = 'support'"
        >
          {{ $t('support') }}
        </button>
        <button
          role="tab"
          :aria-selected="selectedTab === 'history'"
          :tabindex="selectedTab === 'history' ? 0 : -1"
          aria-controls="panel-history"
          :class="tabClass('history')"
          @click="selectedTab = 'history'"
        >
          {{ $t('history') }}
        </button>
      </nav>
    </div>

    <!-- SERVICES -->
    <div
      v-if="selectedTab === 'services'"
      id="panel-services"
      role="tabpanel"
      aria-labelledby="tab-services"
    >
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
    </div>

    <!-- ACTIVE REQUESTS -->
    <div
      v-if="selectedTab === 'activeRequests'"
      id="panel-activeRequests"
      role="tabpanel"
      aria-labelledby="tab-activeRequests"
    >
      <div
        v-if="activeRequestsLoading"
        class="text-center py-10"
      >
        {{ $t('loading') }}…
      </div>
      <div v-else>
        <div
          v-if="activeRequests.length === 0"
          class="text-center text-gray-500 py-10"
        >
          {{ $t('no_active_requests') }}
        </div>
        <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          <div
            v-for="request in activeRequests"
            :key="request.id"
            class="card shadow rounded-lg overflow-hidden cursor-pointer hover:shadow-lg transition"
            @click="openLiveTracking(request)"
          >
            <div class="p-4 flex justify-between items-start bg-gray-100">
              <div>
                <h2 class="font-bold text-lg">
                  {{ sanitize(request.service_title || 'Servicio Activo') }}
                </h2>
                <p class="text-sm text-gray-600">
                  {{ sanitize(request.service_description || '-') }}
                </p>
              </div>
              <div class="text-right ml-4">
                <p class="font-semibold">
                  {{ formatDate(request.created_at) }}
                </p>
                <span
                  :class="statusColor(request.status)"
                  class="text-xs font-medium"
                >{{ statusLabel(request.status) }}</span>
                <!-- ESTADO DE PAGO -->
                <div class="mt-1">
                  <PaymentPill :status="request.payment_status" />
                </div>
              </div>
            </div>
            <div class="p-4 flex justify-between items-center bg-white">
              <div class="flex items-center gap-3">
                <img
                  :src="request.service_image_url ? `http://localhost:8000${request.service_image_url}` : '/img/default-provider.png'"
                  :alt="request.service_name || 'Ads'"
                  class="w-10 h-10 rounded-full object-cover"
                >
                <div>
                  <p class="font-semibold">
                    {{ sanitize(request.service_provider_name || 'Ads') }}
                  </p>
                  <p
                    v-if="request.provider_rating"
                    class="text-yellow-500 text-sm"
                  >
                    ⭐ {{ request.provider_rating }}
                  </p>
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

    <!-- SUPPORT -->
    <div
      v-if="selectedTab === 'support'"
      id="panel-support"
      role="tabpanel"
      aria-labelledby="tab-support"
      class="p-4"
    >
      <div
        v-if="faqLoading"
        class="text-center py-10"
      >
        {{ $t('loading') }}…
      </div>
      <div
        v-else
        class="mb-8"
      >
        <h2 class="text-xl font-semibold mb-4">
          {{ $t('faq') }}
        </h2>
        <div class="space-y-2">
          <details
            v-for="(item, idx) in faqItems"
            :key="idx"
            class="bg-white rounded-md shadow px-4 py-2"
          >
            <summary class="cursor-pointer font-medium text-left">
              {{ sanitize(item.question) }}
            </summary>
            <p class="text-sm text-gray-600 mt-2">
              {{ sanitize(item.answer) }}
            </p>
          </details>
        </div>
      </div>
      <div class="text-center">
        <button
          class="bg-blue-600 text-white rounded-md px-6 py-2 font-semibold hover:bg-blue-700"
          @click="openSupportChat"
        >
          💬 {{ $t('contact_support') }}
        </button>
      </div>
      <div
        v-if="supportLoading"
        class="text-center py-10 mt-8"
      >
        {{ $t('loading') }}…
      </div>
      <div
        v-else
        class="mt-8"
      >
        <h2 class="text-xl font-semibold mb-4">
          {{ $t('my_tickets') }}
        </h2>
        <div
          v-if="tickets.length === 0"
          class="text-center text-gray-500 py-10"
        >
          {{ $t('no_support_tickets') }}
        </div>
        <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          <div
            v-for="ticket in tickets"
            :key="ticket.id"
            class="card shadow rounded-lg overflow-hidden"
          >
            <div class="p-4 bg-gray-100">
              <h2 class="font-bold text-lg truncate">
                {{ sanitize(ticket.subject) }}
              </h2>
              <p class="text-sm text-gray-600 truncate">
                {{ sanitize(ticket.last_message) }}
              </p>
            </div>
            <div class="p-4 flex justify-between items-center bg-white">
              <span :class="statusColor(ticket.status)">{{ statusLabel(ticket.status) }}</span>
              <span class="text-sm text-gray-500">{{ formatDate(ticket.updated_at) }}</span>
            </div>
          </div>
        </div>
        <button
          v-if="!showNewTicket"
          class="fixed bottom-6 right-6 bg-blue-600 text-white rounded-full w-14 h-14 shadow-lg flex items-center justify-center text-2xl"
          :title="$t('new_ticket')"
          @click="showNewTicket = true"
        >
          +
        </button>
        <NewTicketModal
          v-if="showNewTicket"
          :is-open="showNewTicket"
          @close="showNewTicket = false"
          @ticket-created="onTicketCreated"
        />
      </div>
    </div>

    <!-- HISTORIAL (LISTADO) -->
    <div
      v-if="selectedTab === 'history'"
      id="panel-history"
      role="tabpanel"
      aria-labelledby="tab-history"
      class="p-4 space-y-2"
    >
      <div
        v-if="historyLoading"
        class="text-center py-10"
      >
        {{ $t('loading') }}…
      </div>
      <div
        v-else-if="history.length === 0"
        class="text-center text-gray-500 py-10"
      >
        {{ $t('no_history') }}
      </div>
      <div
        v-for="item in history"
        :key="item.id"
        class="flex items-center justify-between p-3 bg-white rounded shadow hover:bg-gray-50 cursor-pointer"
        @click="openHistoryModal(item)"
      >
        <div class="flex-1">
          <p class="font-semibold text-gray-800">
            {{ sanitize(item.service_title || item.title) }}
          </p>
          <p
            class="text-sm"
            :class="statusColor(item.status)"
          >
            {{ statusLabel(item.status) }}
          </p>
        </div>
        <div class="text-right">
          <p class="font-bold text-green-600">
            ${{ Number(item.service_price || item.price || 0).toFixed(2) }}
          </p>
          <p class="text-xs text-gray-400">
            {{ formatDate(item.completed_at || item.created_at) }}
          </p>
        </div>
      </div>
    </div>

    <!-- MODALES -->
    <ServiceDetailsModal
      v-if="modalService"
      :is-open="showServiceDetails"
      :request="modalService"
      @on-request-service="goToRequestConfirmation"
      @on-open-change="(val) => (showServiceDetails = val)"
      @on-start-chat="openChat"
    />
    <ChatRoomModal
      v-if="chatTarget"
      :target="chatTarget"
      @close="chatTarget = null"
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
    <NewTicketModal
      v-if="showNewTicket"
      :is-open="showNewTicket"
      @close="showNewTicket = false"
      @ticket-created="onTicketCreated"
    />

    <!-- LiveOrderTracking -->
    <LiveOrderTracking
      v-if="showLiveTracking"
      :order="liveOrder"
      @close="showLiveTracking = false"
      @open-chat="openChat"
      @open-payment="openPaymentModal"
    />

    <!-- HISTORY DETAIL MODAL -->
    <div
      v-if="historyModal"
      class="fixed inset-0 z-30 flex items-center justify-center bg-black bg-opacity-50"
      @click.self="closeHistoryModal"
    >
      <div class="bg-white rounded-lg shadow-lg max-w-md w-full mx-4 p-6 space-y-4">
        <h2 class="text-xl font-bold text-gray-800">
          {{ sanitize(selectedHistory.service_title || selectedHistory.title) }}
        </h2>
        <p class="text-sm text-gray-600">
          <strong>{{ $t('provider') }}:</strong> {{ sanitize(selectedHistory.provider_name || selectedHistory.providerName) }}
        </p>
        <p class="text-sm">
          <strong>{{ $t('status') }}:</strong> <span :class="statusColor(selectedHistory.status)">{{ statusLabel(selectedHistory.status) }}</span>
        </p>
        <p class="text-sm">
          <strong>{{ $t('price') }}:</strong> <span class="font-bold text-green-600">${{ Number(selectedHistory.service_price || selectedHistory.price || 0).toFixed(2) }}</span>
        </p>
        <p class="text-sm">
          <strong>{{ $t('date') }}:</strong> {{ formatDate(selectedHistory.completed_at || selectedHistory.created_at) }}
        </p>
        <div class="flex justify-end">
          <button
            class="bg-gray-300 text-gray-800 px-4 py-2 rounded hover:bg-gray-400"
            @click="closeHistoryModal"
          >
            {{ $t('close') }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { formatDate as utilFormatDate } from '@/utils/formatDate'
import api from '@/axios'
import { useNotificationStore } from '@/stores/notificationStore'
import { useAuthStore } from '@/stores/authStore'
import { useSocketStore } from '@/stores/socketStore'
import ServiceDetailsModal from '@/components/ServiceDetailsModal.vue'
import RequestConfirmationModal from '@/components/RequestConfirmationModal.vue'
import ProviderContactModal from '@/components/ProviderContactModal.vue'
import PaymentModal from '@/components/PaymentModal.vue'
import ChatRoomModal from '@/components/ChatRoomModal.vue'
import NewTicketModal from '@/components/NewTicketModal.vue'
import LiveOrderTracking from '@/components/LiveOrderTracking.vue'
import PaymentPill from '@/components/PaymentPill.vue'

export default {
  name: 'DashboardUser',
  components: {
    ServiceDetailsModal,
    RequestConfirmationModal,
    ProviderContactModal,
    PaymentModal,
    ChatRoomModal,
    NewTicketModal,
    LiveOrderTracking,
    PaymentPill
  },

  data() {
    return {
      API_URL: import.meta.env.VITE_API_URL,
      services: [],
      loading: true,
      selectedTab: 'services',
      modalService: null,
      showServiceDetails: false,
      showRequestConfirmation: false,
      showProviderContact: false,
      showPayment: false,
      activeRequests: [],
      activeRequestsLoading: true,
      supportLoading: false,
      tickets: [],
      showNewTicket: false,
      faqLoading: false,
      faqItems: [],
      history: [],
      historyLoading: false,
      chatTarget: null,
      notificationSound: null,
      lastSpecDetails: '',
      showLiveTracking: false,
      liveOrder: null,
      historyModal: false,
      selectedHistory: {},
      lastFetch: {
        services: 0,
        activeRequests: 0,
        tickets: 0,
        history: 0,
        faq: 0
      },
      CACHE_TTL: 5000,
      hasError: false,
      errorMessage: '',
      socketHandlers: []
    }
  },

  computed: {
    notificationStore() {
      return useNotificationStore();
    }
  },

  watch: {
    selectedTab(tab) {
      const hidden = document.hidden;
      if (!hidden) {
        const fetchMap = {
          services: () => { this.lastFetch.services = 0; this.fetchServices(); },
          activeRequests: () => { this.lastFetch.activeRequests = 0; this.fetchActiveRequests(); },
          support: () => { this.lastFetch.tickets = 0; this.fetchTickets(); this.lastFetch.faq = 0; this.fetchFaq(); },
          history: () => { this.lastFetch.history = 0; this.fetchHistory(); }
        };
        fetchMap[tab]?.();
      }
    }
  },

  async mounted() {
    const authStore = useAuthStore();
    const socketStore = useSocketStore();

    this.notificationSound = new Audio('/sounds/notification.mp3');

    this.setupSocketHandlers();

    await Promise.allSettled([
      this.fetchServices(),
      this.fetchActiveRequests(),
      this.fetchTickets(),
      this.fetchHistory(),
      this.fetchFaq()
    ]);

    window.addEventListener('refresh-dashboard', this.handleDashboardRefresh);
  },

  beforeUnmount() {
    const providerModal = this.$refs.providerContactModal
    if (providerModal && typeof providerModal.stopProcess === 'function') {
      providerModal.stopProcess()
    }

    this.cleanupSocketHandlers();
    window.removeEventListener('refresh-dashboard', this.handleDashboardRefresh);
  },

  methods: {
    formatDate(date) {
      return utilFormatDate(date)
    },

    sanitize(str) {
      if (!str || typeof str !== 'string') return ''
      const tempDiv = document.createElement('div')
      tempDiv.textContent = str
      return tempDiv.innerHTML
        .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
        .replace(/on\w+="[^"]*"/g, '')
        .replace(/on\w+='[^']*'/g, '')
        .replace(/javascript:/gi, '')
    },

    openChat(target) {
      this.chatTarget = target
    },

    openSupportChat() {
      this.openChat({
        id: 1,
        name: 'Soporte',
        role: 'admin',
        avatarUrl: '/img/support-avatar.png',
      })
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
      const p = s.provider && typeof s.provider === 'object' ? s.provider : {};
      let paymentInfo = {};

      try {
        const methods = typeof s.payment_methods === 'string' ? JSON.parse(s.payment_methods) : s.payment_methods || [];
        methods.forEach(m => {
          if (m.method_type === 'pago_movil') {
            paymentInfo.pagoMovil = {
              banco: m.bank_name,
              telefono: m.phone_number,
              cedula: m.id_number,
            };
          }
          if (m.method_type === 'transferencia') {
            paymentInfo.transferencia = {
              banco: m.bank_name,
              cuenta: m.account_number,
              cedula: m.id_number,
            };
          }
          if (m.method_type === 'paypal') {
            paymentInfo.paypal = {
              email: m.email,
            };
          }
          if (m.method_type === 'zelle') {
            paymentInfo.zelle = {
              email: m.email,
            };
          }
        });
      } catch (e) {
        console.warn("Error parseando payment_methods:", e);
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
      };
    },

    buildPath(resource) {
      const base = api.defaults?.baseURL || ''
      const hasApi = base.endsWith('/api') || base.includes('/api')
      return hasApi ? `/${resource}` : `/api/${resource}`
    },

    async fetchServices() {
      this.hasError = false;
      const now = Date.now()
      if (now - this.lastFetch.services < this.CACHE_TTL && this.services.length > 0) {
        return
      }

      this.loading = true
      try {
        const authStore = useAuthStore()
        const res = await api.get(this.buildPath('services'), {
          headers: authStore?.token ? { Authorization: `Bearer ${authStore.token}` } : {},
        })
        const raw = Array.isArray(res.data) ? res.data : Array.isArray(res.data?.services) ? res.data.services : []
        this.services = raw.map((s) => this.normalizeService(s))
        this.lastFetch.services = now
      } catch (err) {
        console.error(err)
        this.hasError = true;
        this.errorMessage = err.response?.data?.message || 'Error al cargar servicios';
        this.$swal?.fire({ icon: 'error', title: 'Error', text: this.errorMessage })
      } finally {
        this.loading = false
      }
    },

    async fetchActiveRequests() {
      const now = Date.now()
      if (now - this.lastFetch.activeRequests < this.CACHE_TTL && this.activeRequests.length > 0) {
        return
      }

      this.activeRequestsLoading = true
      try {
        const authStore = useAuthStore()
        const res = await api.get(this.buildPath('requests/active'), {
          headers: authStore?.token ? { Authorization: `Bearer ${authStore.token}` } : {},
        })
        const requests = Array.isArray(res.data) ? res.data : Array.isArray(res.data?.requests) ? res.data.requests : Array.isArray(res.data?.data) ? res.data.data : []
        this.activeRequests = requests.map(r => this.normalizeService(r))
        this.lastFetch.activeRequests = now

        if (requests.length > 0 && this.activeRequests.length < requests.length) {
          this.playNotification()
        }
      } catch (err) {
        console.error('Error cargando solicitudes activas:', err)
      } finally {
        this.activeRequestsLoading = false
      }
    },

    async fetchTickets() {
      const now = Date.now()
      if (now - this.lastFetch.tickets < this.CACHE_TTL && this.tickets.length > 0) {
        return
      }

      this.supportLoading = true
      try {
        const authStore = useAuthStore()
        const res = await api.get(this.buildPath('support/tickets'), {
          headers: authStore?.token ? { Authorization: `Bearer ${authStore.token}` } : {},
        })
        this.tickets = Array.isArray(res.data) ? res.data : res.data?.tickets || []
        this.lastFetch.tickets = now
      } catch (err) {
        console.error('Error cargando tickets:', err)
      } finally {
        this.supportLoading = false
      }
    },

    async fetchFaq() {
      const now = Date.now()
      if (now - this.lastFetch.faq < this.CACHE_TTL && this.faqItems.length > 0) {
        return
      }

      this.faqLoading = true
      try {
        const res = await api.get('/support/faq')
        this.faqItems = Array.isArray(res.data) ? res.data : res.data?.faq || []
        this.lastFetch.faq = now
      } catch (err) {
        console.error('Error cargando FAQ:', err)
      } finally {
        this.faqLoading = false
      }
    },

    async fetchHistory() {
      const now = Date.now()
      if (now - this.lastFetch.history < this.CACHE_TTL && this.history.length > 0) {
        return
      }

      this.historyLoading = true
      try {
        const authStore = useAuthStore()
        if (!authStore?.token) return
        const res = await api.get('/history', {
          headers: { Authorization: `Bearer ${authStore.token}` },
        })
        this.history = Array.isArray(res.data?.history) ? res.data.history : []
        this.lastFetch.history = now
      } catch (err) {
        console.error('Error loading history:', err)
      } finally {
        this.historyLoading = false
      }
    },

    playNotification() {
      if (!this.notificationSound) {
        this.notificationSound = new Audio('/sounds/notification.mp3')
      }
      this.notificationSound.play().catch(() => {})
    },

    openServiceDetails(service) {
      this.resetFlow()
      this.$nextTick(() => {
        this.modalService = this.normalizeService(service)
        this.showServiceDetails = true
      })
    },

    openHistoryModal(item) {
      this.selectedHistory = item
      this.historyModal = true
    },

    closeHistoryModal() {
      this.historyModal = false
      this.selectedHistory = {}
    },

    goToRequestConfirmation() {
      this.showServiceDetails = false
      this.showRequestConfirmation = true
    },

    async onConfirmRequest(payload) {
      try {
        const { details, contractAccepted } = payload

        if (!contractAccepted) {
          this.$swal.fire({
            icon: 'warning',
            title: this.$t('Contrato'),
            text: 'Debes aceptar las condiciones del servicio.'
          })
          return
        }

        const authStore = useAuthStore()
        const serviceId = this.modalService?.id
        const providerId = this.modalService?.provider?.id || this.modalService?.user_id
        if (!serviceId || !providerId) return

        const payloadRequest = {
          service_id: serviceId,
          provider_id: providerId,
          price: Number(this.modalService.price) || 0,
          payment_method: 'efectivo',
          additional_details: details || '',
        }

        const res = await api.post(this.buildPath('requests/create'), payloadRequest, {
          headers: authStore?.token ? { Authorization: `Bearer ${authStore.token}` } : {},
        })

        if (!res.data?.success) throw new Error(res.data?.error || 'No se pudo crear la solicitud')

        this.modalService.requestId = res.data.requestId
        this.modalService.status = res.data.status || 'pending'
        this.lastSpecDetails = details

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
          this.$nextTick(() => { this.onConfirmRequest(this.lastSpecDetails) })
        } else {
          this.resetFlow()
        }
      }
    },

    openPaymentModal(order = null) {
      if (order) {
        this.modalService = this.normalizeService(order)
      }

      if (!this.modalService) {
        console.error("❌ [DashboardUser] modalService es null. No se puede abrir el pago.")
        return
      }

      const current = this.activeRequests.find(r => r.id === this.modalService.requestId)
      if (current) {
        this.modalService = this.normalizeService({ ...this.modalService, ...current })
      }

      this.showServiceDetails = false
      this.showRequestConfirmation = false
      this.showProviderContact = false
      this.showPayment = true
    },

    onTicketCreated() {
      this.showNewTicket = false
      this.fetchTickets()
    },

    handlePaymentSubmit(method) {
      if (!this.modalService?.requestId) return
      this.resetFlow()
      this.$swal.fire({ icon: 'success', title: this.$t('payment_completed'), text: `${this.modalService?.title || ''} - ${method}`, timer: 2000, showConfirmButton: false })

      this.lastFetch.activeRequests = 0
      this.lastFetch.history = 0

      this.fetchActiveRequests()
      this.fetchHistory()
    },

    handleRetry() {
      this.resetFlow()
      this.$nextTick(() => { this.onConfirmRequest(this.lastSpecDetails) })
    },

    statusLabel(status) {
      const map = {
        completado: this.$t('status_completed') || 'Completado',
        fallido: this.$t('status_failed') || 'Fallido',
        inconcluso: this.$t('status_incomplete') || 'Inconcluso',
        cancelado: this.$t('status_cancelled') || 'Cancelado',
      }
      return map[status] || status
    },

    statusColor(status) {
      const map = {
        completado: 'text-green-600',
        fallido: 'text-red-600',
        inconcluso: 'text-yellow-600',
        cancelado: 'text-gray-500',
      }
      return map[status] || 'text-gray-500'
    },

    tabClass(tab) {
      return [
        'px-4 py-2 rounded-md font-semibold cursor-pointer text-sm',
        this.selectedTab === tab ? 'bg-blue-600 text-white shadow-md' : 'bg-gray-100 text-gray-700 hover:bg-gray-200',
      ]
    },

    openLiveTracking(request) {
      this.liveOrder = {
        id: request.id,
        serviceName: request.service_title || 'Servicio',
        description: request.service_description || 'Sin descripción',
        price: Number(request.service_price || 0),
        payment_method: request.payment_method || 'Efectivo',
        created_at: request.created_at || request.date,
        address: request.provider_address || 'No especificada',
        provider: {
          name: request.service_provider_name || 'Proveedor',
          avatar_url: request.provider_avatar_url ? `${this.API_URL}/uploads/avatars/${request.provider_avatar_url}` : '/img/default-provider.png',
          rating: request.provider_rating || null,
          phone: request.provider_phone || null,
          current_address: request.provider_address || 'No especificada',
        },
        requestId: request.id,
        provider_id: request.provider_id || request.service_provider_id,
        user_id: request.user_id,
        status: request.status || 'accepted',
        payment_methods: request.payment_methods || [],
      }
      this.showLiveTracking = true
    },

    async handleRealTimeRequestUpdate(requestId, newStatus) {
      this.lastFetch.activeRequests = 0
      this.lastFetch.history = 0

      await this.fetchActiveRequests()

      if (this.showLiveTracking && this.liveOrder?.id === requestId) {
        this.liveOrder.status = newStatus
      }

      if (['completed', 'cancelled', 'rejected'].includes(newStatus)) {
        await this.fetchHistory()
      }

      this.playNotification()
    },

    handleRealTimePaymentUpdate(requestId, paymentStatus) {
      const req = this.activeRequests.find(r => r.id === requestId)
      if (req) {
        req.payment_status = paymentStatus
      }

      if (this.showPayment && this.modalService?.requestId === requestId) {
        this.modalService.payment_status = paymentStatus
      }
    },

    handleDashboardRefresh() {
      console.log('🔄 DashboardUser refresh solicitado');
      const now = Date.now();
      this.lastFetch.services = now - this.CACHE_TTL;
      this.lastFetch.activeRequests = now - this.CACHE_TTL;
      this.lastFetch.history = now - this.CACHE_TTL;
      const fetchMap = {
        services: () => this.fetchServices(),
        activeRequests: () => this.fetchActiveRequests(),
        support: () => { this.fetchTickets(); this.fetchFaq(); },
        history: () => this.fetchHistory()
      };
      fetchMap[this.selectedTab]?.();
    },

    setupSocketHandlers() {
      const socketStore = useSocketStore();
      
      const requestUpdatedHandler = (data) => {
        console.log('🔔 Evento request_updated recibido:', data);
        if (data.request_id && data.status) {
          this.handleRealTimeRequestUpdate(data.request_id, data.status);
        }
      };

      const paymentUpdatedHandler = (data) => {
        console.log('🔔 Evento payment_updated recibido:', data);
        if (data.request_id && data.payment_status) {
          this.handleRealTimePaymentUpdate(data.request_id, data.payment_status);
        }
      };

      const newNotificationHandler = (notification) => {
        console.log('🔔 Notificación recibida:', notification.event);
        switch(notification.event) {
          case 'status_changed':
          case 'request_updated':
            this.lastFetch.activeRequests = 0;
            this.lastFetch.history = 0;
            this.fetchActiveRequests();
            break;
          case 'payment_updated':
            this.lastFetch.activeRequests = 0;
            this.fetchActiveRequests();
            break;
        }
      };

      socketStore.on('request_updated', requestUpdatedHandler);
      socketStore.on('payment_updated', paymentUpdatedHandler);
      socketStore.on('new-notification', newNotificationHandler);

      this.socketHandlers = [
        { event: 'request_updated', handler: requestUpdatedHandler },
        { event: 'payment_updated', handler: paymentUpdatedHandler },
        { event: 'new-notification', handler: newNotificationHandler }
      ];
    },

    cleanupSocketHandlers() {
      const socketStore = useSocketStore();
      this.socketHandlers.forEach(({ event, handler }) => {
        socketStore.off(event, handler);
      });
      this.socketHandlers = [];
    }
  }
}
</script>

<style scoped>
.dashboard-user {
  padding-top: 1rem;
}
.text-green-600 {
  color: #16a34a;
}
.text-red-600 {
  color: #dc2626;
}
</style>
