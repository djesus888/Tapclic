<template>
  <div class="wallet-page">
    <!-- Header con gradiente y animación -->
    <div class="wallet-header">
      <div class="header-content">
        <div class="title-section">
          <div class="wallet-icon">
            <span class="emoji-icon">💰</span>
          </div>
          <div class="title-text">
            <h1>{{ $t('wallet.title') }}</h1>
            <p>Gestiona tu saldo y movimientos</p>
          </div>
        </div>

        <!-- Fecha actual -->
        <div class="date-badge">
          <span class="date-icon">📅</span>
          <span>{{ currentDate }}</span>
        </div>
      </div>
    </div>

    <!-- Balance Card -->
    <div class="balance-card">
      <div class="balance-icon">
        <span class="emoji-icon">💳</span>
      </div>
      <div class="balance-content">
        <span class="balance-label">{{ $t('wallet.currentBalance') }}</span>
        <div class="balance-amount">
          <span class="currency">€</span>
          <span class="amount">{{ balance.toFixed(2) }}</span>
        </div>
        <span class="balance-subtitle">Saldo disponible</span>
      </div>

      <!-- Botones de acción -->
      <div class="balance-actions">
        <button
          @click.prevent="openRechargeRequestModal"
          type="button"
          class="btn-action recharge"
          :disabled="loading"
        >
          <span class="btn-icon">➕</span>
          <span class="btn-text">Solicitar recarga</span>
        </button>
        <button
          @click.prevent="openWithdrawModal"
          type="button"
          class="btn-action withdraw"
          :disabled="loading"
        >
          <span class="btn-icon">💸</span>
          <span class="btn-text">{{ $t('wallet.withdraw') }}</span>
        </button>
      </div>
    </div>

    <!-- Stats Cards -->
    <div class="summary-stats">
      <div class="stat-item">
        <div class="stat-icon" style="background: linear-gradient(135deg, #00b894 0%, #00a085 100%);">💰</div>
        <div class="stat-content">
          <h3>{{ balance.toFixed(2) }}€</h3>
          <p>Saldo actual</p>
        </div>
      </div>
      <div class="stat-item">
        <div class="stat-icon" style="background: linear-gradient(135deg, #fdcb6e 0%, #e17055 100%);">📊</div>
        <div class="stat-content">
          <h3>{{ totalTransactions }}</h3>
          <p>Total movimientos</p>
        </div>
      </div>
      <div class="stat-item">
        <div class="stat-icon" style="background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%);">💹</div>
        <div class="stat-content">
          <h3>{{ totalSpent.toFixed(2) }}€</h3>
          <p>Total gastado</p>
        </div>
      </div>
      <div class="stat-item">
        <div class="stat-icon" style="background: linear-gradient(135deg, #a8e6cf 0%, #4ecdc4 100%);">🎯</div>
        <div class="stat-content">
          <h3>{{ totalRecharged.toFixed(2) }}€</h3>
          <p>Total recargado</p>
        </div>
      </div>
    </div>

    <!-- SECCIÓN: Solicitudes Pendientes -->
    <div v-if="pendingRequests.length > 0" class="pending-requests-section">
      <div class="section-header">
        <h2>
          <span class="header-icon">⏳</span>
          Solicitudes pendientes
        </h2>
        <span class="pending-badge">{{ pendingRequests.length }}</span>
      </div>

      <div class="pending-grid">
        <div v-for="req in pendingRequests" :key="req.id" class="pending-card">
          <div class="pending-header">
            <span class="request-id">#{{ req.reference || req.id }}</span>
            <span class="request-status pending">⏳ Pendiente</span>
          </div>

          <div class="pending-amount">
            <span class="currency">€</span>
            <span class="amount">{{ req.amount.toFixed(2) }}</span>
          </div>

          <div class="pending-details">
            <div class="detail-item">
              <span class="detail-label">📅 Fecha:</span>
              <span class="detail-value">{{ formatDate(req.created_at) }}</span>
            </div>
            <div class="detail-item">
              <span class="detail-label">💳 Método:</span>
              <span class="detail-value">{{ formatPaymentMethod(req.payment_method) }}</span>
            </div>
            <div class="detail-item">
              <span class="detail-label">🔖 Referencia:</span>
              <span class="detail-value">{{ req.reference }}</span>
            </div>
          </div>

          <div class="pending-actions">
            <button v-if="!req.payment_proof" @click="openProofUploadModal(req)" class="btn-upload">
              📎 Subir comprobante
            </button>
            <a v-else :href="req.payment_proof" target="_blank" class="btn-view-proof">
              👁️ Ver comprobante
            </a>
            <button @click="cancelRequest(req.id)" class="btn-cancel-small">
              ✕ Cancelar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Transactions Section -->
    <div class="transactions-section">
      <div class="section-header">
        <h2>
          <span class="header-icon">📋</span>
          Historial de movimientos
        </h2>
        <div class="filter-tabs" v-if="transactions.length > 0">
          <button class="filter-tab" :class="{ active: filterType === 'all' }" @click="filterType = 'all'">Todos</button>
          <button class="filter-tab" :class="{ active: filterType === 'credit' }" @click="filterType = 'credit'">Ingresos</button>
          <button class="filter-tab" :class="{ active: filterType === 'debit' }" @click="filterType = 'debit'">Gastos</button>
        </div>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="loading-container">
        <div class="spinner"></div>
        <p>{{ $t('loading') }}...</p>
      </div>

      <!-- Transactions Grid -->
      <div v-else-if="filteredTransactions.length > 0" class="transactions-grid">
        <div v-for="tx in filteredTransactions" :key="tx.id" class="transaction-card" :class="{ 'credit': tx.type === 'credit', 'debit': tx.type === 'debit' }">
          <div class="transaction-badge" :class="tx.type">{{ tx.type === 'credit' ? '💰' : '💸' }}</div>
          <div class="transaction-content">
            <div class="transaction-header">
              <h3 class="transaction-title">{{ txDescription(tx) }}</h3>
              <div class="transaction-amount" :class="tx.type">{{ txSign(tx.type) }}€{{ formatAmount(tx.amount) }}</div>
            </div>
            <div class="transaction-meta">
              <div class="meta-item">
                <span class="meta-icon">📅</span>
                <span class="meta-text">{{ formatDate(tx.created_at) }}</span>
              </div>
              <div class="meta-item">
                <span class="meta-icon">🏷️</span>
                <span class="meta-text">{{ tx.type === 'credit' ? 'Ingreso' : 'Gasto' }}</span>
              </div>
              <div v-if="tx.reference" class="meta-item">
                <span class="meta-icon">🔖</span>
                <span class="meta-text">Ref: {{ tx.reference }}</span>
              </div>
            </div>
            <div class="transaction-status">
              <span class="status-dot" :class="tx.status || 'completed'"></span>
              {{ tx.status === 'pending' ? 'Pendiente' : 'Completado' }}
            </div>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div v-else class="empty-state">
        <div class="empty-icon">💸</div>
        <h3>No hay movimientos</h3>
        <p>Aún no has realizado ninguna transacción</p>
        <div class="empty-actions">
          <button @click="openRechargeRequestModal" class="btn-primary">
            <span class="btn-icon">➕</span> Solicitar recarga
          </button>
        </div>
      </div>
    </div>

    <!-- MODAL SOLICITUD RECARGA -->
    <div v-if="showRechargeModal" class="modal-overlay" @click.self="showRechargeModal = false">
      <div class="modal modal-large" @click.stop>
        <div class="modal-header">
          <div class="modal-icon">💰</div>
          <h3>Solicitar recarga de saldo</h3>
          <button class="modal-close" @click="showRechargeModal = false" type="button">✕</button>
        </div>

        <div class="modal-content">
          <div class="form-group">
            <label>💰 Monto a recargar (€)</label>
            <div class="amount-input-group large">
              <span class="currency-symbol">€</span>
              <input
                type="number"
                v-model.number="rechargeForm.amount"
                min="5"
                step="0.01"
                class="amount-input"
                placeholder="0.00"
                @keyup.enter="submitRechargeRequest"
              />
            </div>
            <div class="quick-amounts">
              <button v-for="amt in [20,50,100,200]" :key="amt" type="button"
                      @click="rechargeForm.amount = amt"
                      class="quick-amount-btn">
                €{{ amt }}
              </button>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group half">
              <label>💳 Método de pago</label>
              <select v-model="rechargeForm.payment_method" class="form-select">
                <option value="">Selecciona...</option>
                <option v-for="method in paymentMethods" :key="method.value" :value="method.value">
                  {{ method.label }}
                </option>
              </select>
            </div>
            <div class="form-group half">
              <label>🔖 Número de referencia/operación</label>
              <input
                type="text"
                v-model="rechargeForm.reference"
                class="form-input"
                placeholder="Ej: 2025-02-15-12345"
                @keyup.enter="submitRechargeRequest"
              />
            </div>
          </div>

          <div class="form-group">
            <label>📎 Comprobante de pago (opcional - puedes subirlo después)</label>
            <div class="file-upload-area">
              <input
                type="file"
                ref="fileInput"
                @change="handleFileSelect"
                accept=".jpg,.jpeg,.png,.pdf"
                class="file-input"
              />
              <div v-if="selectedFile" class="file-info">
                <span class="file-name">📄 {{ selectedFile.name }}</span>
                <button @click="selectedFile = null" class="file-remove" type="button">✕</button>
              </div>
              <div v-else class="upload-placeholder">
                <span class="upload-icon">📎</span>
                <span>Haz clic o arrastra tu comprobante</span>
                <small>JPG, PNG o PDF (max. 5MB)</small>
              </div>
            </div>
          </div>

          <!-- Datos bancarios dinámicos según método seleccionado -->
          <div v-if="selectedPaymentMethodDetails" class="bank-details">
            <h4>{{ selectedPaymentMethodDetails.title }}</h4>
            <div class="bank-info-grid">
              <div v-for="(value, key) in selectedPaymentMethodDetails.fields" :key="key" class="bank-row">
                <span class="label">{{ key }}:</span>
                <span class="value">{{ value }}</span>
                <button @click="copyToClipboard(value)" class="btn-copy" type="button">📋</button>
              </div>
              <div class="bank-row" v-if="selectedPaymentMethodDetails.concept">
                <span class="label">Concepto:</span>
                <span class="value">{{ selectedPaymentMethodDetails.concept }}-{{ user?.id }}-{{ Date.now() }}</span>
                <button @click="copyToClipboard(`${selectedPaymentMethodDetails.concept}-${user?.id}-${Date.now()}`)" class="btn-copy" type="button">📋</button>
              </div>
            </div>
          </div>
        </div>

        <div class="modal-actions">
          <button @click="showRechargeModal = false" class="btn-cancel" type="button">Cancelar</button>
          <button @click="submitRechargeRequest" class="btn-confirm recharge"
                  :disabled="!isRechargeFormValid || submitting" type="button">
            {{ submitting ? 'Enviando...' : 'Solicitar recarga' }}
          </button>
        </div>
      </div>
    </div>

    <!-- MODAL SUBIR COMPROBANTE -->
    <div v-if="showProofModal" class="modal-overlay" @click.self="showProofModal = false">
      <div class="modal" @click.stop>
        <div class="modal-header">
          <div class="modal-icon">📎</div>
          <h3>Subir comprobante de pago</h3>
          <button class="modal-close" @click="showProofModal = false" type="button">✕</button>
        </div>
        <div class="modal-content">
          <p class="modal-description">
            Solicitud: <strong>#{{ selectedRequest?.reference || selectedRequest?.id }}</strong><br>
            Monto: <strong>€{{ selectedRequest?.amount?.toFixed(2) }}</strong>
          </p>

          <div class="file-upload-area large">
            <input
              type="file"
              ref="proofFileInput"
              @change="handleProofFileSelect"
              accept=".jpg,.jpeg,.png,.pdf"
              class="file-input"
            />
            <div v-if="selectedProofFile" class="file-info">
              <span class="file-name">📄 {{ selectedProofFile.name }}</span>
              <span class="file-size">({{ formatFileSize(selectedProofFile.size) }})</span>
              <button @click="selectedProofFile = null" class="file-remove" type="button">✕</button>
            </div>
            <div v-else class="upload-placeholder">
              <span class="upload-icon large">📎</span>
              <span>Selecciona el comprobante de pago</span>
              <small>JPG, PNG o PDF (max. 5MB)</small>
            </div>
          </div>
        </div>
        <div class="modal-actions">
          <button @click="showProofModal = false" class="btn-cancel" type="button">Cancelar</button>
          <button @click="submitProof" class="btn-confirm"
                  :disabled="!selectedProofFile || uploadingProof" type="button">
            {{ uploadingProof ? 'Subiendo...' : 'Subir comprobante' }}
          </button>
        </div>
      </div>
    </div>

    <!-- MODAL RETIRO -->
    <div v-if="showWithdrawModal" class="modal-overlay" @click.self="showWithdrawModal = false">
      <div class="modal" @click.stop>
        <div class="modal-header">
          <div class="modal-icon">💸</div>
          <h3>Retirar saldo</h3>
          <button class="modal-close" @click="showWithdrawModal = false" type="button">✕</button>
        </div>
        <div class="modal-content">
          <p class="modal-description">
            Ingresa la cantidad que deseas retirar
          </p>
          <div class="amount-input-group">
            <span class="currency-symbol">€</span>
            <input
              type="number"
              v-model.number="withdrawAmount"
              min="1"
              step="0.01"
              class="amount-input"
              placeholder="0.00"
              @keyup.enter="submitWithdraw"
            />
          </div>
          <p class="current-balance-info">
            Saldo disponible: <strong>€{{ balance.toFixed(2) }}</strong>
          </p>
        </div>
        <div class="modal-actions">
          <button @click="showWithdrawModal = false" class="btn-cancel" type="button">Cancelar</button>
          <button @click="submitWithdraw" class="btn-confirm withdraw" :disabled="withdrawing" type="button">
            {{ withdrawing ? 'Procesando...' : 'Retirar' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast" :class="toast.type">
      {{ toast.message }}
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed, reactive, watch } from 'vue'
import { useAuthStore } from '@/stores/authStore'
import { useI18n } from 'vue-i18n'
import api from '@/axios'
import Swal from 'sweetalert2'

const { t } = useI18n()
const auth = useAuthStore()
const user = computed(() => auth.user)

/* ---------- Tipos ---------- */
interface Transaction {
  id: number
  type: 'credit' | 'debit'
  amount: number
  description: string | null
  reference: string | null
  status: 'pending' | 'completed' | 'failed'
  created_at: string
}

interface PaymentMethod {
  value: string
  label: string
  title?: string
  fields?: Record<string, string>
  concept?: string
  is_active?: boolean
}

interface PaymentMethodsResponse {
  methods: PaymentMethod[]
  details: Record<string, PaymentMethod>
}

/* ---------- Estado ---------- */
const balance = ref<number>(0)
const transactions = ref<Transaction[]>([])
const pendingRequests = ref<any[]>([])
const loading = ref<boolean>(true)
const filterType = ref<'all' | 'credit' | 'debit'>('all')
const toast = ref<{ show: boolean; message: string; type: 'success' | 'error' | 'info' }>({
  show: false,
  message: '',
  type: 'success'
})

/* ---------- Métodos de pago desde DB (inicialmente vacíos) ---------- */
const paymentMethods = ref<PaymentMethod[]>([])
const paymentMethodDetails = ref<Record<string, PaymentMethod>>({})

const selectedPaymentMethodDetails = computed(() => {
  if (!rechargeForm.payment_method) return null
  return paymentMethodDetails.value[rechargeForm.payment_method]
})

/* ---------- Estado Modales ---------- */
const showRechargeModal = ref(false)
const showProofModal = ref(false)
const showWithdrawModal = ref(false)
const selectedRequest = ref<any>(null)
const submitting = ref(false)
const uploadingProof = ref(false)
const withdrawing = ref(false)
const selectedFile = ref<File | null>(null)
const selectedProofFile = ref<File | null>(null)
const withdrawAmount = ref<number | null>(null)

/* ---------- Formulario Recarga ---------- */
const rechargeForm = reactive({
  amount: null as number | null,
  payment_method: '',
  reference: ''
})

const isRechargeFormValid = computed(() => {
  return rechargeForm.amount && rechargeForm.amount >= 5 &&
         rechargeForm.payment_method &&
         rechargeForm.reference.trim().length > 3
})

/* ---------- Computed ---------- */
const currentDate = computed<string>(() => {
  return new Date().toLocaleDateString('es-ES', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
})

const totalTransactions = computed<number>(() => transactions.value.length)

const totalSpent = computed<number>(() => {
  return transactions.value
    .filter(tx => tx.type === 'debit' && tx.status === 'completed')
    .reduce((sum, tx) => sum + (tx.amount || 0), 0)
})

const totalRecharged = computed(() => {
  if (!transactions.value || !Array.isArray(transactions.value)) return 0
  return transactions.value
    .filter(tx => tx?.type === 'credit' && tx?.status === 'completed')
    .reduce((sum, tx) => sum + (Number(tx?.amount) || 0), 0)
})

const filteredTransactions = computed<Transaction[]>(() => {
  if (filterType.value === 'all') return transactions.value
  return transactions.value.filter(tx => tx.type === filterType.value)
})

/* ---------- Funciones auxiliares ---------- */
const txDescription = (tx: Transaction): string => {
  return tx.description || t('wallet.noDescription')
}

const txSign = (type: string): string => {
  return type === 'credit' ? '+' : '-'
}

const formatDate = (date: string): string => {
  try {
    return new Date(date).toLocaleDateString('es-ES', {
      day: '2-digit',
      month: 'short',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    })
  } catch {
    return date
  }
}

const formatAmount = (amount: any): string => {
  if (amount === null || amount === undefined) return '0.00'
  const num = Number(amount)
  return isNaN(num) ? '0.00' : num.toFixed(2)
}

const formatCurrency = (amount: number): string => {
  return new Intl.NumberFormat('es-ES', {
    style: 'currency',
    currency: 'EUR',
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(amount)
}

const formatPaymentMethod = (method: string): string => {
  const found = paymentMethods.value.find(m => m.value === method)
  return found?.label || method
}

const formatFileSize = (bytes: number): string => {
  if (bytes < 1024) return bytes + ' B'
  if (bytes < 1048576) return (bytes / 1024).toFixed(1) + ' KB'
  return (bytes / 1048576).toFixed(1) + ' MB'
}

const copyToClipboard = async (text: string): Promise<void> => {
  try {
    await navigator.clipboard.writeText(text)
    showToast('Copiado al portapapeles', 'success')
  } catch (err) {
    showToast('Error al copiar', 'error')
  }
}

const showToast = (message: string, type: 'success' | 'error' | 'info' = 'info'): void => {
  toast.value = { show: true, message, type }
  setTimeout(() => { toast.value.show = false }, 3000)
}

/* ---------- Cargar métodos de pago desde DB ---------- */
const loadPaymentMethods = async (): Promise<void> => {
  try {
    const { data } = await api.get<PaymentMethodsResponse>('/payment-methods', {
      headers: { Authorization: `Bearer ${auth.token}` }
    })
    
    // Actualizar con los datos de la base de datos
    if (data && data.methods) {
      paymentMethods.value = data.methods.filter(m => m.is_active !== false)
    }
    if (data && data.details) {
      paymentMethodDetails.value = data.details
    }
    
    console.log('Métodos de pago cargados:', paymentMethods.value)
  } catch (err) {
    console.error('Error cargando métodos de pago:', err)
    // En caso de error, mostrar mensaje pero no usar datos estáticos
    showToast('Error al cargar métodos de pago', 'error')
  }
}

/* ---------- API Calls ---------- */
const loadWallet = async (): Promise<void> => {
  loading.value = true
  try {
    let walletRes
    try {
      walletRes = await api.get('/wallet', {
        headers: { Authorization: `Bearer ${auth.token}` }
      })
      balance.value = walletRes.data.balance || 0
    } catch (err: any) {
      if (err.response?.status === 404) {
        await api.post('/wallet', {}, {
          headers: { Authorization: `Bearer ${auth.token}` }
        })
        balance.value = 0
      } else {
        throw err
      }
    }

    try {
      const txRes = await api.get('/wallet/transactions', {
        headers: { Authorization: `Bearer ${auth.token}` }
      })
      transactions.value = txRes.data || []
    } catch (err) {
      console.error('Error cargando transacciones:', err)
      transactions.value = []
    }

    try {
      const requestsRes = await api.get('/wallet/my-requests', {
        headers: { Authorization: `Bearer ${auth.token}` }
      })
      pendingRequests.value = requestsRes.data || []
    } catch (err) {
      pendingRequests.value = []
    }

  } catch (err: any) {
    console.error('Error loading wallet:', err)
    Swal.fire({
      icon: 'error',
      title: 'Error',
      text: 'No se pudo cargar la billetera',
      confirmButtonColor: '#667eea'
    })
  } finally {
    loading.value = false
  }
}

/* ---------- Solicitud de Recarga ---------- */
const openRechargeRequestModal = (): void => {
  console.log('Abriendo modal de recarga', auth.token)
  if (!auth.token) {
    Swal.fire('Error', 'Debes iniciar sesión', 'error')
    return
  }
  // Resetear formulario
  rechargeForm.amount = null
  rechargeForm.payment_method = ''
  rechargeForm.reference = ''
  selectedFile.value = null
  // Abrir modal
  showRechargeModal.value = true
}

const handleFileSelect = (event: Event): void => {
  const input = event.target as HTMLInputElement
  if (input.files && input.files[0]) {
    selectedFile.value = input.files[0]
  }
}

const submitRechargeRequest = async (): Promise<void> => {
  if (!isRechargeFormValid.value) {
    Swal.fire('Error', 'Por favor completa todos los campos requeridos', 'warning')
    return
  }

  submitting.value = true
  const formData = new FormData()
  formData.append('amount', rechargeForm.amount!.toString())
  formData.append('payment_method', rechargeForm.payment_method)
  formData.append('reference', rechargeForm.reference.trim())
  if (selectedFile.value) {
    formData.append('payment_proof', selectedFile.value)
  }

  try {
    const { data } = await api.post('/wallet/recharge-request', formData, {
      headers: {
        Authorization: `Bearer ${auth.token}`,
        'Content-Type': 'multipart/form-data'
      }
    })

    showRechargeModal.value = false
    await loadWallet()

    Swal.fire({
      icon: 'success',
      title: '✅ Solicitud enviada',
      text: `Tu solicitud de recarga #${data.request_number} ha sido enviada. El administrador la revisará pronto.`,
      confirmButtonColor: '#667eea'
    })

  } catch (err: any) {
    console.error('Error en solicitud:', err)
    Swal.fire({
      icon: 'error',
      title: 'Error',
      text: err.response?.data?.error || 'Error al enviar solicitud',
      confirmButtonColor: '#667eea'
    })
  } finally {
    submitting.value = false
  }
}

/* ---------- Comprobantes ---------- */
const openProofUploadModal = (request: any): void => {
  selectedRequest.value = request
  selectedProofFile.value = null
  showProofModal.value = true
}

const handleProofFileSelect = (event: Event): void => {
  const input = event.target as HTMLInputElement
  if (input.files && input.files[0]) {
    selectedProofFile.value = input.files[0]
  }
}

const submitProof = async (): Promise<void> => {
  if (!selectedRequest.value || !selectedProofFile.value) return

  uploadingProof.value = true
  const formData = new FormData()
  formData.append('payment_proof', selectedProofFile.value)

  try {
    await api.post(`/wallet/requests/${selectedRequest.value.id}/proof`, formData, {
      headers: {
        Authorization: `Bearer ${auth.token}`,
        'Content-Type': 'multipart/form-data'
      }
    })

    showProofModal.value = false
    await loadWallet()
    showToast('Comprobante subido exitosamente', 'success')

  } catch (err: any) {
    console.error('Error subiendo comprobante:', err)
    showToast('Error al subir comprobante', 'error')
  } finally {
    uploadingProof.value = false
  }
}

/* ---------- Cancelar Solicitud ---------- */
const cancelRequest = async (id: number): Promise<void> => {
  const result = await Swal.fire({
    title: '¿Cancelar solicitud?',
    text: 'Esta acción no se puede deshacer',
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#ff7675',
    confirmButtonText: 'Sí, cancelar',
    cancelButtonText: 'No'
  })

  if (result.isConfirmed) {
    try {
      await api.put(`/wallet/requests/${id}/cancel`, {}, {
        headers: { Authorization: `Bearer ${auth.token}` }
      })
      await loadWallet()
      Swal.fire('Cancelada', 'La solicitud ha sido cancelada', 'success')
    } catch (err) {
      showToast('Error al cancelar solicitud', 'error')
    }
  }
}

/* ---------- Retiro ---------- */
const openWithdrawModal = (): void => {
  console.log('Abriendo modal de retiro', auth.token)
  if (!auth.token) {
    Swal.fire('Error', 'Debes iniciar sesión', 'error')
    return
  }
  withdrawAmount.value = null
  showWithdrawModal.value = true
}

const submitWithdraw = async (): Promise<void> => {
  const num = Number(withdrawAmount.value)
  if (!num || num <= 0) {
    Swal.fire('Error', 'Monto inválido', 'warning')
    return
  }

  if (num > balance.value) {
    Swal.fire('Error', `Saldo insuficiente. Tu saldo es ${formatCurrency(balance.value)}`, 'error')
    return
  }

  withdrawing.value = true
  try {
    const { data } = await api.post('/wallet/withdraw',
      { amount: num },
      { headers: { Authorization: `Bearer ${auth.token}` } }
    )

    showWithdrawModal.value = false
    balance.value = data.balance
    await loadWallet()

    Swal.fire({
      icon: 'success',
      title: '✅ Retiro exitoso',
      text: `Has retirado ${formatCurrency(num)}`,
      timer: 2000,
      showConfirmButton: false
    })
  } catch (err: any) {
    console.error('Error en retiro:', err)
    Swal.fire('Error', err.response?.data?.error || 'Error al retirar', 'error')
  } finally {
    withdrawing.value = false
  }
}

/* ---------- Watchers para debug ---------- */
watch(showRechargeModal, (newVal) => {
  console.log('showRechargeModal cambió a:', newVal)
})

watch(showWithdrawModal, (newVal) => {
  console.log('showWithdrawModal cambió a:', newVal)
})

/* ---------- Lifecycle ---------- */
onMounted(async () => {
  console.log('Wallet montado, token:', auth.token)
  if (auth.token) {
    // Primero cargar métodos de pago, luego la wallet
    await loadPaymentMethods()
    await loadWallet()
  } else {
    console.warn('No hay token de autenticación')
  }
})
</script>

<style scoped>
/* Todos tus estilos existentes se mantienen igual */
.wallet-page {
  max-width: 1400px;
  margin: 0 auto;
  padding: 24px;
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea1a 0%, #764ba21a 100%);
}

/* ... resto de tus estilos ... */

.btn-action:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  pointer-events: none;
}

.modal-overlay {
  cursor: pointer;
}

.modal {
  cursor: default;
}
</style>

<style scoped>
.wallet-page {
  max-width: 1400px;
  margin: 0 auto;
  padding: 24px;
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea1a 0%, #764ba21a 100%);
}

/* Header */
.wallet-header {
  margin-bottom: 32px;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 20px;
}

.title-section {
  display: flex;
  align-items: center;
  gap: 16px;
}

.wallet-icon {
  width: 64px;
  height: 64px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 10px 20px rgba(102, 126, 234, 0.2);
}

.wallet-icon .emoji-icon {
  font-size: 32px;
}

.title-text h1 {
  font-size: 2.2rem;
  color: #2d3436;
  margin-bottom: 8px;
  font-weight: 700;
}

.title-text p {
  color: #636e72;
  font-size: 1rem;
}

.date-badge {
  background: white;
  padding: 12px 24px;
  border-radius: 50px;
  display: flex;
  align-items: center;
  gap: 10px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
  border: 1px solid #f1f2f6;
}

.date-icon {
  font-size: 1.2rem;
}

/* Balance Card */
.balance-card {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 30px;
  padding: 32px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 24px;
  margin-bottom: 32px;
  box-shadow: 0 20px 40px rgba(102, 126, 234, 0.25);
  position: relative;
  overflow: hidden;
}

.balance-card::before {
  content: '';
  position: absolute;
  top: -50%;
  right: -50%;
  width: 200%;
  height: 200%;
  background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 70%);
  animation: pulse 8s ease infinite;
}

@keyframes pulse {
  0%, 100% { transform: scale(1); opacity: 0.3; }
  50% { transform: scale(1.1); opacity: 0.4; }
}

.balance-icon {
  width: 80px;
  height: 80px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 25px;
  display: flex;
  align-items: center;
  justify-content: center;
  backdrop-filter: blur(10px);
  border: 2px solid rgba(255, 255, 255, 0.3);
}

.balance-icon .emoji-icon {
  font-size: 40px;
}

.balance-content {
  flex: 1;
}

.balance-label {
  display: block;
  color: rgba(255, 255, 255, 0.9);
  font-size: 0.9rem;
  margin-bottom: 8px;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.balance-amount {
  display: flex;
  align-items: baseline;
  gap: 4px;
  margin-bottom: 8px;
}

.balance-amount .currency {
  font-size: 2rem;
  color: white;
  font-weight: 600;
}

.balance-amount .amount {
  font-size: 3.5rem;
  color: white;
  font-weight: 700;
  line-height: 1;
}

.balance-subtitle {
  color: rgba(255, 255, 255, 0.8);
  font-size: 0.85rem;
}

.balance-actions {
  display: flex;
  gap: 16px;
}

.btn-action {
  padding: 14px 28px;
  border: none;
  border-radius: 16px;
  font-weight: 600;
  font-size: 1rem;
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  transition: all 0.3s;
  background: white;
}

.btn-action.recharge {
  color: #00b894;
}

.btn-action.withdraw {
  color: #ff7675;
}

.btn-action:hover {
  transform: translateY(-3px);
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2);
}

.btn-icon {
  font-size: 1.2rem;
}

/* Summary Stats */
.summary-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 24px;
  margin-bottom: 40px;
}

.stat-item {
  background: white;
  padding: 24px;
  border-radius: 20px;
  display: flex;
  align-items: center;
  gap: 20px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
  transition: all 0.3s;
  border: 1px solid #f1f2f6;
}

.stat-item:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

.stat-icon {
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 16px;
  color: white;
  font-size: 28px;
}

.stat-content h3 {
  font-size: 1.8rem;
  color: #2d3436;
  margin-bottom: 4px;
  font-weight: 700;
}

.stat-content p {
  color: #636e72;
  font-size: 0.9rem;
}

/* Pending Requests Section */
.pending-requests-section {
  background: white;
  border-radius: 30px;
  padding: 32px;
  margin-bottom: 32px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
  border: 1px solid #f1f2f6;
}

.pending-badge {
  background: #ff7675;
  color: white;
  padding: 6px 16px;
  border-radius: 50px;
  font-weight: 600;
  font-size: 0.9rem;
}

.pending-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 24px;
  margin-top: 24px;
}

