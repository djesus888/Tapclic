import axios from 'axios'
import Swal from 'sweetalert2'

// ✅ Tu backend usa /api/ como prefijo
const API_URL = import.meta.env.VITE_API_URL || 'http://192.168.1.248:8000/api'

const api = axios.create({
  baseURL: API_URL,
  timeout: 30000,
  headers: {
    'Accept': 'application/json; charset=utf-8'
  }
})

// Interceptor de respuesta para detectar mantenimiento
api.interceptors.response.use(
  response => response,
  error => {
    if (error.response?.status === 503) {
      window.location.href = '/maintenance'
    }
    return Promise.reject(error)
  }
)

// ✅ Interceptor para token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token') || localStorage.getItem('staff_token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => Promise.reject(error)
)

// ✅ Interceptor de respuesta con UI
api.interceptors.response.use(
  (response) => response,
  (error) => {
    // 📦 Extraer el mensaje del backend
    const backendMessage = error.response?.data?.error || 
                          error.response?.data?.message || 
                          error.response?.data?.msg || 
                          null
    
    const errorCode = error.response?.data?.code || null

    // 🎯 Mostrar el error en pantalla (excepto para 401 que ya tiene su propio manejo)
    if (backendMessage && error.response?.status !== 401) {
      const lang = localStorage.getItem('userLocale') || 'es'
      
      Swal.fire({
        icon: 'error',
        title: lang === 'en' ? 'Error' : 'Error',
        text: backendMessage,
        confirmButtonText: lang === 'en' ? 'Accept' : 'Aceptar',
        confirmButtonColor: '#667eea',
        timer: 5000,
        timerProgressBar: true
      })
    }

    // ===============================
    // ✅ DETECCIÓN REAL DE ERROR DE RED
    // ===============================
    const isNetworkError =
      !error.response &&
      (
        error.code === 'ERR_NETWORK' ||
        error.message?.toLowerCase().includes('network') ||
        !window.navigator.onLine
      )

    if (isNetworkError) {
      let errorMessage = '📡 Sin internet - No tienes conexión a internet'
      let userMessage = 'No tienes conexión a internet. Por favor, verifica tu red.'

      try {
        const savedLocale = localStorage.getItem('userLocale') || 'es'
        if (savedLocale === 'en') {
          errorMessage = '📡 No internet - You are not connected to the internet'
          userMessage = 'You are not connected to the internet. Please check your network.'
        }
      } catch {
        // intencionalmente vacio
      }

      // Mostrar error de red en pantalla
      Swal.fire({
        icon: 'warning',
        title: savedLocale === 'en' ? 'No Internet' : 'Sin Internet',
        text: userMessage,
        confirmButtonText: savedLocale === 'en' ? 'Accept' : 'Aceptar',
        confirmButtonColor: '#667eea'
      })

      // ⚠️ SOLO enriquecemos el error
      error.isNetworkError = true
      error.isOffline = !window.navigator.onLine
      error.userMessage = userMessage
      error.message = errorMessage
    }

    // ===============================
    // ✅ MANEJO 401 MEJORADO
    // ===============================
    if (error.response?.status === 401 && !error.config?.url?.includes('/login')) {
      // ✅ Leer el header personalizado que envió el backend
      const sessionRejected = error.response?.headers?.['x-session-rejected']

      console.log('🔍 Motivo de rechazo de sesión:', sessionRejected)

      // Limpiar almacenamiento local
      localStorage.removeItem('token')
      localStorage.removeItem('user')
      localStorage.removeItem('role')
      localStorage.removeItem('staff_token')

      // ✅ Si la sesión fue reemplazada por otro dispositivo
      if (sessionRejected === 'session_replaced') {
        // Mostrar notificación antes de redirigir
        const lang = localStorage.getItem('userLocale') || 'es'

        Swal.fire({
          icon: 'warning',
          title: lang === 'en' ? 'Session Closed' : 'Sesión cerrada',
          text: lang === 'en'
            ? 'Your session was closed because you logged in on another device.'
            : 'Tu sesión fue cerrada porque iniciaste sesión en otro dispositivo.',
          confirmButtonText: lang === 'en' ? 'Understood' : 'Entendido',
          confirmButtonColor: '#667eea',
          allowOutsideClick: false,
          allowEscapeKey: false
        }).then(() => {
          window.location.href = '/login'
        })

        return new Promise(() => {})
      }

      // ✅ Si no hay sesión activa (sesión expirada o cerrada manualmente)
      if (sessionRejected === 'no_active_session') {
        const lang = localStorage.getItem('userLocale') || 'es'

        Swal.fire({
          icon: 'info',
          title: lang === 'en' ? 'Session Expired' : 'Sesión expirada',
          text: lang === 'en'
            ? 'Your session has expired or was closed. Please log in again.'
            : 'Tu sesión ha expirado o fue cerrada. Por favor, inicia sesión nuevamente.',
          confirmButtonText: lang === 'en' ? 'Login' : 'Iniciar sesión',
          confirmButtonColor: '#667eea',
          allowOutsideClick: false,
          allowEscapeKey: false
        }).then(() => {
          window.location.href = '/login'
        })

        return new Promise(() => {})
      }

      // ✅ Para cualquier otro motivo de 401 (token inválido, blacklist, etc.)
      window.location.href = '/login'
      return new Promise(() => {})
    }

    // 🔴 CLAVE: dejar que Axios propague el error
    return Promise.reject(error)
  }
)

export default api
