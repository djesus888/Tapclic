require('dotenv').config()
const express = require('express')
const { Server } = require('socket.io')
const http = require('http')
const cors = require('cors')
const jwt = require('jsonwebtoken')

const app = express()
app.use(cors())
app.use(express.json()) // ← antes de las rutas

const server = http.createServer(app)
const io = new Server(server, {
  cors: { origin: '*', methods: ['GET', 'POST'] }
})

const connectedUsers = new Map()

// ---------- MIDDLEWARE JWT ----------
io.use((socket, next) => {
  const token = socket.handshake.auth.token
  if (!token) return next(new Error('No token'))
  try {
    const user = jwt.verify(token, process.env.JWT_SECRET)
    socket.user = user
    next()
  } catch {
    next(new Error('Invalid token'))
  }
})

// ---------- SOCKET.IO ----------
io.on('connection', (socket) => {
  const { id, role } = socket.user
  console.log(`🔌 Usuario conectado: ${id} (${role})`)
  const room = `${role}_${id}`
  socket.join(room)
  connectedUsers.set(`${id}_${role}`, socket)

  // Escucha CUALQUIER evento y lo re-envía a la sala correspondiente
  socket.onAny((event, payload) => {
    if (event === 'join-room') return // ya lo manejamos
    // Ejemplo: status_changed, location_update, etc.
    if (payload?.receiver_id && payload?.receiver_role) {
      const targetRoom = `${payload.receiver_role}_${payload.receiver_id}`
      io.to(targetRoom).emit(event, payload)
    } else {
      // Si no trae destinatario, reenviamos a la sala del emisor
      socket.to(room).emit(event, payload)
    }
  })

  socket.on('join-room', (r) => socket.join(r))

  socket.on('disconnect', () => {
    connectedUsers.delete(`${id}_${role}`)
    console.log(`❌ Usuario desconectado: ${id} (${role})`)
  })
})

// ---------- RUTAS HTTP ----------
// 1. Notificaciones (ya existente)
app.post('/emit', (req, res) => {
  const { receiver_id, receiver_role, title, message } = req.body
  const room = `${receiver_role}_${receiver_id}`
  io.to(room).emit('new-notification', {
    id: Date.now(),
    receiver_id,
    receiver_role,
    title,
    message,
    is_read: 0,
    created_at: new Date().toISOString()
  })
  res.json({ status: 'enviado' })
})

// 2. Evento genérico (opcional) – mismo formato que antes
app.post('/emit-event', (req, res) => {
  const { receiver_id, receiver_role, event, payload = {} } = req.body
  if (!event) return res.status(400).json({ error: 'Falta event' })
  const room = `${receiver_role}_${receiver_id}`
  io.to(room).emit(event, { ...payload, receiver_id, receiver_role })
  res.json({ status: 'enviado' })
})

server.listen(process.env.PORT, () => {
  console.log(`🚀 WebSocket server en puerto ${process.env.PORT}`)
})
