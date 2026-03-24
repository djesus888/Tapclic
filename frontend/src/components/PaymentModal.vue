<script setup lang="ts">
import { ref, watch, computed } from 'vue'
import api from '@/axios'
import { useAuthStore } from '@/stores/authStore'

interface ServiceRequest {
  requestId: number
  provider: {
    paymentInfo?: {
      pagoMovil?: { banco: string; telefono: string; cedula: string }
      transferencia?: { banco: string; cuenta: string; cedula: string }
      paypal?: { email: string }
      zelle?: { email: string }
    }
  }
}

const props = defineProps<{ isOpen: boolean; request: ServiceRequest }>()
const emit = defineEmits<{
  (e: 'update:isOpen', value: boolean): void
  (e: 'on-payment-submit', method: string): void
}>()

const paymentMethod = ref<'efectivo' | 'pago-movil' | 'transferencia' | 'paypal' | 'zelle'>('efectivo')
const reference = ref('')
const captureFile = ref<File | null>(null)
const loading = ref(false)

/* ----------  Validación  ---------- */
const needsRefOrCapture = computed(() => paymentMethod.value !== 'efectivo')
const hasRefOrCapture = computed(() => !!reference.value.trim() || !!captureFile.value)
const canSubmit = computed(() => !needsRefOrCapture.value || hasRefOrCapture.value)

watch(() => props.isOpen, val => {
  if (val) {
    paymentMethod.value = 'efectivo'
    reference.value = ''
    captureFile.value = null
  }
})

function handleFileUpload(e: Event) {
  const target = e.target as HTMLInputElement
  if (target.files && target.files[0]) captureFile.value = target.files[0]
}

