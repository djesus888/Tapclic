<template>
  <div class="min-h-screen bg-gray-50 py-8 px-4 sm:px-6 lg:px-8">
    <div class="max-w-3xl mx-auto bg-white rounded-2xl shadow-lg p-6 sm:p-8">
      <header class="mb-8">
        <h1 class="text-2xl sm:text-3xl font-bold text-gray-900">
          {{ $t('config.title') }}
        </h1>
        <p class="text-sm text-gray-500 mt-1">
          {{ $t('config.subtitle') }}
        </p>
      </header>

      <form
        novalidate
        @submit.prevent="saveConfig"
      >
        <!-- Cuenta (todos) -->
        <section class="mb-10">
          <h2 class="text-lg font-semibold text-gray-800 mb-4">
            {{ $t('config.account') }}
          </h2>
          <div class="grid gap-4 sm:grid-cols-2">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">
                {{ $t('config.name') }}
              </label>
              <input
                v-model="form.name"
                type="text"
                required
                class="w-full border rounded-lg px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
              >
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">
                {{ $t('config.email') }}
              </label>
              <input
                v-model="form.email"
                type="email"
                required
                class="w-full border rounded-lg px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
              >
            </div>
            <div class="sm:col-span-2">
              <label class="block text-sm font-medium text-gray-700 mb-1">
                {{ $t('config.phone') }}
              </label>
              <input
                v-model="form.phone"
                type="tel"
                class="w-full border rounded-lg px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
              >
            </div>
          </div>
        </section>

        <!-- Preferencias (todos) -->
        <section class="mb-10">
          <h2 class="text-lg font-semibold text-gray-800 mb-4">
            {{ $t('config.preferences') }}
          </h2>
          <div class="grid gap-4 sm:grid-cols-2">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">
                {{ $t('config.language') }}
              </label>
              <select
                v-model="form.language"
                class="w-full border rounded-lg px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
              >
                <option value="es">
                  Español
                </option>
                <option value="en">
                  English
                </option>
              </select>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">
                {{ $t('config.theme') }}
              </label>
              <select
                v-model="form.theme"
                class="w-full border rounded-lg px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
              >
                <option value="light">
                  {{ $t('config.light') }}
                </option>
                <option value="dark">
                  {{ $t('config.dark') }}
                </option>
              </select>
            </div>
            <div class="sm:col-span-2 flex items-center gap-2">
              <input
                id="notif"
                v-model="form.notifications"
                type="checkbox"
                class="w-4 h-4 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500"
              >
              <label
                for="notif"
                class="text-sm font-medium text-gray-700"
              >
                {{ $t('config.notifications') }}
              </label>
            </div>
          </div>
        </section>

        <!-- Seguridad (todos) -->
        <section class="mb-10">
          <h2 class="text-lg font-semibold text-gray-800 mb-4">
            {{ $t('config.security') }}
          </h2>
          <button
            type="button"
            class="inline-flex items-center px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition"
            @click="showChangePassword = true"
          >
            🔒 {{ $t('config.changePassword') }}
          </button>
        </section>

        <!-- Opciones de PROVEEDOR -->
        <section
          v-if="isProvider"
          class="mb-10 border-t pt-6"
        >
          <h2 class="text-lg font-semibold text-blue-700 mb-4">
            {{ $t('config.providerSection') }}
          </h2>
          <div class="grid gap-4 sm:grid-cols-2">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">
                {{ $t('config.businessAddress') }}
              </label>
              <textarea
                v-model="form.business_address"
                rows="2"
                class="w-full border rounded-lg px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">
                {{ $t('config.coverageArea') }}
              </label>
              <input
                v-model="form.coverage_area"
                type="text"
                class="w-full border rounded-lg px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
              >
            </div>
            <div class="sm:col-span-2">
              <label class="block text-sm font-medium text-gray-700 mb-1">
                {{ $t('config.serviceCategories') }}
              </label>
              <input
                v-model="form.service_categories"
                type="text"
                placeholder="Ej: Cuidado de adultos, Limpieza"
                class="w-full border rounded-lg px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
              >
            </div>
          </div>
        </section>

        <!-- ADMIN ONLY -->
        <section
          v-if="isAdmin"
          class="mb-10 border-t pt-6"
        >
          <h2 class="text-lg font-semibold text-red-600 mb-4">
            {{ $t('config.adminSection') }}
          </h2>

          <!-- Config global JSON -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">
              {{ $t('config.globalConfig') }}
            </label>
            <textarea
              v-model="form.globalConfig"
              rows="5"
              class="w-full border rounded-lg p-3 text-sm font-mono"
              :class="{ 'border-red-500': errors.globalConfig }"
              placeholder="{&quot;key&quot;: &quot;value&quot;}"
            />
            <p
              v-if="errors.globalConfig"
              class="text-red-500 text-xs mt-1"
            >
              {{ errors.globalConfig }}
            </p>
          </div>

          <!-- Acceso rápido a gestión de usuarios -->
          <div class="mt-4">
            <button
              type="button"
              class="inline-flex items-center px-4 py-2 bg-orange-500 text-white rounded-lg hover:bg-orange-600 transition"
              @click="$router.push('/admin/users')"
            >
              👥 {{ $t('config.manageUsers') }}
            </button>
          </div>
        </section>

        <!-- Submit (todos) -->
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

    <!-- Modal cambio de contraseña -->
    <ChangePasswordModal
      v-if="showChangePassword"
      @close="showChangePassword = false"
      @password-changed="onPasswordChanged"
    />
  </div>
