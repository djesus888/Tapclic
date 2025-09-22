<template>
  <div class="min-h-screen bg-gradient-to-br from-slate-50 to-gray-100 flex flex-col font-sans">
    <header
      :class="[
        'fixed top-0 left-0 right-0 z-50 flex items-center justify-between transition-all duration-300 ease-in-out',
        isExpanded ? 'py-5' : 'py-3',
        'bg-white/90 backdrop-blur-lg shadow-sm border-b border-slate-200/60'
      ]"
    >
      <div class="flex items-center gap-4 px-4">
        <button
          @click="toggleUserPanel"
          class="p-2 rounded-md hover:bg-slate-100 focus:outline-none focus:ring-2 focus:ring-sky-500"
        >
          <span class="text-xl">☰</span>
        </button>
        <h1 class="text-2xl font-bold text-slate-800 tracking-tight">TapClic</h1>
      </div>

      <div class="flex items-center gap-3 px-4">
        <!-- Idioma -->
        <div class="relative" ref="langDropdownRef">
          <button
            @click="toggleLangDropdown"
            class="w-10 h-10 flex items-center justify-center rounded-full border border-slate-200 hover:bg-slate-100"
          >
            <span v-if="locale === 'es'" class="text-xl">🇪🇸</span>
            <span v-else-if="locale === 'en'" class="text-xl">🇺🇸</span>
          </button>
          <transition name="fade">
            <div
              v-if="langDropdownOpen"
              class="absolute right-0 mt-2 w-28 bg-white border border-slate-200 rounded-lg shadow-xl z-50"
            >
              <button
                v-for="(flag, lang) in availableLanguages"
                :key="lang"
                @click="setLocale(lang); langDropdownOpen = false"
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
          class="relative p-2 rounded-full hover:bg-slate-100"
        >
          <span class="text-xl">🔔</span>
          <span
            v-if="notificationStore.unreadCount > 0"
            class="absolute -top-1 -right-1 bg-rose-500 text-white text-xs font-bold rounded-full h-5 w-5 flex items-center justify-center"
          >
            {{ notificationStore.unreadCount }}
          </span>
        </button>

        <!-- Mensajes -->
        <button
          @click="togglePanel('conversations')"
          class="relative p-2 rounded-full hover:bg-slate-100"
        >
          <span class="text-xl">💬</span>
          <span
            v-if="conversationStore.unreadCount > 0"
            class="absolute -top-1 -right-1 bg-rose-500 text-white text-xs font-bold rounded-full h-5 w-5 flex items-center justify-center"
          >
            {{ conversationStore.unreadCount }}
          </span>
        </button>
      </div>
    </header>

    <div :style="{ height: isExpanded ? '88px' : '56px' }" />

    <!-- Panel Notificaciones -->
    <transition name="slide-right">
      <div
        v-if="activePanel === 'notifications'"
        class="fixed top-16 right-0 bottom-0 w-80 bg-white shadow-2xl z-40 flex flex-col"
      >
        <div class="p-4 border-b flex items-center justify-between">
          <h2 class="text-lg font-semibold">{{ $t('notifications') }}</h2>
          <button @click="activePanel = null" class="text-gray-600 text-xl">×</button>
        </div>
        <div class="flex-1 overflow-y-auto divide-y">
          <div
            v-for="notification in notificationStore.notifications"
            :key="notification.id"
            @click="handleNotificationClick(notification)"
            class="p-4 cursor-pointer transition-colors"
            :class="!notification.is_read ? 'bg-sky-50 hover:bg-sky-100' : 'hover:bg-slate-50'"
          >
            <h3 class="font-semibold">{{ notification.title }}</h3>
            <p class="text-sm text-gray-600">{{ notification.message }}</p>
            <p class="text-xs text-gray-400 mt-1">{{ formatDate(notification.created_at) }}</p>
          </div>
        </div>
      </div>
    </transition>

    <!-- Panel Conversaciones -->
    <transition name="slide-right">
      <div
        v-if="activePanel === 'conversations'"
        class="fixed top-16 right-0 bottom-0 w-80 bg-white shadow-2xl z-40 flex flex-col"
      >
        <div class="p-4 border-b flex items-center justify-between">
          <h2 class="text-lg font-semibold">{{ $t('conversations') }}</h2>
          <button @click="activePanel = null" class="text-gray-600 text-xl">×</button>
        </div>
        <div class="flex-1 overflow-y-auto divide-y">
          <template v-if="conversationStore.conversations.length">
            <div
              v-for="conv in conversationStore.conversations"
              :key="conv.id"
              @click="
                conversationStore.goToChat(conv.id, $router);
                activePanel = null;
              "
              class="p-4 cursor-pointer transition-colors"
              :class="conv.unreadCount > 0 ? 'bg-sky-50 hover:bg-sky-100' : 'hover:bg-slate-50'"
            >

               <div class="flex items-center gap-3">
                <img
                  :src="avatarUrl(conv.otherAvatar)"
                  class="w-10 h-10 rounded-full object-cover"
                  :alt="conv.otherName"
                />


              <h3 class="font-semibold">{{ conv.participants.join(', ') }}</h3>
              <p class="text-sm text-gray-600 truncate">
                {{ conv.lastMessage?.text || $t('noMessages') }}
              </p>
              <p class="text-xs text-gray-400 mt-1">
                {{ formatDate(conv.updated_at || conv.created_at) }}
              </p>
            </div>
            </div>
          </template>
          <div v-else class="p-6 text-center text-sm text-gray-500">
            {{ $t('noConversations') }}
          </div>
        </div>
      </div>
    </transition>

    <!-- Sidebar lateral izquierdo -->
    <transition name="slide-left">
      <aside
        v-if="showUserPanel"
        class="fixed top-16 left-0 bottom-0 w-64 bg-white shadow-2xl z-40 flex flex-col"
      >
        <div class="p-4 border-b flex items-center justify-between">
          <h2 class="text-lg font-semibold">{{ $t('menu') }}</h2>
          <button @click="showUserPanel = false" class="text-gray-600 text-xl">×</button>
        </div>
        <nav class="flex-1 p-4 space-y-2 text-sm">
          <!-- Usuario -->
          <template v-if="authStore.user?.role === 'user'">
            <RouterLink to="/" @click="showUserPanel = false" class="block p-2 hover:bg-sky-100 rounded text-left">🏠 {{ $t('home') }}</RouterLink>
            <RouterLink to="/orders" @click="showUserPanel = false" class="block p-2 hover:bg-sky-100 rounded text-left">📦 {{ $t('myOrders') }}</RouterLink>
            <RouterLink to="/chats" @click="showUserPanel = false" class="block p-2 hover:bg-sky-100 rounded text-left">💬 {{ $t('chats') }}</RouterLink>
            <RouterLink to="/profile" @click="showUserPanel = false" class="block p-2 hover:bg-sky-100 rounded text-left">👤 {{ $t('profile') }}</RouterLink>
            <RouterLink to="/reviews" @click="showUserPanel = false" class="block p-2 hover:bg-sky-100 rounded text-left">  {{ $t('reviews') }}</RouterLink>         
            <RouterLink to="/wallet" @click="showUserPanel = false" class="block p-2 hover:bg-sky-100 rounded text-left">💰 {{ $t('wallet') }}</RouterLink>
            <RouterLink to="/config" @click="showUserPanel = false" class="block p-2 hover:bg-sky-100 rounded text-left">⚙️ {{ $t('settings') }}</RouterLink>
            <RouterLink to="/my_requests" @click="showUserPanel = false" class="block p-2 hover:bg-sky-100 rounded text-left">📨 {{ $t('requests') }}</RouterLink>
          </template>

          <!-- Proveedor -->
          <template v-else-if="authStore.user?.role === 'provider'">
            <RouterLink to="/" @click="showUserPanel = false" class="block p-2 hover:bg-sky-100 rounded text-left">📊 {{ $t('dashboard') }}</RouterLink>
            <RouterLink to="/routes" @click="showUserPanel = false" class="block p-2 hover:bg-sky-100 rounded text-left">🛣️ {{ $t('my Routes') }}</RouterLink>
            <RouterLink to="/services" @click="showUserPanel = false" class="block p-2 hover:bg-sky-100 rounded text-left">📦 {{ $t('myServices') }}</RouterLink>
            <RouterLink to="/services/new" @click="showUserPanel = false" class="block p-2 hover:bg-sky-100 rounded text-left">➕ {{ $t('addService') }}</RouterLink>
            <RouterLink to="/payment" @click="showUserPanel = false" class="block p-2 hover:bg-sky-100 rounded text-left">➕ {{ $t('payment_method') }}</RouterLink>
            <RouterLink to="/earnings" @click="showUserPanel = false" class="block p-2 hover:bg-sky-100 rounded text-left">📈 {{ $t('myEarnings') }}</RouterLink>
            <RouterLink to="/chats" @click="showUserPanel = false" class="block p-2 hover:bg-sky-100 rounded text-left">💬 {{ $t('chats') }}</RouterLink>
            <RouterLink to="/profile" @click="showUserPanel = false" class="block p-2 hover:bg-sky-100 rounded text-left">🛡️ {{ $t('profile') }}</RouterLink>
            <RouterLink to="/reviews" @click="showUserPanel = false" class="block p-2 hover:bg-sky-100 rounded text-left">  {{ $t('reviews') }}</RouterLink>          
            <RouterLink to="/wallet" @click="showUserPanel = false" class="block p-2 hover:bg-sky-100 rounded text-left">💰 {{ $t('wallet') }}</RouterLink>
            <RouterLink to="/config" @click="showUserPanel = false" class="block p-2 hover:bg-sky-100 rounded text-left">⚙️ {{ $t('settings') }}</RouterLink>
          </template>

          <!-- Administrador -->
          <template v-else-if="authStore.user?.role === 'admin'">
            <RouterLink to="/dashboard" @click="showUserPanel = false" class="block p-2 hover:bg-sky-100 rounded text-left">🔑 {{ $t('adminDashboard') }}</RouterLink>
            <RouterLink to="/admin/users" @click="showUserPanel = false" class="block p-2 hover:bg-sky-100 rounded text-left">👥 {{ $t('manageUsers') }}</RouterLink>
            <RouterLink to="/provider" @click="showUserPanel = false" class="block p-2 hover:bg-sky-100 rounded text-left">🛡️ {{ $t('manageProviders') }}</RouterLink>
            <RouterLink to="/admin/services" @click="showUserPanel = false" class="block p-2 hover:bg-sky-100 rounded text-left">📦 {{ $t('manageServices') }}</RouterLink>
            <RouterLink to="/admin/reports" @click="showUserPanel = false" class="block p-2 hover:bg-sky-100 rounded text-left">📊 {{ $t('reports') }}</RouterLink>
            <RouterLink to="/chats" @click="showUserPanel = false" class="block p-2 hover:bg-sky-100 rounded text-left">💬 {{ $t('chats') }}</RouterLink>
            <RouterLink to="/profile" @click="showUserPanel = false" class="block p-2 hover:bg-sky-100 rounded text-left">👤 {{ $t('profile') }}</RouterLink>
            <RouterLink to="/wallet" @click="showUserPanel = false" class="block p-2 hover:bg-sky-100 rounded text-left">💰 {{ $t('wallet') }}</RouterLink>
            <RouterLink to="/config" @click="showUserPanel = false" class="block p-2 hover:bg-sky-100 rounded text-left">⚙️ {{ $t('settings') }}</RouterLink>
          </template>

          <hr class="my-4" />
          <button
            @click="logout"
            class="w-full text-left p-2 hover:bg-rose-100 rounded"
          >
            🚪 {{ $t('logout') }}
          </button>
        </nav>
      </aside>
    </transition>

    <main class="flex-1 p-4">
      <RouterView />
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'
import { useAuthStore } from '@/stores/authStore'
import { useNotificationStore } from '@/stores/notificationStore'
import { useConversationStore } from '@/stores/conversationStore'
import { useSocketStore } from '@/stores/socketStore'
import { formatDate } from '@/utils/formatDate'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'

