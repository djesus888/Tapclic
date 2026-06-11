<template>
  <div class="admin-users-page">
    <!-- Header -->
    <div class="header">
      <div class="title-section">
        <h1><span class="admin-icon">👑</span> Gestión de Usuarios</h1>
        <p>Administra los usuarios registrados en la plataforma</p>
      </div>
    </div>

    <!-- Stats Cards -->
    <div class="stats-section">
      <div class="stat-card">
        <div class="stat-icon total">👥</div>
        <div class="stat-content">
          <h3>{{ total }}</h3>
          <p>Usuarios totales</p>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon clients">😊</div>
        <div class="stat-content">
          <h3>{{ clientCount }}</h3>
          <p>Clientes</p>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon providers">🔧</div>
        <div class="stat-content">
          <h3>{{ providerCount }}</h3>
          <p>Proveedores</p>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon drivers">🚗</div>
        <div class="stat-content">
          <h3>{{ driverCount }}</h3>
          <p>Conductores</p>
        </div>
      </div>
    </div>

    <!-- Filters Section -->
    <div class="filters-section">
      <div class="filter-group">
        <label for="search">Buscar usuario</label>
        <div class="search-input">
          <span class="search-icon">🔍</span>
          <input
            v-model="filters.search"
            id="search"
            placeholder="Nombre, email o teléfono"
            @input="debouncedSearch"
          >
        </div>
      </div>

      <div class="filter-row">
        <div class="filter-group">
          <label for="role-filter">Rol</label>
          <select
            id="role-filter"
            v-model="filters.role"
            @change="fetchUsers"
          >
            <option value="">Todos los roles</option>
            <option value="client">Cliente</option>
            <option value="provider">Proveedor</option>
            <option value="driver">Conductor</option>
          </select>
        </div>

        <div class="filter-group">
          <label for="status-filter">Estado</label>
          <select
            id="status-filter"
            v-model="filters.active"
            @change="fetchUsers"
          >
            <option value="">Todos los estados</option>
            <option value="1">Activo</option>
            <option value="0">Inactivo</option>
          </select>
        </div>

        <button
          class="btn-clear-filters"
          @click="resetFilters"
        >
          <span class="clear-icon">🗑️</span>
          Limpiar filtros
        </button>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="loading-container">
      <div class="spinner"></div>
      <p>Cargando usuarios...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="errorMsg && !loading" class="error-state">
      <div class="error-icon">⚠️</div>
      <h3>Error al cargar usuarios</h3>
      <p>{{ errorMsg }}</p>
      <button class="btn-retry" @click="fetchUsers">
        Reintentar
      </button>
    </div>

    <!-- Users Table -->
    <div v-else-if="users.length > 0" class="users-table-container">
      <div class="table-header">
        <div class="table-info">
          Mostrando <strong>{{ from }} - {{ to }}</strong> de <strong>{{ total }}</strong> usuarios
        </div>
        <div class="table-actions">
          <button class="btn-export" @click="exportUsers">
            📊 Exportar CSV
          </button>
        </div>
      </div>

      <div class="users-grid">
        <div
          v-for="user in users"
          :key="user.id"
          class="user-card"
          :class="{
            'client': user.role === 'client',
            'provider': user.role === 'provider',
            'driver': user.role === 'driver'
          }"
        >
          <div class="card-badge" :class="user.role">
            {{ roleLabel(user.role) }}
          </div>

          <div class="user-header">
            <div class="avatar-container">
              <img
                :src="avatarUrl(user?.avatar_url || '')"
                :alt="user?.name"
                class="user-avatar"
                @error="handleAvatarError"
              >
              <div class="status-indicator" :class="{ active: user.active == 1 }"></div>
            </div>

            <div class="user-info">
              <h3 class="user-name">{{ user?.name }}</h3>
              <p class="user-email">{{ user?.email }}</p>
            </div>
          </div>

          <div class="user-details">
            <div class="detail-item">
              <span class="detail-icon">📱</span>
              <span class="detail-text">{{ user?.phone || 'Sin teléfono' }}</span>
            </div>
            <div class="detail-item" v-if="user?.address">
              <span class="detail-icon">📍</span>
              <span class="detail-text">{{ user.address }}</span>
            </div>
            <div class="detail-item" v-if="user?.service_categories">
              <span class="detail-icon">🏷️</span>
              <span class="detail-text">{{ user.service_categories }}</span>
            </div>
          </div>

          <div class="card-actions">
            <button
              class="btn-edit"
              @click="openModal(user)"
              title="Editar usuario"
            >
              <span class="btn-icon">✏️</span>
              Editar
            </button>
            <button
              class="btn-delete"
              @click="deleteUser(user?.id)"
              title="Eliminar usuario"
            >
              <span class="btn-icon">🗑️</span>
              Eliminar
            </button>
          </div>
        </div>
      </div>

      <!-- Pagination -->
      <div v-if="lastPage > 1" class="pagination">
        <div class="pagination-info">
          Página {{ currentPage }} de {{ lastPage }}
        </div>
        <div class="pagination-buttons">
          <button
            class="pagination-btn"
            :disabled="currentPage === 1"
            @click="goToPage(currentPage - 1)"
          >
            ← Anterior
          </button>

          <button
            v-for="page in visiblePages"
            :key="page"
            class="pagination-btn"
            :class="{ active: page === currentPage }"
            @click="goToPage(page)"
          >
            {{ page }}
          </button>

          <button
            class="pagination-btn"
            :disabled="currentPage === lastPage"
            @click="goToPage(currentPage + 1)"
          >
            Siguiente →
          </button>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="empty-state">
      <div class="empty-icon">👥</div>
      <h3>No se encontraron usuarios</h3>
      <p>No hay usuarios que coincidan con los filtros aplicados</p>
      <button class="btn-clear-all" @click="resetFilters">
        Limpiar todos los filtros
      </button>
    </div>

    <!-- Modal de Edición -->
    <div
      v-if="modalOpen"
      class="modal-overlay"
      @click.self="modalOpen = false"
    >
      <div class="modal">
        <div class="modal-header">
          <h2><span class="modal-icon">✏️</span> Editar Usuario</h2>
          <button class="modal-close" @click="modalOpen = false">
            ✕
          </button>
        </div>

        <form @submit.prevent="submitModal" class="modal-form">
          <div class="form-grid">
            <div class="form-group">
              <label for="edit-name">Nombre completo *</label>
              <input
                id="edit-name"
                v-model="form.name"
                required
                placeholder="Ej: Juan Pérez"
              >
            </div>

            <div class="form-group">
              <label for="edit-email">Email *</label>
              <input
                id="edit-email"
                v-model="form.email"
                type="email"
                required
                placeholder="usuario@ejemplo.com"
              >
            </div>

            <div class="form-group">
              <label for="edit-phone">Teléfono</label>
              <input
                id="edit-phone"
                v-model="form.phone"
                placeholder="Ej: +1 234 567 890"
              >
            </div>

            <div class="form-group">
              <label for="edit-role">Rol *</label>
              <select
                id="edit-role"
                v-model="form.role"
                required
              >
                <option value="client">Cliente</option>
                <option value="provider">Proveedor</option>
                <option value="driver">Conductor</option>
              </select>
            </div>

            <div class="form-group full-width">
              <label for="edit-address">Dirección personal</label>
              <input
                id="edit-address"
                v-model="form.address"
                placeholder="Dirección completa"
              >
            </div>

            <div class="form-group full-width">
              <label for="edit-business-address">Dirección comercial</label>
              <input
                id="edit-business-address"
                v-model="form.business_address"
                placeholder="Dirección del negocio"
              >
            </div>

            <div class="form-group full-width">
              <label for="edit-categories">Categorías de servicio</label>
              <input
                id="edit-categories"
                v-model="form.service_categories"
                placeholder="Separadas por coma (Ej: Limpieza, Reparación)"
              >
            </div>

            <div class="form-group full-width">
              <label for="edit-coverage">Área de cobertura</label>
              <input
                id="edit-coverage"
                v-model="form.coverage_area"
                placeholder="Zonas donde ofrece servicios"
              >
            </div>

            <div class="form-group full-width">
              <label for="edit-avatar">Avatar del usuario</label>
              <div class="avatar-upload">
                <div class="avatar-preview">
                  <img
                    :src="preview || getImageUrlHelper(form.avatar_url || '')"
                    alt="Vista previa"
                    class="avatar-preview-img"
                  >
                </div>
                <div class="avatar-upload-controls">
                  <label for="avatar-file" class="btn-upload">
                    📁 Subir nueva imagen
                  </label>
                  <input
                    id="avatar-file"
                    type="file"
                    accept="image/*"
                    @change="onFileChange"
                    class="avatar-file-input"
                  >
                  <p class="upload-hint">Formatos: JPG, PNG, GIF • Máx: 2MB</p>
                </div>
              </div>
            </div>
          </div>

          <div class="modal-actions">
            <button
              type="button"
              class="btn-cancel"
              @click="modalOpen = false"
            >
              Cancelar
            </button>
            <button
              type="submit"
              class="btn-save"
              :disabled="loading"
            >
              <span v-if="loading" class="save-spinner"></span>
              <span v-else>💾 Guardar cambios</span>
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast" :class="toast.type">
      {{ toast.message }}
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { getImageUrl as getImageUrlHelper } from '@/utils/imageHelper'
import api from '@/axios'

