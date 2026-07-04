<template>
  <div class="profile-container">
    <!-- Header Section -->
    <div class="header-section">
      <div class="header-content">
        <h1><span class="icon">👤</span> {{ $t('profile') }}</h1>
        <p>{{ $t('Gestiona tu informacion personal') }}</p>
      </div>
    </div>

    <!-- Main Content -->
    <div class="profile-content">
      <!-- Left Column: Avatar & Info -->
      <div class="profile-left">
        <!-- Avatar Card -->
        <div class="avatar-card">
          <div class="avatar-section">
            <div class="avatar-wrapper">
              <img
                :src="previewAvatar || user?.avatar_url || defaultAvatar"
                :alt="$t('profile.avatarAlt')"
                class="avatar-image"
                @error="handleAvatarError"
              />
              <div class="avatar-overlay">
                <label for="avatar-upload" class="avatar-upload-label">
                  <span class="upload-icon">📷</span>
                  <span class="upload-text">{{ $t('changeAvatar') }}</span>
                </label>
              </div>
            </div>
            <input
              id="avatar-upload"
              type="file"
              accept="image/*"
              class="hidden"
              @change="onAvatarChange"
            />

            <div class="avatar-info">
              <h3 class="avatar-name">{{ form.name || $t('noName') }}</h3>
              <p class="avatar-email">{{ form.email || $t('noEmail') }}</p>
              <div class="avatar-role">
                <span class="role-badge" :class="getRoleClass(user?.role)">
                  {{ getUserRoleLabel(user?.role) }}
                </span>
              </div>
              <div class="avatar-file-info" v-if="avatarFile">
                <div class="file-item">
                  <span class="file-icon">📄</span>
                  <span class="file-name">{{ avatarFile.name }}</span>
                </div>
                <div class="file-size">
                  {{ formatFileSize(avatarFile.size) }}
                </div>
              </div>
              <div class="avatar-file-info" v-else>
                <div class="file-item">
                  <span class="file-icon">ℹ️</span>
                  <span class="file-text">{{ $t('noFileSelected') }}</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Profile Stats -->
          <div class="profile-stats">
            <div class="stat-item">
              <div class="stat-icon">📅</div>
              <div class="stat-content">
                <h3>{{ getMemberSince() }}</h3>
                <p>{{ $t('memberSince') }}</p>
              </div>
            </div>
            <div class="stat-item">
              <div class="stat-icon">✅</div>
              <div class="stat-content">
                <h3>{{ user?.verified ? $t('verified') : $t('pending') }}</h3>
                <p>{{ $t('status') }}</p>
              </div>
            </div>
          </div>
        </div>

        <!-- Preferences Card -->
        <div class="preferences-card">
          <div class="card-header">
            <h3><span class="header-icon">⚙️</span> {{ $t('preferencesSection') }}</h3>
          </div>

          <div class="preferences-content">
            <!-- Language -->
            <div class="preference-item">
              <label class="preference-label">
                <span class="label-icon">🌐</span>
                {{ $t('language') }}
              </label>
              <div class="preference-control">
                <select
                  v-model="pref.language"
                  class="preference-select"
                >
                  <option value="es">
                    <span class="flag-icon">🇪🇸</span> Español
                  </option>
                  <option value="en">
                    <span class="flag-icon">🇺🇸</span> English
                  </option>
                  <option value="pt">
                    <span class="flag-icon">🇵🇹</span> Português
                  </option>
                </select>
              </div>
            </div>

            <!-- Theme -->
            <div class="preference-item">
              <label class="preference-label">
                <span class="label-icon">🎨</span>
                {{ $t('theme') }}
              </label>
              <div class="preference-control">
                <div class="theme-toggle">
                  <button
                    type="button"
                    class="theme-btn light"
                    :class="{ active: !pref.dark }"
                    @click="pref.dark = false"
                  >
                    <span class="theme-icon">☀️</span>
                    <span class="theme-text">{{ $t('light') }}</span>
                  </button>
                  <button
                    type="button"
                    class="theme-btn dark"
                    :class="{ active: pref.dark }"
                    @click="pref.dark = true"
                  >
                    <span class="theme-icon">🌙</span>
                    <span class="theme-text">{{ $t('dark') }}</span>
                  </button>
                </div>
              </div>
            </div>

            <!-- Notifications -->
            <div class="preference-item notifications-item">
              <label class="preference-label">
                <span class="label-icon">🔔</span>
                {{ $t('notifications') }}
              </label>
              <div class="preference-control notifications-control">
                <div class="notification-option">
                  <label class="checkbox-label">
                    <input
                      v-model="pref.notifications.email"
                      type="checkbox"
                      class="checkbox-input"
                      @change="saveNotificationPreferences"
                    />
                    <span class="checkbox-custom"></span>
                    <span class="checkbox-text">
                      <span class="checkbox-icon">📧</span>
                      {{ $t('notifyEmail') }}
                    </span>
                  </label>
                  <button
                    class="btn-notification-action"
                    @click="sendEmailNotification"
                    :disabled="sendingEmail"
                  >
                    <span v-if="sendingEmail" class="loading-spinner-small"></span>
                    <span v-else>📧 Enviar prueba</span>
                  </button>
                </div>
                <div class="notification-option">
                  <label class="checkbox-label">
                    <input
                      v-model="pref.notifications.sms"
                      type="checkbox"
                      class="checkbox-input"
                      @change="saveNotificationPreferences"
                    />
                    <span class="checkbox-custom"></span>
                    <span class="checkbox-text">
                      <span class="checkbox-icon">📱</span>
                      {{ $t('notifySMS') }}
                    </span>
                  </label>
                  <button
                    class="btn-notification-action"
                    @click="sendSMSNotification"
                    :disabled="sendingSMS"
                  >
                    <span v-if="sendingSMS" class="loading-spinner-small"></span>
                    <span v-else>📱 Enviar prueba</span>
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Right Column: Form -->
      <div class="profile-right">
        <!-- Personal Info Card -->
        <div class="form-card">
          <div class="card-header">
            <h3><span class="header-icon">📝</span> {{ $t('personalInfo') }}</h3>
            <p class="card-subtitle">{{ $t('personalInfoSubtitle') }}</p>
          </div>
          <form @submit.prevent="updateProfile" class="form-content">
            <!-- Name -->
            <div class="form-group">
              <label class="form-label">
                <span class="label-icon">👤</span>
                {{ $t('name') }}
                <span class="required">*</span>
              </label>
              <input
                v-model="form.name"
                type="text"
                :placeholder="$t('name')"
                required
                class="form-input"
              />
              <div class="form-hint">{{ $t('nameHint') }}</div>
            </div>

            <!-- Email -->
            <div class="form-group">
              <label class="form-label">
                <span class="label-icon">📧</span>
                {{ $t('email') }}
                <span class="required">*</span>
              </label>
              <input
                v-model="form.email"
                type="email"
                :placeholder="$t('email')"
                required
                class="form-input"
              />
              <div class="form-hint">{{ $t('emailHint') }}</div>
            </div>

            <!-- Phone -->
            <div class="form-group">
              <label class="form-label">
                <span class="label-icon">📱</span>
                {{ $t('phone') }}
                <span class="required">*</span>
              </label>
              <input
                v-model="form.phone"
                type="tel"
                :placeholder="$t('phone')"
                pattern="^[+]?[\d\s\-]{7,15}$"
                :title="$t('phoneInvalid')"
                required
                class="form-input"
              />
              <div class="form-hint">{{ $t('phoneHint') }}</div>
            </div>

            <!-- Address -->
            <div class="form-group">
              <label class="form-label">
                <span class="label-icon">🏠</span>
                {{ $t('address') }}
              </label>
              <input
                v-model="form.address"
                type="text"
                :placeholder="$t('address')"
                class="form-input"
              />
              <div class="form-hint">{{ $t('addressHint') }}</div>
            </div>

            <!-- Business Info (only for admin/provider) -->
            <template v-if="user?.role === 'admin' || user?.role === 'provider'">
              <div class="section-divider">
                <span class="divider-text">{{ $t('professionalInfo') }}</span>
              </div>

              <!-- Business Address -->
              <div class="form-group">
                <label class="form-label">
                  <span class="label-icon">🏢</span>
                  {{ $t('businessAddress') }}
                </label>
                <input
                  v-model="form.business_address"
                  type="text"
                  :placeholder="$t('businessAddress')"
                  class="form-input"
                />
                <div class="form-hint">{{ $t('businessAddressHint') }}</div>
              </div>

              <!-- Service Categories -->
              <div class="form-group">
                <label class="form-label">
                  <span class="label-icon">🏷️</span>
                  {{ $t('serviceCategories') }}
                </label>
                <textarea
                  v-model="form.service_categories"
                  :placeholder="$t('serviceCategoriesPlaceholder')"
                  class="form-textarea"
                  rows="3"
                />
                <div class="form-hint">{{ $t('serviceCategoriesHint') }}</div>
              </div>

              <!-- Coverage Area -->
              <div class="form-group">
                <label class="form-label">
                  <span class="label-icon">🗺️</span>
                  {{ $t('coverageArea') }}
                </label>
                <textarea
                  v-model="form.coverage_area"
                  :placeholder="$t('coverageAreaPlaceholder')"
                  class="form-textarea"
                  rows="3"
                />
                <div class="form-hint">{{ $t('coverageAreaHint') }}</div>
              </div>
            </template>

            <!-- Form Actions -->
            <div class="form-actions">
              <button
                type="button"
                class="btn-secondary"
                @click="resetForm"
                :disabled="loading"
              >
                <span class="btn-icon">↺</span>
                {{ $t('cancel') }}
              </button>
              <button
                type="submit"
                :disabled="loading"
                class="btn-primary"
                :class="{ 'btn-loading': loading }"
              >
                <span v-if="loading" class="loading-spinner"></span>
                <span v-else class="btn-icon">💾</span>
                <span>{{ loading ? $t('profile.saving') : $t('saveChanges') }}</span>
              </button>
            </div>
          </form>
        </div>

        <!-- Security & Privacy Card -->
        <div class="security-card">
          <div class="card-header">
            <h3><span class="header-icon">🔒</span> {{ $t('security') }}</h3>
          </div>
          <div class="security-content">
            <div class="security-item">
              <div class="security-info">
                <span class="security-icon">🔑</span>
                <div class="security-text">
                  <h4>{{ $t('password') }}</h4>
                  <p>{{ $t('lastPasswordUpdate', { date: getLastPasswordUpdate() }) }}</p>
                </div>
              </div>
              <button class="btn-change-password" @click="openChangePasswordModal">
                <span class="btn-icon">✏️</span>
                {{ $t('change') }}
              </button>
            </div>
            <div class="security-item">
              <div class="security-info">
                <span class="security-icon">📱</span>
                <div class="security-text">
                  <h4>{{ $t('connectedDevices') }}</h4>
                  <p>{{ $t('activeDevices', { count: getActiveDevices() }) }}</p>
                </div>
              </div>
              <button class="btn-manage-devices" @click="openDevicesModal">
                <span class="btn-icon">⚙️</span>
                {{ $t('manage') }}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Change Password Modal -->
    <div v-if="showPasswordModal" class="modal-overlay" @click.self="closePasswordModal">
      <div class="modal-container">
        <div class="modal-header">
          <h3>{{ $t('changePassword') }}</h3>
          <button class="modal-close" @click="closePasswordModal">&times;</button>
        </div>
        <form @submit.prevent="changePassword" class="modal-form">
          <div class="form-group">
            <label class="form-label">{{ $t('currentPassword') }} *</label>
            <input
              v-model="passwordForm.current_password"
              type="password"
              required
              class="form-input"
            />
          </div>
          <div class="form-group">
            <label class="form-label">{{ $t('newPassword') }} *</label>
            <input
              v-model="passwordForm.new_password"
              type="password"
              required
              minlength="8"
              class="form-input"
            />
            <div class="form-hint">{{ $t('passwordHint') }}</div>
          </div>
          <div class="form-group">
            <label class="form-label">{{ $t('confirmPassword') }} *</label>
            <input
              v-model="passwordForm.new_password_confirmation"
              type="password"
              required
              minlength="8"
              class="form-input"
            />
          </div>
          <div class="modal-actions">
            <button type="button" class="btn-secondary" @click="closePasswordModal">
              {{ $t('cancel') }}
            </button>
            <button type="submit" class="btn-primary" :disabled="passwordLoading">
              <span v-if="passwordLoading" class="loading-spinner"></span>
              <span v-else>{{ $t('updatePassword') }}</span>
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Devices Modal -->
    <div v-if="showDevicesModal" class="modal-overlay" @click.self="closeDevicesModal">
      <div class="modal-container modal-lg">
        <div class="modal-header">
          <h3>{{ $t('connectedDevices') }}</h3>
          <button class="modal-close" @click="closeDevicesModal">&times;</button>
        </div>
        <div class="modal-body">
          <div v-if="devicesLoading" class="text-center">
            <div class="loading-spinner"></div>
          </div>
          <div v-else>
            <div v-for="device in devices" :key="device.id" class="device-item">
              <div class="device-info">
                <span class="device-icon">📱</span>
                <div class="device-details">
                  <h4>{{ device.name }}</h4>
                  <p>{{ $t('lastActive') }}: {{ device.last_active }}</p>
                  <p>{{ device.location || $t('unknownLocation') }}</p>
                </div>
              </div>
              <div class="device-actions">
                <span v-if="device.is_current" class="device-badge">{{ $t('currentDevice') }}</span>
                <button
                  v-if="!device.is_current"
                  class="btn-danger btn-sm"
                  @click="revokeDevice(device.id)"
                  :disabled="deviceRevoking === device.id"
                >
                  <span v-if="deviceRevoking === device.id" class="loading-spinner"></span>
                  <span v-else>{{ $t('revoke') }}</span>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted, reactive, watch } from 'vue'
