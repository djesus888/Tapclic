<template>
  <div class="modal-overlay" @click.self="close">
    <div class="modal-container ticket-detail-modal">
      <!-- Header -->
      <div class="modal-header">
        <div class="header-title">
          <h2>Ticket #{{ ticket?.id }}: {{ ticket?.subject }}</h2>
          <span class="status-badge" :class="ticket?.status">
            {{ getStatusLabel(ticket?.status) }}
          </span>
        </div>
        <button class="close-btn" @click="close">✕</button>
      </div>

      <!-- Contenido -->
      <div class="modal-body">
        <!-- Información del usuario -->
        <div class="user-info-section">
          <div class="user-avatar">
            <img :src="getUserAvatar(ticket?.user)" alt="User" />
          </div>
          <div class="user-details">
            <h3>{{ ticket?.user?.name }}</h3>
            <p>{{ ticket?.user?.email }}</p>
            <p class="ticket-date">Creado: {{ formatDate(ticket?.created_at) }}</p>
          </div>
          <div class="ticket-meta">
            <span class="priority-badge" :class="ticket?.priority">
              {{ getPriorityLabel(ticket?.priority) }}
            </span>
            <span class="category-badge">{{ getCategoryLabel(ticket?.category) }}</span>
          </div>
        </div>

        <!-- Mensaje original -->
        <div class="original-message">
          <h4>Mensaje:</h4>
          <div class="message-content">
            {{ ticket?.description }}
          </div>
        </div>

        <!-- Historial de respuestas -->
        <div class="replies-section" v-if="replies.length > 0">
          <h4>Conversación:</h4>
          <div class="replies-list">
            <div
              v-for="reply in replies"
              :key="reply.id"
              class="reply-item"
              :class="{ 'admin-reply': reply.user_type === 'admin' }"
            >
              <div class="reply-header">
                <strong>{{ reply.user_name }}</strong>
                <span class="reply-date">{{ formatDateTime(reply.created_at) }}</span>
              </div>
              <div class="reply-content">{{ reply.message }}</div>
            </div>
          </div>
        </div>

        <!-- Formulario de respuesta -->
        <div class="reply-form" v-if="ticket?.status !== 'closed'">
          <h4>Responder:</h4>
          <textarea
            v-model="replyMessage"
            placeholder="Escribe tu respuesta..."
            rows="4"
            class="reply-textarea"
          ></textarea>
          <div class="reply-actions">
            <button class="btn-secondary" @click="close">Cancelar</button>
            <button
              class="btn-primary"
              @click="sendReply"
              :disabled="!replyMessage.trim() || sending"
            >
              <span v-if="sending" class="spinner"></span>
              <span v-else>Enviar respuesta</span>
            </button>
          </div>
        </div>

        <div v-else class="ticket-closed-message">
          <p>Este ticket está cerrado. No se pueden enviar más respuestas.</p>
          <button class="btn-primary" @click="reopenTicket">Reabrir ticket</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import api from '@/axios'
import { useAuthStore } from '@/stores/authStore'
import Swal from 'sweetalert2'

const props = defineProps<{
  ticket: any
}>()

const emit = defineEmits(['update', 'close'])

const authStore = useAuthStore()
const replies = ref<any[]>([])
const replyMessage = ref('')
const sending = ref(false)
const loading = ref(true)

// Cargar respuestas al montar
onMounted(async () => {
  await loadReplies()
})

async function loadReplies() {
  loading.value = true
  try {
    const response = await api.get(`/admin/tickets/${props.ticket.id}/replies`, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    replies.value = response.data.data || []
  } catch (error) {
    console.error('Error cargando respuestas:', error)
  } finally {
    loading.value = false
  }
}

async function sendReply() {
  if (!replyMessage.value.trim()) return

  sending.value = true
  try {
    const response = await api.post(`/admin/tickets/${props.ticket.id}/respond`, {
      message: replyMessage.value
    }, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })

    // Agregar respuesta a la lista
    replies.value.push({
      id: Date.now(),
      user_id: authStore.user?.id,
      user_name: authStore.user?.name,
      user_type: 'admin',
      message: replyMessage.value,
      created_at: new Date().toISOString()
    })

    replyMessage.value = ''
    
    Swal.fire({
      icon: 'success',
      title: 'Respuesta enviada',
      timer: 2000,
      showConfirmButton: false
    })

    emit('update', { ...props.ticket, last_response_at: new Date().toISOString() })

  } catch (error: any) {
    Swal.fire({
      icon: 'error',
      title: 'Error',
      text: error.response?.data?.error || 'Error al enviar respuesta'
    })
  } finally {
    sending.value = false
  }
}

