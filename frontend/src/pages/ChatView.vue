<template>
  <!-- Contenedor principal -->
  <div class="chat-main-container">
    <!-- Chat directo -->
    <div v-if="target" class="chat-wrapper-modern">
      <div class="chat-content">
        <!-- Header del chat con diseño de tarjeta -->
        <div class="chat-header-card">
          <div class="chat-user-info">
            <div class="user-avatar-wrapper">
              <img
                :src="target.avatarUrl || '/img/default-avatar.png'"
                :alt="target.name || 'Usuario'"
                class="user-avatar-modern"
                @error="handleImageError"
              />
              <span
                class="online-dot"
                :class="{ 'online': isUserOnline }"
                :title="isUserOnline ? 'En línea' : 'Desconectado'"
              ></span>
            </div>
            <div class="user-details">
              <div class="user-name-section">
                <h2 class="user-name-modern">{{ target.name || 'Cargando...' }}</h2>
                <span v-if="isUserOnline" class="online-badge-modern">
                  <span class="pulse-dot"></span>
                  EN LÍNEA
                </span>
              </div>
              <div class="user-role-badge" :class="target.role ? target.role.toLowerCase() : ''">
                {{ formatRole(target.role) }}
              </div>
              <div v-if="lastSeen && !isUserOnline" class="last-seen">
                Última vez: {{ formatLastSeen(lastSeen, true) }}
              </div>
            </div>
          </div>

          <!-- Acciones del chat -->
          <div class="chat-actions">
            <div class="action-buttons">
              <button class="action-icon-btn" @click="viewProfile" title="Ver perfil">
                <span class="icon">👤</span>
              </button>
              <div class="file-input-wrapper">
                <label for="imageInput" class="action-icon-btn" title="Adjuntar imagen">
                  <span class="icon">📎</span>
                </label>
                <input
                  id="imageInput"
                  type="file"
                  accept="image/*"
                  class="file-input-hidden"
                  @change="onFileChange"
                />
              </div>
              <button
                class="action-icon-btn"
                :class="{ favorited: isFavorite }"
                @click="toggleFavorite"
                title="Favoritos"
              >
                <span class="icon">{{ isFavorite ? '⭐' : '☆' }}</span>
              </button>
              <button class="action-icon-btn" @click="shareConversation" title="Compartir">
                <span class="icon">🔗</span>
              </button>

              <!-- Menú desplegable -->
              <div class="dropdown-modern">
                <button
                  @click="showMenu = !showMenu"
                  class="action-icon-btn"
                  :class="{ 'active': showMenu }"
                  title="Más opciones"
                >
                  <span class="icon">⋮</span>
                </button>
                <transition name="dropdown">
                  <div v-if="showMenu" class="dropdown-menu-modern">
                    <button @click="exportChatHistory" class="dropdown-item">
                      <span class="item-icon">📥</span>
                      <span>Exportar historial</span>
                    </button>
                    <div class="dropdown-divider"></div>
                    <button @click="confirmClearMessagesForMe" class="dropdown-item warning">
                      <span class="item-icon">🗑️</span>
                      <span>Borrar mis mensajes</span>
                    </button>
                    <button @click="confirmDeleteChatForMe" class="dropdown-item danger">
                      <span class="item-icon">🔥</span>
                      <span>Borrar chat para mí</span>
                    </button>
                    <div v-if="authStore.user?.role === 'admin'" class="admin-section">
                      <div class="dropdown-divider"></div>
                      <div class="admin-label">👑 Admin</div>
                      <button @click="confirmHardDeleteMessages" class="dropdown-item danger">
                        <span class="item-icon">⚠️</span>
                        <span>Borrar permanentemente</span>
                      </button>
                      <button @click="confirmHardDeleteChat" class="dropdown-item danger">
                        <span class="item-icon">💀</span>
                        <span>Eliminar conversación</span>
                      </button>
                    </div>
                  </div>
                </transition>
              </div>
            </div>
          </div>
        </div>

        <!-- Área de mensajes -->
        <div
          ref="scrollRef"
          class="messages-area-modern"
          :class="{ 'empty': currentMessages.length === 0 }"
        >
          <!-- Estado vacío -->
          <div v-if="currentMessages.length === 0" class="empty-messages-modern">
            <div class="empty-icon-wrapper">
              <span class="empty-icon">💬</span>
            </div>
            <h3 class="empty-title">No hay mensajes aún</h3>
            <p class="empty-subtitle">Envía el primer mensaje para comenzar la conversación</p>
          </div>

          <!-- Lista de mensajes -->
          <div v-else class="messages-list-modern">
            <div
              v-for="msg in currentMessages"
              :key="msg.id"
              class="message-modern"
              :class="{ 'sent': msg.is_mine === true, 'received': msg.is_mine === false }"
            >
              <!-- Avatar para mensajes recibidos -->
              <div v-if="!msg.is_mine" class="message-avatar-modern">
                <img
                 :src="msg.avatar_url ? getImageUrl(msg.avatar_url, 'avatar') : (target?.avatarUrl || '/img/default-avatar.png')"
                  :alt="msg.sender"
                  class="avatar-small-modern"
                  @error="handleImageError"
                />
              </div>
              <!-- Contenedor del mensaje -->
              <div class="message-container-modern">
                <div class="message-bubble" :class="{ 'has-image': msg.type === 'image' }">
                  <!-- Botón eliminar -->
                  <button
                    v-if="msg.is_mine"
                    @click="deleteMessageForMe(msg.id)"
                    class="message-delete-btn-modern"
                    title="Borrar para mí"
                  >
                    ✕
                  </button>

                  <!-- Texto del mensaje -->
                  <div v-if="msg.text" class="message-text-modern">
                    {{ msg.text }}
                  </div>
                  <!-- Imagen adjunta -->
                  <div v-if="msg.type === 'image' && msg.attachment_url" class="message-image-modern">
                    <img
                      :src="msg.attachment_url"
                      :alt="msg.text || 'Imagen adjunta'"
                      class="image-preview-modern"
                      @load="scrollToBottom"
                      @error="handleImageError"
                      @click="openImage(msg.attachment_url, msg.text)"
                    />
                  </div>
                  <!-- Info del mensaje -->
                  <div class="message-footer">
                    <span class="message-time-modern">
                      {{ formatMessageTime(msg.created_at) }}
                    </span>
                    <!-- Sistema de tildes - SOLO en mensajes propios -->
                    <span v-if="msg.is_mine" class="message-status-modern">
                      <span v-if="!msg.is_delivered && !msg.is_read" class="status-sent" title="Enviado">✓</span>
                      <span v-else-if="msg.is_delivered && !msg.is_read" class="status-delivered" title="Entregado">✓✓</span>
                      <span v-else-if="msg.is_read" class="status-read" title="Leído">✓✓</span>
                    </span>
                  </div>
                </div>
              </div>
            </div>
            <!-- Indicador de typing DENTRO del flujo de mensajes -->
            <transition name="fade">
              <div v-if="isTyping" class="typing-indicator-modern">
                <div class="typing-bubble">
                  <div class="typing-dots">
                    <span></span>
                    <span></span>
                    <span></span>
                  </div>
                  <span class="typing-name">{{ typingText }}</span>
                </div>
              </div>
            </transition>
          </div>
        </div>

        <!-- Vista previa de imagen -->
        <transition name="slide-up">
          <div v-if="previewUrl" class="image-preview-modern-container">
            <div class="preview-modern">
              <div class="preview-header">
                <span class="preview-label">📷 Vista previa</span>
                <button @click="clearPreview" class="preview-close">
                  ✕
                </button>
              </div>
              <img :src="previewUrl" alt="Vista previa" class="preview-image-modern" />
            </div>
          </div>
        </transition>

        <!-- Área de entrada -->
        <div class="input-area-modern">
          <div class="input-wrapper-modern">
            <input
              v-model="newMessage"
              type="text"
              :placeholder="uploadingImage ? 'Subiendo imagen...' : 'Escribe tu mensaje aquí...'"
              autocomplete="off"
              class="message-input-modern"
              @keyup.enter="sendMessage"
              @keydown="handleTyping"
              @blur="stopTyping"
              :disabled="loading || uploadingImage"
            />
            <button
              @click="sendMessage"
              :disabled="loading || uploadingImage || (!newMessage.trim() && !selectedFile)"
              class="send-btn-modern"
              :class="{ 'loading': loading, 'disabled': (!newMessage.trim() && !selectedFile) }"
            >
              <span v-if="loading" class="spinner-small-modern"></span>
              <span v-else class="send-icon">➢</span>
            </button>
          </div>
          <div class="input-hints-modern">
            <span class="hint-item">
              <span class="hint-icon">↵</span> Enter para enviar
            </span>
            <span v-if="uploadingImage" class="hint-item uploading">
              <span class="hint-icon">⏳</span> Subiendo imagen...
            </span>
            <span v-else-if="isUserOnline" class="hint-item online">
              <span class="online-indicator"></span> En línea
            </span>
          </div>
        </div>
      </div>

      <!-- Sidebar de información -->
      <div class="sidebar-info-modern">
        <div class="info-card-modern">
          <h3 class="info-card-title">
            <span class="title-icon">📋</span> Detalles del chat
          </h3>
          <div class="info-content">
            <div class="info-row">
              <span class="info-label">Usuario:</span>
              <span class="info-value highlight">{{ target.name || 'Cargando...' }}</span>
            </div>
            <div class="info-row">
              <span class="info-label">Rol:</span>
              <span class="info-value">
                <span class="role-badge-modern" :class="target.role ? target.role.toLowerCase() : ''">
                  {{ formatRole(target.role) }}
                </span>
              </span>
            </div>
            <div class="info-row">
              <span class="info-label">ID:</span>
              <span class="info-value code">{{ target.id || '-' }}</span>
            </div>
            <div class="info-row">
              <span class="info-label">Estado:</span>
              <span class="info-value status-value" :class="{ 'online': isUserOnline }">
                <span class="status-indicator-modern" :class="{ 'online': isUserOnline }"></span>
                {{ isUserOnline ? 'En línea' : 'Desconectado' }}
              </span>
            </div>
            <div v-if="lastSeen && !isUserOnline" class="info-row">
              <span class="info-label">Última vez:</span>
              <span class="info-value">{{ formatLastSeen(lastSeen, true) }}</span>
            </div>
            <div class="info-divider"></div>

            <!-- Estadísticas -->
            <div v-if="messageStats" class="stats-grid-modern">
              <div class="stat-item-modern">
                <span class="stat-value">{{ messageStats.total || 0 }}</span>
                <span class="stat-label">Total</span>
              </div>
              <div class="stat-item-modern">
                <span class="stat-value">{{ messageStats.yours || 0 }}</span>
                <span class="stat-label">Tuyos</span>
              </div>
              <div class="stat-item-modern">
                <span class="stat-value">{{ messageStats.theirs || 0 }}</span>
                <span class="stat-label">De {{ target?.name?.split(' ')[0] || 'Usuario' }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Estado de carga mejorado -->
    <div v-else class="loading-state-modern">
      <div class="loading-card">
        <div class="spinner-modern"></div>
        <h3>Cargando conversación...</h3>
        <p>Preparando el espacio de comunicación</p>
        <div class="loading-progress">
          <div class="progress-bar"></div>
        </div>
      </div>
    </div>
  </div>

  <!-- Modal de imagen mejorado -->
  <Teleport to="body">
    <transition name="modal">
      <div v-if="showImageModal" class="image-modal-overlay" @click.self="closeImageModal">
        <div class="image-modal-container" @click.stop>
          <button class="image-modal-close" @click="closeImageModal">✕</button>
          <img :src="selectedImage" alt="Imagen ampliada" class="image-modal-img" />
          <div class="image-modal-caption" v-if="selectedImageCaption">
            {{ selectedImageCaption }}
          </div>
        </div>
      </div>
    </transition>
  </Teleport>
</template>

<script setup>
import { ref, onMounted, onUnmounted, computed, watch, nextTick } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useConversationStore } from '@/stores/conversationStore'
import { useAuthStore } from '@/stores/authStore'
import { useSocketStore } from '@/stores/socketStore'
import { useOnlineUsersStore } from '@/stores/onlineUsersStore'
import api from '@/axios'
import { formatDistanceToNow, format } from 'date-fns'
import { es } from 'date-fns/locale'
import { getImageUrl } from '@/utils/imageHelper'

