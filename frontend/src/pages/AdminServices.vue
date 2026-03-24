<template>
  <div class="admin-services-page">
    <!-- Header con título y estadísticas -->
    <div class="header">
      <div class="title-section">
        <h1><span class="admin-icon">👑</span> Gestión de Servicios</h1>
        <p>Administra y gestiona todos los servicios de la plataforma</p>
      </div>
      
      <div class="header-stats">
        <div class="stat-card">
          <div class="stat-icon">📊</div>
          <div class="stat-content">
            <h3>{{ totalServices }}</h3>
            <p>Total Servicios</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Filtros en sección estilo tarjetas -->
    <section class="filters-section">
      <div class="filter-group">
        <label for="search-filter">
          <span class="filter-icon">🔍</span> Buscar servicio
        </label>
        <input
          id="search-filter"
          v-model="filters.search"
          placeholder="Buscar por título o descripción..."
          @input="debouncedSearch"
          class="filter-input"
        >
      </div>
      
      <div class="filter-group">
        <label for="status-filter">
          <span class="filter-icon">📈</span> Estado del servicio
        </label>
        <select
          id="status-filter"
          v-model="filters.status"
          @change="fetchServices"
          class="filter-select"
        >
          <option value="">Todos los estados</option>
          <option value="pending">⏳ Pendiente</option>
          <option value="active">✅ Activo</option>
          <option value="inactive">⏸️ Inactivo</option>
          <option value="completed">🏁 Completado</option>
        </select>
      </div>
    </section>

    <!-- Tabla con diseño moderno -->
    <div class="table-container">
      <div class="table-card">
        <div class="table-header">
          <h3><span class="table-icon">📋</span> Lista de Servicios</h3>
          <div class="table-info">
            Mostrando <strong>{{ services.length }}</strong> servicios
          </div>
        </div>
        
        <div class="table-responsive">
          <table class="styled-table">
            <thead>
              <tr>
                <th>
                  <span class="th-content">ID</span>
                </th>
                <th>
                  <span class="th-content">Título</span>
                </th>
                <th>
                  <span class="th-content">Proveedor</span>
                </th>
                <th class="hide-sm">
                  <span class="th-content">Categoría</span>
                </th>
                <th class="hide-sm">
                  <span class="th-content">Precio</span>
                </th>
                <th class="hide-sm">
                  <span class="th-content">Ubicación</span>
                </th>
                <th>
                  <span class="th-content">Estado</span>
                </th>
                <th class="hide-sm">
                  <span class="th-content">Rating</span>
                </th>
                <th>
                  <span class="th-content">Acciones</span>
                </th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="s in services"
                :key="s.id"
                class="table-row"
              >
                <td data-label="ID" class="id-cell">
                  <span class="cell-badge">#{{ s.id }}</span>
                </td>
                <td data-label="Título" class="title-cell">
                  <div class="service-title">
                    <strong>{{ s.title }}</strong>
                    <span class="service-desc-mobile">{{ truncateText(s.description, 30) }}</span>
                  </div>
                </td>
                <td data-label="Proveedor" class="provider-cell">
                  <div class="provider-info">
                    <span class="provider-avatar">👤</span>
                    <span>{{ s.provider_name }}</span>
                  </div>
                </td>
                <td
                  data-label="Categoría"
                  class="hide-sm category-cell"
                >
                  <span class="category-badge">{{ s.category }}</span>
                </td>
                <td
                  data-label="Precio"
                  class="hide-sm price-cell"
                >
                  <span class="price-tag">${{ s.price }}</span>
                </td>
                <td
                  data-label="Ubicación"
                  class="hide-sm location-cell"
                >
                  <span class="location-tag">📍 {{ s.location }}</span>
                </td>
                <td data-label="Estado" class="status-cell">
                  <span :class="['status-badge', s.status]">
                    {{ getStatusText(s.status) }}
                  </span>
                </td>
                <td
                  data-label="Rating"
                  class="hide-sm rating-cell"
                >
                  <div class="rating-display">
                    <span class="stars">⭐</span>
                    <span class="rating-value">{{ s.provider_rating }}</span>
                  </div>
                </td>
                <td class="actions-cell">
                  <div class="action-buttons">
                    <button
                      class="btn-action edit-btn"
                      title="Editar servicio"
                      @click="openEditModal(s)"
                    >
                      <span class="btn-icon">✏️</span>
                      <span class="btn-text">Editar</span>
                    </button>
                    
                    <button
                      v-if="s.status !== 'inactive'"
                      class="btn-action suspend-btn"
                      title="Suspender servicio"
                      @click="toggleSuspend(s)"
                    >
                      <span class="btn-icon">⏸️</span>
                      <span class="btn-text">Suspender</span>
                    </button>
                    <button
                      v-else
                      class="btn-action activate-btn"
                      title="Activar servicio"
                      @click="toggleSuspend(s)"
                    >
                      <span class="btn-icon">▶️</span>
                      <span class="btn-text">Activar</span>
                    </button>
                    
                    <button
                      class="btn-action delete-btn"
                      title="Eliminar servicio"
                      @click="remove(s)"
                    >
                      <span class="btn-icon">🗑️</span>
                      <span class="btn-text">Eliminar</span>
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="services.length === 0">
                <td colspan="9" class="empty-state-cell">
                  <div class="empty-state">
                    <div class="empty-icon">📭</div>
                    <h4>No hay servicios disponibles</h4>
                    <p>Intenta cambiar los filtros o crear un nuevo servicio</p>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        
        <div class="table-footer" v-if="services.length > 0">
          <div class="footer-info">
            <span class="showing-text">
              Mostrando <strong>{{ services.length }}</strong> de <strong>{{ totalServices }}</strong> servicios
            </span>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal edición - Diseño mejorado -->
    <Teleport to="body">
      <div
        v-if="showModal"
        class="modal-overlay"
        @click.self="closeModal"
      >
        <div class="modal-container">
          <div class="modal-header">
            <h2>✏️ Editar Servicio #{{ form.id }}</h2>
            <button class="modal-close" @click="closeModal">
              ✕
            </button>
          </div>
          
          <div class="modal-content">
            <form @submit.prevent="save" class="modal-form">
              <!-- Imagen actual -->
              <div v-if="form.image_url" class="image-preview-section">
                <label class="form-label">
                  <span class="label-icon">🖼️</span> Imagen actual
                </label>
                <div class="image-preview">
                  <img
                    :src="form.image_url"
                    alt="Imagen del servicio"
                    class="preview-image"
                    @error="handleImageError"
                  >
                </div>
              </div>

              <!-- Campos del formulario -->
              <div class="form-grid">
                <div class="form-group">
                  <label class="form-label">
                    <span class="label-icon">📝</span> Título
                  </label>
                  <input
                    v-model="form.title"
                    required
                    class="form-input"
                    placeholder="Ej: Diseño de Logotipo Profesional"
                  >
                </div>

                <div class="form-group full-width">
                  <label class="form-label">
                    <span class="label-icon">📄</span> Descripción
                  </label>
                  <textarea
                    v-model="form.description"
                    rows="4"
                    class="form-textarea"
                    placeholder="Describe el servicio detalladamente..."
                  />
                </div>

                <div class="form-group">
                  <label class="form-label">
                    <span class="label-icon">🏷️</span> Categoría
                  </label>
                  <input
                    v-model="form.category"
                    class="form-input"
                    placeholder="Ej: Diseño Gráfico"
                  >
                </div>

                <div class="form-group">
                  <label class="form-label">
                    <span class="label-icon">💰</span> Precio
                  </label>
                  <div class="input-with-symbol">
                    <span class="input-symbol">$</span>
                    <input
                      v-model.number="form.price"
                      type="number"
                      min="0"
                      required
                      class="form-input with-symbol"
                      placeholder="0.00"
                    >
                  </div>
                </div>

                <div class="form-group">
                  <label class="form-label">
                    <span class="label-icon">📍</span> Ubicación
                  </label>
                  <input
                    v-model="form.location"
                    class="form-input"
                    placeholder="Ej: Ciudad, País"
                  >
                </div>

                <div class="form-group">
                  <label class="form-label">
                    <span class="label-icon">📊</span> Estado
                  </label>
                  <select v-model="form.status" class="form-select">
                    <option value="pending">⏳ Pendiente</option>
                    <option value="active">✅ Activo</option>
                    <option value="inactive">⏸️ Inactivo</option>
                    <option value="completed">🏁 Completado</option>
                  </select>
                </div>

                <div class="form-group">
                  <label class="form-label">
                    <span class="label-icon">⭐</span> Rating del Proveedor
                  </label>
                  <div class="rating-input-group">
                    <input
                      v-model.number="form.provider_rating"
                      type="number"
                      step="0.1"
                      min="0"
                      max="5"
                      class="form-input"
                      placeholder="0.0 - 5.0"
                    >
                    <div class="rating-display-small">
                      <span class="stars-small">⭐⭐⭐⭐⭐</span>
                      <span class="rating-value-small">{{ form.provider_rating || 0 }}/5</span>
                    </div>
                  </div>
                </div>
              </div>

              <div class="modal-actions">
                <button
                  type="submit"
                  class="btn-modal btn-save"
                >
                  <span class="btn-icon">💾</span>
                  Guardar Cambios
                </button>
                <button
                  type="button"
                  class="btn-modal btn-cancel"
                  @click="closeModal"
                >
                  <span class="btn-icon">✕</span>
                  Cancelar
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import api from '@/axios'

