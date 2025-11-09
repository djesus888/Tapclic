<template>
  <div class="p-4 space-y-6"
       @pointerdown="pullStart"
       @pointermove="pullMove"
       @pointerup="pullEnd"
       @pointercancel="pullEnd"
       ref="pullArea">

    <!-- TABS -->
    <div class="mb-6 border-b border-gray-300 bg-white sticky top-16 z-20 pb-1">
      <nav class="flex space-x-2 justify-center max-w-md mx-auto" role="tablist" :aria-label="$t('tabs')">
        <button v-for="tab in tabs" :key="`${tab.value}-${$i18n.locale}`"
                role="tab"
                :aria-selected="activeTab === tab.value"
                :tabindex="activeTab === tab.value ? 0 : -1"
                @click="activeTab = tab.value"
                :class="tabClass(tab.value)">
          {{ tab.label }}
        </button>
      </nav>
    </div>

    <!-- PULL-TO-REFRESH INDICATOR -->
    <div v-if="pulling" class="text-center text-sm text-gray-500 mb-2">
      {{ $t('release_to_refresh') }}
    </div>

    <!-- AVAILABLE -->
    <div v-if="activeTab === 'available'" class="grid gap-4 md:grid-cols-2" :key="'available-'+$i18n.locale">
      <div v-if="loading.available" class="text-center py-10">{{ $t('loading') }}…</div>
      <div v-else-if="!availableRequests.length" class="text-center py-10 text-gray-500">
        {{ $t('no_available_requests') }}
      </div>
      <div v-for="req in availableRequests" :key="`${req.id}-${$i18n.locale}`"
           class="bg-white rounded-lg shadow p-4 flex flex-col justify-between">
        <div>
          <div class="flex items-center justify-between mb-2">
            <h3 class="text-lg font-semibold text-gray-800">{{ sanitize(req.service_title) }}</h3>
            <PaymentPill :status="req.payment_status" />
          </div>
          <p class="text-sm text-gray-600">{{ sanitize(req.service_description) }}</p>
          <p class="text-sm mt-2 text-gray-500">{{ req.service_location }}</p>
          <p class="text-sm mt-2 text-gray-500">{{ sanitize(req.service_provider_name) }}</p>
          <p class="text-sm mt-1 font-bold text-green-600">{{ formatCurrency(req.service_price) }}</p>
        </div>
        <div class="flex gap-2 mt-4">
          <button class="bg-green-500 text-white px-3 py-1 rounded hover:bg-green-600"
                  @click="acceptRequest(req.id)">{{ $t('accept') }}</button>
          <button class="bg-red-500 text-white px-3 py-1 rounded hover:bg-red-600"
                  @click="rejectRequest(req.id)">{{ $t('reject') }}</button>
          <button class="bg-yellow-500 text-white px-3 py-1 rounded hover:bg-yellow-600"
                  @click="busyRequest(req.id)">{{ $t('busy') }}</button>
        </div>
        <div v-if="req.additional_details?.trim()" class="mt-3 text-sm text-gray-700 bg-yellow-50 border border-yellow-200 rounded p-2 flex items-start gap-2">
          <span class="text-yellow-600 text-base">🔔</span>
          <span class="whitespace-pre-wrap break-words">{{ req.additional_details }}</span>
        </div>
      </div>
    </div>

    <!-- IN-PROGRESS -->
    <div v-if="activeTab === 'in-progress'" class="grid gap-4 md:grid-cols-2" :key="'in-progress-'+$i18n.locale">
      <div v-if="loading.inProgress" class="text-center py-10">{{ $t('loading') }}…</div>
      <div v-else-if="!inProgressRequests.length" class="text-center py-10 text-gray-500">
        {{ $t('no_active_requests') }}
      </div>
      <div v-for="req in inProgressRequests" :key="`${req.id}-${$i18n.locale}`"
           class="bg-white rounded-lg shadow p-4">
        <div class="flex items-center justify-between mb-2">
          <h3 class="text-lg font-semibold text-gray-800">{{ sanitize(req.service_title) }}</h3>
          <PaymentPill :status="req.payment_status" />
        </div>
        <p class="text-sm text-gray-600">{{ sanitize(req.service_description) }}</p>
        <p class="text-sm mt-2 text-gray-500">
          <strong>{{ $t('requested_by') }}:</strong> {{ sanitize(req.user_name || $t('user')) }}
        </p>
        <!-- CANCELLED BY -->
        <p v-if="req.status === 'cancelled' && req.cancelled_by" class="text-xs text-red-600 mt-1">
          {{ $t('cancelled_by') }}: {{ req.cancelled_by }}
        </p>

        <!-- BOTÓN CONFIRMAR PAGO (solo si está en verificación) -->
        <div v-if="req.payment_status === 'verifying'" class="mt-3">
          <button
            class="bg-orange-500 text-white px-3 py-1 rounded hover:bg-orange-600"
            @click="openProofModal(req.id)">
            👁️ {{ $t('see_proof') }}
          </button>
        </div>

        <details class="mt-3 text-xs">
          <summary class="cursor-pointer text-blue-600">{{ $t('timeline') }}</summary>
          <div class="mt-2 space-y-1">
            <div v-for="(l,i) in timeline(req)" :key="i" class="flex justify-between">
              <span>{{ $t(l.status) }}</span>
              <span>{{ formatDate(l.updated_at, 'time') }}</span>
            </div>
          </div>
        </details>
        <p class="text-xs text-gray-500 mt-2">{{ $t('elapsed') }}: {{ elapsed(req.updated_at) }}</p>
        <div class="mt-4 relative">
          <button @click="toggleDropdown(req.id)"
                  class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 w-full flex items-center justify-between">
            {{ $t('status') }}
            <svg class="w-4 h-4 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
            </svg>
          </button>
          <div v-if="openDropdown === req.id"
               class="absolute right-0 mt-2 w-full bg-white border border-gray-200 rounded-lg shadow-lg z-20">
            <button v-for="st in allowedNext(req.status)" :key="st"
                    class="block w-full text-left px-4 py-2 hover:bg-gray-100"
                    @click="setStatus(req.id, st)">
              {{ emoji(st) }} {{ $t('status.'+st) }}
            </button>
          </div>
        </div>
        <div class="flex gap-2 mt-4">
          <button class="bg-blue-500 text-white px-3 py-1 rounded hover:bg-blue-600"
                  @click="openChat(req.user_id, 'user')">💬</button>
        </div>
      </div>
    </div>

    <!-- SUPPORT -->
    <div v-if="activeTab === 'support'" class="p-4" :key="'support-'+$i18n.locale">
      <div v-if="loading.faq" class="text-center py-10">{{ $t('loading') }}…</div>
      <div v-else class="mb-8">
        <h2 class="text-xl font-semibold mb-4">{{ $t('faq') }}</h2>
        <div class="space-y-2">
          <details v-for="(item, idx) in faqItems" :key="`${idx}-${$i18n.locale}`"
                   class="bg-white rounded-md shadow px-4 py-2">
            <summary class="cursor-pointer font-medium text-left">{{ sanitize(item.question) }}</summary>
            <p class="text-sm text-gray-600 mt-2">{{ sanitize(item.answer) }}</p>
          </details>
        </div>
      </div>
      <div class="text-center">
        <button @click="openSupportChat"
                class="bg-blue-600 text-white rounded-md px-6 py-2 font-semibold hover:bg-blue-700">
          💬 {{ $t('contact_support') }}
        </button>
      </div>
      <div v-if="loading.support" class="text-center py-10 mt-8">{{ $t('loading') }}…</div>
      <div v-else class="mt-8">
        <h2 class="text-xl font-semibold mb-4">{{ $t('my_tickets') }}</h2>
        <div v-if="tickets.length === 0" class="text-center text-gray-500 py-10">
          {{ $t('no_support_tickets') }}
        </div>
        <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          <div v-for="ticket in tickets" :key="`${ticket.id}-${$i18n.locale}`"
               class="card shadow rounded-lg overflow-hidden">
            <div class="p-4 bg-gray-100">
              <h2 class="font-bold text-lg truncate">{{ sanitize(ticket.subject) }}</h2>
              <p class="text-sm text-gray-600 truncate">{{ sanitize(ticket.last_message) }}</p>
            </div>
            <div class="p-4 flex justify-between items-center bg-white">
              <span :class="statusColor(ticket.status)">{{ statusLabel(ticket.status) }}</span>
              <span class="text-sm text-gray-500">{{ formatDate(ticket.updated_at) }}</span>
            </div>
          </div>
        </div>
        <button v-show="!showNewTicket" @click="showNewTicket = true"
                class="fixed bottom-6 right-6 bg-blue-600 text-white rounded-full w-14 h-14 shadow-lg flex items-center justify-center text-2xl"
                :title="$t('new_ticket')">+</button>
        <NewTicketModal v-if="showNewTicket" :is-open="showNewTicket"
                        @close="showNewTicket = false"
                        @ticket-created="onTicketCreated"/>
      </div>
    </div>

    <!-- HISTORY (LISTA) -->
    <div v-if="activeTab === 'history'" class="space-y-2" :key="'history-'+$i18n.locale">
      <div v-if="loading.history" class="text-center py-10">{{ $t('loading') }}…</div>
      <div v-else-if="!historyRequests.length" class="text-center py-10 text-gray-500">
        {{ $t('no_history_requests') }}
      </div>
      <div v-for="req in historyRequests" :key="req.id"
           class="flex items-center justify-between p-3 bg-white rounded shadow hover:bg-gray-50 cursor-pointer"
           @click="openHistoryModal(req)">
        <div class="flex-1">
          <p class="font-semibold text-gray-800">{{ sanitize(req.service_title) }}</p>
          <p class="text-sm" :class="statusColor(req.status)">{{ $t('status.'+req.status) }}</p>
          <p class="text-xs text-gray-500 mt-1">
            <PaymentPill :status="req.payment_status" />
          </p>
        </div>
        <div class="text-right">
          <p class="font-bold text-green-600">{{ formatCurrency(req.service_price) }}</p>
        </div>
      </div>
    </div>

    <!-- MODALES -->
    <ProofModal v-if="showProofModal"
                :request-id="proofModalRequestId"
                @close="onProofModalClose" />
    <NewTicketModal v-if="showNewTicket" :is-open="showNewTicket"
                    @close="showNewTicket = false"
                    @ticket-created="onTicketCreated"/>
    <ChatRoomModal v-if="chatTarget" :target="chatTarget" @close="chatTarget = null" />
  </div>
