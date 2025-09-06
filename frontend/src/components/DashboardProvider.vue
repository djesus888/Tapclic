<!-- DashboardProvider.vue -->
<template>
  <div class="p-4 space-y-6">
    <!-- Tabs -->
    <div class="mb-6 border-b border-gray-300 bg-white sticky top-16 z-20" style="padding-bottom: 0.25rem;">
      <nav class="flex space-x-2 justify-center max-w-md mx-auto" role="tablist" :aria-label="$t('tabs')">
        <button
          v-for="tab in tabs"
          :key="`${tab.value}-${$i18n.locale}`"
          role="tab"
          :aria-selected="activeTab === tab.value"
          :tabindex="activeTab === tab.value ? 0 : -1"
          @click="activeTab = tab.value"
          :class="tabClass(tab.value)"
        >
          {{ tab.label }}
        </button>
      </nav>
    </div>

    <!-- Available Requests -->
    <div v-if="activeTab === 'available'" class="grid gap-4 md:grid-cols-2" :key="'available-' + $i18n.locale">
      <div v-if="availableLoading" class="text-center py-10">{{ $t('loading') }}...</div>
      <div v-else-if="!availableRequests.length" class="text-center py-10 text-gray-500">
        {{ $t('no_available_requests') }}
      </div>
      <div
        v-else
        v-for="req in availableRequests"
        :key="`${req.id}-${$i18n.locale}`"
        class="bg-white rounded-lg shadow p-4 flex flex-col justify-between"
      >
        <div>
          <h3 class="text-lg font-semibold text-gray-800">{{ sanitize(req.service_title) }}</h3>
          <p class="text-sm text-gray-600">{{ sanitize(req.service_description) }}</p>
          <p class="text-sm mt-2 text-gray-500">{{ req.service_location }}</p>
          <p class="text-sm mt-2 text-gray-500">{{ sanitize(req.service_provider_name) }}</p>
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
      </div>
    </div>

    <!-- In Progress -->
    <div v-if="activeTab === 'in-progress'" class="grid gap-4 md:grid-cols-2" :key="'in-progress-' + $i18n.locale">
      <div v-if="inProgressLoading" class="text-center py-10">{{ $t('loading') }}...</div>
      <div v-else-if="!inProgressRequests.length" class="text-center py-10 text-gray-500">
        {{ $t('no_active_requests') }}
      </div>
      <div
        v-else
        v-for="req in inProgressRequests"
        :key="`${req.id}-${$i18n.locale}`"
        class="bg-white rounded-lg shadow p-4"
      >
        <h3 class="text-lg font-semibold text-gray-800">{{ sanitize(req.service_title) }}</h3>
        <p class="text-sm text-gray-600">{{ sanitize(req.service_description) }}</p>
        <p class="text-sm mt-2 text-gray-500">
          <strong>{{ $t('requested_by') }}:</strong> {{ sanitize(req.user_name || $t('user')) }}
        </p>
        <div class="flex gap-2 mt-4">
          <button
            class="bg-blue-500 text-white px-3 py-1 rounded hover:bg-blue-600"
            @click="openChat(req.user_id, 'user')"
          >
            💬
          </button>
          <button
            class="bg-green-500 text-white px-3 py-1 rounded hover:bg-green-600"
            @click="completeRequest(req.id)"
          >
            {{ $t('completed') }}
          </button>
          <button
            class="bg-red-500 text-white px-3 py-1 rounded hover:bg-red-600"
            @click="cancelRequest(req.id)"
          >
            {{ $t('cancel') }}
          </button>
        </div>
      </div>
    </div>

    <!-- Support -->
    <div v-if="activeTab === 'support'" class="p-4" :key="'support-' + $i18n.locale">
      <div v-if="faqLoading" class="text-center py-10">{{ $t('loading') }}…</div>
      <div v-else class="mb-8">
        <h2 class="text-xl font-semibold mb-4">{{ $t('faq') }}</h2>
        <div class="space-y-2">
          <details
            v-for="(item, idx) in faqItems"
            :key="`${idx}-${$i18n.locale}`"
            class="bg-white rounded-md shadow px-4 py-2"
          >
            <summary class="cursor-pointer font-medium text-left">
              {{ sanitize(item.question) }}
            </summary>
            <p class="text-sm text-gray-600 mt-2">{{ sanitize(item.answer) }}</p>
          </details>
        </div>
      </div>
      <div class="text-center">
        <button
          @click="openSupportChat"
          class="bg-blue-600 text-white rounded-md px-6 py-2 font-semibold hover:bg-blue-700"
        >
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
          <div
            v-for="ticket in tickets"
            :key="`${ticket.id}-${$i18n.locale}`"
            class="card shadow rounded-lg overflow-hidden"
          >
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
        <button
          v-show="!showNewTicket"
          :key="$i18n.locale"
          @click="showNewTicket = true"
          class="fixed bottom-6 right-6 bg-blue-600 text-white rounded-full w-14 h-14 shadow-lg flex items-center justify-center text-2xl"
          :title="$t('new_ticket')"
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

    <!-- History -->
    <div v-if="activeTab === 'history'" class="grid gap-4 md:grid-cols-2" :key="'history-' + $i18n.locale">
      <div v-if="historyLoading" class="text-center py-10">{{ $t('loading') }}...</div>
      <div v-else-if="!historyRequests.length" class="text-center py-10 text-gray-500">
        {{ $t('no_history_requests') }}
      </div>
      <div
        v-for="req in historyRequests"
        :key="`${req.id}-${$i18n.locale}`"
        class="card shadow rounded-lg overflow-hidden"
      >
        <div class="p-4 bg-gray-100">
          <h3 class="text-lg font-semibold text-gray-800">{{ sanitize(req.service_title) }}</h3>
          <p class="text-sm text-gray-600">{{ sanitize(req.service_description) }}</p>
          <p class="text-sm mt-2 text-gray-500">
            <strong>{{ $t('requested_by') }}:</strong> {{ sanitize(req.user_name || $t('user')) }}
          </p>
        </div>
        <div class="p-4 flex justify-between items-center bg-white">
          <div>
            <p class="text-sm mt-1 font-bold text-gray-700">
              {{ formatCurrency(req.service_price) }}
            </p>
            <p class="text-xs text-gray-400 mt-2">{{ formatDate(req.updated_at) }}</p>
            <p
              class="text-xs font-semibold mt-1"
              :class="{
                'text-green-600': req.status === 'completed',
                'text-red-600': req.status === 'cancelled',
                'text-orange-600': req.status === 'rejected'
              }"
            >
              {{ $t('status.' + req.status) }}
            </p>
            <p v-if="req.status === 'cancelled'" class="text-xs text-red-600 mt-1">
              {{ $t('cancelled_by') }}: {{ req.cancelled_by }}
            </p>
          </div>
          <span :class="statusColor(req.status)">{{ statusLabel(req.status) }}</span>
        </div>
      </div>
    </div>

    <!-- Chat Modal -->
    <ChatRoomModal
      v-if="chatTarget"
      :target="chatTarget"
      @close="chatTarget = null"
    />
  </div>
