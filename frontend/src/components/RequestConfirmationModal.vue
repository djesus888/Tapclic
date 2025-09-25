<template>
  <div v-if="isOpen" class="fixed inset-0 z-50 flex items-end justify-center bg-black bg-opacity-30">
    <div class="bg-white rounded-t-xl w-full max-w-md p-4">
      <h2 class="text-xl font-semibold">{{ $t('confirmServiceRequest') }}</h2>

      <!-- BOTÓN EXPANSIBLE -->
      <details class="mt-3 text-sm">
        <summary class="cursor-pointer text-blue-600 hover:underline">
          {{ $t('checkDetailsBeforeSending') }}
        </summary>

        <!-- DETALLES DEL SERVICIO -->
        <div class="mt-3 text-gray-700 whitespace-pre-wrap break-words">
          <template v-if="serviceDetails.service_details?.trim()">
            {{ serviceDetails.service_details }}
          </template>
          <span v-else class="text-gray-400 italic">
            {{ $t('noServiceDetails') }}
          </span>
        </div>
      </details>

      <!-- COMENTARIOS OPCIONALES -->
      <div class="mt-4 flex items-center gap-2">
        <input type="checkbox" id="addSpec" v-model="addSpec" />
        <label for="addSpec">{{ $t('add condition in service request.') }}</label>
      </div>

      <textarea
        v-if="addSpec"
        v-model="specDetails"
        class="w-full mt-2 border rounded p-2"
        :placeholder="$t('additionalDetails')"
        maxlength="200"
        rows="4"
      ></textarea>

      <!-- CONTADOR DE CARACTERES -->
      <p v-if="addSpec" class="text-right text-xs text-gray-500 mt-1">
        {{ specDetails.length }}/200
      </p>

      <!-- BOTONES -->
      <div class="flex justify-end gap-2 mt-4">
        <button @click="closeModal" class="px-4 py-2 border rounded">{{ $t('cancel') }}</button>
        <button
          @click="submitRequest"
          class="px-4 py-2 bg-blue-600 text-white rounded disabled:opacity-50 disabled:cursor-not-allowed"
          :disabled="addSpec && specDetails.length > 200"
        >
          {{ $t('confirm') }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  isOpen: { type: Boolean, default: false },
  serviceDetails: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['on-open-change', 'confirm'])

const addSpec = ref(false)
const specDetails = ref('')

const closeModal = () => {
  emit('on-open-change', false)
  resetState()
}

const submitRequest = () => {
  emit('confirm', specDetails.value)
}

const resetState = () => {
  addSpec.value = false
  specDetails.value = ''
}

watch(() => props.isOpen, val => { if (!val) resetState() })
</script>
