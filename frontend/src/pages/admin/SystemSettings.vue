<template>
  <div class="admin-system-settings">
    <!-- Loading State -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner"></div>
      <p>Cargando configuración del sistema...</p>
    </div>

    <template v-else>
      <!-- Header con info del sistema -->
      <div class="page-header">
        <div class="header-left">
          <div class="system-title">
            <h1 class="page-title">
              <span class="title-icon">⚙️</span>
              {{ systemConfig.system_name }}
            </h1>
            <div class="system-version">
              <span class="version-badge">v{{ systemConfig.system_version }}</span>
              <span class="system-host">{{ systemConfig.system_host }}</span>
            </div>
          </div>
          <p class="page-subtitle">
            {{ systemConfig.company_name }} • {{ systemConfig.company_address }}
          </p>
        </div>

        <div class="header-actions">
          <div class="status-badges">
            <div class="status-badge" :class="systemConfig.system_active ? 'active' : 'inactive'">
              <span class="status-dot"></span>
              {{ systemConfig.system_active ? 'ACTIVO' : 'INACTIVO' }}
            </div>
            <div class="status-badge" :class="systemConfig.maintenance_mode ? 'maintenance' : 'operational'">
              <span class="status-dot"></span>
              {{ systemConfig.maintenance_mode ? 'MANTENIMIENTO' : 'OPERATIVO' }}
            </div>
          </div>

          <div class="action-buttons">
            <button class="btn-save-all" @click="saveAllSettings" :disabled="!hasChanges || saving">
              <span v-if="saving" class="save-loading"></span>
              <span v-else>💾 Guardar Todo</span>
            </button>
            <button class="btn-refresh" @click="loadSystemConfig">🔄 Actualizar</button>
            <button class="btn-reset" @click="resetToDefaults" title="Restaurar valores por defecto">🔄 Reset</button>
          </div>
        </div>
      </div>

      <!-- Mensajes de estado -->
      <div v-if="successMessage" class="message-success">
        <span class="message-icon">✅</span>
        {{ successMessage }}
        <button class="message-close" @click="successMessage = ''">×</button>
      </div>
      <div v-if="errorMessage" class="message-error">
        <span class="message-icon">❌</span>
        {{ errorMessage }}
        <button class="message-close" @click="errorMessage = ''">×</button>
      </div>

      <!-- Pestañas de navegación -->
      <div class="settings-tabs">
        <button v-for="tab in tabs" :key="tab.id" class="tab-button"
          :class="{ active: activeTab === tab.id }" @click="activeTab = tab.id">
          <span class="tab-icon">{{ tab.icon }}</span>
          {{ tab.name }}
        </button>
      </div>

      <!-- Contenido de las pestañas -->
      <div class="tab-content">
        <!-- Pestaña 1: Información General -->
        <div v-if="activeTab === 'general'" class="tab-panel">
          <div class="section-card">
            <div class="section-header">
              <h2>🏢 Información General</h2>
              <p>Configuración básica del sistema</p>
            </div>
            <div class="section-content">
              <div class="form-grid">
                <div class="form-group">
                  <label class="form-label required"><span class="label-icon">🏷️</span>Nombre del Sistema</label>
                  <input type="text" v-model="systemConfig.system_name" @input="markAsChanged" placeholder="TapClic" class="form-input" required>
                  <p class="form-help">Nombre que aparece en toda la plataforma</p>
                </div>
                <div class="form-group">
                  <label class="form-label required"><span class="label-icon">📦</span>Versión del Sistema</label>
                  <input type="text" v-model="systemConfig.system_version" @input="markAsChanged" placeholder="1.0.0" class="form-input" required>
                  <p class="form-help">Versión actual del software (ej: 1.2.3)</p>
                </div>
                <div class="form-group">
                  <label class="form-label required"><span class="label-icon">🌐</span>Host del Sistema</label>
                  <input type="url" v-model="systemConfig.system_host" @input="markAsChanged" placeholder="https://tapclic.com" class="form-input" required>
                  <p class="form-help">URL base de la plataforma</p>
                </div>
                <div class="form-group">
                  <label class="form-label"><span class="label-icon">🏢</span>Nombre de la Empresa</label>
                  <input type="text" v-model="systemConfig.company_name" @input="markAsChanged" placeholder="Nombre de la empresa" class="form-input">
                </div>
                <div class="form-group">
                  <label class="form-label"><span class="label-icon">📍</span>Dirección de la Empresa</label>
                  <input type="text" v-model="systemConfig.company_address" @input="markAsChanged" placeholder="Dirección completa" class="form-input">
                </div>
                <div class="form-group">
                  <label class="form-label"><span class="label-icon">📧</span>Email de la Empresa</label>
                  <input type="email" v-model="systemConfig.company_email" @input="markAsChanged" placeholder="info@empresa.com" class="form-input">
                </div>
                <div class="form-group">
                  <label class="form-label"><span class="label-icon">📱</span>Teléfono de la Empresa</label>
                  <input type="text" v-model="systemConfig.company_phone" @input="markAsChanged" placeholder="+58 412-1234567" class="form-input">
                </div>
                <div class="form-group">
                  <label class="form-label"><span class="label-icon">🎯</span>Misión</label>
                  <textarea v-model="systemConfig.company_mission" @input="markAsChanged" placeholder="Nuestra misión..." class="form-textarea" rows="3"></textarea>
                </div>
                <div class="form-group">
                  <label class="form-label"><span class="label-icon">🔮</span>Visión</label>
                  <textarea v-model="systemConfig.company_vision" @input="markAsChanged" placeholder="Nuestra visión..." class="form-textarea" rows="3"></textarea>
                </div>
                <div class="form-group">
                  <label class="form-label"><span class="label-icon">📅</span>Años de experiencia</label>
                  <input type="text" v-model="systemConfig.company_years" @input="markAsChanged" placeholder="5+" class="form-input">
                </div>
                <div class="form-group">
                  <label class="form-label"><span class="label-icon">🎂</span>Año de fundación</label>
                  <input type="text" v-model="systemConfig.company_founded" @input="markAsChanged" placeholder="2020" class="form-input">
                </div>
                <div class="form-group">
                  <label class="form-label"><span class="label-icon">👥</span>Clientes satisfechos</label>
                  <input type="number" v-model="systemConfig.company_clients" @input="markAsChanged" placeholder="150" class="form-input">
                </div>
              </div>
            </div>
          </div>

          <!-- Estado del Sistema -->
          <div class="section-card">
            <div class="section-header">
              <h2>🖥️ Estado del Sistema</h2>
              <p>Control de operaciones del sistema</p>
            </div>
            <div class="section-content">
              <div class="toggle-grid">
                <div class="toggle-item">
                  <div class="toggle-info">
                    <h4>Sistema Activo</h4>
                    <p>Activar/desactivar todo el sistema. Si está inactivo, nadie podrá acceder.</p>
                  </div>
                  <div class="toggle-control">
                    <label class="toggle-switch large">
                      <input type="checkbox" v-model="systemConfig.system_active" true-value="1" false-value="0" @change="markAsChanged">
                      <span class="toggle-slider"></span>
                    </label>
                    <span class="toggle-text" :class="systemConfig.system_active ? 'active' : 'inactive'">
                      {{ systemConfig.system_active ? 'ACTIVADO' : 'DESACTIVADO' }}
                    </span>
                  </div>
                </div>
                <div class="toggle-item">
                  <div class="toggle-info">
                    <h4>Modo Mantenimiento</h4>
                    <p>Los usuarios verán un mensaje de mantenimiento en lugar de la plataforma.</p>
                  </div>
                  <div class="toggle-control">
                    <label class="toggle-switch large">
                      <input type="checkbox" v-model="systemConfig.maintenance_mode" true-value="1" false-value="0" @change="markAsChanged">
                      <span class="toggle-slider"></span>
                    </label>
                    <span class="toggle-text" :class="systemConfig.maintenance_mode ? 'maintenance' : 'normal'">
                      {{ systemConfig.maintenance_mode ? 'ACTIVADO' : 'DESACTIVADO' }}
                    </span>
                  </div>
                </div>
                <div class="toggle-item">
                  <div class="toggle-info">
                    <h4>Permitir Registro de Usuarios</h4>
                    <p>Permitir que nuevos usuarios se registren en la plataforma.</p>
                  </div>
                  <div class="toggle-control">
                    <label class="toggle-switch large">
                      <input type="checkbox" v-model="systemConfig.allow_user_registration" true-value="1" false-value="0" @change="markAsChanged">
                      <span class="toggle-slider"></span>
                    </label>
                    <span class="toggle-text" :class="systemConfig.allow_user_registration ? 'active' : 'inactive'">
                      {{ systemConfig.allow_user_registration ? 'PERMITIDO' : 'BLOQUEADO' }}
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Pestaña 2: Apariencia -->
        <div v-if="activeTab === 'appearance'" class="tab-panel">
          <div class="section-card">
            <div class="section-header">
              <h2>🎨 Apariencia</h2>
              <p>Personaliza la imagen de la plataforma</p>
            </div>
            <div class="section-content">
              <div class="upload-section">
                <h3>🖼️ Logo y Favicon</h3>
                <div class="upload-grid">
                  <div class="upload-card">
                    <div class="upload-header">
                      <h4>Logo del Sistema</h4>
                      <p>Se muestra en el header de la plataforma (recomendado: 200x60px)</p>
                    </div>
                    <div class="upload-area" @click="triggerLogoUpload">
                      <div class="upload-preview">
                        <img v-if="logoPreview || systemConfig.system_logo" :src="getImageUrl(logoPreview || systemConfig.system_logo)" alt="Logo preview" class="preview-image" @error="handleImageError">
                        <div v-else class="upload-placeholder">
                          <span class="upload-icon">🖼️</span>
                          <p>Haz clic para subir logo</p>
                          <small>PNG, JPG o SVG (max 2MB)</small>
                        </div>
                      </div>
                      <input type="file" ref="logoInput" @change="handleLogoUpload" accept="image/png,image/jpeg,image/jpg,image/svg+xml" class="hidden-input">
                    </div>
                    <div v-if="logoFile" class="upload-controls">
                      <div class="file-info">
                        <span class="file-name">{{ logoFile.name }}</span>
                        <span class="file-size">{{ formatFileSize(logoFile.size) }}</span>
                      </div>
                      <div class="upload-actions">
                        <button class="btn-cancel" @click="cancelLogoUpload">Cancelar</button>
                        <button class="btn-upload" @click="uploadFile('logo')" :disabled="uploadingLogo">{{ uploadingLogo ? 'Subiendo...' : 'Subir Logo' }}</button>
                      </div>
                    </div>
                    <div v-else-if="systemConfig.system_logo" class="current-file">
                      <p><strong>Logo actual:</strong> {{ getFileName(systemConfig.system_logo) }}</p>
                      <button class="btn-remove" @click="removeLogo" title="Eliminar logo">🗑️ Eliminar</button>
                    </div>
                  </div>
                  <div class="upload-card">
                    <div class="upload-header">
                      <h4>Favicon</h4>
                      <p>Icono que aparece en la pestaña del navegador (32x32px)</p>
                    </div>
                    <div class="upload-area" @click="triggerFaviconUpload">
                      <div class="upload-preview favicon-preview">
                        <img v-if="faviconPreview || systemConfig.system_favicon" :src="getImageUrl(faviconPreview || systemConfig.system_favicon)" alt="Favicon preview" class="preview-image" @error="handleImageError">
                        <div v-else class="upload-placeholder">
                          <span class="upload-icon">📌</span>
                          <p>Haz clic para subir favicon</p>
                          <small>PNG o ICO (32x32px)</small>
                        </div>
                      </div>
                      <input type="file" ref="faviconInput" @change="handleFaviconUpload" accept="image/png,image/x-icon" class="hidden-input">
                    </div>
                    <div v-if="faviconFile" class="upload-controls">
                      <div class="file-info">
                        <span class="file-name">{{ faviconFile.name }}</span>
                        <span class="file-size">{{ formatFileSize(faviconFile.size) }}</span>
                      </div>
                      <div class="upload-actions">
                        <button class="btn-cancel" @click="cancelFaviconUpload">Cancelar</button>
                        <button class="btn-upload" @click="uploadFile('favicon')" :disabled="uploadingFavicon">{{ uploadingFavicon ? 'Subiendo...' : 'Subir Favicon' }}</button>
                      </div>
                    </div>
                    <div v-else-if="systemConfig.system_favicon" class="current-file">
                      <p><strong>Favicon actual:</strong> {{ getFileName(systemConfig.system_favicon) }}</p>
                      <button class="btn-remove" @click="removeFavicon" title="Eliminar favicon">🗑️ Eliminar</button>
                    </div>
                  </div>
                </div>
              </div>
              <div class="theme-section">
                <h3>🎨 Color del Tema</h3>
                <div class="theme-control">
                  <label class="theme-label">
                    Color Principal
                    <div class="color-picker">
                      <input type="color" v-model="systemConfig.theme_color" @change="markAsChanged" class="color-input">
                      <input type="text" v-model="systemConfig.theme_color" @input="markAsChanged" placeholder="#409EFF" class="color-text" pattern="^#[0-9A-Fa-f]{6}$">
                    </div>
                  </label>
                  <div class="color-preview-area">
                    <div class="color-preview" :style="{ backgroundColor: systemConfig.theme_color }"></div>
                    <div class="color-examples">
                      <div class="color-example" style="background-color: #409EFF;" @click="systemConfig.theme_color = '#409EFF'; markAsChanged()"></div>
                      <div class="color-example" style="background-color: #667eea;" @click="systemConfig.theme_color = '#667eea'; markAsChanged()"></div>
                      <div class="color-example" style="background-color: #00b894;" @click="systemConfig.theme_color = '#00b894'; markAsChanged()"></div>
                      <div class="color-example" style="background-color: #ff6b6b;" @click="systemConfig.theme_color = '#ff6b6b'; markAsChanged()"></div>
                      <div class="color-example" style="background-color: #fdcb6e;" @click="systemConfig.theme_color = '#fdcb6e'; markAsChanged()"></div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Pestaña 3: Configuración Regional -->
        <div v-if="activeTab === 'regional'" class="tab-panel">
          <div class="section-card">
            <div class="section-header">
              <h2>🌍 Configuración Regional</h2>
              <p>Ajustes de idioma, moneda y zona horaria</p>
            </div>
            <div class="section-content">
              <div class="form-grid">
                <div class="form-group">
                  <label class="form-label"><span class="label-icon">🌎</span>Idioma por Defecto</label>
                  <select v-model="systemConfig.default_language" @change="markAsChanged" class="form-select">
                    <option value="es">Español</option>
                    <option value="en">English</option>
                    <option value="pt">Português</option>
                    <option value="fr">Français</option>
                  </select>
                  <p class="form-help">Idioma principal de la plataforma</p>
                </div>
                <div class="form-group">
                  <label class="form-label"><span class="label-icon">🕐</span>Zona Horaria</label>
                  <select v-model="systemConfig.timezone" @change="markAsChanged" class="form-select">
                    <option value="America/Caracas">America/Caracas (Venezuela)</option>
                    <option value="America/Bogota">America/Bogota (Colombia)</option>
                    <option value="America/Mexico_City">America/Mexico_City (México)</option>
                    <option value="America/New_York">America/New_York (EST)</option>
                    <option value="America/Los_Angeles">America/Los_Angeles (PST)</option>
                    <option value="Europe/Madrid">Europe/Madrid (España)</option>
                    <option value="UTC">UTC</option>
                  </select>
                </div>
                <div class="form-group">
                  <label class="form-label"><span class="label-icon">💰</span>Moneda</label>
                  <select v-model="systemConfig.currency" @change="markAsChanged" class="form-select">
                    <option value="USD">USD - Dólar Americano</option>
                    <option value="EUR">EUR - Euro</option>
                    <option value="COP">COP - Peso Colombiano</option>
                    <option value="MXN">MXN - Peso Mexicano</option>
                    <option value="VES">VES - Bolívar Soberano</option>
                    <option value="BRL">BRL - Real Brasileño</option>
                    <option value="PEN">PEN - Sol Peruano</option>
                    <option value="CLP">CLP - Peso Chileno</option>
                    <option value="ARS">ARS - Peso Argentino</option>
                  </select>
                  <p class="form-help">Moneda para precios y pagos</p>
                </div>
                <div class="form-group">
                  <label class="form-label"><span class="label-icon">📄</span>Items por Página</label>
                  <input type="number" v-model.number="systemConfig.items_per_page" @input="markAsChanged" min="5" max="100" step="5" class="form-input">
                  <p class="form-help">Número de items mostrados en listas (5-100)</p>
                </div>
              </div>
            </div>
          </div>
          <div class="section-card">
            <div class="section-header">
              <h2>📞 Información de Contacto</h2>
              <p>Datos de contacto para soporte</p>
            </div>
            <div class="section-content">
              <div class="form-grid">
                <div class="form-group">
                  <label class="form-label"><span class="label-icon">✉️</span>Email de Soporte</label>
                  <input type="email" v-model="systemConfig.support_email" @input="markAsChanged" placeholder="soporte@tapclic.com" class="form-input">
                  <p class="form-help">Email para contacto y soporte técnico</p>
                </div>
                <div class="form-group">
                  <label class="form-label"><span class="label-icon">📞</span>Teléfono de Soporte</label>
                  <input type="tel" v-model="systemConfig.support_phone" @input="markAsChanged" placeholder="+58 412 1234567" class="form-input">
                  <p class="form-help">Teléfono para contacto y soporte</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Pestaña 4: Seguridad -->
        <div v-if="activeTab === 'security'" class="tab-panel">
          <div class="section-card">
            <div class="section-header">
              <h2>🔒 Seguridad</h2>
              <p>Configuración de seguridad del sistema</p>
            </div>
            <div class="section-content">
              <div class="security-grid">
                <div class="security-item">
                  <label class="security-label"><span class="label-icon">🔐</span>Intentos Máximos de Login</label>
                  <div class="security-control">
                    <input type="number" v-model.number="systemConfig.max_login_attempts" @input="markAsChanged" min="1" max="10" class="security-input">
                    <span class="security-unit">intentos</span>
                  </div>
                  <p class="security-help">Intentos fallidos antes de bloquear la cuenta (1-10)</p>
                </div>
                <div class="security-item">
                  <label class="security-label"><span class="label-icon">⏱️</span>Tiempo de Sesión</label>
                  <div class="security-control">
                    <input type="number" v-model.number="systemConfig.session_timeout_minutes" @input="markAsChanged" min="5" max="1440" class="security-input">
                    <span class="security-unit">minutos</span>
                  </div>
                  <p class="security-help">Tiempo antes de expirar la sesión inactiva (5-1440 min)</p>
                </div>
                <div class="security-item">
                  <label class="security-label"><span class="label-icon">📅</span>Expiración de Contraseña</label>
                  <div class="security-control">
                    <input type="number" v-model.number="systemConfig.password_expiration_days" @input="markAsChanged" min="0" max="365" class="security-input">
                    <span class="security-unit">días</span>
                  </div>
                  <p class="security-help">Días antes de requerir cambio de contraseña (0 = nunca)</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Pestaña 5: Funcionalidades -->
        <div v-if="activeTab === 'features'" class="tab-panel">
          <div class="section-card">
            <div class="section-header">
              <h2>🧩 Funcionalidades del Sistema</h2>
              <p>Activa o desactiva módulos de la plataforma</p>
            </div>
            <div class="section-content">
              <div class="toggle-grid">
                <div class="toggle-item">
                  <div class="toggle-info">
                    <h4>💰 Wallet / Billetera</h4>
                    <p>Permite a los usuarios recargar saldo y pagar con wallet</p>
                  </div>
                  <div class="toggle-control">
                    <label class="toggle-switch large">
                      <input type="checkbox" v-model="systemConfig.wallet_enabled" true-value="1" false-value="0" @change="markAsChanged">
                      <span class="toggle-slider"></span>
                    </label>
                    <span class="toggle-text" :class="systemConfig.wallet_enabled ? 'active' : 'inactive'">
                      {{ systemConfig.wallet_enabled ? 'ACTIVADO' : 'DESACTIVADO' }}
                    </span>
                  </div>
                </div>
                <div class="toggle-item">
                  <div class="toggle-info">
                    <h4>⭐ Reseñas / Calificaciones</h4>
                    <p>Permite a los usuarios dejar reseñas después de un servicio</p>
                  </div>
                  <div class="toggle-control">
                    <label class="toggle-switch large">
                      <input type="checkbox" v-model="systemConfig.reviews_enabled" true-value="1" false-value="0" @change="markAsChanged">
                      <span class="toggle-slider"></span>
                    </label>
                    <span class="toggle-text" :class="systemConfig.reviews_enabled ? 'active' : 'inactive'">
                      {{ systemConfig.reviews_enabled ? 'ACTIVADO' : 'DESACTIVADO' }}
                    </span>
                  </div>
                </div>
                <div class="toggle-item">
                  <div class="toggle-info">
                    <h4>💬 Chat / Mensajería</h4>
                    <p>Permite la comunicación entre usuarios y proveedores</p>
                  </div>
                  <div class="toggle-control">
                    <label class="toggle-switch large">
                      <input type="checkbox" v-model="systemConfig.chat_enabled" true-value="1" false-value="0" @change="markAsChanged">
                      <span class="toggle-slider"></span>
                    </label>
                    <span class="toggle-text" :class="systemConfig.chat_enabled ? 'active' : 'inactive'">
                      {{ systemConfig.chat_enabled ? 'ACTIVADO' : 'DESACTIVADO' }}
                    </span>
                  </div>
                </div>
                <div class="toggle-item">
                  <div class="toggle-info">
                    <h4>🎫 Sistema de Tickets</h4>
                    <p>Permite a los usuarios abrir tickets de soporte</p>
                  </div>
                  <div class="toggle-control">
                    <label class="toggle-switch large">
                      <input type="checkbox" v-model="systemConfig.tickets_enabled" true-value="1" false-value="0" @change="markAsChanged">
                      <span class="toggle-slider"></span>
                    </label>
                    <span class="toggle-text" :class="systemConfig.tickets_enabled ? 'active' : 'inactive'">
                      {{ systemConfig.tickets_enabled ? 'ACTIVADO' : 'DESACTIVADO' }}
                    </span>
                  </div>
                </div>
                <div class="toggle-item">
                  <div class="toggle-info">
                    <h4>📊 Panel de Analytics</h4>
                    <p>Muestra estadísticas avanzadas en el dashboard</p>
                  </div>
                  <div class="toggle-control">
                    <label class="toggle-switch large">
                      <input type="checkbox" v-model="systemConfig.analytics_enabled" true-value="1" false-value="0" @change="markAsChanged">
                      <span class="toggle-slider"></span>
                    </label>
                    <span class="toggle-text" :class="systemConfig.analytics_enabled ? 'active' : 'inactive'">
                      {{ systemConfig.analytics_enabled ? 'ACTIVADO' : 'DESACTIVADO' }}
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Pestaña 6: Hitos de la Empresa -->
        <div v-if="activeTab === 'milestones'" class="tab-panel">
          <div class="section-card">
            <div class="section-header">
              <h2>📅 Hitos de la Empresa</h2>
              <p>Gestiona la línea de tiempo que aparece en la página "Nuestra Empresa"</p>
              <button class="btn-add" @click="addMilestone">+ Agregar Hito</button>
            </div>
            <div class="section-content">
              <div v-if="milestones.length === 0" class="empty-state">
                <p>No hay hitos registrados. Agrega el primero.</p>
              </div>
              <div v-else class="milestones-list">
                <div v-for="(m, i) in milestones" :key="m.id || i" class="milestone-item">
                  <div class="milestone-header">
                    <span class="milestone-icon">{{ m.icon || '📅' }}</span>
                    <input v-model="m.year" placeholder="Año" class="milestone-year" @change="markAsChanged">
                    <input v-model="m.title" placeholder="Título" class="milestone-title" @change="markAsChanged">
                    <div class="milestone-actions">
                      <button class="btn-sm" @click="toggleMilestone(m)" :title="m.is_active ? 'Desactivar' : 'Activar'">
                        {{ m.is_active ? '👁️' : '🚫' }}
                      </button>
                      <button class="btn-sm btn-danger" @click="deleteMilestone(m, i)">🗑️</button>
                    </div>
                  </div>
                  <textarea v-model="m.description" placeholder="Descripción del hito" class="milestone-desc" rows="2" @change="markAsChanged"></textarea>
                  <div class="milestone-footer">
                    <label>Icono:</label>
                    <select v-model="m.icon" @change="markAsChanged">
                      <option value="🚀">🚀 Lanzamiento</option>
                      <option value="👥">👥 Clientes</option>
                      <option value="📦">📦 Expansión</option>
                      <option value="💡">💡 Innovación</option>
                      <option value="🏆">🏆 Logro</option>
                      <option value="📅">📅 General</option>
                    </select>
                    <label>Orden:</label>
                    <input type="number" v-model.number="m.sort_order" min="0" class="milestone-order" @change="markAsChanged">
                  </div>
                </div>
                <button class="btn-save" @click="saveMilestones" :disabled="savingMilestones">
                  {{ savingMilestones ? 'Guardando...' : '💾 Guardar Hitos' }}
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Footer con acciones -->
      <div class="action-footer" v-if="hasChanges">
        <div class="footer-left">
          <span class="changes-indicator">⚠️ Tienes cambios sin guardar</span>
        </div>
        <div class="footer-right">
          <button class="btn-discard" @click="resetChanges">Descartar Cambios</button>
          <button class="btn-save" @click="saveAllSettings" :disabled="saving">
            <span v-if="saving" class="save-loading"></span>
            <span v-else>💾 Guardar Configuración</span>
          </button>
        </div>
      </div>
    </template>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useAuthStore } from '@/stores/authStore'
