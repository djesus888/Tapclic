<!-- src/layouts/NotificationModal.vue -->
<template>
  <Teleport to="body">
    <Transition name="modal-fade">
      <div v-if="isOpen"
        class="fixed inset-0 z-50 flex items-center justify-center p-4"
        @click.self="close"
      >
        <!-- Overlay -->
        <div class="absolute inset-0 bg-black/50 backdrop-blur-sm"></div>

        <!-- Modal -->
        <div class="relative bg-white rounded-2xl shadow-2xl max-w-md w-full p-6">
          <!-- Header -->
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-xl font-bold text-slate-800">{{ notification.title }}</h3>
            <button @click="close" class="text-gray-500 hover:text-gray-700 text-2xl leading-none">
              ×
            </button>
          </div>

          <!-- Body -->
          <div class="mb-6">
            <p class="text-gray-600 whitespace-pre-wrap">{{ notification.message }}</p>
            <p class="text-xs text-gray-400 mt-4">{{ formatDate(notification.created_at) }}</p>
          </div>

          <!-- Footer con acciones -->
          <div class="flex gap-3 justify-end">
            <button @click="close" class="px-4 py-2 text-gray-600 hover:bg-gray-100 rounded-lg">
              {{ $t('close') }}
            </button>
            
            <!-- Botón para ir a la URL de la notificación -->
            <button 
              v-if="notificationUrl"
              @click="goToUrl"
              class="px-4 py-2 bg-sky-600 text-white hover:bg-sky-700 rounded-lg"
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

const emit = defineEmits(['close', 'action'])

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

const close = () => emit('close')

const goToUrl = () => {
  if (notificationUrl.value) {
    router.push(notificationUrl.value)
    close() // Cerrar modal después de navegar
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
