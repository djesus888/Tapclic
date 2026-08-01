<template>
  <div class="admin-broadcast">
    <div class="broadcast-header">
      <h2>📢 Notificación Masiva</h2>
      <p>Envía notificaciones a todos los usuarios o por rol</p>
    </div>
    <div class="broadcast-form">
      <div class="form-group">
        <label>Destino</label>
        <select v-model="form.target_role">
          <option value="">🌍 Todos los usuarios</option>
          <option value="user">👤 Clientes</option>
          <option value="provider">🔧 Proveedores</option>
        </select>
      </div>
      <div class="form-group">
        <label>Título *</label>
        <input v-model="form.title" maxlength="255" placeholder="Ej: Mantenimiento programado" />
        <span class="char-count">{{ form.title.length }}/255</span>
      </div>
      <div class="form-group">
        <label>Mensaje *</label>
        <textarea v-model="form.message" maxlength="2000" rows="4" placeholder="Escribe el mensaje..."></textarea>
        <span class="char-count">{{ form.message.length }}/2000</span>
      </div>
      <div class="form-group">
        <label>Tipo</label>
        <select v-model="form.notification_type">
          <option value="broadcast">📢 General</option>
          <option value="system_alert">⚠️ Alerta</option>
          <option value="promotion">🎉 Promoción</option>
          <option value="info">ℹ️ Informativo</option>
        </select>
      </div>
      <div class="form-options">
        <label class="checkbox-label"><input type="checkbox" v-model="form.send_email" />📧 Enviar también por email</label>
        <label class="checkbox-label"><input type="checkbox" v-model="form.send_sms" />📱 Enviar también por SMS</label>
      </div>
      <div class="form-actions">
        <button class="btn-send" @click="sendBroadcast" :disabled="sending || !form.title || !form.message">
          {{ sending ? '⏳ Enviando...' : '🚀 Enviar notificación' }}
        </button>
      </div>
      <div v-if="statusMessage" class="status-message" :class="statusType">{{ statusMessage }}</div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import api from '@/axios'

const form = reactive({ target_role: '', title: '', message: '', notification_type: 'broadcast', send_email: false, send_sms: false })
const sending = ref(false)
const statusMessage = ref('')
const statusType = ref('success')

const sendBroadcast = async () => {
  if (!form.title || !form.message) return
  const target = form.target_role ? (form.target_role === 'user' ? 'Clientes' : 'Proveedores') : 'Todos los usuarios'
  if (!confirm(`¿Enviar a "${target}"?\n\n${form.title}\n${form.message}`)) return
  sending.value = true
  statusMessage.value = ''
  try {
    const { data } = await api.post('/notifications/broadcast', {
      title: form.title, message: form.message,
      notification_type: form.notification_type, target_role: form.target_role || null,
      send_email: form.send_email, send_sms: form.send_sms
    })
    statusMessage.value = `✅ Enviado a ${target}`
    statusType.value = 'success'
  } catch (err) {
    statusMessage.value = `❌ ${err.response?.data?.error || 'Error al enviar'}`
    statusType.value = 'error'
  } finally { sending.value = false }
}
</script>

<style scoped>
.admin-broadcast { max-width: 800px; margin: 32px auto; padding: 24px; background: white; border-radius: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.08); }
.broadcast-header h2 { font-size: 1.5rem; color: #2d3436; margin-bottom: 4px; }
.broadcast-header p { color: #636e72; font-size: 0.9rem; margin-bottom: 20px; }
.form-group { margin-bottom: 16px; }
.form-group label { display: block; font-weight: 600; color: #2d3436; margin-bottom: 6px; font-size: 0.9rem; }
.form-group input, .form-group textarea, .form-group select { width: 100%; padding: 10px 14px; border: 2px solid #dfe6e9; border-radius: 8px; font-size: 0.95rem; font-family: inherit; }
.form-group input:focus, .form-group textarea:focus, .form-group select:focus { outline: none; border-color: #667eea; }
.char-count { font-size: 0.75rem; color: #b2bec3; float: right; }
.form-options { display: flex; gap: 20px; margin: 16px 0; }
.checkbox-label { display: flex; align-items: center; gap: 6px; cursor: pointer; font-size: 0.9rem; }
.form-actions { text-align: right; }
.btn-send { background: linear-gradient(135deg, #667eea, #764ba2); color: white; border: none; padding: 12px 28px; border-radius: 10px; cursor: pointer; font-weight: 600; font-size: 1rem; }
.btn-send:hover:not(:disabled) { transform: translateY(-2px); }
.btn-send:disabled { opacity: 0.6; cursor: not-allowed; }
.status-message { margin-top: 16px; padding: 12px; border-radius: 8px; text-align: center; font-weight: 500; }
.status-message.success { background: rgba(0,184,148,0.1); color: #00b894; }
.status-message.error { background: rgba(255,118,117,0.1); color: #ff7675; }
</style>
