<template>
  <div class="p-4 bg-white dark:bg-gray-900 rounded-xl shadow-md">
    <h2 class="text-xl font-bold mb-4 text-gray-800 dark:text-white">
      {{ $t('wallet') }}
    </h2>

    <!-- Saldo actual -->
    <div class="mb-6 flex items-center justify-between bg-gray-100 dark:bg-gray-800 p-4 rounded-lg">
      <div>
        <p class="text-sm text-gray-600 dark:text-gray-300">
          {{ $t('current_balance') }}
        </p>
        <p class="text-2xl font-bold text-gray-900 dark:text-white">
          €{{ balance.toFixed(2) }}
        </p>
      </div>

      <!-- Acciones -->
      <div class="flex gap-2">
        <button @click="openModal('recharge')"
                class="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700">
          {{ $t('recharge') }}
        </button>
        <button @click="openModal('withdraw')"
                class="bg-red-600 text-white px-4 py-2 rounded-md hover:bg-red-700">
          {{ $t('withdraw') }}
        </button>
      </div>
    </div>

    <!-- Historial de transacciones -->
    <div class="space-y-3">
      <div
        v-for="tx in transactions"
        :key="tx.id"
        class="border-b pb-3"
      >
        <div class="flex justify-between items-center">
          <div>
            <p class="text-sm font-medium text-gray-800 dark:text-white">
              {{ tx.description }}
            </p>
            <p class="text-xs text-gray-500 dark:text-gray-400">
              {{ formatDate(tx.created_at) }}
            </p>
          </div>
          <p
            :class="{
              'text-green-600': tx.type === 'credit',
              'text-red-600': tx.type === 'debit'
            }"
            class="font-semibold"
          >
            {{ tx.type === 'credit' ? '+' : '-' }}€{{ tx.amount.toFixed(2) }}
          </p>
        </div>
      </div>
    </div>

    <!-- Modal -->
    <div v-if="showModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white dark:bg-gray-900 p-6 rounded-lg shadow-xl w-full max-w-md">
        <h3 class="text-lg font-semibold mb-4 text-gray-800 dark:text-white">
          {{ modalType === 'recharge' ? $t('recharge_wallet') : $t('withdraw_wallet') }}
        </h3>

        <input type="number"
               v-model="amount"
               min="1"
               step="0.01"
               class="w-full mb-4 border rounded-md px-3 py-2 dark:bg-gray-800 dark:text-white"
               :placeholder="$t('enter_amount')" />

        <div class="flex justify-end gap-2">
          <button @click="showModal = false"
                  class="bg-gray-300 px-4 py-2 rounded-md dark:bg-gray-700 dark:text-white">
            {{ $t('cancel') }}
          </button>
          <button @click="submit"
                  class="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700">
            {{ $t('confirm') }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useAuthStore } from '@/stores/authStore'
import axios from 'axios'
import Swal from 'sweetalert2'

const auth = useAuthStore()
const balance = ref(0)
const transactions = ref([])
const showModal = ref(false)
const modalType = ref('recharge') // 'recharge' | 'withdraw'
const amount = ref('')

const loadWallet = async () => {
  try {
    const { data } = await axios.get('/api/wallet/get', {
      headers: { Authorization: `Bearer ${auth.token}` }
    })
    balance.value = data.balance
    transactions.value = data.transactions
  } catch (err) {
    console.error(err)
    Swal.fire('Error', 'No se pudo cargar la información de la wallet.', 'error')
  }
}

const openModal = (type) => {
  modalType.value = type
  amount.value = ''
  showModal.value = true
}

const submit = async () => {
  if (!amount.value || amount.value <= 0) {
    return Swal.fire('Error', 'Introduce un monto válido.', 'error')
  }

  const endpoint = modalType.value === 'recharge' ? '/api/wallet/recharge' : '/api/wallet/withdraw'

  try {
    await axios.post(endpoint, { amount: amount.value }, {
      headers: { Authorization: `Bearer ${auth.token}` }
    })
    showModal.value = false
    loadWallet()
    Swal.fire('Éxito', 'Operación completada correctamente.', 'success')
  } catch (err) {
    Swal.fire('Error', 'Hubo un problema en la transacción.', 'error')
  }
}

const formatDate = (date) => {
  return new Date(date).toLocaleDateString()
}

onMounted(() => {
  loadWallet()
})
</script>
