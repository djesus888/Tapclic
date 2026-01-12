// src/axios.js - CONFIGURADO PARA TU BACKEND
import axios from 'axios'

// ✅ Tu backend usa /api/ como prefijo
const API_URL = import.meta.env.VITE_API_URL || 'http://192.168.1.248:8000/api'

// ✅ Axios ya incluye /api/ en todas las llamadas
const api = axios.create({
  baseURL: API_URL, // Ejemplo: http://192.168.31.53:8000/api
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
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

// ✅ Interceptor para 401
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error.response?.status === 401) {
      console.warn('⚠️ Token inválido')
      localStorage.removeItem('token')
      localStorage.removeItem('user')
      localStorage.removeItem('role')
      window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)

export default api