.pending-card {
  background: #fff9f0;
  border-radius: 20px;
  padding: 24px;
  border: 2px solid #ffeaa7;
  transition: all 0.3s;
}

.pending-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 20px rgba(255, 234, 167, 0.3);
}

.pending-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.request-id {
  font-weight: 700;
  color: #2d3436;
  background: white;
  padding: 4px 12px;
  border-radius: 50px;
  font-size: 0.85rem;
}

.request-status.pending {
  background: #fdcb6e;
  color: white;
  padding: 4px 12px;
  border-radius: 50px;
  font-size: 0.8rem;
  font-weight: 600;
}

.pending-amount {
  display: flex;
  align-items: baseline;
  gap: 4px;
  margin-bottom: 20px;
}

.pending-amount .currency {
  font-size: 1.2rem;
  color: #636e72;
}

.pending-amount .amount {
  font-size: 2rem;
  font-weight: 700;
  color: #2d3436;
}

.pending-details {
  background: white;
  padding: 16px;
  border-radius: 16px;
  margin-bottom: 20px;
}

.detail-item {
  display: flex;
  justify-content: space-between;
  padding: 8px 0;
  border-bottom: 1px solid #f1f2f6;
}

.detail-item:last-child {
  border-bottom: none;
}

.detail-label {
  color: #636e72;
  font-size: 0.9rem;
}

