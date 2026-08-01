<template>
  <div class="admin-broadcast">
    <!-- Header -->
    <div class="broadcast-header">
      <div class="header-content">
        <h2>📢 Notificación Masiva</h2>
        <p>Envía notificaciones a todos los usuarios o por rol específico</p>
      </div>
    </div>

    <!-- Formulario -->
    <div class="broadcast-form">
      <!-- Destino -->
      <div class="form-group">
        <label for="target-role">Destino</label>
        <select id="target-role" v-model="form.target_role">
          <option value="">🌍 Todos los usuarios</option>
          <option value="user">👤 Solo clientes</option>
          <option value="provider">🔧 Solo proveedores</option>
        </select>
        <span class="form-hint">
          {{ form.target_role ? `${userCountByRole(form.target_role)} usuarios recibirán esta notificación` : `${totalUsers} usuarios recibirán esta notificación` }}
        </span>
      </div>

      <!-- Título -->
      <div class="form-group">
        <label for="broadcast-title">Título *</label>
        <input
          id="broadcast-title"
          v-model="form.title"
          type="text"
          placeholder="Ej: Mantenimiento programado"
          maxlength="255"
          required
        />
        <span class="char-count">{{ form.title.length }}/255</span>
      </div>

      <!-- Mensaje -->
      <div class="form-group">
        <label for="broadcast-message">Mensaje *</label>
        <textarea
          id="broadcast-message"
          v-model="form.message"
          placeholder="Escribe el mensaje que se enviará a los usuarios..."
          maxlength="2000"
          rows="4"
          required
        ></textarea>
        <span class="char-count">{{ form.message.length }}/2000</span>
      </div>

      <!-- Tipo de notificación -->
      <div class="form-group">
        <label for="notification-type">Tipo</label>
        <select id="notification-type" v-model="form.notification_type">
          <option value="broadcast">📢 General</option>
          <option value="system_alert">⚠️ Alerta del sistema</option>
          <option value="promotion">🎉 Promoción</option>
          <option value="info">ℹ️ Informativo</option>
        </select>
      </div>

      <!-- Opciones adicionales -->
      <div class="form-options">
        <label class="checkbox-label">
          <input type="checkbox" v-model="form.send_email" />
          <span class="checkbox-text">📧 Enviar también por email</span>
        </label>
        <label class="checkbox-label">
          <input type="checkbox" v-model="form.send_sms" />
          <span class="checkbox-text">📱 Enviar también por SMS</span>
        </label>
      </div>

      <!-- Preview -->
      <div v-if="form.title || form.message" class="broadcast-preview">
        <h4>👁️ Vista previa</h4>
        <div class="preview-card">
          <div class="preview-header">
            <span class="preview-badge">{{ notificationTypeLabel }}</span>
            <span class="preview-time">Ahora</span>
          </div>
          <h5 class="preview-title">{{ form.title || 'Sin título' }}</h5>
          <p class="preview-message">{{ form.message || 'Sin mensaje' }}</p>
          <div class="preview-footer">
            <span>{{ form.target_role ? `Para: ${roleLabel(form.target_role)}` : 'Para: Todos' }}</span>
            <span v-if="form.send_email">📧</span>
            <span v-if="form.send_sms">📱</span>
          </div>
        </div>
      </div>

      <!-- Acciones -->
      <div class="form-actions">
        <button
          class="btn-clear"
          @click="clearForm"
          :disabled="sending"
        >
          🗑️ Limpiar
        </button>
        <button
          class="btn-send"
          @click="sendBroadcast"
          :disabled="sending || !isValid"
        >
          <span v-if="sending" class="send-spinner"></span>
          <span v-else>🚀 Enviar notificación</span>
        </button>
      </div>

      <!-- Mensaje de estado -->
      <div v-if="statusMessage" class="status-message" :class="statusType">
        {{ statusMessage }}
      </div>
    </div>

    <!-- Historial de broadcasts -->
    <div class="broadcast-history">
      <div class="history-header">
        <h3>📋 Historial de envíos</h3>
        <button class="btn-refresh-history" @click="loadHistory" :disabled="loadingHistory">
          🔄 Actualizar
        </button>
      </div>

      <div v-if="loadingHistory" class="history-loading">
        <div class="spinner"></div>
        <p>Cargando historial...</p>
      </div>

      <div v-else-if="history.length === 0" class="history-empty">
        <p>No hay envíos masivos recientes</p>
      </div>

      <div v-else class="history-list">
        <div
          v-for="item in history"
          :key="item.id"
          class="history-item"
        >
          <div class="history-icon">
            {{ getTypeIcon(item.notification_type) }}
          </div>
          <div class="history-content">
            <h5>{{ item.title }}</h5>
            <p>{{ item.message?.substring(0, 80) }}{{ item.message?.length > 80 ? '...' : '' }}</p>
            <span class="history-meta">
              {{ formatDate(item.created_at) }} • 
              {{ item.target_role ? roleLabel(item.target_role) : 'Todos' }}
              <span v-if="item.email_sent">• 📧</span>
              <span v-if="item.sms_sent">• 📱</span>
            </span>
          </div>
          <div class="history-status" :class="item.status">
            {{ item.status === 'sent' ? '✅' : '❌' }}
          </div>
        </div>
      </div>
    </div>

    <!-- Toast -->
    <div v-if="toast.show" class="toast" :class="toast.type">
      {{ toast.message }}
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import api from '@/axios'
import { useAuthStore } from '@/stores/authStore'

