<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-100">
    <div class="bg-white p-8 rounded-xl shadow-md w-full max-w-md">
      <h2 class="text-2xl font-bold mb-6 text-center text-gray-800">{{ $t('register') }}</h2>
      <form @submit.prevent="handleRegister">

        <!-- Nombre -->
        <div class="mb-4">
          <label class="block text-sm font-semibold text-gray-600">{{ $t('name') }}</label>
          <input
            v-model="form.name"
            type="text"
            required
            class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>

        <!-- Email -->
        <div class="mb-4">
          <label class="block text-sm font-semibold text-gray-600">{{ $t('email') }}</label>
          <input
            v-model="form.email"
            type="email"
            required
            class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>

        <!-- Teléfono -->
        <div class="mb-4">
          <label class="block text-sm font-semibold text-gray-600">{{ $t('phone') }}</label>
          <input
            v-model="form.phone"
            type="tel"
            required
            class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>

        <!-- Contraseña -->
        <div class="mb-4">
          <label class="block text-sm font-semibold text-gray-600">{{ $t('password') }}</label>
          <input
            :type="showPassword ? 'text' : 'password'"
            v-model="form.password"
            required
            class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>

        <!-- Confirmar contraseña -->
        <div class="mb-4">
          <label class="block text-sm font-semibold text-gray-600">{{ $t('confirm_password') }}</label>
          <input
            :type="showPassword ? 'text' : 'password'"
            v-model="form.confirmPassword"
            required
            class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>

        <!-- Mostrar contraseña -->
        <div class="mb-4 flex items-center">
          <input type="checkbox" v-model="showPassword" id="showPass" class="mr-2" />
          <label for="showPass" class="text-sm text-gray-600">{{ $t('show_password') }}</label>
        </div>

        <!-- Rol -->
        <div class="mb-4">
          <label class="block text-sm font-semibold text-gray-600">{{ $t('role') }}</label>
          <select
            v-model="form.role"
            required
            class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            <option value="" disabled>{{ $t('select_role') }}</option>
            <option value="user">{{ $t('client') }}</option>
            <option value="driver">{{ $t('provider') }}</option>
          </select>
        </div>

        <!-- Botón de registro -->
        <button
          type="submit"
          :disabled="auth.loading"
          class="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2 rounded-lg transition"
        >
          {{ auth.loading ? $t('registering') : $t('register') }}
        </button>
      </form>

      <p class="text-center mt-4 text-sm">
        {{ $t('already_have_account') }}
        <router-link to="/login" class="text-blue-600 hover:underline">{{ $t('login') }}</router-link>
      </p>
    </div>
  </div>
</template>

<script>
import { ref } from 'vue'
import { useAuthStore } from '@/stores/authStore'
import { useRouter } from 'vue-router'
import Swal from 'sweetalert2'

export default {
  setup() {
    const auth = useAuthStore()
    const router = useRouter()

    const form = ref({
      name: '',
      role: '',
      email: '',
      phone: '',
      password: '',
      confirmPassword: ''
    })

    const showPassword = ref(false)

    const handleRegister = async () => {
      if (form.value.password !== form.value.confirmPassword) {
        return Swal.fire({
          icon: 'warning',
          title: 'Contraseñas no coinciden',
          text: 'Por favor asegúrate de que ambas contraseñas sean iguales.',
        })
      }

      const credentials = {
        name: form.value.name,
        role: form.value.role,
        email: form.value.email,
        phone: form.value.phone,
        password: form.value.password
      }

      try {
        auth.loading = true
        const res = await auth.register(credentials)

        if (res.role === 'admin') {
          router.push('/dashboard/admin')
        } else if (res.role === 'driver') {
          router.push('/dashboard/driver')
        } else {
          router.push('/dashboard/user')
        }

      } catch (error) {
        // 🔍 Línea clave: detectar mensaje específico del backend
        const msg = error?.response?.data?.message || error?.response?.data?.error || 'Error al registrar. Intenta de nuevo.'
        
        // Mostrar errores específicos
        if (msg.includes('correo') || msg.includes('email')) {
          Swal.fire('Correo existente', 'El correo electrónico ya está registrado.', 'warning')
        } else if (msg.includes('teléfono') || msg.includes('phone')) {
          Swal.fire('Teléfono existente', 'El número de teléfono ya está registrado.', 'warning')
        } else {
          Swal.fire('Error', msg, 'error')
        }

        console.error('Error de registro:', error?.response?.data) // Para depuración

      } finally {
        auth.loading = false
      }
    }

    return { form, handleRegister, auth, showPassword }
  }
}
</script>
