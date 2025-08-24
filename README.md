# Tapclic – Plataforma de servicios a domicilio

Stack:
- Backend: PHP 8 + PDO + Firebase JWT
- Frontend Web: Vue 3 + Vite + Tailwind
- Frontend Mobile: Flutter 3
- Tiempo real: Socket.IO

## Instalación rápida
```bash
# Backend
cd backend && composer install && cp .env.example .env

# Frontend
cd frontend && npm install && npm run dev

# WebSocket
cd websocket && npm install && npm start


# Backend
cd backend
cp .env.example .env
composer install

# Frontend
cd ../frontend
cp .env.example .env
npm install

# WebSocket
cd ../websocket
cp .env.example .env
npm install
