<template>
  <Teleport to="body">
    <Transition
      enter-active-class="soporte-modal-enter-active"
      leave-active-class="soporte-modal-leave-active"
      enter-from-class="soporte-modal-enter-from"
      leave-to-class="soporte-modal-leave-to"
    >
      <div v-if="modelValue" class="soporte-modal-overlay" @click.self="handleOverlayClick">
        <div 
          class="soporte-ticket-modal"
          ref="modalRef"
          role="dialog"
          aria-modal="true"
          :aria-labelledby="`ticket-modal-title-${ticket?.id}`"
        >
          <!-- Header del Modal -->
          <div class="soporte-modal-header">
            <h2 :id="`ticket-modal-title-${ticket?.id}`" class="soporte-modal-title">
              <span class="soporte-modal-icon">🎫</span>
              Detalles del Ticket #{{ ticket?.id }}
            </h2>
            <button 
              class="soporte-modal-close" 
              @click="closeModal"
              aria-label="Cerrar modal"
              ref="closeButtonRef"
            >
              <span class="soporte-close-icon">×</span>
            </button>
          </div>

          <!-- Contenido del Modal -->
          <div class="soporte-modal-content" v-if="ticket">
            <!-- Información del Ticket -->
            <div class="soporte-ticket-info-section">
              <div class="soporte-info-row">
                <div class="soporte-info-label">Asunto:</div>
                <div class="soporte-info-value">{{ ticket.subject }}</div>
              </div>

              <div class="soporte-info-row">
                <div class="soporte-info-label">Estado:</div>
                <div class="soporte-info-value">
                  <span class="soporte-status-badge" :class="statusColorClass(ticket.status)">
                    {{ statusLabel(ticket.status) }}
                  </span>
                </div>
              </div>

              <div class="soporte-info-row">
                <div class="soporte-info-label">ID del Ticket:</div>
                <div class="soporte-info-value soporte-ticket-id">#{{ ticket.id }}</div>
              </div>

              <div class="soporte-info-row">
                <div class="soporte-info-label">Última actualización:</div>
                <div class="soporte-info-value">
                  <span class="soporte-date-with-icon">
                    <span class="soporte-icon-small">📅</span>
                    {{ formatDate(ticket.updated_at) }}
                  </span>
                </div>
              </div>

              <div class="soporte-info-row" v-if="ticket.created_at">
                <div class="soporte-info-label">Fecha de creación:</div>
                <div class="soporte-info-value">
                  <span class="soporte-date-with-icon">
                    <span class="soporte-icon-small">📝</span>
                    {{ formatDate(ticket.created_at) }}
                  </span>
                </div>
              </div>

              <div class="soporte-info-row" v-if="ticket.priority">
                <div class="soporte-info-label">Prioridad:</div>
                <div class="soporte-info-value">
                  <span class="soporte-priority-badge" :class="priorityClass(ticket.priority)">
                    {{ ticket.priority }}
                  </span>
                </div>
              </div>
            </div>

   <!-- Último Mensaje - VERSIÓN FLEXIBLE -->
<div class="soporte-message-section">
  <h3 class="soporte-section-title-small">
    <span class="soporte-section-icon">💬</span>
    Último Mensaje
  </h3>
  <div class="soporte-message-card">
    <!-- Intenta múltiples campos posibles -->
    <p class="soporte-message-text">
      {{ ticket.last_message || ticket.description || ticket.message || 'No hay mensaje disponible' }}
    </p>
    <div class="soporte-message-meta">
      <span class="soporte-message-time">{{ formatDate(ticket.updated_at || ticket.created_at) }}</span>
    </div>
  </div>
</div>


<!-- Historial del Ticket -->
<div class="soporte-history-section" v-if="history.length > 0">
  <h3 class="soporte-section-title-small">
    <span class="soporte-section-icon">📋</span>
    Respuestas ({{ history.length }})
  </h3>
  <div class="soporte-history-timeline">
    <div
      v-for="(reply, index) in history"
      :key="reply.id || index"
      class="soporte-timeline-item"
      :class="{ 'is-admin': reply.user_type === 'admin' || reply.is_admin }"
    >
      <div class="soporte-timeline-dot"></div>
      <div class="soporte-timeline-content">
        <div class="soporte-timeline-header">
          <span class="soporte-timeline-author">{{ reply.user_name || 'Usuario' }}</span>
          <span class="soporte-timeline-badge" v-if="reply.user_type === 'admin' || reply.is_admin">Admin</span>
          <span class="soporte-timeline-date">{{ formatDate(reply.created_at) }}</span>
        </div>
        <p class="soporte-timeline-message">{{ reply.message }}</p>
      </div>
    </div>
  </div>
