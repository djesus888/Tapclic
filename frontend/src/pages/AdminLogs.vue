<template>
  <div class="admin-logs-page">
    <!-- Header -->
    <div class="header">
      <div class="title-section">
        <h1><span class="admin-icon">📋</span> Registros del Sistema</h1>
        <p>Auditoría de acciones realizadas en la plataforma</p>
      </div>
      <div class="header-actions">
        <button class="btn-refresh" @click="fetchLogs" :disabled="loading">
          {{ loading ? '⏳ Cargando...' : '🔄 Actualizar' }}
        </button>
      </div>
    </div>

    <!-- Filters -->
    <div class="filters-section">
      <div class="filter-group">
        <label for="search">Buscar</label>
        <div class="search-input">
          <span class="search-icon">🔍</span>
          <input v-model="filters.search" id="search" placeholder="Acción, detalles o IP..." @input="debouncedSearch">
        </div>
      </div>
      <div class="filter-row">
        <div class="filter-group">
          <label for="type-filter">Tipo</label>
          <select id="type-filter" v-model="filters.type" @change="fetchLogs">
            <option value="">Todos</option>
            <option v-for="type in actionTypes" :key="type" :value="type">{{ type }}</option>
          </select>
        </div>
        <div class="filter-group">
          <label for="date-from">Desde</label>
          <input type="date" id="date-from" v-model="filters.date_from" @change="fetchLogs">
        </div>
        <div class="filter-group">
          <label for="date-to">Hasta</label>
          <input type="date" id="date-to" v-model="filters.date_to" @change="fetchLogs">
        </div>
        <button class="btn-clear-filters" @click="resetFilters">
          <span class="clear-icon">🗑️</span> Limpiar filtros
        </button>
      </div>
    </div>

    <!-- Stats -->
    <div class="stats-section">
      <div class="stat-card">
        <div class="stat-icon total">📋</div>
        <div class="stat-content">
          <h3>{{ total }}</h3>
          <p>Registros totales</p>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon page">📄</div>
        <div class="stat-content">
          <h3>{{ logs.length }}</h3>
          <p>En esta página</p>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon types">🏷️</div>
        <div class="stat-content">
          <h3>{{ actionTypes.length }}</h3>
          <p>Tipos de acciones</p>
        </div>
      </div>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="loading-container">
      <div class="spinner"></div>
      <p>Cargando registros...</p>
    </div>

    <!-- Error -->
    <div v-else-if="errorMsg" class="error-state">
      <div class="error-icon">⚠️</div>
      <h3>{{ errorMsg }}</h3>
      <button class="btn-retry" @click="fetchLogs">Reintentar</button>
    </div>

    <!-- Logs Table -->
    <div v-else-if="logs.length > 0" class="logs-table-container">
      <div class="table-header">
        <div class="table-info">
          Mostrando <strong>{{ logs.length }}</strong> de <strong>{{ total }}</strong> registros
        </div>
      </div>

      <div class="table-responsive">
        <table class="logs-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Usuario</th>
              <th>Acción</th>
              <th>Tipo</th>
              <th>Detalles</th>
              <th>IP</th>
              <th>Fecha</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="log in logs" :key="log.id" :class="getRowClass(log.action_type)">
              <td class="cell-id">{{ log.id }}</td>
              <td>
                <div class="user-cell">
                  <span class="user-name">{{ log.user_name || 'Sistema' }}</span>
                  <span class="user-role" v-if="log.role">{{ log.role }}</span>
                </div>
              </td>
              <td>
                <span class="action-badge" :class="getActionClass(log.action_type)">
                  {{ log.action || '—' }}
                </span>
              </td>
              <td>
                <span class="type-badge">{{ log.action_type || '—' }}</span>
              </td>
              <td class="cell-details" :title="log.details">{{ truncate(log.details, 60) }}</td>
              <td><code>{{ log.ip_address || '—' }}</code></td>
              <td class="cell-date">{{ formatDate(log.created_at) }}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Pagination -->
      <div v-if="lastPage > 1" class="pagination">
        <div class="pagination-info">Página {{ currentPage }} de {{ lastPage }}</div>
        <div class="pagination-buttons">
          <button class="pagination-btn" :disabled="currentPage === 1" @click="goToPage(currentPage - 1)">←</button>
          <button v-for="page in visiblePages" :key="page" class="pagination-btn" :class="{ active: page === currentPage }" @click="goToPage(page)">{{ page }}</button>
          <button class="pagination-btn" :disabled="currentPage === lastPage" @click="goToPage(currentPage + 1)">→</button>
        </div>
      </div>
    </div>

    <!-- Empty -->
    <div v-else class="empty-state">
      <div class="empty-icon">📋</div>
      <h3>No se encontraron registros</h3>
      <p>No hay logs que coincidan con los filtros aplicados</p>
      <button class="btn-clear-all" @click="resetFilters">Limpiar filtros</button>
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

