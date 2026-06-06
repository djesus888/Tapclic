<template>
  <div class="admin-providers-page">
    <!-- Header -->
    <div class="header">
      <div class="title-section">
        <h1><span class="admin-icon">🛡️</span> Gestión de Proveedores</h1>
        <p>Administra los proveedores registrados en la plataforma</p>
      </div>
      <div class="header-actions">
        <button class="btn-refresh" @click="fetchProviders" :disabled="loading">
          {{ loading ? '⏳ Cargando...' : '🔄 Actualizar' }}
        </button>
      </div>
    </div>

    <!-- Stats Cards -->
    <div class="stats-section">
      <div class="stat-card">
        <div class="stat-icon total">🔧</div>
        <div class="stat-content">
          <h3>{{ total }}</h3>
          <p>Proveedores totales</p>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon active">✅</div>
        <div class="stat-content">
          <h3>{{ activeCount }}</h3>
          <p>Activos</p>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon pending">⏳</div>
        <div class="stat-content">
          <h3>{{ pendingCount }}</h3>
          <p>Pendientes</p>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon services">📦</div>
        <div class="stat-content">
          <h3>{{ totalServices }}</h3>
          <p>Servicios activos</p>
        </div>
      </div>
    </div>

    <!-- Filters -->
    <div class="filters-section">
      <div class="filter-group">
        <label for="search">Buscar proveedor</label>
        <div class="search-input">
          <span class="search-icon">🔍</span>
          <input v-model="filters.search" id="search" placeholder="Nombre, email o teléfono" @input="debouncedSearch">
        </div>
      </div>
      <div class="filter-row">
        <div class="filter-group">
          <label for="status-filter">Estado</label>
          <select id="status-filter" v-model="filters.active" @change="fetchProviders">
            <option value="">Todos</option>
            <option value="1">Activo</option>
            <option value="0">Inactivo</option>
          </select>
        </div>
        <button class="btn-clear-filters" @click="resetFilters">
          <span class="clear-icon">🗑️</span> Limpiar filtros
        </button>
      </div>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="loading-container">
      <div class="spinner"></div>
      <p>Cargando proveedores...</p>
    </div>

    <!-- Error -->
    <div v-else-if="errorMsg" class="error-state">
      <div class="error-icon">⚠️</div>
      <h3>{{ errorMsg }}</h3>
      <button class="btn-retry" @click="fetchProviders">Reintentar</button>
    </div>

    <!-- Providers Table -->
    <div v-else-if="providers.length > 0" class="providers-table-container">
      <div class="table-header">
        <div class="table-info">
          Mostrando <strong>{{ from }} - {{ to }}</strong> de <strong>{{ total }}</strong> proveedores
        </div>
      </div>

      <div class="providers-grid">
        <div v-for="provider in providers" :key="provider.id" class="provider-card">
          <div class="card-header">
            <div class="avatar-container">
              <img :src="avatarUrl(provider?.avatar_url || '')" :alt="provider?.name" class="provider-avatar" @error="handleAvatarError">
              <div class="status-indicator" :class="{ active: provider.active == 1 }"></div>
            </div>
            <div class="provider-info">
              <h3 class="provider-name">{{ provider?.name }}</h3>
              <p class="provider-email">{{ provider?.email }}</p>
            </div>
            <div class="provider-status" :class="provider.active == 1 ? 'active' : 'inactive'">
              {{ provider.active == 1 ? 'Activo' : 'Inactivo' }}
            </div>
          </div>

          <div class="card-details">
            <div class="detail-item">
              <span class="detail-icon">📱</span>
              <span>{{ provider?.phone || 'Sin teléfono' }}</span>
            </div>
            <div class="detail-item">
              <span class="detail-icon">📦</span>
              <span>{{ provider?.service_count || 0 }} servicios</span>
            </div>
            <div class="detail-item">
              <span class="detail-icon">⭐</span>
              <span>{{ provider?.average_rating ? Number(provider.average_rating).toFixed(1) : 'N/A' }}</span>
            </div>
          </div>

          <div class="card-actions">
            <button class="btn-view" @click="viewProvider(provider.id)" title="Ver detalles">👁️ Ver</button>
            <button class="btn-toggle" @click="toggleProvider(provider)" :title="provider.active == 1 ? 'Desactivar' : 'Activar'">
              {{ provider.active == 1 ? '🔒 Desactivar' : '🔓 Activar' }}
            </button>
          </div>
        </div>
      </div>

      <!-- Pagination -->
      <div v-if="lastPage > 1" class="pagination">
        <div class="pagination-info">Página {{ currentPage }} de {{ lastPage }}</div>
        <div class="pagination-buttons">
          <button class="pagination-btn" :disabled="currentPage === 1" @click="goToPage(currentPage - 1)">← Anterior</button>
          <button v-for="page in visiblePages" :key="page" class="pagination-btn" :class="{ active: page === currentPage }" @click="goToPage(page)">{{ page }}</button>
          <button class="pagination-btn" :disabled="currentPage === lastPage" @click="goToPage(currentPage + 1)">Siguiente →</button>
        </div>
      </div>
    </div>

    <!-- Empty -->
    <div v-else class="empty-state">
      <div class="empty-icon">🛡️</div>
      <h3>No se encontraron proveedores</h3>
      <button class="btn-clear-all" @click="resetFilters">Limpiar filtros</button>
    </div>

    <!-- Toast -->
    <div v-if="toast.show" class="toast" :class="toast.type">{{ toast.message }}</div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { getImageUrl } from '@/utils/imageHelper'
