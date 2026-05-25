<template>
  <div class="admin-service-payments">
    <!-- Header -->
    <div class="header">
      <div class="title-section">
        <h1><span class="admin-icon">💳</span> Verificación de Pagos</h1>
        <p>Revisa y aprueba los comprobantes de pago de los proveedores</p>
      </div>
      <button class="btn-refresh" @click="fetchPayments" :disabled="loading">
        {{ loading ? '⏳' : '🔄' }} Actualizar
      </button>
    </div>

    <!-- Stats -->
    <div class="stats-section">
      <div class="stat-card pending">
        <div class="stat-icon">⏳</div>
        <div class="stat-content">
          <h3>{{ stats.pending }}</h3>
          <p>Pendientes</p>
        </div>
      </div>
      <div class="stat-card approved">
        <div class="stat-icon">✅</div>
        <div class="stat-content">
          <h3>{{ stats.approved }}</h3>
          <p>Aprobados</p>
        </div>
      </div>
      <div class="stat-card rejected">
        <div class="stat-icon">❌</div>
        <div class="stat-content">
          <h3>{{ stats.rejected }}</h3>
          <p>Rechazados</p>
        </div>
      </div>
    </div>

    <!-- Filter tabs -->
    <div class="filter-tabs">
      <button v-for="tab in tabs" :key="tab.value"
        :class="['tab-btn', { active: activeTab === tab.value }]"
        @click="activeTab = tab.value; fetchPayments()">
        {{ tab.icon }} {{ tab.label }}
      </button>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="loading-container">
      <div class="spinner"></div>
      <p>Cargando comprobantes...</p>
    </div>

    <!-- Payments List -->
    <div v-else-if="payments.length > 0" class="payments-list">
      <div v-for="payment in payments" :key="payment.id" :class="['payment-card', payment.status]">
        <div class="card-header">
          <div class="provider-info">
            <span class="provider-avatar">👤</span>
            <div>
              <h3>{{ payment.provider_name }}</h3>
              <p>{{ payment.provider_email }}</p>
            </div>
          </div>
          <div class="payment-amount">
            <span class="amount-label">Monto</span>
            <span class="amount-value">${{ formatCurrency(payment.amount) }}</span>
          </div>
        </div>

        <div class="card-body">
          <div class="service-info">
            <p><strong>Servicio:</strong> {{ payment.service_title }}</p>
            <p><strong>Precio servicio:</strong> ${{ formatCurrency(payment.service_price) }}</p>
            <p><strong>Método:</strong> {{ getMethodLabel(payment.payment_method) }}</p>
            <p><strong>Referencia:</strong> {{ payment.reference || '—' }}</p>
            <p><strong>Fecha:</strong> {{ formatDate(payment.created_at) }}</p>
          </div>

          <div class="proof-section" v-if="payment.proof_url">
            <button class="btn-view-proof" @click="viewProof(payment.proof_url)">
              📎 Ver comprobante
            </button>
          </div>
        </div>

        <div class="card-actions" v-if="payment.status === 'pending'">
          <button class="btn-approve" @click="verifyPayment(payment.id, 'approve')">
            ✅ Aprobar y Activar
          </button>
          <button class="btn-reject" @click="verifyPayment(payment.id, 'reject')">
            ❌ Rechazar
          </button>
        </div>

        <div class="card-status" v-else>
          <span :class="['status-badge', payment.status]">
            {{ payment.status === 'approved' ? '✅ Aprobado' : '❌ Rechazado' }}
          </span>
        </div>
      </div>
    </div>

    <!-- Empty -->
    <div v-else class="empty-state">
      <div class="empty-icon">📭</div>
      <h3>No hay comprobantes {{ activeTab === 'pending' ? 'pendientes' : activeTab === 'approved' ? 'aprobados' : 'rechazados' }}</h3>
    </div>

    <!-- Toast -->
    <div v-if="toast.show" class="toast" :class="toast.type">{{ toast.message }}</div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useAuthStore } from '@/stores/authStore'
import api from '@/axios'

const authStore = useAuthStore()

const payments = ref([])
const loading = ref(false)
const activeTab = ref('pending')
const toast = ref({ show: false, message: '', type: 'success' })

const stats = reactive({ pending: 0, approved: 0, rejected: 0 })

const tabs = [
  { value: 'pending', label: 'Pendientes', icon: '⏳' },
  { value: 'approved', label: 'Aprobados', icon: '✅' },
  { value: 'rejected', label: 'Rechazados', icon: '❌' }
]

