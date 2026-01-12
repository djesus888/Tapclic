<template>
  <div class="admin-services">
    <h2>Gestión de Servicios</h2>

    <!-- Filtros / Buscador -->
    <section class="filters">
      <input
        v-model="filters.search"
        placeholder="Buscar por título o descripción"
        @input="debouncedSearch"
      >
      <select
        v-model="filters.status"
        @change="fetchServices"
      >
        <option value="">
          Todos los estados
        </option>
        <option value="pending">
          Pendiente
        </option>
        <option value="active">
          Activo
        </option>
        <option value="inactive">
          Inactivo
        </option>
        <option value="completed">
          Completado
        </option>
      </select>
    </section>

    <!-- Tabla desktop / cards mobile -->
    <div class="table-wrapper">
      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>Título</th>
            <th>Proveedor</th>
            <th class="hide-sm">
              Categoría
            </th>
            <th class="hide-sm">
              Precio
            </th>
            <th class="hide-sm">
              Ubicación
            </th>
            <th>Estado</th>
            <th class="hide-sm">
              Rating
            </th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="s in services"
            :key="s.id"
          >
            <td data-label="ID">
              {{ s.id }}
            </td>
            <td data-label="Título">
              {{ s.title }}
            </td>
            <td data-label="Proveedor">
              {{ s.provider_name }}
            </td>
            <td
              data-label="Categoría"
              class="hide-sm"
            >
              {{ s.category }}
            </td>
            <td
              data-label="Precio"
              class="hide-sm"
            >
              ${{ s.price }}
            </td>
            <td
              data-label="Ubicación"
              class="hide-sm"
            >
              {{ s.location }}
            </td>
            <td data-label="Estado">
              <span :class="['badge', s.status]">{{ s.status }}</span>
            </td>
            <td
              data-label="Rating"
              class="hide-sm"
            >
              {{ s.provider_rating }}
            </td>
            <td class="actions-cell">
              <button
                class="btn-icon"
                title="Editar"
                @click="openEditModal(s)"
              >
                ✏️
              </button>
              <button
                v-if="s.status !== 'inactive'"
                class="btn-icon suspend"
                title="Suspender"
                @click="toggleSuspend(s)"
              >
                ⏸️
              </button>
              <button
                v-else
                class="btn-icon activate"
                title="Activar"
                @click="toggleSuspend(s)"
              >
                ▶️
              </button>
              <button
                class="btn-icon delete"
                title="Eliminar"
                @click="remove(s)"
              >
                🗑️
              </button>
            </td>
          </tr>
          <tr v-if="services.length === 0">
            <td
              colspan="9"
              class="empty"
            >
              Sin servicios
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Modal edición -->
    <Teleport to="body">
      <div
        v-if="showModal"
        class="modal-backdrop"
        @click.self="closeModal"
      >
        <div class="modal">
          <h3>Editar servicio #{{ form.id }}</h3>
          <form @submit.prevent="save">
            <!-- IMAGEN -->
            <label
              v-if="form.image_url"
              class="image-label"
            >
              Imagen actual
              <img
                :src="form.image_url"
                alt="Imagen del servicio"
                class="preview-img"
              >
            </label>

            <label>
              Título
              <input
                v-model="form.title"
                required
              >
            </label>
            <label>
              Descripción
              <textarea
                v-model="form.description"
                rows="3"
              />
            </label>
            <label>
              Categoría
              <input v-model="form.category">
            </label>
            <label>
              Precio
              <input
                v-model.number="form.price"
                type="number"
                min="0"
                required
              >
            </label>
            <label>
              Ubicación
              <input v-model="form.location">
            </label>
            <label>
              Estado
              <select v-model="form.status">
                <option value="pending">Pendiente</option>
                <option value="active">Activo</option>
                <option value="inactive">Inactivo</option>
                <option value="completed">Completado</option>
              </select>
            </label>
            <label>
              Rating proveedor
              <input
                v-model.number="form.provider_rating"
                type="number"
                step="0.1"
                min="0"
                max="5"
              >
            </label>
            <div class="modal-actions">
              <button
                type="submit"
                class="btn primary"
              >
                Guardar
              </button>
              <button
                type="button"
                class="btn secondary"
                @click="closeModal"
              >
                Cancelar
              </button>
            </div>
          </form>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
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
  if (!confirm(`¿Eliminar el servicio "${srv.title}"?`)) return
  try {
    await api.delete('/admin/services/delete', { data: { id: srv.id } })
    fetchServices()
  } catch (e) {
    alert('Error al eliminar')
  }
}