// Mantengo TODA tu lógica original
const users = ref([])
const currentPage = ref(1)
const lastPage = ref(1)
const total = ref(0)
const from = ref(0)
const to = ref(0)
const loading = ref(true)
const errorMsg = ref('')

const filters = reactive({ search: '', role: '', active: '' })

const modalOpen = ref(false)
const form = ref({})
const preview = ref(null)
const file = ref(null)

// Toast notifications
const toast = ref({
  show: false,
  message: '',
  type: 'success'
})


// Computed properties para estadísticas
const clientCount = computed(() => {
  return users.value.filter(u => u.role === 'client').length
})

const providerCount = computed(() => {
  return users.value.filter(u => u.role === 'provider').length
})

const driverCount = computed(() => {
  return users.value.filter(u => u.role === 'driver').length
})

const visiblePages = computed(() => {
  const totalPages = Number(lastPage.value) || 1
  const pages = []
  const maxVisible = 5

  let start = Math.max(1, currentPage.value - Math.floor(maxVisible / 2))
  let end = Math.min(totalPages, start + maxVisible - 1)

  if (end - start + 1 < maxVisible) {
    start = Math.max(1, end - maxVisible + 1)
  }

  for (let i = start; i <= end; i++) {
    pages.push(i)
  }

  return pages
})

