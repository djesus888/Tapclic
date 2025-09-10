import { createApp } from 'vue'
import App from './App.vue'
import './assets/style.css'
import router from './router'
import { createPinia } from 'pinia'
import { i18n } from './i18n'
import Swal from 'sweetalert2'

// 1️⃣ Pinia
const pinia = createPinia()

// 2️⃣ App y Pinia
const app = createApp(App)
app.use(pinia)

// 3️⃣ Stores
import { useSocketStore } from '@/stores/socketStore'
import { useSystemStore } from '@/stores/systemStore'
import { useNotificationStore } from '@/stores/notificationStore'

// 4️⃣ Propiedades globales
app.config.globalProperties.$swal = Swal

// 5️⃣ Plugins
app.use(router)
app.use(i18n)

// 🔹 6️⃣ Eruda desde CDN (solo en development)
if (import.meta.env.MODE === 'development') {
  const script = document.createElement('script')
  script.src = 'https://cdn.jsdelivr.net/npm/eruda'
  script.onload = () => {
    window.eruda.init()
    console.log('%c🛠️ Eruda cargado y activo', 'color: green; font-weight: bold;')
  }
  document.body.appendChild(script)
}

// 7️⃣ Inicializa stores y monta
const systemStore = useSystemStore()
const socketStore = useSocketStore()
const notificationStore = useNotificationStore()

systemStore.fetchConfig().then(() => {
  socketStore.init()
  app.mount('#app')
})
