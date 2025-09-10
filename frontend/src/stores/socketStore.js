// src/stores/socketStore.js
import { defineStore } from 'pinia';
import { io } from 'socket.io-client';
import { useAuthStore } from './authStore';

export const useSocketStore = defineStore('socket', {
  state: () => ({
    socket: null,
    notifications: [],
    notificationSound: null
  }),

  actions: {
    init() {
      if (this.socket) return;

      const authStore = useAuthStore();

      // ✅ Validar que exista user y token antes de conectar
      if (!authStore.user || !authStore.token) {
        console.warn('socketStore.init(): authStore.user o token no definidos, WS no se inicializa');
        return;
      }

      this.socket = io('http://localhost:3001', {
        auth: { token: authStore.token }
      });

      const room = `${authStore.user.role}_${authStore.user.id}`;
      this.socket.emit('join-room', room);

      this.notificationSound = new Audio('/sounds/notification.mp3');

      this.socket.on('connect', () => console.log('🔌 Conectado a WebSocket'));
      this.socket.on('disconnect', (reason) =>
        console.log('❌ Desconectado del WS:', reason)
      );

      this.socket.on('new-notification', (data) => {
        console.log('📣 Notificación recibida:', data);
        this.notifications.unshift(data);
        this.playNotificationSound();
      });
    },

    emit(event, payload) {
      if (this.socket) this.socket.emit(event, payload);
    },

    on(event, handler) {
      this.socket?.on(event, handler);
    },
    off(event, handler) {
      this.socket?.off(event, handler);
    },

    markAsRead(id) {
      const index = this.notifications.findIndex(n => n.id === id);
      if (index !== -1) this.notifications[index].is_read = 1;
    },

    clearNotifications() {
      this.notifications = [];
    },

    playNotificationSound() {
      const sound = new Audio('/sounds/notification.mp3');
      sound.play().catch(() => {});
    }
  },

  getters: {
    unreadCount: (state) => state.notifications.filter(n => !n.is_read).length
  }
});
