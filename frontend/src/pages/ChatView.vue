




<!-- src/pages/ChatView.vue -->
<script setup>
import ChatRoomModal from '@/components/ChatRoomModal.vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const conversationId = Number(route.params.id)
</script>

<template>
  <ChatRoomModal
    :conversation-id="conversationId"
    @close="$router.back()"
  />
</template>


<!-----  <template>
  <ChatRoomModal :conversation-id="Number($route.params.id)" />
</template> --->
