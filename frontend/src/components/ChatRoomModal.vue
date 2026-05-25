<template>
  <div
    class="chat-modal-overlay"
    @click.self="$emit('close')"
  >
    <div class="chat-modal-container">
      <!-- Header del chat -->
      <div class="chat-modal-header">
        <div class="header-left">
          <div class="user-avatar">
            <img
              :src="target.avatarUrl || 'https://via.placeholder.com/40?text=U'"
              :alt="target.name"
              class="avatar-image"
              @error="handleImageError"
            >
            <span
              class="avatar-online-dot"
              :class="{ 'online': isTargetOnline }"
              :title="isTargetOnline ? 'En línea' : 'Desconectado'"
            />
          </div>
          <div class="user-info">
            <div class="user-name-wrapper">
              <h3 class="user-name">
                {{ target.name }}
              </h3>
              <span
                v-if="isTargetOnline"
                class="online-badge"
              >EN LÍNEA</span>
            </div>
            <p class="user-role">
              {{ formatRole(target.role) }}
            </p>
          </div>
        </div>

        <div class="header-right">
          <!-- Botón adjuntar imagen -->
          <div class="file-input-wrapper">
            <label
              for="imageInput"
              class="attach-btn"
              title="Adjuntar imagen"
            >
              📎
            </label>
            <input
              id="imageInput"
              type="file"
              accept="image/*"
              class="file-input"
              @change="onFileChange"
            >
          </div>

          <!-- Menú desplegable -->
          <div class="dropdown-wrapper">
            <button
              class="menu-btn"
              :class="{ 'active': showMenu }"
              @click="showMenu = !showMenu"
            >
              ⋮
            </button>
            <div
              v-if="showMenu"
              class="dropdown-menu"
            >
              <button
                class="dropdown-item"
                @click="confirmClearMessagesForMe"
              >
                <span class="item-icon">🗑️</span>
                <span class="item-text">Borrar mis mensajes</span>
              </button>
              <button
                v-if="authStore.user?.role === 'admin'"
                class="dropdown-item"
                @click="confirmHardDeleteMessages"
              >
                <span class="item-icon">⚠️</span>
                <span class="item-text">Borrar permanentemente (admin)</span>
              </button>
              <div class="dropdown-divider" />
              <button
                class="dropdown-item"
                @click="confirmDeleteChatForMe"
              >
                <span class="item-icon">🔥</span>
                <span class="item-text">Borrar chat para mí</span>
              </button>
              <button
                v-if="authStore.user?.role === 'admin'"
                class="dropdown-item"
                @click="confirmHardDeleteChat"
              >
                <span class="item-icon">💀</span>
                <span class="item-text">Eliminar permanentemente (admin)</span>
              </button>
              <div class="dropdown-divider" />
              <button
                class="dropdown-item"
                @click="exportChatHistory"
              >
                <span class="item-icon">📥</span>
                <span class="item-text">Exportar historial</span>
              </button>
            </div>
          </div>

          <!-- Botón cerrar -->
          <button
            class="close-btn"
            title="Cerrar chat"
            @click="$emit('close')"
          >
            ✕
          </button>
        </div>
      </div>

      <!-- Área de mensajes -->
      <div
        ref="scrollRef"
        class="messages-area"
        :class="{ 'empty': messages.length === 0 }"
      >
        <!-- Estado vacío -->
        <div
          v-if="messages.length === 0"
          class="empty-messages"
        >
          <div class="empty-icon">
            💬
          </div>
          <h3 class="empty-title">
            No hay mensajes aún
          </h3>
          <p class="empty-subtitle">
            Envía el primer mensaje para comenzar la conversación
          </p>
          <div class="chat-tips">
            <p class="tip">
              💡 Puedes adjuntar imágenes usando el botón 📎
            </p>
            <p class="tip">
              💡 Presiona Enter para enviar mensajes rápidamente
            </p>
          </div>
        </div>

        <!-- Lista de mensajes -->
        <div
          v-else
          class="messages-list"
        >
          <div
            v-for="msg in messages"
            :key="msg.id"
            class="message-wrapper"
            :class="{
              'sent': msg.sender === authStore.user?.role,
              'received': msg.sender !== authStore.user?.role
            }"
          >
            <!-- Avatar del remitente (solo para mensajes recibidos) -->
            <div
              v-if="msg.sender !== authStore.user?.role"
              class="message-avatar"
            >
              <img
                :src="msg.avatar_url || target.avatarUrl || 'https://via.placeholder.com/32?text=U'"
                :alt="msg.sender"
                class="avatar-small"
                @error="handleImageError"
              >
            </div>

            <!-- Contenedor del mensaje -->
            <div class="message-container">
              <button
                v-if="msg.sender === authStore.user?.role"
                class="message-delete-btn"
                title="Borrar para mí"
                @click="deleteMessageForMe(msg.id)"
              >
                ✕
              </button>

              <div
                v-if="msg.text"
                class="message-text"
              >
                {{ msg.text }}
              </div>

              <div
                v-if="msg.type === 'image' && msg.attachment_url"
                class="message-image"
              >
                <img
                  :src="msg.attachment_url"
                  :alt="msg.text || 'Imagen adjunta'"
                  class="image-preview"
                  @load="scrollToBottom"
                  @error="handleImageError"
                  @click="openImage(msg.attachment_url)"
                >
              </div>

              <div class="message-info">
                <span class="message-time">
                  {{ formatMessageTime(msg.created_at) }}
                </span>
                <span
                  v-if="msg.sender === authStore.user?.role"
                  class="message-status"
                >
                  <span
                    v-if="!msg.is_delivered && !msg.is_read"
                    class="status-sent"
                    title="Enviado"
                  >✓</span>
                  <span
                    v-else-if="msg.is_delivered && !msg.is_read"
                    class="status-delivered"
                    title="Entregado"
                  >✓✓</span>
                  <span
                    v-else-if="msg.is_read"
                    class="status-read"
                    title="Leído"
                  >✓✓</span>
                </span>
              </div>
            </div>
          </div>

          <!-- Indicador de typing -->
          <div
            v-if="isTyping"
            class="typing-indicator-wrapper"
          >
            <div class="typing-indicator">
              <span />
              <span />
              <span />
            </div>
            <span class="typing-text">{{ typingText }}</span>
          </div>
        </div>
      </div>

      <!-- Vista previa de imagen -->
      <div
        v-if="previewUrl"
        class="image-preview-container"
      >
        <div class="preview-header">
          <span class="preview-label">Vista previa</span>
          <button
            class="preview-close"
            @click="selectedFile = null; previewUrl = null"
          >
            ✕
          </button>
        </div>
        <img
          :src="previewUrl"
          alt="Vista previa"
          class="preview-image"
        >
      </div>

      <!-- Área de entrada de mensaje -->
      <div class="input-area">
        <div class="input-wrapper">
          <input
            v-model="newMessage"
            type="text"
            placeholder="Escribe tu mensaje aquí..."
            autocomplete="off"
            class="message-input"
            :disabled="loading || uploadingImage"
            @keyup.enter="sendMessage"
            @keydown="handleTyping"
            @blur="stopTyping"
          >
          <button
            :disabled="loading || uploadingImage || (!newMessage.trim() && !selectedFile)"
            class="send-btn"
            :class="{
              'loading': loading,
              'disabled': (!newMessage.trim() && !selectedFile)
            }"
            @click="sendMessage"
          >
            <span
              v-if="loading"
              class="spinner-small"
            />
            <span v-else>➢</span>
          </button>
        </div>

        <div class="input-hints">
          <span class="hint">Presiona Enter para enviar</span>
          <span
            v-if="uploadingImage"
            class="hint"
          >Subiendo imagen...</span>
          <span
            v-else-if="isTargetOnline"
            class="hint online-hint"
          >● En línea</span>
        </div>
      </div>
    </div>
  </div>

  <!-- Modal para ver imagen en grande -->
  <Teleport to="body">
    <div
      v-if="showImageModal"
      class="image-modal-overlay"
      @click="closeImageModal"
    >
      <div
        class="image-modal-container"
        @click.stop
      >
        <button
          class="image-modal-close"
          @click="closeImageModal"
        >
          ✕
        </button>
        <img
          :src="selectedImage"
          alt="Imagen ampliada"
          class="image-modal-img"
        >
      </div>
    </div>
  </Teleport>