import api from '@/axios'
import { getImageUrl } from '@/utils/imageHelper'

const authStore = useAuthStore()

// Estados
const loading = ref(true)
const saving = ref(false)
const activeTab = ref('general')
const successMessage = ref('')
const errorMessage = ref('')
const logoInput = ref(null)
const faviconInput = ref(null)
const logoFile = ref(null)
const faviconFile = ref(null)
const logoPreview = ref(null)
const faviconPreview = ref(null)
const uploadingLogo = ref(false)
const uploadingFavicon = ref(false)

const systemConfig = ref({
  id: 1, system_name: 'TapClic', system_host: '', system_active: 1, system_version: '1.0.0',
  system_logo: '', system_favicon: '', default_language: 'es', timezone: 'UTC', currency: 'USD',
  support_email: '', support_phone: '', company_name: '', company_address: '',
  company_phone: '', company_email: '', company_mission: '', company_vision: '',
  company_years: '5+', company_founded: '2020', company_clients: 150,
  maintenance_mode: 0, max_login_attempts: 5, password_expiration_days: 90,
  session_timeout_minutes: 30, items_per_page: 20, theme_color: '#409EFF',
  allow_user_registration: 1, wallet_enabled: 1, reviews_enabled: 1,
  chat_enabled: 1, tickets_enabled: 1, analytics_enabled: 1,
  extra_json: '{}', created_at: null, updated_at: null
})

