require('dotenv').config();
const express = require('express');
const { Server } = require('socket.io');
const http = require('http');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const rateLimit = require('express-rate-limit');

const app = express();

// ✅ CORREGIDO: Configuración UTF-8 para tildes
app.use(express.json({
  limit: '50mb',
  type: 'application/json'
}));

// ✅ NUEVO: Middleware para forzar UTF-8 en todas las respuestas
app.use((req, res, next) => {
  res.setHeader('Content-Type', 'application/json; charset=utf-8');
  next();
});

// ✅ CORREGIDO: CORS con origen específico en lugar de '*'
app.use(cors({
  origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
  credentials: true
}));

const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    // ✅ CORREGIDO: CORS con origen específico en lugar de '*'
    origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
    methods: ['GET', 'POST'],
    credentials: true
  },
  pingInterval: 25000,
  pingTimeout: 60000,
  // ✅ CORREGIDO: Transportes permitidos
  transports: ['websocket', 'polling']
});

// ✅ MEJORADO: Un solo mapa de usuarios (eliminado connectedUsers duplicado)
const userSockets = new Map(); // Mapa de sockets por usuario
const pendingEvents = new Map();
const typingUsers = new Map(); // ✅ MEJORADO: Ahora guarda también el timeout

const MAX_PENDING_EVENTS = 1000;
const PENDING_TTL_MS = 24 * 60 * 60 * 1000;
const TYPING_TIMEOUT_MS = 3000;

const emitLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 120,
  message: { error: 'Too many requests' },
  standardHeaders: true,
  legacyHeaders: false,
});

app.use('/emit', emitLimiter);
app.use('/emit-event', emitLimiter);

function addPendingEvent(room, event, payload, reqBody = {}) {
  if (!pendingEvents.has(room)) pendingEvents.set(room, []);
  const roomEvents = pendingEvents.get(room);
  const now = Date.now();
  const filtered = roomEvents.filter(e => now - e.timestamp < PENDING_TTL_MS);

  if (filtered.length >= MAX_PENDING_EVENTS) {
    console.warn(`⚠️ Room ${room} overflow, clearing old events`);
    filtered.splice(0, filtered.length - MAX_PENDING_EVENTS + 1);
  }

  filtered.push({
    event,
    // ✅ CORREGIDO: Usar reqBody en lugar de req.body
    payload: payload || reqBody || {},
    timestamp: now
  });
  pendingEvents.set(room, filtered);
}

// ✅ MEJORADO: Middleware de autenticación con más validación
io.use((socket, next) => {
  const token = socket.handshake.auth?.token || socket.handshake.query?.token;

  if (!token) {
    console.error('❌ No token provided');
    return next(new Error('No token'));
  }

  try {
    socket.user = jwt.verify(token, process.env.JWT_SECRET);

    // Validar que el usuario tiene id y role
    if (!socket.user.id || !socket.user.role) {
      console.error('❌ Token inválido: falta id o role');
      return next(new Error('Invalid token data'));
    }

    next();
  } catch (err) {
    console.error('❌ JWT Error:', err.message);
    next(new Error('Invalid token'));
  }
});

