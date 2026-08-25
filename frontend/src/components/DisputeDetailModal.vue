<template>
  <Teleport to="body">
    <Transition name="modal-fade">
      <div
        v-if="isOpen"
        class="fixed inset-0 z-[60] flex items-center justify-center p-4"
        @click.self="close"
      >
        <!-- Overlay -->
        <div class="absolute inset-0 bg-black/50 backdrop-blur-sm" />

        <!-- Modal -->
        <div class="relative bg-white rounded-2xl shadow-2xl max-w-lg w-full max-h-[90vh] flex flex-col">
          <!-- Header -->
          <div class="flex items-center justify-between p-4 border-b">
            <h3 class="text-xl font-bold text-slate-800">
              Disputa #{{ dispute?.id || '' }}
            </h3>
            <button class="text-gray-500 hover:text-gray-700 text-2xl" @click="close">×</button>
          </div>

          <!-- Estado -->
          <div class="px-4 py-2 bg-slate-50 border-b">
            <span class="text-sm font-semibold" :class="statusClass">
              {{ statusLabel }}
            </span>
          </div>

          <!-- Mensajes -->
          <div ref="messagesContainer" class="flex-1 overflow-y-auto p-4 space-y-3">
            <div v-if="loading" class="text-center text-gray-500 py-8">
              Cargando...
            </div>
            <div v-else-if="!messages.length" class="text-center text-gray-500 py-8">
              No hay mensajes todavía
            </div>
            <div
              v-for="msg in messages"
              :key="msg.id"
              class="flex"
              :class="msg.sender_role === 'admin' ? 'justify-start' : msg.sender_id === authStore.user?.id ? 'justify-end' : 'justify-start'"
            >
              <div
                class="max-w-[80%] rounded-lg px-4 py-2"
                :class="msg.sender_role === 'admin' ? 'bg-red-50 border border-red-200' : msg.sender_id === authStore.user?.id ? 'bg-sky-600 text-white' : 'bg-gray-100 text-gray-800'"
              >
                <div class="text-xs font-semibold mb-1">
                  {{ msg.sender_role === 'admin' ? 'Admin' : msg.sender_id === authStore.user?.id ? 'Tú' : 'Otra parte' }}
                </div>
                <p class="text-sm whitespace-pre-wrap">{{ msg.message }}</p>
                <div v-if="msg.file_url" class="mt-2">
                  <a :href="msg.file_url" target="_blank" class="text-xs underline">
                    📎 Ver evidencia
                  </a>
                </div>
                <div class="text-xs opacity-70 mt-1">{{ formatDate(msg.created_at) }}</div>
              </div>
            </div>
          </div>

          <!-- Input para mensaje -->
          <div v-if="!isResolved" class="border-t p-4">
            <div class="flex gap-2">
              <input
                v-model="newMessage"
                type="text"
                placeholder="Escribe un mensaje..."
                class="flex-1 px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-sky-500"
                @keyup.enter="sendMessage"
              />
              <button
                :disabled="!newMessage.trim() || sending"
                class="px-4 py-2 bg-sky-600 text-white rounded-lg hover:bg-sky-700 disabled:opacity-50"
                @click="sendMessage"
              >
                Enviar
              </button>
            </div>

            <!-- Subir evidencia -->
            <div class="mt-3">
              <label class="text-sm text-gray-600 cursor-pointer hover:text-sky-600">
                📎 Adjuntar evidencia
                <input
                  type="file"
                  class="hidden"
                  accept="image/*,.pdf"
                  @change="uploadEvidence"
                />
              </label>
            </div>
          </div>

          <!-- Botón de apelación -->
          <div v-if="isResolved && canAppeal" class="border-t p-4">
            <button
              class="w-full px-4 py-2 bg-amber-600 text-white rounded-lg hover:bg-amber-700"
              @click="appeal"
            >
              ⚠️ Apelar resolución
            </button>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup>
import { ref, computed, watch, nextTick } from 'vue'
import api from '@/axios'
import { useAuthStore } from '@/stores/authStore'
import { useSocketStore } from '@/stores/socketStore'
import { formatDate } from '@/utils/formatDate'
import Swal from 'sweetalert2'