const originalConfig = ref({})

// ✅ Tabs - Eliminada "Estadísticas" (duplicada en DashboardAdmin), agregada "Funcionalidades"
const tabs = [
  { id: 'general', name: 'General', icon: '⚙️' },
  { id: 'appearance', name: 'Apariencia', icon: '🎨' },
  { id: 'regional', name: 'Regional', icon: '🌍' },
  { id: 'security', name: 'Seguridad', icon: '🔒' },
  { id: 'features', name: 'Funcionalidades', icon: '🧩' },
  { id: 'milestones', name: 'Hitos', icon: '📅' }
]

const hasChanges = computed(() =>
  JSON.stringify(systemConfig.value) !== JSON.stringify(originalConfig.value) || logoFile.value || faviconFile.value
)

onMounted(loadSystemConfig)

async function loadSystemConfig() {
  try {
    loading.value = true
    const response = await api.get('/admin/system-config', {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    const data = response.data
    const booleanFields = ['system_active', 'maintenance_mode', 'allow_user_registration', 'wallet_enabled', 'reviews_enabled', 'chat_enabled', 'tickets_enabled', 'analytics_enabled']
    const numericFields = ['max_login_attempts', 'password_expiration_days', 'session_timeout_minutes', 'items_per_page']
    booleanFields.forEach(f => { if (data[f] !== undefined) data[f] = data[f] ? 1 : 0 })
    numericFields.forEach(f => { if (data[f] !== undefined) data[f] = parseInt(data[f]) || 0 })
    if (data.extra_json && typeof data.extra_json === 'object') data.extra_json = JSON.stringify(data.extra_json)
    else if (!data.extra_json || data.extra_json.trim() === '') data.extra_json = '{}'
    Object.assign(systemConfig.value, data)
    originalConfig.value = JSON.parse(JSON.stringify(systemConfig.value))
  } catch (error) {
    showError('Error al cargar la configuración del sistema')
  } finally {
    await loadMilestones()
    loading.value = false
  }
}

function markAsChanged() {}
function resetChanges() {
  if (confirm('¿Descartar todos los cambios?')) {
    systemConfig.value = JSON.parse(JSON.stringify(originalConfig.value))
    logoFile.value = null; faviconFile.value = null; logoPreview.value = null; faviconPreview.value = null
  }
}
function resetToDefaults() {
  if (confirm('¿Restaurar todos los valores por defecto?')) {
    Object.assign(systemConfig.value, {
      system_name: 'TapClic', system_host: '', system_active: 1, system_version: '1.0.0',
      system_logo: '', system_favicon: '', default_language: 'es', timezone: 'UTC', currency: 'USD',
      support_email: '', support_phone: '', company_name: '', company_address: '',
      company_phone: '', company_email: '', company_mission: '', company_vision: '',
      company_years: '5+', company_founded: '2020', company_clients: 150,
      maintenance_mode: 0, max_login_attempts: 5, password_expiration_days: 90,
      session_timeout_minutes: 30, items_per_page: 20, theme_color: '#409EFF',
      allow_user_registration: 1, wallet_enabled: 1, reviews_enabled: 1,
      chat_enabled: 1, tickets_enabled: 1, analytics_enabled: 1, extra_json: '{}'
    })
    markAsChanged()
  }
}

function triggerLogoUpload() { logoInput.value.click() }
function triggerFaviconUpload() { faviconInput.value.click() }

function handleFileUpload(event, type) {
  const file = event.target.files[0]
  if (!file || !validateImageFile(file)) return
  if (type === 'logo') { logoFile.value = file; readPreview(file, 'logo') }
  else { faviconFile.value = file; readPreview(file, 'favicon') }
  markAsChanged()
}
function handleLogoUpload(e) { handleFileUpload(e, 'logo') }
function handleFaviconUpload(e) { handleFileUpload(e, 'favicon') }

function readPreview(file, type) {
  const reader = new FileReader()
  reader.onload = (e) => { if (type === 'logo') logoPreview.value = e.target.result; else faviconPreview.value = e.target.result }
  reader.readAsDataURL(file)
}
function validateImageFile(file) {
  if (file.size > 2 * 1024 * 1024) { showError('La imagen no debe superar 2MB'); return false }
  return true
}
function cancelLogoUpload() { logoFile.value = null; logoPreview.value = null; logoInput.value.value = '' }
function cancelFaviconUpload() { faviconFile.value = null; faviconPreview.value = null; faviconInput.value.value = '' }

async function uploadFile(type) {
  const file = type === 'logo' ? logoFile.value : faviconFile.value
  const endpoint = type === 'logo' ? '/admin/upload-logo' : '/admin/upload-favicon'
  const uploadingRef = type === 'logo' ? uploadingLogo : uploadingFavicon
  if (!file) return
  try {
    uploadingRef.value = true
    const formData = new FormData(); formData.append('file', file)
    const response = await api.post(endpoint, formData, { headers: { Authorization: `Bearer ${authStore.token}` } })
    systemConfig.value[type === 'logo' ? 'system_logo' : 'system_favicon'] = response.data.url
    if (type === 'logo') cancelLogoUpload(); else cancelFaviconUpload()
    showSuccess(`${type === 'logo' ? 'Logo' : 'Favicon'} actualizado correctamente`)
  } catch (error) {
    showError(`Error al subir: ${error.response?.data?.error || error.message}`)
  } finally { uploadingRef.value = false }
}

function removeLogo() { if (confirm('¿Eliminar logo?')) { systemConfig.value.system_logo = ''; markAsChanged() } }
function removeFavicon() { if (confirm('¿Eliminar favicon?')) { systemConfig.value.system_favicon = ''; markAsChanged() } }

async function saveAllSettings() {
  try {
    saving.value = true
    await api.put('/admin/system-config', { ...systemConfig.value }, { headers: { Authorization: `Bearer ${authStore.token}` } })
    originalConfig.value = JSON.parse(JSON.stringify(systemConfig.value))
    showSuccess('Configuración guardada correctamente')
  } catch (error) {
    showError(`Error al guardar: ${error.response?.data?.error || error.message}`)
  } finally { saving.value = false }
}

function getFileName(path) { return path ? path.split('/').pop() || path : '' }
function formatFileSize(bytes) {
  if (bytes === 0) return '0 Bytes'
  const k = 1024, sizes = ['Bytes', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
}
function handleImageError(e) { e.target.src = '/img/default-image.png' }
function showSuccess(msg) { successMessage.value = msg; setTimeout(() => successMessage.value = '', 5000) }
function showError(msg) { errorMessage.value = msg; setTimeout(() => errorMessage.value = '', 8000) }

// ========== HITOS (MILESTONES) ==========
const milestones = ref([])
const savingMilestones = ref(false)

async function loadMilestones() {
  try {
    const response = await api.get('/admin/milestones', {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    milestones.value = response.data || []
  } catch (error) {
    console.error('Error cargando hitos:', error)
  }
}

function addMilestone() {
  milestones.value.push({
    id: null,
    year: new Date().getFullYear().toString(),
    title: '',
    description: '',
    icon: '📅',
    sort_order: milestones.value.length,
    is_active: 1
  })
}

function toggleMilestone(m) {
  m.is_active = m.is_active ? 0 : 1
  markAsChanged()
}

async function deleteMilestone(m, index) {
  if (!confirm('¿Eliminar este hito?')) return
  if (m.id) {
    await api.delete(`/admin/milestones/${m.id}`, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
  }
  milestones.value.splice(index, 1)
}

async function saveMilestones() {
  savingMilestones.value = true
  try {
    for (const m of milestones.value) {
      if (m.id) {
        await api.put(`/admin/milestones/${m.id}`, m, {
          headers: { Authorization: `Bearer ${authStore.token}` }
        })
      } else {
        const res = await api.post('/admin/milestones', m, {
          headers: { Authorization: `Bearer ${authStore.token}` }
        })
        m.id = res.data.id
      }
    }
    showSuccess('Hitos guardados correctamente')
  } catch (error) {
    showError('Error al guardar hitos')
  } finally {
    savingMilestones.value = false
  }
}

</script>


<style scoped>
/* Estilos CSS completos - Mantengo los que ya tenía y agrego los nuevos */
/* ... (mantengo todos los estilos CSS anteriores) ... */

/* Tabs */
.settings-tabs {
  display: flex;
  gap: 8px;
  margin-bottom: 32px;
  border-bottom: 2px solid #e2e8f0;
  padding-bottom: 8px;
  overflow-x: auto;
}

.tab-button {
  padding: 12px 24px;
  border: none;
  background: none;
  border-radius: 12px 12px 0 0;
  font-weight: 600;
  color: #636e72;
  cursor: pointer;
  transition: all 0.3s;
  display: flex;
  align-items: center;
  gap: 8px;
  white-space: nowrap;
}

.tab-button:hover {
  background: #f1f5f9;
  color: #2d3436;
}

.tab-button.active {
  background: #667eea;
  color: white;
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
}

.tab-icon {
  font-size: 1.2rem;
}

.tab-content {
  margin-bottom: 40px;
}

.tab-panel {
  animation: fadeIn 0.3s ease-out;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
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
  font-weight: 600;
  color: #2d3436;
  display: flex;
  align-items: center;
  gap: 8px;
}

.form-label.required::after {
  content: '*';
  color: #ff6b6b;
  margin-left: 4px;
}

.form-input, .form-select {
  padding: 14px 16px;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  font-size: 1rem;
  background: white;
  transition: all 0.3s;
}

.form-input:focus, .form-select:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.form-input[type="number"] {
  -moz-appearance: textfield;
}

.form-input[type="number"]::-webkit-outer-spin-button,
.form-input[type="number"]::-webkit-inner-spin-button {
  -webkit-appearance: none;
  margin: 0;
}

.form-help {
  color: #636e72;
  font-size: 0.9rem;
  margin-top: 4px;
}

/* Upload Section */
.upload-section {
  margin-bottom: 32px;
}

.upload-section h3 {
  color: #2d3436;
  margin-bottom: 20px;
  font-size: 1.2rem;
}

.upload-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 24px;
}

.upload-card {
  background: #f8fafc;
  border-radius: 16px;
  padding: 24px;
  border: 2px solid #e2e8f0;
}

.upload-header h4 {
  color: #2d3436;
  margin-bottom: 4px;
}

.upload-header p {
  color: #636e72;
  font-size: 0.9rem;
  margin-bottom: 20px;
}

.upload-area {
  border: 3px dashed #cbd5e1;
  border-radius: 12px;
  padding: 40px 20px;
  display: flex;
  justify-content: center;
  align-items: center;
  cursor: pointer;
  transition: all 0.3s;
  margin-bottom: 16px;
  min-height: 200px;
}

.upload-area:hover {
  border-color: #667eea;
  background: rgba(102, 126, 234, 0.05);
}

.upload-preview {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
}

.favicon-preview {
  width: 64px;
  height: 64px;
}

.preview-image {
  max-width: 200px;
  max-height: 80px;
  object-fit: contain;
}

.upload-placeholder {
  text-align: center;
}

.upload-icon {
  font-size: 3rem;
  display: block;
  margin-bottom: 12px;
  color: #94a3b8;
}

.hidden-input {
  display: none;
}

.upload-controls {
  background: white;
  padding: 16px;
  border-radius: 12px;
  border: 2px solid #e2e8f0;
  margin-top: 16px;
}

.file-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
  padding-bottom: 12px;
  border-bottom: 1px solid #e2e8f0;
}

.file-name {
  font-weight: 600;
  color: #2d3436;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 70%;
}

.file-size {
  color: #636e72;
  font-size: 0.9rem;
}

.upload-actions {
  display: flex;
  gap: 12px;
}

.btn-cancel, .btn-upload, .btn-remove {
  flex: 1;
  padding: 12px 16px;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  border: none;
}

.btn-cancel {
  background: #f1f5f9;
  color: #4a5568;
  border: 2px solid #e2e8f0;
}

.btn-cancel:hover {
  background: #e2e8f0;
  color: #2d3436;
}

.btn-upload {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.btn-upload:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(102, 126, 234, 0.3);
}

.btn-upload:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-remove {
  background: #ffeaea;
  color: #dc2626;
  border: 2px solid #fecaca;
  margin-top: 8px;
}

.btn-remove:hover {
  background: #fecaca;
}

.current-file {
  margin-top: 16px;
  padding: 12px;
  background: #f1f5f9;
  border-radius: 8px;
}

.current-file p {
  margin: 0 0 8px 0;
  color: #4a5568;
}

/* Theme Section */
.theme-section {
  margin-top: 32px;
}

.theme-section h3 {
  color: #2d3436;
  margin-bottom: 20px;
  font-size: 1.2rem;
}

.theme-control {
  display: flex;
  flex-direction: column;
  gap: 16px;
  max-width: 400px;
}

.theme-label {
  font-weight: 600;
  color: #2d3436;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.color-picker {
  display: flex;
  gap: 12px;
  align-items: center;
}

.color-input {
  width: 60px;
  height: 60px;
  border: none;
  border-radius: 12px;
  cursor: pointer;
  border: 2px solid #e2e8f0;
}

.color-text {
  flex: 1;
  padding: 14px 16px;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  font-family: monospace;
  font-size: 1rem;
}

.color-text:focus {
  outline: none;
  border-color: #667eea;
}

.color-preview-area {
  display: flex;
  align-items: center;
  gap: 20px;
}

.color-preview {
  width: 100px;
  height: 60px;
  border-radius: 12px;
  border: 2px solid #e2e8f0;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.color-examples {
  display: flex;
  gap: 10px;
}

.color-example {
  width: 30px;
  height: 30px;
  border-radius: 6px;
  cursor: pointer;
  border: 2px solid white;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
  transition: transform 0.2s;
}

.color-example:hover {
  transform: scale(1.1);
}

/* Security Grid */
.security-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 24px;
  margin-bottom: 32px;
}

.security-item {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.security-label {
  font-weight: 600;
  color: #2d3436;
  display: flex;
  align-items: center;
  gap: 8px;
}

.security-control {
  display: flex;
  align-items: center;
  gap: 12px;
}

.security-input {
  padding: 14px 16px;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  font-size: 1rem;
  background: white;
  width: 100px;
}

.security-unit {
  color: #636e72;
  font-weight: 600;
  min-width: 60px;
}

.security-help {
  color: #636e72;
  font-size: 0.9rem;
}

/* Advanced Security */
.advanced-security {
  margin-top: 32px;
  padding-top: 32px;
  border-top: 2px solid #e2e8f0;
}

.advanced-security h3 {
  color: #2d3436;
  margin-bottom: 20px;
  font-size: 1.2rem;
}

.json-editor {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.json-label {
  font-weight: 600;
  color: #2d3436;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.json-help {
  font-weight: normal;
  color: #636e72;
  font-size: 0.9rem;
}

.json-container {
  position: relative;
}

.json-textarea {
  width: 100%;
  padding: 16px;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
  font-size: 0.9rem;
  line-height: 1.5;
  background: #f8fafc;
  resize: vertical;
  min-height: 150px;
}

.json-textarea:focus {
  outline: none;
  border-color: #667eea;
  background: white;
}

.json-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 12px;
}

.btn-json-format {
  padding: 8px 16px;
  background: #f1f5f9;
  color: #4a5568;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-json-format:hover {
  background: #e2e8f0;
  color: #2d3436;
}

.json-status {
  font-size: 0.9rem;
  font-weight: 600;
  padding: 4px 12px;
  border-radius: 20px;
}

.json-status.valid {
  background: #d4edda;
  color: #155724;
}

.json-status.invalid {
  background: #f8d7da;
  color: #721c24;
}

/* Stats Grid */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 20px;
  margin-bottom: 24px;
}

.stat-card {
  background: white;
  border: 2px solid #e2e8f0;
  border-radius: 16px;
  padding: 24px;
  display: flex;
  align-items: center;
  gap: 20px;
  transition: all 0.3s;
}

.stat-card:hover {
  transform: translateY(-5px);
  border-color: #667eea;
  box-shadow: 0 10px 25px rgba(102, 126, 234, 0.1);
}

.stat-card.primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  color: white;
}

.stat-card.primary .stat-value,
.stat-card.primary .stat-subtext {
  color: white;
}

.stat-icon {
  font-size: 2.5rem;
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(102, 126, 234, 0.1);
  border-radius: 12px;
  color: #667eea;
}

.stat-card.primary .stat-icon {
  background: rgba(255, 255, 255, 0.2);
  color: white;
}

.stat-content {
  flex: 1;
}

.stat-content h4 {
  font-size: 0.9rem;
  color: #636e72;
  margin-bottom: 4px;
  font-weight: 600;
}

.stat-card.primary h4 {
  color: rgba(255, 255, 255, 0.9);
}

.stat-value {
  font-size: 1.8rem;
  font-weight: 700;
  color: #2d3436;
  margin-bottom: 4px;
}

.stat-subtext {
  font-size: 0.8rem;
  color: #94a3b8;
}

.stats-loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 20px;
}

.loading-spinner.small {
  width: 40px;
  height: 40px;
  border-width: 3px;
}

.stats-footer {
  text-align: center;
  padding-top: 20px;
  border-top: 1px solid #e2e8f0;
  margin-top: 20px;
}

.update-time {
  color: #636e72;
  font-size: 0.9rem;
}

/* System Info */
.system-info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
}

