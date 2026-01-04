<!-- src/layouts/MainLayout.vue -->
<template>
  <div class="min-h-screen bg-gradient-to-br from-slate-50 to-gray-100 flex flex-col font-sans">
    <header
      :class="[
        'fixed top-0 left-0 right-0 z-50 flex items-center justify-between transition-all duration-300 ease-in-out',
        isExpanded ? 'py-5' : 'py-3',
        'bg-white/90 backdrop-blur-lg shadow-sm border-b border-slate-200/60',
        isAnyPanelOpen && 'blur-sm'
      ]"
    >
      <div class="flex items-center gap-4 px-4">
        <button
          @click="toggleUserPanel"
          aria-label="Abrir menú"
          :aria-expanded="showUserPanel"
          class="p-2 rounded-md hover:bg-slate-100 focus:outline-none focus:ring-2 focus:ring-sky-500"
        >
          <span aria-hidden="true" class="text-xl">☰</span>
        </button>
        <h1 class="text-2xl font-bold text-slate-800 tracking-tight">TapClic</h1>
      </div>

      <div class="flex items-center gap-3 px-4">
        <!-- Idioma -->
        <div class="relative z-[60]" ref="langDropdownRef">
          <button
            @click="toggleLangDropdown"
            aria-label="Cambiar idioma"
            class="w-10 h-10 flex items-center justify-center rounded-full border border-slate-200 hover:bg-slate-100"
          >
            <span v-if="locale === 'es'" class="text-xl">🇪🇸</span>
            <span v-else-if="locale === 'en'" class="text-xl">🇺🇸</span>
          </button>
          <transition name="fade">
            <div
              v-if="langDropdownOpen"
              class="absolute right-0 mt-2 w-28 bg-white border border-slate-200 rounded-lg shadow-xl z-[60]"
            >
              <button
                v-for="(flag, lang) in availableLanguages"
                :key="lang"
                @click="changeLocale(lang); langDropdownOpen = false"
                class="flex items-center gap-2 px-3 py-2 w-full hover:bg-slate-100 text-left"
              >
                <span class="text-xl">{{ flag }}</span>
              </button>
            </div>
          </transition>
        </div>

        <!-- Notificaciones -->
        <button
          @click="togglePanel('notifications')"
          aria-label="Notificaciones"
          :aria-expanded="activePanel === 'notifications'"
          class="relative p-2 rounded-full hover:bg-slate-100"
        >
          <span class="text-xl">🔔</span>
          <span
            v-if="socketStore.unreadCount"
            class="absolute -top-1 -right-1 bg-rose-500 text-white text-xs font-bold rounded-full h-5 w-5 flex items-center justify-center"
          >
            {{ socketStore.unreadCount }}
          </span>
        </button>

        <!-- Conversaciones -->
        <button
          @click="togglePanel('conversations')"
          aria-label="Conversaciones"
          :aria-expanded="activePanel === 'conversations'"
          class="relative p-2 rounded-full hover:bg-slate-100"
        >
          <span class="text-xl">💬</span>
          <span
            v-if="conversationStore.unreadCount"
            class="absolute -top-1 -right-1 bg-rose-500 text-white text-xs font-bold rounded-full h-5 w-5 flex items-center justify-center"
          >
            {{ conversationStore.unreadCount }}
          </span>
        </button>
      </div>
    </header>

    <!-- Overlay para cerrar paneles al hacer clic fuera -->
    <Teleport to="body">
      <Transition name="fade">
        <div 
          v-if="isAnyPanelOpen" 
          class="fixed inset-0 bg-black/30 backdrop-blur-sm z-30 transition-opacity" 
          @click="closeAllPanels"
        />
      </Transition>
    </Teleport>

    <div :style="{ height: isExpanded ? '88px' : '56px' }" />   

    <!-- ========== PANELES DERECHOS CON LOADING STATE ========== -->
    <transition name="slide-right">
      <div v-if="activePanel === 'notifications'"
        class="fixed top-16 right-0 bottom-0 w-80 bg-white shadow-2xl z-40 flex flex-col"
      >
        <div class="p-4 border-b flex items-center justify-between">
          <h2 class="text-lg font-semibold">{{ $t('notifications') }}</h2>
          <button @click="activePanel = null" class="text-gray-600 text-xl" aria-label="Cerrar">
            ×
          </button>
        </div>
        
        <!-- Skeleton loading -->
        <div v-if="socketStore.loading" class="flex-1 p-4 space-y-3">
          <div v-for="i in 3" :key="i" class="h-20 bg-slate-200 animate-pulse rounded"></div>
        </div>
        
        <div v-else class="flex-1 overflow-y-auto divide-y">
          <div v-for="notification in socketStore.notifications"
            :key="notification.id"
            @click="handleNotificationClick(notification)"
            class="p-4 cursor-pointer transition-colors"
            :class="!notification.is_read ? 'bg-sky-50 hover:bg-sky-100' : 'hover:bg-slate-50'"
          >
            <h3 class="font-semibold">{{ notification.title }}</h3>
            <!-- Mensaje sanitizado para prevenir XSS -->
            <p class="text-sm text-gray-600" v-html="sanitizeMessage(notification.message)"></p>
            <p class="text-xs text-gray-400 mt-1">{{ formatDate(notification.created_at) }}</p>
          </div>
        </div>
      </div>
    </transition>

    <transition name="slide-right">
      <div v-if="activePanel === 'conversations'"
        class="fixed top-16 right-0 bottom-0 w-80 bg-white shadow-2xl z-40 flex flex-col"
      >
        <div class="p-4 border-b flex items-center justify-between">
          <h2 class="text-lg font-semibold">{{ $t('conversations') }}</h2>
          <button @click="activePanel = null" class="text-gray-600 text-xl" aria-label="Cerrar">
            ×
          </button>
        </div>
        
        <div v-if="conversationStore.loading" class="flex-1 p-4 space-y-3">
          <div v-for="i in 3" :key="i" class="h-16 bg-slate-200 animate-pulse rounded"></div>
        </div>
        
        <div v-else class="flex-1 overflow-y-auto divide-y">
          <template v-if="conversationStore.conversations.length">
            <div v-for="conv in conversationStore.conversations"
              :key="conv.id"
              @click="openConversation(conv)"
              class="p-4 cursor-pointer transition-colors"
              :class="conv.unreadCount > 0 ? 'bg-sky-50 hover:bg-sky-100' : 'hover:bg-slate-50'"
            >
              <div class="flex items-center gap-3">
                <img :src="avatarUrl(conv.otherAvatar)"
                  class="w-10 h-10 rounded-full object-cover"
                  :alt="conv.otherName"
                  loading="lazy"
                />
                <div class="flex-1 min-w-0">
                  <h3 class="font-semibold truncate">{{ conv.otherName }}</h3>
                  <p class="text-sm text-gray-600 truncate">
                    {{ conv.lastMessage?.text || $t('noMessages') }}
                  </p>
                  <p class="text-xs text-gray-400 mt-1">
                    {{ formatDate(conv.updated_at || conv.created_at) }}
                  </p>
                </div>
              </div>
            </div>
          </template>
          <div v-else class="p-6 text-center text-sm text-gray-500">
            {{ $t('noConversations') }}
          </div>
        </div>
      </div>
    </transition>

    <!-- ========== SIDEBAR IZQUIERDO ========== -->
    <transition name="slide-left">
      <aside v-if="showUserPanel"
        class="fixed top-16 left-0 bottom-0 w-64 bg-white shadow-2xl z-40 flex flex-col"
        role="complementary"
        aria-label="Menú principal"
      >
        <div class="p-4 border-b flex items-center justify-between">
          <h2 class="text-lg font-semibold">{{ $t('menu') }}</h2>
          <button @click="showUserPanel = false" class="text-gray-600 text-xl" aria-label="Cerrar">
            ×
          </button>
        </div>
        <nav class="flex-1 p-4 space-y-2 text-sm">
          <!-- Usuario -->
          <template v-if="authStore.user?.role === 'user'">
            <RouterLink v-for="item in userMenuItems" :key="item.to"
              :to="item.to"
              @click="showUserPanel = false"
              class="block p-2 hover:bg-sky-100 rounded text-left"
            >
              {{ item.icon }} {{ $t(item.label) }}
            </RouterLink>
          </template>
          <!-- Proveedor -->
          <template v-else-if="authStore.user?.role === 'provider'">
            <RouterLink v-for="item in providerMenuItems" :key="item.to"
              :to="item.to"
              @click="showUserPanel = false"
              class="block p-2 hover:bg-sky-100 rounded text-left"
            >
              {{ item.icon }} {{ $t(item.label) }}
            </RouterLink>
          </template>
          <!-- Administrador -->
          <template v-else-if="authStore.user?.role === 'admin'">
            <RouterLink v-for="item in adminMenuItems" :key="item.to"
              :to="item.to"
              @click="showUserPanel = false"
              class="block p-2 hover:bg-sky-100 rounded text-left"
            >
              {{ item.icon }} {{ $t(item.label) }}
            </RouterLink>
          </template>

          <hr class="my-4" />
          <button @click="logout" class="w-full text-left p-2 hover:bg-rose-100 rounded">
            🚪 {{ $t('logout') }}
          </button>
        </nav>
      </aside>
    </transition>

    <main class="flex-1 p-4 md:p-6 lg:p-8">
      <RouterView />
    </main>

    <!-- MODAL DE NOTIFICACIÓN -->
    <NotificationModal 
      :is-open="!!selectedNotification" 
      :notification="selectedNotification || {}"
      @close="selectedNotification = null"
      @action="handleNotificationAction"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import DOMPurify from 'dompurify'