/* ---------- ciclo ---------- */
onMounted(() => fetchServices())
</script>

<style scoped>
/* ---------- base ---------- */
.admin-services {
  padding: 0.5rem;
  font-family: system-ui, sans-serif;
}
h2 {
  margin-bottom: 0.75rem;
  font-size: 1.1rem;
}

/* ---------- filtros ---------- */
.filters {
  display: flex;
  flex-wrap: wrap;
  gap: 0.4rem;
  margin-bottom: 0.75rem;
}
.filters input,
.filters select {
  flex: 1 1 160px;
  padding: 0.4rem;
  font-size: 0.85rem;
}

/* ---------- tabla / cards ---------- */
.table-wrapper {
  overflow-x: auto;
}
table {
  width: 100%;
  border-collapse: collapse;
  min-width: 600px;
}
th,
td {
  padding: 0.4rem 0.3rem;
  border: 1px solid #ddd;
  text-align: left;
  font-size: 0.8rem;
}
th {
  background: #f5f5f5;
}
.empty {
  text-align: center;
  color: #888;
}

/* ---------- badges ---------- */
.badge {
  padding: 0.15rem 0.3rem;
  border-radius: 3px;
  font-size: 0.65rem;
  color: #fff;
}
.badge.pending {
  background: #f59e0b;
}
.badge.active {
  background: #10b981;
}
.badge.inactive {
  background: #6b7280;
}
.badge.completed {
  background: #3b82f6;
}

/* ---------- botones ---------- */
.actions-cell {
  white-space: nowrap;
}
.btn-icon {
  background: #fff;
  border: 1px solid #ccc;
  border-radius: 4px;
  padding: 0.25rem 0.35rem;
  font-size: 0.9rem;
  cursor: pointer;
  margin-right: 0.2rem;
}
.btn-icon.suspend {
  border-color: #ef4444;
  color: #ef4444;
}
.btn-icon.activate {
  border-color: #10b981;
  color: #10b981;
}
.btn-icon.delete {
  border-color: #7c2d12;
  color: #7c2d12;
}

/* ---------- modal ---------- */
.modal-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  padding: 0.5rem; /* menos margen → modal más arriba */
  overflow-y: auto;
}
.modal {
  background: #fff;
  border-radius: 8px;
  width: 100%;
  max-width: 400px; /* más angosto */
  margin: auto; /* centrado vertical */
  padding: 1rem;
  max-height: 90vh;
  overflow-y: auto;
}
.modal h3 {
  margin: 0 0 0.5rem;
  font-size: 1rem;
}
.modal form label {
  display: block;
  margin-bottom: 0.4rem;
  font-size: 0.8rem;
}
.modal form input,
.modal form textarea,
.modal form select {
  width: 100%;
  padding: 0.4rem;
  margin-top: 0.2rem;
  font-size: 0.8rem;
}
/* imagen */
.image-label {
  margin-bottom: 0.5rem;
}
.preview-img {
  display: block;
  max-width: 100%;
  max-height: 140px;
  object-fit: cover;
  border-radius: 6px;
  margin-top: 0.2rem;
}
.modal-actions {
  margin-top: 0.5rem;
  display: flex;
  gap: 0.4rem;
  justify-content: flex-end;
}
.btn {
  padding: 0.4rem 0.8rem;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.8rem;
}
.btn.primary {
  background: #3b82f6;
  color: #fff;
}
.btn.secondary {
  background: #e5e7eb;
  color: #000;
}

/* ---------- utilidades responsive ---------- */
@media (max-width: 600px) {
  .hide-sm {
    display: none;
  }
  table thead {
    display: none;
  }
  table tr {
    display: block;
    margin-bottom: 0.5rem;
    border: none; /* sin líneas */
    border-radius: 6px;
    padding: 0.4rem;
    background: #fafafa;
  }
  table td {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0.2rem 0; /* datos muy juntos */
    border: none;
    font-size: 0.75rem;
  }
  table td::before {
    content: attr(data-label);
    font-weight: 600;
    margin-right: 0.3rem;
  }
}
</style>
