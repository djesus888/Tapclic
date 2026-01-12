// src/stores/notificationStore.js
import { defineStore } from 'pinia';
import api from '@/axios';
import { useAuthStore } from './authStore';
import { useSocketStore } from './socketStore';

export const useNotificationStore = defineStore('notification', {
  state: () => ({
    notifications: [],
    _initialized: false,
  }),

  actions: {
    async initialize() {
      if (this._initialized) return;

      await this.loadNotificationsFromAPI();
      this._initialized = true;

      const socketStore = useSocketStore();
      socketStore.init();

      // Suscribirse a notificaciones en tiempo real
      socketStore.on('new-notification', (notification) => {
        this.addNotification(notification);
      });

      window.addEventListener('request-updated', () => this._invalidateCache());
      window.addEventListener('payment-updated', () => this._invalidateCache());
    },

    async loadNotificationsFromAPI() {
      try {
        const authStore = useAuthStore();
        const response = await api.get('/notifications/mine', {
          headers: { Authorization: `Bearer ${authStore.token}` },
        });

        const list = Array.isArray(response.data)
          ? response.data
          : Array.isArray(response.data?.data)
          ? response.data.data
          : response.data?.notifications || [];

        this.notifications = list;
      } catch (err) {
        console.error('Error loading notifications:', err);
      }
    },

    addNotification(notification) {
      const exists = this.notifications.find((n) => n.id === notification.id);
      if (!exists) {
        this.notifications.unshift(notification);
        this.playSound();
      }
    },

    markAsRead(id) {
      const idx = this.notifications.findIndex((n) => n.id === id);
      if (idx !== -1) {
        this.notifications[idx].is_read = true;
      }
    },

    markAllAsRead() {
      this.notifications = this.notifications.map((n) => ({ ...n, is_read: true }));
    },

    removeNotification(id) {
      this.notifications = this.notifications.filter((n) => n.id !== id);
    },

    _invalidateCache() {
      this._initialized = false;
      console.log('🔄 Cache de notificaciones invalidado');
      this.initialize(); // refresca inmediatamente
    },

    async playSound() {
      try {
        const audio = new Audio('/sounds/notification.mp3');
        audio.volume = 0.6;
        await audio.play();
      } catch (_) {}
    },
  },

  getters: {
    unreadCount: (state) => state.notifications.filter((n) => !n.is_read).length,
  },
});

