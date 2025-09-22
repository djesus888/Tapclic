<!-- src/components/ReviewFormModal.vue -->
<template>
  <Teleport to="body">
    <div
      class="fixed inset-0 z-50 flex items-end justify-center bg-black/40 md:items-center"
      @click.self="$emit('close')"
    >
      <div
        class="w-full max-w-2xl bg-background rounded-t-2xl md:rounded-2xl p-6 max-h-[90vh] overflow-y-auto"
      >
        <!-- Header -->
        <div class="flex items-center justify-between mb-4">
          <h2 class="text-lg font-semibold">
            {{ isEdit ? 'Editar reseña' : 'Nueva reseña' }}
          </h2>
          <button
            @click="$emit('close')"
            class="text-muted-foreground hover:text-foreground"
            aria-label="Cerrar modal"
          >
            <svg
              class="w-6 h-6"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M6 18L18 6M6 6l12 12"
              />
            </svg>
          </button>
        </div>

        <!-- Estrellas -->
        <div class="mb-4">
          <label class="block text-sm font-medium mb-2">Calificación *</label>
          <div class="flex gap-2">
            <button
              v-for="i in 5"
              :key="i"
              @click="rating = i"
              class="transition-transform hover:scale-110"
              :aria-label="`Calificar ${i} estrella${i > 1 ? 's' : ''}`"
            >
              <svg
                class="w-8 h-8"
                :class="i <= rating ? 'text-yellow-400' : 'text-gray-300'"
                fill="currentColor"
                viewBox="0 0 20 20"
              >
                <path
                  d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"
                />
              </svg>
            </button>
          </div>
        </div>

        <!-- Comentario -->
        <div class="mb-4">
          <label class="block text-sm font-medium mb-2">Comentario</label>
          <textarea
            v-model="comment"
            rows="4"
            maxlength="500"
            class="w-full border rounded-lg p-2 resize-none"
            placeholder="Cuéntanos tu experiencia..."
          />
          <div class="text-right text-xs text-muted-foreground mt-1">
            {{ comment.length }}/500
          </div>
        </div>

        <!-- Tags rápidos -->
        <div class="mb-4">
          <label class="block text-sm font-medium mb-2">Tags rápidos</label>
          <div class="flex flex-wrap gap-2">
            <button
              v-for="tag in quickTags"
              :key="tag"
              @click="toggleTag(tag)"
              class="px-3 py-1 text-sm border rounded-full transition"
              :class="
                safeTags.includes(tag)
                  ? 'bg-accent text-white border-accent'
                  : 'bg-white text-foreground border-border'
              "
            >
              {{ tag }}
            </button>
          </div>
        </div>

        <!-- Fotos -->
        <div class="mb-4">
          <label class="block text-sm font-medium mb-2">Fotos (máx. 3)</label>
          <div class="flex gap-2 mb-2">
            <div v-for="(img, i) in safePhotos" :key="i" class="relative">
              <img
                :src="img"
                class="w-20 h-20 object-cover rounded border"
                alt="Foto adjunta"
              />
              <button
                @click="removePhoto(i)"
                class="absolute -top-2 -right-2 bg-destructive text-white rounded-full w-6 h-6 grid place-items-center"
                aria-label="Eliminar foto"
              >
                <svg
                  class="w-4 h-4"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M6 18L18 6M6 6l12 12"
                  />
                </svg>
              </button>
            </div>
            <button
              v-if="safePhotos.length < 3"
              @click="openFilePicker"
              class="w-20 h-20 border-2 border-dashed border-border rounded flex flex-col items-center justify-center text-muted-foreground hover:text-foreground"
            >
              <svg class="w-6 h-6 mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 4v16m8-8H4"
                />
              </svg>
              <span class="text-xs">Añadir</span>
            </button>
          </div>
          <!-- input oculto -->
          <input
            ref="fileInput"
            type="file"
            accept="image/*"
            class="hidden"
            @change="handleFile"
          />
        </div>

        <!-- Acciones -->
        <div class="flex gap-2">
          <button
            @click="$emit('close')"
            class="flex-1 border py-2 rounded-lg"
          >
            Cancelar
          </button>
          <button
            @click="submit"
            :disabled="rating === 0 || sending"
            class="flex-1 bg-accent text-white py-2 rounded-lg disabled:opacity-50"
          >
            {{ sending ? 'Enviando...' : isEdit ? 'Actualizar' : 'Publicar' }}
          </button>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import api from '@/axios' // <-- usamos Axios siempre

