<template>
  <div class="mb-4 flex flex-wrap gap-2 items-center">
    <!-- Estrellas -->
    <button
      v-for="n in 6"
      :key="n"
      @click="toggleStar(n)"
      class="px-3 py-1 text-sm border rounded-full transition"
      :class="isActive(n)? 'bg-accent text-white border-accent' : 'bg-white text-foreground border-border'"
    >
      <span v-if="n===0">Todas</span>
      <span v-else>{{ n }} ★</span>
    </button>

    <!-- Verificadas -->
    <button
      @click="toggleVerified"
      class="px-3 py-1 text-sm border rounded-full transition"
      :class="filters.verified? 'bg-accent text-white border-accent' : 'bg-white text-foreground border-border'"
    >
      Verificadas
    </button>

    <!-- Con foto -->
    <button
      @click="toggleWithPhoto"
      class="px-3 py-1 text-sm border rounded-full transition"
      :class="filters.withPhoto? 'bg-accent text-white border-accent' : 'bg-white text-foreground border-border'"
    >
      Con foto
    </button>

    <!-- Orden -->
    <select v-model="filters.sort" class="ml-auto text-sm border rounded px-2 py-1">
      <option value="newest">Más nuevo</option>
      <option value="oldest">Más antiguo</option>
      <option value="highest">Mejor puntuación</option>
      <option value="lowest">Peor puntuación</option>
    </select>
  </div>
</template>

<script setup lang="ts">
import { reactive, watch } from 'vue'

const emit = defineEmits(['change'])

const filters = reactive({
  stars: [] as number[],   // estrellas marcadas (vacío = todas)
  verified: false,
  withPhoto: false,
  sort: 'newest'
})

function isActive(n: number){
  if (n === 0) return filters.stars.length === 0
  return filters.stars.includes(n)
}
function toggleStar(n: number){
  if (n === 0) filters.stars = []
  else {
    const idx = filters.stars.indexOf(n)
    idx > -1 ? filters.stars.splice(idx,1) : filters.stars.push(n)
  }
}
function toggleVerified(){ filters.verified = !filters.verified }
function toggleWithPhoto(){ filters.withPhoto = !filters.withPhoto }

watch(filters, () => emit('change', {...filters}), {deep:true})
</script>
