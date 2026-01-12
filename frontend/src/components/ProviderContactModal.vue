<template>
  <div
    v-if="isOpen"
    class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-30"
  >
    <div class="bg-white rounded-xl w-full max-w-sm p-6 text-center">
      <!-- Estado pendiente -->
      <template v-if="status === 'pending'">
        <p class="text-lg">
          {{ $t('contacting_provider', { name: providerName }) }}
        </p>
        <p class="text-gray-600 mt-2">
          {{ $t('waiting_provider_response') }}
        </p>
        <div class="mt-4 flex flex-col items-center space-y-2">
          <span class="text-3xl">⏳</span>
          <p class="text-xl font-mono">
            {{ formatTime(countdown) }}
          </p>
        </div>
      </template>

      <!-- Estado aceptado -->
      <template v-else-if="status === 'accepted'">
        <p class="text-green-600 text-lg">
          {{ $t('service_accepted') }}
        </p>
        <p>{{ $t('provider_accepted_request', { name: providerName }) }}</p>
        <div class="mt-4">
          <button
            class="px-4 py-2 bg-green-600 text-white rounded-lg"
            @click="$emit('openPayment')"
          >
            {{ $t('proceed_to_payment') }}
          </button>
        </div>
      </template>

      <!-- Estado rechazado -->
      <template v-else-if="status === 'rejected'">
        <p class="text-red-600 text-lg">
          {{ $t('request_rejected') }}
        </p>
        <p>{{ $t('provider_rejected_request', { name: providerName }) }}</p>
        <div class="mt-4 flex justify-center gap-2">
          <button
            class="px-4 py-2 border rounded-lg"
            @click="handleCancel"
          >
            {{ $t('cancel') }}
          </button>
          <button
            class="px-4 py-2 bg-blue-600 text-white rounded-lg"
            @click="handleRetry"
          >
            {{ $t('try_again') }}
          </button>
        </div>
      </template>

      <!-- Estado ocupado -->
      <template v-else-if="status === 'busy'">
        <p class="text-yellow-600 text-lg">
          {{ $t('provider_busy') }}
        </p>
        <p>{{ $t('provider_is_busy', { name: providerName }) }}</p>
        <div class="mt-4 flex justify-center gap-2">
          <button
            class="px-4 py-2 border rounded-lg"
            @click="handleCancel"
          >
            {{ $t('cancel') }}
          </button>
          <button
            class="px-4 py-2 bg-blue-600 text-white rounded-lg"
            @click="handleRetry"
          >
            {{ $t('try_later') }}
          </button>
        </div>
      </template>

      <!-- Estado sin respuesta -->
      <template v-else-if="status === 'no-response'">
        <p class="text-gray-600 text-lg">
          {{ $t('no_response') }}
        </p>
        <p>{{ $t('provider_no_response', { name: providerName }) }}</p>
        <div class="mt-4 flex justify-center gap-2">
          <button
            class="px-4 py-2 border rounded-lg"
            @click="handleCancel"
          >
            {{ $t('cancel') }}
          </button>
          <button
            class="px-4 py-2 bg-blue-600 text-white rounded-lg"
            @click="handleRetry"
          >
            {{ $t('try_again') }}
          </button>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, onBeforeUnmount, onUnmounted, onMounted } from 'vue';
import { useSocketStore } from '@/stores/socketStore';
import { useAuthStore } from '@/stores/authStore';
import api from '@/axios';
import { useI18n } from 'vue-i18n';

const { t } = useI18n();
const socketStore = useSocketStore();
const authStore = useAuthStore();

const props = defineProps({
  isOpen: Boolean,
  providerName: String,
  requestId: [Number, String],
});

const emit = defineEmits(['cancel', 'openPayment', 'retry-request']);

const status = ref('pending');
const countdown = ref(90);

let timerInterval = null;
let pollingInterval = null;
let socketHandler = null;

/* ----------------------------------------------------------
  UTILIDADES
---------------------------------------------------------- */
const formatTime = (seconds) => {
  const m = String(Math.floor(seconds / 60)).padStart(2, '0');
  const s = String(seconds % 60).padStart(2, '0');
  return `${m}:${s}`;
};

const stopTimers = () => {
  if (timerInterval) clearInterval(timerInterval);
  if (pollingInterval) clearInterval(pollingInterval);
};

const cleanup = () => {
  console.log('🧹 Limpiando ProviderContactModal...');
  stopTimers();
  
  if (socketHandler) {
    socketStore.off('request_updated', socketHandler);
    socketStore.off('status_updated', socketHandler);
    socketStore.off('request_update', socketHandler);
    socketHandler = null;
  }
};