const authStore = useAuthStore()

// Formulario
const form = reactive({
  target_role: '',
  title: '',
  message: '',
  notification_type: 'broadcast',
  send_email: false,
  send_sms: false
})

const sending = ref(false)
const statusMessage = ref('')
const statusType = ref('success')

// Historial
const history = ref([])
const loadingHistory = ref(false)

// Conteo de usuarios
const totalUsers = ref(0)
const userCounts = reactive({
  user: 0,
  provider: 0
})

// Toast
const toast = reactive({
  show: false,
  message: '',
  type: 'success'
})

// Validación
const isValid = computed(() => {
  return form.title.trim().length > 0 && form.message.trim().length > 0
})

// Labels
const notificationTypeLabel = computed(() => {
  const labels = {
    broadcast: '📢 General',
    system_alert: '⚠️ Alerta',
    promotion: '🎉 Promoción',
    info: 'ℹ️ Info'
  }
  return labels[form.notification_type] || '📢 General'
})

const roleLabel = (role) => {
  const labels = { user: 'Clientes', provider: 'Proveedores' }
  return labels[role] || role
}

const userCountByRole = (role) => {
  return userCounts[role] || 0
}

const getTypeIcon = (type) => {
  const icons = {
    broadcast: '📢',
    system_alert: '⚠️',
    promotion: '🎉',
    info: 'ℹ️'
  }
  return icons[type] || '📢'
}