</template>

<script setup>
/* global confirm, clearTimeout, FileReader, FormData, Blob, URL */
import { ref, watch, nextTick, onMounted, onUnmounted, computed } from 'vue';
import api from '@/axios';
import { useAuthStore } from '@/stores/authStore';
import { useSocketStore } from '@/stores/socketStore';
import { useOnlineUsersStore } from '@/stores/onlineUsersStore';
import { useConversationStore } from '@/stores/conversationStore';

// Definición de props sin TypeScript
const props = defineProps({
  target: {
    type: Object,
    required: true,
    validator: (value) => {
      return value && value.id && value.name && value.role;
    }
  },
  conversationId: {
    type: Number,
    default: null
  }
});

const emit = defineEmits(['close', 'typing', 'message-sent']);

const authStore = useAuthStore();
const socketStore = useSocketStore();
const onlineUsersStore = useOnlineUsersStore();
const conversationStore = useConversationStore();

// Estado
const conversationId = ref(props.conversationId || null);
const loadingConversation = ref(false);
const messages = ref([]);
const newMessage = ref('');
const loading = ref(false);
const scrollRef = ref(null);
const showMenu = ref(false);
const selectedFile = ref(null);
const previewUrl = ref(null);
const uploadingImage = ref(false);
const isTyping = ref(false);
const typingTimeout = ref(null);
const typingStopTimeout = ref(null);
const selectedImage = ref(null);
const showImageModal = ref(false);
const pendingMessages = ref(new Map());
const reconnectAttempts = ref(0);
const hasMarkedAsDelivered = ref(false); // ✅ Para evitar múltiples llamadas

// Computed properties
const isSocketReady = computed(() => {
  return socketStore.socket?.connected === true && socketStore.socket?.id;
});

const isTargetOnline = computed(() => {
  return onlineUsersStore.isUserOnline(Number(props.target.id));
});

const typingText = computed(() => {
  if (!isTyping.value) return '';
  return `${props.target.name} está escribiendo...`;
});

// Métodos
const formatRole = (role) => {
  const roles = {
    provider: 'Proveedor',
    client: 'Cliente',
    user: 'Usuario',
    admin: 'Administrador'
  };
  return roles[role?.toLowerCase()] || role;
};

const formatMessageTime = (timestamp) => {
  return new Date(timestamp).toLocaleTimeString([], {
    hour: '2-digit',
    minute: '2-digit'
  });
};

const openImage = (url) => {
  selectedImage.value = url;
  showImageModal.value = true;
};

const closeImageModal = () => {
  showImageModal.value = false;
  selectedImage.value = null;
};

