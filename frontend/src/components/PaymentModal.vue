<script setup lang="ts">
import { ref, watch } from 'vue'
import api from '@/axio'
import { useAuthStore } from '@/stores/authStore'

interface ServiceRequest {
  id: number
  provider: {
    paymentInfo?: {
      pagoMovil?: { banco: string; telefono: string; cedula: string }
      transferencia?: { banco: string; cuenta: string; cedula: string }
    }
  }
}

const props = defineProps<{ isOpen: boolean; request: ServiceRequest }>()
const emit = defineEmits<{
  (e: 'update:isOpen', value: boolean): void
  (e: 'on-payment-submit', method: string): void
}>()

const paymentMethod = ref<'efectivo' | 'pago-movil' | 'transferencia'>('efectivo')
const reference = ref('')
const captureFile = ref<File | null>(null)
const loading = ref(false)

// Reset campos al abrir modal
watch(() => props.isOpen, val => {
  if (val) {
    paymentMethod.value = 'efectivo'
    reference.value = ''
    captureFile.value = null
  }
})

function handleFileUpload(e: Event) {
  const target = e.target as HTMLInputElement
  if (target.files && target.files[0]) {
    captureFile.value = target.files[0]
  }
}

async function submitPayment() {
  if (!props.request?.id) {
    alert('Solicitud inválida')
    return
  }

  loading.value = true
  try {
    const authStore = useAuthStore()
    if (!authStore.token) {
      alert('Usuario no autenticado')
      return
    }

    const formData = new FormData()
    formData.append('serviceRequestId', props.request.id.toString())
    formData.append('paymentMethod', paymentMethod.value)
    formData.append('reference', reference.value || '')
    if (captureFile.value) formData.append('capture', captureFile.value)

    // Log de depuración
    console.log('Enviando pago:', {
      serviceRequestId: props.request.id,
      paymentMethod: paymentMethod.value,
      reference: reference.value,
      captureFile: captureFile.value,
      token: authStore.token
    })

    const res = await api.post('/payments', formData, {
      headers: {
        Authorization: `Bearer ${authStore.token}`,
        'Content-Type': 'multipart/form-data'
      }
    })

    if (!res.data?.success) {
      console.error('Error backend:', res.data)
      throw new Error(res.data?.error || 'Error al procesar el pago')
    }

    emit('update:isOpen', false)
    emit('on-payment-submit', paymentMethod.value)
  } catch (err: any) {
    console.error('Error submitPayment:', err)
    alert(err?.message || 'Hubo un problema al procesar el pago.')
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <transition name="fade">
    <div
      v-if="props.isOpen"
      class="fixed inset-0 z-[9999] bg-black bg-opacity-50 flex justify-center items-center overflow-auto"
    >
      <div class="bg-white rounded-lg w-full max-w-lg p-4 relative z-50">
        <h2 class="text-lg font-bold">Realizar Pago</h2>
        <p class="text-sm text-gray-500 mb-4">
          Selecciona un método de pago para completar la transacción.
        </p>

        <!-- Métodos de pago -->
        <div class="space-y-2">
          <label class="flex items-center gap-2 p-3 border rounded-md cursor-pointer">
            <input type="radio" value="efectivo" v-model="paymentMethod" />
            💵 Efectivo (al finalizar)
          </label>

          <label
            v-if="props.request.provider.paymentInfo?.pagoMovil"
            class="flex items-center gap-2 p-3 border rounded-md cursor-pointer"
          >
            <input type="radio" value="pago-movil" v-model="paymentMethod" />
            📱 Pago Móvil
          </label>

          <label
            v-if="props.request.provider.paymentInfo?.transferencia"
            class="flex items-center gap-2 p-3 border rounded-md cursor-pointer"
          >
            <input type="radio" value="transferencia" v-model="paymentMethod" />
            💳 Transferencia
          </label>
        </div>

        <!-- Detalles método -->
        <div
          v-if="paymentMethod === 'pago-movil' && props.request.provider.paymentInfo?.pagoMovil"
          class="mt-4 p-3 border rounded-md text-sm"
        >
          <p><strong>Banco:</strong> {{ props.request.provider.paymentInfo.pagoMovil.banco }}</p>
          <p><strong>Teléfono:</strong> {{ props.request.provider.paymentInfo.pagoMovil.telefono }}</p>
          <p><strong>CI/RIF:</strong> {{ props.request.provider.paymentInfo.pagoMovil.cedula }}</p>
        </div>

        <div
          v-if="paymentMethod === 'transferencia' && props.request.provider.paymentInfo?.transferencia"
          class="mt-4 p-3 border rounded-md text-sm"
        >
          <p><strong>Banco:</strong> {{ props.request.provider.paymentInfo.transferencia.banco }}</p>
          <p><strong>Cuenta:</strong> {{ props.request.provider.paymentInfo.transferencia.cuenta }}</p>
          <p><strong>CI/RIF:</strong> {{ props.request.provider.paymentInfo.transferencia.cedula }}</p>
        </div>

        <!-- Referencia y archivo -->
        <div v-if="paymentMethod !== 'efectivo'" class="mt-4 space-y-2">
          <label for="reference" class="block font-medium">Código de Referencia / Capture</label>
          <div class="flex items-center gap-2">
            <input
              id="reference"
              type="text"
              v-model="reference"
              placeholder="Nro. de referencia"
              class="flex-grow border rounded px-2 py-1"
            />
            <input id="capture-upload" type="file" class="hidden" @change="handleFileUpload" />
            <label for="capture-upload" class="p-2 border rounded cursor-pointer">📤</label>
          </div>
        </div>

        <!-- Footer -->
        <div class="mt-6 flex justify-end gap-2">
          <button @click="emit('update:isOpen', false)" class="px-4 py-2 border rounded">
            Cancelar
          </button>
          <button
            @click="submitPayment"
            class="px-4 py-2 bg-blue-600 text-white rounded disabled:opacity-50"
            :disabled="loading"
          >
            <span v-if="loading">Procesando...</span>
            <span v-else>Realizar Pago</span>
          </button>
        </div>
      </div>
    </div>
  </transition>
</template>

<style scoped>
.fade-enter-active, .fade-leave-active {
  transition: opacity 0.25s;
}
.fade-enter-from, .fade-leave-to {
  opacity: 0;
}

/* Forzar que el modal esté siempre encima */
.fixed {
  z-index: 9999 !important;
}
</style>