const logs = ref([])
const currentPage = ref(1)
const lastPage = ref(1)
const total = ref(0)
const loading = ref(true)
const errorMsg = ref('')
const actionTypes = ref([])

const filters = reactive({
  search: '',
  type: '',
  date_from: '',
  date_to: ''
})

const toast = ref({ show: false, message: '', type: 'success' })

// Computed
const visiblePages = computed(() => {
  const totalPages = Number(lastPage.value) || 1
  const pages = []
  const maxVisible = 5
  let start = Math.max(1, currentPage.value - Math.floor(maxVisible / 2))
  let end = Math.min(totalPages, start + maxVisible - 1)
  if (end - start + 1 < maxVisible) start = Math.max(1, end - maxVisible + 1)
  for (let i = start; i <= end; i++) pages.push(i)
  return pages
})

// Methods
const showToast = (message, type = 'success') => {
  toast.value = { show: true, message, type }
  setTimeout(() => { toast.value.show = false }, 3000)
}

const debounce = (fn, delay) => {
  let timeout
  return (...args) => { clearTimeout(timeout); timeout = setTimeout(() => fn(...args), delay) }
}

const truncate = (text, max) => {
  if (!text) return '—'
  return text.length > max ? text.substring(0, max) + '...' : text
}

const formatDate = (dateStr) => {
  if (!dateStr) return '—'
  const date = new Date(dateStr)
  return date.toLocaleString('es-ES', {
    day: '2-digit', month: '2-digit', year: 'numeric',
    hour: '2-digit', minute: '2-digit'
  })
}

const getActionClass = (type) => {
  if (!type) return ''
  if (type.includes('login') || type.includes('auth')) return 'action-auth'
  if (type.includes('create') || type.includes('insert')) return 'action-create'
  if (type.includes('update') || type.includes('edit')) return 'action-update'
  if (type.includes('delete') || type.includes('remove')) return 'action-delete'
  if (type.includes('error') || type.includes('fail')) return 'action-error'
  return 'action-default'
}

const getRowClass = (type) => {
  if (!type) return ''
  if (type.includes('error') || type.includes('fail')) return 'row-error'
  return ''
}

const getHeaders = () => ({
  Authorization: `Bearer ${authStore.token}`
})

const fetchLogs = async () => {
  loading.value = true
  errorMsg.value = ''
  try {
    const params = {
      page: currentPage.value,
      search: filters.search,
      type: filters.type,
      date_from: filters.date_from,
      date_to: filters.date_to
    }
    const { data } = await api.get('/admin/security/audit-logs', { params, headers: getHeaders() })

    logs.value = data?.logs || []
    currentPage.value = data?.pagination?.current_page || 1
    lastPage.value = data?.pagination?.last_page || 1
    total.value = data?.pagination?.total || 0
    actionTypes.value = data?.action_types || []
  } catch (e) {
    errorMsg.value = 'Error al cargar los registros'
    showToast('Error al cargar logs', 'error')
  } finally {
    loading.value = false
  }
}

const debouncedSearch = debounce(fetchLogs, 300)

const resetFilters = () => {
  Object.assign(filters, { search: '', type: '', date_from: '', date_to: '' })
  currentPage.value = 1
  fetchLogs()
}

const goToPage = (page) => {
  if (page < 1 || page > lastPage.value) return
  currentPage.value = page
  fetchLogs()
}

onMounted(fetchLogs)
</script>

<style scoped>
.admin-logs-page {
  padding: 24px;
  max-width: 1400px;
  margin: 0 auto;
}

/* Header */
.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  flex-wrap: wrap;
  gap: 16px;
}

.title-section h1 {
  font-size: 1.8rem;
  font-weight: 700;
  color: #1a1a2e;
  margin: 0 0 4px 0;
}

.title-section p {
  color: #666;
  margin: 0;
}

.admin-icon { margin-right: 8px; }

.btn-refresh {
  padding: 10px 20px;
  background: #667eea;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s;
}

.btn-refresh:hover:not(:disabled) {
  background: #5a6fd6;
}

button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

/* Stats */
.stats-section {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
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

.stat-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.4rem;
}

