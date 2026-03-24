import { ref } from 'vue'

// Estado global de notificaciones
const toasts = ref([])
let toastId = 0

export function useToast() {
  const addToast = (message, type = 'info', duration = 5000) => {
    const id = toastId++
    toasts.value.push({
      id,
      message,
      type,
      duration,
      dismissible: true
    })
    
    return id
  }

  const removeToast = (id) => {
    const index = toasts.value.findIndex(t => t.id === id)
    if (index !== -1) {
      toasts.value.splice(index, 1)
    }
  }

  const success = (message, duration) => addToast(message, 'success', duration)
  const error = (message, duration) => addToast(message, 'error', duration)
  const info = (message, duration) => addToast(message, 'info', duration)
  const warning = (message, duration) => addToast(message, 'warning', duration)

  return {
    toasts,
    addToast,
    removeToast,
    success,
    error,
    info,
    warning
  }
}
