import { defineStore } from 'pinia'
import axios from 'axios'
import Swal from 'sweetalert2'
import router from '@/router'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    token: localStorage.getItem('token') || null,
    user: (() => {
      const stored = localStorage.getItem('user')
      try {
        return stored ? JSON.parse(stored) : null
      } catch {
        return null
      }
    })(),
    role: localStorage.getItem('role') || null,
    loading: false,
  }),

  actions: {
    setAxiosToken(token) {
      axios.defaults.headers.common['Authorization'] = `Bearer ${token}`
    },

    async register(credentials) {
      this.loading = true
      try {
        const res = await axios.post('http://localhost:8000/api/register', credentials)
        const { token, user } = res.data

        if (!token || !user || !user.role) {
          throw new Error('Respuesta inválida del servidor al registrar.')
        }

        this.token = token
        this.user = user
        this.role = user.role

        localStorage.setItem('token', token)
        localStorage.setItem('user', JSON.stringify(user))
        localStorage.setItem('role', user.role)

        this.setAxiosToken(token)

        Swal.fire('Éxito', 'Registro exitoso', 'success')

        return user
      } catch (error) {
        Swal.fire(
          'Error',
          error.response?.data?.message || error.message || 'No se pudo registrar el usuario',
          'error'
        )
        throw error
      } finally {
        this.loading = false
      }
    },

    async login(credentials) {
      this.loading = true
      try {
        const res = await axios.post('http://localhost:8000/api/login', credentials)
        const { token, user } = res.data

        if (!token || !user || !user.role) {
          throw new Error('Respuesta inválida del servidor al iniciar sesión.')
        }

        this.token = token
        this.user = user
        this.role = user.role

        localStorage.setItem('token', token)
        localStorage.setItem('user', JSON.stringify(user))
        localStorage.setItem('role', user.role)

        this.setAxiosToken(token)

        Swal.fire('Éxito', 'Inicio de sesión correcto', 'success')

        // Redirección por rol
        switch (user.role) {
          case 'admin':
            router.push('/dashboard/admin')
            break
          case 'driver':
            router.push('/dashboard/driver')
            break
          case 'user':
          default:
            router.push('/dashboard/user')
            break
        }

      } catch (error) {
        Swal.fire(
          'Error',
          error.response?.data?.message || error.message || 'Credenciales inválidas',
          'error'
        )
        throw error
      } finally {
        this.loading = false
      }
    },

    logout() {
      this.token = null
      this.user = null
      this.role = null

      localStorage.removeItem('token')
      localStorage.removeItem('user')
      localStorage.removeItem('role')
      delete axios.defaults.headers.common['Authorization']

      router.push('/login')
    }
  }
})