.stat-icon.total { background: #e8f0fe; }
.stat-icon.page { background: #e8f5e9; }
.stat-icon.types { background: #fff3e0; }

.stat-content h3 { font-size: 1.3rem; margin: 0; }
.stat-content p { margin: 2px 0 0; font-size: 0.8rem; color: #888; }

/* Filters */
.filters-section {
  background: white;
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 24px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  align-items: flex-end;
}

.filter-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.filter-group label {
  font-weight: 600;
  font-size: 0.85rem;
  color: #555;
}

.search-input {
  display: flex;
  align-items: center;
  border: 1px solid #ddd;
  border-radius: 8px;
  padding: 8px 12px;
  background: #fafafa;
  min-width: 200px;
}

.search-icon { margin-right: 8px; }

.search-input input {
  border: none;
  outline: none;
  background: transparent;
  width: 100%;
  font-size: 0.95rem;
}

.filter-row {
  display: flex;
  gap: 12px;
  align-items: flex-end;
  flex-wrap: wrap;
}

.filter-group select,
.filter-group input[type="date"] {
  padding: 8px 12px;
  border: 1px solid #ddd;
  border-radius: 8px;
  background: #fafafa;
  font-size: 0.95rem;
}

.btn-clear-filters {
  padding: 8px 16px;
  background: #f5f5f5;
  border: 1px solid #ddd;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.3s;
}

.btn-clear-filters:hover { background: #eee; }

/* Loading */
.loading-container {
  text-align: center;
  padding: 60px 0;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #e0e0e0;
  border-top-color: #667eea;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
  margin: 0 auto 16px;
}

@keyframes spin { to { transform: rotate(360deg); } }

/* Error */
.error-state {
  text-align: center;
  padding: 60px 0;
  background: white;
  border-radius: 12px;
}

.btn-retry {
  margin-top: 12px;
  padding: 10px 24px;
  background: #667eea;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
}

/* Table */
.logs-table-container {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
}

.table-header {
  margin-bottom: 16px;
}

.table-info { color: #666; font-size: 0.9rem; }

.table-responsive {
  overflow-x: auto;
}

.logs-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.9rem;
}

.logs-table th {
  background: #fafafa;
  padding: 12px 10px;
  text-align: left;
  font-weight: 600;
  color: #555;
  border-bottom: 2px solid #eee;
  white-space: nowrap;
}

.logs-table td {
  padding: 10px;
  border-bottom: 1px solid #f0f0f0;
}

.logs-table tr:hover { background: #fafafa; }
.logs-table tr.row-error { background: #fff5f5; }

.cell-id { color: #aaa; font-size: 0.8rem; width: 50px; }
.cell-date { white-space: nowrap; color: #888; font-size: 0.85rem; }
.cell-details { max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }

.user-cell {
  display: flex;
  flex-direction: column;
}

.user-name { font-weight: 500; }
.user-role { font-size: 0.75rem; color: #888; }

.action-badge {
  padding: 3px 10px;
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: 500;
}

.action-auth { background: #e8f5e9; color: #2e7d32; }
.action-create { background: #e8f0fe; color: #1a73e8; }
.action-update { background: #fff3e0; color: #e65100; }
.action-delete { background: #fce4ec; color: #c62828; }
.action-error { background: #fbe9e7; color: #bf360c; }
.action-default { background: #f5f5f5; color: #555; }

.type-badge {
  background: #f5f5f5;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 0.8rem;
  color: #666;
}

code {
  background: #f5f5f5;
  padding: 2px 6px;
  border-radius: 4px;
  font-size: 0.85rem;
}

/* Pagination */
.pagination {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 20px;
  flex-wrap: wrap;
  gap: 12px;
}

.pagination-info { color: #666; font-size: 0.9rem; }

.pagination-buttons {
  display: flex;
  gap: 6px;
}

.pagination-btn {
  padding: 8px 14px;
  border: 1px solid #ddd;
  border-radius: 8px;
  background: white;
  cursor: pointer;
  font-size: 0.9rem;
  transition: all 0.3s;
}

.pagination-btn:hover:not(:disabled):not(.active) { background: #f5f5f5; }
.pagination-btn.active { background: #667eea; color: white; border-color: #667eea; }
.pagination-btn:disabled { opacity: 0.5; cursor: not-allowed; }

/* Empty */
.empty-state {
  text-align: center;
  padding: 60px 0;
  background: white;
  border-radius: 12px;
}

.empty-icon { font-size: 3rem; margin-bottom: 12px; }
.empty-state h3 { color: #555; margin: 0 0 8px; }
.empty-state p { color: #888; margin: 0 0 16px; }

.btn-clear-all {
  padding: 10px 24px;
  background: #667eea;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
}

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
  animation: slideIn 0.3s ease;
}

.toast.success { background: #4caf50; }
.toast.error { background: #f44336; }

@keyframes slideIn {
  from { transform: translateX(100%); opacity: 0; }
  to { transform: translateX(0); opacity: 1; }
}

@media (max-width: 768px) {
  .admin-logs-page { padding: 16px; }
  .filters-section { flex-direction: column; }
  .search-input { min-width: 100%; }
}
</style>
