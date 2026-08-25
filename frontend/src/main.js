import { createApp, watch } from 'vue'
import App from './App.vue'
import './assets/style.css'
import router from './router'
import { createPinia } from 'pinia'
import { i18n } from './i18n'
import api from '@/axios'

// 🔔 Notificaciones
import Toast from 'vue-toastification'
import 'vue-toastification/dist/index.css'
import { useFCM } from '@/composables/useFCM'

// 💬 SweetAlert2
import VueSweetalert2 from 'vue-sweetalert2'
import 'sweetalert2/dist/sweetalert2.min.css'
import Swal from 'sweetalert2'

// Stores
import { useSocketStore } from '@/stores/socketStore.js'
import { useSystemStore } from '@/stores/systemStore.js'
import { useNotificationStore } from '@/stores/notificationStore.js'
import { useAuthStore, initializeAuthStore } from '@/stores/authStore.js'

// Crear instancia de Vue
const app = createApp(App)

// Manejo global de errores de Vue
app.config.errorHandler = (err, instance, info) => {
  console.error('>>> ERROR DE VUE:', err.message, '\nInfo:', info)
  if (err.isNetworkError || err.code === 'ERR_NETWORK') return
}

// Errores de JavaScript no capturados
window.addEventListener('error', (e) => {
  if (e.target?.tagName === 'SCRIPT') return
  console.error('>>> ERROR CAPTURADO:', e.message)
})

// ✅ Promesas rechazadas no manejadas
window.addEventListener('unhandledrejection', (e) => {
  const reason = e.reason

  if (reason?.isNetworkError || reason?.code === 'ERR_NETWORK' || reason?.code === 'ECONNABORTED') {
    console.warn('📡 Error de red:', reason.userMessage || reason.message)

    let title = 'Problema de conexión'
    let text = 'No se pudo conectar con el servidor. Verifica tu conexión a internet.'

    try {
      const savedLocale = localStorage.getItem('userLocale') || 'es'
      if (savedLocale === 'en') {
        title = 'Connection problem'
        text = 'Could not connect to the server. Please check your internet connection.'
      }
    } catch {}

    if (!Swal.isVisible()) {
      Swal.fire({
        icon: 'warning',
        title: title,
        text: text,
        confirmButtonText: 'Entendido',
        confirmButtonColor: '#667eea',
        toast: true,
        position: 'top-end',
        showConfirmButton: false,
        timer: 4000,
      })
    }

    e.preventDefault()
    return
  }

  console.error('>>> PROMESA RECHAZADA:', reason?.message || reason)
  e.preventDefault()
})

// Crear Pinia y usar plugins
const pinia = createPinia()
app.use(pinia)
app.use(router)
app.use(i18n)
app.use(Toast)
app.use(VueSweetalert2)

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

// ============================================================
// ✅ LÓGICA CENTRALIZADA: Inicialización de stores y socket
// ============================================================

// 🔥 CORRECCIÓN 1: Obtener stores UNA SOLA VEZ
const authStore = useAuthStore()
const socketStore = useSocketStore()
const systemStore = useSystemStore()
const notificationStore = useNotificationStore()

// 🔥 CORRECCIÓN 2: Flag para evitar inicializaciones múltiples
let _initializing = false
let _initialized = false

// 🔥 CORRECCIÓN 3: Inicialización protegida contra múltiples llamadas
async function initializeApp() {
  // Evitar inicialización múltiple simultánea
  if (_initializing) {
    console.log('⏳ Inicialización ya en progreso, esperando...')
    // Esperar a que termine la inicialización actual
    return new Promise((resolve) => {
      const checkInterval = setInterval(() => {
        if (!_initializing) {
          clearInterval(checkInterval)
          resolve(_initialized)
        }
      }, 100)
    })
  }

  // Si ya está inicializado, no hacer nada
  if (_initialized) {
    console.log('✅ App ya inicializada')
    return true
  }

  _initializing = true

  try {
    await authStore.loadFromStorage()

    if (!authStore.token || !authStore.user) {
      console.log('⏸️ No hay sesión activa, saltando inicialización')
      _initialized = false
      return false
    }
    // 🔥 OPTIMIZACIÓN: Ejecutar en paralelo las operaciones independientes
    const tasks = []

    if (!notificationStore._initialized) {
      tasks.push(notificationStore.initialize().catch(err => console.warn("Notificaciones:", err.message)))
    }

    if (!socketStore.isConnected && !socketStore._creating) {
      tasks.push(socketStore.connect(authStore.token).catch(err => console.warn("Socket:", err.message)))
    } else if (socketStore._creating) {
      tasks.push(socketStore._creating)
    }

    tasks.push(systemStore.fetchConfig().catch(err => console.warn("Config:", err.message)))

    await Promise.allSettled(tasks)
    console.log("✅ Operaciones paralelas completadas")
    _initialized = true
    console.log('✅ App inicializada correctamente')
    return true

  } catch (err) {
    console.warn('⚠️ Error en inicialización:', err.message)
    _initialized = false
    return false
  } finally {
    _initializing = false
  }
}

// 🔥 INICIALIZAR AL CARGAR LA APP (solo una vez)
await initializeApp()

// 🔥 CORRECCIÓN 6: Escuchar cambios de token SIN debounce para respuesta inmediata
watch(
  () => authStore.token,
  async (newToken, oldToken) => {
    // Si el token no cambió realmente, ignorar
    if (newToken === oldToken) return

    if (newToken) {
      console.log('🔑 Token actualizado, inicializando app...')
      
      // Resetear flags para permitir reinicialización
      _initialized = false
      _initializing = false
      
      // 🔥 CORRECCIÓN CRÍTICA: Conectar socket inmediatamente
      if (!socketStore.isConnected && !socketStore._creating) {
        console.log('🔌 Conectando socket con nuevo token...')
        socketStore.connect(newToken).catch(err => {
          console.warn('⚠️ Error al conectar socket:', err)
        })
      }
      
      // Inicializar resto de la app en paralelo
      await initializeApp()
    } else {
      console.log('🔌 Sesión cerrada, socket desconectado')
      socketStore.disconnect?.()
      notificationStore._initialized = false
      notificationStore.notifications = []
      _initialized = false
    }
  },
  { immediate: false } // No ejecutar inmediatamente, solo en cambios
)

