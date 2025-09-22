<!-- src/pages/Reviews.vue -->
<template>
  <div class="max-w-3xl mx-auto p-6">
    <h1 class="text-2xl font-bold mb-4">Mis reseñas</h1>

    <!-- Promedio -->
    <div class="flex items-center gap-3 mb-4">
      <StarRating :rating="average" class="text-xl" />
      <span class="text-lg text-muted-foreground">{{ average }} ({{ total }})</span>
    </div>

    <!-- Filtros -->
    <ReviewFilters @change="filters = $event" />

    <!-- Lista -->
    <div v-if="loading" class="space-y-4">
      <div v-for="i in 3" :key="i" class="p-4 border rounded animate-pulse">
        <div class="h-5 bg-gray-300 rounded w-1/3 mb-2" />
        <div class="h-4 bg-gray-200 rounded w-2/3" />
      </div>
    </div>

    <div v-else-if="!filtered.length" class="text-center text-muted-foreground mt-10">
      No hay reseñas que coincidan con los filtros.
    </div>

    <div v-else class="space-y-4">
      <div v-for="r in filtered" :key="r.id" class="p-4 border rounded-lg shadow-sm">
        <div class="flex items-start gap-3">
          <img
            :src="r.user_avatar || '/default-avatar.png'"
            alt="avatar"
            class="w-10 h-10 rounded-full object-cover"
            loading="lazy"
          />
          <div class="flex-1">
            <p class="font-semibold">{{ r.user_name }}</p>
            <p class="text-sm text-muted-foreground">{{ r.service_title }}</p>
            <StarRating :rating="r.rating" class="mt-1" />

            <!-- Galería -->
            <div v-if="safePhotos(r).length" class="flex gap-2 mt-2 overflow-x-auto flex-nowrap">
              <img
                v-for="(src, idx) in safePhotos(r)"
                :key="idx"
                :src="src"
                class="w-16 h-16 rounded object-cover border"
                loading="lazy"
              />
            </div>

            <!-- Comentario -->
            <p v-if="r.comment" class="mt-2 text-sm">{{ r.comment }}</p>

            <!-- Tags -->
            <div v-if="safeTags(r).length" class="flex flex-wrap gap-2 mt-2">
              <span
                v-for="t in safeTags(r)"
                :key="t"
                class="px-2 py-0.5 text-xs bg-primary/10 text-primary rounded-full"
              >
                {{ t }}
              </span>
            </div>

            <!-- Respuesta del proveedor -->
            <div
              v-if="r.provider_reply"
              class="mt-3 p-3 bg-accent/10 rounded border border-accent/30 text-sm"
            >
              <p class="font-semibold text-accent">Respuesta del proveedor</p>
              <p>{{ r.provider_reply.message }}</p>
              <p class="text-xs text-muted-foreground mt-1">
                {{ dayjs(r.provider_reply.created_at).fromNow() }}
              </p>
            </div>

            <!-- Acciones -->
            <div class="flex items-center gap-3 mt-3 text-xs">
              <button
                type="button"
                @click="markHelpful(r)"
                class="text-muted-foreground hover:text-foreground"
              >
                Útil ({{ r.helpful_count || 0 }})
              </button>
              <button
                v-if="isProvider"
                type="button"
                @click="openReply(r)"
                class="text-accent"
              >
                Responder
              </button>
              <button v-else type="button" @click="report(r)" class="text-destructive">
                Reportar
              </button>
              <span class="text-muted-foreground ml-auto">
                {{ dayjs(r.created_at).fromNow() }}
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- Modal formulario -->
  <ReviewFormModal
    v-if="showForm"
    :modelValue="currentEdit"
    @close="showForm = false"
    @save="handleSave"
  />
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import dayjs from 'dayjs'
import relativeTime from 'dayjs/plugin/relativeTime'
import 'dayjs/locale/es'
import { useAuthStore } from '@/stores/authStore'
import api from '@/axios'
import StarRating from '@/components/StarRating.vue'
import ReviewFilters from '@/components/ReviewFilters.vue'
import ReviewFormModal from '@/components/ReviewFormModal.vue'
import { useReviews } from '@/utils/useReviews.ts'
import type { Review } from '@/utils/useReviews.ts'

dayjs.extend(relativeTime)
dayjs.locale('es')

/* ----------  STATE  ---------- */
const authStore = useAuthStore()
const reviews = ref<Review[]>([])
const average = ref(0)
const total = ref(0)
const loading = ref(true)

/* ----------  ROLES  ---------- */
const isProvider = computed(() => authStore.user?.role === 'provider')

/* ----------  DATA FETCH  ---------- */
async function loadReviews() {
  try {
    const { data } = await api.get('/reviews/received', {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    reviews.value = data.reviews
    average.value = data.average
    total.value = data.total
  } catch (e) {
    console.error('Error cargando reseñas:', e)
  } finally {
    loading.value = false
  }
}

onMounted(() => loadReviews())

/* ----------  FILTERS  ---------- */
const { filters, filtered } = useReviews(reviews)

/* ----------  MODAL  ---------- */
const showForm = ref(false)
const currentEdit = ref<Review | null>(null)

function openReply(r: Review) {
  currentEdit.value = {
    ...r,
    comment: r.provider_reply?.message || ''
  } as Review
  showForm.value = true
}

/* ----------  ACTIONS  ---------- */
async function report(r: Review) {
  try {
    await api.post(
      '/reviews/report',
      { review_id: r.id },
      { headers: { Authorization: `Bearer ${authStore.token}` } }
    )
  } catch (e) {
    console.error('Error al reportar:', e)
  }
}

async function markHelpful(r: Review) {
  try {
    await api.post(
      '/reviews/helpful',
      { review_id: r.id },
      { headers: { Authorization: `Bearer ${authStore.token}` } }
    )
    r.helpful_count = (r.helpful_count || 0) + 1
  } catch (e) {
    console.error('Error al marcar como útil:', e)
  }
}

async function handleSave(payload: any) {
  try {
    if (currentEdit.value) {
      await api.put(
        `/reviews/${currentEdit.value.id}/reply`,
        { message: payload.comment },
        { headers: { Authorization: `Bearer ${authStore.token}` } }
      )
    } else {
      await api.post('/reviews', payload, {
        headers: { Authorization: `Bearer ${authStore.token}` }
      })
    }
    showForm.value = false
    await loadReviews()
  } catch (e) {
    console.error('Error al guardar:', e)
  }
}

/* ----------------------------------------------------------
   HELPERS: siempre devuelven ARRAY (nunca rompen el v-for)
---------------------------------------------------------- */
function safePhotos(r: Review): string[] {
  try {
    return Array.isArray(r.photos) ? r.photos : JSON.parse(r.photos || '[]')
  } catch {
    return []
  }
}

function safeTags(r: Review): string[] {
  try {
    return Array.isArray(r.tags) ? r.tags : JSON.parse(r.tags || '[]')
  } catch {
    return []
  }
}
</script>
