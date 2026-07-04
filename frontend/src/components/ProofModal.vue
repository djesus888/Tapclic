<template>
  <div
    class="fixed inset-0 z-50 bg-black bg-opacity-60 backdrop-blur-sm flex items-center justify-center p-4"
    @click.self="$emit('close')"
  >
    <div class="bg-white rounded-2xl shadow-2xl max-w-lg w-full overflow-hidden animate-slide-up">
      <!-- HEADER -->
      <div class="bg-gradient-to-r from-blue-600 to-purple-600 px-6 py-5">
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-3">
            <div class="w-10 h-10 bg-white bg-opacity-20 rounded-xl flex items-center justify-center text-xl">
              🔍
            </div>
            <div>
              <h2 class="text-xl font-bold text-white">{{ $t('payment_verification') }}</h2>
              <p class="text-blue-100 text-sm">{{ $t('review_client_receipt') }}</p>
            </div>
          </div>
          <button
            class="w-9 h-9 bg-white bg-opacity-20 hover:bg-opacity-30 rounded-lg text-white text-lg flex items-center justify-center transition-all"
            @click="$emit('close')"
          >
            ✕
          </button>
        </div>
      </div>

      <!-- LOADING -->
      <div v-if="loading" class="flex flex-col items-center justify-center py-16">
        <div class="w-12 h-12 border-4 border-blue-200 border-t-blue-600 rounded-full animate-spin mb-4"></div>
        <p class="text-gray-500">{{ $t('loading_receipt') }}</p>
      </div>

      <!-- CONTENT -->
      <div v-else class="p-6 space-y-5">
        <!-- Datos del pago -->
        <div class="bg-gray-50 rounded-xl p-4 grid grid-cols-2 gap-3 text-sm">
          <div class="flex items-center gap-2">
            <span class="text-gray-400">💳</span>
            <div>
              <span class="text-xs text-gray-500 block">{{ $t('method') }}</span>
              <strong class="text-gray-800">{{ methodLabel }}</strong>
            </div>
          </div>
          <div class="flex items-center gap-2" v-if="proof.reference">
            <span class="text-gray-400">#️⃣</span>
            <div>
              <span class="text-xs text-gray-500 block">{{ $t('reference') }}</span>
              <strong class="text-gray-800">{{ proof.reference }}</strong>
            </div>
          </div>
          <div class="col-span-2 flex items-center gap-2">
            <span class="text-gray-400">📊</span>
            <div>
              <span class="text-xs text-gray-500 block">{{ $t('status') }}</span>
              <PaymentPill :status="proof.status" />
            </div>
          </div>
        </div>

        <!-- PAGO EN EFECTIVO -->
        <div v-if="isCash" class="bg-green-50 border border-green-200 rounded-xl p-6 text-center">
          <div class="text-4xl mb-3">💵</div>
          <h4 class="text-green-800 font-semibold text-lg mb-1">{{ $t('cash_payment') }}</h4>
          <p class="text-green-600 text-sm">{{ $t('cash_payment_description') }}</p>
          <div class="mt-3 bg-white rounded-lg p-2 text-green-700 text-xs font-medium">
            {{ $t('no_receipt_needed') }}
          </div>
        </div>

        <!-- IMAGEN DEL COMPROBANTE -->
        <div v-else-if="proof.proof_url" class="relative">
          <div class="absolute -top-3 left-1/2 -translate-x-1/2 bg-gray-800 text-white text-xs px-3 py-1 rounded-full z-10">
            📸 {{ $t('receipt') }}
          </div>
          <div class="bg-gray-100 rounded-xl p-2 pt-5">
            <img
              :src="getImageUrl(proof.proof_url, 'payments')"
              alt="Comprobante de pago"
              class="rounded-lg w-full max-h-72 object-contain cursor-pointer hover:opacity-95 transition-opacity"
              @click="openImageFull"
            />
          </div>
          <p class="text-center text-xs text-gray-400 mt-2">{{ $t('click_to_enlarge') }}</p>
        </div>

        <!-- ACCIONES -->
        <div v-if="proof.status === 'verifying'" class="bg-amber-50 border border-amber-200 rounded-xl p-4">
          <p class="text-amber-800 text-sm font-medium mb-3">⚡ {{ $t('payment_pending_verification') }}</p>
          <div class="flex gap-3">
            <button
              class="flex-1 bg-red-500 hover:bg-red-600 text-white px-4 py-3 rounded-xl font-semibold text-sm transition-all hover:shadow-lg hover:shadow-red-200 flex items-center justify-center gap-2"
              @click="reject"
            >
              <span>✕</span> {{ $t('reject') }}
            </button>
            <button
              class="flex-1 bg-green-500 hover:bg-green-600 text-white px-4 py-3 rounded-xl font-semibold text-sm transition-all hover:shadow-lg hover:shadow-green-200 flex items-center justify-center gap-2"
              @click="confirm"
            >
              <span>✓</span> {{ isCash ? $t('confirm_cash') : $t('confirm_payment') }}
            </button>
          </div>
        </div>

        <!-- Estado ya procesado -->
        <div v-else class="bg-gray-50 rounded-xl p-4 text-center">
          <span v-if="proof.status === 'paid'" class="text-green-600 font-semibold">✅ {{ $t('payment_confirmed') }}</span>
          <span v-else-if="proof.status === 'rejected'" class="text-red-600 font-semibold">❌ {{ $t('payment_rejected') }}</span>
        </div>

        <!-- FOOTER -->
        <div class="flex justify-end pt-2 border-t border-gray-100">
          <button
            class="bg-gray-100 hover:bg-gray-200 text-gray-700 px-5 py-2.5 rounded-xl font-medium text-sm transition-all"
            @click="$emit('close')"
          >
            {{ $t('close') }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import api from '@/axios'
import { useAuthStore } from '@/stores/authStore'
import PaymentPill from './PaymentPill.vue'
import { getImageUrl } from '@/utils/imageHelper'

export default {
  name: 'ProofModal',
  components: { PaymentPill },
  props: {
    requestId: { type: Number, required: true }
  },
  data() {
    return {
      proof: {},
      loading: true
    }
  },
  computed: {
    isCash() {
      return this.proof.method === 'efectivo' && !this.proof.proof_url
    },
    methodLabel() {
      const labels = {
        'efectivo': this.$t('cash'),
        'pago-movil': this.$t('pago_movil'),
        'transferencia': this.$t('transfer'),
        'paypal': 'PayPal',
        'zelle': 'Zelle'
      }
      return labels[this.proof.method] || this.proof.method || '-'
    }
  },
  async mounted() {
    const auth = useAuthStore()
    try {
      const res = await api.get(`/payments/proof?request_id=${this.requestId}`, {
        headers: { Authorization: `Bearer ${auth.token}` }
      })
      this.proof = res.data
    } catch (e) {
      console.error(e)
      this.$toast?.error(this.$t('receipt_load_failed'))
    } finally {
      this.loading = false
    }
  },
  methods: {
    getImageUrl,
    openImageFull() {
      if (this.proof.proof_url) {
        window.open(getImageUrl(this.proof.proof_url, 'payments'), '_blank')
      }
    },
    async confirm() {
      const auth = useAuthStore()
      try {
        await api.post('/payments/confirm-payment', { id: this.proof.id }, {
          headers: { Authorization: `Bearer ${auth.token}` }
        })
        this.$toast?.success(this.$t('payment_confirmed'))
        this.$emit('close')
      } catch (e) {
        this.$toast?.error(this.$t('confirm_error'))
      }
    },
    async reject() {
      const auth = useAuthStore()
      try {
        await api.post('/payments/reject-payment', { id: this.proof.id }, {
          headers: { Authorization: `Bearer ${auth.token}` }
        })
        this.$toast?.success(this.$t('payment_rejected'))
        this.$emit('close')
      } catch (e) {
        this.$toast?.error(this.$t('reject_error'))
      }
    }
  }
}
</script>

<style scoped>
.animate-slide-up {
  animation: slideUp 0.3s ease-out;
}
@keyframes slideUp {
  from { transform: translateY(30px); opacity: 0; }
  to { transform: translateY(0); opacity: 1; }
}
</style>