.detail-value {
  font-weight: 600;
  color: #2d3436;
}

.pending-actions {
  display: flex;
  gap: 12px;
}

.btn-upload {
  flex: 1;
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
  color: white;
  border: none;
  padding: 12px;
  border-radius: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-upload:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 184, 148, 0.3);
}

.btn-view-proof {
  flex: 1;
  background: #667eea;
  color: white;
  padding: 12px;
  border-radius: 12px;
  text-decoration: none;
  text-align: center;
  font-weight: 600;
  transition: all 0.3s;
}

.btn-cancel-small {
  background: #ff7675;
  color: white;
  border: none;
  width: 48px;
  height: 48px;
  border-radius: 12px;
  cursor: pointer;
  font-size: 1.2rem;
  transition: all 0.3s;
}

/* Transactions Section */
.transactions-section {
  background: white;
  border-radius: 30px;
  padding: 32px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
  border: 1px solid #f1f2f6;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 32px;
  flex-wrap: wrap;
  gap: 20px;
}

.section-header h2 {
  display: flex;
  align-items: center;
  gap: 12px;
  color: #2d3436;
  font-size: 1.5rem;
}

.header-icon {
  font-size: 1.8rem;
}

.filter-tabs {
  display: flex;
  gap: 10px;
  background: #f8f9fa;
  padding: 5px;
  border-radius: 50px;
}

