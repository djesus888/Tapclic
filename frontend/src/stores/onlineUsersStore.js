// stores/onlineUsersStore.js
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { useAuthStore } from './authStore'

export const useOnlineUsersStore = defineStore('onlineUsers', () => {
  // Estado
  const users = ref([])
  const lastUpdate = ref(null)
  const typingUsers = ref(new Map())

  // Getters básicos
  const onlineCount = computed(() => users.value.length)

  const providersOnline = computed(() =>
    users.value.filter(u => u.role === 'provider')
  )

  const clientsOnline = computed(() =>
    users.value.filter(u => u.role === 'user' || u.role === 'client')
  )

  const adminsOnline = computed(() =>
    users.value.filter(u => u.role === 'admin')
  )

  // Getters agrupados por rol
  const onlineByRole = computed(() => ({
    providers: providersOnline.value,
    clients: clientsOnline.value,
    admins: adminsOnline.value,
    total: onlineCount.value
  }))

  // ✅ Clave única: rol + id
  function buildKey(id, role) {
    return `${role}_${id}`
  }

  // ✅ CORREGIDO: Limpia usuarios antiguos usando buildKey igual que mergeOnlineUsers
  function setOnlineUsers(newUsers) {
    const authStore = useAuthStore()
    const currentUserId = authStore.user?.id

    const newMap = new Map()

    newUsers.forEach(u => {
      const userId = u.userId || u.id
      const userRole = u.role
      newMap.set(buildKey(userId, userRole), {
        id: userId,
        name: u.name || u.userName,
        avatar: u.avatar || u.avatar_url,
        role: userRole,
        lastSeen: u.lastSeen || u.last_seen || u.connectedAt,
        isCurrentUser: userId === currentUserId,
        socketId: u.socketId,
        connectedAt: u.connectedAt
      })
    })

    // Eliminar los que ya no están
    users.value = users.value.filter(u => newMap.has(buildKey(u.id, u.role)))

    // Agregar o actualizar
    newMap.forEach((data, key) => {
      const idx = users.value.findIndex(u => buildKey(u.id, u.role) === key)
      if (idx !== -1) users.value[idx] = data
      else users.value.push(data)
    })

    lastUpdate.value = Date.now()
  }

  // ✅ Usa rol para distinguir usuarios con mismo ID
  function addOnlineUser(user) {
    const authStore = useAuthStore()
    const currentUserId = authStore.user?.id
    const userId = user.userId || user.id
    const userRole = user.role
    if (!userId) return

    const key = buildKey(userId, userRole)
    const exists = users.value.some(u => buildKey(u.id, u.role) === key)
    
    if (!exists) {
      users.value.push({
        id: userId,
        name: user.name || user.userName,
        avatar: user.avatar || user.avatar_url,
        role: userRole,
        lastSeen: user.lastSeen || user.last_seen || user.connectedAt,
        isCurrentUser: userId === currentUserId,
        socketId: user.socketId,
        connectedAt: user.connectedAt || new Date().toISOString()
      })
    }
  }

  // ✅ Soporta rol para eliminar correctamente
  function removeOnlineUser(userId, role = null) {
    const index = users.value.findIndex(u => u.id === userId && (!role || u.role === role))
    if (index !== -1) {
      users.value.splice(index, 1)
    }
  }

  // ✅ Merge inteligente: no pisa, actualiza
  function mergeOnlineUsers(newUsers) {
    const authStore = useAuthStore()
    const currentUserId = authStore.user?.id
    const newMap = new Map()

    newUsers.forEach(u => {
      const userId = u.userId || u.id
      const userRole = u.role
      newMap.set(buildKey(userId, userRole), {
        id: userId,
        name: u.name || u.userName,
        avatar: u.avatar || u.avatar_url,
        role: userRole,
        lastSeen: u.lastSeen || u.last_seen || u.connectedAt,
        isCurrentUser: userId === currentUserId,
        socketId: u.socketId,
        connectedAt: u.connectedAt || new Date().toISOString()
      })
    })

    // Eliminar los que ya no están
    users.value = users.value.filter(u => newMap.has(buildKey(u.id, u.role)))

    // Agregar o actualizar
    newMap.forEach((data, key) => {
      const idx = users.value.findIndex(u => buildKey(u.id, u.role) === key)
      if (idx !== -1) users.value[idx] = data
      else users.value.push(data)
    })
    
    lastUpdate.value = Date.now()
  }

  // ✅ CORREGIDO: Agregado parámetro role y búsqueda por id + role
  function updateUserLastSeen(userId, role, timestamp = Date.now()) {
    const user = users.value.find(u =>
      u.id === userId && u.role === role
    )
    if (user) {
      user.lastSeen = timestamp
    }
  }

  // ✅ CORREGIDO: Validar por ID + rol
  function isUserOnline(userId, role = null) {
    if (!userId) return false

    return users.value.some(u =>
      u.id === userId &&
      (!role || u.role === role)
    )
  }

  // ✅ CORREGIDO: Soporte para roles
  function getUserById(userId, role = null) {
    return users.value.find(u =>
      u.id === userId &&
      (!role || u.role === role)
    )
  }

  // ✅ CORREGIDO: Recibe y busca por id + role
  function getUserStatus(userId, role) {
    const user = users.value.find(u =>
      u.id === userId && u.role === role
    )
    return {
      online: !!user,
      user: user || null,
      lastSeen: user?.lastSeen || null
    }
  }

  // Obtener usuarios online filtrados por rol
  function getOnlineUsersByRole(role) {
    return users.value.filter(u => u.role === role)
  }

  // Obtener IDs de usuarios online
  const onlineUserIds = computed(() => users.value.map(u => u.id))

  // --- Funcionalidad de "escribiendo..." ---
  function setUserTyping(conversationId, userId, isTyping) {
    if (!conversationId || !userId) return

    if (!typingUsers.value.has(conversationId)) {
      typingUsers.value.set(conversationId, new Map())
    }

    const conversationTyping = typingUsers.value.get(conversationId)

    if (isTyping) {
      conversationTyping.set(userId, {
        userId,
        timestamp: Date.now(),
        conversationId
      })

      setTimeout(() => {
        const current = typingUsers.value.get(conversationId)
        if (current?.get(userId)?.timestamp < Date.now() - 4000) {
          current.delete(userId)
          if (current.size === 0) {
            typingUsers.value.delete(conversationId)
          }
        }
      }, 4000)
    } else {
      conversationTyping.delete(userId)
      if (conversationTyping.size === 0) {
        typingUsers.value.delete(conversationId)
      }
    }
  }

  function handleTypingEvent(data) {
    const { conversation_id, user_id, is_typing } = data
    setUserTyping(conversation_id, user_id, is_typing)
  }

  function isUserTyping(conversationId, userId) {
    return typingUsers.value.get(conversationId)?.has(userId) || false
  }

  function getUsersTyping(conversationId) {
    const typing = typingUsers.value.get(conversationId)
    if (!typing) return []

    return Array.from(typing.values())
      .filter(t => Date.now() - t.timestamp < 4000)
      .map(t => t.userId)
  }

  function getTypingNames(conversationId) {
    const userIds = getUsersTyping(conversationId)
    return userIds.map(id => {
      const user = getUserById(id)
      return user?.name || 'Alguien'
    })
  }

  function getTypingText(conversationId) {
    const typing = getUsersTyping(conversationId)

    if (typing.length === 0) return ''

    if (typing.length === 1) {
      const user = getUserById(typing[0])
      return `${user?.name || 'Alguien'} está escribiendo...`
    }

    if (typing.length === 2) {
      const users = typing.map(id => getUserById(id)?.name || 'Alguien')
      return `${users[0]} y ${users[1]} están escribiendo...`
    }

    return 'Varias personas están escribiendo...'
  }

  // --- Estadísticas ---
  const stats = computed(() => ({
    total: onlineCount.value,
    providers: providersOnline.value.length,
    clients: clientsOnline.value.length,
    admins: adminsOnline.value.length,
    lastUpdate: lastUpdate.value,
    typingInConversations: typingUsers.value.size
  }))

  // --- Reset / Limpieza ---
  function clearAll() {
    users.value = []
    typingUsers.value.clear()
    lastUpdate.value = null
  }
  
  function clearTyping() {
    typingUsers.value.clear()
  }

  // --- Persistencia opcional (para debugging) ---
  function saveToLocalStorage() {
    try {
      const data = {
        users: users.value,
        lastUpdate: lastUpdate.value,
        timestamp: Date.now()
      }
      localStorage.setItem('online_users_cache', JSON.stringify(data))
    } catch (e) {
      console.error('Error saving online users to localStorage:', e)
    }
  }

  function loadFromLocalStorage() {
    try {
      const cached = localStorage.getItem('online_users_cache')
      if (cached) {
        const data = JSON.parse(cached)
        if (Date.now() - data.timestamp < 60000) {
          users.value = data.users
          lastUpdate.value = data.lastUpdate
        } else {
          localStorage.removeItem('online_users_cache')
        }
      }
    } catch (e) {
      console.error('Error loading online users from localStorage:', e)
    }
  }

  return {
    users,
    lastUpdate,
    typingUsers,
    onlineCount,
    providersOnline,
    clientsOnline,
    adminsOnline,
    onlineByRole,
    onlineUserIds,
    stats,
    setOnlineUsers,
    addOnlineUser,
    removeOnlineUser,
    mergeOnlineUsers,
    updateUserLastSeen,
    isUserOnline,
    getUserById,
    getUserStatus,
    getOnlineUsersByRole,
    setUserTyping,
    handleTypingEvent,
    isUserTyping,
    getUsersTyping,
    getTypingNames,
    getTypingText,
    clearAll,
    clearTyping,
    saveToLocalStorage,
    loadFromLocalStorage
  }
})
