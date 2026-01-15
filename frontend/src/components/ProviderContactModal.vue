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
          <p class="text-xs text-gray-500">Socket: {{ socketConnected ? '✅' : '⚠️' }}</p>
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
import { ref, watch, onBeforeUnmount, computed } from 'vue';
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
const socketConnected = computed(() => socketStore.isConnected);

let timerInterval = null;
let pollingInterval = null;
let socketHandler = null;
let reconnectionWatcher = null;

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
  timerInterval = null;
  pollingInterval = null;
};

const cleanup = () => {
  console.log('🧹 Limpiando ProviderContactModal...');
  stopTimers();

  if (socketHandler) {
    socketStore.off('request_updated', socketHandler);
    socketHandler = null;
  }

  if (reconnectionWatcher) {
    reconnectionWatcher();
    reconnectionWatcher = null;
  }
};

/* ----------------------------------------------------------
  SOCKET HANDLER (SOCKET-FIRST)
---------------------------------------------------------- */
const createSocketHandler = () => {
  return (payload) => {
    console.log('🔔 [SOCKET] ProviderContactModal recibió:', payload);

    if (!payload || typeof payload !== 'object') return;

    const incomingId = String(payload.request_id || payload.id || '');
    const currentId = String(props.requestId || '');

    if (incomingId !== currentId) {
      console.log(`⏩ Ignorando evento para ${incomingId} (modal: ${currentId})`);
      return;
    }

    const newStatus = payload.status;
    if (['accepted', 'rejected', 'busy'].includes(newStatus)) {
      console.log(`✅ [SOCKET] Status actualizado: ${status.value} → ${newStatus}`);
      status.value = newStatus;
      stopTimers(); // Detener polling si socket funciona
    }
  };
};

/* ----------------------------------------------------------
  POLLING FALLBACK
---------------------------------------------------------- */
const startPolling = () => {
  if (pollingInterval) return; // Evitar duplicados
  
  console.log('🔄 [POLLING] Iniciando fallback polling...');
  
  pollingInterval = setInterval(async () => {
    if (!props.requestId || status.value !== 'pending' || socketConnected.value) {
      return; // No hacer polling si socket está conectado
    }

    try {
      console.log('📡 [POLLING] Intentando fetch...');
      const res = await api.get(`/requests/status/${props.requestId}`, {
        headers: authStore.token ? { Authorization: `Bearer ${authStore.token}` } : {},
      });

      const newStatus = res.data?.status;
      if (newStatus && newStatus !== 'pending') {
        console.log(`✅ [POLLING] Status cambiado: ${newStatus}`);
        const handler = createSocketHandler();
        handler({ request_id: props.requestId, status: newStatus });
        stopPolling(); // Detener polling una vez que funciona
      }
    } catch (err) {
      console.error('❌ [POLLING] Error:', err.message);
    }
  }, 4000); // Cada 4s (menos agresivo)
};

const stopPolling = () => {
  if (pollingInterval) {
    console.log('🛑 [POLLING] Deteniendo polling');
    clearInterval(pollingInterval);
    pollingInterval = null;
  }
};

/* ----------------------------------------------------------
  PROCESO PRINCIPAL (SOCKET-FIRST)
---------------------------------------------------------- */
const reset = () => {
  status.value = 'pending';
  countdown.value = 90;
};

const startProcess = async () => {
  if (!props.requestId) return;

  console.log('🚀 [START] Iniciando ProviderContactModal para request:', props.requestId);

  cleanup();
  reset();

  // 1. ESPERAR CONEXIÓN SOCKET (máx 5s)
  if (!socketConnected.value) {
    console.log('⏳ Esperando conexión socket...');
    const maxWait = 5000;
    const startTime = Date.now();
    
    await new Promise(resolve => {
      const checkInterval = setInterval(() => {
        if (socketConnected.value || Date.now() - startTime > maxWait) {
          clearInterval(checkInterval);
          resolve();
        }
      }, 100);
    });
  }

  // 2. CONFIGURAR SOCKET HANDLER
  socketHandler = createSocketHandler();
  socketStore.off('request_updated', socketHandler); // Limpieza previa
  socketStore.on('request_updated', socketHandler);
  console.log('📡 [SOCKET] Listener registrado. Conectado:', socketConnected.value);

  // 3. INICIAR POLLING COMO FALLBACK (solo si socket no conectado)
  if (!socketConnected.value) {
    console.warn('⚠️ Socket no conectado, usando polling fallback');
    startPolling();
  } else {
    console.log('✅ Socket conectado, polling desactivado');
  }

  // 4. INICIAR CUENTA REGRESIVA
  timerInterval = setInterval(() => {
    countdown.value--;
    if (countdown.value <= 0 && status.value === 'pending') {
      console.log('⏰ Tiempo agotado, no-response');
      status.value = 'no-response';
      stopPolling();
    }
  }, 1000);

  // 5. WATCHER PARA RECONEXIÓN
  reconnectionWatcher = watch(socketConnected, (connected) => {
    if (connected && status.value === 'pending' && !pollingInterval) {
      console.log('🔄 [RECONNECT] Socket reconectado, desactivando polling');
      stopPolling();
      // Re-registrar listener por si acaso
      socketStore.off('request_updated', socketHandler);
      socketStore.on('request_updated', socketHandler);
    } else if (!connected && status.value === 'pending') {
      console.warn('⚠️ [DISCONNECT] Socket desconectado, activando polling');
      startPolling();
    }
  });
};

const stopProcess = () => {
  console.log('🛑 [STOP] Deteniendo proceso');
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
      stopProcess();
    }
  },
  { immediate: true }
);

watch(
  () => props.requestId,
  (newId, oldId) => {
    if (newId !== oldId && props.isOpen) {
      console.log('🔄 Request ID cambió:', oldId, '→', newId);
      stopProcess();
      startProcess();
    }
  }
);

onBeforeUnmount(() => {
  console.log('🧹 onBeforeUnmount');
  cleanup();
});

defineExpose({
  startProcess,
  stopProcess,
  formatTime,
  status,
  countdown
});
</script>
