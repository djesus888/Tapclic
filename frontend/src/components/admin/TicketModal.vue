<template>
  <div class="modal-overlay" @click.self="close">
    <div class="ticket-modal">
      <div class="modal-header">
        <h2>{{ mode === 'create' ? 'Crear Nuevo Ticket' : 'Editar Ticket #' + ticket?.id }}</h2>
        <button class="btn-close" @click="close">✕</button>
      </div>
      
      <div class="modal-body">
        <form @submit.prevent="handleSubmit">
          <div class="form-group">
            <label for="subject" class="form-label">
              Asunto <span class="required">*</span>
            </label>
            <input
              id="subject"
              v-model="form.subject"
              type="text"
              required
              placeholder="Ej: Problema con la facturación del último servicio"
              class="form-input"
              :class="{ 'input-error': errors.subject }"
            />
            <span v-if="errors.subject" class="error-message">{{ errors.subject }}</span>
          </div>
          
          <div class="form-row">
            <div class="form-group">
              <label for="category" class="form-label">
                Categoría <span class="required">*</span>
              </label>
              <select
                id="category"
                v-model="form.category"
                required
                class="form-select"
                :class="{ 'input-error': errors.category }"
              >
                <option value="">Seleccionar categoría</option>
                <option value="technical">Técnico</option>
                <option value="billing">Facturación</option>
                <option value="account">Cuenta</option>
                <option value="service">Servicio</option>
                <option value="bug">Error/Bug</option>
                <option value="feature">Solicitud de Función</option>
                <option value="other">Otro</option>
              </select>
              <span v-if="errors.category" class="error-message">{{ errors.category }}</span>
            </div>
            
            <div class="form-group">
              <label for="priority" class="form-label">
                Prioridad <span class="required">*</span>
              </label>
              <select
                id="priority"
                v-model="form.priority"
                required
                class="form-select"
                :class="{ 'input-error': errors.priority }"
              >
                <option value="">Seleccionar prioridad</option>
                <option value="low">Baja</option>
                <option value="medium">Media</option>
                <option value="high">Alta</option>
                <option value="urgent">Urgente</option>
              </select>
              <span v-if="errors.priority" class="error-message">{{ errors.priority }}</span>
            </div>
          </div>
          
          <div class="form-group">
            <label for="description" class="form-label">
              Descripción <span class="required">*</span>
            </label>
            <textarea
              id="description"
              v-model="form.description"
              rows="6"
              required
              placeholder="Describe el problema o solicitud en detalle. Incluye pasos para reproducir el problema si aplica."
              class="form-textarea"
              :class="{ 'input-error': errors.description }"
            ></textarea>
            <div class="char-counter">
              {{ form.description.length }}/2000 caracteres
            </div>
            <span v-if="errors.description" class="error-message">{{ errors.description }}</span>
          </div>
          
          <div v-if="mode === 'create'" class="form-group">
            <label for="user_id" class="form-label">
              Usuario <span class="required">*</span>
            </label>
            <select
              id="user_id"
              v-model="form.user_id"
              required
              class="form-select"
              :class="{ 'input-error': errors.user_id }"
            >
              <option value="">Seleccionar usuario</option>
              <option v-for="user in users" :key="user.id" :value="user.id">
                {{ user.name }} ({{ user.email }})
              </option>
            </select>
            <span v-if="errors.user_id" class="error-message">{{ errors.user_id }}</span>
          </div>
          
          <div class="form-group">
            <label for="assigned_to" class="form-label">Asignar a (opcional)</label>
            <select
              id="assigned_to"
              v-model="form.assigned_to_id"
              class="form-select"
            >
              <option value="">Sin asignar</option>
              <option v-for="admin in admins" :key="admin.id" :value="admin.id">
                {{ admin.name }} ({{ admin.assigned_tickets || 0 }} tickets)
              </option>
            </select>
            <p class="helper-text">
              Dejar vacío para asignar más tarde o auto-asignar
            </p>
          </div>
          
          <div class="form-group">
            <label class="form-label">Etiquetas (opcional)</label>
            <div class="tags-input" :class="{ 'input-error': errors.tags }">
              <div class="tags-container">
                <span v-for="(tag, index) in form.tags" :key="index" class="tag">
                  {{ tag }}
                  <button
                    type="button"
                    @click="removeTag(index)"
                    class="tag-remove"
                    :title="`Quitar ${tag}`"
                  >
                    ✕
                  </button>
                </span>
              </div>
              <div class="tag-input-wrapper">
                <input
                  type="text"
                  v-model="tagInput"
                  @keydown.enter.prevent="addTag"
                  @keydown.delete="handleDeleteKey"
                  placeholder="Escribe y presiona Enter para agregar"
                  class="tag-input"
                />
                <button
                  type="button"
                  @click="addTag"
                  class="tag-add-btn"
                  :disabled="!tagInput.trim()"
                >
                  +
                </button>
              </div>
              <div class="tag-suggestions">
                <span class="suggestion-label">Sugerencias:</span>
                <button
                  v-for="suggestion in tagSuggestions"
                  :key="suggestion"
                  type="button"
                  @click="addTag(suggestion)"
                  class="tag-suggestion"
                >
                  {{ suggestion }}
                </button>
              </div>
            </div>
            <span v-if="errors.tags" class="error-message">{{ errors.tags }}</span>
          </div>
          
          <div v-if="mode === 'edit'" class="form-group">
            <label for="status" class="form-label">Estado del Ticket</label>
            <select
              id="status"
              v-model="form.status"
              class="form-select"
            >
              <option value="open">Abierto</option>
              <option value="in_progress">En Progreso</option>
              <option value="pending">Pendiente</option>
              <option value="resolved">Resuelto</option>
              <option value="closed">Cerrado</option>
            </select>
          </div>
          
          <div v-if="attachments.length > 0" class="form-group">
            <label class="form-label">Archivos adjuntos</label>
            <div class="attachments-list">
              <div v-for="(file, index) in attachments" :key="index" class="attachment-item">
                <span class="attachment-icon">📎</span>
                <span class="attachment-name">{{ file.name }}</span>
                <span class="attachment-size">({{ formatFileSize(file.size) }})</span>
                <button
                  type="button"
                  @click="removeAttachment(index)"
                  class="attachment-remove"
                >
                  ✕
                </button>
              </div>
            </div>
          </div>
          
          <div class="form-group">
            <label class="form-label">Adjuntar archivos (opcional)</label>
            <div class="file-upload-area" @dragover.prevent @drop="handleDrop">
              <input
                type="file"
                ref="fileInput"
                @change="handleFileSelect"
                multiple
                class="file-input"
                accept=".pdf,.doc,.docx,.jpg,.jpeg,.png,.txt"
              />
              <div class="upload-placeholder">
                <span class="upload-icon">📎</span>
                <p>Arrastra archivos aquí o haz clic para seleccionar</p>
                <p class="upload-hint">
                  Formatos permitidos: PDF, DOC, JPG, PNG, TXT (Máx. 5MB por archivo)
                </p>
              </div>
            </div>
          </div>
          
          <div class="modal-actions">
            <button type="button" class="btn-cancel" @click="close" :disabled="loading">
              Cancelar
            </button>
            <button type="submit" class="btn-save" :disabled="loading">
              <span v-if="loading" class="btn-spinner"></span>
              <span v-else>{{ mode === 'create' ? 'Crear Ticket' : 'Actualizar Ticket' }}</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import api from '@/axios'
