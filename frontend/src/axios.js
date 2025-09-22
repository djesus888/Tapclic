import axios from 'axios'

// Detectar si es producción o local
const isLocal = window?.location?.hostname === 'localhost'

// Crear instancia de Axios con baseURL dinámica
const api = axios.create({
  baseURL: isLocal
    ? 'http://localhost:8000/api' // ✅ FIX aquí
    : 'https://api.tapclic.com/api',
  withCredentials: true // Si usas JWT, cookies o sesiones
})

// 🔐 Añadir token automáticamente si existe
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

export default api