.info-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  background: #f8fafc;
  border-radius: 12px;
}

.info-label {
  font-weight: 600;
  color: #636e72;
}

.info-value {
  font-weight: 500;
  color: #2d3436;
}

/* Status Badges */
.status-badges {
  display: flex;
  gap: 12px;
  margin-bottom: 16px;
}

.status-badge {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  border-radius: 20px;
  font-weight: 600;
  font-size: 0.85rem;
}

.status-badge.active {
  background: rgba(0, 184, 148, 0.1);
  color: #00b894;
  border: 1px solid rgba(0, 184, 148, 0.3);
}

.status-badge.inactive {
  background: rgba(255, 118, 117, 0.1);
  color: #ff7675;
  border: 1px solid rgba(255, 118, 117, 0.3);
}

.status-badge.maintenance {
  background: rgba(255, 209, 102, 0.1);
  color: #ff9e00;
  border: 1px solid rgba(255, 209, 102, 0.3);
}

.status-badge.operational {
  background: rgba(102, 126, 234, 0.1);
  color: #667eea;
  border: 1px solid rgba(102, 126, 234, 0.3);
}

.status-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
}

.status-badge.active .status-dot {
  background: #00b894;
}

.status-badge.inactive .status-dot {
  background: #ff7675;
}

.status-badge.maintenance .status-dot {
  background: #ff9e00;
}

