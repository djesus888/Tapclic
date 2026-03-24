import { defineStore } from 'pinia';
import { io } from 'socket.io-client';
import { useAuthStore } from './authStore';
import { useNotificationStore } from './notificationStore';
import { useOnlineUsersStore } from './onlineUsersStore';
import { useConversationStore } from './conversationStore';
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
    heartbeatInterval: null,
    httpHeartbeatInterval: null,
    // Tracking de salas unidas
    _joinedRooms: new Set(),
    // Salas pendientes para unirse después de reconectar
    _pendingRooms: null,
    // Cola de mensajes por confirmar
    _pendingConfirmations: new Map(),
    // Control de reconexión para evitar bucles
    _shouldReconnect: true,
    _reconnectTimer: null,
    // Flag para identificar si la desconexión fue por servidor
    _disconnectedByServer: false,
    // Flag para evitar múltiples inicializaciones
    _initialized: false,
    // CORRECCIÓN: Eliminado state.connected (usar solo getter)
    // CORRECCIÓN 1: Variables para control de reconexión con backoff
    _reconnectBaseDelay: 1000,
    _reconnectMaxDelay: 30000,
    _isReconnecting: false,
  }),

  actions: {
    // ✅ NUEVO: Método simplificado para conectar (compatible con websocket.js)
    connect(token) {
      const authStore = useAuthStore();
      const tokenToUse = token || authStore.token;
      if (!tokenToUse) {
        console.warn('⚠️ No hay token para conectar socket');
        return null;
      }
      // Si ya hay socket conectado, retornarlo
      if (this.socket?.connected) {
        console.log('🔌 Socket ya conectado');
        return this.socket;
      }
      // Usar el método connectWithToken existente
      return this.connectWithToken(tokenToUse, authStore.user);
    },

    // Renombramos el connect original para mantener compatibilidad interna
    async connectWithToken(token, user) {
      if (!token || typeof token !== 'string') {
        console.warn('⚠️ Token inválido para conectar socket');
        return null;
      }

      // CORRECCIÓN 3: No destruir socket si ya está conectado
      if (this.socket?.connected) {
        console.log('🔌 Socket ya conectado, reutilizando');
        return this.socket;
      }
      // Verificar si fue desconectado por servidor
      if (!this._shouldReconnect || this._disconnectedByServer) {
        console.log('⏸️ Reconexión deshabilitada por desconexión del servidor');
        return null;
      }
      // CORRECCIÓN 10: Esperar promesa existente correctamente
      if (this._creating) {
        console.log('⏳ Conexión ya en progreso, esperando...');
        return await this._creating;
      }
      if (this._isDisconnecting) {
        console.log('⏳ Esperando desconexión actual...');
        const maxWait = 5000;
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

      if (!this.notificationSound) {
        this.initNotificationSound();
      }

      // CORRECCIÓN 3: Limpiar socket anterior SOLO si no está conectado
      if (this.socket) {
        console.log('🧹 Limpiando socket anterior no conectado');
        this.socket.removeAllListeners();
        this.socket.disconnect();
        this.socket = null;
      }
      // Usar la URL correcta desde la variable de entorno
      let wsUrl = import.meta.env.VITE_WS_URL;
      // CORRECCIÓN 1: Corregir conversión de URL http a ws/wss
      if (wsUrl && wsUrl.startsWith('https://')) {
        wsUrl = wsUrl.replace('https://', 'wss://');
      } else if (wsUrl && wsUrl.startsWith('http://')) {
        wsUrl = wsUrl.replace('http://', 'ws://');
      }
      console.log('🔌 Conectando a WebSocket:', wsUrl);

      const socket = io(wsUrl, {
        transports: ['websocket', 'polling'], // CORRECCIÓN 2: Añadir polling como fallback
        reconnection: false, // Desactivamos reconexión automática, manejaremos manualmente con backoff
        reconnectionAttempts: 0,
        timeout: 20000,
        auth: { token },
      });

      this._creating = new Promise((resolve, reject) => {
        // Timeout de conexión
        const connectionTimeout = setTimeout(() => {
          if (!socket.connected) {
            console.error('❌ Timeout de conexión WebSocket');
            socket.disconnect();
            reject(new Error('Connection timeout'));
          }
        }, 10000);

        const connectHandler = () => {
          clearTimeout(connectionTimeout);
          // CORRECCIÓN 1: Resetear contador de reconexión al conectar exitosamente
          this._reconnectAttempts = 0;
          this._isReconnecting = false;
          if (this._reconnectTimer) {
            clearTimeout(this._reconnectTimer);
            this._reconnectTimer = null;
          }
          this._isDisconnecting = false;
          this._shouldReconnect = true;
          this._disconnectedByServer = false; // Resetear flag

          console.log('✅ Socket conectado, ID:', socket.id);

          // Unirse a salas del usuario - COMENTADO
          // if (user && user.role && user.id) {
          //   const room = `${user.role}_${user.id}`;
          //   socket.emit('join-room', room, (response) => {
          //     if (response?.success) {
          //       this._joinedRooms.add(room);
          //       console.log(`✅ Unido a la sala: ${room}`);
          //     } else {
          //       console.error(`❌ Error al unirse a la sala ${room}:`, response?.error);
          //     }
          //   });
          // }

          // Unirse a conversaciones activas basadas en URL
          const currentPath = window.location.pathname;
          const chatMatch = currentPath.match(/\/chat\/(\d+)/);
          if (chatMatch) {
            const conversationId = chatMatch[1];
            this.joinConversationRoom(conversationId);
          }

          // Re-unirse a salas guardadas
          this._joinedRooms.forEach(room => {
            socket.emit('join-room', room, (response) => {
              if (response?.success) {
                console.log(`✅ Re-unido a sala: ${room}`);
              }
            });
          });

          // ✅ NUEVO: Unirse a salas pendientes después de reconectar
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

          // CORRECCIÓN 9: Re-registrar handlers de componentes sin duplicar
          for (const [event, handlersSet] of this._componentHandlers) {
            for (const handler of handlersSet) {
              // Asegurarse de no duplicar handlers
              socket.off(event, handler);
              // Verificar que no esté ya registrado antes de añadirlo
              if (!socket.listeners(event).includes(handler)) {
                socket.on(event, handler);
              }
            }
          }

          this.socket = socket;
          this._flushPendingEvents();
          this.startHeartbeat();
          this.startHttpHeartbeat();

          resolve(socket);
        };

        const connectErrorHandler = (err) => {
          clearTimeout(connectionTimeout);
          console.error(`❌ connect_error:`, err.message);

          // Si el error es por conexión duplicada, detener reconexión
          if (err.message && err.message.includes('duplicate')) {
            console.log('⛔ Conexión duplicada detectada, deteniendo reconexión');
            this._shouldReconnect = false;
            this._disconnectedByServer = true; // Marcar como desconectado por servidor
            socket.disconnect();
            reject(new Error('Conexión duplicada'));
          } else {
            // CORRECCIÓN 1: Iniciar reconexión con backoff
            this._scheduleReconnect();
            reject(err);
          }
        };

        const disconnectHandler = (reason) => {
          console.warn(`⚠️ Socket desconectado: ${reason}`);
          // CORRECCIÓN 4: Solo considerar desconexión por servidor cuando es explícita
          if (reason === 'io server disconnect') {
            console.log('⏸️ Desconexión por servidor (namespace), deteniendo reconexión');
            this._shouldReconnect = false;
            this._disconnectedByServer = true;
            // Limpiar cualquier timer de reconexión
            if (this._reconnectTimer) {
              clearTimeout(this._reconnectTimer);
              this._reconnectTimer = null;
            }
          } else if (reason === 'transport close' || reason === 'transport error') {
            // CORRECCIÓN 1: Reconectar en caso de error de transporte
            if (this._shouldReconnect && !this._disconnectedByServer) {
              this._scheduleReconnect();
            }
          }
          // ELIMINADO: transport close NO es necesariamente del servidor
        };

        const authErrorHandler = (data) => {
          clearTimeout(connectionTimeout);
          console.error('❌ Auth error:', data?.message || 'Unknown auth error');
          this._shouldReconnect = false;
          this._disconnectedByServer = true; // Marcar como desconectado por servidor
          // Desconectar socket primero
          socket.disconnect();
          // Luego hacer logout
          useAuthStore().logout().finally(() => {
            reject(new Error('Auth error'));
          });
        };

        const errorHandler = (err) => {
          console.error('❌ Socket error:', err);
        };

        // ✅ NUEVO: Setup de listeners para otros stores
        this._setupStoreListeners(socket);

        socket
          .on('connect', connectHandler)
          .on('connect_error', connectErrorHandler)
          .on('disconnect', disconnectHandler)
          .on('auth_error', authErrorHandler)
          .on('error', errorHandler)
          .on('heartbeat_ack', () => {});
      }).finally(() => {
        this._creating = null;
      });

      return this._creating;
    },

    // CORRECCIÓN 1: Método para programar reconexión con backoff exponencial
    _scheduleReconnect() {
      if (!this._shouldReconnect || this._disconnectedByServer || this._isReconnecting) {
        console.log('⏸️ Reconexión no permitida');
        return;
      }

      if (this._reconnectTimer) {
        clearTimeout(this._reconnectTimer);
        this._reconnectTimer = null;
      }

      // Cálculo de delay con backoff exponencial (máximo 30 segundos)
      const delay = Math.min(
        this._reconnectBaseDelay * Math.pow(2, this._reconnectAttempts),
        this._reconnectMaxDelay
      );

      console.log(`🔄 Programando reconexión en ${delay}ms (intento ${this._reconnectAttempts + 1})`);

      this._reconnectTimer = setTimeout(() => {
        this._attemptReconnect();
      }, delay);
    },

    // CORRECCIÓN 1: Método para intentar reconexión
    async _attemptReconnect() {
      if (this._isReconnecting) return;

      this._isReconnecting = true;
      this._reconnectAttempts++;

      const authStore = useAuthStore();

      if (!authStore.token) {
        console.log('⏸️ No hay token, deteniendo reconexión');
        this._isReconnecting = false;
        return;
      }

      if (this.socket?.connected) {
        console.log('🔌 Socket ya conectado, cancelando reconexión');
        this._reconnectAttempts = 0;
        this._isReconnecting = false;
        if (this._reconnectTimer) {
          clearTimeout(this._reconnectTimer);
          this._reconnectTimer = null;
        }
        return;
      }

      console.log(`🔄 Intentando reconexión ${this._reconnectAttempts}...`);

      try {
        await this.connectWithToken(authStore.token, authStore.user);
        console.log('✅ Reconexión exitosa');
        this._reconnectAttempts = 0;
      } catch (err) {
        console.error(`❌ Error en reconexión ${this._reconnectAttempts}:`, err.message);
        // Si aún debemos reconectar, programar otro intento
        if (this._shouldReconnect && !this._disconnectedByServer && this._reconnectAttempts < 10) {
          this._scheduleReconnect();
        } else {
          console.log('⏸️ Máximos intentos alcanzados o reconexión deshabilitada');
          this._reconnectAttempts = 0;
        }
      } finally {
        this._isReconnecting = false;
      }
    },

    // ✅ NUEVO: Método para configurar listeners de otros stores
    _setupStoreListeners(socket) {
      const onlineUsersStore = useOnlineUsersStore();
      const notificationStore = useNotificationStore();
      const conversationStore = useConversationStore();

      // Notificaciones - DELEGAR AL NOTIFICATION STORE
      socket.on('new-notification', (notification) => {
        console.log('📢 Notificación recibida:', notification);
        notificationStore.addNotification(notification);
        this.playNotificationSound();
      });

      // Usuarios online - DELEGAR AL ONLINE USERS STORE
      socket.on('users_online', (users) => {
        console.log('👥 Usuarios online actualizados:', users.length);
        onlineUsersStore.setOnlineUsers(users);
      });

      socket.on('user_online', (user) => {
        console.log('👤 Usuario conectado:', user.userId || user.id);
        onlineUsersStore.addOnlineUser(user);
      });

      socket.on('user_offline', (userId) => {
        console.log('🔴 Usuario desconectado:', userId);
        onlineUsersStore.removeOnlineUser(userId);
      });

      // Mensajes - DELEGAR AL CONVERSATION STORE
      socket.on('new_message', (data) => {
        console.log('📨 Nuevo mensaje:', data);
        const normalizedData = this._normalizeEventData(data);

        // CORRECCIÓN 3: Unirse a la sala de la conversación si no está ya unido
        const room = `conversation_${normalizedData.conversation_id}`;
        if (!this._joinedRooms.has(room) && this.socket?.connected) {
          this.joinConversationRoom(normalizedData.conversation_id);
        }

        // Notificar a conversationStore
        if (conversationStore) {
          conversationStore.addMessage(normalizedData);
        }
        // También emitir a handlers de componentes (por compatibilidad)
        this._emitToHandlers('new_message', normalizedData);

        // Reproducir sonido si es necesario
        const authStore = useAuthStore();
        const message = normalizedData.message || normalizedData;
        if (message && message.sender !== authStore.user?.role) {
          this.playNotificationSound();
        }
      });

      socket.on('message_deleted', (data) => {
        console.log('🗑️ Mensaje eliminado:', data);
        const normalizedData = this._normalizeEventData(data);
        if (conversationStore) {
          // 🔥 CORREGIR: Extraer conversation_id y message_id correctamente
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
        console.log('✅ Mensajes leídos:', data);
        const normalizedData = this._normalizeEventData(data);

        if (conversationStore) {
          conversationStore.markMessagesAsRead(normalizedData);
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

      // Confirmaciones de mensajes
      socket.on('message_sent_confirmation', (data) => {
        console.log('✅ Confirmación de mensaje:', data);
        this._pendingConfirmations.delete(data.temp_id);
        if (conversationStore) {
          conversationStore.confirmMessageSent(data);
        }
        this._emitToHandlers('message_sent_confirmation', data);
      });

      // Conexión duplicada
      socket.on('duplicate_connection', (data) => {
        console.warn('⚠️ Conexión duplicada:', data);
        this._shouldReconnect = false;
        this._disconnectedByServer = true;
        this._emitToHandlers('duplicate_connection', data);
      });
    },

    // ✅ NUEVO: Mantener compatibilidad con websocket.js
    // CORRECCIÓN 10: Actualizar sendMessage para usar evento correcto
    sendMessage(conversation_id, message, temp_id = Date.now()) {
      return this.emit('send_message', {
        conversation_id,
        ...message,
        temp_id
      });
    },

    // ✅ NUEVO: Mantener compatibilidad con websocket.js
    sendTyping(conversation_id, receiver_id, receiver_role, is_typing) {
      return this.emit('typing', {
        conversation_id,
        receiver_id,
        receiver_role,
        is_typing
      });
    },

    // ✅ NUEVO: Mantener compatibilidad con websocket.js
    markMessagesRead(messages, conversationWith) {
      return this.emit('message_read', { messages, conversationWith });
    },

    async init() {
      // Prevenir múltiples inicializaciones
      if (this._initialized) {
        console.log('⚠️ SocketStore ya inicializado, omitiendo...');
        return;
      }
      this._initialized = true;

      const authStore = useAuthStore();

      if (!authStore.user && authStore.token && typeof authStore.loadUser === 'function') {
        try {
          await authStore.loadUser();
        } catch (err) {
          console.error('❌ Error al cargar usuario:', err);
        }
      }

      // CORRECCIÓN 1: Mejorar watch del token para evitar reconexiones innecesarias
      if (!this._stopAuthWatch) {
        this._stopAuthWatch = watch(
          () => authStore.token,
          async (newToken, oldToken) => {
            // Si no hay token, desconectar
            if (!newToken) {
              this.disconnect();
              return;
            }

            // Si el token no ha cambiado realmente, no hacer nada
            if (newToken === oldToken) return;

            // Si el socket no existe o no está conectado, conectar
            if (!this.socket || !this.socket.connected) {
              await this.connectWithToken(newToken, authStore.user);
              return;
            }

            // Si ya está conectado, solo actualizar el token
            this.socket.auth.token = newToken;
            this.socket.emit('refresh-token', newToken);
          },
          { immediate: true }
        );
      }

      if (!this._visibilityListenerAdded) {
        const visibilityHandler = async () => {
          // No reconectar si fue desconectado por servidor
          if (!document.hidden && authStore.token && !this.socket?.connected && !this._isDisconnecting && this._shouldReconnect && !this._disconnectedByServer) {
            await this.connectWithToken(authStore.token, authStore.user);
          }
        };
        document.addEventListener('visibilitychange', visibilityHandler);
        this._visibilityListenerAdded = true;
      }

      this.initNotificationSound();
    },

    initNotificationSound() {
      try {
        this.notificationSound = new Audio();
        this.notificationSound.preload = 'auto';
        this.notificationSound.src = '/sounds/notification.mp3';
        this.notificationSound.volume = 0.6;
        console.log('✅ Sonido de notificación inicializado');
      } catch (err) {
        console.warn('⚠️ No se pudo inicializar el sonido:', err);
      }
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
          onlineUsersStore.setOnlineUsers(data.online_users);
        }
      } catch (error) {
        console.error('❌ Error en heartbeat HTTP:', error);
      }
    },

    // Normalizar datos de eventos - CORRECCIÓN: Simplificado
    _normalizeEventData(data) {
      if (!data) return data;

      // CORRECCIÓN: Asegurar que new_message tenga estructura consistente
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

    startHeartbeat() {
      if (this.heartbeatInterval) {
        clearInterval(this.heartbeatInterval);
      }
      this.heartbeatInterval = setInterval(() => {
        if (this.socket?.connected) {
          this.socket.emit('heartbeat');
        }
      }, 30000);
    },

    startHttpHeartbeat() {
      if (this.httpHeartbeatInterval) {
        clearInterval(this.httpHeartbeatInterval);
      }
      setTimeout(() => this.sendHttpHeartbeat(), 1000);
      this.httpHeartbeatInterval = setInterval(() => {
        this.sendHttpHeartbeat();
      }, 60000);
    },

    // CORRECCIÓN 2: Mejorar gestión de handlers para evitar duplicados y limpieza
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
        // Si el socket ya está conectado, registrar el handler directamente
        if (this.socket?.connected) {
          this.socket.on(event, handler);
        }
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
        // Remover del socket si está conectado
        if (this.socket?.connected) {
          this.socket.off(event, handler);
        }
      } else {
        handlers.clear();
        // Remover todos los handlers del socket
        if (this.socket?.connected) {
          this.socket.off(event);
        }
      }
      if (handlers.size === 0) this._componentHandlers.delete(event);
    },

    // CORRECCIÓN 2: Método para limpiar handlers obsoletos
    cleanupHandlers(event, componentId) {
      if (!event) return;

      if (componentId && this._componentHandlers.has(event)) {
        const handlers = this._componentHandlers.get(event);
        // Filtrar handlers que pertenecen al componente específico
        // Nota: Esto requiere que los handlers tengan una propiedad `__componentId`
        for (const handler of handlers) {
          if (handler.__componentId === componentId) {
            handlers.delete(handler);
            if (this.socket?.connected) {
              this.socket.off(event, handler);
            }
          }
        }
        if (handlers.size === 0) {
          this._componentHandlers.delete(event);
        }
      }
    },

    // CORRECCIÓN 2: Limpiar todos los handlers de un componente
    cleanupComponentHandlers(componentId) {
      if (!componentId) return;

      for (const [event, handlers] of this._componentHandlers) {
        for (const handler of handlers) {
          if (handler.__componentId === componentId) {
            handlers.delete(handler);
            if (this.socket?.connected) {
              this.socket.off(event, handler);
            }
          }
        }
        if (handlers.size === 0) {
          this._componentHandlers.delete(event);
        }
      }
    },

    // CORRECCIÓN 8: Proteger emit() si el socket no existe
    emit(event, payload) {
      if (!event || typeof event !== 'string') {
        console.warn('⚠️ Evento inválido para socket.emit()');
        return;
      }

      // CORRECCIÓN 8: Verificar que el socket existe
      if (!this.socket) {
        console.log(`📤 Socket no disponible, encolando evento: ${event}`);
        this._queueEvent(event, payload);
        return;
      }

      // Hacer una copia profunda del payload
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
        // Usar callback para confirmación si es necesario
        if (event === 'send_message') {
          // Guardar para confirmación
          const tempId = safePayload.temp_id || Date.now();
          this._pendingConfirmations.set(tempId, {
            event,
            payload: safePayload,
            timestamp: Date.now()
          });

          // Esperar confirmación por 5 segundos
          setTimeout(() => {
            if (this._pendingConfirmations.has(tempId)) {
              console.warn(`⚠️ No se recibió confirmación para mensaje ${tempId}`);
              this._pendingConfirmations.delete(tempId);
            }
          }, 5000);
        }
        // CORRECCIÓN 5: Añadir callback vacío para forzar confirmación
        this.socket.emit(event, safePayload, () => {});
        console.log(`📤 Evento enviado: ${event}`, safePayload);
      } catch (err) {
        console.error('❌ Error al emitir evento:', err);
        this._queueEvent(event, safePayload);
      }
    },

    // Método auxiliar para encolar eventos
    _queueEvent(event, payload) {
      this._pendingEvents.push({
        event,
        payload,
        timestamp: Date.now(),
        retryCount: 0
      });
      // CORRECCIÓN 6: Reducir límite de cola a 50
      if (this._pendingEvents.length > 50) {
        const dropped = this._pendingEvents.shift();
        console.warn(`🗑️ Evento descartado por cola llena: ${dropped.event}`);
      }
    },

    _flushPendingEvents() {
      // CORRECCIÓN 6: Verificar conexión activa correctamente
      if (!this.socket || !this.socket.connected) {
        console.warn('⚠️ No se pueden flushar eventos: socket no conectado');
        return;
      }
      const now = Date.now();
      const maxAge = 60000;
      const maxRetries = 3;
      const stillPending = [];

      for (const item of this._pendingEvents) {
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

    disconnect() {
      if (this._isDisconnecting) {
        console.warn('⚠️ Desconexión ya en progreso');
        return;
      }

      this._isDisconnecting = true;
      this._pendingEvents = [];
      this._joinedRooms.clear();
      this._pendingConfirmations.clear();

      // CORRECCIÓN 1: Limpiar timer de reconexión
      if (this._reconnectTimer) {
        clearTimeout(this._reconnectTimer);
        this._reconnectTimer = null;
      }
      this._isReconnecting = false;

      if (this.heartbeatInterval) {
        clearInterval(this.heartbeatInterval);
        this.heartbeatInterval = null;
      }

      if (this.httpHeartbeatInterval) {
        clearInterval(this.httpHeartbeatInterval);
        this.httpHeartbeatInterval = null;
      }

      if (this._reconnectTimer) {
        clearTimeout(this._reconnectTimer);
        this._reconnectTimer = null;
      }

      if (this.socket) {
        this.socket.removeAllListeners();
        this.socket.disconnect();
      }

      this.socket = null;
      // CORRECCIÓN 7: No borrar handlers para mantenerlos en reconexión
      // this._componentHandlers.clear(); // Mantener handlers para reconexión
      this._reconnectAttempts = 0;
      this._shouldReconnect = true;
      this._disconnectedByServer = false; // Resetear flag

      if (this._stopAuthWatch) {
        this._stopAuthWatch();
        this._stopAuthWatch = null;
      }

      // Resetear flag de inicialización para permitir reinicialización limpia
      this._initialized = false;

      console.log('🔌 SocketStore desconectado completamente');
      this._isDisconnecting = false;
    },

    // CORRECCIÓN 7: Mejorar reconexión manual
    reconnect() {
      if (this.socket?.connected) {
        console.log('🔌 Socket ya conectado');
        return;
      }

      // Si fue desconectado por servidor, permitir reintentar manualmente
      if (this._disconnectedByServer) {
        console.log('🔄 Intentando reconexión manual después de desconexión por servidor');
        this._disconnectedByServer = false;
        this._shouldReconnect = true;
      }

      // Limpiar timer existente
      if (this._reconnectTimer) {
        clearTimeout(this._reconnectTimer);
        this._reconnectTimer = null;
      }

      const authStore = useAuthStore();
      if (authStore.token) {
        this.connectWithToken(authStore.token, authStore.user);
      }
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

    markMessagesAsRead(conversationId, messageIds) {
      if (!conversationId || !messageIds?.length) {
        console.warn('⚠️ Parámetros inválidos para markMessagesAsRead');
        return;
      }

      // ✅ CORREGIDO: Usar 'message_read' en lugar de 'messages_read'
      this.emit('message_read', {
        conversation_id: conversationId,
        message_ids: messageIds,
        timestamp: new Date().toISOString()
      });
    },

    markMessagesAsDelivered(conversationId, messageIds) {
      if (!conversationId || !messageIds?.length) return;

      // ✅ CORREGIDO: Usar 'message_delivered' en lugar de 'messages_delivered'
      this.emit('message_delivered', {
        conversation_id: conversationId,
        message_ids: messageIds
      });
    },

    // joinConversationRoom mejorado
    joinConversationRoom(conversationId) {
      if (!conversationId) {
        console.warn('⚠️ No se puede unir a sala: conversationId inválido');
        return false;
      }

      const room = `conversation_${conversationId}`;

      // Si el socket no está conectado, guardar para unirse cuando se conecte
      if (!this.socket || !this.socket.connected) {
        console.log(`⏳ Socket no conectado, guardando sala para unirse después: ${room}`);
        this._pendingRooms = this._pendingRooms || new Set();
        this._pendingRooms.add(room);
        return false;
      }

      return new Promise((resolve) => {
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

    // Verificar si está en una sala
    isInRoom(room) {
      return this._joinedRooms.has(room);
    },

    toggleSound(enabled) {
      this._soundEnabled = enabled;
      console.log(`🔊 Sonido ${enabled ? 'activado' : 'desactivado'}`);
    },

    getPendingEventsCount() {
      return this._pendingEvents.length;
    },

    clearPendingEvents() {
      this._pendingEvents = [];
    },

    // Reenviar mensajes pendientes
    resendPendingMessages() {
      this._flushPendingEvents();
    },
  },

  getters: {
    notifications: () => useNotificationStore().notifications,
    unreadCount: () => useNotificationStore().unreadCount,
    // CORRECCIÓN: Eliminado state.connected, usando solo getter
    isConnected: (state) => state.socket?.connected ?? false,
    pendingEvents: (state) => state._pendingEvents,
    reconnectAttempts: (state) => state._reconnectAttempts,
    soundEnabled: (state) => state._soundEnabled,
    // Getter para salas unidas
    joinedRooms: (state) => Array.from(state._joinedRooms),
    // Verificar si está en conversación específica
    isInConversation: (state) => (conversationId) => {
      return state._joinedRooms.has(`conversation_${conversationId}`);
    },
    // Saber si se debe reconectar
    shouldReconnect: (state) => state._shouldReconnect,
    // Saber si fue desconectado por servidor
    disconnectedByServer: (state) => state._disconnectedByServer,
  },
});
