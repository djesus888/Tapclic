<template>
  <div class="chats-page">
    <div class="header">
      <div class="title-section">
        <h1><span class="chat-icon">💬</span> Mis Conversaciones</h1>
        <p>Mensajes con proveedores y clientes</p>
      </div>
      <div class="actions" v-if="conversationStore.conversations?.length > 0">
        <div class="online-indicator">
          <span class="dot" :class="{ 'online': isConnected }"></span>
          <span>{{ isConnected ? 'Conectado' : 'Desconectado' }}</span>
          <span v-if="onlineCount > 0" class="online-count">
            ({{ onlineCount }} online)
          </span>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div
      v-if="!conversationStore.conversations || conversationStore.conversations.length === 0"
      class="empty-state"
    >
      <div class="empty-icon">📭</div>
      <h2>No tienes conversaciones todavía</h2>
      <p>Inicia una conversación con un proveedor o cliente</p>
      <div class="empty-actions">
        <router-link to="/services" class="btn-primary">
          Explorar servicios
        </router-link>
        <router-link to="/providers" class="btn-secondary">
          Ver proveedores
        </router-link>
      </div>
    </div>

    <!-- Chats Grid -->
    <div v-else class="chats-container">
      <!-- Stats Summary -->
      <div class="summary-stats">
        <div class="stat-item">
          <div class="stat-icon">💬</div>
          <div class="stat-content">
            <h3>{{ conversationStore.conversations?.length || 0 }}</h3>
            <p>Conversaciones</p>
          </div>
        </div>
        <div class="stat-item">
          <div class="stat-icon">📨</div>
          <div class="stat-content">
            <h3>{{ totalUnread }}</h3>
            <p>Mensajes sin leer</p>
          </div>
        </div>
        <div class="stat-item">
          <div class="stat-icon">👥</div>
          <div class="stat-content">
            <h3>{{ uniqueParticipants }}</h3>
            <p>Contactos únicos</p>
          </div>
        </div>
        <div class="stat-item online-stat" @click="showOnlineOnly = !showOnlineOnly">
          <div class="stat-icon">👤</div>
          <div class="stat-content">
            <h3>{{ onlineCount }}</h3>
            <p>Contactos online</p>
            <span class="filter-badge" v-if="showOnlineOnly">Filtrando online</span>
          </div>
        </div>
      </div>
      <!-- Filters -->
      <div class="filters-section">
        <div class="filter-group">
          <label for="role-filter">Filtrar por tipo:</label>
          <select
            id="role-filter"
            v-model="selectedRole"
            class="filter-select"
          >
            <option value="">Todos los contactos</option>
            <option value="provider">Proveedores</option>
            <option value="client">Clientes</option>
          </select>
        </div>
        <div class="filter-group">
          <label for="sort-filter">Ordenar por:</label>
          <select
            id="sort-filter"
            v-model="sortBy"
            class="filter-select"
          >
            <option value="recent">Más recientes</option>
            <option value="unread">No leídos primero</option>
            <option value="name">Nombre (A-Z)</option>
            <option value="online">Online primero</option>
          </select>
        </div>
        <div class="filter-group">
          <label for="search">Buscar conversación:</label>
          <input
            type="text"
            id="search"
            v-model="searchQuery"
            placeholder="Buscar por nombre..."
            class="search-input"
          >
        </div>

        <div class="filter-group toggle-group">
          <label class="toggle-label">
            <input
              type="checkbox"
              v-model="showOnlineOnly"
              class="toggle-checkbox"
            >
            <span class="toggle-text">Mostrar solo online</span>
          </label>
        </div>
      </div>
      <!-- Conversations Grid -->
      <div class="conversations-grid">
        <div
          v-for="conv in filteredConversations"
          :key="conv.id"
          class="conversation-card"
          @click="openChat(conv.id)"
          :class="{
            'unread': conv.unreadCount > 0,
            'online-contact': isUserOnline(interlocutor(conv)?.id)
          }"
        >
          <!-- Unread Badge -->
          <div v-if="conv.unreadCount > 0" class="unread-badge">
            {{ conv.unreadCount }} nuevo{{ conv.unreadCount > 1 ? 's' : '' }}
          </div>

          <!-- Avatar & Online Status -->
          <div class="avatar-container">
            <img
              :src="avatarUrl(interlocutor(conv)?.avatar_url || interlocutor(conv)?.avatar)"
              class="user-avatar"
              :alt="interlocutor(conv)?.name || 'Usuario'"
              @error="handleImageError"
            >
            <span
              class="online-dot"
              :class="{ 'online': isUserOnline(interlocutor(conv)?.id) }"
              :title="isUserOnline(interlocutor(conv)?.id) ? 'En línea' : 'Desconectado'"
            ></span>
          </div>

          <!-- Conversation Content -->
          <div class="conversation-content">
            <div class="conversation-header">
              <div class="user-info">
                <div class="user-name-wrapper">
                  <h3 class="user-name">{{ interlocutor(conv)?.name || 'Usuario' }}</h3>
                  <span class="online-badge" v-if="isUserOnline(interlocutor(conv)?.id)">
                    EN LÍNEA
                  </span>
                </div>
                <span class="user-role capitalize">
                  {{ interlocutor(conv)?.role === 'provider' ? 'Proveedor' : 'Cliente' }}
                </span>
              </div>
              <span class="time-ago">
                {{
                  conv.lastMessage?.created_at
                    ? formatDistanceToNow(new Date(conv.lastMessage.created_at), { addSuffix: true, locale: es })
                    : ''
                }}
              </span>
            </div>

            <!-- Último mensaje con status -->
            <div class="last-message-wrapper">
              <p class="last-message">
                <span v-if="conv.lastMessage?.sender_id === authStore.user?.id" class="you-indicator">
                  Tú:
                </span>
                {{ truncateMessage(getLastMessageText(conv), 60) }}
              </p>

              <!-- Status del último mensaje -->
              <span v-if="conv.lastMessage?.sender_id === authStore.user?.id"
                    class="message-status"
                    :class="getLastMessageStatusClass(conv)">
                {{ getLastMessageStatusIcon(conv) }}
              </span>
            </div>

            <!-- Typing Indicator -->
            <div v-if="isTyping(conv.id)" class="typing-indicator">
              <span class="typing-dots">
                <span class="dot"></span>
                <span class="dot"></span>
                <span class="dot"></span>
              </span>
              <span class="typing-text">escribiendo...</span>
            </div>
            <!-- Message Preview (cuando no hay último mensaje) -->
            <div class="message-preview" v-else-if="!conv.lastMessage">
              <span class="message-text">Sin mensajes todavía...</span>
            </div>
          </div>
          <!-- Quick Actions -->
          <div class="quick-actions">
            <button
              class="btn-quick"
              @click.stop="markAsRead(conv)"
              :title="conv.unreadCount > 0 ? 'Marcar como leído' : 'Ya leído'"
              :disabled="conv.unreadCount === 0"
            >
              {{ conv.unreadCount > 0 ? '👁️' : '✓' }}
            </button>
            <button
              class="btn-quick"
              @click.stop="toggleFavorite(conv.id)"
              :title="isFavorite(conv.id) ? 'Quitar de favoritos' : 'Agregar a favoritos'"
            >
              {{ isFavorite(conv.id) ? '⭐' : '☆' }}
            </button>
          </div>
        </div>
      </div>

      <!-- Footer Actions -->
      <div class="footer-actions">
        <button class="action-btn" @click="startNewConversation">
          <span class="btn-icon">+</span> Nueva conversación
        </button>
        <button class="action-btn secondary" @click="markAllAsRead">
          <span class="btn-icon">✓</span> Marcar todo como leído
        </button>
      </div>
    </div>

    <!-- Toast Notification -->
    <Transition name="toast">
      <div v-if="toast.show" class="toast" :class="toast.type">
        {{ toast.message }}
      </div>
    </Transition>
  </div>
