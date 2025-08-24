<template>
  <div class="min-h-screen bg-gray-50 flex flex-col">
    <!-- Barra superior -->
    <header
      :class="['bg-white shadow-md flex items-center justify-between transition-all duration-300 ease-in-out fixed w-full z-50', { 'py-6': isExpanded, 'py-3': !isExpanded }]"
      style="top: 0; left: 0; right: 0;"
    >
      <div class="flex items-center gap-4 px-4">
        <!-- Menú hamburguesa -->
        <div class="relative">
          <button @click="showUserPanel = !showUserPanel" class="text-xl">
            ☰
          </button>
        </div>
        <h1 class="text-xl font-bold">TapClic</h1>
      </div>

      <!-- Botón campana notificaciones y selector idioma -->
      <div class="relative flex items-center gap-4 px-4">
        <!-- Selector de idioma -->
        <div class="relative" ref="langDropdownRef">
          <button
            @click="toggleLangDropdown"
            class="w-10 h-10 flex items-center justify-center text-3xl rounded-full border border-gray-300 focus:outline-none"
            aria-label="Selector de idioma"
          >
            <span v-if="locale === 'es'">🇪🇸</span>
            <span v-else-if="locale === 'en'">🇺🇸</span>
          </button>

          <transition name="fade">
            <div
              v-if="langDropdownOpen"
              class="absolute right-0 mt-2 w-28 bg-white border border-gray-300 rounded shadow-md z-50"
            >
              <button
                v-for="(flag, lang) in availableLanguages"
                :key="lang"
                @click="setLocale(lang); langDropdownOpen = false"
                class="flex items-center gap-2 px-3 py-2 w-full hover:bg-gray-100 text-left text-base"
              >
                <span class="text-2xl">{{ flag }}</span>
              </button>
            </div>
          </transition>
        </div>

        <!-- Campana -->
        <button
          @click="showNotifications = !showNotifications"
          aria-label="Notificaciones"
          class="flex items-center gap-1 text-3xl focus:outline-none"
          style="position: relative;"
        >
          <span :class="{ 'animate-bounce': notificationStore.unreadCount > 0 }">🔔</span>
          <span
            v-if="notificationStore.unreadCount > 0"
            style="
              background-color: red;
              color: white;
              font-weight: 700;
              font-size: 12px;
              padding: 2px 6px;
              border-radius: 9999px;
              min-width: 20px;
              text-align: center;
              user-select: none;
              display: inline-block;
              line-height: 1;
              align-self: flex-start;
            "
          >
            {{ notificationStore.unreadCount }}
          </span>
        </button>
      </div>
    </header>

    <!-- Espaciador -->
    <div :style="{ height: isExpanded ? '96px' : '56px' }"></div>

    <!-- Panel de notificaciones -->
    <transition name="slide-right">
      <div
        v-show="showNotifications"
        class="fixed right-0 w-80 bg-white shadow-lg z-50 overflow-y-auto notification-panel"
        :style="{ top: isExpanded ? '96px' : '56px', height: isExpanded ? 'calc(100vh - 96px)' : 'calc(100vh - 56px)' }"
      >
        <div class="p-4 border-b flex justify-between items-center">
          <h2 class="text-lg font-semibold">{{ $t('notifications') }}</h2>
          <button @click="showNotifications = false" class="text-gray-600 text-xl">×</button>
        </div>
        <div class="divide-y">
          <div
            v-for="notification in notificationStore.notifications"
            :key="notification.id"
            @click="handleNotificationClick(notification)"
            class="p-4 hover:bg-gray-100 cursor-pointer"
          >
            <h3 class="font-semibold">{{ notification.title }}</h3>
            <p class="text-sm text-gray-600">{{ notification.message }}</p>
            <span
              v-if="!notification.is_read"
              class="text-xs text-blue-600 font-medium"
            >● {{ $t('notifications.unread') }}</span>
            <p class="text-xs text-gray-400 mt-1">{{ formatDate(notification.created_at) }}</p>
          </div>
        </div>
      </div>
    </transition>

    <!-- Panel usuario -->
    <transition name="slide-left">
      <div
        v-show="showUserPanel"
        class="fixed left-0 w-64 bg-white shadow-md overflow-y-auto"
        :style="{ top: isExpanded ? '96px' : '56px', height: isExpanded ? 'calc(100vh - 96px)' : 'calc(100vh - 56px)' }"
        style="z-index: 9999;"
      >
        <div class="p-4 border-b flex justify-between items-center">
          <h2 class="text-lg font-semibold">{{ $t('menu') }}</h2>
          <button @click="showUserPanel = false" class="text-gray-600 text-xl">×</button>
        </div>
        <div class="p-4 space-y-3 text-left text-base leading-relaxed">
          <div v-if="authStore.user?.role === 'user'">
            <RouterLink to="/" class="block" @click="showUserPanel = false">🏠 {{ $t('home') }}</RouterLink>
            <RouterLink to="/orders" class="block" @click="showUserPanel = false">📦 {{ $t('myOrders') }}</RouterLink>
            <RouterLink to="/profile" class="block" @click="showUserPanel = false">👤 {{ $t('profile') }}</RouterLink>
            <RouterLink to="/wallet" class="block" @click="showUserPanel = false">💰 {{ $t('wallet') }}</RouterLink>
            <RouterLink to="/config" class="block" @click="showUserPanel = false">⚙️ {{ $t('settings') }}</RouterLink>
            <RouterLink to="/my_requests" class="block" @click="showUserPanel = false">📨 {{ $t('requests') }}</RouterLink>
            <button @click="showUserPanel = false; logout()" class="block">🚪 {{ $t('logout') }}</button>
          </div>

          <div v-else-if="authStore.user?.role === 'provider'">
            <RouterLink to="/" class="block" @click="showUserPanel = false">📊 {{ $t('dashboard') }}</RouterLink>
            <RouterLink to="/routes" class="block" @click="showUserPanel = false">🛣️ {{ $t('myRoutes') }}</RouterLink>
            <RouterLink to="/services" class="block" @click="showUserPanel = false">📦 {{ $t('myServices') }}</RouterLink>
            <RouterLink to="/services/new" class="block" @click="showUserPanel = false">➕ {{ $t('addService') }}</RouterLink>
            <RouterLink to="/earnings" class="block" @click="showUserPanel = false">📈 {{ $t('myEarnings') }}</RouterLink>
            <RouterLink to="/profile" class="block" @click="showUserPanel = false">🛡️ {{ $t('profile') }}</RouterLink>
            <RouterLink to="/wallet" class="block" @click="showUserPanel = false">💰 {{ $t('wallet') }}</RouterLink>
            <RouterLink to="/config" class="block" @click="showUserPanel = false">⚙️ {{ $t('settings') }}</RouterLink>
            <button @click="showUserPanel = false; logout()" class="block">🚪 {{ $t('logout') }}</button>
          </div>

          <div v-else-if="authStore.user?.role === 'admin'">
            <RouterLink to="/dashboard" class="block" @click="showUserPanel = false">🔑 {{ $t('adminDashboard') }}</RouterLink>
            <RouterLink to="/users" class="block" @click="showUserPanel = false">👥 {{ $t('manageUsers') }}</RouterLink>
            <RouterLink to="/drivers" class="block" @click="showUserPanel = false">🛡️ {{ $t('manageProviders') }}</RouterLink>
            <RouterLink to="/services" class="block" @click="showUserPanel = false">📦 {{ $t('manageServices') }}</RouterLink>
            <RouterLink to="/reports" class="block" @click="showUserPanel = false">📊 {{ $t('reports') }}</RouterLink>
            <RouterLink to="/profile" class="block" @click="showUserPanel = false">👤 {{ $t('profile') }}</RouterLink>
            <RouterLink to="/wallet" class="block" @click="showUserPanel = false">💰 {{ $t('wallet') }}</RouterLink>
            <RouterLink to="/config" class="block" @click="showUserPanel = false">⚙️ {{ $t('settings') }}</RouterLink>
            <button @click="showUserPanel = false; logout()" class="block">🚪 {{ $t('logout') }}</button>
          </div>
        </div>
      </div>
    </transition>

    <!-- Contenido -->
    <main class="flex-1 p-4">
      <RouterView />
    </main>
  </div>
