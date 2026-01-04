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
          <h2 class="text-lg font-semibold">{{ headerText }}</h2>
          <button
            @click="$emit('close')"
            class="text-muted-foreground hover:text-foreground"
            aria-label="Cerrar modal"
          >
            ✕
          </button>
        </div>

        <!-- ⭐ Rating SOLO para reseña -->
        <div v-if="isReview" class="mb-4">
          <label class="block text-sm font-medium mb-2">Calificación *</label>
          <div class="flex gap-2">
            <button
              v-for="i in 5"
              :key="i"
              @click="rating = i"
            >
              <span
                :class="i <= rating ? 'text-yellow-400' : 'text-gray-300'"
                class="text-2xl"
              >★</span>
            </button>
          </div>
        </div>

        <!-- Comentario / Respuesta -->
        <div class="mb-4">
          <label class="block text-sm font-medium mb-2">
            {{ isReply ? 'Respuesta' : 'Comentario' }}
          </label>
          <textarea
            v-model="comment"
            rows="4"
            maxlength="500"
            class="w-full border rounded-lg p-2 resize-none"
          />
          <div class="text-right text-xs text-muted-foreground mt-1">
            {{ comment.length }}/500
          </div>
        </div>

        <!-- Tags SOLO reseña -->
        <div v-if="isReview" class="mb-4">
          <label class="block text-sm font-medium mb-2">Tags</label>
          <div class="flex flex-wrap gap-2">
            <button
              v-for="tag in quickTags"
              :key="tag"
              @click="toggleTag(tag)"
              class="px-3 py-1 text-sm border rounded-full"
              :class="tags.includes(tag)
                ? 'bg-accent text-white'
                : 'bg-white'"
            >
              {{ tag }}
            </button>
          </div>
        </div>

        <!-- Fotos SOLO reseña -->
        <div v-if="isReview" class="mb-4">
          <label class="block text-sm font-medium mb-2">Fotos (máx. 3)</label>
          <div class="flex gap-2 mb-2">
            <div
              v-for="(img, i) in photos"
              :key="i"
              class="relative"
            >
              <img
                :src="img"
                class="w-20 h-20 object-cover rounded border"
              />
              <button
                @click="removePhoto(i)"
                class="absolute -top-2 -right-2 bg-red-500 text-white rounded-full w-6 h-6"
              >✕</button>
            </div>

            <button
              v-if="photos.length < 3"
              @click="openFilePicker"
              class="w-20 h-20 border-2 border-dashed rounded"
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
          <button
            @click="$emit('close')"
            class="flex-1 border py-2 rounded-lg"
          >
            Cancelar
          </button>
          <button
            @click="submit"
            :disabled="sending || (isReview && rating === 0)"
            class="flex-1 bg-accent text-white py-2 rounded-lg disabled:opacity-50"
          >
            {{ sending ? 'Enviando...' : submitText }}
          </button>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import api from '@/axios'

/* ---------- Props ---------- */
const props = defineProps<{
  modelValue: any
  mode: 'new' | 'edit' | 'reply' | 'edit-reply'
  authToken?: string
  serviceHistoryId?: number | string
  targetRole?: 'user' | 'provider'
}>()

const emit = defineEmits(['close', 'save'])

/* ---------- Estado ---------- */
const rating = ref(props.modelValue?.rating || 0)
const comment = ref(
  props.mode.includes('reply')
    ? props.modelValue?.provider_reply?.message ||
      props.modelValue?.user_reply?.message ||
      ''
    : props.modelValue?.comment || ''
)

const tags = ref<string[]>(
  Array.isArray(props.modelValue?.tags)
    ? props.modelValue.tags
    : []
)

const photos = ref<string[]>(
  Array.isArray(props.modelValue?.photos)
    ? props.modelValue.photos
    : []
)

const sending = ref(false)
const fileInput = ref<HTMLInputElement>()

const quickTags = ['Puntual', 'Profesional', 'Calidad', 'Amable']

/* ---------- Computed ---------- */
const isReply = computed(() =>
  props.mode === 'reply' || props.mode === 'edit-reply'
)

const isReview = computed(() => !isReply.value)

const headerText = computed(() => {
  if (props.mode === 'new') return 'Nueva reseña'
  if (props.mode === 'edit') return 'Editar reseña'
  if (props.mode === 'reply') return 'Responder reseña'
  return 'Editar respuesta'
})

const submitText = computed(() => {
  if (props.mode === 'edit') return 'Actualizar'
  if (props.mode === 'edit-reply') return 'Actualizar respuesta'
  return 'Publicar'
})

/* ---------- Métodos ---------- */
function toggleTag(tag: string) {
  tags.value = tags.value.includes(tag)
    ? tags.value.filter(t => t !== tag)
    : [...tags.value, tag]
}

function openFilePicker() {
  fileInput.value?.click()
}

function removePhoto(i: number) {
  photos.value.splice(i, 1)
}

async function handleFile(e: Event) {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (!file || photos.value.length >= 3) return

  const fd = new FormData()
  fd.append('file', file)

  const { url } = await api.post(
    'reviews/image',
    fd,
    { headers: authHeaders() }
  )

  photos.value.push(url)
  ;(e.target as HTMLInputElement).value = ''
}

function authHeaders() {
  return props.authToken
    ? { Authorization: `Bearer ${props.authToken}` }
    : {}
}

async function submit() {
  sending.value = true

  try {
    if (props.mode === 'new') {
      await api.post(
        'reviews',
        {
          rating: rating.value,
          comment: comment.value,
          tags: tags.value,
          photos: photos.value,
          service_history_id: props.serviceHistoryId,
          targetRole: props.targetRole
        },
        { headers: authHeaders() }
      )
    }

    if (props.mode === 'edit') {
      await api.put(
        `reviews/${props.modelValue.id}`,
        {
          rating: rating.value,
          comment: comment.value,
          tags: tags.value,
          photos: photos.value
        },
        { headers: authHeaders() }
      )
    }

    if (props.mode === 'reply') {
      await api.post(
        `reviews/${props.modelValue.id}/reply`,
        {
          message: comment.value,
          targetRole: props.targetRole
        },
        { headers: authHeaders() }
      )
    }

    if (props.mode === 'edit-reply') {
      await api.put(
        `reviews/${props.modelValue.id}/reply`,
        {
          message: comment.value,
          targetRole: props.targetRole
        },
        { headers: authHeaders() }
      )
    }

emit('save', {
  rating: rating.value,
  comment: comment.value,
  tags: tags.value,
  photos: photos.value
})
    emit('close')
  } finally {
    sending.value = false
  }
}
</script>
