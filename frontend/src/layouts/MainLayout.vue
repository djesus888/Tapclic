<!-- src/layouts/MainLayout.vue -->
<template>
  <div class="app-container bg-gradient-to-br from-slate-50 to-blue-50 min-h-screen flex flex-col">
    <!-- ========== HEADER MEJORADO ========== -->
    <header
      :class="[
        'header fixed top-0 left-0 right-0 z-50 transition-all duration-300 ease-in-out backdrop-blur-lg border-b',
        isExpanded ? 'header-expanded' : 'header-collapsed',
        isAnyPanelOpen ? 'header-blurred' : ''
      ]"
      role="banner"
    >
      <div class="header-content">
        <!-- Logo y Menú Hamburguesa -->
        <div class="header-left">
          <button
            aria-label="Abrir menú principal"
            :aria-expanded="showUserPanel"
            class="menu-toggle-btn"
            @click="toggleUserPanel"
          >
            <span class="menu-icon" aria-hidden="true">☰</span>
          </button>

          <div class="logo-container">
            <div class="logo-icon">✨</div>
            <h1 class="logo-text">TapClic</h1>
            <div class="logo-badge">Pro</div>
          </div>
        </div>

        <!-- Acciones del Header -->
        <div class="header-actions">
          <!-- Selector de Idioma -->
          <div
            ref="langDropdownRef"
            class="dropdown-container"
          >
            <button
              aria-label="Cambiar idioma"
              class="lang-toggle-btn"
              @click="toggleLangDropdown"
            >
              <span class="flag-icon">
                {{ locale === 'es' ? '🇪🇸' : '🇺🇸' }}
              </span>
              <span class="lang-text">
                {{ locale === 'es' ? 'ES' : 'EN' }}
              </span>
              <span class="dropdown-arrow">▼</span>
            </button>

            <transition name="dropdown">
              <div
                v-if="langDropdownOpen"
                class="dropdown-menu"
                role="menu"
                aria-label="Seleccionar idioma"
              >
                <button
                  v-for="(flag, lang) in availableLanguages"
                  :key="lang"
                  :class="['dropdown-item', { 'active': locale === lang }]"
                  @click="changeLocale(lang); langDropdownOpen = false"
                  role="menuitem"
                >
                  <span class="item-flag">{{ flag }}</span>
                  <span class="item-text">
                    {{ lang === 'es' ? 'Español' : 'English' }}
                  </span>
                  <span v-if="locale === lang" class="check-icon">✓</span>
                </button>
              </div>
            </transition>
          </div>

          <!-- Notificaciones -->
          <div class="action-btn-container">
            <button
              aria-label="Ver notificaciones"
              :aria-expanded="activePanel === 'notifications'"
              class="action-btn notification-btn"
              @click="togglePanel('notifications')"
            >
              <span class="action-icon">🔔</span>
              <span
                v-if="notificationStore.unreadCount"
                class="badge notification-badge"
              >
                {{ notificationStore.unreadCount > 99 ? '99+' : notificationStore.unreadCount }}
              </span>
            </button>
          </div>

          <!-- Conversaciones -->
          <div class="action-btn-container" v-if="systemStore.chatEnabled">
            <button
              aria-label="Ver conversaciones"
              :aria-expanded="activePanel === 'conversations'"
              class="action-btn chat-btn"
              @click="togglePanel('conversations')"
            >
              <span class="action-icon">💬</span>
              <span
                v-if="conversationStore.unreadCount"
                class="badge chat-badge"
              >
                {{ conversationStore.unreadCount > 99 ? '99+' : conversationStore.unreadCount }}
              </span>
            </button>
          </div>

          <!-- Perfil (si tienes imagen) -->
          <div class="user-avatar">
            <div class="avatar-placeholder">
              {{ authStore.user?.name?.charAt(0)?.toUpperCase() || 'U' }}
            </div>
          </div>
        </div>
      </div>
    </header>

    <!-- Spacer para header fijo -->
    <div :style="{ height: isExpanded ? '88px' : '56px' }" class="header-spacer" />

    <!-- ========== OVERLAY PARA PANELES ========== -->
    <Teleport to="body">
      <Transition name="fade">
        <div
          v-if="isAnyPanelOpen"
          class="panel-overlay"
          @click="closeAllPanels"
          @keydown.esc="closeAllPanels"
          tabindex="0"
        />
      </Transition>
    </Teleport>

    <!-- ========== PANEL DE NOTIFICACIONES MEJORADO ========== -->
    <transition name="slide-panel">
      <div
        v-if="activePanel === 'notifications'"
        class="right-panel"
        role="dialog"
        aria-label="Panel de notificaciones"
      >
        <div class="panel-header">
          <div class="panel-header-content">
            <div class="panel-title">
              <span class="panel-icon">🔔</span>
              <h2>{{ $t('notifications') }}</h2>
              <span v-if="notificationStore.unreadCount" class="panel-count">
                {{ notificationStore.unreadCount }}
              </span>
            </div>
            <button
              class="close-panel-btn"
              aria-label="Cerrar panel de notificaciones"
              @click="activePanel = null"
            >
              ✕
            </button>
          </div>

          <div class="panel-actions">
            <button
              v-if="notificationStore.notifications.length > 0"
              class="panel-action-btn"
              @click="markAllAsRead"
              :disabled="markingAllAsRead"
            >
              <span v-if="markingAllAsRead">⏳</span>
              <span v-else>📭</span>
              {{ markingAllAsRead ? 'Marcando...' : 'Marcar todas como leídas' }}
            </button>
          </div>
        </div>

        <div class="panel-content">
          <!-- Loading State -->
          <div
            v-if="socketStore.loading"
            class="loading-container"
          >
            <div class="skeleton-list">
              <div
                v-for="i in 3"
                :key="i"
                class="notification-skeleton"
              >
                <div class="skeleton-line"></div>
                <div class="skeleton-line short"></div>
                <div class="skeleton-line shorter"></div>
              </div>
            </div>
          </div>

          <!-- Empty State -->
          <div
            v-else-if="notificationStore.notifications.length === 0"
            class="empty-state"
          >
            <div class="empty-icon">🔔</div>
            <h3>No hay notificaciones</h3>
            <p>Todas tus notificaciones aparecerán aquí</p>
          </div>

          <!-- Notifications List -->
          <div
            v-else
            class="notifications-list"
          >
            <div
              v-for="notification in notificationStore.notifications"
              :key="notification.id"
              :class="['notification-item', { unread: !notification.is_read }]"
              @click="handleNotificationClick(notification)"
            >
              <div class="notification-icon">
                <span v-if="!notification.is_read" class="unread-dot"></span>
                <span class="notification-type-icon">
                  {{
                    notification.type === 'order' ? '📦' :
                    notification.type === 'message' ? '💬' :
                    notification.type === 'system' ? '⚙️' :
                    '🔔'
                  }}
                </span>
              </div>

              <div class="notification-content">
                <div class="notification-header">
                  <h4 class="notification-title">{{ notification.title }}</h4>
                  <span class="notification-time">
                    {{ formatDate(notification.created_at) }}
                  </span>
                </div>

                <div
                  class="notification-message"
                  v-html="sanitizeMessage(notification.message)"
                />

                <div v-if="notification.data_json" class="notification-metadata">
                  <span class="metadata-tag">
                    {{ JSON.parse(notification.data_json).type || 'General' }}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </transition>

    <!-- ========== PANEL DE CONVERSACIONES MEJORADO ========== -->
    <transition name="slide-panel">
      <div
        v-if="activePanel === 'conversations' && systemStore.chatEnabled"
        class="right-panel"
        role="dialog"
        aria-label="Panel de conversaciones"
      >
        <div class="panel-header">
          <div class="panel-header-content">
            <div class="panel-title">
              <span class="panel-icon">💬</span>
              <h2>{{ $t('conversations') }}</h2>
              <span v-if="conversationStore.unreadCount" class="panel-count">
                {{ conversationStore.unreadCount }}
              </span>
            </div>
            <button
              class="close-panel-btn"
              aria-label="Cerrar panel de conversaciones"
              @click="activePanel = null"
            >
              ✕
            </button>
          </div>
        </div>

        <div class="panel-content">
          <!-- Loading State -->
          <div
            v-if="conversationStore.loading"
            class="loading-container"
          >
            <div class="skeleton-list">
              <div
                v-for="i in 3"
                :key="i"
                class="conversation-skeleton"
              >
                <div class="skeleton-avatar"></div>
                <div class="skeleton-content">
                  <div class="skeleton-line"></div>
                  <div class="skeleton-line short"></div>
                  <div class="skeleton-line shorter"></div>
                </div>
              </div>
            </div>
          </div>

          <!-- Empty State -->
          <div
            v-else-if="conversationStore.conversations.length === 0"
            class="empty-state"
          >
            <div class="empty-icon">💬</div>
            <h3>No hay conversaciones</h3>
            <p>Cuando recibas un mensaje, aparecerá aquí</p>
          </div>

          <!-- Conversations List -->
          <div
            v-else
            class="conversations-list"
          >
            <div
              v-for="conv in conversationStore.conversations"
              :key="conv.id"
              :class="['conversation-item', { unread: conv.unreadCount > 0 }]"
              @click="openConversation(conv)"
            >
              <div class="conversation-avatar">
                <img
                  :src="avatarUrl(conv.otherAvatar)"
                  :alt="conv.otherName"
                  class="avatar-img"
                  loading="lazy"
                  @error="handleImageError"
                />
                <span v-if="conv.unreadCount > 0" class="unread-indicator">
                  {{ conv.unreadCount > 9 ? '9+' : conv.unreadCount }}
                </span>
              </div>

              <div class="conversation-content">
                <div class="conversation-header">
                  <h4 class="conversation-name">{{ conv.otherName }}</h4>
                  <span class="conversation-time">
                    {{ formatDate(conv.updated_at || conv.created_at) }}
                  </span>
                </div>

                <div class="conversation-preview">
                  <p class="conversation-last-message">
                    {{ conv.lastMessage?.text || $t('noMessages') }}
                  </p>
                  <span v-if="conv.unreadCount > 0" class="unread-dot"></span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </transition>

    <!-- ========== SIDEBAR IZQUIERDO MEJORADO ========== -->
    <transition name="slide-sidebar">
      <aside
        v-if="showUserPanel"
        class="sidebar"
        role="complementary"
        aria-label="Menú de navegación principal"
      >
        <div class="sidebar-header">
          <div class="user-info">
            <div class="sidebar-avatar">
              <div class="sidebar-avatar-img">
                {{ authStore.user?.name?.charAt(0)?.toUpperCase() || 'U' }}
              </div>
              <div class="user-status" :class="authStore.user?.is_online ? 'online' : 'offline'"></div>
            </div>
            <div class="user-details">
              <h3 class="user-name">{{ authStore.user?.name || 'Usuario' }}</h3>
              <p class="user-role">
                {{
                  authStore.user?.role === 'admin' ? 'Administrador' :
                  authStore.user?.role === 'provider' ? 'Proveedor' :
                  'Cliente'
                }}
              </p>
            </div>
          </div>
          <button
            class="close-sidebar-btn"
            aria-label="Cerrar menú"
            @click="showUserPanel = false"
          >
            ✕
          </button>
        </div>

        <div class="sidebar-menu">
          <!-- Menú para Usuario -->
          <template v-if="authStore.user?.role === 'user'">
            <RouterLink
              v-for="item in filteredUserMenu"
              :key="item.to"
              :to="item.to"
              class="menu-item"
              @click="showUserPanel = false"
            >
              <span class="menu-icon">{{ item.icon }}</span>
              <span class="menu-text">{{ $t(item.label) }}</span>
              <span class="menu-arrow">›</span>
            </RouterLink>
          </template>

          <!-- Menú para Proveedor -->
          <template v-else-if="authStore.user?.role === 'provider'">
            <RouterLink
              v-for="item in filteredProviderMenu"
              :key="item.to"
              :to="item.to"
              class="menu-item"
              @click="showUserPanel = false"
            >
              <span class="menu-icon">{{ item.icon }}</span>
              <span class="menu-text">{{ $t(item.label) }}</span>
              <span class="menu-arrow">›</span>
            </RouterLink>
          </template>

          <!-- Menú para Admin -->
          <template v-else-if="authStore.user?.role === 'admin'">
            <RouterLink
              v-for="item in filteredAdminMenu"
              :key="item.to"
              :to="item.to"
              class="menu-item"
              @click="showUserPanel = false"
            >
              <span class="menu-icon">{{ item.icon }}</span>
              <span class="menu-text">{{ $t(item.label) }}</span>
              <span class="menu-arrow">›</span>
            </RouterLink>
          </template>

          <div class="menu-divider"></div>

          <!-- otros link y Cerrar Sesión -->
          <button
            class="menu-item logout-item"
            @click="logout"
          >
            <span class="menu-icon">🚪</span>
            <span class="menu-text">Cerrar Sesión</span>
          </button>
        </div>

        <div class="sidebar-footer">
          <p class="app-version">v1.0.0</p>
          <p class="copyright">© 2024 TapClic. Todos los derechos reservados.</p>
        </div>
      </aside>
    </transition>

    <!-- ========== CONTENIDO PRINCIPAL ========== -->
    <main class="main-content">
      <div class="content-wrapper">
        <RouterView />
      </div>
    </main>

    <!-- ========== MODAL DE NOTIFICACIÓN ========== -->
    <NotificationModal
      :is-open="!!selectedNotification"
      :notification="selectedNotification || {}"
      @close="selectedNotification = null"
      @action="handleNotificationAction"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import DOMPurify from 'dompurify'