io.on('connection', (socket) => {
  const { id, role } = socket.user;
  const room = `${role}_${id}`;

  // ✅ CORREGIDO: Manejo de conexiones duplicadas - CERRAR CONEXIÓN VIEJA
  const userKey = `${id}_${role}`;

  if (userSockets.has(userKey)) {
    console.log(`⚠️ Conexión duplicada para ${userKey}, cerrando conexión vieja`);
    const oldSocket = userSockets.get(userKey);
    oldSocket.disconnect(true); // cerrar conexión vieja
    userSockets.delete(userKey);
  }

  // ✅ Solo llegamos aquí si la conexión es válida
  userSockets.set(userKey, socket);
  socket.join(room);
  const roomSize = io.sockets.adapter.rooms.get(room)?.size || 0;
  console.log(`🔌 Conectado: ${id} (${role}) | Room '${room}' size: ${roomSize}`);

  // Enviar eventos pendientes al conectar
  if (pendingEvents.has(room)) {
    const events = pendingEvents.get(room);
    const now = Date.now();
    const validEvents = events.filter(e => now - e.timestamp < PENDING_TTL_MS);

    validEvents.forEach(ev => {
      socket.emit(ev.event, ev.payload);
      console.log('📤 Evento pendiente entregado →', room, ev.event);
    });

    if (validEvents.length > 0) {
      console.log(`🔄 ${validEvents.length} eventos pendientes entregados →`, room);
    }

    pendingEvents.set(room, []);
  }

  // ✅ NUEVO: Evento para enviar mensajes
  socket.on('send_message', (data) => {
    try {
      if (!data || !data.conversation_id || !data.message) {
        console.error('❌ Datos de mensaje incompletos:', data);
        socket.emit('error', {
          message: 'Datos de mensaje incompletos',
          temp_id: data?.temp_id
        });
        return;
      }

      // Extraer texto del mensaje de forma segura
      let messageText = '';
      let messageForLog = '';

      if (typeof data.message === 'string') {
        // ✅ CORREGIDO: Preservar UTF-8 sin modificar
        messageText = data.message;
        // Solo para log, tomar los primeros caracteres de forma segura
        messageForLog = messageText.length > 30 ? messageText.substring(0, 30) + '...' : messageText;
      } else if (data.message && typeof data.message === 'object') {
        // Si es objeto, buscar propiedades comunes
        messageText = data.message.text || data.message.content || JSON.stringify(data.message);
        messageForLog = messageText.length > 30 ? messageText.substring(0, 30) + '...' : messageText;
      } else {
        messageText = String(data.message || '');
        messageForLog = messageText.length > 30 ? messageText.substring(0, 30) + '...' : messageText;
      }

      // ✅ CORREGIDO: Asegurar conversation_id
      const messageData = {
        ...data,
        conversation_id: data.conversation_id,
        id: data.id || Date.now(),
        sender_id: id,
        sender_role: role,
        timestamp: data.timestamp || Date.now(),
        status: 'sent',
        // Asegurar que message sea string para el resto del sistema
        message: messageText,
//      text: messageText // Para compatibilidad
      };

      // Enviar a la sala de conversación
      const conversationRoom = `conversation_${data.conversation_id}`;
      io.to(conversationRoom).emit('new_message', messageData);
      console.log(`📨 Mensaje enviado: ${id} → conv_${data.conversation_id}: ${messageForLog}`);

      // Confirmar al remitente
      socket.emit('message_sent_confirmation', {
        ...messageData,
        sender_id: id,
        sender_role: role,
        status: 'delivered_to_server',
        temp_id: data.temp_id
      });

    } catch (error) {
      console.error('❌ Error en send_message:', error);
      socket.emit('error', {
        message: 'Error interno al procesar mensaje',
        temp_id: data?.temp_id
      });
    }
  });

  // ✅ CORREGIDO: Manejar typing con mejor validación Y CONTROL DE TIMEOUTS
  socket.on('typing', (data) => {
    if (!data) {
      console.error('❌ Evento typing recibido sin datos');
      return;
    }

    const { receiver_id, receiver_role, is_typing, conversation_id } = data;

    if (!conversation_id) {
      console.error('❌ Datos de typing incompletos: falta conversation_id');
      return;
    }

    // Determinar la sala destino
    let targetRoom;
    if (receiver_id && receiver_role) {
      targetRoom = `${receiver_role}_${receiver_id}`;
    } else {
      targetRoom = `conversation_${conversation_id}`;
    }

    // ✅ MEJORADO: Gestionar estado de typing con limpieza de timeouts anteriores
    const typingKey = `${conversation_id}_${id}`;

    // Si ya existe un timeout para este usuario, lo cancelamos
    if (typingUsers.has(typingKey)) {
      const existing = typingUsers.get(typingKey);
      if (existing.timeout) {
        clearTimeout(existing.timeout);
      }
    }

    if (is_typing) {
      // Crear nuevo timeout para limpiar el estado automáticamente
      const timeout = setTimeout(() => {
        const current = typingUsers.get(typingKey);
        if (current && Date.now() - current.timestamp >= TYPING_TIMEOUT_MS) {
          typingUsers.delete(typingKey);
          io.to(targetRoom).emit('typing_indicator', {
            conversation_id: conversation_id,
            user_id: id,
            user_role: role,
            is_typing: false,
            timestamp: Date.now()
          });
        }
      }, TYPING_TIMEOUT_MS);

      typingUsers.set(typingKey, {
        userId: id,
        userRole: role,
        conversationId: conversation_id,
        timestamp: Date.now(),
        timeout // Guardamos el timeout para poder cancelarlo después
      });
    } else {
      typingUsers.delete(typingKey);
    }

    // Emitir al destinatario
    io.to(targetRoom).emit('typing_indicator', {
      conversation_id: conversation_id,
      user_id: id,
      user_role: role,
      is_typing: is_typing,
      timestamp: Date.now()
    });

    console.log(`✍️ Typing: ${id} (${role}) → ${targetRoom} : ${is_typing ? 'escribiendo' : 'detenido'}`);
  });

  socket.on('heartbeat', () => {
    socket.emit('heartbeat_ack', { timestamp: Date.now() });
  });

  socket.on('message_read', (data) => {
    const { conversation_id, message_ids } = data;

    if (!conversation_id || !message_ids) {
      console.error('❌ Datos de messages_read incompletos:', data);
      return;
    }

    const conversationRoom = `conversation_${conversation_id}`;
    // ✅ CORREGIDO: Unificar formato con user_id y user_role
    io.to(conversationRoom).emit('message_read', {
      conversation_id: conversation_id,
      message_ids: message_ids,
      user_id: id,
      user_role: role,
      timestamp: Date.now()
    });

    console.log(`👁️ Mensajes marcados como leídos: ${message_ids.length} mensajes en conversación ${conversation_id}`);
  });

  socket.on('message_delivered', (data) => {
    const { conversation_id, message_ids } = data;

    if (!conversation_id || !message_ids) {
      console.error('❌ Datos de messages_delivered incompletos:', data);
      return;
    }

    const conversationRoom = `conversation_${conversation_id}`;
    // ✅ CORREGIDO: Unificar formato con user_id y user_role
    io.to(conversationRoom).emit('message_delivered', {
      conversation_id: conversation_id,
      message_ids: message_ids,
      user_id: id,
      user_role: role,
      timestamp: Date.now()
    });

    console.log(`📬 Mensajes marcados como entregados: ${message_ids.length} mensajes en conversación ${conversation_id}`);
  });

  socket.on('refresh-token', (newToken, callback) => {
    try {
      const user = jwt.verify(newToken, process.env.JWT_SECRET);
      const newRoom = `${user.role}_${user.id}`;

      if (newRoom !== room) {
        socket.leave(room);
        socket.join(newRoom);
        console.log(`🔄 Room cambiado: ${room} → ${newRoom}`);
      }

      socket.user = user;

      if (callback && typeof callback === 'function') {
        callback({ error: null });
      }
    } catch (err) {
      console.error('❌ Error en refresh-token:', err);
      if (callback && typeof callback === 'function') {
        callback({ error: 'Token inválido' });
      } else {
        socket.emit('auth_error', { message: 'Token inválido' });
      }
    }
  });

  // ✅ MEJORADO: Seguridad adicional en join-room
  socket.on('join-room', (roomName, callback) => {
    try {
      // Validar que solo pueda unirse a salas de conversación
      if (!roomName.startsWith('conversation_')) {
        console.error(`❌ Intento de unirse a sala no permitida: ${roomName}`);
        if (callback && typeof callback === 'function') {
          callback({ success: false, error: 'Room inválida' });
        }
        return;
      }

      socket.join(roomName);
      console.log(`✅ Cliente ${id} se unió a room: ${roomName}`);

      if (callback && typeof callback === 'function') {
        callback({ success: true, room: roomName });
      }
    } catch (err) {
      console.error(`❌ Error al unirse a room ${roomName}:`, err);
      if (callback && typeof callback === 'function') {
        callback({ success: false, error: err.message });
      }
    }
  });

  socket.on('leave-room', (roomName, callback) => {
    try {
      socket.leave(roomName);
      console.log(`👋 Cliente ${id} salió de room: ${roomName}`);

      if (callback && typeof callback === 'function') {
        callback({ success: true, room: roomName });
      }
    } catch (err) {
      console.error(`❌ Error al salir de room ${roomName}:`, err);
      if (callback && typeof callback === 'function') {
        callback({ success: false, error: err.message });
      }
    }
  });

  socket.on('disconnect', (reason) => {
    // ✅ CORREGIDO: Limpiar solo si es el socket actual
    if (userSockets.get(userKey) === socket) {
      userSockets.delete(userKey);
    }
    // Limpiar typing con sus timeouts
    for (const [key, value] of typingUsers.entries()) {
      if (value.userId === id) {
        if (value.timeout) {
          clearTimeout(value.timeout);
        }
        typingUsers.delete(key);
      }
    }

    console.log(`❌ Desconectado: ${id} (${role}) | Reason: ${reason}`);
  });

  socket.on('error', (err) => {
    console.error(`❌ Socket error para ${id}:`, err.message);
  });
});