const route = useRoute()
const router = useRouter()
const conversationStore = useConversationStore()
const authStore = useAuthStore()
const socketStore = useSocketStore()
const onlineUsersStore = useOnlineUsersStore()

const target = ref(null)
const newMessage = ref('')
const loading = ref(false)
const uploadingImage = ref(false)
const showMenu = ref(false)
const scrollRef = ref(null)
const selectedFile = ref(null)
const previewUrl = ref(null)
const isTyping = ref(false)
let typingTimeout = null
const selectedImage = ref(null)
const showImageModal = ref(false)
const selectedImageCaption = ref('')
const favoriteConversations = ref(new Set(loadFavorites()))
const messageStats = ref(null)
const socketListeners = {}

const currentMessages = computed(() => {
  const convId = Number(route.params.id)
  return conversationStore.messages[convId] || []
})

const isUserOnline = computed(() => {
  if (!target.value?.id) return false
  return onlineUsersStore.isUserOnline(Number(target.value.id))
})

const lastSeen = computed(() => {
  if (!target.value?.id) return null
  const user = onlineUsersStore.getUserById(Number(target.value.id))
  return user?.lastSeen || null
})

const typingText = computed(() => {
  if (!target.value?.id) return 'Alguien está escribiendo...'
  const typingUsersList = conversationStore.getTypingUsers(Number(route.params.id))
  if (typingUsersList.length > 0 && target.value?.name) {
    return `${target.value.name} está escribiendo...`
  }
  return 'Alguien está escribiendo...'
})

const isFavorite = computed(() => {
  return favoriteConversations.value.has(Number(route.params.id))
})

function formatRole(role) {
  if (!role) return 'Usuario'
  const roles = { provider: 'Proveedor', client: 'Cliente', user: 'Usuario', admin: 'Administrador' }
  return roles[role.toLowerCase()] || role
}

function formatLastSeen(timestamp, detailed = false) {
  if (!timestamp) return 'desconocido'
  const date = new Date(timestamp * 1000)
  if (detailed) return format(date, 'dd/MM/yyyy HH:mm', { locale: es })
  return formatDistanceToNow(date, { addSuffix: true, locale: es })
}

