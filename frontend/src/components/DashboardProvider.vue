<template>
  <div
    ref="pullArea"
    class="provider-dashboard"
    @pointerdown="pullStart"
    @pointermove="pullMove"
    @pointerup="pullEnd"
    @pointercancel="pullEnd"
  >
    <!-- HEADER CON ESTADÍSTICAS -->
    <div class="dashboard-header">
      <div class="header-content">
        <h1><span class="dashboard-icon">📊</span> Panel del Proveedor</h1>
        <p>Gestiona tus solicitudes y servicios activos</p>
      </div>

      <!-- ESTADÍSTICAS RÁPIDAS -->
      <div class="header-stats" v-if="!loading.available && !loading.inProgress">
        <div class="stat-card">
          <div class="stat-icon">📋</div>
          <div class="stat-info">
            <h3>{{ availableRequests.length }}</h3>
            <p>Solicitudes Pendientes</p>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-icon">⚡</div>
          <div class="stat-info">
            <h3>{{ inProgressRequests.length }}</h3>
            <p>Activos en progreso</p>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-icon">📅</div>
          <div class="stat-info">
            <h3>{{ historyRequests.length }}</h3>
            <p>En historial</p>
          </div>
        </div>
      </div>
    </div>

    <!-- PULL-TO-REFRESH INDICATOR -->
    <div v-if="pulling" class="pull-refresh-indicator">
      <div class="spinner"></div>
      <p>{{ $t('release_to_refresh') }}</p>
    </div>

    <!-- TABS ESTILIZADAS -->
    <div class="tabs-container">
      <div class="tabs-header">
        <h2>Gestión de Servicios</h2>
        <p class="tabs-subtitle">Selecciona una categoría para gestionar</p>
      </div>
      <nav class="tabs-navigation" role="tablist" :aria-label="$t('tabs')">
        <button
          v-for="tab in tabs"
          :key="`${tab.value}-${$i18n.locale}`"
          role="tab"
          :aria-selected="activeTab === tab.value"
          :tabindex="activeTab === tab.value ? 0 : -1"
          :class="['tab-button', { 'tab-button-active': activeTab === tab.value }]"
          @click="activeTab = tab.value"
        >
          <span class="tab-icon" v-html="getTabIcon(tab.value)"></span>
          <span class="tab-label">{{ tab.label }}</span>
          <span v-if="getTabCount(tab.value) > 0" class="tab-badge">
            {{ getTabCount(tab.value) }}
          </span>
        </button>
      </nav>
    </div>

    <!-- CONTENIDO PRINCIPAL -->
    <div class="dashboard-content">
      <!-- SOLICITUDES PENDIENTES -->
      <div v-if="activeTab === 'available'" class="tab-content">
        <div class="tab-header">
          <h3>📋 Solicitudes Pendientes</h3>
          <p class="tab-description">Acepta nuevas solicitudes de clientes</p>
        </div>

        <SolicitudesDisponibles
          :requests="availableRequests"
          :loading="loading.available"
          @accept="acceptRequest"
          @reject="rejectRequest"
          @busy="busyRequest"
        />

        <div v-if="!loading.available && availableRequests.length === 0" class="empty-state">
          <div class="empty-icon">📭</div>
          <h4>No hay solicitudes disponibles</h4>
          <p>Las nuevas solicitudes aparecerán aquí automáticamente</p>
        </div>
      </div>

      <!-- SOLICITUDES ACTIVAS -->
      <div v-if="activeTab === 'in-progress'" class="tab-content">
        <div class="tab-header">
          <h3>⚡ Solicitudes Activas</h3>
          <p class="tab-description">Gestiona los servicios en progreso</p>
        </div>

        <SolicitudesActivas
          :requests="inProgressRequests"
          :loading="loading.inProgress"
          :dropdown-state="openDropdown"
          @set-status="setStatus"
          @open-chat="openChat"
          @open-proof="openProofModal"
          @toggle-dropdown="toggleDropdown"
        />

        <div v-if="!loading.inProgress && inProgressRequests.length === 0" class="empty-state">
          <div class="empty-icon">🚀</div>
          <h4>No hay servicios activos</h4>
          <p>Acepta solicitudes para comenzar a trabajar</p>
        </div>
      </div>

      <!-- SOPORTE -->
      <div v-if="activeTab === 'support'" class="tab-content">
        <div class="tab-header">
          <h3>🛠️ Centro de Soporte</h3>
          <p class="tab-description">Obtén ayuda y resuelve dudas</p>
        </div>

        <Soporte
          :tickets="tickets"
          :faq-items="faqItems"
          :loading-tickets="loading.support"
          :loading-faq="loading.faq"
          :show-new-ticket="showNewTicket"
          @open-support-chat="openSupportChat"
          @show-new-ticket="showNewTicket = true"
          @reply-ticket="handleReplyTicket"
          @close-ticket="handleCloseTicket"
          @copy-ticket-id="handleCopyTicketId"
          @open-chat-with-ticket="handleChatWithTicket"
        />
      </div>

      <!-- HISTORIAL -->
      <div v-if="activeTab === 'history'" class="tab-content">
        <div class="tab-header">
          <h3>📅 Historial de Servicios</h3>
          <p class="tab-description">Revisa tus servicios completados</p>
        </div>

        <Historial
          :requests="historyRequests"
          :loading="loading.history"
          @open-history="openHistoryModal"
        />

        <div v-if="!loading.history && historyRequests.length === 0" class="empty-state">
          <div class="empty-icon">📖</div>
          <h4>Historial vacío</h4>
          <p>Los servicios completados aparecerán aquí</p>
        </div>
      </div>
    </div>

    <!-- MODALES GLOBALES -->
    <ProofModal
      v-if="showProofModal"
      :request-id="proofModalRequestId"
      @close="onProofModalClose"
    />

    <NewTicketModal
      v-if="showNewTicket"
      :is-open="showNewTicket"
      @close="showNewTicket = false"
      @ticket-created="onTicketCreated"
    />

    <ChatRoomModal
      v-if="chatTarget"
      :target="chatTarget"
      @close="chatTarget = null"
    />

    <!-- TOAST NOTIFICATIONS -->
    <div v-if="pulling" class="toast toast-info">
      ⏳ Soltando para actualizar...
    </div>
  </div>