async function submitPayment() {
  if (needsRefOrCapture.value && !hasRefOrCapture.value) {
    alert('Datos requeridos: ingresa el número de referencia o selecciona un capture.')
    return
  }

  const requestId = props.request?.requestId
  if (!requestId) {
    alert('Solicitud inválida')
    return
  }

  loading.value = true
  try {
    const authStore = useAuthStore()
    if (!authStore.token) {
      alert('Usuario no autenticado')
      return
    }

    const formData = new FormData()
    formData.append('request_id', requestId.toString())
    formData.append('payment_method', paymentMethod.value)
    formData.append('reference', reference.value.trim())
    if (captureFile.value) formData.append('proof_file', captureFile.value)

    const res = await api.post('/payments/create', formData, {
      headers: {
        Authorization: `Bearer ${authStore.token}`,
        'Content-Type': 'multipart/form-data'
      }
    })

    if (!res.data?.success) throw new Error(res.data?.error || 'Error al procesar el pago')

    emit('update:isOpen', false)
    emit('on-payment-submit', paymentMethod.value)
  } catch (err: any) {
    console.error('Error submitPayment:', err)
    alert(err?.message || 'Hubo un problema al procesar el pago.')
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <transition name="fade">
    <div v-if="props.isOpen" class="modal-overlay">
      <div class="modal-container">
        <div class="modal-card">
          <!-- Header -->
          <div class="modal-header">
            <h2 class="modal-title">💳 Realizar Pago</h2>
            <p class="modal-subtitle">Selecciona un método de pago para completar la transacción</p>
          </div>

          <!-- Métodos de pago -->
          <div class="payment-methods">
            <div class="methods-grid">
              <!-- Efectivo -->
              <label class="method-card" :class="{ active: paymentMethod === 'efectivo' }">
                <div class="method-icon">💵</div>
                <div class="method-content">
                  <input 
                    type="radio" 
                    value="efectivo" 
                    v-model="paymentMethod" 
                    class="method-radio"
                  />
                  <h4 class="method-name">Efectivo</h4>
                  <p class="method-description">Pago al finalizar el servicio</p>
                </div>
              </label>

              <!-- Pago Móvil -->
              <label 
                v-if="props.request.provider.paymentInfo?.pagoMovil" 
                class="method-card" 
                :class="{ active: paymentMethod === 'pago-movil' }"
              >
                <div class="method-icon">📱</div>
                <div class="method-content">
                  <input 
                    type="radio" 
                    value="pago-movil" 
                    v-model="paymentMethod" 
                    class="method-radio"
                  />
                  <h4 class="method-name">Pago Móvil</h4>
                  <p class="method-description">Transferencia desde tu móvil</p>
                </div>
              </label>

              <!-- Transferencia -->
              <label 
                v-if="props.request.provider.paymentInfo?.transferencia" 
                class="method-card" 
                :class="{ active: paymentMethod === 'transferencia' }"
              >
                <div class="method-icon">💳</div>
                <div class="method-content">
                  <input 
                    type="radio" 
                    value="transferencia" 
                    v-model="paymentMethod" 
                    class="method-radio"
                  />
                  <h4 class="method-name">Transferencia</h4>
                  <p class="method-description">Transferencia bancaria</p>
                </div>
              </label>

              <!-- PayPal -->
              <label 
                v-if="props.request.provider.paymentInfo?.paypal" 
                class="method-card" 
                :class="{ active: paymentMethod === 'paypal' }"
              >
                <div class="method-icon">🅿️</div>
                <div class="method-content">
                  <input 
                    type="radio" 
                    value="paypal" 
                    v-model="paymentMethod" 
                    class="method-radio"
                  />
                  <h4 class="method-name">PayPal</h4>
                  <p class="method-description">Pago seguro online</p>
                </div>
              </label>

              <!-- Zelle -->
              <label 
                v-if="props.request.provider.paymentInfo?.zelle" 
                class="method-card" 
                :class="{ active: paymentMethod === 'zelle' }"
              >
                <div class="method-icon">🇺🇸</div>
                <div class="method-content">
                  <input 
                    type="radio" 
                    value="zelle" 
                    v-model="paymentMethod" 
                    class="method-radio"
                  />
                  <h4 class="method-name">Zelle</h4>
                  <p class="method-description">Transferencia rápida USA</p>
                </div>
              </label>
            </div>
          </div>

          <!-- Detalles del método seleccionado -->
          <div v-if="paymentMethod !== 'efectivo'" class="method-details">
            <div class="details-header">
              <h3 class="details-title">Información de Pago</h3>
              <div class="details-badge">{{ paymentMethod }}</div>
            </div>

            <!-- Pago Móvil -->
            <div 
              v-if="paymentMethod === 'pago-movil' && props.request.provider.paymentInfo?.pagoMovil" 
              class="details-content"
            >
              <div class="detail-item">
                <span class="detail-label">🏦 Banco:</span>
                <span class="detail-value">{{ props.request.provider.paymentInfo.pagoMovil.banco }}</span>
              </div>
              <div class="detail-item">
                <span class="detail-label">📞 Teléfono:</span>
                <span class="detail-value">{{ props.request.provider.paymentInfo.pagoMovil.telefono }}</span>
              </div>
              <div class="detail-item">
                <span class="detail-label">🆔 CI/RIF:</span>
                <span class="detail-value">{{ props.request.provider.paymentInfo.pagoMovil.cedula }}</span>
              </div>
            </div>

            <!-- Transferencia -->
            <div 
              v-if="paymentMethod === 'transferencia' && props.request.provider.paymentInfo?.transferencia" 
              class="details-content"
            >
              <div class="detail-item">
                <span class="detail-label">🏦 Banco:</span>
                <span class="detail-value">{{ props.request.provider.paymentInfo.transferencia.banco }}</span>
              </div>
              <div class="detail-item">
                <span class="detail-label">💳 Cuenta:</span>
                <span class="detail-value">{{ props.request.provider.paymentInfo.transferencia.cuenta }}</span>
              </div>
              <div class="detail-item">
                <span class="detail-label">🆔 CI/RIF:</span>
                <span class="detail-value">{{ props.request.provider.paymentInfo.transferencia.cedula }}</span>
              </div>
            </div>

            <!-- PayPal -->
            <div 
              v-if="paymentMethod === 'paypal' && props.request.provider.paymentInfo?.paypal" 
              class="details-content"
            >
              <div class="detail-item">
                <span class="detail-label">📧 Email PayPal:</span>
                <span class="detail-value">{{ props.request.provider.paymentInfo.paypal.email }}</span>
              </div>
            </div>

            <!-- Zelle -->
            <div 
              v-if="paymentMethod === 'zelle' && props.request.provider.paymentInfo?.zelle" 
              class="details-content"
            >
              <div class="detail-item">
                <span class="detail-label">📧 Email Zelle:</span>
                <span class="detail-value">{{ props.request.provider.paymentInfo.zelle.email }}</span>
              </div>
            </div>
          </div>

          <!-- Referencia y archivo -->
          <div v-if="needsRefOrCapture" class="reference-section">
            <div class="section-header">
              <h3 class="section-title">Comprobante de Pago</h3>
              <p class="section-subtitle">Ingresa el número de referencia o adjunta un capture</p>
            </div>

            <div class="reference-inputs">
              <div class="input-group">
                <label class="input-label">Número de Referencia</label>
                <input 
                  type="text" 
                  v-model="reference" 
                  placeholder="Ej: 1234567890" 
                  class="text-input"
                />
              </div>

              <div class="file-upload">
                <label class="file-label">
                  <span class="file-icon">📤</span>
                  <span class="file-text">
                    {{ captureFile ? captureFile.name : 'Seleccionar capture' }}
                  </span>
                  <input 
                    type="file" 
                    class="file-input" 
                    @change="handleFileUpload"
                    accept="image/*,.pdf"
                  />
                </label>
                <p v-if="captureFile" class="file-info">
                  Archivo seleccionado: {{ captureFile.name }} ({{ (captureFile.size / 1024).toFixed(0) }} KB)
                </p>
              </div>
            </div>
          </div>

          <!-- Footer -->
          <div class="modal-footer">
            <div class="footer-actions">
              <button 
                @click="emit('update:isOpen', false)" 
                class="btn-secondary"
                :disabled="loading"
              >
                Cancelar
              </button>
              <button
                @click="submitPayment"
                class="btn-primary"
                :disabled="loading || !canSubmit"
                :class="{ 'btn-loading': loading }"
              >
                <span v-if="loading" class="loading-spinner"></span>
                <span v-else class="btn-content">
                  <span class="btn-icon">💳</span>
                  {{ loading ? 'Procesando...' : 'Realizar Pago' }}
                </span>
              </button>
            </div>

            <div v-if="!canSubmit" class="validation-warning">
              ⚠️ Para continuar, ingresa el número de referencia o adjunta un capture
            </div>
          </div>
        </div>
      </div>
    </div>
  </transition>
</template>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
  backdrop-filter: blur(4px);
  animation: fadeIn 0.3s ease-out;
}

@keyframes fadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

.modal-container {
  width: 90%;
  max-width: 500px;
  animation: slideUp 0.4s ease-out;
}

@keyframes slideUp {
  from {
    transform: translateY(20px);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

.modal-card {
  background: white;
  border-radius: 24px;
  overflow: hidden;
  box-shadow: 0 25px 50px rgba(0, 0, 0, 0.25);
  animation: cardAppear 0.5s ease-out;
  border: 1px solid rgba(255, 255, 255, 0.1);
}

@keyframes cardAppear {
  from {
    transform: scale(0.95);
    opacity: 0;
  }
  to {
    transform: scale(1);
    opacity: 1;
  }
}

/* Header */
.modal-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 32px 32px 24px;
  color: white;
  text-align: center;
}

.modal-title {
  font-size: 1.8rem;
  font-weight: 700;
  margin-bottom: 8px;
}

.modal-subtitle {
  font-size: 0.95rem;
  opacity: 0.9;
}

/* Payment Methods */
.payment-methods {
  padding: 24px 32px 0;
}

.methods-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
  gap: 16px;
}

.method-card {
  background: #f8f9fa;
  border: 2px solid transparent;
  border-radius: 16px;
  padding: 20px;
  cursor: pointer;
  transition: all 0.3s;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  position: relative;
}

.method-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
  border-color: #667eea;
}