</template>

<script setup>
/* ------------------------------------
 * Imports
 * ------------------------------------ */
import { onMounted, onUnmounted, ref, computed, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useConversationStore } from '@/stores/conversationStore'
import { getImageUrl } from '@/utils/imageHelper'
import { useAuthStore } from '@/stores/authStore'
import { useSocketStore } from '@/stores/socketStore'
import { useOnlineUsersStore } from '@/stores/onlineUsersStore'
import { formatDistanceToNow } from 'date-fns'
import { es } from 'date-fns/locale'

/* ------------------------------------
 * Stores & Router
 * ------------------------------------ */
const authStore = useAuthStore()
const conversationStore = useConversationStore()
const socketStore = useSocketStore()
const onlineUsersStore = useOnlineUsersStore()
const router = useRouter()

/* ------------------------------------
 * Reactive State
 * ------------------------------------ */
const selectedRole = ref('')
const sortBy = ref('recent')
const searchQuery = ref('')
const showOnlineOnly = ref(false)
const typingStatus = ref(new Map())
const favoriteConversations = ref(new Set(loadFavorites()))

// Toast notifications
const toast = ref({
  show: false,
  message: '',
  type: 'success'
})

/* ------------------------------------
 * Computed Properties
 * ------------------------------------ */
const isConnected = computed(() => socketStore.isConnected)
const onlineCount = computed(() => onlineUsersStore.onlineCount)