function formatMessageTime(timestamp) {
  if (!timestamp) return ''
  return new Date(timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
}

async function fetchMessages() {
  if (!authStore.token || !target.value) return
  const conversationId = Number(route.params.id)
  try {
    await conversationStore.fetchMessages(conversationId)
    await markMessagesAsDeliveredHttp()
    await loadMessageStats(conversationId)
    await scrollToBottom()
  } catch (err) {
    console.error('Error al cargar mensajes:', err)
  }
}

async function markMessagesAsDeliveredHttp() {
  const conversationId = Number(route.params.id)
  if (!conversationId) return
  try {
    const response = await api.post(
      `/messages/conversation/${conversationId}/delivered`,
      { target_id: target.value?.id, target_role: target.value?.role },
      { headers: { Authorization: `Bearer ${authStore.token}` } }
    )
    if (response.data?.count > 0) {
      console.log(`✅ ${response.data.count} mensajes marcados como entregados`)
    }
  } catch (err) {
    console.error('❌ Error marcando mensajes como entregados:', err)
  }
}

function onFileChange(e) {
  const file = e.target.files?.[0]
  if (!file) return
  selectedFile.value = file
  const reader = new FileReader()
  reader.onload = (ev) => (previewUrl.value = ev.target?.result)
  reader.readAsDataURL(file)
}

function clearPreview() {
  selectedFile.value = null
  previewUrl.value = null
}

const sendMessage = async () => {
  if ((!newMessage.value.trim() && !selectedFile.value) || !authStore.token) return
  stopTyping()
  let attachment_url = null
  if (selectedFile.value) {
    uploadingImage.value = true
    const formData = new FormData()
    formData.append('image', selectedFile.value)
    try {
      const uploadRes = await api.post('/upload/image', formData, {
        headers: { Authorization: `Bearer ${authStore.token}`, 'Content-Type': 'multipart/form-data' }
      })
      if (!uploadRes.data?.image_url) throw new Error('URL de imagen no recibida')
      attachment_url = uploadRes.data.image_url
    } catch (err) {
      uploadingImage.value = false
      showNotification(err.response?.data?.error || 'Error al subir la imagen', 'error')
      return
    }
    uploadingImage.value = false
  }

  const messageText = newMessage.value.trim()
  const conversationId = Number(route.params.id)
  if (!conversationId || !target.value) return

  const tempId = `temp_${Date.now()}_${Math.random()}`
  const tempMessage = {
    id: tempId, temp_id: tempId,
    text: messageText || (attachment_url ? '📷 Imagen' : ''),
    sender_id: authStore.user?.id, sender: authStore.user?.role,
    is_mine: true, is_delivered: false, is_read: false,
    created_at: new Date().toISOString(), attachment_url,
    type: attachment_url ? 'image' : 'text',
    avatar_url: authStore.user?.avatar_url || '', _temp: true
  }

  if (!conversationStore.messages[conversationId]) conversationStore.messages[conversationId] = []
  conversationStore.messages[conversationId].push(tempMessage)
  await scrollToBottom()
  newMessage.value = ''
  selectedFile.value = null
  previewUrl.value = null
  loading.value = true

  try {
    const res = await api.post('/messages/send', {
      conversation_id: conversationId, recipient_id: target.value.id,
      recipient_role: target.value.role, text: messageText,
      temp_id: tempId, type: attachment_url ? 'image' : 'text',
      attachment_url
    }, { headers: { Authorization: `Bearer ${authStore.token}` } })
    const realMessage = res.data.message || res.data
    conversationStore.confirmMessageSent({ conversation_id: conversationId, temp_id: tempId, message: realMessage })
    await loadMessageStats(conversationId)
  } catch (err) {
    const index = conversationStore.messages[conversationId].findIndex(m => m.id === tempId || m.temp_id === tempId)
    if (index !== -1) conversationStore.messages[conversationId][index].error = true
    showNotification(err.response?.data?.message || 'Error al enviar', 'error')
  } finally {
    loading.value = false
  }
}
let typingSent = false

function handleTyping() {
  if (!socketStore.socket?.connected || !isUserOnline.value || !target.value) return
  if (typingSent) return  // ✅ No reenviar si ya se envió
  const conversationId = Number(route.params.id)
  if (!conversationId) return

  typingSent = true
  socketStore.emit('typing', {
    receiver_id: target.value.id,
    receiver_role: target.value.role,
    is_typing: true,
    conversation_id: conversationId
  })

  if (typingTimeout) clearTimeout(typingTimeout)
  typingTimeout = setTimeout(() => {
    stopTyping()
    typingSent = false
  }, 3000)
}

function stopTyping() {
  if (!socketStore.socket?.connected || !target.value) return
  const conversationId = Number(route.params.id)
  if (!conversationId) return

  socketStore.emit('typing', {
    receiver_id: target.value.id,
    receiver_role: target.value.role,
    is_typing: false,
    conversation_id: conversationId
  })
  if (typingTimeout) { clearTimeout(typingTimeout); typingTimeout = null }
 
 typingSent = false
} 
async function deleteMessageForMe(messageId) {
  if (!confirm('¿Borrar este mensaje solo para ti?')) return
  try {
    await api.delete(`/messages/${messageId}/for-me`, { headers: { Authorization: `Bearer ${authStore.token}` } })
    const convId = Number(route.params.id)
    if (conversationStore.messages[convId]) conversationStore.messages[convId] = conversationStore.messages[convId].filter(m => m.id !== messageId)
    showNotification('Mensaje borrado', 'success')
    loadMessageStats(convId)
  } catch (err) { showNotification('Error al borrar el mensaje', 'error') }
}

async function deleteChatForMe() {
  if (!confirm('¿Borrar esta conversación solo para ti?')) return
  try {
    await api.delete(`/conversations/${route.params.id}/for-me`, { headers: { Authorization: `Bearer ${authStore.token}` } })
    showNotification('Conversación borrada', 'success')
    router.push('/chats')
  } catch (err) { showNotification('Error al borrar la conversación', 'error') }
}

const confirmClearMessagesForMe = () => {
  if (currentMessages.value.length === 0) { showNotification('No hay mensajes para borrar', 'info'); return }
  if (confirm('¿Borrar TODOS los mensajes para ti?')) clearAllMessagesForMe()
}
const confirmDeleteChatForMe = () => deleteChatForMe()
const confirmHardDeleteMessages = () => {
  if (authStore.user?.role !== 'admin') { showNotification('Solo administradores', 'error'); return }
  if (confirm('¿ELIMINAR PERMANENTEMENTE todos los mensajes?')) clearAllMessages()
}
const confirmHardDeleteChat = () => {
  if (authStore.user?.role !== 'admin') { showNotification('Solo administradores', 'error'); return }
  if (confirm('¿ELIMINAR PERMANENTEMENTE toda la conversación?')) deleteEntireChat()
}

const clearAllMessagesForMe = async () => {
  if (!authStore.token || !target.value) return
  try {
    loading.value = true
    const promises = currentMessages.value.map(msg => api.delete(`/messages/${msg.id}/for-me`, { headers: { Authorization: `Bearer ${authStore.token}` } }).catch(() => {}))
    await Promise.all(promises)
    const convId = Number(route.params.id)
    if (conversationStore.messages[convId]) conversationStore.messages[convId] = []
    showMenu.value = false
    showNotification('Mensajes borrados', 'success')
  } catch (error) { showNotification('Error al borrar los mensajes', 'error') }
  finally { loading.value = false }
}

const clearAllMessages = async () => {
  if (!authStore.token || !target.value) return
  try {
    loading.value = true
    const response = await api.delete(`/conversations/${route.params.id}/messages`, { headers: { Authorization: `Bearer ${authStore.token}` } })
    if (response.data.success) {
      const convId = Number(route.params.id)
      if (conversationStore.messages[convId]) conversationStore.messages[convId] = []
      showMenu.value = false
      showNotification('Todos los mensajes han sido borrados permanentemente', 'success')
    } else { showNotification('Error al borrar los mensajes', 'error') }
  } catch (error) {
    if (error.response?.status === 404) await fallbackClearMessages()
    else showNotification(error.response?.data?.message || 'Error al borrar los mensajes', 'error')
  } finally { loading.value = false }
}

const fallbackClearMessages = async () => {
  try {
    showNotification('Borrando mensajes uno por uno...', 'info')
    const messageIds = currentMessages.value.map(m => m.id)
    let deletedCount = 0
    for (const msgId of messageIds) {
      try { await api.delete(`/messages/${msgId}`, { headers: { Authorization: `Bearer ${authStore.token}` } }); deletedCount++ }
      catch (err) { console.error(`Error borrando mensaje ${msgId}:`, err) }
    }
    if (deletedCount > 0) {
      const convId = Number(route.params.id)
      if (conversationStore.messages[convId]) conversationStore.messages[convId] = []
      showMenu.value = false
      showNotification(`Se borraron ${deletedCount} mensajes`, 'success')
    } else { showNotification('No se pudo borrar ningún mensaje', 'error') }
  } catch (error) { showNotification('Error al borrar mensajes', 'error') }
}

const deleteEntireChat = async () => {
  if (!authStore.token || !target.value) return
  try {
    loading.value = true
    const response = await api.delete(`/conversations/${route.params.id}`, { headers: { Authorization: `Bearer ${authStore.token}` } })
    if (response.data.success) {
      showNotification('Conversación eliminada permanentemente', 'success')
      if (conversationStore.conversations) {
        const index = conversationStore.conversations.findIndex(c => c.id === Number(route.params.id))
        if (index !== -1) conversationStore.conversations.splice(index, 1)
      }
      router.push('/chats')
    } else { showNotification('Error al eliminar la conversación', 'error') }
  } catch (error) {
    if (error.response?.status === 404) await legacyDeleteChat()
    else showNotification(error.response?.data?.message || 'Error al eliminar la conversación', 'error')
  } finally { loading.value = false }
}

const legacyDeleteChat = async () => {
  try {
    const response = await api.delete(`/messages/${target.value.id}/${target.value.role}`, { headers: { Authorization: `Bearer ${authStore.token}` } })
    if (response.data.success) {
      if (response.data.messages?.length > 0) {
        const convId = Number(route.params.id)
        if (conversationStore.messages[convId]) conversationStore.messages[convId] = response.data.messages
        showNotification('No se pudo eliminar la conversación completa. Algunos mensajes permanecen.', 'warning')
      } else { showNotification('Conversación eliminada', 'success'); router.push('/chats') }
    }
  } catch (error) { showNotification('Error al eliminar la conversación', 'error') }
}

function exportChatHistory() {
  const chatData = { target: target.value, messages: currentMessages.value, exportDate: new Date().toISOString() }
  const dataStr = JSON.stringify(chatData, null, 2)
  const dataBlob = new Blob([dataStr], { type: 'application/json' })
  const url = URL.createObjectURL(dataBlob)
  const link = document.createElement('a')
  link.href = url
  link.download = `chat_${target.value?.name || 'chat'}_${new Date().getTime()}.json`
  link.click()
  URL.revokeObjectURL(url)
}

async function scrollToBottom() {
  await nextTick()
  if (scrollRef.value) scrollRef.value.scrollTop = scrollRef.value.scrollHeight
}

async function loadMessageStats(conversationId) {
  try {
    const msgs = currentMessages.value
    messageStats.value = {
      total: msgs.length || 0,
      yours: msgs.filter(m => m.is_mine).length || 0,
      theirs: msgs.filter(m => !m.is_mine).length || 0
    }
  } catch (error) { console.error('Error cargando estadísticas:', error) }
}

function loadFavorites() {
  try { const saved = localStorage.getItem('favorite_conversations'); return saved ? JSON.parse(saved) : [] }
  catch { return [] }
}

function saveFavorites() {
  localStorage.setItem('favorite_conversations', JSON.stringify(Array.from(favoriteConversations.value)))
}

function toggleFavorite() {
  const conversationId = Number(route.params.id)
  if (favoriteConversations.value.has(conversationId)) {
    favoriteConversations.value.delete(conversationId)
    showNotification('Conversación quitada de favoritos', 'info')
  } else {
    favoriteConversations.value.add(conversationId)
    showNotification('Conversación agregada a favoritos', 'success')
  }
  saveFavorites()
}

function viewProfile() {
  if (target.value) router.push(`/profile/${target.value.id}`).catch(() => showNotification('Página de perfil no disponible', 'error'))
}

function shareConversation() {
  const shareUrl = `${window.location.origin}/chat/${route.params.id}`
  if (navigator.clipboard && window.isSecureContext) {
    navigator.clipboard.writeText(shareUrl).then(() => showNotification('Enlace copiado', 'success')).catch(() => fallbackCopy(shareUrl))
  } else { fallbackCopy(shareUrl) }
}

function fallbackCopy(text) {
  const textArea = document.createElement('textarea')
  textArea.value = text
  document.body.appendChild(textArea)
  textArea.select()
  document.execCommand('copy')
  document.body.removeChild(textArea)
  showNotification('Enlace copiado', 'success')
}

function handleImageError(event) { event.target.src = 'https://via.placeholder.com/60?text=Usuario' }
function openImage(url, caption = '') { selectedImage.value = url; selectedImageCaption.value = caption; showImageModal.value = true }
function closeImageModal() { showImageModal.value = false; selectedImage.value = null; selectedImageCaption.value = '' }

function showNotification(message, type = 'info') {
  console.log(`[${type.toUpperCase()}] ${message}`)
  if (window.notificationSystem) window.notificationSystem.show(message, type)
  else if (type === 'error' || type === 'success') alert(message)
}

// ============================================
// WATCHERS (PROTEGIDOS)
// ============================================
watch(currentMessages, () => {
  scrollToBottom()
  loadMessageStats(Number(route.params.id))
}, { deep: true })

// ✅ CORREGIDO: Proteger el watcher contra valores null/undefined
let isMarkingRead = false
let lastMarkedReadTime = 0
const MARK_READ_DEBOUNCE_MS = 300

watch(
  () => {
    const convId = Number(route.params.id)
    // ✅ Protección: retornar array vacío si no hay mensajes
    return conversationStore?.messages?.[convId] ?? []
  },
  async (newMessages) => {
    if (!newMessages || !Array.isArray(newMessages)) return
    const now = Date.now()
    if (now - lastMarkedReadTime < MARK_READ_DEBOUNCE_MS) return
    lastMarkedReadTime = now
    if (isMarkingRead) return

    const unreadMessages = newMessages.filter(m => m && !m.is_mine && !m.is_read && m.id && !String(m.id).startsWith('temp'))
    if (unreadMessages.length > 0) {
      isMarkingRead = true
      const messageIds = unreadMessages.map(m => m.id)
      const convId = Number(route.params.id)
      await conversationStore.markAsRead(convId, messageIds).catch(err => console.error('❌ Error al marcar como leídos:', err))
      setTimeout(() => { isMarkingRead = false }, 200)
    }
  },
  { deep: true, immediate: true }
)

// Watch para typing
watch(() => conversationStore.getTypingUsers(Number(route.params.id)), (typingUsersList) => {
  isTyping.value = typingUsersList.length > 0
}, { immediate: true, deep: true })

watch(isTyping, (newVal) => {
  if (newVal) nextTick(() => scrollToBottom())
})

// ============================================
// HANDLERS DE EVENTOS DE SOCKET
// ============================================
const handleNewMessage = (data) => {
  const messageData = data.message || data
  const convId = Number(messageData.conversation_id)
  if (convId === Number(route.params.id)) nextTick(() => scrollToBottom())
}

const handleMessageDelivered = (data) => {
  const conversationId = Number(route.params.id)
  const deliveredConversationId = Number(data.conversation_id || data.conversationId)
  if (deliveredConversationId === conversationId) {
    const messageIds = data.message_ids || data.messageIds || []
    if (Array.isArray(messageIds) && messageIds.length > 0) {
      nextTick(() => { loadMessageStats(conversationId); scrollToBottom() })
    }
  }
}

const handleMessageRead = (data) => {
  const conversationId = Number(route.params.id)
  const readConversationId = Number(data.conversation_id || data.conversationId)
  if (readConversationId === conversationId) {
    const messageIds = data.message_ids || data.messageIds || []
    if (Array.isArray(messageIds) && messageIds.length > 0) {
      nextTick(() => { loadMessageStats(conversationId); scrollToBottom() })
    }
  }
}

const handleTypingIndicator = (data) => {
  const convId = Number(route.params.id)
  if (data.conversation_id === convId) console.log('⌨️ [ChatView] typing_indicator:', data)
}

// ============================================
// LIFECYCLE HOOKS
// ============================================
onMounted(async () => {
  // ✅ Protección al asignar activeConversationId
  if (conversationStore?.activeConversationId) {
    conversationStore.activeConversationId.value = Number(route.params.id)
  }

  if (socketListeners.new_message) socketStore.off('new_message', socketListeners.new_message)
  if (socketListeners.typing_indicator) socketStore.off('typing_indicator', socketListeners.typing_indicator)
  if (socketListeners.message_delivered) socketStore.off('message_delivered', socketListeners.message_delivered)
  if (socketListeners.message_read) socketStore.off('message_read', socketListeners.message_read)
  if (socketListeners.message_sent_confirmation) socketStore.off('message_sent_confirmation', socketListeners.message_sent_confirmation)

  const conversationId = Number(route.params.id)

  try {
    let conversation = await conversationStore.fetchConversation(conversationId)
    if (!conversation) { router.replace('/chats'); return }

    const other = conversation.other_participant
    if (!other) { router.replace('/chats'); return }

    target.value = {
      id: other.id,
      name: other.name || 'Usuario',
      role: other.role || 'user',
      avatarUrl: other.avatar_url ? getImageUrl(other.avatar_url, 'avatar') : null
    }

    await fetchMessages()
    await markMessagesAsDeliveredHttp()
    await conversationStore.syncMessageStatuses(conversationId)
    await conversationStore.fetchConversations()

    const waitForSocket = () => new Promise((resolve) => {
      if (socketStore.socket?.connected) { resolve(true); return }
      const checkInterval = setInterval(() => {
        if (socketStore.socket?.connected) { clearInterval(checkInterval); resolve(true) }
      }, 100)
      setTimeout(() => { clearInterval(checkInterval); resolve(false) }, 5000)
    })

    await waitForSocket()
    await socketStore.joinConversationRoom(conversationId)

    socketStore.on('new_message', handleNewMessage)
    socketListeners.new_message = handleNewMessage
    socketStore.on('typing_indicator', handleTypingIndicator)
    socketListeners.typing_indicator = handleTypingIndicator
    socketStore.on('message_delivered', handleMessageDelivered)
    socketListeners.message_delivered = handleMessageDelivered
    socketStore.on('message_read', handleMessageRead)
    socketListeners.message_read = handleMessageRead

    const handleMessageSentConfirmation = (data) => {
      nextTick(() => loadMessageStats(conversationId))
    }
    socketStore.on('message_sent_confirmation', handleMessageSentConfirmation)
    socketListeners.message_sent_confirmation = handleMessageSentConfirmation

  } catch (error) {
    console.error('Error al cargar la conversación:', error)
    router.replace('/chats')
  }
})

onUnmounted(() => {
  if (conversationStore?.activeConversationId) {
    conversationStore.activeConversationId.value = null
  }
  socketStore.leaveConversationRoom(Number(route.params.id))
  if (socketListeners.new_message) socketStore.off('new_message', socketListeners.new_message)
  if (socketListeners.typing_indicator) socketStore.off('typing_indicator', socketListeners.typing_indicator)
  if (socketListeners.message_delivered) socketStore.off('message_delivered', socketListeners.message_delivered)
  if (socketListeners.message_read) socketStore.off('message_read', socketListeners.message_read)
  if (socketListeners.message_sent_confirmation) socketStore.off('message_sent_confirmation', socketListeners.message_sent_confirmation)
  if (typingTimeout) clearTimeout(typingTimeout)
})
</script>

<style scoped>
:root {
  --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  --secondary-gradient: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  --success-gradient: linear-gradient(135deg, #00b894 0%, #00a085 100%);
  --warning-gradient: linear-gradient(135deg, #fdcb6e 0%, #e17055 100%);
  --danger-gradient: linear-gradient(135deg, #ff7675 0%, #d63031 100%);
  
  --primary-color: #667eea;
  --secondary-color: #764ba2;
  --success-color: #00b894;
  --warning-color: #fdcb6e;
  --danger-color: #ff7675;
  
  --text-dark: #2d3436;
  --text-light: #636e72;
  --text-muted: #b2bec3;
  
  --bg-light: #f8f9fa;
  --bg-white: #ffffff;
  --bg-gradient: linear-gradient(135deg, #f5f7fa 0%, #e4edf5 100%);
  
  --shadow-sm: 0 4px 15px rgba(0, 0, 0, 0.08);
  --shadow-md: 0 10px 30px rgba(0, 0, 0, 0.1);
  --shadow-lg: 0 20px 40px rgba(0, 0, 0, 0.15);
  
  --border-radius-sm: 8px;
  --border-radius-md: 12px;
  --border-radius-lg: 20px;
  --border-radius-xl: 30px;
  
  --transition-fast: 0.2s;
  --transition-normal: 0.3s;
  --transition-slow: 0.5s;
}

/* Estilos base */
.chat-view-page {
  min-height: 100vh;
  background: var(--bg-gradient);
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
}

/* Header con gradiente */
.header-gradient {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 30px 0;
  margin-bottom: 30px;
  box-shadow: var(--shadow-lg);
  position: relative;
  overflow: hidden;
}

.header-gradient::before {
  content: '';
  position: absolute;
  top: -50%;
  right: -50%;
  width: 200%;
  height: 200%;
  background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 70%);
  animation: rotate 20s linear infinite;
}

@keyframes rotate {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.header {
  max-width: 1400px;
  margin: 0 auto;
  padding: 0 30px;
  position: relative;
  z-index: 1;
}

.title-section {
  position: relative;
}

.back-btn {
  background: rgba(255, 255, 255, 0.2);
  border: 2px solid rgba(255, 255, 255, 0.3);
  color: white;
  padding: 10px 24px;
  border-radius: 50px;
  cursor: pointer;
  font-weight: 600;
  font-size: 1rem;
  display: inline-flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 20px;
  backdrop-filter: blur(10px);
  transition: all var(--transition-normal);
}

.back-btn:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: translateX(-5px);
  border-color: rgba(255, 255, 255, 0.5);
}

.back-icon {
  font-size: 1.2rem;
}

.title-section h1 {
  color: white;
  font-size: 2.8rem;
  margin-bottom: 10px;
  display: flex;
  align-items: center;
  gap: 15px;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.1);
}

.chat-icon {
  font-size: 2.5rem;
  animation: bounce 2s infinite;
}

@keyframes bounce {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-10px); }
}

.subtitle {
  color: rgba(255, 255, 255, 0.9);
  font-size: 1.2rem;
  max-width: 500px;
}

/* Contenedor principal */
.chat-main-container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 0 30px 50px;
}