.method-card.active {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  border-color: #f093fb;
  color: white;
}

.method-card.active .method-description {
  color: rgba(255, 255, 255, 0.9);
}

.method-icon {
  font-size: 2.5rem;
  margin-bottom: 12px;
}

.method-content {
  flex: 1;
}

.method-radio {
  position: absolute;
  opacity: 0;
  width: 0;
  height: 0;
}

.method-name {
  font-size: 1rem;
  font-weight: 600;
  margin-bottom: 4px;
}

.method-description {
  font-size: 0.8rem;
  color: #666;
  line-height: 1.3;
}

/* Method Details */
.method-details {
  background: linear-gradient(135deg, #a8edea 0%, #fed6e3 100%);
  margin: 24px 32px;
  border-radius: 16px;
  padding: 20px;
  animation: fadeInUp 0.5s ease-out;
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.details-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.details-title {
  font-size: 1.1rem;
  font-weight: 600;
  color: #2d3436;
}

.details-badge {
  background: rgba(255, 255, 255, 0.2);
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
  color: white;
  backdrop-filter: blur(10px);
}

.details-content {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.detail-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  background: rgba(255, 255, 255, 0.3);
  border-radius: 12px;
  backdrop-filter: blur(5px);
}

.detail-label {
  font-weight: 600;
  color: #2d3436;
  min-width: 120px;
}

.detail-value {
  color: #636e72;
  font-weight: 500;
  word-break: break-all;
}

/* Reference Section */
.reference-section {
  padding: 0 32px;
  margin: 24px 0;
}

.section-header {
  margin-bottom: 20px;
}

.section-title {
  font-size: 1.2rem;
  font-weight: 600;
  color: #2d3436;
  margin-bottom: 4px;
}

.section-subtitle {
  color: #636e72;
  font-size: 0.9rem;
}

.reference-inputs {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.input-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.input-label {
  font-weight: 600;
  color: #2d3436;
  font-size: 0.9rem;
}

.text-input {
  padding: 14px 16px;
  border: 2px solid #dfe6e9;
  border-radius: 12px;
  font-size: 1rem;
  transition: all 0.3s;
}

.text-input:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.text-input::placeholder {
  color: #b2bec3;
}

.file-upload {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.file-label {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px 20px;
  background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%);
  color: white;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s;
  font-weight: 600;
}

.file-label:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 20px rgba(116, 185, 255, 0.3);
}

.file-icon {
  font-size: 1.2rem;
}

.file-text {
  flex: 1;
}

.file-input {
  display: none;
}

.file-info {
  font-size: 0.85rem;
  color: #636e72;
  padding-left: 12px;
}

/* Footer */
.modal-footer {
  padding: 24px 32px 32px;
  background: #f8f9fa;
  border-top: 1px solid #e9ecef;
}

.footer-actions {
  display: flex;
  gap: 16px;
  margin-bottom: 16px;
}

.btn-secondary, .btn-primary {
  flex: 1;
  padding: 16px 24px;
  border: none;
  border-radius: 12px;
  font-weight: 600;
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.3s;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
}

.btn-secondary {
  background: white;
  color: #636e72;
  border: 2px solid #dfe6e9;
}

.btn-secondary:hover:not(:disabled) {
  border-color: #74b9ff;
  color: #0984e3;
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(116, 185, 255, 0.2);
}

.btn-primary {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
  color: white;
  position: relative;
}

.btn-primary:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 10px 25px rgba(0, 184, 148, 0.3);
}

.btn-primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none !important;
  box-shadow: none !important;
}