const handleImageError = (event) => {
  const img = event.target;
  img.src = 'https://via.placeholder.com/300x200?text=Imagen+No+Cargada';
  img.classList.add('error-image');
};

const scrollToBottom = async () => {
  await nextTick();
  if (scrollRef.value) {
    scrollRef.value.scrollTop = scrollRef.value.scrollHeight;
  }
};

const showNotification = (message, type = 'info') => {
  console.log(`[${type.toUpperCase()}] ${message}`);
  if (type === 'error') {
    console.error(message);
  }
};

// ✅ NUEVO: Marcar mensajes como entregados
const markMessagesAsDelivered = async () => {
  if (!conversationId.value || hasMarkedAsDelivered.value) return;
  
  try {
    console.log('📬 Marcando mensajes como entregados para conversación:', conversationId.value);
    const response = await api.post(
      `/messages/conversation/${conversationId.value}/delivered`,
      {},
      { headers: { Authorization: `Bearer ${authStore.token}` } }
    );
    
    if (response.data?.count > 0) {
      console.log(`✅ ${response.data.count} mensajes marcados como entregados`);
    }
    
    hasMarkedAsDelivered.value = true;
  } catch (err) {
    console.error('❌ Error marcando mensajes como entregados:', err);
    // No mostrar error al usuario, no es crítico
  }
};

const ensureConversation = async () => {
  if (conversationId.value) return true;

  loadingConversation.value = true;

  try {
    console.log('🔍 Buscando conversación con:', props.target.id, props.target.role);

    // Buscar en store primero
    const existingConversation = conversationStore.conversations.find(c => {
      const participants = c.participants || [];
      return participants.some(p => p.id === props.target.id);
    });

    if (existingConversation) {
      console.log('✅ Conversación encontrada en store:', existingConversation.id);
      conversationId.value = existingConversation.id;
      return true;
    }

    // Buscar en servidor
    try {
      const res = await api.get(
        `/conversations/find/${props.target.id}/${props.target.role}`,
        { headers: { Authorization: `Bearer ${authStore.token}` } }
      );

      if (res.data?.id) {
        console.log('✅ Conversación encontrada en servidor:', res.data.id);
        conversationId.value = res.data.id;
        return true;
      }
    } catch (_err) {
      console.log('⚠️ No se encontró conversación existente');
    }

    // Crear nueva conversación
    console.log('🆕 Creando nueva conversación...');
    const createRes = await api.post(
      '/conversations/create',
      {
        participant_id: props.target.id,
        participant_role: props.target.role
      },
      { headers: { Authorization: `Bearer ${authStore.token}` } }
    );

    if (createRes.data?.id) {
      console.log('✅ Nueva conversación creada:', createRes.data.id);
      conversationId.value = createRes.data.id;
      return true;
    }

    throw new Error('No se pudo obtener/crear la conversación');
  } catch (error) {
    console.error('❌ Error al obtener conversación:', error);
    showNotification('Error al iniciar la conversación', 'error');
    return false;
  } finally {
    loadingConversation.value = false;
  }
};

const fetchMessages = async () => {
  if (!authStore.token || !conversationId.value) return;

  try {
    const res = await api.get(
      `/messages/${conversationId.value}`,
      { headers: { Authorization: `Bearer ${authStore.token}` } }
    );

    const msgs = res.data?.messages || [];
    messages.value = msgs.map((m) => ({
      ...m,
      avatar_url: m.sender === props.target.role
        ? props.target.avatarUrl
        : authStore.user?.avatar_url || '',
      is_read: Boolean(m.is_read),
      is_delivered: Boolean(m.is_delivered)
    }));

    // ✅ Marcar como entregados después de cargar mensajes
    await markMessagesAsDelivered();

    // Marcar mensajes no leídos como leídos
    const unreadIds = msgs
      .filter(m => m.sender !== authStore.user?.role && !m.is_read)
      .map(m => m.id);

    if (unreadIds.length) {
      await api.post(
        '/messages/read',
        { message_ids: unreadIds },
        { headers: { Authorization: `Bearer ${authStore.token}` } }
      );

      messages.value = messages.value.map(msg =>
        unreadIds.includes(msg.id) ? { ...msg, is_read: true } : msg
      );

      // Notificar por WebSocket
      if (isSocketReady.value) {
        socketStore.emit('messages_read', {
          conversation_id: conversationId.value,
          message_ids: unreadIds
        });
      }
    }

    await scrollToBottom();
  } catch (err) {
    console.error('Error al cargar mensajes:', err);
    showNotification('Error al cargar los mensajes', 'error');
  }
};