</template>

<script>
import api from '@/axios'
import { useAuthStore } from '@/stores/authStore'
import { useSocketStore } from '@/stores/socketStore'
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
      _unsubscribeListeners: []
    }
  },

  watch: {
    '$i18n.locale': {
      immediate: true,
      handler() {
        this.tabs = [
          { value: 'available',   label: this.$t('requests') },
          { value: 'in-progress', label: this.$t('active') },
          { value: 'support',     label: this.$t('support') },
          { value: 'history',     label: this.$t('history') }
        ]
        if (this.providerId) {
          this.$nextTick(() => this.syncRequests())
        }
      }
    }
  },

  async mounted() {
    const auth = useAuthStore()
    const socketStore = useSocketStore()
    if (!socketStore.socket?.connected) socketStore.init()

    this.setupSocketListeners(socketStore)
    this.providerId = auth.user?.id
    await auth.loadLocale()
    await this.fetchAvailableRequests()

    this.$watch('activeTab', () => this.syncRequests())
  },

  beforeUnmount() {
    this.cleanupSocketListeners()
    this.resetModals()
  },

  methods: {
    /* ----------  Socket  ---------- */
    setupSocketListeners(socketStore) {
      const onRequestUpdated = ({ request }) => {
        this.handleRequestUpdate(request)
        socketStore.playNotificationSound()
      }
      const onPaymentUpdated = ({ request_id, payment_status }) => {
        this.handlePaymentUpdate(request_id, payment_status)
      }
      this._unsubscribeListeners = [
        socketStore.on('request_updated', onRequestUpdated),
        socketStore.on('payment_updated', onPaymentUpdated)
      ]
      this._socketHandlers = { onRequestUpdated, onPaymentUpdated }
    },

    cleanupSocketListeners() {
      this._unsubscribeListeners?.forEach(fn => { if (typeof fn === 'function') fn() })
      this._unsubscribeListeners = []
      this._socketHandlers = null
    },

    handleRequestUpdate(request) {
      if (['accepted', 'rejected', 'busy'].includes(request.status)) {
        this.availableRequests = this.availableRequests.filter(r => r.id !== request.id)
      }
      const idx = this.inProgressRequests.findIndex(r => r.id === request.id)
      if (idx >= 0) {
        // ✅ Vue 3: asignación directa
        this.inProgressRequests[idx] = request
      } else {
        this.inProgressRequests.unshift(request)
      }
      if (['completed', 'cancelled', 'rejected', 'finalized'].includes(request.status)) {
        this.updateHistory(request)
      }
    },

    handlePaymentUpdate(request_id, payment_status) {
      const req = this.inProgressRequests.find(r => r.id === request_id)
      if (req) req.payment_status = payment_status
    },

    updateHistory(request) {
      const hIdx = this.historyRequests.findIndex(h => h.id === request.id)
      const normalized = this.normalizeHistory(request)
      if (hIdx >= 0) {
        this.historyRequests[hIdx] = normalized
      } else {
        this.historyRequests.unshift(normalized)
      }
    },

    /* ----------  Utils  ---------- */
    resetModals() {
      this.chatTarget = null
      this.showNewTicket = false
      this.openDropdown = null
      this.showProofModal = false
      this.proofModalRequestId = null
      this.historyModal = false
      this.selectedHistory = {}
    },

    sanitize(str) {
      if (!str || typeof str !== 'string') return str
      const tempDiv = document.createElement('div')
      tempDiv.textContent = str
      return tempDiv.innerHTML
        .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
        .replace(/on\w+="[^"]*"/g, '')
        .replace(/on\w+='[^']*'/g, '')
        .replace(/javascript:/gi, '')
    },

    parsePaymentMethods(raw) {
      try {
        if (Array.isArray(raw)) return raw
        if (typeof raw === 'string') return JSON.parse(raw)
        return []
      } catch {
        return []
      }
    },

    normalizeHistory(h) {
      return { ...h, payment_methods: this.parsePaymentMethods(h.payment_methods) }
    },

    formatDate(d, onlyTime = false) {
      if (!d) return ''
      const locale = this.$i18n.locale.value || 'es'
      const opts = onlyTime
        ? { hour: '2-digit', minute: '2-digit', second: '2-digit' }
        : { year: 'numeric', month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit' }
      try {
        return new Date(d).toLocaleString(locale, opts)
      } catch {
        return d
      }
    },

    formatCurrency(amount) {
      const locale = this.$i18n.locale.value || 'es'
      return new Intl.NumberFormat(locale, { style: 'currency', currency: 'USD' }).format(amount || 0)
    },

    /* ----------  UI  ---------- */
    tabClass(tab) {
      return [
        'px-4 py-2 rounded-md font-semibold cursor-pointer text-sm',
        this.activeTab === tab
          ? 'bg-blue-600 text-white shadow-md'
          : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
      ]
    },

    statusLabel(status) {
      const key = 'status.' + status
      const translated = this.$t(key)
      return translated === key ? status : translated
    },

    statusColor(status) {
      return STATUS_COLORS[status] || 'text-gray-500'
    },

    emoji(status) {
      return STATUS_EMOJIS[status] || '•'
    },

    allowedNext(status) {
      return STATUS_FLOW[status] || []
    },

    toggleDropdown(id) {
      this.openDropdown = this.openDropdown === id ? null : id
    },

    elapsed(updatedAt) {
      if (!updatedAt) return '00:00:00'
      try {
        const seconds = Math.floor((Date.now() - new Date(updatedAt)) / 1000)
        const hours = String(Math.floor(seconds / 3600)).padStart(2, '0')
        const minutes = String(Math.floor((seconds % 3600) / 60)).padStart(2, '0')
        const secs = String(seconds % 60).padStart(2, '0')
        return `${hours}:${minutes}:${secs}`
      } catch {
        return '00:00:00'
      }
    },

    /* FIX: función que faltaba */
    timeline(req) {
      return [
        { status: req.status, updated_at: req.updated_at }
      ]
    },

    /* ----------  Chat  ---------- */
    openChat(userId, role = 'user') {
      const request = this.inProgressRequests.find(r => r.user_id === userId)
      this.chatTarget = { id: userId, name: request?.user_name || this.$t('user'), role }
    },
    openSupportChat() {
      this.chatTarget = { id: 1, name: this.$t('support'), role: 'admin' }
    },

    /* ----------  Modals  ---------- */
    openHistoryModal(request) {
      this.selectedHistory = request
      this.historyModal = true
    },
    closeHistoryModal() {
      this.historyModal = false
      this.selectedHistory = {}
    },
    openProofModal(requestId) {
      this.proofModalRequestId = requestId
      this.showProofModal = true
    },
    onProofModalClose() {
      this.showProofModal = false
      this.fetchActiveRequests()
    },

    /* ----------  Data Fetching  ---------- */
    syncRequests() {
      const fetchMap = {
        'available': () => this.fetchAvailableRequests(),
        'in-progress': () => this.fetchActiveRequests(),
        'history': () => this.fetchHistoryRequests(),
        'support': () => { this.fetchTickets(); this.fetchFaq(); }
      }
      fetchMap[this.activeTab]?.()
    },

    pullStart(e) {
      this.pulling = true
      this.pullStartY = e.touches ? e.touches[0].clientY : e.clientY
    },
    pullMove(e) {
      if (!this.pulling) return
      const y = e.touches ? e.touches[0].clientY : e.clientY
      const deltaY = y - this.pullStartY
      if (deltaY > 120) { this.pulling = false; this.syncRequests(); }
    },
    pullEnd() {
      this.pulling = false
    },

    async fetchAvailableRequests() {
      this.loading.available = true
      try {
        const auth = useAuthStore()
        const res = await api.get('/requests/pending', {
          headers: { Authorization: `Bearer ${auth.token}` }
        })
        this.availableRequests = Array.isArray(res.data?.data) ? res.data.data : []
      } catch (e) {
        console.error(e)
        this.$swal?.fire({ icon: 'error', title: 'Error', text: e.message })
      } finally {
        this.loading.available = false
      }
    },

    async fetchActiveRequests() {
      this.loading.inProgress = true
      try {
        const auth = useAuthStore()
        const res = await api.get('/requests/active', {
          headers: { Authorization: `Bearer ${auth.token}` }
        })
        this.inProgressRequests = Array.isArray(res.data?.data) ? res.data.data : []
      } catch (e) {
        console.error(e)
        this.$swal?.fire({ icon: 'error', title: 'Error', text: e.message })
      } finally {
        this.loading.inProgress = false
      }
    },

    async fetchHistoryRequests() {
      this.loading.history = true
      try {
        const auth = useAuthStore()
        const res = await api.get('/history', {
          headers: { Authorization: `Bearer ${auth.token}` }
        })
        const data = Array.isArray(res.data?.history) ? res.data.history : res.data || []
        this.historyRequests = data.map(h => this.normalizeHistory(h))
      } catch (e) {
        console.error(e)
        this.$swal?.fire({ icon: 'error', title: 'Error', text: e.message })
      } finally {
        this.loading.history = false
      }
    },

    async fetchTickets() {
      if (this.tickets.length > 0) return
      this.loading.support = true
      try {
        const auth = useAuthStore()
        const res = await api.get('/support/tickets', {
          headers: { Authorization: `Bearer ${auth.token}` }
        })
        this.tickets = Array.isArray(res.data?.tickets) ? res.data.tickets : res.data || []
      } catch (e) {
        console.error(e)
        this.$swal?.fire({ icon: 'error', title: 'Error', text: e.message })
      } finally {
        this.loading.support = false
      }
    },

    async fetchFaq() {
      if (this.faqItems.length > 0) return
      this.loading.faq = true
      try {
        const res = await api.get('/support/faq')
        this.faqItems = Array.isArray(res.data?.faq) ? res.data.faq : res.data || []
      } catch (e) {
        console.error(e)
        this.$swal?.fire({ icon: 'error', title: 'Error', text: e.message })
      } finally {
        this.loading.faq = false
      }
    },

    /* ----------  Actions  ---------- */
    async executeRequestAction(id, endpoint, successMessage = null) {
      try {
        const res = await api.post(endpoint, { id })
        if (res.data.success) {
          this.availableRequests = this.availableRequests.filter(r => r.id !== id)
          useSocketStore().playNotificationSound()
          if (successMessage) {
            this.$swal?.fire({ icon: 'success', title: 'Éxito', text: successMessage })
          }
        }
      } catch (e) {
        console.error(e)
        this.$swal?.fire({ icon: 'error', title: 'Error', text: e.message })
      }
    },

    async acceptRequest(id) {
      await this.executeRequestAction(id, '/requests/accept', 'Solicitud aceptada')
    },

    async rejectRequest(id) {
      await this.executeRequestAction(id, '/requests/reject', 'Solicitud rechazada')
    },

    async busyRequest(id) {
      await this.executeRequestAction(id, '/requests/busy', 'Estado ocupado establecido')
    },

    async setStatus(requestId, newStatus) {
      try {
        const auth = useAuthStore()
        const res = await api.post(`/requests/${newStatus}`, { id: requestId }, {
          headers: { Authorization: `Bearer ${auth.token}` }
        })
        if (res.data.success) {
          this.updateRequestStatus(requestId, newStatus, res.data.updated_at || new Date().toISOString())
          this.openDropdown = null
          useSocketStore().playNotificationSound()
        }
      } catch (e) {
        console.error(e)
        this.$swal?.fire({ icon: 'error', title: 'Error', text: e.message })
      }
    },

    updateRequestStatus(requestId, newStatus, updatedAt) {
      const index = this.inProgressRequests.findIndex(r => r.id === requestId)
      if (index === -1) return
      // ✅ Vue 3: asignación directa
      this.inProgressRequests[index].status = newStatus
      this.inProgressRequests[index].updated_at = updatedAt
    },

    async confirmPayment(requestId) {
      try {
        const auth = useAuthStore()
        const res = await api.post('/requests/confirm-payment', { id: requestId }, {
          headers: { Authorization: `Bearer ${auth.token}` }
        })
        if (res.data.success) {
          const index = this.inProgressRequests.findIndex(r => r.id === requestId)
          if (index !== -1) {
            this.inProgressRequests[index].payment_status = 'paid'
          }
          useSocketStore().playNotificationSound()
        }
      } catch (e) {
        this.$swal?.fire({
          icon: 'error',
          title: 'Error',
          text: this.$t('error_confirming_payment') || 'Error confirmando pago'
        })
      }
    },

    onTicketCreated() {
      this.showNewTicket = false
      this.fetchTickets()
    }
  }
}
</script>

<style scoped>
.card {
  @apply bg-white rounded-lg shadow-md overflow-hidden;
}
.pull-indicator {
  transition: transform 0.3s ease;
}
.pull-indicator.pulling {
  transform: translateY(50px);
}
</style>