import api from '@/axios'

const router = useRouter()

const providers = ref([])
const currentPage = ref(1)
const lastPage = ref(1)
const total = ref(0)
const from = ref(0)
const to = ref(0)
const loading = ref(true)
const errorMsg = ref('')
const totalServices = ref(0)

const filters = reactive({ search: '', active: '' })
const toast = ref({ show: false, message: '', type: 'success' })

// Computed
const activeCount = computed(() => providers.value.filter(p => p.active == 1).length)
const pendingCount = computed(() => providers.value.filter(p => p.active == 0).length)

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
const getImageUrl = (path) => {
  if (!path) return 'https://via.placeholder.com/100?text=P'
  if (path.startsWith('http') || path.startsWith('blob:')) return path
  if (path.startsWith('/')) return `${import.meta.env.VITE_API_URL || ''}${path}`
  return getImageUrlFromHelper(path, 'avatars')
}
const avatarUrl = (name) => name ? getImageUrl(name.startsWith('http') || name.startsWith('/') ? name : `/uploads/avatars/${name}`) : 'https://via.placeholder.com/100?text=P'

const handleAvatarError = (e) => { e.target.src = 'https://via.placeholder.com/100?text=P' }

const showToast = (message, type = 'success') => {
  toast.value = { show: true, message, type }
  setTimeout(() => { toast.value.show = false }, 3000)
}

const debounce = (fn, delay) => {
  let timeout
  return (...args) => { clearTimeout(timeout); timeout = setTimeout(() => fn(...args), delay) }
}

const fetchProviders = async () => {
  loading.value = true
  errorMsg.value = ''
  try {
    const params = { page: currentPage.value, search: filters.search, role: 'provider', active: filters.active }
    const { data } = await api.get('/admin/users', { params })
    providers.value = Array.isArray(data?.data) ? data.data : []
    currentPage.value = data?.current_page || 1
    lastPage.value = data?.last_page || 1
    total.value = data?.total || 0
    from.value = data?.from || 0
    to.value = data?.to || 0
  } catch (e) {
    errorMsg.value = 'No se pudieron cargar los proveedores.'
    showToast('Error al cargar proveedores', 'error')
  } finally {
    loading.value = false
  }
}

const fetchStats = async () => {
  try {
    const { data } = await api.get('/admin/stats')
    totalServices.value = data?.totalServices || 0
  } catch {}
}

const debouncedSearch = debounce(fetchProviders, 300)

const resetFilters = () => {
  Object.assign(filters, { search: '', active: '' })
  currentPage.value = 1
  fetchProviders()
}

const goToPage = (page) => {
  if (page < 1 || page > lastPage.value) return
  currentPage.value = page
  fetchProviders()
}

const viewProvider = (id) => {
  router.push(`/admin/users?search=&role=provider&active=&highlight=${id}`)
}

const toggleProvider = async (provider) => {
  const newStatus = provider.active == 1 ? 0 : 1
  const action = newStatus ? 'activar' : 'desactivar'
  if (!confirm(`¿Estás seguro de ${action} a ${provider.name}?`)) return
  try {
    const fd = new FormData()
    fd.append('id', provider.id)
    fd.append('active', newStatus)
    await api.post(`/admin/users.php?id=${provider.id}`, fd, { headers: { 'Content-Type': 'multipart/form-data' } })
    provider.active = newStatus
    showToast(`Proveedor ${action}do correctamente`)
  } catch (e) {
    showToast(`Error al ${action} proveedor`, 'error')
  }
}

onMounted(() => {
  fetchProviders()
  fetchStats()
})
</script>


<style scoped>
.admin-providers-page {
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
  font-size: 0.95rem;
}