/* ---------- Tipos ---------- */
export interface Review {
  id?: string | number
  rating: number
  comment?: string
  tags?: string[] | string
  photos?: string[] | string
  provider_reply?: {
    message: string
    created_at: string
  }
  helpful_count?: number
  created_at?: string
}

/* ---------- Props & Emits ---------- */
const props = defineProps<{
  modelValue: Review | null
  uploadUrl?: string
  authToken?: string
}>()

const emit = defineEmits<{
  close: []
  save: [payload: Omit<Review, 'id' | 'created_at'>]
}>()

/* ---------- Estado ---------- */
const isEdit = computed(() => !!props.modelValue)
const rating = ref(props.modelValue?.rating || 0)
const comment = ref(props.modelValue?.comment || '')

/* inicializamos parseando */
const tags   = ref<string[]>(parseTags(props.modelValue))
const photos = ref<string[]>(parsePhotos(props.modelValue))

const sending = ref(false)
const quickTags = ['Puntual', 'Profesional', 'Calidad', 'Limpio', 'Buen precio', 'Amable']
const fileInput = ref<HTMLInputElement>()

/* ---------- Computed que usan el template ---------- */
const safePhotos = computed(() => photos.value)
const safeTags   = computed(() => tags.value)

/* ---------- Métodos ---------- */
function toggleTag(t: string) {
  tags.value = tags.value.includes(t)
    ? tags.value.filter(x => x !== t)
    : [...tags.value, t]
}

function openFilePicker() {
  fileInput.value?.click()
}

function removePhoto(idx: number) {
  photos.value.splice(idx, 1)
}

/* subida con Axios (sin barra inicial) */
async function handleFile(e: Event) {
  const target = e.target as HTMLInputElement
  const file = target.files?.[0]
  if (!file) return
  if (photos.value.length >= 3) return

  const localUrl = URL.createObjectURL(file)
  photos.value.push(localUrl)

  const fd = new FormData()
  fd.append('file', file)

  try {
    const { url } = await api.post(
      'reviews/imag', // <-- sin barra inicial
      fd,
      { headers: { ...(props.authToken && { Authorization: `Bearer ${props.authToken}` }) } }
    )
    const idx = photos.value.indexOf(localUrl)
    if (idx !== -1) photos.value[idx] = url
    URL.revokeObjectURL(localUrl)
  } catch (err) {
    photos.value = photos.value.filter(u => u !== localUrl)
    alert('Error al subir la imagen')
    console.error(err)
  } finally {
    target.value = ''
  }
}

/* guardar con Axios (sin barra inicial) */
async function submit() {
  if (rating.value === 0) return
  sending.value = true

  const payload: Omit<Review, 'id' | 'created_at'> = {
    rating: rating.value,
    comment: comment.value.trim(),
    tags: tags.value,
    photos: photos.value
  }

  try {
    await api({
      method: isEdit.value ? 'PUT' : 'POST',
      url: isEdit.value ? `reviews/${props.modelValue?.id}/reply` : 'reviews',
      data: payload,
      headers: { ...(props.authToken && { Authorization: `Bearer ${props.authToken}` }) }
    })
    emit('save', payload)
  } catch (err) {
    alert('No se pudo guardar la reseña')
    console.error(err)
  } finally {
    sending.value = false
  }
}

/* ----------------------------------------------------------
   HELPERS: siempre devuelven ARRAY (nunca rompen el v-for)
---------------------------------------------------------- */
function parsePhotos(r: Review | null): string[] {
  if (!r) return []
  try {
    return Array.isArray(r.photos) ? r.photos : JSON.parse((r.photos as string) || '[]')
  } catch {
    return []
  }
}

function parseTags(r: Review | null): string[] {
  if (!r) return []
  try {
    return Array.isArray(r.tags) ? r.tags : JSON.parse((r.tags as string) || '[]')
  } catch {
    return []
  }
}
</script>
