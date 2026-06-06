<template>
  <div class="soporte-page">
    <!-- Toast Container -->
    <SoporteToastContainer />

    <!-- FAQ Section -->
    <div class="soporte-section-card" v-if="!loadingFaq">
      <div class="soporte-section-header">
        <h1 class="soporte-section-title">
          <span class="soporte-icon">❓</span> {{ $t('faq') }}
        </h1>
        <p class="soporte-section-subtitle">Preguntas frecuentes y respuestas rápidas</p>
      </div>

      <div class="soporte-faq-grid">
        <SoporteFaqItem
          v-for="item in faqItems"
          :key="item.id"
          :item="item"
          :is-active="activeFaq === item.id"
          @toggle="toggleFaq"
        />
      </div>
    </div>

    <!-- Loading FAQ State -->
    <SoporteLoading v-if="loadingFaq" />

    <!-- Support Button -->
    <div class="soporte-support-actions">
      <button
        class="soporte-btn-support-chat"
        @click="openSupportChat"
        aria-label="Abrir chat de soporte"
      >
        <span class="soporte-btn-icon">💬</span>
        <span class="soporte-btn-text">{{ $t('contact_support') }}</span>
      </button>
    </div>

    <!-- Tickets Section -->
    <div class="soporte-section-card" v-if="!loadingTickets">
      <div class="soporte-section-header">
        <h1 class="soporte-section-title">
          <span class="soporte-icon">🎫</span> {{ $t('my_tickets') }}
        </h1>
        <p class="soporte-section-subtitle">Historial de tickets de soporte</p>
      </div>

      <!-- Empty State -->
      <div v-if="tickets.length === 0" class="soporte-empty-state">
        <div class="soporte-empty-icon">📭</div>
        <h3 class="soporte-empty-title">{{ $t('no_support_tickets') }}</h3>
        <p class="soporte-empty-description">No hay tickets de soporte registrados</p>
      </div>

      <!-- Tickets Grid -->
      <div v-else class="soporte-tickets-grid">
        <SoporteTicketCard
          v-for="ticket in tickets"
          :key="ticket.id"
          :ticket="ticket"
          @click="openTicketModal"
        />
      </div>
    </div>

    <!-- Loading Tickets State -->
    <SoporteLoading v-if="loadingTickets" />

    <!-- Floating Action Button -->
    <button
      v-show="!showNewTicket"
      class="soporte-floating-btn"
      :aria-label="$t('new_ticket')"
      @click="createNewTicket"
    >
      <span class="soporte-plus-icon">+</span>
    </button>

    <!-- Ticket Modal -->
    <SoporteTicketModal
  v-model="showModal"
  :ticket="selectedTicket"
  :history="ticketHistory"
  :loading="modalLoading"
  @reply="handleReplyTicket"
  @send-reply="handleSendReply"
  @close-ticket="handleCloseTicket"
  @copy-id="handleCopyId"
  @open-chat="openChatWithTicket"
/>
  </div>
</template>

<script>
import { ref, computed, watch, onBeforeUnmount } from 'vue'
import { useToast } from '../../composables/useToast'
import SoporteFaqItem from './SoporteFaqItem.vue'
import SoporteTicketCard from './SoporteTicketCard.vue'
import SoporteLoading from './SoporteLoading.vue'
import SoporteTicketModal from './SoporteTicketModal.vue'
import SoporteToastContainer from './SoporteToastContainer.vue'

