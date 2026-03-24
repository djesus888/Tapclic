<template>
  <div class="dashboard-user-container">
    <!-- Header con diseño moderno -->
    <div class="dashboard-header">
      <div class="header-content">
        <h1 class="dashboard-title">
          <span class="dashboard-icon">📊</span> Catalogo
        </h1>
        <p class="dashboard-subtitle">Gestiona tus servicios, solicitudes y soporte</p>
      </div>

      <div class="header-stats" v-if="selectedTab === 'services' && services.length > 0">
        <div class="stat-badge">
          <span class="stat-icon">📋</span>
          <div class="stat-info">
            <span class="stat-number">{{ services.length }}</span>
            <span class="stat-label">Servicios</span>
          </div>
        </div>
      </div>
    </div>

    <!-- TABS MODERNAS -->
    <div class="tabs-container">
      <div class="tabs-wrapper">
        <nav class="tabs-nav" role="tablist" :aria-label="$t('tabs')">
          <button
            role="tab"
            :aria-selected="selectedTab === 'services'"
            :tabindex="selectedTab === 'services' ? 0 : -1"
            aria-controls="panel-services"
            :class="['tab-btn', { 'active': selectedTab === 'services' }]"
            @click="selectedTab = 'services'"
          >
            <span class="tab-icon">🛒</span>
            <span class="tab-text">{{ $t('services') }}</span>
          </button>

          <button
            role="tab"
            :aria-selected="selectedTab === 'activeRequests'"
            :tabindex="selectedTab === 'activeRequests' ? 0 : -1"
            aria-controls="panel-activeRequests"
            :class="['tab-btn', { 'active': selectedTab === 'activeRequests' }]"
            @click="selectedTab = 'activeRequests'"
          >
            <span class="tab-icon">🔄</span>
            <span class="tab-text">{{ $t('active') }}</span>
          </button>

          <button
            role="tab"
            :aria-selected="selectedTab === 'support'"
            :tabindex="selectedTab === 'support' ? 0 : -1"
            aria-controls="panel-support"
            :class="['tab-btn', { 'active': selectedTab === 'support' }]"
            @click="selectedTab = 'support'"
          >
            <span class="tab-icon">👨‍💼</span>
            <span class="tab-text">{{ $t('support') }}</span>
          </button>

          <button
            role="tab"
            :aria-selected="selectedTab === 'history'"
            :tabindex="selectedTab === 'history' ? 0 : -1"
            aria-controls="panel-history"
            :class="['tab-btn', { 'active': selectedTab === 'history' }]"
            @click="selectedTab = 'history'"
          >
            <span class="tab-icon">📅</span>
            <span class="tab-text">{{ $t('history') }}</span>
          </button>
        </nav>
      </div>
    </div>

    <!-- CONTENIDO PRINCIPAL -->
    <div class="main-content">
      <!-- COMPONENTES HIJOS -->
      <div class="tab-content">
        <Servicios
          v-if="selectedTab === 'services'"
          :services="services"
          :loading="loading"
          @open-service-details="openServiceDetails"
          class="content-section"
        />

        <SolicitudesActivas
          v-if="selectedTab === 'activeRequests'"
          :requests="activeRequests"
          :loading="activeRequestsLoading"
          @open-live-tracking="openLiveTracking"
          class="content-section"
        />

        <!-- SOPORTE - AHORA CON TODOS LOS EVENTOS -->
        <Soporte
          v-if="selectedTab === 'support'"
          :tickets="tickets"
          :faq-items="faqItems"
          :loading-tickets="supportLoading"
          :loading-faq="faqLoading"
          :show-new-ticket="showNewTicket"
          @open-support-chat="openSupportChat"
          @show-new-ticket="showNewTicket = true"
          @reply-ticket="handleReplyTicket"
          @close-ticket="handleCloseTicket"
          @copy-ticket-id="handleCopyTicketId"
          @open-chat-with-ticket="handleChatWithTicket"
          class="content-section"
        />

        <Historial
          v-if="selectedTab === 'history'"
          :requests="history"
          :loading="historyLoading"
          @open-history="openHistoryModal"
          class="content-section"
        />
      </div>

      <!-- Loading State Global -->
      <div v-if="globalLoading" class="loading-overlay">
        <div class="loading-spinner"></div>
        <p>Cargando...</p>
      </div>

      <!-- Error State -->
      <div v-if="hasError && selectedTab === 'services'" class="error-state">
        <div class="error-icon">⚠️</div>
        <h3>Error al cargar servicios</h3>
        <p>{{ errorMessage }}</p>
        <button class="retry-btn" @click="fetchServices">
          🔄 Reintentar
        </button>
      </div>
    </div>

    <!-- MODALES GLOBALES (MANTENIENDO TU LÓGICA) -->
    <ServiceDetailsModal
      v-if="modalService"
      :is-open="showServiceDetails"
      :request="modalService"
      @on-request-service="goToRequestConfirmation"
      @on-open-change="(val) => (showServiceDetails = val)"
      @on-start-chat="openChat"
    />

    <ChatRoomModal v-if="chatTarget" :target="chatTarget" @close="chatTarget = null" />

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

    <!-- HISTORY DETAIL MODAL - REDISEÑADO -->
    <div v-if="historyModal" class="modal-overlay" @click.self="closeHistoryModal">
      <div class="modern-modal">
        <div class="modal-header">
          <h2 class="modal-title">{{ sanitize(selectedHistory.service_title || selectedHistory.title) }}</h2>
          <button class="modal-close" @click="closeHistoryModal">✕</button>
        </div>

        <div class="modal-content">
          <div class="info-grid">
            <div class="info-item">
              <span class="info-label">Proveedor:</span>
              <span class="info-value">{{ sanitize(selectedHistory.provider_name || selectedHistory.providerName) }}</span>
            </div>

            <div class="info-item">
              <span class="info-label">Estado:</span>
              <span class="info-badge" :class="statusColor(selectedHistory.status)">
                {{ statusLabel(selectedHistory.status) }}
              </span>
            </div>

            <div class="info-item">
              <span class="info-label">Precio:</span>
              <span class="price-value">${{ Number(selectedHistory.service_price || selectedHistory.price || 0).toFixed(2) }}</span>
            </div>

            <div class="info-item">
              <span class="info-label">Fecha:</span>
              <span class="info-value">{{ formatDate(selectedHistory.completed_at || selectedHistory.created_at) }}</span>
            </div>
          </div>
        </div>

        <div class="modal-footer">
          <button class="btn-secondary" @click="closeHistoryModal">Cerrar</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { formatDate as utilFormatDate } from '@/utils/formatDate';
