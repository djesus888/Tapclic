<template>
  <div
    class="bg-white dark:bg-gray-900 rounded-xl shadow hover:shadow-md transition-all p-4 flex flex-col justify-between"
  >
    <!-- Título y proveedor -->
    <div>
      <h3 class="text-lg font-semibold text-gray-800 dark:text-white">
        {{ service.title }}
      </h3>
      <p class="text-sm text-gray-500 dark:text-gray-400">
        {{ $t('provided_by') }}: <strong>{{ service.provider_name }}</strong>
      </p>
    </div>

    <!-- Descripción -->
    <p class="mt-2 text-sm text-gray-600 dark:text-gray-300 line-clamp-3">
      {{ service.description }}
    </p>

    <!-- Valoración -->
    <div class="mt-2 flex items-center gap-1 text-yellow-500">
      <i
        v-for="n in Math.floor(service.rating)"
        :key="n"
        class="ri-star-fill"
      />
      <i
        v-for="n in 5 - Math.floor(service.rating)"
        :key="'e'+n"
        class="ri-star-line"
      />
      <span class="ml-1 text-gray-600 dark:text-gray-400 text-xs">
        {{ service.rating.toFixed(1) }} / 5 ({{ service.reviews_count }} {{ $t('reviews') }})
      </span>
    </div>

    <!-- Precio -->
    <div class="mt-2 text-blue-600 dark:text-blue-400 font-bold text-md">
      {{ service.price }} USD
    </div>

    <!-- Botones -->
    <div class="mt-4 flex flex-col md:flex-row gap-2">
      <button
        class="bg-green-600 text-white py-2 px-4 rounded-lg hover:bg-green-700 w-full"
        @click="requestService"
      >
        ✉️ {{ $t('request_service') }}
      </button>
      <button
        class="bg-gray-200 dark:bg-gray-700 text-gray-900 dark:text-white py-2 px-4 rounded-lg hover:bg-gray-300 dark:hover:bg-gray-600 w-full"
        @click="openChat"
      >
        💬 {{ $t('chat_with_provider') }}
      </button>
    </div>
  </div>
</template>

<script setup>
const props = defineProps({
  service: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['request', 'chat'])

const requestService = () => {
  emit('request', service.id)
}

const openChat = () => {
  emit('chat', service.provider_id)
}
</script>

<style scoped>
.line-clamp-3 {
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
