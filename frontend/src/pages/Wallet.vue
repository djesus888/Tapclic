<template>
  <div class="p-4 bg-white dark:bg-gray-900 rounded-xl shadow-md">
    <h2 class="text-xl font-bold mb-4 text-gray-800 dark:text-white">
      {{ $t('wallet.title') }}
    </h2>

    <!-- Saldo actual -->
    <div class="mb-6 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 bg-gray-100 dark:bg-gray-800 p-4 rounded-lg">
      <div>
        <p class="text-sm text-gray-600 dark:text-gray-300">
          {{ $t('wallet.currentBalance') }}
        </p>
        <p class="text-2xl font-bold text-gray-900 dark:text-white break-all">
          €{{ balance.toFixed(2) }}
        </p>
      </div>

      <!-- Botones pequeños y envoltorio flexible -->
      <div class="flex flex-wrap gap-2">
        <button @click="openModal('recharge')"
                class="bg-blue-600 text-white px-3 py-2 text-sm rounded-md hover:bg-blue-700">
          {{ $t('wallet.recharge') }}
        </button>
        <button @click="openModal('withdraw')"
                class="bg-red-600 text-white px-3 py-2 text-sm rounded-md hover:bg-red-700">
          {{ $t('wallet.withdraw') }}
        </button>
      </div>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="text-center py-10 text-gray-500 dark:text-gray-400">
      {{ $t('loading') }}...
    </div>

    <!-- Historial -->
    <div v-else class="space-y-3">
      <div
        v-for="tx in transactions"
        :key="tx.id"
        class="border-b pb-3 break-words"
      >
        <div class="flex justify-between items-center gap-2">
          <div class="min-w-0 flex-1">
            <p class="text-sm font-medium text-gray-800 dark:text-white truncate">
              {{ txDescription(tx) }}
            </p>
            <p class="text-xs text-gray-500 dark:text-gray-400">
              {{ formatDate(tx.created_at) }}
            </p>
          </div>
          <p
            :class="txColor(tx.type)"
            class="font-semibold whitespace-nowrap"
          >
            {{ txSign(tx.type) }}€{{ tx.amount.toFixed(2) }}
          </p>
        </div>
      </div>

      <!-- Vacío -->
      <div v-if="transactions.length === 0" class="text-center text-gray-500 dark:text-gray-400 py-6">
        {{ $t('wallet.noTransactions') }}
      </div>
    </div>

    <!-- Modal -->
    <div v-if="showModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div class="bg-white dark:bg-gray-900 p-6 rounded-lg shadow-xl w-full max-w-md">
        <h3 class="text-lg font-semibold mb-4 text-gray-800 dark:text-white">
          {{ modalTitle }}
        </h3>

        <input
          type="number"
          v-model="amount"
          min="1"
          step="0.01"
          class="w-full mb-4 border rounded-md px-3 py-2 dark:bg-gray-800 dark:text-white"
          :placeholder="$t('wallet.enterAmount')"
        />

        <div class="flex justify-end gap-2">
          <button @click="showModal = false"
                  class="bg-gray-300 px-4 py-2 rounded-md dark:bg-gray-700 dark:text-white">
            {{ $t('actions.cancel') }}
          </button>
          <button @click="submit"
                  class="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700">
            {{ $t('actions.confirm') }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useAuthStore } from '@/stores/authStore'
import { useI18n } from 'vue-i18n'
import api from '@/axios'
import Swal from 'sweetalert2'

const { t } = useI18n()
const auth = useAuthStore()

/* ---------- Estado ---------- */
const balance       = ref(0)
const transactions  = ref([])
const loading       = ref(true)
const showModal     = ref(false)
const modalType     = ref<'recharge' | 'withdraw'>('recharge')
const amount        = ref('')

/* ---------- Computed ---------- */
const modalTitle = computed(() =>
  modalType.value === 'recharge'
    ? t('wallet.rechargeTitle')
    : t('wallet.withdrawTitle')
)

/* ---------- Funciones auxiliares ---------- */
const txDescription = (tx: any) => tx.description || t('wallet.noDescription')
const txColor       = (type: string) => (type === 'credit' ? 'text-green-600' : 'text-red-600')
const txSign        = (type: string) => (type === 'credit' ? '+' : '-')
const formatDate    = (date: string) => new Date(date).toLocaleDateString()

/* ---------- Carga inicial ---------- */
const loadWallet = async () => {
  loading.value = true
  try {
    const { data } = await api.get('/wallet/get', {
      headers: { Authorization: `Bearer ${auth.token}` }
    })
    balance.value      = data.balance || 0
    transactions.value = data.transactions || []
  } catch (err: any) {
    console.error(err)
    Swal.fire(t('errors.generic'), t('wallet.loadFailed'), 'error')
  } finally {
    loading.value = false
  }
}

/* ---------- Modal ---------- */
const openModal = (type: 'recharge' | 'withdraw') => {
  modalType.value = type
  amount.value    = ''
  showModal.value = true
}

const submit = async () => {
  const num = Number(amount.value)
  if (!num || num <= 0) {
    Swal.fire(t('errors.validation'), t('wallet.invalidAmount'), 'error')
    return
  }

  const endpoint = modalType.value === 'recharge' ? '/wallet/recharge' : '/wallet/withdraw'

  try {
    await api.post(endpoint, { amount: num }, {
      headers: { Authorization: `Bearer ${auth.token}` }
    })
    showModal.value = false
    await loadWallet()
    Swal.fire(t('success.title'), t('wallet.operationSuccess'), 'success')
  } catch (err: any) {
    const msg = err?.response?.data?.error || t('errors.generic')
    Swal.fire(t('errors.title'), msg, 'error')
  }
}

/* ---------- Montaje ---------- */
onMounted(() => {
  loadWallet()
})
</script>

<style scoped>
/* Evita desbordes en móvil */
.wallet-card {
  @apply p-4 bg-white dark:bg-gray-900 rounded-xl shadow-md;
}

.balance-box {
  @apply flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 bg-gray-100 dark:bg-gray-800 p-4 rounded-lg;
}

.action-buttons {
  @apply flex flex-wrap gap-2;
}
.action-buttons button {
  @apply px-3 py-2 text-sm rounded-md;
}

.tx-item {
  @apply border-b pb-3 break-words;
}

.modal-inner {
  @apply w-full max-w-md mx-4;
}
</style>
