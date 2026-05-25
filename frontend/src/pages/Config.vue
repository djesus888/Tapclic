<template>
  <div class="config-container">
    <!-- Header -->
    <div class="header-section">
      <div class="header-content">
        <h1><span class="icon">⚙️</span> {{ $t('config.title') }}</h1>
        <p>{{ $t('config.subtitle') }}</p>
      </div>
      <div class="role-badge-section">
        <div class="role-badge" :class="getRoleBadgeClass(user?.role)">
          {{ getUserRoleLabel(user?.role) }}
        </div>
        <div class="user-email">{{ user?.email || 'Usuario' }}</div>
      </div>
    </div>

    <!-- Config Content -->
    <div class="config-content">
      <div class="config-sidebar">
        <nav class="sidebar-nav">
          <button v-for="section in sections" :key="section.id" @click="activeSection = section.id"
            :class="['nav-item', { active: activeSection === section.id }]">
            <span class="nav-icon">{{ section.icon }}</span>
            <span class="nav-text">{{ section.label }}</span>
          </button>
        </nav>
        <div class="save-status" :class="{ 'has-changes': hasUnsavedChanges }">
          <div class="status-icon">{{ hasUnsavedChanges ? '💾' : '✅' }}</div>
          <div class="status-text">
            <h4>{{ hasUnsavedChanges ? 'Cambios sin guardar' : 'Todo guardado' }}</h4>
            <p>{{ hasUnsavedChanges ? 'Guarda para aplicar cambios' : 'Tu configuración está actualizada' }}</p>
          </div>
          <button v-if="hasUnsavedChanges" @click="saveConfig" :disabled="loading" class="btn-save-changes">
            <span v-if="loading" class="loading-spinner-small"></span>
            <span v-else>💾</span>
            <span>{{ loading ? 'Guardando...' : 'Guardar' }}</span>
          </button>
        </div>
      </div>

      <div class="config-main">
        <div v-if="!user" class="loading-section">
          <div class="spinner"></div>
          <p>Cargando configuración...</p>
        </div>

        <div v-else class="forms-container">
          <!-- Account Section -->
          <div v-show="activeSection === 'account'" class="config-section">
            <div class="section-header">
              <h2><span class="section-icon">👤</span> {{ $t('config.account') }}</h2>
              <p class="section-subtitle">Información básica de tu cuenta</p>
            </div>
            <div class="form-grid">
              <div class="form-group">
                <label class="form-label"><span class="label-icon">👤</span>{{ $t('config.name') }}<span class="required">*</span></label>
                <input v-model="form.name" type="text" required class="form-input" :class="{ 'input-error': errors.name }" @input="markUnsavedChanges" />
                <div v-if="errors.name" class="error-message">{{ errors.name }}</div>
              </div>
              <div class="form-group">
                <label class="form-label"><span class="label-icon">📧</span>{{ $t('config.email') }}<span class="required">*</span></label>
                <input v-model="form.email" type="email" required class="form-input" :class="{ 'input-error': errors.email }" @input="markUnsavedChanges" />
                <div v-if="errors.email" class="error-message">{{ errors.email }}</div>
              </div>
              <div class="form-group">
                <label class="form-label"><span class="label-icon">📱</span>{{ $t('config.phone') }}</label>
                <input v-model="form.phone" type="tel" class="form-input" :class="{ 'input-error': errors.phone }" @input="markUnsavedChanges" placeholder="+34 123 456 789" />
                <div v-if="errors.phone" class="error-message">{{ errors.phone }}</div>
              </div>
            </div>
          </div>

          <!-- Preferences Section -->
          <div v-show="activeSection === 'preferences'" class="config-section">
            <div class="section-header">
              <h2><span class="section-icon">⚙️</span> {{ $t('config.preferences') }}</h2>
              <p class="section-subtitle">Personaliza tu experiencia</p>
            </div>
            <div class="form-grid">
              <div class="form-group">
                <label class="form-label"><span class="label-icon">🌐</span>{{ $t('config.language') }}</label>
                <div class="language-selector">
                  <div v-for="lang in languages" :key="lang.value" @click="form.language = lang.value; markUnsavedChanges()"
                    :class="['language-option', { active: form.language === lang.value }]">
                    <span class="language-flag">{{ lang.flag }}</span>
                    <span class="language-name">{{ lang.name }}</span>
                    <span v-if="form.language === lang.value" class="language-check">✅</span>
                  </div>
                </div>
              </div>
              <div class="form-group">
                <label class="form-label"><span class="label-icon">🔔</span>{{ $t('config.notifications') }}</label>
                <div class="notifications-settings">
                  <div class="notification-option">
                    <label class="checkbox-label">
                      <input v-model="form.notifications" type="checkbox" class="checkbox-input" @change="markUnsavedChanges" />
                      <span class="checkbox-custom"></span>
                      <span class="checkbox-text">Recibir notificaciones</span>
                    </label>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Security Section -->
          <div v-show="activeSection === 'security'" class="config-section">
            <div class="section-header">
              <h2><span class="section-icon">🔒</span> {{ $t('config.security') }}</h2>
              <p class="section-subtitle">Protege tu cuenta</p>
            </div>
            <div class="security-grid">
              <div class="security-card">
                <div class="security-icon">🔑</div>
                <div class="security-content">
                  <h3>Contraseña</h3>
                  <p>Actualiza tu contraseña regularmente</p>
                </div>
                <button class="btn-security-action" @click="showChangePassword = true">✏️ Cambiar</button>
              </div>
              <div class="security-card">
                <div class="security-icon">📱</div>
                <div class="security-content">
                  <h3>Dispositivos</h3>
                  <p>Gestiona tus sesiones activas</p>
                </div>
                <button class="btn-security-action" @click="viewDevices">📊 Ver dispositivos</button>
              </div>
              <div class="security-card">
                <div class="security-icon">📋</div>
                <div class="security-content">
                  <h3>Actividad</h3>
                  <p>Ver registros de tu cuenta</p>
                </div>
                <button class="btn-security-action" @click="viewActivityLog">📊 Ver actividad</button>
              </div>
            </div>
          </div>

          <!-- Provider Section -->
          <div v-show="activeSection === 'provider' && isProvider" class="config-section">
            <div class="section-header">
              <h2><span class="section-icon">🏢</span> {{ $t('config.providerSection') }}</h2>
              <p class="section-subtitle">Configuración de tu negocio</p>
            </div>
            <div class="form-grid">
              <div class="form-group">
                <label class="form-label"><span class="label-icon">📍</span>{{ $t('config.businessAddress') }}</label>
                <textarea v-model="form.business_address" rows="3" class="form-textarea" @input="markUnsavedChanges" placeholder="Dirección completa de tu negocio..."></textarea>
              </div>
              <div class="form-group">
                <label class="form-label"><span class="label-icon">🗺️</span>{{ $t('config.coverageArea') }}</label>
                <input v-model="form.coverage_area" type="text" class="form-input" @input="markUnsavedChanges" placeholder="Ej: Ciudad, Zona Norte..." />
              </div>
              <div class="form-group">
                <label class="form-label"><span class="label-icon">🏷️</span>{{ $t('config.serviceCategories') }}</label>
                <div class="tags-input">
                  <input v-model="newCategory" type="text" class="tags-input-field" placeholder="Agrega una categoría..." @keydown.enter.prevent="addCategory" />
                  <button @click="addCategory" class="btn-add-tag" type="button">+</button>
                </div>
                <div class="tags-container">
                  <span v-for="(category, index) in categories" :key="index" class="tag">{{ category }}<button @click="removeCategory(index)" class="tag-remove">×</button></span>
                  <span v-if="categories.length === 0" class="no-tags">No hay categorías agregadas</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Admin Section -->
          <div v-show="activeSection === 'admin' && isAdmin" class="config-section">
            <div class="section-header">
              <h2><span class="section-icon">👑</span> {{ $t('config.adminSection') }}</h2>
              <p class="section-subtitle">Accesos rápidos del sistema</p>
            </div>
            <div class="admin-actions">
              <div class="admin-action-card">
                <div class="action-icon">👥</div>
                <div class="action-content"><h3>Gestión de Usuarios</h3><p>Administra usuarios del sistema</p></div>
                <button class="btn-admin-action" @click="$router.push('/admin/users')">→ Ir</button>
              </div>
              <div class="admin-action-card">
                <div class="action-icon">📊</div>
                <div class="action-content"><h3>Estadísticas</h3><p>Ver métricas y reportes</p></div>
                <button class="btn-admin-action" @click="$router.push('/admin/analytics')">→ Ir</button>
              </div>
              <div class="admin-action-card">
                <div class="action-icon">💾</div>
                <div class="action-content"><h3>Backups</h3><p>Copias de seguridad</p></div>
                <button class="btn-admin-action" @click="$router.push('/admin/backups')">→ Ir</button>
              </div>
              <div class="admin-action-card">
                <div class="action-icon">⚙️</div>
                <div class="action-content"><h3>Configuración del Sistema</h3><p>Ajustes globales</p></div>
                <button class="btn-admin-action" @click="$router.push('/admin/system')">→ Ir</button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Global Save Bar -->
    <div v-if="hasUnsavedChanges" class="global-save-bar">
      <div class="save-message"><span class="message-icon">💾</span><span>Tienes cambios sin guardar</span></div>
      <div class="save-actions">
        <button class="btn-discard" @click="discardChanges">Descartar cambios</button>
        <button class="btn-save" @click="saveConfig" :disabled="loading">
          <span v-if="loading" class="loading-spinner"></span>
          <span v-else>💾</span> {{ loading ? 'Guardando...' : 'Guardar cambios' }}
        </button>
      </div>
    </div>

    <ChangePasswordModal v-if="showChangePassword" @close="showChangePassword = false" @password-changed="onPasswordChanged" />
  </div>
