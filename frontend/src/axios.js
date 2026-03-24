import axios from 'axios'

// ✅ Tu backend usa /api/ como prefijo
const API_URL = import.meta.env.VITE_API_URL || 'http://192.168.1.248:8000/api'

const api = axios.create({
  baseURL: API_URL,
  timeout: 30000,
  headers: {
  'Content-Type': 'application/json; charset=utf-8',
  'Accept': 'application/json; charset=utf-8'
  }
})

// ✅ Interceptor para token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => Promise.reject(error)
)

// ✅ Interceptor de respuesta
api.interceptors.response.use(
  (response) => response,
  (error) => {
    console.log('🚨 INTERCEPTOR DEBUG:', {
      status: error.response?.status,
      url: error.config?.url,
      data: error.response?.data,
      code: error.code,
      message: error.message
    })

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
      } catch {}

      // ⚠️ SOLO enriquecemos el error
      error.isNetworkError = true
      error.isOffline = !window.navigator.onLine
      error.userMessage = userMessage
      error.message = errorMessage
    }

    // ===============================
    // ✅ MANEJO 401 (sin tocar)
    // ===============================
    if (error.response?.status === 401 && !error.config?.url?.includes('/login')) {
      localStorage.removeItem('token')
      localStorage.removeItem('user')
      localStorage.removeItem('role')
      window.location.href = '/login'
      return new Promise(() => {})
    }

    // 🔴 CLAVE: dejar que Axios propague el error
    return Promise.reject(error)
  }
)

export default api