.filter-tab {
  padding: 10px 24px;
  border: none;
  border-radius: 50px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  background: transparent;
  color: #636e72;
}

.filter-tab.active {
  background: white;
  color: #667eea;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

/* Loading */
.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 300px;
}

.spinner {
  width: 50px;
  height: 50px;
  border: 4px solid rgba(102, 126, 234, 0.2);
  border-top: 4px solid #667eea;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 20px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* Transactions Grid */
.transactions-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
  gap: 24px;
}

.transaction-card {
  background: white;
  border-radius: 20px;
  padding: 24px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
  border: 1px solid #f1f2f6;
  transition: all 0.4s;
  position: relative;
  display: flex;
  gap: 20px;
}

.transaction-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

.transaction-card.credit {
  border-left: 6px solid #00b894;
}

.transaction-card.debit {
  border-left: 6px solid #ff7675;
}

.transaction-badge {
  width: 50px;
  height: 50px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  flex-shrink: 0;
}

.transaction-badge.credit {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
  color: white;
}

.transaction-badge.debit {
  background: linear-gradient(135deg, #ff7675 0%, #d63031 100%);
  color: white;
}

.transaction-content {
  flex: 1;
}

.transaction-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 12px;
}

.transaction-title {
  font-size: 1.1rem;
  font-weight: 600;
  color: #2d3436;
  margin: 0;
}