</template>

<script setup>
import { reactive, ref, computed, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import api from '@/axios'
import Swal from 'sweetalert2'
import { useAuthStore } from '@/stores/authStore'
import { useI18n } from 'vue-i18n'
import ChangePasswordModal from '@/components/ChangePasswordModal.vue'

const router = useRouter()
const authStore = useAuthStore()
const { t, locale } = useI18n()

const loading = ref(false)
const showChangePassword = ref(false)
const user = ref(null)
const hasUnsavedChanges = ref(false)
const activeSection = ref('account')
const newCategory = ref('')
const originalForm = ref({})

const sections = computed(() => [
  { id: 'account', label: 'Cuenta', icon: '👤' },
  { id: 'preferences', label: 'Preferencias', icon: '⚙️' },
  { id: 'security', label: 'Seguridad', icon: '🔒' },
  ...(isProvider.value ? [{ id: 'provider', label: 'Proveedor', icon: '🏢' }] : []),
  ...(isAdmin.value ? [{ id: 'admin', label: 'Administrador', icon: '👑' }] : [])
])

const languages = [
  { value: 'es', name: 'Español', flag: '🇪🇸' },
  { value: 'en', name: 'English', flag: '🇺🇸' }
]

const form = reactive({
  name: '', email: '', phone: '',
  language: 'es', notifications: true,
  business_address: '', coverage_area: '', service_categories: ''
})

const errors = reactive({ name: '', email: '', phone: '' })

const isAdmin = computed(() => user.value?.role === 'admin')
const isProvider = computed(() => user.value?.role === 'provider')

const categories = computed({
  get() { return form.service_categories ? form.service_categories.split(',').map(c => c.trim()).filter(c => c) : [] },
  set(newCategories) { form.service_categories = newCategories.join(', '); markUnsavedChanges() }
})

const getRoleBadgeClass = (role) => ({ admin: 'role-admin', provider: 'role-provider', user: 'role-user' }[role] || 'role-default')
const getUserRoleLabel = (role) => ({ admin: 'Administrador', provider: 'Proveedor', user: 'Usuario' }[role] || 'Usuario')

const addCategory = () => { if (newCategory.value.trim()) { categories.value = [...categories.value, newCategory.value.trim()]; newCategory.value = '' } }
const removeCategory = (index) => { const c = [...categories.value]; c.splice(index, 1); categories.value = c }

const validate = () => {
  let valid = true
  Object.keys(errors).forEach(k => errors[k] = '')
  if (!form.name.trim()) { errors.name = 'El nombre es requerido'; valid = false }
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.email)) { errors.email = 'Email inválido'; valid = false }
  return valid
}

