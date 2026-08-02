<template>
  <div class="staff-container">
    <div class="staff-header">
      <div>
        <h1>👥 Mi Personal</h1>
        <p class="subtitle">Gestiona tu equipo de trabajo</p>
      </div>
      <button class="btn-add" @click="showForm = true" v-if="!showForm">
        <span class="btn-icon">+</span> Agregar personal
      </button>
    </div>

    <!-- Formulario para agregar/editar -->
    <transition name="slide">
      <div v-if="showForm" class="staff-form">
        <h3>{{ editing ? '✏️ Editar' : '➕ Nuevo' }} personal</h3>
        <div class="form-grid">
          <div class="form-group">
            <label>Nombre completo *</label>
            <input v-model="form.name" placeholder="Ej: Juan Pérez" class="input" />
          </div>
          <div class="form-group">
            <label>Email</label>
            <input v-model="form.email" type="email" placeholder="correo@ejemplo.com" class="input" />
          </div>
          <div class="form-group">
            <label>Teléfono</label>
            <input v-model="form.phone" placeholder="0412-0000000" class="input" />
          </div>
          <div class="form-group">
            <label>Contraseña {{ editing ? '(dejar vacía para mantener)' : '*' }}</label>
            <input v-model="form.password" type="password" placeholder="••••••••" class="input" />
          </div>
          <div class="form-group">
            <label>Rol</label>
            <select v-model="form.role" class="input">
              <option value="delivery">🛵 Delivery</option>
              <option value="staff">👤 Staff</option>
            </select>
          </div>
        </div>
        <div class="form-actions">
          <button class="btn-save" @click="saveStaff" :disabled="!form.name">
            💾 {{ editing ? 'Actualizar' : 'Guardar' }}
          </button>
          <button class="btn-cancel" @click="resetForm">❌ Cancelar</button>
        </div>
      </div>
    </transition>

    <!-- Loading -->
    <div v-if="loading" class="loading-container">
      <div class="spinner"></div>
      <p>Cargando personal...</p>
    </div>

    <!-- Lista de staff -->
    <div v-else-if="staff.length > 0" class="staff-list">
      <div class="list-header">
        <span>{{ staff.length }} miembro{{ staff.length !== 1 ? 's' : '' }}</span>
      </div>
      <div v-for="s in staff" :key="s.id" class="staff-card">
        <div class="staff-avatar">
          {{ getInitials(s.name) }}
        </div>
        <div class="staff-info">
          <strong>{{ s.name }}</strong>
          <span class="role-badge" :class="s.role">{{ getRoleLabel(s.role) }}</span>
          <p class="contact-info">
            <span v-if="s.email">📧 {{ s.email }}</span>
            <span v-if="s.phone">📱 {{ s.phone }}</span>
            <span v-if="!s.email && !s.phone">Sin información de contacto</span>
          </p>
        </div>
        <div class="staff-actions">
          <button class="btn-edit" @click="editStaff(s)" title="Editar">✏️</button>
          <button class="btn-delete" @click="deleteStaff(s.id)" title="Eliminar">🗑️</button>
        </div>
      </div>
    </div>

    <!-- Empty state -->
    <div v-else class="empty-state">
      <div class="empty-icon">👥</div>
      <h3>No tienes personal registrado</h3>
      <p>Agrega delivery o staff para que te ayuden con los servicios</p>
      <button class="btn-add" @click="showForm = true">+ Agregar primer miembro</button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import api from '@/axios'
import { useAuthStore } from '@/stores/authStore'
import Swal from 'sweetalert2'

const authStore = useAuthStore()
const staff = ref([])
const showForm = ref(false)
const editing = ref(null)
const loading = ref(true)

const form = ref({
  name: '', email: '', phone: '', password: '', role: 'delivery'
})

const fetchStaff = async () => {
  loading.value = true
  try {
    const { data } = await api.get('/provider/staff')
    staff.value = data.staff || []
  } catch (e) {
    Swal.fire({ icon: 'error', title: 'Error', text: 'No se pudo cargar el personal', toast: true, position: 'top-end', showConfirmButton: false, timer: 3000 })
  } finally {
    loading.value = false
  }
}

const saveStaff = async () => {
  if (!form.value.name.trim()) {
    Swal.fire({ icon: 'warning', title: 'Campo requerido', text: 'El nombre es obligatorio', toast: true, position: 'top-end', showConfirmButton: false, timer: 3000 })
    return
  }
  try {
    const url = editing.value ? '/provider/staff/update' : '/provider/staff/create'
    const payload = editing.value ? { id: editing.value.id, ...form.value } : form.value
    await api.post(url, payload)
    Swal.fire({ icon: 'success', title: editing.value ? 'Actualizado' : 'Creado', text: editing.value ? 'Personal actualizado correctamente' : 'Personal agregado correctamente', toast: true, position: 'top-end', showConfirmButton: false, timer: 2000 })
    resetForm()
    fetchStaff()
  } catch (e) {
    Swal.fire({ icon: 'error', title: 'Error', text: e.response?.data?.error || 'Error al guardar', toast: true, position: 'top-end', showConfirmButton: false, timer: 3000 })
  }
}

const editStaff = (s) => {
  editing.value = s
  form.value = { name: s.name, email: s.email || '', phone: s.phone || '', password: '', role: s.role }
  showForm.value = true
}

