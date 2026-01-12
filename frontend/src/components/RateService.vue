<template>
  <section>
    <h2 class="text-lg font-semibold mb-2">
      {{ $t('rate_services') }}
    </h2>
    <ul
      v-if="unrated.length"
      class="space-y-4"
    >
      <li
        v-for="s in unrated"
        :key="s.id"
        class="p-4 border rounded shadow"
      >
        <div class="font-semibold">
          {{ s.title }}
        </div>
        <div class="text-sm text-gray-600 mb-2">
          {{ s.description }}
        </div>

        <div class="flex items-center space-x-2 mb-2">
          <span
            v-for="star in 5"
            :key="star"
            class="cursor-pointer text-xl"
            :class="star <= s.rating ? 'text-yellow-400' : 'text-gray-300'"
            @click="s.rating = star"
          >★</span>
        </div>

        <textarea
          v-model="s.comment"
          rows="2"
          class="w-full p-2 border rounded text-sm"
          placeholder="Escribe un comentario..."
        />

        <button
          class="mt-2 px-4 py-1 bg-blue-600 text-white rounded hover:bg-blue-700"
          @click="submitRating(s)"
        >
          {{ $t('submit_rating') }}
        </button>
      </li>
    </ul>
    <p
      v-else
      class="text-sm text-gray-500"
    >
      {{ $t('no_services_to_rate') }}
    </p>
  </section>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'
import Swal from 'sweetalert2'

const unrated = ref([])

const fetchUnrated = async () => {
  const res = await axios.get('/api/services/unrated')
  unrated.value = res.data.map(s => ({ ...s, rating: 0, comment: '' }))
}

const submitRating = async (service) => {
  if (!service.rating) {
    return Swal.fire('Error', 'Selecciona una puntuación.', 'warning')
  }

  try {
    await axios.post('/api/services/rate', {
      service_id: service.id,
      rating: service.rating,
      comment: service.comment
    })

    unrated.value = unrated.value.filter(s => s.id !== service.id)

    Swal.fire('¡Gracias!', 'Tu calificación fue enviada.', 'success')
  } catch (err) {
    Swal.fire('Error', 'No se pudo enviar tu calificación.', 'error')
  }
}

onMounted(fetchUnrated)
</script>
