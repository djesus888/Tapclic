require('dotenv').config();
const express = require('express');
const { Server } = require('socket.io');
const http = require('http');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const rateLimit = require('express-rate-limit');

const app = express();

// Configuración UTF-8 para tildes
app.use(express.json({
  limit: '50mb',
  type: 'application/json'
}));

// Middleware para forzar UTF-8 en todas las respuestas
app.use((req, res, next) => {
  res.setHeader('Content-Type', 'application/json; charset=utf-8');
  next();
});

// CORS con origen específico
app.use(cors({
  origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
  credentials: true
}));

const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
    methods: ['GET', 'POST'],
    credentials: true
  },
  pingInterval: 25000,
  pingTimeout: 60000,
  transports: ['websocket', 'polling']
});

// Mapa de sockets por usuario
const userSockets = new Map();
const pendingEvents = new Map();
const typingUsers = new Map();

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

// ✅ CORREGIDO: Función helper para generar userKey de forma consistente
// Usa un delimitador que no aparece en roles (:: en lugar de _)
function buildUserKey(id, role) {
  return `${role}::${id}`;
}

// ✅ CORREGIDO: Función helper para parsear userKey
function parseUserKey(key) {
  const separatorIndex = key.indexOf('::');
  if (separatorIndex === -1) {
    // Fallback para claves antiguas con _
    const parts = key.split('_');
    return { role: parts[0], id: parts.slice(1).join('_') };
  }
  return {
    role: key.substring(0, separatorIndex),
    id: key.substring(separatorIndex + 2)
  };
}

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
    payload: payload || reqBody || {},
    timestamp: now
  });
  pendingEvents.set(room, filtered);
}

