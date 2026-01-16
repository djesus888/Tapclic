<template>
  <div
    ref="pullArea"
    class="p-4 space-y-6"
    @pointerdown="pullStart"
    @pointermove="pullMove"
    @pointerup="pullEnd"
    @pointercancel="pullEnd"
  >
    <!-- TABS -->
    <div class="mb-6 border-b border-gray-300 bg-white sticky top-16 z-20 pb-1">
      <nav
        class="flex space-x-2 justify-center max-w-md mx-auto"
        role="tablist"
        :aria-label="$t('tabs')"
      >
        <button
          v-for="tab in tabs"
          :key="`${tab.value}-${$i18n.locale}`"
          role="tab"
          :aria-selected="activeTab === tab.value"
          :tabindex="activeTab === tab.value ? 0 : -1"
          :class="tabClass(tab.value)"
          @click="activeTab = tab.value"
        >
          {{ tab.label }}
        </button>
      </nav>
    </div>

    <!-- PULL-TO-REFRESH INDICATOR -->
    <div
      v-if="pulling"
      class="text-center text-sm text-gray-500 mb-2"
    >
      {{ $t('release_to_refresh') }}
    </div>

    <!-- AVAILABLE -->
    <div
      v-if="activeTab === 'available'"
      :key="'available-'+$i18n.locale"
      class="grid gap-4 md:grid-cols-2"
    >
      <div
        v-if="loading.available"
        class="text-center py-10"
      >
        {{ $t('loading') }}…
      </div>
      <div
        v-else-if="!availableRequests.length"
        class="text-center py-10 text-gray-500"
      >
        {{ $t('no_available_requests') }}
      </div>
      <div
        v-for="req in availableRequests"
        :key="`${req.id}-${$i18n.locale}`"
        class="bg-white rounded-lg shadow p-4 flex flex-col justify-between"
      >
        <div>
          <div class="flex items-center justify-between mb-2">
            <h3 class="text-lg font-semibold text-gray-800">
              {{ sanitize(req.service_title) }}
            </h3>
            <PaymentPill :status="req.payment_status" />
          </div>
          <p class="text-sm text-gray-600">
            {{ sanitize(req.service_description) }}
          </p>
          <p class="text-sm mt-2 text-gray-500">
            {{ req.service_location }}
          </p>
          <p class="text-sm mt-2 text-gray-500">
            {{ sanitize(req.service_provider_name) }}
          </p>
          <p class="text-sm mt-1 font-bold text-green-600">
            {{ formatCurrency(req.service_price) }}
          </p>
        </div>
        <div class="flex gap-2 mt-4">
          <button
            class="bg-green-500 text-white px-3 py-1 rounded hover:bg-green-600"
            @click="acceptRequest(req.id)"
          >
            {{ $t('accept') }}
          </button>
          <button
            class="bg-red-500 text-white px-3 py-1 rounded hover:bg-red-600"
            @click="rejectRequest(req.id)"
          >
            {{ $t('reject') }}
          </button>
          <button
            class="bg-yellow-500 text-white px-3 py-1 rounded hover:bg-yellow-600"
            @click="busyRequest(req.id)"
          >
            {{ $t('busy') }}
          </button>
        </div>
        <div
          v-if="req.additional_details?.trim()"
          class="mt-3 text-sm text-gray-700 bg-yellow-50 border border-yellow-200 rounded p-2 flex items-start gap-2"
        >
          <span class="text-yellow-600 text-base">🔔</span>
          <span class="whitespace-pre-wrap break-words">{{ req.additional_details }}</span>
        </div>
      </div>
    </div>

    <!-- IN-PROGRESS -->
    <div
      v-if="activeTab === 'in-progress'"
      :key="'in-progress-'+$i18n.locale"
      class="grid gap-4 md:grid-cols-2"
    >
      <div
        v-if="loading.inProgress"
        class="text-center py-10"
      >
        {{ $t('loading') }}…
      </div>
      <div
        v-else-if="!inProgressRequests.length"
        class="text-center py-10 text-gray-500"
      >
        {{ $t('no_active_requests') }}
      </div>
      <div
        v-for="req in inProgressRequests"
        :key="`${req.id}-${$i18n.locale}`"
        class="bg-white rounded-lg shadow p-4"
      >
        <div class="flex items-center justify-between mb-2">
          <h3 class="text-lg font-semibold text-gray-800">
            {{ sanitize(req.service_title) }}
          </h3>
          <PaymentPill :status="req.payment_status" />
        </div>
        <p class="text-sm text-gray-600">
          {{ sanitize(req.service_description) }}
        </p>
        <p class="text-sm mt-2 text-gray-500">
          <strong>{{ $t('requested_by') }}:</strong> {{ sanitize(req.user_name || $t('user')) }}
        </p>
        <!-- CANCELLED BY -->
        <p
          v-if="req.status === 'cancelled' && req.cancelled_by"
          class="text-xs text-red-600 mt-1"
        >
          {{ $t('cancelled_by') }}: {{ req.cancelled_by }}
        </p>

        <!-- BOTÓN CONFIRMAR PAGO (solo si está en verificación) -->
        <div
          v-if="req.payment_status === 'verifying'"
          class="mt-3"
        >
          <button
            class="bg-orange-500 text-white px-3 py-1 rounded hover:bg-orange-600"
            @click="openProofModal(req.id)"
          >
            👁️ {{ $t('see_proof') }}
          </button>
        </div>

        <details class="mt-3 text-xs">
          <summary class="cursor-pointer text-blue-600">
            {{ $t('timeline') }}
          </summary>
          <div class="mt-2 space-y-1">
            <div
              v-for="(l,i) in timeline(req)"
              :key="i"
              class="flex justify-between"
            >
              <span>{{ $t(l.status) }}</span>
              <span>{{ formatDate(l.updated_at, 'time') }}</span>
            </div>
          </div>
        </details>
        <p class="text-xs text-gray-500 mt-2">
          {{ $t('elapsed') }}: {{ elapsed(req.updated_at) }}
        </p>
        <div class="mt-4 relative">
          <button
            class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 w-full flex items-center justify-between"
            @click="toggleDropdown(req.id)"
          >
            {{ $t('status') }}
            <svg
              class="w-4 h-4 ml-2"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M19 9l-7 7-7-7"
              />
            </svg>
          </button>
          <div
            v-if="openDropdown === req.id"
            class="absolute right-0 mt-2 w-full bg-white border border-gray-200 rounded-lg shadow-lg z-20"
          >
            <button
              v-for="st in allowedNext(req.status)"
              :key="st"
              class="block w-full text-left px-4 py-2 hover:bg-gray-100"
              @click="setStatus(req.id, st)"
            >
              {{ emoji(st) }} {{ $t('status.'+st) }}
            </button>
          </div>
        </div>
        <div class="flex gap-2 mt-4">
          <button
            class="bg-blue-500 text-white px-3 py-1 rounded hover:bg-blue-600"
            @click="openChat(req.user_id, 'user')"
          >
            💬
          </button>
        </div>
      </div>
    </div>

    <!-- SUPPORT -->
    <div
      v-if="activeTab === 'support'"
      :key="'support-'+$i18n.locale"
      class="p-4"
    >
      <div
        v-if="loading.faq"
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
            :key="`${idx}-${$i18n.locale}`"
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
        v-if="loading.support"
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
            :key="`${ticket.id}-${$i18n.locale}`"
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
          v-show="!showNewTicket"
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
    
    <!-- HISTORY (LISTA) -->
    <div
      v-if="activeTab === 'history'"
      :key="'history-'+$i18n.locale"
      class="space-y-2"
    >
      <div
        v-if="loading.history"
        class="text-center py-10"
      >
        {{ $t('loading') }}…
      </div>
      <div
        v-else-if="!historyRequests.length"
        class="text-center py-10 text-gray-500"
      >
        {{ $t('no_history_requests') }}
      </div>
      <div
        v-for="req in historyRequests"
        :key="req.id"
        class="flex items-center justify-between p-3 bg-white rounded shadow hover:bg-gray-50 cursor-pointer"
        @click="openHistoryModal(req)"
      >
        <div class="flex-1">
          <p class="font-semibold text-gray-800">
            {{ sanitize(req.service_title) }}
          </p>
          <p
            class="text-sm"
            :class="statusColor(req.status)"
          >
            {{ $t('status.'+req.status) }}
          </p>
          <p class="text-xs text-gray-500 mt-1">
            <PaymentPill :status="req.payment_status" />
          </p>
        </div>
        <div class="text-right">
          <p class="font-bold text-green-600">
            {{ formatCurrency(req.service_price) }}
          </p>
        </div>
      </div>
    </div>
    
    <!-- MODALES -->
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
  </div>