import { useAuthStore } from '@/stores/authStore'
import { useConversationStore } from '@/stores/conversationStore'
import { useNotificationStore } from '@/stores/notificationStore'
import { useNotificationCacheStore } from '@/stores/notificationCacheStore'
import { useSocketStore } from '@/stores/socketStore'
import { useSystemStore } from '@/stores/systemStore'
import { formatDate } from '@/utils/formatDate'
import api from '@/axios'
import NotificationModal from '@/layouts/NotificationModal.vue'

const HEADER_EXPANDED_HEIGHT = 88
const HEADER_COLLAPSED_HEIGHT = 56
const SCROLL_THRESHOLD = 100

const authStore = useAuthStore()
const notificationStore = useNotificationStore()
const conversationStore = useConversationStore()
const socketStore = useSocketStore()
const systemStore = useSystemStore()
const router = useRouter()
const { locale, t } = useI18n()
const cache = useNotificationCacheStore()

onMounted(() => {
  notificationStore.initialize()
  systemStore.fetchConfig()
})

const showUserPanel = ref(false)
const activePanel = ref(null)
const langDropdownOpen = ref(false)
const langDropdownRef = ref(null)
const isExpanded = ref(false)
const selectedNotification = ref(null)

const availableLanguages = {
  es: '🇪🇸',
  en: '🇺🇸'
}

