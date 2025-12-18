// index.js  (servidor WebSocket) – versión corregida y lista para producción
require('dotenv').config();
const express = require('express');
const { Server } = require('socket.io');
const http = require('http');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const rateLimit = require('express-rate-limit');

const app = express();
app.use(cors({ origin: process.env.CORS_ORIGIN || '*' })); // ✅ explícito
app.use(express.json({ limit: '50mb' }));

const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: process.env.CORS_ORIGIN || '*',
    methods: ['GET', 'POST'],
  },
  pingInterval: 25000,
  pingTimeout: 90000,
});

const connectedUsers = new Map();

// ---------- EVENTOS PENDIENTES (offline) ----------
const pendingEvents = new Map(); 
// key: room (role_id) → value: array de { event, payload }

// ---------- RATE LIMIT para /emit* ----------
const emitLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 min
  max: 120,            // 120 req/min
  message: { error: 'Too many requests' },
  standardHeaders: true,
  legacyHeaders: false,
});
app.use('/emit', emitLimiter);
app.use('/emit-event', emitLimiter);

// ---------- MIDDLEWARE JWT ----------
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

// ---------- SOCKET.IO ----------
io.on('connection', (socket) => {
  const { id, role } = socket.user;
  const room = `${role}_${id}`;
  socket.join(room);

console.log('Room actual:', io.sockets.adapter.rooms.get(room));

  connectedUsers.set(`${id}_${role}`, socket);
  console.log(`🔌 Conectado: ${id} (${role})`);

  // ---------- ENTREGAR EVENTOS PENDIENTES ----------
  if (pendingEvents.has(room)) {
    for (const ev of pendingEvents.get(room)) {
      socket.emit(ev.event, ev.payload);
      console.log('📤 Evento pendiente entregado →', room, ev.event);
    }
    pendingEvents.delete(room);
   console.log('🔄 Eventos pendientes entregados al reconectar →', room);

  }

  // ---------- REFRESH TOKEN ----------
  socket.on('refresh-token', (newToken, callback) => {
    try {
      const user = jwt.verify(newToken, process.env.JWT_SECRET);
      const newRoom = `${user.role}_${user.id}`;
      if (newRoom !== room) {
        socket.leave(room);
        socket.join(newRoom);
      }
      socket.user = user;
      callback({ error: null });
    } catch (err) {
      callback({ error: 'Token inválido' });
    }
  });

socket.on('join-room', (room) => {
  socket.join(room);
  console.log(`✅ Cliente se unió a room: ${room}`);
});

  socket.on('disconnect', (reason) => {
    connectedUsers.delete(`${id}_${role}`);
    console.log(`❌ Desconectado: ${id} (${role})`, reason);
  });
});

// ---------- RUTAS HTTP ----------
app.post('/emit', (req, res) => {
  const { receiver_id, receiver_role, title, message, event, payload } = req.body;
  const room = `${receiver_role}_${receiver_id}`;
  if (event) {
    // ✅ emite evento con nombre
    const socketsInRoom = io.sockets.adapter.rooms.get(room);
    if (socketsInRoom && socketsInRoom.size > 0) {
      io.to(room).emit(event, payload);
      console.log('📡 /emit event entregado en vivo →', room, event, payload);
    } else {
      if (!pendingEvents.has(room)) pendingEvents.set(room, []);
      pendingEvents.get(room).push({ event, payload });
      console.log('🕒 /emit event guardado (offline) →', room, event, payload);
    }
    console.log("📥 BODY RECIBIDO:", req.body);
  } else {
    // notificación clásica
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
      if (!pendingEvents.has(room)) pendingEvents.set(room, []);
      pendingEvents.get(room).push({ event: 'new-notification', payload: notificationPayload });
      console.log('🕒 /emit notification guardada (offline) →', room, title);
    }
  }
  res.json({ status: 'enviado' });
});

app.post('/emit-event', (req, res) => {
  const { receiver_id, receiver_role, event, payload = {} } = req.body;
  if (!event) return res.status(400).json({ error: 'Falta event' });
  const room = `${receiver_role}_${receiver_id}`;
  const socketsInRoom = io.sockets.adapter.rooms.get(room);
  if (socketsInRoom && socketsInRoom.size > 0) {
    io.to(room).emit(event, payload);
    console.log('📡 POST /emit-event entregado en vivo →', room, event, payload);
  } else {
    if (!pendingEvents.has(room)) pendingEvents.set(room, []);
    pendingEvents.get(room).push({ event, payload });
    console.log('🕒 POST /emit-event guardado (offline) →', room, event, payload);
  }
  res.json({ status: 'enviado' });
});

const PORT = process.env.PORT || 3001;
server.listen(PORT, () => {
  console.log(`🚀 WS server en puerto ${PORT}`);
});
