// src/stores/socketStore.js
import { defineStore } from 'pinia';
import { io } from 'socket.io-client';
import { useAuthStore } from './authStore';
import { useNotificationStore } from './notificationStore';
import { watch } from 'vue';

export const useSocketStore = defineStore('socket', {
  state: () => ({
    socket: null,
    notificationSound: null,
    _creating: null,
    _soundEnabled: false,
    _listeners: new Map(),
  }),

  actions: {
    /* ----------------------------------------------------------
       Inicializa watcher sobre token → conecta/desconecta
       ---------------------------------------------------------- */
    init() {
      const authStore = useAuthStore();
      const notificationStore = useNotificationStore();

      watch(
        () => authStore.token,
        async (newToken) => {
          console.log('watcher disparado:', { newToken });
          if (!newToken) {
            console.log('❌ Token borrado; desconectando WS…');
            this.disconnect();
            return;
          }
          if (!this.socket?.connected) {
            console.log('🔄 Token detectado; arrancando WS…');
            try { await this.connect(newToken, authStore.user); }
            catch (e) { console.error('❌ Falló conexión WS:', e.message); }
            return;
          }
          console.log('🔄 Token renovado; actualizando sin cerrar…');
          this.socket.auth.token = newToken;
          this.socket.emit('refresh-token', newToken, (res) => {
            if (res?.error) {
              console.error('❌ Refresh token rechazado:', res.error);
              this.disconnect();
            } else {
              console.log('✅ Token actualizado en servidor');
            }
          });
        }
      );
    },

    /* ----------------------------------------------------------
       Conexión única y protegida
       ---------------------------------------------------------- */
    connect(token, user) {
      if (this.socket?.connected) return Promise.resolve(this.socket);
      if (this._creating) return this._creating;

      console.log('📡 Creando WebSocket');
      if (!this.notificationSound) {
        this.notificationSound = new Audio('/sounds/notification.mp3');
        this.notificationSound.volume = 0.6;
        this.notificationSound.addEventListener('error', () => {
          console.warn('🔇 No se pudo cargar el sonido de notificación');
          this._soundEnabled = false;
        });
      }

      const room = user ? `${user.role}_${user.id}` : null;
      const socket = io(import.meta.env.VITE_WS_URL || 'http://localhost:3001', {
        transports: ['websocket'],
        reconnection: true,
        auth: { token },
        query: { token }
      });

      this._creating = new Promise((resolve, reject) => {
        socket
          .on('connect', () => {
            console.log('✅ Conectado a WebSocket:', socket.id);
            if (room) {
              socket.emit('join-room', room);
              console.log('📌 Sala unida:', room);
            }
            this.socket = socket;

            // 🔥 SUSCRIPCIONES DENTRO DE connect
            this._subscribeEvents();
            resolve(socket);
          })
          .on('connect_error', err => {
            console.error('❌ Error de conexión:', err.message);
            reject(err);
          })
          .on('disconnect', reason => {
            console.log('🔌 Desconectado del WS:', reason);
          })
          .on('auth_error', msg => {
            socket.disconnect();
            reject(new Error(msg.message || 'Auth failed'));
          });
      }).finally(() => { this._creating = null; });

      return this._creating;
    },

    /* ----------------------------------------------------------
       SUSCRIPCIONES (siempre después de connect)
       ---------------------------------------------------------- */
    _subscribeEvents() {
      const notificationStore = useNotificationStore();

      // 1. Notificaciones en tiempo real
      this.on('new-notification', (payload) => {
        console.log('📣 Notificación recibida:', payload);
        if (payload && typeof payload === 'object') {
          notificationStore.list.unshift({
            id: payload.id || Date.now(),
            is_read: payload.is_read ?? 0,
            ...payload
          });
          this.playNotificationSound();
        }
      });

      // 2. Mensajes de chat (si usas)
      this.on('new-message', (payload) => {
        // tu lógica de chat
      });

      // 3. Actualización de solicitudes (user/provider)
      this.on('request_updated', (payload) => {
        console.log('📦 request_updated:', payload);
        // Aquí puedes emitir un evento global o actualizar tienda correspondiente
      });
    },

    /* ----------------------------------------------------------
       Helpers
       ---------------------------------------------------------- */
    on(event, handler) { this.socket?.on(event, handler); },
    off(event, handler) { this.socket?.off(event, handler); },
    emit(event, payload) { this.socket?.emit(event, payload); },

    markAsRead(id) {
      const notificationStore = useNotificationStore();
      const idx = notificationStore.notifications.findIndex(n => n.id === id);
      if (idx !== -1) notificationStore.notifications[idx].is_read = 1;
    },

    clearNotifications() {
      const notificationStore = useNotificationStore();
      notificationStore.notifications = [];
    },

    async playNotificationSound() {
      if (!this.notificationSound) return;
      try {
        this.notificationSound.currentTime = 0;
        await this.notificationSound.play();
        this._soundEnabled = true;
      } catch (err) {
        console.warn('🔇 Autoplay bloqueado:', err.message);
        this._soundEnabled = false;
      }
    },

    disconnect() {
      if (!this.socket) return;
      console.log('🔌 Cerrando conexión manualmente');
      this.socket.offAny?.();
      this._listeners.forEach((h, ev) => this.socket.off(ev, h));
      this._listeners.clear();
      this.socket.disconnect();
      this.socket = null;
    }
  },
getters: {
  notifications: (state) => {
    const store = useNotificationStore();
    return store.notifications; // ✅ notifications SÍ existe
  },
  unreadCount: (state) => {
    const store = useNotificationStore();
    return store.notifications.filter(n => !n.is_read).length; 
  }
}
});
