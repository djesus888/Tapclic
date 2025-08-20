import { io } from 'socket.io-client'
import { useNotificationStore } from '@/stores/notificationStore'

export let socket = null

export function connectSocket(token) {
  if (!token) return

  // Evitar múltiples conexiones
  if (!socket) {
    const notificationStore = useNotificationStore()

    socket = io('http://localhost:3001', {
  auth: {
    token // token JWT del usuario
  }
})


    // Evento: conexión exitosa
    socket.on('connect', () => {
      console.log('✅ Conectado al socket:', socket.id)
    })

    // Evento: recibir notificación
    socket.on('notification', (data) => {
      console.log('🔔 Notificación recibida:', data)
      notificationStore.addNotification(data) // <-- Aquí se guarda
    })

    // Evento: desconexión
    socket.on('disconnect', () => {
      console.log('❌ Desconectado del socket')
    })

    // Evento: error de conexión
    socket.on('connect_error', (err) => {
      console.error('🚨 Error de conexión al socket:', err.message)
    })
  }
}

export function getSocketInstance() {
  return socket
}
