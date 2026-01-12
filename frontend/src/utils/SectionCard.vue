<!-- utils/SectionCard.vue -->
<template>
  <div class="bg-white dark:bg-gray-900 rounded-xl shadow p-4 flex flex-col items-start hover:bg-gray-50 dark:hover:bg-gray-800 transition">
    <div class="text-3xl mb-2">
      <slot name="icon" />
    </div>
    <h3 class="text-lg font-semibold text-gray-800 dark:text-white">
      {{ title }}
    </h3>
    <p class="text-sm text-gray-500 mt-1">
      {{ subtitle }}
    </p>
  </div>
</template>

<script>
export default {
  name: 'SectionCard',
  props: {
    title: String,
    subtitle: String
  }
}
</script>
