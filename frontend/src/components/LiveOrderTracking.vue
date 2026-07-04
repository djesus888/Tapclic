<template>
  <Teleport to="body">
    <div class="live-tracking-container">
      <div
        class="modal-overlay"
        @click="$emit('close')"
      />
      <div class="modal-content-wrapper">
        <!-- Header mejorado -->
        <div class="modal-header">
          <div class="header-content">
            <button
              class="back-button"
              aria-label="Cerrar"
              @click="$emit('close')"
            >
              <svg
                class="back-icon"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M15 19l-7-7 7-7"
                />
              </svg>
            </button>
            <div class="header-info">
              <h1 class="modal-title">
                🚀 {{ $t('live_tracking') }}
              </h1>
              <p class="modal-subtitle">
                {{ $t('real_time_tracking') }}
              </p>
            </div>
            <div class="status-badge">
              <span :class="`status-${mappedStatus}`">{{ $t(mappedStatus) }}</span>
            </div>
          </div>
        </div>

        <!-- Contenido principal con scroll -->
        <div class="modal-content-scrollable">
          <!-- 🗺️ MAPA LEAFLET -->
          <div class="map-container">
            <div class="map-header">
              <div class="map-label">
                <span class="map-icon">📍</span>
                <span>{{ $t('live_map') }}</span>
              </div>
              <div class="map-actions">
                <button class="map-btn" @click="centerMap">
                  <span class="btn-icon">🎯</span>
                  <span class="btn-text">{{ $t('center') }}</span>
                </button>
                <button class="map-btn" @click="refreshMap">
                  <span class="btn-icon">🔄</span>
                  <span class="btn-text">{{ $t('update') }}</span>
                </button>
              </div>
            </div>
            <div class="map-wrapper-leaflet">
              <div id="delivery-map" ref="mapContainer" class="leaflet-map"></div>
              <div v-if="mapLoading" class="map-loading-overlay">
                <div class="spinner"></div>
                <p>{{ $t('loading_map') }}</p>
              </div>
            </div>
            <div class="map-legend">
              <div class="legend-item">
                <span class="legend-dot delivery"></span>
                <span>{{ $t('delivery_position') }}</span>
              </div>
              <div class="legend-item">
                <span class="legend-dot destination"></span>
                <span>{{ $t('delivery_point') }}</span>
              </div>
            </div>
          </div>

          <!-- Timeline mejorado -->
          <div class="timeline-section">
            <h3 class="section-title">
              <span class="section-icon">📋</span>
              {{ $t('service_progress') }}
            </h3>
            <div class="timeline-container">
              <div class="timeline-line" />
              <div class="timeline-steps">
                <div
                  v-for="(step, idx) in timelineSteps"
                  :key="step.key"
                  class="timeline-step"
                  :class="{ active: currentStepIndex >= idx, current: currentStepIndex === idx }"
                >
                  <div class="step-circle">
                    <span class="step-number">{{ idx + 1 }}</span>
                    <span v-if="currentStepIndex >= idx" class="step-icon">{{ getStepIcon(step.key) }}</span>
                  </div>
                  <span class="step-label">{{ $t(step.label) }}</span>
                  <span v-if="currentStepIndex === idx" class="step-time">{{ $t('in_progress') }}</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Información del Delivery (si está asignado) -->
          <div v-if="deliveryInfo" class="provider-section delivery-section">
            <h3 class="section-title">
              <span class="section-icon">🛵</span>
              {{ $t('assigned_delivery') }}
            </h3>
            <div class="provider-card delivery-card">
              <div class="provider-header">
                <div class="delivery-avatar-circle">🛵</div>
                <div class="provider-info">
                  <h4 class="provider-name">{{ deliveryInfo.name }}</h4>
                  <a v-if="deliveryInfo.phone" :href="'tel:' + deliveryInfo.phone" class="delivery-phone-link">
                    📱 {{ deliveryInfo.phone }}
                  </a>
                </div>
              </div>
            </div>
          </div>

          <!-- Información del proveedor mejorada -->
          <div class="provider-section">
            <h3 class="section-title">
              <span class="section-icon">👨‍🔧</span>
              {{ $t('provider_info') }}
            </h3>
            <div class="provider-card">
              <div class="provider-header">
                <img
                  :src="getImageUrl(localOrder.provider?.avatar_url, 'avatar') || '/img/default-provider.png'"
                  alt="Provider"
                  class="provider-avatar"
                  @error="handleImageError"
                >
                <div class="provider-info">
                  <h4 class="provider-name">{{ localOrder.provider?.name || $t('provider') }}</h4>
                  <div v-if="hasValidRating" class="provider-rating">
                    <span class="stars">
                      <span v-for="n in 5" :key="n" class="star" :class="{ filled: n <= getRatingStars }">★</span>
                    </span>
                    <span class="rating-value">{{ formattedRating }}</span>
                  </div>
                  <p class="provider-status" :class="{ offline: !isProviderConnected }">
                    {{ isProviderConnected ? $t('connected') : $t('disconnected') }}
                  </p>
                </div>
              </div>
              <div class="provider-actions">
                <button class="action-btn chat" :disabled="!isProviderConnected" @click="openChat">
                  <span class="action-icon">💬</span>
                  <span class="action-text">{{ $t('chat') }}</span>
                </button>
                <button class="action-btn call" @click="callProvider">
                  <span class="action-icon">📞</span>
                  <span class="action-text">{{ $t('call') }}</span>
                </button>
              </div>
            </div>
          </div>

          <!-- Detalles del servicio mejorados -->
          <div class="details-section">
            <h3 class="section-title">
              <span class="section-icon">📄</span>
              {{ $t('order_details') }}
            </h3>
            <div class="details-grid">
              <div class="detail-item">
                <span class="detail-label">{{ $t('order_number') }}:</span>
                <span class="detail-value order-id">#{{ localOrder.id || 'N/A' }}</span>
              </div>
              <div class="detail-item">
                <span class="detail-label">{{ $t('service') }}:</span>
                <span class="detail-value service-name">{{ localOrder.serviceName || $t('service') }}</span>
              </div>
              <div class="detail-item full-width">
                <span class="detail-label">{{ $t('description') }}:</span>
                <span class="detail-value description">{{ localOrder.description || $t('no_description') }}</span>
              </div>
              <div class="detail-item">
                <span class="detail-label">{{ $t('date') }}:</span>
                <span class="detail-value">{{ formatDate(localOrder.created_at || localOrder.date) }}</span>
              </div>
              <div class="detail-item highlight">
                <span class="detail-label">{{ $t('price') }}:</span>
                <span class="detail-value price">${{ formatPrice(localOrder.price) }}</span>
              </div>
              <div class="detail-item full-width">
                <span class="detail-label">{{ $t('location') }}:</span>
                <span class="detail-value location">{{ localOrder.address || $t('not_specified') }}</span>
              </div>
              <div class="detail-item">
                <span class="detail-label">{{ $t('payment_method') }}:</span>
                <span class="detail-value payment-method">{{ localOrder.payment_method || $t('not_defined') }}</span>
              </div>
              <div v-if="localOrder.payment_status" class="detail-item">
                <span class="detail-label">{{ $t('payment_status') }}:</span>
                <span class="detail-value payment-status" :class="`payment-${localOrder.payment_status}`">
                  {{ formatPaymentStatus(localOrder.payment_status) }}
                </span>
              </div>
            </div>
          </div>

          <!-- Acciones principales -->
          <div class="actions-section">
            <div class="actions-grid">
              <button class="action-card primary" :disabled="!canMakePayment" @click="openPayment">
                <div class="action-icon-wrapper"><span class="action-main-icon">💳</span></div>
                <div class="action-content">
                  <h4>{{ $t('pay') }}</h4>
                  <p v-if="canMakePayment">{{ $t('complete_payment') }}</p>
                  <p v-else class="disabled-text">{{ $t('payment_unavailable') }}</p>
                </div>
                <span v-if="canMakePayment" class="action-arrow">→</span>
              </button>
              <button class="action-card secondary" :disabled="!isProviderConnected" @click="openChat">
                <div class="action-icon-wrapper"><span class="action-main-icon">💬</span></div>
                <div class="action-content">
                  <h4>{{ $t('chat') }}</h4>
                  <p v-if="isProviderConnected">{{ $t('contact_provider') }}</p>
                  <p v-else class="disabled-text">{{ $t('provider_offline') }}</p>
                </div>
                <span v-if="isProviderConnected" class="action-arrow">→</span>
              </button>
              <button class="action-card tertiary" @click="callProvider">
                <div class="action-icon-wrapper"><span class="action-main-icon">📞</span></div>
                <div class="action-content">
                  <h4>{{ $t('call') }}</h4>
                  <p>{{ $t('call_now') }}</p>
                </div>
                <span class="action-arrow">→</span>
              </button>
            </div>
          </div>
        </div>

        <!-- Botón de cierre flotante -->
        <button class="floating-close-btn" aria-label="Cerrar ventana" @click="$emit('close')">
          <svg class="close-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>
    </div>
  </Teleport>