// ✅ MEJORADO: Endpoint /emit con soporte UTF-8 y room directo
app.post('/emit', (req, res) => {
  // Asegurar UTF-8
  res.setHeader('Content-Type', 'application/json; charset=utf-8');

  const { receiver_id, receiver_role, title, message, event, payload, conversation_id, room } = req.body;

  console.log("📥 BODY RECIBIDO:", JSON.stringify(req.body, null, 2));

  // ✅ CORREGIDO: Validación de estructura de payload
  if (event && typeof event !== 'string') {
    return res.status(400).json({ error: 'Invalid event' });
  }

  const rooms = [];
  if (receiver_id && receiver_role) {
    rooms.push(`${receiver_role}_${receiver_id}`);
  }
  if (conversation_id) {
    rooms.push(`conversation_${conversation_id}`);
  }
  // ✅ AGREGADO: Soporte para room directo (como envía PHP)
  if (room) {
    rooms.push(room);
  }

  if (rooms.length === 0) {
    return res.status(400).json({ error: 'Se requiere receiver_id/receiver_role, conversation_id o room' });
  }

  if (event) {
    // ✅ CORREGIDO: Asegurar conversation_id en el payload
    const eventPayload = {
      ...(payload || req.body || {}),
      conversation_id: conversation_id || payload?.conversation_id || null
    };

    rooms.forEach(room => {
      const socketsInRoom = io.sockets.adapter.rooms.get(room);

      if (socketsInRoom && socketsInRoom.size > 0) {
        io.to(room).emit(event, eventPayload);
        console.log('📡 /emit event entregado en vivo →', room, event);
      } else {
        addPendingEvent(room, event, eventPayload);
        console.log('🕒 /emit event guardado (offline) →', room, event);
      }
    });
  } else {
    // Notificación tradicional
    const notificationPayload = {
      id: Date.now(),
      receiver_id,
      receiver_role,
      title,
      message,
      is_read: 0,
      created_at: new Date().toISOString(),
    };

    const targetRoom = `${receiver_role}_${receiver_id}`;
    const socketsInRoom = io.sockets.adapter.rooms.get(targetRoom);

    if (socketsInRoom && socketsInRoom.size > 0) {
      io.to(targetRoom).emit('new-notification', notificationPayload);
      console.log('📡 /emit notification → room:', targetRoom, 'title:', title);
    } else {
      addPendingEvent(targetRoom, 'new-notification', notificationPayload);
      console.log('🕒 /emit notification guardada (offline) →', targetRoom, title);
    }
  }

  res.json({
    status: 'enviado',
    rooms,
    timestamp: new Date().toISOString()
  });
});