const authStore = useAuthStore()
const notificationStore = useNotificationStore()
const conversationStore = useConversationStore()
const router = useRouter()

const activePanel = ref(null)
const showUserPanel = ref(false)
const langDropdownOpen = ref(false)
const langDropdownRef = ref(null)
const isExpanded = ref(false)
const { locale } = useI18n()
const availableLanguages = { es: '🇪🇸', en: '🇺🇸' }

// Guardar y restaurar idioma
const setLocale = (lang) => {
  locale.value = lang
  localStorage.setItem('userLocale', lang)
}

const toggleLangDropdown = () => (langDropdownOpen.value = !langDropdownOpen.value)
const toggleUserPanel = () => {
  showUserPanel.value = !showUserPanel.value
  activePanel.value = null
}
const togglePanel = (panel) => {
  activePanel.value = activePanel.value === panel ? null : panel
  showUserPanel.value = false
}
const logout = () => {
  showUserPanel.value = false
  authStore.logout()
}

const onScroll = () => (isExpanded.value = window.scrollY < 100)
const handleNotificationClick = (notification) => {
  notificationStore.markAsRead(notification.id)
  activePanel.value = null
  if (notification.link) router.push(notification.link)
}


const avatarUrl = (src) => {
  if (!src) return '/img/default-avatar.png'
  return src.startsWith('/') ? src : `http://localhost:8000/uploads/avatars/${src}`
}



