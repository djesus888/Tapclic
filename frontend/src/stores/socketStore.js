// src/stores/socketStore.js
import { defineStore } from 'pinia';
import { io } from 'socket.io-client';
import { useAuthStore } from './authStore';
import { watch } from 'vue';

export const useSocketStore = defineStore('socket', {
  state: () => ({
    socket: null,
    notifications: [],
    notificationSound: null,
  }),

  actions: {
    /* ------------------------------------------------------------------ */
    /*  1. Observa el token: conecta la 1ª vez o actualiza sin cerrar     */
    /* ------------------------------------------------------------------ */
    init() {
      const authStore = useAuthStore();

      watch(
        () => authStore.token,
        async (newToken, oldToken) => {
          if (!newToken) {                                    // logout
            console.log('❌ Token borrado; desconectando WS…');
            this.disconnect();
            return;
          }

          // Primera conexión o reconexión manual
          if (!this.socket?.connected) {
            console.log('🔄 Token detectado; arrancando WS…');
            this.connect(newToken, authStore.user);
            return;
          }

          // Token renovado → solo actualizamos
          console.log('🔄 Token renovado; actualizando sin cerrar…');
          this.socket.auth.token = newToken;        // socket.io v4
          this.socket.emit('refresh-token', newToken); // si tu back lo usa
        },
        { immediate: true }
      );
    },

    /* ------------------------------------------------------------------ */
    /*  2. Crear socket (solo si no hay uno previo)                       */
    /* ------------------------------------------------------------------ */
    connect(token, user) {
      if (!token || this.socket?.connected) return;

      console.log('📡 Creando WebSocket');
      if (!this.notificationSound) {
        this.notificationSound = new Audio('/sounds/notification.mp3');
      }

      this.socket = io(import.meta.env.VITE_WS_URL || 'http://localhost:3001', {
        transports: ['websocket'],
        reconnection: true,
        auth: { token },
        query: { token }
      });

      this.setupSocketListeners(user);
    },

    /* ------------------------------------------------------------------ */
    /*  3. Listeners                                                      */
    /* ------------------------------------------------------------------ */
    setupSocketListeners(user) {
      const room = user ? `${user.role}_${user.id}` : null;

      this.socket
        .on('connect', () => {
          if (!this.socket.id) return;          // ← evita "indefinido"
          console.log('✅ Conectado a WebSocket:', this.socket.id);
          if (room) {
            this.socket.emit('join-room', room);
            console.log('📌 Sala unida:', room);
          }
        })
        .on('disconnect', reason => {
          console.log('🔌 Desconectado del WS:', reason);
        })
        .on('connect_error', err => {
          console.error('❌ Error de conexión:', err.message);
        })
        .on('new-notification', payload => {
          console.log('📣 Notificación recibida:', payload);
          this.notifications.unshift(payload);
          this.playNotificationSound();
        });
    },

    /* ------------------------------------------------------------------ */
    /*  4. Helpers                                                        */
    /* ------------------------------------------------------------------ */
    emit(event, payload) { this.socket?.emit(event, payload); },
    on(event, handler)   { this.socket?.on(event, handler); },
    off(event, handler)  { this.socket?.off(event, handler); },

    markAsRead(id) {
      const idx = this.notifications.findIndex(n => n.id === id);
      if (idx !== -1) this.notifications[idx].is_read = 1;
    },
    clearNotifications() { this.notifications = []; },

    playNotificationSound() {
      if (!this.notificationSound) return;
      this.notificationSound.currentTime = 0;
      this.notificationSound.play().catch(() => {});
    },

    /* ------------------------------------------------------------------ */
    /*  5. Desconexión limpia (solo cuando se hace logout)               */
    /* ------------------------------------------------------------------ */
    disconnect() {
      if (!this.socket) return;
      console.log('🔌 Cerrando conexión manualmente');
      this.socket.disconnect();
      this.socket = null;
    }
  },

  getters: {
    unreadCount: state => state.notifications.filter(n => !n.is_read).length
  }
});