const userMenuItems = [
  { to: '/', label: 'home', icon: '🏠' },
  { to: '/requests', label: 'requests', icon: '📨' },
  { to: '/orders', label: 'myOrders', icon: '📦' },
  { to: '/chats', label: 'chats', icon: '💬', feature: 'chat' },
  { to: '/profile', label: 'profile', icon: '👤' },
  { to: '/reviews', label: 'reviews', icon: '⭐', feature: 'reviews' },
  { to: '/wallet', label: 'wallet', icon: '💰', feature: 'wallet' },
  { to: '/config', label: 'settings', icon: '⚙️' }
]

const providerMenuItems = [
  { to: '/', label: 'dashboard', icon: '📊' },
  { to: '/routes', label: 'myRoutes', icon: '🛣️' },
  { to: '/services', label: 'Services', icon: '📦' },
  { to: '/myservices', label: 'myServices', icon: '📦' },
  { to: '/services/new', label: 'addService', icon: '➕' },
  { to: '/payment', label: 'payment_method', icon: '💳' },
  { to: '/earnings', label: 'myEarnings', icon: '📈' },
  { to: '/chats', label: 'chats', icon: '💬', feature: 'chat' },
  { to: '/profile', label: 'profile', icon: '🛡️' },
  { to: '/reviews', label: 'reviews', icon: '⭐', feature: 'reviews' },
  { to: '/wallet', label: 'wallet', icon: '💰', feature: 'wallet' },
  { to: '/config', label: 'settings', icon: '⚙️' }
]