const sendMessage = async () => {
  if ((!newMessage.value.trim() && !selectedFile.value) || !authStore.token) return;

  if (!conversationId.value) {
    const hasConversation = await ensureConversation();
    if (!hasConversation) return;
  }

  stopTyping();

  let attachment_url;

  if (selectedFile.value) {
    uploadingImage.value = true;
    const formData = new FormData();
    formData.append('image', selectedFile.value);

    try {
      const res = await api.post('/upload/image', formData, {
        headers: {
          Authorization: `Bearer ${authStore.token}`,
          'Content-Type': 'multipart/form-data'
        }
      });
      attachment_url = res.data.image_url;
    } catch (err) {
      console.error('Error al subir imagen:', err);
      uploadingImage.value = false;
      showNotification('Error al subir la imagen', 'error');
      return;
    }
    uploadingImage.value = false;
  }

  const tempId = Date.now();
  const messageText = newMessage.value.trim() || (attachment_url ? '📷 Imagen' : '');

  const tempMessage = {
    id: tempId,
    temp_id: tempId,
    text: messageText,
    type: attachment_url ? 'image' : 'text',
    sender: authStore.user?.role,
    created_at: new Date().toISOString(),
    avatar_url: authStore.user?.avatar_url || '',
    attachment_url,
    is_read: false,
    is_delivered: false,
    _temp: true // ✅ Flag para identificar mensajes temporales
  };

  messages.value.push(tempMessage);
  pendingMessages.value.set(tempId, tempMessage);
  await scrollToBottom();

  loading.value = true;

  try {
    // Enviar por HTTP primero
    const messageData = {
      conversation_id: conversationId.value,
      recipient_id: props.target.id,
      recipient_role: props.target.role,
      text: messageText,
      temp_id: tempId // ✅ Enviar temp_id al backend
    };

    if (attachment_url) {
      messageData.attachment_url = attachment_url;
    }

    const response = await api.post(
      '/messages/send',
      messageData,
      { headers: { Authorization: `Bearer ${authStore.token}` } }
    );

    const sentMessage = response.data?.message || response.data;

    // Actualizar mensaje temporal con ID real
    const index = messages.value.findIndex(m => m.id === tempId);
    if (index !== -1) {
      messages.value[index] = {
        ...messages.value[index],
        ...sentMessage,
        id: sentMessage.id || Date.now(),
        temp_id: undefined,
        _temp: false,
        is_delivered: false
      };
    }

    pendingMessages.value.delete(tempId);

    // Enviar por WebSocket también para actualización en tiempo real
    if (isSocketReady.value) {
      socketStore.emit('send_message', {
        conversation_id: conversationId.value,
        message: messages.value[index],
        recipient_id: props.target.id,
        recipient_role: props.target.role,
        temp_id: tempId
      });
    }

    newMessage.value = '';
    selectedFile.value = null;
    previewUrl.value = null;

    emit('message-sent', messages.value[index]);

  } catch (err) {
    console.error('Error al enviar mensaje:', err);
    showNotification('Error al enviar el mensaje', 'error');

    // Eliminar mensaje temporal si falló
    messages.value = messages.value.filter(m => m.id !== tempId);
    pendingMessages.value.delete(tempId);
  } finally {
    loading.value = false;
  }
};

const onFileChange = (e) => {
  const file = e.target.files?.[0];
  if (!file) return;

  selectedFile.value = file;
  const reader = new FileReader();
  reader.onload = (ev) => (previewUrl.value = ev.target?.result);
  reader.readAsDataURL(file);
};

const handleTyping = () => {
  if (!isSocketReady.value) {
    console.warn('⚠️ Socket no conectado, reintentando en 1s...');
    setTimeout(() => handleTyping(), 1000);
    return;
  }

  if (!isTargetOnline.value || !conversationId.value) {
    console.warn('⚠️ No se puede enviar typing: destinatario offline o sin conversación');
    return;
  }

  socketStore.emit('typing', {
    receiver_id: props.target.id,
    receiver_role: props.target.role,
    is_typing: true,
    conversation_id: conversationId.value
  });

  emit('typing', true);

  if (typingTimeout.value) clearTimeout(typingTimeout.value);

  typingTimeout.value = setTimeout(stopTyping, 3000);
};

const stopTyping = () => {
  if (!isSocketReady.value || !conversationId.value) return;

  socketStore.emit('typing', {
    receiver_id: props.target.id,
    receiver_role: props.target.role,
    is_typing: false,
    conversation_id: conversationId.value
  });

  emit('typing', false);

  if (typingTimeout.value) {
    clearTimeout(typingTimeout.value);
    typingTimeout.value = null;
  }
};

// Manejadores de eventos
const handleTypingIndicator = (data) => {
  if (!data) return;

  const { conversation_id, user_id, is_typing } = data;

  if (conversation_id === conversationId.value && user_id === Number(props.target.id)) {
    isTyping.value = is_typing;

    if (is_typing) {
      if (typingStopTimeout.value) clearTimeout(typingStopTimeout.value);
      typingStopTimeout.value = setTimeout(() => {
        isTyping.value = false;
      }, 4000);
    }
  }
};

const handleNewMessage = async (data) => {
  const { conversation_id, message } = data || {};

  if (conversation_id === conversationId.value && message) {
    // Verificar si ya tenemos este mensaje
    const existingIndex = messages.value.findIndex(m =>
      m.id === message.id || m.temp_id === message.temp_id
    );

    if (existingIndex !== -1) {
      // Actualizar mensaje existente
      const existingMsg = messages.value[existingIndex];
      messages.value[existingIndex] = {
        ...existingMsg,
        ...message,
        is_read: message.is_read !== undefined ? message.is_read : existingMsg.is_read,
        is_delivered: message.is_delivered !== undefined ? message.is_delivered : existingMsg.is_delivered,
        temp_id: undefined,
        _temp: false
      };
    } else {
      // Nuevo mensaje
      const enrichedMessage = {
        ...message,
        is_read: message.is_read || false,
        user_read_at: message.user_read_at || null,
        is_delivered: message.is_delivered || false,
        _temp: false
      };

      messages.value.push(enrichedMessage);

      // Marcar como entregado si es para nosotros
      if (message.sender !== authStore.user?.role) {
        try {
          await api.post('/messages/mark-delivered',
            { message_id: message.id },
            { headers: { Authorization: `Bearer ${authStore.token}` } }
          );

          // Notificar entrega
          if (isSocketReady.value) {
            socketStore.emit('messages_delivered', {
              conversation_id: conversationId.value,
              message_ids: [message.id]
            });
          }

        } catch (err) {
          console.error('Error al marcar mensaje como entregado:', err);
        }
        socketStore.playNotificationSound();
      }
    }

    await scrollToBottom();
  }
};

