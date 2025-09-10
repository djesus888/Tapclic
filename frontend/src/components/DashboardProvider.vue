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
      <div v-if="availableLoading" class="text-center py-10">{{ $t('loading') }}…</div>
      <div v-else-if="!availableRequests.length" class="text-center py-10 text-gray-500">
        {{ $t('no_available_requests') }}
      </div>
      <div v-for="req in availableRequests" :key="`${req.id}-${$i18n.locale}`"
           class="bg-white rounded-lg shadow p-4 flex flex-col justify-between">
        <div>
          <h3 class="text-lg font-semibold text-gray-800">{{ sanitize(req.service_title) }}</h3>
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
      </div>
    </div>

    <!-- IN-PROGRESS -->
    <div v-if="activeTab === 'in-progress'" class="grid gap-4 md:grid-cols-2" :key="'in-progress-'+$i18n.locale">
      <div v-if="inProgressLoading" class="text-center py-10">{{ $t('loading') }}…</div>
      <div v-else-if="!inProgressRequests.length" class="text-center py-10 text-gray-500">
        {{ $t('no_active_requests') }}
      </div>
      <div v-for="req in inProgressRequests" :key="`${req.id}-${$i18n.locale}`"
           class="bg-white rounded-lg shadow p-4">
        <h3 class="text-lg font-semibold text-gray-800">{{ sanitize(req.service_title) }}</h3>
        <p class="text-sm text-gray-600">{{ sanitize(req.service_description) }}</p>
        <p class="text-sm mt-2 text-gray-500">
          <strong>{{ $t('requested_by') }}:</strong> {{ sanitize(req.user_name || $t('user')) }}
        </p>

        <!-- TIMELINE -->
        <details class="mt-3 text-xs">
          <summary class="cursor-pointer text-blue-600">{{ $t('timeline') }}</summary>
          <div class="mt-2 space-y-1">
            <div v-for="(l,i) in timeline(req)" :key="i" class="flex justify-between">
              <span>{{ $t('status.'+l.status) }}</span>
              <span>{{ formatDate(l.updated_at, 'time') }}</span>
            </div>
          </div>
        </details>

        <!-- TIEMPO TRANSCURRIDO -->
        <p class="text-xs text-gray-500 mt-2">{{ $t('elapsed') }}: {{ elapsed(req.updated_at) }}</p>

        <!-- ACTIONS DROPDOWN -->
        <div class="mt-4 relative">
          <button @click="toggleDropdown(req.id)"
                  class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 w-full flex items-center justify-between">
            {{ $t('actions') }}
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

        <!-- CHAT -->
        <div class="flex gap-2 mt-4">
          <button class="bg-blue-500 text-white px-3 py-1 rounded hover:bg-blue-600"
                  @click="openChat(req.user_id, 'user')">💬</button>
        </div>
      </div>
    </div>

    <!-- SUPPORT -->
    <div v-if="activeTab === 'support'" class="p-4" :key="'support-'+$i18n.locale">
      <div v-if="faqLoading" class="text-center py-10">{{ $t('loading') }}…</div>
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
      <div v-if="supportLoading" class="text-center py-10 mt-8">{{ $t('loading') }}…</div>
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

    <!-- HISTORY -->
    <div v-if="activeTab === 'history'" class="grid gap-4 md:grid-cols-2" :key="'history-'+$i18n.locale">
      <div v-if="historyLoading" class="text-center py-10">{{ $t('loading') }}…</div>
      <div v-else-if="!historyRequests.length" class="text-center py-10 text-gray-500">
        {{ $t('no_history_requests') }}
      </div>
      <div v-for="req in historyRequests" :key="`${req.id}-${$i18n.locale}`"
           class="card shadow rounded-lg overflow-hidden">
        <div class="p-4 bg-gray-100">
          <h3 class="text-lg font-semibold text-gray-800">{{ sanitize(req.service_title) }}</h3>
          <p class="text-sm text-gray-600">{{ sanitize(req.service_description) }}</p>
          <p class="text-sm mt-2 text-gray-500">
            <strong>{{ $t('requested_by') }}:</strong> {{ sanitize(req.user_name || $t('user')) }}
          </p>
        </div>
        <div class="p-4 flex justify-between items-center bg-white">
          <div>
            <p class="text-sm mt-1 font-bold text-gray-700">{{ formatCurrency(req.service_price) }}</p>
            <p class="text-xs text-gray-400 mt-2">{{ formatDate(req.updated_at) }}</p>
            <p class="text-xs font-semibold mt-1"
               :class="{'text-green-600':req.status==='completed','text-red-600':req.status==='cancelled','text-orange-600':req.status==='rejected'}">
              {{ $t('status.'+req.status) }}
            </p>
            <p v-if="req.status === 'cancelled'" class="text-xs text-red-600 mt-1">
              {{ $t('cancelled_by') }}: {{ req.cancelled_by }}
            </p>
          </div>
          <span :class="statusColor(req.status)">{{ statusLabel(req.status) }}</span>
        </div>
      </div>
    </div>

    <!-- CHAT MODAL -->
    <ChatRoomModal v-if="chatTarget" :target="chatTarget" @close="chatTarget = null"/>
  </div>