const markUnsavedChanges = () => { hasUnsavedChanges.value = true }

const discardChanges = async () => {
  const { isConfirmed } = await Swal.fire({ title: '¿Descartar cambios?', text: 'Se perderán todos los cambios sin guardar', icon: 'warning', showCancelButton: true, confirmButtonText: 'Sí, descartar', cancelButtonText: 'Cancelar' })
  if (isConfirmed) { Object.assign(form, originalForm.value); hasUnsavedChanges.value = false; newCategory.value = '' }
}

// ✅ CORREGIDO: Guardar perfil con endpoint real
const saveConfig = async () => {
  if (!validate()) { Swal.fire('Error', 'Corrige los errores', 'error'); return }
  loading.value = true
  try {
    const payload = { name: form.name.trim(), email: form.email.trim(), phone: form.phone.trim() }
    if (isProvider.value) {
      payload.business_address = form.business_address.trim()
      payload.coverage_area = form.coverage_area.trim()
      payload.service_categories = form.service_categories.trim()
    }
    await api.post('/profile/update', payload, { headers: { Authorization: `Bearer ${authStore.token}` } })
    if (form.language !== originalForm.value.language) { locale.value = form.language; localStorage.setItem('userLocale', form.language) }
    Object.assign(originalForm.value, { ...form })
    hasUnsavedChanges.value = false
    Swal.fire({ icon: 'success', title: 'Guardado', timer: 2000, showConfirmButton: false, position: 'top-end', toast: true })
  } catch (error) {
    Swal.fire({ icon: 'error', title: 'Error', text: error.response?.data?.error || 'Error al guardar' })
  } finally { loading.value = false }
}

