import { defineStore } from 'pinia'
import axios from 'axios'
import Swal from 'sweetalert2'
import router from '@/router'
import { i18n } from '@/i18n' 

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
      axios.defaults.headers.common['Authorization'] = `Bearer ${token}`
    },

    setLocale(locale) {
      this.locale = locale
      localStorage.setItem('userLocale', locale)

      // Actualizar i18n global
      if (i18n && i18n.global) {
        i18n.global.locale.value = locale
      }

      // Actualizar lang attribute en html
      document.documentElement.lang = locale
    },

    loadLocale() {
      const savedLocale = localStorage.getItem('userLocale')
      if (savedLocale) {
        this.locale = savedLocale
        if (i18n && i18n.global) {
          i18n.global.locale.value = savedLocale
        }
      } else {
        // Detectar idioma del navegador
        const browserLocale = navigator.language.substring(0, 2)
        const supportedLocales = ['es', 'en']
        const defaultLocale = supportedLocales.includes(browserLocale) ? browserLocale : 'es'
        this.setLocale(defaultLocale)
      }
      return this.locale
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

        // Usar traducciones de i18n
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

        // Cargar locale del usuario si está disponible
        if (user.locale) {
          this.setLocale(user.locale)
        } else {
          this.loadLocale()
        }

        const $t = i18n.global.t
        Swal.fire({
          icon: 'success',
          title: $t('success'),
          text: $t('login_success'),
          timer: 1500,
          showConfirmButton: false,
          willClose: () => {
            // Redirección por rol
            switch (user.role) {
              case 'admin':
                router.push('/dashboard/admin')
                break
              case 'provider':
                router.push('/dashboard/provider')
                break
              case 'user':
              default:
                router.push('/dashboard/user')
                break
            }
          }
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

    async updateUserLocale(locale) {
      if (!this.token || !this.user) return

      try {
        const res = await axios.post('http://localhost:8000/api/user/locale',
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

      // Resetear idioma al salir
      if (i18n && i18n.global) {
        i18n.global.locale.value = 'es'
      }
      document.documentElement.lang = 'es'

      delete axios.defaults.headers.common['Authorization']
      router.push('/login')
    },

    // Método para inicializar el store con el idioma correcto
    initialize() {
      this.loadLocale()
      this.setAxiosToken(this.token)
    }
  }
})

// Inicializar el store al importar
export function initializeAuthStore() {
  const auth = useAuthStore()
  auth.initialize()
  return auth
}
