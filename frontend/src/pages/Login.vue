<template>
<h2 class="text-2xl font-bold mb-6 text-center text-gray-800"> {{ systemStore.systemName }}</h2>
  <div class="min-h-screen flex items-center justify-center bg-gray-100">
    <div class="bg-white p-8 rounded-xl shadow-md w-full max-w-md">
      <h2 class="text-2xl font-bold mb-6 text-center text-gray-800">{{ $t('login') }}</h2>

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
          />
        </div>

        <div class="mb-2">
          <label class="block text-sm font-semibold text-gray-600">{{ $t('password') }}</label>
          <input
            v-model="form.password"
            :type="showPassword ? 'text' : 'password'"
            required
            class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            :placeholder="$t('enter_password')"
          />
        </div>

        <div class="flex items-center justify-between mb-6 text-sm">
          <label class="flex items-center">
            <input type="checkbox" v-model="showPassword" class="mr-2" />
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
        <router-link to="/register" class="text-blue-600 hover:underline">
          {{ $t('register_here') }}
        </router-link>
      </p>
    </div>
  </div>
</template>

<script>
import { useAuthStore } from '@/stores/authStore'
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useSystemStore } from '@/stores/systemStore'



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

    const handleLogin = () => {
      auth.login(form.value)
    }

    const goToForgotPassword = () => {
      router.push('/forgot-password')
    }

    return { form, handleLogin, auth, showPassword, goToForgotPassword, systemStore }
  }
}
</script>