const formatDate = (dateStr) => {
  if (!dateStr) return ''
  const date = new Date(dateStr)
  return date.toLocaleDateString('es-ES', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const showToast = (message, type = 'success') => {
  toast.show = true
  toast.message = message
  toast.type = type
  setTimeout(() => { toast.show = false }, 4000)
}

const clearForm = () => {
  form.target_role = ''
  form.title = ''
  form.message = ''
  form.notification_type = 'broadcast'
  form.send_email = false
  form.send_sms = false
  statusMessage.value = ''
}

const loadUserCounts = async () => {
  try {
    const { data } = await api.get('/admin/stats')
    totalUsers.value = data.totalUsers || 0
    userCounts.user = data.totalClients || 0
    userCounts.provider = data.activeProviders || 0
  } catch (err) {
    console.error('Error cargando conteo de usuarios:', err)
  }
}

const loadHistory = async () => {
  loadingHistory.value = true
  try {
    const { data } = await api.get('/admin/broadcast-history')
    history.value = Array.isArray(data) ? data : (data?.data || [])
  } catch (err) {
    console.error('Error cargando historial:', err)
    history.value = []
  } finally {
    loadingHistory.value = false
  }
}

const sendBroadcast = async () => {
  if (!isValid.value) return

  // Confirmación
  const target = form.target_role ? roleLabel(form.target_role) : 'Todos los usuarios'
  const extras = []
  if (form.send_email) extras.push('email')
  if (form.send_sms) extras.push('SMS')
  const extraText = extras.length > 0 ? ` (con ${extras.join(' y ')})` : ''

  if (!confirm(`¿Enviar esta notificación a "${target}"${extraText}?\n\nTítulo: ${form.title}\nMensaje: ${form.message}`)) {
    return
  }

  sending.value = true
  statusMessage.value = ''

  try {
    const { data } = await api.post('/notifications/broadcast', {
      title: form.title,
      message: form.message,
      notification_type: form.notification_type,
      target_role: form.target_role || null,
      send_email: form.send_email,
      send_sms: form.send_sms
    })

    statusMessage.value = `✅ Notificación enviada a ${target}`
    statusType.value = 'success'
    
    if (data.email) {
      statusMessage.value += ` • ${data.email.sent} emails enviados`
    }
    if (data.sms) {
      statusMessage.value += ` • ${data.sms.sent} SMS enviados`
    }

    showToast('Notificación enviada exitosamente', 'success')
    loadHistory()
  } catch (err) {
    const errorMsg = err.response?.data?.error || 'Error al enviar la notificación'
    statusMessage.value = `❌ ${errorMsg}`
    statusType.value = 'error'
    showToast(errorMsg, 'error')
  } finally {
    sending.value = false
  }
}

onMounted(() => {
  loadUserCounts()
  loadHistory()
})
</script>

<style scoped>
.admin-broadcast {
  max-width: 800px;
  margin: 0 auto;
  padding: 24px;
}

/* Header */
.broadcast-header {
  margin-bottom: 32px;
}

.broadcast-header h2 {
  font-size: 1.8rem;
  color: #2d3436;
  margin-bottom: 8px;
}

.broadcast-header p {
  color: #636e72;
  font-size: 1rem;
}

/* Form */
.broadcast-form {
  background: white;
  border-radius: 20px;
  padding: 32px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
  margin-bottom: 32px;
}

.form-group {
  margin-bottom: 24px;
  position: relative;
}

.form-group label {
  display: block;
  font-weight: 600;
  color: #2d3436;
  margin-bottom: 8px;
  font-size: 0.95rem;
}

.form-group input,
.form-group textarea,
.form-group select {
  width: 100%;
  padding: 12px 16px;
  border: 2px solid #dfe6e9;
  border-radius: 10px;
  font-size: 1rem;
  transition: all 0.3s;
  background: white;
  font-family: inherit;
}

.form-group input:focus,
.form-group textarea:focus,
.form-group select:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.form-group textarea {
  resize: vertical;
  min-height: 100px;
}

.form-hint {
  display: block;
  color: #636e72;
  font-size: 0.85rem;
  margin-top: 6px;
}

.char-count {
  position: absolute;
  right: 12px;
  bottom: 12px;
  font-size: 0.8rem;
  color: #b2bec3;
  background: white;
  padding: 2px 8px;
  border-radius: 4px;
}

/* Options */
.form-options {
  display: flex;
  gap: 24px;
  margin-bottom: 24px;
  flex-wrap: wrap;
}

.checkbox-label {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  user-select: none;
}

.checkbox-label input[type="checkbox"] {
  width: 18px;
  height: 18px;
  cursor: pointer;
  accent-color: #667eea;
}

.checkbox-text {
  font-size: 0.95rem;
  color: #2d3436;
}

/* Preview */
.broadcast-preview {
  background: #f8f9fa;
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 24px;
}

.broadcast-preview h4 {
  color: #636e72;
  margin-bottom: 12px;
  font-size: 0.9rem;
}

.preview-card {
  background: white;
  border-radius: 10px;
  padding: 16px;
  border: 1px solid #dfe6e9;
}

.preview-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.preview-badge {
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
  padding: 3px 10px;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 600;
}

.preview-time {
  color: #b2bec3;
  font-size: 0.8rem;
}

.preview-title {
  font-size: 1.1rem;
  color: #2d3436;
  margin-bottom: 6px;
}

.preview-message {
  color: #636e72;
  font-size: 0.9rem;
  margin-bottom: 8px;
}

.preview-footer {
  display: flex;
  gap: 12px;
  color: #b2bec3;
  font-size: 0.8rem;
}

/* Actions */
.form-actions {
  display: flex;
  gap: 16px;
  justify-content: flex-end;
}

.btn-clear {
  background: #dfe6e9;
  color: #2d3436;
  border: none;
  padding: 12px 24px;
  border-radius: 10px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s;
}

.btn-clear:hover:not(:disabled) {
  background: #b2bec3;
}

.btn-send {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 12px 32px;
  border-radius: 10px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s;
  display: flex;
  align-items: center;
  gap: 8px;
  min-width: 200px;
  justify-content: center;
}

.btn-send:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
}

.btn-send:disabled,
.btn-clear:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.send-spinner {
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

/* Status Message */
.status-message {
  margin-top: 16px;
  padding: 12px 16px;
  border-radius: 10px;
  font-weight: 500;
  text-align: center;
}

.status-message.success {
  background: rgba(0, 184, 148, 0.1);
  color: #00b894;
  border: 1px solid rgba(0, 184, 148, 0.2);
}

.status-message.error {
  background: rgba(255, 118, 117, 0.1);
  color: #ff7675;
  border: 1px solid rgba(255, 118, 117, 0.2);
}

/* History */
.broadcast-history {
  background: white;
  border-radius: 20px;
  padding: 32px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
}

.history-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.history-header h3 {
  font-size: 1.3rem;
  color: #2d3436;
}

.btn-refresh-history {
  background: #f8f9fa;
  color: #636e72;
  border: 1px solid #dfe6e9;
  padding: 8px 16px;
  border-radius: 8px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: all 0.3s;
}

.btn-refresh-history:hover:not(:disabled) {
  background: #f1f2f6;
}

.history-loading {
  text-align: center;
  padding: 40px;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 3px solid rgba(102, 126, 234, 0.2);
  border-top: 3px solid #667eea;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 16px;
}

.history-empty {
  text-align: center;
  padding: 40px;
  color: #636e72;
}

.history-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.history-item {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px;
  background: #f8f9fa;
  border-radius: 12px;
  transition: all 0.3s;
}

.history-item:hover {
  background: #f1f2f6;
}

.history-icon {
  font-size: 1.5rem;
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.history-content {
  flex: 1;
  min-width: 0;
}

.history-content h5 {
  color: #2d3436;
  font-size: 0.95rem;
  margin-bottom: 4px;
}

.history-content p {
  color: #636e72;
  font-size: 0.85rem;
  margin-bottom: 4px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.history-meta {
  color: #b2bec3;
  font-size: 0.75rem;
}

.history-status {
  font-size: 1.2rem;
  flex-shrink: 0;
}

/* Toast */
.toast {
  position: fixed;
  bottom: 24px;
  right: 24px;
  padding: 16px 24px;
  border-radius: 12px;
  color: white;
  font-weight: 600;
  z-index: 1001;
  animation: slideInRight 0.3s ease-out;
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.2);
}

.toast.success {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
}

.toast.error {
  background: linear-gradient(135deg, #ff7675 0%, #d63031 100%);
}

@keyframes slideInRight {
  from { transform: translateX(100%); opacity: 0; }
  to { transform: translateX(0); opacity: 1; }
}

/* Responsive */
@media (max-width: 768px) {
  .admin-broadcast {
    padding: 16px;
  }

  .broadcast-form {
    padding: 20px;
  }

  .form-actions {
    flex-direction: column;
  }

  .btn-send {
    width: 100%;
  }

  .form-options {
    flex-direction: column;
    gap: 12px;
  }
}
</style>