import { useAuthStore } from '@/stores/authStore'
import { useConversationStore } from '@/stores/conversationStore'
import { useNotificationStore } from '@/stores/notificationStore'
import { useSocketStore } from '@/stores/socketStore'
import { formatDate } from '@/utils/formatDate'
import api from '@/axios'
import NotificationModal from '@/layouts/NotificationModal.vue'

/* ----------  CONFIGURACIÓN  ---------- */
const HEADER_EXPANDED_HEIGHT = 88
const HEADER_COLLAPSED_HEIGHT = 56
const SCROLL_THRESHOLD = 100

/* ----------  STORES  ---------- */
const authStore = useAuthStore()
const notificationStore = useNotificationStore()
const conversationStore = useConversationStore()
const socketStore = useSocketStore()
const router = useRouter()
const { locale, t } = useI18n()

/* ----------  ESTADO LOCAL  ---------- */
const showUserPanel = ref(false)
const activePanel = ref(null)
const langDropdownOpen = ref(false)
const langDropdownRef = ref(null)
const isExpanded = ref(false)
const selectedNotification = ref(null)

// Definición de idiomas disponibles
const availableLanguages = {
  es: '🇪🇸',
  en: '🇺🇸'
}

/* ----------  MENÚS DINÁMICOS  ---------- */
const userMenuItems = [
  { to: '/', label: 'home', icon: '🏠' },
  { to: '/requests', label: 'requests', icon: '📨' },
  { to: '/orders', label: 'myOrders', icon: '📦' },
  { to: '/chats', label: 'chats', icon: '💬' },
  { to: '/profile', label: 'profile', icon: '👤' },
  { to: '/reviews', label: 'reviews', icon: '⭐' },
  { to: '/wallet', label: 'wallet', icon: '💰' },
  { to: '/config', label: 'settings', icon: '⚙️' }
]

