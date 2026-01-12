<template>
  <div class="max-w-2xl mx-auto p-4">
    <h1 class="text-2xl font-bold mb-4">
      Mis Conversaciones
    </h1>

    <!-- Sin conversaciones -->
    <div
      v-if="chatStore.conversations.length === 0"
      class="text-center text-gray-500 py-10"
    >
      📭 No tienes conversaciones todavía.
    </div>

    <!-- Lista de conversaciones -->
    <ul
      v-else
      class="space-y-3"
    >
      <li
        v-for="conv in chatStore.conversations"
        :key="conv.id"
        class="flex items-center gap-4 p-3 bg-white rounded-lg shadow cursor-pointer hover:bg-gray-50 transition"
        @click="openChat(conv.id)"
      >
        <!-- Avatar -->
        <img
          :src="avatarUrl(interlocutor(conv).avatar)"
          class="w-12 h-12 rounded-full object-cover"
          :alt="interlocutor(conv).name"
        >

        <!-- Info -->
        <div class="flex-1 min-w-0">
          <p class="font-semibold truncate">
            {{ interlocutor(conv).name }}
          </p>
          <small class="text-gray-500 capitalize">
            {{ interlocutor(conv).role }}
          </small>
          <p class="text-sm text-gray-600 truncate">
            {{ conv.lastMessage?.text || 'Sin mensajes' }}
          </p>
        </div>

        <!-- Meta -->
        <div class="text-right text-sm">
          <p class="text-gray-500">
            {{
              conv.lastMessage?.created_at
                ? formatDistanceToNow(new Date(conv.lastMessage.created_at))
                : ''
            }}
          </p>
          <span
            v-if="conv.unreadCount > 0"
            class="inline-block bg-red-500 text-white rounded-full px-2 py-0.5 text-xs font-bold"
          >
            {{ conv.unreadCount }}
          </span>
        </div>
      </li>
    </ul>
  </div>
</template>

<script setup>
/* ------------------------------------
 * Imports
 * ------------------------------------ */
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useConversationStore } from '@/stores/conversationStore'
import { useAuthStore } from '@/stores/authStore'
import { formatDistanceToNow } from 'date-fns'

/* ------------------------------------
 * Stores & Router
 * ------------------------------------ */
const authStore = useAuthStore()
const chatStore = useConversationStore()
const router = useRouter()

/* ------------------------------------
 * Lifecycle
 * ------------------------------------ */
onMounted(() => {
  chatStore.fetchConversations()
  if (authStore.user?.id) {
    chatStore.initSocket(authStore.user.id)
  }
})

/* ------------------------------------
 * Methods
 * ------------------------------------ */
function openChat(conversationId) {
  chatStore.goToChat(conversationId, router)
}

/* Devuelve el OTRO participante de la conversación */
function interlocutor(conv) {
  return (
    conv.participants.find(p => p.id !== authStore.user?.id) ||
    conv.participants[0]
  )
}

/* Construye la URL del avatar */
function avatarUrl(avatar) {
  if (!avatar) return '/img/default-avatar.png'
  return avatar.startsWith('/')
    ? avatar
    : `http://localhost:8000/uploads/avatars/${avatar}`
}
</script>
