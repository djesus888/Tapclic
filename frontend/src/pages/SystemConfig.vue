<template>
  <div class="system-config-page">
    <!-- Header -->
    <div class="header">
      <div class="title-section">
        <h1><span class="config-icon">⚙️</span> {{ t("systemConfig.title") }}</h1>
        <p>Configura los parámetros generales del sistema</p>
      </div>
    </div>

    <!-- Formulario -->
    <div class="config-container">
      <form
        class="config-form"
        @submit.prevent="save"
      >
        <!-- Sección 1: Información General -->
        <div class="form-section">
          <div class="section-header">
            <div class="section-icon">🏢</div>
            <h2>Información General</h2>
          </div>
          
          <div class="form-grid">
            <!-- Nombre del Sistema -->
            <div class="form-group">
              <label class="form-label">
                <span class="label-icon">🏷️</span>
                {{ t("systemConfig.systemName") }}
              </label>
              <input
                v-model="form.system_name"
                type="text"
                class="form-input"
                required
                placeholder="Mi Sistema de Servicios"
              >
              <div class="form-hint">Nombre que aparecerá en la aplicación</div>
            </div>

            <!-- Host del Sistema -->
            <div class="form-group">
              <label class="form-label">
                <span class="label-icon">🌐</span>
                {{ t("systemConfig.systemHost") }}
              </label>
              <input
                v-model="form.system_host"
                type="url"
                class="form-input"
                required
                placeholder="https://miservicios.com"
              >
              <div class="form-hint">URL principal de tu aplicación</div>
            </div>
          </div>
        </div>

        <!-- Sección 2: Información de la Empresa -->
        <div class="form-section">
          <div class="section-header">
            <div class="section-icon">🏭</div>
            <h2>Información de la Empresa</h2>
          </div>
          
          <div class="form-grid">
            <!-- Nombre de la Empresa -->
            <div class="form-group">
              <label class="form-label">
                <span class="label-icon">💼</span>
                {{ t("systemConfig.companyName") }}
              </label>
              <input
                v-model="form.company_name"
                type="text"
                class="form-input"
                required
                placeholder="Mi Empresa S.A."
              >
            </div>

            <!-- Dirección -->
            <div class="form-group full-width">
              <label class="form-label">
                <span class="label-icon">📍</span>
                {{ t("systemConfig.companyAddress") }}
              </label>
              <textarea
                v-model="form.company_address"
                rows="3"
                class="form-textarea"
                required
                placeholder="Av. Principal #123, Ciudad"
              ></textarea>
            </div>

            <!-- Email de Soporte -->
            <div class="form-group">
              <label class="form-label">
                <span class="label-icon">✉️</span>
                {{ t("systemConfig.supportEmail") }}
              </label>
              <input
                v-model="form.support_email"
                type="email"
                class="form-input"
                required
                placeholder="soporte@empresa.com"
              >
            </div>

            <!-- Teléfono de Soporte -->
            <div class="form-group">
              <label class="form-label">
                <span class="label-icon">📞</span>
                {{ t("systemConfig.supportPhone") }}
              </label>
              <input
                v-model="form.support_phone"
                type="tel"
                class="form-input"
                placeholder="+1 234 567 8900"
              >
            </div>
          </div>
        </div>

        <!-- Sección 3: Configuración Regional -->
        <div class="form-section">
          <div class="section-header">
            <div class="section-icon">🌍</div>
            <h2>Configuración Regional</h2>
          </div>
          
          <div class="form-grid">
            <!-- Idioma -->
            <div class="form-group">
              <label class="form-label">
                <span class="label-icon">🗣️</span>
                {{ t("systemConfig.defaultLanguage") }}
              </label>
              <div class="select-wrapper">
                <select
                  v-model="form.default_language"
                  class="form-select"
                >
                  <option value="es">🇪🇸 Español</option>
                  <option value="en">🇺🇸 English</option>
                </select>
                <div class="select-arrow">▼</div>
              </div>
            </div>

            <!-- Zona Horaria -->
            <div class="form-group">
              <label class="form-label">
                <span class="label-icon">🕒</span>
                {{ t("systemConfig.timezone") }}
              </label>
              <input
                v-model="form.timezone"
                type="text"
                class="form-input"
                placeholder="America/Caracas"
              >
              <div class="form-hint">Ej: America/Caracas, Europe/Madrid</div>
            </div>

            <!-- Moneda -->
            <div class="form-group">
              <label class="form-label">
                <span class="label-icon">💰</span>
                {{ t("systemConfig.currency") }}
              </label>
              <input
                v-model="form.currency"
                maxlength="3"
                class="form-input"
                placeholder="USD"
              >
              <div class="form-hint">Código de 3 letras (USD, EUR, etc.)</div>
            </div>
          </div>
        </div>

        <!-- Sección 4: Apariencia -->
        <div class="form-section">
          <div class="section-header">
            <div class="section-icon">🎨</div>
            <h2>Apariencia</h2>
          </div>
          
          <div class="form-grid">
            <!-- Color del Tema -->
            <div class="form-group">
              <label class="form-label">
                <span class="label-icon">🎨</span>
                {{ t("systemConfig.themeColor") }}
              </label>
              <div class="color-picker-wrapper">
                <input
                  v-model="form.theme_color"
                  type="color"
                  class="color-picker"
                >
                <span class="color-value">{{ form.theme_color }}</span>
              </div>
            </div>

            <!-- Logo -->
            <div class="form-group">
              <label class="form-label">
                <span class="label-icon">🖼️</span>
                {{ t("systemConfig.systemLogo") }}
              </label>
              <div class="file-upload-wrapper">
                <input
                  ref="logoFile"
                  type="file"
                  accept="image/*"
                  class="file-input"
                  @change="uploadLogo"
                >
                <div class="file-preview" v-if="form.system_logo">
                  <img
                    :src="form.system_logo"
                    alt="Logo del sistema"
                    class="preview-image"
                  >
                  <button
                    type="button"
                    class="remove-file"
                    @click="form.system_logo = ''"
                  >
                    ✕
                  </button>
                </div>
                <div v-else class="file-placeholder">
                  📤 Haga clic para subir logo
                </div>
              </div>
            </div>

            <!-- Favicon -->
            <div class="form-group">
              <label class="form-label">
                <span class="label-icon">📱</span>
                {{ t("systemConfig.systemFavicon") }}
              </label>
              <div class="file-upload-wrapper">
                <input
                  ref="faviconFile"
                  type="file"
                  accept="image/*"
                  class="file-input"
                  @change="uploadFavicon"
                >
                <div class="file-preview" v-if="form.system_favicon">
                  <img
                    :src="form.system_favicon"
                    alt="Favicon"
                    class="preview-image favicon"
                  >
                  <button
                    type="button"
                    class="remove-file"
                    @click="form.system_favicon = ''"
                  >
                    ✕
                  </button>
                </div>
                <div v-else class="file-placeholder">
                  📤 Haga clic para subir favicon
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Sección 5: Configuración de Seguridad -->
        <div class="form-section">
          <div class="section-header">
            <div class="section-icon">🔒</div>
            <h2>Seguridad</h2>
          </div>
          
          <div class="form-grid">
            <!-- Intentos de Login -->
            <div class="form-group">
              <label class="form-label">
                <span class="label-icon">🔑</span>
                {{ t("systemConfig.maxLoginAttempts") }}
              </label>
              <input
                v-model.number="form.max_login_attempts"
                type="number"
                min="1"
                max="20"
                class="form-input"
              >
              <div class="form-hint">Máximo de intentos fallidos antes de bloquear</div>
            </div>

            <!-- Tiempo de Sesión -->
            <div class="form-group">
              <label class="form-label">
                <span class="label-icon">⏱️</span>
                {{ t("systemConfig.sessionTimeout") }}
              </label>
              <div class="input-with-unit">
                <input
                  v-model.number="form.session_timeout_minutes"
                  type="number"
                  min="1"
                  max="999"
                  class="form-input"
                >
                <span class="input-unit">minutos</span>
              </div>
            </div>

            <!-- Expiración de Contraseña -->
            <div class="form-group">
              <label class="form-label">
                <span class="label-icon">📅</span>
                {{ t("systemConfig.passwordExpiration") }}
              </label>
              <div class="input-with-unit">
                <input
                  v-model.number="form.password_expiration_days"
                  type="number"
                  min="0"
                  max="999"
                  class="form-input"
                >
                <span class="input-unit">días</span>
              </div>
              <div class="form-hint">0 = nunca expira</div>
            </div>

            <!-- Elementos por Página -->
            <div class="form-group">
              <label class="form-label">
                <span class="label-icon">📄</span>
                {{ t("systemConfig.itemsPerPage") }}
              </label>
              <input
                v-model.number="form.items_per_page"
                type="number"
                min="5"
                max="200"
                class="form-input"
              >
              <div class="form-hint">Elementos mostrados en listados</div>
            </div>
          </div>
        </div>

        <!-- Sección 6: Opciones del Sistema -->
        <div class="form-section">
          <div class="section-header">
            <div class="section-icon">⚡</div>
            <h2>Opciones del Sistema</h2>
          </div>
          
          <div class="switches-grid">
            <!-- Sistema Activo -->
            <div class="switch-group">
              <label class="switch-wrapper">
                <input
                  id="system_active"
                  v-model="form.system_active"
                  type="checkbox"
                  class="switch-input"
                >
                <span class="switch-slider"></span>
                <span class="switch-label">
                  <span class="switch-icon">✅</span>
                  {{ t("systemConfig.systemActive") }}
                </span>
              </label>
              <div class="switch-hint">Activa/desactiva el sistema completamente</div>
            </div>

            <!-- Modo Mantenimiento -->
            <div class="switch-group">
              <label class="switch-wrapper">
                <input
                  id="maintenance_mode"
                  v-model="form.maintenance_mode"
                  type="checkbox"
                  class="switch-input"
                >
                <span class="switch-slider"></span>
                <span class="switch-label">
                  <span class="switch-icon">🔧</span>
                  {{ t("systemConfig.maintenanceMode") }}
                </span>
              </label>
              <div class="switch-hint">Mostrar página de mantenimiento a los usuarios</div>
            </div>

            <!-- Registro de Usuarios -->
            <div class="switch-group">
              <label class="switch-wrapper">
                <input
                  id="allow_user_registration"
                  v-model="form.allow_user_registration"
                  type="checkbox"
                  class="switch-input"
                >
                <span class="switch-slider"></span>
                <span class="switch-label">
                  <span class="switch-icon">👥</span>
                  {{ t("systemConfig.allowRegistration") }}
                </span>
              </label>
              <div class="switch-hint">Permitir registro de nuevos usuarios</div>
            </div>
          </div>
        </div>

        <!-- Botones de Acción -->
        <div class="form-actions">
          <button
            type="submit"
            class="btn-save"
          >
            <span class="btn-icon">💾</span>
            {{ t("systemConfig.save") }}
          </button>
          
          <button
            type="button"
            class="btn-reset"
            @click="loadCurrentConfig"
          >
            <span class="btn-icon">🔄</span>
            Restablecer
          </button>
        </div>
      </form>
    </div>

    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast" :class="toast.type">
      {{ toast.message }}
    </div>
  </div>