const totalUnread = computed(() => {
  if (!conversationStore.conversations) return 0
  return conversationStore.conversations.reduce((total, conv) => total + (conv.unreadCount || 0), 0)
})

const uniqueParticipants = computed(() => {
  if (!conversationStore.conversations) return 0
  const ids = new Set()
  conversationStore.conversations.forEach(conv => {
    const interlocutorId = interlocutor(conv)?.id
    if (interlocutorId) ids.add(interlocutorId)
  })
  return ids.size
})

const filteredConversations = computed(() => {
  if (!conversationStore.conversations) return []
  let conversations = [...conversationStore.conversations]

  // Filtrar por rol
  if (selectedRole.value) {
    conversations = conversations.filter(conv =>
      interlocutor(conv)?.role === selectedRole.value
    )
  }

  // Filtrar por búsqueda
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    conversations = conversations.filter(conv =>
      interlocutor(conv)?.name?.toLowerCase().includes(query)
    )
  }

  // Filtrar solo online
  if (showOnlineOnly.value) {
    conversations = conversations.filter(conv =>
      isUserOnline(interlocutor(conv)?.id)
    )
  }

  // Ordenar
  switch (sortBy.value) {
    case 'recent':
      conversations.sort((a, b) => {
        const dateA = a.lastMessage?.created_at ? new Date(a.lastMessage.created_at) : new Date(0)
        const dateB = b.lastMessage?.created_at ? new Date(b.lastMessage.created_at) : new Date(0)
        return dateB - dateA
      })
      break
    case 'unread':
      conversations.sort((a, b) => (b.unreadCount || 0) - (a.unreadCount || 0))
      break
    case 'name':
      conversations.sort((a, b) =>
        (interlocutor(a)?.name || '').localeCompare(interlocutor(b)?.name || '')
      )
      break
    case 'online':
      conversations.sort((a, b) => {
        const aOnline = isUserOnline(interlocutor(a)?.id)
        const bOnline = isUserOnline(interlocutor(b)?.id)
        if (aOnline && !bOnline) return -1
        if (!aOnline && bOnline) return 1
        return 0
      })
      break
  }

  return conversations
})

/* ------------------------------------
 * Lifecycle
 * ------------------------------------ */
onMounted(() => {
  // Inicializar socket si hay token
  if (authStore.token) {
    socketStore.init()
  }
  // Cargar conversaciones
  conversationStore.fetchConversations()

  // Escuchar eventos de typing
  window.addEventListener('user_typing', handleTypingEvent)
  window.addEventListener('new_message', handleNewMessage)

  // Escuchar actualizaciones de mensajes
  window.addEventListener('message_delivered', handleMessageDelivered)
  window.addEventListener('message_read', handleMessageRead)
})

onUnmounted(() => {
  window.removeEventListener('user_typing', handleTypingEvent)
  window.removeEventListener('new_message', handleNewMessage)
  window.removeEventListener('message_delivered', handleMessageDelivered)
  window.removeEventListener('message_read', handleMessageRead)
})

/* ------------------------------------
 * Watchers
 * ------------------------------------ */
watch(() => authStore.token, (newToken) => {
  if (newToken) {
    socketStore.init()
  }
})

/* ------------------------------------
 * Methods
 * ------------------------------------ */
function openChat(conversationId) {
  router.push(`/chat/${conversationId}`)
}

