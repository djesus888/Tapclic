<template>
  <div class="modal-overlay" @click.self="close">
    <div class="assign-modal">
      <div class="modal-header">
        <h2>
          {{ mode === 'assign' ? 'Asignar Ticket' : 'Reasignar Ticket' }} 
          <span class="ticket-id">#{{ ticket.id }}</span>
        </h2>
        <button class="btn-close" @click="close">✕</button>
      </div>
      
      <div class="modal-body">
        <div class="ticket-preview">
          <div class="preview-header">
            <h3 class="preview-subject">{{ ticket.subject }}</h3>
            <div class="preview-meta">
              <span class="preview-category">{{ getCategoryLabel(ticket.category) }}</span>
              <span class="preview-priority" :class="ticket.priority">
                {{ getPriorityLabel(ticket.priority) }}
              </span>
            </div>
          </div>
          <p class="preview-description">{{ truncateDescription(ticket.description) }}</p>
          <div class="preview-footer">
            <div class="current-assignment" v-if="ticket.assigned_to">
              <span class="current-label">Actualmente asignado a:</span>
              <div class="current-admin">
                <img
                  :src="getAdminAvatar(ticket.assigned_to)"
                  :alt="ticket.assigned_to.name"
                  class="admin-avatar"
                />
                <span class="admin-name">{{ ticket.assigned_to.name }}</span>
              </div>
            </div>
            <div v-else class="unassigned-notice">
              <span class="notice-icon">👤</span>
              <span class="notice-text">Este ticket no está asignado</span>
            </div>
          </div>
        </div>
        
        <div class="assignment-section">
          <h3 class="section-title">Seleccionar Administrador</h3>
          <p class="section-subtitle">Asigna este ticket a un administrador para su seguimiento</p>
          
          <div class="search-admin">
            <div class="search-input-wrapper">
              <span class="search-icon">🔍</span>
              <input
                type="text"
                v-model="searchQuery"
                placeholder="Buscar administrador por nombre o email..."
                class="search-input"
                @input="filterAdmins"
              />
              <button
                v-if="searchQuery"
                class="clear-search"
                @click="clearSearch"
              >
                ✕
              </button>
            </div>
          </div>
          
          <div class="admins-list" v-if="filteredAdmins.length > 0">
            <div class="admins-grid">
              <div
                v-for="admin in filteredAdmins"
                :key="admin.id"
                :class="['admin-card', { selected: selectedAdmin === admin.id }]"
                @click="selectAdmin(admin.id)"
              >
                <div class="card-header">
                  <div class="admin-avatar-section">
                    <img
                      :src="getAdminAvatar(admin)"
                      :alt="admin.name"
                      class="admin-avatar-lg"
                    />
                    <div class="admin-status" :class="getAdminStatus(admin)">
                      <span class="status-dot"></span>
                      <span class="status-text">{{ getAdminStatusText(admin) }}</span>
                    </div>
                  </div>
                  <div class="admin-info">
                    <h4 class="admin-name">{{ admin.name }}</h4>
                    <p class="admin-email">{{ admin.email }}</p>
                    <div class="admin-role">
                      <span class="role-badge">{{ admin.role || 'Administrador' }}</span>
                    </div>
                  </div>
                </div>
                
                <div class="admin-stats">
                  <div class="stat-item">
                    <span class="stat-icon">📋</span>
                    <div class="stat-content">
                      <span class="stat-value">{{ admin.assigned_tickets || 0 }}</span>
                      <span class="stat-label">Tickets asignados</span>
                    </div>
                  </div>
                  <div class="stat-item">
                    <span class="stat-icon">✅</span>
                    <div class="stat-content">
                      <span class="stat-value">{{ admin.resolved_tickets || 0 }}</span>
                      <span class="stat-label">Resueltos</span>
                    </div>
                  </div>
                  <div class="stat-item">
                    <span class="stat-icon">⏱️</span>
                    <div class="stat-content">
                      <span class="stat-value">{{ admin.avg_response_time || '--' }}</span>
                      <span class="stat-label">Tiempo respuesta</span>
                    </div>
                  </div>
                </div>
                
                <div class="admin-skills" v-if="admin.skills && admin.skills.length > 0">
                  <div class="skills-label">Habilidades:</div>
                  <div class="skills-list">
                    <span
                      v-for="(skill, index) in admin.skills"
                      :key="index"
                      class="skill-tag"
                    >
                      {{ skill }}
                    </span>
                  </div>
                </div>
                
                <div class="card-footer">
                  <button
                    class="btn-select-admin"
                    @click.stop="selectAdmin(admin.id)"
                  >
                    {{ selectedAdmin === admin.id ? '✓ Seleccionado' : 'Seleccionar' }}
                  </button>
                </div>
              </div>
            </div>
          </div>
          
          <div v-else class="no-admins">
            <div class="no-admins-icon">👤</div>
            <h4>No se encontraron administradores</h4>
            <p>No hay administradores disponibles que coincidan con tu búsqueda</p>
          </div>
          
          <div v-if="selectedAdmin" class="selected-admin-preview">
            <h4 class="preview-title">Administrador seleccionado</h4>
            <div class="selected-admin-info">
              <img
                :src="getSelectedAdminAvatar()"
                :alt="selectedAdminInfo?.name"
                class="selected-admin-avatar"
              />
              <div class="selected-admin-details">
                <h5 class="selected-admin-name">{{ selectedAdminInfo?.name }}</h5>
                <p class="selected-admin-email">{{ selectedAdminInfo?.email }}</p>
                <div class="selected-admin-stats">
                  <span class="stat-badge">
                    📋 {{ selectedAdminInfo?.assigned_tickets || 0 }} tickets
                  </span>
                  <span class="stat-badge">
                    ✅ {{ selectedAdminInfo?.resolved_tickets || 0 }} resueltos
                  </span>
                  <span class="stat-badge">
                    ⭐ {{ selectedAdminInfo?.rating || '--' }} rating
                  </span>
                </div>
              </div>
            </div>
          </div>
          
          <div class="assignment-options">
            <div class="option-group">
              <h4 class="option-title">Opciones de asignación</h4>
              
              <div class="option-item">
                <label class="checkbox-option">
                  <input
                    type="checkbox"
                    v-model="options.notifyAdmin"
                    :disabled="loading"
                  />
                  <span class="checkbox-label">
                    Notificar al administrador por email
                  </span>
                </label>
                <p class="option-description">
                  El administrador recibirá una notificación sobre este ticket
                </p>
              </div>
              
              <div class="option-item">
                <label class="checkbox-option">
                  <input
                    type="checkbox"
                    v-model="options.notifyUser"
                    :disabled="loading"
                  />
                  <span class="checkbox-label">
                    Notificar al usuario sobre la asignación
                  </span>
                </label>
                <p class="option-description">
                  El usuario será notificado sobre quién está atendiendo su ticket
                </p>
              </div>
              
              <div class="option-item">
                <label class="checkbox-option">
                  <input
                    type="checkbox"
                    v-model="options.setDueDate"
                    :disabled="loading"
                  />
                  <span class="checkbox-label">
                    Establecer fecha límite de resolución
                  </span>
                </label>
                
                <div v-if="options.setDueDate" class="due-date-picker">
                  <label>Fecha límite:</label>
                  <input
                    type="date"
                    v-model="options.dueDate"
                    :min="minDueDate"
                    :max="maxDueDate"
                    class="date-input"
                  />
                  <span class="date-hint">
                    El administrador deberá resolver el ticket antes de esta fecha
                  </span>
                </div>
              </div>
              
              <div class="option-item">
                <label class="checkbox-option">
                  <input
                    type="checkbox"
                    v-model="options.addInternalNote"
                    :disabled="loading"
                  />
                  <span class="checkbox-label">
                    Agregar nota interna sobre la asignación
                  </span>
                </label>
                
                <div v-if="options.addInternalNote" class="internal-note">
                  <textarea
                    v-model="options.internalNote"
                    placeholder="Agrega una nota sobre por qué estás asignando este ticket..."
                    rows="3"
                    class="note-textarea"
                  ></textarea>
                </div>
              </div>
            </div>
          </div>
          
          <div class="modal-actions">
            <div class="action-buttons">
              <button
                type="button"
                class="btn-cancel"
                @click="close"
                :disabled="loading"
              >
                Cancelar
              </button>
              <button
                type="button"
                class="btn-assign-self"
                @click="assignToSelf"
                :disabled="loading"
                v-if="!isCurrentUserAssigned"
              >
                Asignar a mí mismo
              </button>
              <button
                type="button"
                class="btn-unassign"
                @click="unassignTicket"
                :disabled="loading"
                v-if="ticket.assigned_to && mode === 'reassign'"
              >
                Quitar asignación
              </button>
              <button
                type="submit"
                class="btn-confirm"
                @click="confirmAssignment"
                :disabled="!selectedAdmin || loading"
              >
                <span v-if="loading" class="btn-spinner"></span>
                <span v-else>
                  {{ mode === 'assign' ? 'Asignar Ticket' : 'Reasignar Ticket' }}
                </span>
              </button>
            </div>
            
            <div class="action-hints">
              <p v-if="!selectedAdmin" class="hint-text">
                Selecciona un administrador para continuar
              </p>
              <p v-else class="hint-text">
                Ticket será asignado a: <strong>{{ selectedAdminInfo?.name }}</strong>
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import api from '@/axios'
import { useAuthStore } from '@/stores/authStore'