</template>

<script setup>
import { reactive, ref, onMounted } from "vue";
import { useI18n } from "vue-i18n";
import api from "@/axios";

const { t } = useI18n();

const logoFile = ref();
const faviconFile = ref();

// Estado reactivo del formulario (MANTENIDO IGUAL)
const form = reactive({
  system_name: "",
  system_host: "",
  company_name: "",
  company_address: "",
  support_email: "",
  support_phone: "",
  default_language: "es",
  timezone: "",
  currency: "USD",
  theme_color: "#409EFF",
  items_per_page: 20,
  max_login_attempts: 5,
  session_timeout_minutes: 30,
  password_expiration_days: 90,
  system_active: true,
  maintenance_mode: false,
  allow_user_registration: true,
  system_logo: "",
  system_favicon: "",
});

// Toast notifications (nuevo)
const toast = ref({
  show: false,
  message: '',
  type: 'success'
});

/* ---------- Cargar valores actuales ---------- */
async function loadCurrentConfig() {
  try {
    const { data } = await api.get("/admin/system-config");
    Object.assign(form, data);
    showToast("Configuración cargada correctamente", "success");
  } catch (error) {
    showToast("Error al cargar la configuración", "error");
  }
}

onMounted(() => {
  loadCurrentConfig();
});

/* ---------- Subir logo ---------- */
async function uploadLogo() {
  const file = logoFile.value.files[0];
  if (!file) return;
  
  // Validar tamaño (opcional)
  if (file.size > 5 * 1024 * 1024) { // 5MB
    showToast("El logo no debe superar los 5MB", "error");
    return;
  }
  
  try {
    const fd = new FormData();
    fd.append("file", file);
    const { data } = await api.post("/admin/upload-logo", fd, {
      headers: { "Content-Type": "multipart/form-data" },
    });
    form.system_logo = data.url;
    showToast("Logo subido correctamente", "success");
  } catch (error) {
    showToast("Error al subir el logo", "error");
  }
}

