<template>
  <div class="admin-billing-page">
    <!-- Header -->
    <div class="header">
      <div class="title-section">
        <h1><span class="admin-icon">💳</span> Facturación de Proveedores</h1>
        <p>Gestiona las facturas y pagos de comisiones</p>
      </div>
      <div class="header-actions">
        <button class="btn-generate" @click="generateBilling" :disabled="generating">
          {{ generating ? '⏳ Generando...' : '📄 Generar Facturas' }}
        </button>
        <button class="btn-refresh" @click="fetchBills" :disabled="loading">
          {{ loading ? '⏳' : '🔄' }} Actualizar
        </button>
      </div>
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
      <div class="stat-card paid">
        <div class="stat-icon">✅</div>
        <div class="stat-content">
          <h3>{{ stats.paid }}</h3>
          <p>Pagadas</p>
        </div>
      </div>
      <div class="stat-card overdue">
        <div class="stat-icon">🚫</div>
        <div class="stat-content">
          <h3>{{ stats.overdue }}</h3>
          <p>Vencidas</p>
        </div>
      </div>
      <div class="stat-card total">
        <div class="stat-icon">💰</div>
        <div class="stat-content">
          <h3>${{ formatCurrency(stats.totalAmount) }}</h3>
          <p>Total pendiente</p>
        </div>
      </div>
    </div>

    <!-- Filters -->
    <div class="filters-section">
      <select v-model="filterStatus" @change="fetchBills" class="filter-select">
        <option value="">Todos los estados</option>
        <option value="pending">Pendientes</option>
        <option value="paid">Pagadas</option>
        <option value="overdue">Vencidas</option>
      </select>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="loading-container">
      <div class="spinner"></div>
      <p>Cargando facturas...</p>
    </div>

    <!-- Bills Table -->
    <div v-else-if="bills.length > 0" class="bills-table-container">
      <div class="table-responsive">
        <table class="bills-table">
          <thead>
            <tr>
              <th>Proveedor</th>
              <th>Período</th>
              <th>Monto</th>
              <th>Servicios</th>
              <th>Transacciones</th>
              <th>Estado</th>
              <th>Comprobante</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="bill in bills" :key="bill.id" :class="getRowClass(bill.status)">
              <td>
                <div class="provider-cell">
                  <span class="provider-name">{{ bill.provider_name }}</span>
                  <span class="provider-email">{{ bill.provider_email }}</span>
                </div>
              </td>
              <td>
                <span class="period">{{ formatDate(bill.period_start) }} - {{ formatDate(bill.period_end) }}</span>
              </td>
              <td class="amount">${{ formatCurrency(bill.total_commission) }}</td>
              <td>{{ bill.total_services }}</td>
              <td>{{ bill.total_transactions }}</td>
              <td>
                <span class="status-badge" :class="bill.status">
                  {{ getStatusLabel(bill.status) }}
                </span>
              </td>
              <td>
                <button v-if="bill.payment_proof" class="btn-proof" @click="viewProof(bill.payment_proof)">📎 Ver</button>
                <span v-else class="no-proof">—</span>
              </td>
              <td>
                <div class="action-buttons">
                  <button v-if="bill.status === 'pending' && bill.payment_proof" class="btn-approve" @click="verifyPayment(bill.id, 'approve')" title="Aprobar pago">✅</button>
                  <button v-if="bill.status === 'pending' && bill.payment_proof" class="btn-reject" @click="verifyPayment(bill.id, 'reject')" title="Rechazar comprobante">❌</button>
                  <button class="btn-block" @click="toggleBlock(bill.provider_id)" :title="'Bloquear/Desbloquear proveedor'">🔒</button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Pagination -->
      <div v-if="totalPages > 1" class="pagination">
        <button :disabled="currentPage === 1" @click="goToPage(currentPage - 1)">←</button>
        <span>Página {{ currentPage }} de {{ totalPages }}</span>
        <button :disabled="currentPage === totalPages" @click="goToPage(currentPage + 1)">→</button>
      </div>
    </div>

    <!-- Empty -->
    <div v-else class="empty-state">
      <div class="empty-icon">📋</div>
      <h3>No hay facturas</h3>
      <p>Genera facturas para empezar a cobrar comisiones</p>
    </div>

    <!-- Generate Modal -->
    <div v-if="showGenerateModal" class="modal-overlay" @click.self="showGenerateModal = false">
      <div class="modal">
        <div class="modal-header">
          <h2>📄 Generar Facturación</h2>
          <button class="modal-close" @click="showGenerateModal = false">✕</button>
        </div>
        <div class="modal-content">
          <p>Selecciona el período de facturación:</p>
          <div class="period-options">
            <button class="period-option" @click="confirmGenerate('biweekly')">
              <span class="period-icon">📅</span>
              <div>
                <h4>Quincenal</h4>
                <p>Últimos 15 días</p>
              </div>
            </button>
            <button class="period-option" @click="confirmGenerate('monthly')">
              <span class="period-icon">📆</span>
              <div>
                <h4>Mensual</h4>
                <p>Mes actual</p>
              </div>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Toast -->
    <div v-if="toast.show" class="toast" :class="toast.type">{{ toast.message }}</div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useAuthStore } from '@/stores/authStore'