</div>
<div class="soporte-history-section" v-else>
  <p class="soporte-empty-text">No hay respuestas aún</p>
</div>
           


            <!-- Acciones del Ticket -->
            <div class="soporte-actions-section">
            
<!-- Campo de respuesta (se muestra al hacer clic en Responder) -->
<div class="soporte-reply-section" v-if="showReplyInput">
  <h3 class="soporte-section-title-small">
    <span class="soporte-section-icon">✍️</span>
    Escribe tu respuesta
  </h3>
  <textarea
    v-model="replyMessage"
    class="soporte-reply-textarea"
    placeholder="Escribe tu mensaje aquí..."
    rows="4"
    :disabled="sendingReply"
  ></textarea>
  <div class="soporte-reply-actions">
    <button
      class="soporte-btn-secondary"
      @click="showReplyInput = false"
      :disabled="sendingReply"
    >
      Cancelar
    </button>
    <button
      class="soporte-btn-primary"
      @click="sendReply"
      :disabled="sendingReply || !replyMessage.trim()"
    >
      <span v-if="sendingReply" class="soporte-spinner-small"></span>
      <span v-else>📨</span>
      Enviar respuesta
    </button>
  </div>
</div>

  <h3 class="soporte-section-title-small">
                <span class="soporte-section-icon">⚡</span>
                Acciones
              </h3>
              <div class="soporte-action-buttons">
                <button 
                  class="soporte-action-btn soporte-btn-reply" 
                  @click="replyToTicket"
                  :disabled="loading"
                  :aria-label="`Responder al ticket #${ticket.id}`"
                >
                  <span class="soporte-btn-icon">↩️</span>
                  Responder
                </button>
                
                <button
                  v-if="ticket.status !== 'completed' && ticket.status !== 'cancelled'"
                  class="soporte-action-btn soporte-btn-close"
                  @click="closeTicket"
                  :disabled="loading"
                  :aria-label="`Cerrar ticket #${ticket.id}`"
                >
                  <span class="soporte-btn-icon">✅</span>
                  Cerrar Ticket
                </button>

                <button 
                  class="soporte-action-btn soporte-btn-copy" 
                  @click="copyTicketId"
                  :aria-label="`Copiar ID del ticket #${ticket.id}`"
                >
                  <span class="soporte-btn-icon">📋</span>
                  Copiar ID
                </button>
              </div>
            </div>
          </div>

          <!-- Footer del Modal -->
          <div class="soporte-modal-footer">
            <button 
              class="soporte-btn-secondary" 
              @click="closeModal"
              :disabled="loading"
            >
              Cerrar
            </button>
            <button 
              class="soporte-btn-primary" 
              @click="openChat"
              :disabled="loading"
            >
              <span class="soporte-btn-icon">💬</span>
              Abrir Chat
            </button>
          </div>

          <!-- Loading Overlay -->
          <div v-if="loading" class="soporte-modal-loading">
            <div class="soporte-spinner"></div>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script>
import { ref, watch, nextTick } from 'vue'
import { useToast } from '../../composables/useToast'