/* ----------------------------------------------------------
  SOCKET HANDLER
---------------------------------------------------------- */
const createSocketHandler = () => {
  return (payload) => {
    console.log('🔔 ProviderContactModal recibió evento:', payload);
    
    if (!payload || typeof payload !== 'object') return;
    
    const incomingId = String(payload.request_id || payload.id || '');
    const currentId = String(props.requestId || '');
    
    if (incomingId !== currentId) {
      console.log(`⏩ Ignorando evento para request ${incomingId} (modal está en ${currentId})`);
      return;
    }

    const newStatus = payload.status;
    if (['accepted', 'rejected', 'busy'].includes(newStatus)) {
      console.log(`✅ Status actualizado: ${status.value} → ${newStatus}`);
      status.value = newStatus;
      stopTimers();
    }
  };
};

/* ----------------------------------------------------------
  PROCESO
---------------------------------------------------------- */
const reset = () => {
  status.value = 'pending';
  countdown.value = 90;
};

const startPolling = () => {
  if (pollingInterval) clearInterval(pollingInterval);
  
  pollingInterval = setInterval(async () => {
    if (props.requestId && status.value === 'pending') {
      try {
        const res = await api.get(`/requests/${props.requestId}`, {
          headers: authStore.token ? { Authorization: `Bearer ${authStore.token}` } : {},
        });
        
        const data = res.data?.data;
        if (data?.status && data.status !== 'pending') {
          const handler = createSocketHandler();
          handler({ request_id: props.requestId, status: data.status });
          stopPolling();
        }
      } catch (err) {
        console.error('❌ Polling error:', err.message);
      }
    }
  }, 3000);
};

const stopPolling = () => {
  if (pollingInterval) {
    clearInterval(pollingInterval);
    pollingInterval = null;
  }
};

const startProcess = async () => {
  if (!props.requestId) return;
  
  console.log('🚀 Iniciando ProviderContactModal para request:', props.requestId);
  
  cleanup();
  reset();
  
  // Asegurar conexión socket
//  if (!socketStore.isConnected && authStore.token) {
  //  try {
    //  await socketStore.connect(authStore.token, authStore.user);
   // } catch {
     // console.warn('⚠️ Socket no conectado, usando polling fallback');
   // }
 // }
  
  // Configurar listener socket
  socketHandler = createSocketHandler();
  
  // Intentar múltiples nombres de evento por compatibilidad
  socketStore.off('request_updated', socketHandler);
  socketStore.off('status_updated', socketHandler);
  socketStore.off('request_update', socketHandler);
  
  socketStore.on('request_updated', socketHandler);
  socketStore.on('status_updated', socketHandler);
  
  console.log('📡 Socket listeners registrados para request_updated y status_updated');
  
  startPolling();
  
  // Timer de cuenta regresiva
  timerInterval = setInterval(() => {
    countdown.value--;
    if (countdown.value <= 0 && status.value === 'pending') {
      status.value = 'no-response';
      stopPolling();
    }
  }, 1000);
};

const stopProcess = () => {
  cleanup();
};

/* ----------------------------------------------------------
  ACCIONES
---------------------------------------------------------- */
const deleteRequest = async () => {
  try {
    await api.delete(`/requests/${props.requestId}`);
    console.log('🗑️ Solicitud eliminada:', props.requestId);
  } catch (err) {
    console.error('❌ Error al eliminar:', err);
  }
};

const handleCancel = async () => {
  await deleteRequest();
  cleanup();
  emit('cancel');
};

const handleRetry = async () => {
  await deleteRequest();
  cleanup();
  emit('retry-request');
};

/* ----------------------------------------------------------
  WATCHERS & LIFECYCLE
---------------------------------------------------------- */
watch(
  () => props.isOpen,
  (open) => {
    if (open && props.requestId) {
      startProcess();
    } else {
      cleanup();
    }
  },
  { immediate: true }
);

onBeforeUnmount(() => {
  cleanup();
});

onUnmounted(() => {
  cleanup();
});

onMounted(() => {
  window.addEventListener('beforeunload', cleanup);
});

/* ----------------------------------------------------------
  EXPONER MÉTODOS AL COMPONENTE PADRE
---------------------------------------------------------- */
defineExpose({
  startProcess,
  stopProcess,
  formatTime,
  status,
  countdown
});
</script>
