<template>
  <div class="min-h-screen bg-gray-100 flex flex-col">
    <!-- Barra superior -->
    <header class="bg-white shadow-sm px-6 py-3 flex items-center justify-between">
      <!-- Nombre del sistema a la izquierda -->
      <h1 class="text-xl font-bold text-gray-800">
        {{ systemStore.systemName }}
      </h1>

      <!-- Selector de idioma a la derecha (igual que MainLayout) -->
      <div class="relative">
        <select
          v-model="$i18n.locale"
          class="bg-gray-100 border border-gray-300 rounded-md px-3 py-1 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
          @change="changeLocale"
        >
          <option value="es">
            🇪🇸 Español
          </option>
          <option value="en">
            🇺🇸 English
          </option>
        </select>
      </div>
    </header>

    <!-- Contenido principal centrado -->
    <div class="flex-1 flex items-center justify-center">
      <div class="bg-white p-8 rounded-xl shadow-md w-full max-w-md">
        <!-- Logo centrado encima del formulario -->
        <div class="flex justify-center mb-6">
          <img
            v-if="systemStore.logo"
            :src="systemStore.logo"
            alt="Logo"
            class="h-20 w-auto object-contain"
          >
          <div
            v-else
            class="h-20 w-20 bg-blue-100 rounded-full flex items-center justify-center"
          >
            <span class="text-2xl font-bold text-blue-600">
              {{ systemStore.systemName?.charAt(0) }}
            </span>
          </div>
        </div>

        <h2 class="text-2xl font-bold mb-6 text-center text-gray-800">
          {{ $t('login') }}
        </h2>

        <p class="text-sm text-gray-600 text-center mb-4">
          {{ $t('login_prompt') }}
        </p>

        <form @submit.prevent="handleLogin">
          <div class="mb-4">
            <label class="block text-sm font-semibold text-gray-600">{{ $t('email_or_phone') }}</label>
            <input
              v-model="form.identifier"
              type="text"
              required
              class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              :placeholder="$t('enter_email_or_phone')"
            >
          </div>

          <div class="mb-2">
            <label class="block text-sm font-semibold text-gray-600">{{ $t('password') }}</label>
            <input
              v-model="form.password"
              :type="showPassword ? 'text' : 'password'"
              required
              class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              :placeholder="$t('enter_password')"
            >
          </div>

          <div class="flex items-center justify-between mb-6 text-sm">
            <label class="flex items-center">
              <input
                v-model="showPassword"
                type="checkbox"
                class="mr-2"
              >
              {{ $t('show_password') }}
            </label>

            <button
              type="button"
              class="text-blue-600 hover:underline"
              @click="goToForgotPassword"
            >
              {{ $t('forgot_password') }}
            </button>
          </div>

          <button
            type="submit"
            :disabled="auth.loading"
            class="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2 rounded-lg transition"
          >
            {{ auth.loading ? $t('logging_in') : $t('login') }}
          </button>
        </form>

        <p class="text-center text-sm text-gray-600 mt-6">
          {{ $t('no_account') }}
          <router-link
            to="/register"
            class="text-blue-600 hover:underline"
          >
            {{ $t('register_here') }}
          </router-link>
        </p>
      </div>
    </div>
  </div>
</template>


<script>
import { useAuthStore } from '@/stores/authStore'
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useSystemStore } from '@/stores/systemStore'
import Swal from 'sweetalert2' // ✅ solo para mostrar el error bonito

export default {
  setup() {
    const auth = useAuthStore()
    const router = useRouter()
    const systemStore = useSystemStore()

    const form = ref({
      identifier: '',
      password: '',
    })
    const showPassword = ref(false)

    /* ✅ NUEVO: manejamos el error real del backend sin tocar tu lógica */
    const handleLogin = async () => {
      try {
        await auth.login(form.value) // ← tu función original
      } catch (err) {
        // ❗️Aquí leemos el mensaje que manda el backend
        const msg = err.response?.data?.message || err.response?.data?.error || 'Error inesperado'
        Swal.fire('Error', msg, 'error') // mostramos bonito
        // (opcional) puedes hacer console.error(msg) si no quieres Swal
      }
    }

    const goToForgotPassword = () => {
      router.push('/forgot-password')
    }

    const changeLocale = (event) => {
      const newLocale = event.target.value
      auth.setLocale(newLocale)
    }

    return {
      form,
      handleLogin, // ← ahora es async y captura errores
      auth,
      showPassword,
      goToForgotPassword,
      systemStore,
      changeLocale
    }
  }
}
</script>