import api from '@/axios'

const authStore = useAuthStore()

const bills = ref([])
const loading = ref(false)
const generating = ref(false)
const showGenerateModal = ref(false)
const currentPage = ref(1)
const totalPages = ref(1)
const filterStatus = ref('')
const toast = ref({ show: false, message: '', type: 'success' })

const stats = reactive({
  pending: 0,
  paid: 0,
  overdue: 0,
  totalAmount: 0
})

const formatCurrency = (v) => Number(v || 0).toFixed(2)
const formatDate = (d) => d ? new Date(d).toLocaleDateString('es-ES', { day: '2-digit', month: 'short' }) : ''
const getStatusLabel = (s) => ({ pending: 'Pendiente', paid: 'Pagada', overdue: 'Vencida', cancelled: 'Cancelada' }[s] || s)
const getRowClass = (s) => s === 'overdue' ? 'row-overdue' : s === 'paid' ? 'row-paid' : ''

const showToast = (msg, type = 'success') => {
  toast.value = { show: true, message: msg, type }
  setTimeout(() => { toast.value.show = false }, 4000)
}

const fetchBills = async () => {
  loading.value = true
  try {
    const params = { page: currentPage.value }
    if (filterStatus.value) params.status = filterStatus.value

    const { data } = await api.get('/admin/billing', {
      params,
      headers: { Authorization: `Bearer ${authStore.token}` }
    })

    bills.value = data?.bills || []
    totalPages.value = data?.pagination?.last_page || 1

    // Calcular stats
    stats.pending = bills.value.filter(b => b.status === 'pending').length
    stats.paid = bills.value.filter(b => b.status === 'paid').length
    stats.overdue = bills.value.filter(b => b.status === 'overdue').length
    stats.totalAmount = bills.value
      .filter(b => b.status !== 'paid' && b.status !== 'cancelled')
      .reduce((sum, b) => sum + Number(b.total_commission || 0), 0)
  } catch (e) {
    showToast('Error al cargar facturas', 'error')
  } finally {
    loading.value = false
  }
}

const generateBilling = () => {
  showGenerateModal.value = true
}

const confirmGenerate = async (period) => {
  showGenerateModal.value = false
  generating.value = true
  try {
    const { data } = await api.post('/admin/billing/generate',
      { period },
      { headers: { Authorization: `Bearer ${authStore.token}` } }
    )
    showToast(data?.message || 'Facturación generada')
    fetchBills()
  } catch (e) {
    showToast('Error al generar facturación', 'error')
  } finally {
    generating.value = false
  }
}

const verifyPayment = async (billId, action) => {
  const msg = action === 'approve' ? '¿Aprobar este pago?' : '¿Rechazar este comprobante?'
  if (!confirm(msg)) return

  try {
    const { data } = await api.post(`/admin/billing/${billId}/verify`,
      { action },
      { headers: { Authorization: `Bearer ${authStore.token}` } }
    )
    showToast(data?.message || 'Operación completada')
    fetchBills()
  } catch (e) {
    showToast('Error al procesar', 'error')
  }
}