// ✅ CORREGIDO: Manejador de confirmación de mensaje
const handleMessageConfirmation = (data) => {
  console.log('✅ Confirmación de mensaje en ChatRoomModal:', data);

  if (!data || !data.temp_id) {
    console.warn('⚠️ Confirmación inválida en ChatRoomModal');
    return;
  }

  // Buscar mensaje temporal en el array
  const index = messages.value.findIndex(m => m._temp && m.id === data.temp_id);

  if (index !== -1) {
    const realMessage = data.message || data;

    messages.value[index] = {
      ...messages.value[index],
      ...realMessage,
      id: realMessage.id || data.temp_id,
      is_delivered: true,
      _temp: false
    };

    console.log('✅ Mensaje actualizado en ChatRoomModal:', messages.value[index]);
  } else {
    console.log('⚠️ No se encontró mensaje temporal con temp_id:', data.temp_id);
  }
};

const handleMessageDeleted = (data) => {
  const { conversation_id, message_id } = data || {};
  if (conversation_id === conversationId.value) {
    messages.value = messages.value.filter(m => m.id !== message_id);
  }
};

const handleMessageRead = (data) => {
  const { conversation_id, message_ids } = data || {};
  if (conversation_id === conversationId.value && message_ids) {
    messages.value = messages.value.map(msg =>
      message_ids.includes(msg.id) ? { ...msg, is_read: true } : msg
    );
  }
};

const handleMessageDelivered = (data) => {
  if (!data) return;

  const { conversation_id, message_ids } = data;
  if (conversation_id === conversationId.value && Array.isArray(message_ids)) {
    messages.value = messages.value.map(msg =>
      message_ids.includes(msg.id) ? { ...msg, is_delivered: true } : msg
    );
    console.log('✅ Mensajes marcados como entregados:', message_ids);
  }
};

const handleReconnect = () => {
  console.log('🔄 Socket reconectado, reuniendo a salas...');
  reconnectAttempts.value = 0;

  if (conversationId.value) {
    socketStore.joinConversationRoom(conversationId.value);
    // Re-enviar mensajes pendientes si es necesario
    if (pendingMessages.value.size > 0) {
      console.log(`📨 Reenviando ${pendingMessages.value.size} mensajes pendientes...`);
      // Aquí puedes implementar lógica de reenvío
    }
  }
};

const setupListeners = () => {
  socketStore.on('typing_indicator', handleTypingIndicator);
  socketStore.on('new_message', handleNewMessage);
  socketStore.on('message_deleted', handleMessageDeleted);
  socketStore.on('message_read', handleMessageRead);
  socketStore.on('message_delivered', handleMessageDelivered);
  socketStore.on('connect', handleReconnect);
  socketStore.on('message_sent_confirmation', handleMessageConfirmation); // ✅ Agregado
};

const deleteMessageForMe = async (messageId) => {
  if (!confirm('¿Borrar este mensaje solo para ti? El otro usuario aún podrá verlo.')) return;

  try {
    await api.delete(`/messages/${messageId}/for-me`, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    });
    messages.value = messages.value.filter(m => m.id !== messageId);
    showNotification('Mensaje borrado', 'success');
  } catch (err) {
    console.error('Error al borrar mensaje:', err);
    showNotification('Error al borrar el mensaje', 'error');
  }
};

const deleteChatForMe = async () => {
  if (!authStore.token || !conversationId.value) return;
  if (!confirm('¿Borrar esta conversación solo para ti? El otro usuario aún podrá ver los mensajes.')) return;

  try {
    await api.delete(`/conversations/${conversationId.value}/for-me`, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    });
    showNotification('Conversación borrada', 'success');
    emit('close');
  } catch (err) {
    console.error('Error al borrar chat:', err);
    showNotification('Error al borrar la conversación', 'error');
  }
};

const confirmClearMessagesForMe = () => {
  if (messages.value.length === 0) {
    showNotification('No hay mensajes para borrar', 'info');
    return;
  }
  if (confirm('¿Borrar TODOS los mensajes para ti? El otro usuario aún podrá verlos.')) {
    clearAllMessagesForMe();
  }
};

const confirmDeleteChatForMe = () => {
  deleteChatForMe();
};

const confirmHardDeleteMessages = () => {
  if (authStore.user?.role !== 'admin') {
    showNotification('Solo administradores', 'error');
    return;
  }
  if (confirm('¿ELIMINAR PERMANENTEMENTE todos los mensajes? Esta acción NO se puede deshacer.')) {
    hardDeleteAllMessages();
  }
};

const confirmHardDeleteChat = () => {
  if (authStore.user?.role !== 'admin') {
    showNotification('Solo administradores', 'error');
    return;
  }
  if (confirm('¿ELIMINAR PERMANENTEMENTE toda la conversación? Esta acción NO se puede deshacer.')) {
    hardDeleteChat();
  }
};

const clearAllMessagesForMe = async () => {
  if (!authStore.token || !conversationId.value) return;

  try {
    loading.value = true;
    const promises = messages.value.map(msg =>
      api.delete(`/messages/${msg.id}/for-me`, {
        headers: { Authorization: `Bearer ${authStore.token}` }
      }).catch(() => {})
    );

    await Promise.all(promises);
    messages.value = [];
    showMenu.value = false;
    showNotification('Mensajes borrados', 'success');
  } catch (error) {
    console.error('Error al borrar mensajes:', error);
    showNotification('Error al borrar los mensajes', 'error');
  } finally {
    loading.value = false;
  }
};

