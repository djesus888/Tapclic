import Swal from 'sweetalert2'
import { createApp } from 'vue'
import App from './App.vue'
import './assets/style.css'
import router from './router'
import { createPinia } from 'pinia'
import { i18n } from './i18n'

// Importar store de configuración del sistema
import { useSystemStore } from '@/stores/systemStore'

const app = createApp(App)
app.config.globalProperties.$swal = Swal

app.use(createPinia())
app.use(router)
app.use(i18n)

// ⚡ Cargar configuración del sistema antes de montar
const systemStore = useSystemStore()
systemStore.fetchConfig().then(() => {
  app.mount('#app')
})
