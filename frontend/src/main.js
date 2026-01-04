// src/main.js
import { createApp } from 'vue'
import App from './App.vue'
import './assets/style.css'
import router from './router'
import { createPinia } from 'pinia'
import { i18n } from './i18n'
import  api from '@/axios'


// 🔔 Notificaciones
import Toast from 'vue-toastification'
import 'vue-toastification/dist/index.css'

// 💬 SweetAlert2
import VueSweetalert2 from 'vue-sweetalert2'
import 'sweetalert2/dist/sweetalert2.min.css'
import Swal from 'sweetalert2'


// Stores
import { useSocketStore } from '@/stores/socketStore.js'
import { useSystemStore } from '@/stores/systemStore.js'
import { useNotificationStore } from '@/stores/notificationStore.js'
import { initializeAuthStore } from '@/stores/authStore.js'

// funciones de autenticacion
import { checkSession, apiFetch } from './utils/auth.js';

// Inicializar Vue
const app = createApp(App)

// Manejo global de errores
app.config.errorHandler = (err, instance, info) => {
  console.error('>>> ERROR DE VUE:', err.message, '\n', err.stack, '\nInfo:', info)
  app.config.globalProperties.$swal.fire({
    icon: 'error',
    title: 'Error en la aplicación',
    html: `<pre style="text-align:left">${err.message}\n${err.stack || ''}</pre>`,
    width: 600
  })
}

window.addEventListener('error', (e) => {
  console.error('>>> ERROR CAPTURADO:', e.message, '\n', e.error?.stack || e.stack)
  app.config.globalProperties.$swal.fire({
    icon: 'error',
    title: 'Error de JavaScript',
    html: `<pre style="text-align:left">${e.message}\n${e.error?.stack || e.stack}</pre>`,
    width: 600
  })
})

window.addEventListener('unhandledrejection', (e) => {
  console.error('>>> PROMESA RECHAZADA:', e.reason)
  app.config.globalProperties.$swal.fire({
    icon: 'error',
    title: 'Error en Promesa',
    html: `<pre style="text-align:left">${e.reason}</pre>`,
    width: 600
  })
})

// Crear instancia de Pinia
const pinia = createPinia()
app.use(pinia)
app.use(router)
app.use(i18n)
app.use(Toast)
app.use(VueSweetalert2) // ✅ Plugin SweetAlert2 completo

// Eruda (solo desarrollo)
if (import.meta.env.MODE === 'development') {
  const script = document.createElement('script')
  script.src = 'https://cdn.jsdelivr.net/npm/eruda'
  script.onload = () => {
    window.eruda.init()
    console.log('%c🛠️ Eruda cargado y activo', 'color: green; font-weight: bold;')
  }
  document.body.appendChild(script)
}

// Inicializar stores
const authStore = initializeAuthStore()
// 🔒 Verificar token al iniciar la app
await checkSession()
const systemStore = useSystemStore()
const socketStore = useSocketStore()
if (authStore.token && authStore.user) socketStore.connect(authStore.token, authStore.user);
const notificationStore = useNotificationStore()

// Listener global para mostrar notificaciones
window.addEventListener('show-notification-toast', (e) => {
  const { title, message } = e.detail;
  app.config.globalProperties.$swal.fire({
    icon: 'info',
    title,
    text: message,
    toast: true,
    position: 'top-end',
    showConfirmButton: false,
    timer: 4000
  });
});


// ⭐ Listener para abrir modal de calificación
window.addEventListener('open-rating-modal', async (e) => {
  const { request_id, from_id, from_role, message } = e.detail;

  // ✅ CORRECCIÓN CLAVE
  const requestId = request_id;

  // 1. Buscamos el history que tenga ese request_id
  const { data } = await api.get(`/history/by-request/${requestId}`, {
    headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
  });

  const historyId = data?.history_id;

  if (!historyId) {
    Swal.fire(
      'Aún no se puede calificar',
      'El servicio no está listo para reseñas.',
      'info'
    );
    return;
  }

  // 2. Si existe, abrimos el modal con el ID correcto
  const { value: confirmed } = await Swal.fire({
    icon: 'info',
    title: 'Califica el servicio',
    text: message,
    showCancelButton: true,
    confirmButtonText: 'Abrir calificación',
    cancelButtonText: 'Ahora no'
  });

  if (!confirmed) return;

  const div = document.createElement('div');
  document.body.appendChild(div);

  const { default: ReviewComp } = await import('@/components/ReviewModal.vue');
  const { createApp } = await import('vue');

  const appModal = createApp(ReviewComp, {
    modelValue: null,
    mode: 'new',
     targetRole: from_role === 'provider' ? 'user' : 'provider',
    authToken: localStorage.getItem('token'),
    uploadUrl: 'reviews/imag',
    serviceHistoryId: historyId,
    onClose: () => {
      appModal.unmount();
      div.remove();
    },
    onSave: (payload) => {
      console.log('Reseña guardada:', payload);
      appModal.unmount();
      div.remove();
    }
  });

  appModal.mount(div);
});

// 💰 Listener para actualización de pago
window.addEventListener('payment-updated', (e) => {
  const { amount, status, request_id } = e.detail;
  app.config.globalProperties.$swal.fire({
    icon: 'success',
    title: 'Pago actualizado',
    text: `Solicitud ${request_id}: ${status} (${amount})`,
    toast: true,
    position: 'top-end',
    showConfirmButton: false,
    timer: 4000
  });
});


// 💰 Listener para actualización de pago
window.addEventListener('payment-updated', (e) => {
  const { amount, status, request_id } = e.detail;
  app.config.globalProperties.$swal.fire({
    icon: 'success',
    title: 'Pago actualizado',
    text: `Solicitud ${request_id}: ${status} (${amount})`,
    toast: true,
    position: 'top-end',
    showConfirmButton: false,
    timer: 4000
  });
});



// Montar app inmediatamente para evitar doble request
app.mount('#app')

// Escuchar cuando la app pasa a segundo plano o vuelve
document.addEventListener('visibilitychange', () => {
  if (document.hidden) {
    console.log('😴 App en segundo plano → desconectando WS')
    socketStore.disconnect()
  } else {
    console.log('👀 App activa → reconectando WS')

//    if (authStore.token && authStore.user) {
  //    socketStore.connect(authStore.token, authStore.user)
    //}
  }
})

// Inicializar configuración y socket de forma asíncrona
systemStore.fetchConfig()
  .then(() => {
    // Solo inicializa socket si hay token
    if (authStore.token && authStore.user) {
      socketStore.init()
    }
  })
  .catch(error => {
    console.error('Error al cargar la configuración:', error)
    app.config.globalProperties.$swal.fire({
      icon: 'error',
      title: 'Error de Inicialización',
      text: 'No se pudo cargar la configuración inicial.',
      width: 600
    })
  })
