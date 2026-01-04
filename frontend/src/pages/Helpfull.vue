<template>
  <div class="max-w-3xl mx-auto p-6">

    <!-- Encabezado -->
    <div class="flex items-center gap-4 mb-6">
      <img
        :src="profile.avatar_url || '/default-avatar.png'"
        class="w-20 h-20 rounded-full object-cover border"
      />

      <div>
        <h1 class="text-2xl font-bold">{{ profile.name }}</h1>

        <p class="text-muted-foreground text-sm capitalize">
          Rol: {{ profile.role }}
        </p>

        <div class="flex items-center gap-2 mt-2">
          <StarRating :rating="average" class="text-xl" />
          <span class="text-muted-foreground text-sm">
            {{ average }} ({{ total }} reseñas)
          </span>
        </div>
      </div>
    </div>

    <ReviewFilters @change="filters = $event" />

    <!-- Loading -->
    <div v-if="loading" class="space-y-4">
      <div v-for="i in 3" :key="i" class="p-4 border rounded animate-pulse">
        <div class="h-5 bg-gray-300 rounded w-1/3 mb-2" />
        <div class="h-4 bg-gray-200 rounded w-2/3" />
      </div>
    </div>

    <div v-else-if="!filtered.length" class="text-center text-muted-foreground mt-10">
      No hay reseñas que coincidan con los filtros.
    </div>

    <!-- Lista de reseñas -->
    <div v-else class="space-y-4">
      <div
        v-for="r in filtered"
        :key="r.id"
        class="p-4 border rounded-lg shadow-sm"
      >
        <div class="flex items-start gap-3">

          <img
            :src="r.reviewer_avatar || '/default-avatar.png'"
            class="w-10 h-10 rounded-full object-cover"
          />

          <div class="flex-1">

            <p class="font-semibold">{{ r.reviewer_name }}</p>
            <p class="text-sm text-muted-foreground">{{ r.service_title }}</p>

            <StarRating :rating="r.rating" class="mt-1" />

            <div v-if="safePhotos(r).length" class="flex gap-2 mt-2 overflow-x-auto flex-nowrap">
              <img
                v-for="(src, idx) in safePhotos(r)"
                :key="idx"
                :src="src"
                class="w-16 h-16 rounded object-cover border"
              />
            </div>

            <p v-if="r.comment" class="mt-2 text-sm">
              {{ r.comment }}
            </p>

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
            <div
              v-if="r.reply"
              class="mt-3 p-3 bg-accent/10 rounded border border-accent/30 text-sm"
            >
              <p class="font-semibold text-accent">Respuesta del proveedor</p>
              <p>{{ r.reply }}</p>
              <p class="text-xs text-muted-foreground mt-1">
                {{ dayjs(r.reply_at).fromNow() }}
              </p>
            </div>

            <!-- Acciones -->
            <div class="flex items-center gap-3 mt-3 text-xs">
              <button
                @click="markHelpful(r)"
                class="text-muted-foreground hover:text-foreground"
              >
                Útil ({{ r.helpful_count || 0 }})
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
</template>


<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import dayjs from 'dayjs'
import relativeTime from 'dayjs/plugin/relativeTime'
import 'dayjs/locale/es'
import api from '@/axios'
import StarRating from '@/components/StarRating.vue'
import ReviewFilters from '@/components/ReviewFilters.vue'
import { useReviews } from '@/utils/useReviews'

dayjs.extend(relativeTime)
dayjs.locale('es')

/* ---------- ROUTE ---------- */
const route = useRoute()
const pageId = Number(route.params.id) // El ID de perfil public que quieres ver

/* ---------- STATE ---------- */
const profile = ref<any>({})
const me = ref<any>(null)
const reviews = ref([])
const average = ref(0)
const total = ref(0)
const loading = ref(true)

/* ---------- LOAD AUTH USER ---------- */
async function loadMe() {
  const { data } = await api.get('/auth/user')
  me.value = data.data
}

/* ---------- LOAD PROFILE ---------- */
async function loadProfile() {
  if (!pageId || pageId === me.value.id) {
    // viendo tu propio perfil
    profile.value = me.value
  } else {
    // viendo perfil público
    const { data } = await api.get(`/users/${pageId}`)
    profile.value = data.data
  }
}

/* ---------- LOAD REVIEWS BY ROLE ---------- */
async function loadReviews() {
  const isOwnProfile = pageId === me.value.id
  const role = me.value.role
  const targetId = pageId || me.value.id

  let endpoint = ''

  if (isOwnProfile) {
    if (role === 'provider') endpoint = '/reviews/provider'
    else if (role === 'user') endpoint = '/reviews/user'
    else if (role === 'admin') endpoint = `/reviews/user/${targetId}`
  } else {
    endpoint = `/reviews/user/${targetId}`
  }

  const { data } = await api.get(endpoint)
  reviews.value = data.data.reviews
  average.value = data.data.average
  total.value = data.data.total
}

/* ---------- MARK HELPFUL ---------- */
async function markHelpful(r: any) {
  try {
    await api.post('/reviews/helpful', { review_id: r.id })
    r.helpful_count = (r.helpful_count || 0) + 1
  } catch {}
}

/* ---------- FILTERS ---------- */
const { filters, filtered } = useReviews(reviews)

/* ---------- HELPERS ---------- */
function safePhotos(r: any): string[] {
  try {
    return Array.isArray(r.photos) ? r.photos : JSON.parse(r.photos || '[]')
  } catch { return [] }
}
function safeTags(r: any): string[] {
  try {
    return Array.isArray(r.tags) ? r.tags : JSON.parse(r.tags || '[]')
  } catch { return [] }
}

/* ---------- INIT ---------- */
onMounted(async () => {
  await loadMe()
  await loadProfile()
  await loadReviews()
  loading.value = false
})
</script>