export default {
  name: 'SoporteTicketModal',
  props: {
    modelValue: {
      type: Boolean,
      required: true
    },
    ticket: {
      type: Object,
      default: null
    },
    history: {
      type: Array,
      default: () => []
    },
    loading: {
      type: Boolean,
      default: false
    }
  },
  emits: [
    'update:modelValue',
    'reply',
    'send-reply',
    'close-ticket',
    'copy-id',
    'open-chat'
  ],
  setup(props, { emit }) {
    const modalRef = ref(null)
    const closeButtonRef = ref(null)
    const replyMessage = ref('')
    const showReplyInput = ref(false)
    const sendingReply = ref(false)
    const { success, error } = useToast()

    // Manejar foco cuando se abre/cierra el modal
    watch(() => props.modelValue, async (newVal) => {
      if (newVal) {
        document.body.style.overflow = 'hidden'
        // Resetear al abrir
        replyMessage.value = ''
        showReplyInput.value = false
        sendingReply.value = false
        await nextTick()
        closeButtonRef.value?.focus()
      } else {
        document.body.style.overflow = 'auto'
      }
    })

    const closeModal = () => {
      emit('update:modelValue', false)
    }

    const handleOverlayClick = () => {
      closeModal()
    }

    const statusColorClass = (status) => {
      const colorMap = {
        completed: 'soporte-status-completed',
        cancelled: 'soporte-status-cancelled',
        rejected: 'soporte-status-rejected',
        finalized: 'soporte-status-finalized',
        open: 'soporte-status-open',
        pending: 'soporte-status-pending',
        in_progress: 'soporte-status-in-progress'
      }
      return colorMap[status] || 'soporte-status-default'
    }

    const statusLabel = (status) => {
      const key = 'status.' + status
      const translated = props.$t?.(key) || key
      return translated === key ? status : translated
    }

    const priorityClass = (priority) => {
      const colorMap = {
        high: 'soporte-priority-high',
        medium: 'soporte-priority-medium',
        low: 'soporte-priority-low',
        urgent: 'soporte-priority-urgent'
      }
      return colorMap[priority] || 'soporte-priority-default'
    }

    const formatDate = (date) => {
      if (!date) return ''
      const locale = props.$i18n?.locale?.value || 'es'
      try {
        return new Date(date).toLocaleString(locale, {
          year: 'numeric',
          month: 'long',
          day: 'numeric',
          hour: '2-digit',
          minute: '2-digit'
        })
      } catch {
        return date
      }
    }

    const formatShortDate = (date) => {
      if (!date) return ''
      const locale = props.$i18n?.locale?.value || 'es'
      try {
        return new Date(date).toLocaleString(locale, {
          month: 'short',
          day: 'numeric',
          hour: '2-digit',
          minute: '2-digit'
        })
      } catch {
        return date
      }
    }

    // ✅ CORREGIDO: Muestra/oculta el campo de texto para responder
    const replyToTicket = () => {
      showReplyInput.value = !showReplyInput.value
      if (showReplyInput.value) {
        // Scroll al campo de texto
        setTimeout(() => {
          const textarea = document.querySelector('.soporte-reply-textarea')
          if (textarea) {
            textarea.focus()
            textarea.scrollIntoView({ behavior: 'smooth', block: 'center' })
          }
        }, 100)
      }
    }

    // ✅ NUEVO: Enviar la respuesta al backend
    const sendReply = () => {
      const message = replyMessage.value.trim()
      if (!message) {
        error('Escribe un mensaje para responder')
        return
      }

      sendingReply.value = true
      emit('send-reply', {
        ticket: props.ticket,
        message: message
      })

      // Limpiar después de enviar
      setTimeout(() => {
        replyMessage.value = ''
        showReplyInput.value = false
        sendingReply.value = false
        success('Respuesta enviada correctamente')
      }, 500)
    }

    const closeTicket = () => {
      emit('close-ticket', props.ticket)
    }

    const copyTicketId = async () => {
      try {
        await navigator.clipboard.writeText(`#${props.ticket.id}`)
        success('ID del ticket copiado al portapapeles')
        emit('copy-id', props.ticket)
      } catch (err) {
        console.error('Error al copiar:', err)
        error('No se pudo copiar el ID del ticket')
      }
    }

    const openChat = () => {
      emit('open-chat', props.ticket)
    }

    return {
      modalRef,
      closeButtonRef,
      replyMessage,
      showReplyInput,
      sendingReply,
      closeModal,
      handleOverlayClick,
      statusColorClass,
      statusLabel,
      priorityClass,
      formatDate,
      formatShortDate,
      replyToTicket,
      sendReply,
      closeTicket,
      copyTicketId,
      openChat
    }
  }
}
</script>

