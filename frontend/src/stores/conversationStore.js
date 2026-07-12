// src/stores/conversationStore.js
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import api from '@/axios'
import { useSocketStore } from './socketStore'
import { useOnlineUsersStore } from './onlineUsersStore'
import { useAuthStore } from './authStore'

export const useConversationStore = defineStore('conversation', () => {
  const conversations = ref([])
  const messages = ref({})
  const loaded = ref(false)
  const typingUsers = ref(new Map())
  const activeConversationId = ref(null)
  const unreadCount = computed(() =>
    conversations.value.reduce((sum, c) => sum + (c.unreadCount || 0), 0)
  )

  let _socketInitialized = false

  function initSocket() {
    if (_socketInitialized) return
    const socketStore = useSocketStore()
    const authStore = useAuthStore()
    const room = `user_${authStore.user.id}`
    socketStore.on('connect', () => {
      console.log('🔌 Chat conectado al WS')
      socketStore.emit('join-room', room)
    })
    _socketInitialized = true
  }

  function disconnectSocket() {
    const socketStore = useSocketStore()
    socketStore.off('connect')
    socketStore.off('new_message')
    socketStore.off('message_read')
    socketStore.off('message_delivered')
    socketStore.off('message_deleted')
    socketStore.off('typing_indicator')
    socketStore.off('message_sent_confirmation')
    _socketInitialized = false
    typingUsers.value.clear()
  }

  // ✅ CORREGIDO: Incluye is_online en la normalización
  function normalizeConversation(conv) {
    if (conv.participant && !conv.other_participant) {
      return {
        id: conv.id,
        other_participant: {
          id: conv.participant.id,
          name: conv.participant.name,
          avatar_url: conv.participant.avatar,
          role: conv.participant.role,
          is_online: conv.participant.is_online ?? false
        },
        lastMessage: conv.lastMessage || { text: '', created_at: null },
        unreadCount: conv.unreadCount || 0,
        participants: [conv.participant]
      }
    }
    if (conv.other_participant) {
      return {
        id: conv.id,
        other_participant: {
          id: conv.other_participant.id,
          name: conv.other_participant.name,
          avatar_url: conv.other_participant.avatar_url,
          role: conv.other_participant.role,
          is_online: conv.other_participant.is_online ?? false
        },
        lastMessage: conv.last_message || conv.lastMessage || { text: '', created_at: null },
        unreadCount: conv.unread_count || conv.unreadCount || 0,
        participants: conv.participants || []
      }
    }
    return conv
  }

  function markConversationAsRead(conversationId) {
    const conv = conversations.value.find(c => c.id === conversationId)
    if (conv) {
      conv.unreadCount = 0
      console.log(`📖 Conversación ${conversationId} marcada como leída localmente`)
    }
  }

  function markMessagesAsRead(data) {
    console.log('📚 markMessagesAsRead llamado desde socketStore:', data)
    const conversationId = data.conversation_id || data.conversationId
    const messageIds = data.message_ids || data.messageIds || (data.message_id ? [data.message_id] : [])
    if (conversationId && messageIds.length > 0) {
      markMessagesAsReadLocally(conversationId, messageIds)
    }
  }

  function markMessagesAsDelivered(data) {
    console.log('📬 markMessagesAsDelivered llamado desde socketStore:', data)
    const conversationId = data.conversation_id || data.conversationId
    const messageIds = data.message_ids || data.messageIds || (data.message_id ? [data.message_id] : [])
    if (conversationId && messageIds.length > 0) {
      markMessagesAsDeliveredLocally(conversationId, messageIds)
    }
  }

  const typingTimeouts = new Map()

  function setTypingIndicator(data) {
    console.log('⌨️ setTypingIndicator:', data)
    const conversationId = data.conversation_id || data.conversationId
    const userId = data.user_id || data.userId
    const isTyping = data.is_typing === true || data.isTyping === true

    if (!conversationId || !userId) return

    let typingSet = typingUsers.value.get(conversationId)
    if (!typingSet) {
      typingSet = new Set()
      typingUsers.value.set(conversationId, typingSet)
    }

    const key = `${conversationId}_${userId}`
    if (isTyping) {
      typingSet.add(userId)
      if (typingTimeouts.has(key)) {
        clearTimeout(typingTimeouts.get(key))
      }
      const timeout = setTimeout(() => {
        const currentSet = typingUsers.value.get(conversationId)
        if (currentSet?.has(userId)) {
          currentSet.delete(userId)
          if (currentSet.size === 0) {
            typingUsers.value.delete(conversationId)
          }
          typingUsers.value = new Map(typingUsers.value)
        }
        typingTimeouts.delete(key)
      }, 3000)
      typingTimeouts.set(key, timeout)
    } else {
      if (typingSet.has(userId)) {
        typingSet.delete(userId)
        if (typingSet.size === 0) {
          typingUsers.value.delete(conversationId)
        }
        typingUsers.value = new Map(typingUsers.value)
      }
      if (typingTimeouts.has(key)) {
        clearTimeout(typingTimeouts.get(key))
        typingTimeouts.delete(key)
      }
    }
  }

  function confirmMessageSent(data) {
    console.log('✅ confirmMessageSent:', data)

    if (!data) {
      console.warn('⚠️ confirmMessageSent: data es undefined')
      return
    }

    const conversationId = data.conversation_id || data.conversationId
    const tempId = data.temp_id || data.tempId

    if (!conversationId) {
      console.warn('⚠️ confirmMessageSent: falta conversationId', data)
      return
    }
    if (!tempId) {
      console.warn('⚠️ confirmMessageSent: falta tempId', data)
      return
    }

    if (!messages.value[conversationId]) {
      console.warn(`⚠️ confirmMessageSent: no hay mensajes para conversationId ${conversationId}`)
      messages.value[conversationId] = []
      return
    }

    const index = messages.value[conversationId].findIndex(m =>
      m.temp_id === tempId
    )

    if (index === -1) {
      console.warn(`⚠️ confirmMessageSent: no se encontró mensaje temporal con tempId ${tempId}`)
      return
    }

    let realMessage = data.message || data.payload || data
    if (realMessage === data && data.conversation_id && data.text !== undefined) {
      realMessage = data
    }
    if (!realMessage || typeof realMessage !== 'object') {
      console.warn('⚠️ confirmMessageSent: realMessage no es válido', realMessage)
      return
    }

    const tempMessage = messages.value[conversationId][index]
    const authStore = useAuthStore()

    const finalIsDelivered = tempMessage.is_delivered === true || realMessage.is_delivered === true
    const finalIsRead = tempMessage.is_read === true || realMessage.is_read === true

    const calculatedIsMine = String(realMessage.sender_id || tempMessage.sender_id) === String(authStore.user?.id) &&
                             (realMessage.sender || tempMessage.sender) === authStore.user?.role

    const confirmedMessage = {
      id: realMessage.id || tempId,
      temp_id: tempId,
      conversation_id: conversationId,
      text: realMessage.text || tempMessage.text || '',
      type: realMessage.type || tempMessage.type || 'text',
      attachment_url: realMessage.attachment_url || tempMessage.attachment_url || null,
      sender_id: realMessage.sender_id || tempMessage.sender_id,
      sender: realMessage.sender || tempMessage.sender,
      receiver_id: realMessage.receiver_id || tempMessage.receiver_id,
      receiver_role: realMessage.receiver_role || tempMessage.receiver_role,
      created_at: realMessage.created_at || tempMessage.created_at || new Date().toISOString(),
      is_delivered: finalIsDelivered,
      is_read: finalIsRead,
      ...(finalIsRead && { is_delivered: true }),
      delivered_at: (tempMessage.is_delivered && tempMessage.delivered_at) || realMessage.delivered_at || null,
      read_at: (tempMessage.is_read && tempMessage.read_at) || realMessage.read_at || null,
      is_mine: calculatedIsMine,
      _temp: false,
      _confirmed: true,
      confirmed_at: new Date().toISOString(),
      avatar_url: authStore.user?.avatar_url || ''
    }

    messages.value[conversationId][index] = confirmedMessage

    messages.value = {
      ...messages.value,
      [conversationId]: [...messages.value[conversationId]]
    }

    const event = new CustomEvent('conversation-message-confirmed', {
      detail: {
        conversationId,
        tempId,
        message: confirmedMessage
      }
    })
    window.dispatchEvent(event)

    const socketStore = useSocketStore()
    if (socketStore._pendingConfirmations) {
      socketStore._pendingConfirmations.delete(tempId)
    }
  }

  function sendTypingIndicator(conversationId, isTyping) {
    const socketStore = useSocketStore()
    const authStore = useAuthStore()
    socketStore.emit('typing', {
      conversation_id: conversationId,
      user_id: authStore.user?.id,
      user_role: authStore.user?.role,
      is_typing: isTyping
    })
  }

  async function fetchConversations() {
    try {
      const { data: res } = await api.get('/conversations')
      const list = Array.isArray(res) ? res : res.conversations || []
      conversations.value = list.map(c => normalizeConversation(c))
      
      // ✅ Sincronizar onlineUsersStore con is_online de las conversaciones
      const onlineUsersStore = useOnlineUsersStore()
      list.forEach(conv => {
        const other = conv.participant || conv.other_participant
        if (other && other.is_online) {
          onlineUsersStore.addOnlineUser({
            userId: other.id,
            role: other.role,
            name: other.name,
            avatar: other.avatar || other.avatar_url
          })
        } else if (other && !other.is_online) {
          onlineUsersStore.removeOnlineUser(other.id, other.role)
        }
      })
      
      console.log('📋 Conversaciones normalizadas:', conversations.value)
    } catch (err) {
      console.error('Error fetching conversations:', err)
    } finally {
      loaded.value = true
    }
  }

  async function fetchConversation(id) {
    try {
      const { data } = await api.get(`/conversations/${id}`)
      const conversation = data.conversation || data
      const normalized = normalizeConversation(conversation)
      const index = conversations.value.findIndex(c => c.id === normalized.id)
      if (index !== -1) {
        conversations.value[index] = normalized
      } else {
        conversations.value.push(normalized)
      }
      return normalized
    } catch (err) {
      console.error(`Error fetching conversation ${id}:`, err)
      throw err
    }
  }

  async function fetchMessages(conversationId) {
    try {
      const { data } = await api.get(`/messages/${conversationId}`)
      const authStore = useAuthStore()
      console.log('📥 fetchMessages - Datos recibidos:', data.messages?.length || 0, 'mensajes')

      messages.value[conversationId] = (data.messages || []).map(m => ({
        ...m,
        conversation_id: conversationId,
        is_mine: String(m.sender_id) === String(authStore.user?.id) &&
         m.sender === authStore.user?.role,
        is_delivered: Boolean(m.is_delivered),
        is_read: Boolean(m.is_read)
      }))

      console.log('📥 fetchMessages - Mensajes procesados:', messages.value[conversationId].length)
      console.log('📥 Primer mensaje:', messages.value[conversationId][0])

      const unreadInThisConv = messages.value[conversationId].filter(
        m => !m.is_read && !m.is_mine
      ).length
      const conv = conversations.value.find(c => c.id === conversationId)
      if (conv) {
        conv.unreadCount = unreadInThisConv
      }
    } catch (err) {
      console.error('Error fetching messages:', err)
    }
  }

  async function syncMessageStatuses(conversationId) {
    if (!conversationId) return
    try {
      console.log('🔄 [STORE] Sincronizando estados de mensajes para conversación:', conversationId)
      const { data } = await api.get(`/messages/${conversationId}/status`, {
        headers: { Authorization: `Bearer ${useAuthStore().token}` }
      })
      if (data?.messages && data.messages.length > 0) {
        const msgs = messages.value[conversationId]
        if (!msgs) return

        let updated = false
        let newlyReadCount = 0
        let newlyDeliveredCount = 0

        const updatedMessages = msgs.map(localMsg => {
          const serverMsg = data.messages.find(m => m.id === localMsg.id)
          if (!serverMsg) return localMsg

          let newMsg = { ...localMsg }

          if (serverMsg.is_read && !localMsg.is_read) {
            newMsg.is_read = true
            newMsg.read_at = serverMsg.read_at || new Date().toISOString()
            newlyReadCount++
            updated = true
          }
          if (serverMsg.is_delivered && !localMsg.is_delivered) {
            newMsg.is_delivered = true
            newMsg.delivered_at = serverMsg.delivered_at || new Date().toISOString()
            newlyDeliveredCount++
            updated = true
          }

          return newMsg
        })

        if (updated) {
          messages.value[conversationId] = updatedMessages
        }

        const conv = conversations.value.find(c => c.id === conversationId)
        if (conv && newlyReadCount > 0) {
          conv.unreadCount = Math.max(0, (conv.unreadCount || 0) - newlyReadCount)
        }

        console.log(`🔄 [STORE] Sincronización completada: ${newlyReadCount} leídos, ${newlyDeliveredCount} entregados`)
      }
    } catch (err) {
      console.error('❌ [STORE] Error sincronizando estados:', err)
    }
  }

  async function markAsRead(conversationId, messageIds) {
    if (!messageIds || messageIds.length === 0) return
    try {
      markMessagesAsReadLocally(conversationId, messageIds)
      await api.post('/messages/read', { message_ids: messageIds })
      console.log('✅ Mensajes marcados como leídos (HTTP):', messageIds)
    } catch (err) {
      console.error('Error marking as read:', err)
    }
  }

  async function markAsDelivered(conversationId, messageIds) {
    if (!messageIds || messageIds.length === 0) return
    try {
      console.log('📬 markAsDelivered: solo actualización local, el backend emitirá el evento')
    } catch (err) {
      console.error('Error marking as delivered:', err)
    }
  }

  async function deleteMessageForMe(messageId, conversationId) {
    try {
      await api.delete(`/messages/${messageId}/for-me`)
      removeMessage(conversationId, messageId)
      showNotification('Mensaje borrado', 'success')
    } catch (err) {
      console.error('Error deleting message:', err)
      showNotification('Error al borrar mensaje', 'error')
    }
  }

  async function deleteConversationForMe(conversationId) {
    try {
      await api.delete(`/conversations/${conversationId}/for-me`)
      conversations.value = conversations.value.filter(c => c.id !== conversationId)
      delete messages.value[conversationId]
      typingUsers.value.delete(conversationId)
      showNotification('Conversación borrada', 'success')
    } catch (err) {
      console.error('Error deleting conversation:', err)
      showNotification('Error al borrar conversación', 'error')
    }
  }

  function removeMessage(conversationId, messageId) {
    if (messages.value[conversationId]) {
      messages.value[conversationId] = messages.value[conversationId].filter(m => m.id !== messageId)
    }
  }

  function addMessage(conversationId, message) {
    const authStore = useAuthStore()
    const socketStore = useSocketStore()

    if (!message) {
      console.warn('⚠️ addMessage: message es undefined')
      return
    }

    console.log('📨 addMessage:', { conversationId, message })

    if (!messages.value[conversationId]) {
      messages.value[conversationId] = []
    }

    if (message.is_mine === true && message.temp_id) {
      const tempIndex = messages.value[conversationId].findIndex(m => m.temp_id === message.temp_id)
      if (tempIndex !== -1) {
        console.log('🔄 Reemplazando mensaje temporal con confirmación por socket:', message.temp_id)
        const tempMsg = messages.value[conversationId][tempIndex]
        messages.value[conversationId][tempIndex] = {
          ...message,
          is_delivered: tempMsg.is_delivered || message.is_delivered,
          is_read: tempMsg.is_read || message.is_read,
          delivered_at: tempMsg.delivered_at || message.delivered_at,
          read_at: tempMsg.read_at || message.read_at,
          _confirmed: true
        }
        messages.value = {
          ...messages.value,
          [conversationId]: [...messages.value[conversationId]]
        }
        return
      }
    }

    const messageId = message.id || message._id
    if (!messageId) {
      console.warn('⚠️ addMessage: message sin ID', message)
      return
    }

    const existsById = messages.value[conversationId].some(m => m.id === messageId && !m._temp)
    const existsByTempId = message.temp_id && messages.value[conversationId].some(m => m.temp_id === message.temp_id)

    if (existsById) {
      console.log('⛔ Mensaje real ya existe, evitando duplicado')
      return
    }
    if (existsByTempId) {
      console.log('⛔ Mensaje con temp_id ya existe, evitando duplicado')
      return
    }

    const calculatedIsMine = String(message.sender_id) === String(authStore.user?.id) &&
                             message.sender === authStore.user?.role

    const enrichedMessage = {
      ...message,
      id: messageId,
      conversation_id: conversationId,
      is_delivered: message.is_delivered === true,
      is_read: message.is_read === true,
      is_mine: calculatedIsMine,
      delivered_at: message.delivered_at || null,
      read_at: message.read_at || null,
      _temp: message._temp || false,
      received_at: new Date().toISOString()
    }

    messages.value[conversationId].push(enrichedMessage)
    messages.value[conversationId].sort((a, b) =>
      new Date(a.created_at) - new Date(b.created_at)
    )

    console.log('✅ Mensaje agregado:', enrichedMessage)

    const conv = conversations.value.find(c => c.id === conversationId)
    if (conv) {
      conv.lastMessage = {
        text: message.text || '',
        created_at: message.created_at || new Date().toISOString(),
        sender: message.sender,
        type: message.type || 'text',
        is_delivered: enrichedMessage.is_delivered,
        is_read: enrichedMessage.is_read,
        id: message.id,
        temp_id: message.temp_id || null
      }
      if (!enrichedMessage.is_mine && !enrichedMessage.is_read) {
        conv.unreadCount = (conv.unreadCount || 0) + 1
      }
      conv.updated_at = message.created_at || new Date().toISOString()
    } else {
      const otherId = calculatedIsMine ? message.receiver_id : message.sender_id
      const otherRole = calculatedIsMine ? message.receiver_role : message.sender
      const otherName = calculatedIsMine ? message.receiver_name : message.sender_name
      const otherAvatar = calculatedIsMine ? message.receiver_avatar : message.sender_avatar

      const newConversation = {
        id: conversationId,
        other_participant: {
          id: otherId || 0,
          name: otherName || 'Usuario',
          avatar_url: otherAvatar || null,
          role: otherRole || 'user',
          is_online: false
        },
        lastMessage: {
          text: message.text || '',
          created_at: message.created_at || new Date().toISOString(),
          sender: message.sender,
          type: message.type || 'text',
          is_delivered: enrichedMessage.is_delivered,
          is_read: enrichedMessage.is_read,
          id: message.id,
          temp_id: message.temp_id || null
        },
        participants: [],
        unreadCount: enrichedMessage.is_mine ? 0 : 1,
        updated_at: message.created_at || new Date().toISOString(),
        created_at: message.created_at || new Date().toISOString()
      }
      conversations.value.unshift(newConversation)
      console.log('📋 Nueva conversación creada:', newConversation)
    }

    if (!calculatedIsMine) {
      socketStore.playNotificationSound()
    }

    window.dispatchEvent(new CustomEvent('conversation-message-added', {
      detail: { conversationId, message: enrichedMessage }
    }))
  }

  function markMessagesAsReadLocally(conversationId, messageIds) {
    console.log('📖 [STORE] Marcando localmente como leídos:', { conversationId, messageIds })

    const msgs = messages.value[conversationId]
    if (!msgs) return

    let updated = false
    let newlyReadCount = 0

    const updatedMessages = msgs.map(m => {
      const matchesRealId = messageIds.includes(m.id)
      const matchesTempId = m.temp_id && messageIds.some(id => {
        return String(id) === String(m.id) || (m._confirmed && String(id) === String(m.temp_id))
      })

      if ((matchesRealId || matchesTempId) && !m.is_read) {
        updated = true
        newlyReadCount++
        console.log(`📖 [STORE] Marcando como leído mensaje: ${m.id} (temp: ${m.temp_id})`)
        return {
          ...m,
          is_read: true,
          is_delivered: true,
          read_at: new Date().toISOString(),
          delivered_at: m.delivered_at || new Date().toISOString()
        }
      }
      return m
    })

    if (updated) {
      messages.value = {
        ...messages.value,
        [conversationId]: updatedMessages
      }
      console.log(`📖 [STORE] ${newlyReadCount} mensajes marcados como leídos`)
    }

    const conv = conversations.value.find(c => c.id === conversationId)
    if (conv) {
      const msgs = messages.value[conversationId] || []
      conv.unreadCount = msgs.filter(m => !m.is_read && !m.is_mine).length
    }
  }

  function markMessagesAsDeliveredLocally(conversationId, messageIds) {
    console.log('📬 [STORE] Marcando localmente como entregados:', { conversationId, messageIds });

    const msgs = messages.value[conversationId];
    if (!msgs) {
      console.warn(`⚠️ [STORE] No hay mensajes para conversación ${conversationId}`);
      return;
    }

    let updated = false;
    let updatedCount = 0;

    const updatedMessages = msgs.map(m => {
      const messageIdStr = String(m.id);
      const isInList = messageIds.some(id => String(id) === messageIdStr);
      const isConfirmedTemp = m.temp_id && messageIds.some(id => String(id) === String(m.temp_id));

      if ((isInList || isConfirmedTemp) && !m.is_delivered) {
        updated = true;
        updatedCount++;
        console.log(`📬 [STORE] Marcando como entregado mensaje: ${m.id} (temp: ${m.temp_id})`);
        return {
          ...m,
          is_delivered: true,
          delivered_at: new Date().toISOString(),
          _updated_at: Date.now()
        };
      }
      return m;
    });

    if (updated) {
      messages.value = {
        ...messages.value,
        [conversationId]: [...updatedMessages]
      };
      console.log(`📬 [STORE] ${updatedCount} mensajes marcados como entregados`);
    }

    const conv = conversations.value.find(c => c.id === conversationId);
    if (conv && conv.lastMessage) {
      const lastMsgId = String(conv.lastMessage.id);
      if (messageIds.some(id => String(id) === lastMsgId)) {
        conv.lastMessage = {
          ...conv.lastMessage,
          is_delivered: true,
          delivered_at: new Date().toISOString()
        };
      }
    }
  }

  function goToChat(conversationId, router) {
    router.push(`/chat/${conversationId}`)
  }

  function prependMessage(payload) {
    addMessage(payload.conversationId, payload)
  }

  function updateConversation(payload) {
    const idx = conversations.value.findIndex(c => c.id === payload.id)
    if (idx !== -1) Object.assign(conversations.value[idx], payload)
  }

  function getMessageStatus(message) {
    if (!message) return { icon: '', color: '', title: '' }
    const isOwn = message.is_mine
    if (!isOwn) {
      return {
        icon: message.is_read ? '✓✓' : '',
        color: message.is_read ? 'text-blue-500' : '',
        title: message.is_read ? 'Leído' : ''
      }
    }
    if (message.is_read) {
      return { icon: '✓✓', color: 'text-blue-500', title: 'Leído' }
    }
    if (message.is_delivered) {
      return { icon: '✓✓', color: 'text-gray-400', title: 'Entregado' }
    }
    return { icon: '✓', color: 'text-gray-400', title: 'Enviado' }
  }

  function getTypingUsers(conversationId) {
    const typingSet = typingUsers.value.get(conversationId)
    return typingSet ? Array.from(typingSet) : []
  }

  function showNotification(message, type = 'info') {
    console.log(`[${type.toUpperCase()}] ${message}`)
    if (type === 'error' || type === 'success') {
      alert(message)
    }
  }

  return {
    conversations,
    messages,
    unreadCount,
    loaded,
    typingUsers,
    activeConversationId,
    initSocket,
    disconnectSocket,
    fetchConversation,
    fetchConversations,
    fetchMessages,
    syncMessageStatuses,
    markAsRead,
    markAsDelivered,
    deleteMessageForMe,
    deleteConversationForMe,
    goToChat,
    prependMessage,
    updateConversation,
    addMessage,
    getMessageStatus,
    markMessagesAsReadLocally,
    markMessagesAsDeliveredLocally,
    markMessagesAsRead,
    markMessagesAsDelivered,
    setTypingIndicator,
    confirmMessageSent,
    sendTypingIndicator,
    getTypingUsers,
    removeMessage,
    normalizeConversation,
    markConversationAsRead
  }
})