import api from '@/axios';
import { useNotificationStore } from '@/stores/notificationStore';
import { useAuthStore } from '@/stores/authStore';
import { useSocketStore } from '@/stores/socketStore';
import ServiceDetailsModal from '@/components/ServiceDetailsModal.vue';
import RequestConfirmationModal from '@/components/RequestConfirmationModal.vue';
import ProviderContactModal from '@/components/ProviderContactModal.vue';
import PaymentModal from '@/components/PaymentModal.vue';
import ChatRoomModal from '@/components/ChatRoomModal.vue';
import NewTicketModal from '@/components/NewTicketModal.vue';
import LiveOrderTracking from '@/components/LiveOrderTracking.vue';
import PaymentPill from '@/components/PaymentPill.vue';
import Servicios from '@/components/usuario/Servicios.vue';
import SolicitudesActivas from '@/components/usuario/SolicitudesActivas.vue';
import Soporte from '@/components/shared/Soporte.vue';
import Historial from '@/components/shared/Historial.vue';

export default {
  name: 'DashboardUser',
  components: {
    ServiceDetailsModal, RequestConfirmationModal, ProviderContactModal,
    PaymentModal, ChatRoomModal, NewTicketModal, LiveOrderTracking,
    PaymentPill, Servicios, SolicitudesActivas, Soporte, Historial
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
      lastFetch: { services: 0, activeRequests: 0, tickets: 0, history: 0, faq: 0 },
      CACHE_TTL: 5000,
      hasError: false,
      errorMessage: '',
      socketHandlers: []
    };
  },
  computed: {
    notificationStore() { return useNotificationStore(); },
    globalLoading() {
      const loadingMap = {
        services: this.loading,
        activeRequests: this.activeRequestsLoading,
        support: this.supportLoading || this.faqLoading,
        history: this.historyLoading
      };
      return loadingMap[this.selectedTab] || false;
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
    const providerModal = this.$refs.providerContactModal;
    if (providerModal && typeof providerModal.stopProcess === 'function') {
      providerModal.stopProcess();
    }
    this.cleanupSocketHandlers();
    window.removeEventListener('refresh-dashboard', this.handleDashboardRefresh);
  },
  methods: {
    formatDate(date) { return utilFormatDate(date); },
    sanitize(str) {
      if (!str || typeof str !== 'string') return '';
      const tempDiv = document.createElement('div');
      tempDiv.textContent = str;
      return tempDiv.innerHTML.replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
        .replace(/on\w+="[^"]*"/g, '').replace(/on\w+='[^']*'/g, '').replace(/javascript:/gi, '');
    },

    openChat(target) { this.chatTarget = target; },
    openSupportChat() {
      this.openChat({ id: 1, name: 'Soporte', role: 'admin', avatarUrl: '/img/support-avatar.png' });
    },

    // ===========================================
    // NUEVOS MÉTODOS PARA SOPORTE (AGREGADOS)
    // ===========================================
    handleReplyTicket(ticket) {
      console.log('👤 Usuario responde al ticket:', ticket.id);
      // Abrir el chat de soporte
      this.openSupportChat();
    },

    async handleCloseTicket(ticket) {
      console.log('👤 Usuario cierra ticket:', ticket.id);

      const result = await this.$swal?.fire({
        icon: 'question',
        title: '¿Cerrar ticket?',
        text: '¿Estás seguro de que deseas cerrar este ticket?',
        showCancelButton: true,
        confirmButtonText: 'Sí, cerrar',
        cancelButtonText: 'Cancelar'
      });

      if (result?.isConfirmed) {
        try {
          const authStore = useAuthStore();
          const response = await api.post('/support/tickets/close', {
            ticket_id: ticket.id
          }, {
            headers: authStore?.token ? { Authorization: `Bearer ${authStore.token}` } : {}
          });

          if (response.data?.success) {
            this.lastFetch.tickets = 0;
            await this.fetchTickets();

            this.$swal?.fire({
              icon: 'success',
              title: 'Ticket cerrado',
              text: 'El ticket se ha cerrado correctamente',
              timer: 2000,
              showConfirmButton: false
            });
          }
        } catch (error) {
          console.error('Error cerrando ticket:', error);
          this.$swal?.fire({
            icon: 'error',
            title: 'Error',
            text: error.response?.data?.message || 'Error al cerrar el ticket'
          });
        }
      }
    },

    handleCopyTicketId(ticket) {
      console.log('👤 Usuario copia ID del ticket:', ticket.id);
      // El toast ya se muestra desde el modal
    },

    handleChatWithTicket(ticket) {
      console.log('👤 Usuario abre chat con ticket:', ticket.id);
      this.openSupportChat();
    },
    // ===========================================

    resetFlow() {
      this.showServiceDetails = false;
      this.showRequestConfirmation = false;
      this.showProviderContact = false;
      this.showPayment = false;
      this.chatTarget = null;
      this.modalService = null;
      this.lastSpecDetails = '';
      const providerModal = this.$refs.providerContactModal;
      if (providerModal && typeof providerModal.stopProcess === 'function') {
        providerModal.stopProcess();
      }
    },
    normalizeService(s) {
      const p = s.provider && typeof s.provider === 'object' ? s.provider : {};
      let paymentInfo = {};
      try {
        const methods = typeof s.payment_methods === 'string' ? JSON.parse(s.payment_methods) : s.payment_methods || [];
        methods.forEach(m => {
          if (m.method_type === 'pago_movil') paymentInfo.pagoMovil = { banco: m.bank_name, telefono: m.phone_number, cedula: m.id_number };
          if (m.method_type === 'transferencia') paymentInfo.transferencia = { banco: m.bank_name, cuenta: m.account_number, cedula: m.id_number };
          if (m.method_type === 'paypal') paymentInfo.paypal = { email: m.email };
          if (m.method_type === 'zelle') paymentInfo.zelle = { email: m.email };
        });
      } catch (e) { console.warn("Error parseando payment_methods:", e); }
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
      const base = api.defaults?.baseURL || '';
      const hasApi = base.endsWith('/api') || base.includes('/api');
      return hasApi ? `/${resource}` : `/api/${resource}`;
    },

    async fetchServices() {
      this.hasError = false;
      const now = Date.now();
      if (now - this.lastFetch.services < this.CACHE_TTL && this.services.length > 0) return;
      this.loading = true;
      try {
        const authStore = useAuthStore();
        const res = await api.get(this.buildPath('services'), {
          headers: authStore?.token ? { Authorization: `Bearer ${authStore.token}` } : {},
        });
        const raw = Array.isArray(res.data) ? res.data : Array.isArray(res.data?.services) ? res.data.services : [];
        this.services = raw.map((s) => this.normalizeService(s));
        this.lastFetch.services = now;
      } catch (err) {
        console.error(err);
        this.hasError = true;
        this.errorMessage = err.response?.data?.message || 'Error al cargar servicios';
        this.$swal?.fire({
          icon: 'error',
          title: 'Error',
          text: this.errorMessage
        });
      } finally {
        this.loading = false;
      }
    },

    async fetchActiveRequests() {
      const now = Date.now();
      if (now - this.lastFetch.activeRequests < this.CACHE_TTL && this.activeRequests.length > 0) return;
      this.activeRequestsLoading = true;
      try {
        const authStore = useAuthStore();
        const res = await api.get(this.buildPath('requests/active'), {
          headers: authStore?.token ? { Authorization: `Bearer ${authStore.token}` } : {},
        });
        const requests = Array.isArray(res.data) ? res.data : Array.isArray(res.data?.requests) ? res.data.requests : Array.isArray(res.data?.data) ? res.data.data : [];
        this.activeRequests = requests.map(r => this.normalizeService(r));
        this.lastFetch.activeRequests = now;
        if (requests.length > 0 && this.activeRequests.length < requests.length) {
          this.playNotification();
        }
      } catch (err) {
        console.error('Error cargando solicitudes activas:', err);
        this.$swal?.fire({
          icon: 'error',
          title: 'Error',
          text: err.message,
          timer: 4000
        });
      } finally {
        this.activeRequestsLoading = false;
      }
    },

    async fetchTickets() {
      const now = Date.now();
      if (now - this.lastFetch.tickets < this.CACHE_TTL && this.tickets.length > 0) return;
      this.supportLoading = true;
      try {
        const authStore = useAuthStore();
        const res = await api.get(this.buildPath('support/tickets'), {
          headers: authStore?.token ? { Authorization: `Bearer ${authStore.token}` } : {},
        });

        // NORMALIZAR: Convertir description a last_message
        this.tickets = (Array.isArray(res.data) ? res.data : res.data?.tickets || []).map(ticket => ({
          ...ticket,
          last_message: ticket.description || ticket.message || 'Sin mensaje'
        }));
        this.lastFetch.tickets = now;
      } catch (err) {
        console.error('Error cargando tickets:', err);
        this.$swal?.fire({
          icon: 'error',
          title: 'Error',
          text: err.message,
          timer: 4000
        });
      } finally {
        this.supportLoading = false;
      }
    },

    async fetchFaq() {
      const now = Date.now();
      if (now - this.lastFetch.faq < this.CACHE_TTL && this.faqItems.length > 0) return;
      this.faqLoading = true;
      try {
        const res = await api.get('/support/faq');
        this.faqItems = Array.isArray(res.data) ? res.data : res.data?.faq || [];
        this.lastFetch.faq = now;
      } catch (err) {
        console.error('Error cargando FAQ:', err);
        this.$swal?.fire({
          icon: 'error',
          title: 'Error',
          text: err.message,
          timer: 4000
        });
      } finally {
        this.faqLoading = false;
      }
    },

    async fetchHistory() {
      const now = Date.now();
      if (now - this.lastFetch.history < this.CACHE_TTL && this.history.length > 0) return;
      this.historyLoading = true;
      try {
        const authStore = useAuthStore();
        if (!authStore?.token) return;
        const res = await api.get('/history', {
          headers: { Authorization: `Bearer ${authStore.token}` },
        });
        this.history = Array.isArray(res.data?.history) ? res.data.history : [];
        this.lastFetch.history = now;
      } catch (err) {
        console.error('Error loading history:', err);
        this.$swal?.fire({
          icon: 'error',
          title: 'Error',
          text: err.message,
          timer: 4000
        });
      } finally {
        this.historyLoading = false;
      }
    },

    playNotification() {
      if (!this.notificationSound) {
        this.notificationSound = new Audio('/sounds/notification.mp3');
      }
      this.notificationSound.play().catch(() => {});
    },
    openServiceDetails(service) {
      this.resetFlow();
      this.$nextTick(() => {
        this.modalService = this.normalizeService(service);
        this.showServiceDetails = true;
      });
    },
    openHistoryModal(item) {
      this.selectedHistory = item;
      this.historyModal = true;
    },
    closeHistoryModal() {
      this.historyModal = false;
      this.selectedHistory = {};
    },
    goToRequestConfirmation() {
      this.showServiceDetails = false;
      this.showRequestConfirmation = true;
    },

    async onConfirmRequest(payload) {
      try {
        const { details, contractAccepted } = payload;
        if (!contractAccepted) {
          this.$swal.fire({ icon: 'warning', title: this.$t('Contrato'), text: 'Debes aceptar las condiciones del servicio.' });
          return;
        }
        const authStore = useAuthStore();
        const serviceId = this.modalService?.id;
        const providerId = this.modalService?.provider?.id || this.modalService?.user_id;
        if (!serviceId || !providerId) return;
        const payloadRequest = {
          service_id: serviceId, provider_id: providerId,
          price: Number(this.modalService.price) || 0, payment_method: 'efectivo',
          additional_details: details || '',
        };
        const res = await api.post(this.buildPath('requests/create'), payloadRequest, {
          headers: authStore?.token ? { Authorization: `Bearer ${authStore.token}` } : {},
        });
        if (!res.data?.success) throw new Error(res.data?.error || 'No se pudo crear la solicitud');
        this.modalService.requestId = res.data.requestId;
        this.modalService.status = res.data.status || 'pending';
        this.lastSpecDetails = details;
        this.showRequestConfirmation = false;
        this.showProviderContact = true;
        this.$nextTick(() => {
          const providerModal = this.$refs.providerContactModal;
          if (providerModal) {
            providerModal.status = this.modalService.status;
            providerModal.startProcess();
          }
        });
      } catch (err) {
        console.error(err);
        const status = err.response?.status;
        let title = this.$t('error.default') || 'Error';
        let text = err.message;
        if (status === 409) {
          title = this.$t('error.conflict.title') || 'Solicitud duplicada';
          text = this.$t('error.conflict.active_request') || 'Ya tienes una solicitud activa con este proveedor';
        }
        this.$swal?.fire({ icon: 'error', title, text });
      }
    },

    async onProviderResponse(status) {
      this.showProviderContact = false;
      if (status === 'accepted' && this.modalService?.requestId) {
        this.openPaymentModal();
      } else {
        const { isConfirmed } = await this.$swal.fire({
          icon: status === 'rejected' ? 'error' : 'warning',
          title: status === 'rejected' ? this.$t('request_rejected') : this.$t('provider_busy'),
          showCancelButton: true, confirmButtonText: this.$t('try_again'), cancelButtonText: this.$t('cancel'),
        });
        if (isConfirmed) {
          this.showRequestConfirmation = true;
          this.$nextTick(() => { this.onConfirmRequest(this.lastSpecDetails); });
        } else {
          this.resetFlow();
        }
      }
    },

    openPaymentModal(order = null) {
      if (order) this.modalService = this.normalizeService(order);
      if (!this.modalService) {
        console.error("❌ [DashboardUser] modalService es null. No se puede abrir el pago.");
        return;
      }
      const current = this.activeRequests.find(r => r.id === this.modalService.requestId);
      if (current) this.modalService = this.normalizeService({ ...this.modalService, ...current });
      this.showServiceDetails = false;
      this.showRequestConfirmation = false;
      this.showProviderContact = false;
      this.showPayment = true;
    },

    onTicketCreated() {
      this.showNewTicket = false;
      this.fetchTickets();
    },

    handlePaymentSubmit(method) {
      if (!this.modalService?.requestId) return;
      this.resetFlow();
      this.$swal.fire({ icon: 'success', title: this.$t('payment_completed'), text: `${this.modalService?.title || ''} - ${method}`, timer: 2000, showConfirmButton: false });
      this.lastFetch.activeRequests = 0;
      this.lastFetch.history = 0;
      this.fetchActiveRequests();
      this.fetchHistory();
    },

    handleRetry() {
      this.resetFlow();
      this.$nextTick(() => { this.onConfirmRequest(this.lastSpecDetails); });
    },

    statusLabel(status) {
      const map = { completado: this.$t('status_completed') || 'Completado', fallido: this.$t('status_failed') || 'Fallido', inconcluso: this.$t('status_incomplete') || 'Inconcluso', cancelado: this.$t('status_cancelled') || 'Cancelado' };
      return map[status] || status;
    },

    statusColor(status) {
      const colorMap = {
        completado: 'status-completed',
        fallido: 'status-failed',
        inconcluso: 'status-incomplete',
        cancelado: 'status-cancelled'
      };
      return colorMap[status] || 'status-default';
    },

    openLiveTracking(request) {
      this.liveOrder = {
        id: request.id, serviceName: request.service_title || 'Servicio', description: request.service_description || 'Sin descripción',
        price: Number(request.service_price || 0), payment_method: request.payment_method || 'Efectivo', created_at: request.created_at || request.date,
        address: request.provider_address || 'No especificada', provider: {
          name: request.service_provider_name || 'Proveedor', avatar_url: request.provider_avatar_url ? `${this.API_URL}/uploads/avatars/${request.provider_avatar_url}` : '/img/default-provider.png',
          rating: request.provider_rating || null, phone: request.provider_phone || null, current_address: request.provider_address || 'No especificada',
        }, requestId: request.id, provider_id: request.provider_id || request.service_provider_id, user_id: request.user_id,
        status: request.status || 'accepted', payment_methods: request.payment_methods || [],
      };
      this.showLiveTracking = true;
    },

    async handleRealTimeRequestUpdate(requestId, newStatus) {
      this.lastFetch.activeRequests = 0;
      this.lastFetch.history = 0;
      await this.fetchActiveRequests();
      if (this.showLiveTracking && this.liveOrder?.id === requestId) this.liveOrder.status = newStatus;
      if (['completed', 'cancelled', 'rejected'].includes(newStatus)) await this.fetchHistory();
      this.playNotification();
    },

    handleRealTimePaymentUpdate(requestId, paymentStatus) {
      const req = this.activeRequests.find(r => r.id === requestId);
      if (req) req.payment_status = paymentStatus;
      if (this.showPayment && this.modalService?.requestId === requestId) this.modalService.payment_status = paymentStatus;
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
        const requestData = data.request || data;
        const requestId = requestData.id || requestData.request_id;
        const status = requestData.status;
        if (requestId && status) this.handleRealTimeRequestUpdate(requestId, status);
        else console.warn('⚠️ request_updated: No se encontró ID o status en el payload', data);
      };
      const paymentUpdatedHandler = (data) => {
        console.log('🔔 Evento payment_updated recibido:', data);
        if (data.request_id && data.payment_status) this.handleRealTimePaymentUpdate(data.request_id, data.payment_status);
      };
      const newNotificationHandler = (notification) => {
        console.log('🔔 Notificación recibida:', notification.event);
        switch(notification.event) {
          case 'status_changed': case 'request_updated':
            this.lastFetch.activeRequests = 0; this.lastFetch.history = 0; this.fetchActiveRequests(); break;
          case 'payment_updated':
            this.lastFetch.activeRequests = 0; this.fetchActiveRequests(); break;
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
      this.socketHandlers.forEach(({ event, handler }) => { socketStore.off(event, handler); });
      this.socketHandlers = [];
    }
  }
};
</script>

<style scoped>
.dashboard-user-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #f5f7fa 0%, #e4edf5 100%);
}