const toggleBlock = async (providerId) => {
  if (!confirm('¿Bloquear/desbloquear este proveedor?')) return
  try {
    const { data } = await api.post(`/admin/billing/block/${providerId}`, {}, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    showToast(data?.message || 'Operación completada')
  } catch (e) {
    showToast('Error al bloquear proveedor', 'error')
  }
}

const viewProof = (url) => {
  const base = import.meta.env.VITE_API_URL || ''
  window.open(url.startsWith('http') ? url : base + url, '_blank')
}

const goToPage = (page) => {
  currentPage.value = page
  fetchBills()
}

onMounted(fetchBills)
</script>

<style scoped>
.admin-billing-page {
  padding: 24px;
  max-width: 1300px;
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

.title-section p {
  color: #666;
  margin: 4px 0 0;
}

.admin-icon { margin-right: 8px; }

.header-actions {
  display: flex;
  gap: 10px;
}

.btn-generate {
  padding: 10px 20px;
  background: #4caf50;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
}

.btn-generate:disabled { opacity: 0.6; }

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
  grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
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

/* Filters */
.filters-section { margin-bottom: 16px; }
.filter-select {
  padding: 10px 16px;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 0.95rem;
  min-width: 180px;
}

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

/* Table */
.bills-table-container {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
}

.table-responsive { overflow-x: auto; }

.bills-table { width: 100%; border-collapse: collapse; font-size: 0.9rem; }

.bills-table th {
  background: #fafafa;
  padding: 12px 10px;
  text-align: left;
  font-weight: 600;
  color: #555;
  border-bottom: 2px solid #eee;
  white-space: nowrap;
}

.bills-table td {
  padding: 10px;
  border-bottom: 1px solid #f0f0f0;
}

.row-overdue { background: #fff5f5; }
.row-paid { background: #f1f8e9; }

.provider-cell { display: flex; flex-direction: column; }
.provider-name { font-weight: 500; }
.provider-email { font-size: 0.8rem; color: #888; }

.amount { font-weight: 700; color: #1a1a2e; }
.period { font-size: 0.85rem; color: #666; }

.status-badge {
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
}

.status-badge.pending { background: #fff3e0; color: #e65100; }
.status-badge.paid { background: #e8f5e9; color: #2e7d32; }
.status-badge.overdue { background: #fce4ec; color: #c62828; }
.status-badge.cancelled { background: #f5f5f5; color: #888; }

.btn-proof {
  padding: 4px 10px;
  background: #e8f0fe;
  color: #1a73e8;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.8rem;
}

.no-proof { color: #ccc; }

.action-buttons { display: flex; gap: 6px; }

.btn-approve, .btn-reject, .btn-block {
  width: 32px; height: 32px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 1rem;
}

.btn-approve { background: #e8f5e9; }
.btn-approve:hover { background: #c8e6c9; }
.btn-reject { background: #fce4ec; }
.btn-reject:hover { background: #f8bbd0; }
.btn-block { background: #f5f5f5; }
.btn-block:hover { background: #e0e0e0; }

/* Pagination */
.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 12px;
  margin-top: 16px;
}

.pagination button {
  padding: 8px 16px;
  border: 1px solid #ddd;
  border-radius: 8px;
  background: white;
  cursor: pointer;
}

.pagination button:disabled { opacity: 0.5; cursor: not-allowed; }

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

.period-options {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
  margin-top: 16px;
}

.period-option {
  padding: 16px;
  border: 2px solid #eee;
  border-radius: 10px;
  cursor: pointer;
  text-align: left;
  display: flex;
  align-items: center;
  gap: 10px;
  background: white;
  transition: all 0.3s;
}

.period-option:hover { border-color: #667eea; }

.period-icon { font-size: 1.5rem; }
.period-option h4 { margin: 0 0 4px; }
.period-option p { margin: 0; font-size: 0.8rem; color: #888; }

/* Toast */
.toast {
  position: fixed;
  bottom: 24px;
  right: 24px;
  padding: 12px 24px;
  border-radius: 8px;
  color: white;
  font-weight: 500;
  z-index: 1000;
}

.toast.success { background: #4caf50; }
.toast.error { background: #f44336; }
</style>