.transaction-amount {
  font-size: 1.4rem;
  font-weight: 700;
}

.transaction-amount.credit {
  color: #00b894;
}

.transaction-amount.debit {
  color: #ff7675;
}

.transaction-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  margin-bottom: 12px;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 6px;
  background: #f8f9fa;
  padding: 6px 12px;
  border-radius: 50px;
  font-size: 0.85rem;
  color: #636e72;
}

.meta-icon {
  font-size: 0.9rem;
}

.meta-text {
  font-weight: 500;
}

.transaction-status {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.85rem;
  color: #00b894;
  font-weight: 600;
}

.status-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #00b894;
}

.status-dot.completed {
  background: #00b894;
}

.status-dot.pending {
  background: #fdcb6e;
}

/* Empty State */
.empty-state {
  grid-column: 1 / -1;
  text-align: center;
  padding: 60px 20px;
}

.empty-icon {
  font-size: 64px;
  margin-bottom: 24px;
  animation: bounce 2s infinite;
}

@keyframes bounce {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-20px); }
}

.empty-state h3 {
  color: #2d3436;
  margin-bottom: 12px;
  font-size: 1.8rem;
}

.empty-state p {
  color: #636e72;
  margin-bottom: 32px;
  font-size: 1.1rem;
}

.btn-primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 14px 32px;
  border: none;
  border-radius: 12px;
  font-weight: 600;
  display: inline-flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-primary:hover {
  transform: translateY(-3px);
  box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
}

