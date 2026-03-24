<template>
  <Teleport to="body">
    <div class="soporte-toast-container">
      <SoporteToast
        v-for="toast in toasts"
        :key="toast.id"
        :message="toast.message"
        :type="toast.type"
        :duration="toast.duration"
        :dismissible="toast.dismissible"
        @close="removeToast(toast.id)"
      />
    </div>
  </Teleport>
</template>

<script>
import { useToast } from '../../composables/useToast'
import SoporteToast from './SoporteToast.vue'

export default {
  name: 'SoporteToastContainer',
  components: {
    SoporteToast
  },
  setup() {
    const { toasts, removeToast } = useToast()
    return { toasts, removeToast }
  }
}
</script>

<style scoped>
.soporte-toast-container {
  position: fixed;
  top: 0;
  right: 0;
  z-index: 1100;
  pointer-events: none;
}

.soporte-toast-container :deep(.soporte-toast) {
  pointer-events: auto;
}
</style>
