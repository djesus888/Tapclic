<template>
  <div class="modal-overlay" @click.self="close">
    <div class="confirm-modal">
      <div class="modal-icon" :class="type">
        <span v-if="type === 'danger'">⚠️</span>
        <span v-else-if="type === 'success'">✅</span>
        <span v-else>❓</span>
      </div>
      
      <div class="modal-content">
        <h3 class="modal-title">{{ title }}</h3>
        <p class="modal-message">{{ message }}</p>
        
        <div v-if="details" class="modal-details">
          <pre>{{ details }}</pre>
        </div>
        
        <div class="modal-actions">
          <button
            type="button"
            class="btn-cancel"
            @click="cancel"
            :disabled="loading"
          >
            {{ cancelText }}
          </button>
          <button
            type="button"
            class="btn-confirm"
            :class="type"
            @click="confirm"
            :disabled="loading"
          >
            <span v-if="loading" class="btn-spinner"></span>
            <span v-else>{{ confirmText }}</span>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
interface Props {
  title: string
  message: string
  details?: string
  confirmText?: string
  cancelText?: string
  confirmType?: 'default' | 'danger' | 'success'
}

interface Emits {
  (e: 'confirm'): void
  (e: 'cancel'): void
}

const props = withDefaults(defineProps<Props>(), {
  confirmText: 'Confirmar',
  cancelText: 'Cancelar',
  confirmType: 'default'
})

const emit = defineEmits<Emits>()
const loading = ref(false)

const type = computed(() => props.confirmType)

function confirm() {
  emit('confirm')
}

function cancel() {
  emit('cancel')
}

function close() {
  if (!loading.value) {
    emit('cancel')
  }
}
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
  z-index: 2000;
  padding: 20px;
  backdrop-filter: blur(4px);
  animation: fadeIn 0.2s ease-out;
}

.confirm-modal {
  background: white;
  width: 90%;
  max-width: 500px;
  border-radius: 20px;
  overflow: hidden;
  animation: slideUp 0.3s ease-out;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.modal-icon {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 3rem;
  margin: 40px auto 24px;
}

.modal-icon.default {
  background: #e3f2fd;
  color: #1976d2;
}

.modal-icon.danger {
  background: #ffebee;
  color: #d32f2f;
}

.modal-icon.success {
  background: #e8f5e9;
  color: #388e3c;
}

.modal-content {
  padding: 0 40px 40px;
  text-align: center;
}

.modal-title {
  margin: 0 0 16px 0;
  font-size: 1.5rem;
  color: #2d3436;
  font-weight: 600;
}

.modal-message {
  color: #636e72;
  line-height: 1.6;
  margin: 0 0 24px 0;
  font-size: 1.05rem;
}

.modal-details {
  background: #f8f9fa;
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 24px;
  max-height: 200px;
  overflow-y: auto;
  text-align: left;
  font-family: 'Courier New', monospace;
  font-size: 0.9rem;
  color: #2d3436;
}

.modal-details pre {
  margin: 0;
  white-space: pre-wrap;
  word-wrap: break-word;
}

.modal-actions {
  display: flex;
  gap: 16px;
  justify-content: center;
}

.btn-cancel,
.btn-confirm {
  padding: 12px 32px;
  border-radius: 10px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  border: 2px solid transparent;
  min-width: 120px;
}

.btn-cancel {
  background: white;
  color: #2d3436;
  border-color: #dfe6e9;
}

.btn-cancel:hover:not(:disabled) {
  background: #f8f9fa;
  border-color: #b2bec3;
}

.btn-confirm {
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.btn-confirm.default {
  background: #3498db;
}

.btn-confirm.danger {
  background: #e74c3c;
}

.btn-confirm.success {
  background: #2ecc71;
}

.btn-confirm:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
}

.btn-cancel:disabled,
.btn-confirm:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  transform: none !important;
}

.btn-spinner {
  width: 20px;
  height: 20px;
  border: 3px solid rgba(255, 255, 255, 0.3);
  border-top: 3px solid white;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

@media (max-width: 768px) {
  .confirm-modal {
    width: 95%;
  }
  
  .modal-content {
    padding: 0 24px 32px;
  }
  
  .modal-actions {
    flex-direction: column;
  }
  
  .btn-cancel,
  .btn-confirm {
    width: 100%;
  }
}
</style>