// ✅ CORREGIDO: Obtener perfil real del backend
const fetchProfile = async () => {
  try {
    const { data } = await api.get('/profile', { headers: { Authorization: `Bearer ${authStore.token}` } })
    user.value = data.user || data
    const ud = {
      name: user.value.name || '', email: user.value.email || '', phone: user.value.phone || '',
      language: user.value.language || localStorage.getItem('userLocale') || 'es',
      notifications: user.value.notifications ?? true,
      business_address: user.value.business_address || '', coverage_area: user.value.coverage_area || '',
      service_categories: user.value.service_categories || ''
    }
    Object.assign(form, ud)
    originalForm.value = { ...ud }
    if (isAdmin.value) activeSection.value = 'admin'
    else if (isProvider.value) activeSection.value = 'provider'
  } catch (error) {
    Swal.fire('Error', 'No se pudo cargar el perfil', 'error')
  }
}

// ✅ CORREGIDO: Redirige a páginas reales en vez de simular
const viewDevices = () => router.push('/profile')
const viewActivityLog = () => router.push('/admin/logs')

const onPasswordChanged = () => {
  showChangePassword.value = false
  Swal.fire({ icon: 'success', title: 'Contraseña actualizada', timer: 2000, showConfirmButton: false, position: 'top-end', toast: true })
}