// Métodos auxiliares
const roleLabel = (role) => {
  const labels = {
    client: 'Cliente',
    provider: 'Proveedor',
    driver: 'Conductor'
  }
  return labels[role] || role
}

const showToast = (message, type = 'success') => {
  toast.value = { show: true, message, type }
  setTimeout(() => {
    toast.value.show = false
  }, 3000)
}

const handleAvatarError = (event) => {
  event.target.src = 'https://via.placeholder.com/100?text=Usuario'
}

const exportUsers = () => {
  const headers = ['Nombre', 'Email', 'Teléfono', 'Rol', 'Dirección']
  const csvData = users.value.map(user => [
    user.name,
    user.email,
    user.phone || 'N/A',
    roleLabel(user.role),
    user.address || 'N/A'
  ])

  const csvContent = [headers, ...csvData]
    .map(row => row.map(cell => `"${cell}"`).join(','))
    .join('\n')

  const blob = new Blob([csvContent], { type: 'text/csv' })
  const url = window.URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `usuarios-pagina-${currentPage.value}.csv`
  a.click()

  showToast('Lista exportada a CSV', 'success')
}

// Mantengo TODOS tus métodos originales
const debounce = (fn, delay) => {
  let timeout
  return (...args) => {
    clearTimeout(timeout)
    timeout = setTimeout(() => fn(...args), delay)
  }
}

