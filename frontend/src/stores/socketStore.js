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

      watch(
        () => authStore.token,
        async (newToken) => {
          if (!newToken) {
            this.disconnect();
            return;
          }

          if (!this.socket?.connected) {
            await this.connect(newToken, authStore.user);
            return;
          }

          // actualizar token sin desconectar
          this.socket.auth.token = newToken;
          this.socket.emit('refresh-token', newToken);
        }
      );
    },

    /* ----------------------------------------------------------
      Conexión
    ---------------------------------------------------------- */
    connect(token, user) {
      if (this.socket?.connected) return Promise.resolve(this.socket);
      if (this._creating) return this._creating;

      if (!this.notificationSound) {
        this.notificationSound = new Audio('/sounds/notification.mp3');
        this.notificationSound.volume = 0.6;
      }

      const room = user ? `${user.role}_${user.id}` : null;

console.log('>>>> INTENTANDO CONECTAR a', import.meta.env.VITE_WS_URL || 'http://localhost:3001');

      const socket = io(import.meta.env.VITE_WS_URL || 'http://localhost:3001', {
        transports: ['websocket'],
        reconnection: true,
        reconnectionAttempts: Infinity,
        reconnectionDelay: 1000,
        auth: { token },
        query: { token },
      });

      this._creating = new Promise((resolve, reject) => {
        socket
          .on('connect', () => {
console.log('>>>> EVENTO CONNECT EJECUTADO');
     


       if (room) socket.emit('join-room', room);
console.log('>>>> Me uni a la room:', room);
 
           this.socket = socket;

            // 🔔 Suscribir eventos, incluso después de reconexión
            this._subscribeEvents();

console.log('>>>> _subscribeEvents ejecutado');



            // Reentregar eventos pendientes que el backend haya guardado
            if (socket.pendingEvents?.length) {
              socket.pendingEvents.forEach(({ event, payload }) => {
                socket.emit(event, payload);
              });
              socket.pendingEvents = [];
            }

            resolve(socket);
          })
         .on('connect_error', (err) => {
  console.log('>>>> CONNECT_ERROR:', err.message);
  reject(err);
     })
          .on('disconnect', (reason) => {
            console.log('🔌 Desconectado:', reason);
          })
          .on('auth_error', () => {
            socket.disconnect();
            reject();
0          });
      }).finally(() => {
        this._creating = null;
      });

      return this._creating;
    },

    /* ----------------------------------------------------------
      SUSCRIPCIONES
    ---------------------------------------------------------- */
_subscribeEvents() {
  const notificationStore = useNotificationStore();

  // 🔔 Notificaciones normales
  this.on('new-notification', (payload) => {
 console.log('🔔 LLEGO new-notification con payload:', payload);
window.dispatchEvent(new CustomEvent('show-notification-toast', { detail: payload }));
 
    if (!payload) return;

    notificationStore.notifications.unshift({
      id: payload.id || Date.now(),
      is_read: payload.is_read ?? 0,
      ...payload,
    });

    this.playNotificationSound();
  });

// ⭐ Abrir modal de calificación
this.on('open_rating_modal', (payload) => {
  console.log('⭐ open_rating_modal:', payload);
  window.dispatchEvent(new CustomEvent('open-rating-modal', { detail: payload }));
});

// 💰 Actualización de pago
this.on('payment_updated', (payload) => {
  console.log('💰 payment_updated:', payload);
  window.dispatchEvent(new CustomEvent('payment-updated', { detail: payload }));
});



  // 📦 Actualizaciones de solicitud
  this.on('request_updated', (payload) => {
    console.log('request_updated:', payload);
  });

  // ⭐ Evento crítico: abrir modal de calificación
  this.on('open_rating_modal', (payload) => {
    console.log('⭐ open_rating_modal recibido:', payload);
    window.dispatchEvent(
      new CustomEvent('open-rating-modal', { detail: payload })
    );
  });
},
    /* ----------------------------------------------------------
      Helpers
    ---------------------------------------------------------- */
    on(event, handler) {
      if (!this.socket) return;
      this.socket.on(event, handler);
      this._listeners.set(event, handler);
    },

    off(event) {
      if (!this.socket) return;
      const handler = this._listeners.get(event);
      if (handler) {
        this.socket.off(event, handler);
        this._listeners.delete(event);
      }
    },

    emit(event, payload) {
      if (!this.socket?.connected) {
        // Guardar eventos si el socket está desconectado
        if (!this.socket) this.socket = {};
        if (!this.socket.pendingEvents) this.socket.pendingEvents = [];
        this.socket.pendingEvents.push({ event, payload });
      } else {
        this.socket.emit(event, payload);
      }
    },

    async playNotificationSound() {
      if (!this.notificationSound) return;
      try {
        this.notificationSound.currentTime = 0;
        await this.notificationSound.play();
      } catch (_) {}
    },

    disconnect() {
      if (!this.socket) return;
      this.socket.disconnect();
      this.socket = null;
      this._listeners.clear();
    },

    /* ----------------------------------------------------------
      FUNCIONES RESTAURADAS
    ---------------------------------------------------------- */
    markAsRead(id) {
      const notificationStore = useNotificationStore();
      const idx = notificationStore.notifications.findIndex((n) => n.id === id);
      if (idx !== -1) notificationStore.notifications[idx].is_read = 1;
    },
  },

  getters: {
    notifications: () => {
      const store = useNotificationStore();
      return store.notifications;
    },

    unreadCount: () => {
      const store = useNotificationStore();
      return store.notifications.filter((n) => !n.is_read).length;
    },
  },
});
