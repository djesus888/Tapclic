<template>
  <div class="max-w-md mx-auto mt-10 p-6 bg-white rounded-xl shadow">
    <h2 class="text-xl font-semibold mb-4">
      {{ t('forgot.title') }}
    </h2>

    <!-- Selector método -->
    <div class="mb-4">
      <label class="block mb-1 font-medium">
        {{ t('forgot.method') }}
      </label>
      <select
        v-model="method"
        class="w-full border rounded p-2"
      >
        <option value="email">
          {{ t('forgot.email') }}
        </option>
        <option value="phone">
          {{ t('forgot.phone') }}
        </option>
      </select>
    </div>

    <!-- Input -->
    <div class="mb-4">
      <label class="block mb-1 font-medium">
        {{ method === 'email' ? t('forgot.email') : t('forgot.phone') }}
      </label>
      <input
        v-model="value"
        type="text"
        class="w-full border rounded p-2"
        :placeholder="method === 'email'
          ? t('forgot.emailPlaceholder')
          : t('forgot.phonePlaceholder')"
      >
    </div>

    <!-- Botón -->
    <button
      class="w-full bg-blue-600 text-white py-2 rounded hover:bg-blue-700 disabled:opacity-50"
      :disabled="loading"
      @click="submit"
    >
      {{ loading ? t('forgot.sending') : t('forgot.sendCode') }}
    </button>

    <!-- Mensaje -->
    <p
      v-if="message"
      class="mt-4 text-sm text-center"
      :class="error ? 'text-red-600' : 'text-green-600'"
    >
      {{ message }}
    </p>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'
import api from '@/axios'

const { t } = useI18n()
const router = useRouter()

const method = ref('email')
const value = ref('')
const message = ref('')
const error = ref(false)
const loading = ref(false)

const submit = async () => {
  message.value = ''
  error.value = false

  if (!value.value) {
    message.value = t('forgot.required')
    error.value = true
    return
  }

  loading.value = true

  try {
    const res = await api.post('/forgot-password', {
      method: method.value,
      value: value.value
    })

    // Mostrar mensaje de éxito
    message.value = res.data?.message || t('forgot.success')

    // Limpiar campo
    value.value = ''

    // Redirigir automáticamente a la pantalla de ingresar token
    setTimeout(() => {
      router.push({ path: '/reset-password' })
    }, 1500)

  } catch (e) {
    message.value = e.response?.data?.message || t('forgot.error')
    error.value = true
  } finally {
    loading.value = false
  }
}
</script>
