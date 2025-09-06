// src/stores/conversationStore.js
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import api from '@/axio'
import { io } from 'socket.io-client'

export const useConversationStore = defineStore('conversation', () => {
  /* ---------- Estado ---------- */
  const conversations = ref([])
  const messages      = ref({})
  const socket        = ref(null)
  const loaded        = ref(false)

  /* ---------- Computed ---------- */
  const unreadCount = computed(() =>
    conversations.value.reduce((sum, c) => sum + (c.unreadCount || 0), 0)
  )

  /* ---------- WebSocket ---------- */
  function initSocket(userId) {
    if (socket.value) return
    socket.value = io(import.meta.env.VITE_WS_URL || window.location.origin, {
      query: { userId },
    })

    socket.value.on('newMessage', ({ conversationId, message }) => {
      addMessage(conversationId, message)
    })

    socket.value.on('messageRead', ({ conversationId, messageIds }) => {
      markMessagesAsReadLocally(conversationId, messageIds)
    })
  }

  function disconnectSocket() {
    socket.value?.disconnect()
    socket.value = null
  }

  /* ---------- API ---------- */
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
      messages.value[conversationId] = data
    } catch (err) {
      console.error('Error fetching messages:', err)
    }
  }

  async function sendMessage(conversationId, text) {
    try {
      const { data } = await api.post(`/conversations/${conversationId}/messages`, { text })
      addMessage(conversationId, data)
      socket.value?.emit('sendMessage', { conversationId, message: data })
    } catch (err) {
      console.error('Error sending message:', err)
    }
  }

  async function markAsRead(conversationId, messageIds) {
    try {
      await api.post(`/conversations/${conversationId}/read`, { messageIds })
      markMessagesAsReadLocally(conversationId, messageIds)
      socket.value?.emit('readMessages', { conversationId, messageIds })
    } catch (err) {
      console.error('Error marking as read:', err)
    }
  }

  /* ---------- Helpers ---------- */
  function addMessage(conversationId, message) {
    if (!messages.value[conversationId]) messages.value[conversationId] = []
    messages.value[conversationId].push(message)

    const conv = conversations.value.find(c => c.id === conversationId)
    if (conv) {
      conv.lastMessage = message
      if (!message.isOwn) conv.unreadCount = (conv.unreadCount || 0) + 1
    }
  }

  function markMessagesAsReadLocally(conversationId, messageIds) {
    const conv = conversations.value.find(c => c.id === conversationId)
    if (conv)
      conv.unreadCount = Math.max(0, (conv.unreadCount || 0) - messageIds.length)

    const msgs = messages.value[conversationId]
    if (msgs)
      msgs.forEach(m => {
        if (messageIds.includes(m.id)) m.isRead = true
      })
  }

  /* ---------- Navegación ---------- */
  function goToChat(conversationId, router) {
    router.push(`/chat/${conversationId}`)
  }

  /* ---------- Exports ---------- */
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
  }
})
