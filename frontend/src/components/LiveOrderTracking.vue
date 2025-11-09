<template>
  <Teleport to="body">
    <div class="fixed inset-0 bg-white z-[60] flex flex-col">
      <!-- Header -->
      <header class="bg-blue-600 text-white px-4 py-3 flex items-center shadow z-10">
        <button @click="$emit('close')" class="mr-3 p-1 rounded-full hover:bg-blue-700">
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
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

      <!-- Bottom Sheet -->
      <div
        ref="sheet"
        class="bottom-sheet bg-white rounded-t-2xl shadow-lg max-h-[70vh] overflow-y-auto"
        :style="{ transform: `translateY(${translateY}px)` }"
      >
        <div class="drag-handle w-full h-6 flex justify-center items-center">
          <div class="w-12 h-1 bg-gray-300 rounded-full"></div>
        </div>

        <!-- Timeline -->
        <div class="px-4 py-3 bg-gray-50 rounded-lg mb-4">
          <div class="flex items-center justify-between relative">
            <div class="absolute top-5 left-0 right-0 h-1 bg-gray-300 -z-10"></div>
            <div v-for="(step, idx) in timelineSteps" :key="step.key" class="flex flex-col items-center z-10">
              <div
                class="w-10 h-10 rounded-full flex items-center justify-center text-white text-sm font-bold"
                :class="currentStepIndex >= idx ? 'bg-green-600' : 'bg-gray-300'"
              >
                {{ idx + 1 }}
              </div>
              <span class="text-[10px] mt-1 text-center">{{ $t(step.label) }}</span>
            </div>
          </div>
        </div>

        <!-- Info proveedor -->
        <div class="flex items-center gap-3 px-4">
          <img
            :src="localOrder.provider?.avatar_url || '/img/default-provider.png'"
            alt="Provider"
            class="w-12 h-12 rounded-full object-cover"
          />
          <div>
            <p class="font-semibold">{{ localOrder.provider?.name || 'Proveedor' }}</p>
            <p v-if="localOrder.provider?.rating" class="text-yellow-500">⭐ {{ localOrder.provider.rating }}</p>
          </div>
        </div>

        <!-- Detalles -->
        <div class="px-4 py-2 text-sm space-y-1">
          <div><strong>{{ $t('order_number') }}:</strong> #{{ localOrder.id }}</div>
          <div><strong>{{ $t('service') }}:</strong> {{ localOrder.serviceName || 'Servicio' }}</div>
          <div><strong>{{ $t('description') }}:</strong> {{ localOrder.description || 'Sin descripción' }}</div>
          <div><strong>{{ $t('date') }}:</strong> {{ formatDate(localOrder.created_at || localOrder.date) }}</div>
          <div><strong>{{ $t('price') }}:</strong> ${{ Number(localOrder.price || 0).toFixed(2) }}</div>
          <div><strong>{{ $t('location') }}:</strong> {{ localOrder.address || 'No especificada' }}</div>
          <div><strong>{{ $t('payment_method') }}:</strong> {{ localOrder.payment_method || 'No definido' }}</div>
        </div>

        <!-- Botones -->
        <div class="px-4 pb-4 grid grid-cols-3 gap-2">
          <button @click="openChat" class="bg-blue-500 text-white rounded-md py-2 text-xs">
            💬 {{ $t('chat') }}
          </button>
          <button @click="callProvider" class="bg-green-500 text-white rounded-md py-2 text-xs">
            📞 {{ $t('call') }}
          </button>
          <button @click="openPayment" class="bg-purple-500 text-white rounded-md py-2 text-xs">
            💳 {{ $t('pay') }}
          </button>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script>
import { useI18n } from 'vue-i18n'
import { useSocketStore } from '@/stores/socketStore'
import { useToast } from 'vue-toastification'
import api from '@/axios'