const hardDeleteAllMessages = async () => {
  if (!authStore.token || !conversationId.value) return;

  try {
    loading.value = true;
    await api.delete(`/conversations/${conversationId.value}/messages`, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    });
    messages.value = [];
    showMenu.value = false;
    showNotification('Mensajes eliminados permanentemente', 'success');
  } catch (err) {
    console.error('Error al eliminar mensajes:', err);
    showNotification('Error al eliminar los mensajes', 'error');
  } finally {
    loading.value = false;
  }
};

const hardDeleteChat = async () => {
  if (!authStore.token || !conversationId.value) return;

  try {
    loading.value = true;
    await api.delete(`/conversations/${conversationId.value}`, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    });
    showNotification('Conversación eliminada permanentemente', 'success');
    emit('close');
  } catch (err) {
    console.error('Error al eliminar chat:', err);
    showNotification('Error al eliminar la conversación', 'error');
  } finally {
    loading.value = false;
  }
};

const exportChatHistory = () => {
  const chatData = {
    target: props.target,
    messages: messages.value,
    exportDate: new Date().toISOString()
  };

  const dataStr = JSON.stringify(chatData, null, 2);
  const dataBlob = new Blob([dataStr], { type: 'application/json' });
  const url = URL.createObjectURL(dataBlob);
  const link = document.createElement('a');
  link.href = url;
  link.download = `chat_${props.target.name}_${new Date().getTime()}.json`;
  link.click();
  URL.revokeObjectURL(url);
  showNotification('Historial exportado', 'success');
};

// Watchers
watch(messages, scrollToBottom);

// Lifecycle hooks
onMounted(async () => {
  console.log('🚀 ChatRoomModal montado');
  console.log('🎯 Target:', props.target);
  console.log('🔌 Socket conectado:', isSocketReady.value);

  const hasConversation = await ensureConversation();

  if (hasConversation && conversationId.value) {
    setupListeners();

    // Unirse a la sala de conversación
    if (isSocketReady.value) {
      socketStore.joinConversationRoom(conversationId.value);
    } else {
      // Esperar a que el socket se conecte
      const checkSocket = setInterval(() => {
        if (isSocketReady.value) {
          clearInterval(checkSocket);
          socketStore.joinConversationRoom(conversationId.value);
        }
      }, 500);
    }

    await fetchMessages();
  } else {
    console.error('❌ No se pudo obtener conversationId');
    showNotification('Error al iniciar el chat', 'error');
    emit('close');
  }
});

onUnmounted(() => {
  socketStore.off('typing_indicator', handleTypingIndicator);
  socketStore.off('new_message', handleNewMessage);
  socketStore.off('message_deleted', handleMessageDeleted);
  socketStore.off('message_read', handleMessageRead);
  socketStore.off('message_delivered', handleMessageDelivered);
  socketStore.off('connect', handleReconnect);
  socketStore.off('message_sent_confirmation', handleMessageConfirmation); // ✅ Agregado

  stopTyping();

  if (typingStopTimeout.value) clearTimeout(typingStopTimeout.value);

  if (conversationId.value && isSocketReady.value) {
    socketStore.leaveConversationRoom(conversationId.value);
  }
});
</script>

<style scoped>
.message-delete-btn {
  position: absolute;
  top: -8px;
  right: -8px;
  width: 20px;
  height: 20px;
  border-radius: 50%;
  background: #ff4444;
  color: white;
  border: none;
  font-size: 12px;
  cursor: pointer;
  display: none;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.2s;
  z-index: 10;
}

.message-wrapper:hover .message-delete-btn {
  display: flex;
  opacity: 1;
}

.message-delete-btn:hover {
  background: #cc0000;
}

.message-container {
  position: relative;
}

.chat-modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  backdrop-filter: blur(5px);
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

.chat-modal-container {
  background: white;
  width: 90%;
  max-width: 600px;
  height: 80vh;
  border-radius: 1rem;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  animation: slideUp 0.3s ease;
}

@keyframes slideUp {
  from {
    transform: translateY(50px);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

.chat-modal-header {
  background: linear-gradient(135deg, #0984e3 0%, #74b9ff 100%);
  padding: 1rem 1.5rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  color: white;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.header-left {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.user-avatar {
  position: relative;
  width: 44px;
  height: 44px;
  border-radius: 50%;
  overflow: hidden;
  border: 3px solid rgba(255, 255, 255, 0.3);
  flex-shrink: 0;
}

.avatar-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.avatar-online-dot {
  position: absolute;
  bottom: 2px;
  right: 2px;
  width: 10px;
  height: 10px;
  background: #b2bec3;
  border-radius: 50%;
  border: 2px solid white;
  transition: background-color 0.3s;
}

.avatar-online-dot.online {
  background: #00b894;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% {
    transform: scale(1);
    box-shadow: 0 0 0 0 rgba(0, 184, 148, 0.7);
  }
  50% {
    transform: scale(1.1);
    box-shadow: 0 0 0 4px rgba(0, 184, 148, 0.3);
  }
}

.user-info {
  display: flex;
  flex-direction: column;
}

.user-name-wrapper {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
  margin-bottom: 0.25rem;
}

.user-name {
  font-size: 1.1rem;
  font-weight: 600;
  color: white;
  margin: 0;
}

.online-badge {
  background: #00b894;
  color: white;
  font-size: 0.6rem;
  font-weight: 600;
  padding: 2px 6px;
  border-radius: 10px;
  letter-spacing: 0.5px;
  animation: glow 2s infinite;
}

@keyframes glow {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.7; }
}

.user-role {
  font-size: 0.8rem;
  color: rgba(255, 255, 255, 0.9);
  margin: 0;
  text-transform: capitalize;
}

.file-input-wrapper {
  position: relative;
}

.attach-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 50%;
  cursor: pointer;
  font-size: 1.2rem;
  transition: all 0.3s;
}

.attach-btn:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: scale(1.1);
}

.file-input {
  display: none;
}

.menu-btn {
  width: 36px;
  height: 36px;
  background: rgba(255, 255, 255, 0.2);
  border: none;
  border-radius: 50%;
  color: white;
  font-size: 1.5rem;
  cursor: pointer;
  transition: all 0.3s;
  display: flex;
  align-items: center;
  justify-content: center;
}

.menu-btn:hover,
.menu-btn.active {
  background: rgba(255, 255, 255, 0.3);
  transform: scale(1.1);
}

.close-btn {
  width: 36px;
  height: 36px;
  background: rgba(255, 255, 255, 0.2);
  border: none;
  border-radius: 50%;
  color: white;
  font-size: 1.2rem;
  cursor: pointer;
  transition: all 0.3s;
  display: flex;
  align-items: center;
  justify-content: center;
}

.close-btn:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: scale(1.1);
}