/* ---------- Subir favicon ---------- */
async function uploadFavicon() {
  const file = faviconFile.value.files[0];
  if (!file) return;
  
  // Validar tamaño (opcional)
  if (file.size > 1 * 1024 * 1024) { // 1MB
    showToast("El favicon no debe superar los 1MB", "error");
    return;
  }
  
  try {
    const fd = new FormData();
    fd.append("file", file);
    const { data } = await api.post("/admin/upload-favicon", fd, {
      headers: { "Content-Type": "multipart/form-data" },
    });
    form.system_favicon = data.url;
    showToast("Favicon subido correctamente", "success");
  } catch (error) {
    showToast("Error al subir el favicon", "error");
  }
}

/* ---------- Guardar cambios ---------- */
async function save() {
  try {
    await api.put("/admin/system-config", form);
    showToast(t("systemConfig.saved"), "success");
  } catch (error) {
    showToast("Error al guardar la configuración", "error");
  }
}

/* ---------- Mostrar notificación ---------- */
function showToast(message, type = 'info') {
  toast.value = { show: true, message, type };
  setTimeout(() => {
    toast.value.show = false;
  }, 3000);
}
</script>

<style scoped>
.system-config-page {
  max-width: 1400px;
  margin: 0 auto;
  padding: 24px;
  min-height: 100vh;
  background: linear-gradient(135deg, #f5f7fa 0%, #e4edf5 100%);
}

/* Header */
.header {
  margin-bottom: 40px;
}

.title-section h1 {
  font-size: 2.5rem;
  color: #2d3436;
  margin-bottom: 8px;
  display: flex;
  align-items: center;
  gap: 12px;
}

.config-icon {
  font-size: 2.2rem;
  animation: spin 20s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.title-section p {
  color: #636e72;
  font-size: 1.1rem;
  margin-left: 44px;
}

/* Config Container */
.config-container {
  background: white;
  border-radius: 24px;
  padding: 40px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.1);
}

/* Form Sections */
.form-section {
  margin-bottom: 48px;
  padding-bottom: 40px;
  border-bottom: 2px solid #f1f2f6;
}

.form-section:last-child {
  border-bottom: none;
  margin-bottom: 32px;
}

.section-header {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 32px;
}

.section-icon {
  font-size: 2rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  width: 60px;
  height: 60px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.section-header h2 {
  font-size: 1.8rem;
  color: #2d3436;
  margin: 0;
}

/* Form Grid */
.form-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 32px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-group.full-width {
  grid-column: 1 / -1;
}

.form-label {
  font-weight: 600;
  color: #2d3436;
  font-size: 1rem;
  display: flex;
  align-items: center;
  gap: 8px;
}

.label-icon {
  font-size: 1.2rem;
}

.form-input,
.form-textarea,
.form-select {
  padding: 14px 16px;
  border: 2px solid #dfe6e9;
  border-radius: 12px;
  font-size: 1rem;
  transition: all 0.3s;
  background: white;
  color: #2d3436;
}

.form-input:focus,
.form-textarea:focus,
.form-select:focus {
  outline: none;
  border-color: #3498db;
  box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
}

.form-textarea {
  resize: vertical;
  min-height: 100px;
  font-family: inherit;
}

/* Select Wrapper */
.select-wrapper {
  position: relative;
}

.select-wrapper select {
  appearance: none;
  width: 100%;
  padding-right: 40px;
}

.select-arrow {
  position: absolute;
  right: 16px;
  top: 50%;
  transform: translateY(-50%);
  pointer-events: none;
  color: #636e72;
}

/* Color Picker */
.color-picker-wrapper {
  display: flex;
  align-items: center;
  gap: 16px;
}

.color-picker {
  width: 60px;
  height: 60px;
  border: 3px solid #dfe6e9;
  border-radius: 12px;
  cursor: pointer;
  padding: 0;
  background: transparent;
}

.color-picker::-webkit-color-swatch-wrapper {
  padding: 0;
}

.color-picker::-webkit-color-swatch {
  border: none;
  border-radius: 8px;
}

.color-value {
  font-family: monospace;
  background: #f8f9fa;
  padding: 10px 16px;
  border-radius: 8px;
  border: 2px solid #dfe6e9;
  font-weight: 600;
  color: #2d3436;
}

/* File Upload */
.file-upload-wrapper {
  position: relative;
}

.file-input {
  position: absolute;
  width: 100%;
  height: 100%;
  opacity: 0;
  cursor: pointer;
  z-index: 2;
}

.file-placeholder {
  background: #f8f9fa;
  border: 2px dashed #dfe6e9;
  border-radius: 12px;
  padding: 40px 20px;
  text-align: center;
  color: #636e72;
  font-weight: 500;
  transition: all 0.3s;
  cursor: pointer;
}

.file-placeholder:hover {
  background: #e9ecef;
  border-color: #3498db;
  color: #3498db;
}

.file-preview {
  position: relative;
  background: #f8f9fa;
  border: 2px solid #dfe6e9;
  border-radius: 12px;
  padding: 20px;
  text-align: center;
}

.preview-image {
  max-width: 200px;
  max-height: 100px;
  object-fit: contain;
}

.preview-image.favicon {
  max-width: 64px;
  max-height: 64px;
}

.remove-file {
  position: absolute;
  top: 10px;
  right: 10px;
  background: #ff7675;
  color: white;
  border: none;
  width: 30px;
  height: 30px;
  border-radius: 50%;
  cursor: pointer;
  font-size: 14px;
  transition: all 0.3s;
  display: flex;
  align-items: center;
  justify-content: center;
}

.remove-file:hover {
  background: #d63031;
  transform: rotate(90deg);
}

/* Input with Unit */
.input-with-unit {
  position: relative;
}

.input-unit {
  position: absolute;
  right: 16px;
  top: 50%;
  transform: translateY(-50%);
  color: #636e72;
  font-weight: 500;
  background: white;
  padding: 0 4px;
}

/* Switches */
.switches-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 24px;
}

.switch-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.switch-wrapper {
  display: flex;
  align-items: center;
  gap: 16px;
  cursor: pointer;
  padding: 12px;
  background: #f8f9fa;
  border-radius: 12px;
  transition: all 0.3s;
}

.switch-wrapper:hover {
  background: #e9ecef;
  transform: translateY(-2px);
}

.switch-input {
  display: none;
}

.switch-slider {
  position: relative;
  width: 52px;
  height: 28px;
  background: #dfe6e9;
  border-radius: 14px;
  transition: all 0.3s;
}

.switch-slider:before {
  content: '';
  position: absolute;
  width: 24px;
  height: 24px;
  background: white;
  border-radius: 50%;
  top: 2px;
  left: 2px;
  transition: all 0.3s;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
}

.switch-input:checked + .switch-slider {
  background: #00b894;
}

.switch-input:checked + .switch-slider:before {
  transform: translateX(24px);
}

.switch-label {
  font-weight: 600;
  color: #2d3436;
  display: flex;
  align-items: center;
  gap: 8px;
  flex: 1;
}

.switch-icon {
  font-size: 1.2rem;
}

.switch-hint {
  color: #636e72;
  font-size: 0.9rem;
  margin-left: 68px;
  line-height: 1.4;
}

/* Form Actions */
.form-actions {
  display: flex;
  gap: 16px;
  justify-content: flex-end;
  padding-top: 32px;
  border-top: 2px solid #f1f2f6;
}

.btn-save {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 16px 32px;
  border-radius: 12px;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 10px;
  transition: all 0.3s;
}

.btn-save:hover {
  transform: translateY(-3px);
  box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
}

.btn-reset {
  background: white;
  color: #636e72;
  border: 2px solid #dfe6e9;
  padding: 16px 32px;
  border-radius: 12px;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 10px;
  transition: all 0.3s;
}

.btn-reset:hover {
  border-color: #3498db;
  color: #3498db;
  transform: translateY(-3px);
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
}

.btn-icon {
  font-size: 1.2rem;
}

/* Form Hint */
.form-hint {
  color: #636e72;
  font-size: 0.9rem;
  line-height: 1.4;
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
  z-index: 1000;
  animation: slideIn 0.3s ease-out;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
  min-width: 300px;
  text-align: center;
}

.toast.success {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
}

.toast.error {
  background: linear-gradient(135deg, #ff7675 0%, #d63031 100%);
}

@keyframes slideIn {
  from {
    transform: translateX(100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

/* Responsive Design */
@media (max-width: 1200px) {
  .form-grid {
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  }
}

@media (max-width: 768px) {
  .system-config-page {
    padding: 16px;
  }
  
  .config-container {
    padding: 24px;
  }
  
  .title-section h1 {
    font-size: 2rem;
  }
  
  .form-grid,
  .switches-grid {
    grid-template-columns: 1fr;
    gap: 24px;
  }
  
  .form-actions {
    flex-direction: column;
  }
  
  .btn-save,
  .btn-reset {
    width: 100%;
    justify-content: center;
  }
  
  .section-header h2 {
    font-size: 1.5rem;
  }
}

@media (max-width: 480px) {
  .title-section h1 {
    font-size: 1.8rem;
  }
  
  .config-container {
    padding: 16px;
  }
  
  .form-section {
    padding-bottom: 32px;
    margin-bottom: 32px;
  }
  
  .switch-hint {
    margin-left: 0;
    padding-left: 68px;
  }
}
</style>