</template>

<script>
import api from '@/axios';
import { useAuthStore } from '@/stores/authStore';
import { useSocketStore } from '@/stores/socketStore';
import { useNotificationStore } from '@/stores/notificationStore';
import ChatRoomModal from '@/components/ChatRoomModal.vue';
import NewTicketModal from '@/components/NewTicketModal.vue';
import PaymentPill from '@/components/PaymentPill.vue';
import ProofModal from '@/components/ProofModal.vue';
import SolicitudesDisponibles from '@/components/proveedor/SolicitudesDisponibles.vue';
import SolicitudesActivas from '@/components/proveedor/SolicitudesActivas.vue';
import Soporte from '@/components/shared/Soporte.vue';
import Historial from '@/components/shared/Historial.vue';

const ACTIVE_STATUSES = ['accepted', 'in_progress', 'on_the_way', 'arrived', 'finalized'];
const STATUS_FLOW = {
  pending: ['accepted', 'rejected'],
  accepted: ['in_progress', 'cancelled'],
  in_progress: ['on_the_way', 'cancelled'],
  on_the_way: ['arrived', 'cancelled'],
  arrived: ['finalized', 'cancelled'],
  finalized: ['completed'],
  completed: [],
  cancelled: [],
  rejected: []
};
const STATUS_EMOJIS = {
  pending: '⏳',
  accepted: '👍',
  rejected: '👎',
  in_progress: '📦',
  on_the_way: '🚚',
  arrived: '📍',
  finalized: '✅',
  completed: '✅',
  cancelled: '❌'
};
const STATUS_COLORS = {
  completed: 'text-green-600',
  cancelled: 'text-red-600',
  rejected: 'text-orange-600',
  finalized: 'text-green-700'
};

