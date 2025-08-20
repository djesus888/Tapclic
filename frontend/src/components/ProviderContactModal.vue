<template>
  <div v-if="isOpen" class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-30">
    <div class="bg-white rounded-xl w-full max-w-sm p-6 text-center">

      <!-- Estado pendiente -->
      <template v-if="status === 'pending'">
        <p class="text-lg">Contactando a {{ providerName }}</p>
        <p class="text-gray-600 mt-2">Esperando respuesta del proveedor...</p>
        <div class="mt-4 flex flex-col items-center space-y-2">
          <span class="text-3xl">⏳</span>
          <p class="text-xl font-mono">{{ formatTime(countdown) }}</p>
        </div>
      </template>

      <!-- Estado aceptado -->
      <template v-else-if="status === 'accepted'">
        <p class="text-green-600 text-lg">¡Servicio Aceptado!</p>
        <p>{{ providerName }} aceptó tu solicitud.</p>
        <div class="mt-4">
          <button @click="$emit('openPayment')" class="px-4 py-2 bg-green-600 text-white rounded-lg">
            Proceder al Pago
          </button>
        </div>
      </template>

      <!-- Estado rechazado -->
      <template v-else-if="status === 'rejected'">
        <p class="text-red-600 text-lg">Solicitud Rechazada</p>
        <p>{{ providerName }} no puede atender tu solicitud.</p>
        <div class="mt-4 flex justify-center gap-2">
          <button @click="$emit('cancel')" class="px-4 py-2 border rounded-lg">Cancelar</button>
          <button @click="retry" class="px-4 py-2 bg-blue-600 text-white rounded-lg">Intentar de Nuevo</button>
        </div>
      </template>

      <!-- Estado ocupado -->
      <template v-else-if="status === 'busy'">
        <p class="text-yellow-600 text-lg">Proveedor Ocupado</p>
        <p>{{ providerName }} está ocupado en este momento.</p>
        <div class="mt-4 flex justify-center gap-2">
          <button @click="$emit('cancel')" class="px-4 py-2 border rounded-lg">Cancelar</button>
          <button @click="retry" class="px-4 py-2 bg-blue-600 text-white rounded-lg">Intentar más tarde</button>
        </div>
      </template>

      <!-- Estado sin respuesta -->
      <template v-else-if="status === 'no-response'">
        <p class="text-gray-600 text-lg">Sin Respuesta</p>
        <p>{{ providerName }} no respondió en el tiempo establecido.</p>
        <div class="mt-4 flex justify-center gap-2">
          <button @click="$emit('cancel')" class="px-4 py-2 border rounded-lg">Cancelar</button>
          <button @click="retry" class="px-4 py-2 bg-blue-600 text-white rounded-lg">Intentar de Nuevo</button>
        </div>
      </template>

    </div>
  </div>
</template>

<script setup>
import { ref, watch, onMounted, onUnmounted } from 'vue'
import api from '@/axio'

const props = defineProps({
  isOpen: Boolean,
  providerName: String,
  requestId: Number // ID de la solicitud en el backend
})

const emit = defineEmits(['cancel', 'openPayment'])

const status = ref('pending')
const countdown = ref(90)
let pollInterval = null
let timerInterval = null

// Formatear tiempo
const formatTime = (seconds) => {
  const m = String(Math.floor(seconds / 60)).padStart(2, '0')
  const s = String(seconds % 60).padStart(2, '0')
  return `${m}:${s}`
}

// Reiniciar proceso
const reset = () => {
  status.value = 'pending'
  countdown.value = 90
}

// Reintentar
const retry = () => {
  reset()
  startProcess()
}

// Inicia el polling y el contador
const startProcess = () => {
  stopProcess()

  // Contador regresivo
  timerInterval = setInterval(() => {
    countdown.value--
    if (countdown.value <= 0 && status.value === 'pending') {
      status.value = 'no-response'
      stopProcess()
    }
  }, 1000)

  // Polling al backend
  pollInterval = setInterval(async () => {
    try {
      const { data } = await api.get(`/requests/status/${props.requestId}`)
      if (['accepted', 'rejected', 'busy'].includes(data.status)) {
        status.value = data.status
        stopProcess()
      }
    } catch (err) {
      console.error('Error al obtener estado del proveedor', err)
    }
  }, 3000) // cada 3 segundos
}

// Detener polling y contador
const stopProcess = () => {
  if (pollInterval) clearInterval(pollInterval)
  if (timerInterval) clearInterval(timerInterval)
}

// Vigilar apertura del modal
watch(() => props.isOpen, (val) => {
  if (val) {
    reset()
    startProcess()
  } else {
    stopProcess()
  }
})

onUnmounted(() => {
  stopProcess()
})

defineExpose({ startProcess, retry });
</script>