onMounted(fetchProfile)

watch(() => ({ ...form }), (newVal) => {
  if (JSON.stringify(newVal) !== JSON.stringify(originalForm.value)) hasUnsavedChanges.value = true
}, { deep: true })
</script>

<style scoped>
.config-container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 0 16px;
  min-height: 100vh;
  padding-bottom: 80px; /* Space for global save bar */
}

/* Header Section */
.header-section {
  margin-bottom: 40px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 24px;
}

.header-content {
  text-align: left;
}

.header-content h1 {
  font-size: 2.5rem;
  color: #2d3436;
  margin-bottom: 8px;
  display: flex;
  align-items: center;
  gap: 12px;
}

.header-content .icon {
  font-size: 2.2rem;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.1); }
}

.header-content p {
  color: #636e72;
  font-size: 1.1rem;
  max-width: 600px;
}

/* Role Badge Section */
.role-badge-section {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 8px;
}

.role-badge {
  padding: 8px 20px;
  border-radius: 20px;
  font-weight: 700;
  font-size: 0.9rem;
  color: white;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.role-admin {
  background: linear-gradient(135deg, #ff7675 0%, #d63031 100%);
}

.role-provider {
  background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%);
}

.role-user {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
}

.role-default {
  background: linear-gradient(135deg, #b2bec3 0%, #636e72 100%);
}

.user-email {
  color: #636e72;
  font-size: 0.9rem;
  font-weight: 600;
}

/* Config Content Layout */
.config-content {
  display: grid;
  grid-template-columns: 280px 1fr;
  gap: 32px;
  margin-bottom: 40px;
}

/* Sidebar */
.config-sidebar {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.sidebar-nav {
  background: white;
  border-radius: 16px;
  padding: 16px;
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.08);
  border: 1px solid #f1f2f6;
}

.nav-item {
  display: flex;
  align-items: center;
  gap: 12px;
  width: 100%;
  padding: 14px 16px;
  border: none;
  background: transparent;
  border-radius: 12px;
  cursor: pointer;
  font-weight: 600;
  color: #636e72;
  transition: all 0.3s;
  text-align: left;
  margin-bottom: 8px;
}

.nav-item:last-child {
  margin-bottom: 0;
}

.nav-item:hover {
  background: #f8f9fa;
  color: #2d3436;
  transform: translateX(5px);
}

.nav-item.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

.nav-icon {
  font-size: 1.2rem;
}

.nav-text {
  font-size: 0.95rem;
}

/* Save Status */
.save-status {
  background: white;
  border-radius: 16px;
  padding: 20px;
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.08);
  border: 1px solid #f1f2f6;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.save-status.has-changes {
  border-color: #fdcb6e;
  background: linear-gradient(to right, white, #fff9e6);
}

.status-icon {
  font-size: 2rem;
  text-align: center;
}

.status-text h4 {
  font-size: 1.1rem;
  color: #2d3436;
  margin-bottom: 4px;
  font-weight: 700;
}

.status-text p {
  color: #636e72;
  font-size: 0.85rem;
  line-height: 1.4;
}

.btn-save-changes {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 12px;
  border-radius: 10px;
  font-weight: 600;
  font-size: 0.95rem;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  transition: all 0.3s;
}

.btn-save-changes:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 15px rgba(102, 126, 234, 0.3);
}

.btn-save-changes:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.loading-spinner-small {
  width: 16px;
  height: 16px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top-color: white;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

/* Main Content */
.config-main {
  background: white;
  border-radius: 20px;
  padding: 32px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
  border: 1px solid #f1f2f6;
  min-height: 600px;
}

/* Loading Section */
.loading-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 400px;
}

.spinner {
  width: 60px;
  height: 60px;
  border: 4px solid rgba(52, 152, 219, 0.2);
  border-top: 4px solid #3498db;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 20px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.loading-section p {
  color: #636e72;
  font-size: 1.1rem;
}

/* Config Sections */
.config-section {
  animation: fadeIn 0.3s ease-out;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.section-header {
  margin-bottom: 32px;
  padding-bottom: 16px;
  border-bottom: 2px solid #f1f2f6;
}

.section-header h2 {
  font-size: 1.8rem;
  color: #2d3436;
  margin-bottom: 8px;
  display: flex;
  align-items: center;
  gap: 12px;
}

.section-icon {
  font-size: 1.5rem;
}

.section-subtitle {
  color: #636e72;
  font-size: 1rem;
  margin-left: 44px; /* Align with icon */
}

/* Form Grid */
.form-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 24px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-label {
  font-weight: 700;
  color: #2d3436;
  font-size: 0.95rem;
  display: flex;
  align-items: center;
  gap: 8px;
}

.label-icon {
  font-size: 1.1rem;
}

.required {
  color: #e74c3c;
  margin-left: 4px;
}

.form-input,
.form-textarea {
  padding: 14px;
  border: 2px solid #dfe6e9;
  border-radius: 10px;
  font-size: 1rem;
  transition: all 0.3s;
  background: white;
}

.form-input:focus,
.form-textarea:focus {
  outline: none;
  border-color: #3498db;
  box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
}

.form-textarea {
  min-height: 100px;
  resize: vertical;
}

.input-error {
  border-color: #e74c3c !important;
}

.input-error:focus {
  box-shadow: 0 0 0 3px rgba(231, 76, 60, 0.1) !important;
}

.error-message {
  color: #e74c3c;
  font-size: 0.85rem;
  font-weight: 600;
}

.success-message {
  color: #00b894;
  font-size: 0.85rem;
  font-weight: 600;
}

.form-hint {
  color: #636e72;
  font-size: 0.85rem;
  font-style: italic;
}

/* Language Selector */
.language-selector {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.language-option {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  border: 2px solid #dfe6e9;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.3s;
}

.language-option:hover {
  border-color: #3498db;
  background: #f8f9fa;
}

.language-option.active {
  border-color: #3498db;
  background: #e3f2fd;
  font-weight: 600;
}

.language-flag {
  font-size: 1.2rem;
}

.language-name {
  flex: 1;
}

.language-check {
  color: #00b894;
  font-size: 1rem;
}

/* Theme Selector */
.theme-selector {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
  gap: 12px;
}

.theme-option {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 16px;
  border: 2px solid #dfe6e9;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s;
  text-align: center;
}

.theme-option:hover {
  border-color: #3498db;
  transform: translateY(-2px);
}

.theme-option.active {
  border-color: #3498db;
  background: #e3f2fd;
  box-shadow: 0 4px 12px rgba(52, 152, 219, 0.15);
}

.theme-icon {
  font-size: 1.8rem;
}

.theme-name {
  font-weight: 600;
  font-size: 0.9rem;
}

.theme-check {
  color: #00b894;
  font-size: 1rem;
}

/* Notifications */
.notifications-settings {
  background: #f8f9fa;
  padding: 16px;
  border-radius: 12px;
}

.checkbox-label {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  cursor: pointer;
  font-size: 0.95rem;
}

.checkbox-input {
  display: none;
}

.checkbox-custom {
  width: 20px;
  height: 20px;
  border: 2px solid #b2bec3;
  border-radius: 4px;
  position: relative;
  transition: all 0.3s;
  margin-top: 2px;
}

.checkbox-input:checked + .checkbox-custom {
  background: #3498db;
  border-color: #3498db;
}

.checkbox-input:checked + .checkbox-custom::after {
  content: '✓';
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  color: white;
  font-size: 12px;
  font-weight: bold;
}

.checkbox-text {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #2d3436;
  font-weight: 600;
}

.checkbox-icon {
  font-size: 1.1rem;
}

.notification-hint {
  color: #636e72;
  font-size: 0.85rem;
  margin-top: 8px;
  margin-left: 32px;
}

/* Security Grid */
.security-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 20px;
}

.security-card {
  background: #f8f9fa;
  border-radius: 16px;
  padding: 24px;
  display: flex;
  align-items: center;
  gap: 20px;
  transition: all 0.3s;
}

.security-card:hover {
  background: #e9ecef;
  transform: translateY(-2px);
}

.security-icon {
  font-size: 2rem;
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 12px;
  color: white;
}

.security-content {
  flex: 1;
}

.security-content h3 {
  font-size: 1.1rem;
  color: #2d3436;
  margin-bottom: 4px;
  font-weight: 700;
}

.security-content p {
  color: #636e72;
  font-size: 0.9rem;
}

.btn-security-action {
  background: white;
  color: #3498db;
  border: 2px solid #3498db;
  padding: 10px 20px;
  border-radius: 8px;
  font-weight: 600;
  font-size: 0.9rem;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s;
  white-space: nowrap;
}

.btn-security-action:hover:not(:disabled) {
  background: #3498db;
  color: white;
  transform: translateY(-2px);
}

.btn-security-action:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

/* Tags Input */
.tags-input {
  display: flex;
  gap: 8px;
  margin-bottom: 12px;
}

.tags-input-field {
  flex: 1;
  padding: 12px;
  border: 2px solid #dfe6e9;
  border-radius: 10px;
  font-size: 1rem;
}

.btn-add-tag {
  width: 44px;
  background: #3498db;
  color: white;
  border: none;
  border-radius: 10px;
  font-size: 1.5rem;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-add-tag:hover {
  background: #2980b9;
  transform: scale(1.05);
}

.tags-container {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  min-height: 40px;
  align-items: center;
}

.tag {
  background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%);
  color: white;
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 6px;
}

.tag-remove {
  background: rgba(255, 255, 255, 0.3);
  color: white;
  border: none;
  width: 18px;
  height: 18px;
  border-radius: 50%;
  cursor: pointer;
  font-size: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s;
}

.tag-remove:hover {
  background: rgba(255, 255, 255, 0.5);
  transform: scale(1.1);
}

.no-tags {
  color: #b2bec3;
  font-style: italic;
  font-size: 0.9rem;
}

/* Admin Section */
.admin-grid {
  display: flex;
  flex-direction: column;
  gap: 32px;
}

.admin-card {
  background: #f8f9fa;
  border-radius: 16px;
  padding: 24px;
}

.admin-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.admin-card-header h3 {
  font-size: 1.3rem;
  color: #2d3436;
  display: flex;
  align-items: center;
  gap: 10px;
}

.admin-icon {
  font-size: 1.2rem;
}

.btn-validate-json {
  background: #00b894;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 8px;
  font-weight: 600;
  font-size: 0.9rem;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s;
}

.btn-validate-json:hover:not(:disabled) {
  background: #00a085;
  transform: translateY(-2px);
}

.btn-validate-json:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.json-editor {
  width: 100%;
  padding: 16px;
  border: 2px solid #dfe6e9;
  border-radius: 12px;
  font-family: 'Monaco', 'Courier New', monospace;
  font-size: 0.9rem;
  line-height: 1.4;
  resize: vertical;
  transition: all 0.3s;
}

.json-editor:focus {
  outline: none;
  border-color: #3498db;
}

.json-error {
  border-color: #e74c3c;
  background: #fff5f5;
}

.json-valid {
  border-color: #00b894;
  background: #f0fff4;
}

.json-hint {
  color: #636e72;
  font-size: 0.85rem;
  margin-top: 8px;
  font-style: italic;
}

/* Admin Actions */
.admin-actions {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
}

.admin-action-card {
  background: white;
  border-radius: 16px;
  padding: 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
  border: 1px solid #f1f2f6;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
  transition: all 0.3s;
}

.admin-action-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
}

.action-icon {
  font-size: 2.5rem;
  text-align: center;
}

.action-content h3 {
  font-size: 1.1rem;
  color: #2d3436;
  margin-bottom: 4px;
  font-weight: 700;
  text-align: center;
}

.action-content p {
  color: #636e72;
  font-size: 0.9rem;
  text-align: center;
}

.btn-admin-action {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 12px;
  border-radius: 10px;
  font-weight: 600;
  font-size: 0.95rem;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  transition: all 0.3s;
}

.btn-admin-action:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 15px rgba(102, 126, 234, 0.3);
}