.btn-loading {
  background: linear-gradient(135deg, #81ecec 0%, #00cec9 100%);
}

.loading-spinner {
  width: 20px;
  height: 20px;
  border: 3px solid rgba(255, 255, 255, 0.3);
  border-top: 3px solid white;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.btn-content {
  display: flex;
  align-items: center;
  gap: 8px;
}

.btn-icon {
  font-size: 1.2rem;
}

.validation-warning {
  background: #fff9db;
  border: 2px solid #ffd43b;
  border-radius: 12px;
  padding: 12px 16px;
  color: #5c3c00;
  font-size: 0.9rem;
  text-align: center;
  animation: shake 0.5s ease-in-out;
}

@keyframes shake {
  0%, 100% { transform: translateX(0); }
  25% { transform: translateX(-5px); }
  75% { transform: translateX(5px); }
}

/* Responsive */
@media (max-width: 768px) {
  .modal-container {
    width: 95%;
    max-width: 400px;
  }
  
  .modal-header,
  .payment-methods,
  .method-details,
  .reference-section,
  .modal-footer {
    padding-left: 20px;
    padding-right: 20px;
  }
  
  .methods-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .footer-actions {
    flex-direction: column;
  }
  
  .detail-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 4px;
  }
  
  .detail-label {
    min-width: auto;
  }
}

@media (max-width: 480px) {
  .methods-grid {
    grid-template-columns: 1fr;
  }
  
  .modal-title {
    font-size: 1.5rem;
  }
  
  .method-icon {
    font-size: 2rem;
  }
}

/* Transition */
.fade-enter-active, .fade-leave-active {
  transition: opacity 0.3s;
}
.fade-enter-from, .fade-leave-to {
  opacity: 0;
}
</style>