<style scoped>
/* Campo de respuesta */
.soporte-reply-section {
  background: #f0f7ff;
  border-radius: 1rem;
  padding: 1.25rem;
  margin-bottom: 1.5rem;
  border: 1px solid #d0e3ff;
}

.soporte-reply-textarea {
  width: 100%;
  border: 1px solid #d0d7de;
  border-radius: 0.75rem;
  padding: 0.75rem;
  font-size: 0.9rem;
  font-family: inherit;
  resize: vertical;
  min-height: 80px;
  transition: border-color 0.2s;
  box-sizing: border-box;
}

.soporte-reply-textarea:focus {
  outline: none;
  border-color: #3498db;
  box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.15);
}

.soporte-reply-actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.75rem;
  margin-top: 0.75rem;
}

.soporte-spinner-small {
  display: inline-block;
  width: 16px;
  height: 16px;
  border: 2px solid rgba(255,255,255,0.3);
  border-top: 2px solid white;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

.soporte-modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 1rem;
}

.soporte-ticket-modal {
  background: white;
  border-radius: 1.5rem;
  width: 100%;
  max-width: 700px;
  max-height: 90vh;
  overflow-y: auto;
  position: relative;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
}

.soporte-modal-header {
  padding: 1.5rem;
  border-bottom: 1px solid #f0f0f0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  position: sticky;
  top: 0;
  background: white;
  border-radius: 1.5rem 1.5rem 0 0;
  z-index: 10;
}