import { useAuthStore } from '@/stores/authStore'

interface User {
  id: number
  name: string
  email: string
  role: string
}

interface Admin {
  id: number
  name: string
  email: string
  assigned_tickets?: number
  avatar_url?: string
}

interface Ticket {
  id: number
  subject: string
  description: string
  category: string
  priority: string
  status: string
  user_id: number
  assigned_to_id?: number
  tags?: string[]
}

interface Props {
  ticket?: Ticket | null
  mode: 'create' | 'edit'
}

interface Emits {
  (e: 'save', data: any): void
  (e: 'close'): void
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()

const authStore = useAuthStore()
const loading = ref(false)

// Form data
const form = ref({
  subject: '',
  description: '',
  category: '',
  priority: '',
  user_id: '',
  assigned_to_id: '',
  status: 'open',
  tags: [] as string[]
})

// Form errors
const errors = ref<Record<string, string>>({})

// Tag management
const tagInput = ref('')
const tagSuggestions = ['urgente', 'bug', 'feature', 'soporte', 'factura', 'pago', 'cuenta', 'tecnico']

// Users and admins
const users = ref<User[]>([])
const admins = ref<Admin[]>([])

// File attachments
const attachments = ref<File[]>([])
const fileInput = ref<HTMLInputElement>()

// Computed
const isEditMode = computed(() => props.mode === 'edit')

// Lifecycle
onMounted(async () => {
  if (isEditMode.value && props.ticket) {
    loadTicketData()
  }
  
  await Promise.all([
    loadUsers(),
    loadAdmins()
  ])
})

// Methods
function loadTicketData() {
  if (!props.ticket) return
  
  form.value = {
    subject: props.ticket.subject || '',
    description: props.ticket.description || '',
    category: props.ticket.category || '',
    priority: props.ticket.priority || '',
    user_id: props.ticket.user_id?.toString() || '',
    assigned_to_id: props.ticket.assigned_to_id?.toString() || '',
    status: props.ticket.status || 'open',
    tags: props.ticket.tags || []
  }
}

async function loadUsers() {
  try {
    const response = await api.get('/admin/users', {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    users.value = response.data.data || []
  } catch (error) {
    console.error('Error cargando usuarios:', error)
  }
}

async function loadAdmins() {
  try {
    const response = await api.get('/admin/users/admins', {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    admins.value = response.data.data || []
  } catch (error) {
    console.error('Error cargando administradores:', error)
  }
}

function validateForm(): boolean {
  errors.value = {}
  
  if (!form.value.subject.trim()) {
    errors.value.subject = 'El asunto es requerido'
  } else if (form.value.subject.length > 200) {
    errors.value.subject = 'El asunto no puede exceder 200 caracteres'
  }
  
  if (!form.value.category) {
    errors.value.category = 'La categoría es requerida'
  }
  
  if (!form.value.priority) {
    errors.value.priority = 'La prioridad es requerida'
  }
  
  if (!form.value.description.trim()) {
    errors.value.description = 'La descripción es requerida'
  } else if (form.value.description.length > 2000) {
    errors.value.description = 'La descripción no puede exceder 2000 caracteres'
  } else if (form.value.description.length < 10) {
    errors.value.description = 'La descripción debe tener al menos 10 caracteres'
  }
  
  if (props.mode === 'create' && !form.value.user_id) {
    errors.value.user_id = 'Debes seleccionar un usuario'
  }
  
  return Object.keys(errors.value).length === 0
}

async function handleSubmit() {
  if (!validateForm()) return
  
  loading.value = true
  
  try {
    const formData = new FormData()
    
    // Agregar campos del formulario
    Object.entries(form.value).forEach(([key, value]) => {
      if (key === 'tags') {
        if (value && Array.isArray(value)) {
          formData.append(key, JSON.stringify(value))
        }
      } else if (value !== null && value !== undefined) {
        formData.append(key, value.toString())
      }
    })
    
    // Agregar archivos adjuntos
    attachments.value.forEach((file, index) => {
      formData.append(`attachments[${index}]`, file)
    })
    
    // Determinar endpoint y método
    const endpoint = isEditMode.value 
      ? `/admin/tickets/${props.ticket?.id}`
      : '/admin/tickets'
    
    const method = isEditMode.value ? 'PUT' : 'POST'
    
    const response = await api({
      method,
      url: endpoint,
      data: formData,
      headers: {
        'Authorization': `Bearer ${authStore.token}`,
        'Content-Type': 'multipart/form-data'
      }
    })
    
    // Emitir evento con los datos del ticket
    emit('save', response.data.data || form.value)
    
  } catch (error: any) {
    console.error('Error guardando ticket:', error)
    
    // Manejar errores de validación del backend
    if (error.response?.data?.errors) {
      errors.value = error.response.data.errors
    }
  } finally {
    loading.value = false
  }
}

function addTag(tag?: string) {
  const newTag = (tag || tagInput.value).trim().toLowerCase()
  
  if (!newTag) return
  
  // Validar que no exista
  if (!form.value.tags.includes(newTag)) {
    form.value.tags.push(newTag)
  }
  
  // Limpiar input
  tagInput.value = ''
}

function removeTag(index: number) {
  form.value.tags.splice(index, 1)
}

function handleDeleteKey(event: KeyboardEvent) {
  if (event.key === 'Delete' || event.key === 'Backspace') {
    if (!tagInput.value && form.value.tags.length > 0) {
      form.value.tags.pop()
    }
  }
}

function handleFileSelect(event: Event) {
  const input = event.target as HTMLInputElement
  if (input.files) {
    Array.from(input.files).forEach(file => {
      if (validateFile(file)) {
        attachments.value.push(file)
      }
    })
  }
  // Reset input para permitir seleccionar el mismo archivo de nuevo
  input.value = ''
}

function handleDrop(event: DragEvent) {
  event.preventDefault()
  
  if (event.dataTransfer?.files) {
    Array.from(event.dataTransfer.files).forEach(file => {
      if (validateFile(file)) {
        attachments.value.push(file)
      }
    })
  }
}

function validateFile(file: File): boolean {
  const maxSize = 5 * 1024 * 1024 // 5MB
  const allowedTypes = [
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'image/jpeg',
    'image/jpg',
    'image/png',
    'text/plain'
  ]
  
  if (file.size > maxSize) {
    alert(`El archivo ${file.name} excede el tamaño máximo de 5MB`)
    return false
  }
  
  if (!allowedTypes.includes(file.type)) {
    alert(`El tipo de archivo ${file.name} no está permitido`)
    return false
  }
  
  return true
}

function removeAttachment(index: number) {
  attachments.value.splice(index, 1)
}

function formatFileSize(bytes: number): string {
  if (bytes === 0) return '0 Bytes'
  const k = 1024
  const sizes = ['Bytes', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
}

function close() {
  if (!loading.value) {
    emit('close')
  }
}

// Watchers
watch(
  () => props.ticket,
  (newTicket) => {
    if (newTicket && isEditMode.value) {
      loadTicketData()
    }
  }
)
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
  backdrop-filter: blur(4px);
  animation: fadeIn 0.2s ease-out;
}

.ticket-modal {
  background: white;
  width: 90%;
  max-width: 800px;
  max-height: 90vh;
  border-radius: 20px;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  animation: slideUp 0.3s ease-out;
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
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.modal-header h2 {
  margin: 0;
  font-size: 1.5rem;
  font-weight: 600;
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

form {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
}

@media (max-width: 768px) {
  .form-row {
    grid-template-columns: 1fr;
  }
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-label {
  font-weight: 600;
  color: #2d3436;
  font-size: 0.95rem;
}

.required {
  color: #e74c3c;
}

.form-input,
.form-select,
.form-textarea,
.tag-input {
  padding: 12px 16px;
  border: 2px solid #dfe6e9;
  border-radius: 10px;
  font-size: 1rem;
  font-family: inherit;
  transition: all 0.3s;
  background: white;
}

.form-input:focus,
.form-select:focus,
.form-textarea:focus,
.tag-input:focus {
  outline: none;
  border-color: #3498db;
  box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
}

.input-error {
  border-color: #e74c3c !important;
}

.form-textarea {
  resize: vertical;
  min-height: 120px;
  line-height: 1.5;
}

.char-counter {
  text-align: right;
  font-size: 0.85rem;
  color: #636e72;
  margin-top: 4px;
}

.helper-text {
  font-size: 0.85rem;
  color: #636e72;
  margin: 4px 0 0 0;
}

.error-message {
  color: #e74c3c;
  font-size: 0.85rem;
  margin-top: 4px;
}

/* Tags Styles */
.tags-input {
  border: 2px solid #dfe6e9;
  border-radius: 10px;
  padding: 8px;
  transition: border-color 0.3s;
}

.tags-input:focus-within {
  border-color: #3498db;
}

.tags-container {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-bottom: 8px;
}

.tag {
  background: #e3f2fd;
  color: #1976d2;
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 500;
  display: inline-flex;
  align-items: center;
  gap: 6px;
}

.tag-remove {
  background: none;
  border: none;
  color: #1976d2;
  cursor: pointer;
  font-size: 12px;
  padding: 0;
  width: 16px;
  height: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  transition: background 0.3s;
}

.tag-remove:hover {
  background: rgba(25, 118, 210, 0.1);
}

.tag-input-wrapper {
  display: flex;
  gap: 8px;
  align-items: center;
}

.tag-input {
  flex: 1;
  border: none;
  padding: 8px;
  font-size: 0.95rem;
}

.tag-input:focus {
  outline: none;
  box-shadow: none;
}

.tag-add-btn {
  background: #3498db;
  color: white;
  border: none;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  cursor: pointer;
  font-size: 18px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background 0.3s;
}

.tag-add-btn:hover:not(:disabled) {
  background: #2980b9;
}

.tag-add-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.tag-suggestions {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 8px;
  padding-top: 8px;
  border-top: 1px solid #f1f2f6;
}

.suggestion-label {
  font-size: 0.85rem;
  color: #636e72;
  align-self: center;
}

.tag-suggestion {
  background: #f8f9fa;
  border: 1px solid #dfe6e9;
  color: #636e72;
  padding: 4px 12px;
  border-radius: 15px;
  font-size: 0.8rem;
  cursor: pointer;
  transition: all 0.3s;
}

.tag-suggestion:hover {
  background: #3498db;
  color: white;
  border-color: #3498db;
}

/* Attachments Styles */
.attachments-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
  max-height: 200px;
  overflow-y: auto;
}

.attachment-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  background: #f8f9fa;
  border-radius: 8px;
  border: 1px solid #e0e6ed;
}

.attachment-icon {
  font-size: 1.2rem;
}

.attachment-name {
  flex: 1;
  font-weight: 500;
  color: #2d3436;
  font-size: 0.9rem;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.attachment-size {
  color: #636e72;
  font-size: 0.85rem;
  white-space: nowrap;
}

.attachment-remove {
  background: #ffebee;
  border: none;
  width: 24px;
  height: 24px;
  border-radius: 50%;
  color: #d32f2f;
  cursor: pointer;
  font-size: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s;
}

.attachment-remove:hover {
  background: #ffcdd2;
}

.file-upload-area {
  border: 2px dashed #dfe6e9;
  border-radius: 10px;
  padding: 40px 20px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s;
  position: relative;
}

.file-upload-area:hover {
  border-color: #3498db;
  background: #f8f9fa;
}

.file-input {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  opacity: 0;
  cursor: pointer;
}

.upload-placeholder {
  pointer-events: none;
}

.upload-icon {
  font-size: 3rem;
  color: #b2bec3;
  margin-bottom: 16px;
  display: block;
}

.upload-placeholder p {
  margin: 8px 0;
  color: #636e72;
}

.upload-hint {
  font-size: 0.85rem;
  color: #b2bec3;
}

/* Modal Actions */
.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 16px;
  padding-top: 24px;
  border-top: 1px solid #e0e6ed;
}

.btn-cancel {
  background: white;
  color: #2d3436;
  border: 2px solid #dfe6e9;
  padding: 12px 24px;
  border-radius: 10px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-cancel:hover:not(:disabled) {
  border-color: #b2bec3;
  background: #f8f9fa;
}

.btn-cancel:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-save {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 12px 32px;
  border-radius: 10px;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  transition: all 0.3s;
  min-width: 140px;
}

.btn-save:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
}

.btn-save:disabled {
  opacity: 0.6;
  cursor: not-allowed;
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

/* Responsive */
@media (max-width: 768px) {
  .ticket-modal {
    width: 95%;
    height: 95vh;
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
  
  .modal-actions {
    flex-direction: column-reverse;
  }
  
  .btn-cancel,
  .btn-save {
    width: 100%;
    justify-content: center;
  }
}
</style>
