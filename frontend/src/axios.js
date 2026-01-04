import axios from 'axios'

// Detectar host real (localhost o IP)
const { protocol, hostname } = window.location

const api = axios.create({
  baseURL: `${protocol}//${hostname}:8000/api`,
  withCredentials: true,
  timeout: 10000
})

// 🔐 Token automático
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
