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

      <div v-if="!loading.available && !loading.inProgress" class="header-stats">
        <div class="stat-card">
          <div class="stat-icon">📋</div>
          <div class="stat-info"><h3>{{ availableRequests.length }}</h3><p>Solicitudes Pendientes</p></div>
        </div>
        <div class="stat-card">
          <div class="stat-icon">⚡</div>
          <div class="stat-info"><h3>{{ inProgressRequests.length }}</h3><p>Activos en progreso</p></div>
        </div>
        <div class="stat-card">
          <div class="stat-icon">📅</div>
          <div class="stat-info"><h3>{{ historyRequests.length }}</h3><p>En historial</p></div>
        </div>
      </div>
    </div>

    <div v-if="pulling" class="pull-refresh-indicator">
      <div class="spinner" /><p>{{ $t('release_to_refresh') }}</p>
    </div>

    <!-- TABS -->
    <div class="tabs-container">
      <div class="tabs-header"><h2>Gestión de Servicios</h2><p class="tabs-subtitle">Selecciona una categoría para gestionar</p></div>
      <nav class="tabs-navigation" role="tablist">
        <button v-for="tab in tabs" :key="`${tab.value}-${$i18n.locale}`" role="tab" :aria-selected="activeTab === tab.value"
          :class="['tab-button', { 'tab-button-active': activeTab === tab.value }]" @click="activeTab = tab.value">
          <span class="tab-icon" v-html="getTabIcon(tab.value)" />
          <span class="tab-label">{{ tab.label }}</span>
          <span v-if="getTabCount(tab.value) > 0" class="tab-badge">{{ getTabCount(tab.value) }}</span>
        </button>
      </nav>
    </div>

    <!-- CONTENIDO PRINCIPAL -->
    <div class="dashboard-content">
      <div v-if="activeTab === 'available'" class="tab-content">
        <div class="tab-header"><h3>📋 Solicitudes Pendientes</h3><p class="tab-description">Acepta nuevas solicitudes de clientes</p></div>
        <SolicitudesDisponibles :requests="availableRequests" :loading="loading.available" @accept="acceptRequest" @reject="rejectRequest" @busy="busyRequest" />
        <div v-if="!loading.available && availableRequests.length === 0" class="empty-state"><div class="empty-icon">📭</div><h4>No hay solicitudes disponibles</h4><p>Las nuevas solicitudes aparecerán aquí automáticamente</p></div>
      </div>

      <div v-if="activeTab === 'in-progress'" class="tab-content">
        <div class="tab-header"><h3>⚡ Solicitudes Activas</h3><p class="tab-description">Gestiona los servicios en progreso</p></div>
        <SolicitudesActivas
          :requests="inProgressRequests" :loading="loading.inProgress" :dropdown-state="openDropdown"
          @set-status="setStatus" @open-chat="openChat" @open-proof="openProofModal"
          @toggle-dropdown="toggleDropdown" @assign-delivery="openAssignDeliveryModal"
        />
        <div v-if="!loading.inProgress && inProgressRequests.length === 0" class="empty-state"><div class="empty-icon">🚀</div><h4>No hay servicios activos</h4><p>Acepta solicitudes para comenzar a trabajar</p></div>
      </div>

      <div v-if="activeTab === 'support'" class="tab-content">
        <div class="tab-header"><h3>🛠️ Centro de Soporte</h3><p class="tab-description">Obtén ayuda y resuelve dudas</p></div>
        <Soporte :tickets="tickets" :faq-items="faqItems" :loading-tickets="loading.support" :ticket-history-data="ticketHistoryData"
          :loading-faq="loading.faq" :show-new-ticket="showNewTicket" @open-support-chat="openSupportChat"
          @open-ticket="handleOpenTicket" @show-new-ticket="showNewTicket = true" @reply-ticket="handleReplyTicket"
          @close-ticket="handleCloseTicket" @send-reply="handleSendReply" @copy-ticket-id="handleCopyTicketId" @open-chat-with-ticket="handleChatWithTicket" />
      </div>

      <div v-if="activeTab === 'history'" class="tab-content">
        <div class="tab-header"><h3>📅 Historial de Servicios</h3><p class="tab-description">Revisa tus servicios completados</p></div>
        <Historial :requests="historyRequests" :loading="loading.history" @open-history="openHistoryModal" />
        <div v-if="!loading.history && historyRequests.length === 0" class="empty-state"><div class="empty-icon">📖</div><h4>Historial vacío</h4><p>Los servicios completados aparecerán aquí</p></div>
      </div>
    </div>

    <!-- MODALES GLOBALES -->
    <ProofModal v-if="showProofModal" :request-id="proofModalRequestId" @close="onProofModalClose" />
    <NewTicketModal v-if="showNewTicket" :is-open="showNewTicket" @close="showNewTicket = false" @ticket-created="onTicketCreated" />
    <ChatRoomModal v-if="chatTarget" :target="chatTarget" @close="chatTarget = null" />

    <!-- HISTORY DETAIL MODAL -->
    <div v-if="historyModal" class="modal-overlay" @click.self="closeHistoryModal">
      <div class="modern-modal">
        <div class="modal-header"><h2 class="modal-title">{{ selectedHistory.service_title || selectedHistory.title || 'Detalles' }}</h2><button class="modal-close" @click="closeHistoryModal">✕</button></div>
        <div class="modal-content">
          <div class="info-grid">
            <div class="info-item"><span class="info-label">Cliente:</span><span class="info-value">{{ selectedHistory.user_name || '-' }}</span></div>
            <div class="info-item"><span class="info-label">Estado:</span><span class="info-badge" :class="statusColor(selectedHistory.status)">{{ statusLabel(selectedHistory.status) }}</span></div>
            <div class="info-item"><span class="info-label">Precio:</span><span class="price-value">${{ Number(selectedHistory.service_price || selectedHistory.price || 0).toFixed(2) }}</span></div>
            <div class="info-item"><span class="info-label">Pago:</span><span class="info-value">{{ selectedHistory.payment_status || '-' }}</span></div>
            <div class="info-item"><span class="info-label">Fecha:</span><span class="info-value">{{ formatDate(selectedHistory.completed_at || selectedHistory.finished_at || selectedHistory.created_at) }}</span></div>
          </div>
        </div>
        <div class="modal-footer"><button class="btn-secondary" @click="closeHistoryModal">Cerrar</button></div>
      </div>
    </div>

    <!-- MODAL ASIGNAR DELIVERY -->
    <div v-if="showAssignModal" class="modal-overlay" @click.self="showAssignModal = false">
      <div class="modern-modal">
        <div class="modal-header"><h2 class="modal-title">🛵 Asignar Delivery</h2><button class="modal-close" @click="showAssignModal = false">✕</button></div>
        <div class="modal-content">
          <div v-if="staffList.length === 0" class="text-center py-4">
            <p>No tienes personal de delivery.</p>
            <router-link to="/provider/staff" class="btn-link">Agregar staff</router-link>
          </div>
          <div v-else class="staff-select-list">
            <div v-for="s in staffList" :key="s.id" :class="['staff-option', { selected: selectedStaffId === s.id }]" @click="selectedStaffId = s.id">
              <span class="staff-name">{{ s.name }}</span>
              <span class="staff-phone">{{ s.phone || 'Sin teléfono' }}</span>
              <span v-if="selectedStaffId === s.id" class="check">✅</span>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn-secondary" @click="showAssignModal = false">Cancelar</button>
          <button class="btn-primary" @click="assignDeliveryToRequest" :disabled="!selectedStaffId || assigning">
            {{ assigning ? 'Asignando...' : 'Asignar' }}
          </button>
        </div>
      </div>
    </div>

    <div v-if="pulling" class="toast toast-info">⏳ Soltando para actualizar...</div>
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
const STATUS_FLOW = { pending: ['accepted', 'rejected'], accepted: ['in_progress', 'cancelled'], in_progress: ['on_the_way', 'cancelled'], on_the_way: ['arrived', 'cancelled'], arrived: ['finalized', 'cancelled'], finalized: ['completed'], completed: [], cancelled: [], rejected: [] };
const STATUS_EMOJIS = { pending: '⏳', accepted: '👍', rejected: '👎', in_progress: '📦', on_the_way: '🚚', arrived: '📍', finalized: '✅', completed: '✅', cancelled: '❌' };