const fetchUsers = async () => {
  loading.value = true
  errorMsg.value = ''
  try {
    const params = {
      page: currentPage.value,
      search: filters.search,
      role: filters.role,
      active: filters.active
    }
    const { data } = await api.get('/admin/users', { params })

    users.value = Array.isArray(data?.data) ? data.data : []
    currentPage.value = data?.current_page || 1
    lastPage.value = data?.last_page || 1
    total.value = data?.total || 0
    from.value = data?.from || 0
    to.value = data?.to || 0

    if (users.value.length === 0 && (filters.search || filters.role || filters.active)) {
      showToast('No se encontraron usuarios con esos filtros', 'info')
    }
  } catch (e) {
    console.error('[fetchUsers] error', e)
    errorMsg.value = 'No se pudieron cargar los usuarios.'
    users.value = []
    showToast('Error al cargar usuarios', 'error')
  } finally {
    loading.value = false
  }
}

const debouncedSearch = debounce(fetchUsers, 300)

const resetFilters = () => {
  Object.assign(filters, { search: '', role: '', active: '' })
  currentPage.value = 1
  fetchUsers()
  showToast('Filtros restablecidos', 'info')
}

const goToPage = page => {
  if (page < 1 || page > lastPage.value) return
  currentPage.value = page
  fetchUsers()
}

// ✅ Corregido: openModal con getImageUrl
const openModal = (user) => {
  form.value = { ...user }
  preview.value = user?.avatar_url ? getImageUrlHelper(user.avatar_url) : null
  modalOpen.value = true
}

const onFileChange = e => {
  file.value = e.target.files[0]
  if (file.value) {
    preview.value = URL.createObjectURL(file.value)
  }
}

const submitModal = async () => {
  try {
    const fd = new FormData()
    Object.keys(form.value).forEach(k => fd.append(k, form.value[k]))
    if (file.value) fd.append('avatar', file.value)

    await api.post(`/admin/users.php?id=${form.value.id}`, fd, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })

    modalOpen.value = false
    fetchUsers()
    showToast('Usuario actualizado exitosamente', 'success')
  } catch (error) {
    console.error('Error al actualizar usuario:', error)
    showToast('Error al actualizar el usuario', 'error')
  }
}

const deleteUser = async id => {
  if (!confirm('¿Estás seguro de eliminar este usuario? Esta acción no se puede deshacer.')) return

  try {
    await api.delete(`/admin/users.php?id=${id}`)
    fetchUsers()
    showToast('Usuario eliminado exitosamente', 'success')
  } catch (error) {
    console.error('Error al eliminar usuario:', error)
    showToast('Error al eliminar el usuario', 'error')
  }
}

// ✅ Corregido: avatarUrl con getImageUrl
const avatarUrl = (name) => {
  if (!name) return '/img/default-avatar.png'
  if (name.startsWith('http')) return name
  return getImageUrlHelper(name, 'avatars')
}
onMounted(fetchUsers)
</script>

<style scoped>
.admin-users-page {
  max-width: 1400px;
  margin: 0 auto;
  padding: 24px;
  min-height: 100vh;
  background: linear-gradient(135deg, #f5f7fa 0%, #f0f4f8 100%);
}

/* Header */
.header {
  margin-bottom: 40px;
}

.title-section h1 {
  font-size: 2.5rem;
  color: #2d3436;
  margin-bottom: 8px;
  display: flex;
  align-items: center;
  gap: 12px;
}

.admin-icon {
  font-size: 2.2rem;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.1); }
}

.title-section p {
  color: #636e72;
  font-size: 1.1rem;
}

/* Stats Section */
.stats-section {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 20px;
  margin-bottom: 32px;
}

.stat-card {
  background: white;
  padding: 24px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  gap: 20px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
  transition: transform 0.3s;
  cursor: default;
}

.stat-card:hover {
  transform: translateY(-5px);
}

.stat-icon {
  font-size: 2.2rem;
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 12px;
  color: white;
}

