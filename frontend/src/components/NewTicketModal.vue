<!-- NewTicketModal.vue -->
<template>
  <!-- Modal backdrop -->
  <Teleport to="body">
    <div
      v-if="isOpen"
      class="fixed inset-0 z-50 flex items-center justify-center bg-black/40"
      @click.self="$emit('close')"
    >
      <div class="bg-white rounded-lg shadow-xl w-full max-w-md mx-4">
        <!-- Header -->
        <div class="flex justify-between items-center border-b px-4 py-3">
          <h2 class="text-lg font-semibold">{{ $t('new_support_ticket') }}</h2>
          <button
            @click="$emit('close')"
            class="text-gray-400 hover:text-gray-600"
            aria-label="Cerrar"
          >
            ✕
          </button>
        </div>

        <!-- Body -->
        <form @submit.prevent="submitTicket" class="px-4 py-4 space-y-4">
          <!-- Título -->
          <div>
            <label class="block text-sm font-medium mb-1">{{ $t('ticket_subject') }}</label>
            <input
              v-model="form.subject"
              type="text"
              class="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              required
            />
          </div>

          <!-- Descripción -->
          <div>
            <label class="block text-sm font-medium mb-1">{{ $t('description') }}</label>
            <textarea
              v-model="form.description"
              rows="4"
              class="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              required
            ></textarea>
          </div>

          <!-- Categoría (opcional) -->
          <div>
            <label class="block text-sm font-medium mb-1">{{ $t('category') }}</label>
            <select v-model="form.category" class="w-full border border-gray-300 rounded-md px-3 py-2">
              <option value="">{{ $t('select_category') }}</option>
              <option value="payment">{{ $t('payment_issues') }}</option>
              <option value="service">{{ $t('service_issues') }}</option>
              <option value="technical">{{ $t('technical_issues') }}</option>
              <option value="account">{{ $t('account_issues') }}</option>
              <option value="other">{{ $t('other') }}</option>
            </select>
          </div>

          <!-- Botones -->
          <div class="flex justify-end gap-2 pt-2">
            <button
              type="button"
              @click="$emit('close')"
              class="px-4 py-2 text-sm rounded-md border border-gray-300 hover:bg-gray-100"
            >
              {{ $t('cancel') }}
            </button>
            <button
              type="submit"
              :disabled="loading"
              class="px-4 py-2 text-sm rounded-md bg-blue-600 text-white hover:bg-blue-700 disabled:opacity-50"
            >
              {{ loading ? $t('sending') + '...' : $t('send') }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </Teleport>
</template>

<script>
import api from '@/axio'
import { useAuthStore } from '@/stores/authStore'

export default {
  name: 'NewTicketModal',
  props: {
    isOpen: { type: Boolean, required: true }
  },
  emits: ['close', 'ticket-created'],
  data() {
    return {
      loading: false,
      form: {
        subject: '',
        description: '',
        category: ''
      }
    }
  },
  methods: {
    async submitTicket() {
      this.loading = true
      try {
        const authStore = useAuthStore()
        const payload = {
          subject: this.form.subject,
          description: this.form.description,
          category: this.form.category || 'other'
        }

        await api.post('/support/tickets/create', payload, {
          headers: authStore?.token ? { Authorization: `Bearer ${authStore.token}` } : {}
        })

        this.$emit('ticket-created')
        this.$swal?.fire({
          icon: 'success',
          title: this.$t('ticket_sent'),
          text: this.$t('ticket_sent_message'),
          timer: 2000,
          showConfirmButton: false
        })
      } catch (err) {
        console.error(err)
        this.$swal?.fire({ icon: 'error', title: 'Error', text: err.message })
      } finally {
        this.loading = false
      }
    }
  },
  // 👇 AGREGAR SOLO ESTAS 5 LÍNEAS
  watch: {
    '$i18n.locale'() {
      this.$forceUpdate()
    }
  }
}
</script>
