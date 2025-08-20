// src/hooks/use-toast.js
import Swal from 'sweetalert2'

export function useToast() {
  return {
    success(message) {
      Swal.fire({
        icon: 'success',
        title: 'Éxito',
        text: message,
        timer: 2000,
        showConfirmButton: false,
      })
    },
    error(message) {
      Swal.fire({
        icon: 'error',
        title: 'Error',
        text: message,
        timer: 3000,
        showConfirmButton: false,
      })
    },
    info(message) {
      Swal.fire({
        icon: 'info',
        title: 'Info',
        text: message,
        timer: 2500,
        showConfirmButton: false,
      })
    },
  }
}
