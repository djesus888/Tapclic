// src/utils/socket.js
import { io } from 'socket.io-client';

let socket = null;

export function connectSocket(userId) {
  if (!socket) {
    socket = io('http://localhost:3001', {
      query: { userId }
    });

    socket.on('connect', () => {
      console.log('✅ Conectado al socket:', socket.id);
    });

    socket.on('disconnect', () => {
      console.log('⚠️ Socket desconectado');
    });

    socket.on('notification', (data) => {
      console.log('🔔 Nueva notificación recibida:', data);
      // Aquí puedes usar tu store o emitir un evento global
    });
  }

  return socket;
}

export function getSocket() {
  return socket;
}