import api from '@/axios'
import Swal from 'sweetalert2'
import { useSystemStore } from '@/stores/systemStore'
import { getImageUrl } from '@/utils/imageHelper'
import { useAuthStore } from '@/stores/authStore'
import { useI18n } from 'vue-i18n'

export default {
  name: 'Profile',
  setup() {
    const authStore = useAuthStore()
    const systemStore = useSystemStore()
    const { t, locale } = useI18n()

    const user = ref(null)
    const form = ref({
      name: '',
      email: '',
      phone: '',
      address: '',
      business_address: '',
      service_categories: '',
      coverage_area: '',
      preferences: ''
    })

    const avatarFile = ref(null)
    const previewAvatar = ref(null)
    const defaultAvatar = '/img/default-avatar.png'
    const loading = ref(false)

    // ✅ Detectar si es staff
    const isStaff = ref(false)

    // Preferencias
    const pref = reactive({
      language: 'es',
      dark: false,
      notifications: { email: true, sms: false }
    })

    // Password change
    const showPasswordModal = ref(false)
    const passwordLoading = ref(false)
    const passwordForm = ref({
      current_password: '',
      new_password: '',
      new_password_confirmation: ''
    })

    // Devices
    const showDevicesModal = ref(false)
    const devicesLoading = ref(false)
    const devices = ref([])
    const deviceRevoking = ref(null)

    // Notifications
    const sendingEmail = ref(false)
    const sendingSMS = ref(false)

    // ✅ Detectar tipo de usuario
    const detectUserType = () => {
      // Verificar staff_token en localStorage
      if (localStorage.getItem('staff_token')) {
        isStaff.value = true
        return 'staff'
      }
      // Verificar rol en authStore
      if (authStore.user?.role?.startsWith('staff_')) {
        isStaff.value = true
        return 'staff'
      }
      return 'user'
    }

    const fetchProfile = async () => {
      try {
        const userType = detectUserType()
        
        // Asegurar que la configuración del sistema esté cargada
        if (!systemStore.config) {
          await systemStore.fetchConfig()
        }

        let data
        
        // ✅ Usar endpoint diferente según el tipo de usuario
        if (userType === 'staff') {
          // Endpoint para staff
          const response = await api.get('/staff/profile', {
            headers: { Authorization: `Bearer ${authStore.token}` }
          })
          data = response.data
          // Adaptar respuesta de staff al formato esperado
          user.value = {
            ...data.staff,
            role: 'staff_' + (data.staff?.role || 'delivery'),
            avatar_url: data.staff?.avatar_url || null,
            verified: data.staff?.active === 1,
            created_at: data.staff?.created_at
          }
        } else {
          // Endpoint para usuario normal
          const response = await api.get('/profile', {
            headers: { Authorization: `Bearer ${authStore.token}` }
          })
          data = response.data
          user.value = data.user || {}
        }

        console.log('📸 Datos de perfil cargados:', user.value)
        console.log('📸 avatar_url del backend:', user.value?.avatar_url)

        // Construir URL del avatar usando getImageUrl
        if (user.value.avatar_url && !user.value.avatar_url.startsWith('http')) {
          user.value.avatar_url = getImageUrl(user.value.avatar_url, 'avatar')
          console.log('📸 avatar_url después de getImageUrl:', user.value.avatar_url)
        } else {
          console.log('⚠️ No se procesó avatar_url. Valor:', user.value.avatar_url)
        }

        form.value = {
          name: user.value.name || '',
          email: user.value.email || '',
          phone: user.value.phone || '',
          address: user.value.address || '',
          business_address: user.value.business_address || '',
          service_categories: user.value.service_categories || '',
          coverage_area: user.value.coverage_area || '',
          preferences: user.value.preferences || ''
        }

        if (user.value.preferences) {
          try {
            const p = JSON.parse(user.value.preferences)
            pref.language = p.language || 'es'
            pref.dark = p.dark || false
            pref.notifications.email = p.notifications?.email ?? true
            pref.notifications.sms = p.notifications?.sms ?? false
          } catch (e) {
            console.warn('Preferencias corruptas, se usan valores por defecto')
          }
        }

        // Leer idioma desde localStorage (prioridad)
        const savedLang = localStorage.getItem('userLanguage')
        if (savedLang && ['es', 'en', 'pt'].includes(savedLang)) {
          pref.language = savedLang
        }
        // Cargar preferencias de notificaciones
        await loadNotificationPreferences()
      } catch (err) {
        console.error('Error al obtener perfil:', err)

        if (err.response?.status === 401) {
          authStore.logout()
          window.location.href = isStaff.value ? '/staff/login' : '/login'
        } else {
          Swal.fire({
            icon: 'error',
            title: t('profile.error'),
            text: t('profile.loadFailed'),
            timer: 3000,
            showConfirmButton: true
          })
        }
      }
    }

    const onAvatarChange = (e) => {
      const file = e.target.files[0]
      if (file) {
        if (!file.type.startsWith('image/')) {
          Swal.fire({
            icon: 'error',
            title: 'Error',
            text: t('avatarInvalidType'),
            timer: 3000
          })
          return
        }

        if (file.size > 5 * 1024 * 1024) {
          Swal.fire({
            icon: 'error',
            title: 'Error',
            text: t('avatarTooLarge'),
            timer: 3000
          })
          return
        }

        avatarFile.value = file
        previewAvatar.value = URL.createObjectURL(file)
      } else {
        avatarFile.value = null
        previewAvatar.value = null
      }
    }

    // Cambio de idioma con debounce
    let languageTimeout
    watch(
      () => pref.language,
      (newLang) => {
        clearTimeout(languageTimeout)
        languageTimeout = setTimeout(() => {
          if (['es', 'en', 'pt'].includes(newLang)) {
            localStorage.setItem('userLanguage', newLang)
            locale.value = newLang
          }
        }, 300)
      },
      { immediate: true }
    )

    const updateProfile = async () => {
      loading.value = true
      form.value.preferences = JSON.stringify(pref)

      try {
        const userType = detectUserType()
        const payload = new FormData()
        payload.append('name', form.value.name.trim())
        payload.append('email', form.value.email.trim().toLowerCase())
        payload.append('phone', form.value.phone.trim())
        payload.append('address', form.value.address.trim())
        
        if (!isStaff.value) {
          payload.append('business_address', form.value.business_address.trim())
          payload.append('service_categories', form.value.service_categories.trim())
          payload.append('coverage_area', form.value.coverage_area.trim())
        }
        
        payload.append('preferences', form.value.preferences)

        if (avatarFile.value) {
          payload.append('avatar', avatarFile.value)
        }

        // ✅ Usar endpoint diferente según el tipo de usuario
        const endpoint = userType === 'staff' ? '/staff/profile/update' : '/profile/update'
        
        const response = await api.post(endpoint, payload, {
          headers: {
            Authorization: `Bearer ${authStore.token}`,
            'Content-Type': 'multipart/form-data'
          }
        })

        if (response.data.token) {
          authStore.setToken(response.data.token)
        }

        await Swal.fire({
          icon: 'success',
          title: t('profile.successTitle'),
          text: t('profile.successMessage'),
          timer: 2000,
          showConfirmButton: false,
          position: 'top-end',
          toast: true,
          background: '#f8f9fa'
        })

        await fetchProfile()
        avatarFile.value = null
        previewAvatar.value = null
      } catch (err) {
        console.error('Error al actualizar perfil:', err)

        let message = t('profile.updateFailed')
        if (err.response?.data?.errors) {
          message = Object.values(err.response.data.errors).flat().join(', ')
        } else if (err.response?.data?.error) {
          message = err.response.data.error
        }

        Swal.fire({
          icon: 'error',
          title: t('profile.error'),
          text: message,
          confirmButtonText: t('ok'),
          timer: 5000
        })
      } finally {
        loading.value = false
      }
    }

    // Password Management
    const openChangePasswordModal = () => {
      passwordForm.value = {
        current_password: '',
        new_password: '',
        new_password_confirmation: ''
      }
      showPasswordModal.value = true
    }

    const closePasswordModal = () => {
      showPasswordModal.value = false
    }

    const changePassword = async () => {
      if (passwordForm.value.new_password !== passwordForm.value.new_password_confirmation) {
        Swal.fire({
          icon: 'error',
          title: t('error'),
          text: t('passwordsDoNotMatch'),
          timer: 3000
        })
        return
      }

      if (passwordForm.value.new_password.length < 8) {
        Swal.fire({
          icon: 'error',
          title: t('error'),
          text: t('passwordTooShort'),
          timer: 3000
        })
        return
      }

      passwordLoading.value = true

      try {
        const endpoint = isStaff.value ? '/staff/change-password' : '/profile/change-password'
        
        await api.post(endpoint, passwordForm.value, {
          headers: { Authorization: `Bearer ${authStore.token}` }
        })

        await Swal.fire({
          icon: 'success',
          title: t('success'),
          text: t('passwordChanged'),
          timer: 2000
        })

        closePasswordModal()
      } catch (err) {
        console.error('Error al cambiar contraseña:', err)

        let message = t('passwordChangeFailed')
        if (err.response?.data?.error) {
          message = err.response.data.error
        } else if (err.response?.data?.message) {
          message = err.response.data.message
        }

        Swal.fire({
          icon: 'error',
          title: t('error'),
          text: message,
          confirmButtonText: t('ok')
        })
      } finally {
        passwordLoading.value = false
      }
    }

    // Devices Management
    const openDevicesModal = async () => {
      showDevicesModal.value = true
      await fetchDevices()
    }

    const closeDevicesModal = () => {
      showDevicesModal.value = false
    }

    const fetchDevices = async () => {
      devicesLoading.value = true
      try {
        const { data } = await api.get('/profile/devices', {
          headers: { Authorization: `Bearer ${authStore.token}` }
        })
        devices.value = data.devices || []
      } catch (err) {
        console.error('Error al obtener dispositivos:', err)
        Swal.fire({
          icon: 'error',
          title: t('error'),
          text: t('devicesLoadFailed'),
          timer: 3000
        })
      } finally {
        devicesLoading.value = false
      }
    }

    const revokeDevice = async (deviceId) => {
      const result = await Swal.fire({
        icon: 'warning',
        title: t('confirmRevoke'),
        text: t('revokeDeviceWarning'),
        showCancelButton: true,
        confirmButtonText: t('yesRevoke'),
        cancelButtonText: t('cancel')
      })

      if (!result.isConfirmed) return

      deviceRevoking.value = deviceId
      try {
        await api.post('/profile/revoke-device', { device_id: deviceId }, {
          headers: { Authorization: `Bearer ${authStore.token}` }
        })

        await Swal.fire({
          icon: 'success',
          title: t('success'),
          text: t('deviceRevoked'),
          timer: 2000
        })

        await fetchDevices()
      } catch (err) {
        console.error('Error al revocar dispositivo:', err)
        Swal.fire({
          icon: 'error',
          title: t('error'),
          text: t('deviceRevokeFailed'),
          timer: 3000
        })
      } finally {
        deviceRevoking.value = null
      }
    }

    // Notifications Management
    const loadNotificationPreferences = async () => {
      try {
        const { data } = await api.get('/notifications/preferences', {
          headers: { Authorization: `Bearer ${authStore.token}` }
        })
        if (data.notifications) {
          pref.notifications.email = data.notifications.email
          pref.notifications.sms = data.notifications.sms
        }
      } catch (err) {
        console.error('Error cargando preferencias:', err)
      }
    }

    const saveNotificationPreferences = async () => {
      try {
        await api.post('/notifications/preferences', {
          email: pref.notifications.email,
          sms: pref.notifications.sms
        }, {
          headers: { Authorization: `Bearer ${authStore.token}` }
        })
      } catch (err) {
        console.error('Error guardando preferencias:', err)
      }
    }

    const sendEmailNotification = async () => {
      if (!form.value.email) {
        Swal.fire({
          icon: 'warning',
          title: 'Sin email',
          text: 'Debes tener un email registrado para enviar notificaciones'
        })
        return
      }

      sendingEmail.value = true
      try {
        await api.post('/notifications/email', {
          to: form.value.email,
          subject: 'Notificación de prueba - TapClic',
          message: 'Esta es una notificación de prueba enviada desde tu perfil.',
          type: 'test'
        }, {
          headers: { Authorization: `Bearer ${authStore.token}` }
        })

        Swal.fire({
          icon: 'success',
          title: 'Email enviado',
          text: 'Revisa tu bandeja de entrada',
          timer: 3000
        })
      } catch (err) {
        Swal.fire({
          icon: 'error',
          title: 'Error',
          text: err.response?.data?.error || 'No se pudo enviar el email'
        })
      } finally {
        sendingEmail.value = false
      }
    }

    const sendSMSNotification = async () => {
      if (!form.value.phone) {
        Swal.fire({
          icon: 'warning',
          title: 'Sin teléfono',
          text: 'Debes tener un teléfono registrado para enviar SMS'
        })
        return
      }

      sendingSMS.value = true
      try {
        await api.post('/notifications/sms', {
          to: form.value.phone,
          message: 'TapClic: Notificación de prueba desde tu perfil.'
        }, {
          headers: { Authorization: `Bearer ${authStore.token}` }
        })

        Swal.fire({
          icon: 'success',
          title: 'SMS enviado',
          text: 'Revisa tu teléfono',
          timer: 3000
        })
      } catch (err) {
        Swal.fire({
          icon: 'error',
          title: 'Error',
          text: err.response?.data?.error || 'No se pudo enviar el SMS'
        })
      } finally {
        sendingSMS.value = false
      }
    }

    // Helper methods
    const getRoleClass = (role) => {
      if (!role) return 'role-default'
      if (role.startsWith('staff_')) return 'role-staff'
      
      const classes = {
        admin: 'role-admin',
        provider: 'role-provider',
        user: 'role-user'
      }
      return classes[role] || 'role-default'
    }

    const getUserRoleLabel = (role) => {
      if (!role) return t('roleUser')
      if (role.startsWith('staff_')) {
        const staffRole = role.replace('staff_', '')
        const labels = {
          delivery: 'Staff Delivery',
          manager: 'Staff Manager',
          support: 'Staff Soporte'
        }
        return labels[staffRole] || 'Staff'
      }
      
      const labels = {
        admin: t('roleAdmin'),
        provider: t('roleProvider'),
        user: t('roleUser')
      }
      return labels[role] || t('roleUser')
    }

    const formatFileSize = (bytes) => {
      if (bytes === 0) return '0 Bytes'
      const k = 1024
      const sizes = ['Bytes', 'KB', 'MB', 'GB']
      const i = Math.floor(Math.log(bytes) / Math.log(k))
      return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
    }

    const getMemberSince = () => {
      if (!user.value?.created_at) return t('na')
      const date = new Date(user.value.created_at)
      return date.toLocaleDateString(pref.language, { year: 'numeric', month: 'short' })
    }

    const getLastPasswordUpdate = () => {
      if (!user.value?.password_updated_at) return t('never')
      const date = new Date(user.value.password_updated_at)
      const days = Math.floor((Date.now() - date) / (1000 * 60 * 60 * 24))

      if (days === 0) return t('today')
      if (days === 1) return t('yesterday')
      return t('daysAgo', { days })
    }

    const getActiveDevices = () => {
      return devices.value.length || 0
    }

    const formatDate = (dateString) => {
      if (!dateString) return t('never')
      const date = new Date(dateString)
      return date.toLocaleString(pref.language)
    }

    const resetForm = () => {
      if (user.value) {
        form.value = {
          name: user.value.name || '',
          email: user.value.email || '',
          phone: user.value.phone || '',
          address: user.value.address || '',
          business_address: user.value.business_address || '',
          service_categories: user.value.service_categories || '',
          coverage_area: user.value.coverage_area || '',
          preferences: user.value.preferences || ''
        }
      }
      avatarFile.value = null
      previewAvatar.value = null
    }

    const handleAvatarError = (event) => {
      event.target.src = defaultAvatar
    }

    onMounted(fetchProfile)

    return {
      user,
      form,
      avatarFile,
      previewAvatar,
      defaultAvatar,
      loading,
      onAvatarChange,
      updateProfile,
      t,
      pref,
      isStaff,
      getRoleClass,
      getUserRoleLabel,
      formatFileSize,
      getMemberSince,
      getLastPasswordUpdate,
      getActiveDevices,
      resetForm,
      handleAvatarError,
      // Password
      showPasswordModal,
      passwordLoading,
      passwordForm,
      openChangePasswordModal,
      closePasswordModal,
      changePassword,
      // Devices
      showDevicesModal,
      devicesLoading,
      devices,
      deviceRevoking,
      openDevicesModal,
      closeDevicesModal,
      revokeDevice,
      formatDate,
      // Notifications
      sendingEmail,
      sendingSMS,
      sendEmailNotification,
      sendSMSNotification,
      saveNotificationPreferences
    }
  }
}
</script>

