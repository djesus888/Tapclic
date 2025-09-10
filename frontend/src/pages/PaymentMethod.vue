<script setup lang="ts">
import { ref, reactive, computed, onMounted, h } from 'vue'
import api from '@/axio'
import { useAuthStore } from '@/stores/authStore'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
const authStore = useAuthStore()

/* ---------- tipos ---------- */
type MethodType = 'pago_movil' | 'transferencia' | 'zelle' | 'paypal' | 'binance'

interface PaymentMethod {
  id?: number
  method_type: MethodType
  bank_name?: string
  holder_name: string
  id_number: string
  phone_number?: string
  account_number?: string
  email?: string
  qr_url?: string
  is_active: boolean
}

/* ---------- estado ---------- */
const methods   = ref<PaymentMethod[]>([])
const loading   = ref(false)
const editingId = ref<number | null>(null)

const form = reactive<PaymentMethod>({
  method_type: 'pago_movil',
  holder_name: '',
  id_number: '',
  phone_number: '',
  bank_name: '',
  account_number: '',
  email: '',
  qr_url: '',
  is_active: true
})

/* ---------- validaciones ---------- */
const isFormValid = computed(() => {
  const f = form
  return !!f.holder_name.trim() && !!f.id_number.trim()
})

/* ---------- iconos (componentes funcionales) ---------- */
const PhoneIcon = () => h('svg', { class: 'w-4 h-4', fill: 'none', stroke: 'currentColor', viewBox: '0 0 24 24' },
  h('path', { 'stroke-linecap': 'round', 'stroke-linejoin': 'round', 'stroke-width': '2', d: 'M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z' }))
const BankIcon  = () => h('svg', { class: 'w-4 h-4', fill: 'none', stroke: 'currentColor', viewBox: '0 0 24 24' },
  h('path', { 'stroke-linecap': 'round', 'stroke-linejoin': 'round', 'stroke-width': '2', d: 'M3 6l3 1m0 0l-3 9a5.002 5.002 0 006.001 0M6 7l3 9M6 7l6-2m6 2l3-1m-3 1l-3 9a5.002 5.002 0 006.001 0M18 7l3 9m-3-9l-6-2m0-2v2m0 16V5m0 16H9m3 0h3' }))
const HashIcon  = () => h('svg', { class: 'w-4 h-4', fill: 'none', stroke: 'currentColor', viewBox: '0 0 24 24' },
  h('path', { 'stroke-linecap': 'round', 'stroke-linejoin': 'round', 'stroke-width': '2', d: 'M7 20l4-16m2 16l4-16M6 9h14M4 15h14' }))
const MailIcon  = () => h('svg', { class: 'w-4 h-4', fill: 'none', stroke: 'currentColor', viewBox: '0 0 24 24' },
  h('path', { 'stroke-linecap': 'round', 'stroke-linejoin': 'round', 'stroke-width': '2', d: 'M3 8l7.89 4.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z' }))