const adminMenuItems = [
  { to: '/dashboard', label: 'adminDashboard', icon: '🔑' },
  { to: '/admin/users', label: 'manageUsers', icon: '👥' },
  { to: '/provider', label: 'manageProviders', icon: '🛡️' },
  { to: '/admin/services', label: 'manageServices', icon: '📦' },
  { to: '/admin/reports', label: 'reports', icon: '📊' },
  { to: '/admin/system', label: 'systemSettings', icon: '⚙️' },
  { to: '/admin/content', label: 'contentManager', icon: '📝' },
  { to: '/admin/payments', label: 'paymentGateways', icon: '💳' },
  { to: '/admin/security', label: 'security', icon: '🔒' },
  { to: '/admin/backups', label: 'backups', icon: '💾' },
  { to: '/admin/logs', label: 'systemLogs', icon: '📋' },
  { to: '/admin/analytics', label: 'analytics', icon: '📈', feature: 'analytics' },
  { to: '/admin/adminwallet', label: 'Admin Wallet', icon: '💰', feature: 'wallet' },
  { to: '/admin/system-config', label: 'serverConfig', icon: '🌐' },
  { to: '/chats', label: 'chats', icon: '💬', feature: 'chat' },
  { to: '/profile', label: 'profile', icon: '👤' },
  { to: '/wallet', label: 'wallet', icon: '💰', feature: 'wallet' },
  { to: '/config', label: 'settings', icon: '🔧' }
]

// ✅ Menús filtrados por features
const filteredUserMenu = computed(() => userMenuItems.filter(item => !item.feature || isFeatureEnabled(item.feature)))
const filteredProviderMenu = computed(() => providerMenuItems.filter(item => !item.feature || isFeatureEnabled(item.feature)))
const filteredAdminMenu = computed(() => adminMenuItems.filter(item => !item.feature || isFeatureEnabled(item.feature)))

function isFeatureEnabled(feature) {
  switch (feature) {
    case 'wallet': return systemStore.walletEnabled
    case 'reviews': return systemStore.reviewsEnabled
    case 'chat': return systemStore.chatEnabled
    case 'tickets': return systemStore.ticketsEnabled
    case 'analytics': return systemStore.analyticsEnabled
    default: return true
  }
}

const isAnyPanelOpen = computed(() => activePanel.value || showUserPanel.value)

const toggleUserPanel = () => {
  showUserPanel.value = !showUserPanel.value
  activePanel.value = null
}

const togglePanel = (panel) => {
  activePanel.value = activePanel.value === panel ? null : panel
  showUserPanel.value = false

  if (panel === 'conversations') {
    conversationStore.conversations.forEach(conv => {
      if (conv.unreadCount > 0) {
        conversationStore.markConversationAsRead(conv.id)
      }
    })
  }
}

const markingAllAsRead = ref(false)

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