export default {
  name: 'DashboardProvider',
  components: { ChatRoomModal, NewTicketModal, PaymentPill, ProofModal, SolicitudesDisponibles, SolicitudesActivas, Soporte, Historial },
  data() {
    return {
      tabs: [], activeTab: 'available', availableRequests: [], inProgressRequests: [], historyRequests: [],
      chatTarget: null, providerId: null,
      loading: { available: false, inProgress: false, history: false, support: false, faq: false },
      tickets: [], faqItems: [], showNewTicket: false, openDropdown: null,
      pulling: false, pullStartY: 0, proofModalRequestId: null, showProofModal: false,
      selectedHistory: {}, ticketHistoryData: {}, historyModal: false,
      authStore: useAuthStore(), lastPullRefresh_: 0, pullRefreshCooldown_: 5000,
      socketHandlers_: [], initialized_: false,
      lastFetch_: { support: 0, history: 0, faq: 0 }, CACHE_TTL_: 5000,
      showAssignModal: false, assignRequestId: null, staffList: [], selectedStaffId: null, assigning: false
    };
  },
  watch: {
    activeTab(newTab, oldTab) { if (newTab !== oldTab) { this.$nextTick(() => this.syncRequests()); } }
  },
  async mounted() {
    const auth = useAuthStore(); const socketStore = useSocketStore(); const notificationStore = useNotificationStore();
    try {
      socketStore.init(); await notificationStore.initialize();
      this.setupSocketHandlers(socketStore); this.providerId = auth.user?.id;
      await auth.loadLocale(); await this.initializeTabs(); await this.$nextTick();
      if (!socketStore.isConnected) { await new Promise(resolve => { const i = setInterval(() => { if (socketStore.isConnected) { clearInterval(i); resolve(); } }, 100); }); }
      await Promise.allSettled([this.fetchAvailableRequests(), this.fetchActiveRequests(), this.fetchTickets(), this.fetchFaq(), this.fetchHistoryRequests()]);
      this.initialized_ = true;
    } catch (error) { this.$swal?.fire({ icon: 'error', title: 'Error', text: error.message }); }
    document.addEventListener('visibilitychange', this.onVisibilityChange);
    window.addEventListener('refresh-provider-dashboard', this.handleProviderRefresh);
  },
  beforeUnmount() { this.cleanupSocketHandlers(); this.resetModals(); document.removeEventListener('visibilitychange', this.onVisibilityChange); window.removeEventListener('refresh-provider-dashboard', this.handleProviderRefresh); },
  methods: {
    getTabIcon(tab) { const i = { 'available': '📋', 'in-progress': '⚡', 'support': '🛠️', 'history': '📅' }; return i[tab] || ' 📄'; },
    getTabCount(tab) { switch(tab) { case 'available': return this.availableRequests.length; case 'in-progress': return this.inProgressRequests.length; case 'history': return this.historyRequests.length; case 'support': return this.tickets.length; default: return 0; } },
    async onVisibilityChange() { if (!document.hidden && this.initialized_) { this.lastPullRefresh_ = 0; await this.syncRequests(); } },
    async openAssignDeliveryModal(requestId) { this.assignRequestId = requestId; this.selectedStaffId = null; await this.fetchStaffList(); this.showAssignModal = true; },
    async fetchStaffList() { try { const { data } = await api.get('/provider/staff', { headers: { Authorization: `Bearer ${this.authStore.token}` } }); this.staffList = (data.staff || []).filter(s => s.role === 'delivery'); } catch (err) { console.error('Error cargando staff:', err); } },
    async assignDeliveryToRequest() { if (!this.selectedStaffId || !this.assignRequestId) return; this.assigning = true; try { await api.post('/requests/assign-delivery', { request_id: this.assignRequestId, staff_id: this.selectedStaffId }, { headers: { Authorization: `Bearer ${this.authStore.token}` } }); this.showAssignModal = false; await this.fetchActiveRequests(); } catch (err) { alert('Error al asignar delivery'); } finally { this.assigning = false; } },
    async handleOpenTicket(ticket) { try { const auth = useAuthStore(); const { data } = await api.get(`/support/tickets/${ticket.id}/replies`, { headers: { Authorization: `Bearer ${auth.token}` } }); this.ticketHistoryData = { ...this.ticketHistoryData, [ticket.id]: data.replies || [] }; } catch (e) { console.error("Error cargando replies:", e); } },
    handleReplyTicket(ticket) { console.log('🔵 Proveedor quiere responder al ticket:', ticket.id); },
    async handleSendReply(payload) { try { const auth = useAuthStore(); const response = await api.post('/support/tickets/reply', { ticket_id: payload.ticket.id, message: payload.message }, { headers: { Authorization: `Bearer ${auth.token}` } }); if (response.data.success) { this.ticketHistoryData = { ...this.ticketHistoryData, [payload.ticket.id]: [] }; await this.handleOpenTicket(payload.ticket); this.$swal?.fire({ icon: 'success', title: 'Respuesta enviada', text: 'Tu mensaje ha sido enviado correctamente', timer: 2000, showConfirmButton: false }); } } catch (error) { this.$swal?.fire({ icon: 'error', title: 'Error', text: error.response?.data?.message || 'Error al enviar la respuesta' }); } },
    async handleCloseTicket(ticket) { try { const auth = useAuthStore(); const response = await api.put('/support/tickets/close', { ticket_id: ticket.id }, { headers: { Authorization: `Bearer ${auth.token}` } }); if (response.data.success) { this.lastFetch_.support = 0; await this.fetchTickets(); this.$swal?.fire({ icon: 'success', title: 'Ticket cerrado', text: 'El ticket se ha cerrado correctamente', timer: 2000, showConfirmButton: false }); } } catch (error) { this.$swal?.fire({ icon: 'error', title: 'Error', text: error.response?.data?.message || 'Error al cerrar el ticket' }); } },
    handleCopyTicketId(ticket) { console.log('ID del ticket copiado:', ticket.id); },
    handleChatWithTicket(ticket) { this.chatTarget = { id: -ticket.id, name: `Soporte - Ticket #${ticket.id}`, role: 'support', context: { ticket_id: ticket.id, subject: ticket.subject, last_message: ticket.last_message } }; },

    setupSocketHandlers(socketStore) {
      const onNewRequest = () => {
        this.fetchAvailableRequests();
      };

      const onRequestUpdated = (data) => {
        const request = data.request || data;
        if (request && request.id) {
          this.handleRequestUpdate(request);
        }
      };

      const onPaymentUpdated = (data) => {
        if (data.request_id) {
          this.handlePaymentUpdate(data.request_id, data.payment_status);
        }
      };

      socketStore.on('new_request_created', onNewRequest);
      socketStore.on('request_updated', onRequestUpdated);
      socketStore.on('payment_updated', onPaymentUpdated);

      this.socketHandlers_ = [
        { event: 'new_request_created', handler: onNewRequest },
        { event: 'request_updated', handler: onRequestUpdated },
        { event: 'payment_updated', handler: onPaymentUpdated },
      ];
    },

    cleanupSocketHandlers() { const socketStore = useSocketStore(); this.socketHandlers_.forEach(({ event, handler }) => { socketStore.off(event, handler); }); this.socketHandlers_ = []; },
    async initializeTabs() { this.tabs = [{ value: 'available', label: this.$t('requests') }, { value: 'in-progress', label: this.$t('active') }, { value: 'support', label: this.$t('support') }, { value: 'history', label: this.$t('history') }]; },
    handleProviderRefresh() { this.syncRequests(); },
    pullStart(e) { this.pulling = true; this.pullStartY = e.touches ? e.touches[0].clientY : e.clientY; },
    pullMove(e) { if (!this.pulling) return; const y = e.touches ? e.touches[0].clientY : e.clientY; if (y - this.pullStartY > 120) { const now = Date.now(); if (now - this.lastPullRefresh_ > this.pullRefreshCooldown_) { this.lastPullRefresh_ = now; this.pulling = false; this.syncRequests(); } } },
    pullEnd() { this.pulling = false; },
    updateRequestStatus(requestId, newStatus, updatedAt) { const i = this.inProgressRequests.findIndex(r => r.id === requestId); if (i === -1) return; const u = [...this.inProgressRequests]; u[i] = { ...u[i], status: newStatus, updated_at: updatedAt }; this.inProgressRequests = u; },
    handleRequestUpdate(request) { if (request.status !== 'pending') this.availableRequests = this.availableRequests.filter(r => r.id !== request.id); const i = this.inProgressRequests.findIndex(r => r.id === request.id); if (ACTIVE_STATUSES.includes(request.status)) { if (i >= 0) this.inProgressRequests.splice(i, 1, { ...request }); else this.inProgressRequests.unshift({ ...request }); } else if (i >= 0) this.inProgressRequests.splice(i, 1); if (['completed', 'cancelled', 'rejected', 'busy'].includes(request.status)) this.updateHistory(request); },
    handlePaymentUpdate(request_id, payment_status) { const req = this.inProgressRequests.find(r => r.id === request_id); if (req) req.payment_status = payment_status; },
    updateHistory(request) { const i = this.historyRequests.findIndex(h => h.id === request.id); const n = this.normalizeHistory(request); if (i >= 0) this.historyRequests[i] = n; else this.historyRequests.unshift(n); },
    resetModals() { this.chatTarget = null; this.showNewTicket = false; this.openDropdown = null; this.showProofModal = false; this.proofModalRequestId = null; this.historyModal = false; this.selectedHistory = {}; this.showAssignModal = false; },
    normalizeHistory(h) { const pm = h.payment_methods || []; return { ...h, payment_methods: (() => { try { if (Array.isArray(pm)) return pm; if (typeof pm === 'string') return JSON.parse(pm); return []; } catch { return []; } })() }; },
    normalizeRequest(r) { return { ...r, service_title: r.service_title || r.title || 'Servicio', service_price: Number(r.service_price || r.price || 0), status: r.status || 'pending', payment_status: r.payment_status || 'pending' }; },
    formatDate(d, onlyTime = false) { if (!d) return ''; const l = this.$i18n.locale.value || 'es'; const o = onlyTime ? { hour: '2-digit', minute: '2-digit', second: '2-digit' } : { year: 'numeric', month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit' }; try { return new Date(d).toLocaleString(l, o); } catch { return d; } },
    formatCurrency(amount) { return new Intl.NumberFormat(this.$i18n.locale.value || 'es', { style: 'currency', currency: 'USD' }).format(amount || 0); },
    statusLabel(status) { const m = { completed: 'Completado', completado: 'Completado', cancelled: 'Cancelado', cancelado: 'Cancelado', pending: 'Pendiente', pendiente: 'Pendiente' }; return m[status] || status; },
    statusColor(status) { const m = { completed: 'status-completed', completado: 'status-completed', cancelled: 'status-cancelled', cancelado: 'status-cancelled', pending: 'status-pending', pendiente: 'status-pending' }; return m[status] || 'status-default'; },
    emoji(status) { return STATUS_EMOJIS[status] || '•'; },
    allowedNext(status) { return STATUS_FLOW[status] || []; },
    toggleDropdown(id) { this.openDropdown = this.openDropdown === id ? null : id; },
    openChat(userId, role = 'user') { const r = this.inProgressRequests.find(r => r.user_id === userId); this.chatTarget = { id: userId, name: r?.user_name || this.$t('user'), role, avatarUrl: r?.user_avatar_url || null }; },
    openSupportChat() { this.chatTarget = { id: 1, name: this.$t('support'), role: 'support', avatarUrl: '/img/support-avatar.png' }; },
    openHistoryModal(request) { this.selectedHistory = request; this.historyModal = true; },
    closeHistoryModal() { this.historyModal = false; this.selectedHistory = {}; },
    openProofModal(requestId) { this.proofModalRequestId = requestId; this.showProofModal = true; },
    onProofModalClose() { this.showProofModal = false; this.fetchActiveRequests(); },
    async syncRequests() { const a = useAuthStore(); if (!a.token) return; const m = { 'available': () => this.fetchAvailableRequests(), 'in-progress': () => this.fetchActiveRequests(), 'history': () => this.fetchHistoryRequests(), 'support': () => { this.fetchTickets(); this.fetchFaq(); } }; try { await m[this.activeTab]?.(); } catch (e) { console.error('❌ Error en syncRequests:', e); } },
    async fetchAvailableRequests() { const a = useAuthStore(); if (!a.token) { this.loading.available = false; return; } this.loading.available = true; try { const r = await api.get('/requests/pending', { headers: { Authorization: `Bearer ${a.token}` } }); this.availableRequests = Array.isArray(r.data?.data) ? r.data.data : []; } catch (e) { console.error(e); } finally { this.loading.available = false; } },
    async fetchActiveRequests() { const a = useAuthStore(); if (!a.token) { this.loading.inProgress = false; return; } this.loading.inProgress = true; try { const r = await api.get('/requests/active', { headers: { Authorization: `Bearer ${a.token}` } }); this.inProgressRequests = Array.isArray(r.data?.data) ? r.data.data : []; } catch (e) { console.error(e); } finally { this.loading.inProgress = false; } },
    async fetchHistoryRequests() { const n = Date.now(); if (n - this.lastFetch_.history < this.CACHE_TTL_ && this.historyRequests.length > 0) return; const a = useAuthStore(); if (!a.token) { this.loading.history = false; return; } this.loading.history = true; try { const r = await api.get('/history', { headers: { Authorization: `Bearer ${a.token}` } }); const d = Array.isArray(r.data?.history) ? r.data.history : r.data || []; this.historyRequests = d.map(h => this.normalizeHistory(h)); this.lastFetch_.history = n; } catch (e) { console.error(e); } finally { this.loading.history = false; } },
    async fetchTickets() { const n = Date.now(); if (n - this.lastFetch_.support < this.CACHE_TTL_ && this.tickets.length > 0) return; const a = useAuthStore(); if (!a.token) { this.loading.support = false; return; } this.loading.support = true; try { const r = await api.get('/support/tickets', { headers: { Authorization: `Bearer ${a.token}` } }); this.tickets = (Array.isArray(r.data?.tickets) ? r.data.tickets : r.data || []).map(t => ({ ...t, last_message: t.description || t.message || 'Sin mensaje', description: t.description })); this.lastFetch_.support = n; } catch (e) { console.error(e); } finally { this.loading.support = false; } },
    async fetchFaq() { const n = Date.now(); if (n - this.lastFetch_.faq < this.CACHE_TTL_ && this.faqItems.length > 0) return; this.loading.faq = true; try { const r = await api.get('/support/faq'); this.faqItems = Array.isArray(r.data?.faq) ? r.data.faq : r.data || []; this.lastFetch_.faq = n; } catch (e) { console.error(e); } finally { this.loading.faq = false; } },
    async executeRequestAction(id, endpoint, msg = null) { try { const a = useAuthStore(); const r = await api.post(endpoint, { id }, { headers: { Authorization: `Bearer ${a.token}` } }); if (r.data.success) { this.availableRequests = this.availableRequests.filter(r => r.id !== id); useSocketStore().playNotificationSound(); if (msg) this.$swal?.fire({ icon: 'success', title: 'Éxito', text: msg }); } } catch (e) { this.$swal?.fire({ icon: 'error', title: 'Error', text: e.message }); } },
    async acceptRequest(id) { await this.executeRequestAction(id, '/requests/accept', 'Solicitud aceptada'); },
    async rejectRequest(id) { await this.executeRequestAction(id, '/requests/reject', 'Solicitud rechazada'); },
    async busyRequest(id) { await this.executeRequestAction(id, '/requests/busy', 'Estado ocupado establecido'); },
    async setStatus(requestId, newStatus) { try { const a = useAuthStore(); const r = await api.post(`/requests/${newStatus}`, { id: requestId }, { headers: { Authorization: `Bearer ${a.token}` } }); if (r.data.success) { this.updateRequestStatus(requestId, newStatus, r.data.updated_at || new Date().toISOString()); this.openDropdown = null; useSocketStore().playNotificationSound(); } else { this.$swal?.fire({ icon: 'error', title: 'Error', text: r.data.message }); } } catch (e) { this.$swal?.fire({ icon: 'error', title: 'Error', text: e.response?.data?.message || e.message }); } },
    async confirmPayment(requestId) { try { const a = useAuthStore(); const r = await api.post('/requests/confirm-payment', { id: requestId }, { headers: { Authorization: `Bearer ${a.token}` } }); if (r.data.success) { const i = this.inProgressRequests.findIndex(r => r.id === requestId); if (i !== -1) this.inProgressRequests[i].payment_status = 'paid'; useSocketStore().playNotificationSound(); } } catch (e) { this.$swal?.fire({ icon: 'error', title: 'Error', text: this.$t('error_confirming_payment') || 'Error confirmando pago' }); } },
    onTicketCreated() { this.showNewTicket = false; this.lastFetch_.support = 0; this.fetchTickets(); }
  }
};
</script>

<style scoped>
.provider-dashboard { max-width: 1400px; margin: 0 auto; padding: 24px; min-height: 100vh; background: linear-gradient(135deg, #f5f7fa 0%, #e4edf5 100%); }
.dashboard-header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 24px; padding: 32px; margin-bottom: 32px; color: white; box-shadow: 0 20px 60px rgba(102, 126, 234, 0.3); position: relative; overflow: hidden; }
.dashboard-header::before { content: ''; position: absolute; top: 0; left: 0; right: 0; bottom: 0; background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 100"><path d="M0,50 Q250,0 500,50 T1000,50 L1000,100 L0,100 Z" fill="rgba(255,255,255,0.1)"/></svg>'); background-size: cover; }
.header-content { position: relative; z-index: 2; }
.dashboard-icon { font-size: 2.5rem; margin-right: 12px; vertical-align: middle; animation: float 3s ease-in-out infinite; }
@keyframes float { 0%, 100% { transform: translateY(0px); } 50% { transform: translateY(-10px); } }
.header-content h1 { font-size: 2.8rem; font-weight: 800; margin-bottom: 8px; display: flex; align-items: center; }
.header-content p { font-size: 1.2rem; opacity: 0.9; margin-bottom: 24px; }
.header-stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-top: 24px; position: relative; z-index: 2; }
.stat-card { background: rgba(255, 255, 255, 0.15); backdrop-filter: blur(10px); border-radius: 16px; padding: 20px; display: flex; align-items: center; gap: 16px; transition: transform 0.3s, background 0.3s; border: 1px solid rgba(255, 255, 255, 0.2); }
.stat-card:hover { transform: translateY(-5px); background: rgba(255, 255, 255, 0.25); }
.stat-icon { font-size: 2.2rem; width: 60px; height: 60px; display: flex; align-items: center; justify-content: center; background: rgba(255, 255, 255, 0.2); border-radius: 12px; }
.stat-info h3 { font-size: 2rem; font-weight: 700; margin-bottom: 4px; }
.stat-info p { font-size: 0.9rem; opacity: 0.9; margin: 0; }
.pull-refresh-indicator { display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 20px; background: rgba(255, 255, 255, 0.9); border-radius: 12px; margin: 20px auto; max-width: 300px; box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1); }
.pull-refresh-indicator .spinner { width: 40px; height: 40px; border: 3px solid #f3f3f3; border-top: 3px solid #3498db; border-radius: 50%; animation: spin 1s linear infinite; margin-bottom: 10px; }
@keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
.tabs-container { background: white; border-radius: 20px; padding: 32px; margin-bottom: 32px; box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08); }
.tabs-header { margin-bottom: 32px; }
.tabs-header h2 { font-size: 2rem; color: #2d3436; margin-bottom: 8px; }
.tabs-subtitle { color: #636e72; font-size: 1.1rem; }
.tabs-navigation { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; }
.tab-button { background: #f8f9fa; border: 2px solid #e9ecef; border-radius: 16px; padding: 20px; display: flex; align-items: center; justify-content: center; gap: 12px; cursor: pointer; transition: all 0.3s; position: relative; }
.tab-button:hover { transform: translateY(-3px); border-color: #74b9ff; box-shadow: 0 10px 20px rgba(116, 185, 255, 0.2); }
.tab-button-active { background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%); border-color: #0984e3; color: white; box-shadow: 0 10px 25px rgba(116, 185, 255, 0.4); }
.tab-button-active .tab-icon { transform: scale(1.2); }
.tab-icon { font-size: 1.8rem; transition: transform 0.3s; }
.tab-label { font-weight: 600; font-size: 1.1rem; }
.tab-badge { position: absolute; top: -8px; right: -8px; background: #ff7675; color: white; font-size: 0.8rem; font-weight: 700; width: 28px; height: 28px; border-radius: 50%; display: flex; align-items: center; justify-content: center; animation: pulse 2s infinite; }
@keyframes pulse { 0%, 100% { transform: scale(1); } 50% { transform: scale(1.1); } }
.dashboard-content { background: white; border-radius: 20px; padding: 32px; box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08); }
.tab-content { animation: fadeIn 0.5s ease-out; }
@keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
.tab-header { margin-bottom: 32px; padding-bottom: 20px; border-bottom: 2px solid #f1f2f6; }
.tab-header h3 { font-size: 1.8rem; color: #2d3436; margin-bottom: 8px; display: flex; align-items: center; gap: 10px; }
.tab-description { color: #636e72; font-size: 1.1rem; }
.empty-state { text-align: center; padding: 60px 20px; background: #f8f9fa; border-radius: 20px; margin: 40px 0; }
.empty-icon { font-size: 64px; margin-bottom: 20px; opacity: 0.6; animation: bounce 2s infinite; }
@keyframes bounce { 0%, 100% { transform: translateY(0); } 50% { transform: translateY(-15px); } }
.empty-state h4 { color: #2d3436; margin-bottom: 12px; font-size: 1.5rem; }
.empty-state p { color: #636e72; font-size: 1.1rem; max-width: 400px; margin: 0 auto; }
.toast { position: fixed; bottom: 24px; right: 24px; padding: 16px 24px; border-radius: 12px; color: white; font-weight: 600; z-index: 1000; animation: slideIn 0.3s ease-out; box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2); }
.toast-info { background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%); }
@keyframes slideIn { from { transform: translateX(100%); opacity: 0; } to { transform: translateX(0); opacity: 1; } }
@media (max-width: 1200px) { .provider-dashboard { padding: 16px; } .tabs-navigation { grid-template-columns: repeat(2, 1fr); } }
@media (max-width: 768px) { .dashboard-header { padding: 24px; } .header-content h1 { font-size: 2rem; flex-direction: column; align-items: flex-start; } .dashboard-icon { margin-bottom: 10px; } .header-stats { grid-template-columns: 1fr; } .tabs-navigation { grid-template-columns: 1fr; } .tab-button { padding: 16px; } .tabs-container, .dashboard-content { padding: 20px; } }
@media (max-width: 480px) { .header-content h1 { font-size: 1.8rem; } .tab-header h3 { font-size: 1.5rem; } .tab-button { flex-direction: column; text-align: center; padding: 12px; } .tab-label { font-size: 1rem; } }
.modal-overlay { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); display: flex; align-items: center; justify-content: center; z-index: 1000; }
.modern-modal { background: white; border-radius: 20px; padding: 32px; max-width: 500px; width: 90%; max-height: 80vh; overflow-y: auto; box-shadow: 0 20px 60px rgba(0,0,0,0.2); }
.modal-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }
.modal-title { font-size: 1.3rem; font-weight: 700; color: #2d3436; margin: 0; }
.modal-close { background: #f1f5f9; border: none; width: 36px; height: 36px; border-radius: 10px; font-size: 1.2rem; cursor: pointer; color: #64748b; }
.modal-close:hover { background: #e2e8f0; }
.info-grid { display: flex; flex-direction: column; gap: 12px; }
.info-item { display: flex; justify-content: space-between; align-items: center; padding: 8px 0; border-bottom: 1px solid #f1f5f9; }
.info-label { color: #64748b; font-size: 0.9rem; }
.info-value { font-weight: 600; color: #2d3436; }
.price-value { font-weight: 700; color: #059669; font-size: 1.1rem; }
.info-badge { padding: 4px 12px; border-radius: 12px; font-size: 0.8rem; font-weight: 600; }
.status-completed { background: #d1fae5; color: #047857; }
.status-cancelled { background: #fee2e2; color: #dc2626; }
.status-pending { background: #fef3c7; color: #b45309; }
.status-default { background: #f1f5f9; color: #64748b; }
.modal-footer { margin-top: 24px; display: flex; justify-content: flex-end; gap: 10px; }
.btn-secondary { padding: 10px 24px; background: #f1f5f9; border: none; border-radius: 10px; font-weight: 600; cursor: pointer; color: #4a5568; }
.btn-secondary:hover { background: #e2e8f0; }
.btn-primary { padding: 10px 24px; background: #10B981; border: none; border-radius: 10px; font-weight: 600; cursor: pointer; color: white; }
.btn-primary:hover { background: #059669; }
.btn-primary:disabled { background: #9ca3af; cursor: not-allowed; }
.staff-select-list { display: flex; flex-direction: column; gap: 8px; }
.staff-option { display: flex; align-items: center; gap: 12px; padding: 12px; border: 2px solid #e5e7eb; border-radius: 8px; cursor: pointer; transition: all 0.2s; }
.staff-option:hover { border-color: #10B981; background: #f0fdf4; }
.staff-option.selected { border-color: #10B981; background: #d1fae5; }
.staff-name { font-weight: 600; flex: 1; }
.staff-phone { color: #6b7280; font-size: 0.9rem; }
.btn-link { color: #10B981; text-decoration: underline; }
</style>