// ============================================================
// ✅ LISTENERS GLOBALES DE EVENTOS
// ============================================================

// Toast de notificaciones
window.addEventListener('show-notification-toast', (e) => {
  const { title, message } = e.detail
  Swal.fire({
    icon: 'info',
    title,
    text: message,
    toast: true,
    position: 'top-end',
    showConfirmButton: false,
    timer: 4000,
  })
})

// 🔥 CORRECCIÓN 7: Usar la MISMA instancia de socketStore para todos los eventos
// Eliminar socketStore2 y usar socketStore directamente

// ✅ Escuchar evento open_rating_modal desde WebSocket
socketStore.on('open_rating_modal', (data) => {
  console.log('⭐ Modal de calificación desde WebSocket:', data)
  window.dispatchEvent(new CustomEvent('open-rating-modal', {
    detail: {
      request_id: data.request_id || (data.url || '').split('/').pop(),
      targetRole: authStore.user?.role === 'provider' ? 'user' : 'provider',
      from_role: data.from_role || 'provider',
      message: data.message || '¿Quieres calificar este servicio?'
    }
  }))
})

// ✅ Modal de rating
window.addEventListener('open-rating-modal', async (e) => {
  try {
    const { request_id, targetRole: eventTargetRole, from_role } = e.detail
    if (!authStore.token) return

    await new Promise(resolve => setTimeout(resolve, 1500))

    const { data } = await api.get(`/history/by-request/${request_id}`, {
      headers: { Authorization: `Bearer ${authStore.token}` },
    }).catch(() => ({ data: null }))

    const historyId = data?.history?.id || data?.history_id || data?.id

    if (!historyId) {
      console.warn('⚠️ No se encontró history_id para request:', request_id)
      Swal.fire('Aún no disponible', 'El servicio no está listo para reseñas.', 'info')
      return
    }

    const { value: confirmed } = await Swal.fire({
      icon: 'info',
      title: 'Califica el servicio',
      text: e.detail.message,
      showCancelButton: true,
      confirmButtonText: 'Abrir calificación',
      cancelButtonText: 'Ahora no',
    })

    if (!confirmed) return

    const div = document.createElement('div')
    div.id = `modal-${Date.now()}`
    document.body.appendChild(div)

    const { default: ReviewComp } = await import('@/components/ReviewModal.vue')
    const { createApp } = await import('vue')

    const targetRole = authStore.user?.role === 'provider' ? 'user' : 'provider'

    const appModal = createApp(ReviewComp, {
      serviceHistoryId: historyId,
      authToken: authStore.token,
      targetRole: targetRole,
      mode: 'new',
      onClose: () => {
        appModal.unmount()
        const el = document.getElementById(div.id)
        if (el) el.remove()
      },
      onSave: (payload) => {
        console.log('Reseña guardada:', payload)
        appModal.unmount()
        const el = document.getElementById(div.id)
        if (el) el.remove()
        Swal.fire('¡Gracias!', 'Tu reseña ha sido guardada.', 'success')
      },
    })

    appModal.mount(div)
  } catch (err) {
    console.error('Error en modal de rating:', err)
    Swal.fire('Error', 'No se pudo abrir el modal de calificación.', 'error')
  }
})

// Pago actualizado
window.addEventListener('payment-updated', (e) => {
  const { amount, status, request_id } = e.detail
  Swal.fire({
    icon: 'success',
    title: 'Pago actualizado',
    text: `Solicitud ${request_id}: ${status} (${amount})`,
    toast: true,
    position: 'top-end',
    showConfirmButton: false,
    timer: 4000,
  })
})

// ============================================================
// ✅ DETECCIÓN DE CONEXIÓN EN TIEMPO REAL
// ============================================================

window.addEventListener('online', () => {
  console.log('🌐 Conexión restaurada')
  
  // 🔥 CORRECCIÓN: Intentar reconectar socket al restaurar conexión
  if (authStore.token && !socketStore.isConnected && !socketStore._creating) {
    console.log('🔌 Reconectando socket...')
    socketStore.connect(authStore.token).catch(err => {
      console.warn('⚠️ Error al reconectar socket:', err)
    })
  }
  
  Swal.fire({
    icon: 'success',
    title: '¡Conectado!',
    text: 'La conexión a internet se ha restaurado.',
    toast: true,
    position: 'top-end',
    showConfirmButton: false,
    timer: 3000,
    timerProgressBar: true,
  })
})

window.addEventListener('offline', () => {
  console.log('📡 Sin conexión a internet')
  Swal.fire({
    icon: 'warning',
    title: 'Sin conexión',
    text: 'Has perdido la conexión a internet. Algunas funciones no estarán disponibles.',
    toast: true,
    position: 'top-end',
    showConfirmButton: false,
    timer: 5000,
    timerProgressBar: true,
  })
})

// ============================================================
// ✅ MONTAR APP
// ============================================================

// Firebase Cloud Messaging
try {
  const { requestPermission, onNotification } = useFCM()
  requestPermission().catch(() => {})
  onNotification((payload) => {
    console.log("📲 Notificación FCM recibida:", payload)
  })
} catch (e) {
  console.log("🔕 FCM no disponible")
}

app.mount('#app')
