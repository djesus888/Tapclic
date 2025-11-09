// stores/notificationStore.js
import { defineStore } from 'pinia'
import api from '@/axios' // Importamos el axios ya configurado

export const useNotificationStore = defineStore('notification', {
  state: () => ({
    notifications: [],
    unreadCount: 0
  }),

  actions: {
    async fetchNotificationsFromDB() {
  try {
    const res = await api.get('/notifications/mine')
    // extrae el array que viene dentro de res.data.data o res.data
    const list = Array.isArray(res.data)
      ? res.data
      : Array.isArray(res.data?.data)
      ? res.data.data
      : res.data?.notifications || []

    this.notifications = list
    this.unreadCount  = list.filter(n => !n.is_read).length
  } catch (error) {
    console.error('❌ Error al obtener notificaciones:', error)
    this.notifications = []
    this.unreadCount  = 0
  }
},
  async markAllAsRead() {
      try {
        await api.post('/notifications/mark-all-read')
        this.notifications = this.notifications.map(n => ({ ...n, is_read: true }))
        this.unreadCount = 0
      } catch (error) {
        console.error('❌ Error al marcar todas las notificaciones como leídas:', error)
      }
    },

    async markAsRead(notificationId) {
         const notification = this.notifications.find(n => n.id === notificationId)
       if (notification && !notification.is_read) {
       try {
      await api.post(`/notifications/read`, { id: notificationId })
      notification.is_read = true
      this.unreadCount = this.notifications.filter(n => !n.is_read).length
    } catch (error) {
      console.error('❌ Error al marcar la notificación como leída:', error.response?.data || error.message)
    }
  }
},

    handleIncomingNotification(notification) {
      this.notifications.unshift(notification)
      if (!notification.is_read) {
        this.unreadCount++
      }
    },
    handleIncomingNotification(notification) {
      this.notifications.unshift(notification)
      if (!notification.is_read) {
        this.unreadCount++
      }
    },

    /* ↓↓↓ NUEVOS ↓↓↓ */
    prependNotification(payload) {
      this.notifications.unshift(payload)
      this.unreadCount = this.notifications.filter(n => !n.is_read).length
      this.playNotificationSound?.()
    },

    playNotificationSound() {
      const audio = new Audio('/sounds/notification.mp3')
      audio.volume = 0.6
      audio.play().catch(() => {})
    }
  }
})