/* Header */
.dashboard-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 40px 24px 24px;
  color: white;
  border-radius: 0 0 30px 30px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
  position: relative;
  overflow: hidden;
}

.dashboard-header::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: radial-gradient(circle at top right, rgba(255,255,255,0.1) 0%, transparent 70%);
}

.header-content {
  position: relative;
  z-index: 1;
}

.dashboard-title {
  font-size: 2.5rem;
  font-weight: 800;
  margin-bottom: 8px;
  display: flex;
  align-items: center;
  gap: 15px;
}

.dashboard-icon {
  font-size: 2.8rem;
  animation: bounce 2s infinite;
}

@keyframes bounce {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-10px); }
}

.dashboard-subtitle {
  font-size: 1.1rem;
  opacity: 0.9;
  max-width: 600px;
}

.header-stats {
  position: absolute;
  right: 24px;
  top: 40px;
  z-index: 1;
}

.stat-badge {
  background: rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(10px);
  padding: 12px 20px;
  border-radius: 15px;
  display: flex;
  align-items: center;
  gap: 12px;
  border: 1px solid rgba(255, 255, 255, 0.3);
}

.stat-icon {
  font-size: 1.8rem;
}

.stat-info {
  display: flex;
  flex-direction: column;
}

.stat-number {
  font-size: 1.8rem;
  font-weight: 700;
}