// Middleware de autenticación con más validación
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
  // ✅ CORREGIDO: Usar buildUserKey para consistencia
  const userKey = buildUserKey(id, role);
  const room = `${role}_${id}`;

  // Manejo de conexiones duplicadas - CERRAR CONEXIÓN VIEJA
  if (userSockets.has(userKey)) {
    console.log(`⚠️ Conexión duplicada para ${userKey}, cerrando conexión vieja`);
    const oldSocket = userSockets.get(userKey);
    oldSocket.disconnect(true);
    userSockets.delete(userKey);
  }

  // Guardar socket
  userSockets.set(userKey, socket);
  socket.join(room);
  const roomSize = io.sockets.adapter.rooms.get(room)?.size || 0;
  console.log(`🔌 Conectado: ${id} (${role}) | UserKey: ${userKey} | Room '${room}' size: ${roomSize}`);

  // ✅ Unirse a sala de rol para broadcast
  const roleRoom = `role_${role}`;
  socket.join(roleRoom);
  console.log(`🔌 ${id} también unido a sala de rol: ${roleRoom}`);

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

  // Manejar typing con mejor validación
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

    let targetRoom;
    if (receiver_id && receiver_role) {
      targetRoom = `${receiver_role}_${receiver_id}`;
    } else {
      targetRoom = `conversation_${conversation_id}`;
    }

    const typingKey = `${conversation_id}_${id}`;

    if (typingUsers.has(typingKey)) {
      const existing = typingUsers.get(typingKey);
      if (existing.timeout) {
        clearTimeout(existing.timeout);
      }
    }

    if (is_typing) {
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
        timeout
      });
    } else {
      typingUsers.delete(typingKey);
    }

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

  // ✅ CORREGIDO: message_read y message_delivered SOLO reenvían al conversation_room
  // El backend ya notifica a los remitentes individualmente vía HTTP → emitToUser
  // Estos listeners son para cuando un cliente emite directamente (legacy support)
  socket.on('message_read', (data) => {
    const { conversation_id, message_ids } = data;

    if (!conversation_id || !message_ids || !Array.isArray(message_ids) || message_ids.length === 0) {
      console.error('❌ Datos de message_read incompletos o inválidos:', data);
      return;
    }

    const conversationRoom = `conversation_${conversation_id}`;
    io.to(conversationRoom).emit('message_read', {
      conversation_id: conversation_id,
      message_ids: message_ids,
      user_id: id,
      user_role: role,
      timestamp: Date.now()
    });

    console.log(`👁️ Mensajes marcados como leídos: ${message_ids.length} mensajes en conversación ${conversation_id} por ${role}:${id}`);
  });

  socket.on('message_delivered', (data) => {
    const { conversation_id, message_ids } = data;

    if (!conversation_id || !message_ids || !Array.isArray(message_ids) || message_ids.length === 0) {
      console.error('❌ Datos de message_delivered incompletos o inválidos:', data);
      return;
    }

    const conversationRoom = `conversation_${conversation_id}`;
    io.to(conversationRoom).emit('message_delivered', {
      conversation_id: conversation_id,
      message_ids: message_ids,
      user_id: id,
      user_role: role,
      timestamp: Date.now()
    });

    console.log(`📬 Mensajes marcados como entregados: ${message_ids.length} mensajes en conversación ${conversation_id} por ${role}:${id}`);
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

  socket.on('join-room', (roomName, callback) => {
    try {
      if (!roomName.startsWith('conversation_')) {
        console.error(`❌ Intento de unirse a sala no permitida: ${roomName}`);
        if (callback && typeof callback === 'function') {
          callback({ success: false, error: 'Room inválida' });
        }
        return;
      }

      socket.join(roomName);
      console.log(`✅ Cliente ${userKey} se unió a room: ${roomName}`);

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
      console.log(`👋 Cliente ${userKey} salió de room: ${roomName}`);

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

  socket.on('mark_notification_read', (data) => {
    const { notification_id } = data;
    if (notification_id) {
      console.log(`✅ Notificación ${notification_id} marcada como leída por ${userKey}`);
    }
  });

  socket.on('disconnect', (reason) => {
    // ✅ CORREGIDO: Usar el userKey del closure para eliminar correctamente
    if (userSockets.get(userKey) === socket) {
      userSockets.delete(userKey);
      console.log(`🗑️ Socket eliminado de userSockets: ${userKey}`);
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

    console.log(`❌ Desconectado: ${userKey} | Reason: ${reason}`);
  });

  socket.on('error', (err) => {
    console.error(`❌ Socket error para ${userKey}:`, err.message);
  });
});

// ✅ CORREGIDO: Endpoint /emit con soporte para broadcast_role
app.post('/emit', (req, res) => {
  res.setHeader('Content-Type', 'application/json; charset=utf-8');

  const {
    receiver_id,
    receiver_role,
    title,
    message,
    event,
    payload,
    conversation_id,
    room,
    broadcast_role
  } = req.body;

  console.log("📥 [EMIT] BODY RECIBIDO:", JSON.stringify({
    event,
    receiver_id,
    receiver_role,
    broadcast_role,
    room,
    conversation_id,
    hasPayload: !!payload,
    hasTitle: !!title,
    hasMessage: !!message
  }));

  if (event && typeof event !== 'string') {
    return res.status(400).json({ error: 'Invalid event' });
  }

  // Usar Set para evitar salas duplicadas
  const rooms = new Set();

  // Soporte para broadcast_role (emitToRole)
  if (broadcast_role) {
    const roleRoom = `role_${broadcast_role}`;
    rooms.add(roleRoom);
    console.log(`📢 [EMIT] Broadcast a rol: ${roleRoom}`);
  }

  if (receiver_id && receiver_role) {
    rooms.add(`${receiver_role}_${receiver_id}`);
  }
  if (conversation_id) {
    rooms.add(`conversation_${conversation_id}`);
  }
  if (room) {
    rooms.add(room);
  }

  if (rooms.size === 0) {
    console.error('❌ [EMIT] No se pudo determinar sala destino');
    return res.status(400).json({
      error: 'Se requiere receiver_id/receiver_role, broadcast_role, conversation_id o room'
    });
  }

  if (event) {
    const eventPayload = {
      ...(payload || {}),
      conversation_id: conversation_id || payload?.conversation_id || null
    };

    const roomsArray = Array.from(rooms);

    roomsArray.forEach(room => {
      const socketsInRoom = io.sockets.adapter.rooms.get(room);

      if (socketsInRoom && socketsInRoom.size > 0) {
        io.to(room).emit(event, eventPayload);
        console.log(`📡 [EMIT] Evento '${event}' entregado en vivo → ${room} (${socketsInRoom.size} sockets)`);
      } else {
        addPendingEvent(room, event, eventPayload);
        console.log(`🕒 [EMIT] Evento '${event}' guardado (offline) → ${room}`);
      }
    });

    // SOLO enviar notificación tradicional si hay title Y message
    if (title && message) {
      const notificationPayload = {
        id: Date.now(),
        receiver_id,
        receiver_role,
        title,
        message,
        is_read: 0,
        created_at: new Date().toISOString(),
      };

      roomsArray.forEach(room => {
        const socketsInRoom = io.sockets.adapter.rooms.get(room);

        if (socketsInRoom && socketsInRoom.size > 0) {
          io.to(room).emit('new-notification', notificationPayload);
          console.log(`📡 [EMIT] Notificación → ${room}: ${title}`);
        } else {
          addPendingEvent(room, 'new-notification', notificationPayload);
          console.log(`🕒 [EMIT] Notificación guardada (offline) → ${room}: ${title}`);
        }
      });
    }
  }

  res.json({
    status: 'enviado',
    rooms: Array.from(rooms),
    timestamp: new Date().toISOString()
  });
});

app.post('/emit-event', (req, res) => {
  res.setHeader('Content-Type', 'application/json; charset=utf-8');

  const { receiver_id, receiver_role, event, conversation_id } = req.body;

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

  const finalPayload = {
    ...(req.body.payload || req.body || {}),
    conversation_id: conversation_id || req.body.payload?.conversation_id || null
  };

  rooms.forEach(room => {
    const socketsInRoom = io.sockets.adapter.rooms.get(room);

    if (socketsInRoom && socketsInRoom.size > 0) {
      io.to(room).emit(event, finalPayload);
      console.log('📡 POST /emit-event entregado en vivo →', { room, event });
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

// ✅ CORREGIDO: Endpoint /status usa parseUserKey
app.get('/status', (req, res) => {
  res.setHeader('Content-Type', 'application/json; charset=utf-8');
  const usersOnline = Array.from(userSockets.keys()).map(key => {
    const parsed = parseUserKey(key);
    return { id: parseInt(parsed.id), role: parsed.role };
  });

  res.json({
    status: 'online',
    timestamp: Date.now(),
    connections: userSockets.size,
    users_online: usersOnline,
    typing_users: typingUsers.size,
    pending_events: pendingEvents.size,
    active_sockets: userSockets.size
  });
});

// Limpieza periódica de eventos pendientes (cada 10 minutos)
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