/* ---------- datos ---------- */
const services = ref([])
const showModal = ref(false)
const form = reactive({
  id: null,
  title: '',
  description: '',
  category: '',
  price: 0,
  location: '',
  status: 'pending',
  provider_rating: 5,
  image_url: ''
})

const filters = reactive({
  search: '',
  status: ''
})

let searchTimeout = null
const debouncedSearch = () => {
  clearTimeout(searchTimeout)
  searchTimeout = setTimeout(() => fetchServices(), 300)
}

/* ---------- métodos ---------- */
const fetchServices = async () => {
  try {
    const { data } = await api.get('/admin/services', {
      params: { search: filters.search, status: filters.status }
    })
    services.value = data.services || data
  } catch (e) {
    alert('Error al cargar servicios')
    console.error(e)
  }
}

const openEditModal = (srv) => {
  Object.assign(form, { ...srv })
  showModal.value = true
}

const closeModal = () => (showModal.value = false)

const save = async () => {
  try {
    await api.put('/admin/services/update', form)
    closeModal()
    fetchServices()
  } catch (e) {
    alert('Error al guardar')
    console.error(e)
  }
}

const toggleSuspend = async (srv) => {
  const newStatus = srv.status === 'inactive' ? 'active' : 'inactive'
  try {
    await api.put('/admin/services/update', { id: srv.id, status: newStatus })
    fetchServices()
  } catch (e) {
    alert('Error al cambiar estado')
  }
}