.stat-label {
  font-size: 0.9rem;
  opacity: 0.8;
}

/* Tabs */
.tabs-container {
  position: sticky;
  top: 80px;
  z-index: 20;
  background: white;
  border-radius: 20px;
  margin: -20px 24px 24px;
  padding: 8px;
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
}

.tabs-wrapper {
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
  scrollbar-width: none;
}

.tabs-wrapper::-webkit-scrollbar {
  display: none;
}

.tabs-nav {
  display: flex;
  gap: 8px;
  min-width: max-content;
  padding: 4px;
}

.tab-btn {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 14px 24px;
  border: none;
  border-radius: 15px;
  background: #f8f9fa;
  color: #636e72;
  font-weight: 600;
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.3s ease;
  white-space: nowrap;
  min-width: 140px;
  justify-content: center;
}

.tab-btn:hover:not(.active) {
  background: #e9ecef;
  transform: translateY(-2px);
}

.tab-btn.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.3);
  transform: translateY(-2px);
}

.tab-icon {
  font-size: 1.2rem;
}

.tab-text {
  font-size: 0.95rem;
}

/* Main Content */
.main-content {
  padding: 0 24px 40px;
}

.content-section {
  background: white;
  border-radius: 25px;
  padding: 30px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
  margin-top: 20px;
  border: 1px solid #f1f2f6;
}

