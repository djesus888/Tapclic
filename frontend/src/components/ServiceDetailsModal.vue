<!-- ServiceDetailsModal.vue -->
<template>
  <div
    v-if="isOpen"
    class="fixed inset-0 z-50 flex items-end justify-center bg-black bg-opacity-30"
    @click.self="$emit('on-open-change', false)"
  >
    <div class="bg-white rounded-t-xl w-full max-w-md p-4">
      <h2 class="text-xl font-semibold">{{ request.title || '—' }}</h2>
      <p class="text-sm text-gray-600">{{ request.description || '—' }}</p>

      <div class="flex justify-between mt-4 text-sm text-gray-600">
        <div class="flex items-center gap-1">
          📍 {{ request.location || '—' }}
        </div>
        <div
          :class="request.isAvailable ? 'text-green-600' : 'text-red-600'"
          class="flex items-center gap-1"
        >
          {{ request.isAvailable ? $t('available') : $t('notAvailable') }}
        </div>
      </div>

      <!-- Proveedor -->
      <div class="flex items-center gap-3 mt-4">
        <img
          :src="request.image_url ? `http://localhost:8000${request.image_url}` : '/img/default-provider.png'"
          alt="Avatar"
          class="w-10 h-10 rounded-full"
        />
        <div>
          <p class="font-semibold">{{ request.provider?.name || '—' }}</p>
          <p>{{ request.provider?.rating ?? 'N/A' }} ⭐</p>
        </div>

        <!-- Botón abrir chat -->
        <button
          @click="openChat"
          class="ml-auto bg-gray-100 p-2 rounded"
          title="Abrir chat"
        >
          💬
        </button>
      </div>

      <div class="flex justify-between items-center mt-4">
        <span>{{ $t('servicePrice') }}</span>
        <span class="font-bold text-lg">${{ formattedPrice }}</span>
      </div>

      <div class="flex justify-end gap-2 mt-4">
        <button
          @click="$emit('on-open-change', false)"
          class="px-4 py-2 border rounded"
        >
          {{ $t('close') }}
        </button>
        <button
          v-if="request.isAvailable"
          @click="$emit('on-request-service')"
          class="px-4 py-2 bg-blue-600 text-white rounded"
        >
          {{ $t('requestService') }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { defineProps, computed } from 'vue'

const props = defineProps({
  isOpen: Boolean,
  request: Object
})

const formattedPrice = computed(() => {
  return Number(props.request?.price || 0).toFixed(2)
})

/* Emitir objeto Target al abrir el chat */
const openChat = () => {
  const provider = props.request?.provider
  const target = {
    id: provider?.id ?? props.request?.provider_id ?? props.request?.user_id,
    name: provider?.name ?? 'Proveedor',
    role: 'provider',
    avatarUrl: provider?.avatar_url
  }
  // Disparar evento con el objeto completo
  emit('on-start-chat', target)
}

// defineEmits
const emit = defineEmits([
  'on-open-change',
  'on-request-service',
  'on-start-chat'
])
</script>