const sanitizeMessage = (message) => {
  if (!message) return ''
  return DOMPurify.sanitize(message, { ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'span'] })
}

const markAllAsRead = async () => {
  if (markingAllAsRead.value) return

  try {
    markingAllAsRead.value = true
    const token = authStore.token
    if (!token || authStore.isTokenExpired?.()) {
      await authStore.refreshToken?.()
      markingAllAsRead.value = false
      return router.push('/login')
    }

    const unreadCount = notificationStore.unreadCount
    if (unreadCount === 0) {
      markingAllAsRead.value = false
      return
    }

    await api.post('/notifications/read-all', {}, {
      headers: { Authorization: `Bearer ${token}` }
    })

    notificationStore.markAllAsRead()
    await nextTick()

    try {
      if (socketStore.markAllAsRead) {
        socketStore.markAllAsRead()
      }
    } catch (e) {
      // Ignorar
    }

    console.log('✅ Todas las notificaciones marcadas como leídas')

  } catch (error) {
    console.error('❌ Error al marcar todas como leídas:', error)
  } finally {
    await nextTick()
    markingAllAsRead.value = false
  }
}

const handleNotificationClick = async (notification) => {
  try {
    notificationStore.markAsRead(notification.id)

    try {
      socketStore.markAsRead(notification.id)
    } catch (e) {
      // Ignorar
    }

    activePanel.value = null

    let targetPath = null
    if (notification.data_json) {
      try {
        const data = JSON.parse(notification.data_json)
        if (data.link) targetPath = data.link
        if (data.type === 'order' && data.orderId) targetPath = `/orders/${data.orderId}`
        else if (data.type === 'service' && data.serviceId) targetPath = `/services/${data.serviceId}`
        else if (data.type === 'chat' && data.chatId) targetPath = `/chats/${data.chatId}`
      } catch (e) {
        console.warn('⚠️ data_json inválido:', e)
      }
    }
    if (!targetPath && notification.link) targetPath = notification.link

    if (targetPath) router.push(targetPath)
    else selectedNotification.value = notification

  } catch (error) {
    console.error('❌ Error en handleNotificationClick:', error)
  }
}

const handleNotificationAction = (notification) => {
  if (notification.action_link) router.push(notification.action_link)
  selectedNotification.value = null
}

const openConversation = (conv) => {
  conversationStore.goToChat(conv.id, router)
  activePanel.value = null
}

const avatarUrl = (src) => {
  if (!src) return '/img/default-avatar.png'
  const baseUrl = import.meta.env.VITE_API_BASE_URL
  return src.startsWith('/') ? src : `${baseUrl}/uploads/avatars/${src}`
}

const handleImageError = (event) => {
  event.target.src = '/img/default-avatar.png'
}

