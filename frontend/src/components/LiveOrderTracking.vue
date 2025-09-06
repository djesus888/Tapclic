<template>
  <Teleport to="body">
    <div class="fixed inset-0 bg-white z-[60] flex flex-col">
      <!-- Header -->
      <header class="bg-blue-600 text-white px-4 py-3 flex items-center shadow z-10">
        <button @click="$emit('close')" class="mr-3 p-1 rounded-full hover:bg-blue-700">
          <svg
            class="w-6 h-6"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
          </svg>
        </button>
        <h1 class="font-semibold text-lg">{{ $t('live_tracking') }}</h1>
      </header>

      <!-- Mapa -->
      <div class="flex-1 relative">
        <iframe
          v-if="mapUrl"
          :src="mapUrl"
          class="w-full h-full border-0"
          allowfullscreen
          loading="lazy"
          referrerpolicy="no-referrer-when-downgrade"
        ></iframe>
        <div v-else class="w-full h-full bg-gray-200 grid place-items-center">
          <p class="text-gray-500">{{ $t('loading_map') }}</p>
        </div>
      </div>

      <!-- Bottom Sheet Swipeable -->
      <div
        ref="sheet"
        class="bottom-sheet bg-white rounded-t-2xl shadow-lg max-h-[70vh] overflow-y-auto"
        :style="{ transform: `translateY(${translateY}px)` }"
      >
        <!-- Drag handle -->
        <div class="drag-handle w-full h-6 flex justify-center items-center">
          <div class="w-12 h-1 bg-gray-300 rounded-full"></div>
        </div>

        <!-- Contenido -->
        <div class="p-4 space-y-3 text-sm">
          <!-- Info del proveedor -->
          <div class="flex items-center gap-3">
            <img
              :src="order.provider?.avatar_url || '/img/default-provider.png'"
              alt="Provider"
              class="w-12 h-12 rounded-full object-cover"
            />
            <div>
              <p class="font-semibold">{{ order.provider?.name || 'Proveedor' }}</p>
              <p v-if="order.provider?.rating" class="text-yellow-500">⭐ {{ order.provider.rating }}</p>
            </div>
          </div>

          <div>
            <strong>{{ $t('order_number') }}:</strong> #{{ order.id }}<br />
            <strong>{{ $t('service') }}:</strong> {{ order.serviceName || 'Servicio' }}
          </div>

          <!-- Botones -->
          <div class="flex gap-2">
            <button @click="openChat" class="flex-1 bg-blue-500 text-white rounded-md py-2">💬 {{ $t('chat') }}</button>
            <button @click="callProvider" class="flex-1 bg-green-500 text-white rounded-md py-2">📞 {{ $t('call') }}</button>
            <button @click="triggerEmergency" class="flex-1 bg-red-500 text-white rounded-md py-2">🚨 {{ $t('emergency') }}</button>
          </div>

          <!-- Detalles -->
          <h2 class="font-bold text-base pt-2">{{ $t('service_details') }}</h2>
          <div><strong>{{ $t('description') }}:</strong> {{ order.description || 'Sin descripción' }}</div>
          <div><strong>{{ $t('date') }}:</strong> {{ formatDate(order.created_at || order.date) }}</div>
          <div><strong>{{ $t('price') }}:</strong> ${{ Number(order.price || 0).toFixed(2) }}</div>
          <div><strong>{{ $t('location') }}:</strong> {{ order.address || 'No especificada' }}</div>
          <div><strong>{{ $t('payment_method') }}:</strong> {{ order.payment_method || 'No definido' }}</div>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script>