const props = defineProps({
  isOpen: Boolean,
  disputeId: {
    type: Number,
    default: null
  }
})

const emit = defineEmits(['close', 'updated'])

const authStore = useAuthStore()
const socketStore = useSocketStore()

const dispute = ref(null)
const messages = ref([])
const newMessage = ref('')
const loading = ref(false)
const sending = ref(false)
const messagesContainer = ref(null)

const isResolved = computed(() => dispute.value?.status === 'resolved' || dispute.value?.status === 'closed')
const canAppeal = computed(() => dispute.value?.user_id === authStore.user?.id)

const statusLabel = computed(() => {
  const labels = {
    open: '⚖️ Abierta',
    under_review: '🔍 En revisión',
    resolved: '✅ Resuelta',
    closed: '🔒 Cerrada'
  }
  return labels[dispute.value?.status] || dispute.value?.status || ''
})

const statusClass = computed(() => {
  const classes = {
    open: 'text-red-600',
    under_review: 'text-amber-600',
    resolved: 'text-green-600',
    closed: 'text-gray-600'
  }
  return classes[dispute.value?.status] || ''
})

const fetchDispute = async () => {
  if (!props.disputeId) return
  loading.value = true
  try {
    const { data } = await api.get(`/disputes/${props.disputeId}`, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    dispute.value = data.dispute
    messages.value = data.messages || []
    scrollToBottom()
  } catch (err) {
    console.error('Error cargando disputa:', err)
  } finally {
    loading.value = false
  }
}

const sendMessage = async () => {
  if (!newMessage.value.trim() || sending.value) return
  sending.value = true
  try {
    await api.post(`/disputes/${props.disputeId}/message`, {
      message: newMessage.value.trim()
    }, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    newMessage.value = ''
    await fetchDispute()
    emit('updated')
  } catch (err) {
    console.error('Error enviando mensaje:', err)
    Swal.fire('Error', 'No se pudo enviar el mensaje', 'error')
  } finally {
    sending.value = false
  }
}

const uploadEvidence = async (event) => {
  const file = event.target.files?.[0]
  if (!file) return

  const formData = new FormData()
  formData.append('evidence', file)

  try {
    await api.post(`/disputes/${props.disputeId}/upload`, formData, {
      headers: {
        Authorization: `Bearer ${authStore.token}`,
        'Content-Type': 'multipart/form-data'
      }
    })
    await fetchDispute()
    emit('updated')
    Swal.fire('Éxito', 'Evidencia subida correctamente', 'success')
  } catch (err) {
    console.error('Error subiendo evidencia:', err)
    Swal.fire('Error', 'No se pudo subir la evidencia', 'error')
  }
}

const appeal = async () => {
  const { value: reason } = await Swal.fire({
    title: 'Apelar resolución',
    input: 'textarea',
    inputPlaceholder: 'Explica por qué no estás de acuerdo con la resolución...',
    showCancelButton: true,
    confirmButtonText: 'Enviar apelación',
    cancelButtonText: 'Cancelar'
  })

  if (!reason) return

  try {
    await api.post(`/disputes/${props.disputeId}/appeal`, { reason }, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    await fetchDispute()
    emit('updated')
    Swal.fire('Éxito', 'Apelación enviada', 'success')
  } catch (err) {
    console.error('Error apelando:', err)
    Swal.fire('Error', 'No se pudo enviar la apelación', 'error')
  }
}

const scrollToBottom = () => {
  nextTick(() => {
    if (messagesContainer.value) {
      messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight
    }
  })
}

watch(() => props.isOpen, (val) => {
  if (val) fetchDispute()
})

watch(() => props.disputeId, (val) => {
  if (val && props.isOpen) fetchDispute()
})

const close = () => emit('close')
</script>

<style scoped>
.modal-fade-enter-active,
.modal-fade-leave-active {
  transition: opacity 0.2s ease;
}
.modal-fade-enter-from,
.modal-fade-leave-to {
  opacity: 0;
}
</style>