const logout = async () => {
  try {
    await api.post('/logout', {}, {
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

let clickOutsideListener = null
let unlockAudio = null
let visibilityChangeListener = null

onMounted(async () => {
  window.addEventListener('scroll', onScroll, { passive: true })

  clickOutsideListener = (e) => {
    if (langDropdownRef.value && !langDropdownRef.value.contains(e.target)) {
      langDropdownOpen.value = false
    }
  }
  document.addEventListener('click', clickOutsideListener)

  unlockAudio = () => {
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
      notificationStore.reset?.()
      await Promise.all([
        notificationStore.loadNotificationsFromAPI(),
        conversationStore.fetchConversations()
      ])

      socketStore.init({ heartbeat: true, heartbeatInterval: 30000 })
      socketStore.on('new-message', (payload) => conversationStore.prependMessage?.(payload))
      socketStore.on('conversation-updated', (payload) => conversationStore.updateConversation?.(payload))

      visibilityChangeListener = () => {
        if (!document.hidden && authStore.user) {
          socketStore.init()
        }
      }
      document.addEventListener('visibilitychange', visibilityChangeListener)
    } catch (err) {
      console.error('❌ Error al inicializar:', err)
    }
  }
})

onBeforeUnmount(() => {
  window.removeEventListener('scroll', onScroll)
  if (clickOutsideListener) document.removeEventListener('click', clickOutsideListener)
  if (unlockAudio) {
    document.removeEventListener('click', unlockAudio)
    document.removeEventListener('touchstart', unlockAudio)
  }
  if (visibilityChangeListener) document.removeEventListener('visibilitychange', visibilityChangeListener)

  socketStore.off('new-message')
  socketStore.off('conversation-updated')
  socketStore.disconnect()
})
</script>


<style scoped>
/* ========== ESTILOS GLOBALES ========== */
.app-container {
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
}

.app-version {
  font-size: 12px;
  color: #94a3b8;
  margin: 0 0 4px 0;
}

@keyframes loading {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}

.action-btn {
  width: 44px;
  height: 44px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: white;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.action-btn:hover {
  transform: translateY(-2px);
  border-color: #667eea;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.1);
}

.action-btn-container {
  position: relative;
}

.action-icon {
  font-size: 20px;
}

.avatar-img {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  object-fit: cover;
  border: 3px solid white;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.avatar-placeholder {
  width: 44px;
  height: 44px;
  border-radius: 50%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: 700;
  font-size: 18px;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
  cursor: pointer;
  transition: transform 0.3s;
}

.avatar-placeholder:hover {
  transform: scale(1.05);
}

.badge {
  position: absolute;
  top: -6px;
  right: -6px;
  min-width: 20px;
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  font-size: 10px;
  font-weight: 800;
  color: white;
  padding: 0 4px;
}

.chat-badge {
  background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%);
  box-shadow: 0 2px 6px rgba(116, 185, 255, 0.4);
}

.check-icon {
  color: #667eea;
  font-weight: bold;
}

.close-panel-btn {
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f1f5f9;
  border: none;
  border-radius: 10px;
  cursor: pointer;
  font-size: 20px;
  color: #64748b;
  transition: all 0.3s;
}

.close-panel-btn:hover {
  background: #e2e8f0;
  color: #334155;
  transform: rotate(90deg);
}

.close-sidebar-btn {
  position: absolute;
  top: 24px;
  right: 24px;
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(255, 255, 255, 0.2);
  border: none;
  border-radius: 10px;
  cursor: pointer;
  font-size: 20px;
  color: white;
  transition: all 0.3s;
}

.close-sidebar-btn:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: rotate(90deg);
}

.content-wrapper {
  max-width: 1400px;
  margin: 0 auto;
  padding: 32px 24px;
}

.conversation-avatar {
  position: relative;
  flex-shrink: 0;
}

.conversation-content {
  flex: 1;
  min-width: 0;
}

.conversation-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 8px;
}

.conversation-item {
  display: flex;
  gap: 16px;
  padding: 20px 24px;
  border-bottom: 1px solid #f1f5f9;
  cursor: pointer;
  transition: all 0.3s;
}

.conversation-item:hover {
  background: #f8fafc;
}

.conversation-item.unread {
  background: linear-gradient(135deg, rgba(116, 185, 255, 0.05) 0%, rgba(9, 132, 227, 0.05) 100%);
}

.conversation-last-message {
  font-size: 14px;
  color: #64748b;
  margin: 0;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  flex: 1;
}

.conversation-name {
  font-weight: 600;
  color: #2d3436;
  margin: 0;
  font-size: 15px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.conversation-preview {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.conversation-skeleton {
  background: white;
  padding: 20px;
  border-radius: 12px;
  border: 1px solid #e2e8f0;
  display: flex;
  gap: 16px;
  align-items: center;
}

.conversation-time {
  font-size: 12px;
  color: #94a3b8;
  white-space: nowrap;
  margin-left: 8px;
}

.conversations-list {
  padding: 0;
}

.copyright {
  font-size: 11px;
  color: #94a3b8;
  margin: 0;
}

.dropdown-arrow {
  font-size: 10px;
  opacity: 0.7;
  transition: transform 0.3s;
}

.dropdown-container {
  position: relative;
}

.dropdown-container:hover .dropdown-arrow {
  transform: rotate(180deg);
}

.dropdown-enter-active,
.dropdown-leave-active {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.dropdown-enter-from,
.dropdown-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}

.dropdown-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 20px;
  width: 100%;
  border: none;
  background: transparent;
  cursor: pointer;
  transition: all 0.2s;
  color: #2d3436;
  font-size: 14px;
}

.dropdown-item:hover {
  background: #f8fafc;
}

.dropdown-item.active {
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);
  color: #667eea;
  font-weight: 600;
}

.dropdown-menu {
  position: absolute;
  top: 100%;
  right: 0;
  margin-top: 8px;
  background: white;
  border-radius: 16px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.15);
  min-width: 180px;
  overflow: hidden;
  z-index: 1000;
  border: 1px solid #e2e8f0;
}

.empty-icon {
  font-size: 64px;
  margin-bottom: 20px;
  opacity: 0.5;
}

.empty-state {
  padding: 60px 24px;
  text-align: center;
}

.empty-state h3 {
  font-size: 20px;
  color: #64748b;
  margin-bottom: 8px;
}

.empty-state p {
  color: #94a3b8;
  font-size: 14px;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

.flag-icon {
  font-size: 20px;
}

.header {
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.95) 0%, rgba(255, 255, 255, 0.98) 100%);
  border-bottom: 1px solid rgba(203, 213, 225, 0.6);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 16px;
}

.header-blurred {
  filter: blur(4px);
}

.header-collapsed {
  padding: 16px 0;
}

.header-content {
  max-width: 1400px;
  margin: 0 auto;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 24px;
}

.header-expanded {
  padding: 24px 0;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 20px;
}

.header-spacer {
  transition: height 0.3s ease;
}

.item-flag {
  font-size: 20px;
  margin-right: 12px;
}