</template>

<script>
import api from '@/axio'
import {useAuthStore} from '@/stores/authStore'
import {useSocketStore} from '@/stores/socketStore'
import ChatRoomModal from '@/components/ChatRoomModal.vue'
import NewTicketModal from '@/components/NewTicketModal.vue'

export default {
  name: 'DashboardProvider',
  components: {ChatRoomModal, NewTicketModal},
  data() {
    return {
      tabs: [],
      activeTab: 'available',
      availableRequests: [],
      inProgressRequests: [],
      historyRequests: [],
      chatTarget: null,
      providerId: null,
      availableLoading: false,
      inProgressLoading: false,
      historyLoading: false,
      supportLoading: false,
      faqLoading: false,
      tickets: [],
      faqItems: [],
      showNewTicket: false,
      openDropdown: null,
      pulling: false,
      pullStartY: 0
    }
  },
  watch: {
    '$i18n.locale': {
      immediate: true,
      handler() {
        this.tabs = [
          {value: 'available', label: this.$t('requests')},
          {value: 'in-progress', label: this.$t('active')},
          {value: 'support', label: this.$t('support')},
          {value: 'history', label: this.$t('history')}
        ]
        this.$nextTick(() => {
          if (this.activeTab === 'available') this.fetchAvailableRequests()
          if (this.activeTab === 'in-progress') this.fetchActiveRequests()
          if (this.activeTab === 'history') this.fetchHistoryRequests()
          if (this.activeTab === 'support') { this.fetchTickets(); this.fetchFaq() }
        })
      }
    }
  },
  async created() {
    const auth = useAuthStore()
    const socket = useSocketStore()
    socket.init()
    this.providerId = auth.user?.id
    auth.loadLocale()
    await this.fetchAvailableRequests()

    socket.on('request.status_changed', (msg) => {
      if (msg.provider_id !== this.providerId) return
      this.updateRequestStatus(msg.request_id, msg.status, msg.updated_at)
      this.playSound()
    })

    this.$watch('activeTab', tab => {
      if (tab === 'in-progress') this.fetchActiveRequests()
      if (tab === 'history') this.fetchHistoryRequests()
      if (tab === 'support') { this.fetchTickets(); this.fetchFaq() }
    })
  },
  methods: {
    /*  PULL-TO-REFRESH  */
    pullStart(e) { this.pulling = true; this.pullStartY = e.clientY },
    pullMove(e) {
      if (!this.pulling) return
      const dy = e.clientY - this.pullStartY
      if (dy > 120) { this.pulling = false; this.syncRequests() }
    },
    pullEnd() { this.pulling = false },
    syncRequests() {
      if (this.activeTab === 'available') this.fetchAvailableRequests()
      if (this.activeTab === 'in-progress') this.fetchActiveRequests()
      if (this.activeTab === 'history') this.fetchHistoryRequests()
    },

    /*  HELPERS  */
    sanitize(str) { return (str || '').replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '') },
    formatDate(d, onlyTime) {
      const locale = this.$i18n.locale.value || 'es'
      const opts = onlyTime ? {hour: '2-digit', minute: '2-digit', second: '2-digit'}
                            : {year: 'numeric', month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit'}
      return new Date(d).toLocaleString(locale, opts)
    },
    formatCurrency(amount) {
      const locale = this.$i18n.locale.value || 'es'
      return new Intl.NumberFormat(locale, {style: 'currency', currency: 'USD'}).format(amount || 0)
    },
    tabClass(tab) {
      return ['px-4 py-2 rounded-md font-semibold cursor-pointer text-sm',
        this.activeTab === tab ? 'bg-blue-600 text-white shadow-md' : 'bg-gray-100 text-gray-700 hover:bg-gray-200']
    },
    openChat(userId, role = 'user') {
      const req = this.inProgressRequests.find(r => r.user_id === userId)
      this.chatTarget = {id: userId, name: req?.user_name || this.$t('user'), role}
    },
    openSupportChat() {
      this.chatTarget = {id: 1, name: this.$t('support'), role: 'admin'}
    },
    statusLabel(s) { return this.$t('status.' + s) || s },
    statusColor(s) {
      const map = {completed: 'text-green-600', cancelled: 'text-red-600', rejected: 'text-orange-600'}
      return map[s] || 'text-gray-500'
    },
    toggleDropdown(id) { this.openDropdown = this.openDropdown === id ? null : id },
    emoji(st) {
      const map = {accepted: '👍', rejected: '👎', in_progress: '📦', on_the_way: '🚚', arrived: '📍', completed: '✅', cancelled: '❌'}
      return map[st] || '•'
    },
    allowedNext(status) {
      const flow = {
        pending: ['accepted', 'rejected'],
        accepted: ['in_progress', 'cancelled'],
        in_progress: ['on_the_way', 'cancelled'],
        on_the_way: ['arrived', 'cancelled'],
        arrived: ['completed', 'cancelled'],
        completed: [],
        cancelled: [],
        rejected: []
      }
      return flow[status] || []
    },
    elapsed(updatedAt) {
      const s = Math.floor((Date.now() - new Date(updatedAt)) / 1000)
      const h = String(Math.floor(s / 3600)).padStart(2, '0')
      const m = String(Math.floor((s % 3600) / 60)).padStart(2, '0')
      const sec = String(s % 60).padStart(2, '0')
      return `${h}:${m}:${sec}`
    },
    timeline(req) {
      return [{status: req.status, updated_at: req.updated_at}]
    },

    /*  CRUD  */
    async fetchAvailableRequests() {
      if (this.availableRequests.length) return
      this.availableLoading = true
      try {
        const auth = useAuthStore()
        const res = await api.get('/requests/pending', {headers: {Authorization: `Bearer ${auth.token}`}})
        this.availableRequests = Array.isArray(res.data.data) ? res.data.data : []
      } catch (e) { console.error(e) } finally { this.availableLoading = false }
    },
    async fetchActiveRequests() {
      if (this.inProgressRequests.length) return
      this.inProgressLoading = true
      try {
        const auth = useAuthStore()
        const res = await api.get('/requests/active', {headers: {Authorization: `Bearer ${auth.token}`}})
        this.inProgressRequests = Array.isArray(res.data.data) ? res.data.data : []
      } catch (e) { console.error(e) } finally { this.inProgressLoading = false }
    },
    async fetchHistoryRequests() {
      if (this.historyRequests.length) return
      this.historyLoading = true
      try {
        const auth = useAuthStore()
        const res = await api.get('/requests/history', {headers: {Authorization: `Bearer ${auth.token}`}})
        this.historyRequests = Array.isArray(res.data.data) ? res.data.data : []
      } catch (e) { console.error(e) } finally { this.historyLoading = false }
    },
    async fetchTickets() {
      if (this.tickets.length) return
      this.supportLoading = true
      try {
        const auth = useAuthStore()
        const res = await api.get('/support/tickets', {headers: {Authorization: `Bearer ${auth.token}`}})
        this.tickets = Array.isArray(res.data) ? res.data : res.data?.tickets || []
      } catch (e) { console.error(e) } finally { this.supportLoading = false }
    },
    async fetchFaq() {
      if (this.faqItems.length) return
      this.faqLoading = true
      try {
        const res = await api.get('/support/faq')
        this.faqItems = Array.isArray(res.data) ? res.data : res.data?.faq || []
      } catch (e) { console.error(e) } finally { this.faqLoading = false }
    },
    async acceptRequest(id) {
      try {
        const res = await api.post('/requests/accept', {id})
        if (res.data.success) {
          this.availableRequests = this.availableRequests.filter(r => r.id !== id)
          this.playSound()
        }
      } catch (e) { console.error(e) }
    },
    async rejectRequest(id) {
      try {
        const res = await api.post('/requests/reject', {id})
        if (res.data.success) {
          this.availableRequests = this.availableRequests.filter(r => r.id !== id)
          this.playSound()
        }
      } catch (e) { console.error(e) }
    },
    async busyRequest(id) {
      try {
        const res = await api.post('/requests/busy', {id})
        if (res.data.success) {
          this.availableRequests = this.availableRequests.filter(r => r.id !== id)
          this.playSound()
        }
      } catch (e) { console.error(e) }
    },
    async setStatus(requestId, newStatus) {
      try {
        const auth = useAuthStore()
        const endpoint = `/requests/${newStatus}`
        const res = await api.post(endpoint, {id: requestId}, {headers: {Authorization: `Bearer ${auth.token}`}})
        if (res.data.success) {
          this.updateRequestStatus(requestId, newStatus, res.data.updated_at || new Date().toISOString())
          this.openDropdown = null
          this.playSound()
        }
      } catch (e) { console.error(e) }
    },
    updateRequestStatus(requestId, newStatus, updatedAt) {
      const idx = this.inProgressRequests.findIndex(r => r.id === requestId)
      if (idx === -1) return
      this.inProgressRequests[idx].status = newStatus
      this.inProgressRequests[idx].updated_at = updatedAt
    },
    onTicketCreated() { this.showNewTicket = false; this.fetchTickets() },
    playSound() {
      const socket = useSocketStore()
      socket.playNotificationSound()
    }
  }
}
</script>

<style scoped>
.card {@apply bg-white rounded-lg shadow-md overflow-hidden}
</style>
