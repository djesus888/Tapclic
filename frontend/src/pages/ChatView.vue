<template>
  <div class="h-full">
    <ChatRoomModal
      v-if="target"
      :target="target"
      @close="goBack"
    />
    <div
      v-else
      class="flex items-center justify-center h-screen"
    >
      <p class="text-gray-500">
        Cargando conversación...
      </p>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useConversationStore } from '@/stores/conversationStore'
import { useAuthStore } from '@/stores/authStore'
import ChatRoomModal from '@/components/ChatRoomModal.vue'

const route = useRoute()
const router = useRouter()
const chatStore = useConversationStore()
const authStore = useAuthStore()

const target = ref(null)

onMounted(() => {
  const conversationId = Number(route.params.id)

  const conversation = chatStore.conversations.find(c => c.id === conversationId)

  if (!conversation) {
    console.warn('Conversación no encontrada')
    router.replace('/chats') // o donde tengas tu lista de chats
    return
  }

  const other = conversation.participants.find(
    p => p.id !== authStore.user?.id
  ) || conversation.participants[0]

  target.value = {
    id: other.id,
    name: other.name,
    role: other.role,
    avatarUrl: other.avatar,
  }
})

function goBack() {
  router.push('/chats') // o donde tengas tu lista de chats
}
</script>