.item-text {
  flex: 1;
  text-align: left;
}

.lang-text {
  font-size: 14px;
  font-weight: 600;
}

.lang-toggle-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 16px;
  background: white;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-weight: 600;
  color: #2d3436;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.lang-toggle-btn:hover {
  border-color: #667eea;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.1);
}

.loading-container {
  padding: 24px;
}

.logo-badge {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
  color: white;
  font-size: 12px;
  font-weight: 700;
  padding: 4px 10px;
  border-radius: 20px;
  margin-left: 8px;
}

.logo-container {
  display: flex;
  align-items: center;
  gap: 12px;
}

.logo-icon {
  font-size: 32px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.logo-text {
  font-size: 28px;
  font-weight: 800;
  background: linear-gradient(135deg, #2c3e50 0%, #4a6572 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  letter-spacing: -0.5px;
}

.logout-item {
  color: #ef4444;
}

.logout-item:hover {
  background: #fee2e2;
  border-left-color: #ef4444;
  color: #dc2626;
}

.main-content {
  flex: 1;
  padding: 0;
}

.menu-arrow {
  font-size: 20px;
  color: #94a3b8;
}

.menu-divider {
  height: 1px;
  background: #e2e8f0;
  margin: 16px 24px;
}

.menu-icon {
  font-size: 20px;
  width: 24px;
  text-align: center;
}

.menu-item {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px 24px;
  text-decoration: none;
  color: #334155;
  transition: all 0.3s;
  border: none;
  background: transparent;
  cursor: pointer;
  width: 100%;
  text-align: left;
  border-left: 4px solid transparent;
}

.menu-item:hover {
  background: #f1f5f9;
  border-left-color: #667eea;
  color: #667eea;
}

.menu-item.router-link-exact-active {
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);
  border-left-color: #667eea;
  color: #667eea;
  font-weight: 600;
}

.menu-text {
  flex: 1;
  font-size: 15px;
  font-weight: 500;
}

.menu-toggle-btn {
  width: 44px;
  height: 44px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.2);
}

.menu-toggle-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(102, 126, 234, 0.3);
}

.metadata-tag {
  font-size: 11px;
  padding: 4px 10px;
  background: #f1f5f9;
  color: #64748b;
  border-radius: 12px;
  font-weight: 600;
}

.notification-badge {
  background: linear-gradient(135deg, #ff7675 0%, #d63031 100%);
  box-shadow: 0 2px 6px rgba(255, 118, 117, 0.4);
}

.notification-content {
  flex: 1;
  min-width: 0;
}

.notification-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 8px;
}

.notification-icon {
  position: relative;
  flex-shrink: 0;
}

.notification-item {
  display: flex;
  gap: 16px;
  padding: 20px 24px;
  border-bottom: 1px solid #f1f5f9;
  cursor: pointer;
  transition: all 0.3s;
  position: relative;
}

.notification-item:hover {
  background: #f8fafc;
}

.notification-item.unread {
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.05) 0%, rgba(118, 75, 162, 0.05) 100%);
}

.notification-message {
  font-size: 14px;
  color: #64748b;
  line-height: 1.5;
  margin-bottom: 12px;
}

.notification-metadata {
  display: flex;
  gap: 8px;
}

.notification-skeleton {
  background: white;
  padding: 20px;
  border-radius: 12px;
  border: 1px solid #e2e8f0;
}

.notification-time {
  font-size: 12px;
  color: #94a3b8;
  white-space: nowrap;
  margin-left: 8px;
}

.notification-title {
  font-weight: 600;
  color: #2d3436;
  margin: 0;
  font-size: 15px;
}

.notification-type-icon {
  font-size: 24px;
  display: block;
  width: 48px;
  height: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: white;
  border-radius: 12px;
  border: 2px solid #e2e8f0;
}

.notifications-list {
  padding: 0;
}

.panel-action-btn {
  padding: 8px 16px;
  background: #f1f5f9;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-size: 13px;
  color: #64748b;
  transition: all 0.3s;
}

.panel-action-btn:hover {
  background: #e2e8f0;
  color: #334155;
}

.panel-actions {
  display: flex;
  gap: 8px;
}

.panel-content {
  flex: 1;
  overflow-y: auto;
  padding: 0;
}

.panel-count {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  font-size: 12px;
  font-weight: 700;
  padding: 2px 8px;
  border-radius: 12px;
}

.panel-header {
  padding: 24px;
  border-bottom: 1px solid #e2e8f0;
  background: linear-gradient(135deg, #f8fafc 0%, #ffffff 100%);
}

.panel-header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.panel-icon {
  font-size: 24px;
}

.panel-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.4);
  backdrop-filter: blur(4px);
  z-index: 40;
}

.panel-title {
  display: flex;
  align-items: center;
  gap: 12px;
}

.panel-title h2 {
  font-size: 20px;
  font-weight: 700;
  color: #2d3436;
  margin: 0;
}