</template>

<script>
import api from '@/axio'
import { ref, onMounted, onBeforeUnmount } from 'vue'
import { useAuthStore } from '@/stores/authStore'
import { useNotificationStore } from '@/stores/notificationStore'
import { connectSocket } from '@/services/socket'
import { formatDate } from '@/utils/formatDate'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'

export default {
  name: 'MainLayout',
  setup() {
    const authStore = useAuthStore()
    const notificationStore = useNotificationStore()
    const router = useRouter()

    const showNotifications = ref(false)
    const showUserPanel = ref(false)
    const langDropdownOpen = ref(false)
    const langDropdownRef = ref(null)
    const isExpanded = ref(false)
    const { locale } = useI18n()

    const availableLanguages = { es: '🇪🇸', en: '🇺🇸' }

    function setLocale(lang) { locale.value = lang }
    function toggleLangDropdown() { langDropdownOpen.value = !langDropdownOpen.value }
    function handleClickOutside(event) {
      if (langDropdownRef.value && !langDropdownRef.value.contains(event.target)) {
        langDropdownOpen.value = false
      }
    }
    function logout() {
      showUserPanel.value = false
      authStore.logout()
    }
    function onScroll() { isExpanded.value = window.scrollY < 100 }

    function handleNotificationClick(notification) {
      notificationStore.markAsRead(notification.id)
      showNotifications.value = false
      if (notification.link) router.push(notification.link)
    }

    onMounted(async () => {
      document.addEventListener('click', handleClickOutside)
      window.addEventListener('scroll', onScroll)

      if (authStore.user) {
        await notificationStore.fetchNotificationsFromDB()
        const socket = connectSocket(authStore.user.id)
        socket.on('new_notification', (notification) => {
          const audio = new Audio('/sounds/notification.mp3')
          audio.play().catch(() => {})
          notificationStore.handleIncomingNotification(notification)
        })
      }
    })
    onBeforeUnmount(() => {
      document.removeEventListener('click', handleClickOutside)
      window.removeEventListener('scroll', onScroll)
    })

    return {
      authStore,
      notificationStore,
      showNotifications,
      showUserPanel,
      langDropdownOpen,
      langDropdownRef,
      toggleLangDropdown,
      setLocale,
      locale,
      availableLanguages,
      formatDate,
      isExpanded,
      logout,
      handleNotificationClick,
    }
  },
}
</script>

