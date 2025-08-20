<template>
  <div class="max-w-3xl mx-auto p-6 bg-white rounded-xl shadow-md mt-8">
    <h2 class="text-3xl font-semibold text-gray-800 mb-6 border-b pb-2">
      {{ $t('profile.title') }}
    </h2>

    <form @submit.prevent="updateProfile" class="space-y-6">
      <!-- Avatar -->
      <div class="flex items-center space-x-6">
        <img
          :src="previewAvatar || user?.avatar_url || defaultAvatar"
          alt="Avatar"
          class="w-24 h-24 rounded-full object-cover border border-gray-300"
        />
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
            @change="onAvatarChange"
            class="hidden"
          />
          <p v-if="avatarFile" class="mt-2 text-sm text-gray-600 truncate max-w-xs">
            {{ avatarFile.name }}
          </p>
          <p v-else class="mt-2 text-sm text-gray-400 italic">
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
          type="text"
          v-model="form.name"
          :placeholder="$t('name')"
          required
          class="w-full border border-gray-300 rounded-md shadow-sm p-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
      </div>

      <!-- Email -->
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">
          {{ $t('email') }}
        </label>
        <input
          type="email"
          v-model="form.email"
          :placeholder="$t('email')"
          required
          class="w-full border border-gray-300 rounded-md shadow-sm p-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
      </div>

      <!-- Teléfono -->
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">
          {{ $t('phone') }}
        </label>
        <input
          type="tel"
          v-model="form.phone"
          :placeholder="$t('phone')"
          pattern="^[+]?[\d\s\-]{7,15}$"
          title="Introduce un teléfono válido"
          class="w-full border border-gray-300 rounded-md shadow-sm p-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
      </div>

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
import { ref, onMounted } from 'vue'
import api from '@/axio'
import Swal from 'sweetalert2'
import { useAuthStore } from '@/stores/authStore'
import { useI18n } from 'vue-i18n'

export default {
  name: 'Profile',
  setup() {
    const authStore = useAuthStore()
    const { t } = useI18n()

    const BASE_URL = 'http://localhost:8000' // Cambia esto si usas otro dominio o puerto

    const user = ref(null)
    const form = ref({ name: '', email: '', phone: '' })
    const avatarFile = ref(null)
    const previewAvatar = ref(null)
    const defaultAvatar = '/img/default-avatar.png'
    const loading = ref(false)

    const fetchProfile = async () => {
      try {
        const { data } = await api.get('/profile', {
          headers: { Authorization: `Bearer ${authStore.token}` }
        })
        user.value = data.user || {}

        // Si avatar_url no es URL completa, construir URL pública
        if (user.value.avatar_url && !user.value.avatar_url.startsWith('http')) {
          user.value.avatar_url = BASE_URL + '/uploads/avatars/' + user.value.avatar_url
        }

        form.value = {
          name: user.value.name || '',
          email: user.value.email || '',
          phone: user.value.phone || ''
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

    const updateProfile = async () => {
      loading.value = true

      try {
        if (avatarFile.value) {
          const formData = new FormData()
          formData.append('name', form.value.name)
          formData.append('email', form.value.email)
          formData.append('phone', form.value.phone)
          formData.append('avatar', avatarFile.value)

          await api.post('/profile/update', formData, {
            headers: { Authorization: `Bearer ${authStore.token}` }
          })
        } else {
          const payload = {
            name: form.value.name,
            email: form.value.email,
            phone: form.value.phone,
          }

          await api.post('/profile/update', payload, {
            headers: {
              Authorization: `Bearer ${authStore.token}`,
              'Content-Type': 'application/json'
            }
          })
        }

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
      t
    }
  }
}
</script>