const remove = async (srv) => {
  if (!confirm(`¿Eliminar el servicio "${srv.title}"? Esta acción no se puede deshacer.`)) return
  try {
    await api.delete('/admin/services/delete', { data: { id: srv.id } })
    fetchServices()
  } catch (e) {
    alert('Error al eliminar')
  }
}

/* ---------- métodos helper ---------- */
const getStatusText = (status) => {
  const statusMap = {
    'pending': 'Pendiente',
    'active': 'Activo',
    'inactive': 'Inactivo',
    'completed': 'Completado'
  }
  return statusMap[status] || status
}

const truncateText = (text, length) => {
  if (!text) return ''
  return text.length > length ? text.substring(0, length) + '...' : text
}

const handleImageError = (event) => {
  event.target.src = 'https://via.placeholder.com/400x200?text=Imagen+No+Disponible'
}

/* ---------- computed ---------- */
const totalServices = computed(() => {
  return services.value.length
})

/* ---------- ciclo ---------- */
onMounted(() => fetchServices())
</script>

<style scoped>
/* ---------- Estilos Generales ---------- */
.admin-services-page {
  max-width: 1400px;
  margin: 0 auto;
  padding: 24px;
  min-height: 100vh;
  background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
}

/* ---------- Header ---------- */
.header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 32px;
  flex-wrap: wrap;
  gap: 20px;
}

