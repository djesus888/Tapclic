import { defineStore } from 'pinia'

export const useNotificationCacheStore = defineStore('notificationCache', {
  id: 'notificationCache',

  state: () => ({
    notifications: []
  }),

  getters: {
    unreadCount: (state) => state.notifications.filter(n => !n.is_read).length
  },

  actions: {
    setNotifications(list) {
      // Deduplicar por ID
      const unique = list.filter(
        (n, i, arr) => arr.findIndex(x => x.id === n.id) === i
      )
      this.notifications = unique
    },

    add(notification) {
      const exists = this.notifications.find(n => n.id === notification.id)
      if (!exists) this.notifications.unshift(notification)
    },

    markAsRead(id) {
      const n = this.notifications.find(n => n.id === id)
      if (n) n.is_read = true
    },

    clear() {
      this.notifications = []
    }
  },

  persist: {
    key: 'notifications',
    storage: localStorage
  }
})