export default {
  name: 'DashboardProvider',
  components: {
    ChatRoomModal,
    NewTicketModal,
    PaymentPill,
    ProofModal,
    SolicitudesDisponibles,
    SolicitudesActivas,
    Soporte,
    Historial
  },
  data() {
    return {
      tabs: [],
      activeTab: 'available',
      availableRequests: [],
      inProgressRequests: [],
      historyRequests: [],
      chatTarget: null,
      providerId: null,
      loading: {
        available: false,
        inProgress: false,
        history: false,
        support: false,
        faq: false
      },
      tickets: [],
      faqItems: [],
      showNewTicket: false,
      openDropdown: null,
      pulling: false,
      pullStartY: 0,
      proofModalRequestId: null,
      showProofModal: false,
      selectedHistory: {},
      historyModal: false,
      _lastPullRefresh: 0,
      _pullRefreshCooldown: 5000,
      _socketHandlers: [],
      _initialized: false,
      _lastFetch: {
        support: 0,
        history: 0,
        faq: 0
      },
      _CACHE_TTL: 5000
    };
  },

  // ✅ AGREGADO: Watcher para activeTab que refresca datos automáticamente
  watch: {
    activeTab(newTab, oldTab) {
      if (newTab !== oldTab) {
        console.log(`🔄 Tab cambiada a: ${newTab}, refrescando datos...`);
        this.$nextTick(() => {
          this.syncRequests();
        });
      }
    }
  },

  methods: {
    getTabIcon(tab) {
      const icons = {
        'available': '📋',
        'in-progress': '⚡',
        'support': '🛠️',
        'history': '📅'
      };
      return icons[tab] || '📄';
    },

    getTabCount(tab) {
      switch(tab) {
        case 'available': return this.availableRequests.length;
        case 'in-progress': return this.inProgressRequests.length;
        case 'history': return this.historyRequests.length;
        case 'support': return this.tickets.length;
        default: return 0;
      }
    },

    async onVisibilityChange() {
      if (!document.hidden && this._initialized) {
        console.log('👀 Provider volvió de background → refrescando');
        this._lastPullRefresh = 0;
        await this.syncRequests();
      }
    },

    setupSocketHandlers(socketStore) {
      this.cleanupSocketHandlers();

      const throttle = (func, limit) => {
        let inThrottle;
        return function(...args) {
          if (!inThrottle) {
            func.apply(this, args);
            inThrottle = true;
            setTimeout(() => inThrottle = false, limit);
          }
        };
      };

      const onRequestUpdated = throttle((payload) => {
        console.log('🔔 Provider: Evento request_updated recibido:', payload);
        
        // ✅ CORREGIDO: Extraer datos tanto de payload directo como de payload.request
        const requestData = payload.request || payload;
        
        if (requestData && requestData.request_id) {
          // Si el estado ya no es pending, quitar de disponibles
          if (requestData.status !== 'pending') {
            this.availableRequests = this.availableRequests.filter(r => r.id !== requestData.request_id);
          }
          
          // Actualizar en activos si corresponde
          if (ACTIVE_STATUSES.includes(requestData.status)) {
            const activeIndex = this.inProgressRequests.findIndex(r => r.id === requestData.request_id);
            const normalizedRequest = this.normalizeRequest({
              id: requestData.request_id,
              status: requestData.status,
              updated_at: requestData.updated_at || new Date().toISOString(),
              ...requestData
            });
            
            if (activeIndex >= 0) {
              this.inProgressRequests.splice(activeIndex, 1, normalizedRequest);
            } else {
              this.inProgressRequests.unshift(normalizedRequest);
            }
          }
          
          // Si está completado/cancelado/rechazado, mover a historial
          if (['completed', 'cancelled', 'rejected'].includes(requestData.status)) {
            this.inProgressRequests = this.inProgressRequests.filter(r => r.id !== requestData.request_id);
            this.updateHistory({
              id: requestData.request_id,
              status: requestData.status,
              ...requestData
            });
          }
        } else {
          // Fallback: refrescar todo
          this.syncRequests();
        }
        
        socketStore.playNotificationSound();
      }, 1000);

      const onPaymentUpdated = throttle((payload) => {
        console.log('🔔 Provider: Evento payment_updated recibido:', payload);
        if (payload.request_id && payload.payment_status) {
          this.handlePaymentUpdate(payload.request_id, payload.payment_status);
        }
      }, 1000);

      const onNewNotification = throttle((notification) => {
        console.log('🔔 Provider: Notificación recibida:', notification);
        // ✅ CORREGIDO: Verificar si la notificación es de tipo request y refrescar
        if (notification.notification_type === 'new_request' || 
            notification.action === 'view_request' ||
            notification.event === 'status_changed') {
          this.syncRequests();
        }
      }, 1000);

      const onNewRequest = throttle((payload) => {
        console.log('🔔 Provider: Evento new_request_created recibido:', JSON.stringify(payload, null, 2));
        try {
          // ✅ CORREGIDO: Evitar duplicados verificando si ya existe
          const existingIndex = this.availableRequests.findIndex(r => r.id === payload.request_id);
          if (existingIndex >= 0) {
            console.log('⚠️ Solicitud ya existe en la lista, omitiendo duplicado');
            return;
          }
          
          const normalizedRequest = this.normalizeRequest({
            id: payload.request_id,
            service_id: payload.service_id,
            service_title: payload.service_title || payload.title || 'Servicio',
            service_description: payload.service_description || payload.description || '',
            service_price: payload.service_price || payload.price || 0,
            service_image_url: payload.service_image_url || payload.image_url || null,
            service_location: payload.service_location || payload.location || 'Ubicación no especificada',
            user_id: payload.user_id,
            user_name: payload.user_name || 'Usuario',
            user_phone: payload.user_phone || null,
            status: payload.status || 'pending',
            payment_status: payload.payment_status || 'pending',
            additional_details: payload.additional_details || '',
            created_at: payload.created_at || new Date().toISOString(),
            ...payload
          });
          
          this.availableRequests = [normalizedRequest, ...this.availableRequests];
          socketStore.playNotificationSound();
          
          // ✅ Toast informativo
          this.$swal?.fire({
            icon: 'info',
            title: 'Nueva Solicitud',
            text: `${normalizedRequest.service_title} - $${normalizedRequest.service_price}`,
            timer: 4000,
            showConfirmButton: false,
            position: 'top-end',
            toast: true
          });
          
          console.log('✅ Solicitud normalizada y añadida. Total disponibles:', this.availableRequests.length);
        } catch (error) {
          console.error('❌ Error en onNewRequest:', error);
        }
      }, 1000);

      socketStore.on('request_updated', onRequestUpdated);
      socketStore.on('payment_updated', onPaymentUpdated);
      socketStore.on('new-notification', onNewNotification);
      socketStore.on('new_request_created', onNewRequest);
      this._socketHandlers = [
        { event: 'request_updated', handler: onRequestUpdated },
        { event: 'payment_updated', handler: onPaymentUpdated },
        { event: 'new-notification', handler: onNewNotification },
        { event: 'new_request_created', handler: onNewRequest }
      ];
    },

    cleanupSocketHandlers() {
      const socketStore = useSocketStore();
      this._socketHandlers.forEach(({ event, handler }) => {
        socketStore.off(event, handler);
      });
      this._socketHandlers = [];
    },

    async initializeTabs() {
      this.tabs = [
        { value: 'available', label: this.$t('requests') },
        { value: 'in-progress', label: this.$t('active') },
        { value: 'support', label: this.$t('support') },
        { value: 'history', label: this.$t('history') }
      ];
    },

    handleProviderRefresh() {
      console.log('🔄 Provider dashboard refresh solicitado');
      this.syncRequests();
    },

    pullStart(e) {
      this.pulling = true;
      this.pullStartY = e.touches ? e.touches[0].clientY : e.clientY;
    },

    pullMove(e) {
      if (!this.pulling) return;
      const y = e.touches ? e.touches[0].clientY : e.clientY;
      const deltaY = y - this.pullStartY;
      if (deltaY > 120) {
        const now = Date.now();
        if (now - this._lastPullRefresh > this._pullRefreshCooldown) {
          this._lastPullRefresh = now;
          this.pulling = false;
          this.syncRequests();
        } else {
          console.log('⏳ Pull-to-refresh en cooldown');
        }
      }
    },

    pullEnd() {
      this.pulling = false;
    },

    updateRequestStatus(requestId, newStatus, updatedAt) {
      const index = this.inProgressRequests.findIndex(r => r.id === requestId);
      if (index === -1) return;
      const updated = [...this.inProgressRequests];
      updated[index] = { ...updated[index], status: newStatus, updated_at: updatedAt };
      this.inProgressRequests = updated;
    },

    handleRequestUpdate(request) {
      if (request.status !== 'pending') {
        this.availableRequests = this.availableRequests.filter(r => r.id !== request.id);
      }
      const activeIndex = this.inProgressRequests.findIndex(r => r.id === request.id);
      if (ACTIVE_STATUSES.includes(request.status)) {
        if (activeIndex >= 0) {
          this.inProgressRequests.splice(activeIndex, 1, { ...request });
        } else {
          this.inProgressRequests.unshift({ ...request });
        }
      } else if (activeIndex >= 0) {
        this.inProgressRequests.splice(activeIndex, 1);
      }
      if (['completed', 'cancelled', 'rejected', 'busy'].includes(request.status)) {
        this.updateHistory(request);
      }
    },

    handlePaymentUpdate(request_id, payment_status) {
      const req = this.inProgressRequests.find(r => r.id === request_id);
      if (req) req.payment_status = payment_status;
    },

    updateHistory(request) {
      const hIdx = this.historyRequests.findIndex(h => h.id === request.id);
      const normalized = this.normalizeHistory(request);
      if (hIdx >= 0) {
        this.historyRequests[hIdx] = normalized;
      } else {
        this.historyRequests.unshift(normalized);
      }
    },

    resetModals() {
      this.chatTarget = null;
      this.showNewTicket = false;
      this.openDropdown = null;
      this.showProofModal = false;
      this.proofModalRequestId = null;
      this.historyModal = false;
      this.selectedHistory = {};
    },

    normalizeHistory(h) {
      const paymentMethods = h.payment_methods || [];
      return {
        ...h,
        payment_methods: (() => {
          try {
            if (Array.isArray(paymentMethods)) return paymentMethods;
            if (typeof paymentMethods === 'string') return JSON.parse(paymentMethods);
            return [];
          } catch {
            return [];
          }
        })()
      };
    },

    normalizeRequest(r) {
      let paymentMethods = [];
      try {
        paymentMethods = typeof r.payment_methods === 'string' ? JSON.parse(r.payment_methods) : (r.payment_methods || []);
      } catch (e) {
        paymentMethods = [];
      }
      const provider = r.provider || {};
      return {
        ...r,
        service_title: r.service_title || r.title || 'Servicio',
        service_description: r.service_description || r.description || '',
        service_price: Number(r.service_price || r.price || 0),
        service_location: r.service_location || r.location || 'Ubicación no especificada',
        service_image_url: r.service_image_url || r.image_url || null,
        service_provider_name: r.service_provider_name || provider.name || r.provider_name || 'Proveedor',
        provider_id: r.provider_id || provider.id || null,
        provider_phone: r.provider_phone || provider.phone || null,
        provider_address: r.provider_address || provider.address || 'No especificada',
        provider_avatar_url: r.provider_avatar_url || provider.avatar_url || null,
        provider_rating: r.provider_rating || provider.rating || null,
        user_id: r.user_id || null,
        user_name: r.user_name || r.user?.name || 'Usuario',
        user_phone: r.user_phone || r.user?.phone || null,
        status: r.status || 'pending',
        payment_status: r.payment_status || 'pending',
        payment_methods: paymentMethods,
        additional_details: r.additional_details || '',
        created_at: r.created_at || new Date().toISOString(),
        updated_at: r.updated_at || r.created_at || new Date().toISOString(),
        image_url: r.image_url ? getImageUrl(r.image_url) : null
      };
    },

    formatDate(d, onlyTime = false) {
      if (!d) return '';
      const locale = this.$i18n.locale.value || 'es';
      const opts = onlyTime ? {
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit'
      } : {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      };
      try {
        return new Date(d).toLocaleString(locale, opts);
      } catch {
        return d;
      }
    },

    formatCurrency(amount) {
      const locale = this.$i18n.locale.value || 'es';
      return new Intl.NumberFormat(locale, {
        style: 'currency',
        currency: 'USD'
      }).format(amount || 0);
    },

    tabClass(tab) {
      return [
        'px-4 py-2 rounded-md font-semibold cursor-pointer text-sm',
        this.activeTab === tab ? 'bg-blue-600 text-white shadow-md' : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
      ];
    },

    statusLabel(status) {
      const key = 'status.' + status;
      const translated = this.$t(key);
      return translated === key ? status : translated;
    },

    statusColor(status) {
      return STATUS_COLORS[status] || 'text-gray-500';
    },

    emoji(status) {
      return STATUS_EMOJIS[status] || '•';
    },

    allowedNext(status) {
      return STATUS_FLOW[status] || [];
    },

    toggleDropdown(id) {
      this.openDropdown = this.openDropdown === id ? null : id;
    },

    openChat(userId, role = 'user') {
      const request = this.inProgressRequests.find(r => r.user_id === userId);
      this.chatTarget = {
        id: userId,
        name: request?.user_name || this.$t('user'),
        role
      };
    },

    openSupportChat() {
      this.chatTarget = {
        id: 1,
        name: this.$t('support'),
        role: 'admin'
      };
    },

    handleReplyTicket(ticket) {
      console.log('Respondiendo al ticket:', ticket.id);
      this.chatTarget = {
        id: ticket.id,
        name: `Ticket #${ticket.id}`,
        role: 'support',
        context: ticket
      };
    },

    async handleCloseTicket(ticket) {
      console.log('Cerrando ticket:', ticket.id);
      try {
        const auth = useAuthStore();
        const response = await api.post('/support/tickets/close', {
          ticket_id: ticket.id
        }, {
          headers: { Authorization: `Bearer ${auth.token}` }
        });

        if (response.data.success) {
          this._lastFetch.support = 0;
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
    },

    handleCopyTicketId(ticket) {
      console.log('ID del ticket copiado:', ticket.id);
    },

    handleChatWithTicket(ticket) {
      console.log('Abriendo chat con ticket:', ticket.id);
      this.chatTarget = {
        id: ticket.id,
        name: `Soporte - Ticket #${ticket.id}`,
        role: 'support',
        context: {
          ticket_id: ticket.id,
          subject: ticket.subject,
          last_message: ticket.last_message
        }
      };
    },

    openHistoryModal(request) {
      this.selectedHistory = request;
      this.historyModal = true;
    },

    closeHistoryModal() {
      this.historyModal = false;
      this.selectedHistory = {};
    },

    openProofModal(requestId) {
      this.proofModalRequestId = requestId;
      this.showProofModal = true;
    },

    onProofModalClose() {
      this.showProofModal = false;
      this.fetchActiveRequests();
    },

    async syncRequests() {
      const authStore = useAuthStore();
      if (!authStore.token) {
        console.warn('⚠️ No hay token, cancelando syncRequests');
        return;
      }
      const fetchMap = {
        'available': () => this.fetchAvailableRequests(),
        'in-progress': () => this.fetchActiveRequests(),
        'history': () => this.fetchHistoryRequests(),
        'support': () => {
          this.fetchTickets();
          this.fetchFaq();
        }
      };
      try {
        await fetchMap[this.activeTab]?.();
      } catch (error) {
        console.error('❌ Error en syncRequests:', error);
      }
    },

    async fetchAvailableRequests() {
      const auth = useAuthStore();
      if (!auth.token) {
        this.loading.available = false;
        return;
      }
      this.loading.available = true;
      try {
        const res = await api.get('/requests/pending', {
          headers: { Authorization: `Bearer ${auth.token}` }
        });
        this.availableRequests = Array.isArray(res.data?.data) ? res.data.data : [];
      } catch (e) {
        console.error(e);
        this.$swal?.fire({
          icon: 'error',
          title: 'Error',
          text: e.message
        });
      } finally {
        this.loading.available = false;
      }
    },

    async fetchActiveRequests() {
      const auth = useAuthStore();
      if (!auth.token) {
        this.loading.inProgress = false;
        return;
      }
      this.loading.inProgress = true;
      try {
        const res = await api.get('/requests/active', {
          headers: { Authorization: `Bearer ${auth.token}` }
        });
        this.inProgressRequests = Array.isArray(res.data?.data) ? res.data.data : [];
      } catch (e) {
        console.error(e);
        this.$swal?.fire({
          icon: 'error',
          title: 'Error',
          text: e.message
        });
      } finally {
        this.loading.inProgress = false;
      }
    },

    async fetchHistoryRequests() {
      const now = Date.now();
      if (now - this._lastFetch.history < this._CACHE_TTL && this.historyRequests.length > 0) return;
      const auth = useAuthStore();
      if (!auth.token) {
        this.loading.history = false;
        return;
      }
      this.loading.history = true;
      try {
        const res = await api.get('/history', {
          headers: { Authorization: `Bearer ${auth.token}` }
        });
        const data = Array.isArray(res.data?.history) ? res.data.history : res.data || [];
        this.historyRequests = data.map(h => this.normalizeHistory(h));
        this._lastFetch.history = now;
      } catch (e) {
        console.error(e);
        this.$swal?.fire({
          icon: 'error',
          title: 'Error',
          text: e.message
        });
      } finally {
        this.loading.history = false;
      }
    },

    async fetchTickets() {
      const now = Date.now();
      if (now - this._lastFetch.support < this._CACHE_TTL && this.tickets.length > 0) return;
      const auth = useAuthStore();
      if (!auth.token) {
        this.loading.support = false;
        return;
      }
      this.loading.support = true;
      try {
        const res = await api.get('/support/tickets', {
          headers: { Authorization: `Bearer ${auth.token}` }
        });

        this.tickets = (Array.isArray(res.data?.tickets) ? res.data.tickets : res.data || []).map(ticket => ({
          ...ticket,
          last_message: ticket.description || ticket.message || 'Sin mensaje',
          description: ticket.description
        }));

        this._lastFetch.support = now;
      } catch (e) {
        console.error(e);
        this.$swal?.fire({
          icon: 'error',
          title: 'Error',
          text: e.message
        });
      } finally {
        this.loading.support = false;
      }
    },

    async fetchFaq() {
      const now = Date.now();
      if (now - this._lastFetch.faq < this._CACHE_TTL && this.faqItems.length > 0) return;
      this.loading.faq = true;
      try {
        const res = await api.get('/support/faq');
        this.faqItems = Array.isArray(res.data?.faq) ? res.data.faq : res.data || [];
        this._lastFetch.faq = now;
      } catch (e) {
        console.error(e);
        this.$swal?.fire({
          icon: 'error',
          title: 'Error',
          text: e.message
        });
      } finally {
        this.loading.faq = false;
      }
    },

    async executeRequestAction(id, endpoint, successMessage = null) {
      try {
        const auth = useAuthStore();
        const res = await api.post(endpoint, { id }, {
          headers: { Authorization: `Bearer ${auth.token}` }
        });
        if (res.data.success) {
          this.availableRequests = this.availableRequests.filter(r => r.id !== id);
          const socketStore = useSocketStore();
          socketStore.playNotificationSound();
          if (successMessage) {
            this.$swal?.fire({
              icon: 'success',
              title: 'Éxito',
              text: successMessage
            });
          }
        }
      } catch (e) {
        console.error(e);
        this.$swal?.fire({
          icon: 'error',
          title: 'Error',
          text: e.message
        });
      }
    },

    async acceptRequest(id) {
      await this.executeRequestAction(id, '/requests/accept', 'Solicitud aceptada');
    },

    async rejectRequest(id) {
      await this.executeRequestAction(id, '/requests/reject', 'Solicitud rechazada');
    },

    async busyRequest(id) {
      await this.executeRequestAction(id, '/requests/busy', 'Estado ocupado establecido');
    },

    async setStatus(requestId, newStatus) {
      try {
        const auth = useAuthStore();
        const res = await api.post(`/requests/${newStatus}`, { id: requestId }, {
          headers: { Authorization: `Bearer ${auth.token}` }
        });
        if (res.data.success) {
          this.updateRequestStatus(requestId, newStatus, res.data.updated_at || new Date().toISOString());
          if (newStatus === 'finalized') {
            const req = this.inProgressRequests.find(r => r.id === requestId);
            if (req) {
              window.dispatchEvent(new CustomEvent('open-rating-modal', {
                detail: {
                  request_id: req.id,
                  from_id: this.providerId,
                  from_role: 'user',
                  targetRole: 'provider',
                  message: 'Quieres calificar a este cliente'
                }
              }));
            }
          }
          this.openDropdown = null;
          const socketStore = useSocketStore();
          socketStore.playNotificationSound();
        } else {
          this.$swal?.fire({
            icon: 'error',
            title: 'Error',
            text: res.data.message
          });
        }
      } catch (e) {
        const errorMsg = e.response?.data?.message || e.message;
        this.$swal?.fire({
          icon: 'error',
          title: 'Error',
          text: errorMsg
        });
      }
    },

    async confirmPayment(requestId) {
      try {
        const auth = useAuthStore();
        const res = await api.post('/requests/confirm-payment', { id: requestId }, {
          headers: { Authorization: `Bearer ${auth.token}` }
        });
        if (res.data.success) {
          const index = this.inProgressRequests.findIndex(r => r.id === requestId);
          if (index !== -1) this.inProgressRequests[index].payment_status = 'paid';
          const socketStore = useSocketStore();
          socketStore.playNotificationSound();
        }
      } catch (e) {
        this.$swal?.fire({
          icon: 'error',
          title: 'Error',
          text: this.$t('error_confirming_payment') || 'Error confirmando pago'
        });
      }
    },

    onTicketCreated() {
      this.showNewTicket = false;
      this._lastFetch.support = 0;
      this.fetchTickets();
    }
  },

  async mounted() {
    const auth = useAuthStore();
    const socketStore = useSocketStore();
    const notificationStore = useNotificationStore();
    try {
      socketStore.init();
      await notificationStore.initialize();
      this.setupSocketHandlers(socketStore);
      this.providerId = auth.user?.id;
      await auth.loadLocale();
      await this.initializeTabs();
      await this.$nextTick();
      if (!socketStore.isConnected) {
        await new Promise(resolve => {
          const checkInterval = setInterval(() => {
            if (socketStore.isConnected) {
              clearInterval(checkInterval);
              resolve();
            }
          }, 100);
        });
      }
      await Promise.allSettled([
        this.fetchAvailableRequests(),
        this.fetchActiveRequests(),
        this.fetchTickets(),
        this.fetchFaq(),
        this.fetchHistoryRequests()
      ]);
      this._initialized = true;
    } catch (error) {
      console.error('❌ Error inicializando DashboardProvider:', error);
      this.$swal?.fire({ icon: 'error', title: 'Error', text: error.message });
    }
    document.addEventListener('visibilitychange', this.onVisibilityChange);
    window.addEventListener('refresh-provider-dashboard', this.handleProviderRefresh);
  },

  beforeUnmount() {
    this.cleanupSocketHandlers();
    this.resetModals();
    document.removeEventListener('visibilitychange', this.onVisibilityChange);
    window.removeEventListener('refresh-provider-dashboard', this.handleProviderRefresh);
  }
};
</script>

<style scoped>
/* ESTILOS PRINCIPALES CON EL NUEVO DISEÑO */
.provider-dashboard {
  max-width: 1400px;
  margin: 0 auto;
  padding: 24px;
  min-height: 100vh;
  background: linear-gradient(135deg, #f5f7fa 0%, #e4edf5 100%);
}

/* HEADER */
.dashboard-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 24px;
  padding: 32px;
  margin-bottom: 32px;
  color: white;
  box-shadow: 0 20px 60px rgba(102, 126, 234, 0.3);
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
  background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 100"><path d="M0,50 Q250,0 500,50 T1000,50 L1000,100 L0,100 Z" fill="rgba(255,255,255,0.1)"/></svg>');
  background-size: cover;
}

.header-content {
  position: relative;
  z-index: 2;
}

.dashboard-icon {
  font-size: 2.5rem;
  margin-right: 12px;
  vertical-align: middle;
  animation: float 3s ease-in-out infinite;
}

@keyframes float {
  0%, 100% { transform: translateY(0px); }
  50% { transform: translateY(-10px); }
}

.header-content h1 {
  font-size: 2.8rem;
  font-weight: 800;
  margin-bottom: 8px;
  display: flex;
  align-items: center;
}

.header-content p {
  font-size: 1.2rem;
  opacity: 0.9;
  margin-bottom: 24px;
}

/* ESTADÍSTICAS DEL HEADER */
.header-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
  margin-top: 24px;
  position: relative;
  z-index: 2;
}

.stat-card {
  background: rgba(255, 255, 255, 0.15);
  backdrop-filter: blur(10px);
  border-radius: 16px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 16px;
  transition: transform 0.3s, background 0.3s;
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.stat-card:hover {
  transform: translateY(-5px);
  background: rgba(255, 255, 255, 0.25);
}

.stat-icon {
  font-size: 2.2rem;
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 12px;
}

.stat-info h3 {
  font-size: 2rem;
  font-weight: 700;
  margin-bottom: 4px;
}

.stat-info p {
  font-size: 0.9rem;
  opacity: 0.9;
  margin: 0;
}

/* PULL TO REFRESH */
.pull-refresh-indicator {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 20px;
  background: rgba(255, 255, 255, 0.9);
  border-radius: 12px;
  margin: 20px auto;
  max-width: 300px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
}

.pull-refresh-indicator .spinner {
  width: 40px;
  height: 40px;
  border: 3px solid #f3f3f3;
  border-top: 3px solid #3498db;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 10px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* TABS */
.tabs-container {
  background: white;
  border-radius: 20px;
  padding: 32px;
  margin-bottom: 32px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
}

.tabs-header {
  margin-bottom: 32px;
}

.tabs-header h2 {
  font-size: 2rem;
  color: #2d3436;
  margin-bottom: 8px;
}

.tabs-subtitle {
  color: #636e72;
  font-size: 1.1rem;
}

.tabs-navigation {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
}

.tab-button {
  background: #f8f9fa;
  border: 2px solid #e9ecef;
  border-radius: 16px;
  padding: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  cursor: pointer;
  transition: all 0.3s;
  position: relative;
}

.tab-button:hover {
  transform: translateY(-3px);
  border-color: #74b9ff;
  box-shadow: 0 10px 20px rgba(116, 185, 255, 0.2);
}

.tab-button-active {
  background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%);
  border-color: #0984e3;
  color: white;
  box-shadow: 0 10px 25px rgba(116, 185, 255, 0.4);
}

.tab-button-active .tab-icon {
  transform: scale(1.2);
}

.tab-icon {
  font-size: 1.8rem;
  transition: transform 0.3s;
}

.tab-label {
  font-weight: 600;
  font-size: 1.1rem;
}

.tab-badge {
  position: absolute;
  top: -8px;
  right: -8px;
  background: #ff7675;
  color: white;
  font-size: 0.8rem;
  font-weight: 700;
  width: 28px;
  height: 28px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.1); }
}

