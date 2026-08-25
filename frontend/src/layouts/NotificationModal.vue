<!-- src/layouts/NotificationModal.vue -->
<template>
  <Teleport to="body">
    <Transition name="modal-fade">
      <div
        v-if="isOpen"
        class="fixed inset-0 z-50 flex items-center justify-center p-4"
        @click.self="close"
      >
        <!-- Overlay -->
        <div class="absolute inset-0 bg-black/50 backdrop-blur-sm" />

        <!-- Modal -->
        <div class="relative bg-white rounded-2xl shadow-2xl max-w-md w-full p-6">
          <!-- Header -->
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-xl font-bold text-slate-800">
              {{ notification.title }}
            </h3>
            <button
              class="text-gray-500 hover:text-gray-700 text-2xl leading-none"
              @click="close"
            >
              ×
            </button>
          </div>

          <!-- Body -->
          <div class="mb-6">
            <p class="text-gray-600 whitespace-pre-wrap">
              {{ notification.message }}
            </p>
            <p class="text-xs text-gray-400 mt-4">
              {{ formatDate(notification.created_at) }}
            </p>
          </div>

          <!-- Footer con acciones -->
          <div class="flex gap-3 justify-end">
            <button
              class="px-4 py-2 text-gray-600 hover:bg-gray-100 rounded-lg"
              @click="close"
            >
              {{ $t('close') }}
            </button>

            <!-- 🔥 CORRECCIÓN: Botón para ver detalles o abrir modal de verificación de pago -->
            <button
              v-if="isPaymentNotification && paymentRequestId"
              class="px-4 py-2 bg-emerald-600 text-white hover:bg-emerald-700 rounded-lg"
              @click="openPaymentProof"
            >
              💳 {{ $t('verifyPayment') || 'Verificar pago' }}
            </button>

            <!-- Botón para ir a la URL de la notificación (solo si NO es de pago) -->
            <button
              v-else-if="notificationUrl"
              class="px-4 py-2 bg-sky-600 text-white hover:bg-sky-700 rounded-lg"
              @click="goToUrl"
            >
              {{ $t('viewDetails') }}
            </button>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup>
import { defineProps, defineEmits, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { formatDate } from '@/utils/formatDate'

const props = defineProps({
  isOpen: Boolean,
  notification: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['close', 'action', 'open-payment-proof'])

const router = useRouter()
const { t } = useI18n()

// Computed para extraer la URL del data_json
const notificationUrl = computed(() => {
  if (!props.notification.data_json) return null

  try {
    const data = JSON.parse(props.notification.data_json)
    // Extraer url o route, y limpiar barras escapadas
    const url = data.url || data.route || null
    return url ? url.replace(/\\\//g, '/') : null
  } catch (e) {
    console.warn('⚠️ Error parseando data_json:', e)
    return null
  }
})

// 🔥 NUEVO: Detectar si es notificación de pago
const isPaymentNotification = computed(() => {
  if (!props.notification.data_json) return false

  try {
    const data = JSON.parse(props.notification.data_json)
    return data.notification_type === 'payment_received' || 
           data.type === 'payment' || 
           data.action === 'verify_payment' ||
           data.action === 'view_order'
  } catch (e) {
    return false
  }
})

// 🔥 NUEVO: Extraer el request_id para el modal de verificación
const paymentRequestId = computed(() => {
  if (!props.notification.data_json) return null

  try {
    const data = JSON.parse(props.notification.data_json)
    return data.request_id || props.notification.request_id || null
  } catch (e) {
    return null
  }
})

const close = () => emit('close')

const goToUrl = () => {
  if (notificationUrl.value) {
    router.push(notificationUrl.value)
    close() // Cerrar modal después de navegar
  }
}

// 🔥 NUEVO: Abrir modal de verificación de pago
const openPaymentProof = () => {
  if (paymentRequestId.value) {
    emit('open-payment-proof', {
      request_id: paymentRequestId.value
    })
    close() // Cerrar el modal de notificación
  }
}

const handleAction = () => {
  emit('action', props.notification)
}
</script>

<style scoped>
.modal-fade-enter-active,
.modal-fade-leave-active {
  transition: opacity 0.2s ease;
}

.modal-fade-enter-from,
.modal-fade-leave-to {
  opacity: 0;
}
</style>