<style>
/* slide-right: entrar desde la derecha y quedarse pegado a la derecha */
.slide-right-enter-active,
.slide-right-leave-active {
  transition: transform 0.28s cubic-bezier(.2,.8,.2,1), opacity 0.18s ease;
  will-change: transform, opacity;
}
.slide-right-enter-from,
.slide-right-leave-to {
  transform: translateX(100%);
  opacity: 0;
}
.slide-right-enter-to,
.slide-right-leave-from {
  transform: translateX(0);
  opacity: 1;
}

/* asegurar anclaje a la derecha y evitar reflows que muevan el panel */
.notification-panel {
  transform-origin: right center;
  right: 0;
  left: auto;
  backface-visibility: hidden;
  -webkit-backface-visibility: hidden;
  contain: paint;
  will-change: transform;
}

.slide-left-enter-active { transition: all 0.3s ease; }
.slide-left-leave-active { transition: all 0.2s ease; }
.slide-left-enter-from,
.slide-left-leave-to { transform: translateX(-100%); opacity: 0; }

.fade-enter-active, .fade-leave-active { transition: opacity 0.2s ease; }
.fade-enter-from, .fade-leave-to { opacity: 0; }

div.p-4.space-y-3.text-left {
  text-align: left;
  font-size: 1.05rem;
  line-height: 1.6;
}
@keyframes bounce { 0%,100%{transform:translateY(0);} 50%{transform:translateY(-6px);} }
.animate-bounce { animation: bounce 1s infinite; }

header { transition: padding 0.3s ease; padding-top: 0.75rem; padding-bottom: 0.75rem; }
header.py-6 { padding-top: 1.5rem; padding-bottom: 1.5rem; }

.main-layout > div[style] { transition: height 0.3s ease; }
</style>
