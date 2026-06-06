Aquí tienes el archivo completo y corregido listo para copiar y pegar:

```vue
<template>
  <div class="service-publish-container">
    <!-- Loading -->
    <div v-if="loading" class="loading-section">
      <div class="spinner"></div>
      <p>Cargando información del servicio...</p>
    </div>

    <!-- Error -->
    <div v-else-if="errorMsg" class="error-section">
      <div class="error-icon">⚠️</div>
      <h3>{{ errorMsg }}</h3>
      <router-link to="/services" class="btn-back">← Volver a Servicios</router-link>
    </div>

    <!-- Content -->
    <template v-else>
      <!-- Header -->
      <div class="header">
        <div class="title-section">
          <h1><span class="icon">💳</span> Publicar Servicio</h1>
          <p>Completa el pago para activar tu servicio</p>
        </div>
        <router-link to="/services" class="btn-back-link">← Volver</router-link>
      </div>

      <!-- Service Summary -->
      <div class="service-summary">
        <div class="summary-card">
          <div class="summary-header">
            <img v-if="service.image_url" :src="getImageUrl(service.image_url)" :alt="service.title" class="service-image" />
            <div v-else class="service-image-placeholder">📦</div>
            <div class="service-info">
              <h2>{{ service.title }}</h2>
              <p class="service-category">{{ service.category }}</p>
              <p class="service-location">📍 {{ service.location }}</p>
            </div>
          </div>
          <div class="summary-details">
            <div class="detail-row highlight">
              <span>Costo de publicación</span>
              <span class="detail-value">${{ formatCurrency(publishCost) }}</span>
            </div>
            <div class="detail-row total">
              <span>Total a pagar</span>
              <span class="detail-value">${{ formatCurrency(publishCost) }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- ✅ Payment Section -->
      <div class="payment-section" v-if="publishCost > 0">
        <h2>💳 Método de Pago</h2>

        <!-- ✅ Wallet (solo si está habilitado) -->
        <div v-if="walletEnabled" class="payment-card" :class="{ active: payMethod === 'wallet' }" @click="payMethod = 'wallet'">
          <div class="payment-radio">
            <span class="radio-circle" :class="{ selected: payMethod === 'wallet' }"></span>
          </div>
          <div class="payment-icon">💰</div>
          <div class="payment-info">
            <h3>Pagar con Wallet</h3>
            <p>Saldo disponible: <strong>${{ formatCurrency(walletBalance) }}</strong></p>
          </div>
          <span v-if="payMethod === 'wallet'" class="check-icon">✅</span>
        </div>

        <!-- ✅ Métodos de pago externos -->
        <div v-if="paymentMethods.length > 0">
          <div v-for="method in paymentMethods" :key="method.type"
            class="payment-card" :class="{ active: payMethod === method.type }" @click="payMethod = method.type">
            <div class="payment-radio">
              <span class="radio-circle" :class="{ selected: payMethod === method.type }"></span>
            </div>
            <div class="payment-icon">{{ method.icon }}</div>
            <div class="payment-info">
              <h3>{{ method.label }}</h3>
              <p>{{ method.description }}</p>
            </div>
            <span v-if="payMethod === method.type" class="check-icon">✅</span>
          </div>
        </div>

        <!-- ✅ Sin métodos de pago y sin wallet -->
        <div v-if="!walletEnabled && paymentMethods.length === 0" class="no-methods">
          <div class="warning-icon">⚠️</div>
          <h3>No hay métodos de pago disponibles</h3>
          <p>Contacta al administrador para habilitar los métodos de pago.</p>
        </div>
      </div>

      <!-- ✅ Detalles del método seleccionado -->
      <div v-if="payMethod !== 'wallet' && selectedMethod" class="transfer-section">
        <div class="bank-info">
          <h3>{{ selectedMethod.icon }} Datos para el pago</h3>
          <div class="bank-details">
            <p v-if="selectedMethod.bank"><strong>Banco:</strong> {{ selectedMethod.bank }}</p>
            <p v-if="selectedMethod.account"><strong>Cuenta:</strong> {{ selectedMethod.account }}</p>
            <p v-if="selectedMethod.phone"><strong>Teléfono:</strong> {{ selectedMethod.phone }}</p>
            <p v-if="selectedMethod.email"><strong>Email:</strong> {{ selectedMethod.email }}</p>
            <p v-if="selectedMethod.holder"><strong>Titular:</strong> {{ selectedMethod.holder }}</p>
            <p v-if="selectedMethod.idNumber"><strong>Cédula:</strong> {{ selectedMethod.idNumber }}</p>
            <p><strong>Monto exacto:</strong> ${{ formatCurrency(publishCost) }}</p>
          </div>
        </div>

        <div class="upload-section">
          <h3>📎 Subir Comprobante</h3>
          <div class="upload-area" @click="$refs.fileInput.click()">
            <input type="file" ref="fileInput" @change="handleFile" accept="image/*" class="hidden-input" />
            <div v-if="!paymentFile" class="upload-placeholder">
              <span class="upload-icon">📁</span>
              <p>Haz clic para subir comprobante</p>
            </div>
            <div v-else class="upload-preview">
              <span class="file-icon">📄</span>
              <span>{{ paymentFile.name }}</span>
              <button class="btn-remove-file" @click.stop="paymentFile = null">✕</button>
            </div>
          </div>
          <div class="form-group">
            <label>Número de referencia</label>
            <input v-model="reference" type="text" placeholder="Ej: 12345678" class="form-input" />
          </div>
        </div>
      </div>

      <!-- ✅ Pay Button -->
      <div class="pay-actions" v-if="publishCost > 0 && (walletEnabled || paymentMethods.length > 0)">
        <div v-if="payMethod === 'wallet' && walletBalance < publishCost" class="warning-msg">
          ⚠️ Saldo insuficiente. Recarga tu wallet para continuar.
          <router-link to="/wallet" class="link-recharge" v-if="walletEnabled">Ir a recargar →</router-link>
        </div>

        <button class="btn-pay" @click="processPayment" :disabled="paying || !canPay">
          {{ paying ? '⏳ Procesando...' : `💳 Pagar $${formatCurrency(publishCost)}` }}
        </button>
      </div>

      <!-- ✅ Publicación gratuita -->
      <div v-if="publishCost === 0" class="free-publish">
        <p>🎉 Este servicio es de <strong>publicación gratuita</strong></p>
        <button class="btn-pay" @click="activateFree" :disabled="paying">
          {{ paying ? '⏳ Activando...' : '🚀 Publicar gratis' }}
        </button>
      </div>
    </template>

    <!-- Toast -->
    <div v-if="toast.show" class="toast" :class="toast.type">{{ toast.message }}</div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/authStore'
import { useSystemStore } from '@/stores/systemStore'
import { getImageUrl } from '@/utils/imageHelper'
import api from '@/axios'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const systemStore = useSystemStore()

const service = ref({})
const loading = ref(true)
const errorMsg = ref('')
const paying = ref(false)
const payMethod = ref('wallet')
const walletBalance = ref(0)
const walletEnabled = ref(false)
const publishCost = ref(0)
const paymentFile = ref(null)
const reference = ref('')
const toast = ref({ show: false, message: '', type: 'success' })

const paymentMethods = ref([])

const formatCurrency = (v) => Number(v || 0).toFixed(2)

const selectedMethod = computed(() => {
  return paymentMethods.value.find(m => m.type === payMethod.value) || null
})

const canPay = computed(() => {
  if (payMethod.value === 'wallet') return walletBalance.value >= publishCost.value
  if (selectedMethod.value) return paymentFile.value && reference.value.trim()
  return false
})


const showToast = (msg, type = 'success') => {
  toast.value = { show: true, message: msg, type }
  setTimeout(() => { toast.value.show = false }, 4000)
}

const handleFile = (e) => {
  paymentFile.value = e.target.files[0] || null
}

const loadServiceData = async () => {
  const serviceId = route.params.id
  if (!serviceId) {
    errorMsg.value = 'ID de servicio no encontrado'
    loading.value = false
    return
  }

  try {
    const [serviceRes, costRes, walletRes, paymentMethodsRes] = await Promise.all([
      api.get(`/services/${serviceId}`, { headers: { Authorization: `Bearer ${authStore.token}` } }),
      api.get('/monetization/publish-cost'),
      api.get('/wallet', { headers: { Authorization: `Bearer ${authStore.token}` } }).catch(() => ({ data: { balance: 0 } })),
      api.get('/payments/admin-methods').catch(() => ({ data: { methods: [] } }))
    ])

    service.value = serviceRes.data?.data || serviceRes.data || {}
    publishCost.value = parseFloat(costRes.data?.publish_cost || 0)
    walletBalance.value = parseFloat(walletRes.data?.balance || 0)
    walletEnabled.value = costRes.data?.wallet_enabled || systemStore.walletEnabled

    // ✅ CORREGIDO: métodos vienen como array del endpoint admin-methods
    paymentMethods.value = paymentMethodsRes.data?.methods || []

    // ✅ Seleccionar método por defecto
    if (walletEnabled.value) {
      payMethod.value = 'wallet'
    } else if (paymentMethods.value.length > 0) {
      payMethod.value = paymentMethods.value[0].type
    }

  } catch (e) {
    console.error('ServicePublish error:', e)
    errorMsg.value = 'Error al cargar datos: ' + (e.response?.data?.error || e.message || 'Desconocido')
  } finally {
    loading.value = false
  }
}

const activateFree = async () => {
  const serviceId = route.params.id
  paying.value = true
  try {
    const { data } = await api.post(`/services/${serviceId}/publish`, {}, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    showToast(data?.message || 'Servicio publicado gratuitamente')
    router.push('/myservices')
  } catch (e) {
    showToast(e.response?.data?.error || 'Error', 'error')
  } finally {
    paying.value = false
  }
}

const processPayment = async () => {
  const serviceId = route.params.id
  paying.value = true

  try {
    if (payMethod.value === 'wallet') {
      const { data } = await api.post(`/services/${serviceId}/publish`, {}, {
        headers: { Authorization: `Bearer ${authStore.token}` }
      })
      showToast(data?.message || 'Pago exitoso. El admin verificará tu servicio.')
      router.push('/myservices')
    } else {
      const formData = new FormData()
      formData.append('payment_method', payMethod.value)
      formData.append('reference', reference.value)
      if (paymentFile.value) formData.append('payment_proof', paymentFile.value)

      const { data } = await api.post(`/services/${serviceId}/publish-external`, formData, {
        headers: { Authorization: `Bearer ${authStore.token}`, 'Content-Type': 'multipart/form-data' }
      })
      showToast(data?.message || 'Comprobante enviado. El admin verificará tu pago.')
      router.push('/myservices')
    }
  } catch (e) {
    showToast(e.response?.data?.error || 'Error al procesar pago', 'error')
  } finally {
    paying.value = false
  }
}

onMounted(loadServiceData)
</script>

<style scoped>
.service-publish-container {
  max-width: 700px;
  margin: 0 auto;
  padding: 24px;
}

/* Loading */
.loading-section { text-align: center; padding: 80px 0; }
.spinner {
  width: 40px; height: 40px;
  border: 4px solid #e0e0e0;
  border-top-color: #667eea;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
  margin: 0 auto 16px;
}
@keyframes spin { to { transform: rotate(360deg); } }

/* Error */
.error-section { text-align: center; padding: 60px 0; }
.error-icon { font-size: 3rem; }
.btn-back { display: inline-block; margin-top: 12px; color: #667eea; }

/* Header */
.header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 24px;
  flex-wrap: wrap;
  gap: 12px;
}

.title-section h1 { margin: 0; font-size: 1.8rem; }
.title-section p { color: #666; margin: 4px 0 0; }
.icon { margin-right: 8px; }
.btn-back-link { color: #667eea; text-decoration: none; }

/* Summary */
.service-summary { margin-bottom: 24px; }
.summary-card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
}
.summary-header {
  display: flex;
  gap: 16px;
  margin-bottom: 16px;
  padding-bottom: 16px;
  border-bottom: 1px solid #f0f0f0;
}
.service-image { width: 80px; height: 80px; border-radius: 10px; object-fit: cover; }
.service-image-placeholder {
  width: 80px; height: 80px;
  border-radius: 10px;
  background: #f5f5f5;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 2rem;
}
.service-info h2 { margin: 0 0 4px; }
.service-category { color: #667eea; font-weight: 500; margin: 0; }
.service-location { color: #888; margin: 4px 0 0; font-size: 0.9rem; }

.detail-row {
  display: flex;
  justify-content: space-between;
  padding: 8px 0;
  color: #666;
}
.detail-row.highlight { color: #333; font-weight: 500; }
.detail-row.total {
  border-top: 2px solid #667eea;
  margin-top: 4px;
  padding-top: 12px;
  font-size: 1.2rem;
  font-weight: 700;
  color: #1a1a2e;
}

/* Payment Section */
.payment-section { margin-bottom: 24px; }
.payment-section h2 { margin-bottom: 12px; }

.payment-card {
  background: white;
  border: 2px solid #eee;
  border-radius: 12px;
  padding: 16px;
  display: flex;
  align-items: center;
  gap: 14px;
  cursor: pointer;
  transition: all 0.3s;
  margin-bottom: 10px;
}
.payment-card:hover { border-color: #667eea; }
.payment-card.active { border-color: #667eea; background: #f8f9ff; }

.radio-circle {
  width: 20px; height: 20px;
  border-radius: 50%;
  border: 2px solid #ccc;
}
.radio-circle.selected { border-color: #667eea; background: #667eea; }

.payment-icon { font-size: 1.5rem; }
.payment-info h3 { margin: 0 0 4px; font-size: 1rem; }
.payment-info p { margin: 0; color: #888; font-size: 0.9rem; }
.check-icon { margin-left: auto; font-size: 1.2rem; }

/* Transfer */
.transfer-section { margin-bottom: 24px; }
.bank-info {
  background: white;
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 16px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
}
.bank-details p { margin: 4px 0; }

.upload-section {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
}

.upload-area {
  border: 2px dashed #ddd;
  border-radius: 10px;
  padding: 24px;
  text-align: center;
  cursor: pointer;
  margin-bottom: 16px;
  transition: border-color 0.3s;
}
.upload-area:hover { border-color: #667eea; }
.upload-icon { font-size: 2rem; }
.upload-preview { display: flex; align-items: center; gap: 8px; }
.file-icon { font-size: 1.2rem; }
.btn-remove-file {
  background: #fce4ec;
  border: none;
  border-radius: 50%;
  width: 24px; height: 24px;
  cursor: pointer;
  margin-left: auto;
}
.hidden-input { display: none; }

.form-group { margin-bottom: 12px; }
.form-group label { display: block; font-weight: 600; margin-bottom: 4px; }
.form-input {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 1rem;
}

/* Pay Actions */
.pay-actions { text-align: center; }
.warning-msg {
  background: #fff3e0;
  padding: 12px;
  border-radius: 8px;
  margin-bottom: 12px;
  color: #e65100;
}
.link-recharge { color: #667eea; margin-left: 8px; }

.btn-pay {
  padding: 14px 40px;
  background: #667eea;
  color: white;
  border: none;
  border-radius: 10px;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.3s;
}
.btn-pay:hover:not(:disabled) { background: #5a6fd6; }
.btn-pay:disabled { opacity: 0.5; cursor: not-allowed; }

/* Toast */
.toast {
  position: fixed;
  bottom: 24px;
  right: 24px;
  padding: 12px 24px;
  border-radius: 8px;
  color: white;
  z-index: 1000;
}
.toast.success { background: #4caf50; }
.toast.error { background: #f44336; }

.service-publish-container { max-width: 700px; margin: 0 auto; padding: 24px; }
.loading-section { text-align: center; padding: 80px 0; }
.spinner { width: 40px; height: 40px; border: 4px solid #e0e0e0; border-top-color: #667eea; border-radius: 50%; animation: spin 0.8s linear infinite; margin: 0 auto 16px; }
@keyframes spin { to { transform: rotate(360deg); } }
.error-section { text-align: center; padding: 60px 0; }
.error-icon { font-size: 3rem; }
.btn-back { display: inline-block; margin-top: 12px; color: #667eea; }

.header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 24px; flex-wrap: wrap; gap: 12px; }
.title-section h1 { margin: 0; font-size: 1.8rem; }
.title-section p { color: #666; margin: 4px 0 0; }
.icon { margin-right: 8px; }
.btn-back-link { color: #667eea; text-decoration: none; }

.service-summary { margin-bottom: 24px; }
.summary-card { background: white; border-radius: 12px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); }
.summary-header { display: flex; gap: 16px; margin-bottom: 16px; padding-bottom: 16px; border-bottom: 1px solid #f0f0f0; }
.service-image { width: 80px; height: 80px; border-radius: 10px; object-fit: cover; }
.service-image-placeholder { width: 80px; height: 80px; border-radius: 10px; background: #f5f5f5; display: flex; align-items: center; justify-content: center; font-size: 2rem; }
.service-info h2 { margin: 0 0 4px; }
.service-category { color: #667eea; font-weight: 500; margin: 0; }
.service-location { color: #888; margin: 4px 0 0; font-size: 0.9rem; }

.detail-row { display: flex; justify-content: space-between; padding: 8px 0; color: #666; }
.detail-row.highlight { color: #333; font-weight: 500; }
.detail-row.total { border-top: 2px solid #667eea; margin-top: 4px; padding-top: 12px; font-size: 1.2rem; font-weight: 700; color: #1a1a2e; }

.payment-section { margin-bottom: 24px; }
.payment-section h2 { margin-bottom: 12px; }
.payment-card { background: white; border: 2px solid #eee; border-radius: 12px; padding: 16px; display: flex; align-items: center; gap: 14px; cursor: pointer; transition: all 0.3s; margin-bottom: 10px; }
.payment-card:hover { border-color: #667eea; }
.payment-card.active { border-color: #667eea; background: #f8f9ff; }
.radio-circle { width: 20px; height: 20px; border-radius: 50%; border: 2px solid #ccc; }
.radio-circle.selected { border-color: #667eea; background: #667eea; }
.payment-icon { font-size: 1.5rem; }
.payment-info h3 { margin: 0 0 4px; font-size: 1rem; }
.payment-info p { margin: 0; color: #888; font-size: 0.9rem; }
.check-icon { margin-left: auto; font-size: 1.2rem; }

.transfer-section { margin-bottom: 24px; }
.bank-info { background: white; border-radius: 12px; padding: 20px; margin-bottom: 16px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); }
.bank-details p { margin: 4px 0; }
.upload-section { background: white; border-radius: 12px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); }
.upload-area { border: 2px dashed #ddd; border-radius: 10px; padding: 24px; text-align: center; cursor: pointer; margin-bottom: 16px; transition: border-color 0.3s; }
.upload-area:hover { border-color: #667eea; }
.upload-icon { font-size: 2rem; }
.upload-preview { display: flex; align-items: center; gap: 8px; }
.file-icon { font-size: 1.2rem; }
.btn-remove-file { background: #fce4ec; border: none; border-radius: 50%; width: 24px; height: 24px; cursor: pointer; margin-left: auto; }
.hidden-input { display: none; }
.form-group { margin-bottom: 12px; }
.form-group label { display: block; font-weight: 600; margin-bottom: 4px; }
.form-input { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 8px; font-size: 1rem; }

.pay-actions { text-align: center; }
.warning-msg { background: #fff3e0; padding: 12px; border-radius: 8px; margin-bottom: 12px; color: #e65100; }
.link-recharge { color: #667eea; margin-left: 8px; }

.btn-pay { padding: 14px 40px; background: #667eea; color: white; border: none; border-radius: 10px; font-size: 1.1rem; font-weight: 600; cursor: pointer; transition: background 0.3s; }
.btn-pay:hover:not(:disabled) { background: #5a6fd6; }
.btn-pay:disabled { opacity: 0.5; cursor: not-allowed; }

.free-publish { text-align: center; padding: 20px; }
.free-publish p { font-size: 1.1rem; margin-bottom: 16px; }

.toast { position: fixed; bottom: 24px; right: 24px; padding: 12px 24px; border-radius: 8px; color: white; z-index: 1000; }
.toast.success { background: #4caf50; }
.toast.error { background: #f44336; }

.service-publish-container { max-width: 700px; margin: 0 auto; padding: 24px; }
.loading-section { text-align: center; padding: 80px 0; }
.spinner { width: 40px; height: 40px; border: 4px solid #e0e0e0; border-top-color: #667eea; border-radius: 50%; animation: spin 0.8s linear infinite; margin: 0 auto 16px; }
@keyframes spin { to { transform: rotate(360deg); } }
.error-section { text-align: center; padding: 60px 0; }
.error-icon { font-size: 3rem; }
.btn-back { display: inline-block; margin-top: 12px; color: #667eea; }

.header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 24px; flex-wrap: wrap; gap: 12px; }
.title-section h1 { margin: 0; font-size: 1.8rem; }
.title-section p { color: #666; margin: 4px 0 0; }
.icon { margin-right: 8px; }
.btn-back-link { color: #667eea; text-decoration: none; }

.service-summary { margin-bottom: 24px; }
.summary-card { background: white; border-radius: 12px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); }
.summary-header { display: flex; gap: 16px; margin-bottom: 16px; padding-bottom: 16px; border-bottom: 1px solid #f0f0f0; }
.service-image { width: 80px; height: 80px; border-radius: 10px; object-fit: cover; }
.service-image-placeholder { width: 80px; height: 80px; border-radius: 10px; background: #f5f5f5; display: flex; align-items: center; justify-content: center; font-size: 2rem; }
.service-info h2 { margin: 0 0 4px; }
.service-category { color: #667eea; font-weight: 500; margin: 0; }
.service-location { color: #888; margin: 4px 0 0; font-size: 0.9rem; }

.detail-row { display: flex; justify-content: space-between; padding: 8px 0; color: #666; }
.detail-row.highlight { color: #333; font-weight: 500; }
.detail-row.total { border-top: 2px solid #667eea; margin-top: 4px; padding-top: 12px; font-size: 1.2rem; font-weight: 700; color: #1a1a2e; }

.payment-section { margin-bottom: 24px; }
.payment-section h2 { margin-bottom: 12px; }
.payment-card { background: white; border: 2px solid #eee; border-radius: 12px; padding: 16px; display: flex; align-items: center; gap: 14px; cursor: pointer; transition: all 0.3s; margin-bottom: 10px; }
.payment-card:hover { border-color: #667eea; }
.payment-card.active { border-color: #667eea; background: #f8f9ff; }
.radio-circle { width: 20px; height: 20px; border-radius: 50%; border: 2px solid #ccc; }
.radio-circle.selected { border-color: #667eea; background: #667eea; }
.payment-icon { font-size: 1.5rem; }
.payment-info h3 { margin: 0 0 4px; font-size: 1rem; }
.payment-info p { margin: 0; color: #888; font-size: 0.9rem; }
.check-icon { margin-left: auto; font-size: 1.2rem; }

.no-methods { text-align: center; padding: 30px; background: #fff3e0; border-radius: 10px; }
.no-methods .warning-icon { font-size: 2rem; }
.no-methods h3 { color: #e65100; margin: 8px 0; }
.no-methods p { color: #666; }

.transfer-section { margin-bottom: 24px; }
.bank-info { background: white; border-radius: 12px; padding: 20px; margin-bottom: 16px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); }
.bank-details p { margin: 4px 0; }
.upload-section { background: white; border-radius: 12px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); }
.upload-area { border: 2px dashed #ddd; border-radius: 10px; padding: 24px; text-align: center; cursor: pointer; margin-bottom: 16px; transition: border-color 0.3s; }
.upload-area:hover { border-color: #667eea; }
.upload-icon { font-size: 2rem; }
.upload-preview { display: flex; align-items: center; gap: 8px; }
.file-icon { font-size: 1.2rem; }
.btn-remove-file { background: #fce4ec; border: none; border-radius: 50%; width: 24px; height: 24px; cursor: pointer; margin-left: auto; }
.hidden-input { display: none; }
.form-group { margin-bottom: 12px; }
.form-group label { display: block; font-weight: 600; margin-bottom: 4px; }
.form-input { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 8px; font-size: 1rem; }

.pay-actions { text-align: center; }
.warning-msg { background: #fff3e0; padding: 12px; border-radius: 8px; margin-bottom: 12px; color: #e65100; }
.link-recharge { color: #667eea; margin-left: 8px; }

.btn-pay { padding: 14px 40px; background: #667eea; color: white; border: none; border-radius: 10px; font-size: 1.1rem; font-weight: 600; cursor: pointer; transition: background 0.3s; }
.btn-pay:hover:not(:disabled) { background: #5a6fd6; }
.btn-pay:disabled { opacity: 0.5; cursor: not-allowed; }

.free-publish { text-align: center; padding: 20px; }
.free-publish p { font-size: 1.1rem; margin-bottom: 16px; }

.toast { position: fixed; bottom: 24px; right: 24px; padding: 12px 24px; border-radius: 8px; color: white; z-index: 1000; }
.toast.success { background: #4caf50; }
.toast.error { background: #f44336; }
</style>
