<template>
  <div class="bg-white rounded-lg shadow-md overflow-hidden border border-gray-200">
    <!-- Cabecera: Título y Fecha -->
    <div class="p-4 border-b bg-gray-50">
      <div class="flex justify-between items-start">
        <h3 class="font-bold text-lg text-gray-800">
          {{ order.title }}
        </h3>
        <span class="text-sm text-gray-500">{{ order.date }}</span>
      </div>
    </div>

    <!-- Cuerpo: Descripción -->
    <div class="p-4">
      <p class="text-gray-600 text-sm mb-3">
        {{ order.description }}
      </p>

      <!-- Proveedor y Chat -->
      <div class="flex justify-between items-center mb-3">
        <div class="flex items-center space-x-1">
          <span class="text-xs text-gray-500">Proveedor:</span>
          <span class="text-sm font-medium text-gray-700">{{ order.provider }}</span>
        </div>
        <button
          v-if="order.chat"
          class="text-blue-500 hover:text-blue-700 transition"
          @click="onChatClick"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="h-5 w-5"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.507 15.42 3 14.05 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"
            />
          </svg>
        </button>
      </div>

      <!-- Ítems del pedido -->
      <div class="mb-3">
        <ul class="space-y-1">
          <li
            v-for="(item, index) in order.items"
            :key="index"
            class="text-sm text-gray-700 flex justify-between"
          >
            <span>{{ item.name }}</span>
            <span class="font-medium">{{ item.quantity }}</span>
          </li>
        </ul>
      </div>

      <!-- Monto -->
      <div class="flex justify-between items-center mb-3">
        <span class="text-sm text-gray-500">{{ $t('amount') }}:</span>
        <span class="font-bold text-gray-800 text-sm">{{ order.amount }}</span>
      </div>

      <!-- Calificación y Estado -->
      <div class="flex justify-between items-center mb-3">
        <div class="flex items-center space-x-1">
          <span class="text-xs text-gray-500">{{ $t('rating') }}:</span>
          <span class="text-sm font-medium">{{ order.rating }}/5</span>
        </div>
        <span
          :class="[
            'text-xs font-semibold px-2 py-1 rounded-full',
            order.status === 'Disponible'
              ? 'bg-green-100 text-green-800'
              : 'bg-red-100 text-red-800'
          ]"
        >
          {{ order.status }}
        </span>
      </div>

      <!-- Checkbox: Servicio solicitado -->
      <div class="flex items-center justify-between">
        <label class="flex items-center space-x-2 cursor-pointer">
          <input
            type="checkbox"
            :checked="order.serviceRequest"
            class="form-checkbox h-4 w-4 text-blue-600 rounded focus:ring-blue-500"
            @change="onServiceRequestToggle"
          >
          <span class="text-xs text-gray-600">{{ $t('service_requested') }}</span>
        </label>
      </div>
    </div>
  </div>
</template>

<script setup>
defineProps({
  order: {
    type: Object,
    required: true,
    validator: (val) => {
      return (
        'title' in val &&
        'date' in val &&
        'description' in val &&
        'provider' in val &&
        'chat' in val &&
        'items' in val &&
        'amount' in val &&
        'rating' in val &&
        'status' in val &&
        'serviceRequest' in val
      );
    },
  },
});

const emit = defineEmits(['toggle-chat', 'toggle-service-request']);

const onChatClick = () => {
  emit('toggle-chat', order.id);
};

const onServiceRequestToggle = () => {
  emit('toggle-service-request', order.id);
};
</script>

<style scoped>
/* Puedes personalizar más si usas Tailwind o estilos propios */
.form-checkbox:checked {
  background-color: #2563eb;
  border-color: #2563eb;
}
</style>
