import { defineStore } from 'pinia';
import { io } from 'socket.io-client';
import { useAuthStore } from './authStore';
import { useNotificationStore } from './notificationStore';
import { watch } from 'vue';

export const useSocketStore = defineStore('socket', {
 state: () => ({
   socket: null,
   _creating: null,
   notificationSound: null,
   _soundEnabled: true,
   _componentHandlers: new Map(),
   _pendingEvents: [],
   _reconnectAttempts: 0,
   _maxReconnectDelay: 30000,
   _visibilityListenerAdded: false,
   _stopAuthWatch: null,
   _isDisconnecting: false,
 }),

 actions: {
   async init() {
     const authStore = useAuthStore();
     
     // ✅ Asegurar que el user esté cargado
     if (!authStore.user && authStore.token && typeof authStore.loadUser === 'function') {
       try {
         await authStore.loadUser();
       } catch (err) {
         console.error('❌ Error al cargar usuario:', err);
       }
     }

     if (!this._stopAuthWatch) {
       this._stopAuthWatch = watch(
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
           if (this.socket) {
             this.socket.auth.token = newToken;
             this.socket.emit('refresh-token', newToken);
           }
         },
         { immediate: true }
       );
     }

     if (!this._visibilityListenerAdded) {
       const visibilityHandler = async () => {
         if (!document.hidden && authStore.token && !this.socket?.connected && !this._isDisconnecting) {
           await this.connect(authStore.token, authStore.user);
         }
       };
       document.addEventListener('visibilitychange', visibilityHandler);
       this._visibilityListenerAdded = true;
     }
   },

   async connect(token, user) {
     // Validaciones defensivas
     if (!token || typeof token !== 'string') {
       console.warn('⚠️ Token inválido para conectar socket');
       return null;
     }

     if (this.socket?.connected) return this.socket;
     if (this._creating) return this._creating;
     
     // Manejo de desconexión en progreso con timeout
     if (this._isDisconnecting) {
       console.log('⏳ Esperando desconexión actual...');
       const maxWait = 5000; // 5 segundos max
       const startTime = Date.now();
       
       await new Promise((resolve) => {
         const checkInterval = setInterval(() => {
           if (!this._isDisconnecting || Date.now() - startTime > maxWait) {
             clearInterval(checkInterval);
             resolve();
           }
         }, 100);
       });
     }

     // Lazy loading mejorado del sonido
     if (!this.notificationSound) {
       try {
         this.notificationSound = new Audio();
         this.notificationSound.preload = 'auto';
         this.notificationSound.src = '/sounds/notification.mp3';
         this.notificationSound.volume = 0.6;
       } catch (err) {
         console.warn('⚠️ No se pudo inicializar el sonido:', err);
       }
     }

     const socket = io(import.meta.env.VITE_WS_URL || 'http://192.168.1.248:3001', {
       transports: ['websocket'],
       reconnection: true,
       reconnectionAttempts: 10, // Limitado pero configurable
       reconnectionDelay: 1000,
       reconnectionDelayMax: this._maxReconnectDelay,
       timeout: 20000, // Timeout de conexión
       auth: { token },
     });

     this._creating = new Promise((resolve, reject) => {
       const connectHandler = () => {
         this._reconnectAttempts = 0;
         this._isDisconnecting = false;
         console.log('✅ Socket conectado, ID:', socket.id);

         if (user && user.role && user.id) {
           const room = `${user.role}_${user.id}`;
           socket.emit('join-room', room);
         }

         // Registro de handlers con limpieza previa
         for (const [event, handlersSet] of this._componentHandlers) {
           socket.off(event); // Limpieza crucial para evitar duplicados
           for (const handler of handlersSet) {
             socket.on(event, handler);
           }
         }

         this.socket = socket;
         this._flushPendingEvents();
         resolve(socket);
       };

       const connectErrorHandler = (err) => {
         this._reconnectAttempts++;
         // Backoff exponencial con jitter
         const delay = Math.min(
           this._maxReconnectDelay,
           Math.pow(2, this._reconnectAttempts) * 1000 + Math.random() * 1000
         );
         console.error(`❌ connect_error (intento ${this._reconnectAttempts}, retry en ${delay}ms):`, err.message);
       };

       const disconnectHandler = (reason) => {
         console.warn(`⚠️ Socket desconectado: ${reason}`);
       };

       const authErrorHandler = (data) => {
         console.error('❌ Auth error:', data?.message || 'Unknown auth error');
         socket.disconnect();
         useAuthStore().logout();
         reject(new Error('Auth error'));
       };

       const errorHandler = (err) => {
         console.error('❌ Socket error:', err);
       };

       const notificationHandler = (notification) => {
         const notificationStore = useNotificationStore();
         notificationStore.addNotification(notification);
         this.playNotificationSound();
       };

       socket
         .on('connect', connectHandler)
         .on('connect_error', connectErrorHandler)
         .on('disconnect', disconnectHandler)
         .on('auth_error', authErrorHandler)
         .on('error', errorHandler)
         .on('new-notification', notificationHandler);

     }).finally(() => {
       this._creating = null;
     });

     return this._creating;
   },

   on(event, handler) {
     if (!event || typeof event !== 'string' || !handler || typeof handler !== 'function') {
       console.warn('⚠️ Parámetros inválidos para socket.on()');
       return;
     }

     if (!this._componentHandlers.has(event)) {
       this._componentHandlers.set(event, new Set());
     }

     const handlers = this._componentHandlers.get(event);
     if (!handlers.has(handler)) {
       handlers.add(handler);
       if (this.socket?.connected) {
         this.socket.on(event, handler);
       }
     }
   },

   off(event, handler) {
     if (!event || typeof event !== 'string') {
       console.warn('⚠️ Evento inválido para socket.off()');
       return;
     }

     if (!this._componentHandlers.has(event)) return;
     const handlers = this._componentHandlers.get(event);
     
     if (handler) {
       handlers.delete(handler);
       if (this.socket) this.socket.off(event, handler);
     } else {
       // Si no se pasa handler, remover todos para este evento
       handlers.clear();
       if (this.socket) this.socket.off(event);
     }

     if (handlers.size === 0) this._componentHandlers.delete(event);
   },

   emit(event, payload) {
     if (!event || typeof event !== 'string') {
       console.warn('⚠️ Evento inválido para socket.emit()');
       return;
     }

     if (!this.socket?.connected) {
       console.log(`📤 Evento en cola (offline): ${event}`, payload);
       this._pendingEvents.push({ 
         event, 
         payload, 
         timestamp: Date.now(),
         retryCount: 0 
       });
       
       // Límite más inteligente
       if (this._pendingEvents.length > 100) {
         const dropped = this._pendingEvents.shift();
         console.warn(`🗑️ Evento descartado por cola llena: ${dropped.event}`);
       }
       return;
     }

     try {
       this.socket.emit(event, payload);
     } catch (err) {
       console.error('❌ Error al emitir evento:', err);
       // Re-encolar si falla
       this._pendingEvents.push({ 
         event, 
         payload, 
         timestamp: Date.now(),
         retryCount: 0 
       });
     }
   },

   _flushPendingEvents() {
     if (!this.socket?.connected) {
       console.warn('⚠️ No se pueden flushar eventos: socket no conectado');
       return;
     }

     const now = Date.now();
     const maxAge = 60000; // 1 minuto
     const maxRetries = 3;
     const stillPending = [];

     for (const item of this._pendingEvents) {
       // Expiración por tiempo o reintentos
       const age = now - item.timestamp;
       const retries = item.retryCount || 0;
       
       if (age > maxAge || retries >= maxRetries) {
         console.warn(`⏰ Evento expirado (age: ${age}ms, retries: ${retries}): ${item.event}`, item.payload);
         continue;
       }

       try {
         this.socket.emit(item.event, item.payload);
         console.log(`📤 Evento pendiente enviado: ${item.event}`, item.payload);
       } catch (err) {
         console.error('❌ Error al enviar evento pendiente:', err);
         item.retryCount = retries + 1;
         stillPending.push(item);
       }
     }

     this._pendingEvents = stillPending;
   },

   async playNotificationSound() {
     if (!this._soundEnabled || !this.notificationSound) return;

     try {
       this.notificationSound.currentTime = 0;
       await this.notificationSound.play();
     } catch (err) {
       console.warn('⚠️ No se pudo reproducir sonido:', err.message);
     }
   },

   disconnect() {
     if (this._isDisconnecting) {
       console.warn('⚠️ Desconexión ya en progreso');
       return;
     }

     this._isDisconnecting = true;
     this._pendingEvents = [];

     if (this.socket) {
       // Limpieza exhaustiva de handlers
       for (const [event, handlersSet] of this._componentHandlers) {
         for (const handler of handlersSet) {
           this.socket.off(event, handler);
         }
       }
       this.socket.disconnect();
     }

     this.socket = null;
     this._componentHandlers.clear();
     this._reconnectAttempts = 0;

     if (this._stopAuthWatch) {
       this._stopAuthWatch();
       this._stopAuthWatch = null;
     }
     
     console.log('🔌 SocketStore desconectado completamente');
     this._isDisconnecting = false;
   },

   markAsRead(notificationId) {
     if (!notificationId || typeof notificationId !== 'string') {
       console.warn('⚠️ ID de notificación inválido');
       return;
     }

     const notificationStore = useNotificationStore();
     notificationStore.markAsRead(notificationId);

     if (this.socket?.connected) {
       this.socket.emit('mark_notification_read', { notification_id: notificationId });
     }
   },

   // Métodos utilitarios adicionales
   toggleSound(enabled) {
     this._soundEnabled = enabled;
   },

   getPendingEventsCount() {
     return this._pendingEvents.length;
   },

   clearPendingEvents() {
     this._pendingEvents = [];
   },
 },

 getters: {
   notifications: () => useNotificationStore().notifications,
   unreadCount: () => useNotificationStore().unreadCount,
   isConnected: (state) => state.socket?.connected ?? false,
   pendingEvents: (state) => state._pendingEvents,
   reconnectAttempts: (state) => state._reconnectAttempts,
   soundEnabled: (state) => state._soundEnabled,
 },
});
