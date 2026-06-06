<template>
  <Teleport to="body">
    <div
      class="fixed inset-0 z-50 flex items-end justify-center bg-black/40 md:items-center"
      @click.self="emit('close')"
    >
      <div
        class="w-full max-w-2xl bg-background rounded-t-2xl md:rounded-2xl p-6 max-h-[90vh] overflow-y-auto"
      >
        <!-- Header -->
        <div class="flex items-center justify-between mb-4">
          <h2 class="text-lg font-semibold">
            {{ headerText }}
          </h2>
          <button
            @click="emit('close')"
            class="text-muted-foreground hover:text-foreground"
            aria-label="Cerrar modal"
          >
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
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

        <!-- Tags -->
        <div class="mb-4">
          <label class="block text-sm font-medium mb-2">Tags rápidos</label>
          <div class="flex flex-wrap gap-2">
            <button
              v-for="tag in quickTags"
              :key="tag"
              @click="toggleTag(tag)"
              class="px-3 py-1 text-sm border rounded-full"
              :class="tags.includes(tag)
                ? 'bg-accent text-white border-accent'
                : 'bg-white border-border'"
            >
              {{ tag }}
            </button>
          </div>
        </div>

        <!-- Fotos -->
        <div class="mb-4">
          <label class="block text-sm font-medium mb-2">Fotos (máx. 3)</label>
          <div class="flex gap-2 mb-2">
            <div v-for="(img, i) in photos" :key="i" class="relative">
              <img
                :src="img.preview || img.url"
                class="w-20 h-20 object-cover rounded border"
              />
              <button
                @click="removePhoto(i)"
                class="absolute -top-2 -right-2 bg-destructive text-white rounded-full w-6 h-6 grid place-items-center"
              >
                ✕
              </button>
            </div>

            <button
              v-if="photos.length < 3"
              @click="openFilePicker"
              class="w-20 h-20 border-2 border-dashed rounded flex items-center justify-center"
            >
              +
            </button>
          </div>

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
          <button @click="emit('close')" class="flex-1 border py-2 rounded-lg">
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
import { ref, computed, onBeforeUnmount, watch, onUnmounted } from 'vue'
import api from '@/axios'

export interface Review {
  id?: number | string;
  rating: number;
  comment?: string;
  tags?: string[] | string;
  photos?: string[] | string;
}

const props = defineProps<{
  modelValue?: Review | null;
  mode?: 'new' | 'reply' | 'edit';
  targetRole?: 'user' | 'provider';
  reviewType?: 'service' | 'user';
  authToken?: string;
  serviceHistoryId?: number | string;
  divId?: string;
}>()

const emit = defineEmits(['close', 'save'])

const isEdit = computed(() => props.mode === 'edit')

const headerText = computed(() => {
  if (props.mode === 'reply') return 'Responder reseña'
  if (props.mode === 'edit') return 'Editar reseña'
  return 'Nueva reseña'
})

const rating = ref(0)
const comment = ref('')
const tags = ref<string[]>([])

type Photo = {
  id: string
  file?: File
  url?: string
  preview?: string
}

const photos = ref<Photo[]>([])
const sending = ref(false)

const quickTags = ['Puntual', 'Profesional', 'Calidad', 'Limpio', 'Buen precio', 'Amable']
const fileInput = ref<HTMLInputElement>()
const blobUrls = new Set<string>()

function generateId(): string {
  return Date.now().toString(36) + Math.random().toString(36).substring(2)
}

function getReviewType(): string {
  return props.reviewType || 'service'
}

// Inicializar desde modelValue
function initializeFromProps() {
  rating.value = props.modelValue?.rating || 0
  comment.value = props.modelValue?.comment || ''

  const val = props.modelValue?.tags
  if (val) {
    tags.value = Array.isArray(val) ? val : val.split(',').filter(Boolean)
  } else {
    tags.value = []
  }

  photos.value = props.modelValue?.photos
    ? (Array.isArray(props.modelValue.photos)
        ? props.modelValue.photos.map((url: string) => ({
            id: generateId(),
            url
          }))
        : [{
            id: generateId(),
            url: props.modelValue.photos as string
          }])
    : []
}