interface Admin {
  id: number
  name: string
  email: string
  avatar_url?: string
  role: string
  assigned_tickets?: number
  resolved_tickets?: number
  avg_response_time?: string
  rating?: number
  skills?: string[]
  is_online?: boolean
  last_active?: string
}

interface Ticket {
  id: number
  subject: string
  description: string
  category: string
  priority: string
  assigned_to?: Admin
  assigned_to_id?: number
}

interface Props {
  ticket: Ticket
  admins: Admin[]
  mode?: 'assign' | 'reassign'
}

interface Emits {
  (e: 'assign', data: { adminId: number; options?: any }): void
  (e: 'unassign'): void
  (e: 'close'): void
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()

const authStore = useAuthStore()

// State
const loading = ref(false)
const searchQuery = ref('')
const selectedAdmin = ref<number | null>(null)
const filteredAdmins = ref<Admin[]>([])

// Assignment options
const options = ref({
  notifyAdmin: true,
  notifyUser: true,
  setDueDate: false,
  dueDate: '',
  addInternalNote: false,
  internalNote: ''
})

// Computed properties
const selectedAdminInfo = computed(() => {
  if (!selectedAdmin.value) return null
  return props.admins.find(admin => admin.id === selectedAdmin.value)
})

const isCurrentUserAssigned = computed(() => {
  return props.ticket.assigned_to_id === authStore.user?.id
})

const minDueDate = computed(() => {
  const today = new Date()
  return today.toISOString().split('T')[0]
})

const maxDueDate = computed(() => {
  const future = new Date()
  future.setDate(future.getDate() + 30) // Máximo 30 días
  return future.toISOString().split('T')[0]
})

// Lifecycle
onMounted(() => {
  filteredAdmins.value = [...props.admins]
  
  // Si estamos reasignando, mostrar el administrador actual
  if (props.mode === 'reassign' && props.ticket.assigned_to_id) {
    selectedAdmin.value = props.ticket.assigned_to_id
  }
  
  // Establecer fecha límite predeterminada (3 días)
  const threeDaysFromNow = new Date()
  threeDaysFromNow.setDate(threeDaysFromNow.getDate() + 3)
  options.value.dueDate = threeDaysFromNow.toISOString().split('T')[0]
})

// Methods
function getCategoryLabel(category: string): string {
  const labels: Record<string, string> = {
    technical: 'Técnico',
    billing: 'Facturación',
    account: 'Cuenta',
    service: 'Servicio',
    bug: 'Error/Bug',
    feature: 'Solicitud de Función',
    other: 'Otro'
  }
  return labels[category] || category
}

function getPriorityLabel(priority: string): string {
  const labels: Record<string, string> = {
    low: 'Baja',
    medium: 'Media',
    high: 'Alta',
    urgent: 'Urgente'
  }
  return labels[priority] || priority
}

function getAdminAvatar(admin?: Admin): string {
  if (admin?.avatar_url) {
    return getImageUrl(admin.avatar_url, 'avatar')
  }
  return '/img/default-admin.png'
}

function getSelectedAdminAvatar(): string {
  return selectedAdminInfo.value 
    ? getAdminAvatar(selectedAdminInfo.value)
    : '/img/default-admin.png'
}

function getAdminStatus(admin: Admin): string {
  if (admin.is_online) return 'online'
  
  if (admin.last_active) {
    const lastActive = new Date(admin.last_active)
    const now = new Date()
    const hoursDiff = (now.getTime() - lastActive.getTime()) / (1000 * 60 * 60)
    
    if (hoursDiff < 1) return 'recent'
    if (hoursDiff < 24) return 'away'
  }
  
  return 'offline'
}

function getAdminStatusText(admin: Admin): string {
  const status = getAdminStatus(admin)
  const texts: Record<string, string> = {
    online: 'En línea',
    recent: 'Reciente',
    away: 'Ausente',
    offline: 'Desconectado'
  }
  return texts[status] || status
}

function truncateDescription(description: string): string {
  return description.length > 200 
    ? description.substring(0, 200) + '...'
    : description
}

function filterAdmins() {
  if (!searchQuery.value.trim()) {
    filteredAdmins.value = [...props.admins]
    return
  }
  
  const query = searchQuery.value.toLowerCase()
  filteredAdmins.value = props.admins.filter(admin =>
    admin.name.toLowerCase().includes(query) ||
    admin.email.toLowerCase().includes(query) ||
    admin.skills?.some(skill => skill.toLowerCase().includes(query))
  )
}

function clearSearch() {
  searchQuery.value = ''
  filteredAdmins.value = [...props.admins]
}

function selectAdmin(adminId: number) {
  selectedAdmin.value = adminId
}

async function assignToSelf() {
  selectedAdmin.value = authStore.user?.id || null
}

async function unassignTicket() {
  if (!confirm('¿Estás seguro de que deseas quitar la asignación de este ticket?')) {
    return
  }
  
  loading.value = true
  try {
    await api.put(
      `/admin/tickets/${props.ticket.id}/unassign`,
      {},
      { headers: { Authorization: `Bearer ${authStore.token}` } }
    )
    
    emit('unassign')
    close()
  } catch (error) {
    console.error('Error quitando asignación:', error)
  } finally {
    loading.value = false
  }
}

async function confirmAssignment() {
  if (!selectedAdmin.value) return
  
  loading.value = true
  
  try {
    const assignmentData = {
      admin_id: selectedAdmin.value,
      options: options.value
    }
    
    emit('assign', assignmentData)
    close()
    
  } catch (error) {
    console.error('Error en asignación:', error)
  } finally {
    loading.value = false
  }
}

function close() {
  if (!loading.value) {
    emit('close')
  }
}

// Watchers
watch(searchQuery, filterAdmins)
</script>

<style scoped>
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
  padding: 20px;
  backdrop-filter: blur(4px);
  animation: fadeIn 0.2s ease-out;
}

