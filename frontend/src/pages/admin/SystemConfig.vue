<template>
  <div class="system-config-container">
    <!-- Header -->
    <div class="page-header">
      <h1>
        <span class="icon">⚙️</span>
        Configuración del Sistema
      </h1>
      <p>Administra la configuración global de la plataforma</p>
    </div>

    <!-- Tabs -->
    <div class="config-tabs">
      <button 
        class="tab-btn" 
        :class="{ active: activeTab === 'general' }"
        @click="activeTab = 'general'"
      >
        <span class="tab-icon">🏠</span>
        General
      </button>
      <button 
        class="tab-btn" 
        :class="{ active: activeTab === 'email' }"
        @click="activeTab = 'email'"
      >
        <span class="tab-icon">📧</span>
        Email (SMTP)
      </button>
      <button 
        class="tab-btn" 
        :class="{ active: activeTab === 'sms' }"
        @click="activeTab = 'sms'"
      >
        <span class="tab-icon">📱</span>
        SMS (Twilio)
      </button>
      <button 
        class="tab-btn" 
        :class="{ active: activeTab === 'security' }"
        @click="activeTab = 'security'"
      >
        <span class="tab-icon">🔒</span>
        Seguridad
      </button>
    </div>

    <!-- Contenido según tab -->
    <div class="tab-content">
      <!-- GENERAL -->
      <div v-if="activeTab === 'general'" class="config-section">
        <form @submit.prevent="saveGeneralConfig">
          <div class="form-grid">
            <div class="form-group">
              <label>Nombre del Sistema</label>
              <input 
                v-model="form.system_name" 
                type="text" 
                class="form-input"
                required
              />
            </div>

            <div class="form-group">
              <label>Host del Sistema</label>
              <input 
                v-model="form.system_host" 
                type="text" 
                class="form-input"
                placeholder="https://tudominio.com"
              />
            </div>

            <div class="form-group">
              <label>Versión</label>
              <input 
                v-model="form.system_version" 
                type="text" 
                class="form-input"
                placeholder="1.0.0"
              />
            </div>

            <div class="form-group">
              <label>Idioma por defecto</label>
              <select v-model="form.default_language" class="form-input">
                <option value="es">Español</option>
                <option value="en">English</option>
                <option value="pt">Português</option>
              </select>
            </div>

            <div class="form-group">
              <label>Zona Horaria</label>
              <select v-model="form.timezone" class="form-input">
                <option value="America/Caracas">Caracas (GMT-4)</option>
                <option value="America/Bogota">Bogotá (GMT-5)</option>
                <option value="America/Mexico_City">México (GMT-6)</option>
                <option value="America/Argentina/Buenos_Aires">Buenos Aires (GMT-3)</option>
                <option value="UTC">UTC</option>
              </select>
            </div>

            <div class="form-group">
              <label>Moneda</label>
              <select v-model="form.currency" class="form-input">
                <option value="USD">USD - Dólar</option>
                <option value="EUR">EUR - Euro</option>
                <option value="COP">COP - Peso Colombiano</option>
                <option value="MXN">MXN - Peso Mexicano</option>
                <option value="ARS">ARS - Peso Argentino</option>
                <option value="PEN">PEN - Sol Peruano</option>
              </select>
            </div>

            <div class="form-group">
              <label>Email de Soporte</label>
              <input 
                v-model="form.support_email" 
                type="email" 
                class="form-input"
              />
            </div>

            <div class="form-group">
              <label>Teléfono de Soporte</label>
              <input 
                v-model="form.support_phone" 
                type="text" 
                class="form-input"
                placeholder="+584241234567"
              />
            </div>

            <div class="form-group full-width">
              <label>Nombre de la Empresa</label>
              <input 
                v-model="form.company_name" 
                type="text" 
                class="form-input"
              />
            </div>

            <div class="form-group full-width">
              <label>Dirección de la Empresa</label>
              <textarea 
                v-model="form.company_address" 
                class="form-input" 
                rows="3"
              ></textarea>
            </div>

            <div class="form-group">
              <label>Items por página</label>
              <input 
                v-model="form.items_per_page" 
                type="number" 
                class="form-input"
                min="5"
                max="100"
              />
            </div>

            <div class="form-group">
              <label>Color del tema</label>
              <input 
                v-model="form.theme_color" 
                type="color" 
                class="form-input color-picker"
              />
            </div>

            <div class="form-group checkbox-group">
              <label class="checkbox-label">
                <input 
                  v-model="form.system_active" 
                  type="checkbox"
                />
                <span>Sistema activo</span>
              </label>
            </div>

            <div class="form-group checkbox-group">
              <label class="checkbox-label">
                <input 
                  v-model="form.maintenance_mode" 
                  type="checkbox"
                />
                <span>Modo mantenimiento</span>
              </label>
            </div>

            <div class="form-group checkbox-group">
              <label class="checkbox-label">
                <input 
                  v-model="form.allow_user_registration" 
                  type="checkbox"
                />
                <span>Permitir registro de usuarios</span>
              </label>
            </div>
          </div>

          <div class="form-actions">
            <button type="button" class="btn-secondary" @click="resetForm">
              Cancelar
            </button>
            <button type="submit" class="btn-primary" :disabled="saving">
              <span v-if="saving" class="loading-spinner"></span>
              <span v-else>Guardar cambios</span>
            </button>
          </div>
        </form>
      </div>

      <!-- EMAIL CONFIG -->
      <div v-if="activeTab === 'email'" class="config-section">
        <div class="section-header">
          <h2>Configuración de Email (SMTP)</h2>
          <div class="status-badge" :class="{ 'status-active': emailConfigured }">
            {{ emailConfigured ? '✅ Configurado' : '❌ No configurado' }}
          </div>
        </div>

        <form @submit.prevent="saveEmailConfig">
          <div class="form-grid">
            <div class="form-group">
              <label>Host SMTP</label>
              <input 
                v-model="emailConfig.host" 
                type="text" 
                class="form-input"
                placeholder="smtp.gmail.com"
                required
              />
            </div>

            <div class="form-group">
              <label>Puerto</label>
              <input 
                v-model="emailConfig.port" 
                type="number" 
                class="form-input"
                placeholder="587"
                required
              />
            </div>

            <div class="form-group">
              <label>Encriptación</label>
              <select v-model="emailConfig.encryption" class="form-input">
                <option value="tls">TLS</option>
                <option value="ssl">SSL</option>
                <option value="">Sin encriptación</option>
              </select>
            </div>

            <div class="form-group">
              <label>Usuario</label>
              <input 
                v-model="emailConfig.username" 
                type="text" 
                class="form-input"
                placeholder="tu-email@gmail.com"
                required
              />
            </div>

            <div class="form-group">
              <label>Contraseña</label>
              <input 
                v-model="emailConfig.password" 
                :type="showPassword ? 'text' : 'password'" 
                class="form-input"
                placeholder="••••••••"
              />
              <button 
                type="button" 
                class="btn-toggle-password"
                @click="showPassword = !showPassword"
              >
                {{ showPassword ? 'Ocultar' : 'Mostrar' }}
              </button>
            </div>

            <div class="form-group">
              <label>Email remitente</label>
              <input 
                v-model="emailConfig.from" 
                type="email" 
                class="form-input"
                placeholder="notificaciones@tudominio.com"
                required
              />
            </div>

            <div class="form-group">
              <label>Nombre remitente</label>
              <input 
                v-model="emailConfig.from_name" 
                type="text" 
                class="form-input"
                placeholder="Mi Aplicación"
                required
              />
            </div>
          </div>

          <div class="form-actions">
            <button type="button" class="btn-secondary" @click="testEmailConfig">
              📧 Enviar prueba
            </button>
            <button type="submit" class="btn-primary" :disabled="saving">
              <span v-if="saving" class="loading-spinner"></span>
              <span v-else>Guardar configuración</span>
            </button>
          </div>
        </form>
      </div>

      <!-- SMS CONFIG -->
      <div v-if="activeTab === 'sms'" class="config-section">
        <div class="section-header">
          <h2>Configuración de SMS (Twilio)</h2>
          <div class="status-badge" :class="{ 'status-active': smsConfigured }">
            {{ smsConfigured ? '✅ Configurado' : '❌ No configurado' }}
          </div>
        </div>

        <form @submit.prevent="saveSMSConfig">
          <div class="form-grid">
            <div class="form-group">
              <label>Twilio Account SID</label>
              <input 
                v-model="smsConfig.sid" 
                type="text" 
                class="form-input"
                placeholder="ACxxxxxxxxxxxxxx"
                required
              />
            </div>

            <div class="form-group">
              <label>Twilio Auth Token</label>
              <input 
                v-model="smsConfig.token" 
                :type="showSMSToken ? 'text' : 'password'" 
                class="form-input"
                placeholder="your-auth-token"
                required
              />
              <button 
                type="button" 
                class="btn-toggle-password"
                @click="showSMSToken = !showSMSToken"
              >
                {{ showSMSToken ? 'Ocultar' : 'Mostrar' }}
              </button>
            </div>

            <div class="form-group">
              <label>Número Twilio</label>
              <input 
                v-model="smsConfig.phone" 
                type="text" 
                class="form-input"
                placeholder="+1234567890"
                required
              />
              <small class="form-hint">Formato internacional: +584241234567</small>
            </div>
          </div>

          <div class="form-actions">
            <button type="button" class="btn-secondary" @click="testSMSConfig">
              📱 Enviar prueba
            </button>
            <button type="submit" class="btn-primary" :disabled="saving">
              <span v-if="saving" class="loading-spinner"></span>
              <span v-else>Guardar configuración</span>
            </button>
          </div>
        </form>
      </div>

      <!-- SECURITY CONFIG -->
      <div v-if="activeTab === 'security'" class="config-section">
        <form @submit.prevent="saveSecurityConfig">
          <div class="form-grid">
            <div class="form-group">
              <label>Intentos máximos de login</label>
              <input 
                v-model="securityConfig.max_login_attempts" 
                type="number" 
                class="form-input"
                min="1"
                max="10"
              />
            </div>

            <div class="form-group">
              <label>Expiración de contraseña (días)</label>
              <input 
                v-model="securityConfig.password_expiration_days" 
                type="number" 
                class="form-input"
                min="0"
                max="365"
              />
              <small class="form-hint">0 = nunca expira</small>
            </div>

            <div class="form-group">
              <label>Tiempo de sesión (minutos)</label>
              <input 
                v-model="securityConfig.session_timeout_minutes" 
                type="number" 
                class="form-input"
                min="5"
                max="1440"
              />
            </div>
          </div>

          <div class="form-actions">
            <button type="submit" class="btn-primary" :disabled="saving">
              <span v-if="saving" class="loading-spinner"></span>
              <span v-else>Guardar configuración</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, reactive, onMounted } from 'vue'
