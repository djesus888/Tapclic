<template>
  <div class="fixed inset-0 z-50 bg-black bg-opacity-60 flex items-center justify-center p-4"
       @click.self="$emit('close')">
    <div class="bg-white rounded-xl shadow-2xl max-w-lg w-full p-6 space-y-4">

      <!-- HEADER -->
      <div class="flex items-center justify-between">
        <h2 class="text-xl font-bold text-gray-800">Verificación de pago</h2>
        <button @click="$emit('close')"
                class="text-gray-400 hover:text-gray-600 text-2xl leading-none">&times;</button>
      </div>

      <!-- LOADING -->
      <div v-if="loading" class="text-center py-10 text-gray-500">Cargando comprobante…</div>

      <!-- CONTENT -->
      <div v-else class="space-y-3">
        <div class="grid grid-cols-2 gap-2 text-sm">
          <div><strong>Método:</strong> {{ proof.method }}</div>
          <div v-if="proof.reference"><strong>Referencia:</strong> {{ proof.reference }}</div>
          <div class="col-span-2"><strong>Estado actual:</strong> <PaymentPill :status="proof.status" /></div>
        </div>

        <!-- IMAGEN -->
        <div v-if="proof.proof_url" class="mt-4">
          <img :src="`http://localhost:8000${proof.proof_url}`"
               alt="Comprobante"
               class="rounded-lg border max-h-80 mx-auto object-contain">
        </div>

        <!-- ACCIONES -->
        <div v-if="proof.status === 'verifying'" class="mt-6 flex gap-3 justify-end">
          <button @click="reject"
                  class="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700">
            Rechazar
          </button>
          <button @click="confirm"
                  class="bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700">
            Confirmar pago
          </button>
        </div>
      </div>

      <!-- FOOTER -->
      <div class="flex justify-end pt-2">
        <button @click="$emit('close')"
                class="bg-gray-200 text-gray-800 px-4 py-2 rounded hover:bg-gray-300">
          Cerrar
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import api from '@/axios'
import { useAuthStore } from '@/stores/authStore'
import PaymentPill from './PaymentPill.vue'

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
  async mounted() {
    const auth = useAuthStore()
    try {
      const res = await api.get(`/payments/proof?request_id=${this.requestId}`, {
        headers: { Authorization: `Bearer ${auth.token}` }
      })
      this.proof = res.data
    } catch (e) {
      console.error(e)
      this.$toast?.error('No se pudo cargar el comprobante')
    } finally {
      this.loading = false
    }
  },
  methods: {
    async confirm() {
      const auth = useAuthStore()
      try {
        await api.post('/payments/confirm-payment', { id: this.proof.id }, {
          headers: { Authorization: `Bearer ${auth.token}` }
        })
        this.$toast?.success('Pago confirmado')
        this.$emit('close')
      } catch (e) {
        this.$toast?.error('Error al confirmar')
      }
    },
    async reject() {
      const auth = useAuthStore()
      try {
        await api.post('/payments/reject-payment', { id: this.proof.id }, {
          headers: { Authorization: `Bearer ${auth.token}` }
        })
        this.$toast?.success('Pago rechazado')
        this.$emit('close')
      } catch (e) {
        this.$toast?.error('Error al rechazar')
      }
    }
  }
}
</script>