<style scoped>
/* Modal Styles */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-container {
  background: white;
  border-radius: 12px;
  width: 90%;
  max-width: 500px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
}

.modal-lg {
  max-width: 700px;
}

.modal-header {
  padding: 20px 24px;
  border-bottom: 1px solid #e0e0e0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  position: sticky;
  top: 0;
  background: white;
  border-radius: 12px 12px 0 0;
}

.modal-header h3 {
  margin: 0;
  font-size: 1.25rem;
  color: #333;
}

.modal-close {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  color: #666;
  padding: 0 8px;
  line-height: 1;
}

.modal-close:hover {
  color: #333;
}

.modal-form {
  padding: 24px;
}

.modal-body {
  padding: 24px;
}

.modal-actions {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
  margin-top: 24px;
}

/* Device Items */
.device-item {
  padding: 16px;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  margin-bottom: 12px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.device-item:last-child {
  margin-bottom: 0;
}

.device-info {
  display: flex;
  gap: 12px;
  align-items: flex-start;
}

.device-icon {
  font-size: 24px;
}

.device-details h4 {
  margin: 0 0 4px 0;
  font-size: 1rem;
  color: #333;
}

.device-details p {
  margin: 2px 0;
  font-size: 0.875rem;
  color: #666;
}

.device-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.device-badge {
  background: #e8f5e9;
  color: #2e7d32;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 0.75rem;
  font-weight: 500;
}

.btn-danger {
  background: #dc3545;
  color: white;
  border: none;
  padding: 6px 12px;
  border-radius: 6px;
  font-size: 0.875rem;
  cursor: pointer;
  transition: background 0.2s;
}

.btn-danger:hover:not(:disabled) {
  background: #c82333;
}

.btn-danger:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-sm {
  padding: 4px 8px;
  font-size: 0.75rem;
}

.text-center {
  text-align: center;
  padding: 40px 0;
}
.profile-container {                                max-width: 1400px;
  margin: 0 auto;
  padding: 0 16px;
  min-height: 100vh;
}

/* Header Section */
.header-section {
  margin-bottom: 40px;
}

.header-content {
  text-align: center;
  margin-bottom: 24px;
}

.header-content h1 {
  font-size: 2.5rem;
  color: #2d3436;
  margin-bottom: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
}

.header-content .icon {
  font-size: 2.2rem;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.1); }
}

