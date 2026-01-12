<template>
  <div class="max-w-3xl mx-auto p-6 bg-white rounded-xl shadow-md mt-8">
    <h2 class="text-3xl font-semibold text-gray-800 mb-6 border-b pb-2">
      {{ $t('profile.title') }}
    </h2>

    <form
      class="space-y-6"
      @submit.prevent="updateProfile"
    >
      <!-- Avatar -->
      <div class="flex items-center space-x-6">
        <img
          :src="previewAvatar || user?.avatar_url || defaultAvatar"
          alt="Avatar"
          class="w-24 h-24 rounded-full object-cover border border-gray-300"
        >
        <div class="flex flex-col">
          <label
            for="avatar-upload"
            class="cursor-pointer bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 transition text-center select-none"
          >
            {{ $t('changeAvatar') }}
          </label>
          <input
            id="avatar-upload"
            type="file"
            accept="image/*"
            class="hidden"
            @change="onAvatarChange"
          >
          <p
            v-if="avatarFile"
            class="mt-2 text-sm text-gray-600 truncate max-w-xs"
          >
            {{ avatarFile.name }}
          </p>
          <p
            v-else
            class="mt-2 text-sm text-gray-400 italic"
          >
            {{ $t('noFileSelected') }}
          </p>
        </div>
      </div>

      <!-- Nombre -->
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">
          {{ $t('name') }}
        </label>
        <input
          v-model="form.name"
          type="text"
          :placeholder="$t('name')"
          required
          class="w-full border border-gray-300 rounded-md shadow-sm p-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
        >
      </div>

      <!-- Email -->
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">
          {{ $t('email') }}
        </label>
        <input
          v-model="form.email"
          type="email"
          :placeholder="$t('email')"
          required
          class="w-full border border-gray-300 rounded-md shadow-sm p-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
        >
      </div>

      <!-- Teléfono -->
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">
          {{ $t('phone') }}
        </label>
        <input
          v-model="form.phone"
          type="tel"
          :placeholder="$t('phone')"
          pattern="^[+]?[\d\s\-]{7,15}$"
          title="Introduce un teléfono válido"
          class="w-full border border-gray-300 rounded-md shadow-sm p-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
        >
      </div>

      <!-- Dirección personal -->
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">
          {{ $t('address') }}
        </label>
        <input
          v-model="form.address"
          type="text"
          :placeholder="$t('address')"
          class="w-full border border-gray-300 rounded-md shadow-sm p-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
        >
      </div>

      <!-- Campos exclusivos para admin o provider -->
      <template v-if="user?.role === 'admin' || user?.role === 'provider'">
        <!-- Dirección comercial -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">
            {{ $t('businessAddress') }}
          </label>
          <input
            v-model="form.business_address"
            type="text"
            :placeholder="$t('businessAddress')"
            class="w-full border border-gray-300 rounded-md shadow-sm p-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
        </div>

        <!-- Categorías de servicio -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">
            {{ $t('serviceCategories') }}
          </label>
          <textarea
            v-model="form.service_categories"
            :placeholder="$t('serviceCategoriesPlaceholder')"
            class="w-full border border-gray-300 rounded-md shadow-sm p-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>

        <!-- Área de cobertura -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">
            {{ $t('coverageArea') }}
          </label>
          <textarea
            v-model="form.coverage_area"
            :placeholder="$t('coverageAreaPlaceholder')"
            class="w-full border border-gray-300 rounded-md shadow-sm p-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>
      </template>

      <!-- Sección Preferencias -->
      <details class="mt-6">
        <summary class="cursor-pointer font-semibold text-gray-700 mb-3">
          {{ $t('preferencesSection') }}
        </summary>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 border-t pt-4">
          <!-- Idioma -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">
              {{ $t('language') }}
            </label>
            <select
              v-model="pref.language"
              class="w-full border rounded-md p-2"
            >
              <option value="es">
                Español
              </option>
              <option value="en">
                English
              </option>
              <option value="pt">
                Português
              </option>
            </select>
          </div>

          <!-- Tema -->
          <div>
            <label class="flex items-center mt-6">
              <input
                v-model="pref.dark"
                type="checkbox"
                class="mr-2"
              >
              {{ $t('darkTheme') }}
            </label>
          </div>

          <!-- Notificaciones -->
          <div class="md:col-span-2 space-y-2">
            <label class="block text-sm font-medium text-gray-700">
              {{ $t('notifications') }}
            </label>
            <label class="flex items-center">
              <input
                v-model="pref.notifications.email"
                type="checkbox"
                class="mr-2"
              >
              {{ $t('notifyEmail') }}
            </label>
            <label class="flex items-center">
              <input
                v-model="pref.notifications.sms"
                type="checkbox"
                class="mr-2"
              >
              {{ $t('notifySMS') }}
            </label>
          </div>
        </div>
      </details>

      <!-- Botón Guardar -->
      <div>
        <button
          type="submit"
          :disabled="loading"
          class="w-full bg-blue-600 text-white py-3 rounded-md font-semibold hover:bg-blue-700 transition disabled:opacity-50"
        >
          <span v-if="loading">{{ $t('profile.saving') }}</span>
          <span v-else>{{ $t('saveChanges') }}</span>
        </button>
      </div>
    </form>
  </div>
