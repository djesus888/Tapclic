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
      <div v-for="r in filtered" :key="r.id" class="p-4 border rounded-lg shadow-sm relative">
        <!-- Menú derecha-arriba solo visible al dueño (quien escribió la reseña) -->
        <div v-if="isOwner(r)" class="absolute top-2 right-2">
          <button @click="openMenu(r)" class="text-muted-foreground hover:text-foreground">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2z" />
            </svg>
          </button>
          <div v-if="menuOpen === r.id" class="absolute right-0 mt-1 w-40 bg-white border rounded shadow z-10">
            <button @click="reportContent(r)" class="block w-full text-left px-3 py-2 text-sm text-destructive">
              Denunciar reseña
            </button>
          </div>
        </div>

        <div class="flex items-start gap-3">
          <img
            :src="r.user_avatar || r.provider_avatar || '/default-avatar.png'"
            alt="avatar"
            class="w-10 h-10 rounded-full object-cover"
            loading="lazy"
          />
          <div class="flex-1">
            <p class="font-semibold">{{ r.user_name || r.provider_name }}</p>
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

            <!-- Respuesta -->
            <div v-if="(r.provider_reply || r.user_reply)" class="mt-3 p-3 bg-accent/10 rounded border border-accent/30 text-sm">
              <p class="font-semibold text-accent">
                {{ r.type === 'service_review' ? 'Respuesta del proveedor' : 'Tu respuesta' }}
              </p>
              <p>{{ (r.provider_reply || r.user_reply).message }}</p>
              <p class="text-xs text-muted-foreground mt-1">
                {{ dayjs((r.provider_reply || r.user_reply).created_at).fromNow() }}
              </p>
            </div>

            <!-- Acciones -->
            <div class="flex items-center gap-3 mt-3 text-xs">
              <button type="button" @click="markHelpful(r)" class="text-muted-foreground hover:text-foreground">
                👍 {{ r.helpful_count || 0 }}
              </button>

              <!-- Botón Responder/Actualizar SOLO para quien recibió la reseña -->
              <template v-if="canReply(r)">
                <button
                  v-if="!(r.provider_reply || r.user_reply)"
                  type="button"
                  @click="openReply(r)"
                  class="text-accent"
                >
                  Responder
                </button>
                <button
                  v-else
                  type="button"
                  @click="openUpdate(r)"
                  class="text-accent"
                >
                  Actualizar
                </button>
              </template>

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
    :mode="modalMode"
    :targetRole="targetRole"
    :authToken="authStore.token"
    :serviceHistoryId="currentServiceHistoryId"
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
const menuOpen = ref<number | null>(null)
const modalMode = ref<'new' | 'reply' | 'edit'>('reply') // ✅ Ahora incluye 'new'
const targetRole = ref<'provider' | 'user'>('provider')
const showForm = ref(false)
const currentEdit = ref<Review | null>(null)
const currentServiceHistoryId = ref<number | string | undefined>(undefined)

/* ----------  ROLES  ---------- */
const isProvider = computed(() => authStore.user?.role === 'provider')

/* ----------  OWNER LOGIC: Quién puede denunciar  ---------- */
const isOwner = (r: Review): boolean => {
  if (!authStore.user?.id) return false
  const userId = Number(authStore.user.id)
  
  if (r.type === 'service_review') return Number(r.user_id) === userId
  if (r.type === 'user_review') return Number(r.provider_id) === userId
  return false
}

/* ----------  REPLY LOGIC: Quién puede responder  ---------- */
const canReply = (r: Review): boolean => {
  if (!authStore.user?.role) return false
  
  if (r.type === 'service_review') return isProvider.value
  if (r.type === 'user_review') return !isProvider.value
  return false
}

/* ----------  DATA FETCH  ---------- */
async function loadReviews() {
  try {
    const { data } = await api.get('/reviews/received', {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })

    reviews.value = data.reviews.map((r: any) => ({
      ...r,
      // ✅ Determinar tipo correctamente por la tabla de origen
      type: r.provider_reply !== undefined ? 'service_review' : 'user_review',
      // ✅ Asegurar IDs numéricos para comparaciones
      id: Number(r.id),
      user_id: r.user_id ? Number(r.user_id) : undefined,
      provider_id: r.provider_id ? Number(r.provider_id) : undefined
    }))

    average.value = data.average || 0
    total.value = data.total || 0
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

function openReply(r: Review) {
  // ✅ NO sobrescribir los datos originales
  currentEdit.value = {
    id: r.id,
    rating: r.rating,
    comment: '', // Respuesta nueva empieza vacía
    type: r.type
  } as Review
  
  modalMode.value = 'reply'
  targetRole.value = r.type === 'service_review' ? 'provider' : 'user'
  currentServiceHistoryId.value = r.service_history_id
  showForm.value = true
}

function openUpdate(r: Review) {
  const reply = r.type === 'service_review' ? r.provider_reply : r.user_reply
  
  // ✅ Cargar solo el mensaje de respuesta, no sobrescribir el comentario original
  currentEdit.value = {
    id: r.id,
    rating: r.rating,
    comment: reply?.message || '',
    type: r.type
  } as Review
  
  modalMode.value = 'edit'
  targetRole.value = r.type === 'service_review' ? 'provider' : 'user'
  currentServiceHistoryId.value = r.service_history_id
  showForm.value = true
}

function openMenu(r: Review) {
  menuOpen.value = menuOpen.value === r.id ? null : r.id
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

async function reportContent(r: Review) {
  try {
    const reason = prompt('¿Motivo de la denuncia? (ofensiva, falsa, spam, etc.)')
    if (!reason) return

    await api.post(
      '/reviews/report-content',
      {
        review_id: r.id,
        reason,
        comment: `Denunciado por el ${authStore.user?.role}: ${authStore.user?.name}`
      },
      { headers: { Authorization: `Bearer ${authStore.token}` } }
    )
  } catch (e) {
    console.error('Error al denunciar:', e)
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
  if (!payload || typeof payload.comment !== 'string') {
    console.warn('Save emitido sin payload válido')
    return
  }

  const reviewId = currentEdit.value?.id
  if (!reviewId) return

  try {
    if (modalMode.value === 'reply') {
      await api.post(
        `/api/reviews/${reviewId}/reply`,
        {
          message: payload.comment,
          targetRole: targetRole.value
        },
        { headers: { Authorization: `Bearer ${authStore.token}` } }
      )
    }

    if (modalMode.value === 'edit') {
      await api.put(
        `/api/reviews/${reviewId}/reply`,
        { message: payload.comment },
        { headers: { Authorization: `Bearer ${authStore.token}` } }
      )
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
    const photosData = r.photos || '[]'
    return Array.isArray(photosData) ? photosData : JSON.parse(photosData)
  } catch {
    return []
  }
}

function safeTags(r: Review): string[] {
  try {
    const tagsData = r.tags || '[]'
    return Array.isArray(tagsData) ? tagsData : JSON.parse(tagsData)
  } catch {
    return []
  }
}
</script>
