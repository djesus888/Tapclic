// src/main.js
import { createApp } from 'vue'
import App from './App.vue'
import './assets/style.css'
import router from './router'
import { createPinia } from 'pinia'
import { i18n } from './i18n'
import Swal from 'sweetalert2'

// Inicializar Vue
const app = createApp(App)

// Manejo de errores de Vue
app.config.errorHandler = (err, instance, info) => {
  console.error('>>> ERROR DE VUE:', err.message, '\n', err.stack, '\nInfo:', info)
  Swal.fire({
    icon: 'error',
    title: 'Error en la aplicación',
    html: `<pre style="text-align:left">${err.message}\n${err.stack || ''}</pre>`,
    width: 600
  })
}

// Errores globales JS
window.addEventListener('error', (e) => {
  console.error('>>> ERROR CAPTURADO:', e.message, '\n', e.error?.stack || e.stack)
  Swal.fire({
    icon: 'error',
    title: 'Error de JavaScript',
    html: `<pre style="text-align:left">${e.message}\n${e.error?.stack || ''}</pre>`,
    width: 600
  })
})

// Promesas no manejadas
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

// Importar stores
import { useSocketStore } from '@/stores/socketStore.js'
import { useSystemStore } from '@/stores/systemStore.js'
import { useNotificationStore } from '@/stores/notificationStore.js'

// Propiedades globales
app.config.globalProperties.$swal = Swal

// Usar plugins
app.use(router)
app.use(i18n)

// Eruda desde CDN (solo en desarrollo)
if (import.meta.env.MODE === 'development') {
  const script = document.createElement('script')
  script.src = 'https://cdn.jsdelivr.net/npm/eruda'
  script.onload = () => {
    window.eruda.init()
    console.log('%c🛠️ Eruda cargado y activo', 'color: green; font-weight: bold;')
  }
  document.body.appendChild(script)
}

// Inicializa stores y monta
const systemStore = useSystemStore()
const socketStore = useSocketStore()
const notificationStore = useNotificationStore()

systemStore.fetchConfig().then(() => {
  socketStore.init()
  app.mount('#app')
}).catch(error => {
  console.error('Error al cargar la configuración:', error)
  Swal.fire({
    icon: 'error',
    title: 'Error de Inicialización',
    text: 'No se pudo cargar la configuración inicial.',
    width: 600
  })
})