export default {
  name: 'Soporte',
  components: {
    SoporteFaqItem,
    SoporteTicketCard,
    SoporteLoading,
    SoporteTicketModal,
    SoporteToastContainer
  },
  props: {
    tickets: {
      type: Array,
      required: true,
      validator: (value) => {
        return Array.isArray(value) && value.every(ticket =>
          ticket && ticket.id && ticket.subject && ticket.status
        )
      }
    },
    faqItems: {
      type: Array,
      required: true,
      validator: (value) => {
        return Array.isArray(value) && value.every(item =>
          item && item.id && item.question && item.answer
        )
      }
    },
    loadingTickets: { type: Boolean, default: false },
    loadingFaq: { type: Boolean, default: false },
    showNewTicket: { type: Boolean, default: false },
    ticketHistoryData: {
      type: Object,
      default: () => ({})
    }
  },
  emits: [
    'open-support-chat',
    'show-new-ticket',
    'open-ticket',
    'reply-ticket',
    'send-reply',
    'close-ticket',
    'copy-ticket-id',
    'open-chat-with-ticket'
  ],
  setup(props, { emit }) {
    const activeFaq = ref(null)
    const showModal = ref(false)
    const selectedTicket = ref(null)
    const modalLoading = ref(false)
    const { success, error, info } = useToast()

    const ticketHistory = computed(() => {
      if (!selectedTicket.value) return []
      return props.ticketHistoryData[selectedTicket.value.id] || []
    })

    onBeforeUnmount(() => {
      document.body.style.overflow = 'auto'
    })

    watch(showModal, (newVal) => {
      if (!newVal) {
        selectedTicket.value = null
      }
    })

    const toggleFaq = (id) => {
      activeFaq.value = activeFaq.value === id ? null : id
    }

    const openSupportChat = () => {
      emit('open-support-chat')
      info('Conectando con el equipo de soporte...')
    }

    const createNewTicket = () => {
      emit('show-new-ticket')
    }

    const openTicketModal = async (ticket) => {
      selectedTicket.value = ticket
      modalLoading.value = true
      showModal.value = true

      try {
        emit('open-ticket', ticket)
      } catch (err) {
        error('Error al cargar los detalles del ticket')
        console.error('Error loading ticket:', err)
      } finally {
        modalLoading.value = false
      }
    }

    // ✅ CORREGIDO: "Responder" ya no abre chat, solo muestra el campo de texto
    const handleReplyTicket = (ticket) => {
      console.log('🔵 Mostrando campo de respuesta para ticket:', ticket.id)
      // El campo de texto se maneja dentro del modal (showReplyInput)
      // No es necesario hacer nada aquí, el modal ya tiene la lógica
    }

    // ✅ NUEVO: Enviar la respuesta al backend vía DashboardProvider
    const handleSendReply = (payload) => {
      console.log('🔵 Enviando respuesta al ticket:', payload.ticket.id)
      emit('send-reply', payload)
    }

    const handleCloseTicket = async (ticket) => {
      console.log('🔵 Cerrando ticket:', ticket.id)

      if (confirm('¿Estás seguro de que deseas cerrar este ticket?')) {
        try {
          modalLoading.value = true
          emit('close-ticket', ticket)
          await new Promise(resolve => setTimeout(resolve, 1000))
          success('Ticket cerrado exitosamente')
          setTimeout(() => {
            showModal.value = false
            modalLoading.value = false
          }, 500)
        } catch (err) {
          error('Error al cerrar el ticket')
          console.error('Error closing ticket:', err)
          modalLoading.value = false
        }
      }
    }

    const handleCopyId = (ticket) => {
      console.log('🔵 Copiando ID del ticket:', ticket.id)
      emit('copy-ticket-id', ticket)
      success('ID copiado al portapapeles')
    }

    const openChatWithTicket = (ticket) => {
      console.log('🔵 Abriendo chat en vivo para ticket:', ticket.id)
      emit('open-chat-with-ticket', ticket)
      info('Abriendo conversación en vivo con soporte...')
      setTimeout(() => {
        showModal.value = false
      }, 500)
    }

    return {
      activeFaq,
      showModal,
      selectedTicket,
      modalLoading,
      ticketHistory,
      toggleFaq,
      openSupportChat,
      createNewTicket,
      openTicketModal,
      handleReplyTicket,
      handleSendReply,
      handleCloseTicket,
      handleCopyId,
      openChatWithTicket
    }
  }
}
</script>

<style scoped>
/* Tus estilos existentes - se mantienen igual */
.soporte-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 1rem;
}

.soporte-section-card {
  background: #f8f9fa;
  border-radius: 1.5rem;
  padding: 1.5rem;
  margin-bottom: 2rem;
}

.soporte-section-header {
  margin-bottom: 1.5rem;
}

.soporte-section-title {
  font-size: 1.5rem;
  font-weight: 600;
  color: #1a1a1a;
  margin: 0 0 0.35rem 0;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.soporte-section-subtitle {
  font-size: 0.9rem;
  color: #666;
  margin: 0;
}

.soporte-icon {
  font-size: 1.5rem;
}

.soporte-faq-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 1rem;
}

.soporte-tickets-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 1rem;
}

.soporte-support-actions {
  display: flex;
  justify-content: center;
  margin: 2rem 0;
}

.soporte-btn-support-chat {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 2rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 2rem;
  font-size: 1rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
}

.soporte-btn-support-chat:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.5);
}

.soporte-btn-support-chat:active {
  transform: translateY(0);
}

.soporte-empty-state {
  text-align: center;
  padding: 3rem 1rem;
}

.soporte-empty-icon {
  font-size: 3rem;
  margin-bottom: 1rem;
  opacity: 0.5;
}

.soporte-empty-title {
  font-size: 1.1rem;
  font-weight: 500;
  color: #666;
  margin: 0 0 0.5rem 0;
}

.soporte-empty-description {
  font-size: 0.9rem;
  color: #999;
  margin: 0;
}

.soporte-floating-btn {
  position: fixed;
  bottom: 2rem;
  right: 2rem;
  width: 56px;
  height: 56px;
  border-radius: 50%;
  background: #3498db;
  color: white;
  border: none;
  box-shadow: 0 4px 15px rgba(52, 152, 219, 0.4);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s ease;
  z-index: 100;
}

.soporte-floating-btn:hover {
  transform: scale(1.1);
  background: #2980b9;
  box-shadow: 0 6px 20px rgba(52, 152, 219, 0.5);
}

.soporte-plus-icon {
  font-size: 24px;
  font-weight: 300;
  line-height: 1;
}

@media (max-width: 768px) {
  .soporte-page {
    padding: 1rem;
  }

  .soporte-section-card {
    padding: 1rem;
  }

  .soporte-faq-grid,
  .soporte-tickets-grid {
    grid-template-columns: 1fr;
  }

  .soporte-floating-btn {
    bottom: 1rem;
    right: 1rem;
  }
}
</style>
