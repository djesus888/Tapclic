<template>
  <Teleport to="body">
    <div
      class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-40"
      @click.self="$emit('close')"
    >
      <div class="bg-white rounded-2xl shadow-xl p-6 w-full max-w-md">
        <header class="flex items-center justify-between mb-4">
          <h3 class="text-lg font-semibold text-gray-900">
            {{ $t('config.changePassword') }}
          </h3>
          <button
            class="text-gray-400 hover:text-gray-600"
            @click="$emit('close')"
          >
            ✕
          </button>
        </header>

        <form
          novalidate
          @submit.prevent="changePassword"
        >
          <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-1">
              {{ $t('config.currentPassword') }}
            </label>
            <input
              v-model="payload.current_password"
              type="password"
              required
              class="w-full border rounded-lg px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
            >
          </div>

          <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-1">
              {{ $t('config.newPassword') }}
            </label>
            <input
              v-model="payload.new_password"
              type="password"
              required
              class="w-full border rounded-lg px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
            >
          </div>

          <div class="mb-6">
            <label class="block text-sm font-medium text-gray-700 mb-1">
              {{ $t('config.confirmPassword') }}
            </label>
            <input
              v-model="payload.new_password_confirmation"
              type="password"
              required
              class="w-full border rounded-lg px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
            >
            <p
              v-if="error"
              class="text-red-500 text-xs mt-1"
            >
              {{ error }}
            </p>
          </div>

          <div class="flex justify-end gap-3">
            <button
              type="button"
              class="px-4 py-2 border rounded-lg hover:bg-gray-100 transition"
              @click="$emit('close')"
            >
              {{ $t('config.cancel') }}
            </button>
            <button
              type="submit"
              :disabled="loading"
              class="px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 disabled:opacity-50 transition"
            >
              <span v-if="loading">⏳</span>
              <span v-else>{{ $t('config.save') }}</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  </Teleport>
</template>

<script setup>
import { reactive, ref } from 'vue'
import api from '@/axios'
import Swal from 'sweetalert2'
import { useAuthStore } from '@/stores/authStore'
import { useI18n } from 'vue-i18n'

const authStore = useAuthStore()
const { t } = useI18n()

const emit = defineEmits(['close', 'passwordChanged'])

const loading = ref(false)
const error = ref('')

const payload = reactive({
  current_password: '',
  new_password: '',
  new_password_confirmation: ''
})

const changePassword = async () => {
  error.value = ''
  if (payload.new_password !== payload.new_password_confirmation) {
    error.value = t('config.passwordsDoNotMatch')
    return
  }
  if (payload.new_password.length < 6) {
    error.value = t('config.passwordTooShort')
    return
  }

  loading.value = true
  try {
    await api.post(
      '/profile/password',
      {
        current_password: payload.current_password,
        new_password: payload.new_password
      },
      { headers: { Authorization: `Bearer ${authStore.token}` } }
    )
    Swal.fire(t('success'), t('config.passwordChanged'), 'success')
    emit('passwordChanged')
  } catch (e) {
    error.value = e.response?.data?.message || t('config.changeFailed')
  } finally {
    loading.value = false
  }
}
</script>