app.post('/emit-event', (req, res) => {
  // Asegurar UTF-8
  res.setHeader('Content-Type', 'application/json; charset=utf-8');

  const { receiver_id, receiver_role, event, conversation_id } = req.body;

  // ✅ CORREGIDO: Validación de estructura de payload
  if (event && typeof event !== 'string') {
    return res.status(400).json({ error: 'Invalid event' });
  }

  if (!event) {
    console.error('❌ /emit-event: Falta event');
    return res.status(400).json({ error: 'Falta event' });
  }

  const rooms = [];
  if (receiver_id && receiver_role) {
    rooms.push(`${receiver_role}_${receiver_id}`);
  }
  if (conversation_id) {
    rooms.push(`conversation_${conversation_id}`);
  }

  if (rooms.length === 0) {
    return res.status(400).json({ error: 'Se requiere receiver_id/receiver_role o conversation_id' });
  }

  // ✅ CORREGIDO: Asegurar conversation_id en el payload
  const finalPayload = {
    ...(req.body.payload || req.body || {}),
    conversation_id: conversation_id || req.body.payload?.conversation_id || null
  };

  rooms.forEach(room => {
    const socketsInRoom = io.sockets.adapter.rooms.get(room);

    if (socketsInRoom && socketsInRoom.size > 0) {
      io.to(room).emit(event, finalPayload);
      console.log('📡 POST /emit-event entregado en vivo →', { room, event });
      if (event === 'new_message') {
        console.log('💬 Nuevo mensaje en tiempo real enviado a', room);
      } else if (event === 'typing_indicator') {
        console.log('✍️ Indicador de typing enviado a', room);
      }
    } else {
      addPendingEvent(room, event, finalPayload);
      console.log('🕒 POST /emit-event guardado (offline) →', { room, event });
    }
  });

  res.json({
    status: 'enviado',
    rooms,
    event,
    timestamp: new Date().toISOString()
  });
});