</template>

<script>
import api from '@/axios'
import { useAuthStore } from '@/stores/authStore'
import { useSocketStore } from '@/stores/socketStore'
import { useNotificationStore } from '@/stores/notificationStore'
import ChatRoomModal from '@/components/ChatRoomModal.vue'
import NewTicketModal from '@/components/NewTicketModal.vue'
import PaymentPill from '@/components/PaymentPill.vue'
import ProofModal from '@/components/ProofModal.vue'

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
}

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
}

const STATUS_COLORS = {
  completed: 'text-green-600',
  cancelled: 'text-red-600',
  rejected: 'text-orange-600',
  finalized: 'text-green-700'
}

export default {
  name: 'DashboardProvider',
  components: { ChatRoomModal, NewTicketModal, PaymentPill, ProofModal },

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
      _socketHandlers: {},
      _unsubscribeFns: [],
      _initialized: false,
      socketHandlers: [],
      _lastFetch: {
        support: 0,
        history: 0,
        faq: 0
      },
      _CACHE_TTL: 5000
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

      console.log('🔍 Provider ID:', this.providerId);
      console.log('🔍 Socket conectado?', socketStore.isConnected);
      console.log('🔍 Socket ID:', socketStore.socket?.id);

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

      console.log('🔍 Room que debería unirse:', `provider_${this.providerId}`);
      
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
  },

  methods: {
    async onVisibilityChange() {
      if (!document.hidden && this._initialized) {
        console.log('👀 Provider volvió de background → refrescando');
        this._lastPullRefresh = 0;
        await this.syncRequests();
      }
    },

    setupSocketHandlers(socketStore) {
      this.cleanupSocketHandlers();

      const onRequestUpdated = this.throttle((payload) => {
        console.log('🔔 Provider: Evento request_updated recibido:', payload);
        if (payload.request) {
          this.handleRequestUpdate(payload.request);
          socketStore.playNotificationSound();
        }
      }, 1000);

      const onPaymentUpdated = this.throttle((payload) => {
        console.log('🔔 Provider: Evento payment_updated recibido:', payload);
        if (payload.request_id && payload.payment_status) {
          this.handlePaymentUpdate(payload.request_id, payload.payment_status);
        }
      }, 1000);

      const onNewNotification = this.throttle((notification) => {
        console.log('🔔 Provider: Notificación recibida:', notification.event);
        switch(notification.event) {
          case 'status_changed':
          case 'request_updated':
            this.syncRequests();
            break;
        }
      }, 1000);
      
      // ✅ HANDLER CORREGIDO CON NORMALIZACIÓN
      const onNewRequest = this.throttle((payload) => {
        console.log('🔔 Provider: Evento new_request_created recibido:', JSON.stringify(payload, null, 2));

        try {
          // ✅ NORMALIZAR el payload al formato esperado
          const normalizedRequest = this.normalizeRequest({
            id: payload.request_id,
            service_id: payload.service_id,
            service_title: payload.service_title,
            service_description: payload.service_description,
            service_price: payload.service_price,
            service_image_url: payload.service_image_url,
            service_location: payload.service_location,
            user_id: payload.user_id,
            user_name: payload.user_name,
            user_phone: payload.user_phone,
            status: payload.status || 'pending',
            payment_status: payload.payment_status || 'pending',
            additional_details: payload.additional_details,
            created_at: payload.created_at,
            ...payload // Asegura que cualquier otra propiedad se pase también
          });

          // ✅ Forzar reactividad con spread operator
          this.availableRequests = [normalizedRequest, ...this.availableRequests];
          
          socketStore.playNotificationSound();
          this.$swal?.fire({
            icon: 'info',
            title: 'Nueva Solicitud',
            text: `${normalizedRequest.service_title} - $${normalizedRequest.service_price}`,
            timer: 4000,
            showConfirmButton: false,
            position: 'top-end',
            toast: true
          });
          
          console.log('✅ Solicitud normalizada y añadida. Total:', this.availableRequests.length);
        } catch (error) {
          console.error('❌ Error en onNewRequest:', error);
        }
      }, 1000);

      socketStore.on('request_updated', onRequestUpdated);
      socketStore.on('payment_updated', onPaymentUpdated);
      socketStore.on('new-notification', onNewNotification);
      socketStore.on('new_request_created', onNewRequest);
      
      this.socketHandlers = [
        { event: 'request_updated', handler: onRequestUpdated },
        { event: 'payment_updated', handler: onPaymentUpdated },
        { event: 'new-notification', handler: onNewNotification },
        { event: 'new_request_created', handler: onNewRequest }
      ];
    },

    cleanupSocketHandlers() {
      const socketStore = useSocketStore();
      this.socketHandlers.forEach(({ event, handler }) => {
        socketStore.off(event, handler);
      });
      this.socketHandlers = [];
    },

    throttle(func, limit) {
      let inThrottle;
      return function() {
        const args = arguments;
        const context = this;
        if (!inThrottle) {
          func.apply(context, args);
          inThrottle = true;
          setTimeout(() => inThrottle = false, limit);
        }
      }
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
      updated[index] = {
        ...updated[index],
        status: newStatus,
        updated_at: updatedAt
      };
      this.inProgressRequests = updated;
    },

    // ✅ MÉTODO MODIFICADO CON NORMALIZACIÓN
    handleRequestUpdate(request) {
      // ✅ Normalizar la solicitud recibida
      const normalizedRequest = this.normalizeRequest(request);
      
      // Filtrar de available si corresponde
      if (['accepted', 'rejected', 'busy'].includes(normalizedRequest.status)) {
        this.availableRequests = this.availableRequests.filter(r => r.id !== normalizedRequest.id);
      }

      // Actualizar en inProgress
      const idx = this.inProgressRequests.findIndex(r => r.id === normalizedRequest.id);
      if (idx >= 0) {
        // ✅ ACTUALIZACIÓN REACTIVA con splice
        this.inProgressRequests.splice(idx, 1, normalizedRequest);
      } else {
        // ✅ Añadir nueva solicitud normalizada
        this.inProgressRequests.unshift(normalizedRequest);
      }

      // Actualizar historial si corresponde
      if (['completed', 'cancelled', 'rejected', 'finalized'].includes(normalizedRequest.status)) {
        this.updateHistory(normalizedRequest);
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

    sanitize(str) {
      if (!str || typeof str !== 'string') return str;
      const tempDiv = document.createElement('div');
      tempDiv.textContent = str;
      return tempDiv.innerHTML
        .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
        .replace(/on\w+="[^"]*"/g, '')
        .replace(/on\w+='[^']*'/g, '')
        .replace(/javascript:/gi, '');
    },

    parsePaymentMethods(raw) {
      try {
        if (Array.isArray(raw)) return raw;
        if (typeof raw === 'string') return JSON.parse(raw);
        return [];
      } catch {
        return [];
      }
    },

    normalizeHistory(h) {
      return { ...h, payment_methods: this.parsePaymentMethods(h.payment_methods) };
    },

    // ✅ MÉTODO NUEVO DE NORMALIZACIÓN
    normalizeRequest(r) {
      // Parsear payment_methods si viene como string
      let paymentMethods = [];
      try {
        paymentMethods = typeof r.payment_methods === 'string' 
          ? JSON.parse(r.payment_methods) 
          : (r.payment_methods || []);
      } catch (e) {
        paymentMethods = [];
      }

      // Normalizar proveedor (si existe)
      const provider = r.provider || {};
      
      return {
        ...r,
        // Propiedades del servicio
        service_title: r.service_title || r.title || 'Servicio',
        service_description: r.service_description || r.description || '',
        service_price: Number(r.service_price || r.price || 0),
        service_location: r.service_location || r.location || 'Ubicación no especificada',
        service_image_url: r.service_image_url || r.image_url || null,
        
        // Propiedades del proveedor
        service_provider_name: r.service_provider_name || provider.name || r.provider_name || 'Proveedor',
        provider_id: r.provider_id || provider.id || null,
        provider_phone: r.provider_phone || provider.phone || null,
        provider_address: r.provider_address || provider.address || 'No especificada',
        provider_avatar_url: r.provider_avatar_url || provider.avatar_url || null,
        provider_rating: r.provider_rating || provider.rating || null,
        
        // Propiedades del usuario (para in-progress)
        user_id: r.user_id || null,
        user_name: r.user_name || r.user?.name || 'Usuario',
        user_phone: r.user_phone || r.user?.phone || null,
        
        // Estado y pagos
        status: r.status || 'pending',
        payment_status: r.payment_status || 'pending',
        payment_methods: paymentMethods,
        
        // Detalles adicionales
        additional_details: r.additional_details || '',
        created_at: r.created_at || new Date().toISOString(),
        updated_at: r.updated_at || r.created_at || new Date().toISOString(),
        
        // URLs de imagen
        image_url: r.image_url ? `http://localhost:8000${r.image_url}` : null
      };
    },

    formatDate(d, onlyTime = false) {
      if (!d) return '';
      const locale = this.$i18n.locale.value || 'es';
      const opts = onlyTime
        ? { hour: '2-digit', minute: '2-digit', second: '2-digit' }
        : { year: 'numeric', month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit' };
      try {
        return new Date(d).toLocaleString(locale, opts);
      } catch { return d; }
    },

    formatCurrency(amount) {
      const locale = this.$i18n.locale.value || 'es';
      return new Intl.NumberFormat(locale, { style: 'currency', currency: 'USD' }).format(amount || 0);
    },

    tabClass(tab) {
      return [
        'px-4 py-2 rounded-md font-semibold cursor-pointer text-sm',
        this.activeTab === tab
          ? 'bg-blue-600 text-white shadow-md'
          : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
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

    elapsed(updatedAt) {
      if (!updatedAt) return '00:00:00';
      try {
        const seconds = Math.floor((Date.now() - new Date(updatedAt)) / 1000);
        const hours = String(Math.floor(seconds / 3600)).padStart(2, '0');
        const minutes = String(Math.floor((seconds % 3600) / 60)).padStart(2, '0');
        const secs = String(seconds % 60).padStart(2, '0');
        return `${hours}:${minutes}:${secs}`;
      } catch {
        return '00:00:00';
      }
    },

    timeline(req) {
      return [
        { status: req.status, updated_at: req.updated_at }
      ];
    },

    openChat(userId, role = 'user') {
      const request = this.inProgressRequests.find(r => r.user_id === userId);
      this.chatTarget = { id: userId, name: request?.user_name || this.$t('user'), role };
    },

    openSupportChat() {
      this.chatTarget = { id: 1, name: this.$t('support'), role: 'admin' };
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
        'support': () => { this.fetchTickets(); this.fetchFaq(); }
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
          headers: {
            Authorization: `Bearer ${auth.token}`
          }
        });
        this.availableRequests = Array.isArray(res.data?.data) ? res.data.data : [];
      } catch (e) {
        console.error(e);
        this.$swal?.fire({ icon: 'error', title: 'Error', text: e.message });
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
          headers: {
            Authorization: `Bearer ${auth.token}`
          }
        });
        this.inProgressRequests = Array.isArray(res.data?.data) ? res.data.data : [];
      } catch (e) {
        console.error(e);
        this.$swal?.fire({ icon: 'error', title: 'Error', text: e.message });
      } finally {
        this.loading.inProgress = false;
      }
    },

    async fetchHistoryRequests() {
      const now = Date.now();
      if (now - this._lastFetch.history < this._CACHE_TTL && this.historyRequests.length > 0) {
        return;
      }

      const auth = useAuthStore();
      if (!auth.token) {
        this.loading.history = false;
        return;
      }

      this.loading.history = true;
      try {
        const res = await api.get('/history', {
          headers: {
            Authorization: `Bearer ${auth.token}`
          }
        });
        const data = Array.isArray(res.data?.history) ? res.data.history : res.data || [];
        this.historyRequests = data.map(h => this.normalizeHistory(h));
        this._lastFetch.history = now;
      } catch (e) {
        console.error(e);
        this.$swal?.fire({ icon: 'error', title: 'Error', text: e.message });
      } finally {
        this.loading.history = false;
      }
    },

    async fetchTickets() {
      const now = Date.now();
      if (now - this._lastFetch.support < this._CACHE_TTL && this.tickets.length > 0) {
        return;
      }
      
      const auth = useAuthStore();
      if (!auth.token) {
        this.loading.support = false;
        return;
      }

      this.loading.support = true;
      try {
        const res = await api.get('/support/tickets', {
          headers: {
            Authorization: `Bearer ${auth.token}`
          }
        });
        this.tickets = Array.isArray(res.data?.tickets) ? res.data.tickets : res.data || [];
        this._lastFetch.support = now;
      } catch (e) {
        console.error(e);
        this.$swal?.fire({ icon: 'error', title: 'Error', text: e.message });
      } finally {
        this.loading.support = false;
      }
    },

    async fetchFaq() {
      const now = Date.now();
      if (now - this._lastFetch.faq < this._CACHE_TTL && this.faqItems.length > 0) {
        return;
      }
      
      this.loading.faq = true;
      try {
        const res = await api.get('/support/faq');
        this.faqItems = Array.isArray(res.data?.faq) ? res.data.faq : res.data || [];
        this._lastFetch.faq = now;
      } catch (e) {
        console.error(e);
        this.$swal?.fire({ icon: 'error', title: 'Error', text: e.message });
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
          useSocketStore().playNotificationSound();
          if (successMessage) this.$swal?.fire({ icon: 'success', title: 'Éxito', text: successMessage });
        }
      } catch (e) {
        console.error(e);
        this.$swal?.fire({ icon: 'error', title: 'Error', text: e.message });
      }
    },

    async acceptRequest(id) { await this.executeRequestAction(id, '/requests/accept', 'Solicitud aceptada'); },
    async rejectRequest(id) { await this.executeRequestAction(id, '/requests/reject', 'Solicitud rechazada'); },
    async busyRequest(id) { await this.executeRequestAction(id, '/requests/busy', 'Estado ocupado establecido'); },

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
          useSocketStore().playNotificationSound();
        } else {
          this.$swal?.fire({ icon: 'error', title: 'Error', text: res.data.message });
        }
      } catch (e) {
        const errorMsg = e.response?.data?.message || e.message;
        this.$swal?.fire({ icon: 'error', title: 'Error', text: errorMsg });
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
          useSocketStore().playNotificationSound();
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
  }
}
</script>

<style scoped>
.card {
  @apply bg-white rounded-lg shadow-md overflow-hidden;
}
</style>