.stat-icon.total {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.stat-icon.clients {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
}

.stat-icon.providers {
  background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
}

.stat-icon.drivers {
  background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
}

.stat-content h3 {
  font-size: 2rem;
  color: #2d3436;
  margin-bottom: 4px;
}

.stat-content p {
  color: #636e72;
  font-size: 0.9rem;
}

/* Filters Section */
.filters-section {
  background: white;
  padding: 24px;
  border-radius: 16px;
  margin-bottom: 32px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
}

.filter-group {
  margin-bottom: 20px;
}

.filter-group label {
  display: block;
  font-weight: 600;
  color: #2d3436;
  margin-bottom: 8px;
  font-size: 0.9rem;
}

.search-input {
  position: relative;
  display: flex;
  align-items: center;
}

.search-icon {
  position: absolute;
  left: 16px;
  font-size: 1.2rem;
  color: #636e72;
}

.search-input input {
  width: 100%;
  padding: 14px 16px 14px 48px;
  border: 2px solid #dfe6e9;
  border-radius: 12px;
  font-size: 1rem;
  transition: all 0.3s;
  background: white;
}

.search-input input:focus {
  outline: none;
  border-color: #3498db;
  box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
}

.filter-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
  align-items: end;
}

.filter-row select {
  width: 100%;
  padding: 12px;
  border: 2px solid #dfe6e9;
  border-radius: 8px;
  font-size: 1rem;
  transition: border-color 0.3s;
  background: white;
}

.filter-row select:focus {
  outline: none;
  border-color: #3498db;
}

.btn-clear-filters {
  background: #dfe6e9;
  color: #2d3436;
  border: none;
  padding: 12px 20px;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s;
  height: fit-content;
}

.btn-clear-filters:hover {
  background: #b2bec3;
}

.clear-icon {
  font-size: 1.1rem;
}

/* Loading State */
.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 300px;
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
}

.spinner {
  width: 60px;
  height: 60px;
  border: 4px solid rgba(52, 152, 219, 0.2);
  border-top: 4px solid #3498db;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 20px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* Error State */
.error-state {
  text-align: center;
  padding: 60px 20px;
  background: white;
  border-radius: 20px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
  margin: 20px 0;
}

.error-icon {
  font-size: 64px;
  margin-bottom: 24px;
  animation: shake 0.5s ease-in-out;
}

@keyframes shake {
  0%, 100% { transform: translateX(0); }
  25% { transform: translateX(-10px); }
  75% { transform: translateX(10px); }
}

.error-state h3 {
  color: #2d3436;
  margin-bottom: 12px;
  font-size: 1.5rem;
}

.error-state p {
  color: #e74c3c;
  margin-bottom: 24px;
  max-width: 400px;
  margin-left: auto;
  margin-right: auto;
}

.btn-retry {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 12px 32px;
  border-radius: 10px;
  cursor: pointer;
  font-weight: 600;
  transition: transform 0.3s, box-shadow 0.3s;
}

.btn-retry:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
}

/* Users Table Container */
.users-table-container {
  background: white;
  border-radius: 20px;
  overflow: hidden;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
}

.table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px;
  border-bottom: 1px solid #f1f2f6;
  background: #f8f9fa;
}

.table-info {
  color: #636e72;
  font-size: 0.95rem;
}

.table-info strong {
  color: #2d3436;
}

.table-actions {
  display: flex;
  gap: 12px;
}

.btn-export {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s;
}

.btn-export:hover {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(79, 172, 254, 0.3);
}

/* Users Grid */
.users-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 24px;
  padding: 24px;
}

.user-card {
  background: white;
  border-radius: 16px;
  padding: 20px;
  position: relative;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
  transition: all 0.4s;
  border: 2px solid transparent;
}

.user-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 15px 35px rgba(0, 0, 0, 0.15);
}

.user-card.client {
  border-color: rgba(79, 172, 254, 0.3);
}

.user-card.provider {
  border-color: rgba(67, 233, 123, 0.3);
}

