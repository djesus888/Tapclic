<template>
  <div class="min-h-screen bg-gray-50 py-8 px-4 sm:px-6 lg:px-8">
    <div class="max-w-3xl mx-auto bg-white rounded-2xl shadow-lg p-6 sm:p-8">
      <header class="mb-8">
        <h1 class="text-2xl sm:text-3xl font-bold text-gray-900">{{ $t('config.title') }}</h1>
        <p class="text-sm text-gray-500 mt-1">{{ $t('config.subtitle') }}</p>
      </header>

      <form @submit.prevent="saveConfig" novalidate>
        <!-- Cuenta -->
        <section class="mb-10">
          <h2 class="text-lg font-semibold text-gray-800 mb-4">{{ $t('config.account') }}</h2>
          <div class="grid gap-4 sm:grid-cols-2">
            <FormInput
              v-model="form.name"
              label="Nombre"
              required
              aria-required="true"
              :error="errors.name"
            />
            <FormInput
              v-model="form.email"
              type="email"
              label="Email"
              required
              aria-required="true"
              :error="errors.email"
            />
            <FormInput
              v-model="form.phone"
              type="tel"
              label="Teléfono"
              :error="errors.phone"
              class="sm:col-span-2"
            />
          </div>
        </section>

        <!-- Preferencias -->
        <section class="mb-10">
          <h2 class="text-lg font-semibold text-gray-800 mb-4">{{ $t('config.preferences') }}</h2>
          <div class="grid gap-4 sm:grid-cols-2">
            <FormSelect
              v-model="form.language"
              label="Idioma"
              :options="languages"
            />
            <FormSelect
              v-model="form.theme"
              label="Tema"
              :options="themes"
            />
            <FormSwitch
              v-model="form.notifications"
              label="Notificaciones"
              class="sm:col-span-2"
            />
          </div>
        </section>

        <!-- Seguridad -->
        <section class="mb-10">
          <h2 class="text-lg font-semibold text-gray-800 mb-4">{{ $t('config.security') }}</h2>
          <button
            type="button"
            @click="showChangePassword = true"
            class="inline-flex items-center px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition"
          >
            🔒 {{ $t('config.changePassword') }}
          </button>
        </section>

        <!-- Admin -->
        <section v-if="isAdmin" class="mb-10 border-t pt-6">
          <h2 class="text-lg font-semibold text-red-600 mb-4">{{ $t('config.adminSection') }}</h2>
          <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-1">Gestionar Usuarios</label>
            <button
              type="button"
              @click="openUserManagement"
              class="inline-flex items-center px-4 py-2 bg-orange-500 text-white rounded-lg hover:bg-orange-600 transition"
            >
              👥 {{ $t('config.manageUsers') }}
            </button>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Configuración Global</label>
            <textarea
              v-model="form.globalConfig"
              rows="5"
              class="w-full border rounded-lg p-3 text-sm font-mono"
              placeholder='{"key": "value"}'
              :class="{ 'border-red-500': errors.globalConfig }"
            ></textarea>
            <p v-if="errors.globalConfig" class="text-red-500 text-xs mt-1">{{ errors.globalConfig }}</p>
          </div>
        </section>

        <!-- Submit -->
        <div class="flex justify-end">
          <button
            type="submit"
            :disabled="loading"
            class="px-6 py-3 bg-green-600 text-white rounded-lg font-semibold hover:bg-green-700 disabled:opacity-50 transition"
          >
            <span v-if="loading">⏳ {{ $t('config.saving') }}</span>
            <span v-else>💾 {{ $t('config.saveChanges') }}</span>
          </button>
        </div>
      </form>
    </div>

    <ChangePasswordModal
      v-if="showChangePassword"
      @close="showChangePassword = false"
      @passwordChanged="onPasswordChanged"
    />
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import api from '@/axio'
import Swal from 'sweetalert2'
import { useAuthStore } from '@/stores/authStore'
import { useI18n } from 'vue-i18n'

const authStore = useAuthStore()
const { t } = useI18n()

const loading = ref(false)
const showChangePassword = ref(false)
const user = ref(null)

const form = reactive({
  name: '',
  email: '',
  phone: '',
  language: 'es',
  theme: 'light',
  notifications: true,
  globalConfig: ''
})

const errors = reactive({
  name: '',
  email: '',
  phone: '',
  globalConfig: ''
})

const languages = [
  { label: 'Español', value: 'es' },
  { label: 'English', value: 'en' },
  { label: 'Français', value: 'fr' }
]

const themes = [
  { label: 'Claro', value: 'light' },
  { label: 'Oscuro', value: 'dark' }
]

const isAdmin = computed(() => user.value?.role === 'admin')

const validate = () => {
  let valid = true
  errors.name = form.name ? '' : 'El nombre es obligatorio'
  errors.email = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.email) ? '' : 'Email inválido'
  errors.phone = !form.phone || /^\+?\d{7,15}$/.test(form.phone) ? '' : 'Teléfono inválido'

  if (form.globalConfig) {
    try {
      JSON.parse(form.globalConfig)
      errors.globalConfig = ''
    } catch {
      errors.globalConfig = 'JSON inválido'
      valid = false
    }
  }

  return valid && !Object.values(errors).some(e => e)
}

const fetchProfile = async () => {
  try {
    const { data } = await api.get('/profile', {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    user.value = data.user || {}
    Object.assign(form, {
      name: user.value.name || '',
      email: user.value.email || '',
      phone: user.value.phone || '',
      language: user.value.language || 'es',
      theme: user.value.theme || 'light',
      notifications: user.value.notifications ?? true,
      globalConfig: user.value.globalConfig || ''
    })
  } catch {
    Swal.fire(t('error'), t('config.loadFailed'), 'error')
  }
}

const saveConfig = async () => {
  if (!validate()) return
  loading.value = true
  try {
    await api.post('/profile/update', form, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    Swal.fire(t('success'), t('config.saved'), 'success')
  } catch {
    Swal.fire(t('error'), t('config.saveFailed'), 'error')
  } finally {
    loading.value = false
  }
}

const openUserManagement = () => {
  Swal.fire(t('config.manageUsers'), t('config.featureComing'), 'info')
}

const onPasswordChanged = () => {
  showChangePassword.value = false
  Swal.fire(t('success'), t('config.passwordChanged'), 'success')
}

onMounted(fetchProfile)
</script>