.title-section h1 {
  font-size: 2.5rem;
  color: #1e293b;
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
  color: #64748b;
  font-size: 1.1rem;
  max-width: 600px;
}

.header-stats {
  display: flex;
  gap: 16px;
}

.stat-card {
  background: white;
  padding: 20px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  gap: 16px;
  min-width: 180px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
  border: 1px solid #e2e8f0;
}

.stat-icon {
  font-size: 2.2rem;
  width: 56px;
  height: 56px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
  border-radius: 12px;
  color: white;
}

.stat-content h3 {
  font-size: 1.8rem;
  color: #1e293b;
  margin-bottom: 4px;
  font-weight: 700;
}

.stat-content p {
  color: #64748b;
  font-size: 0.9rem;
  font-weight: 500;
}

/* ---------- Filtros ---------- */
.filters-section {
  background: white;
  padding: 24px;
  border-radius: 16px;
  margin-bottom: 32px;
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 24px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
  border: 1px solid #e2e8f0;
}

.filter-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.filter-group label {
  font-weight: 600;
  color: #334155;
  font-size: 0.9rem;
  display: flex;
  align-items: center;
  gap: 8px;
}

.filter-icon {
  font-size: 1.1rem;
}

.filter-input,
.filter-select {
  padding: 12px 16px;
  border: 2px solid #e2e8f0;
  border-radius: 10px;
  font-size: 1rem;
  transition: all 0.3s;
  background: white;
}

.filter-input:focus,
.filter-select:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.filter-input::placeholder {
  color: #94a3b8;
}

/* ---------- Tabla ---------- */
.table-container {
  background: white;
  border-radius: 20px;
  overflow: hidden;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
  border: 1px solid #e2e8f0;
  margin-bottom: 40px;
}