.assign-modal {
  background: white;
  width: 95%;
  max-width: 1000px;
  max-height: 90vh;
  border-radius: 20px;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  animation: slideUp 0.3s ease-out;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px 32px;
  background: linear-gradient(135deg, #4a6491 0%, #2c3e50 100%);
  color: white;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.modal-header h2 {
  margin: 0;
  font-size: 1.5rem;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 12px;
}

.ticket-id {
  background: rgba(255, 255, 255, 0.2);
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 0.9rem;
  font-weight: 500;
}

.btn-close {
  background: rgba(255, 255, 255, 0.2);
  color: white;
  border: none;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  cursor: pointer;
  font-size: 18px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background 0.3s;
}

.btn-close:hover {
  background: rgba(255, 255, 255, 0.3);
}

.modal-body {
  flex: 1;
  overflow-y: auto;
  padding: 32px;
}

.ticket-preview {
  background: #f8f9fa;
  border-radius: 16px;
  padding: 24px;
  margin-bottom: 32px;
  border: 2px solid #e0e6ed;
}

.preview-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 16px;
  flex-wrap: wrap;
  gap: 12px;
}

.preview-subject {
  margin: 0;
  font-size: 1.3rem;
  color: #2d3436;
  flex: 1;
  line-height: 1.3;
}

.preview-meta {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}

.preview-category {
  background: #e3f2fd;
  color: #1976d2;
  padding: 6px 16px;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 500;
}

.preview-priority {
  padding: 6px 16px;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 500;
}

.preview-priority.low {
  background: #e8f5e9;
  color: #388e3c;
}

.preview-priority.medium {
  background: #fff3e0;
  color: #f57c00;
}

.preview-priority.high {
  background: #ffebee;
  color: #d32f2f;
}

.preview-priority.urgent {
  background: #d32f2f;
  color: white;
}

.preview-description {
  color: #636e72;
  line-height: 1.6;
  margin: 0 0 20px 0;
  font-size: 0.95rem;
}

.preview-footer {
  padding-top: 20px;
  border-top: 1px solid #dfe6e9;
}

.current-assignment {
  display: flex;
  align-items: center;
  gap: 16px;
}

.current-label {
  color: #636e72;
  font-size: 0.9rem;
  font-weight: 500;
}

.current-admin {
  display: flex;
  align-items: center;
  gap: 12px;
  background: white;
  padding: 10px 16px;
  border-radius: 12px;
  border: 2px solid #dfe6e9;
}

.admin-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  object-fit: cover;
}