function interlocutor(conv) {
  if (!conv) {
    return { id: null, name: 'Usuario', role: 'user', avatar_url: null }
  }
  // Usar other_participant si existe (estructura de conversationStore)
  if (conv.other_participant) {
    return {
      id: conv.other_participant.id,
      name: conv.other_participant.name,
      role: conv.other_participant.role,
      avatar_url: conv.other_participant.avatar_url
    }
  }
  // Fallback a participants
  if (conv.participants && conv.participants.length > 0) {
    const other = conv.participants.find(p => p.id !== authStore.user?.id) || conv.participants[0]
    return {
      id: other?.id,
      name: other?.name,
      role: other?.role,
      avatar_url: other?.avatar_url || other?.avatar
    }
  }
  return { id: null, name: 'Usuario', role: 'user', avatar_url: null }
}

function avatarUrl(avatar) {
  if (!avatar) return '/img/default-avatar.png'
  if (avatar.startsWith('http')) return avatar
  return getImageUrl(avatar, 'avatar')
}

function truncateMessage(message, length) {
  if (!message) return ''
  return message.length > length ? message.substring(0, length) + '...' : message
}

/* Obtener texto del último mensaje */
function getLastMessageText(conv) {
  if (!conv.lastMessage) return 'Sin mensajes todavía...'
  if (conv.lastMessage.type === 'image') return '📷 Imagen'
  if (conv.lastMessage.type === 'file') return '📎 Archivo'
  return conv.lastMessage.text || ''
}

/* Obtener clase de status del último mensaje */
function getLastMessageStatusClass(conv) {
  if (!conv.lastMessage) return ''
  if (conv.lastMessage.is_read) return 'status-read'
  if (conv.lastMessage.is_delivered) return 'status-delivered'
  return 'status-sent'
}

/* Obtener ícono de status del último mensaje */
function getLastMessageStatusIcon(conv) {
  if (!conv.lastMessage) return ''
  if (conv.lastMessage.is_read) return '✓✓'
  if (conv.lastMessage.is_delivered) return '✓✓'
  return '✓'
}

function getMessageTypeIcon(type) {
  const icons = {
    image: '📷',
    file: '📎',
    audio: '🎤',
    video: '🎥'
  }
  return icons[type] || '💬'
}

/* ------------------------------------
 * Online Presence
 * ------------------------------------ */
function isUserOnline(userId) {
  if (!userId) return false
  return onlineUsersStore.isUserOnline(userId)
}

/* ------------------------------------
 * Typing Indicator
 * ------------------------------------ */
function handleTypingEvent(event) {
  const { from, isTyping } = event.detail
  typingStatus.value.set(from, { isTyping, timestamp: Date.now() })

  // Limpiar después de 3 segundos si no hay más eventos
  setTimeout(() => {
    const current = typingStatus.value.get(from)
    if (current && Date.now() - current.timestamp > 3000) {
      typingStatus.value.delete(from)
    }
  }, 3000)
}

function handleNewMessage(event) {
  // Recargar conversaciones cuando llega un nuevo mensaje
  conversationStore.fetchConversations()
}

/* Manejar mensajes entregados */
function handleMessageDelivered(event) {
  const { conversation_id, message_id } = event.detail || {}
  // Actualizar la vista si es necesario
  conversationStore.fetchConversations()
}

/* Manejar mensajes leídos */
function handleMessageRead(event) {
  const { conversation_id, message_ids } = event.detail || {}
  // Actualizar la vista si es necesario
  conversationStore.fetchConversations()
}

function isTyping(conversationId) {
  const conv = conversationStore.conversations?.find(c => c.id === conversationId)
  if (!conv) return false
  const otherUser = interlocutor(conv)?.id
  return typingStatus.value.get(otherUser)?.isTyping || false
}

/* ------------------------------------
 * Message Actions
 * ------------------------------------ */
function markAsRead(conversation) {
  if (!conversation || conversation.unreadCount === 0) return
  // Buscar mensajes no leídos de esta conversación
  const unreadMessageIds = conversationStore.messages?.[conversation.id]
    ?.filter(m => !m.is_read && m.sender !== authStore.user?.role)
    .map(m => m.id) || []

  if (unreadMessageIds.length > 0) {
    conversationStore.markAsRead(conversation.id, unreadMessageIds)
    showToast('Conversación marcada como leída', 'success')
  }
}

function markAllAsRead() {
  if (!conversationStore.conversations) return
  const promises = conversationStore.conversations.map(conv => {
    if (conv.unreadCount > 0) {
      const unreadMessageIds = conversationStore.messages?.[conv.id]
        ?.filter(m => !m.is_read && m.sender !== authStore.user?.role)
        .map(m => m.id) || []

      if (unreadMessageIds.length > 0) {
        return conversationStore.markAsRead(conv.id, unreadMessageIds)
      }
    }
    return Promise.resolve()
  })

  Promise.all(promises).then(() => {
    showToast('Todas las conversaciones marcadas como leídas', 'success')
  })
}