const formatCurrency = (v) => Number(v || 0).toFixed(2)
const formatDate = (d) => d ? new Date(d).toLocaleString('es-ES', { day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit' }) : ''
const getMethodLabel = (m) => ({ transferencia: 'Transferencia', pago_movil: 'Pago Móvil', zelle: 'Zelle', paypal: 'PayPal', mercadopago: 'MercadoPago', bank_transfer: 'Transferencia', mobile_payment: 'Pago Móvil' }[m] || m)

const showToast = (msg, type = 'success') => {
  toast.value = { show: true, message: msg, type }
  setTimeout(() => { toast.value.show = false }, 4000)
}
const viewProof = (url) => {
  if (!url) return
  // Si ya es una URL completa, usarla directamente
  if (url.startsWith('http')) {
    window.open(url, '_blank')
    return
  }
  // Construir URL correcta (sin /api)
  const base = (import.meta.env.VITE_API_URL || '').replace(/\/api$/, '')
  window.open(base + url, '_blank')
}

const fetchPayments = async () => {
  loading.value = true
  try {
    const { data } = await api.get('/admin/service-payments', {
      params: { status: activeTab.value },
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    payments.value = data?.payments || []

    // Calcular stats
    stats.pending = payments.value.filter(p => p.status === 'pending').length
    stats.approved = payments.value.filter(p => p.status === 'approved').length
    stats.rejected = payments.value.filter(p => p.status === 'rejected').length
  } catch (e) {
    showToast('Error al cargar comprobantes', 'error')
  } finally {
    loading.value = false
  }
}

const verifyPayment = async (id, action) => {
  const msg = action === 'approve' ? '¿Aprobar y activar este servicio?' : '¿Rechazar este comprobante?'
  if (!confirm(msg)) return

  try {
    const { data } = await api.post(`/admin/service-payments/${id}/verify`,
      { action },
      { headers: { Authorization: `Bearer ${authStore.token}` } }
    )
    showToast(data?.message || 'Operación completada')
    fetchPayments()
  } catch (e) {
    showToast('Error al procesar', 'error')
  }
}

onMounted(fetchPayments)
</script>

<style scoped>
.admin-service-payments {
  padding: 24px;
  max-width: 1000px;
  margin: 0 auto;
}

/* Header */
.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  flex-wrap: wrap;
  gap: 12px;
}

.title-section h1 {
  font-size: 1.8rem;
  font-weight: 700;
  color: #1a1a2e;
  margin: 0;
}

.title-section p { color: #666; margin: 4px 0 0; }
.admin-icon { margin-right: 8px; }

.btn-refresh {
  padding: 10px 20px;
  background: #667eea;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
}

.btn-refresh:disabled { opacity: 0.6; }

/* Stats */
.stats-section {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
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
.stat-content h3 { margin: 0; font-size: 1.3rem; }
.stat-content p { margin: 2px 0 0; font-size: 0.8rem; color: #888; }

/* Tabs */
.filter-tabs {
  display: flex;
  gap: 8px;
  margin-bottom: 20px;
  flex-wrap: wrap;
}

.tab-btn {
  padding: 10px 20px;
  border: 2px solid #eee;
  border-radius: 10px;
  background: white;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.3s;
}

.tab-btn:hover { border-color: #667eea; }
.tab-btn.active { background: #667eea; color: white; border-color: #667eea; }

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

/* Payments */
.payments-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.payment-card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
  border-left: 4px solid #ff9800;
}

.payment-card.approved { border-left-color: #4caf50; }
.payment-card.rejected { border-left-color: #f44336; }

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 14px;
  flex-wrap: wrap;
  gap: 12px;
}

.provider-info {
  display: flex;
  align-items: center;
  gap: 10px;
}

.provider-avatar {
  width: 40px; height: 40px;
  border-radius: 50%;
  background: #f0f0f0;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.2rem;
}

.provider-info h3 { margin: 0; font-size: 1rem; }
.provider-info p { margin: 2px 0 0; font-size: 0.85rem; color: #888; }

.payment-amount { text-align: right; }
.amount-label { display: block; font-size: 0.8rem; color: #888; }
.amount-value { font-size: 1.3rem; font-weight: 700; color: #1a1a2e; }

.card-body {
  margin-bottom: 14px;
}

.service-info p { margin: 4px 0; font-size: 0.9rem; color: #555; }

.proof-section { margin-top: 10px; }

.btn-view-proof {
  padding: 8px 16px;
  background: #e8f0fe;
  color: #1a73e8;
  border: none;
  border-radius: 6px;
  cursor: pointer;
}

.card-actions {
  display: flex;
  gap: 10px;
}

.btn-approve, .btn-reject {
  padding: 10px 20px;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
}

.btn-approve { background: #4caf50; color: white; }
.btn-approve:hover { background: #43a047; }
.btn-reject { background: #f44336; color: white; }
.btn-reject:hover { background: #e53935; }

.card-status { text-align: right; }

.status-badge {
  padding: 4px 14px;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 600;
}

.status-badge.approved { background: #e8f5e9; color: #2e7d32; }
.status-badge.rejected { background: #fce4ec; color: #c62828; }

/* Empty */
.empty-state {
  text-align: center;
  padding: 60px 0;
  background: white;
  border-radius: 12px;
}

.empty-icon { font-size: 3rem; margin-bottom: 12px; }

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
</style>