.user-card.driver {
  border-color: rgba(250, 112, 154, 0.3);
}

.card-badge {
  position: absolute;
  top: 16px;
  right: 16px;
  padding: 6px 16px;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
  color: white;
  z-index: 2;
}

.card-badge.client {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
}

.card-badge.provider {
  background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
}

.card-badge.driver {
  background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
}

/* User Header */
.user-header {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 20px;
}

.avatar-container {
  position: relative;
}

.user-avatar {
  width: 70px;
  height: 70px;
  border-radius: 50%;
  object-fit: cover;
  border: 3px solid #f1f2f6;
}

.status-indicator {
  position: absolute;
  bottom: 5px;
  right: 5px;
  width: 14px;
  height: 14px;
  border-radius: 50%;
  background: #e74c3c;
  border: 2px solid white;
}

.status-indicator.active {
  background: #2ecc71;
}

.user-info {
  flex: 1;
}

.user-name {
  font-size: 1.3rem;
  color: #2d3436;
  margin-bottom: 4px;
  font-weight: 600;
}

.user-email {
  color: #636e72;
  font-size: 0.9rem;
  word-break: break-all;
}

/* User Details */
.user-details {
  margin-bottom: 20px;
}

.detail-item {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 10px;
  padding: 8px 0;
  border-bottom: 1px solid #f8f9fa;
}

.detail-item:last-child {
  border-bottom: none;
}

.detail-icon {
  font-size: 1.1rem;
  min-width: 24px;
  text-align: center;
}

.detail-text {
  color: #636e72;
  font-size: 0.9rem;
  line-height: 1.4;
}

/* Card Actions */
.card-actions {
  display: flex;
  gap: 10px;
  margin-top: 20px;
}

.card-actions button {
  flex: 1;
  padding: 10px;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  font-size: 0.9rem;
  transition: all 0.3s;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.btn-edit {
  background: #3498db;
  color: white;
}

.btn-edit:hover {
  background: #2980b9;
  transform: translateY(-2px);
}

.btn-delete {
  background: #e74c3c;
  color: white;
}

.btn-delete:hover {
  background: #c0392b;
  transform: translateY(-2px);
}

.btn-icon {
  font-size: 1.1rem;
}

/* Pagination */
.pagination {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px;
  border-top: 1px solid #f1f2f6;
  background: #f8f9fa;
}

.pagination-info {
  color: #636e72;
  font-size: 0.95rem;
}

.pagination-buttons {
  display: flex;
  gap: 8px;
}

.pagination-btn {
  padding: 10px 16px;
  border: 2px solid #dfe6e9;
  background: white;
  color: #2d3436;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s;
  min-width: 44px;
}

.pagination-btn:hover:not(:disabled) {
  border-color: #3498db;
  color: #3498db;
  transform: translateY(-2px);
}

.pagination-btn.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-color: transparent;
}

.pagination-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Empty State */
.empty-state {
  text-align: center;
  padding: 80px 20px;
  background: white;
  border-radius: 20px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
  margin: 40px 0;
}

.empty-icon {
  font-size: 80px;
  margin-bottom: 24px;
  opacity: 0.7;
}

.empty-state h3 {
  color: #2d3436;
  margin-bottom: 12px;
  font-size: 1.8rem;
}

.empty-state p {
  color: #636e72;
  font-size: 1.1rem;
  margin-bottom: 32px;
  max-width: 400px;
  margin-left: auto;
  margin-right: auto;
}

.btn-clear-all {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 14px 32px;
  border-radius: 10px;
  cursor: pointer;
  font-weight: 600;
  transition: transform 0.3s, box-shadow 0.3s;
}