const deleteStaff = async (id) => {
  const result = await Swal.fire({
    icon: 'warning',
    title: '¿Eliminar miembro?',
    text: 'Esta acción no se puede deshacer',
    showCancelButton: true,
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#ef4444',
  })
  if (!result.isConfirmed) return
  try {
    await api.post('/provider/staff/delete', { id })
    Swal.fire({ icon: 'success', title: 'Eliminado', text: 'Miembro eliminado correctamente', toast: true, position: 'top-end', showConfirmButton: false, timer: 2000 })
    fetchStaff()
  } catch (e) {
    Swal.fire({ icon: 'error', title: 'Error', text: 'No se pudo eliminar', toast: true, position: 'top-end', showConfirmButton: false, timer: 3000 })
  }
}

const resetForm = () => {
  showForm.value = false
  editing.value = null
  form.value = { name: '', email: '', phone: '', password: '', role: 'delivery' }
}

const getInitials = (name) => {
  if (!name) return '?'
  return name.split(' ').map(w => w[0]).join('').toUpperCase().slice(0, 2)
}

const getRoleLabel = (role) => {
  return role === 'delivery' ? '🛵 Delivery' : '👤 Staff'
}

onMounted(fetchStaff)
</script>

<style scoped>
.staff-container {
  padding: 24px;
  max-width: 800px;
  margin: 0 auto;
  min-height: 60vh;
}

.staff-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 24px;
  flex-wrap: wrap;
  gap: 12px;
}

.staff-header h1 {
  margin: 0;
  font-size: 1.5rem;
  color: #1e293b;
}

.subtitle {
  margin: 4px 0 0;
  color: #64748b;
  font-size: 0.9rem;
}

.btn-add {
  background: #667eea;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 10px;
  cursor: pointer;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 6px;
  transition: all 0.2s;
  white-space: nowrap;
}

.btn-add:hover {
  background: #5a6fd6;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

.btn-icon {
  font-size: 1.2rem;
  font-weight: 700;
}

/* Form */
.staff-form {
  background: #f8fafc;
  padding: 24px;
  border-radius: 16px;
  margin-bottom: 24px;
  border: 1px solid #e2e8f0;
}

.staff-form h3 {
  margin: 0 0 16px;
  color: #1e293b;
  font-size: 1.1rem;
}

.form-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.form-group label {
  font-size: 0.85rem;
  font-weight: 600;
  color: #475569;
}

.input {
  padding: 10px 14px;
  border: 1px solid #cbd5e1;
  border-radius: 8px;
  font-size: 0.95rem;
  transition: border 0.2s;
  background: white;
}

.input:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.form-actions {
  display: flex;
  gap: 10px;
  margin-top: 20px;
  justify-content: flex-end;
}

.btn-save {
  background: #22c55e;
  color: white;
  border: none;
  padding: 10px 24px;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.2s;
}

.btn-save:hover:not(:disabled) {
  background: #16a34a;
}

.btn-save:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-cancel {
  background: #e2e8f0;
  color: #475569;
  border: none;
  padding: 10px 24px;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.2s;
}

.btn-cancel:hover {
  background: #cbd5e1;
}

/* Loading */
.loading-container {
  text-align: center;
  padding: 48px;
  color: #64748b;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 3px solid #e2e8f0;
  border-top: 3px solid #667eea;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
  margin: 0 auto 16px;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* List */
.list-header {
  color: #64748b;
  font-size: 0.85rem;
  margin-bottom: 12px;
}

.staff-list {
  max-height: 60vh;
  overflow-y: auto;
  padding-right: 4px;
}

.staff-card {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  background: white;
  border-radius: 12px;
  margin-bottom: 10px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.06);
  border: 1px solid #e2e8f0;
  transition: all 0.2s;
  gap: 14px;
}

.staff-card:hover {
  box-shadow: 0 4px 12px rgba(0,0,0,0.08);
  border-color: #cbd5e1;
}

.staff-avatar {
  width: 44px;
  height: 44px;
  border-radius: 50%;
  background: #667eea;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 0.95rem;
  flex-shrink: 0;
}

.staff-info {
  flex: 1;
  min-width: 0;
}

.staff-info strong {
  display: block;
  color: #1e293b;
  margin-bottom: 4px;
}

.role-badge {
  display: inline-block;
  padding: 2px 10px;
  border-radius: 20px;
  font-size: 0.75rem;
  font-weight: 600;
  background: #e0e7ff;
  color: #4338ca;
}

.role-badge.delivery {
  background: #fef3c7;
  color: #92400e;
}

.contact-info {
  margin: 6px 0 0;
  font-size: 0.82rem;
  color: #64748b;
  display: flex;
  gap: 14px;
  flex-wrap: wrap;
}

.staff-actions {
  display: flex;
  gap: 4px;
  flex-shrink: 0;
}

.staff-actions button {
  width: 36px;
  height: 36px;
  border-radius: 8px;
  border: 1px solid #e2e8f0;
  background: white;
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
}

.btn-edit:hover {
  background: #e0e7ff;
  border-color: #667eea;
  color: #667eea;
}

.btn-delete:hover {
  background: #fee2e2;
  border-color: #ef4444;
  color: #ef4444;
}

/* Empty state */
.empty-state {
  text-align: center;
  padding: 60px 20px;
  background: #f8fafc;
  border-radius: 16px;
  border: 2px dashed #e2e8f0;
}

.empty-icon {
  font-size: 4rem;
  margin-bottom: 16px;
}

.empty-state h3 {
  color: #1e293b;
  margin: 0 0 8px;
}

.empty-state p {
  color: #64748b;
  margin: 0 0 24px;
}

/* Transitions */
.slide-enter-active, .slide-leave-active {
  transition: all 0.3s ease;
}
.slide-enter-from, .slide-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}

@media (max-width: 640px) {
  .form-grid {
    grid-template-columns: 1fr;
  }
  .staff-card {
    flex-wrap: wrap;
  }
  .contact-info {
    flex-direction: column;
    gap: 2px;
  }
}
</style>