</template>

<script>
import { useI18n } from 'vue-i18n'
import { useSocketStore } from '@/stores/socketStore'
import { useToast } from 'vue-toastification'
import { getImageUrl } from '@/utils/imageHelper'
import api from '@/axios'
import L from 'leaflet'
import 'leaflet/dist/leaflet.css'

// Fix para íconos de Leaflet
delete L.Icon.Default.prototype._getIconUrl
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon-2x.png',
  iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
})

export default {
  name: 'LiveOrderTracking',
  props: { order: { type: Object, required: true } },
  emits: ['close', 'open-chat', 'update:order', 'open-payment'],

  data() {
    return {
      localOrder: { ...this.order },
      deliveryInfo: null,
      mapLoading: true,
      mapInstance: null,
      deliveryMarker: null,
      destinationMarker: null,
      routeLine: null,
      translateY: 0,
      startY: 0,
      dragging: false,
      toast: null,
      providerConnected: true,
      timelineSteps: [
        { key: 'accepted', label: 'accepted' },
        { key: 'in_progress', label: 'in_progress' },
        { key: 'on_the_way', label: 'on_the_way' },
        { key: 'completed', label: 'completed' }
      ],
      requestUpdatedHandler: null,
      paymentUpdatedHandler: null,
      newNotificationHandler: null
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
        case 'arrived': return 'on_the_way'
        case 'finalized': return 'completed'
        case 'completed': return 'completed'
        default: return 'accepted'
      }
    },
    parsedOrder() {
      return this.normalizeService(this.localOrder)
    },
    hasValidRating() {
      const rating = this.localOrder.provider?.rating
      return rating !== null && rating !== undefined && !isNaN(Number(rating))
    },
    formattedRating() {
      if (!this.hasValidRating) return '0.0'
      const num = Number(this.localOrder.provider.rating)
      return isNaN(num) ? '0.0' : num.toFixed(1)
    },
    getRatingStars() {
      if (!this.hasValidRating) return 0
      const num = Number(this.localOrder.provider.rating)
      return isNaN(num) ? 0 : Math.round(num)
    },
    isProviderConnected() { return this.providerConnected },
    canMakePayment() {
      return this.parsedOrder.provider?.paymentInfo &&
             this.localOrder.payment_status !== 'paid' &&
             this.localOrder.payment_status !== 'completed'
    }
  },

  watch: {
    order: {
      immediate: true,
      deep: true,
      handler(newVal) {
        this.localOrder = { ...this.localOrder, ...newVal }
      }
    }
  },

  created() { this.toast = useToast() },

  mounted() {
    this.$nextTick(() => {
      this.initMap()
    })
    this.setupSocketListeners()
    this.fetchStatusOnce()
    document.addEventListener('visibilitychange', this.onVisibilityChange)
    document.body.style.overflow = 'hidden'
  },

  beforeUnmount() {
    this.removeSocketListeners()
    document.removeEventListener('visibilitychange', this.onVisibilityChange)
    document.body.style.overflow = ''
    if (this.mapInstance) {
      this.mapInstance.remove()
      this.mapInstance = null
    }
  },

  methods: {
    getImageUrl(url, type) { return getImageUrl(url, type) },
    formatPrice(price) {
      if (!price && price !== 0) return '0.00'
      return isNaN(Number(price)) ? '0.00' : Number(price).toFixed(2)
    },
    formatPaymentStatus(status) {
      const map = { 'pending': this.$t('pending'), 'paid': this.$t('paid'), 'failed': this.$t('failed'), 'refunded': this.$t('refunded'), 'completed': this.$t('completed') }
      return map[status] || status
    },
    handleImageError(event) { event.target.src = '/img/default-provider.png' },
    async onVisibilityChange() {
      if (!document.hidden) await this.fetchStatusOnce()
    },

    // ============ 🗺️ MAPA LEAFLET ============
    initMap() {
      if (!this.$refs.mapContainer) {
        setTimeout(() => this.initMap(), 200)
        return
      }

      // Coordenadas por defecto (Venezuela)
      const defaultLat = 10.4806
      const defaultLng = -66.9036

      this.mapInstance = L.map('delivery-map', {
        center: [defaultLat, defaultLng],
        zoom: 13,
        zoomControl: true,
        attributionControl: false
      })

      // Capa de OpenStreetMap
      L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
      }).addTo(this.mapInstance)

      // Intentar geocodificar las direcciones
      this.geocodeAddresses()
    },

    async geocodeAddresses() {
      this.mapLoading = true
      
      try {
        const providerAddr = this.localOrder.provider?.current_address || ''
        const deliveryAddr = this.localOrder.address || this.localOrder.service_location || ''

        // Coordenadas por defecto (Caracas)
        let providerCoords = [10.4806, -66.9036]
        let deliveryCoords = [10.4900, -66.9100]

        // Geocodificar dirección del proveedor
        if (providerAddr && providerAddr !== '0,0') {
          const pCoords = await this.geocode(providerAddr)
          if (pCoords) providerCoords = pCoords
        }

        // Geocodificar dirección de entrega
        if (deliveryAddr && deliveryAddr !== '0,0') {
          const dCoords = await this.geocode(deliveryAddr)
          if (dCoords) deliveryCoords = dCoords
        }

        this.addMarkers(providerCoords, deliveryCoords)
      } catch (e) {
        console.warn('Error geocodificando:', e)
        this.addMarkers([10.4806, -66.9036], [10.4900, -66.9100])
      } finally {
        this.mapLoading = false
      }
    },

    async geocode(address) {
      try {
        const url = `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(address)}&limit=1`
        const response = await fetch(url)
        const data = await response.json()
        if (data.length > 0) {
          return [parseFloat(data[0].lat), parseFloat(data[0].lon)]
        }
      } catch (e) {
        console.warn('Geocoding falló:', e)
      }
      return null
    },

    addMarkers(providerCoords, deliveryCoords) {
      if (!this.mapInstance) return

      // Limpiar marcadores anteriores
      if (this.deliveryMarker) this.mapInstance.removeLayer(this.deliveryMarker)
      if (this.destinationMarker) this.mapInstance.removeLayer(this.destinationMarker)
      if (this.routeLine) this.mapInstance.removeLayer(this.routeLine)

      // Icono personalizado para delivery
      const deliveryIcon = L.divIcon({
        html: '<div style="background:#10B981;color:white;width:40px;height:40px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:20px;border:3px solid white;box-shadow:0 4px 12px rgba(16,185,129,0.5);">🛵</div>',
        className: '',
        iconSize: [40, 40],
        iconAnchor: [20, 20]
      })

      // Icono para destino
      const destIcon = L.divIcon({
        html: '<div style="background:#EF4444;color:white;width:36px;height:36px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:16px;border:3px solid white;box-shadow:0 4px 12px rgba(239,68,68,0.5);">📍</div>',
        className: '',
        iconSize: [36, 36],
        iconAnchor: [18, 18]
      })

      // Agregar marcadores
      this.deliveryMarker = L.marker(providerCoords, { icon: deliveryIcon })
        .bindPopup(`<b>${this.$t('delivery_position')}</b>`)
        .addTo(this.mapInstance)

      this.destinationMarker = L.marker(deliveryCoords, { icon: destIcon })
        .bindPopup(`<b>${this.$t('delivery_point')}</b><br>${this.localOrder.address || ''}`)
        .addTo(this.mapInstance)

      // Dibujar línea de ruta
      this.routeLine = L.polyline([providerCoords, deliveryCoords], {
        color: '#10B981',
        weight: 4,
        dashArray: '10, 10',
        opacity: 0.8
      }).addTo(this.mapInstance)

      // Ajustar zoom para mostrar ambos puntos
      const bounds = L.latLngBounds([providerCoords, deliveryCoords])
      this.mapInstance.fitBounds(bounds, { padding: [50, 50] })
    },

    centerMap() {
      if (!this.mapInstance) return
      const bounds = L.latLngBounds([
        this.deliveryMarker?.getLatLng() || [10.48, -66.90],
        this.destinationMarker?.getLatLng() || [10.49, -66.91]
      ])
      this.mapInstance.fitBounds(bounds, { padding: [50, 50] })
    },

    refreshMap() {
      this.geocodeAddresses()
      if (this.toast) this.toast.info(this.$t('map_updated'))
    },

    // ============ FIN MAPA ============

    async fetchStatusOnce() {
      try {
        const { data } = await api.get(`/requests/status/${this.localOrder.id}`)
        if (data?.status) {
          this.localOrder = { ...this.localOrder, status: data.status }
        }
        if (data?.delivery) {
          this.deliveryInfo = data.delivery
        }
      } catch (err) {
        console.warn('❌ Error al obtener estado:', err.message)
      }
    },

    openChat() {
      if (!this.isProviderConnected) {
        this.toast.warning(this.$t('provider_unavailable_chat'))
        return
      }
      this.$emit('close')
      this.$emit('open-chat', {
        id: this.localOrder.provider?.id || this.localOrder.provider_id,
        name: this.localOrder.provider?.name || this.$t('provider'),
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
      if (!this.canMakePayment) {
        this.toast.warning(this.$t('no_payment_methods'))
        return
      }
      this.$emit('open-payment', this.parsedOrder)
    },

    formatDate(date) {
      if (!date) return this.$t('not_specified')
      try {
        return new Date(date).toLocaleDateString('es-ES', { day: 'numeric', month: 'long', year: 'numeric', hour: '2-digit', minute: '2-digit' })
      } catch (e) { return this.$t('invalid_date') }
    },

    parsePaymentMethods(raw) {
      if (!raw) return []
      try { return typeof raw === 'string' ? JSON.parse(raw) : raw }
      catch (e) { return [] }
    },

    normalizeService(s) {
      const p = s.provider && typeof s.provider === 'object' ? s.provider : {}
      let paymentInfo = {}
      try {
        const methods = this.parsePaymentMethods(s.payment_methods || this.order.payment_methods || '[]')
        methods.forEach(m => {
          if (m.method_type === 'pago_movil') paymentInfo.pagoMovil = { banco: m.bank_name, telefono: m.phone_number, cedula: m.id_number }
          if (m.method_type === 'transferencia') paymentInfo.transferencia = { banco: m.bank_name, cuenta: m.account_number, cedula: m.id_number }
          if (m.method_type === 'paypal') paymentInfo.paypal = { email: m.email }
          if (m.method_type === 'zelle') paymentInfo.zelle = { email: m.email }
        })
      } catch (e) {}
      return { ...s, provider: { id: p.id || s.provider_id || s.providerId || null, name: p.name || s.provider_name || '—', avatar_url: p.avatar_url || s.provider_avatar_url || '', rating: p.rating ?? s.provider_rating ?? null, paymentInfo: Object.keys(paymentInfo).length ? paymentInfo : undefined } }
    },

    setupSocketListeners() {
      const socketStore = useSocketStore()
      this.requestUpdatedHandler = (payload) => {
        const requestId = payload.request_id || payload.id
        const newStatus = payload.status
        if (!requestId || !newStatus) return
        if (String(requestId) === String(this.localOrder.id)) {
          this.localOrder = { ...this.localOrder, status: newStatus }
          this.fetchStatusOnce()
          if (newStatus === 'completed') this.toast.success(this.$t('provider_arrived'))
        }
      }
      this.paymentUpdatedHandler = (payload) => {
        const requestId = payload.request_id
        const paymentStatus = payload.payment_status
        if (String(requestId) === String(this.localOrder.id) && paymentStatus) {
          this.localOrder = { ...this.localOrder, payment_status: paymentStatus }
        }
      }
      socketStore.on('request_updated', this.requestUpdatedHandler)
      socketStore.on('payment_updated', this.paymentUpdatedHandler)
    },

    removeSocketListeners() {
      const socketStore = useSocketStore()
      if (this.requestUpdatedHandler) socketStore.off('request_updated', this.requestUpdatedHandler)
      if (this.paymentUpdatedHandler) socketStore.off('payment_updated', this.paymentUpdatedHandler)
    },

    getStepIcon(stepKey) {
      const icons = { accepted: '✓', in_progress: '⚙️', on_the_way: '🚗', completed: '🎉' }
      return icons[stepKey] || '○'
    },
  }
}
</script>