.dropdown-wrapper {
  position: relative;
}

.dropdown-menu {
  position: absolute;
  top: 100%;
  right: 0;
  margin-top: 0.5rem;
  background: white;
  border-radius: 0.5rem;
  box-shadow: 0 5px 20px rgba(0, 0, 0, 0.2);
  min-width: 200px;
  z-index: 10;
  animation: fadeIn 0.2s ease;
}

.dropdown-item {
  width: 100%;
  padding: 0.75rem 1rem;
  border: none;
  background: none;
  display: flex;
  align-items: center;
  gap: 0.75rem;
  cursor: pointer;
  transition: all 0.3s;
  color: #2d3436;
  font-size: 0.95rem;
}

.dropdown-item:hover {
  background: #f1f2f6;
}

.dropdown-item:first-child {
  border-radius: 0.5rem 0.5rem 0 0;
}

.dropdown-item:last-child {
  border-radius: 0 0 0.5rem 0.5rem;
}

.dropdown-divider {
  height: 1px;
  background: #e1e8ed;
  margin: 0.25rem 0;
}

.item-icon {
  font-size: 1.1rem;
}

.item-text {
  flex: 1;
  text-align: left;
}

.messages-area {
  flex: 1;
  overflow-y: auto;
  padding: 1.5rem;
  background: #f8f9fa;
}

.messages-area.empty {
  display: flex;
  align-items: center;
  justify-content: center;
}

.messages-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.empty-messages {
  text-align: center;
  max-width: 400px;
  padding: 2rem;
}

.empty-icon {
  font-size: 4rem;
  margin-bottom: 1rem;
  opacity: 0.5;
}

.empty-title {
  color: #2d3436;
  font-size: 1.2rem;
  margin: 0 0 0.5rem 0;
}

.empty-subtitle {
  color: #636e72;
  margin-bottom: 2rem;
}

.chat-tips {
  background: #f1f2f6;
  border-radius: 0.75rem;
  padding: 1rem;
}

.tip {
  color: #0984e3;
  font-size: 0.9rem;
  margin: 0.5rem 0;
  text-align: left;
}

.message-wrapper {
  display: flex;
  gap: 0.75rem;
  animation: fadeIn 0.3s ease;
}

.message-wrapper.sent {
  flex-direction: row-reverse;
}

.message-avatar {
  flex-shrink: 0;
}

.avatar-small {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  object-fit: cover;
}

