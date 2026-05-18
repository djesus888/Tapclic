<template>
  <div v-if="isOpen" class="modal-overlay">
    <div class="modal-container">
      <!-- Estado pendiente -->
      <template v-if="status === 'pending'">
        <div class="modal-card pending">
          <div class="modal-icon">
            <span class="icon">⏳</span>
          </div>

          <div class="modal-content">
            <h3 class="modal-title">
              {{ $t('contacting_provider', { name: providerName }) }}
            </h3>
            <p class="modal-description">
              {{ $t('waiting_provider_response') }}
            </p>

            <div class="modal-timer">
              <div class="timer-display">
                {{ formatTime(countdown) }}
              </div>
              <div class="timer-progress">
                <div
                  class="progress-bar"
                  :style="{ width: `${(countdown / 90) * 100}%` }"
                ></div>
              </div>
            </div>

            <div class="modal-status">
              <div class="status-item">
                <span class="status-icon">{{ socketConnected ? '✅' : '⚠️' }}</span>
                <span class="status-text">Socket: {{ socketConnected ? 'Conectado' : 'Desconectado' }}</span>
              </div>
            </div>
          </div>
        </div>
      </template>

      <!-- Estado aceptado -->
      <template v-else-if="status === 'accepted'">
        <div class="modal-card accepted">
          <div class="modal-icon">
            <span class="icon">✅</span>
          </div>

          <div class="modal-content">
            <h3 class="modal-title modal-title-success">
              {{ $t('service_accepted') }}
            </h3>
            <p class="modal-description">
              {{ $t('provider_accepted_request', { name: providerName }) }}
            </p>

            <div class="modal-actions">
              <button
                class="btn-success"
                @click="$emit('openPayment')"
              >
                <span class="btn-icon">💳</span>
                {{ $t('proceed_to_payment') }}
              </button>
            </div>
          </div>
        </div>
      </template>

      <!-- Estado rechazado -->
      <template v-else-if="status === 'rejected'">
        <div class="modal-card rejected">
          <div class="modal-icon">
            <span class="icon">❌</span>
          </div>

          <div class="modal-content">
            <h3 class="modal-title modal-title-error">
              {{ $t('request_rejected') }}
            </h3>
            <p class="modal-description">
              {{ $t('provider_rejected_request', { name: providerName }) }}
            </p>

            <div class="modal-actions">
              <button
                class="btn-secondary"
                @click="handleCancel"
              >
                <span class="btn-icon">←</span>
                {{ $t('cancel') }}
              </button>
              <button
                class="btn-primary"
                @click="handleRetry"
              >
                <span class="btn-icon">🔄</span>
                {{ $t('try_again') }}
              </button>
            </div>
          </div>
        </div>
      </template>

      <!-- Estado ocupado -->
      <template v-else-if="status === 'busy'">
        <div class="modal-card busy">
          <div class="modal-icon">
            <span class="icon">⚠️</span>
          </div>

          <div class="modal-content">
            <h3 class="modal-title modal-title-warning">
              {{ $t('provider_busy') }}
            </h3>
            <p class="modal-description">
              {{ $t('provider_is_busy', { name: providerName }) }}
            </p>

            <div class="modal-actions">
              <button
                class="btn-secondary"
                @click="handleCancel"
              >
                <span class="btn-icon">←</span>
                {{ $t('cancel') }}
              </button>
              <button
                class="btn-primary"
                @click="handleRetry"
              >
                <span class="btn-icon">⏰</span>
                {{ $t('try_later') }}
              </button>
            </div>
          </div>
        </div>
      </template>

      <!-- Estado sin respuesta -->
      <template v-else-if="status === 'no-response'">
        <div class="modal-card no-response">
          <div class="modal-icon">
            <span class="icon">⏰</span>
          </div>

          <div class="modal-content">
            <h3 class="modal-title modal-title-info">
              {{ $t('no_response') }}
            </h3>
            <p class="modal-description">
              {{ $t('provider_no_response', { name: providerName }) }}
            </p>

            <div class="modal-actions">
              <button
                class="btn-secondary"
                @click="handleCancel"
              >
                <span class="btn-icon">←</span>
                {{ $t('cancel') }}
              </button>
              <button
                class="btn-primary"
                @click="handleRetry"
              >
                <span class="btn-icon">🔄</span>
                {{ $t('try_again') }}
              </button>
            </div>
          </div>
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

    // Buscar en payload.request.id (estructura anidada del backend)
    const incomingId = String(
      payload.request_id ||
      payload.id ||
      payload.request?.id ||
      ''
    );
    const currentId = String(props.requestId || '');

    if (incomingId !== currentId) {
      console.log(`⏩ Ignorando evento para ${incomingId} (modal: ${currentId})`);
      return;
    }

    // Buscar status en payload.request.status
    const newStatus = payload.status || payload.request?.status;
    if (['accepted', 'rejected', 'busy'].includes(newStatus)) {
      console.log(`✅ [SOCKET] Status actualizado: ${status.value} → ${newStatus}`);
      status.value = newStatus;
      stopTimers();
    }
  };
};

