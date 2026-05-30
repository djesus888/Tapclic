<template>
  <div class="earnings-page">
    <div class="header">
      <h1><span class="icon">📈</span> Mis Ganancias</h1>
      <p>Resumen de tus ingresos como proveedor</p>
    </div>

    <div class="stats-grid">
      <div class="stat-card">
        <span class="stat-icon">💰</span>
        <div class="stat-content">
          <h3>{{ formatCurrency(summary.total_earned) }}</h3>
          <p>Total generado</p>
        </div>
      </div>
      <div class="stat-card">
        <span class="stat-icon">✅</span>
        <div class="stat-content">
          <h3>{{ formatCurrency(summary.total_paid) }}</h3>
          <p>Pagado</p>
        </div>
      </div>
      <div class="stat-card">
        <span class="stat-icon">⏳</span>
        <div class="stat-content">
          <h3>{{ formatCurrency(summary.total_pending) }}</h3>
          <p>Pendiente</p>
        </div>
      </div>
      <div class="stat-card">
        <span class="stat-icon">📋</span>
        <div class="stat-content">
          <h3>{{ summary.total_services }}</h3>
          <p>Servicios</p>
        </div>
      </div>
    </div>

    <div class="transactions-section">
      <h2>📋 Historial de servicios completados</h2>
      <div v-if="loading" class="empty">Cargando...</div>
      <div v-else-if="error" class="empty" style="color:red">{{ error }}</div>
      <div v-else-if="transactions.length === 0" class="empty">No hay servicios completados aún</div>
      <div v-else>
        <div class="tx-list">
          <div v-for="tx in transactions" :key="tx.id" class="tx-item">
            <div class="tx-info">
              <span class="tx-name">{{ tx.service_name }}</span>
              <span class="tx-date">{{ formatDate(tx.created_at) }}</span>
            </div>
            <div class="tx-right">
              <span class="tx-status" :class="tx.status">{{ tx.status }}</span>
              <span class="tx-amount">{{ formatCurrency(tx.amount) }}</span>
            </div>
          </div>
        </div>
        <div v-if="totalPages > 1" class="pagination">
          <button :disabled="page <= 1" @click="changePage(page - 1)">←</button>
          <span>{{ page }} / {{ totalPages }}</span>
          <button :disabled="page >= totalPages" @click="changePage(page + 1)">→</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import api from '@/axios'

export default {
  name: 'EarningsPage',
  data() {
    return {
      summary: { total_earned: 0, total_paid: 0, total_pending: 0, total_services: 0 },
      transactions: [],
      page: 1,
      total: 0,
      limit: 20,
      loading: true,
      error: null
    }
  },
  computed: {
    totalPages() {
      return Math.ceil(this.total / this.limit) || 1
    }
  },
  async mounted() {
    await this.loadEarnings()
  },
  methods: {
    async loadEarnings() {
      this.loading = true
      this.error = null
      try {
        const { data } = await api.get('/provider/earnings', { params: { page: this.page } })
        this.summary = data.summary || {}
        this.transactions = data.transactions || []
        this.total = data.total || 0
      } catch (e) {
        this.error = 'Error al cargar: ' + (e.response?.data?.error || e.message)
        console.error(e)
      } finally {
        this.loading = false
      }
    },
    async changePage(page) {
      this.page = page
      await this.loadEarnings()
    },
    formatCurrency(amount) {
      return new Intl.NumberFormat('es-VE', {
        style: 'currency', currency: 'VES', minimumFractionDigits: 2
      }).format(amount || 0)
    },
    formatDate(date) {
      if (!date) return ''
      return new Date(date).toLocaleDateString('es-VE', {
        year: 'numeric', month: 'short', day: 'numeric'
      })
    }
  }
}
</script>

<style scoped>
.earnings-page { max-width: 900px; margin: 0 auto; padding: 24px; }
.header { margin-bottom: 32px; }
.header h1 { font-size: 2rem; color: #2d3436; display: flex; align-items: center; gap: 10px; }
.icon { font-size: 2rem; }
.stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 16px; margin-bottom: 32px; }
.stat-card { background: white; border-radius: 16px; padding: 24px; display: flex; align-items: center; gap: 16px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); }
.stat-icon { font-size: 2rem; }
.stat-content h3 { font-size: 1.4rem; margin: 0; color: #2d3436; }
.stat-content p { color: #636e72; margin: 4px 0 0; font-size: 0.85rem; }
.transactions-section { background: white; border-radius: 16px; padding: 24px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); }
.transactions-section h2 { margin: 0 0 16px; font-size: 1.2rem; }
.empty { text-align: center; color: #94a3b8; padding: 24px; }
.tx-item { display: flex; justify-content: space-between; align-items: center; padding: 12px 0; border-bottom: 1px solid #f1f5f9; }
.tx-name { font-weight: 600; color: #2d3436; font-size: 0.9rem; }
.tx-date { font-size: 0.75rem; color: #94a3b8; display: block; }
.tx-right { display: flex; align-items: center; gap: 12px; }
.tx-status { font-size: 0.7rem; padding: 3px 8px; border-radius: 10px; font-weight: 600; text-transform: uppercase; }
.tx-status.pending { background: #fef3c7; color: #d97706; }
.tx-status.verifying { background: #dbeafe; color: #2563eb; }
.tx-status.paid { background: #d1fae5; color: #059669; }
.tx-amount { font-weight: 700; color: #2d3436; }
.pagination { display: flex; justify-content: center; align-items: center; gap: 16px; margin-top: 20px; padding-top: 16px; border-top: 1px solid #f1f5f9; }
.pagination button { padding: 8px 16px; border: 1px solid #e2e8f0; background: white; border-radius: 8px; cursor: pointer; font-weight: 600; }
.pagination button:hover:not(:disabled) { background: #667eea; color: white; }
.pagination button:disabled { opacity: 0.5; cursor: not-allowed; }
.pagination span { color: #64748b; font-size: 0.9rem; }
</style>
