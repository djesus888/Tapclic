<template>
  <div
    v-if="isOpen"
    class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-30"
  >
    <div class="bg-white rounded-xl w-full max-w-sm p-6 text-center">
      <!-- Estado pendiente -->
      <template v-if="status === 'pending'">
        <p class="text-lg">{{ $t('contacting_provider', { name: providerName }) }}</p>
        <p class="text-gray-600 mt-2">{{ $t('waiting_provider_response') }}</p>
        <div class="mt-4 flex flex-col items-center space-y-2">
          <span class="text-3xl">⏳</span>
          <p class="text-xl font-mono">{{ formatTime(countdown) }}</p>
        </div>
      </template>

      <!-- Estado aceptado -->
      <template v-else-if="status === 'accepted'">
        <p class="text-green-600 text-lg">{{ $t('service_accepted') }}</p>
        <p>{{ $t('provider_accepted_request', { name: providerName }) }}</p>
        <div class="mt-4">
          <button
            @click="$emit('openPayment')"
            class="px-4 py-2 bg-green-600 text-white rounded-lg"
          >
            {{ $t('proceed_to_payment') }}
          </button>
        </div>
      </template>

      <!-- Estado rechazado -->
      <template v-else-if="status === 'rejected'">
        <p class="text-red-600 text-lg">{{ $t('request_rejected') }}</p>
        <p>{{ $t('provider_rejected_request', { name: providerName }) }}</p>
        <div class="mt-4 flex justify-center gap-2">
          <button
            @click="handleCancel"
            class="px-4 py-2 border rounded-lg"
          >
            {{ $t('cancel') }}
          </button>
          <button
            @click="handleRetry"
            class="px-4 py-2 bg-blue-600 text-white rounded-lg"
          >
            {{ $t('try_again') }}
          </button>
        </div>
      </template>

      <!-- Estado ocupado -->
      <template v-else-if="status === 'busy'">
        <p class="text-yellow-600 text-lg">{{ $t('provider_busy') }}</p>
        <p>{{ $t('provider_is_busy', { name: providerName }) }}</p>
        <div class="mt-4 flex justify-center gap-2">
          <button
            @click="handleCancel"
            class="px-4 py-2 border rounded-lg"
          >
            {{ $t('cancel') }}
          </button>
          <button
            @click="handleRetry"
            class="px-4 py-2 bg-blue-600 text-white rounded-lg"
          >
            {{ $t('try_later') }}
          </button>
        </div>
      </template>

      <!-- Estado sin respuesta -->
      <template v-else-if="status === 'no-response'">
        <p class="text-gray-600 text-lg">{{ $t('no_response') }}</p>
        <p>{{ $t('provider_no_response', { name: providerName }) }}</p>
        <div class="mt-4 flex justify-center gap-2">
          <button
            @click="handleCancel"
            class="px-4 py-2 border rounded-lg"
          >
            {{ $t('cancel') }}
          </button>
          <button
            @click="handleRetry"
            class="px-4 py-2 bg-blue-600 text-white rounded-lg"
          >
            {{ $t('try_again') }}
          </button>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, onUnmounted } from 'vue'
import api from '@/axios'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()

const props = defineProps({
  isOpen: Boolean,
  providerName: String,
  requestId: Number,
})

// Emitimos dos eventos: el que ya existía + retry-request
const emit = defineEmits(['cancel', 'openPayment', 'retry-request'])

const status = ref('pending')
const countdown = ref(90)
let pollInterval = null
let timerInterval = null

const formatTime = (seconds) => {
  const m = String(Math.floor(seconds / 60)).padStart(2, '0')
  const s = String(seconds % 60).padStart(2, '0')
  return `${m}:${s}`
}

// Función para detener todo
const stopProcess = () => {
  if (pollInterval) clearInterval(pollInterval)
  if (timerInterval) clearInterval(timerInterval)
}

// Reiniciar y empezar
const reset = () => {
  status.value = 'pending'
  countdown.value = 90
}

const startProcess = () => {
  stopProcess()
  timerInterval = setInterval(() => {
    countdown.value--
    if (countdown.value <= 0 && status.value === 'pending') {
      status.value = 'no-response'
      stopProcess()
    }
  }, 1000)

  pollInterval = setInterval(async () => {
    try {
      const { data } = await api.get(
        `/requests/status/${props.requestId}`
      )
      if (['accepted', 'rejected', 'busy'].includes(data.status)) {
        status.value = data.status
        stopProcess()
      }
    } catch (err) {
      console.error(t('error_fetching_provider_status'), err)
    }
  }, 3000)
}

// Handlers para los botones
const handleCancel = () => {
  stopProcess()
  emit('cancel')
}

const handleRetry = () => {
  stopProcess()
  emit('retry-request') // <-- Nuevo evento que DashboardUser escuchará
}

watch(
  () => props.isOpen,
  (val) => {
    if (val) {
      reset()
      startProcess()
    } else {
      stopProcess()
    }
  }
)

onUnmounted(stopProcess)

// Exportamos startProcess para que el padre pueda llamarlo
defineExpose({ startProcess, stopProcess })
</script>
