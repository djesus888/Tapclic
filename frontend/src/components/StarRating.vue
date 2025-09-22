<!-- src/components/StarRating.vue -->
<template>
  <div class="flex items-center gap-0.5">
    <svg
      v-for="i in 5"
      :key="i"
      :class="i <= safeRating ? 'text-yellow-400 fill-yellow-400' : 'text-muted-foreground'"
      class="h-4 w-4"
      viewBox="0 0 24 24"
    >
      <path d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z" />
    </svg>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
  rating: number
}>()

// Asegura que el valor esté entre 0 y 5
const safeRating = computed(() => {
  const val = Number(props.rating)
  if (Number.isNaN(val)) return 0
  return Math.min(5, Math.max(0, val))
})
</script>