/* ------------------------------------
 * Favorites (usando localStorage)
 * ------------------------------------ */
function loadFavorites() {
  try {
    const saved = localStorage.getItem('favorite_conversations')
    return saved ? JSON.parse(saved) : []
  } catch {
    return []
  }
}

function saveFavorites() {
  localStorage.setItem('favorite_conversations',
    JSON.stringify(Array.from(favoriteConversations.value))
  )
}

function toggleFavorite(conversationId) {
  if (favoriteConversations.value.has(conversationId)) {
    favoriteConversations.value.delete(conversationId)
    showToast('Conversación quitada de favoritos', 'info')
  } else {
    favoriteConversations.value.add(conversationId)
    showToast('Conversación agregada a favoritos', 'success')
  }
  saveFavorites()
}

function isFavorite(conversationId) {
  return favoriteConversations.value.has(conversationId)
}

/* ------------------------------------
 * Utility Methods
 * ------------------------------------ */
function startNewConversation() {
  router.push('/providers')
}

function handleImageError(event) {
  event.target.src = '/img/default-avatar.png'
}

function showToast(message, type = 'info') {
  toast.value = { show: true, message, type }
  setTimeout(() => {
    toast.value.show = false
  }, 3000)
}
</script>

<style scoped>
/* Agrega aquí tus estilos si los necesitas */
.capitalize {
  text-transform: capitalize;
}

.conversations-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 1rem;
  padding: 1rem;
}

.conversation-card {
  background: white;
  border-radius: 12px;
  padding: 1rem;
  cursor: pointer;
  transition: all 0.2s ease;
  border: 1px solid #e5e7eb;
  position: relative;
}

.conversation-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.conversation-card.unread {
  background: #fef3c7;
  border-left: 4px solid #f59e0b;
}

.unread-badge {
  position: absolute;
  top: 0.5rem;
  right: 0.5rem;
  background: #ef4444;
  color: white;
  border-radius: 20px;
  padding: 0.25rem 0.75rem;
  font-size: 0.75rem;
  font-weight: bold;
}

.avatar-container {
  position: relative;
  width: 50px;
  height: 50px;
  margin-right: 1rem;
}

.user-avatar {
  width: 100%;
  height: 100%;
  border-radius: 50%;
  object-fit: cover;
}

.online-dot {
  position: absolute;
  bottom: 0;
  right: 0;
  width: 12px;
  height: 12px;
  border-radius: 50%;
  background: #9ca3af;
  border: 2px solid white;
}

.online-dot.online {
  background: #10b981;
}

.conversation-content {
  flex: 1;
  margin-left: 1rem;
}

.conversation-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 0.5rem;
}

.user-name {
  font-size: 1rem;
  font-weight: 600;
  margin: 0;
}

.online-badge {
  font-size: 0.7rem;
  background: #10b981;
  color: white;
  padding: 0.15rem 0.4rem;
  border-radius: 4px;
  margin-left: 0.5rem;
}

.user-role {
  font-size: 0.75rem;
  color: #6b7280;
}

.time-ago {
  font-size: 0.7rem;
  color: #9ca3af;
}

.last-message {
  font-size: 0.85rem;
  color: #4b5563;
  margin: 0.25rem 0;
}

.you-indicator {
  font-weight: 600;
  color: #3b82f6;
}

.message-status {
  font-size: 0.75rem;
  margin-left: 0.5rem;
}

.status-sent {
  color: #9ca3af;
}

.status-delivered {
  color: #3b82f6;
}

.status-read {
  color: #10b981;
}

.typing-indicator {
  display: flex;
  align-items: center;
  gap: 0.25rem;
  margin-top: 0.25rem;
}

.typing-dots {
  display: flex;
  gap: 0.2rem;
}

.typing-dots .dot {
  width: 4px;
  height: 4px;
  background: #9ca3af;
  border-radius: 50%;
  animation: typing 1.4s infinite;
}

.typing-text {
  font-size: 0.7rem;
  color: #9ca3af;
}