</template>

<script>
import { ref, onMounted, reactive, watch } from 'vue'
import api from '@/axios'
import Swal from 'sweetalert2'
import { useAuthStore } from '@/stores/authStore'
import { useI18n } from 'vue-i18n'

export default {
  name: 'Profile',
  setup() {
    const authStore = useAuthStore()
    const { t, locale } = useI18n()

    const BASE_URL = 'http://localhost:8000'

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

    const pref = reactive({
      language: 'es',
      dark: false,
      notifications: { email: true, sms: false }
    })

    const fetchProfile = async () => {
      try {
        const { data } = await api.get('/profile', {
          headers: { Authorization: `Bearer ${authStore.token}` }
        })
        user.value = data.user || {}

        if (user.value.avatar_url && !user.value.avatar_url.startsWith('http')) {
          user.value.avatar_url = BASE_URL + '/uploads/avatars/' + user.value.avatar_url
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

        // idioma desde localStorage (sobre-escribe el de BD si existe)
        const savedLang = localStorage.getItem('userLanguage')
        if (savedLang) {
          pref.language = savedLang
        }
      } catch (err) {
        console.error('Error al obtener perfil:', err)
        Swal.fire(t('profile.error'), t('profile.loadFailed'), 'error')
      }
    }

    const onAvatarChange = (e) => {
      const file = e.target.files[0]
      if (file) {
        avatarFile.value = file
        previewAvatar.value = URL.createObjectURL(file)
      } else {
        avatarFile.value = null
        previewAvatar.value = null
      }
    }

    // cambio instantáneo de idioma + localStorage
    watch(
      () => pref.language,
      newLang => {
        localStorage.setItem('userLanguage', newLang)
        locale.value = newLang
      },
      { immediate: true }
    )

    const updateProfile = async () => {
      loading.value = true
      form.value.preferences = JSON.stringify(pref)

      try {
        const payload = new FormData()
        payload.append('name', form.value.name)
        payload.append('email', form.value.email)
        payload.append('phone', form.value.phone)
        payload.append('address', form.value.address)
        payload.append('business_address', form.value.business_address)
        payload.append('service_categories', form.value.service_categories)
        payload.append('coverage_area', form.value.coverage_area)
        payload.append('preferences', form.value.preferences)

        if (avatarFile.value) {
          payload.append('avatar', avatarFile.value)
        }

        await api.post('/profile/update', payload, {
          headers: { Authorization: `Bearer ${authStore.token}` }
        })

        Swal.fire(t('profile.successTitle'), t('profile.successMessage'), 'success')
        await fetchProfile()
        avatarFile.value = null
        previewAvatar.value = null
      } catch (err) {
        console.error('Error al actualizar perfil:', err)
        const status = err.response?.status
        const message = err.response?.data?.error || t('profile.updateFailed')

        if (status === 400 || status === 409) {
          Swal.fire(t('profile.error'), message, 'warning')
        } else {
          Swal.fire(t('profile.error'), t('profile.updateFailed'), 'error')
        }
      } finally {
        loading.value = false
      }
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
      pref
    }
  }
}
</script>
