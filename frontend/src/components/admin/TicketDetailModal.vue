<template>
  <div class="modal-overlay" @click.self="close">
    <div class="ticket-detail-modal">
      <!-- Header con ID y estado -->
      <div class="modal-header">
        <div class="ticket-header-info">
          <h2>Ticket #{{ ticket.id }}</h2>
          <div class="ticket-status">
            <span class="status-badge" :class="ticket.status">
              {{ getStatusLabel(ticket.status) }}
            </span>
            <span class="priority-badge" :class="ticket.priority">
              {{ getPriorityLabel(ticket.priority) }}
            </span>
          </div>
        </div>
        <div class="header-actions">
          <button
            v-if="ticket.status !== 'closed'"
            class="btn-close-ticket"
            @click="confirmCloseTicket"
            :disabled="loading"
          >
            Cerrar Ticket
          </button>
          <button
            class="btn-assign"
            @click="assignTicket"
            :disabled="loading"
          >
            {{ ticket.assigned_to ? 'Reasignar' : 'Asignar' }}
          </button>
          <button class="btn-close-modal" @click="close">✕</button>
        </div>
      </div>
      
      <!-- Contenido del ticket -->
      <div class="modal-body">
        <div class="ticket-content">
          <!-- Asunto y descripción -->
          <div class="ticket-main">
            <div class="ticket-subject-section">
              <h3 class="ticket-subject">{{ ticket.subject }}</h3>
              <div class="ticket-meta">
                <span class="meta-item">
                  <span class="meta-icon">🏷️</span>
                  <span class="meta-text">{{ getCategoryLabel(ticket.category) }}</span>
                </span>
                <span class="meta-item">
                  <span class="meta-icon">👤</span>
                  <span class="meta-text">{{ formatUser(ticket.user) }}</span>
                </span>
                <span class="meta-item">
                  <span class="meta-icon">📅</span>
                  <span class="meta-text">{{ formatDateTime(ticket.created_at) }}</span>
                </span>
              </div>
            </div>
            
            <div class="ticket-description-section">
              <h4 class="section-title">Descripción</h4>
              <div class="description-content">
                <p>{{ ticket.description }}</p>
              </div>
            </div>
          </div>
          
          <!-- Sidebar con información y acciones -->
          <div class="ticket-sidebar">
            <!-- Información del ticket -->
            <div class="sidebar-section">
              <h4 class="section-title">📋 Información del Ticket</h4>
              <div class="info-grid">
                <div class="info-item">
                  <span class="info-label">ID:</span>
                  <span class="info-value">#{{ ticket.id }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Estado:</span>
                  <span class="info-value">
                    <span class="status-indicator" :class="ticket.status"></span>
                    {{ getStatusLabel(ticket.status) }}
                  </span>
                </div>
                <div class="info-item">
                  <span class="info-label">Prioridad:</span>
                  <span class="info-value">
                    <span class="priority-indicator" :class="ticket.priority"></span>
                    {{ getPriorityLabel(ticket.priority) }}
                  </span>
                </div>
                <div class="info-item">
                  <span class="info-label">Categoría:</span>
                  <span class="info-value">{{ getCategoryLabel(ticket.category) }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Creado:</span>
                  <span class="info-value">{{ formatDate(ticket.created_at) }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Actualizado:</span>
                  <span class="info-value">{{ formatDate(ticket.updated_at) }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Respuestas:</span>
                  <span class="info-value">{{ ticket.response_count || 0 }}</span>
                </div>
              </div>
            </div>
            
            <!-- Personas involucradas -->
            <div class="sidebar-section">
              <h4 class="section-title">👥 Personas Involucradas</h4>
              
              <div class="person-card">
                <div class="person-header">
                  <div class="person-avatar">
                    <img :src="getUserAvatar(ticket.user)" :alt="ticket.user?.name" />
                  </div>
                  <div class="person-info">
                    <h5 class="person-name">{{ ticket.user?.name }}</h5>
                    <p class="person-role">Solicitante</p>
                  </div>
                </div>
                <div class="person-details">
                  <p class="person-email">📧 {{ ticket.user?.email }}</p>
                  <p class="person-meta">
                    <span class="meta-badge">{{ ticket.user?.role || 'Usuario' }}</span>
                  </p>
                </div>
                <button
                  class="btn-contact"
                  @click="contactUser(ticket.user)"
                  :disabled="loading"
                >
                  Contactar
                </button>
              </div>
              
              <div class="person-card" v-if="ticket.assigned_to">
                <div class="person-header">
                  <div class="person-avatar">
                    <img :src="getAdminAvatar(ticket.assigned_to)" :alt="ticket.assigned_to?.name" />
                  </div>
                  <div class="person-info">
                    <h5 class="person-name">{{ ticket.assigned_to?.name }}</h5>
                    <p class="person-role">Asignado a</p>
                  </div>
                </div>
                <div class="person-details">
                  <p class="person-email">📧 {{ ticket.assigned_to?.email }}</p>
                  <p class="person-meta">
                    <span class="meta-badge">Administrador</span>
                    <span class="meta-badge">{{ ticket.assigned_to?.assigned_tickets || 0 }} tickets</span>
                  </p>
                </div>
                <button
                  class="btn-reassign"
                  @click="assignTicket"
                  :disabled="loading"
                >
                  Reasignar
                </button>
              </div>
              
              <div v-else class="unassigned-card">
                <div class="unassigned-icon">👤</div>
                <div class="unassigned-content">
                  <h5>Sin asignar</h5>
                  <p>Este ticket no tiene asignado un administrador</p>
                </div>
                <button
                  class="btn-assign-now"
                  @click="assignTicket"
                  :disabled="loading"
                >
                  Asignar ahora
                </button>
              </div>
            </div>
            
            <!-- Etiquetas -->
            <div class="sidebar-section" v-if="ticket.tags && ticket.tags.length > 0">
              <h4 class="section-title">🏷️ Etiquetas</h4>
              <div class="tags-list">
                <span
                  v-for="(tag, index) in ticket.tags"
                  :key="index"
                  class="tag"
                  @click="filterByTag(tag)"
                >
                  {{ tag }}
                </span>
              </div>
            </div>
            
            <!-- Acciones rápidas -->
            <div class="sidebar-section">
              <h4 class="section-title">⚡ Acciones Rápidas</h4>
              <div class="quick-actions">
                <button
                  class="btn-quick-action"
                  @click="changePriority"
                  :disabled="loading"
                >
                  <span class="action-icon">⚡</span>
                  <span class="action-text">Cambiar Prioridad</span>
                </button>
                <button
                  class="btn-quick-action"
                  @click="changeStatus"
                  :disabled="loading"
                >
                  <span class="action-icon">🔄</span>
                  <span class="action-text">Cambiar Estado</span>
                </button>
                <button
                  class="btn-quick-action"
                  @click="addNote"
                  :disabled="loading"
                >
                  <span class="action-icon">📝</span>
                  <span class="action-text">Agregar Nota</span>
                </button>
                <button
                  class="btn-quick-action"
                  @click="exportTicket"
                  :disabled="loading"
                >
                  <span class="action-icon">📤</span>
                  <span class="action-text">Exportar Ticket</span>
                </button>
              </div>
            </div>
          </div>
        </div>
        
        <!-- Historial de comentarios -->
        <div class="comments-section">
          <div class="section-header">
            <h3 class="section-title">💬 Historial de Comentarios</h3>
            <span class="comment-count">{{ comments.length }} comentarios</span>
          </div>
          
          <div v-if="loadingComments" class="loading-comments">
            <div class="spinner"></div>
            <p>Cargando comentarios...</p>
          </div>
          
          <div v-else-if="comments.length === 0" class="no-comments">
            <div class="no-comments-icon">💬</div>
            <h4>No hay comentarios aún</h4>
            <p>Sé el primero en comentar sobre este ticket</p>
          </div>
          
          <div v-else class="comments-list">
            <div
              v-for="comment in sortedComments"
              :key="comment.id"
              class="comment-item"
              :class="{ 'is-admin': comment.is_admin, 'is-internal': comment.is_internal }"
            >
              <div class="comment-header">
                <div class="comment-author">
                  <img
                    :src="getCommenterAvatar(comment)"
                    :alt="comment.author_name"
                    class="comment-avatar"
                  />
                  <div class="author-info">
                    <h5 class="author-name">{{ comment.author_name }}</h5>
                    <div class="author-meta">
                      <span class="author-role">{{ comment.is_admin ? 'Administrador' : 'Usuario' }}</span>
                      <span class="comment-time">{{ formatDateTime(comment.created_at) }}</span>
                    </div>
                  </div>
                </div>
                <div class="comment-actions" v-if="canEditComment(comment)">
                  <button class="btn-comment-action" @click="editComment(comment)">
                    ✏️
                  </button>
                  <button class="btn-comment-action" @click="deleteComment(comment)">
                    🗑️
                  </button>
                </div>
              </div>
              
              <div class="comment-content">
                <div v-if="comment.is_internal" class="internal-note-badge">
                  📝 Nota interna
                </div>
                <p>{{ comment.content }}</p>
                
                <div v-if="comment.attachments && comment.attachments.length > 0" class="comment-attachments">
                  <div
                    v-for="(attachment, index) in comment.attachments"
                    :key="index"
                    class="attachment-item"
                    @click="viewAttachment(attachment)"
                  >
                    <span class="attachment-icon">📎</span>
                    <span class="attachment-name">{{ attachment.name }}</span>
                    <span class="attachment-size">{{ formatFileSize(attachment.size) }}</span>
                  </div>
                </div>
              </div>
              
              <div class="comment-footer">
                <span
                  v-if="comment.edited_at && comment.edited_at !== comment.created_at"
                  class="edited-badge"
                >
                  Editado {{ formatDateTime(comment.edited_at) }}
                </span>
              </div>
            </div>
          </div>
          
          <!-- Nuevo comentario -->
          <div class="new-comment-section">
            <div class="new-comment-header">
              <h4 class="section-title">Agregar Comentario</h4>
              <div class="comment-options">
                <label class="checkbox-label">
                  <input
                    type="checkbox"
                    v-model="newComment.is_internal"
                  />
                  <span class="checkbox-text">Nota interna (solo para admins)</span>
                </label>
              </div>
            </div>
            
            <div class="new-comment-editor">
              <textarea
                v-model="newComment.content"
                placeholder="Escribe tu comentario aquí..."
                rows="4"
                class="comment-textarea"
                :disabled="loading"
              ></textarea>
              
              <div class="editor-tools">
                <div class="toolbar">
                  <button
                    type="button"
                    class="tool-btn"
                    @click="insertText('**texto**')"
                    title="Negrita"
                  >
                    <strong>B</strong>
                  </button>
                  <button
                    type="button"
                    class="tool-btn"
                    @click="insertText('*texto*')"
                    title="Itálica"
                  >
                    <em>I</em>
                  </button>
                  <button
                    type="button"
                    class="tool-btn"
                    @click="insertText('`código`')"
                    title="Código"
                  >
                    <code>C</code>
                  </button>
                  <button
                    type="button"
                    class="tool-btn"
                    @click="showEmojiPicker = !showEmojiPicker"
                    title="Emoji"
                  >
                    😀
                  </button>
                </div>
                
                <div v-if="showEmojiPicker" class="emoji-picker">
                  <div class="emoji-grid">
                    <span
                      v-for="emoji in commonEmojis"
                      :key="emoji"
                      class="emoji"
                      @click="insertEmoji(emoji)"
                    >
                      {{ emoji }}
                    </span>
                  </div>
                </div>
              </div>
              
              <div class="attachments-preview" v-if="newComment.attachments.length > 0">
                <div
                  v-for="(file, index) in newComment.attachments"
                  :key="index"
                  class="attachment-preview"
                >
                  <span class="preview-icon">📎</span>
                  <span class="preview-name">{{ file.name }}</span>
                  <span class="preview-size">{{ formatFileSize(file.size) }}</span>
                  <button
                    type="button"
                    @click="removeAttachment(index)"
                    class="preview-remove"
                  >
                    ✕
                  </button>
                </div>
              </div>
              
              <div class="comment-actions">
                <div class="file-upload">
                  <label class="btn-attach">
                    <input
                      type="file"
                      @change="handleFileSelect"
                      multiple
                      :disabled="loading"
                      accept=".pdf,.doc,.docx,.jpg,.jpeg,.png,.txt"
                    />
                    📎 Adjuntar archivos
                  </label>
                  <span class="file-hint">Máx. 5MB por archivo</span>
                </div>
                
                <div class="submit-actions">
                  <button
                    type="button"
                    class="btn-cancel-comment"
                    @click="clearNewComment"
                    :disabled="loading"
                  >
                    Cancelar
                  </button>
                  <button
                    type="submit"
                    class="btn-submit-comment"
                    @click="submitComment"
                    :disabled="!newComment.content.trim() || loading"
                  >
                    <span v-if="loading" class="btn-spinner"></span>
                    <span v-else>Publicar Comentario</span>
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useAuthStore } from '@/stores/authStore'
import api from '@/axios'

interface User {
  id: number
  name: string
  email: string
  avatar_url?: string
  role: string
}

interface Admin {
  id: number
  name: string
  email: string
  avatar_url?: string
  assigned_tickets?: number
}

interface Comment {
  id: number
  content: string
  author_name: string
  author_id: number
  is_admin: boolean
  is_internal: boolean
  created_at: string
  edited_at?: string
  attachments?: Array<{
    name: string
    url: string
    size: number
    type: string
  }>
}

interface Ticket {
  id: number
  subject: string
  description: string
  category: string
  priority: string
  status: string
  user: User
  assigned_to?: Admin
  created_at: string
  updated_at: string
  response_count: number
  tags?: string[]
}

interface Props {
  ticket: Ticket
}

interface Emits {
  (e: 'update', updatedTicket: Ticket): void
  (e: 'close'): void
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()

const authStore = useAuthStore()
const loading = ref(false)
const loadingComments = ref(false)

// Comments
const comments = ref<Comment[]>([])
const newComment = ref({
  content: '',
  is_internal: false,
  attachments: [] as File[]
})

// UI states
const showEmojiPicker = ref(false)
const fileInput = ref<HTMLInputElement>()

// Common emojis for quick access
const commonEmojis = ['👍', '👎', '🎉', '😊', '😢', '😡', '🤔', '✅', '❌', '⚠️', '🚀', '🔧']

// Computed
const sortedComments = computed(() => {
  return [...comments.value].sort((a, b) => 
    new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
  )
})

// Lifecycle
onMounted(async () => {
  await loadComments()
})

// Methods
async function loadComments() {
  loadingComments.value = true
  try {
    const response = await api.get(`/admin/tickets/${props.ticket.id}/comments`, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    comments.value = response.data.data || []
  } catch (error) {
    console.error('Error cargando comentarios:', error)
  } finally {
    loadingComments.value = false
  }
}

function getStatusLabel(status: string): string {
  const labels: Record<string, string> = {
    open: 'Abierto',
    in_progress: 'En Progreso',
    pending: 'Pendiente',
    resolved: 'Resuelto',
    closed: 'Cerrado'
  }
  return labels[status] || status
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

function getUserAvatar(user?: User): string {
  if (user?.avatar_url) {
    return getImageUrl(`/uploads/${user.avatar_url}`)
  }
  return '/img/default-avatar.png'
}

function getAdminAvatar(admin?: Admin): string {
  if (admin?.avatar_url) {
    return getImageUrl(`/uploads/${admin.avatar_url}`)
  }
  return '/img/default-admin.png'
}

function getCommenterAvatar(comment: Comment): string {
  // Implementar lógica para obtener avatar del comentarista
  return comment.is_admin ? '/img/default-admin.png' : '/img/default-avatar.png'
}

function formatUser(user?: User): string {
  return user ? `${user.name} (${user.email})` : 'Usuario desconocido'
}

function formatDateTime(dateString: string): string {
  const date = new Date(dateString)
  return date.toLocaleString('es-ES', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

function formatDate(dateString: string): string {
  const date = new Date(dateString)
  return date.toLocaleDateString('es-ES', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric'
  })
}

function formatFileSize(bytes: number): string {
  if (bytes === 0) return '0 Bytes'
  const k = 1024
  const sizes = ['Bytes', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
}

function canEditComment(comment: Comment): boolean {
  return comment.author_id === authStore.user?.id || authStore.user?.role === 'admin'
}

// Comment actions
function insertText(text: string) {
  const textarea = document.querySelector('.comment-textarea') as HTMLTextAreaElement
  if (textarea) {
    const start = textarea.selectionStart
    const end = textarea.selectionEnd
    const selectedText = textarea.value.substring(start, end)
    const replacement = text.replace('texto', selectedText || 'texto')
    
    newComment.value.content = 
      textarea.value.substring(0, start) +
      replacement +
      textarea.value.substring(end)
    
    // Restaurar el foco y posición del cursor
    setTimeout(() => {
      textarea.focus()
      const newPosition = start + replacement.length
      textarea.setSelectionRange(newPosition, newPosition)
    }, 0)
  }
}

function insertEmoji(emoji: string) {
  newComment.value.content += emoji
  showEmojiPicker.value = false
}

function handleFileSelect(event: Event) {
  const input = event.target as HTMLInputElement
  if (input.files) {
    Array.from(input.files).forEach(file => {
      if (validateFile(file)) {
        newComment.value.attachments.push(file)
      }
    })
  }
  input.value = ''
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
  newComment.value.attachments.splice(index, 1)
}

async function submitComment() {
  if (!newComment.value.content.trim()) return
  
  loading.value = true
  
  try {
    const formData = new FormData()
    formData.append('content', newComment.value.content)
    formData.append('is_internal', newComment.value.is_internal.toString())
    
    // Agregar archivos adjuntos
    newComment.value.attachments.forEach((file, index) => {
      formData.append(`attachments[${index}]`, file)
    })
    
    const response = await api.post(
      `/admin/tickets/${props.ticket.id}/comments`,
      formData,
      {
        headers: {
          'Authorization': `Bearer ${authStore.token}`,
          'Content-Type': 'multipart/form-data'
        }
      }
    )
    
    comments.value.unshift(response.data.data)
    clearNewComment()
    
  } catch (error) {
    console.error('Error publicando comentario:', error)
  } finally {
    loading.value = false
  }
}

function clearNewComment() {
  newComment.value = {
    content: '',
    is_internal: false,
    attachments: []
  }
}

function editComment(comment: Comment) {
  // Implementar edición de comentario
  console.log('Editar comentario:', comment)
}

function deleteComment(comment: Comment) {
  if (confirm('¿Estás seguro de que deseas eliminar este comentario?')) {
    // Implementar eliminación de comentario
    console.log('Eliminar comentario:', comment)
  }
}

// Ticket actions
function confirmCloseTicket() {
  if (confirm('¿Estás seguro de que deseas cerrar este ticket?')) {
    closeTicket()
  }
}

async function closeTicket() {
  loading.value = true
  try {
    const response = await api.put(
      `/admin/tickets/${props.ticket.id}/close`,
      {},
      { headers: { Authorization: `Bearer ${authStore.token}` } }
    )
    
    emit('update', response.data.data)
  } catch (error) {
    console.error('Error cerrando ticket:', error)
  } finally {
    loading.value = false
  }
}

function assignTicket() {
  emit('close')
  // Este evento debería ser manejado por el padre para abrir el modal de asignación
}

function contactUser(user: User) {
  console.log('Contactar usuario:', user)
  // Implementar lógica de contacto
}

function changePriority() {
  console.log('Cambiar prioridad del ticket')
  // Implementar cambio de prioridad
}

function changeStatus() {
  console.log('Cambiar estado del ticket')
  // Implementar cambio de estado
}

function addNote() {
  newComment.value.is_internal = true
  // Enfocar el textarea
  const textarea = document.querySelector('.comment-textarea') as HTMLTextAreaElement
  if (textarea) {
    textarea.focus()
  }
}

function exportTicket() {
  console.log('Exportar ticket')
  // Implementar exportación
}

function filterByTag(tag: string) {
  console.log('Filtrar por etiqueta:', tag)
  // Implementar filtrado por etiqueta
}

function viewAttachment(attachment: any) {
  window.open(attachment.url, '_blank')
}

function close() {
  emit('close')
}
</script>

<style scoped>
/* Importante: El CSS es demasiado largo para mostrarlo completo aquí */
/* Pero necesitarás todos los estilos para que funcione correctamente */

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
  z-index: 2000;
  padding: 20px;
  backdrop-filter: blur(8px);
  animation: fadeIn 0.2s ease-out;
}

.ticket-detail-modal {
  background: white;
  width: 95%;
  max-width: 1400px;
  max-height: 95vh;
  border-radius: 24px;
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
    transform: translateY(40px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* Header styles */
.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px 32px;
  background: linear-gradient(135deg, #2c3e50 0%, #4a6491 100%);
  color: white;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.ticket-header-info {
  flex: 1;
}

.ticket-header-info h2 {
  margin: 0 0 12px 0;
  font-size: 1.8rem;
  font-weight: 700;
  display: flex;
  align-items: center;
  gap: 12px;
}

.ticket-status {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}

.status-badge,
.priority-badge {
  padding: 6px 16px;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.status-badge {
  background: rgba(255, 255, 255, 0.2);
  border: 1px solid rgba(255, 255, 255, 0.3);
}

.priority-badge {
  background: rgba(231, 76, 60, 0.9);
  border: 1px solid rgba(231, 76, 60, 0.5);
}

.status-badge.open { background: rgba(243, 156, 18, 0.9); }
.status-badge.in_progress { background: rgba(52, 152, 219, 0.9); }
.status-badge.pending { background: rgba(155, 89, 182, 0.9); }
.status-badge.resolved { background: rgba(46, 204, 113, 0.9); }
.status-badge.closed { background: rgba(149, 165, 166, 0.9); }

.priority-badge.low { background: rgba(46, 204, 113, 0.9); }
.priority-badge.medium { background: rgba(243, 156, 18, 0.9); }
.priority-badge.high { background: rgba(231, 76, 60, 0.9); }
.priority-badge.urgent { background: rgba(192, 57, 43, 0.9); }

.header-actions {
  display: flex;
  gap: 12px;
  align-items: center;
}

.btn-close-ticket,
.btn-assign {
  padding: 10px 20px;
  border-radius: 8px;
  font-weight: 600;
  font-size: 0.9rem;
  cursor: pointer;
  transition: all 0.3s;
  border: 2px solid rgba(255, 255, 255, 0.3);
  background: rgba(255, 255, 255, 0.1);
  color: white;
}

.btn-close-ticket:hover:not(:disabled),
.btn-assign:hover:not(:disabled) {
  background: rgba(255, 255, 255, 0.2);
  transform: translateY(-2px);
}

.btn-close-modal {
  background: rgba(255, 255, 255, 0.2);
  color: white;
  border: none;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  cursor: pointer;
  font-size: 18px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background 0.3s;
}

.btn-close-modal:hover {
  background: rgba(255, 255, 255, 0.3);
}

.modal-body {
  flex: 1;
  overflow-y: auto;
  padding: 32px;
}

.ticket-content {
  display: grid;
  grid-template-columns: 1fr 400px;
  gap: 32px;
  margin-bottom: 40px;
}

@media (max-width: 1200px) {
  .ticket-content {
    grid-template-columns: 1fr;
  }
}

/* Estilos para las secciones principales del ticket */
.ticket-main {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.ticket-subject-section {
  background: white;
  border-radius: 16px;
  padding: 24px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  border: 1px solid #f1f2f6;
}

.ticket-subject {
  margin: 0 0 16px 0;
  font-size: 1.8rem;
  color: #2d3436;
  line-height: 1.3;
}

.ticket-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 8px;
  background: #f8f9fa;
  padding: 8px 16px;
  border-radius: 20px;
  font-size: 0.9rem;
}

.meta-icon {
  opacity: 0.7;
}

.meta-text {
  color: #2d3436;
  font-weight: 500;
}

.ticket-description-section {
  background: white;
  border-radius: 16px;
  padding: 24px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  border: 1px solid #f1f2f6;
}

.section-title {
  margin: 0 0 16px 0;
  font-size: 1.2rem;
  color: #2d3436;
  display: flex;
  align-items: center;
  gap: 8px;
}

.description-content {
  color: #636e72;
  line-height: 1.6;
  font-size: 1rem;
}

.description-content p {
  margin: 0;
}

/* Sidebar styles */
.ticket-sidebar {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.sidebar-section {
  background: white;
  border-radius: 16px;
  padding: 24px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  border: 1px solid #f1f2f6;
}

.info-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 12px;
}

.info-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 0;
  border-bottom: 1px solid #f1f2f6;
}

.info-item:last-child {
  border-bottom: none;
}

.info-label {
  color: #636e72;
  font-size: 0.9rem;
  font-weight: 500;
}

.info-value {
  color: #2d3436;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 8px;
}

.status-indicator,
.priority-indicator {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  display: inline-block;
}

.status-indicator.open { background: #f39c12; }
.status-indicator.in_progress { background: #3498db; }
.status-indicator.pending { background: #9b59b6; }
.status-indicator.resolved { background: #2ecc71; }
.status-indicator.closed { background: #95a5a6; }

.priority-indicator.low { background: #2ecc71; }
.priority-indicator.medium { background: #f39c12; }
.priority-indicator.high { background: #e74c3c; }
.priority-indicator.urgent { background: #c0392b; }

/* Person card styles */
.person-card,
.unassigned-card {
  background: #f8f9fa;
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 16px;
  border: 2px solid transparent;
  transition: all 0.3s;
}

.person-card:hover {
  border-color: #3498db;
  transform: translateY(-2px);
}

.person-header {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 16px;
}

.person-avatar {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  overflow: hidden;
  border: 3px solid white;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
}

.person-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.person-info {
  flex: 1;
}

.person-name {
  margin: 0 0 4px 0;
  font-size: 1.1rem;
  color: #2d3436;
  font-weight: 600;
}

.person-role {
  margin: 0;
  color: #636e72;
  font-size: 0.9rem;
}

.person-details {
  margin-bottom: 16px;
}

.person-email {
  margin: 0 0 8px 0;
  color: #2d3436;
  font-size: 0.9rem;
}

.person-meta {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.meta-badge {
  background: #e3f2fd;
  color: #1976d2;
  padding: 4px 12px;
  border-radius: 15px;
  font-size: 0.8rem;
  font-weight: 500;
}

.btn-contact,
.btn-reassign,
.btn-assign-now {
  width: 100%;
  padding: 10px;
  border-radius: 8px;
  border: none;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-contact {
  background: #3498db;
  color: white;
}

.btn-reassign {
  background: #f39c12;
  color: white;
}

.btn-assign-now {
  background: #2ecc71;
  color: white;
}

.btn-contact:hover:not(:disabled),
.btn-reassign:hover:not(:disabled),
.btn-assign-now:hover:not(:disabled) {
  opacity: 0.9;
  transform: translateY(-2px);
}

/* Unassigned card */
.unassigned-card {
  display: flex;
  align-items: center;
  gap: 20px;
  border: 2px dashed #dfe6e9;
  background: #f8f9fa;
}

.unassigned-icon {
  font-size: 2.5rem;
  opacity: 0.5;
}

.unassigned-content {
  flex: 1;
}

.unassigned-content h5 {
  margin: 0 0 4px 0;
  color: #2d3436;
}

.unassigned-content p {
  margin: 0;
  color: #636e72;
  font-size: 0.9rem;
}

/* Tags list */
.tags-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.tag {
  background: #e3f2fd;
  color: #1976d2;
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s;
  border: 2px solid transparent;
}

.tag:hover {
  background: #bbdefb;
  border-color: #1976d2;
  transform: translateY(-2px);
}

/* Quick actions */
.quick-actions {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
}

.btn-quick-action {
  background: white;
  border: 2px solid #dfe6e9;
  padding: 12px;
  border-radius: 10px;
  cursor: pointer;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  transition: all 0.3s;
}

.btn-quick-action:hover:not(:disabled) {
  border-color: #3498db;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(52, 152, 219, 0.1);
}

.action-icon {
  font-size: 1.5rem;
}

.action-text {
  font-size: 0.85rem;
  color: #2d3436;
  font-weight: 500;
  text-align: center;
}

/* Comments section */
.comments-section {
  background: white;
  border-radius: 16px;
  padding: 32px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  border: 1px solid #f1f2f6;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.comment-count {
  background: #e3f2fd;
  color: #1976d2;
  padding: 6px 16px;
  border-radius: 20px;
  font-weight: 600;
  font-size: 0.9rem;
}

/* Loading comments */
.loading-comments {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px;
}

.loading-comments .spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #f3f3f3;
  border-top: 4px solid #3498db;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 16px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* No comments */
.no-comments {
  text-align: center;
  padding: 60px 40px;
}

.no-comments-icon {
  font-size: 64px;
  margin-bottom: 20px;
  opacity: 0.3;
}

.no-comments h4 {
  margin: 0 0 12px 0;
  color: #2d3436;
}

.no-comments p {
  margin: 0;
  color: #636e72;
}

/* Comments list */
.comments-list {
  display: flex;
  flex-direction: column;
  gap: 24px;
  margin-bottom: 32px;
}

.comment-item {
  background: white;
  border-radius: 12px;
  padding: 24px;
  border: 2px solid #f1f2f6;
  transition: all 0.3s;
}

.comment-item:hover {
  border-color: #dfe6e9;
}

.comment-item.is-admin {
  border-left: 4px solid #3498db;
}

.comment-item.is-internal {
  background: #fff3e0;
  border-color: #ffcc80;
}

.comment-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 16px;
}

.comment-author {
  display: flex;
  align-items: center;
  gap: 16px;
}

.comment-avatar {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  object-fit: cover;
  border: 3px solid white;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

.author-info {
  flex: 1;
}

.author-name {
  margin: 0 0 4px 0;
  font-size: 1.1rem;
  color: #2d3436;
  font-weight: 600;
}

.author-meta {
  display: flex;
  gap: 16px;
  align-items: center;
}

.author-role {
  background: #e3f2fd;
  color: #1976d2;
  padding: 4px 12px;
  border-radius: 15px;
  font-size: 0.8rem;
  font-weight: 500;
}

.comment-time {
  color: #636e72;
  font-size: 0.85rem;
}

.comment-actions {
  display: flex;
  gap: 8px;
}

.btn-comment-action {
  background: white;
  border: 1px solid #dfe6e9;
  width: 32px;
  height: 32px;
  border-radius: 8px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  transition: all 0.3s;
}

.btn-comment-action:hover {
  background: #f8f9fa;
  border-color: #3498db;
  color: #3498db;
}

.comment-content {
  margin-bottom: 16px;
}

.internal-note-badge {
  background: #ffcc80;
  color: #e65100;
  padding: 6px 16px;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 600;
  display: inline-block;
  margin-bottom: 12px;
}

.comment-content p {
  margin: 0;
  color: #2d3436;
  line-height: 1.6;
  font-size: 1rem;
}

.comment-attachments {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-top: 16px;
}

.attachment-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  background: #f8f9fa;
  border-radius: 8px;
  border: 1px solid #e0e6ed;
  cursor: pointer;
  transition: all 0.3s;
}

.attachment-item:hover {
  background: #e3f2fd;
  border-color: #3498db;
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

.comment-footer {
  padding-top: 16px;
  border-top: 1px solid #f1f2f6;
}

.edited-badge {
  color: #636e72;
  font-size: 0.85rem;
  font-style: italic;
}

/* New comment section */
.new-comment-section {
  background: #f8f9fa;
  border-radius: 12px;
  padding: 24px;
  border: 2px dashed #dfe6e9;
}

.new-comment-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.comment-options {
  display: flex;
  gap: 16px;
}

.checkbox-label {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
}

.checkbox-label input[type="checkbox"] {
  width: 18px;
  height: 18px;
  cursor: pointer;
}

.checkbox-text {
  color: #636e72;
  font-size: 0.9rem;
  font-weight: 500;
}

.new-comment-editor {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.comment-textarea {
  width: 100%;
  padding: 16px;
  border: 2px solid #dfe6e9;
  border-radius: 10px;
  font-size: 1rem;
  font-family: inherit;
  resize: vertical;
  min-height: 120px;
  transition: border-color 0.3s;
  background: white;
}

.comment-textarea:focus {
  outline: none;
  border-color: #3498db;
  box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
}

.comment-textarea:disabled {
  background: #f8f9fa;
  cursor: not-allowed;
}

.editor-tools {
  position: relative;
}

.toolbar {
  display: flex;
  gap: 8px;
}

.tool-btn {
  background: white;
  border: 1px solid #dfe6e9;
  width: 36px;
  height: 36px;
  border-radius: 8px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  transition: all 0.3s;
}

.tool-btn:hover {
  background: #f8f9fa;
  border-color: #3498db;
  color: #3498db;
}

.emoji-picker {
  position: absolute;
  top: 100%;
  left: 0;
  background: white;
  border: 1px solid #dfe6e9;
  border-radius: 12px;
  padding: 16px;
  margin-top: 8px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
  z-index: 10;
  animation: slideDown 0.2s ease-out;
}

@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.emoji-grid {
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  gap: 8px;
}

.emoji {
  font-size: 1.5rem;
  cursor: pointer;
  padding: 8px;
  border-radius: 8px;
  transition: all 0.3s;
  text-align: center;
}

.emoji:hover {
  background: #f8f9fa;
  transform: scale(1.2);
}

.attachments-preview {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.attachment-preview {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  background: white;
  border-radius: 8px;
  border: 2px solid #dfe6e9;
}

.preview-icon {
  font-size: 1.2rem;
}

.preview-name {
  flex: 1;
  font-weight: 500;
  color: #2d3436;
  font-size: 0.9rem;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.preview-size {
  color: #636e72;
  font-size: 0.85rem;
  white-space: nowrap;
}

.preview-remove {
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

.preview-remove:hover {
  background: #ffcdd2;
}

.comment-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.file-upload {
  display: flex;
  align-items: center;
  gap: 12px;
}

.btn-attach {
  background: white;
  border: 2px solid #dfe6e9;
  color: #2d3436;
  padding: 10px 20px;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s;
  position: relative;
}

.btn-attach:hover {
  border-color: #3498db;
  color: #3498db;
}

.btn-attach input[type="file"] {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  opacity: 0;
  cursor: pointer;
}

.file-hint {
  color: #636e72;
  font-size: 0.85rem;
}

.submit-actions {
  display: flex;
  gap: 12px;
}

.btn-cancel-comment {
  background: white;
  color: #2d3436;
  border: 2px solid #dfe6e9;
  padding: 10px 20px;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-cancel-comment:hover:not(:disabled) {
  border-color: #b2bec3;
  background: #f8f9fa;
}

.btn-submit-comment {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 10px 32px;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  transition: all 0.3s;
  min-width: 160px;
}

.btn-submit-comment:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
}

.btn-submit-comment:disabled {
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

/* Responsive styles */
@media (max-width: 768px) {
  .modal-header {
    flex-direction: column;
    align-items: stretch;
    gap: 16px;
    padding: 20px;
  }
  
  .header-actions {
    width: 100%;
    justify-content: space-between;
  }
  
  .modal-body {
    padding: 20px;
  }
  
  .ticket-content {
    gap: 20px;
  }
  
  .ticket-subject {
    font-size: 1.5rem;
  }
  
  .ticket-meta {
    flex-direction: column;
    gap: 8px;
  }
  
  .quick-actions {
    grid-template-columns: 1fr;
  }
  
  .comment-actions {
    flex-direction: column;
    gap: 16px;
    align-items: stretch;
  }
  
  .file-upload,
  .submit-actions {
    width: 100%;
    justify-content: center;
  }
  
  .btn-attach,
  .btn-cancel-comment,
  .btn-submit-comment {
    width: 100%;
    justify-content: center;
  }
}
</style>