/* ---------- CRUD ---------- */
async function fetchMethods() {
  try {
    const { data } = await api.get('/provider/payment-methods', {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    methods.value = (data.methods || []).filter((m: any) => m?.method_type)
  } catch {
    methods.value = []
  }
}

async function saveMethod() {
  if (!isFormValid.value) return
  loading.value = true
  try {
    const payload = { ...form }
    if (editingId.value) {
      await api.put(`/provider/payment-methods/${editingId.value}`, payload, {
        headers: { Authorization: `Bearer ${authStore.token}` }
      })
    } else {
      await api.post('/provider/payment-methods', payload, {
        headers: { Authorization: `Bearer ${authStore.token}` }
      })
    }
    resetForm()
    await fetchMethods()
  } catch (e: any) {
    alert(e?.response?.data?.error || t('errors.save'))
  } finally {
    loading.value = false
  }
}

async function deleteMethod(id: number) {
  if (!confirm(t('confirm.delete'))) return
  try {
    await api.delete(`/provider/payment-methods/${id}`, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    await fetchMethods()
  } catch {
    alert(t('errors.delete'))
  }
}

async function toggleStatus(m: PaymentMethod) {
  try {
    await api.put(`/provider/payment-methods/${m.id}`, { ...m, is_active: !m.is_active }, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    await fetchMethods()
  } catch {
    alert(t('errors.toggle'))
  }
}

function editMethod(m: PaymentMethod) {
  if (!m || !m.id || !m.method_type) return
  Object.assign(form, { ...m })
  editingId.value = m.id
}

function resetForm() {
  Object.assign(form, {
    method_type: 'pago_movil',
    holder_name: '',
    id_number: '',
    phone_number: '',
    bank_name: '',
    account_number: '',
    email: '',
    qr_url: '',
    is_active: true
  })
  editingId.value = null
}

onMounted(fetchMethods)
</script>

<template>
  <div class="max-w-5xl mx-auto p-4 sm:p-6">
    <h1 class="text-3xl font-extrabold text-gray-800 mb-6">{{ $t('paymentMethods.title') }}</h1>

    <!-- Formulario -->
    <form @submit.prevent="saveMethod" class="bg-white rounded-xl shadow-md p-5 mb-6 space-y-4">
      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">{{ $t('paymentMethods.type') }}</label>
          <select v-model="form.method_type" class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500">
            <option value="pago_movil">{{ $t('methods.pagoMovil') }}</option>
            <option value="transferencia">{{ $t('methods.transferencia') }}</option>
            <option value="zelle">Zelle</option>
            <option value="paypal">PayPal</option>
            <option value="binance">Binance</option>
          </select>
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">{{ $t('paymentMethods.holder') }}</label>
          <input v-model="form.holder_name" maxlength="100" required class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500" />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">{{ $t('paymentMethods.idNumber') }}</label>
          <input v-model="form.id_number" maxlength="20" required class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500" />
        </div>

        <div v-if="form.method_type === 'pago_movil'">
          <label class="block text-sm font-medium text-gray-700 mb-1">{{ $t('paymentMethods.phone') }}</label>
          <input v-model="form.phone_number" maxlength="20" class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500" />
        </div>

        <div v-if="['pago_movil','transferencia'].includes(form.method_type)">
          <label class="block text-sm font-medium text-gray-700 mb-1">{{ $t('paymentMethods.bank') }}</label>
          <input v-model="form.bank_name" maxlength="50" class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500" />
        </div>

        <div v-if="form.method_type === 'transferencia'">
          <label class="block text-sm font-medium text-gray-700 mb-1">{{ $t('paymentMethods.account') }}</label>
          <input v-model="form.account_number" maxlength="20" class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500" />
        </div>

        <div v-if="['zelle','paypal','binance'].includes(form.method_type)">
          <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
          <input v-model="form.email" type="email" maxlength="100" class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500" />
        </div>

        <div class="flex items-center gap-2">
          <input v-model="form.is_active" type="checkbox" class="h-4 w-4 text-blue-600 rounded" />
          <span class="text-sm text-gray-700">{{ $t('paymentMethods.active') }}</span>
        </div>
      </div>

      <div class="flex items-center gap-3 pt-2">
        <button type="submit" :disabled="!isFormValid || loading" class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 transition">
          {{ editingId ? $t('actions.update') : $t('actions.add') }}
        </button>
        <button type="button" @click="resetForm" class="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition">
          {{ $t('actions.cancel') }}
        </button>
      </div>
    </form>

    <!-- Lista -->
    <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
      <div v-for="m in methods" :key="m.id" class="bg-white rounded-xl shadow hover:shadow-lg transition p-4 flex flex-col justify-between">
        <div>
          <div class="flex items-start justify-between mb-2">
            <span class="inline-block px-2 py-1 text-xs font-semibold rounded-full bg-blue-100 text-blue-800">
              {{ $t('methods.' + m.method_type) }}
            </span>
            <label class="relative inline-flex items-center cursor-pointer">
              <input type="checkbox" :checked="m.is_active" @change="toggleStatus(m)" class="sr-only peer">
              <div class="w-9 h-5 bg-gray-200 rounded-full peer peer-checked:bg-blue-600 peer-focus:ring-2 peer-focus:ring-blue-300"></div>
              <span class="ml-2 text-xs text-gray-600">{{ $t('paymentMethods.active') }}</span>
            </label>
          </div>
          <p class="text-sm text-gray-900 font-medium">{{ m.holder_name }}</p>
          <p class="text-xs text-gray-500">{{ $t('paymentMethods.id') }}: {{ m.id_number }}</p>
          <div class="mt-2 space-y-1 text-xs text-gray-600">
            <p v-if="m.phone_number" class="flex items-center gap-2"><PhoneIcon /> {{ m.phone_number }}</p>
            <p v-if="m.bank_name" class="flex items-center gap-2"><BankIcon /> {{ m.bank_name }}</p>
            <p v-if="m.account_number" class="flex items-center gap-2"><HashIcon /> {{ m.account_number }}</p>
            <p v-if="m.email" class="flex items-center gap-2"><MailIcon /> {{ m.email }}</p>
          </div>
        </div>
        <div class="mt-4 flex items-center justify-end gap-2">
          <button @click="editMethod(m)" class="text-sm text-blue-600 hover:underline">{{ $t('actions.edit') }}</button>
          <button @click="deleteMethod(m.id!)" class="text-sm text-red-600 hover:underline">{{ $t('actions.delete') }}</button>
        </div>
      </div>
      <div v-if="!methods.length" class="col-span-full text-center text-gray-500 py-10">{{ $t('paymentMethods.empty') }}</div>
    </div>
  </div>
</template>
