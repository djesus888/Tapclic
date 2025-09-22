<!-- ChatRoomModal.vue -->
<script setup lang="ts">
import { ref, watch, nextTick, onMounted } from 'vue';
import api from '@/axios';
import { useAuthStore } from '@/stores/authStore';

interface Message {
  id: number;
  text: string;
  type: 'text' | 'image';
  sender: 'user' | 'provider' | 'admin' | 'support';
  created_at: string;
  avatar_url?: string;
  attachment_url?: string;
  read_at?: string;
}

interface Target {
  id: string | number;
  name: string;
  role: 'user' | 'provider' | 'admin' | 'support';
  avatarUrl?: string;
}

const props = defineProps<{ target: Target }>();
const emit = defineEmits<{ (e: 'close'): void }>();

const messages = ref<Message[]>([]);
const newMessage = ref('');
const loading = ref(false);
const scrollRef = ref<HTMLElement | null>(null);
const showMenu = ref(false);
const authStore = useAuthStore();

const selectedFile = ref<File | null>(null);
const previewUrl = ref<string | null>(null);
const uploadingImage = ref(false);

const scrollToBottom = async () => {
  await nextTick();
  if (scrollRef.value) scrollRef.value.scrollTop = scrollRef.value.scrollHeight;
};

const fetchMessages = async () => {
  if (!authStore.token) return;
  try {
    const res = await api.get(
      `/messages/${props.target.id}/${props.target.role}`,
      { headers: { Authorization: `Bearer ${authStore.token}` } }
    );
    const msgs: Message[] = res.data?.messages || [];
    messages.value = msgs.map((m) => ({
      ...m,
      avatar_url:
        m.sender === props.target.role
          ? props.target.avatarUrl
          : authStore.user?.avatar_url || '',
    }));

    const unreadIds = msgs
      .filter(m => m.sender !== authStore.user?.role && !m.read_at)
      .map(m => m.id);

    if (unreadIds.length) {
      api.post(
        '/messages/read',
        { message_ids: unreadIds },
        { headers: { Authorization: `Bearer ${authStore.token}` } }
      ).catch(() => {});
    }

    await scrollToBottom();
  } catch (err) {
    console.error('Error al cargar mensajes:', err);
  }
};

const sendMessage = async () => {
  if ((!newMessage.value.trim() && !previewUrl.value) || !authStore.token) return;

  let attachment_url: string | undefined;

  if (selectedFile.value) {
    uploadingImage.value = true;
    const formData = new FormData();
    formData.append('image', selectedFile.value);

    try {
      const res = await api.post('/upload/image', formData, {
        headers: {
          Authorization: `Bearer ${authStore.token}`,
          'Content-Type': 'multipart/form-data',
        },
      });
      attachment_url = res.data.image_url;
    } catch (err) {
      console.error('Error al subir imagen:', err);
      uploadingImage.value = false;
      return;
    }
    uploadingImage.value = false;
  }

  loading.value = true;
  try {
    const res = await api.post(
      `/messages/send`,
      {
        recipient_id: props.target.id,
        recipient_role: props.target.role,
        text: newMessage.value.trim(),
        attachment_url,
      },
      { headers: { Authorization: `Bearer ${authStore.token}` } }
    );

    const msg: Message = res.data?.message || {
      id: Date.now(),
      text: newMessage.value.trim(),
      type: attachment_url ? 'image' : 'text',
      sender: authStore.user?.role as any,
      created_at: new Date().toISOString(),
      avatar_url: authStore.user?.avatar_url || '',
      attachment_url,
    };

    messages.value.push(msg);
    newMessage.value = '';
    selectedFile.value = null;
    previewUrl.value = null;
    await scrollToBottom();
  } catch (err) {
    console.error('Error al enviar mensaje:', err);
  } finally {
    loading.value = false;
  }
};

const onFileChange = (e: Event) => {
  const file = (e.target as HTMLInputElement).files?.[0];
  if (!file) return;
  selectedFile.value = file;
  const reader = new FileReader();
  reader.onload = (ev) => (previewUrl.value = ev.target?.result as string);
  reader.readAsDataURL(file);
};