.chat-wrapper-modern {
  display: grid;
  grid-template-columns: 1fr 320px;
  gap: 30px;
  min-height: calc(100vh - 200px);
}

/* Contenido del chat */
.chat-content {
  background: white;
  border-radius: var(--border-radius-lg);
  box-shadow: var(--shadow-lg);
  overflow: hidden;
  display: flex;
  flex-direction: column;
  height: calc(100vh - 200px);
  border: 1px solid rgba(255, 255, 255, 0.1);
}

/* Header del chat en tarjeta */
.chat-header-card {
  padding: 20px 25px;
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  border-bottom: 2px solid rgba(102, 126, 234, 0.2);
  display: flex;
  justify-content: space-between;
  align-items: center;
  position: sticky;
  top: 0;
  z-index: 10;
}

.chat-user-info {
  display: flex;
  gap: 20px;
  align-items: center;
}

.user-avatar-wrapper {
  position: relative;
}

.user-avatar-modern {
  width: 70px;
  height: 70px;
  border-radius: 50%;
  object-fit: cover;
  border: 4px solid white;
  box-shadow: var(--shadow-md);
  transition: transform var(--transition-normal);
}

.user-avatar-modern:hover {
  transform: scale(1.05);
}

.online-dot {
  position: absolute;
  bottom: 5px;
  right: 5px;
  width: 15px;
  height: 15px;
  border-radius: 50%;
  background: #b2bec3;
  border: 3px solid white;
  transition: all var(--transition-normal);
}