const providerMenuItems = [
  { to: '/', label: 'dashboard', icon: '📊' },
  { to: '/routes', label: 'myRoutes', icon: '🛣️' },
  { to: '/services', label: 'myServices', icon: '📦' },
  { to: '/services/new', label: 'addService', icon: '➕' },
  { to: '/payment', label: 'payment_method', icon: '💳' },
  { to: '/earnings', label: 'myEarnings', icon: '📈' },
  { to: '/chats', label: 'chats', icon: '💬' },
  { to: '/profile', label: 'profile', icon: '🛡️' },
  { to: '/reviews', label: 'reviews', icon: '⭐' },
  { to: '/wallet', label: 'wallet', icon: '💰' },
  { to: '/config', label: 'settings', icon: '⚙️' }
]

const adminMenuItems = [
  { to: '/dashboard', label: 'adminDashboard', icon: '🔑' },
  { to: '/admin/users', label: 'manageUsers', icon: '👥' },
  { to: '/provider', label: 'manageProviders', icon: '🛡️' },
  { to: '/admin/services', label: 'manageServices', icon: '📦' },
  { to: '/admin/reports', label: 'reports', icon: '📊' },
  { to: '/chats', label: 'chats', icon: '💬' },
  { to: '/profile', label: 'profile', icon: '👤' },
  { to: '/wallet', label: 'wallet', icon: '💰' },
  { to: '/config', label: 'settings', icon: '⚙️' }
]

/* ----------  COMPUTED  ---------- */
const isAnyPanelOpen = computed(() => activePanel.value || showUserPanel.value)

/* ----------  MÉTODOS  ---------- */
const toggleUserPanel = () => {
  showUserPanel.value = !showUserPanel.value
  activePanel.value = null
}

const togglePanel = (panel) => {
  activePanel.value = activePanel.value === panel ? null : panel
  showUserPanel.value = false
}

const toggleLangDropdown = () => {
  langDropdownOpen.value = !langDropdownOpen.value
}

const changeLocale = (lang) => {
  locale.value = lang
  localStorage.setItem('userLocale', lang)
  langDropdownOpen.value = false
}

const closeAllPanels = () => {
  activePanel.value = null
  showUserPanel.value = false
  langDropdownOpen.value = false
}

// Sanitización de mensajes para prevenir XSS
const sanitizeMessage = (message) => {
  if (!message) return ''
  return DOMPurify.sanitize(message, { ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'span'] })
}

