// src/stores/authStore.js
import { defineStore } from 'pinia'
import axios from 'axios'
import Swal from 'sweetalert2'
import router from '@/router'
import { i18n } from '@/i18n'

const API_URL = import.meta.env.VITE_API_URL
axios.defaults.baseURL = API_URL

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
    locale: localStorage.getItem('userLocale') || 'es',
    loading: false,
  }),

  actions: {
    setAxiosToken(token) {
      if (token) {
        axios.defaults.headers.common['Authorization'] = `Bearer ${token}`
      } else {
        delete axios.defaults.headers.common['Authorization']
      }
    },

    setLocale(locale) {
      this.locale = locale
      localStorage.setItem('userLocale', locale)

      if (i18n?.global) {
        i18n.global.locale.value = locale
      }
      document.documentElement.lang = locale
    },

    loadLocale() {
      const savedLocale = localStorage.getItem('userLocale')
      if (savedLocale) {
        this.setLocale(savedLocale)
      } else {
        const browserLocale = navigator.language.substring(0, 2)
        const supported = ['es', 'en']
        const defaultLocale = supported.includes(browserLocale) ? browserLocale : 'es'
        this.setLocale(defaultLocale)
      }
      return this.locale
    },

    async register(credentials) {
      this.loading = true
      try {
        const res = await axios.post('/api/register', credentials)
        const { token, user } = res.data
        if (!token || !user || !user.role) throw new Error('Respuesta inválida del servidor al registrar.')

        if (token === this.token && JSON.stringify(user) === JSON.stringify(this.user)) {
          return user
        }

        this.token = token
        this.user = user
        this.role = user.role

        localStorage.setItem('token', token)
        localStorage.setItem('user', JSON.stringify(user))
        localStorage.setItem('role', user.role)

        this.setAxiosToken(token)

        const $t = i18n.global.t
        Swal.fire($t('success'), $t('registration_success'), 'success')

        return user
      } catch (error) {
        const $t = i18n.global.t
        Swal.fire(
          $t('error'),
          error.response?.data?.message || error.message || $t('registration_failed'),
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
        const res = await axios.post('/api/login', credentials)
        const { token, user } = res.data
        if (!token || !user || !user.role) throw new Error('Respuesta inválida del servidor al iniciar sesión.')

        if (token === this.token && JSON.stringify(user) === JSON.stringify(this.user)) {
          return
        }

        this.token = token
        this.user = user
        this.role = user.role

        localStorage.setItem('token', token)
        localStorage.setItem('user', JSON.stringify(user))
        localStorage.setItem('role', user.role)

        this.setAxiosToken(token)
        user.locale ? this.setLocale(user.locale) : this.loadLocale()

        const $t = i18n.global.t
        Swal.fire({
          icon: 'success',
          title: $t('success'),
          text: $t('login_success'),
          timer: 1500,
          showConfirmButton: false,
          willClose: async () => {
            // ✅ Redirección segura, sin duplicar navegación
            const target =
              user.role === 'admin'
                ? '/dashboard/admin'
                : user.role === 'provider'
                ? '/dashboard/provider'
                : '/dashboard/user'

            if (router.currentRoute.value.path !== target) {
              await router.replace(target)
            }
          },
        })
      } catch (error) {
        const $t = i18n.global.t
        Swal.fire(
          $t('error'),
          error.response?.data?.message || error.message || $t('invalid_credentials'),
          'error'
        )
        throw error
      } finally {
        this.loading = false
      }
    },

    async refreshToken() {
      try {
        const res = await axios.post('/api/refresh-token', {}, {
          headers: { Authorization: `Bearer ${this.token}` },
        })
        const { token, user } = res.data
        if (token === this.token) return token

        this.token = token
        this.user = user

        localStorage.setItem('token', token)
        localStorage.setItem('user', JSON.stringify(user))
        this.setAxiosToken(token)

        return token
      } catch (err) {
        console.error('❌ No se pudo refrescar el token:', err)
        this.logout()
        throw err
      }
    },

    async updateUserLocale(locale) {
      if (!this.token || !this.user) return
      try {
        const res = await axios.post(
          '/api/user/locale',
          { locale },
          { headers: { Authorization: `Bearer ${this.token}` } }
        )

        if (res.data.success) {
          this.setLocale(locale)
          this.user.locale = locale
          localStorage.setItem('user', JSON.stringify(this.user))
        }
      } catch (error) {
        console.error('Error al actualizar idioma:', error)
      }
    },

    logout() {
      this.token = null
      this.user = null
      this.role = null
      this.locale = 'es'

      localStorage.removeItem('token')
      localStorage.removeItem('user')
      localStorage.removeItem('role')
      localStorage.removeItem('userLocale')

      this.setAxiosToken(null)

      if (i18n?.global) {
        i18n.global.locale.value = 'es'
      }
      document.documentElement.lang = 'es'

      // ✅ Redirección única al login
      const current = router.currentRoute.value.path
      if (current !== '/login') {
        router.replace('/login').catch(() => {})
      }
    },
  },
})

// ✅ Inicialización consistente del store
export function initializeAuthStore() {
  const auth = useAuthStore()
  if (auth.token) {
    auth.setAxiosToken(auth.token)
    auth.loadLocale()
  }
  return auth
}
