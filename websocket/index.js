require('dotenv').config();
const express = require('express');
const { Server } = require('socket.io');
const http = require('http');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const rateLimit = require('express-rate-limit');

const app = express();
app.use(cors({ origin: process.env.CORS_ORIGIN || '*' }));
app.use(express.json({ limit: '50mb' }));

const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: process.env.CORS_ORIGIN || '*',
    methods: ['GET', 'POST'],
  },
  pingInterval: 25000,
  pingTimeout: 60000,
});

const connectedUsers = new Map();
const pendingEvents = new Map();
const MAX_PENDING_EVENTS = 1000;
const PENDING_TTL_MS = 24 * 60 * 60 * 1000;

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
    console.warn(`⚠️  Room ${room} overflow, clearing old events`);
    filtered.splice(0, filtered.length - MAX_PENDING_EVENTS + 1);
  }

  filtered.push({
    event,
    payload: payload || req.body || {},
    timestamp: now
  });
  pendingEvents.set(room, filtered);
}

io.use((socket, next) => {
  const token = socket.handshake.auth?.token || socket.handshake.query?.token;
  if (!token) {
    socket.emit('auth_error', { message: 'No token' });
    return next(new Error('No token'));
  }
  try {
    socket.user = jwt.verify(token, process.env.JWT_SECRET);
    next();
  } catch (err) {
    socket.emit('auth_error', { message: 'Invalid token' });
    next(new Error('Invalid token'));
  }
});

io.on('connection', (socket) => {
  const { id, role } = socket.user;
  const room = `${role}_${id}`;
  socket.join(room);

  const roomSize = io.sockets.adapter.rooms.get(room)?.size || 0;
  console.log(`🔌 Conectado: ${id} (${role}) | Room '${room}' size: ${roomSize}`);

  connectedUsers.set(`${id}_${role}`, socket);

  if (pendingEvents.has(room)) {
    const events = pendingEvents.get(room);
    const now = Date.now();
    const validEvents = events.filter(e => now - e.timestamp < PENDING_TTL_MS);

    for (const ev of validEvents) {
      socket.emit(ev.event, ev.payload);
      console.log('📤 Evento pendiente entregado →', room, ev.event, ev.payload);
    }

    if (validEvents.length > 0) {
      console.log(`🔄 ${validEvents.length} eventos pendientes entregados →`, room);
    }
    pendingEvents.set(room, []);
  }

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

  socket.on('join-room', (roomName) => {
    socket.join(roomName);
    console.log(`✅ Cliente se unió a room adicional: ${roomName}`);
  });

  socket.on('disconnect', (reason) => {
    connectedUsers.delete(`${id}_${role}`);
    console.log(`❌ Desconectado: ${id} (${role}) | Reason: ${reason}`);
  });

  socket.on('error', (err) => {
    console.error(`❌ Socket error para ${id}:`, err.message);
    socket.disconnect(true);
  });
});

app.post('/emit', (req, res) => {
  const { receiver_id, receiver_role, title, message, event, payload } = req.body;
  const room = `${receiver_role}_${receiver_id}`;

  if (event) {
    const socketsInRoom = io.sockets.adapter.rooms.get(room);
    const eventPayload = payload || req.body || {};

    if (socketsInRoom && socketsInRoom.size > 0) {
      io.to(room).emit(event, eventPayload);
      console.log('📡 /emit event entregado en vivo →', room, event, eventPayload);
    } else {
      addPendingEvent(room, event, eventPayload);
      console.log('🕒 /emit event guardado (offline) →', room, event, eventPayload);
    }
  } else {
    const socketsInRoom = io.sockets.adapter.rooms.get(room);
    const notificationPayload = {
      id: Date.now(),
      receiver_id,
      receiver_role,
      title,
      message,
      is_read: 0,
      created_at: new Date().toISOString(),
    };

    if (socketsInRoom && socketsInRoom.size > 0) {
      io.to(room).emit('new-notification', notificationPayload);
      console.log('📡 /emit notification → room:', room, 'title:', title);
    } else {
      addPendingEvent(room, 'new-notification', notificationPayload);
      console.log('🕒 /emit notification guardada (offline) →', room, title);
    }
  }

  console.log("📥 BODY RECIBIDO:", JSON.stringify(req.body, null, 2));
  res.json({ status: 'enviado', room, timestamp: new Date().toISOString() });
});

app.post('/emit-event', (req, res) => {
  const { receiver_id, receiver_role, event, payload } = req.body;

  if (!event) return res.status(400).json({ error: 'Falta event' });

  const room = `${receiver_role}_${receiver_id}`;
  const socketsInRoom = io.sockets.adapter.rooms.get(room);
  const finalPayload = payload || req.body || {};

  if (socketsInRoom && socketsInRoom.size > 0) {
    io.to(room).emit(event, finalPayload);
    console.log('📡 POST /emit-event entregado en vivo →', room, event, finalPayload);
  } else {
    addPendingEvent(room, event, finalPayload);
    console.log('🕒 POST /emit-event guardado (offline) →', room, event, finalPayload);
  }

  res.json({ status: 'enviado', room, timestamp: new Date().toISOString() });
});

const PORT = process.env.PORT || 3001;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 WS server en 0.0.0.0:${PORT}`);
});