.online-dot.online {
  background: #00b894;
  box-shadow: 0 0 0 3px rgba(0, 184, 148, 0.2);
  animation: pulse-online 2s infinite;
}

@keyframes pulse-online {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.1); }
}

.user-name-section {
  display: flex;
  align-items: center;
  gap: 15px;
  margin-bottom: 8px;
}

.user-name-modern {
  font-size: 1.8rem;
  color: var(--text-dark);
  font-weight: 700;
  margin: 0;
}

.online-badge-modern {
  background: rgba(0, 184, 148, 0.1);
  color: #00b894;
  padding: 5px 15px;
  border-radius: 50px;
  font-size: 0.8rem;
  font-weight: 700;
  display: inline-flex;
  align-items: center;
  gap: 8px;
  border: 1px solid rgba(0, 184, 148, 0.3);
}

.pulse-dot {
  width: 8px;
  height: 8px;
  background: #00b894;
  border-radius: 50%;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 1; transform: scale(1); }
  50% { opacity: 0.5; transform: scale(1.5); }
}

.user-role-badge {
  display: inline-block;
  padding: 6px 16px;
  border-radius: 50px;
  font-weight: 600;
  font-size: 0.9rem;
  margin-bottom: 5px;
}

.user-role-badge.provider {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.user-role-badge.client {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
  color: white;
}

.user-role-badge.admin {
  background: linear-gradient(135deg, #ff7675 0%, #d63031 100%);
  color: white;
}

.user-role-badge.user {
  background: var(--text-light);
  color: white;
}

.last-seen {
  font-size: 0.85rem;
  color: var(--text-light);
}

/* Acciones del chat */
.action-buttons {
  display: flex;
  gap: 10px;
  align-items: center;
}

.action-icon-btn {
  width: 45px;
  height: 45px;
  border-radius: 50%;
  border: none;
  background: white;
  color: var(--text-dark);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.2rem;
  transition: all var(--transition-normal);
  box-shadow: var(--shadow-sm);
  border: 1px solid rgba(102, 126, 234, 0.1);
}

.action-icon-btn:hover {
  transform: translateY(-3px);
  box-shadow: var(--shadow-md);
  background: var(--primary-gradient);
  color: white;
}

.action-icon-btn.favorited {
  background: var(--warning-gradient);
  color: white;
}

.action-icon-btn.active {
  background: var(--primary-gradient);
  color: white;
  transform: scale(1.1);
}

/* Dropdown mejorado */
.dropdown-modern {
  position: relative;
}

.dropdown-menu-modern {
  position: absolute;
  top: 100%;
  right: 0;
  margin-top: 10px;
  background: white;
  border-radius: var(--border-radius-md);
  box-shadow: var(--shadow-lg);
  min-width: 250px;
  z-index: 1000;
  overflow: hidden;
  border: 1px solid rgba(102, 126, 234, 0.1);
  animation: slideDown 0.3s ease-out;
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

.dropdown-item {
  width: 100%;
  padding: 15px 20px;
  border: none;
  background: white;
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
  font-size: 0.95rem;
  color: var(--text-dark);
  transition: all var(--transition-normal);
  text-align: left;
}

.dropdown-item:hover {
  background: linear-gradient(135deg, #f5f7fa 0%, #e4edf5 100%);
  transform: translateX(5px);
}

.dropdown-item.warning:hover {
  background: linear-gradient(135deg, #fdcb6e 0%, #e17055 100%);
  color: white;
}

.dropdown-item.danger:hover {
  background: linear-gradient(135deg, #ff7675 0%, #d63031 100%);
  color: white;
}

.dropdown-divider {
  height: 1px;
  background: linear-gradient(90deg, transparent, rgba(102, 126, 234, 0.3), transparent);
  margin: 5px 0;
}

.admin-section {
  padding: 5px 0;
}

.admin-label {
  padding: 8px 20px;
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--danger-color);
  text-transform: uppercase;
  letter-spacing: 1px;
}

.item-icon {
  width: 24px;
  font-size: 1.1rem;
}

/* Área de mensajes */
.messages-area-modern {
  flex: 1;
  overflow-y: auto;
  padding: 30px;
  background: linear-gradient(135deg, #f8f9fa 0%, #ffffff 100%);
  position: relative;
}

.messages-area-modern.empty {
  display: flex;
  align-items: center;
  justify-content: center;
}

/* Estado vacío mejorado */
.empty-messages-modern {
  text-align: center;
  max-width: 400px;
  margin: 0 auto;
  animation: fadeIn 0.5s ease-out;
}

.empty-icon-wrapper {
  width: 120px;
  height: 120px;
  border-radius: 50%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  margin: 0 auto 30px;
  display: flex;
  align-items: center;
  justify-content: center;
  animation: pulse 2s infinite;
  box-shadow: var(--shadow-lg);
}

.empty-icon {
  font-size: 4rem;
  filter: drop-shadow(2px 4px 6px rgba(0, 0, 0, 0.1));
}

.empty-title {
  font-size: 2rem;
  color: var(--text-dark);
  margin-bottom: 15px;
  background: linear-gradient(135deg, #667eea, #764ba2);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.empty-subtitle {
  color: var(--text-light);
  font-size: 1.1rem;
  line-height: 1.6;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

/* Lista de mensajes */
.messages-list-modern {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

/* Mensaje individual */
.message-modern {
  display: flex;
  gap: 15px;
  animation: slideInMessage 0.3s ease-out;
}

@keyframes slideInMessage {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.message-modern.sent {
  flex-direction: row-reverse;
}

.message-avatar-modern {
  width: 40px;
  height: 40px;
  flex-shrink: 0;
}

.avatar-small-modern {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid white;
  box-shadow: var(--shadow-sm);
}

.message-container-modern {
  max-width: 70%;
  position: relative;
}

.message-modern.sent .message-container-modern {
  max-width: 70%;
}

.message-bubble {
  background: white;
  padding: 15px 20px;
  border-radius: 20px 20px 20px 5px;
  box-shadow: var(--shadow-sm);
  position: relative;
  border: 1px solid rgba(102, 126, 234, 0.1);
  transition: transform var(--transition-normal);
}

.message-bubble:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
}

.message-modern.sent .message-bubble {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 20px 20px 5px 20px;
}

.message-delete-btn-modern {
  position: absolute;
  top: -8px;
  right: -8px;
  width: 24px;
  height: 24px;
  border-radius: 50%;
  background: var(--danger-gradient);
  color: white;
  border: none;
  cursor: pointer;
  font-size: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: all var(--transition-normal);
  box-shadow: var(--shadow-sm);
  z-index: 2;
}

.message-bubble:hover .message-delete-btn-modern {
  opacity: 1;
  transform: scale(1.1);
}

.message-text-modern {
  font-size: 1rem;
  line-height: 1.5;
  margin-bottom: 10px;
  word-wrap: break-word;
}

/* Imágenes en mensajes */
.message-image-modern {
  margin: 10px -20px -15px -20px;
  overflow: hidden;
  border-radius: 0 0 20px 20px;
  cursor: pointer;
  position: relative;
}

.image-preview-modern {
  width: 100%;
  max-height: 300px;
  object-fit: cover;
  transition: transform var(--transition-slow);
}

.image-preview-modern:hover {
  transform: scale(1.05);
}

.message-image-modern::after {
  content: '🔍';
  position: absolute;
  bottom: 10px;
  right: 10px;
  background: rgba(0, 0, 0, 0.5);
  color: white;
  width: 30px;
  height: 30px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity var(--transition-normal);
}

.message-image-modern:hover::after {
  opacity: 1;
}

.message-footer {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  gap: 8px;
  margin-top: 5px;
}

.message-time-modern {
  font-size: 0.75rem;
  color: var(--text-light);
  opacity: 0.8;
}

.message-modern.sent .message-time-modern {
  color: rgba(255, 255, 255, 0.8);
}

/* Status de mensajes */
.message-status-modern, .read-indicator-modern {
  display: flex;
  gap: 2px;
  font-size: 0.9rem;
}

.status-sent {
  color: var(--text-light);
  opacity: 0.5;
}

.status-delivered {
  color: var(--text-light);
}

.status-read {
  color: #00b894;
}

.read-indicator-modern {
  color: #00b894;
}

/* Typing indicator */
.typing-indicator-modern {
  padding: 10px 0;
  animation: fadeIn 0.3s ease-out;
}

.typing-bubble {
  background: white;
  padding: 12px 20px;
  border-radius: 20px 20px 20px 5px;
  box-shadow: var(--shadow-sm);
  display: inline-flex;
  align-items: center;
  gap: 10px;
  border: 1px solid rgba(102, 126, 234, 0.1);
}

.typing-dots {
  display: flex;
  gap: 5px;
  padding: 0 5px;
}

.typing-dots span {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: linear-gradient(135deg, #667eea, #764ba2);
  animation: typing 1.4s infinite ease-in-out;
}

.typing-dots span:nth-child(1) { animation-delay: 0s; }
.typing-dots span:nth-child(2) { animation-delay: 0.2s; }
.typing-dots span:nth-child(3) { animation-delay: 0.4s; }

@keyframes typing {
  0%, 60%, 100% { transform: translateY(0); opacity: 0.4; }
  30% { transform: translateY(-10px); opacity: 1; }
}

.typing-name {
  font-size: 0.9rem;
  color: var(--text-light);
  font-style: italic;
}

/* Vista previa de imagen */
.image-preview-modern-container {
  padding: 20px 25px;
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  border-top: 2px solid rgba(102, 126, 234, 0.2);
  animation: slideUp 0.3s ease-out;
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.preview-modern {
  background: white;
  border-radius: var(--border-radius-md);
  padding: 15px;
  box-shadow: var(--shadow-sm);
}

.preview-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.preview-label {
  font-weight: 600;
  color: var(--text-dark);
  display: flex;
  align-items: center;
  gap: 8px;
}

.preview-close-modern {
  width: 30px;
  height: 30px;
  border-radius: 50%;
  border: none;
  background: var(--danger-gradient);
  color: white;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all var(--transition-normal);
}

.preview-close-modern:hover {
  transform: rotate(90deg);
}

.preview-image-modern {
  max-width: 200px;
  max-height: 200px;
  border-radius: var(--border-radius-sm);
  box-shadow: var(--shadow-sm);
}

/* Área de entrada */
.input-area-modern {
  padding: 20px 25px;
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  border-top: 2px solid rgba(102, 126, 234, 0.2);
}

.input-wrapper-modern {
  display: flex;
  gap: 15px;
  margin-bottom: 15px;
}

.message-input-modern {
  flex: 1;
  padding: 18px 25px;
  border: 2px solid rgba(102, 126, 234, 0.2);
  border-radius: 50px;
  font-size: 1rem;
  transition: all var(--transition-normal);
  background: white;
  box-shadow: var(--shadow-sm);
}

.message-input-modern:focus {
  outline: none;
  border-color: var(--primary-color);
  box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.1);
  transform: translateY(-2px);
}

.message-input-modern:disabled {
  background: #f8f9fa;
  cursor: not-allowed;
}

.send-btn-modern {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  border: none;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
  transition: all var(--transition-normal);
  box-shadow: var(--shadow-md);
  position: relative;
  overflow: hidden;
}

.send-btn-modern::before {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  width: 0;
  height: 0;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.3);
  transform: translate(-50%, -50%);
  transition: width 0.5s, height 0.5s;
}

.send-btn-modern:hover::before {
  width: 100%;
  height: 100%;
}

.send-btn-modern:hover {
  transform: scale(1.1) rotate(90deg);
  box-shadow: var(--shadow-lg);
}

.send-btn-modern.loading {
  pointer-events: none;
  opacity: 0.7;
}

.send-btn-modern.disabled {
  opacity: 0.5;
  cursor: not-allowed;
  pointer-events: none;
}

.send-icon {
  position: relative;
  z-index: 1;
}

.spinner-small-modern {
  width: 25px;
  height: 25px;
  border: 3px solid rgba(255, 255, 255, 0.3);
  border-top: 3px solid white;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.input-hints-modern {
  display: flex;
  gap: 20px;
  justify-content: center;
}

.hint-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.9rem;
  color: var(--text-light);
}

.hint-icon {
  background: white;
  width: 24px;
  height: 24px;
  border-radius: 5px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.8rem;
  border: 1px solid rgba(102, 126, 234, 0.2);
}

.hint-item.online {
  color: #00b894;
}

.online-indicator {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #00b894;
  animation: pulse 2s infinite;
}

.hint-item.uploading {
  color: var(--primary-color);
}

/* Sidebar de información */
.sidebar-info-modern {
  background: transparent;
}

.info-card-modern {
  background: white;
  border-radius: var(--border-radius-lg);
  padding: 25px;
  box-shadow: var(--shadow-lg);
  border: 1px solid rgba(255, 255, 255, 0.1);
  position: sticky;
  top: 30px;
  animation: slideInRight 0.5s ease-out;
}

@keyframes slideInRight {
  from {
    opacity: 0;
    transform: translateX(30px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

.info-card-title {
  font-size: 1.4rem;
  color: var(--text-dark);
  margin-bottom: 20px;
  padding-bottom: 15px;
  border-bottom: 2px solid rgba(102, 126, 234, 0.2);
  display: flex;
  align-items: center;
  gap: 10px;
}

.title-icon {
  background: linear-gradient(135deg, #667eea, #764ba2);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  font-size: 1.6rem;
}

.info-content {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.info-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
  border-bottom: 1px dashed rgba(102, 126, 234, 0.1);
}

.info-label {
  color: var(--text-light);
  font-weight: 500;
  font-size: 0.95rem;
}

.info-value {
  color: var(--text-dark);
  font-weight: 600;
  font-size: 0.95rem;
}

.info-value.highlight {
  background: linear-gradient(135deg, #667eea, #764ba2);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.info-value.code {
  font-family: monospace;
  background: #f8f9fa;
  padding: 3px 8px;
  border-radius: 5px;
  font-size: 0.85rem;
}

.role-badge-modern {
  display: inline-block;
  padding: 5px 15px;
  border-radius: 50px;
  font-weight: 600;
  font-size: 0.85rem;
}

.role-badge-modern.provider {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.role-badge-modern.client {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
  color: white;
}

.role-badge-modern.admin {
  background: linear-gradient(135deg, #ff7675 0%, #d63031 100%);
  color: white;
}

.role-badge-modern.user {
  background: var(--text-light);
  color: white;
}

.status-value {
  display: flex;
  align-items: center;
  gap: 8px;
}

.status-value.online {
  color: #00b894;
}

.status-indicator-modern {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background: #b2bec3;
  transition: all var(--transition-normal);
}

.status-indicator-modern.online {
  background: #00b894;
  box-shadow: 0 0 0 3px rgba(0, 184, 148, 0.2);
  animation: pulse 2s infinite;
}

.info-divider {
  height: 2px;
  background: linear-gradient(90deg, transparent, rgba(102, 126, 234, 0.3), transparent);
  margin: 15px 0;
}

/* Estadísticas en el sidebar */
.stats-grid-modern {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 15px;
  margin-top: 15px;
}

.stat-item-modern {
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  padding: 15px 10px;
  border-radius: var(--border-radius-md);
  text-align: center;
  transition: transform var(--transition-normal);
}

.stat-item-modern:hover {
  transform: translateY(-3px);
  box-shadow: var(--shadow-sm);
}

.stat-value {
  display: block;
  font-size: 1.8rem;
  font-weight: 700;
  color: var(--primary-color);
  margin-bottom: 5px;
  background: linear-gradient(135deg, #667eea, #764ba2);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.stat-label {
  font-size: 0.75rem;
  color: var(--text-light);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

/* Loading state mejorado */
.loading-state-modern {
  min-height: calc(100vh - 200px);
  display: flex;
  align-items: center;
  justify-content: center;
}

.loading-card {
  background: white;
  padding: 50px;
  border-radius: var(--border-radius-lg);
  box-shadow: var(--shadow-lg);
  text-align: center;
  max-width: 400px;
  width: 100%;
  border: 1px solid rgba(255, 255, 255, 0.1);
  animation: fadeIn 0.5s ease-out;
}

.spinner-modern {
  width: 60px;
  height: 60px;
  margin: 0 auto 30px;
  border: 4px solid rgba(102, 126, 234, 0.2);
  border-top: 4px solid var(--primary-color);
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

.loading-card h3 {
  font-size: 1.5rem;
  color: var(--text-dark);
  margin-bottom: 10px;
}

.loading-card p {
  color: var(--text-light);
  margin-bottom: 20px;
}

.loading-progress {
  width: 100%;
  height: 6px;
  background: rgba(102, 126, 234, 0.1);
  border-radius: 3px;
  overflow: hidden;
}

.progress-bar {
  width: 60%;
  height: 100%;
  background: linear-gradient(90deg, #667eea, #764ba2);
  border-radius: 3px;
  animation: progress 2s ease-in-out infinite;
}

@keyframes progress {
  0% { transform: translateX(-100%); }
  100% { transform: translateX(200%); }
}

/* Modal de imagen mejorado */
.image-modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.95);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2000;
  backdrop-filter: blur(10px);
}

.modal-enter-active, .modal-leave-active {
  transition: all 0.5s;
}

.modal-enter-from, .modal-leave-to {
  opacity: 0;
  transform: scale(0.8);
}

.image-modal-container {
  position: relative;
  max-width: 90vw;
  max-height: 90vh;
  animation: zoomIn 0.3s ease-out;
}

@keyframes zoomIn {
  from {
    opacity: 0;
    transform: scale(0.8);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

.image-modal-close {
  position: absolute;
  top: -40px;
  right: 0;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  border: none;
  background: rgba(255, 255, 255, 0.2);
  color: white;
  cursor: pointer;
  font-size: 1.2rem;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all var(--transition-normal);
  backdrop-filter: blur(5px);
  border: 2px solid rgba(255, 255, 255, 0.1);
}

.image-modal-close:hover {
  background: var(--danger-gradient);
  transform: rotate(90deg) scale(1.1);
}

.image-modal-img {
  max-width: 100%;
  max-height: 90vh;
  object-fit: contain;
  border-radius: var(--border-radius-lg);
  box-shadow: var(--shadow-lg);
  border: 3px solid rgba(255, 255, 255, 0.1);
}

.image-modal-caption {
  position: absolute;
  bottom: -40px;
  left: 0;
  right: 0;
  text-align: center;
  color: rgba(255, 255, 255, 0.8);
  font-size: 1rem;
  padding: 10px;
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(5px);
  border-radius: var(--border-radius-md);
}

/* Animaciones adicionales */
.fade-enter-active, .fade-leave-active {
  transition: opacity 0.3s;
}

.fade-enter-from, .fade-leave-to {
  opacity: 0;
}

.slide-up-enter-active, .slide-up-leave-active {
  transition: all 0.3s;
}

.slide-up-enter-from, .slide-up-leave-to {
  opacity: 0;
  transform: translateY(20px);
}

.dropdown-enter-active, .dropdown-leave-active {
  transition: all 0.3s;
}

.dropdown-enter-from, .dropdown-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}

/* File input oculto */
.file-input-hidden {
  display: none;
}

/* Responsive */
@media (max-width: 1200px) {
  .chat-wrapper-modern {
    grid-template-columns: 1fr 280px;
    gap: 20px;
  }
  
  .user-name-modern {
    font-size: 1.5rem;
  }
}

@media (max-width: 992px) {
  .chat-wrapper-modern {
    grid-template-columns: 1fr;
  }
  
  .sidebar-info-modern {
    display: none;
  }
  
  .header {
    padding: 0 20px;
  }
  
  .title-section h1 {
    font-size: 2.2rem;
  }
}

@media (max-width: 768px) {
  .chat-main-container {
    padding: 0 15px 30px;
  }
  
  .chat-header-card {
    flex-direction: column;
    gap: 15px;
    align-items: flex-start;
  }
  
  .chat-user-info {
    width: 100%;
  }
  
  .user-name-modern {
    font-size: 1.3rem;
  }
  
  .action-buttons {
    width: 100%;
    justify-content: flex-end;
  }
  
  .messages-area-modern {
    padding: 20px 15px;
  }
  
  .message-container-modern {
    max-width: 85%;
  }
  
  .input-wrapper-modern {
    flex-direction: column;
  }
  
  .send-btn-modern {
    width: 100%;
    border-radius: 50px;
  }
  
  .message-input-modern {
    width: 100%;
  }
  
  .input-hints-modern {
    flex-wrap: wrap;
  }
  
  .empty-icon-wrapper {
    width: 80px;
    height: 80px;
  }
  
  .empty-icon {
    font-size: 2.5rem;
  }
  
  .empty-title {
    font-size: 1.5rem;
  }
}

@media (max-width: 480px) {
  .title-section h1 {
    font-size: 1.8rem;
  }
  
  .back-btn {
    padding: 8px 16px;
    font-size: 0.9rem;
  }
  
  .user-avatar-modern {
    width: 50px;
    height: 50px;
  }
  
  .user-name-section {
    flex-direction: column;
    align-items: flex-start;
    gap: 5px;
  }
  
  .online-badge-modern {
    padding: 3px 10px;
    font-size: 0.7rem;
  }
  
  .action-icon-btn {
    width: 35px;
    height: 35px;
    font-size: 1rem;
  }
  
  .dropdown-menu-modern {
    min-width: 200px;
  }
  
  .message-container-modern {
    max-width: 95%;
  }
  
  .message-bubble {
    padding: 10px 15px;
  }
  
  .input-area-modern {
    padding: 15px;
  }
  
  .message-input-modern {
    padding: 12px 20px;
  }
  
  .empty-icon-wrapper {
    width: 60px;
    height: 60px;
    margin-bottom: 20px;
  }
  
  .empty-icon {
    font-size: 2rem;
  }
  
  .empty-title {
    font-size: 1.2rem;
  }
  
  .empty-subtitle {
    font-size: 0.95rem;
  }
}

/* Scroll personalizado */
.messages-area-modern::-webkit-scrollbar {
  width: 6px;
}

.messages-area-modern::-webkit-scrollbar-track {
  background: rgba(102, 126, 234, 0.05);
  border-radius: 3px;
}

.messages-area-modern::-webkit-scrollbar-thumb {
  background: linear-gradient(135deg, #667eea, #764ba2);
  border-radius: 3px;
}

.messages-area-modern::-webkit-scrollbar-thumb:hover {
  background: linear-gradient(135deg, #764ba2, #667eea);
}

/* Efectos hover suaves */
.message-modern {
  transition: transform var(--transition-normal);
}

.status-sent { color: #9ca3af; } /* gris */
.status-delivered { color: #9ca3af; } /* gris */
.status-read { color: #3b82f6; } /* azul */
.message-modern:hover {
  transform: translateX(5px);
}

.message-modern.sent:hover {
  transform: translateX(-5px);
}

/* Tooltips personalizados */
[title] {
  position: relative;
  cursor: help;
}

[title]:hover::after {
  content: attr(title);
  position: absolute;
  bottom: 100%;
  left: 50%;
  transform: translateX(-50%);
  background: rgba(0, 0, 0, 0.8);
  color: white;
  padding: 5px 10px;
  border-radius: 5px;
  font-size: 0.8rem;
  white-space: nowrap;
  z-index: 1000;
  margin-bottom: 5px;
  animation: fadeIn 0.2s ease-out;
}
</style>