import api from '@/axios'
import Swal from 'sweetalert2'
import { useAuthStore } from '@/stores/authStore'

export default {
  name: 'SystemConfig',
  setup() {
    const authStore = useAuthStore()
    const saving = ref(false)
    const activeTab = ref('general')
    const showPassword = ref(false)
    const showSMSToken = ref(false)
    const emailConfigured = ref(false)
    const smsConfigured = ref(false)

    // Formulario general
    const form = reactive({
      id: null,
      system_name: '',
      system_host: '',
      system_active: true,
      system_version: '1.0.0',
      system_logo: '',
      system_favicon: '',
      default_language: 'es',
      timezone: 'America/Caracas',
      currency: 'USD',
      support_email: '',
      support_phone: '',
      company_name: '',
      company_address: '',
      maintenance_mode: false,
      max_login_attempts: 5,
      password_expiration_days: 90,
      session_timeout_minutes: 30,
      items_per_page: 20,
      theme_color: '#409EFF',
      allow_user_registration: true
    })

    // Configuración de email
    const emailConfig = reactive({
      host: 'smtp.gmail.com',
      port: 587,
      encryption: 'tls',
      username: '',
      password: '',
      from: 'notificaciones@tapclic.com',
      from_name: 'TapClic'
    })

    // Configuración de SMS
    const smsConfig = reactive({
      sid: '',
      token: '',
      phone: ''
    })

    // Configuración de seguridad
    const securityConfig = reactive({
      max_login_attempts: 5,
      password_expiration_days: 90,
      session_timeout_minutes: 30
    })

    const fetchConfig = async () => {
      try {
        const { data } = await api.get('/system/config', {
          headers: { Authorization: `Bearer ${authStore.token}` }
        })

        if (data.config) {
          const config = data.config
          form.id = config.id
          form.system_name = config.system_name || ''
          form.system_host = config.system_host || ''
          form.system_active = config.system_active == 1
          form.system_version = config.system_version || '1.0.0'
          form.default_language = config.default_language || 'es'
          form.timezone = config.timezone || 'America/Caracas'
          form.currency = config.currency || 'USD'
          form.support_email = config.support_email || ''
          form.support_phone = config.support_phone || ''
          form.company_name = config.company_name || ''
          form.company_address = config.company_address || ''
          form.maintenance_mode = config.maintenance_mode == 1
          form.max_login_attempts = config.max_login_attempts || 5
          form.password_expiration_days = config.password_expiration_days || 90
          form.session_timeout_minutes = config.session_timeout_minutes || 30
          form.items_per_page = config.items_per_page || 20
          form.theme_color = config.theme_color || '#409EFF'
          form.allow_user_registration = config.allow_user_registration == 1

          // Email config
          emailConfig.host = config.mail_host || 'smtp.gmail.com'
          emailConfig.port = config.mail_port || 587
          emailConfig.encryption = config.mail_encryption || 'tls'
          emailConfig.username = config.mail_username || ''
          emailConfig.from = config.mail_from || 'notificaciones@tapclic.com'
          emailConfig.from_name = config.mail_from_name || 'TapClic'
          
          // SMS config
          smsConfig.sid = config.twilio_sid || ''
          smsConfig.phone = config.twilio_phone || ''

          emailConfigured.value = !!(config.mail_username && config.mail_password)
          smsConfigured.value = !!(config.twilio_sid && config.twilio_token && config.twilio_phone)
        }
      } catch (err) {
        console.error('Error cargando configuración:', err)
      }
    }

    const saveGeneralConfig = async () => {
      saving.value = true
      try {
        await api.post('/system/config', form, {
          headers: { Authorization: `Bearer ${authStore.token}` }
        })

        Swal.fire({
          icon: 'success',
          title: 'Configuración guardada',
          text: 'Los cambios se han aplicado correctamente',
          timer: 2000
        })
      } catch (err) {
        Swal.fire({
          icon: 'error',
          title: 'Error',
          text: err.response?.data?.error || 'Error al guardar configuración'
        })
      } finally {
        saving.value = false
      }
    }

    const saveEmailConfig = async () => {
      saving.value = true
      try {
        await api.post('/system/config', {
          mail_host: emailConfig.host,
          mail_port: emailConfig.port,
          mail_encryption: emailConfig.encryption,
          mail_username: emailConfig.username,
          mail_password: emailConfig.password,
          mail_from: emailConfig.from,
          mail_from_name: emailConfig.from_name
        }, {
          headers: { Authorization: `Bearer ${authStore.token}` }
        })

        Swal.fire({
          icon: 'success',
          title: 'Configuración de email guardada',
          timer: 2000
        })

        await fetchConfig()
      } catch (err) {
        Swal.fire({
          icon: 'error',
          title: 'Error',
          text: err.response?.data?.error || 'Error al guardar configuración'
        })
      } finally {
        saving.value = false
      }
    }

    const saveSMSConfig = async () => {
      saving.value = true
      try {
        await api.post('/system/config', {
          twilio_sid: smsConfig.sid,
          twilio_token: smsConfig.token,
          twilio_phone: smsConfig.phone
        }, {
          headers: { Authorization: `Bearer ${authStore.token}` }
        })

        Swal.fire({
          icon: 'success',
          title: 'Configuración de SMS guardada',
          timer: 2000
        })

        await fetchConfig()
      } catch (err) {
        Swal.fire({
          icon: 'error',
          title: 'Error',
          text: err.response?.data?.error || 'Error al guardar configuración'
        })
      } finally {
        saving.value = false
      }
    }

    const saveSecurityConfig = async () => {
      saving.value = true
      try {
        await api.post('/system/config', {
          max_login_attempts: securityConfig.max_login_attempts,
          password_expiration_days: securityConfig.password_expiration_days,
          session_timeout_minutes: securityConfig.session_timeout_minutes
        }, {
          headers: { Authorization: `Bearer ${authStore.token}` }
        })

        Swal.fire({
          icon: 'success',
          title: 'Configuración de seguridad guardada',
          timer: 2000
        })
      } catch (err) {
        Swal.fire({
          icon: 'error',
          title: 'Error',
          text: err.response?.data?.error || 'Error al guardar configuración'
        })
      } finally {
        saving.value = false
      }
    }

    const testEmailConfig = async () => {
      const { value: email } = await Swal.fire({
        title: 'Enviar email de prueba',
        input: 'email',
        inputLabel: 'Correo electrónico',
        inputPlaceholder: 'tu@email.com',
        inputValue: form.support_email || authStore.user?.email,
        showCancelButton: true
      })

      if (email) {
        try {
          await api.post('/system/test-email', { test_email: email }, {
            headers: { Authorization: `Bearer ${authStore.token}` }
          })

          Swal.fire({
            icon: 'success',
            title: 'Email enviado',
            text: 'Revisa tu bandeja de entrada'
          })
        } catch (err) {
          Swal.fire({
            icon: 'error',
            title: 'Error',
            text: err.response?.data?.error || 'Error al enviar email de prueba'
          })
        }
      }
    }

    const testSMSConfig = async () => {
      const { value: phone } = await Swal.fire({
        title: 'Enviar SMS de prueba',
        input: 'text',
        inputLabel: 'Número de teléfono',
        inputPlaceholder: '+584241234567',
        inputValue: form.support_phone,
        showCancelButton: true
      })

      if (phone) {
        try {
          await api.post('/system/test-sms', { test_phone: phone }, {
            headers: { Authorization: `Bearer ${authStore.token}` }
          })

          Swal.fire({
            icon: 'success',
            title: 'SMS enviado',
            text: 'Revisa tu teléfono'
          })
        } catch (err) {
          Swal.fire({
            icon: 'error',
            title: 'Error',
            text: err.response?.data?.error || 'Error al enviar SMS de prueba'
          })
        }
      }
    }

    const resetForm = () => {
      fetchConfig()
    }

    onMounted(fetchConfig)

    return {
      activeTab,
      saving,
      showPassword,
      showSMSToken,
      form,
      emailConfig,
      smsConfig,
      securityConfig,
      emailConfigured,
      smsConfigured,
      saveGeneralConfig,
      saveEmailConfig,
      saveSMSConfig,
      saveSecurityConfig,
      testEmailConfig,
      testSMSConfig,
      resetForm
    }
  }
}
</script>

