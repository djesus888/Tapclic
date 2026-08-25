import { defineStore } from 'pinia';
import { io } from 'socket.io-client';
import { useAuthStore } from './authStore';
import { useNotificationStore } from './notificationStore';
import { useOnlineUsersStore } from './onlineUsersStore';
import { useConversationStore } from './conversationStore';
import { watch } from 'vue';

// Constantes de configuración
const CONFIG = {
  HEARTBEAT_INTERVAL: 30000,
  HTTP_HEARTBEAT_INTERVAL: 60000,
  CONNECTION_TIMEOUT: 10000,
  MAX_RECONNECT_ATTEMPTS: 10,
  RECONNECT_BASE_DELAY: 1000,
  RECONNECT_MAX_DELAY: 30000,
  MAX_PENDING_EVENTS: 50,
  PENDING_EVENT_MAX_AGE: 60000,
  MESSAGE_CONFIRMATION_TIMEOUT: 5000,
  MAX_WAIT_FOR_DISCONNECT: 5000,
  SOUND_VOLUME: 0.6,
};

export const useSocketStore = defineStore('socket', {
  state: () => ({
    // Estado de conexión unificado
    connectionState: 'disconnected',
    socket: null,
    _creating: null,

    // Audio
    notificationSound: null,
    _soundEnabled: true,

    // Handlers y eventos
    _componentHandlers: new Map(),
    _pendingEvents: [],
    _pendingConfirmations: new Map(),
    _joinedRooms: new Set(),
    _pendingRooms: null,

    // Control de reconexión
    _reconnectAttempts: 0,
    _reconnectTimer: null,
    _shouldReconnect: true,
    _disconnectedByServer: false,

    // Heartbeats
    heartbeatInterval: null,
    httpHeartbeatInterval: null,

    // Control de estado
    _isDisconnecting: false,
    _visibilityListenerAdded: false,
    _stopAuthWatch: null,
    _initialized: false,
    _listenersSetup: false,

    // 🔥 NUEVO: Para evitar duplicados de modal de calificación
    _processedRatingModals: new Set(),
  }),

  actions: {
    // ============ MÉTODOS PÚBLICOS ============
    connect(token) {
      const authStore = useAuthStore();
      const tokenToUse = token || authStore.token;

      if (!tokenToUse) {
        console.warn('⚠️ No hay token para conectar socket');
        return null;
      }

      return this.connectWithToken(tokenToUse, authStore.user);
    },

    // ============ MÉTODO PRINCIPAL DE CONEXIÓN ============
    async connectWithToken(token, user) {
      if (this._creating) {
        console.log('⏳ Conexión ya en progreso, esperando...');
        return await this._creating;
      }

      if (this.socket?.connected && this.connectionState === 'connected') {
        console.log('✅ Socket ya conectado, no es necesario reconectar');
        return this.socket;
      }

      if (!token || typeof token !== 'string') {
        console.warn('⚠️ Token inválido para conectar socket');
        return null;
      }

      if (!this._shouldReconnect && this.connectionState === 'reconnecting') {
        console.log('⏸️ Reconexión automática deshabilitada');
        return null;
      }

      if (this._disconnectedByServer) {
        console.log('🔄 Reseteando flag de desconexión por servidor');
        this._disconnectedByServer = false;
      }

      if (this._isDisconnecting) {
        console.log('⏳ Esperando desconexión actual...');
        await this._waitForDisconnect();
      }

      if (!this.notificationSound) {
        this.initNotificationSound();
      }

      this._cleanupOldSocket();

      const wsUrl = this._getWebSocketUrl();
      console.log('🔌 Conectando a WebSocket:', wsUrl);

      const socket = io(wsUrl, {
        transports: ['websocket', 'polling'],
        reconnection: false,
        reconnectionAttempts: 0,
        timeout: CONFIG.CONNECTION_TIMEOUT,
        auth: { token, device_id: localStorage.getItem("device_id") || null },
      });

      this.connectionState = 'connecting';

      this._creating = new Promise((resolve, reject) => {
        const connectionTimeout = setTimeout(() => {
          if (!socket.connected) {
            console.error('❌ Timeout de conexión WebSocket');
            socket.disconnect();
            this.connectionState = 'disconnected';
            reject(new Error('Connection timeout'));
          }
        }, CONFIG.CONNECTION_TIMEOUT);

        const handlers = {
          connect: () => this._onConnect(socket, connectionTimeout, resolve),
          connect_error: (err) => this._onConnectError(err, connectionTimeout, socket, reject),
          disconnect: (reason) => this._onDisconnect(reason),
          auth_error: (data) => this._onAuthError(data, socket, reject),
          error: (err) => this._onError(err),
          heartbeat_ack: () => {},
        };

        Object.entries(handlers).forEach(([event, handler]) => {
          socket.on(event, handler);
        });

        this.socket = socket;
      }).finally(() => {
        this._creating = null;
      });

      return this._creating;
    },

    // ============ MÉTODOS DE INICIALIZACIÓN ============
    async init() {
      const authStore = useAuthStore();

      if (this._initialized && this.socket?.connected) {
        console.log('⚠️ SocketStore ya inicializado y conectado');
        return;
      }

      if (!authStore.token) {
        console.log('⏸️ Sin token, no se inicializa socket');
        return;
      }

      if (!authStore.user && typeof authStore.loadUser === 'function') {
        try {
          await authStore.loadUser();
        } catch (err) {
          console.error('❌ Error al cargar usuario:', err);
        }
      }

      if (!this._stopAuthWatch) {
        this._stopAuthWatch = watch(
          () => authStore.token,
          async (newToken, oldToken) => {
            if (newToken === oldToken) return;
            if (!this.socket || !this.socket.connected) {
              await this.connectWithToken(newToken, authStore.user);
              return;
            }
            this.socket.auth.token = newToken;
            this.socket.emit('refresh-token', newToken);
          },
          { immediate: true }
        );
      }

      if (!this._visibilityListenerAdded) {
        const visibilityHandler = async () => {
          if (!document.hidden && authStore.token &&
              !this.socket?.connected && !this._isDisconnecting &&
              this._shouldReconnect && !this._disconnectedByServer) {
            this.connect(authStore.token);
          }
        };

        const focusHandler = () => {
          if (authStore.token && !this.socket?.connected && !this._isDisconnecting) {
            this._shouldReconnect = true;
            this._disconnectedByServer = false;
            this.connect(authStore.token);
          }
        };

        document.addEventListener("focus", focusHandler);
        document.addEventListener("visibilitychange", visibilityHandler);
        this._visibilityListenerAdded = true;
      }

      this.initNotificationSound();

      try {
        await this.connectWithToken(authStore.token, authStore.user);
        this._initialized = true;
        console.log('✅ Socket inicializado correctamente');
      } catch (err) {
        console.error('❌ Error al inicializar socket:', err);
        this._initialized = false;
      }
    },

    initNotificationSound() {
      try {
        if (!this.notificationSound) {
          this.notificationSound = new Audio();
          this.notificationSound.preload = 'auto';
          this.notificationSound.src = '/sounds/notification.mp3';
          this.notificationSound.volume = CONFIG.SOUND_VOLUME;
          console.log('✅ Sonido de notificación inicializado');
        }
      } catch (err) {
        console.warn('⚠️ No se pudo inicializar el sonido:', err);
      }
    },

    // ============ MÉTODOS DE RECONEXIÓN ============
    _scheduleReconnect() {
      if (!this._shouldReconnect || this._disconnectedByServer || this.connectionState === 'reconnecting') {
        console.log('⏸️ Reconexión no permitida');
        return;
      }

      if (this._reconnectTimer) {
        clearTimeout(this._reconnectTimer);
        this._reconnectTimer = null;
      }

      const delay = Math.min(
        CONFIG.RECONNECT_BASE_DELAY * Math.pow(2, this._reconnectAttempts),
        CONFIG.RECONNECT_MAX_DELAY
      );

      console.log(`🔄 Programando reconexión en ${delay}ms (intento ${this._reconnectAttempts + 1})`);

      this.connectionState = 'reconnecting';
      this._reconnectTimer = setTimeout(() => {
        this._attemptReconnect();
      }, delay);
    },

    async _attemptReconnect() {
      if (this._creating) {
        console.log('⏳ Conexión ya en progreso, esperando...');
        return await this._creating;
      }

      if (this.connectionState === 'reconnecting') return;

      this.connectionState = 'reconnecting';
      this._reconnectAttempts++;

      const authStore = useAuthStore();

      if (!authStore.token) {
        console.log('⏸️ No hay token, deteniendo reconexión');
        this.connectionState = 'disconnected';
        return;
      }

      console.log(`🔄 Intentando reconexión ${this._reconnectAttempts}...`);

      try {
        await this.connectWithToken(authStore.token, authStore.user);
        console.log('✅ Reconexión exitosa');
        this._reconnectAttempts = 0;
        this.connectionState = 'connected';
      } catch (err) {
        console.error(`❌ Error en reconexión ${this._reconnectAttempts}:`, err.message);
        this.connectionState = 'disconnected';

        if (this._shouldReconnect && !this._disconnectedByServer &&
            this._reconnectAttempts < CONFIG.MAX_RECONNECT_ATTEMPTS) {
          this._scheduleReconnect();
        } else {
          console.log('⏸️ Máximos intentos alcanzados o reconexión deshabilitada');
          this._reconnectAttempts = 0;
        }
      }
    },

    reconnect() {
      if (this._disconnectedByServer) {
        console.log('🔄 Intentando reconexión manual después de desconexión por servidor');
        this._disconnectedByServer = false;
        this._shouldReconnect = true;
      }

      if (this._reconnectTimer) {
        clearTimeout(this._reconnectTimer);
        this._reconnectTimer = null;
      }

      const authStore = useAuthStore();
      if (authStore.token) {
        this.connectionState = 'reconnecting';
        this.connectWithToken(authStore.token, authStore.user);
      }
    },

    // ============ MÉTODOS DE DESCONEXIÓN ============
    disconnect() {
      if (this._isDisconnecting) {
        console.warn('⚠️ Desconexión ya en progreso');
        return;
      }

      this._isDisconnecting = true;
      this.connectionState = 'disconnected';

      this._pendingEvents = [];
      this._joinedRooms.clear();
      this._pendingConfirmations.clear();
      this._pendingRooms = null;

      if (this._reconnectTimer) {
        clearTimeout(this._reconnectTimer);
        this._reconnectTimer = null;
      }

      if (this.heartbeatInterval) {
        clearInterval(this.heartbeatInterval);
        this.heartbeatInterval = null;
      }

      if (this.httpHeartbeatInterval) {
        clearInterval(this.httpHeartbeatInterval);
        this.httpHeartbeatInterval = null;
      }

      if (this.socket) {
        this.socket.removeAllListeners();
        this.socket.disconnect();
        this.socket = null;
      }

      this._reconnectAttempts = 0;
      this._shouldReconnect = true;
      this._disconnectedByServer = false;
      this._listenersSetup = false;

      if (this._stopAuthWatch) {
        this._stopAuthWatch();
        this._stopAuthWatch = null;
      }

      this._initialized = false;
      this._isDisconnecting = false;

      console.log('🔌 SocketStore desconectado completamente');
    },

    // ============ MÉTODOS DE EVENTOS ============
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
        console.log(`🎧 Handler registrado para evento: ${event}`);
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
      } else {
        handlers.clear();
      }

      if (handlers.size === 0) {
        this._componentHandlers.delete(event);
      }
    },

    cleanupHandlers(event, componentId) {
      if (!event) return;

      if (componentId && this._componentHandlers.has(event)) {
        const handlers = this._componentHandlers.get(event);

        for (const handler of handlers) {
          if (handler.__componentId === componentId) {
            handlers.delete(handler);
          }
        }

        if (handlers.size === 0) {
          this._componentHandlers.delete(event);
        }
      }
    },

    cleanupComponentHandlers(componentId) {
      if (!componentId) return;

      for (const [event, handlers] of this._componentHandlers) {
        for (const handler of handlers) {
          if (handler.__componentId === componentId) {
            handlers.delete(handler);
          }
        }

        if (handlers.size === 0) {
          this._componentHandlers.delete(event);
        }
      }
    },

    // ============ MÉTODOS DE EMISIÓN ============
    emit(event, payload) {
      if (!event || typeof event !== 'string') {
        console.warn('⚠️ Evento inválido para socket.emit()');
        return;
      }

      if (!this.socket) {
        console.log(`📤 Socket no disponible, encolando evento: ${event}`);
        this._queueEvent(event, payload);
        return;
      }

      let safePayload = {};
      try {
        safePayload = payload ? JSON.parse(JSON.stringify(payload)) : {};
      } catch (e) {
        console.error('❌ Error al copiar payload:', e);
        safePayload = payload || {};
      }

      if (!this.socket.connected) {
        console.log(`📤 Evento en cola (offline): ${event}`, safePayload);
        this._queueEvent(event, safePayload);
        return;
      }

      try {
        if (event === 'send_message') {
          const tempId = safePayload.temp_id || Date.now();
          this._pendingConfirmations.set(tempId, {
            event,
            payload: safePayload,
            timestamp: Date.now()
          });

          setTimeout(() => {
            if (this._pendingConfirmations.has(tempId)) {
              console.warn(`⚠️ No se recibió confirmación para mensaje ${tempId}`);
              this._pendingConfirmations.delete(tempId);
            }
          }, CONFIG.MESSAGE_CONFIRMATION_TIMEOUT);
        }

        this.socket.emit(event, safePayload, () => {});
        console.log(`📤 Evento enviado: ${event}`, safePayload);
      } catch (err) {
        console.error('❌ Error al emitir evento:', err);
        this._queueEvent(event, safePayload);
      }
    },

    _queueEvent(event, payload) {
      this._pendingEvents.push({
        event,
        payload,
        timestamp: Date.now(),
        retryCount: 0
      });

      if (this._pendingEvents.length > CONFIG.MAX_PENDING_EVENTS) {
        const dropped = this._pendingEvents.shift();
        console.warn(`🗑️ Evento descartado por cola llena: ${dropped.event}`);
      }
    },

    _flushPendingEvents() {
      if (!this.socket || !this.socket.connected) {
        console.warn('⚠️ No se pueden flushar eventos: socket no conectado');
        return;
      }

      const now = Date.now();
      const stillPending = [];

      for (const item of this._pendingEvents) {
        const age = now - item.timestamp;
        const retries = item.retryCount || 0;

        if (age > CONFIG.PENDING_EVENT_MAX_AGE || retries >= CONFIG.MAX_RECONNECT_ATTEMPTS) {
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

    // ============ MÉTODOS DE MENSAJES ============
    sendMessage(conversation_id, message, temp_id = Date.now()) {
      return this.emit('send_message', {
        conversation_id,
        ...message,
        temp_id
      });
    },

    sendTyping(conversation_id, receiver_id, receiver_role, is_typing) {
      return this.emit('typing', {
        conversation_id,
        receiver_id,
        receiver_role,
        is_typing
      });
    },

    markMessagesRead(messages, conversationWith) {
      return this.emit('message_read', { messages, conversationWith });
    },

    markMessagesAsRead(conversationId, messageIds) {
      if (!conversationId || !messageIds?.length) {
        console.warn('⚠️ Parámetros inválidos para markMessagesAsRead');
        return;
      }
      this.emit('message_read', {
        conversation_id: conversationId,
        message_ids: messageIds,
        timestamp: new Date().toISOString()
      });
    },

    markMessagesAsDelivered(conversationId, messageIds) {
      if (!conversationId || !messageIds?.length) return;
      this.emit('message_delivered', {
        conversation_id: conversationId,
        message_ids: messageIds
      });
    },

    // ============ MÉTODOS DE SALAS ============
    async joinConversationRoom(conversationId) {
      if (!conversationId) {
        console.warn('⚠️ No se puede unir a sala: conversationId inválido');
        return false;
      }

      const room = `conversation_${conversationId}`;

      if (this._joinedRooms.has(room)) {
        console.log(`✅ Ya está en sala: ${room}`);
        return true;
      }

      if (!this.socket || !this.socket.connected) {
        console.log(`⏳ Socket no conectado, guardando sala para unirse después: ${room}`);
        this._pendingRooms = this._pendingRooms || new Set();
        this._pendingRooms.add(room);
        return false;
      }

      return new Promise((resolve) => {
        console.log(`🔗 Uniéndose a sala: ${room}`);
        this.socket.emit('join-room', room, (response) => {
          if (response?.success) {
            this._joinedRooms.add(room);
            console.log(`✅ Unido a sala de conversación: ${room}`);
            resolve(true);
          } else {
            console.error(`❌ Error al unirse a conversación ${room}:`, response?.error);
            resolve(false);
          }
        });
      });
    },

    leaveConversationRoom(conversationId) {
      if (!this.socket?.connected || !conversationId) return;

      const room = `conversation_${conversationId}`;
      this.socket.emit('leave-room', room);
      this._joinedRooms.delete(room);
      console.log(`👋 Salido de sala: ${room}`);
    },

    isInRoom(room) {
      return this._joinedRooms.has(room);
    },

    // ============ MÉTODOS DE NOTIFICACIONES ============
    markAsRead(notificationId) {
      if (!notificationId || typeof notificationId !== 'string') {
        console.warn('⚠️ ID de notificación inválido');
        return;
      }

      const notificationStore = useNotificationStore();
      notificationStore.markAsRead(notificationId);
    },

    async playNotificationSound() {
      if (!this._soundEnabled) {
        console.log('🔇 Sonido deshabilitado');
        return;
      }

      if (!this.notificationSound) {
        console.warn('⚠️ Sonido no inicializado, intentando inicializar...');
        this.initNotificationSound();
        await new Promise(resolve => setTimeout(resolve, 100));
      }

      if (!this.notificationSound) {
        console.error('❌ No se pudo inicializar el sonido');
        return;
      }

      try {
        this.notificationSound.currentTime = 0;
        await this.notificationSound.play();
        console.log('🔊 Sonido de notificación reproducido');
      } catch (err) {
        console.warn('⚠️ No se pudo reproducir sonido:', err.message);
        try {
          this.notificationSound.load();
          setTimeout(async () => {
            try {
              await this.notificationSound.play();
              console.log('🔊 Sonido reproducido después de recargar');
            } catch (e) {
              console.warn('⚠️ Segundo intento falló:', e.message);
            }
          }, 500);
        } catch (e) {
          console.warn('⚠️ Error al recargar audio:', e.message);
        }
      }
    },

    toggleSound(enabled) {
      this._soundEnabled = enabled;
      console.log(`🔊 Sonido ${enabled ? 'activado' : 'desactivado'}`);
    },

    // ============ MÉTODOS DE HEARTBEAT ============
    startHeartbeat() {
      if (this.heartbeatInterval) {
        clearInterval(this.heartbeatInterval);
      }
      this.heartbeatInterval = setInterval(() => {
        if (this.socket?.connected) {
          this.socket.emit('heartbeat');
        }
      }, CONFIG.HEARTBEAT_INTERVAL);
    },

    startHttpHeartbeat() {
      if (this.httpHeartbeatInterval) {
        clearInterval(this.httpHeartbeatInterval);
      }

      setTimeout(() => this.sendHttpHeartbeat(), 1000);

      this.httpHeartbeatInterval = setInterval(() => {
        this.sendHttpHeartbeat();
      }, CONFIG.HTTP_HEARTBEAT_INTERVAL);
    },

    async sendHttpHeartbeat() {
      const authStore = useAuthStore();
      if (!authStore.token) return;

      try {
        const response = await fetch(`${import.meta.env.VITE_API_URL}/user/heartbeat`, {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${authStore.token}`,
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          credentials: 'include'
        });

        if (!response.ok) {
          const errorData = await response.text();
          console.error('❌ Heartbeat error:', response.status, errorData);
          return;
        }

        const data = await response.json();
        if (data.online_users) {
          const onlineUsersStore = useOnlineUsersStore();
          onlineUsersStore.mergeOnlineUsers(data.online_users);
        }
      } catch (error) {
        console.error('❌ Error en heartbeat HTTP:', error);
      }
    },

    // ============ MÉTODOS DE UTILIDAD ============
    getPendingEventsCount() {
      return this._pendingEvents.length;
    },

    clearPendingEvents() {
      this._pendingEvents = [];
    },

    resendPendingMessages() {
      this._flushPendingEvents();
    },

    // ============ MÉTODOS PRIVADOS ============
    _waitForDisconnect() {
      return new Promise((resolve) => {
        const startTime = Date.now();
        const checkInterval = setInterval(() => {
          if (!this._isDisconnecting || Date.now() - startTime > CONFIG.MAX_WAIT_FOR_DISCONNECT) {
            clearInterval(checkInterval);
            resolve();
          }
        }, 100);
      });
    },

    _cleanupOldSocket() {
      if (this.socket) {
        console.log('🧹 Limpiando socket anterior no conectado');
        this.socket.removeAllListeners();
        this.socket.disconnect();
        this.socket = null;
      }
    },

    _getWebSocketUrl() {
      let wsUrl = import.meta.env.VITE_WS_URL;
      if (wsUrl) {
        if (wsUrl.startsWith('https://')) {
          wsUrl = wsUrl.replace('https://', 'wss://');
        } else if (wsUrl.startsWith('http://')) {
          wsUrl = wsUrl.replace('http://', 'ws://');
        }
      }
      return wsUrl;
    },

    _onConnect(socket, connectionTimeout, resolve) {
      clearTimeout(connectionTimeout);
      this._reconnectAttempts = 0;
      this.connectionState = 'connected';

      if (this._reconnectTimer) {
        clearTimeout(this._reconnectTimer);
        this._reconnectTimer = null;
      }

      this._isDisconnecting = false;
      this._shouldReconnect = true;
      this._disconnectedByServer = false;

      console.log('✅ Socket conectado, ID:', socket.id);

      this._rejoinRooms(socket);
      this._setupStoreListeners(socket);
      this._reconnectComponentHandlers(socket);

      this.socket = socket;
      this._flushPendingEvents();
      this.startHeartbeat();
      this.startHttpHeartbeat();

      this._emitToHandlers('connect', { socketId: socket.id });
      resolve(socket);
    },

    _onConnectError(err, connectionTimeout, socket, reject) {
      clearTimeout(connectionTimeout);
      console.error(`❌ connect_error:`, err.message);

      this.connectionState = 'disconnected';

      if (err.message && err.message.includes('duplicate')) {
        console.log('⛔ Conexión duplicada detectada, deteniendo reconexión');
        this._shouldReconnect = false;
        this._disconnectedByServer = true;
        socket.disconnect();
        reject(new Error('Conexión duplicada'));
      } else {
        this._scheduleReconnect();
        reject(err);
      }
    },

    _onDisconnect(reason) {
      console.warn(`⚠️ Socket desconectado: ${reason}`);
      this.connectionState = 'disconnected';

      if (reason === 'io server disconnect' || reason === 'server namespace disconnect') {
        console.log('⏸️ Desconexión por servidor, deteniendo reconexión');
        this._shouldReconnect = false;
        this._disconnectedByServer = true;
        if (this._reconnectTimer) {
          clearTimeout(this._reconnectTimer);
          this._reconnectTimer = null;
        }
        this._emitToHandlers('connection_closed_by_server', { reason });
        return;
      }

      if (reason === 'transport close' || reason === 'transport error' || reason === 'ping timeout') {
        if (this._shouldReconnect && !this._disconnectedByServer) {
          this._scheduleReconnect();
        }
      }
    },

    _onAuthError(data, socket, reject) {
      console.error('❌ Auth error:', data?.message || 'Unknown auth error');
      this._shouldReconnect = false;
      this._disconnectedByServer = true;
      this.connectionState = 'disconnected';

      socket.disconnect();

      useAuthStore().logout().finally(() => {
        reject(new Error('Auth error'));
      });
    },

    _onError(err) {
      console.error('❌ Socket error:', err);
    },

    _rejoinRooms(socket) {
      const roomsToRejoin = new Set(this._joinedRooms);
      this._joinedRooms.clear();
      console.log('🧹 Salas unidas limpiadas tras reconexión, reuniendo:', [...roomsToRejoin]);

      const currentPath = window.location.pathname;
      const chatMatch = currentPath.match(/\/chat\/(\d+)/);
      if (chatMatch) {
        const conversationId = chatMatch[1];
        this.joinConversationRoom(conversationId);
      }

      roomsToRejoin.forEach(room => {
        socket.emit('join-room', room, (response) => {
          if (response?.success) {
            console.log(`✅ Re-unido a sala: ${room}`);
          }
        });
      });

      if (this._pendingRooms && this._pendingRooms.size > 0) {
        console.log(`🔄 Uniéndose a ${this._pendingRooms.size} salas pendientes...`);
        this._pendingRooms.forEach(room => {
          socket.emit('join-room', room, (response) => {
            if (response?.success) {
              this._joinedRooms.add(room);
              console.log(`✅ Unido a sala pendiente: ${room}`);
            }
          });
        });
        this._pendingRooms.clear();
      }
    },

    _reconnectComponentHandlers(socket) {
      for (const [event, handlersSet] of this._componentHandlers) {
        for (const handler of handlersSet) {
          socket.off(event, handler);
          if (!socket.listeners(event).includes(handler)) {
            socket.on(event, handler);
          }
        }
      }
    },

    _setupStoreListeners(socket) {
      // Limpiar listeners viejos del socket actual antes de agregar nuevos
      if (socket) {
        socket.removeAllListeners();
      }

      const onlineUsersStore = useOnlineUsersStore();
      const notificationStore = useNotificationStore();
      const conversationStore = useConversationStore();

      // Usuarios online
      socket.on('users_online', (users) => {
        console.log('👥 Usuarios online actualizados:', users.length);
        const normalized = users.map(u => ({
          userId: u.userId || u.id,
          role: u.role,
          name: u.name || u.userName,
          avatar: u.avatar || u.avatar_url,
          socketId: u.socketId,
          connectedAt: u.connectedAt
        }));
        onlineUsersStore.mergeOnlineUsers(normalized);
      });

      socket.on('user_online', (data) => {
        const userId = data?.user_id || data?.userId || data?.id || data;
        const role = data?.role;
        console.log('👤 Usuario conectado:', userId, role);
        onlineUsersStore.addOnlineUser({ userId, role });
      });

      socket.on('user_offline', (data) => {
        const userId = data?.user_id || data?.userId || data?.id || data;
        const role = data?.role;
        console.log('🔴 Usuario desconectado:', userId, role);

        if (!role) {
          console.warn('⚠️ user_offline recibido sin role, la eliminación puede ser incorrecta');
        }
        onlineUsersStore.removeOnlineUser(userId, role);
      });

      // 🔥 LISTENER: Notificaciones generales
      socket.on('new-notification', (notification) => {
        console.log('📬 [SOCKET] Notificación recibida:', notification);
        
        // Verificar si es una notificación de mensaje
        if (notification.data_json) {
          try {
            const data = JSON.parse(notification.data_json);
            if (data.notification_type === 'new_message') {
              notificationStore.addNotification(notification, false);
              return;
            }
          } catch (e) {
            // No es JSON, continuar normal
          }
        }
        
        // Notificación normal del sistema
        notificationStore.addNotification(notification);
        this.playNotificationSound();
      });

      // 🔥 LISTENER: Modal de calificación (con prevención de duplicados)
      socket.on('open_rating_modal', (data) => {
        console.log('⭐ [SOCKET] Modal de calificación recibido:', data);
        
        // 🔥 CORRECCIÓN: Evitar duplicados por notification_id
        if (data?.notification_id) {
          const notificationKey = `rating_${data.notification_id}`;
          
          // Si ya procesamos esta notificación, ignorar
          if (this._processedRatingModals?.has(notificationKey)) {
            console.log('🔇 [SOCKET] Modal de calificación duplicado, omitiendo:', data.notification_id);
            return;
          }
          
          // Marcar como procesado
          if (!this._processedRatingModals) {
            this._processedRatingModals = new Set();
          }
          this._processedRatingModals.add(notificationKey);
          
          // Limpiar después de 30 segundos para evitar memoria infinita
          setTimeout(() => {
            this._processedRatingModals?.delete(notificationKey);
          }, 30000);
        }
        
        // Emitir a los handlers de componentes
        this._emitToHandlers('open_rating_modal', data);
        
        // También reproducir sonido
        this.playNotificationSound();
        
        // Disparar evento global para abrir el modal
        window.dispatchEvent(new CustomEvent('open-rating-modal', {
          detail: {
            request_id: data.request_id || (data.url || '').split('/').pop(),
            targetRole: data.target_role || data.from_role === 'provider' ? 'user' : 'provider',
            from_role: data.from_role || 'provider',
            message: data.message || '¿Quieres calificar este servicio?'
          }
        }));
      });

      // Solicitudes y pagos
      socket.on('new_request_created', (data) => {
        console.log('🆕 [SOCKET] Nueva solicitud recibida:', data);
        this.playNotificationSound();
        this._emitToHandlers('new_request_created', data);
      });

      socket.on('request_updated', (data) => {
        console.log('🔄 [SOCKET] Solicitud actualizada:', JSON.stringify(data));
        const status = data.request?.status || data.status;
        if (status === 'accepted' || status === 'rejected' || status === 'cancelled' || status === 'completed') {
          this.playNotificationSound();
        }
        this._emitToHandlers('request_updated', data);
      });

      socket.on('payment_updated', (data) => {
        console.log('💳 [SOCKET] Pago actualizado:', JSON.stringify(data));
        this.playNotificationSound();
        this._emitToHandlers('payment_updated', data);
      });

      // Mensajes
      socket.on('new_message', (data) => {
        console.log('📨 [SOCKET] new_message recibido:', JSON.stringify(data, null, 2));

        let messageData = {};
        if (data.message && typeof data.message === 'object') {
          messageData = {
            ...data,
            ...data.message,
            conversation_id: data.conversation_id || data.message.conversation_id
          };
        } else {
          messageData = { ...data };
        }

        if (data.payload) {
          messageData = {
            ...messageData,
            ...data.payload
          };
        }

        const authStore = useAuthStore();
        messageData.is_mine = String(messageData.sender_id) === String(authStore.user?.id) &&
          messageData.sender === authStore.user?.role;

        const conversationId = messageData.conversation_id;
        if (!conversationId) {
          console.error('❌ [SOCKET] No se pudo obtener conversation_id');
          return;
        }

        const room = `conversation_${conversationId}`;
        if (!this._joinedRooms.has(room) && this.socket?.connected) {
          this.joinConversationRoom(conversationId);
        }

        const existingMessages = conversationStore?.messages?.[conversationId] || [];
        const messageExists = existingMessages.some(m =>
          m.id === messageData.id ||
          (messageData.temp_id && m.temp_id === messageData.temp_id)
        );

        if (messageExists) {
          console.log('📨 [SOCKET] Mensaje ya existe, omitiendo duplicado:', messageData.id);
          return;
        }

        if (messageData.is_mine && messageData.temp_id) {
          const tempIndex = existingMessages.findIndex(m =>
            m.temp_id === messageData.temp_id && m._temp === true
          );
          if (tempIndex !== -1) {
            console.log('🔄 [SOCKET] Reemplazando mensaje temporal:', messageData.temp_id);
            conversationStore.messages[conversationId][tempIndex] = {
              ...existingMessages[tempIndex],
              ...messageData,
              _temp: false,
              temp_id: undefined
            };
            conversationStore.messages = {
              ...conversationStore.messages,
              [conversationId]: [...conversationStore.messages[conversationId]]
            };
            return;
          }
        }

        if (conversationStore) {
          conversationStore.addMessage(conversationId, messageData);
        }
      });

      socket.on('message_deleted', (data) => {
        console.log('🗑️ Mensaje eliminado:', data);
        const normalizedData = this._normalizeEventData(data);
        if (conversationStore) {
          const conversationId = normalizedData.conversation_id || data.conversation_id;
          const messageId = normalizedData.message_id || data.message_id ||
            (normalizedData.message_ids && normalizedData.message_ids[0]) ||
            (data.message_ids && data.message_ids[0]);

          if (conversationId && messageId) {
            conversationStore.removeMessage(conversationId, messageId);
          } else {
            console.warn('⚠️ No se pudo eliminar mensaje: faltan parámetros', { normalizedData, data });
          }
        }
        this._emitToHandlers('message_deleted', normalizedData);
      });

      socket.on('message_read', (data) => {
        console.log('✅ [SOCKET] Mensajes leídos:', data);
        const normalizedData = this._normalizeEventData(data);
        if (conversationStore) {
          const conversationId = normalizedData.conversation_id || data.conversation_id;
          const messageIds = normalizedData.message_ids || data.message_ids || [];
          if (conversationId && messageIds.length > 0) {
            conversationStore.markMessagesAsReadLocally(conversationId, messageIds);
          }
        }
        this._emitToHandlers('message_read', normalizedData);
      });

      socket.on('message_delivered', (data) => {
        console.log('📬 Mensajes entregados:', data);
        const normalizedData = this._normalizeEventData(data);
        if (conversationStore) {
          conversationStore.markMessagesAsDelivered(normalizedData);
        }
        this._emitToHandlers('message_delivered', normalizedData);
      });

      socket.on('typing_indicator', (data) => {
        console.log('⌨️ Indicador de escritura:', data);
        const normalizedData = this._normalizeEventData(data);
        if (conversationStore) {
          conversationStore.setTypingIndicator(normalizedData);
        }
        this._emitToHandlers('typing_indicator', normalizedData);
      });

      socket.on('message_sent_confirmation', (data) => {
        console.log('✅ Confirmación de mensaje:', data);
        this._pendingConfirmations.delete(data.temp_id);
        if (conversationStore) {
          conversationStore.confirmMessageSent(data);
        }
        this._emitToHandlers('message_sent_confirmation', data);
      });

      socket.on('duplicate_connection', (data) => {
        console.warn('⚠️ Conexión duplicada:', data);
        this._shouldReconnect = false;
        this._disconnectedByServer = true;
        this.connectionState = 'disconnected';
        this._emitToHandlers('duplicate_connection', data);
      });
    },

    _normalizeEventData(data) {
      if (!data) return data;

      if (data.event === 'new_message' || data.message || data.payload?.message) {
        const message = data.message || data.payload?.message || data;
        return {
          ...data,
          conversation_id: data.conversation_id || message.conversation_id,
          message: message
        };
      }

      if (data.payload) return data.payload;
      if (data.message) return data.message;
      return data;
    },

    _emitToHandlers(event, data) {
      if (this._componentHandlers.has(event)) {
        const handlers = this._componentHandlers.get(event);

        handlers.forEach(handler => {
          try {
            handler(data);
          } catch (err) {
            console.error(`❌ Error en handler de evento ${event}:`, err);
          }
        });
      }
    },
  },

  getters: {
    isConnected: (state) => state.socket?.connected ?? false,

    pendingEvents: (state) => state._pendingEvents,

    reconnectAttempts: (state) => state._reconnectAttempts,

    soundEnabled: (state) => state._soundEnabled,

    joinedRooms: (state) => Array.from(state._joinedRooms),

    shouldReconnect: (state) => state._shouldReconnect,

    disconnectedByServer: (state) => state._disconnectedByServer,

    isInConversation: (state) => (conversationId) => {
      return state._joinedRooms.has(`conversation_${conversationId}`);
    },

    pendingEventsCount: (state) => state._pendingEvents.length,
  },
});
