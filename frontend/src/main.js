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

// Manejo global de errores
app.config.errorHandler = (err, instance, info) => {
  console.error('>>> ERROR DE VUE:', err.message, '\n', err.stack, '\nInfo:', info)
  app.config.globalProperties.$swal?.fire({
    icon: 'error',
    title: 'Error en la aplicación',
    html: `<pre style="text-align:left">${err.message}\n${err.stack || ''}</pre>`,
    width: 600,
  })
}

window.addEventListener('error', (e) => {
  console.error('>>> ERROR CAPTURADO:', e.message, '\n', e.error?.stack || e.stack)
  app.config.globalProperties.$swal?.fire({
    icon: 'error',
    title: 'Error de JavaScript',
    html: `<pre style="text-align:left">${e.message}\n${e.error?.stack || e.stack}</pre>`,
    width: 600,
  })
})

window.addEventListener('unhandledrejection', (e) => {
  console.error('>>> PROMESA RECHAZADA:', e.reason)

  // ✅ Mostrar mensaje según idioma para errores de red
  if (e.reason?.isNetworkError) {
    let title = 'Problema de conexión'
    try {
      const savedLocale = localStorage.getItem('userLocale') || 'es'
      if (savedLocale === 'en') {
        title = 'Connection problem'
      }
    } catch {}

    app.config.globalProperties.$swal?.fire({
      icon: 'warning',
      title: title,
      text: e.reason.message,
      confirmButtonText: 'OK',
      width: 400,
    })
    return
  }

  app.config.globalProperties.$swal?.fire({
    icon: 'error',
    title: 'Error en Promesa',
    html: `<pre style="text-align:left">${e.reason}</pre>`,
    width: 600,
  })
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
const authStore = initializeAuthStore()
const socketStore = useSocketStore()
const systemStore = useSystemStore()
const notificationStore = useNotificationStore()

// ✅ Activa el listener visibilitychange
socketStore.init()

// ✅ INICIALIZACIÓN PRINCIPAL (solo con token válido)
async function initializeApp() {
  await authStore.loadFromStorage()

  if (!authStore.token || !authStore.user) {
    console.log('⏸️ No hay sesión activa, saltando inicialización')
    return false
  }

  try {
    if (!notificationStore._initialized) {
      await notificationStore.initialize()
      console.log('📬 Notificaciones inicializadas')
    }

    if (!socketStore.isConnected && !socketStore._creating) {
      await socketStore.connect(authStore.token, authStore.user)
      console.log('🔌 Socket conectado en main.js')
    }

    await systemStore.fetchConfig()

    return true
  } catch (err) {
    console.warn('⚠️ Error en inicialización:', err.message)
    return false
  }
}

// 🔥 INICIALIZAR AL CARGAR LA APP
initializeApp()

// Escuchar cambios de token (login/logout)
watch(
  () => authStore.token,
  async (newToken) => {
    if (newToken) {
      await initializeApp()
    } else {
      socketStore.disconnect?.()
      notificationStore._initialized = false
      notificationStore.notifications = []
      console.log('🔌 Sesión cerrada, socket desconectado')
    }
  }
)

// ============================================================
// ✅ LISTENERS GLOBALES DE EVENTOS
// ============================================================

// Toast de notificaciones
window.addEventListener('show-notification-toast', (e) => {
  const { title, message } = e.detail
  app.config.globalProperties.$swal?.fire({
    icon: 'info',
    title,
    text: message,
    toast: true,
    position: 'top-end',
    showConfirmButton: false,
    timer: 4000,
  })
})


// ✅ Escuchar evento open_rating_modal desde WebSocket
const socketStore2 = useSocketStore()
socketStore2.on('open_rating_modal', (data) => {
  console.log('⭐ Modal de calificación desde WebSocket:', data)
  window.dispatchEvent(new CustomEvent('open-rating-modal', {
    detail: {
      request_id: data.request_id || (data.url || '').split('/').pop(),
      targetRole: data.target_role || (authStore.user?.role === 'provider' ? 'user' : 'provider'),
      from_role: data.from_role || 'provider',
      message: data.message || '¿Quieres calificar este servicio?'
    }
  }))
})


// ✅ CORREGIDO: Modal de rating - ahora busca history_id correctamente
window.addEventListener('open-rating-modal', async (e) => {
  try {
    const { request_id, targetRole: eventTargetRole, from_role } = e.detail
    if (!authStore.token) return

    // ✅ CORREGIDO: Obtener el history_id desde la respuesta correcta
    const { data } = await api.get(`/history/by-request/${request_id}`, {
      headers: { Authorization: `Bearer ${authStore.token}` },
    }).catch(() => ({ data: null }))

    // ✅ CORREGIDO: El endpoint devuelve { success: true, history: { id, ... } }
    const historyId = data?.history?.id || data?.history_id || data?.id

    if (!historyId) {
      console.warn('⚠️ No se encontró history_id para request:', request_id, 'Respuesta:', data)
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

    // ✅ Determinar targetRole según quién califica
    const targetRole = eventTargetRole || (from_role === 'provider' ? 'user' : 'provider')

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
  app.config.globalProperties.$swal?.fire({
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
// ✅ MONTAR APP
// ============================================================
app.mount('#app')

// Configuración inicial
systemStore.fetchConfig().catch((err) => {
  console.warn('Error fetching config:', err)
})