/* Modal */
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
  z-index: 1000;
  backdrop-filter: blur(4px);
}

.modal {
  background: white;
  border-radius: 30px;
  max-width: 500px;
  width: 90%;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  overflow: hidden;
}

.modal-large {
  max-width: 700px !important;
}

.modal-header {
  padding: 24px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  gap: 16px;
  color: white;
}

.modal-header .modal-icon {
  width: 48px;
  height: 48px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
}

.modal-header h3 {
  flex: 1;
  font-size: 1.3rem;
  color: white;
  margin: 0;
}

.modal-close {
  background: rgba(255, 255, 255, 0.2);
  border: none;
  color: white;
  font-size: 20px;
  cursor: pointer;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background 0.3s;
}

.modal-close:hover {
  background: rgba(255, 255, 255, 0.3);
}

.modal-content {
  padding: 32px;
}

.modal-description {
  color: #636e72;
  margin-bottom: 24px;
}

.current-balance-info {
  margin-top: 16px;
  padding: 12px;
  background: #f8f9fa;
  border-radius: 12px;
  color: #2d3436;
}

.amount-input-group {
  display: flex;
  align-items: center;
  border: 2px solid #dfe6e9;
  border-radius: 16px;
  overflow: hidden;
}

.amount-input-group.large {
  border: 2px solid #667eea;
}