.admin-name {
  font-weight: 600;
  color: #2d3436;
}

.unassigned-notice {
  display: flex;
  align-items: center;
  gap: 12px;
  color: #636e72;
}

.notice-icon {
  font-size: 1.5rem;
  opacity: 0.5;
}

.notice-text {
  font-size: 0.95rem;
}

.assignment-section {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.section-title {
  margin: 0 0 8px 0;
  font-size: 1.4rem;
  color: #2d3436;
}

.section-subtitle {
  color: #636e72;
  margin: 0;
  font-size: 0.95rem;
}

.search-admin {
  margin-bottom: 16px;
}

.search-input-wrapper {
  position: relative;
}

.search-icon {
  position: absolute;
  left: 16px;
  top: 50%;
  transform: translateY(-50%);
  font-size: 1.2rem;
  color: #636e72;
}

.search-input {
  width: 100%;
  padding: 14px 16px 14px 48px;
  border: 2px solid #dfe6e9;
  border-radius: 12px;
  font-size: 1rem;
  transition: all 0.3s;
  background: white;
}

.search-input:focus {
  outline: none;
  border-color: #3498db;
  box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
}

.clear-search {
  position: absolute;
  right: 16px;
  top: 50%;
  transform: translateY(-50%);
  background: #dfe6e9;
  border: none;
  width: 24px;
  height: 24px;
  border-radius: 50%;
  cursor: pointer;
  font-size: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.clear-search:hover {
  background: #b2bec3;
}

.admins-list {
  margin-bottom: 24px;
}

.admins-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
  max-height: 400px;
  overflow-y: auto;
  padding: 8px;
}

.admin-card {
  background: white;
  border: 2px solid #dfe6e9;
  border-radius: 16px;
  padding: 20px;
  cursor: pointer;
  transition: all 0.3s;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.admin-card:hover {
  border-color: #3498db;
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(52, 152, 219, 0.1);
}

.admin-card.selected {
  border-color: #3498db;
  background: #e3f2fd;
}

.card-header {
  display: flex;
  align-items: flex-start;
  gap: 16px;
}

.admin-avatar-section {
  position: relative;
}

.admin-avatar-lg {
  width: 70px;
  height: 70px;
  border-radius: 50%;
  object-fit: cover;
  border: 4px solid white;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
}

.admin-status {
  position: absolute;
  bottom: 0;
  right: 0;
  display: flex;
  align-items: center;
  gap: 4px;
  background: white;
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 0.7rem;
  font-weight: 500;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
}

.admin-status.online {
  color: #2ecc71;
}

.admin-status.recent {
  color: #f39c12;
}

.admin-status.away {
  color: #e74c3c;
}

.admin-status.offline {
  color: #95a5a6;
}

.status-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  display: inline-block;
}

.admin-status.online .status-dot {
  background: #2ecc71;
}

.admin-status.recent .status-dot {
  background: #f39c12;
}

.admin-status.away .status-dot {
  background: #e74c3c;
}

.admin-status.offline .status-dot {
  background: #95a5a6;
}

.admin-info {
  flex: 1;
}

.admin-name {
  margin: 0 0 4px 0;
  font-size: 1.1rem;
  color: #2d3436;
  font-weight: 600;
}

.admin-email {
  margin: 0 0 8px 0;
  color: #636e72;
  font-size: 0.9rem;
}

.admin-role {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.role-badge {
  background: #e3f2fd;
  color: #1976d2;
  padding: 4px 12px;
  border-radius: 15px;
  font-size: 0.8rem;
  font-weight: 500;
}

.admin-stats {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
  background: #f8f9fa;
  padding: 16px;
  border-radius: 12px;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 8px;
}

.stat-icon {
  font-size: 1.2rem;
  opacity: 0.7;
}

.stat-content {
  display: flex;
  flex-direction: column;
}

.stat-value {
  font-weight: 700;
  color: #2d3436;
  font-size: 1.1rem;
}

.stat-label {
  color: #636e72;
  font-size: 0.75rem;
}

.admin-skills {
  margin-top: 8px;
}

.skills-label {
  font-size: 0.85rem;
  color: #636e72;
  margin-bottom: 8px;
  font-weight: 500;
}

.skills-list {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.skill-tag {
  background: #e0f7fa;
  color: #0097a7;
  padding: 4px 10px;
  border-radius: 15px;
  font-size: 0.75rem;
  font-weight: 500;
}

.card-footer {
  margin-top: auto;
}

.btn-select-admin {
  width: 100%;
  background: #3498db;
  color: white;
  border: none;
  padding: 10px;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-select-admin:hover {
  background: #2980b9;
}

.no-admins {
  text-align: center;
  padding: 40px 20px;
  background: #f8f9fa;
  border-radius: 16px;
  border: 2px dashed #dfe6e9;
}

.no-admins-icon {
  font-size: 48px;
  margin-bottom: 16px;
  opacity: 0.5;
}

.no-admins h4 {
  margin: 0 0 8px 0;
  color: #2d3436;
}

.no-admins p {
  margin: 0;
  color: #636e72;
  font-size: 0.95rem;
}

.selected-admin-preview {
  background: #e3f2fd;
  border-radius: 16px;
  padding: 24px;
  border: 2px solid #3498db;
  margin-bottom: 24px;
}

.preview-title {
  margin: 0 0 16px 0;
  font-size: 1.1rem;
  color: #1976d2;
  font-weight: 600;
}

.selected-admin-info {
  display: flex;
  align-items: center;
  gap: 20px;
}

.selected-admin-avatar {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  object-fit: cover;
  border: 4px solid white;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.selected-admin-details {
  flex: 1;
}

.selected-admin-name {
  margin: 0 0 4px 0;
  font-size: 1.3rem;
  color: #2d3436;
  font-weight: 600;
}

.selected-admin-email {
  margin: 0 0 12px 0;
  color: #636e72;
  font-size: 0.95rem;
}

.selected-admin-stats {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}

.stat-badge {
  background: white;
  color: #1976d2;
  padding: 6px 16px;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 500;
}

.assignment-options {
  background: white;
  border-radius: 16px;
  padding: 24px;
  border: 2px solid #f1f2f6;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
}

.option-group {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.option-title {
  margin: 0 0 16px 0;
  font-size: 1.2rem;
  color: #2d3436;
  font-weight: 600;
}

.option-item {
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding-bottom: 24px;
  border-bottom: 1px solid #f1f2f6;
}

.option-item:last-child {
  border-bottom: none;
  padding-bottom: 0;
}

.checkbox-option {
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
  user-select: none;
}

.checkbox-option input[type="checkbox"] {
  width: 20px;
  height: 20px;
  cursor: pointer;
}

.checkbox-label {
  font-weight: 600;
  color: #2d3436;
  font-size: 1rem;
}

.option-description {
  color: #636e72;
  font-size: 0.9rem;
  margin: 0;
  padding-left: 32px;
}

.due-date-picker {
  padding-left: 32px;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.due-date-picker label {
  font-weight: 600;
  color: #2d3436;
  font-size: 0.95rem;
}

.date-input {
  padding: 10px;
  border: 2px solid #dfe6e9;
  border-radius: 8px;
  font-size: 1rem;
  max-width: 200px;
}

.date-input:focus {
  outline: none;
  border-color: #3498db;
}

.date-hint {
  color: #636e72;
  font-size: 0.85rem;
  margin-top: 4px;
}

.internal-note {
  padding-left: 32px;
}

.note-textarea {
  width: 100%;
  padding: 12px;
  border: 2px solid #dfe6e9;
  border-radius: 8px;
  font-size: 0.95rem;
  font-family: inherit;
  resize: vertical;
  min-height: 80px;
}

.note-textarea:focus {
  outline: none;
  border-color: #3498db;
}

.modal-actions {
  margin-top: 32px;
  padding-top: 24px;
  border-top: 1px solid #e0e6ed;
}

.action-buttons {
  display: flex;
  gap: 12px;
  margin-bottom: 16px;
  flex-wrap: wrap;
}

.btn-cancel,
.btn-assign-self,
.btn-unassign,
.btn-confirm {
  padding: 12px 24px;
  border-radius: 10px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  border: 2px solid transparent;
}

.btn-cancel {
  background: white;
  color: #2d3436;
  border-color: #dfe6e9;
}

.btn-cancel:hover:not(:disabled) {
  background: #f8f9fa;
  border-color: #b2bec3;
}

.btn-assign-self {
  background: #f39c12;
  color: white;
}

.btn-assign-self:hover:not(:disabled) {
  background: #e67e22;
  transform: translateY(-2px);
}

.btn-unassign {
  background: #e74c3c;
  color: white;
}

.btn-unassign:hover:not(:disabled) {
  background: #c0392b;
  transform: translateY(-2px);
}

.btn-confirm {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.btn-confirm:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
}

.btn-cancel:disabled,
.btn-assign-self:disabled,
.btn-unassign:disabled,
.btn-confirm:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  transform: none !important;
}

.btn-spinner {
  width: 20px;
  height: 20px;
  border: 3px solid rgba(255, 255, 255, 0.3);
  border-top: 3px solid white;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.action-hints {
  text-align: center;
}

.hint-text {
  margin: 0;
  color: #636e72;
  font-size: 0.9rem;
}

/* Responsive */
@media (max-width: 768px) {
  .assign-modal {
    width: 100%;
    height: 100vh;
    max-height: 100vh;
    border-radius: 0;
  }
  
  .modal-header {
    padding: 20px;
  }
  
  .modal-header h2 {
    font-size: 1.3rem;
  }
  
  .modal-body {
    padding: 20px;
  }
  
  .admins-grid {
    grid-template-columns: 1fr;
  }
  
  .action-buttons {
    flex-direction: column;
  }
  
  .btn-cancel,
  .btn-assign-self,
  .btn-unassign,
  .btn-confirm {
    width: 100%;
    justify-content: center;
  }
  
  .selected-admin-info {
    flex-direction: column;
    text-align: center;
  }
}
</style>