.status-badge.operational .status-dot {
  background: #667eea;
}

/* Action Buttons */
.action-buttons {
  display: flex;
  gap: 12px;
}

.btn-reset {
  padding: 12px 16px;
  background: #ffeaa7;
  color: #5c3c00;
  border: 2px solid #fdcb6e;
  border-radius: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-reset:hover {
  background: #fdcb6e;
}

/* Responsive */
@media (max-width: 1024px) {
  .page-header {
    flex-direction: column;
    gap: 20px;
  }
  
  .header-actions {
    width: 100%;
  }
  
  .action-buttons {
    flex-wrap: wrap;
  }
}

@media (max-width: 768px) {
  .settings-tabs {
    flex-wrap: nowrap;
    overflow-x: auto;
  }
  
  .tab-button {
    padding: 10px 16px;
    font-size: 0.9rem;
  }
  
  .form-grid,
  .upload-grid,
  .security-grid,
  .stats-grid {
    grid-template-columns: 1fr;
  }
  
  .action-footer {
    flex-direction: column;
    gap: 16px;
  }
  
  .footer-right {
    display: flex;
    gap: 12px;
    width: 100%;
  }
  
  .btn-discard, .btn-save {
    flex: 1;
  }
}

@media (max-width: 480px) {
  .color-picker {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .color-preview-area {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .json-actions {
    flex-direction: column;
    gap: 12px;
    align-items: flex-start;
  }
}

/* ========== ESTILOS FALTANTES ========== */

/* Page Header */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 32px;
  flex-wrap: wrap;
  gap: 20px;
}

.header-left {
  flex: 1;
}

.system-title {
  display: flex;
  align-items: center;
  gap: 16px;
  flex-wrap: wrap;
}

.page-title {
  font-size: 2rem;
  font-weight: 700;
  color: #2d3436;
  display: flex;
  align-items: center;
  gap: 12px;
  margin: 0;
}

.title-icon {
  font-size: 2rem;
}

.system-version {
  display: flex;
  align-items: center;
  gap: 12px;
}

.version-badge {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 600;
}

.system-host {
  color: #636e72;
  font-size: 0.9rem;
}

.page-subtitle {
  color: #636e72;
  margin-top: 8px;
  font-size: 1rem;
}

/* Header Actions */
.header-actions {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 16px;
}

/* Botones principales */
.btn-save-all {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  display: flex;
  align-items: center;
  gap: 8px;
}

.btn-save-all:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(102, 126, 234, 0.3);
}

.btn-save-all:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-refresh {
  padding: 12px 20px;
  background: #f1f5f9;
  color: #4a5568;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-refresh:hover {
  background: #e2e8f0;
}

/* Mensajes */
.message-success {
  background: #d4edda;
  color: #155724;
  padding: 16px 20px;
  border-radius: 12px;
  margin-bottom: 20px;
  display: flex;
  align-items: center;
  gap: 12px;
  border: 1px solid #c3e6cb;
}

.message-error {
  background: #f8d7da;
  color: #721c24;
  padding: 16px 20px;
  border-radius: 12px;
  margin-bottom: 20px;
  display: flex;
  align-items: center;
  gap: 12px;
  border: 1px solid #f5c6cb;
}

.message-icon {
  font-size: 1.2rem;
}

.message-close {
  margin-left: auto;
  background: none;
  border: none;
  font-size: 1.2rem;
  cursor: pointer;
  color: inherit;
  opacity: 0.6;
}

.message-close:hover {
  opacity: 1;
}

/* Section Card */
.section-card {
  background: white;
  border-radius: 16px;
  padding: 32px;
  margin-bottom: 24px;
  border: 2px solid #e2e8f0;
}

.section-header {
  margin-bottom: 24px;
  display: flex;
  align-items: flex-start;
  gap: 12px;
  flex-wrap: wrap;
}

.section-header h2 {
  font-size: 1.3rem;
  color: #2d3436;
  margin: 0;
}

.section-header p {
  color: #636e72;
  margin: 0;
  flex: 1;
}

.section-content {
  /* contenedor */
}

/* Toggle Grid (Funcionalidades) */
.toggle-grid {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.toggle-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  background: #f8fafc;
  border-radius: 12px;
  border: 1px solid #e2e8f0;
  gap: 20px;
}

.toggle-info h4 {
  margin: 0 0 4px 0;
  color: #2d3436;
}

.toggle-info p {
  margin: 0;
  color: #636e72;
  font-size: 0.9rem;
}

.toggle-control {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-shrink: 0;
}

/* Toggle Switch */
.toggle-switch {
  position: relative;
  display: inline-block;
  width: 52px;
  height: 28px;
}

.toggle-switch.large {
  width: 60px;
  height: 32px;
}

.toggle-switch input {
  opacity: 0;
  width: 0;
  height: 0;
}

.toggle-slider {
  position: absolute;
  cursor: pointer;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: #cbd5e1;
  transition: 0.3s;
  border-radius: 28px;
}

.toggle-slider:before {
  position: absolute;
  content: "";
  height: 22px;
  width: 22px;
  left: 3px;
  bottom: 3px;
  background-color: white;
  transition: 0.3s;
  border-radius: 50%;
}

.toggle-switch.large .toggle-slider:before {
  height: 26px;
  width: 26px;
}

input:checked + .toggle-slider {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

input:checked + .toggle-slider:before {
  transform: translateX(24px);
}

.toggle-switch.large input:checked + .toggle-slider:before {
  transform: translateX(28px);
}

.toggle-text {
  font-weight: 600;
  font-size: 0.85rem;
}

.toggle-text.active { color: #00b894; }
.toggle-text.inactive { color: #ff7675; }
.toggle-text.maintenance { color: #ff9e00; }
.toggle-text.normal { color: #667eea; }

/* Form textarea */
.form-textarea {
  padding: 14px 16px;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  font-size: 1rem;
  background: white;
  resize: vertical;
  font-family: inherit;
  transition: all 0.3s;
}

.form-textarea:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

/* Loading */
.loading-overlay {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 100px 20px;
}

.loading-spinner {
  width: 50px;
  height: 50px;
  border: 4px solid #e2e8f0;
  border-top: 4px solid #667eea;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 20px;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* Empty State */
.empty-state {
  text-align: center;
  padding: 40px 20px;
  color: #636e72;
}

/* Footer */
.action-footer {
  position: sticky;
  bottom: 0;
  background: white;
  border-top: 2px solid #e2e8f0;
  padding: 20px 32px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-radius: 16px 16px 0 0;
  box-shadow: 0 -4px 20px rgba(0, 0, 0, 0.1);
  z-index: 10;
}

.footer-left {
  display: flex;
  align-items: center;
}

.changes-indicator {
  color: #ff9e00;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 8px;
}

.footer-right {
  display: flex;
  gap: 12px;
}

.btn-discard {
  padding: 12px 24px;
  background: #f1f5f9;
  color: #4a5568;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  font-weight: 600;
  cursor: pointer;
}

.btn-discard:hover {
  background: #e2e8f0;
}

.btn-save {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 12px;
  font-weight: 600;
  cursor: pointer;
}

.btn-save:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(102, 126, 234, 0.3);
}

.btn-save:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.save-loading {
  width: 20px;
  height: 20px;
  border: 2px solid rgba(255,255,255,0.3);
  border-top: 2px solid white;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
  display: inline-block;
}

/* ========== HITOS (MILESTONES) ========== */
.btn-add {
  background: #667eea;
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 8px;
  cursor: pointer;
  font-size: 14px;
  margin-left: auto;
}
.btn-add:hover { background: #5a6fd6; }

.milestones-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}
.milestone-item {
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  padding: 16px;
}
.milestone-header {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
}
.milestone-icon {
  font-size: 24px;
}
.milestone-year {
  width: 80px;
  padding: 6px 10px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  text-align: center;
}
.milestone-title {
  flex: 1;
  padding: 6px 10px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  min-width: 200px;
}
.milestone-actions {
  display: flex;
  gap: 6px;
  margin-left: auto;
}
.btn-sm {
  background: #e2e8f0;
  border: none;
  padding: 6px 10px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
}
.btn-sm:hover { background: #cbd5e1; }
.btn-danger { background: #fee2e2; }
.btn-danger:hover { background: #fecaca; }
.milestone-desc {
  width: 100%;
  margin-top: 8px;
  padding: 8px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  resize: vertical;
  font-family: inherit;
}
.milestone-footer {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-top: 8px;
  font-size: 13px;
  color: #64748b;
}
.milestone-footer select {
  padding: 4px 8px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
}
.milestone-order {
  width: 60px;
  padding: 4px 8px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  text-align: center;
}

/* Hide scrollbar */
.admin-system-settings {
  max-width: 1400px;
  margin: 0 auto;
  padding: 24px;
}

.label-icon {
  font-size: 1.1rem;
}
</style>
