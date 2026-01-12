<template>
  <div
    v-if="isOpen"
    class="fixed inset-0 z-50 flex items-end justify-center bg-black bg-opacity-30"
  >
    <div class="bg-white rounded-t-xl w-full max-w-md p-4">
      <h2 class="text-xl font-semibold">
        {{ $t('confirmServiceRequest') }}
      </h2>

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
          <span
            v-else
            class="text-gray-400 italic"
          >
            {{ $t('noServiceDetails') }}
          </span>
        </div>
      </details>

      <!-- COMENTARIOS OPCIONALES -->
      <div class="mt-4 flex items-center gap-2">
        <input
          id="addSpec"
          v-model="addSpec"
          type="checkbox"
        >
        <label for="addSpec">{{ $t('add condition in service request.') }}</label>
      </div>                                                    
      <textarea
        v-if="addSpec"
        v-model="specDetails"
        class="w-full mt-2 border rounded p-2"
        :placeholder="$t('additionalDetails')"
        maxlength="200"
        rows="4"
      />

      <!-- CONTADOR DE CARACTERES -->
      <p
        v-if="addSpec"
        class="text-right text-xs text-gray-500 mt-1"
      >
        {{ specDetails.length }}/200
      </p>

      <!-- CONTRATO -->
      <div class="mt-4 p-3 border rounded bg-gray-50 text-sm">
        <p>
          Al confirmar este servicio aceptas las condiciones del contrato:
          el servicio será prestado según lo descrito y no habrá reembolso
          una vez iniciado.
        </p>
        <label class="flex items-center mt-3 gap-2">
          <input
            v-model="acceptedContract"
            type="checkbox"
          >
          <span>Acepto las condiciones del servicio</span>
        </label>
      </div>

      <!-- BOTONES -->
      <div class="flex justify-end gap-2 mt-4">
        <button
          class="px-4 py-2 border rounded"
          @click="closeModal"
        >
          {{ $t('cancel') }}
        </button>
        <button
          class="px-4 py-2 bg-blue-600 text-white rounded disabled:opacity-50 disabled:cursor-not-allowed"
          :disabled="(!acceptedContract) || (addSpec && specDetails.length > 200)"
          @click="submitRequest"
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
const acceptedContract = ref(false)

const closeModal = () => {
  emit('on-open-change', false)
  resetState()
}

const submitRequest = () => {
  if (!acceptedContract.value) {
    alert('Debes aceptar las condiciones del contrato.')
    return
  }
  emit('confirm', {
    details: specDetails.value,
    contractAccepted: acceptedContract.value
  })
}

const resetState = () => {
  addSpec.value = false
  specDetails.value = ''
  acceptedContract.value = false
}

watch(() => props.isOpen, val => { if (!val) resetState() })
</script>