.header-content p {
  color: #636e72;
  font-size: 1.1rem;
  max-width: 600px;
  margin: 0 auto;
}

/* Profile Content Layout */
.profile-content {
  display: grid;
  grid-template-columns: 1fr 2fr;
  gap: 32px;
  margin-bottom: 40px;
}

/* Left Column */
.profile-left {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

/* Cards Common Styles */
.avatar-card,
.preferences-card,
.form-card,
.security-card {
  background: white;
  border-radius: 20px;
  overflow: hidden;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
  border: 1px solid #f1f2f6;
}

/* Avatar Card */
.avatar-card {                                      padding: 24px;
}

.avatar-section {
  display: flex;                                    flex-direction: column;
  align-items: center;
  gap: 24px;
  margin-bottom: 24px;
}
                                                  .avatar-wrapper {
  position: relative;
  width: 180px;
  height: 180px;                                    border-radius: 50%;
  overflow: hidden;
  border: 5px solid white;
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

.avatar-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s;
}

.avatar-wrapper:hover .avatar-image {
  transform: scale(1.05);
}

.avatar-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;                                         bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.3s;
}

.avatar-wrapper:hover .avatar-overlay {
  opacity: 1;
}

.avatar-upload-label {
  background: rgba(255, 255, 255, 0.9);
  padding: 12px 24px;
  border-radius: 25px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 600;
  color: #2d3436;
  transition: transform 0.3s;
}
                                                  .avatar-upload-label:hover {
  transform: translateY(-2px);
  background: white;                              }

