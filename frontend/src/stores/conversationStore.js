// src/stores/conversationStore.js
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import api from '@/axios'
import { useSocketStore } from './socketStore'   // ← usamos el store central
import { useAuthStore }   from './authStore'

export const useConversationStore = defineStore('conversation', () => {
  const conversations = ref([])
  const messages      = ref({})
  const loaded        = ref(false)

  const unreadCount = computed(() =>
    conversations.value.reduce((sum, c) => sum + (c.unreadCount || 0), 0)
  )

  /* ------------------------------------------------------------------ */
  /*  1.  Inicialización del socket (solo UNA vez)                       */
  /* ------------------------------------------------------------------ */
  function initSocket() {
    const socketStore = useSocketStore()
    const authStore   = useAuthStore()

    // si ya estamos escuchando, no hacemos nada
    if (socketStore.socket?.hasListeners('newMessage')) return

    const room = `user_${authStore.user.id}`

    // Nos aprovechamos del socket YA conectado por socketStore
    socketStore.on('connect', () => {
      console.log('🔌 Chat conectado al WS')
      socketStore.emit('join-room', room)
    })

    socketStore.on('newMessage', ({ conversationId, message }) => {
      addMessage(conversationId, message)
    })

    socketStore.on('messageRead', ({ conversationId, messageIds }) => {
      markMessagesAsReadLocally(conversationId, messageIds)
    })
  }

  /* ------------------------------------------------------------------ */
  /*  2.  Desconectar (cuando haga falta)                               */
  /* ------------------------------------------------------------------ */
  function disconnectSocket() {
    const socketStore = useSocketStore()
    socketStore.off('newMessage')
    socketStore.off('messageRead')
    // NO llamamos socket.disconnect() aquí; lo hace socketStore cuando proceda
  }

  /* ------------------------------------------------------------------ */
  /*  3.  Resto de acciones (sin cambios)                               */
  /* ------------------------------------------------------------------ */
  async function fetchConversations() {
    try {
      const { data: res } = await api.get('/conversations')
      const list = Array.isArray(res) ? res : res.conversations || []
      conversations.value = list.map(c => ({
        ...c,
        participants: Array.isArray(c.participants)
          ? c.participants
          : [c.participants || '?'],
        lastMessage: c.lastMessage || { text: '', created_at: null },
      }))
    } catch (err) {
      console.error('Error fetching conversations:', err)
    } finally {
      loaded.value = true
    }
  }

  async function fetchMessages(conversationId) {
    try {
      const { data } = await api.get(`/conversations/${conversationId}/messages`)
      messages.value[conversationId] = Array.isArray(data) ? data : []
    } catch (err) {
      console.error('Error fetching messages:', err)
    }
  }

  async function sendMessage(conversationId, text) {
    try {
      const { data } = await api.post(`/conversations/${conversationId}/messages`, { text })
      addMessage(conversationId, data)
      useSocketStore().emit('sendMessage', { conversationId, message: data })
    } catch (err) {
      console.error('Error sending message:', err)
    }
  }

  async function markAsRead(conversationId, messageIds) {
    try {
      await api.post(`/conversations/${conversationId}/read`, { messageIds })
      markMessagesAsReadLocally(conversationId, messageIds)
      useSocketStore().emit('readMessages', { conversationId, messageIds })
    } catch (err) {
      console.error('Error marking as read:', err)
    }
  }

  function addMessage(conversationId, message) {
    if (!messages.value[conversationId]) messages.value[conversationId] = []
    messages.value[conversationId].unshift(message)

    const conv = conversations.value.find(c => c.id === conversationId)
    if (conv) {
      conv.lastMessage = message
      if (!message.isOwn) conv.unreadCount = (conv.unreadCount || 0) + 1
    } else {
      // Crear conversación mínima si no existe
      conversations.value.unshift({
        id: conversationId,
        lastMessage: message,
        participants: message.participants || [],
        unreadCount: message.isOwn ? 0 : 1,
        updated_at: message.created_at || new Date().toISOString(),
        otherName: message.otherName || 'Usuario',
        otherAvatar: message.otherAvatar || null
      })
    }
  }

  function markMessagesAsReadLocally(conversationId, messageIds) {
    const conv = conversations.value.find(c => c.id === conversationId)
    if (conv) conv.unreadCount = Math.max(0, (conv.unreadCount || 0) - messageIds.length)

    const msgs = messages.value[conversationId]
    if (msgs) {
      msgs.forEach(m => {
        if (messageIds.includes(m.id)) m.isRead = true
      })
    }
  }

  function goToChat(conversationId, router) {
    router.push(`/chat/${conversationId}`)
  }

  /* ----------  MÉTODOS PARA TIEMPO-REAL (llamados desde MainLayout)  ---------- */
  function prependMessage(payload) {
    // payload = { conversationId, message, ... }
    addMessage(payload.conversationId, payload)
  }

  function updateConversation(payload) {
    const idx = conversations.value.findIndex(c => c.id === payload.id)
    if (idx !== -1) Object.assign(conversations.value[idx], payload)
  }

  return {
    conversations,
    messages,
    unreadCount,
    loaded,
    initSocket,
    disconnectSocket,
    fetchConversations,
    fetchMessages,
    sendMessage,
    markAsRead,
    goToChat,
    prependMessage,
    updateConversation,
  }
})