.message-container {
  max-width: 70%;
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.sent .message-container {
  align-items: flex-end;
}

.message-text {
  background: white;
  padding: 0.75rem 1rem;
  border-radius: 1rem;
  border-bottom-left-radius: 0.25rem;
  color: #2d3436;
  font-size: 0.95rem;
  line-height: 1.4;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
}

.sent .message-text {
  background: #0984e3;
  color: white;
  border-bottom-left-radius: 1rem;
  border-bottom-right-radius: 0.25rem;
}

.message-image {
  margin-top: 0.5rem;
}

.image-preview {
  max-width: 100%;
  max-height: 200px;
  border-radius: 0.75rem;
  cursor: pointer;
  transition: transform 0.3s;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.image-preview:hover {
  transform: scale(1.02);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
}

.message-info {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.7rem;
  color: #b2bec3;
  margin-top: 0.25rem;
}

.sent .message-info {
  justify-content: flex-end;
}

.typing-indicator-wrapper {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 16px;
  background: white;
  border-radius: 18px;
  border: 1px solid #f1f2f6;
  align-self: flex-start;
  max-width: 200px;
  margin-top: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.typing-indicator {
  display: flex;
  gap: 4px;
}

.typing-indicator span {
  width: 6px;
  height: 6px;
  background: #0984e3;
  border-radius: 50%;
  animation: typingBounce 1.4s infinite ease-in-out;
}

.typing-indicator span:nth-child(1) { animation-delay: -0.32s; }
.typing-indicator span:nth-child(2) { animation-delay: -0.16s; }

@keyframes typingBounce {
  0%, 80%, 100% { transform: scale(0); }
  40% { transform: scale(1); }
}

.typing-text {
  color: #636e72;
  font-size: 0.8rem;
  font-style: italic;
}

.image-preview-container {
  padding: 1rem;
  border-top: 1px solid #e1e8ed;
  background: #f8f9fa;
}

.preview-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.5rem;
}

.preview-label {
  font-size: 0.9rem;
  font-weight: 500;
  color: #2d3436;
}

.preview-close {
  background: none;
  border: none;
  color: #636e72;
  font-size: 1.2rem;
  cursor: pointer;
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  transition: all 0.3s;
}

.preview-close:hover {
  background: #e1e8ed;
  color: #d63031;
}

.preview-image {
  max-width: 100%;
  max-height: 100px;
  border-radius: 0.5rem;
  object-fit: contain;
}

.input-area {
  padding: 1rem;
  border-top: 1px solid #e1e8ed;
  background: white;
}

.input-wrapper {
  display: flex;
  gap: 0.75rem;
  margin-bottom: 0.5rem;
}

.message-input {
  flex: 1;
  padding: 0.75rem 1rem;
  border: 2px solid #e1e8ed;
  border-radius: 2rem;
  font-size: 0.95rem;
  transition: all 0.3s;
  outline: none;
}

.message-input:focus {
  border-color: #0984e3;
  box-shadow: 0 0 0 3px rgba(9, 132, 227, 0.1);
}

.message-input:disabled {
  background: #f1f2f6;
  cursor: not-allowed;
}

.send-btn {
  width: 44px;
  height: 44px;
  border: none;
  background: #0984e3;
  color: white;
  border-radius: 50%;
  font-size: 1.5rem;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s;
}

.send-btn:hover:not(:disabled) {
  transform: scale(1.1);
  background: #0866b3;
  box-shadow: 0 4px 12px rgba(9, 132, 227, 0.3);
}

.send-btn.disabled {
  background: #b2bec3;
  cursor: not-allowed;
}

.send-btn.loading {
  background: #b2bec3;
  cursor: wait;
}

.spinner-small {
  width: 20px;
  height: 20px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top: 2px solid white;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.input-hints {
  display: flex;
  gap: 1rem;
  font-size: 0.75rem;
  color: #b2bec3;
  padding-left: 0.5rem;
}

.hint {
  display: flex;
  align-items: center;
  gap: 0.25rem;
}

.online-hint {
  color: #00b894 !important;
  display: flex;
  align-items: center;
  gap: 4px;
}

.online-hint::before {
  content: '●';
  font-size: 0.8rem;
}

.messages-area::-webkit-scrollbar {
  width: 6px;
}

.messages-area::-webkit-scrollbar-track {
  background: #f1f2f6;
}

.messages-area::-webkit-scrollbar-thumb {
  background: #b2bec3;
  border-radius: 3px;
}

.messages-area::-webkit-scrollbar-thumb:hover {
  background: #636e72;
}

.image-modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.95);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2000;
  animation: fadeIn 0.3s ease;
}

.image-modal-container {
  position: relative;
  max-width: 90vw;
  max-height: 90vh;
  animation: zoomIn 0.3s ease;
}

@keyframes zoomIn {
  from {
    transform: scale(0.5);
    opacity: 0;
  }
  to {
    transform: scale(1);
    opacity: 1;
  }
}

.image-modal-close {
  position: absolute;
  top: -40px;
  right: 0;
  width: 40px;
  height: 40px;
  background: rgba(255, 255, 255, 0.2);
  border: none;
  border-radius: 50%;
  color: white;
  font-size: 1.2rem;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s;
}

.image-modal-close:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: scale(1.1);
}

.image-modal-img {
  max-width: 100%;
  max-height: 90vh;
  border-radius: 0.5rem;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
}

@media (max-width: 768px) {
  .image-modal-close {
    top: -50px;
    right: 10px;
  }
}

@media (max-width: 768px) {
  .chat-modal-container {
    width: 100%;
    height: 100vh;
    border-radius: 0;
  }

  .chat-modal-header {
    padding: 0.75rem 1rem;
  }

  .user-name {
    font-size: 1rem;
  }

  .online-badge {
    font-size: 0.55rem;
    padding: 1px 4px;
  }

  .avatar-online-dot {
    width: 8px;
    height: 8px;
  }

  .message-container {
    max-width: 85%;
  }

  .message-text {
    font-size: 0.9rem;
    padding: 0.6rem 0.9rem;
  }

  .input-hints {
    flex-wrap: wrap;
    gap: 0.5rem;
  }
}

@media (max-width: 480px) {
  .header-left {
    gap: 0.5rem;
  }

  .user-avatar {
    width: 36px;
    height: 36px;
  }

  .attach-btn,
  .menu-btn,
  .close-btn {
    width: 32px;
    height: 32px;
    font-size: 1rem;
  }

  .dropdown-menu {
    right: -20px;
  }

  .message-container {
    max-width: 90%;
  }

  .messages-area {
    padding: 1rem;
  }

  .input-wrapper {
    gap: 0.5rem;
  }

  .message-input {
    padding: 0.6rem 0.9rem;
    font-size: 0.9rem;
  }

  .send-btn {
    width: 40px;
    height: 40px;
    font-size: 1.3rem;
  }
}

.status-sent {
  color: #9ca3af;
  margin-left: 4px;
}

.status-delivered {
  color: #9ca3af;
  margin-left: 4px;
}

.status-read {
  color: #3b82f6;
  margin-left: 4px;
}

.read-indicator {
  color: #3b82f6;
  margin-left: 4px;
  font-size: 12px;
}

.error-image {
  opacity: 0.5;
  filter: grayscale(100%);
}
</style>
