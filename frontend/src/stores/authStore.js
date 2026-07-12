// src/stores/authStore.js
import { defineStore } from 'pinia'
import api from '@/axios'
import Swal from 'sweetalert2'
import router from '@/router'
import { i18n } from '@/i18n'
import { useSocketStore } from './socketStore'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    token: (() => {
      const staffToken = localStorage.getItem('staff_token')
      if (staffToken) return staffToken
      return localStorage.getItem('token') || null
    })(),
    user: (() => {
      const staffToken = localStorage.getItem('staff_token')
      if (staffToken) {
        const staffData = localStorage.getItem('staff')
        try {
          if (staffData) {
            const parsed = JSON.parse(staffData)
            return {
              id: parsed.id,
              name: parsed.name,
              email: parsed.email,
              phone: parsed.phone,
              role: 'staff_' + (parsed.role || 'delivery'),
              provider_id: parsed.provider_id,
              active: parsed.active,
              created_at: parsed.created_at,
              avatar_url: parsed.avatar_url || null,
              is_online: parsed.is_online ?? true  // ✅ Usar valor guardado o true por defecto
            }
          }
        } catch {
          localStorage.removeItem('staff')
        }
        return null
      }

      const stored = localStorage.getItem('user')
      try {
        return stored ? JSON.parse(stored) : null
      } catch {
        localStorage.removeItem('user')
        return null
      }
    })(),
    role: (() => {
      const staffToken = localStorage.getItem('staff_token')
      if (staffToken) {
        const staffData = localStorage.getItem('staff')
        try {
          if (staffData) {
            const parsed = JSON.parse(staffData)
            return 'staff_' + (parsed.role || 'delivery')
          }
        } catch {
          // ignorar
        }
        return 'staff_delivery'
      }
      return localStorage.getItem('role') || null
    })(),
    locale: localStorage.getItem('userLocale') || 'es',
    loading: false,
  }),

  getters: {
    isStaff: (state) => {
      if (localStorage.getItem('staff_token')) return true
      return state.role?.startsWith('staff_') || false
    },

    roleText: (state) => {
      if (!state.role) return 'Usuario'

      if (state.role.startsWith('staff_')) {
        const staffRole = state.role.replace('staff_', '')
        switch (staffRole) {
          case 'delivery': return 'Staff Delivery'
          case 'manager': return 'Staff Manager'
          case 'support': return 'Staff Soporte'
          default: return 'Staff'
        }
      }

      switch (state.role) {
        case 'admin': return 'Administrador'
        case 'provider': return 'Proveedor'
        case 'user': return 'Cliente'
        default: return state.role
      }
    },

    isAuthenticated: (state) => {
      return !!(state.token && state.user)
    }
  },

  actions: {
    _saveAuthData({ token, user, role }) {
      const isStaff = role?.startsWith('staff_') || localStorage.getItem('staff_token')

      if (isStaff) {
        localStorage.setItem('staff_token', token)
        localStorage.setItem('staff', JSON.stringify({
          id: user.id,
          name: user.name,
          email: user.email,
          phone: user.phone,
          role: user.role?.replace('staff_', '') || 'delivery',
          provider_id: user.provider_id,
          active: user.active,
          created_at: user.created_at,
          avatar_url: user.avatar_url || null,
          is_online: user.is_online ?? true  // ✅ Guardar estado online
        }))
        localStorage.removeItem('token')
        localStorage.removeItem('user')
        localStorage.removeItem('role')
      } else {
        localStorage.setItem('token', token)
        localStorage.setItem('user', JSON.stringify(user))
        localStorage.setItem('role', role)
        localStorage.removeItem('staff_token')
        localStorage.removeItem('staff')
      }

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
      localStorage.removeItem('staff_token')
      localStorage.removeItem('staff')
      localStorage.removeItem('userLocale')

      this.setAxiosToken(null)
    },

    _getDependencies() {
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

    async loadFromStorage() {
      const staffToken = localStorage.getItem('staff_token')
      const normalToken = localStorage.getItem('token')
      const token = staffToken || normalToken

      if (token) {
        try {
          this.token = token

          if (staffToken) {
            const staffData = localStorage.getItem('staff')
            if (staffData) {
              const parsed = JSON.parse(staffData)

              // ✅ Intentar obtener estado online real del backend
              let isOnline = parsed.is_online ?? true
              try {
                const { data } = await api.get('/staff/profile', {
                  headers: { Authorization: `Bearer ${staffToken}` }
                })
                if (data?.staff) {
                  // Actualizar localStorage con datos frescos
                  const updatedStaff = {
                    ...parsed,
                    ...data.staff,
                    is_online: data.staff.is_online ?? isOnline
                  }
                  localStorage.setItem('staff', JSON.stringify(updatedStaff))
                  isOnline = data.staff.is_online ?? true
                }
              } catch (err) {
                console.warn('No se pudo obtener perfil de staff del backend, usando datos locales')
              }

              this.user = {
                id: parsed.id,
                name: parsed.name,
                email: parsed.email,
                phone: parsed.phone,
                role: 'staff_' + (parsed.role || 'delivery'),
                provider_id: parsed.provider_id,
                active: parsed.active,
                created_at: parsed.created_at,
                avatar_url: parsed.avatar_url || null,
                is_online: isOnline
              }
              this.role = 'staff_' + (parsed.role || 'delivery')
            }
          } else {
            const user = localStorage.getItem('user')
            if (user) {
              this.user = JSON.parse(user)
              this.role = localStorage.getItem('role')
            }
          }

          this.setAxiosToken(token)
          await this.loadLocale()

          const socketStore = useSocketStore()
          await socketStore.init()
          socketStore.connect(token)

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

        const socketStore = useSocketStore()
        await socketStore.init()
        socketStore.connect(token)

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
        return false
      } finally {
        this.loading = false
      }
    },

    async staffLogin(credentials) {
      this.loading = true
      const { apiInstance, routerInstance, i18nInstance } = this._getDependencies()
      try {
        const res = await apiInstance.post('/provider/staff/login', credentials)
        const { token, staff } = res.data

        if (!token || !staff) {
          throw new Error('Respuesta inválida del servidor al iniciar sesión.')
        }

        // ✅ Construir objeto de usuario para staff con is_online real
        const user = {
          id: staff.id,
          name: staff.name,
          email: staff.email,
          phone: staff.phone,
          role: 'staff_' + (staff.role || 'delivery'),
          provider_id: staff.provider_id,
          active: staff.active,
          created_at: staff.created_at,
          avatar_url: staff.avatar_url || null,
          is_online: staff.is_online ?? true  // ✅ Usar valor del backend
        }

        this._saveAuthData({ token, user, role: user.role })

        const socketStore = useSocketStore()
        await socketStore.init()
        socketStore.connect(token)

        await this.loadLocale()

        const $t = i18nInstance.global.t
        Swal.fire({
          icon: 'success',
          title: $t('success'),
          text: 'Inicio de sesión exitoso',
          timer: 1500,
          showConfirmButton: false,
          willClose: async () => {
            const target = '/delivery/orders'
            if (routerInstance.currentRoute.value.path !== target) {
              await routerInstance.replace(target).catch(() => {})
            }
          },
        })
        return staff
      } catch (error) {
        const $t = i18nInstance.global.t
        Swal.fire(
          $t('error'),
          error.response?.data?.message || error.message || 'Credenciales inválidas',
          'error'
        )
        return false
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

        if (token && token !== this.token) {
          this._saveAuthData({ token, user, role: user?.role || this.role })

          const socketStore = useSocketStore()
          socketStore.disconnect()
          socketStore.connect(token)
        }

        return token || this.token
      } catch (err) {
        console.error('❌ No se pudo refrescar el token:', err)

        if (retries > 0 && (!err.response || err.code === 'ERR_NETWORK')) {
          await new Promise(r => setTimeout(r, 500))
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

          if (this.isStaff) {
            const staffData = JSON.parse(localStorage.getItem('staff') || '{}')
            staffData.locale = locale
            localStorage.setItem('staff', JSON.stringify(staffData))
          } else {
            localStorage.setItem('user', JSON.stringify(this.user))
          }
        }
      } catch (error) {
        console.error('Error al actualizar idioma:', error)
      }
    },

    async updateStaffProfile(profileData) {
      if (!this.isStaff || !this.token) return
      const { apiInstance } = this._getDependencies()
      try {
        const res = await apiInstance.post('/staff/profile/update', profileData, {
          headers: { Authorization: `Bearer ${this.token}` }
        })

        if (res.data.staff) {
          const updatedStaff = res.data.staff
          localStorage.setItem('staff', JSON.stringify(updatedStaff))

          this.user = {
            ...this.user,
            name: updatedStaff.name,
            email: updatedStaff.email,
            phone: updatedStaff.phone,
            avatar_url: updatedStaff.avatar_url || null,
            is_online: updatedStaff.is_online ?? this.user.is_online
          }
        }

        return res.data
      } catch (error) {
        console.error('Error al actualizar perfil de staff:', error)
        throw error
      }
    },

    // ✅ CORREGIDO: Actualizar is_online en localStorage al hacer logout
    async staffLogout() {
      if (!this.isStaff || !this.token) return
      const { apiInstance } = this._getDependencies()
      try {
        await apiInstance.post('/provider/staff/logout', {}, {
          headers: { Authorization: `Bearer ${this.token}` }
        })
      } catch (err) {
        console.error('Error en logout de staff:', err)
      }
    },

    logout() {
      const { routerInstance, i18nInstance } = this._getDependencies()

      const socketStore = useSocketStore()
      socketStore.disconnect()

      const wasStaff = this.isStaff || localStorage.getItem('staff_token')

      // ✅ Si es staff, intentar hacer logout en el backend
      if (wasStaff && this.token) {
        api.post('/provider/staff/logout', {}, {
          headers: { Authorization: `Bearer ${this.token}` }
        }).catch(() => {})
      }

      this._clearAuthData()

      if (i18nInstance?.global) i18nInstance.global.locale.value = 'es'
      document.documentElement.lang = 'es'

      const targetPath = wasStaff ? '/staff/login' : '/login'
      if (routerInstance.currentRoute.value.path !== targetPath) {
        routerInstance.replace(targetPath).catch(() => {})
      }
    },
  },
})

export function initializeAuthStore(dependencies = {}) {
  const auth = useAuthStore()

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
    auth.loadLocale().catch(console.warn)

    const socketStore = useSocketStore()
    socketStore.init().then(() => {
      socketStore.connect(auth.token)
    })
  }

  return auth
}
