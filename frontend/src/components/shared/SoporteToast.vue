<template>
  <Transition 
    enter-active-class="soporte-toast-enter-active"
    leave-active-class="soporte-toast-leave-active"
    enter-from-class="soporte-toast-enter-from"
    leave-to-class="soporte-toast-leave-to"
  >
    <div 
      v-if="visible" 
      class="soporte-toast" 
      :class="`soporte-toast-${type}`"
      role="alert"
      :aria-live="type === 'error' ? 'assertive' : 'polite'"
    >
      <span class="soporte-toast-icon">{{ icon }}</span>
      <span class="soporte-toast-message">{{ message }}</span>
      <button 
        v-if="dismissible" 
        class="soporte-toast-close" 
        @click="close"
        aria-label="Cerrar notificación"
      >
        ×
      </button>
    </div>
  </Transition>
</template>

<script>
export default {
  name: 'SoporteToast',
  props: {
    message: {
      type: String,
      required: true
    },
    type: {
      type: String,
      default: 'info',
      validator: (value) => ['success', 'error', 'info', 'warning'].includes(value)
    },
    duration: {
      type: Number,
      default: 5000
    },
    dismissible: {
      type: Boolean,
      default: true
    }
  },
  emits: ['close'],
  data() {
    return {
      visible: true,
      timeoutId: null
    }
  },
  computed: {
    icon() {
      const icons = {
        success: '✅',
        error: '❌',
        info: 'ℹ️',
        warning: '⚠️'
      }
      return icons[this.type] || 'ℹ️'
    }
  },
  mounted() {
    if (this.duration > 0) {
      this.timeoutId = setTimeout(() => {
        this.close()
      }, this.duration)
    }
  },
  beforeUnmount() {
    this.clearTimeout()
  },
  methods: {
    close() {
      this.visible = false
      this.clearTimeout()
      setTimeout(() => {
        this.$emit('close')
      }, 300) // Tiempo para la animación de salida
    },
    clearTimeout() {
      if (this.timeoutId) {
        clearTimeout(this.timeoutId)
        this.timeoutId = null
      }
    }
  }
}
</script>

<style scoped>
.soporte-toast {
  position: fixed;
  top: 1.5rem;
  right: 1.5rem;
  min-width: 300px;
  max-width: 450px;
  padding: 1rem 1.25rem;
  background: white;
  border-radius: 0.75rem;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
  display: flex;
  align-items: center;
  gap: 0.75rem;
  z-index: 1100;
  border-left: 4px solid;
  animation: slideIn 0.3s ease;
}

.soporte-toast-success {
  border-left-color: #2ecc71;
}

.soporte-toast-error {
  border-left-color: #e74c3c;
}

.soporte-toast-info {
  border-left-color: #3498db;
}

.soporte-toast-warning {
  border-left-color: #f39c12;
}

.soporte-toast-icon {
  font-size: 1.25rem;
  flex-shrink: 0;
}

.soporte-toast-message {
  flex: 1;
  font-size: 0.95rem;
  color: #2c3e50;
  line-height: 1.4;
  word-break: break-word;
}

.soporte-toast-close {
  background: none;
  border: none;
  font-size: 1.25rem;
  color: #95a5a6;
  cursor: pointer;
  padding: 0.25rem;
  line-height: 1;
  border-radius: 0.25rem;
  transition: all 0.2s;
  flex-shrink: 0;
}

.soporte-toast-close:hover {
  color: #7f8c8d;
  background: #f8f9fa;
}

/* Transiciones */
.soporte-toast-enter-active,
.soporte-toast-leave-active {
  transition: all 0.3s ease;
}

.soporte-toast-enter-from {
  opacity: 0;
  transform: translateX(100%);
}

.soporte-toast-leave-to {
  opacity: 0;
  transform: translateX(100%);
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateX(100%);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

@media (max-width: 768px) {
  .soporte-toast {
    top: auto;
    bottom: 1.5rem;
    right: 1rem;
    left: 1rem;
    min-width: auto;
    max-width: none;
  }
}
</style>