.admin-icon {
  margin-right: 8px;
}

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
  transform: translateY(-1px);
}

.btn-refresh:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

/* Stats */
.stats-section {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
  margin-bottom: 24px;
}

.stat-card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 16px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
  transition: transform 0.3s;
}

.stat-card:hover {
  transform: translateY(-2px);
}

.stat-icon {
  width: 50px;
  height: 50px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
}

.stat-icon.total { background: #e8f0fe; }
.stat-icon.active { background: #e6f9ed; }
.stat-icon.pending { background: #fff8e1; }
.stat-icon.services { background: #fce4ec; }

.stat-content h3 {
  font-size: 1.5rem;
  font-weight: 700;
  margin: 0;
  color: #1a1a2e;
}

.stat-content p {
  margin: 2px 0 0;
  color: #888;
  font-size: 0.85rem;
}

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
  min-width: 250px;
}

.search-icon {
  margin-right: 8px;
}

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

.filter-group select {
  padding: 8px 12px;
  border: 1px solid #ddd;
  border-radius: 8px;
  background: #fafafa;
  font-size: 0.95rem;
  min-width: 150px;
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

.btn-clear-filters:hover {
  background: #eee;
}

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

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* Error */
.error-state {
  text-align: center;
  padding: 60px 0;
  background: white;
  border-radius: 12px;
}

.error-icon {
  font-size: 3rem;
  margin-bottom: 12px;
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

/* Providers Grid */
.providers-table-container {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
}

.table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  flex-wrap: wrap;
  gap: 12px;
}

.table-info {
  color: #666;
  font-size: 0.9rem;
}

.providers-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 16px;
}

.provider-card {
  border: 1px solid #eee;
  border-radius: 12px;
  padding: 16px;
  transition: all 0.3s;
}

.provider-card:hover {
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
  transform: translateY(-2px);
}

.card-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
}

.avatar-container {
  position: relative;
}

.provider-avatar {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  object-fit: cover;
}

.status-indicator {
  position: absolute;
  bottom: 0;
  right: 0;
  width: 12px;
  height: 12px;
  border-radius: 50%;
  background: #ccc;
  border: 2px solid white;
}

.status-indicator.active {
  background: #4caf50;
}

.provider-info {
  flex: 1;
}

.provider-name {
  font-weight: 600;
  margin: 0;
  font-size: 1rem;
  color: #1a1a2e;
}

.provider-email {
  margin: 2px 0 0;
  font-size: 0.85rem;
  color: #888;
}

.provider-status {
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
}

.provider-status.active {
  background: #e6f9ed;
  color: #2e7d32;
}

.provider-status.inactive {
  background: #fce4ec;
  color: #c62828;
}

.card-details {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  margin-bottom: 12px;
  padding: 10px 0;
  border-top: 1px solid #f0f0f0;
  border-bottom: 1px solid #f0f0f0;
}

.detail-item {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 0.85rem;
  color: #555;
}

.card-actions {
  display: flex;
  gap: 8px;
}

.btn-view, .btn-toggle {
  flex: 1;
  padding: 8px 12px;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-size: 0.85rem;
  font-weight: 500;
  transition: all 0.3s;
}

.btn-view {
  background: #e8f0fe;
  color: #1a73e8;
}

.btn-view:hover {
  background: #d2e3fc;
}

.btn-toggle {
  background: #f5f5f5;
  color: #555;
}

.btn-toggle:hover {
  background: #eee;
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

.pagination-info {
  color: #666;
  font-size: 0.9rem;
}

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

.pagination-btn:hover:not(:disabled):not(.active) {
  background: #f5f5f5;
}

.pagination-btn.active {
  background: #667eea;
  color: white;
  border-color: #667eea;
}

.pagination-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Empty */
.empty-state {
  text-align: center;
  padding: 60px 0;
  background: white;
  border-radius: 12px;
}

.empty-icon {
  font-size: 3rem;
  margin-bottom: 12px;
}

.empty-state h3 {
  color: #555;
  margin: 0 0 8px;
}

.empty-state p {
  color: #888;
  margin: 0 0 16px;
}

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
.toast.info { background: #2196f3; }

@keyframes slideIn {
  from { transform: translateX(100%); opacity: 0; }
  to { transform: translateX(0); opacity: 1; }
}

@media (max-width: 768px) {
  .admin-providers-page { padding: 16px; }
  .header { flex-direction: column; align-items: flex-start; }
  .providers-grid { grid-template-columns: 1fr; }
  .filters-section { flex-direction: column; }
  .search-input { min-width: 100%; }
}
</style>
