<template>
  <div class="max-w-md mx-auto mt-10 p-6 bg-white rounded-xl shadow">
    <h2 class="text-xl font-semibold mb-4">
      {{ t('resetPassword.title') }}
    </h2>

    <!-- Token -->
    <div class="mb-4">
      <label class="block mb-1 font-medium">
        {{ t('resetPassword.tokenLabel') }}
      </label>
      <input
        v-model="token"
        type="text"
        class="w-full border rounded p-2"
        :placeholder="t('resetPassword.tokenPlaceholder')"
      />
    </div>

    <!-- Nueva contraseña -->
    <div class="mb-4">
      <label class="block mb-1 font-medium">
        {{ t('resetPassword.passwordLabel') }}
      </label>
      <input
        v-model="password"
        type="password"
        class="w-full border rounded p-2"
        :placeholder="t('resetPassword.passwordPlaceholder')"
      />
    </div>

    <!-- Confirmar -->
    <div class="mb-4">
      <label class="block mb-1 font-medium">
        {{ t('resetPassword.confirmPasswordLabel') }}
      </label>
      <input
        v-model="confirmPassword"
        type="password"
        class="w-full border rounded p-2"
      />
    </div>

    <!-- Botón -->
    <button
      class="w-full bg-green-600 text-white py-2 rounded hover:bg-green-700 disabled:opacity-50"
      :disabled="loading"
      @click="submit"
    >
      {{ loading ? t('resetPassword.loading') : t('resetPassword.submit') }}
    </button>

    <!-- Mensaje -->
    <p
      v-if="message"
      class="mt-4 text-sm text-center"
      :class="success ? 'text-green-600' : 'text-red-600'"
    >
      {{ message }}
    </p>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'
import api from '@/axios'

const { t } = useI18n()
const router = useRouter()

const token = ref('')
const password = ref('')
const confirmPassword = ref('')
const message = ref('')
const success = ref(false)
const loading = ref(false)

onMounted(() => {
  // Detecta token desde enlace de correo
  const params = new URLSearchParams(window.location.search)
  const urlToken = params.get('token')
  if (urlToken) token.value = urlToken
})

const submit = async () => {
  message.value = ''
  success.value = false

  if (!token.value || !password.value || !confirmPassword.value) {
    message.value = t('resetPassword.errors.required')
    return
  }

  if (password.value.length < 6) {
    message.value = t('resetPassword.errors.minLength')
    return
  }

  if (password.value !== confirmPassword.value) {
    message.value = t('resetPassword.errors.notMatch')
    return
  }

  loading.value = true
  try {
    const res = await api.post('/reset-password', {
      token: token.value,
      password: password.value
    })

    success.value = true
    message.value = res.data.message || t('resetPassword.success')

    // Limpiar campos
    token.value = ''
    password.value = ''
    confirmPassword.value = ''

    // Redirigir automáticamente al login después de 2 segundos
    setTimeout(() => {
      router.push('/login')
    }, 2000)

  } catch (err) {
    message.value = err.response?.data?.message || t('resetPassword.errors.invalidToken')
  } finally {
    loading.value = false
  }
}
</script>
