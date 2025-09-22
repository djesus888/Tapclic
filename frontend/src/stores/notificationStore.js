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
        const { data } = await api.get('/notifications/mine')
        this.notifications = data
        this.unreadCount = data.filter(n => !n.is_read).length
      } catch (error) {
        console.error('❌ Error al obtener notificaciones desde la base de datos:', error)
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
    }
  }
})
