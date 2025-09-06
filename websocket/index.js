require('dotenv').config()
const express = require('express')
const { Server } = require('socket.io')
const http = require('http')
const cors = require('cors')
const jwt = require('jsonwebtoken')

const app = express()
app.use(cors())

const server = http.createServer(app)

const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST']
  }
})

const connectedUsers = new Map()

io.use((socket, next) => {
  const token = socket.handshake.auth.token
  if (!token) return next(new Error("No token"))

  try {
    const user = jwt.verify(token, process.env.JWT_SECRET)
    socket.user = user
    next()
  } catch (err) {
    next(new Error("Invalid token"))
  }
})

io.on('connection', (socket) => {
  const { id, role } = socket.user

  console.log(`🔌 Usuario conectado: ${id} (${role})`)

  const room = `${role}_${id}`
  socket.join(room)
  connectedUsers.set(`${id}_${role}`, socket)

  socket.on('join-room', (r) => {
    socket.join(r)
  })

  socket.on('disconnect', () => {
    connectedUsers.delete(`${id}_${role}`)
    console.log(`❌ Usuario desconectado: ${id} (${role})`)
  })
})

app.use(express.json())

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

server.listen(process.env.PORT, () => {
  console.log(`🚀 WebSocket server en puerto ${process.env.PORT}`)
})
