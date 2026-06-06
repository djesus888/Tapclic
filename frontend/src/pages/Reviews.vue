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
        <!-- Menú derecha-arriba: solo visible si puede reportar (no es el dueño) -->
        <div v-if="canReport(r)" class="absolute top-2 right-2">
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
            :src="getAvatarUrl(r)" 
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
                :src="getImageUrl(src, getPhotoFolder(r))"
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
                {{ getReplyLabel(r) }}
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
    :reviewType="currentReviewType"
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
import { getImageUrl } from '@/utils/imageHelper.js'

dayjs.extend(relativeTime)
dayjs.locale('es')

/* ----------  STATE  ---------- */
const authStore = useAuthStore()
const reviews = ref<Review[]>([])
const average = ref(0)
const total = ref(0)
const loading = ref(true)
const menuOpen = ref<number | null>(null)
const modalMode = ref<'new' | 'reply' | 'edit'>('reply')
const targetRole = ref<'provider' | 'user'>('provider')
const showForm = ref(false)
const currentEdit = ref<Review | null>(null)
const currentServiceHistoryId = ref<number | string | undefined>(undefined)
const currentReviewType = ref<'service' | 'user'>('service')

/* ----------  ROLES  ---------- */
const isProvider = computed(() => authStore.user?.role === 'provider')
const isAdmin = computed(() => authStore.user?.role === 'admin')
const currentUserRole = computed(() => authStore.user?.role as string)

/* ----------  HELPERS  ---------- */
function getReviewType(r: Review): 'service' | 'user' {
  return (r as any).review_type || r.type || 'service'
}

function getAvatarUrl(r: Review): string {
  const avatar = r.user_avatar || r.provider_avatar || (r as any).provider_avatar
  return getImageUrl(avatar, 'avatar') || '/default-avatar.png'
}

function getPhotoFolder(r: Review): string {
  return getReviewType(r) === 'user' ? 'user-reviews' : 'reviews'
}

function getReplyLabel(r: Review): string {
  if (getReviewType(r) === 'service') {
    return 'Respuesta del proveedor'
  }
  return 'Tu respuesta'
}

/* ----------  OWNER LOGIC: Quién puede denunciar (cualquiera menos el dueño) ---------- */
const isOwner = (r: Review): boolean => {
  if (!authStore.user?.id) return false
  const userId = Number(authStore.user.id)
  const type = getReviewType(r)

  if (type === 'service') return Number((r as any).user_id) === userId
  if (type === 'user') return Number((r as any).provider_id) === userId
  return false
}

const canReport = (r: Review): boolean => {
  // Cualquiera autenticado que no sea el dueño puede reportar
  return !!authStore.user?.id && !isOwner(r)
}

/* ----------  REPLY LOGIC: Quién puede responder ---------- */
const canReply = (r: Review): boolean => {
  if (!authStore.user?.role) return false
  const role = authStore.user.role
  const type = getReviewType(r)
  const userId = Number(authStore.user.id)

  // Admin puede responder cualquier reseña
  if (role === 'admin') return true

  // Proveedor responde a service_reviews que son para él
  if (type === 'service' && role === 'provider') {
    return Number((r as any).provider_id) === userId
  }

  // Usuario responde a user_reviews que son para él
  if (type === 'user' && role === 'user') {
    return Number((r as any).user_id) === userId
  }

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
      type: r.review_type || (r.provider_reply !== undefined ? 'service' : 'user'),
      id: Number(r.id),
      user_id: r.user_id ? Number(r.user_id) : undefined,
      provider_id: r.provider_id ? Number(r.provider_id) : undefined,
      service_history_id: r.service_history_id ? Number(r.service_history_id) : undefined,
      review_type: r.review_type || (r.provider_reply !== undefined ? 'service' : 'user')
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
  const type = getReviewType(r)
  currentEdit.value = {
    id: r.id,
    rating: r.rating,
    comment: '',
    type: type,
    review_type: type
  } as Review

  modalMode.value = 'reply'
  targetRole.value = type === 'service' ? 'provider' : 'user'
  currentServiceHistoryId.value = (r as any).service_history_id
  currentReviewType.value = type
  showForm.value = true
}

function openUpdate(r: Review) {
  const type = getReviewType(r)
  const reply = type === 'service' ? r.provider_reply : r.user_reply

  currentEdit.value = {
    id: r.id,
    rating: r.rating,
    comment: reply?.message || '',
    type: type,
    review_type: type
  } as Review

  modalMode.value = 'edit'
  targetRole.value = type === 'service' ? 'provider' : 'user'
  currentServiceHistoryId.value = (r as any).service_history_id
  currentReviewType.value = type
  showForm.value = true
}

function openMenu(r: Review) {
  menuOpen.value = menuOpen.value === r.id ? null : r.id
}

/* ----------  ACTIONS  ---------- */
async function markHelpful(r: Review) {
  try {
    const { data } = await api.post(
      '/reviews/helpful',
      { 
        review_id: r.id, 
        review_type: getReviewType(r) 
      },
      { headers: { Authorization: `Bearer ${authStore.token}` } }
    )
    r.helpful_count = data.helpful_count || (r.helpful_count || 0) + 1
  } catch (e) {
    console.error('Error al marcar como útil:', e)
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
        review_type: getReviewType(r),
        reason,
        comment: `Denunciado por el ${authStore.user?.role}: ${authStore.user?.name}`
      },
      { headers: { Authorization: `Bearer ${authStore.token}` } }
    )
    alert('Denuncia enviada. Gracias por ayudarnos.')
  } catch (e) {
    console.error('Error al denunciar:', e)
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
        `/reviews/${reviewId}/reply`,
        {
          message: payload.comment,
          review_type: currentReviewType.value
        },
        { headers: { Authorization: `Bearer ${authStore.token}` } }
      )
    }

    if (modalMode.value === 'edit') {
      await api.put(
        `/reviews/${reviewId}/reply`,
        { 
          message: payload.comment,
          review_type: currentReviewType.value
        },
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
    const photosData = (r as any).photos || '[]'
    return Array.isArray(photosData) ? photosData : JSON.parse(photosData)
  } catch {
    return []
  }
}

function safeTags(r: Review): string[] {
  try {
    const tagsData = (r as any).tags || '[]'
    return Array.isArray(tagsData) ? tagsData : JSON.parse(tagsData)
  } catch {
    return []
  }
}
</script>
