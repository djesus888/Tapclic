<template>
  <div class="content-block-wrapper">
    <div v-if="block" class="content-block" :class="`block-type-${block.type}`">
      <!-- Banner -->
      <div v-if="block.type === 'banner'" class="block-banner" v-html="block.content"></div>

      <!-- Texto -->
      <div v-else-if="block.type === 'text'" class="block-text" v-html="block.content"></div>

      <!-- HTML -->
      <div v-else-if="block.type === 'html'" class="block-html" v-html="block.content"></div>

      <!-- Imagen -->
      <img v-else-if="block.type === 'image'" :src="block.content" :alt="block.name" class="block-image" loading="lazy" />
    </div>
    <div v-else-if="!loading" class="content-block-empty">
      <!-- Slot para contenido fallback -->
      <slot name="fallback">
        <!-- Opcional: contenido por defecto si no hay bloque -->
      </slot>
    </div>
    <div v-if="loading" class="content-block-loading">
      <div class="skeleton-pulse"></div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import api from '@/axios'

const props = defineProps({
  identifier: {
    type: String,
    required: true
  },
  autoload: {
    type: Boolean,
    default: true
  }
})

const block = ref(null)
const loading = ref(false)
const error = ref(null)

const loadBlock = async () => {
  if (!props.identifier) {
    console.warn('⚠️ ContentBlock: identifier vacío')
    return
  }

  loading.value = true
  error.value = null

  try {
    const { data } = await api.get(`/content/block/${props.identifier}`)
    if (data.success) {
      block.value = data.block
    } else {
      block.value = null
    }
  } catch (err) {
    if (err.response?.status !== 404) {
      console.warn(`Error cargando bloque "${props.identifier}":`, err.message)
    }
    block.value = null
    error.value = err
  } finally {
    loading.value = false
  }
}

// Recargar si cambia el identifier
watch(() => props.identifier, () => {
  if (props.autoload) loadBlock()
})

onMounted(() => {
  if (props.autoload) loadBlock()
})

// Exponer método para recarga manual
defineExpose({ loadBlock, block, loading, error })
</script>

<style scoped>
.content-block-wrapper {
  width: 100%;
}

.content-block {
  width: 100%;
}

.content-block-loading .skeleton-pulse {
  height: 200px;
  background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
  background-size: 200% 100%;
  animation: skeleton-loading 1.5s infinite;
  border-radius: 8px;
}

@keyframes skeleton-loading {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}

.block-banner :deep(img) {
  max-width: 100%;
  height: auto;
}

.block-text :deep(h1),
.block-text :deep(h2),
.block-text :deep(h3) {
  margin-top: 1em;
  margin-bottom: 0.5em;
}

.block-text :deep(p) {
  margin-bottom: 1em;
  line-height: 1.6;
}

.block-image {
  max-width: 100%;
  height: auto;
  border-radius: 8px;
}
</style>