</template>

<script setup>
import { reactive, ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import api from '@/axios'
import Swal from 'sweetalert2'
import { useAuthStore } from '@/stores/authStore'
import { useI18n } from 'vue-i18n'
import ChangePasswordModal from '@/components/ChangePasswordModal.vue'

/* ---------- Composables ---------- */
const router = useRouter()
const authStore = useAuthStore()
const { t } = useI18n()

/* ---------- Estado ---------- */
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
  business_address: '',
  coverage_area: '',
  service_categories: '',
  globalConfig: ''
})

const errors = reactive({
  name: '',
  email: '',
  phone: '',
  globalConfig: ''
})

/* ---------- Computed ---------- */
const isAdmin = computed(() => user.value?.role === 'admin')
const isProvider = computed(() => user.value?.role === 'provider')

/* ---------- Cargar perfil ---------- */
const fetchProfile = async () => {
  try {
    const { data } = await api.get('/profile', {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    user.value = data.user
    Object.assign(form, {
      name: data.user.name || '',
      email: data.user.email || '',
      phone: data.user.phone || '',
      language: data.user.language || 'es',
      theme: data.user.theme || 'light',
      notifications: data.user.notifications ?? true,
      business_address: data.user.business_address || '',
      coverage_area: data.user.coverage_area || '',
      service_categories: data.user.service_categories || '',
      globalConfig: data.user.globalConfig || ''
    })
  } catch {
    Swal.fire(t('error'), t('config.loadFailed'), 'error')
  }
}

/* ---------- Validaciones ---------- */
const validate = () => {
  let valid = true
  errors.name = form.name.trim() ? '' : t('config.nameRequired')
  errors.email = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.email) ? '' : t('config.emailInvalid')
  errors.phone = !form.phone || /^\+?\d{7,15}$/.test(form.phone) ? '' : t('config.phoneInvalid')

  if (form.globalConfig.trim()) {
    try {
      JSON.parse(form.globalConfig)
      errors.globalConfig = ''
    } catch {
      errors.globalConfig = t('config.jsonInvalid')
      valid = false
    }
  }
  return valid && !Object.values(errors).some(Boolean)
}

/* ---------- Guardar ---------- */
const saveConfig = async () => {
  if (!validate()) return
  loading.value = true
  try {
    // Construimos payload dinámico según rol
    const payload = {
      name: form.name.trim(),
      email: form.email.trim(),
      phone: form.phone.trim(),
      language: form.language,
      theme: form.theme,
      notifications: form.notifications
    }
    if (isProvider.value) {
      payload.business_address = form.business_address.trim()
      payload.coverage_area = form.coverage_area.trim()
      payload.service_categories = form.service_categories.trim()
    }
    if (isAdmin.value) {
      payload.globalConfig = form.globalConfig.trim()
    }

    await api.post('/profile/update', payload, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    Swal.fire(t('success'), t('config.saved'), 'success')
  } catch {
    Swal.fire(t('error'), t('config.saveFailed'), 'error')
  } finally {
    loading.value = false
  }
}

/* ---------- Eventos ---------- -->
const onPasswordChanged = () => {
  showChangePassword.value = false
  Swal.fire(t('success'), t('config.passwordChanged'), 'success')
}

/* ---------- Montaje ---------- */
onMounted(fetchProfile)
</script>

<style scoped>
/* Opcional: colores dinámicos según tema */
body {
  @apply transition-colors duration-300;
}
</style>