<style scoped>
.system-config-container {
  padding: 24px;
  max-width: 1200px;
  margin: 0 auto;
}

.page-header {
  margin-bottom: 32px;
}

.page-header h1 {
  font-size: 28px;
  color: #333;
  margin-bottom: 8px;
  display: flex;
  align-items: center;
  gap: 12px;
}

.page-header p {
  color: #666;
  font-size: 16px;
}

.config-tabs {
  display: flex;
  gap: 8px;
  margin-bottom: 24px;
  border-bottom: 2px solid #e0e0e0;
  padding-bottom: 8px;
}

.tab-btn {
  padding: 10px 20px;
  background: none;
  border: none;
  border-radius: 8px 8px 0 0;
  font-size: 16px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  color: #666;
  transition: all 0.3s;
}

.tab-btn:hover {
  background: #f5f5f5;
  color: #333;
}

.tab-btn.active {
  background: #4F46E5;
  color: white;
}

.tab-icon {
  font-size: 20px;
}

.tab-content {
  background: white;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.config-section {
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.section-header h2 {
  font-size: 20px;
  color: #333;
  margin: 0;
}

.status-badge {
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 500;
  background: #ffebee;
  color: #c62828;
}

.status-badge.status-active {
  background: #e8f5e9;
  color: #2e7d32;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.form-group.full-width {
  grid-column: span 2;
}

.form-group label {
  font-weight: 500;
  color: #444;
  font-size: 14px;
}

.form-input {
  padding: 10px 12px;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 14px;
  transition: all 0.3s;
}

.form-input:focus {
  outline: none;
  border-color: #4F46E5;
  box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
}

.color-picker {
  height: 42px;
  padding: 4px;
}

.checkbox-group {
  display: flex;
  flex-direction: row;
  align-items: center;
}

.checkbox-label {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
}

.checkbox-label input[type="checkbox"] {
  width: 18px;
  height: 18px;
  cursor: pointer;
}

.form-hint {
  font-size: 12px;
  color: #999;
  margin-top: 4px;
}

.btn-toggle-password {
  position: absolute;
  right: 10px;
  top: 50%;
  transform: translateY(-50%);
  background: none;
  border: none;
  color: #666;
  cursor: pointer;
  font-size: 12px;
}

.form-actions {
  margin-top: 32px;
  display: flex;
  gap: 12px;
  justify-content: flex-end;
}

.btn-primary, .btn-secondary {
  padding: 12px 24px;
  border: none;
  border-radius: 6px;
  font-size: 16px;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s;
}

.btn-primary {
  background: #4F46E5;
  color: white;
}

.btn-primary:hover:not(:disabled) {
  background: #4338CA;
}

.btn-secondary {
  background: #f5f5f5;
  color: #333;
  border: 1px solid #ddd;
}

.btn-secondary:hover:not(:disabled) {
  background: #e0e0e0;
}

.btn-primary:disabled, .btn-secondary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.loading-spinner {
  display: inline-block;
  width: 16px;
  height: 16px;
  border: 2px solid rgba(255,255,255,0.3);
  border-radius: 50%;
  border-top-color: white;
  animation: spin 1s ease-in-out infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

@media (max-width: 768px) {
  .form-grid {
    grid-template-columns: 1fr;
  }
  
  .form-group.full-width {
    grid-column: span 1;
  }
  
  .config-tabs {
    flex-wrap: wrap;
  }
  
  .tab-btn {
    flex: 1;
    min-width: 120px;
    justify-content: center;
  }
}
</style>