const clearMessages = () => { messages.value = []; showMenu.value = false; };

const deleteChat = async () => {
  if (!authStore.token) return;
  try {
    await api.delete(`/messages/${props.target.id}/${props.target.role}`, {
      headers: { Authorization: `Bearer ${authStore.token}` },
    });
    messages.value = [];
    showMenu.value = false;
  } catch (err) {
    console.error('Error al borrar chat:', err);
  }
};

watch(messages, scrollToBottom);
onMounted(fetchMessages);
</script>

<template>
  <div
    class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-30"
    @click.self="$emit('close')"
  >
    <div class="flex flex-col w-full max-w-md h-[80vh] bg-white border rounded-lg shadow-lg">
      <!-- Barra superior -->
      <div class="flex items-center justify-between p-3 border-b bg-gray-100">
        <div class="flex items-center gap-2">
          <img :src="props.target.avatarUrl || '/img/default-avatar.png'" class="w-8 h-8 rounded-full object-cover" />
          <span class="font-semibold text-gray-800">{{ props.target.name }}</span>
        </div>
        <div class="flex items-center gap-2">
          <label for="imageInput" class="cursor-pointer text-gray-600 hover:text-blue-600" title="Adjuntar imagen">📎</label>
          <input id="imageInput" type="file" accept="image/*" class="hidden" @change="onFileChange" />
          <div class="relative">
            <button @click="showMenu = !showMenu" class="p-1 rounded hover:bg-gray-200">⋮</button>
            <div v-if="showMenu" class="absolute right-0 mt-2 w-40 bg-white border rounded shadow-md text-sm z-10">
              <button @click="clearMessages" class="block w-full text-left px-3 py-2 hover:bg-gray-100">Borrar mensajes</button>
              <button @click="deleteChat" class="block w-full text-left px-3 py-2 hover:bg-gray-100">Borrar chat</button>
            </div>
          </div>
          <button @click="$emit('close')" class="text-gray-600 hover:text-red-600 text-xl font-semibold" title="Cerrar chat">✕</button>
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
            :class="[
              'flex items-end gap-2',
              msg.sender === authStore.user?.role ? 'justify-end' : 'justify-start',
            ]"
          >
            <img v-if="msg.sender !== authStore.user?.role"
                 :src="msg.avatar_url || '/img/default-avatar.png'"
                 class="w-8 h-8 rounded-full object-cover" />
            <div
              :class="[
                'max-w-xs md:max-w-md p-3 rounded-lg',
                msg.sender === authStore.user?.role ? 'bg-blue-600 text-white' : 'bg-gray-200 text-gray-900',
              ]"
            >
              <p v-if="msg.text" class="text-sm mb-1">{{ msg.text }}</p>
              <img v-if="msg.type === 'image' && msg.attachment_url"
                   :src="msg.attachment_url"
                   class="rounded max-w-full max-h-48 object-contain" />
              <div class="flex items-center justify-end text-xs text-right mt-1 opacity-70">
                {{ new Date(msg.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) }}
                <span v-if="msg.sender === authStore.user?.role && msg.read_at" class="ml-1">✓✓</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Preview de imagen -->
      <div v-if="previewUrl" class="px-4 py-2 border-t bg-gray-50 relative">
        <button @click="selectedFile = null; previewUrl = null"
                class="absolute top-1 right-1 bg-black bg-opacity-40 text-white rounded-full w-6 h-6 flex items-center justify-center text-xs">✕</button>
        <p class="text-sm text-gray-600 mb-1">Vista previa:</p>
        <img :src="previewUrl" class="rounded max-w-full max-h-32 object-contain" />
      </div>

      <!-- Input -->
      <div class="p-4 border-t flex items-center gap-2">
        <input v-model="newMessage" type="text" placeholder="Escribe tu mensaje..." autocomplete="off"
               class="flex-grow border rounded px-2 py-1" @keyup.enter="sendMessage" />
        <button @click="sendMessage" :disabled="loading || uploadingImage"
                class="px-3 py-1 bg-blue-600 text-white rounded flex items-center">➢</button>
      </div>
    </div>
  </div>
</template>
