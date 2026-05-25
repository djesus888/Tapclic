<template>
  <div class="provider-billing-page">
    <!-- Header -->
    <div class="header">
      <div class="title-section">
        <h1><span class="page-icon">💳</span> Mis Facturas</h1>
        <p>Gestiona tus pagos de comisiones a la plataforma</p>
      </div>
    </div>

    <!-- Stats -->
    <div class="stats-section">
      <div class="stat-card pending">
        <div class="stat-icon">⏳</div>
        <div class="stat-content">
          <h3>${{ formatCurrency(stats.pending) }}</h3>
          <p>Pendiente</p>
        </div>
      </div>
      <div class="stat-card paid">
        <div class="stat-icon">✅</div>
        <div class="stat-content">
          <h3>${{ formatCurrency(stats.paid) }}</h3>
          <p>Pagado</p>
        </div>
      </div>
      <div class="stat-card overdue">
        <div class="stat-icon">🚫</div>
        <div class="stat-content">
          <h3>${{ formatCurrency(stats.overdue) }}</h3>
          <p>Vencido</p>
        </div>
      </div>
    </div>

    <!-- Warning if overdue -->
    <div v-if="stats.overdue > 0" class="warning-banner">
      <span class="warning-icon">⚠️</span>
      <div>
        <strong>Tienes facturas vencidas</strong>
        <p>Regulariza tu situación para evitar el bloqueo de tu cuenta</p>
      </div>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="loading-container">
      <div class="spinner"></div>
      <p>Cargando facturas...</p>
    </div>

    <!-- Bills List -->
    <div v-else-if="bills.length > 0" class="bills-list">
      <div v-for="bill in bills" :key="bill.id" :class="['bill-card', bill.status]">
        <div class="bill-header">
          <div class="bill-period">
            <span class="period-icon">📅</span>
            <div>
              <h3>{{ formatDate(bill.period_start) }} - {{ formatDate(bill.period_end) }}</h3>
              <p>{{ bill.total_services }} servicios • {{ bill.total_transactions }} transacciones</p>
            </div>
          </div>
          <div class="bill-amount">
            <span class="amount-label">Total comisión</span>
            <span class="amount-value">${{ formatCurrency(bill.total_commission) }}</span>
          </div>
        </div>

        <div class="bill-body">
          <div class="bill-status">
            <span class="status-badge" :class="bill.status">{{ getStatusLabel(bill.status) }}</span>
          </div>

          <!-- Payment Info -->
          <div v-if="bill.status === 'paid'" class="payment-info">
            <p><strong>Pagado el:</strong> {{ formatDateTime(bill.paid_at) }}</p>
            <p><strong>Método:</strong> {{ bill.payment_method || '—' }}</p>
            <p><strong>Referencia:</strong> {{ bill.payment_reference || '—' }}</p>
          </div>

          <!-- Pay Button -->
          <div v-if="bill.status === 'pending' || bill.status === 'overdue'" class="pay-section">
            <button class="btn-pay" @click="openPayModal(bill)">
              💳 Reportar Pago
            </button>
          </div>

          <!-- Proof Link -->
          <div v-if="bill.payment_proof" class="proof-link">
            <button class="btn-proof" @click="viewProof(bill.payment_proof)">📎 Ver comprobante</button>
          </div>
        </div>
      </div>
    </div>

    <!-- Empty -->
    <div v-else class="empty-state">
      <div class="empty-icon">📋</div>
      <h3>No tienes facturas</h3>
      <p>Las facturas de comisiones aparecerán aquí cuando el administrador las genere</p>
    </div>

    <!-- Pay Modal -->
    <div v-if="showPayModal" class="modal-overlay" @click.self="showPayModal = false">
      <div class="modal">
        <div class="modal-header">
          <h2>💳 Reportar Pago</h2>
          <button class="modal-close" @click="showPayModal = false">✕</button>
        </div>
        <div class="modal-content">
          <div class="bill-summary">
            <p><strong>Período:</strong> {{ formatDate(selectedBill?.period_start) }} - {{ formatDate(selectedBill?.period_end) }}</p>
            <p><strong>Monto a pagar:</strong> <span class="pay-amount">${{ formatCurrency(selectedBill?.total_commission) }}</span></p>
          </div>

          <form @submit.prevent="submitPayment" class="pay-form">
            <div class="form-group">
              <label>Método de pago</label>
              <select v-model="payForm.payment_method" required @change="onMethodChange">
                <option value="">Selecciona...</option>
                <option v-for="method in paymentMethods" :key="method.type" :value="method.type">
                  {{ method.icon }} {{ method.label }}
                </option>
              </select>
            </div>

            <!-- ✅ Datos del método seleccionado -->
            <div v-if="selectedMethod" class="bank-info-box">
              <h4>{{ selectedMethod.icon }} Datos para el pago</h4>
              <p v-if="selectedMethod.bank"><strong>Banco:</strong> {{ selectedMethod.bank }}</p>
              <p v-if="selectedMethod.account"><strong>Cuenta:</strong> {{ selectedMethod.account }}</p>
              <p v-if="selectedMethod.phone"><strong>Teléfono:</strong> {{ selectedMethod.phone }}</p>
              <p v-if="selectedMethod.email"><strong>Email:</strong> {{ selectedMethod.email }}</p>
              <p v-if="selectedMethod.holder"><strong>Titular:</strong> {{ selectedMethod.holder }}</p>
              <p v-if="selectedMethod.idNumber"><strong>Cédula:</strong> {{ selectedMethod.idNumber }}</p>
              <p><strong>Monto exacto:</strong> ${{ formatCurrency(selectedBill?.total_commission) }}</p>
            </div>

            <div class="form-group">
              <label>Número de referencia</label>
              <input v-model="payForm.reference" type="text" placeholder="Ej: 12345678" required />
            </div>

            <div class="form-group">
              <label>Comprobante de pago</label>
              <div class="file-upload">
                <input type="file" ref="fileInput" @change="handleFile" accept="image/*" class="file-input" />
                <button type="button" class="btn-select-file" @click="$refs.fileInput.click()">
                  📁 Seleccionar archivo
                </button>
                <span v-if="payForm.file" class="file-name">{{ payForm.file.name }}</span>
              </div>
            </div>

            <div class="modal-actions">
              <button type="button" class="btn-cancel" @click="showPayModal = false">Cancelar</button>
              <button type="submit" class="btn-submit" :disabled="paying">
                {{ paying ? '⏳ Enviando...' : '📤 Enviar comprobante' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- Toast -->
    <div v-if="toast.show" class="toast" :class="toast.type">{{ toast.message }}</div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { useAuthStore } from '@/stores/authStore'
import api from '@/axios'

const authStore = useAuthStore()

const bills = ref([])
const loading = ref(true)
const showPayModal = ref(false)
const selectedBill = ref(null)
const paying = ref(false)
const fileInput = ref(null)
const toast = ref({ show: false, message: '', type: 'success' })
const paymentMethods = ref([])

const stats = reactive({ pending: 0, paid: 0, overdue: 0 })

const payForm = reactive({
  payment_method: '',
  reference: '',
  file: null
})

// ✅ Método seleccionado
const selectedMethod = computed(() => paymentMethods.value.find(m => m.type === payForm.payment_method) || null)

const formatCurrency = (v) => Number(v || 0).toFixed(2)
const formatDate = (d) => d ? new Date(d).toLocaleDateString('es-ES', { day: '2-digit', month: 'short', year: 'numeric' }) : ''
const formatDateTime = (d) => d ? new Date(d).toLocaleString('es-ES', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' }) : ''
const getStatusLabel = (s) => ({ pending: 'Pendiente', paid: 'Pagada', overdue: 'Vencida', cancelled: 'Cancelada' }[s] || s)

const showToast = (msg, type = 'success') => {
  toast.value = { show: true, message: msg, type }
  setTimeout(() => { toast.value.show = false }, 4000)
}

// ✅ Cargar métodos de pago del admin
const loadPaymentMethods = async () => {
  try {
    const { data } = await api.get('/payments/admin-methods')
    paymentMethods.value = (data?.methods || []).filter(m => m.type !== 'mercadopago').map(m => ({
      type: m.type,
      icon: m.icon,
      label: m.label,
      bank: m.bank,
      account: m.account,
      phone: m.phone,
      email: m.email,
      holder: m.holder,
      idNumber: m.idNumber
    }))
  } catch { paymentMethods.value = [] }
}

const onMethodChange = () => {}

const fetchBills = async () => {
  loading.value = true
  try {
    const { data } = await api.get('/provider/billing', {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })

    bills.value = data?.bills || []
    stats.pending = data?.stats?.pending || 0
    stats.paid = data?.stats?.paid || 0
    stats.overdue = data?.stats?.overdue || 0
  } catch (e) {
    showToast('Error al cargar facturas', 'error')
  } finally {
    loading.value = false
  }
}

const openPayModal = (bill) => {
  selectedBill.value = bill
  payForm.payment_method = ''
  payForm.reference = ''
  payForm.file = null
  showPayModal.value = true
}

const handleFile = (e) => {
  payForm.file = e.target.files[0] || null
}

const submitPayment = async () => {
  if (!selectedBill.value) return

  paying.value = true
  try {
    const formData = new FormData()
    formData.append('payment_method', payForm.payment_method)
    formData.append('reference', payForm.reference)
    if (payForm.file) formData.append('payment_proof', payForm.file)

    const { data } = await api.post(`/provider/billing/${selectedBill.value.id}/pay`, formData, {
      headers: {
        Authorization: `Bearer ${authStore.token}`,
        'Content-Type': 'multipart/form-data'
      }
    })

    showPayModal.value = false
    showToast(data?.message || 'Pago reportado exitosamente')
    fetchBills()
  } catch (e) {
    showToast(e.response?.data?.error || 'Error al reportar pago', 'error')
  } finally {
    paying.value = false
  }
}

const viewProof = (url) => {
  const base = import.meta.env.VITE_API_URL || ''
  window.open(url.startsWith('http') ? url : base + url, '_blank')
}

onMounted(() => {
  fetchBills()
  loadPaymentMethods()
})
</script>

<style scoped>
.provider-billing-page {
  padding: 24px;
  max-width: 800px;
  margin: 0 auto;
}

/* Header */
.header {
  margin-bottom: 24px;
}

.title-section h1 {
  font-size: 1.8rem;
  font-weight: 700;
  color: #1a1a2e;
  margin: 0;
}

.title-section p {
  color: #666;
  margin: 4px 0 0;
}

.page-icon { margin-right: 8px; }

/* Stats */
.stats-section {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
  margin-bottom: 24px;
}

.stat-card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 14px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
}

.stat-icon { font-size: 1.6rem; }
.stat-content h3 { margin: 0; font-size: 1.3rem; color: #1a1a2e; }
.stat-content p { margin: 2px 0 0; font-size: 0.8rem; color: #888; }

/* Warning */
.warning-banner {
  background: #fff3e0;
  border: 1px solid #ffcc02;
  border-radius: 10px;
  padding: 14px 18px;
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 20px;
}

.warning-icon { font-size: 1.5rem; }
.warning-banner strong { color: #e65100; }
.warning-banner p { margin: 2px 0 0; font-size: 0.85rem; color: #bf360c; }

/* Loading */
.loading-container { text-align: center; padding: 60px 0; }
.spinner {
  width: 40px; height: 40px;
  border: 4px solid #e0e0e0;
  border-top-color: #667eea;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
  margin: 0 auto 16px;
}
@keyframes spin { to { transform: rotate(360deg); } }

/* Bills */
.bills-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.bill-card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
  border-left: 4px solid #ddd;
}

.bill-card.overdue { border-left-color: #f44336; }
.bill-card.paid { border-left-color: #4caf50; }
.bill-card.pending { border-left-color: #ff9800; }

.bill-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
  flex-wrap: wrap;
  gap: 12px;
}

.bill-period { display: flex; align-items: center; gap: 10px; }
.period-icon { font-size: 1.4rem; }
.bill-period h3 { margin: 0; font-size: 1rem; }
.bill-period p { margin: 2px 0 0; font-size: 0.85rem; color: #888; }

.bill-amount { text-align: right; }
.amount-label { display: block; font-size: 0.8rem; color: #888; }
.amount-value { font-size: 1.4rem; font-weight: 700; color: #1a1a2e; }

.bill-body {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}

.status-badge {
  padding: 4px 14px;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
}

.status-badge.pending { background: #fff3e0; color: #e65100; }
.status-badge.paid { background: #e8f5e9; color: #2e7d32; }
.status-badge.overdue { background: #fce4ec; color: #c62828; }

.payment-info { font-size: 0.85rem; color: #666; }
.payment-info p { margin: 2px 0; }

.btn-pay {
  padding: 10px 20px;
  background: #667eea;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
}

.btn-pay:hover { background: #5a6fd6; }

.btn-proof {
  padding: 6px 12px;
  background: #e8f0fe;
  color: #1a73e8;
  border: none;
  border-radius: 6px;
  cursor: pointer;
}

/* Empty */
.empty-state {
  text-align: center;
  padding: 60px 0;
  background: white;
  border-radius: 12px;
}

.empty-icon { font-size: 3rem; margin-bottom: 12px; }

/* Modal */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 100;
}

.modal {
  background: white;
  border-radius: 12px;
  padding: 24px;
  width: 90%;
  max-width: 500px;
  max-height: 90vh;
  overflow-y: auto;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.modal-header h2 { margin: 0; }

.modal-close {
  background: none;
  border: none;
  font-size: 1.2rem;
  cursor: pointer;
}

.bill-summary {
  background: #f8f9ff;
  padding: 14px;
  border-radius: 8px;
  margin-bottom: 20px;
}

.pay-amount { font-size: 1.3rem; font-weight: 700; color: #667eea; }

.form-group {
  margin-bottom: 16px;
}

.form-group label {
  display: block;
  font-weight: 600;
  margin-bottom: 6px;
  font-size: 0.9rem;
}

.form-group select,
.form-group input[type="text"] {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 0.95rem;
}

.file-upload {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
}

.file-input { display: none; }

.btn-select-file {
  padding: 8px 16px;
  background: #f5f5f5;
  border: 1px solid #ddd;
  border-radius: 8px;
  cursor: pointer;
}

.file-name {
  font-size: 0.85rem;
  color: #666;
}

.modal-actions {
  display: flex;
  gap: 10px;
  justify-content: flex-end;
}

.btn-cancel {
  padding: 10px 20px;
  background: #f5f5f5;
  border: 1px solid #ddd;
  border-radius: 8px;
  cursor: pointer;
}

.btn-submit {
  padding: 10px 20px;
  background: #667eea;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
}

.btn-submit:disabled { opacity: 0.6; }

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

.provider-billing-page { padding: 24px; max-width: 800px; margin: 0 auto; }
.header { margin-bottom: 24px; }
.title-section h1 { font-size: 1.8rem; font-weight: 700; color: #1a1a2e; margin: 0; }
.title-section p { color: #666; margin: 4px 0 0; }
.page-icon { margin-right: 8px; }
.stats-section { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 24px; }
.stat-card { background: white; border-radius: 12px; padding: 20px; display: flex; align-items: center; gap: 14px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); }
.stat-icon { font-size: 1.6rem; }
.stat-content h3 { margin: 0; font-size: 1.3rem; color: #1a1a2e; }
.stat-content p { margin: 2px 0 0; font-size: 0.8rem; color: #888; }
.warning-banner { background: #fff3e0; border: 1px solid #ffcc02; border-radius: 10px; padding: 14px 18px; display: flex; align-items: center; gap: 12px; margin-bottom: 20px; }
.warning-icon { font-size: 1.5rem; }
.warning-banner strong { color: #e65100; }
.warning-banner p { margin: 2px 0 0; font-size: 0.85rem; color: #bf360c; }
.loading-container { text-align: center; padding: 60px 0; }
.spinner { width: 40px; height: 40px; border: 4px solid #e0e0e0; border-top-color: #667eea; border-radius: 50%; animation: spin 0.8s linear infinite; margin: 0 auto 16px; }
@keyframes spin { to { transform: rotate(360deg); } }
.bills-list { display: flex; flex-direction: column; gap: 16px; }
.bill-card { background: white; border-radius: 12px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); border-left: 4px solid #ddd; }
.bill-card.overdue { border-left-color: #f44336; }
.bill-card.paid { border-left-color: #4caf50; }
.bill-card.pending { border-left-color: #ff9800; }
.bill-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; flex-wrap: wrap; gap: 12px; }
.bill-period { display: flex; align-items: center; gap: 10px; }
.period-icon { font-size: 1.4rem; }
.bill-period h3 { margin: 0; font-size: 1rem; }
.bill-period p { margin: 2px 0 0; font-size: 0.85rem; color: #888; }
.bill-amount { text-align: right; }
.amount-label { display: block; font-size: 0.8rem; color: #888; }
.amount-value { font-size: 1.4rem; font-weight: 700; color: #1a1a2e; }
.bill-body { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; }
.status-badge { padding: 4px 14px; border-radius: 20px; font-size: 0.8rem; font-weight: 600; }
.status-badge.pending { background: #fff3e0; color: #e65100; }
.status-badge.paid { background: #e8f5e9; color: #2e7d32; }
.status-badge.overdue { background: #fce4ec; color: #c62828; }
.payment-info { font-size: 0.85rem; color: #666; }
.payment-info p { margin: 2px 0; }
.btn-pay { padding: 10px 20px; background: #667eea; color: white; border: none; border-radius: 8px; cursor: pointer; font-weight: 600; }
.btn-pay:hover { background: #5a6fd6; }
.btn-proof { padding: 6px 12px; background: #e8f0fe; color: #1a73e8; border: none; border-radius: 6px; cursor: pointer; }
.empty-state { text-align: center; padding: 60px 0; background: white; border-radius: 12px; }
.empty-icon { font-size: 3rem; margin-bottom: 12px; }
.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.4); display: flex; align-items: center; justify-content: center; z-index: 100; }
.modal { background: white; border-radius: 12px; padding: 24px; width: 90%; max-width: 500px; max-height: 90vh; overflow-y: auto; }
.modal-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
.modal-header h2 { margin: 0; }
.modal-close { background: none; border: none; font-size: 1.2rem; cursor: pointer; }
.bill-summary { background: #f8f9ff; padding: 14px; border-radius: 8px; margin-bottom: 20px; }
.pay-amount { font-size: 1.3rem; font-weight: 700; color: #667eea; }
.bank-info-box { background: #f5f5f5; padding: 14px; border-radius: 8px; margin-bottom: 16px; }
.bank-info-box h4 { margin: 0 0 8px; }
.bank-info-box p { margin: 4px 0; font-size: 0.9rem; }
.form-group { margin-bottom: 16px; }
.form-group label { display: block; font-weight: 600; margin-bottom: 6px; font-size: 0.9rem; }
.form-group select, .form-group input[type="text"] { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 8px; font-size: 0.95rem; }
.file-upload { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
.file-input { display: none; }
.btn-select-file { padding: 8px 16px; background: #f5f5f5; border: 1px solid #ddd; border-radius: 8px; cursor: pointer; }
.file-name { font-size: 0.85rem; color: #666; }
.modal-actions { display: flex; gap: 10px; justify-content: flex-end; }
.btn-cancel { padding: 10px 20px; background: #f5f5f5; border: 1px solid #ddd; border-radius: 8px; cursor: pointer; }
.btn-submit { padding: 10px 20px; background: #667eea; color: white; border: none; border-radius: 8px; cursor: pointer; font-weight: 600; }
.btn-submit:disabled { opacity: 0.6; }
.toast { position: fixed; bottom: 24px; right: 24px; padding: 12px 24px; border-radius: 8px; color: white; z-index: 1000; }
.toast.success { background: #4caf50; }
.toast.error { background: #f44336; }
@media (max-width: 768px) { .stats-section { grid-template-columns: 1fr; 
 }
}


.toast.success { background: #4caf50; }
.toast.error { background: #f44336; }

@media (max-width: 768px) {
  .stats-section { grid-template-columns: 1fr; }
}
</style>

