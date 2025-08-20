<!-- ChatRoomModal.vue -->
<script setup lang="ts">
import { ref, watch, nextTick, onMounted } from 'vue'
import api from '@/axio'
import { useAuthStore } from '@/stores/authStore'

interface Message {
  id: number
  text: string
  sender: 'user' | 'provider'
  created_at: string
  avatar_url?: string
}

interface Provider {
  id: number
  name: string
  avatar_url?: string
}

const FILE_BASE_URL = api.defaults.baseURL?.replace('/api', '') + '/uploads/avatars/'

const props = defineProps<{ providerId: number }>()
const emit = defineEmits<{ (e: 'close'): void }>()

const messages = ref<Message[]>([])
const newMessage = ref('')
const loading = ref(false)
const scrollRef = ref<HTMLElement | null>(null)
const providerProfile = ref<Provider | null>(null)
const showMenu = ref(false)

const authStore = useAuthStore()

// ----------------- Funciones -----------------

// Cargar perfil del proveedor
const fetchProvider = async () => {
  if (!authStore.token) return
  try {
    const res = await api.get(`/provider/${props.providerId}`, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })

    providerProfile.value = {
      id: res.data.provider?.id ?? props.providerId,
      name: res.data.provider?.name ?? 'Proveedor',
      avatar_url: res.data.provider?.avatar_url
  ? FILE_BASE_URL + res.data.provider.avatar_url
  : '' 
   }
  } catch (err) {
    console.error('Error fetching provider profile:', err)
    providerProfile.value = { id: props.providerId, name: 'Proveedor', avatar_url: '' }
  }
}

// Scroll al final
const scrollToBottom = async () => {
  await nextTick()
  if (scrollRef.value) scrollRef.value.scrollTop = scrollRef.value.scrollHeight
}

// Cargar mensajes
const fetchMessages = async () => {
  if (!authStore.token) return
  try {
    const res = await api.get(`/messages/${props.providerId}`, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })

    const messagesData: Message[] = res.data.messages || []

    // Aseguramos avatar del proveedor
    messages.value = messagesData.map(m =>
      m.sender === 'provider'
        ? { ...m, avatar_url: providerProfile.value?.avatar_url ?? '' }
        : m
    )

    await scrollToBottom()
  } catch (err) {
    console.error('Error fetching messages:', err)
  }
}

// Enviar mensaje
const sendMessage = async () => {
  if (!newMessage.value.trim() || !authStore.token) return
  loading.value = true

  try {
    const res = await api.post(
      `/messages`,
      {
        driver_id: props.providerId,
        text: newMessage.value
      },
      {
        headers: { Authorization: `Bearer ${authStore.token}` }
      }
    )

    // Adaptación temporal: si el backend no devuelve message, usamos un objeto local
    const msg: Message = res.data.message ?? {
      id: Date.now(),
      text: newMessage.value,
      sender: 'user',
      created_at: new Date().toISOString(),
      avatar_url: authStore.user?.avatar_url ?? ''
    }

    // Aseguramos avatar del proveedor si viene de provider
    if (msg.sender === 'provider' && providerProfile.value) {
      msg.avatar_url = providerProfile.value.avatar_url ?? ''
    }

    messages.value.push(msg)
    newMessage.value = ''

    await scrollToBottom()
  } catch (err) {
    console.error('Error enviando mensaje:', err)
  } finally {
    loading.value = false
  }
}

// Borrar mensajes solo frontend
const clearMessages = () => {
  messages.value = []
  showMenu.value = false
}

// Borrar chat definitivo (backend + frontend)
const deleteChat = async () => {
  if (!authStore.token) return
  try {
    await api.delete(`/messages/${props.providerId}`, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    messages.value = []
    showMenu.value = false
  } catch (err) {
    console.error('Error borrando chat:', err)
  }
}

// ----------------- Watch & Mounted -----------------
watch(messages, () => scrollToBottom())

onMounted(async () => {
  await fetchProvider()
  await fetchMessages()
})
</script>

<template>
  <div
    v-if="props.providerId"
    class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-30"
    @click.self="emit('close')"
  >
    <div class="flex flex-col w-full max-w-md h-[80vh] bg-white border rounded-lg shadow-lg">

      <!-- Barra superior -->
      <div class="flex items-center justify-between p-3 border-b bg-gray-100">
        <div class="flex items-center gap-2">
          <img
            :src="providerProfile?.avatar_url || 'https://placehold.co/40x40.png'"
            alt="Proveedor"
            class="w-8 h-8 rounded-full object-cover"
          />
          <span class="font-semibold text-gray-800">
            {{ providerProfile?.name || 'Proveedor' }}
          </span>
        </div>
        <div class="relative">
          <button @click="showMenu = !showMenu" class="p-1 rounded hover:bg-gray-200">⋮</button>
          <div
            v-if="showMenu"
            class="absolute right-0 mt-2 w-40 bg-white border rounded shadow-md text-sm z-10"
          >
            <button
              class="block w-full text-left px-3 py-2 hover:bg-gray-100"
              @click="clearMessages"
            >
              Borrar mensajes
            </button>
            <button
              class="block w-full text-left px-3 py-2 hover:bg-gray-100"
              @click="deleteChat"
            >
              Borrar chat
            </button>
          </div>
        </div>
      </div>

      <!-- Zona de mensajes -->
      <div ref="scrollRef" class="flex-grow p-4 overflow-y-auto">
        <div v-if="messages.length === 0" class="flex justify-center items-center h-full">
          <p class="text-gray-400">No hay mensajes aún</p>
        </div>

        <div v-else class="space-y-4">
          <div
            v-for="msg in messages"
            :key="msg.id"
            :class="['flex items-end gap-2', msg.sender === 'user' ? 'justify-end' : 'justify-start']"
          >
            <img
              v-if="msg.sender === 'provider'"
              :src="msg.avatar_url || 'https://placehold.co/40x40.png'"
              alt="Proveedor"
              class="w-10 h-10 rounded-full object-cover"
            />
            <div
              :class="[
                'max-w-xs md:max-w-md p-3 rounded-lg',
                msg.sender === 'user' ? 'bg-blue-600 text-white' : 'bg-gray-200 text-gray-900'
              ]"
            >
              <p class="text-sm">{{ msg.text }}</p>
              <p class="text-xs text-right mt-1 opacity-70">
                {{ new Date(msg.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) }}
              </p>
            </div>
          </div>
        </div>
      </div>

      <!-- Input -->
      <div class="p-4 border-t flex items-center gap-2">
        <input
          v-model="newMessage"
          type="text"
          placeholder="Escribe tu mensaje..."
          autocomplete="off"
          class="flex-grow border rounded px-2 py-1"
        />
        <button
          @click="sendMessage"
          :disabled="loading"
          class="px-3 py-1 bg-blue-600 text-white rounded flex items-center"
        >
          ➢
        </button>
      </div>
    </div>
  </div>
</template>
