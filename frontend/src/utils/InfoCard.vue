<!-- utils/InfoCard.vue -->
<template>
  <div class="bg-white dark:bg-gray-800 rounded-2xl shadow p-4 flex items-center justify-between">
    <div>
      <h3 class="text-lg font-semibold text-gray-700 dark:text-white">
        {{ title }}
      </h3>
      <p class="text-2xl font-bold text-primary mt-1">
        {{ value }}
      </p>
    </div>
    <div class="text-4xl">
      <slot />
    </div>
  </div>
</template>

<script>
export default {
  name: 'InfoCard',
  props: {
    title: String,
    value: [String, Number]
  }
}
</script>