.btn-clear-all:hover {
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
  animation: fadeIn 0.3s ease-out;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

.modal {
  background: white;
  border-radius: 24px;
  width: 90%;
  max-width: 800px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 25px 50px rgba(0, 0, 0, 0.3);
  animation: slideUp 0.3s ease-out;
}

@keyframes slideUp {
  from {
    transform: translateY(30px);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px;
  border-bottom: 1px solid #f1f2f6;
}

.modal-header h2 {
  font-size: 1.8rem;
  color: #2d3436;
  display: flex;
  align-items: center;
  gap: 12px;
}

.modal-icon {
  font-size: 1.5rem;
}

.modal-close {
  background: none;
  border: none;
  font-size: 1.5rem;
  color: #636e72;
  cursor: pointer;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s;
}

.modal-close:hover {
  background: #f1f2f6;
  color: #2d3436;
}

.modal-form {
  padding: 24px;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-group.full-width {
  grid-column: 1 / -1;
}

.form-group label {
  font-weight: 600;
  color: #2d3436;
  font-size: 0.95rem;
}

.form-group input,
.form-group select {
  padding: 12px;
  border: 2px solid #dfe6e9;
  border-radius: 8px;
  font-size: 1rem;
  transition: all 0.3s;
  background: white;
}

.form-group input:focus,
.form-group select:focus {
  outline: none;
  border-color: #3498db;
  box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
}

/* Avatar Upload */
.avatar-upload {
  display: flex;
  gap: 24px;
  align-items: flex-start;
}

.avatar-preview {
  flex-shrink: 0;
}

.avatar-preview-img {
  width: 100px;
  height: 100px;
  border-radius: 50%;
  object-fit: cover;
  border: 3px solid #f1f2f6;
}

.avatar-upload-controls {
  flex: 1;
}

.btn-upload {
  display: inline-block;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 12px 24px;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s;
  margin-bottom: 12px;
}

.btn-upload:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
}

.avatar-file-input {
  display: none;
}

.upload-hint {
  color: #636e72;
  font-size: 0.85rem;
  margin-top: 8px;
}

/* Modal Actions */
.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 16px;
  margin-top: 32px;
  padding-top: 24px;
  border-top: 1px solid #f1f2f6;
}

.btn-cancel {
  background: #dfe6e9;
  color: #2d3436;
  border: none;
  padding: 12px 32px;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s;
}

.btn-cancel:hover {
  background: #b2bec3;
}

.btn-save {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 12px 32px;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s;
  display: flex;
  align-items: center;
  gap: 8px;
  min-width: 160px;
  justify-content: center;
}

.btn-save:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
}

.btn-save:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.save-spinner {
  width: 20px;
  height: 20px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top: 2px solid white;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

/* Toast Notification */
.toast {
  position: fixed;
  bottom: 24px;
  right: 24px;
  padding: 16px 24px;
  border-radius: 12px;
  color: white;
  font-weight: 600;
  z-index: 1001;
  animation: slideInRight 0.3s ease-out;
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.2);
  min-width: 300px;
  max-width: 400px;
}

@keyframes slideInRight {
  from {
    transform: translateX(100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
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

/* Responsive Design */
@media (max-width: 1200px) {
  .users-grid {
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  }
}

@media (max-width: 768px) {
  .admin-users-page {
    padding: 16px;
  }
  
  .title-section h1 {
    font-size: 2rem;
  }
  
  .stats-section {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .filter-row {
    grid-template-columns: 1fr;
  }
  
  .users-grid {
    grid-template-columns: 1fr;
    padding: 16px;
  }
  
  .table-header {
    flex-direction: column;
    gap: 16px;
    align-items: stretch;
  }
  
  .pagination {
    flex-direction: column;
    gap: 20px;
    align-items: stretch;
  }
  
  .pagination-buttons {
    justify-content: center;
    flex-wrap: wrap;
  }
  
  .modal {
    width: 95%;
    margin: 10px;
  }
  
  .avatar-upload {
    flex-direction: column;
    align-items: center;
  }
  
  .form-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 480px) {
  .stats-section {
    grid-template-columns: 1fr;
  }
  
  .card-actions {
    flex-direction: column;
  }
  
  .modal-actions {
    flex-direction: column;
  }
  
  .modal-header h2 {
    font-size: 1.5rem;
  }
  
  .toast {
    left: 16px;
    right: 16px;
    min-width: auto;
  }
}
</style>