// Watch para reinicializar cuando modelValue cambie
watch(() => props.modelValue, initializeFromProps, { immediate: true })

function resolveSrc(img: any) {
  return img.preview || img.url || ''
}

// Limpiar URLs de blobs al desmontar
onBeforeUnmount(() => {
  blobUrls.forEach(URL.revokeObjectURL)
})

// Limpiar elemento DOM si quedó colgado
onUnmounted(() => {
  if (props.divId) {
    const el = document.getElementById(props.divId)
    if (el) {
      el.remove()
      console.log(`🧹 Elemento DOM #${props.divId} limpiado automáticamente`)
    }
  }
})

function toggleTag(t: string) {
  tags.value = tags.value.includes(t)
    ? tags.value.filter(x => x !== t)
    : [...tags.value, t]
}

function openFilePicker() {
  fileInput.value?.click()
}

function removePhoto(i: number) {
  // Limpiar blob URL si existe preview
  const img = photos.value[i]
  if (img.preview) {
    blobUrls.delete(img.preview)
    URL.revokeObjectURL(img.preview)
  }
  photos.value.splice(i, 1)
}

async function handleFile(e: Event) {
  const input = e.target as HTMLInputElement
  const file = input.files?.[0]

  if (!file || photos.value.length >= 3) {
    input.value = ''
    return
  }

  const preview = URL.createObjectURL(file)

  photos.value.push({
    id: generateId(),
    file,
    preview
  })

  input.value = ''
}

function resetForm() {
  rating.value = 0
  comment.value = ''
  tags.value = []
  photos.value = []
  sending.value = false
}

async function submit() {
  if (!props.serviceHistoryId && !isEdit.value) {
    alert('Error: ID de servicio no proporcionado')
    return
  }

  if (rating.value === 0 && !isEdit.value) {
    alert('Debes seleccionar una calificación')
    return
  }

  sending.value = true
  const token = props.authToken || localStorage.getItem('token')
  const headers = { Authorization: `Bearer ${token}` }

  try {
    if (isEdit.value) {
      // Editar reseña existente
      await api.put(
        `/reviews/${props.modelValue?.id}`,
        {
          rating: rating.value,
          comment: comment.value,
          tags: tags.value,
          photos: photos.value.filter(p => p.url).map(p => p.url),
          review_type: getReviewType()
        },
        { headers }
      )
    } else {
      // Nueva reseña: subir imágenes primero
      const uploadPromises = photos.value.map(async (p) => {
        if (p.url) return p.url

        const fd = new FormData()
        fd.append('file', p.file!)

        const { data } = await api.post('/reviews/image', fd, {
          headers: {
            Authorization: `Bearer ${token}`
          }
        })

        return data.url
      })

      const uploadedPhotos = await Promise.all(uploadPromises)

      // Nueva reseña: decidir endpoint según quién califica
      // targetRole = a quién va dirigida la calificación
      // Si targetRole es 'provider' → el usuario califica al proveedor → /history/rate
      // Si targetRole es 'user' → el proveedor/admin califica al usuario → /history/rate-user
      const endpoint = props.targetRole === 'user'
        ? '/history/rate-user'
        : '/history/rate'

      console.log('🚀 ReviewModal endpoint:', endpoint, 'targetRole:', props.targetRole)

      const payload: any = {
        id: props.serviceHistoryId,
        service_history_id: props.serviceHistoryId,
        rating: rating.value,
        comment: comment.value,
        tags: tags.value.join(','),
        photos: uploadedPhotos.join(',')
      }

      await api.post(endpoint, payload, { headers })
    }

    emit('save', {
      rating: rating.value,
      comment: comment.value,
      tags: tags.value,
      photos: photos.value
    })
    emit('close')
    resetForm()
  } catch (error: any) {
    console.error('Error al enviar reseña:', error)
    const message = error.response?.data?.message || error.message || 'Error al enviar la reseña. Intenta nuevamente.'
    alert(message)
  } finally {
    sending.value = false
  }
}
</script>