export default {
  name: 'LiveOrderTracking',
  props: { order: { type: Object, required: true } },
  emits: ['close', 'open-chat', 'update:order', 'open-payment'],
  data() {
    return {
      localOrder: { ...this.order },
      mapUrl: null,
      translateY: 0,
      startY: 0,
      dragging: false,
      pollInterval: null,
      toast: null,
      timelineSteps: [
        { key: 'accepted', label: 'accepted' },
        { key: 'in_progress', label: 'in_progress' },
        { key: 'on_the_way', label: 'on_the_way' },
        { key: 'completed', label: 'completed' }
      ]
    }
  },
  computed: {
    currentStepIndex() {
      return this.timelineSteps.findIndex(s => s.key === this.mappedStatus)
    },
    mappedStatus() {
      switch (this.localOrder.status) {
        case 'accepted': return 'accepted'
        case 'in_progress': return 'in_progress'
        case 'on_the_way': return 'on_the_way'
        case 'completed': return 'completed'
        default: return 'accepted'
      }
    },
    parsedOrder() {
      return this.normalizeService(this.localOrder)
    }
  },
  watch: {
    order: {
      immediate: true,
      deep: true,
      handler(newVal) {
        this.localOrder = { ...newVal }
      }
    }
  },
  created() {
    // ✅ Inicializar toast para todo el componente
    this.toast = useToast()
  },
  mounted() {
    this.loadMap()
    this.fetchStatusOnce()
    this.pollStatus()
    this.addSwipeListeners()
    this.listenStatusChanges()
  },
  beforeUnmount() {
    this.removeSwipeListeners()
    this.stopListening()
    if (this.pollInterval) clearInterval(this.pollInterval)
  },
  methods: {
    loadMap() {
      const origin = encodeURIComponent(this.localOrder.provider?.current_address || '0,0')
      const dest = encodeURIComponent(this.localOrder.address || '0,0')
      const key = import.meta.env.VITE_GOOGLE_MAPS_KEY
      this.mapUrl = `https://www.google.com/maps/embed/v1/directions?key=${key}&origin=${origin}&destination=${dest}&mode=driving`
    },
    async fetchStatusOnce() {
      try {
        const { data } = await api.get(`/requests/status/${this.localOrder.id}`)
        this.localOrder = { ...this.localOrder, status: data.status }
      } catch (err) {
        console.warn('❌ Error al obtener estado inicial:', err)
      }
    },
    pollStatus() {
      this.pollInterval = setInterval(async () => {
        try {
          const { data } = await api.get(`/requests/status/${this.localOrder.id}`)
          let status = data.status
          if (status === 'arrived') status = 'completed'
          this.localOrder = { ...this.localOrder, status }
          if (status === 'completed') {
            this.toast.success(this.$t('provider_arrived'))
            clearInterval(this.pollInterval)
          }
        } catch (err) {
          console.warn('❌ Error en pollStatus:', err)
          clearInterval(this.pollInterval)
        }
      }, 15000)
    },
    openChat() {
      this.$emit('close')
      this.$emit('open-chat', {
        id: this.localOrder.provider?.id || this.localOrder.provider_id,
        name: this.localOrder.provider?.name || 'Proveedor',
        role: 'provider',
        avatarUrl: this.localOrder.provider?.avatar_url,
        phone: this.localOrder.provider?.phone || null
      })
    },
    callProvider() {
      const phone = this.localOrder.provider?.phone
      if (phone) {
        window.location.href = `tel:${phone}`
      } else {
        this.toast.warning(this.$t('no_phone_available'))
      }
    },
    openPayment() {
      if (!this.parsedOrder.provider?.paymentInfo) {
        this.toast.warning(this.$t('no_payment_methods'))
        return
      }
      this.$emit('open-payment', this.parsedOrder)
    },
    formatDate(date) {
      return new Date(date).toLocaleDateString()
    },
    parsePaymentMethods(raw) {
      if (!raw) return []
      try {
        return typeof raw === 'string' ? JSON.parse(raw) : raw
      } catch (e) {
        console.warn('❌ Error parseando payment_methods:', e)
        return []
      }
    },
    normalizeService(s) {
      const p = s.provider && typeof s.provider === 'object' ? s.provider : {}
      let paymentInfo = {}
      try {
        const methods = this.parsePaymentMethods(s.payment_methods || this.order.payment_methods || '[]')
        methods.forEach(m => {
          if (m.method_type === 'pago_movil') {
            paymentInfo.pagoMovil = { banco: m.bank_name, telefono: m.phone_number, cedula: m.id_number }
          }
          if (m.method_type === 'transferencia') {
            paymentInfo.transferencia = { banco: m.bank_name, cuenta: m.account_number, cedula: m.id_number }
          }
          if (m.method_type === 'paypal') paymentInfo.paypal = { email: m.email }
          if (m.method_type === 'zelle') paymentInfo.zelle = { email: m.email }
        })
      } catch (e) {
        console.warn('Error parseando payment_methods:', e)
      }
      return {
        ...s,
        service_details: s.service_details || '',
        provider: {
          id: p.id || s.provider_id || s.providerId || null,
          name: p.name || s.provider_name || '—',
          avatar_url: p.avatar_url || s.provider_avatar_url || '',
          rating: p.rating ?? s.provider_rating ?? null,
          paymentInfo: Object.keys(paymentInfo).length ? paymentInfo : undefined
        }
      }
    },
    listenStatusChanges() {
      useSocketStore().on('status_changed', payload => {
        if (payload.request_id === this.localOrder.id) {
          let status = payload.status
          if (status === 'arrived') status = 'completed'
          this.localOrder = { ...this.localOrder, status }
          if (status === 'completed') this.toast.success(this.$t('provider_arrived'))
        }
      })
    },
    stopListening() {
      useSocketStore().off('status_changed')
    },
    addSwipeListeners() {
      const sheet = this.$refs.sheet
      if (!sheet) return
      sheet.addEventListener('touchstart', this.onTouchStart, { passive: true })
      sheet.addEventListener('touchmove', this.onTouchMove, { passive: true })
      sheet.addEventListener('touchend', this.onTouchEnd, { passive: true })
      sheet.addEventListener('mousedown', this.onMouseDown)
    },
    removeSwipeListeners() {
      const sheet = this.$refs.sheet
      if (!sheet) return
      sheet.removeEventListener('touchstart', this.onTouchStart)
      sheet.removeEventListener('touchmove', this.onTouchMove)
      sheet.removeEventListener('touchend', this.onTouchEnd)
      sheet.removeEventListener('mousedown', this.onMouseDown)
      window.removeEventListener('mousemove', this.onMouseMove)
      window.removeEventListener('mouseup', this.onMouseUp)
    },
    onTouchStart(e) {
      this.startY = e.touches[0].clientY
      this.dragging = true
    },
    onTouchMove(e) {
      if (!this.dragging) return
      const delta = e.touches[0].clientY - this.startY
      if (delta > 0) this.translateY = delta
    },
    onTouchEnd() {
      if (!this.dragging) return
      this.dragging = false
      if (this.translateY > 120) this.$emit('close')
      else this.translateY = 0
    },
    onMouseDown(e) {
      this.startY = e.clientY
      this.dragging = true
      window.addEventListener('mousemove', this.onMouseMove)
      window.addEventListener('mouseup', this.onMouseUp)
    },
    onMouseMove(e) {
      if (!this.dragging) return
      const delta = e.clientY - this.startY
      if (delta > 0) this.translateY = delta
    },
    onMouseUp() {
      if (!this.dragging) return
      this.dragging = false
      window.removeEventListener('mousemove', this.onMouseMove)
      window.removeEventListener('mouseup', this.onMouseUp)
      if (this.translateY > 120) this.$emit('close')
      else this.translateY = 0
    }
  }
}
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
@media (max-width: 640px) {
  .text-xs {
    font-size: 0.65rem;
  }
}
</style>
