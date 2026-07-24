// src/stores/notificationStore.js
import { defineStore } from 'pinia';
import api from '@/axios';
import { useAuthStore } from './authStore';
import { useSocketStore } from './socketStore';

export const useNotificationStore = defineStore('notification', {
  state: () => ({
    notifications: [],
    _initialized: false,
    _readCache: new Set(),
    _soundEnabledTypes: ['new_message', 'request_updated', 'payment_received'],
    _pollingInterval: null,
    // ✅ NUEVO: Referencia a la función cleanup del listener
    _notificationListenerCleanup: null
  }),

  actions: {
    async initialize() {
      if (this._initialized) return;

      await this.loadNotificationsFromAPI();
      this._initialized = true;

      const socketStore = useSocketStore();
      socketStore.init();

      // ============================================================
      // ✅ CORREGIDO: Limpiar listener anterior antes de registrar
      // uno nuevo para evitar acumulación en reconexiones
      // ============================================================
      if (this._notificationListenerCleanup) {
        this._notificationListenerCleanup();
      }

      // Registrar listener y guardar función de limpieza
      this._notificationListenerCleanup = socketStore.on('new-notification', (notification) => {
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

      // ✅ NUEVO: Iniciar polling de respaldo
      this._startPolling();
    },

    _startPolling() {
      if (this._pollingInterval) clearInterval(this._pollingInterval);

      this._pollingInterval = setInterval(async () => {
        try {
          const socketStore = useSocketStore();
          if (!socketStore.isConnected) {
            await this.loadNotificationsFromAPI();
          }
        } catch (err) {
          // Silencioso, solo respaldo
        }
      }, 30000);
    },

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

        const existingIds = new Set(this.notifications.map(n => n.id));
        const newNotifications = list.filter(n => !existingIds.has(n.id));

        if (newNotifications.length > 0) {
          this.notifications = [...newNotifications, ...this.notifications];
        }

        list.forEach(n => {
          if (n.is_read) this._readCache.add(n.id);
        });

      } catch (err) {
        console.error('Error loading notifications:', err);
      }
    },

    addNotification(notification, playSound = true) {
      // ✅ CORREGIDO: Convertir ID a string (el frontend espera string)
      if (notification.id !== undefined && notification.id !== null) {
        notification.id = String(notification.id);
      }

      // ✅ CORREGIDO: Si no tiene ID, generar uno único
      if (!notification.id) {
        notification.id = `notif_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
      }

      // ✅ CORREGIDO: Agregar created_at si no viene pero hay timestamp
      if (!notification.created_at && notification.timestamp) {
        notification.created_at = new Date(notification.timestamp * 1000).toISOString();
      }

      // ✅ CORREGIDO: Verificar duplicados SOLO por ID (más simple y efectivo)
      const exists = this.notifications.some((n) => String(n.id) === String(notification.id));

      if (exists) {
        console.log('🔇 Notificación duplicada por ID, omitiendo:', notification.id);
        return;
      }

      // ✅ Agregar la notificación al inicio de la lista
      this.notifications.unshift(notification);

      // Limitar número de notificaciones en memoria
      if (this.notifications.length > 100) {
        this.notifications = this.notifications.slice(0, 100);
      }

      // Reproducir sonido si está permitido
      if (playSound && this._shouldPlaySound(notification)) {
        this.playSound();
      }

      console.log('✅ Notificación agregada:', notification.id, notification.title);
    },

    _shouldPlaySound(notification) {
      return this._soundEnabledTypes.includes(notification.type);
    },

    async markAsRead(id) {
      // ✅ CORREGIDO: Convertir id a string para comparación consistente
      const strId = String(id);
      const idx = this.notifications.findIndex((n) => String(n.id) === strId);
      if (idx !== -1) {
        this.notifications[idx].is_read = true;
        this._readCache.add(strId);
      }
      try {
        await api.post('/notifications/read', { id: strId }, {
          headers: { Authorization: `Bearer ${useAuthStore().token}` }
        });
      } catch (e) {
        console.error('Error marcando notificación como leída:', e);
      }
    },

    markAsReadLocally(id) {
      const strId = String(id);
      const idx = this.notifications.findIndex((n) => String(n.id) === strId);
      if (idx !== -1) {
        this.notifications[idx].is_read = true;
        this._readCache.add(strId);
      }
    },

    markAllAsRead() {
      const len = this.notifications.length;
      for (let i = 0; i < len; i++) {
        this.notifications[i].is_read = true;
        this._readCache.add(this.notifications[i].id);
      }
    },

    removeNotification(id) {
      const strId = String(id);
      this.notifications = this.notifications.filter((n) => String(n.id) !== strId);
      this._readCache.delete(strId);
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

    // ✅ Limpiar al destruir
    cleanup() {
      this._stopPolling();
      // Limpiar listener de socket
      if (this._notificationListenerCleanup) {
        this._notificationListenerCleanup();
        this._notificationListenerCleanup = null;
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