.currency-symbol {
  padding: 0 16px;
  font-size: 1.2rem;
  font-weight: 600;
  color: #2d3436;
  background: #f8f9fa;
  height: 56px;
  display: flex;
  align-items: center;
}

.amount-input {
  flex: 1;
  border: none;
  padding: 0 16px;
  font-size: 1.2rem;
  height: 56px;
  outline: none;
}

.amount-input:focus {
  border-color: #667eea;
}

.quick-amounts {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
  margin-top: 16px;
}

.quick-amount-btn {
  padding: 12px;
  background: #f8f9fa;
  border: 2px solid #dfe6e9;
  border-radius: 12px;
  font-weight: 600;
  color: #2d3436;
  cursor: pointer;
  transition: all 0.3s;
}

.quick-amount-btn:hover {
  background: #667eea;
  color: white;
  border-color: #667eea;
}

.modal-actions {
  padding: 24px;
  border-top: 2px solid #f1f2f6;
  display: flex;
  gap: 16px;
  justify-content: flex-end;
}

.btn-cancel {
  padding: 12px 24px;
  border: 2px solid #dfe6e9;
  border-radius: 12px;
  background: white;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-cancel:hover {
  background: #dfe6e9;
}

.btn-confirm {
  padding: 12px 32px;
  border: none;
  border-radius: 12px;
  font-weight: 600;
  color: white;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-confirm.recharge {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
}

.btn-confirm.withdraw {
  background: linear-gradient(135deg, #ff7675 0%, #d63031 100%);
}

.btn-confirm:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
}

.btn-confirm:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Form Styles */
.form-row {
  display: flex;
  gap: 20px;
  margin-bottom: 20px;
}

.form-group {
  margin-bottom: 24px;
}

.form-group.half {
  flex: 1;
  margin-bottom: 0;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  font-weight: 600;
  color: #2d3436;
}

.form-select, .form-input {
  width: 100%;
  padding: 14px 16px;
  border: 2px solid #dfe6e9;
  border-radius: 12px;
  font-size: 1rem;
  transition: all 0.3s;
}

.form-select:focus, .form-input:focus {
  border-color: #667eea;
  outline: none;
}

/* File Upload */
.file-upload-area {
  border: 3px dashed #dfe6e9;
  border-radius: 20px;
  padding: 32px;
  text-align: center;
  position: relative;
  transition: all 0.3s;
  cursor: pointer;
}

.file-upload-area:hover {
  border-color: #667eea;
  background: #f8f9fa;
}

.file-upload-area.large {
  padding: 48px 32px;
}

.file-input {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  opacity: 0;
  cursor: pointer;
}

.upload-placeholder {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
}

.upload-icon {
  font-size: 2rem;
}

.upload-icon.large {
  font-size: 3rem;
}

.upload-placeholder small {
  color: #636e72;
  font-size: 0.8rem;
}

.file-info {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  padding: 12px;
  background: #e3f2fd;
  border-radius: 12px;
}

.file-name {
  font-weight: 600;
  color: #0984e3;
}

.file-size {
  color: #636e72;
  font-size: 0.85rem;
}

.file-remove {
  background: none;
  border: none;
  color: #ff7675;
  font-size: 1.2rem;
  cursor: pointer;
  padding: 4px;
}

/* Bank Details */
.bank-details {
  background: linear-gradient(135deg, #667eea1a 0%, #764ba21a 100%);
  border-radius: 20px;
  padding: 24px;
  margin-top: 16px;
}

.bank-details h4 {
  color: #2d3436;
  margin-bottom: 16px;
  font-size: 1.1rem;
}

.bank-info-grid {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.bank-row {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 8px 0;
  border-bottom: 1px solid rgba(102, 126, 234, 0.1);
}

.bank-row .label {
  min-width: 100px;
  color: #636e72;
  font-weight: 500;
}

.bank-row .value {
  flex: 1;
  font-weight: 600;
  color: #2d3436;
  font-family: monospace;
}

.btn-copy {
  background: white;
  border: 1px solid #dfe6e9;
  border-radius: 8px;
  padding: 6px 12px;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-copy:hover {
  background: #667eea;
  color: white;
  border-color: #667eea;
}

/* Toast */
.toast {
  position: fixed;
  bottom: 24px;
  right: 24px;
  padding: 16px 24px;
  border-radius: 12px;
  color: white;
  font-weight: 600;
  z-index: 1001;
  animation: slideIn 0.3s ease-out;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
}

.toast.success {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
}

.toast.error {
  background: linear-gradient(135deg, #ff7675 0%, #d63031 100%);
}

.toast.info {
  background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%);
}

@keyframes slideIn {
  from {
    transform: translateX(100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

/* Responsive */
@media (max-width: 1024px) {
  .transactions-grid {
    grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  }
}

@media (max-width: 768px) {
  .wallet-page {
    padding: 16px;
  }

  .title-text h1 {
    font-size: 1.8rem;
  }

  .balance-card {
    padding: 24px;
  }

  .balance-amount .amount {
    font-size: 2.5rem;
  }

  .summary-stats {
    grid-template-columns: 1fr;
  }

  .pending-grid {
    grid-template-columns: 1fr;
  }

  .transactions-grid {
    grid-template-columns: 1fr;
  }

  .transaction-card {
    flex-direction: column;
  }

  .section-header {
    flex-direction: column;
    align-items: flex-start;
  }

  .filter-tabs {
    width: 100%;
  }

  .filter-tab {
    flex: 1;
  }

  .form-row {
    flex-direction: column;
    gap: 16px;
  }

  .bank-row {
    flex-wrap: wrap;
  }

  .bank-row .label {
    min-width: 100%;
  }

  .quick-amounts {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 480px) {
  .balance-actions {
    flex-direction: column;
    width: 100%;
  }

  .btn-action {
    width: 100%;
    justify-content: center;
  }

  .pending-actions {
    flex-direction: column;
  }

  .btn-upload,
  .btn-view-proof {
    width: 100%;
  }

  .btn-cancel-small {
    width: 100%;
  }

  .transaction-meta {
    flex-direction: column;
    gap: 8px;
  }

  .meta-item {
    width: 100%;
  }

  .modal-actions {
    flex-direction: column;
  }

  .btn-cancel,
  .btn-confirm {
    width: 100%;
  }

  .quick-amounts {
    grid-template-columns: 1fr;
  }
}

/* Añadir solo estos estilos adicionales */
.btn-action:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  pointer-events: none;
}

.modal-overlay {
  cursor: pointer;
}

.modal {
  cursor: default;
}
</style>