<style scoped>
.live-tracking-container { position: fixed; top: 0; left: 0; right: 0; bottom: 0; z-index: 9999; display: flex; align-items: center; justify-content: center; padding: 20px; }
.modal-overlay { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0, 0, 0, 0.85); backdrop-filter: blur(10px); -webkit-backdrop-filter: blur(10px); animation: fadeIn 0.3s ease; z-index: 1; }
@keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
.modal-content-wrapper { position: relative; width: 100%; max-width: 900px; max-height: 90vh; background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%); border-radius: 28px; box-shadow: 0 30px 60px -12px rgba(0, 0, 0, 0.6); overflow: hidden; animation: slideUp 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275); z-index: 2; border: 1px solid rgba(255, 255, 255, 0.2); }
@keyframes slideUp { from { opacity: 0; transform: translateY(60px) scale(0.95); } to { opacity: 1; transform: translateY(0) scale(1); } }
.modal-header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 24px 28px; color: white; position: relative; overflow: hidden; border-bottom: 1px solid rgba(255, 255, 255, 0.1); }
.modal-header::before { content: ''; position: absolute; top: -50%; right: -50%; width: 300px; height: 300px; background: radial-gradient(circle, rgba(255,255,255,0.15) 0%, transparent 70%); }
.header-content { display: flex; align-items: center; gap: 20px; position: relative; z-index: 1; }
.back-button { background: rgba(255, 255, 255, 0.25); border: none; width: 48px; height: 48px; border-radius: 14px; display: flex; align-items: center; justify-content: center; cursor: pointer; transition: all 0.3s; flex-shrink: 0; backdrop-filter: blur(5px); }
.back-button:hover { background: rgba(255, 255, 255, 0.35); transform: translateX(-3px) scale(1.05); }
.back-icon { width: 26px; height: 26px; stroke-width: 2.5; }
.header-info { flex: 1; }
.modal-title { font-size: 2rem; font-weight: 800; margin-bottom: 6px; display: flex; align-items: center; gap: 12px; text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2); }
.modal-subtitle { opacity: 0.9; font-size: 1rem; font-weight: 500; }
.status-badge { flex-shrink: 0; }
.status-badge span { padding: 10px 20px; border-radius: 24px; font-weight: 700; font-size: 0.9rem; background: rgba(255, 255, 255, 0.25); border: 2px solid rgba(255, 255, 255, 0.3); backdrop-filter: blur(5px); text-transform: uppercase; letter-spacing: 0.5px; }
.status-accepted { background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%) !important; box-shadow: 0 4px 15px rgba(245, 87, 108, 0.4); }
.status-in_progress { background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%) !important; box-shadow: 0 4px 15px rgba(79, 172, 254, 0.4); }
.status-on_the_way { background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%) !important; box-shadow: 0 4px 15px rgba(67, 233, 123, 0.4); }
.status-completed { background: linear-gradient(135deg, #fa709a 0%, #fee140 100%) !important; box-shadow: 0 4px 15px rgba(250, 112, 154, 0.4); }
.modal-content-scrollable { padding: 28px; overflow-y: auto; max-height: calc(90vh - 120px); background: #f8f9fa; }
.modal-content-scrollable::-webkit-scrollbar { width: 8px; }
.modal-content-scrollable::-webkit-scrollbar-track { background: #f1f2f6; border-radius: 4px; }
.modal-content-scrollable::-webkit-scrollbar-thumb { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 4px; }
.section-title { font-size: 1.4rem; font-weight: 700; color: #2d3436; margin-bottom: 24px; display: flex; align-items: center; gap: 12px; padding-bottom: 12px; border-bottom: 2px solid #f1f2f6; }
.section-icon { font-size: 1.6rem; }

/* 🗺️ MAPA LEAFLET */
.map-container { background: white; border-radius: 20px; padding: 24px; margin-bottom: 28px; box-shadow: 0 6px 20px rgba(0, 0, 0, 0.1); border: 1px solid #e9ecef; }
.map-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
.map-label { display: flex; align-items: center; gap: 12px; font-weight: 700; color: #2d3436; font-size: 1.1rem; }
.map-icon { font-size: 1.4rem; }
.map-actions { display: flex; gap: 12px; }
.map-btn { display: flex; align-items: center; gap: 10px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border: none; padding: 10px 20px; border-radius: 10px; font-size: 0.9rem; font-weight: 600; cursor: pointer; transition: all 0.3s; box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3); }
.map-btn:hover { transform: translateY(-3px); box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4); }
.map-wrapper-leaflet { border-radius: 16px; overflow: hidden; height: 320px; position: relative; margin-bottom: 20px; border: 2px solid #e9ecef; background: #f8f9fa; }
.leaflet-map { width: 100%; height: 100%; z-index: 1; }
.map-loading-overlay { position: absolute; top: 0; left: 0; right: 0; bottom: 0; background: rgba(255,255,255,0.9); display: flex; flex-direction: column; align-items: center; justify-content: center; z-index: 10; }
.map-loading-overlay .spinner { width: 40px; height: 40px; border: 3px solid #e5e7eb; border-top: 3px solid #10B981; border-radius: 50%; animation: spin 1s linear infinite; margin-bottom: 12px; }
@keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
.map-legend { display: flex; gap: 24px; justify-content: center; flex-wrap: wrap; }
.legend-item { display: flex; align-items: center; gap: 10px; font-size: 0.9rem; color: #636e72; background: #f8f9fa; padding: 8px 16px; border-radius: 20px; border: 1px solid #e9ecef; }
.legend-dot { width: 14px; height: 14px; border-radius: 50%; border: 2px solid white; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
.legend-dot.delivery { background: #10B981; }
.legend-dot.destination { background: #EF4444; }

.timeline-section { background: white; border-radius: 20px; padding: 24px; margin-bottom: 28px; box-shadow: 0 6px 20px rgba(0, 0, 0, 0.1); border: 1px solid #e9ecef; }
.timeline-container { position: relative; padding: 30px 0; }
.timeline-line { position: absolute; top: 50%; left: 10%; right: 10%; height: 4px; background: linear-gradient(90deg, #dfe6e9, #b2bec3, #dfe6e9); transform: translateY(-50%); z-index: 1; border-radius: 2px; }
.timeline-steps { display: flex; justify-content: space-between; position: relative; z-index: 2; }
.timeline-step { display: flex; flex-direction: column; align-items: center; position: relative; flex: 1; }
.timeline-step.active .step-circle { background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%); color: white; transform: scale(1.15); box-shadow: 0 8px 25px rgba(67, 233, 123, 0.4); }
.timeline-step.current .step-circle { animation: pulse-glow 2s infinite; border: 3px solid white; }
@keyframes pulse-glow { 0%, 100% { box-shadow: 0 8px 25px rgba(67, 233, 123, 0.4), 0 0 0 0 rgba(67, 233, 123, 0.7); } 50% { box-shadow: 0 8px 25px rgba(67, 233, 123, 0.4), 0 0 0 10px rgba(67, 233, 123, 0); } }
.step-circle { width: 60px; height: 60px; border-radius: 50%; background: #dfe6e9; display: flex; align-items: center; justify-content: center; font-weight: 800; color: #636e72; margin-bottom: 12px; transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275); position: relative; border: 3px solid white; }
.step-number { font-size: 1.2rem; }
.step-icon { position: absolute; font-size: 1.4rem; }
.step-label { font-size: 0.9rem; font-weight: 700; color: #2d3436; text-align: center; margin-top: 8px; }
.step-time { font-size: 0.8rem; color: #00b894; font-weight: 700; margin-top: 6px; background: rgba(0, 184, 148, 0.1); padding: 4px 12px; border-radius: 12px; }
.provider-section { margin-bottom: 28px; }
.provider-card { background: white; border-radius: 20px; padding: 24px; box-shadow: 0 6px 20px rgba(0, 0, 0, 0.1); border: 1px solid #e9ecef; }
.provider-header { display: flex; align-items: center; gap: 20px; margin-bottom: 24px; }
.provider-avatar { width: 80px; height: 80px; border-radius: 50%; object-fit: cover; border: 4px solid #3498db; box-shadow: 0 4px 15px rgba(52, 152, 219, 0.3); transition: transform 0.3s; }
.provider-avatar:hover { transform: scale(1.05); }
.provider-info { flex: 1; }
.provider-name { font-size: 1.5rem; font-weight: 800; color: #2d3436; margin-bottom: 10px; }
.provider-rating { display: flex; align-items: center; gap: 12px; margin-bottom: 12px; }
.stars { display: flex; gap: 4px; }
.star { color: #dfe6e9; font-size: 1.2rem; transition: color 0.3s; }
.star.filled { color: #fdcb6e; text-shadow: 0 2px 4px rgba(253, 203, 110, 0.3); }
.rating-value { font-weight: 700; color: #2d3436; font-size: 1.1rem; background: #f8f9fa; padding: 4px 12px; border-radius: 12px; }
.provider-status { font-size: 0.9rem; font-weight: 700; color: #00b894; display: inline-block; padding: 6px 16px; background: rgba(0, 184, 148, 0.1); border-radius: 20px; border: 2px solid rgba(0, 184, 148, 0.2); }
.provider-status.offline { color: #e74c3c; background: rgba(231, 76, 60, 0.1); border-color: rgba(231, 76, 60, 0.2); }
.provider-actions { display: flex; gap: 16px; }
.action-btn { flex: 1; display: flex; align-items: center; justify-content: center; gap: 12px; padding: 14px; border: none; border-radius: 12px; font-weight: 700; cursor: pointer; transition: all 0.3s; font-size: 0.95rem; }
.action-btn.chat { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3); }
.action-btn.chat:disabled { opacity: 0.5; cursor: not-allowed; transform: none !important; box-shadow: none !important; }
.action-btn.call { background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%); color: white; box-shadow: 0 4px 15px rgba(67, 233, 123, 0.3); }
.action-btn:hover:not(:disabled) { transform: translateY(-3px); box-shadow: 0 6px 25px rgba(0, 0, 0, 0.2); }
.action-icon { font-size: 1.3rem; }
.action-text { font-size: 0.95rem; }

/* Delivery */
.delivery-section { margin-top: 0; }
.delivery-card { border: 2px solid #10B981; }
.delivery-avatar-circle { width: 80px; height: 80px; border-radius: 50%; background: linear-gradient(135deg, #10B981, #059669); display: flex; align-items: center; justify-content: center; font-size: 2.5rem; color: white; flex-shrink: 0; }
.delivery-phone-link { color: #10B981; font-weight: 700; text-decoration: none; font-size: 1.1rem; display: inline-block; margin-top: 8px; }
.delivery-phone-link:hover { text-decoration: underline; }

.details-section { background: white; border-radius: 20px; padding: 24px; margin-bottom: 28px; box-shadow: 0 6px 20px rgba(0, 0, 0, 0.1); border: 1px solid #e9ecef; }
.details-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 20px; }
.detail-item { display: flex; justify-content: space-between; padding: 16px; background: #f8f9fa; border-radius: 14px; transition: all 0.3s; border: 1px solid transparent; }
.detail-item:hover { background: #e9ecef; transform: translateX(8px); border-color: #3498db; }
.detail-item.highlight { background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); color: white; border: none; }
.detail-item.full-width { grid-column: 1 / -1; }
.detail-label { font-weight: 700; color: #2d3436; font-size: 0.95rem; flex-shrink: 0; }
.detail-item.highlight .detail-label { color: white; }
.detail-value { color: #636e72; font-weight: 600; text-align: right; max-width: 180px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; flex: 1; margin-left: 16px; }
.detail-item.highlight .detail-value { color: white; }
.order-id { color: #3498db; font-weight: 800; font-size: 1.1rem; }
.service-name { color: #2d3436; font-weight: 700; }
.description { white-space: normal; line-height: 1.5; }
.price { font-size: 1.3rem; font-weight: 800; }
.location { color: #00b894; font-weight: 700; }
.payment-method { color: #9b59b6; font-weight: 700; }
.payment-status { font-weight: 700; padding: 4px 12px; border-radius: 12px; font-size: 0.85rem; }
.payment-pending { background: #fdcb6e; color: #2d3436; }
.payment-paid { background: #00b894; color: white; }
.payment-failed { background: #e74c3c; color: white; }
.actions-section { margin-top: 32px; }
.actions-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 20px; }
.action-card { background: white; border-radius: 20px; padding: 24px; display: flex; align-items: center; gap: 20px; cursor: pointer; border: none; transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275); text-align: left; box-shadow: 0 6px 20px rgba(0, 0, 0, 0.1); border: 2px solid transparent; position: relative; overflow: hidden; }
.action-card::before { content: ''; position: absolute; top: 0; left: 0; right: 0; height: 4px; background: linear-gradient(90deg, transparent, rgba(255,255,255,0.8), transparent); transform: translateX(-100%); }
.action-card:hover:not(:disabled)::before { animation: shimmer 1.5s infinite; }
@keyframes shimmer { 100% { transform: translateX(100%); } }
.action-card:hover:not(:disabled) { transform: translateY(-8px); box-shadow: 0 15px 35px rgba(0, 0, 0, 0.15); }
.action-card:disabled { opacity: 0.5; cursor: not-allowed; transform: none !important; box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1) !important; }
.action-card.primary:hover:not(:disabled) { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border-color: #764ba2; }
.action-card.secondary:hover:not(:disabled) { background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); color: white; border-color: #00f2fe; }
.action-card.tertiary:hover:not(:disabled) { background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%); color: white; border-color: #38f9d7; }
.action-icon-wrapper { width: 60px; height: 60px; border-radius: 16px; display: flex; align-items: center; justify-content: center; font-size: 1.8rem; flex-shrink: 0; transition: all 0.3s; }
.action-card.primary .action-icon-wrapper { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; }
.action-card.secondary .action-icon-wrapper { background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); color: white; }
.action-card.tertiary .action-icon-wrapper { background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%); color: white; }
.action-content { flex: 1; }
.action-content h4 { font-size: 1.2rem; font-weight: 800; margin-bottom: 6px; color: #2d3436; transition: color 0.3s; }
.action-card:hover:not(:disabled) .action-content h4 { color: white; }
.action-content p { font-size: 0.9rem; color: #636e72; transition: color 0.3s; }
.action-card:hover:not(:disabled) .action-content p { color: rgba(255, 255, 255, 0.9); }
.disabled-text { color: #95a5a6 !important; font-style: italic; }
.action-arrow { font-size: 1.4rem; color: #3498db; transition: all 0.3s; font-weight: 800; }
.action-card:hover:not(:disabled) .action-arrow { transform: translateX(8px); color: white; }
.floating-close-btn { position: absolute; top: 20px; right: 20px; width: 48px; height: 48px; background: rgba(255, 255, 255, 0.25); backdrop-filter: blur(10px); border: 2px solid rgba(255, 255, 255, 0.3); border-radius: 50%; display: flex; align-items: center; justify-content: center; cursor: pointer; transition: all 0.3s; z-index: 3; box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2); }
.floating-close-btn:hover { background: rgba(255, 255, 255, 0.35); transform: rotate(90deg) scale(1.1); border-color: rgba(255, 255, 255, 0.5); }
.close-icon { width: 24px; height: 24px; stroke-width: 2.5; color: white; }

@media (max-width: 992px) { .live-tracking-container { padding: 15px; } .modal-content-wrapper { max-height: 95vh; } .modal-content-scrollable { max-height: calc(95vh - 120px); padding: 20px; } .timeline-steps { flex-wrap: wrap; gap: 30px; } .timeline-step { flex: 0 0 calc(50% - 15px); } .timeline-line { display: none; } }
@media (max-width: 768px) { .live-tracking-container { padding: 10px; } .modal-content-wrapper { border-radius: 24px; max-height: 98vh; } .modal-header { padding: 20px; } .header-content { flex-wrap: wrap; gap: 15px; } .modal-title { font-size: 1.6rem; } .status-badge { order: 3; width: 100%; text-align: center; } .status-badge span { display: inline-block; width: 100%; } .provider-header { flex-direction: column; text-align: center; } .provider-avatar, .delivery-avatar-circle { width: 70px; height: 70px; } .provider-actions { flex-direction: column; } .actions-grid { grid-template-columns: 1fr; } .map-wrapper-leaflet { height: 250px; } .details-grid { grid-template-columns: 1fr; } .floating-close-btn { top: 15px; right: 15px; width: 44px; height: 44px; } }
@media (max-width: 480px) { .modal-content-wrapper { border-radius: 20px; } .modal-header { padding: 16px; } .modal-title { font-size: 1.4rem; } .modal-subtitle { font-size: 0.9rem; } .back-button { width: 44px; height: 44px; } .section-title { font-size: 1.2rem; } .timeline-step { flex: 0 0 100%; margin-bottom: 20px; } .step-circle { width: 50px; height: 50px; } .map-container, .timeline-section, .provider-card, .details-section { padding: 20px; } .action-card { padding: 20px; gap: 16px; } .action-icon-wrapper { width: 50px; height: 50px; font-size: 1.5rem; } }
</style>