.soporte-modal-title {
  font-size: 1.25rem;
  font-weight: 600;
  color: #1a1a1a;
  margin: 0;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.soporte-modal-close {
  background: none;
  border: none;
  font-size: 1.5rem;
  color: #666;
  cursor: pointer;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 9999px;
  transition: all 0.2s;
}

.soporte-modal-close:hover {
  background: #f0f0f0;
  color: #1a1a1a;
}

.soporte-modal-content {
  padding: 1.5rem;
}

.soporte-ticket-info-section {
  background: #f8f9fa;
  border-radius: 1rem;
  padding: 1.25rem;
  margin-bottom: 1.5rem;
}

.soporte-info-row {
  display: flex;
  margin-bottom: 0.75rem;
}

.soporte-info-row:last-child {
  margin-bottom: 0;
}

.soporte-info-label {
  width: 140px;
  font-size: 0.9rem;
  color: #666;
  flex-shrink: 0;
}

.soporte-info-value {
  flex: 1;
  font-size: 0.9rem;
  color: #1a1a1a;
  font-weight: 500;
}

.soporte-status-badge {
  display: inline-block;
  padding: 0.25rem 0.75rem;
  border-radius: 2rem;
  font-size: 0.8rem;
  font-weight: 500;
}

.soporte-priority-badge {
  display: inline-block;
  padding: 0.25rem 0.75rem;
  border-radius: 2rem;
  font-size: 0.8rem;
  font-weight: 500;
  background: #f0f0f0;
  color: #666;
  text-transform: uppercase;
}

.soporte-priority-high { background: #ffebee; color: #c62828; }
.soporte-priority-medium { background: #fff3e0; color: #ef6c00; }
.soporte-priority-low { background: #e8f5e9; color: #2e7d32; }
.soporte-priority-urgent { background: #ffebee; color: #b71c1c; }

.soporte-message-section,
.soporte-history-section,
.soporte-actions-section {
  margin-bottom: 1.5rem;
}

.soporte-section-title-small {
  font-size: 1rem;
  font-weight: 600;
  color: #1a1a1a;
  margin: 0 0 1rem 0;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.soporte-message-card {
  background: #f8f9fa;
  border-radius: 1rem;
  padding: 1.25rem;
}

.soporte-message-text {
  font-size: 0.95rem;
  color: #1a1a1a;
  margin: 0 0 0.75rem 0;
  line-height: 1.6;
}

.soporte-message-meta {
  display: flex;
  justify-content: flex-end;
}

.soporte-message-time {
  font-size: 0.8rem;
  color: #999;
}

.soporte-history-timeline {
  position: relative;
  padding-left: 1.5rem;
}

.soporte-timeline-item {
  position: relative;
  padding-bottom: 1.5rem;
}

.soporte-timeline-item:last-child {
  padding-bottom: 0;
}

.soporte-timeline-dot {
  position: absolute;
  left: -1.5rem;
  top: 0.25rem;
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background: #3498db;
  border: 2px solid white;
  box-shadow: 0 0 0 2px #e0e0e0;
}

.soporte-timeline-item:not(:last-child)::before {
  content: '';
  position: absolute;
  left: -1.25rem;
  top: 1rem;
  bottom: 0;
  width: 2px;
  background: #e0e0e0;
}

.soporte-timeline-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.35rem;
}

.soporte-timeline-event {
  font-size: 0.9rem;
  font-weight: 500;
  color: #1a1a1a;
}

.soporte-timeline-date {
  font-size: 0.75rem;
  color: #999;
}

.soporte-timeline-description {
  font-size: 0.85rem;
  color: #666;
  margin: 0;
  line-height: 1.4;
}

.soporte-action-buttons {
  display: flex;
  gap: 0.75rem;
  flex-wrap: wrap;
}

.soporte-action-btn {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.6rem 1.2rem;
  border: 1px solid #e0e0e0;
  background: white;
  border-radius: 2rem;
  font-size: 0.9rem;
  color: #1a1a1a;
  cursor: pointer;
  transition: all 0.2s;
}

.soporte-action-btn:hover:not(:disabled) {
  background: #f8f9fa;
  border-color: #d0d0d0;
  transform: translateY(-1px);
}

.soporte-action-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.soporte-btn-reply {
  background: #e3f2fd;
  border-color: #bbdefb;
  color: #1565c0;
}

.soporte-btn-reply:hover:not(:disabled) {
  background: #bbdefb;
}

.soporte-btn-close {
  background: #ffebee;
  border-color: #ffcdd2;
  color: #c62828;
}

.soporte-btn-close:hover:not(:disabled) {
  background: #ffcdd2;
}

.soporte-btn-copy {
  background: #f5f5f5;
  border-color: #e0e0e0;
}

.soporte-modal-footer {
  padding: 1.5rem;
  border-top: 1px solid #f0f0f0;
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  position: sticky;
  bottom: 0;
  background: white;
  border-radius: 0 0 1.5rem 1.5rem;
  z-index: 10;
}

.soporte-btn-secondary,
.soporte-btn-primary {
  padding: 0.6rem 1.5rem;
  border-radius: 2rem;
  font-size: 0.9rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
  border: none;
}

.soporte-btn-secondary {
  background: #f0f0f0;
  color: #666;
}

.soporte-btn-secondary:hover:not(:disabled) {
  background: #e0e0e0;
  color: #1a1a1a;
}

.soporte-btn-primary {
  background: #3498db;
  color: white;
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
}

.soporte-btn-primary:hover:not(:disabled) {
  background: #2980b9;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(52, 152, 219, 0.3);
}

.soporte-btn-primary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.soporte-modal-loading {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(255, 255, 255, 0.8);
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 1.5rem;
  z-index: 20;
}

.soporte-spinner {
  width: 40px;
  height: 40px;
  border: 3px solid #f3f3f3;
  border-top: 3px solid #3498db;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* Transiciones del modal */
.soporte-modal-enter-active,
.soporte-modal-leave-active {
  transition: all 0.3s ease;
}

.soporte-modal-enter-from,
.soporte-modal-leave-to {
  opacity: 0;
}

.soporte-modal-enter-from .soporte-ticket-modal,
.soporte-modal-leave-to .soporte-ticket-modal {
  transform: scale(0.95);
}

/* Responsive */
@media (max-width: 768px) {
  .soporte-ticket-modal {
    max-height: 100vh;
    border-radius: 0;
  }

  .soporte-modal-overlay {
    padding: 0;
  }

  .soporte-info-row {
    flex-direction: column;
    margin-bottom: 1rem;
  }

  .soporte-info-label {
    width: auto;
    margin-bottom: 0.25rem;
    font-size: 0.8rem;
  }

  .soporte-action-buttons {
    flex-direction: column;
  }

  .soporte-action-btn {
    width: 100%;
    justify-content: center;
  }
}
</style>