// Redirección inteligente de notificaciones con modal fallback
const handleNotificationClick = async (notification) => {
  try {
    // 1. Marcar como leída inmediatamente en UI
    socketStore.markAsRead(notification.id)
    
    // 2. Validar token
    const token = authStore.token
    if (!token || authStore.isTokenExpired?.()) {
      await authStore.refreshToken?.()
      return router.push('/login')
    }

    // 3. Enviar al backend (no bloqueante)
    api.post('/notifications/read', { id: notification.id }, {
      headers: { Authorization: `Bearer ${token}` }
    }).catch(err => console.error('❌ Error marcando leído:', err))

    // 4. Cerrar panel
    activePanel.value = null

    // 5. Lógica de redirección
    let targetPath = null
    
    if (notification.data_json) {
      try {
        const data = JSON.parse(notification.data_json)
        if (data.link) targetPath = data.link
        
        // Tipos específicos
        if (data.type === 'order' && data.orderId) {
          targetPath = `/orders/${data.orderId}`
        } else if (data.type === 'service' && data.serviceId) {
          targetPath = `/services/${data.serviceId}`
        } else if (data.type === 'chat' && data.chatId) {
          targetPath = `/chats/${data.chatId}`
        }
      } catch (e) {
        console.warn('⚠️ data_json inválido:', e)
      }
    }
    
    if (!targetPath && notification.link) {
      targetPath = notification.link
    }

    // 6. Navegar o mostrar modal
    if (targetPath) {
      router.push(targetPath)
    } else {
      // Mostrar modal si no hay ruta
      selectedNotification.value = notification
    }
  } catch (error) {
    console.error('❌ Error en handleNotificationClick:', error)
  }
}

// Manejar acción del modal
const handleNotificationAction = (notification) => {
  if (notification.action_link) {
    router.push(notification.action_link)
  }
  selectedNotification.value = null
}

const openConversation = (conv) => {
  conversationStore.goToChat(conv.id, router)
  activePanel.value = null
}

const avatarUrl = (src) => {
  if (!src) return '/img/default-avatar.png'
  const baseUrl = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000'
  return src.startsWith('/') ? src : `${baseUrl}/uploads/avatars/${src}`
}

const logout = async () => {
  try {
    await api.post('/auth/logout', {}, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    }).catch(() => {})
  } finally {
    showUserPanel.value = false
    authStore.logout()
    router.push('/login')
  }
}

const onScroll = () => {
  isExpanded.value = window.scrollY < SCROLL_THRESHOLD
}

/* ----------  CICLO DE VIDA  ---------- */
onMounted(async () => {
  window.addEventListener('scroll', onScroll, { passive: true })
  
  document.addEventListener('click', (e) => {
    if (langDropdownRef.value && !langDropdownRef.value.contains(e.target)) {
      langDropdownOpen.value = false
    }
  })
  
  const unlockAudio = () => {
    if (socketStore.notificationSound) {
      socketStore.notificationSound.volume = 0
      socketStore.notificationSound.play()
        .then(() => {
          socketStore.notificationSound.pause()
          socketStore.notificationSound.currentTime = 0
          socketStore.notificationSound.volume = 0.6
          socketStore._soundEnabled = true
        })
        .catch(() => {})
    }
    document.removeEventListener('click', unlockAudio)
    document.removeEventListener('touchstart', unlockAudio)
  }
  document.addEventListener('click', unlockAudio)
  document.addEventListener('touchstart', unlockAudio)
  
  if (authStore.user) {
    try {
      await Promise.all([
        notificationStore.fetchNotificationsFromDB(),
        conversationStore.fetchConversations()
      ])
      
      socketStore.init({
        heartbeat: true,
        heartbeatInterval: 30000
      })

      socketStore.on('new-message', (payload) => {
        conversationStore.prependMessage?.(payload)
      })
      
      socketStore.on('conversation-updated', (payload) => {
        conversationStore.updateConversation?.(payload)
      })

      const debouncedReconnect = () => {
        if (!document.hidden && authStore.user) {
          socketStore.init()
        }
      }
      
      document.addEventListener('visibilitychange', debouncedReconnect)
    } catch (err) {
      console.error('❌ Error al inicializar:', err)
    }
  }
})

onBeforeUnmount(() => {
  window.removeEventListener('scroll', onScroll)
  socketStore.off('new-message')
  socketStore.off('conversation-updated')
  socketStore.disconnect()
})
</script>

<style scoped>
/* Transiciones unificadas */
.slide-right-enter-active,
.slide-right-leave-active,
.slide-left-enter-active,
.slide-left-leave-active {
  transition: transform 0.25s cubic-bezier(0.4, 0, 0.2, 1), opacity 0.2s ease;
}

.slide-right-enter-from,
.slide-right-leave-to {
  transform: translateX(100%);
  opacity: 0;
}

.slide-left-enter-from,
.slide-left-leave-to {
  transform: translateX(-100%);
  opacity: 0;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>

