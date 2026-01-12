// src/stores/authStore.js - VERSIÓN REFACTORIZADA
import { defineStore } from 'pinia'
import api from '@/axios' // Instancia por defecto
import Swal from 'sweetalert2'
import router from '@/router' // Router por defecto
import { i18n } from '@/i18n' // i18n por defecto

export const useAuthStore = defineStore('auth', {
  state: () => ({
    token: localStorage.getItem('token') || null,
    user: (() => {
      const stored = localStorage.getItem('user')
      try { 
        return stored ? JSON.parse(stored) : null 
      } catch { 
        localStorage.removeItem('user') // Limpieza automática
        return null 
      }
    })(),
    role: localStorage.getItem('role') || null,
    locale: localStorage.getItem('userLocale') || 'es',
    loading: false,
  }),

  actions: {
    // HELPERS PRIVADOS (APIS INTERNA MEJORADA)
    _saveAuthData({ token, user, role }) {
      const data = { token, user: JSON.stringify(user), role }
      Object.entries(data).forEach(([key, value]) => {
        if (value !== undefined && value !== null) {
          localStorage.setItem(key, value)
        }
      })
      this.token = token
      this.user = user
      this.role = role
      this.setAxiosToken(token)
    },

    _clearAuthData() {
      this.token = null
      this.user = null
      this.role = null
      this.locale = 'es'
      localStorage.removeItem('token')
      localStorage.removeItem('user')
      localStorage.removeItem('role')
      localStorage.removeItem('userLocale')
      this.setAxiosToken(null)
    },

    // INYECCIÓN DE DEPENDENCIAS (PARA TESTING)
    _getDependencies() {
      // Permite sobrescribir en tests
      return {
        apiInstance: api,
        routerInstance: router,
        i18nInstance: i18n,
      }
    },

    setAxiosToken(token) {
      const { apiInstance } = this._getDependencies()
      if (token) {
        apiInstance.defaults.headers.common['Authorization'] = `Bearer ${token}`
      } else {
        delete apiInstance.defaults.headers.common['Authorization']
      }
    },

    setLocale(locale) {
      const { i18nInstance } = this._getDependencies()
      this.locale = locale
      localStorage.setItem('userLocale', locale)
      if (i18nInstance?.global) i18nInstance.global.locale.value = locale
      document.documentElement.lang = locale
    },

    async loadLocale() {
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

    // NUEVA ACTION SOLICITADA
    async loadFromStorage() {
      const token = localStorage.getItem('token')
      const user = localStorage.getItem('user')
      
      if (token && user) {
        try {
          this.token = token
          this.user = JSON.parse(user)
          this.role = localStorage.getItem('role')
          this.setAxiosToken(token)
          await this.loadLocale()
        } catch (error) {
          console.warn('⚠️ Datos corruptos en localStorage, limpiando...')
          this._clearAuthData()
        }
      }
    },

    async register(credentials) {
      this.loading = true
      const { apiInstance } = this._getDependencies()
      try {
        const res = await apiInstance.post('/register', credentials)
        const { token, user } = res.data
        if (!token || !user?.role) {
          throw new Error('Respuesta inválida del servidor al registrar.')
        }

        this._saveAuthData({ token, user, role: user.role })

        const { i18nInstance } = this._getDependencies()
        const $t = i18nInstance.global.t
        Swal.fire($t('success'), $t('registration_success'), 'success')
        return user
      } catch (error) {
        const { i18nInstance } = this._getDependencies()
        const $t = i18nInstance.global.t
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
      const { apiInstance, routerInstance, i18nInstance } = this._getDependencies()
      try {
        const res = await apiInstance.post('/login', credentials)
        const { token, user } = res.data
        if (!token || !user?.role) {
          throw new Error('Respuesta inválida del servidor al iniciar sesión.')
        }

        this._saveAuthData({ token, user, role: user.role })
        
        // Carga de locale con await para consistencia
        if (user.locale) {
          this.setLocale(user.locale)
        } else {
          await this.loadLocale()
        }

        const $t = i18nInstance.global.t
        Swal.fire({
          icon: 'success',
          title: $t('success'),
          text: $t('login_success'),
          timer: 1500,
          showConfirmButton: false,
          willClose: async () => {
            const target = user.role === 'admin' ? '/dashboard/admin'
                         : user.role === 'provider' ? '/dashboard/provider'
                         : '/dashboard/user'
            if (routerInstance.currentRoute.value.path !== target) {
              await routerInstance.replace(target).catch(() => {})
            }
          },
        })
      } catch (error) {
        const $t = i18nInstance.global.t
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

    async refreshToken(retries = 1) {
      const { apiInstance } = this._getDependencies()
      try {
        const res = await apiInstance.post('/refresh-token', {}, {
          headers: { Authorization: `Bearer ${this.token}` },
        })
        const { token, user } = res.data
        
        // Solo actualizar si hay cambio
        if (token && token !== this.token) {
          this._saveAuthData({ token, user, role: user?.role || this.role })
        }
        
        return token || this.token
      } catch (err) {
        console.error('❌ No se pudo refrescar el token:', err)
        
        // Lógica de reintento para errores de red
        if (retries > 0 && (!err.response || err.code === 'ERR_NETWORK')) {
          await new Promise(r => setTimeout(r, 500)) // Espera 500ms
          return this.refreshToken(retries - 1)
        }
        
        this.logout()
        throw err
      }
    },

    async updateUserLocale(locale) {
      if (!this.token || !this.user) return
      
      const { apiInstance } = this._getDependencies()
      try {
        const res = await apiInstance.post('/user/locale', { locale }, {
          headers: { Authorization: `Bearer ${this.token}` }
        })
        
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
      const { routerInstance, i18nInstance } = this._getDependencies()
      
      this._clearAuthData()
      
      if (i18nInstance?.global) i18nInstance.global.locale.value = 'es'
      document.documentElement.lang = 'es'

      if (routerInstance.currentRoute.value.path !== '/login') {
        routerInstance.replace('/login').catch(() => {})
      }
    },
  },
})

// INICIALIZACIÓN MEJORADA (MANTIENE MISMA FIRMA PÚBLICA)
export function initializeAuthStore(dependencies = {}) {
  const auth = useAuthStore()
  
  // Permitir inyección de dependencias para tests
  if (Object.keys(dependencies).length > 0) {
    auth._getDependencies = () => ({
      api: api,
      router: router,
      i18n: i18n,
      ...dependencies,
    })
  }

  if (auth.token) {
    auth.setAxiosToken(auth.token)
    // Carga asíncrona sin bloquear
    auth.loadLocale().catch(console.warn)
  }
  
  return auth
}