onMounted(async () => {
  // Restaurar idioma guardado
  const savedLocale = localStorage.getItem('userLocale')
  if (savedLocale) {
    locale.value = savedLocale
  }

  // Cerrar dropdown si se hace clic fuera
  document.addEventListener('click', (e) => {
    if (langDropdownRef.value && !langDropdownRef.value.contains(e.target)) {
      langDropdownOpen.value = false
    }
  })
  window.addEventListener('scroll', onScroll)

  if (authStore.user) {
    await notificationStore.fetchNotificationsFromDB()
    await conversationStore.fetchConversations()
    conversationStore.initSocket(authStore.user.id)
    const socketStore = useSocketStore()
    socketStore.init()
  }
})

onBeforeUnmount(() => {
  window.removeEventListener('scroll', onScroll)
  conversationStore.disconnectSocket()
})
</script>

<style scoped>
.slide-right-enter-active,
.slide-right-leave-active {
  transition: transform 0.25s ease, opacity 0.2s;
}
.slide-right-enter-from,
.slide-right-leave-to {
  transform: translateX(100%);
  opacity: 0;
}

.slide-left-enter-active,
.slide-left-leave-active {
  transition: transform 0.25s ease, opacity 0.2s;
}
.slide-left-enter-from,
.slide-left-leave-to {
  transform: translateX(-100%);
  opacity: 0;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
