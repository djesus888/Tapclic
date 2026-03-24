// src/stores/conversationStore.js
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import api from '@/axios'
import { useSocketStore } from './socketStore'
import { useAuthStore } from './authStore'

export const useConversationStore = defineStore('conversation', () => {
  const conversations = ref([])
  const messages = ref({})
  const loaded = ref(false)
  const typingUsers = ref(new Map()) // conversationId -> Set(userId)

  const unreadCount = computed(() =>
    conversations.value.reduce((sum, c) => sum + (c.unreadCount || 0), 0)
  )

  // -------------------------------------------------------
  // 1. Inicialización del socket (solo UNA vez)
  // -------------------------------------------------------
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

  // -------------------------------------------------------
  // 2. Desconectar (cuando haga falta)
  // -------------------------------------------------------
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

  // -------------------------------------------------------
  // 3. FUNCIÓN AUXILIAR: Normalizar conversación
  // -------------------------------------------------------
  function normalizeConversation(conv) {
    // Si viene de getConversations() (lista)
    if (conv.participant && !conv.other_participant) {
      return {
        id: conv.id,
        other_participant: {
          id: conv.participant.id,
          name: conv.participant.name,
          avatar_url: conv.participant.avatar,
          role: conv.participant.role
        },
        lastMessage: conv.lastMessage || { text: '', created_at: null },
        unreadCount: conv.unreadCount || 0,
        participants: [conv.participant]
      }
    }
    // Si viene de getById() (individual)
    if (conv.other_participant) {
      return {
        id: conv.id,
        other_participant: {
          id: conv.other_participant.id,
          name: conv.other_participant.name,
          avatar_url: conv.other_participant.avatar_url,
          role: conv.other_participant.role
        },
        lastMessage: conv.last_message || conv.lastMessage || { text: '', created_at: null },
        unreadCount: conv.unread_count || conv.unreadCount || 0,
        participants: conv.participants || []
      }
    }
    // Fallback
    return conv
  }

  // -------------------------------------------------------
  // 4. NUEVOS MÉTODOS REQUERIDOS POR SOCKETSTORE
  // -------------------------------------------------------

  // NUEVO: Método público para marcar mensajes como leídos (llamado desde socketStore)
  function markMessagesAsRead(data) {
    console.log('📚 markMessagesAsRead llamado desde socketStore:', data)
    const conversationId = data.conversation_id || data.conversationId
    const messageIds = data.message_ids || data.messageIds || (data.message_id ? [data.message_id] : [])

    if (conversationId && messageIds.length > 0) {
      markMessagesAsReadLocally(conversationId, messageIds)
    }
  }

  // NUEVO: Método público para marcar mensajes como entregados (llamado desde socketStore)
  function markMessagesAsDelivered(data) {
    console.log('📬 markMessagesAsDelivered llamado desde socketStore:', data)
    const conversationId = data.conversation_id || data.conversationId
    const messageIds = data.message_ids || data.messageIds || (data.message_id ? [data.message_id] : [])

    if (conversationId && messageIds.length > 0) {
      markMessagesAsDeliveredLocally(conversationId, messageIds)
    }
  }

  // NUEVO: Método para manejar indicadores de escritura
  const typingTimeouts = new Map() // userId -> timeout

  function setTypingIndicator(data) {
    console.log('⌨️ setTypingIndicator:', data)
    const conversationId = data.conversation_id || data.conversationId
    const userId = data.user_id || data.userId
    const isTyping = data.is_typing === true || data.isTyping === true

    if (!conversationId || !userId) return

    if (!typingUsers.value.has(conversationId)) {
      typingUsers.value.set(conversationId, new Set())
    }

    const typingSet = typingUsers.value.get(conversationId)

    if (isTyping) {
      typingSet.add(userId)

      // Limpiar timeout anterior si existe
      if (typingTimeouts.has(userId)) {
        clearTimeout(typingTimeouts.get(userId))
      }

      // Auto-limpiar después de 3 segundos
      const timeout = setTimeout(() => {
        const currentSet = typingUsers.value.get(conversationId)
        if (currentSet?.has(userId)) {
          currentSet.delete(userId)
          if (currentSet.size === 0) {
            typingUsers.value.delete(conversationId)
          }
        }
        typingTimeouts.delete(userId)
      }, 3000)

      typingTimeouts.set(userId, timeout)
    } else {
      typingSet.delete(userId)
      if (typingSet.size === 0) {
        typingUsers.value.delete(conversationId)
      }
      // Limpiar timeout si existe
      if (typingTimeouts.has(userId)) {
        clearTimeout(typingTimeouts.get(userId))
        typingTimeouts.delete(userId)
      }
    }
  }

  // NUEVO: Método para confirmar mensajes enviados
  function confirmMessageSent(data) {
    console.log('✅ confirmMessageSent:', data)
    // =====================================================
    // VALIDACIÓN 1: Verificar que data existe
    // =====================================================
    if (!data) {
      console.warn('⚠️ confirmMessageSent: data es undefined')
      return
    }
    // =====================================================
    // VALIDACIÓN 2: Extraer IDs correctamente
    // =====================================================
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

    // =====================================================
    // VALIDACIÓN 3: Verificar que existe el array de mensajes
    // =====================================================
    if (!messages.value[conversationId]) {
      console.warn(`⚠️ confirmMessageSent: no hay mensajes para conversationId ${conversationId}`)
      messages.value[conversationId] = []
      return
    }

    // =====================================================
    // VALIDACIÓN 4: Buscar mensaje temporal (CORREGIDO)
    // =====================================================
    const index = messages.value[conversationId].findIndex(m =>
      m.temp_id === tempId ||
      m.id === tempId ||
      m._temp_id === tempId ||
      (m._temp && m.id === tempId)
    )
    if (index === -1) {
      console.warn(`⚠️ confirmMessageSent: no se encontró mensaje temporal con tempId ${tempId}`)
      console.log('📋 Mensajes disponibles:', messages.value[conversationId].map(m => ({
        id: m.id,
        temp_id: m.temp_id,
        _temp: m._temp
      })))
      return
    }

    // =====================================================
    // VALIDACIÓN 5: Extraer el mensaje real de data
    // =====================================================
    // El mensaje puede venir en diferentes formatos:
    // - data.message (estructura completa)
    // - data (directamente el mensaje)
    // - data.payload (otro formato común)
    let realMessage = data.message || data.payload || data
    // Si realMessage es el mismo objeto que data y tiene conversation_id,
    // significa que data ES el mensaje directamente
    if (realMessage === data && data.conversation_id && data.text !== undefined) {
      realMessage = data
    }

    // =====================================================
    // VALIDACIÓN 6: Asegurar que realMessage es un objeto
    // =====================================================
    if (!realMessage || typeof realMessage !== 'object') {
      console.warn('⚠️ confirmMessageSent: realMessage no es válido', realMessage)
      return
    }
    console.log('📦 Mensaje real extraído:', realMessage)

    // =====================================================
    // GUARDAR REFERENCIA al mensaje temporal
    // =====================================================
    const tempMessage = messages.value[conversationId][index]

    // =====================================================
    // OBTENER authStore para verificar usuario actual
    // =====================================================
    const authStore = useAuthStore()

    // =====================================================
    // CONSTRUIR mensaje confirmado con VALIDACIONES
    // =====================================================
    const confirmedMessage = {
      // ✅ Preservar propiedades del mensaje temporal
      ...tempMessage,
      // ✅ Sobrescribir con datos reales del servidor
      ...realMessage,
      // ✅ FORZAR valores críticos
      id: realMessage.id || tempId,
      temp_id: tempId,
      conversation_id: conversationId,
      // ✅ Estado de entrega (con validación)
      is_delivered: realMessage.is_delivered !== undefined ? realMessage.is_delivered : true,
      // ✅ Estado de lectura (con validación)
      is_read: realMessage.is_read !== undefined ? realMessage.is_read : false,
      // ✅ Determinar si es mío (preservar del temporal o calcular) - CORREGIDO: convertir a string para comparación
      is_mine: tempMessage.is_mine !== undefined ? tempMessage.is_mine :
        (String(realMessage.sender_id) === String(authStore.user?.id)),
      // ✅ Fechas (con validación)
      created_at: realMessage.created_at || tempMessage.created_at || new Date().toISOString(),
      delivered_at: realMessage.delivered_at || new Date().toISOString(),
      read_at: realMessage.read_at || null,
      // ✅ Flags de estado
      _temp: false,
      _confirmed: true,
      confirmed_at: new Date().toISOString(),
      // ✅ Preservar datos adicionales importantes
      type: realMessage.type || tempMessage.type || 'text',
      text: realMessage.text || tempMessage.text || '',
      attachment_url: realMessage.attachment_url || tempMessage.attachment_url || null,
      sender_id: realMessage.sender_id || tempMessage.sender_id,
      receiver_id: realMessage.receiver_id || tempMessage.receiver_id,
      sender: realMessage.sender || tempMessage.sender,
      receiver: realMessage.receiver || tempMessage.receiver
    }

    // =====================================================
    // ACTUALIZAR el mensaje en el array
    // =====================================================
    messages.value[conversationId][index] = confirmedMessage
    console.log('✅ Mensaje confirmado y actualizado:', confirmedMessage)

    // =====================================================
    // ACTUALIZAR ÚLTIMO MENSAJE en la conversación
    // =====================================================
    const conv = conversations.value.find(c => c.id === conversationId)

    if (conv) {
      // Verificar si este mensaje es el último de la conversación
      const isLastMessage = !conv.lastMessage ||
        conv.lastMessage.id === tempId ||
        conv.lastMessage.temp_id === tempId ||
        (conv.lastMessage.created_at && confirmedMessage.created_at &&
          new Date(confirmedMessage.created_at) >= new Date(conv.lastMessage.created_at))

      if (isLastMessage) {
        conv.lastMessage = {
          text: confirmedMessage.text || '',
          created_at: confirmedMessage.created_at,
          sender: confirmedMessage.sender,
          type: confirmedMessage.type || 'text',
          is_delivered: confirmedMessage.is_delivered,
          is_read: confirmedMessage.is_read,
          id: confirmedMessage.id,
          temp_id: confirmedMessage.temp_id,
          attachment_url: confirmedMessage.attachment_url
        }
        console.log('📋 Último mensaje de conversación actualizado:', conv.lastMessage)
      }
    }

    // =====================================================
    // DISPARAR EVENTO PERSONALIZADO (opcional)
    // =====================================================
    const event = new CustomEvent('conversation-message-confirmed', {
      detail: {
        conversationId,
        tempId,
        message: confirmedMessage
      }
    })
    window.dispatchEvent(event)

    // =====================================================
    // LIMPIEZA: Eliminar de pendingConfirmations si existe
    // =====================================================
    const socketStore = useSocketStore()
    if (socketStore._pendingConfirmations) {
      socketStore._pendingConfirmations.delete(tempId)
    }
  }

  // NUEVO: Método para enviar indicador de escritura
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

  // -------------------------------------------------------
  // 5. Resto de acciones
  // -------------------------------------------------------

  async function fetchConversations() {
    try {
      const { data: res } = await api.get('/conversations')
      const list = Array.isArray(res) ? res : res.conversations || []

      conversations.value = list.map(c => normalizeConversation(c))
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

      messages.value[conversationId] = (data.messages || []).map(m => ({
        ...m,
        conversation_id: conversationId
      }))

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

  async function markAsRead(conversationId, messageIds) {
    if (!messageIds || messageIds.length === 0) return

    try {
      await api.post('/messages/read', { message_ids: messageIds })

      markMessagesAsReadLocally(conversationId, messageIds)

      const socketStore = useSocketStore()
      socketStore.emit('message_read', {
        conversation_id: conversationId,
        message_ids: messageIds
      })
    } catch (err) {
      console.error('Error marking as read:', err)
    }
  }

  async function markAsDelivered(conversationId, messageIds) {
    if (!messageIds || messageIds.length === 0) return

    try {
      const socketStore = useSocketStore()
      socketStore.emit('message_delivered', {
        conversation_id: conversationId,
        message_ids: messageIds
      })
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

  function sendMessage(conversationId, text, attachment_url = null) {
    const socketStore = useSocketStore()
    const temp_id = Date.now()
    const message = {
      temp_id,
      conversation_id: conversationId,
      text,
      attachment_url,
      _temp: true,
      created_at: new Date().toISOString()
    }
    // Agregar localmente
    addMessage(conversationId, message)

    // Enviar por socket
    socketStore.sendMessage(conversationId, message, temp_id)

    return message
  }

  // -------------------------------------------------------
  // FUNCIÓN COMPLETA: addMessage (CORREGIDA)
  // -------------------------------------------------------
  function addMessage(conversationId, message) {
    // ✅ Validación 1: Verificar que message existe
    if (!message) {
      console.warn('⚠️ addMessage: message es undefined')
      return
    }

    console.log('📨 addMessage:', { conversationId, message })

    // ✅ Validación 2: Inicializar array de mensajes si no existe
    if (!messages.value[conversationId]) {
      messages.value[conversationId] = []
    }

    // ✅ Validación 3: Obtener ID del mensaje
    const messageId = message.id || message._id
    if (!messageId) {
      console.warn('⚠️ addMessage: message sin ID', message)
      return
    }

    // ✅ Validación 4: Verificar si el mensaje ya existe (CORREGIDO)
    const exists = messages.value[conversationId].some(m =>
      m.id === messageId ||
      (message.temp_id && m.temp_id === message.temp_id)
    )

    if (exists) {
      console.log('📨 Mensaje ya existe, omitiendo:', messageId)
      return
    }

    // ✅ Validación 5: Obtener authStore para determinar si es mío
    const authStore = useAuthStore()

    // ✅ Construir mensaje enriquecido con validaciones - CORREGIDO: convertir a string para comparación
    const enrichedMessage = {
      ...message,
      id: messageId,
      conversation_id: conversationId,
      // ✅ Valores por defecto seguros
      is_delivered: message.is_delivered !== undefined ? message.is_delivered : false,
      is_read: message.is_read || false,
      delivered_at: message.delivered_at || null,
      read_at: message.read_at || null,
      // ✅ Determinar si es mío comparando sender_id con el usuario actual (CORREGIDO)
      is_mine: String(message.sender_id) === String(authStore.user?.id),
      // ✅ Preservar _temp si existe (para mensajes temporales)
      _temp: message._temp || false,
      // ✅ Timestamp de recepción
      received_at: new Date().toISOString()
    }

    // ✅ Agregar mensaje al array
    messages.value[conversationId].push(enrichedMessage)

    // ✅ Ordenar mensajes por fecha
    messages.value[conversationId].sort((a, b) =>
      new Date(a.created_at) - new Date(b.created_at)
    )

    console.log('📨 Mensaje agregado:', enrichedMessage)

    // =====================================================
    // ACTUALIZAR LA CONVERSACIÓN EN LA LISTA
    // =====================================================
    const conv = conversations.value.find(c => c.id === conversationId)

    if (conv) {
      // ✅ Actualizar último mensaje de la conversación
      conv.lastMessage = {
        text: message.text || '',
        created_at: message.created_at || new Date().toISOString(),
        sender: message.sender,
        type: message.type || 'text',
        is_delivered: message.is_delivered || false,
        is_read: message.is_read || false,
        id: message.id,
        temp_id: message.temp_id || null
      }

      // ✅ Actualizar contador de no leídos SOLO si el mensaje NO es mío y NO está leído
      if (!enrichedMessage.is_mine && !enrichedMessage.is_read) {
        conv.unreadCount = (conv.unreadCount || 0) + 1
      }

      // ✅ Actualizar timestamp de la conversación
      conv.updated_at = message.created_at || new Date().toISOString()
      console.log('📋 Conversación actualizada:', {
        id: conv.id,
        lastMessage: conv.lastMessage,
        unreadCount: conv.unreadCount
      })
    } else {
      // =====================================================
      // Si la conversación NO existe en la lista, CREAR UNA NUEVA
      // =====================================================
      console.log('📋 Creando nueva conversación desde mensaje:', conversationId)

      // ✅ Determinar quién es el otro participante
      const isMine = enrichedMessage.is_mine
      const otherId = isMine ? message.receiver_id : message.sender_id
      const otherRole = isMine ? message.receiver_role : message.sender
      const otherName = isMine ? message.receiver_name : message.sender_name
      const otherAvatar = isMine ? message.receiver_avatar : message.sender_avatar

      // ✅ Crear objeto de conversación temporal
      const newConversation = {
        id: conversationId,
        other_participant: {
          id: otherId || 0,
          name: otherName || 'Usuario',
          avatar_url: otherAvatar || null,
          role: otherRole || 'user'
        },
        lastMessage: {
          text: message.text || '',
          created_at: message.created_at || new Date().toISOString(),
          sender: message.sender,
          type: message.type || 'text',
          is_delivered: message.is_delivered || false,
          is_read: message.is_read || false,
          id: message.id,
          temp_id: message.temp_id || null
        },
        participants: [],
        unreadCount: enrichedMessage.is_mine ? 0 : 1,
        updated_at: message.created_at || new Date().toISOString(),
        created_at: message.created_at || new Date().toISOString()
      }

      // ✅ Agregar al inicio de la lista de conversaciones
      conversations.value.unshift(newConversation)
      console.log('📋 Nueva conversación creada:', newConversation)
    }

    // ✅ Emitir evento para notificar que hay nuevos mensajes (opcional)
    const event = new CustomEvent('conversation-message-added', {
      detail: { conversationId, message: enrichedMessage }
    })
    window.dispatchEvent(event)
  }

  function markMessagesAsReadLocally(conversationId, messageIds) {
    const conv = conversations.value.find(c => c.id === conversationId)
    if (conv) {
      conv.unreadCount = Math.max(0, (conv.unreadCount || 0) - messageIds.length)
      if (conv.lastMessage && messageIds.includes(conv.lastMessage.id)) {
        conv.lastMessage.is_read = true
      }
    }

    const msgs = messages.value[conversationId]
    if (msgs) {
      msgs.forEach(m => {
        if (messageIds.includes(m.id)) {
          m.is_read = true
          m.read_at = new Date().toISOString()
        }
      })
    }
  }

  function markMessagesAsDeliveredLocally(conversationId, messageIds) {
    const conv = conversations.value.find(c => c.id === conversationId)
    if (conv && conv.lastMessage && messageIds.includes(conv.lastMessage.id)) {
      conv.lastMessage.is_delivered = true
    }

    const msgs = messages.value[conversationId]
    if (msgs) {
      msgs.forEach(m => {
        if (messageIds.includes(m.id)) {
          m.is_delivered = true
          m.delivered_at = new Date().toISOString()
        }
      })
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
    return typingUsers.value.get(conversationId) || new Set()
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
    initSocket,
    disconnectSocket,
    fetchConversation,
    fetchConversations,
    fetchMessages,
    sendMessage,
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
    normalizeConversation
  }
})
