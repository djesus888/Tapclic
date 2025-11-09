// src/main.js
import { createApp } from 'vue'
import App from './App.vue'
import './assets/style.css'
import router from './router'
import { createPinia } from 'pinia'
import { i18n } from './i18n'

// 🔔 Notificaciones
import Toast from 'vue-toastification'
import 'vue-toastification/dist/index.css'

// 💬 SweetAlert2
import VueSweetalert2 from 'vue-sweetalert2'
import 'sweetalert2/dist/sweetalert2.min.css'

// Stores
import { useSocketStore } from '@/stores/socketStore.js'
import { useSystemStore } from '@/stores/systemStore.js'
import { useNotificationStore } from '@/stores/notificationStore.js'
import { initializeAuthStore } from '@/stores/authStore.js'

// funciones  de autenticacion
import { checkSession, apiFetch } from './utils/auth.js';
// Inicializar Vue
const app = createApp(App)

// Manejo global de errores
app.config.errorHandler = (err, instance, info) => {
  console.error('>>> ERROR DE VUE:', err.message, '\n', err.stack, '\nInfo:', info)
  app.config.globalProperties.$swal.fire({
    icon: 'error',
    title: 'Error en la aplicación',
    html: `<pre style="text-align:left">${err.message}\n${err.stack || ''}</pre>`,
    width: 600
  })
}

window.addEventListener('error', (e) => {
  console.error('>>> ERROR CAPTURADO:', e.message, '\n', e.error?.stack || e.stack)
  app.config.globalProperties.$swal.fire({
    icon: 'error',
    title: 'Error de JavaScript',
    html: `<pre style="text-align:left">${e.message}\n${e.error?.stack || e.stack}</pre>`,
    width: 600
  })
})

window.addEventListener('unhandledrejection', (e) => {
  console.error('>>> PROMESA RECHAZADA:', e.reason)
  app.config.globalProperties.$swal.fire({
    icon: 'error',
    title: 'Error en Promesa',
    html: `<pre style="text-align:left">${e.reason}</pre>`,
    width: 600
  })
})

// Crear instancia de Pinia
const pinia = createPinia()
app.use(pinia)
app.use(router)
app.use(i18n)
app.use(Toast)
app.use(VueSweetalert2) // ✅ Plugin SweetAlert2 completo

// Eruda (solo desarrollo)
if (import.meta.env.MODE === 'development') {
  const script = document.createElement('script')
  script.src = 'https://cdn.jsdelivr.net/npm/eruda'
  script.onload = () => {
    window.eruda.init()
    console.log('%c🛠️ Eruda cargado y activo', 'color: green; font-weight: bold;')
  }
  document.body.appendChild(script)
}

// Inicializar stores
const authStore = initializeAuthStore()
// 🔒 Verificar token al iniciar la app
checkSession()
const systemStore = useSystemStore()
const socketStore = useSocketStore()
const notificationStore = useNotificationStore()

// Escuchar cuando la app pasa a segundo plano o vuelve
document.addEventListener('visibilitychange', () => {
  if (document.hidden) {
    console.log('😴 App en segundo plano → desconectando WS')
    socketStore.disconnect()
  } else {
    console.log('👀 App activa → reconectando WS')
    if (authStore.token && authStore.user) {
      socketStore.connect(authStore.token, authStore.user)
    }
  }
})

// Inicializar configuración y socket
systemStore.fetchConfig()
  .then(() => {
    socketStore.init()
    app.mount('#app')
  })
  .catch(error => {
    console.error('Error al cargar la configuración:', error)
    app.config.globalProperties.$swal.fire({
      icon: 'error',
      title: 'Error de Inicialización',
      text: 'No se pudo cargar la configuración inicial.',
      width: 600
    })
  })