.upload-icon {
  font-size: 1.2rem;
}

.avatar-info {
  text-align: center;
  width: 100%;
}
                                                  .avatar-name {
  font-size: 1.8rem;
  color: #2d3436;
  margin-bottom: 4px;                               font-weight: 700;
}                                                                                                   .avatar-email {
  color: #636e72;                                   font-size: 1rem;
  margin-bottom: 12px;                            }

.avatar-role {
  margin-bottom: 16px;
}                                                 
.role-badge {
  display: inline-block;
  padding: 6px 16px;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 600;
  color: white;
}
                                                  .role-admin {
  background: linear-gradient(135deg, #ff7675 0%, #d63031 100%);                                    }

.role-provider {
  background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%);
}

.role-user {                                        background: linear-gradient(135deg, #00b894 0%, #00a085 100%);                                    }
                                                  .role-default {
  background: linear-gradient(135deg, #b2bec3 0%, #636e72 100%);
}                                                 
.avatar-file-info {
  background: #f8f9fa;
  padding: 12px;
  border-radius: 12px;                              margin-top: 16px;
}                                                 
.file-item {
  display: flex;
  align-items: center;
  gap: 8px;                                         margin-bottom: 4px;
}

.file-icon {
  font-size: 1rem;
}

.file-name {
  font-weight: 600;
  color: #2d3436;                                   font-size: 0.9rem;
}
                                                  .file-size {
  color: #636e72;
  font-size: 0.85rem;
}

.file-text {
  color: #b2bec3;
  font-style: italic;                             }
                                                  /* Profile Stats */
.profile-stats {                                    display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
  padding-top: 20px;
  border-top: 1px solid #f1f2f6;                  }

.stat-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;                                    background: #f8f9fa;
  border-radius: 12px;
}                                                 
.stat-icon {
  font-size: 1.5rem;
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 10px;
  color: white;
}

.stat-content h3 {                                  font-size: 1rem;
  color: #2d3436;
  margin-bottom: 2px;
  font-weight: 700;
}
                                                  .stat-content p {
  color: #636e72;
  font-size: 0.8rem;
}

/* Preferences Card */
.preferences-card {
  padding: 24px;
}                                                                                                   .card-header {
  margin-bottom: 24px;
}

.card-header h3 {
  font-size: 1.5rem;                                color: #2d3436;
  display: flex;
  align-items: center;
  gap: 10px;
}
                                                  .header-icon {
  font-size: 1.3rem;
}                                                                                                   .preferences-content {                              display: flex;
  flex-direction: column;
  gap: 20px;
}

.preference-item {
  display: flex;                                    flex-direction: column;
  gap: 8px;                                       }                                                 
.preference-label {
  font-weight: 600;
  color: #2d3436;
  font-size: 0.95rem;
  display: flex;
  align-items: center;
  gap: 8px;                                       }                                                 
.label-icon {
  font-size: 1.1rem;
}
                                                  .preference-control {
  flex: 1;
}                                                 
.preference-select {
  width: 100%;
  padding: 12px;
  border: 2px solid #dfe6e9;                        border-radius: 10px;
  font-size: 0.95rem;
  background: white;
  cursor: pointer;
  transition: all 0.3s;
}
                                                  .preference-select:focus {
  outline: none;                                    border-color: #3498db;
  box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);  }

.flag-icon {
  margin-right: 8px;                              }
                                                  /* Theme Toggle */
.theme-toggle {
  display: flex;
  gap: 8px;
  background: #f8f9fa;
  padding: 4px;                                     border-radius: 12px;
}

.theme-btn {
  flex: 1;
  padding: 12px;                                    border: none;
  border-radius: 8px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;                          gap: 8px;
  font-weight: 600;
  font-size: 0.9rem;
  transition: all 0.3s;
  background: transparent;
  color: #636e72;
}

.theme-btn.active {
  background: white;
  color: #2d3436;                                   box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.theme-btn.light.active {
  color: #f39c12;
}

.theme-btn.dark.active {
  color: #2c3e50;
}
                                                  .theme-icon {
  font-size: 1.1rem;
}

/* Notifications */
.notifications-item {
  gap: 12px;
}

.notifications-control {
  display: flex;                                    flex-direction: column;
  gap: 12px;
}

.notification-option {
  background: #f8f9fa;
  padding: 12px;                                    border-radius: 10px;
}

.checkbox-label {
  display: flex;
  align-items: center;                              gap: 12px;
  cursor: pointer;                                  font-size: 0.95rem;                             }                                                 
.checkbox-input {
  display: none;                                  }                                                                                                   .checkbox-custom {                                  width: 20px;                                      height: 20px;
  border: 2px solid #b2bec3;                        border-radius: 4px;
  position: relative;
  transition: all 0.3s;
}

.checkbox-input:checked + .checkbox-custom {        background: #3498db;
  border-color: #3498db;
}                                                 
.checkbox-input:checked + .checkbox-custom::after {                                                   content: '✓';
  position: absolute;                               top: 50%;                                         left: 50%;
  transform: translate(-50%, -50%);                 color: white;
  font-size: 12px;
  font-weight: bold;                              }

.checkbox-text {
  display: flex;                                    align-items: center;                              gap: 8px;
  color: #2d3436;
  font-weight: 600;
}
                                                  .checkbox-icon {
  font-size: 1.1rem;                              }

/* Right Column */
.profile-right {
  display: flex;
  flex-direction: column;                           gap: 24px;                                      }                                                                                                   /* Form Card */
.form-card {                                        padding: 32px;
}                                                                                                   .card-subtitle {
  color: #636e72;                                   font-size: 0.95rem;                               margin-top: 4px;                                }
                                                  .form-content {
  display: flex;
  flex-direction: column;
  gap: 24px;                                      }

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;                                       }
                                                  .form-label {                                       font-weight: 600;
  color: #2d3436;
  font-size: 0.95rem;
  display: flex;                                    align-items: center;                              gap: 8px;
}
                                                  .required {                                         color: #e74c3c;
}                                                 
.form-input,
.form-textarea {
  padding: 14px;
  border: 2px solid #dfe6e9;                        border-radius: 10px;
  font-size: 1rem;
  transition: all 0.3s;
  background: white;
}                                                                                                   .form-input:focus,
.form-textarea:focus {
  outline: none;
  border-color: #3498db;                            box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
}

.form-textarea {
  min-height: 100px;
  resize: vertical;
}                                                                                                   .form-hint {                                        color: #636e72;
  font-size: 0.85rem;                               font-style: italic;                             }
                                                  /* Section Divider */                             .section-divider {
  position: relative;                               text-align: center;                               margin: 24px 0;                                 }                                                 
.section-divider::before {
  content: '';
  position: absolute;
  top: 50%;
  left: 0;                                          right: 0;                                         height: 1px;                                      background: #dfe6e9;                            }                                                                                                   .divider-text {
  position: relative;                               background: white;
  padding: 0 20px;
  color: #636e72;                                   font-weight: 600;                                 font-size: 0.9rem;                              }                                                 
/* Form Actions */                                .form-actions {
  display: flex;                                    gap: 16px;
  margin-top: 24px;
  padding-top: 24px;                                border-top: 1px solid #f1f2f6;
}                                                 
.btn-primary,                                     .btn-secondary {                                    flex: 1;                                          padding: 16px;                                    border: none;
  border-radius: 12px;                              font-weight: 600;                                 font-size: 1rem;                                  cursor: pointer;                                  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  transition: all 0.3s;
}                                                 
.btn-primary {                                      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;                                   }
                                                  .btn-primary:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
}

.btn-primary:disabled {                             opacity: 0.6;                                     cursor: not-allowed;                            }                                                 
.btn-secondary {
  background: #dfe6e9;
  color: #2d3436;
}
                                                  .btn-secondary:hover:not(:disabled) {
  background: #b2bec3;                              transform: translateY(-2px);
}

.btn-secondary:disabled {                           opacity: 0.6;
  cursor: not-allowed;
}

.btn-icon {
  font-size: 1.1rem;                              }                                                 
.btn-loading {
  position: relative;
  color: transparent;
}
                                                  .loading-spinner {
  position: absolute;
  width: 20px;                                      height: 20px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top-color: white;                          border-radius: 50%;
  animation: spin 0.8s linear infinite;
}                                                 
@keyframes spin {                                   to { transform: rotate(360deg); }
}                                                 
/* Security Card */
.security-card {                                    padding: 24px;
}

.security-content {
  display: flex;
  flex-direction: column;
  gap: 16px;                                      }                                                 
.security-item {
  display: flex;
  justify-content: space-between;
  align-items: center;                              padding: 16px;
  background: #f8f9fa;
  border-radius: 12px;                              transition: all 0.3s;                           }
                                                  .security-item:hover {
  background: #e9ecef;
}                                                 
.security-info {
  display: flex;
  align-items: center;                              gap: 16px;                                      }
                                                  .security-icon {
  font-size: 1.5rem;                                width: 48px;
  height: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%);
  border-radius: 12px;
  color: white;
}                                                 
.security-text h4 {
  font-size: 1rem;
  color: #2d3436;                                   margin-bottom: 4px;                               font-weight: 700;
}
                                                  .security-text p {                                  color: #636e72;
  font-size: 0.85rem;
}                                                 
.btn-change-password,                             .btn-manage-devices {                               padding: 10px 20px;
  border: 2px solid #3498db;
  background: white;                                color: #3498db;
  border-radius: 8px;
  font-weight: 600;                                 font-size: 0.9rem;
  cursor: pointer;                                  display: flex;
  align-items: center;                              gap: 8px;
  transition: all 0.3s;                           }
                                                  .btn-change-password:hover,
.btn-manage-devices:hover {                         background: #3498db;
  color: white;
  transform: translateY(-2px);
}

/* Responsive Design */
@media (max-width: 1200px) {
  .profile-content {                                  grid-template-columns: 1fr;
    gap: 24px;
  }
                                                    .profile-left {
    grid-template-columns: repeat(2, 1fr);
    display: grid;
  }
}

@media (max-width: 992px) {
  .profile-left {                                     grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .profile-container {
    padding: 0 12px;
  }

  .header-content h1 {
    font-size: 2rem;
  }
                                                    .profile-content {
    gap: 20px;
  }
                                                    .avatar-card,                                     .preferences-card,
  .form-card,
  .security-card {
    padding: 20px;
    border-radius: 16px;
  }                                                                                                   .avatar-wrapper {
    width: 150px;                                     height: 150px;
  }
                                                    .form-actions {
    flex-direction: column;                         }                                               
  .security-item {                                    flex-direction: column;                           align-items: stretch;
    gap: 16px;
  }
                                                    .btn-change-password,
  .btn-manage-devices {
    width: 100%;
    justify-content: center;
  }                                               }                                                 
@media (max-width: 480px) {                         .header-content h1 {
    font-size: 1.8rem;                                flex-direction: column;                           gap: 8px;                                       }                                               
  .avatar-name {
    font-size: 1.5rem;
  }                                               
  .profile-stats {
    grid-template-columns: 1fr;                     }                                               
  .theme-toggle {
    flex-direction: column;
  }                                                                                                   .checkbox-label {
    font-size: 0.9rem;
  }                                               }
</style>