/* ----------------------------------------------------------
  POLLING FALLBACK
---------------------------------------------------------- */
const startPolling = () => {
  if (pollingInterval) return;

  console.log('🔄 [POLLING] Iniciando fallback polling...');

  pollingInterval = setInterval(async () => {
    if (!props.requestId || status.value !== 'pending' || socketConnected.value) {
      return;
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
        stopPolling();
      }
    } catch (err) {
      console.error('❌ [POLLING] Error:', err.message);
    }
  }, 4000);
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

const startTimer = () => {
  stopTimers();
  timerInterval = setInterval(() => {
    countdown.value--;
    if (countdown.value <= 0 && status.value === 'pending') {
      console.log('⏰ Tiempo agotado, no-response');
      status.value = 'no-response';
      stopPolling();
      stopTimers();
    }
  }, 1000);
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
  socketStore.off('request_updated', socketHandler);
  socketStore.on('request_updated', socketHandler);
  console.log('📡 [SOCKET] Listener registrado. Conectado:', socketConnected.value);

  // 3. INICIAR POLLING COMO FALLBACK
  if (!socketConnected.value) {
    console.warn('⚠️ Socket no conectado, usando polling fallback');
    startPolling();
  } else {
    console.log('✅ Socket conectado, polling desactivado');
  }

  // 4. INICIAR CUENTA REGRESIVA
  startTimer();

  // 5. WATCHER PARA RECONEXIÓN
  reconnectionWatcher = watch(socketConnected, (connected) => {
    if (connected && status.value === 'pending' && !pollingInterval) {
      console.log('🔄 [RECONNECT] Socket reconectado, desactivando polling');
      stopPolling();
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
const cancelRequest = async () => {
  if (!props.requestId || !authStore.token) return false;

  try {
    const res = await api.post(
      '/requests/cancel',
      { id: props.requestId },
      {
        headers: { Authorization: `Bearer ${authStore.token}` }
      }
    );

    if (res.data?.success) {
      console.log('✅ Solicitud cancelada vía API:', props.requestId);
      return true;
    } else {
      console.warn('⚠️ API no pudo cancelar:', res.data?.message);
      return false;
    }
  } catch (err) {
    console.error('❌ Error al cancelar solicitud:', err);
    return false;
  }
};

const handleCancel = async () => {
  await cancelRequest();
  cleanup();
  emit('cancel');
};

const handleRetry = () => {
  console.log('🔄 Reiniciando contador para nuevo intento...');
  // Reiniciar estado visual
  status.value = 'pending';
  countdown.value = 90;
  // Reiniciar timer
  startTimer();
  // Reactivar polling si socket no conectado
  if (!socketConnected.value) {
    startPolling();
  }
  // Emitir para que el padre reintente la lógica
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

<style scoped>
.modal-overlay {
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
  backdrop-filter: blur(4px);
  animation: fadeIn 0.3s ease-out;
}

@keyframes fadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

.modal-container {
  width: 90%;
  max-width: 400px;
  animation: slideUp 0.4s ease-out;
}

@keyframes slideUp {
  from {
    transform: translateY(20px);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

.modal-card {
  background: white;
  border-radius: 20px;
  overflow: hidden;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  animation: cardAppear 0.5s ease-out;
}

@keyframes cardAppear {
  from {
    transform: scale(0.95);
    opacity: 0;
  }
  to {
    transform: scale(1);
    opacity: 1;
  }
}

.modal-card.pending {
  border-top: 4px solid #3498db;
}

.modal-card.accepted {
  border-top: 4px solid #00b894;
}

.modal-card.rejected {
  border-top: 4px solid #ff7675;
}

.modal-card.busy {
  border-top: 4px solid #fdcb6e;
}

.modal-card.no-response {
  border-top: 4px solid #636e72;
}

.modal-icon {
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 30px 0 20px;
}

.modal-icon .icon {
  font-size: 64px;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.1);
  }
}

.modal-content {
  padding: 0 30px 30px;
  text-align: center;
}

.modal-title {
  font-size: 1.8rem;
  color: #2d3436;
  margin-bottom: 12px;
  font-weight: 700;
}

.modal-title-success {
  color: #00b894;
}

.modal-title-error {
  color: #ff7675;
}

.modal-title-warning {
  color: #fdcb6e;
}

.modal-title-info {
  color: #636e72;
}

.modal-description {
  color: #636e72;
  font-size: 1rem;
  line-height: 1.5;
  margin-bottom: 25px;
}

.modal-timer {
  background: #f8f9fa;
  padding: 20px;
  border-radius: 12px;
  margin-bottom: 20px;
}

.timer-display {
  font-family: 'Courier New', monospace;
  font-size: 2.5rem;
  font-weight: 700;
  color: #2d3436;
  margin-bottom: 12px;
  letter-spacing: 2px;
}

.timer-progress {
  height: 8px;
  background: #dfe6e9;
  border-radius: 4px;
  overflow: hidden;
}

.progress-bar {
  height: 100%;
  background: linear-gradient(90deg, #74b9ff, #0984e3);
  border-radius: 4px;
  transition: width 1s linear;
}

.modal-status {
  display: flex;
  justify-content: center;
  margin-top: 15px;
}

.status-item {
  display: flex;
  align-items: center;
  gap: 8px;
  background: #f8f9fa;
  padding: 8px 16px;
  border-radius: 20px;
}

.status-icon {
  font-size: 1.2rem;
}

.status-text {
  font-size: 0.9rem;
  color: #636e72;
  font-weight: 600;
}

.modal-actions {
  display: flex;
  gap: 12px;
  justify-content: center;
  margin-top: 25px;
}

button {
  border: none;
  padding: 14px 24px;
  border-radius: 12px;
  font-weight: 600;
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.3s;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  min-width: 140px;
}

button:hover {
  transform: translateY(-3px);
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.15);
}

button:active {
  transform: translateY(-1px);
}

.btn-success {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
  color: white;
}

.btn-success:hover {
  box-shadow: 0 10px 20px rgba(0, 184, 148, 0.3);
}

.btn-primary {
  background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%);
  color: white;
}

.btn-primary:hover {
  box-shadow: 0 10px 20px rgba(116, 185, 255, 0.3);
}

.btn-secondary {
  background: #f8f9fa;
  color: #636e72;
  border: 2px solid #dfe6e9;
}

.btn-secondary:hover {
  border-color: #74b9ff;
  color: #0984e3;
  box-shadow: 0 10px 20px rgba(223, 230, 233, 0.3);
}

.btn-icon {
  font-size: 1.2rem;
}

/* Responsive */
@media (max-width: 480px) {
  .modal-container {
    width: 95%;
  }
  
  .modal-content {
    padding: 0 20px 20px;
  }
  
  .modal-title {
    font-size: 1.5rem;
  }
  
  .modal-actions {
    flex-direction: column;
    align-items: stretch;
  }
  
  button {
    width: 100%;
  }
  
  .timer-display {
    font-size: 2rem;
  }
}

@media (max-width: 768px) {
  .modal-card {
    border-radius: 16px;
  }
}
</style>
