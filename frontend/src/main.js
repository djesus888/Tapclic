// src/main.js
import { createApp } from 'vue'
import App from './App.vue'
import './assets/style.css'
import router from './router'
import { createPinia } from 'pinia'
import { i18n } from './i18n'
import Swal from 'sweetalert2'

// Importar stores
import { useSocketStore } from '@/stores/socketStore.js'
import { useSystemStore } from '@/stores/systemStore.js'
import { useNotificationStore } from '@/stores/notificationStore.js'
import { initializeAuthStore } from '@/stores/authStore.js'

// Inicializar Vue
const app = createApp(App)

// Manejo global de errores
app.config.errorHandler = (err, instance, info) => {
  console.error('>>> ERROR DE VUE:', err.message, '\n', err.stack, '\nInfo:', info)
  Swal.fire({
    icon: 'error',
    title: 'Error en la aplicación',
    html: `<pre style="text-align:left">${err.message}\n${err.stack || ''}</pre>`,
    width: 600
  })
}
window.addEventListener('error', (e) => {
  console.error('>>> ERROR CAPTURADO:', e.message, '\n', e.error?.stack || e.stack)
  Swal.fire({
    icon: 'error',
    title: 'Error de JavaScript',
    html: `<pre style="text-align:left">${e.message}\n${e.error?.stack || ''}</pre>`,
    width: 600
  })
})
window.addEventListener('unhandledrejection', (e) => {
  console.error('>>> PROMISE RECHAZADA:', e.reason)
  Swal.fire({
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
app.config.globalProperties.$swal = Swal

// Eruda para desarrollo
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
const authStore = initializeAuthStore() // 🔑 token ya disponible
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
    socketStore.init() // ahora authStore.token ya está cargado
    app.mount('#app')
  })
  .catch(error => {
    console.error('Error al cargar la configuración:', error)
    Swal.fire({
      icon: 'error',
      title: 'Error de Inicialización',
      text: 'No se pudo cargar la configuración inicial.',
      width: 600
    })
  })
