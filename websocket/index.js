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
    origin: '*', // o tu frontend exacto
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

  // Guardar socket por id y role
  connectedUsers.set(`${id}_${role}`, socket)

  socket.on('disconnect', () => {
    connectedUsers.delete(`${id}_${role}`)
    console.log(`❌ Usuario desconectado: ${id} (${role})`)
  })
})

// Ruta para emitir notificación desde PHP u otro backend
app.use(express.json())

app.post('/emit', (req, res) => {
  const { receiver_id, receiver_role, title, message } = req.body
  const targetKey = `${receiver_id}_${receiver_role}`
  const socket = connectedUsers.get(targetKey)

  if (socket) {
    socket.emit('new-notification', {
      id: Date.now(), // o real de DB
      receiver_id,
      receiver_role,
      title,
      message,
      is_read: 0,
      created_at: new Date().toISOString()
    })
    return res.json({ status: 'enviado' })
  }

  res.status(404).json({ status: 'usuario no conectado' })
})

server.listen(process.env.PORT, () => {
  console.log(`🚀 WebSocket server en puerto ${process.env.PORT}`)
})