// ✅ CORREGIDO: Endpoint /status actualizado
app.get('/status', (req, res) => {
  res.setHeader('Content-Type', 'application/json; charset=utf-8');
  const usersOnline = Array.from(userSockets.keys()).map(key => {
    const [id, role] = key.split('_');
    return { id: parseInt(id), role };
  });

  res.json({
    status: 'online',
    timestamp: Date.now(),
    connections: userSockets.size, // ✅ Cambiado de connectedUsers a userSockets
    users_online: usersOnline,
    typing_users: typingUsers.size,
    pending_events: pendingEvents.size,
    active_sockets: userSockets.size
  });
});

// ✅ NUEVO: Limpieza periódica de eventos pendientes (cada 10 minutos)
setInterval(() => {
  const now = Date.now();
  let cleanedCount = 0;

  for (const [room, events] of pendingEvents.entries()) {
    const filtered = events.filter(e => now - e.timestamp < PENDING_TTL_MS);

    if (filtered.length === 0) {
      pendingEvents.delete(room);
      cleanedCount++;
    } else if (filtered.length !== events.length) {
      pendingEvents.set(room, filtered);
      cleanedCount++;
    }
  }

  if (cleanedCount > 0) {
    console.log(`🧹 Limpieza de eventos: ${cleanedCount} rooms procesadas`);
  }
}, 600000); // 10 minutos

const PORT = process.env.PORT || 3001;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 WS server en 0.0.0.0:${PORT}`);
});