.quick-actions {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.btn-quick {
  background: none;
  border: none;
  font-size: 1.2rem;
  cursor: pointer;
  padding: 0.25rem;
  transition: transform 0.2s;
}

.btn-quick:hover {
  transform: scale(1.1);
}

.btn-quick:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.footer-actions {
  display: flex;
  gap: 1rem;
  padding: 1rem;
  justify-content: center;
}

.action-btn {
  padding: 0.5rem 1rem;
  background: #3b82f6;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  transition: background 0.2s;
}

.action-btn.secondary {
  background: #6b7280;
}

.action-btn:hover {
  background: #2563eb;
}

.toast {
  position: fixed;
  bottom: 2rem;
  right: 2rem;
  padding: 1rem 1.5rem;
  border-radius: 8px;
  color: white;
  z-index: 1000;
  animation: slideIn 0.3s ease;
}

.toast.success {
  background: #10b981;
}

.toast.info {
  background: #3b82f6;
}

.toast.error {
  background: #ef4444;
}

@keyframes typing {
  0%, 60%, 100% {
    transform: translateY(0);
    opacity: 0.4;
  }
  30% {
    transform: translateY(-4px);
    opacity: 1;
  }
}

@keyframes slideIn {
  from {
    transform: translateX(100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}
</style>

<style scoped>
/* 🔥 NUEVO: Estilos para status de mensajes */
.message-status {
  margin-left: 4px;
  font-size: 12px;
}

.status-sent {
  color: #9ca3af;
}

.status-delivered {
  color: #9ca3af;
}

.status-read {
  color: #3b82f6;
}

.last-message-wrapper {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
}

.last-message {
  flex: 1;
  margin: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.chats-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
  min-height: 100vh;
  background: #f8f9fa;
}

/* Header */
.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
  background: white;
  padding: 1.5rem 2rem;
  border-radius: 1rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.title-section h1 {
  font-size: 2rem;
  font-weight: 600;
  color: #2d3436;
  margin: 0 0 0.5rem 0;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.chat-icon {
  font-size: 2rem;
}

.title-section p {
  color: #636e72;
  margin: 0;
  font-size: 1rem;
}

/* Online Indicator */
.online-indicator {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  background: #f1f3f5;
  border-radius: 2rem;
  font-size: 0.9rem;
  color: #2d3436;
}

.online-indicator .dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background: #b2bec3;
  transition: background-color 0.3s;
}

.online-indicator .dot.online {
  background: #00b894;
  box-shadow: 0 0 0 2px rgba(0, 184, 148, 0.2);
}

.online-count {
  font-size: 0.9rem;
  color: #00b894;
  margin-left: 4px;
  font-weight: 600;
}

/* Empty State */
.empty-state {
  text-align: center;
  padding: 4rem 2rem;
  background: white;
  border-radius: 1rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.empty-icon {
  font-size: 5rem;
  margin-bottom: 1rem;
  opacity: 0.5;
}

.empty-state h2 {
  font-size: 1.5rem;
  color: #2d3436;
  margin: 0 0 0.5rem 0;
}

.empty-state p {
  color: #636e72;
  margin-bottom: 2rem;
}

.empty-actions {
  display: flex;
  gap: 1rem;
  justify-content: center;
}

.btn-primary, .btn-secondary {
  display: inline-block;
  padding: 0.75rem 1.5rem;
  border-radius: 0.5rem;
  text-decoration: none;
  font-weight: 500;
  transition: all 0.3s;
}

.btn-primary {
  background: #0984e3;
  color: white;
}

.btn-primary:hover {
  background: #0866b3;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(9, 132, 227, 0.2);
}

.btn-secondary {
  background: #f1f3f5;
  color: #2d3436;
}

.btn-secondary:hover {
  background: #e9ecef;
  transform: translateY(-2px);
}

/* Stats Summary */
.summary-stats {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 1rem;
  margin-bottom: 2rem;
}

.stat-item {
  background: white;
  padding: 1.5rem;
  border-radius: 0.75rem;
  display: flex;
  align-items: center;
  gap: 1rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  transition: all 0.3s;
}

.stat-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.stat-icon {
  font-size: 2rem;
  background: #f1f3f5;
  width: 3.5rem;
  height: 3.5rem;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 0.75rem;
}

.stat-content h3 {
  font-size: 1.5rem;
  font-weight: 600;
  color: #2d3436;
  margin: 0;
  line-height: 1.2;
}

.stat-content p {
  color: #636e72;
  margin: 0;
  font-size: 0.9rem;
}

.online-stat {
  cursor: pointer;
  transition: all 0.3s;
}

.online-stat:hover {
  transform: translateY(-5px);
  background: linear-gradient(135deg, #00b89410, #00cec910);
}

.filter-badge {
  display: inline-block;
  background: #00b894;
  color: white;
  font-size: 0.7rem;
  padding: 2px 8px;
  border-radius: 10px;
  margin-top: 4px;
}

/* Filters Section */
.filters-section {
  background: white;
  padding: 1.5rem;
  border-radius: 0.75rem;
  margin-bottom: 2rem;
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  align-items: end;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.filter-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.filter-group label {
  font-size: 0.9rem;
  font-weight: 500;
  color: #636e72;
}

.filter-select, .search-input {
  padding: 0.6rem;
  border: 1px solid #e1e8ed;
  border-radius: 0.5rem;
  font-size: 0.95rem;
  color: #2d3436;
  background: white;
  transition: all 0.3s;
  width: 100%;
}

.filter-select:focus, .search-input:focus {
  outline: none;
  border-color: #0984e3;
  box-shadow: 0 0 0 3px rgba(9, 132, 227, 0.1);
}

.toggle-group {
  justify-content: flex-end;
}

.toggle-label {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  user-select: none;
  padding: 0.6rem;
  background: #f8f9fa;
  border-radius: 0.5rem;
  border: 1px solid #e1e8ed;
}

.toggle-checkbox {
  width: 18px;
  height: 18px;
  cursor: pointer;
}

.toggle-text {
  color: #2d3436;
  font-weight: 500;
}

/* Conversations Grid */
.conversations-grid {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  margin-bottom: 2rem;
}

.conversation-card {
  background: white;
  border-radius: 0.75rem;
  padding: 1.5rem;
  display: flex;
  gap: 1.5rem;
  position: relative;
  cursor: pointer;
  transition: all 0.3s;
  border: 2px solid transparent;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.conversation-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.conversation-card.unread {
  background: #f0f9ff;
  border-left: 4px solid #0984e3;
}

.online-contact {
  border: 2px solid #00b894;
  background: linear-gradient(135deg, rgba(0, 184, 148, 0.05), white);
}

/* Unread Badge */
.unread-badge {
  position: absolute;
  top: 1rem;
  right: 1rem;
  background: #0984e3;
  color: white;
  font-size: 0.8rem;
  font-weight: 600;
  padding: 0.25rem 0.75rem;
  border-radius: 1rem;
  box-shadow: 0 2px 4px rgba(9, 132, 227, 0.3);
}

/* Avatar Container */
.avatar-container {
  position: relative;
  flex-shrink: 0;
}

.user-avatar {
  width: 4rem;
  height: 4rem;
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid #e1e8ed;
}

.online-dot {
  position: absolute;
  bottom: 0;
  right: 0;
  width: 12px;
  height: 12px;
  border-radius: 50%;
  background: #b2bec3;
  border: 2px solid white;
  transition: background-color 0.3s;
}

.online-dot.online {
  background: #00b894;
}

/* Conversation Content */
.conversation-content {
  flex: 1;
  min-width: 0;
}

.conversation-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 0.5rem;
}

.user-info {
  flex: 1;
  min-width: 0;
}

.user-name-wrapper {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
  margin-bottom: 0.25rem;
}

.user-name {
  font-size: 1.1rem;
  font-weight: 600;
  color: #2d3436;
  margin: 0;
}

.online-badge {
  background: #00b894;
  color: white;
  font-size: 0.65rem;
  font-weight: 600;
  padding: 2px 8px;
  border-radius: 12px;
  letter-spacing: 0.5px;
}

.user-role {
  font-size: 0.85rem;
  color: #636e72;
}

.capitalize {
  text-transform: capitalize;
}

.time-ago {
  font-size: 0.85rem;
  color: #b2bec3;
  white-space: nowrap;
  margin-left: 1rem;
}

.last-message {
  color: #636e72;
  font-size: 0.95rem;
  margin: 0 0 0.5rem 0;
  line-height: 1.4;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.you-indicator {
  font-weight: 600;
  color: #0984e3;
  margin-right: 4px;
}

/* Typing Indicator */
.typing-indicator {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-top: 8px;
  padding: 8px 12px;
  background: #f8f9fa;
  border-radius: 8px;
  font-size: 0.9rem;
}

.typing-dots {
  display: flex;
  gap: 4px;
}

.typing-dots .dot {
  width: 6px;
  height: 6px;
  background: #636e72;
  border-radius: 50%;
  animation: typingBounce 1.4s infinite;
}

.typing-dots .dot:nth-child(2) {
  animation-delay: 0.2s;
}

.typing-dots .dot:nth-child(3) {
  animation-delay: 0.4s;
}

.typing-text {
  color: #636e72;
  font-style: italic;
}

@keyframes typingBounce {
  0%, 60%, 100% {
    transform: translateY(0);
  }
  30% {
    transform: translateY(-4px);
  }
}

/* Message Preview */
.message-preview {
  display: flex;
  align-items: center;
  gap: 4px;
  color: #b2bec3;
  font-size: 0.9rem;
}

.message-type {
  margin-right: 4px;
  font-size: 1.1rem;
}

/* Quick Actions */
.quick-actions {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  margin-left: 1rem;
}

.btn-quick {
  width: 2rem;
  height: 2rem;
  border-radius: 0.5rem;
  border: 1px solid #e1e8ed;
  background: white;
  color: #636e72;
  font-size: 1.1rem;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s;
}

.btn-quick:hover:not(:disabled) {
  background: #0984e3;
  color: white;
  border-color: #0984e3;
  transform: scale(1.1);
}

.btn-quick:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Footer Actions */
.footer-actions {
  display: flex;
  gap: 1rem;
  justify-content: center;
  margin-top: 2rem;
}

.action-btn {
  padding: 0.75rem 1.5rem;
  border-radius: 0.5rem;
  border: none;
  background: #0984e3;
  color: white;
  font-weight: 500;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  transition: all 0.3s;
  font-size: 1rem;
}

.action-btn.secondary {
  background: #f1f3f5;
  color: #2d3436;
}

.action-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(9, 132, 227, 0.3);
}

.action-btn.secondary:hover {
  background: #e9ecef;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.btn-icon {
  font-size: 1.2rem;
  line-height: 1;
}

/* Toast Notification */
.toast {
  position: fixed;
  bottom: 2rem;
  right: 2rem;
  padding: 1rem 1.5rem;
  border-radius: 0.5rem;
  background: white;
  color: #2d3436;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  z-index: 1000;
  max-width: 400px;
  animation: slideIn 0.3s ease;
}

.toast.success {
  background: #00b894;
  color: white;
}

.toast.error {
  background: #d63031;
  color: white;
}

.toast.info {
  background: #0984e3;
  color: white;
}

.toast.warning {
  background: #fdcb6e;
  color: #2d3436;
}

/* Toast transitions */
.toast-enter-active,
.toast-leave-active {
  transition: all 0.3s ease;
}

.toast-enter-from {
  transform: translateX(100%);
  opacity: 0;
}

.toast-leave-to {
  transform: translateX(100%);
  opacity: 0;
}

/* Animations */
@keyframes slideIn {
  from {
    transform: translateX(100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

/* Responsive Design */
@media (max-width: 768px) {
  .chats-page {
    padding: 1rem;
  }

  .header {
    flex-direction: column;
    align-items: flex-start;
    gap: 1rem;
    padding: 1rem;
  }

  .summary-stats {
    grid-template-columns: repeat(2, 1fr);
  }

  .filters-section {
    grid-template-columns: 1fr;
  }

  .conversation-card {
    flex-direction: column;
    padding: 1rem;
  }

  .avatar-container {
    align-self: flex-start;
  }

  .quick-actions {
    flex-direction: row;
    justify-content: flex-end;
    margin-left: 0;
    margin-top: 0.5rem;
  }

  .footer-actions {
    flex-direction: column;
  }

  .action-btn {
    width: 100%;
    justify-content: center;
  }

  .toast {
    bottom: 1rem;
    right: 1rem;
    left: 1rem;
    max-width: none;
  }
}

@media (max-width: 480px) {
  .summary-stats {
    grid-template-columns: 1fr;
  }

  .conversation-header {
    flex-direction: column;
    gap: 0.5rem;
  }

  .time-ago {
    margin-left: 0;
  }

  .user-name-wrapper {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.25rem;
  }
}

/* Utilidades */
.capitalize {
  text-transform: capitalize;
}
</style>