.table-header {
  padding: 24px;
  border-bottom: 1px solid #e2e8f0;
  background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.table-header h3 {
  color: #1e293b;
  font-size: 1.5rem;
  display: flex;
  align-items: center;
  gap: 10px;
}

.table-icon {
  font-size: 1.3rem;
}

.table-info {
  color: #64748b;
  font-size: 0.9rem;
}

.table-responsive {
  overflow-x: auto;
}

.styled-table {
  width: 100%;
  min-width: 1000px;
  border-collapse: collapse;
}

.styled-table thead {
  background: #f8fafc;
}

.styled-table th {
  padding: 16px 20px;
  text-align: left;
  font-weight: 600;
  color: #475569;
  font-size: 0.9rem;
  border-bottom: 2px solid #e2e8f0;
}

.th-content {
  display: flex;
  align-items: center;
  gap: 8px;
}

.styled-table td {
  padding: 16px 20px;
  border-bottom: 1px solid #f1f5f9;
  vertical-align: middle;
}

.table-row:hover {
  background: #f8fafc;
}

/* ---------- Celdas Especiales ---------- */
.id-cell .cell-badge {
  background: #f1f5f9;
  color: #475569;
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
}

.service-title {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.service-title strong {
  color: #1e293b;
  font-size: 1rem;
}

.service-desc-mobile {
  color: #64748b;
  font-size: 0.8rem;
  display: none;
}

.provider-info {
  display: flex;
  align-items: center;
  gap: 10px;
}

.provider-avatar {
  width: 32px;
  height: 32px;
  background: #dbeafe;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #1d4ed8;
}

.category-badge {
  background: #dbeafe;
  color: #1d4ed8;
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
  display: inline-block;
}

.price-tag {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: white;
  padding: 8px 16px;
  border-radius: 10px;
  font-weight: 700;
  font-size: 0.9rem;
  display: inline-block;
}

.location-tag {
  color: #475569;
  font-size: 0.9rem;
  display: flex;
  align-items: center;
  gap: 6px;
}

.status-badge {
  padding: 8px 16px;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
  display: inline-block;
  text-transform: capitalize;
}

.status-badge.pending {
  background: linear-gradient(135deg, #fbbf24 0%, #f59e0b 100%);
  color: white;
}

.status-badge.active {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: white;
}

.status-badge.inactive {
  background: linear-gradient(135deg, #6b7280 0%, #4b5563 100%);
  color: white;
}

.status-badge.completed {
  background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
  color: white;
}

.rating-display {
  display: flex;
  align-items: center;
  gap: 8px;
}

.stars {
  color: #fbbf24;
  font-size: 1rem;
}

.rating-value {
  font-weight: 700;
  color: #475569;
}

/* ---------- Botones de Acción ---------- */
.action-buttons {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.btn-action {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 12px;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-size: 0.85rem;
  font-weight: 600;
  transition: all 0.3s;
  white-space: nowrap;
}

.btn-icon {
  font-size: 0.9rem;
}

.btn-text {
  display: inline;
}

.edit-btn {
  background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
  color: white;
}

.edit-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
}

.suspend-btn {
  background: linear-gradient(135deg, #f97316 0%, #ea580c 100%);
  color: white;
}

.suspend-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(249, 115, 22, 0.3);
}

.activate-btn {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: white;
}

.activate-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
}

.delete-btn {
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
  color: white;
}

.delete-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
}

/* ---------- Estado Vacío ---------- */
.empty-state-cell {
  padding: 0 !important;
}

.empty-state {
  text-align: center;
  padding: 60px 20px;
  background: #f8fafc;
}

.empty-icon {
  font-size: 64px;
  margin-bottom: 20px;
  opacity: 0.5;
}

.empty-state h4 {
  color: #475569;
  margin-bottom: 8px;
  font-size: 1.2rem;
}

.empty-state p {
  color: #94a3b8;
  max-width: 400px;
  margin: 0 auto;
}

/* ---------- Footer de la Tabla ---------- */
.table-footer {
  padding: 20px 24px;
  border-top: 1px solid #e2e8f0;
  background: #f8fafc;
}

.footer-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.showing-text {
  color: #64748b;
  font-size: 0.9rem;
}

/* ---------- Modal ---------- */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 20px;
  backdrop-filter: blur(4px);
}

.modal-container {
  background: white;
  border-radius: 24px;
  width: 100%;
  max-width: 800px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
  animation: modalSlideIn 0.3s ease-out;
}

@keyframes modalSlideIn {
  from {
    opacity: 0;
    transform: translateY(-20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.modal-header {
  padding: 24px 32px;
  border-bottom: 1px solid #e2e8f0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
  border-radius: 24px 24px 0 0;
}

.modal-header h2 {
  color: #1e293b;
  font-size: 1.8rem;
  display: flex;
  align-items: center;
  gap: 12px;
}

.modal-close {
  background: none;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  color: #64748b;
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  transition: all 0.3s;
}

.modal-close:hover {
  background: #f1f5f9;
  color: #1e293b;
}

.modal-content {
  padding: 32px;
}

/* ---------- Formulario Modal ---------- */
.modal-form {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.image-preview-section {
  margin-bottom: 16px;
}

.image-preview {
  margin-top: 12px;
}

.preview-image {
  width: 100%;
  max-height: 300px;
  object-fit: cover;
  border-radius: 12px;
  border: 2px solid #e2e8f0;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
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

.form-label {
  font-weight: 600;
  color: #334155;
  font-size: 0.9rem;
  display: flex;
  align-items: center;
  gap: 8px;
}

.label-icon {
  font-size: 1.1rem;
}

.form-input,
.form-textarea,
.form-select {
  padding: 12px 16px;
  border: 2px solid #e2e8f0;
  border-radius: 10px;
  font-size: 1rem;
  transition: all 0.3s;
  background: white;
}

.form-input:focus,
.form-textarea:focus,
.form-select:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.form-textarea {
  resize: vertical;
  min-height: 100px;
}

.input-with-symbol {
  position: relative;
}

.input-symbol {
  position: absolute;
  left: 16px;
  top: 50%;
  transform: translateY(-50%);
  color: #64748b;
  font-weight: 600;
}

.form-input.with-symbol {
  padding-left: 36px;
}

.rating-input-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.rating-display-small {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  background: #fef3c7;
  border-radius: 8px;
  border: 1px solid #fde68a;
}

.stars-small {
  color: #fbbf24;
  font-size: 0.9rem;
}

.rating-value-small {
  font-weight: 700;
  color: #92400e;
  font-size: 0.9rem;
}

/* ---------- Botones Modal ---------- */
.modal-actions {
  display: flex;
  gap: 16px;
  justify-content: flex-end;
  margin-top: 24px;
  padding-top: 24px;
  border-top: 1px solid #e2e8f0;
}

.btn-modal {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 14px 28px;
  border: none;
  border-radius: 12px;
  cursor: pointer;
  font-weight: 600;
  font-size: 1rem;
  transition: all 0.3s;
}

.btn-save {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: white;
}

.btn-save:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 20px rgba(16, 185, 129, 0.3);
}

.btn-cancel {
  background: #f1f5f9;
  color: #475569;
}

.btn-cancel:hover {
  background: #e2e8f0;
  transform: translateY(-2px);
}

/* ---------- Responsive ---------- */
@media (max-width: 1200px) {
  .header {
    flex-direction: column;
  }
  
  .form-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .admin-services-page {
    padding: 16px;
  }
  
  .title-section h1 {
    font-size: 2rem;
  }
  
  .header-stats {
    width: 100%;
  }
  
  .stat-card {
    flex: 1;
    min-width: auto;
  }
  
  .filters-section {
    grid-template-columns: 1fr;
    padding: 20px;
  }
  
  .table-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }
  
  .styled-table {
    min-width: 700px;
  }
  
  .btn-text {
    display: none;
  }
  
  .btn-action {
    padding: 8px;
  }
  
  .modal-container {
    margin: 20px;
    max-height: calc(100vh - 40px);
  }
  
  .modal-header {
    padding: 20px;
  }
  
  .modal-content {
    padding: 20px;
  }
}

@media (max-width: 640px) {
  .title-section h1 {
    font-size: 1.8rem;
  }
  
  .table-header h3 {
    font-size: 1.3rem;
  }
  
  .action-buttons {
    flex-direction: column;
    gap: 6px;
  }
  
  .btn-action {
    width: 100%;
    justify-content: center;
  }
  
  .service-desc-mobile {
    display: block;
  }
  
  .btn-modal {
    width: 100%;
    justify-content: center;
  }
  
  .modal-actions {
    flex-direction: column;
  }
}

@media (max-width: 600px) {
  .hide-sm {
    display: none !important;
  }
  
  .styled-table {
    min-width: 500px;
  }
  
  .styled-table thead {
    display: none;
  }
  
  .styled-table tr {
    display: block;
    margin-bottom: 16px;
    background: white;
    border-radius: 12px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
    border: 1px solid #e2e8f0;
    overflow: hidden;
  }
  
  .styled-table td {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 12px 16px;
    border-bottom: 1px solid #f1f5f9;
  }
  
  .styled-table td:last-child {
    border-bottom: none;
  }
  
  .styled-table td::before {
    content: attr(data-label);
    font-weight: 600;
    color: #475569;
    margin-right: 16px;
    flex-shrink: 0;
    font-size: 0.9rem;
  }
  
  .id-cell,
  .title-cell,
  .provider-cell,
  .status-cell,
  .actions-cell {
    display: flex !important;
  }
  
  .action-buttons {
    flex-direction: row;
    justify-content: flex-end;
    width: 100%;
  }
  
  .empty-state {
    padding: 40px 20px;
  }
}
</style>