/* Loading State */
.loading-overlay {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 400px;
  background: white;
  border-radius: 25px;
  margin-top: 20px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
}

.loading-spinner {
  width: 60px;
  height: 60px;
  border: 4px solid #f3f3f3;
  border-top: 4px solid #667eea;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 20px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* Error State */
.error-state {
  background: white;
  border-radius: 25px;
  padding: 60px 40px;
  text-align: center;
  margin-top: 20px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
  border: 2px solid #ffebee;
}

.error-icon {
  font-size: 4rem;
  margin-bottom: 20px;
}

.error-state h3 {
  color: #d32f2f;
  margin-bottom: 12px;
  font-size: 1.8rem;
}

.error-state p {
  color: #666;
  margin-bottom: 30px;
  max-width: 400px;
  margin-left: auto;
  margin-right: auto;
}

.retry-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 14px 32px;
  border-radius: 12px;
  font-weight: 600;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 10px;
  transition: all 0.3s;
}

.retry-btn:hover {
  transform: translateY(-3px);
  box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
}

/* History Modal */
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

.modern-modal {
  background: white;
  border-radius: 25px;
  width: 90%;
  max-width: 500px;
  overflow: hidden;
  box-shadow: 0 25px 50px rgba(0, 0, 0, 0.25);
  animation: modalSlideIn 0.3s ease-out;
}

