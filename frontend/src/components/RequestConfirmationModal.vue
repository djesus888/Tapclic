<template>
  <div v-if="isOpen" class="fixed inset-0 z-50 flex items-end justify-center bg-black bg-opacity-30">
    <div class="bg-white rounded-t-xl w-full max-w-md p-4">
      <h2 class="text-xl font-semibold">{{ $t('confirmServiceRequest') }}</h2>
      <p class="text-sm text-gray-600 mt-2">{{ $t('checkDetailsBeforeSending') }}</p>

      <div class="mt-4 flex items-center gap-2">
        <input type="checkbox" id="addSpec" v-model="addSpec" />
        <label for="addSpec">{{ $t('addComments') }}</label>
      </div>

      <textarea
        v-if="addSpec"
        v-model="specDetails"
        class="w-full mt-2 border rounded p-2"
        placeholder="Detalles adicionales..."
      ></textarea>

      <div class="flex justify-end gap-2 mt-4">
        <button @click="closeModal" class="px-4 py-2 border rounded">{{ $t('cancel') }}</button>
        <button @click="submitRequest" class="px-4 py-2 bg-blue-600 text-white rounded">{{ $t('confirm') }}</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  isOpen: { type: Boolean, default: false }
})

const emit = defineEmits(['on-open-change', 'confirm'])

const addSpec = ref(false)
const specDetails = ref('')

const closeModal = () => {
  emit('on-open-change', false)
  resetState()
}

const submitRequest = () => {
  // Importante: NO cerrar aquí. El padre decide el flujo.
  emit('confirm', specDetails.value)
}

const resetState = () => {
  addSpec.value = false
  specDetails.value = ''
}

watch(() => props.isOpen, (val) => {
  if (!val) resetState()
})
</script>
