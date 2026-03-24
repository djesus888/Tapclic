// src/stores/notificationStore.js
import { defineStore } from 'pinia';
import api from '@/axios';
import { useAuthStore } from './authStore';
import { useSocketStore } from './socketStore';  // ✅ CORREGIDO: una sola llave

export const useNotificationStore = defineStore('notification', {
  state: () => ({
    notifications: [],
    _initialized: false,
    // Cache de notificaciones leídas
    _readCache: new Set(),
    // Tipos de notificaciones que requieren sonido
    _soundEnabledTypes: ['new_message', 'request_updated', 'payment_received']
  }),

  actions: {
    async initialize() {
      if (this._initialized) return;

      await this.loadNotificationsFromAPI();
      this._initialized = true;

      const socketStore = useSocketStore();
      socketStore.init();

      // Escuchar notificaciones del sistema
      socketStore.on('new-notification', (notification) => {
        console.log('📬 Notificación recibida:', notification);
        
        // Verificar si es una notificación de mensaje
        if (notification.data_json) {
          try {
            const data = JSON.parse(notification.data_json);
            if (data.notification_type === 'new_message') {
              // Es una notificación de mensaje - no reproducir sonido (ya lo hace el chat)
              this.addNotification(notification, false);
              return;
            }
          } catch (e) {
            // No es JSON, continuar normal
          }
        }
        
        // Notificación normal del sistema
        this.addNotification(notification);
      });

      // Escuchar específicamente mensajes nuevos
      socketStore.on('new_message', (data) => {
        // Crear notificación de mensaje si no viene del sistema de notificaciones
        if (data.message && !data.notification) {
          const messageNotification = {
            id: `msg_${data.message.id}`,
            type: 'new_message',
            title: 'Nuevo mensaje',
            message: data.message.text || 'Has recibido un mensaje',
            data: {
              conversation_id: data.conversation_id,
              message_id: data.message.id,
              url: `/chat/${data.conversation_id}`
            },
            created_at: new Date().toISOString(),
            is_read: false
          };
          this.addNotification(messageNotification, false); // false = no reproducir sonido
        }
      });

      window.addEventListener('request-updated', () => this._invalidateCache());
      window.addEventListener('payment-updated', () => this._invalidateCache());
      window.addEventListener('message-received', () => this._invalidateCache());
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
        
        // Actualizar cache de leídas
        list.forEach(n => {
          if (n.is_read) this._readCache.add(n.id);
        });
        
      } catch (err) {
        console.error('Error loading notifications:', err);
      }
    },

    addNotification(notification, playSound = true) {
      // Verificar si ya existe
      const exists = this.notifications.find((n) => n.id === notification.id);
      if (!exists) {
        this.notifications.unshift(notification);
        
        // Limitar número de notificaciones en memoria
        if (this.notifications.length > 100) {
          this.notifications = this.notifications.slice(0, 100);
        }
        
        // Reproducir sonido si está permitido
        if (playSound && this._shouldPlaySound(notification)) {
          this.playSound();
        }
      }
    },

    _shouldPlaySound(notification) {
      return this._soundEnabledTypes.includes(notification.type);
    },

    markAsRead(id) {
      const idx = this.notifications.findIndex((n) => n.id === id);
      if (idx !== -1) {
        this.notifications[idx].is_read = true;
        this._readCache.add(id);
        
        // Notificar al servidor
        this._notifyServerRead(id);
      }
    },

    markAsReadLocally(id) {
      const idx = this.notifications.findIndex((n) => n.id === id);
      if (idx !== -1) {
        this.notifications[idx].is_read = true;
        this._readCache.add(id);
      }
    },

    async _notifyServerRead(id) {
      try {
        const authStore = useAuthStore();
        await api.post('/notifications/read', { notification_id: id }, {
          headers: { Authorization: `Bearer ${authStore.token}` }
        });
      } catch (err) {
        console.error('Error marking notification as read on server:', err);
      }
    },

    markAllAsRead() {
      const unreadIds = this.notifications
        .filter(n => !n.is_read)
        .map(n => n.id);
        
      this.notifications = this.notifications.map((n) => ({ ...n, is_read: true }));
      unreadIds.forEach(id => this._readCache.add(id));
      
      // Notificar al servidor
      unreadIds.forEach(id => this._notifyServerRead(id));
    },

    removeNotification(id) {
      this.notifications = this.notifications.filter((n) => n.id !== id);
      this._readCache.delete(id);
    },

    getUnreadNotifications() {
      return this.notifications.filter(n => !n.is_read);
    },

    getNotificationsByType(type) {
      return this.notifications.filter(n => n.type === type);
    },

    clearOldNotifications(days = 7) {
      const cutoff = new Date();
      cutoff.setDate(cutoff.getDate() - days);
      
      this.notifications = this.notifications.filter(n => 
        new Date(n.created_at) > cutoff || !n.is_read
      );
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

    setSoundEnabledTypes(types) {
      this._soundEnabledTypes = types;
    },

    toggleSoundForType(type, enabled) {
      if (enabled && !this._soundEnabledTypes.includes(type)) {
        this._soundEnabledTypes.push(type);
      } else if (!enabled) {
        this._soundEnabledTypes = this._soundEnabledTypes.filter(t => t !== type);
      }
    }
  },

  getters: {
    unreadCount: (state) => state.notifications.filter((n) => !n.is_read).length,
    
    unreadMessagesCount: (state) => state.notifications
      .filter(n => n.type === 'new_message' && !n.is_read).length,
      
    recentNotifications: (state) => (limit = 10) => 
      [...state.notifications]
        .sort((a, b) => new Date(b.created_at) - new Date(a.created_at))
        .slice(0, limit),
        
    notificationsByDate: (state) => {
      const grouped = {};
      state.notifications.forEach(n => {
        const date = new Date(n.created_at).toLocaleDateString();
        if (!grouped[date]) grouped[date] = [];
        grouped[date].push(n);
      });
      return grouped;
    },
    
    hasUnreadByType: (state) => (type) => 
      state.notifications.some(n => n.type === type && !n.is_read),
  },
});