@keyframes modalSlideIn {
  from {
    opacity: 0;
    transform: translateY(-30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.modal-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 24px;
  color: white;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-title {
  font-size: 1.5rem;
  font-weight: 700;
  margin: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  max-width: 80%;
}

.modal-close {
  background: rgba(255, 255, 255, 0.2);
  border: none;
  color: white;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  cursor: pointer;
  font-size: 18px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s;
}

.modal-close:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: rotate(90deg);
}

.modal-content {
  padding: 30px;
}

.info-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 20px;
}

.info-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-bottom: 15px;
  border-bottom: 1px solid #f0f0f0;
}

.info-item:last-child {
  border-bottom: none;
}

.info-label {
  font-weight: 600;
  color: #555;
  font-size: 0.95rem;
}

.info-value {
  color: #333;
  font-weight: 500;
  text-align: right;
  max-width: 60%;
  word-break: break-word;
}

.info-badge {
  padding: 6px 16px;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 600;
}

.status-completed {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
  color: white;
}

.status-failed {
  background: linear-gradient(135deg, #ff7675 0%, #d63031 100%);
  color: white;
}

.status-incomplete {
  background: linear-gradient(135deg, #fdcb6e 0%, #e17055 100%);
  color: white;
}

.status-cancelled {
  background: linear-gradient(135deg, #636e72 0%, #2d3436 100%);
  color: white;
}

.status-default {
  background: #dfe6e9;
  color: #2d3436;
}

.price-value {
  font-size: 1.5rem;
  font-weight: 700;
  color: #00b894;
}

.modal-footer {
  padding: 0 30px 30px;
  display: flex;
  justify-content: flex-end;
}

.btn-secondary {
  background: #dfe6e9;
  color: #2d3436;
  border: none;
  padding: 12px 32px;
  border-radius: 10px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-secondary:hover {
  background: #b2bec3;
  transform: translateY(-2px);
}

/* Responsive Design */
@media (max-width: 1024px) {
  .dashboard-title {
    font-size: 2.2rem;
  }

  .tab-btn {
    min-width: 120px;
    padding: 12px 20px;
  }
}

@media (max-width: 768px) {
  .dashboard-header {
    padding: 30px 20px 20px;
    border-radius: 0 0 25px 25px;
  }

  .dashboard-title {
    font-size: 2rem;
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }

  .header-stats {
    position: relative;
    right: auto;
    top: auto;
    margin-top: 20px;
    width: fit-content;
  }

  .tabs-container {
    margin: -15px 20px 20px;
  }

  .main-content {
    padding: 0 20px 30px;
  }

  .content-section {
    padding: 20px;
  }

  .tab-btn {
    min-width: 100px;
    padding: 10px 16px;
    font-size: 0.9rem;
  }

  .tab-icon {
    font-size: 1rem;
  }
}

@media (max-width: 480px) {
  .dashboard-header {
    padding: 25px 16px 16px;
  }

  .dashboard-title {
    font-size: 1.8rem;
  }

  .dashboard-icon {
    font-size: 2.2rem;
  }

  .tabs-container {
    margin: -12px 16px 16px;
  }

  .tabs-nav {
    gap: 4px;
  }

  .tab-btn {
    min-width: auto;
    padding: 10px 14px;
    font-size: 0.85rem;
  }

  .tab-text {
    display: none;
  }

  .tab-icon {
    font-size: 1.2rem;
  }

  .modern-modal {
    width: 95%;
    margin: 0 10px;
  }

  .modal-content {
    padding: 20px;
  }

  .info-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }

  .info-value {
    text-align: left;
    max-width: 100%;
  }
}
</style>
