<template>
  <div class="bg-white dark:bg-gray-800 p-4 rounded-xl shadow flex flex-col md:flex-row md:items-end gap-4">
    <!-- Búsqueda por texto -->
    <div class="flex-1">
      <label class="text-sm font-medium text-gray-700 dark:text-gray-300">
        {{ $t('search_services') }}
      </label>
      <input
        v-model="filters.query"
        type="text"
        class="w-full mt-1 p-2 border border-gray-300 rounded-lg dark:bg-gray-900 dark:text-white"
        :placeholder="$t('search_services')"
      >
    </div>

    <!-- Categoría -->
    <div class="flex-1">
      <label class="text-sm font-medium text-gray-700 dark:text-gray-300">
        {{ $t('category') }}
      </label>
      <select
        v-model="filters.category"
        class="w-full mt-1 p-2 border border-gray-300 rounded-lg dark:bg-gray-900 dark:text-white"
      >
        <option value="">
          {{ $t('all_categories') }}
        </option>
        <option
          v-for="category in categories"
          :key="category"
          :value="category"
        >
          {{ category }}
        </option>
      </select>
    </div>

    <!-- Rango de precio -->
    <div class="flex-1">
      <label class="text-sm font-medium text-gray-700 dark:text-gray-300">
        {{ $t('price_range') }}
      </label>
      <div class="flex gap-2 mt-1">
        <input
          v-model.number="filters.minPrice"
          type="number"
          class="w-1/2 p-2 border border-gray-300 rounded-lg dark:bg-gray-900 dark:text-white"
          placeholder="Min"
        >
        <input
          v-model.number="filters.maxPrice"
          type="number"
          class="w-1/2 p-2 border border-gray-300 rounded-lg dark:bg-gray-900 dark:text-white"
          placeholder="Max"
        >
      </div>
    </div>

    <!-- Botones -->
    <div class="flex gap-2">
      <button
        class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700"
        @click="applyFilters"
      >
        {{ $t('apply_filters') }}
      </button>
      <button
        class="bg-gray-300 text-gray-800 px-4 py-2 rounded-lg hover:bg-gray-400 dark:bg-gray-600 dark:text-white"
        @click="clearFilters"
      >
        {{ $t('clear_filters') }}
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const filters = ref({
  query: '',
  category: '',
  minPrice: null,
  maxPrice: null
})

// Simulamos categorías hasta que lleguen desde el backend
const categories = ['Tecnología', 'Hogar', 'Educación', 'Salud']

const emit = defineEmits(['updateFilters'])

const applyFilters = () => {
  emit('updateFilters', { ...filters.value })
}

const clearFilters = () => {
  filters.value = {
    query: '',
    category: '',
    minPrice: null,
    maxPrice: null
  }
  applyFilters()
}
</script>
