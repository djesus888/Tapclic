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
    _soundEnabledTypes: ['new_message', 'request_updated', 'payment_received'],
    // ✅ NUEVO: Evitar duplicados por procesamiento simultáneo
    _processingIds: new Set(),
    // ✅ NUEVO: Polling de respaldo
    _pollingInterval: null
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

      // ✅ NUEVO: Iniciar polling de respaldo
      this._startPolling();
    },

    // ✅ NUEVO: Polling de respaldo para cuando WebSocket falla
    _startPolling() {
      if (this._pollingInterval) clearInterval(this._pollingInterval);

      this._pollingInterval = setInterval(async () => {
        try {
          const socketStore = useSocketStore();
          // Solo hacer polling si el socket no está conectado
          if (!socketStore.isConnected) {
            await this.loadNotificationsFromAPI();
          }
        } catch (err) {
          // Silencioso, solo respaldo
        }
      }, 30000); // Cada 30 segundos
    },

    // ✅ NUEVO: Detener polling
    _stopPolling() {
      if (this._pollingInterval) {
        clearInterval(this._pollingInterval);
        this._pollingInterval = null;
      }
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

        // ✅ CORREGIDO: Merge inteligente para no perder notificaciones locales
        const existingIds = new Set(this.notifications.map(n => n.id));
        const newNotifications = list.filter(n => !existingIds.has(n.id));

        if (newNotifications.length > 0) {
          this.notifications = [...newNotifications, ...this.notifications];
        }

        // Actualizar cache de leídas
        list.forEach(n => {
          if (n.is_read) this._readCache.add(n.id);
        });

      } catch (err) {
        console.error('Error loading notifications:', err);
      }
    },

    addNotification(notification, playSound = true) {
      // ✅ NUEVO: Evitar procesar la misma notificación dos veces simultáneamente
      const dedupeKey = notification.id ||
        `${notification.title}_${notification.message}_${notification.created_at || notification.timestamp}`;

      if (this._processingIds.has(dedupeKey)) {
        console.log('🔄 Notificación ya en procesamiento, omitiendo:', dedupeKey);
        return;
      }

      this._processingIds.add(dedupeKey);

      // Limpiar la clave después de un tiempo
      setTimeout(() => {
        this._processingIds.delete(dedupeKey);
      }, 5000);

      // ✅ CORREGIDO: Verificar duplicados por id, título y timestamp
      const exists = this.notifications.find((n) => {
        // Si tiene id, comparar por id
        if (notification.id && n.id === notification.id) return true;
        // Si no, comparar por título + mensaje + timestamp cercano
        if (notification.title === n.title &&
            notification.message === n.message &&
            Math.abs((notification.timestamp || 0) - (n.timestamp || 0)) < 2000) {
          return true;
        }
        return false;
      });

      if (!exists) {
        // Asegurar que tenga un id único
        if (!notification.id) {
          notification.id = `notif_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
        }
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
      }
    },

    markAsReadLocally(id) {
      const idx = this.notifications.findIndex((n) => n.id === id);
      if (idx !== -1) {
        this.notifications[idx].is_read = true;
        this._readCache.add(id);
      }
    },

    // ✅ CORREGIDO: Mutar cada elemento en lugar de reemplazar el array
    // Esto evita el error "insertBefore" en Vue al no romper la referencia del array
    markAllAsRead() {
      for (let i = 0; i < this.notifications.length; i++) {
        if (!this.notifications[i].is_read) {
          this.notifications[i].is_read = true;
        }
        this._readCache.add(this.notifications[i].id);
      }
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
    },

    // ✅ NUEVO: Limpiar al destruir
    cleanup() {
      this._stopPolling();
      this._processingIds.clear();
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