async function reopenTicket() {
  try {
    await api.put(`/admin/tickets/${props.ticket.id}/status`, {
      status: 'open'
    }, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })

    Swal.fire({
      icon: 'success',
      title: 'Ticket reabierto',
      timer: 2000
    })

    emit('update', { ...props.ticket, status: 'open' })
    close()

  } catch (error: any) {
    Swal.fire({
      icon: 'error',
      title: 'Error',
      text: error.response?.data?.error || 'Error al reabrir ticket'
    })
  }
}

function close() {
  emit('close')
}

// Helpers
function getStatusLabel(status: string): string {
  const labels: Record<string, string> = {
    open: 'Abierto',
    pending: 'Pendiente',
    in_progress: 'En Progreso',
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
    feature: 'Solicitud'
  }
  return labels[category] || category
}

function getUserAvatar(user: any): string {
  if (user?.avatar_url) {
   return getImageUrl(user.avatar_url, 'avatar')
  }
  return '/img/default-avatar.png'
}

function formatDate(date: string): string {
  return new Date(date).toLocaleDateString('es-ES')
}

function formatDateTime(date: string): string {
  return new Date(date).toLocaleString('es-ES')
}
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
}

.modal-container {
  background: white;
  border-radius: 12px;
  width: 90%;
  max-width: 800px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
}

.ticket-detail-modal .modal-header {
  padding: 20px;
  border-bottom: 1px solid #e0e0e0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  position: sticky;
  top: 0;
  background: white;
}

.header-title {
  display: flex;
  align-items: center;
  gap: 12px;
}

.header-title h2 {
  margin: 0;
  font-size: 1.25rem;
}

.close-btn {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  color: #666;
}

.modal-body {
  padding: 20px;
}

.user-info-section {
  display: flex;
  gap: 16px;
  padding: 16px;
  background: #f8f9fa;
  border-radius: 8px;
  margin-bottom: 20px;
}

.user-avatar img {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  object-fit: cover;
}

.user-details {
  flex: 1;
}

.user-details h3 {
  margin: 0 0 4px;
}

.user-details p {
  margin: 2px 0;
  color: #666;
}

.ticket-date {
  font-size: 0.9em;
  color: #999;
}

.ticket-meta {
  display: flex;
  gap: 8px;
  align-items: center;
}

.status-badge, .priority-badge, .category-badge {
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 0.85rem;
  font-weight: 500;
}

.status-badge.open { background: #e3f2fd; color: #1976d2; }
.status-badge.pending { background: #fff3e0; color: #f57c00; }
.status-badge.in_progress { background: #e8f5e9; color: #388e3c; }
.status-badge.resolved { background: #e8f5e9; color: #388e3c; }
.status-badge.closed { background: #eeeeee; color: #616161; }

.priority-badge.low { background: #e8f5e9; color: #2e7d32; }
.priority-badge.medium { background: #fff3e0; color: #f57c00; }
.priority-badge.high { background: #ffebee; color: #c62828; }
.priority-badge.urgent { background: #ffebee; color: #b71c1c; font-weight: bold; }

.original-message {
  padding: 16px;
  background: #f5f5f5;
  border-radius: 8px;
  margin-bottom: 20px;
}

.original-message h4 {
  margin: 0 0 8px;
  color: #333;
}

.message-content {
  white-space: pre-wrap;
  line-height: 1.6;
}

.replies-section {
  margin-bottom: 20px;
}

.replies-section h4 {
  margin: 0 0 12px;
}

.replies-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.reply-item {
  padding: 12px;
  background: #f5f5f5;
  border-radius: 8px;
}

.reply-item.admin-reply {
  background: #e3f2fd;
  margin-left: 20px;
}

.reply-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
  font-size: 0.9em;
}

.reply-date {
  color: #666;
}

.reply-content {
  white-space: pre-wrap;
  line-height: 1.6;
}

.reply-form {
  padding: 16px;
  background: #f8f9fa;
  border-radius: 8px;
}

.reply-form h4 {
  margin: 0 0 12px;
}

.reply-textarea {
  width: 100%;
  padding: 12px;
  border: 1px solid #ddd;
  border-radius: 6px;
  margin-bottom: 12px;
  font-family: inherit;
  resize: vertical;
}

.reply-actions {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
}

.btn-primary, .btn-secondary {
  padding: 10px 20px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
  transition: all 0.2s;
}

.btn-primary {
  background: #4F46E5;
  color: white;
}

.btn-primary:hover:not(:disabled) {
  background: #4338CA;
}

.btn-primary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-secondary {
  background: #f0f0f0;
  color: #333;
}

.btn-secondary:hover {
  background: #e0e0e0;
}

.ticket-closed-message {
  text-align: center;
  padding: 20px;
  background: #f5f5f5;
  border-radius: 8px;
}

.spinner {
  display: inline-block;
  width: 16px;
  height: 16px;
  border: 2px solid rgba(255,255,255,0.3);
  border-radius: 50%;
  border-top-color: white;
  animation: spin 1s ease-in-out infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}
</style>