/* CONTENIDO DE TABS */
.dashboard-content {
  background: white;
  border-radius: 20px;
  padding: 32px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
}

.tab-content {
  animation: fadeIn 0.5s ease-out;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

.tab-header {
  margin-bottom: 32px;
  padding-bottom: 20px;
  border-bottom: 2px solid #f1f2f6;
}

.tab-header h3 {
  font-size: 1.8rem;
  color: #2d3436;
  margin-bottom: 8px;
  display: flex;
  align-items: center;
  gap: 10px;
}

.tab-description {
  color: #636e72;
  font-size: 1.1rem;
}

/* ESTADOS VACÍOS */
.empty-state {
  text-align: center;
  padding: 60px 20px;
  background: #f8f9fa;
  border-radius: 20px;
  margin: 40px 0;
}

.empty-icon {
  font-size: 64px;
  margin-bottom: 20px;
  opacity: 0.6;
  animation: bounce 2s infinite;
}

@keyframes bounce {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-15px); }
}

.empty-state h4 {
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

/* TOAST NOTIFICATIONS */
.toast {
  position: fixed;
  bottom: 24px;
  right: 24px;
  padding: 16px 24px;
  border-radius: 12px;
  color: white;
  font-weight: 600;
  z-index: 1000;
  animation: slideIn 0.3s ease-out;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
}

.toast-info {
  background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%);
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

/* RESPONSIVE DESIGN */
@media (max-width: 1200px) {
  .provider-dashboard {
    padding: 16px;
  }

  .tabs-navigation {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 768px) {
  .dashboard-header {
    padding: 24px;
  }

  .header-content h1 {
    font-size: 2rem;
    flex-direction: column;
    align-items: flex-start;
  }

  .dashboard-icon {
    margin-bottom: 10px;
  }

  .header-stats {
    grid-template-columns: 1fr;
  }

  .tabs-navigation {
    grid-template-columns: 1fr;
  }

  .tab-button {
    padding: 16px;
  }

  .tabs-container,
  .dashboard-content {
    padding: 20px;
  }
}

@media (max-width: 480px) {
  .header-content h1 {
    font-size: 1.8rem;
  }

  .tab-header h3 {
    font-size: 1.5rem;
  }

  .tab-button {
    flex-direction: column;
    text-align: center;
    padding: 12px;
  }

  .tab-label {
    font-size: 1rem;
  }
}
</style>