/* Global Save Bar */
.global-save-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 16px 32px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 -4px 20px rgba(0, 0, 0, 0.2);
  z-index: 1000;
  animation: slideUp 0.3s ease-out;
}

@keyframes slideUp {
  from {
    transform: translateY(100%);
  }
  to {
    transform: translateY(0);
  }
}

.save-message {
  display: flex;
  align-items: center;
  gap: 12px;
  font-weight: 600;
  font-size: 1.1rem;
}

.message-icon {
  font-size: 1.3rem;
}

.save-actions {
  display: flex;
  gap: 16px;
}

.btn-discard {
  background: rgba(255, 255, 255, 0.2);
  color: white;
  border: 2px solid rgba(255, 255, 255, 0.3);
  padding: 12px 24px;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-discard:hover {
  background: rgba(255, 255, 255, 0.3);
  border-color: rgba(255, 255, 255, 0.5);
}

.btn-save {
  background: white;
  color: #667eea;
  border: none;
  padding: 12px 32px;
  border-radius: 8px;
  font-weight: 700;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 10px;
  transition: all 0.3s;
}

.btn-save:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(255, 255, 255, 0.3);
}

.btn-save:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.loading-spinner {
  width: 20px;
  height: 20px;
  border: 2px solid rgba(102, 126, 234, 0.3);
  border-top-color: #667eea;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@media (max-width: 1200px) {
  .config-content {
    grid-template-columns: 1fr;
  }
  
  /* Elimina o comenta esta línea */
  /* .config-sidebar {
    display: none;
  } */
  
  /* En su lugar, puedes hacerla más compacta */
  .config-sidebar {
    display: flex;
    flex-direction: row;
    overflow-x: auto;
    gap: 12px;
    padding-bottom: 16px;
  }
  
  .sidebar-nav {
    flex: 1;
    display: flex;
    flex-direction: row;
    padding: 12px;
    gap: 8px;
  }
  
  .nav-item {
    flex-direction: column;
    min-width: 80px;
    padding: 12px 8px;
  }
  
  .nav-text {
    font-size: 0.8rem;
    text-align: center;
  }
}

@media (max-width: 768px) {
  .config-container {
    padding: 0 12px;
  }
  
  .header-section {
    flex-direction: column;
    align-items: stretch;
    gap: 16px;
  }
  
  .header-content h1 {
    font-size: 2rem;
  }
  
  .role-badge-section {
    align-items: stretch;
    text-align: center;
  }
  
  .config-main {
    padding: 24px;
    border-radius: 16px;
  }
  
  .form-grid {
    grid-template-columns: 1fr;
  }
  
  .security-grid {
    grid-template-columns: 1fr;
  }
  
  .security-card {
    flex-direction: column;
    text-align: center;
    gap: 16px;
  }
  
  .theme-selector {
    grid-template-columns: 1fr;
  }
  
  .global-save-bar {
    flex-direction: column;
    gap: 16px;
    padding: 16px;
  }
  
  .save-actions {
    width: 100%;
    flex-direction: column;
  }
  
  .btn-discard,
  .btn-save {
    width: 100%;
    justify-content: center;
  }
}

@media (max-width: 480px) {
  .header-content h1 {
    font-size: 1.8rem;
    flex-direction: column;
    gap: 8px;
  }
  
  .admin-actions {
    grid-template-columns: 1fr;
  }
}
</style>
