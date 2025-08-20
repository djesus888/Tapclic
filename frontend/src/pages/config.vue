<template>
  <div class="max-w-4xl mx-auto p-6 bg-white rounded-lg shadow-md mt-8">
    <h1 class="text-3xl font-bold mb-6">{{ $t('config.title') }}</h1>

    <!-- Sección cuenta -->
    <section class="mb-8">
      <h2 class="text-xl font-semibold mb-4">{{ $t('config.account') }}</h2>
      <FormInput
        label="Nombre"
        v-model="form.name"
        required
      />
      <FormInput
        label="Email"
        type="email"
        v-model="form.email"
        required
      />
      <FormInput
        label="Teléfono"
        type="tel"
        v-model="form.phone"
      />
    </section>

    <!-- Sección preferencias -->
    <section class="mb-8">
      <h2 class="text-xl font-semibold mb-4">{{ $t('config.preferences') }}</h2>
      <FormSelect
        label="Idioma"
        :options="languages"
        v-model="form.language"
      />
      <FormSelect
        label="Tema"
        :options="themes"
        v-model="form.theme"
      />
      <FormSwitch
        label="Notificaciones"
        v-model="form.notifications"
      />
    </section>

    <!-- Seguridad -->
    <section class="mb-8">
      <h2 class="text-xl font-semibold mb-4">{{ $t('config.security') }}</h2>
      <button @click="showChangePassword = true" class="btn-primary">
        {{ $t('config.changePassword') }}
      </button>
    </section>

    <!-- Sección admin (solo visible para admins) -->
    <section v-if="isAdmin" class="mb-8 border-t pt-6">
      <h2 class="text-xl font-semibold mb-4 text-red-600">{{ $t('config.adminSection') }}</h2>

      <div>
        <label class="block font-medium mb-1">Gestionar Usuarios</label>
        <button @click="openUserManagement" class="btn-secondary mb-4">
          {{ $t('config.manageUsers') }}
        </button>
      </div>

      <div>
        <label class="block font-medium mb-1">Configuración Global</label>
        <textarea
          v-model="form.globalConfig"
          rows="5"
          class="w-full border rounded p-2"
          placeholder="JSON o configuración avanzada"
        ></textarea>
      </div>
    </section>

    <!-- Botón guardar -->
    <div>
      <button
        @click="saveConfig"
        :disabled="loading"
        class="btn-primary w-full py-3 rounded text-white font-semibold"
      >
        <span v-if="loading">{{ $t('config.saving') }}</span>
        <span v-else>{{ $t('config.saveChanges') }}</span>
      </button>
    </div>

    <!-- Modal cambio contraseña -->
    <ChangePasswordModal
      v-if="showChangePassword"
      @close="showChangePassword = false"
      @passwordChanged="onPasswordChanged"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import api from '@/axio'
import Swal from 'sweetalert2'
import { useAuthStore } from '@/stores/authStore'


import { useI18n } from 'vue-i18n'

const authStore = useAuthStore()
const { t } = useI18n()

const loading = ref(false)
const showChangePassword = ref(false)

const user = ref(null)
const form = ref({
  name: '',
  email: '',
  phone: '',
  language: 'es',
  theme: 'light',
  notifications: true,
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

const fetchProfile = async () => {
  try {
    const { data } = await api.get('/profile', {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    user.value = data.user || {}

    form.value.name = user.value.name || ''
    form.value.email = user.value.email || ''
    form.value.phone = user.value.phone || ''
    form.value.language = user.value.language || 'es'
    form.value.theme = user.value.theme || 'light'
    form.value.notifications = user.value.notifications ?? true
    form.value.globalConfig = user.value.globalConfig || ''
  } catch (err) {
    console.error(err)
    Swal.fire(t('error'), t('config.loadFailed'), 'error')
  }
}

const saveConfig = async () => {
  loading.value = true

  try {
    const payload = {
      name: form.value.name,
      email: form.value.email,
      phone: form.value.phone,
      language: form.value.language,
      theme: form.value.theme,
      notifications: form.value.notifications,
      globalConfig: form.value.globalConfig
    }

    await api.post('/profile/update', payload, {
      headers: {
        Authorization: `Bearer ${authStore.token}`,
        'Content-Type': 'application/json'
      }
    })

    Swal.fire(t('success'), t('config.saved'), 'success')
  } catch (err) {
    console.error(err)
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

<style scoped>
.btn-primary {
  background-color: #2563eb;
  transition: background-color 0.3s ease;
}
.btn-primary:hover {
  background-color: #1e40af;
}

.btn-secondary {
  background-color: #f97316;
  color: white;
  padding: 0.5rem 1rem;
  border-radius: 0.375rem;
  cursor: pointer;
  transition: background-color 0.3s ease;
}
.btn-secondary:hover {
  background-color: #c2410c;
}
</style>