export default {
  name: 'LiveOrderTracking',
  props: {
    order: { type: Object, required: true },
  },
  emits: ['close', 'open-chat'],
  data: () => ({
    mapUrl: null,
    translateY: 0,
    startY: 0,
    dragging: false,
  }),
  mounted() {
    this.loadMap();
    this.pollStatus();
    this.addSwipeListeners();
  },
  beforeUnmount() {
    this.removeSwipeListeners();
  },
  methods: {
    loadMap() {
      const origin = encodeURIComponent(this.order.provider?.current_address || '0,0');
      const dest = encodeURIComponent(this.order.address || '0,0');
      const key = import.meta.env.VITE_GOOGLE_MAPS_KEY;
      this.mapUrl = `https://www.google.com/maps/embed/v1/directions?key=${key}&origin=${origin}&destination=${dest}&mode=driving`;
    },
    pollStatus() {
      const interval = setInterval(async () => {
        try {
          const { data } = await this.$api.get(`/requests/${this.order.id}/status`);
          this.order.status = data.status;
          if (data.status === 'arrived') {
            this.$toast?.info(this.$t('provider_arrived'));
            clearInterval(interval);
          }
        } catch {
          clearInterval(interval);
        }
      }, 15000);
    },
    openChat() {
      this.$emit('open-chat', this.order.provider);
    },
    callProvider() {
      const phone = this.order.provider?.phone;
      if (phone) window.open(`tel:${phone}`, '_self');
    },
    triggerEmergency() {
      this.$swal
        ?.fire({
          title: this.$t('emergency'),
          text: this.$t('emergency_confirm'),
          icon: 'warning',
          showCancelButton: true,
          confirmButtonColor: '#e02424',
          confirmButtonText: this.$t('confirm'),
          cancelButtonText: this.$t('cancel'),
        })
        .then(async (res) => {
          if (res.isConfirmed) {
            await this.$api.post('/emergency', { request_id: this.order.id });
            this.$toast?.success(this.$t('alert_sent'));
          }
        });
    },
    formatDate(date) {
      return new Date(date).toLocaleDateString();
    },

    // Swipe handlers
    addSwipeListeners() {
      const sheet = this.$refs.sheet;
      sheet.addEventListener('touchstart', this.onTouchStart, { passive: true });
      sheet.addEventListener('touchmove', this.onTouchMove, { passive: true });
      sheet.addEventListener('touchend', this.onTouchEnd, { passive: true });
      sheet.addEventListener('mousedown', this.onMouseDown);
    },
    removeSwipeListeners() {
      const sheet = this.$refs.sheet;
      if (!sheet) return;
      sheet.removeEventListener('touchstart', this.onTouchStart);
      sheet.removeEventListener('touchmove', this.onTouchMove);
      sheet.removeEventListener('touchend', this.onTouchEnd);
      sheet.removeEventListener('mousedown', this.onMouseDown);
      window.removeEventListener('mousemove', this.onMouseMove);
      window.removeEventListener('mouseup', this.onMouseUp);
    },
    onTouchStart(e) {
      this.startY = e.touches[0].clientY;
      this.dragging = true;
    },
    onTouchMove(e) {
      if (!this.dragging) return;
      const y = e.touches[0].clientY;
      const delta = y - this.startY;
      if (delta > 0) this.translateY = delta;
    },
    onTouchEnd() {
      if (!this.dragging) return;
      this.dragging = false;
      if (this.translateY > 120) {
        this.$emit('close');
      } else {
        this.translateY = 0;
      }
    },
    onMouseDown(e) {
      this.startY = e.clientY;
      this.dragging = true;
      window.addEventListener('mousemove', this.onMouseMove);
      window.addEventListener('mouseup', this.onMouseUp);
    },
    onMouseMove(e) {
      if (!this.dragging) return;
      const delta = e.clientY - this.startY;
      if (delta > 0) this.translateY = delta;
    },
    onMouseUp() {
      if (!this.dragging) return;
      this.dragging = false;
      window.removeEventListener('mousemove', this.onMouseMove);
      window.removeEventListener('mouseup', this.onMouseUp);
      if (this.translateY > 120) {
        this.$emit('close');
      } else {
        this.translateY = 0;
      }
    },
  },
};
</script>

<style scoped>
.bottom-sheet {
  position: fixed;
  bottom: 0;
  width: 100%;
  z-index: 70;
  transition: transform 0.3s ease;
  border-top-left-radius: 1rem;
  border-top-right-radius: 1rem;
}

.drag-handle {
  cursor: grab;
  user-select: none;
}
</style>
