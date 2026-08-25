// src/stores/notificationStore.js
import { defineStore } from 'pinia';
import api from '@/axios';
import { useAuthStore } from './authStore';
import { useSocketStore } from './socketStore';
import Swal from 'sweetalert2';

export const useNotificationStore = defineStore('notification', {
  state: () => ({
    notifications: [],
    _initialized: false,
    _readCache: new Set(),
    _soundEnabledTypes: ['new_message', 'request_updated', 'payment_received'],
    _pollingInterval: null,
    _notificationListenerCleanup: null,
    _sessionClosedListenerCleanup: null,
    _duplicateConnectionCleanup: null, // 🔥 NUEVO: Para manejar duplicate_connection
    _sessionClosedAlertShown: false, // 🔥 NUEVO: Evitar alertas duplicadas
  }),

  actions: {
    async initialize() {
      if (this._initialized) return;

      const socketStore = useSocketStore();

      // ============================================================
      // Limpiar listener anterior antes de registrar uno nuevo
      // ============================================================
      if (this._notificationListenerCleanup) {
        this._notificationListenerCleanup();
      }

      // Registrar listener de notificaciones
      this._notificationListenerCleanup = socketStore.on('new-notification', (notification) => {
        console.log('📬 Notificación recibida:', notification);

        // Verificar si es una notificación de mensaje
        if (notification.data_json) {
          try {
            const data = JSON.parse(notification.data_json);
            if (data.notification_type === 'new_message') {
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

      // ============================================================
      // Escuchar cierre de sesión remoto (session_closed)
      // ============================================================
      if (this._sessionClosedListenerCleanup) {
        this._sessionClosedListenerCleanup();
      }

      this._sessionClosedListenerCleanup = socketStore.on('session_closed', (data) => {
        console.warn('🔒 Evento session_closed recibido:', data);
        this._handleSessionClosed(data);
      });

      // 🔥 NUEVO: Escuchar evento duplicate_connection del WebSocket
      // ============================================================
      if (this._duplicateConnectionCleanup) {
        this._duplicateConnectionCleanup();
      }

      this._duplicateConnectionCleanup = socketStore.on('duplicate_connection', (data) => {
        console.warn('🔒 Evento duplicate_connection recibido del servidor WebSocket:', data);
        
        // Mostrar la misma alerta que session_closed
        this._handleSessionClosed({
          message: data?.message || 'Tu cuenta ha sido abierta en otro dispositivo. Esta sesión ha sido cerrada por seguridad.',
          timestamp: new Date().toISOString(),
          device_id: data?.newSocketId || null,
        });
      });

      // Cargar notificaciones en segundo plano (sin bloquear)
      this.loadNotificationsFromAPI().catch(() => {});
      this._initialized = true;

      // Iniciar polling de respaldo
      this._startPolling();
    },

    // 🔥 NUEVO: Método centralizado para manejar cierre de sesión
    _handleSessionClosed(data) {
      console.warn('🔒 Sesión cerrada remotamente:', data);

      const authStore = useAuthStore();
      const myDeviceId = localStorage.getItem('device_id');

      // ⭐ CORRECCIÓN PRINCIPAL: Verificar device_id
      if (data?.device_id && myDeviceId) {
        // Si mi device_id coincide con el device_id del evento, CERRAR SESIÓN
        if (String(data.device_id) === String(myDeviceId)) {
          console.log('✅ Este es mi dispositivo, cerrando sesión');
          this._showSessionClosedAlert(data);
          return;
        }
        
        // Si mi device_id coincide con new_device_id, soy el NUEVO, ignorar
        if (data?.new_device_id && String(data.new_device_id) === String(myDeviceId)) {
          console.log('✅ Soy el dispositivo nuevo, ignorando session_closed');
          return;
        }
        
        // Si no coincide con ninguno, ignorar
        console.log('✅ device_id no coincide, ignorando. Mi device:', myDeviceId, '| Event device:', data.device_id);
        return;
      }

      // Fallback por timestamp (si no hay device_id disponible)
      if (authStore.token) {
        try {
          const payload = JSON.parse(atob(authStore.token.split('.')[1]));
          if (payload.iat && data?.timestamp) {
            const tokenTime = new Date(payload.iat * 1000).getTime();
            const closeTime = new Date(data.timestamp).getTime();
            if (tokenTime > closeTime) {
              console.log('✅ Este es el dispositivo nuevo (por timestamp), ignorando session_closed');
              return;
            }
          }
        } catch (e) {
          // Si no se puede decodificar, continuar con el cierre
        }
      }

      // Si no hay device_id ni timestamp, mostrar alerta por defecto
      this._showSessionClosedAlert(data);
    },

    // 🔥 NUEVO: Método para mostrar la alerta de sesión cerrada
    _showSessionClosedAlert(data) {
      // Verificar si ya se mostró una alerta de sesión cerrada
      if (this._sessionClosedAlertShown) {
        console.log('⚠️ Alerta de sesión cerrada ya mostrada, omitiendo');
        return;
      }

      this._sessionClosedAlertShown = true;

      // Mostrar notificación
      Swal.fire({
        icon: 'warning',
        title: '🔒 Sesión cerrada',
        text: data?.message || 'Tu cuenta ha sido abierta en otro dispositivo. Esta sesión ha sido cerrada por seguridad.',
        confirmButtonText: 'Entendido',
        confirmButtonColor: '#667eea',
        allowOutsideClick: false,
        allowEscapeKey: false,
      }).then(() => {
        // Resetear flag
        this._sessionClosedAlertShown = false;

        // Cerrar sesión local
        useAuthStore().logout();
        // Usar window.location en lugar de router
        window.location.href = '/login';
      });
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
      if (notification.id !== undefined && notification.id !== null) {
        notification.id = String(notification.id);
      }

      if (!notification.id) {
        notification.id = `notif_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
      }

      if (!notification.created_at && notification.timestamp) {
        notification.created_at = new Date(notification.timestamp * 1000).toISOString();
      }

      const exists = this.notifications.some((n) => String(n.id) === String(notification.id));

      if (exists) {
        console.log('🔇 Notificación duplicada por ID, omitiendo:', notification.id);
        return;
      }

      this.notifications.unshift(notification);

      if (this.notifications.length > 100) {
        this.notifications = this.notifications.slice(0, 100);
      }

      if (playSound && this._shouldPlaySound(notification)) {
        this.playSound();
      }

      console.log('✅ Notificación agregada:', notification.id, notification.title);
    },

    _shouldPlaySound(notification) {
      return this._soundEnabledTypes.includes(notification.type);
    },

    async markAsRead(id) {
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

    // Limpiar al destruir
    cleanup() {
      this._stopPolling();
      if (this._notificationListenerCleanup) {
        this._notificationListenerCleanup();
        this._notificationListenerCleanup = null;
      }
      if (this._sessionClosedListenerCleanup) {
        this._sessionClosedListenerCleanup();
        this._sessionClosedListenerCleanup = null;
      }
      // 🔥 NUEVO: Limpiar listener de duplicate_connection
      if (this._duplicateConnectionCleanup) {
        this._duplicateConnectionCleanup();
        this._duplicateConnectionCleanup = null;
      }
      // 🔥 NUEVO: Resetear flag de alerta
      this._sessionClosedAlertShown = false;
    },
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