.right-panel {
  position: fixed;
  top: 0;
  right: 0;
  bottom: 0;
  width: 400px;
  max-width: 90vw;
  background: white;
  box-shadow: -10px 0 40px rgba(0, 0, 0, 0.15);
  z-index: 50;
  display: flex;
  flex-direction: column;
}

.settings-item,
.logout-item {
  margin-top: 8px;
}

.sidebar {
  position: fixed;
  top: 0;
  left: 0;
  bottom: 0;
  width: 320px;
  max-width: 85vw;
  background: linear-gradient(180deg, #ffffff 0%, #f8fafc 100%);
  box-shadow: 10px 0 40px rgba(0, 0, 0, 0.15);
  z-index: 50;
  display: flex;
  flex-direction: column;
  border-right: 1px solid #e2e8f0;
}

.sidebar-avatar {
  position: relative;
}

.sidebar-avatar-img {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  background: white;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #667eea;
  font-weight: 700;
  font-size: 24px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.2);
}

.sidebar-footer {
  padding: 20px 24px;
  border-top: 1px solid #e2e8f0;
  text-align: center;
}

.sidebar-header {
  padding: 32px 24px 24px;
  border-bottom: 1px solid #e2e8f0;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  position: relative;
}

.sidebar-menu {
  flex: 1;
  padding: 24px 0;
  overflow-y: auto;
}

.skeleton-avatar {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  background: linear-gradient(90deg, #f1f5f9 25%, #e2e8f0 50%, #f1f5f9 75%);
  background-size: 200% 100%;
  animation: loading 1.5s infinite;
}

.skeleton-content {
  flex: 1;
}

.skeleton-line {
  height: 12px;
  background: linear-gradient(90deg, #f1f5f9 25%, #e2e8f0 50%, #f1f5f9 75%);
  background-size: 200% 100%;
  animation: loading 1.5s infinite;
  border-radius: 6px;
  margin-bottom: 8px;
}

.skeleton-line.short {
  width: 60%;
}

.skeleton-line.shorter {
  width: 40%;
  height: 8px;
}

.skeleton-list {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.slide-panel-enter-active,
.slide-panel-leave-active {
  transition: transform 0.4s cubic-bezier(0.4, 0, 0.2, 1), opacity 0.3s ease;
}

.slide-panel-enter-from,
.slide-panel-leave-to {
  transform: translateX(100%);
  opacity: 0;
}

.slide-sidebar-enter-active,
.slide-sidebar-leave-active {
  transition: transform 0.4s cubic-bezier(0.4, 0, 0.2, 1), opacity 0.3s ease;
}

.slide-sidebar-enter-from,
.slide-sidebar-leave-to {
  transform: translateX(-100%);
  opacity: 0;
}

.unread-dot {
  position: absolute;
  top: -2px;
  right: -2px;
  width: 10px;
  height: 10px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 50%;
  border: 2px solid white;
}

.unread-indicator {
  position: absolute;
  top: -4px;
  right: -4px;
  min-width: 20px;
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%);
  color: white;
  font-size: 10px;
  font-weight: 800;
  border-radius: 50%;
  border: 2px solid white;
}

.user-avatar {
  margin-left: 8px;
}

.user-details {
  flex: 1;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 8px;
}

.user-name {
  font-size: 18px;
  font-weight: 700;
  margin: 0 0 4px 0;
  color: white;
}

.user-role {
  font-size: 13px;
  margin: 0;
  opacity: 0.9;
  color: white;
}

.user-status {
  position: absolute;
  bottom: 2px;
  right: 2px;
  width: 14px;
  height: 14px;
  border-radius: 50%;
  border: 2px solid white;
}

.user-status.online {
  background: #00b894;
}

.user-status.offline {
  background: #dfe6e9;
}

/* ========== RESPONSIVE ========== */
@media (max-width: 1024px) {
  .header-content {
    padding: 0 20px;
  }

  .right-panel {
    width: 350px;
  }

  .sidebar {
    width: 280px;
  }
}

@media (max-width: 768px) {
  .header-content {
    padding: 0 16px;
  }

  .logo-text {
    font-size: 24px;
  }

  .lang-toggle-btn .lang-text {
    display: none;
  }

  .right-panel {
    width: 100vw;
  }

  .sidebar {
    width: 100vw;
  }

  .content-wrapper {
    padding: 24px 16px;
  }
}

@media (max-width: 480px) {
  .header-left {
    gap: 12px;
  }

  .logo-container {
    gap: 8px;
  }

  .logo-text {
    font-size: 20px;
  }

  .logo-badge {
    font-size: 10px;
    padding: 3px 8px;
  }

  .menu-toggle-btn,
  .action-btn {
    width: 40px;
    height: 40px;
  }

  .avatar-placeholder {
    width: 40px;
    height: 40px;
    font-size: 16px;
  }
}
</style>