</template>

<script>
import api from "@/axio";
import { useAuthStore } from "@/stores/authStore";
import { useSocketStore } from "@/stores/socketStore";
import ChatRoomModal from "@/components/ChatRoomModal.vue";
import NewTicketModal from "@/components/NewTicketModal.vue";

export default {
  name: "DashboardProvider",
  components: { ChatRoomModal, NewTicketModal },
  data() {
    return {
      tabs: [
        { value: "available", label: this.$t("requests") },
        { value: "in-progress", label: this.$t("active") },
        { value: "support", label: this.$t("support") },
        { value: "history", label: this.$t("history") }
      ],
      activeTab: "available",
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
      showNewTicket: false
    };
  },
  watch: {
    '$i18n.locale': {
      immediate: true,
      handler(newLocale) {
        this.tabs = [
          { value: "available", label: this.$t("requests") },
          { value: "in-progress", label: this.$t("active") },
          { value: "support", label: this.$t("support") },
          { value: "history", label: this.$t("history") }
        ];
        
        // Forzar actualización de todas las listas cuando cambia el idioma
        this.$nextTick(() => {
          if (this.activeTab === 'available') this.fetchAvailableRequests();
          if (this.activeTab === 'in-progress') this.fetchActiveRequests();
          if (this.activeTab === 'history') this.fetchHistoryRequests();
          if (this.activeTab === 'support') {
            this.fetchTickets();
            this.fetchFaq();
          }
        });
      }
    }
  },
  async created() {
    const socketStore = useSocketStore();
    socketStore.init();
    const auth = useAuthStore();
    this.providerId = auth.user?.id;

    // Cargar locale del usuario
    auth.loadLocale();

    await this.fetchAvailableRequests();

    const fetchActiveRequests = async () => {
      if (this.inProgressRequests.length) return;
      this.inProgressLoading = true;
      try {
        const res = await api.get("/requests/active", {
          headers: { Authorization: `Bearer ${auth.token}` }
        });
        this.inProgressRequests = Array.isArray(res.data.data) ? res.data.data : [];
      } catch (err) {
        console.error("Error recargando solicitudes activas:", err);
      } finally {
        this.inProgressLoading = false;
      }
    };

    const fetchHistoryRequests = async () => {
      if (this.historyRequests.length) return;
      this.historyLoading = true;
      try {
        const res = await api.get("/requests/history", {
          headers: { Authorization: `Bearer ${auth.token}` }
        });
        this.historyRequests = Array.isArray(res.data.data) ? res.data.data : [];
      } catch (err) {
        console.error("Error recargando historial:", err);
      } finally {
        this.historyLoading = false;
      }
    };

    const fetchTickets = async () => {
      if (this.tickets.length) return;
      this.supportLoading = true;
      try {
        const res = await api.get("/support/tickets", {
          headers: { Authorization: `Bearer ${auth.token}` }
        });
        this.tickets = Array.isArray(res.data) ? res.data : res.data?.tickets || [];
      } catch (err) {
        console.error("Error cargando tickets:", err);
      } finally {
        this.supportLoading = false;
      }
    };

    const fetchFaq = async () => {
      if (this.faqItems.length) return;
      this.faqLoading = true;
      try {
        const res = await api.get("/support/faq");
        this.faqItems = Array.isArray(res.data) ? res.data : res.data?.faq || [];
      } catch (err) {
        console.error("Error cargando FAQ:", err);
      } finally {
        this.faqLoading = false;
      }
    };

    this.$watch("activeTab", (tab) => {
      if (tab === "in-progress") fetchActiveRequests();
      if (tab === "history") fetchHistoryRequests();
      if (tab === "support") {
        fetchTickets();
        fetchFaq();
      }
    });

    this.$watch(
      () => socketStore.notifications,
      (newVal) => {
        if (!newVal.length) return;
        const last = newVal[newVal.length - 1];
        if (last.type === "request.accepted" || last.type === "request.busy") {
          fetchActiveRequests();
        } else if (last.type === "request.rejected") {
          this.fetchAvailableRequests();
        } else if (last.type === "request.completed") {
          fetchHistoryRequests();
        }
      },
      { deep: true }
    );
  },
  methods: {
    playSound() {
      const socketStore = useSocketStore();
      socketStore.playNotificationSound();
    },
    sanitize(str) {
      if (!str || typeof str !== "string") return str;
      return str.replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, "");
    },
    formatDate(date) {
      const locale = this.$i18n.locale.value || 'es';
      return new Date(date).toLocaleString(locale, {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      });
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
        "px-4 py-2 rounded-md font-semibold cursor-pointer text-sm",
        this.activeTab === tab
          ? "bg-blue-600 text-white shadow-md"
          : "bg-gray-100 text-gray-700 hover:bg-gray-200"
      ];
    },
    openChat(userId, role = 'user') {
      const req = this.inProgressRequests.find(r => r.user_id === userId);
      this.chatTarget = {
        id: userId,
        name: req?.user_name || this.$t('user'),
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
    statusLabel(status) {
      const map = {
        completed: this.$t('status.completed'),
        cancelled: this.$t('status.cancelled'),
        rejected: this.$t('status.rejected')
      };
      return map[status] || status;
    },
    statusColor(status) {
      const map = {
        completed: 'text-green-600',
        cancelled: 'text-red-600',
        rejected: 'text-orange-600'
      };
      return map[status] || 'text-gray-500';
    },
    async fetchAvailableRequests() {
      if (this.availableRequests.length) return;
      this.availableLoading = true;
      try {
        const auth = useAuthStore();
        const res = await api.get("/requests/pending", {
          headers: { Authorization: `Bearer ${auth.token}` }
        });
        this.availableRequests = Array.isArray(res.data.data) ? res.data.data : [];
      } catch (err) {
        console.error(this.$t('error_fetching_pending'), err);
      } finally {
        this.availableLoading = false;
      }
    },
    async acceptRequest(id) {
      try {
        const res = await api.post("/requests/accept", { id });
        if (res.data.success) {
          this.availableRequests = this.availableRequests.filter(r => r.id !== id);
          this.playSound();
        }
      } catch (err) {
        console.error(err);
      }
    },
    async rejectRequest(id) {
      try {
        const res = await api.post("/requests/reject", { id });
        if (res.data.success) {
          this.availableRequests = this.availableRequests.filter(r => r.id !== id);
          this.playSound();
        }
      } catch (err) {
        console.error(err);
      }
    },
    async busyRequest(id) {
      try {
        const res = await api.post("/requests/busy", { id });
        if (res.data.success) {
          this.availableRequests = this.availableRequests.filter(r => r.id !== id);
          this.playSound();
        }
      } catch (err) {
        console.error(err);
      }
    },
    async completeRequest(id) {
      try {
        const auth = useAuthStore();
        const res = await api.post("/requests/finalized", { id }, {
          headers: { Authorization: `Bearer ${auth.token}` }
        });
        if (res.data.success) {
          this.inProgressRequests = this.inProgressRequests.filter(r => r.id !== id);
          await this.fetchHistoryRequests();
          this.playSound();
        } else {
          this.$swal?.fire({
            icon: 'error',
            title: this.$t('error'),
            text: res.data.message || this.$t('completion_error')
          });
        }
      } catch (err) {
        console.error(this.$t('completion_error'), err);
        this.$swal?.fire({
          icon: 'error',
          title: this.$t('error'),
          text: this.$t('completion_error')
        });
      }
    },
    async cancelRequest(id) {
      try {
        const auth = useAuthStore();
        const res = await api.post("/requests/cancel", { id }, {
          headers: { Authorization: `Bearer ${auth.token}` }
        });
        if (res.data.success) {
          const idx = this.inProgressRequests.findIndex(r => r.id === id);
          if (idx !== -1) {
            const req = this.inProgressRequests.splice(idx, 1)[0];
            this.historyRequests.unshift(req);
          }
          this.playSound();
        }
      } catch (err) {
        console.error(err);
      }
    },
    onTicketCreated() {
      this.showNewTicket = false;
      this.fetchTickets();
    }
  }
};
</script>

<style scoped>
.card {
  @apply bg-white rounded-lg shadow-md overflow-hidden;
}
</style>
