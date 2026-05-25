<!-- src/pages/admin/SecuritySettings.vue -->
<template>
  <div class="admin-security">
    <!-- Loading State -->
    <div
      v-if="loading"
      class="loading-overlay"
    >
      <div class="loading-spinner" />
      <p>Cargando configuración de seguridad...</p>
    </div>

    <template v-else>
      <!-- Header -->
      <div class="page-header">
        <div class="header-left">
          <h1 class="page-title">
            <span class="title-icon">🔒</span>
            Seguridad del Sistema
          </h1>
          <p class="page-subtitle">
            Protege tu plataforma TapClic
          </p>
        </div>
        
        <div class="header-actions">
          <div
            class="security-score"
            :class="getSecurityScoreClass(securityScore)"
          >
            <span class="score-label">Puntuación:</span>
            <span class="score-value">{{ securityScore }}/100</span>
          </div>
          <button
            class="btn-scan"
            :disabled="scanning"
            @click="runSecurityScan"
          >
            <span
              v-if="scanning"
              class="scan-loading"
            />
            <span v-else>🔍 Escanear Seguridad</span>
          </button>
        </div>
      </div>

      <!-- Alertas de seguridad -->
      <div
        v-if="securityAlerts.length > 0"
        class="security-alerts"
      >
        <div class="alert-header">
          <span class="alert-icon">⚠️</span>
          <h3>Alertas de Seguridad ({{ securityAlerts.length }})</h3>
        </div>
        <div class="alert-list">
          <div
            v-for="alert in securityAlerts"
            :key="alert.id"
            class="alert-item"
            :class="alert.level"
          >
            <div class="alert-content">
              <h4>{{ alert.title }}</h4>
              <p>{{ alert.description }}</p>
              <div
                v-if="alert.action"
                class="alert-actions"
              >
                <button
                  class="btn-fix"
                  @click="executeFix(alert)"
                >
                  🔧 {{ alert.action }}
                </button>
              </div>
            </div>
            <span class="alert-level">{{ alert.level }}</span>
          </div>
        </div>
      </div>

      <!-- Tabs de seguridad -->
      <div class="security-tabs">
        <button 
          v-for="tab in tabs" 
          :key="tab.id"
          class="tab-button"
          :class="{ active: activeTab === tab.id }"
          @click="activeTab = tab.id"
        >
          <span class="tab-icon">{{ tab.icon }}</span>
          {{ tab.name }}
          <span
            v-if="tab.badge"
            class="tab-badge"
          >{{ tab.badge }}</span>
        </button>
      </div>

      <!-- Contenido de las pestañas -->
      <div class="tab-content">
        <!-- Pestaña 1: SSL & Dominio -->
        <div
          v-if="activeTab === 'ssl'"
          class="tab-panel"
        >
          <div class="section-card">
            <div class="section-header">
              <h2>🌐 SSL & Dominio</h2>
              <p>Configuración de certificados y dominio</p>
            </div>

            <div class="section-content">
              <!-- Estado SSL -->
              <div
                class="ssl-status-card"
                :class="sslStatus.valid ? 'valid' : 'invalid'"
              >
                <div class="ssl-header">
                  <div class="ssl-icon">
                    <span v-if="sslStatus.valid">🔐</span>
                    <span v-else>⚠️</span>
                  </div>
                  <div class="ssl-info">
                    <h3>Certificado SSL</h3>
                    <p
                      v-if="sslStatus.valid"
                      class="ssl-valid"
                    >
                      ✅ Certificado válido instalado
                    </p>
                    <p
                      v-else
                      class="ssl-invalid"
                    >
                      ❌ {{ sslStatus.message || 'Problema con SSL' }}
                    </p>
                  </div>
                </div>
                
                <div
                  v-if="sslStatus.valid"
                  class="ssl-details"
                >
                  <div class="ssl-detail">
                    <span class="detail-label">Emisor:</span>
                    <span class="detail-value">{{ sslStatus.issuer || 'Desconocido' }}</span>
                  </div>
                  <div class="ssl-detail">
                    <span class="detail-label">Válido para:</span>
                    <span class="detail-value">{{ sslStatus.subject || 'Desconocido' }}</span>
                  </div>
                  <div class="ssl-detail">
                    <span class="detail-label">Expira:</span>
                    <span class="detail-value">
                      {{ sslStatus.expires || 'No disponible' }}
                      <span
                        v-if="sslStatus.expires_in_days"
                        class="expiry-days"
                      >
                        ({{ sslStatus.expires_in_days }} días)
                      </span>
                    </span>
                  </div>
                </div>
                
                <div class="ssl-actions">
                  <button
                    class="btn-refresh-ssl"
                    @click="checkSSLStatus"
                  >
                    🔄 Verificar SSL
                  </button>
                  <a
                    v-if="securityConfig.system_host"
                    :href="securityConfig.system_host" 
                    target="_blank"
                    class="btn-visit-site"
                  >
                    🌐 Visitar Sitio
                  </a>
                </div>
              </div>

              <!-- Configuración de Dominio -->
              <div class="domain-settings">
                <h3>Dominio Principal</h3>
                <div class="domain-form">
                  <div class="form-group">
                    <label class="form-label">
                      <span class="label-icon">🌐</span>
                      URL del Sistema
                    </label>
                    <input
                      v-model="securityConfig.system_host"
                                        />
                    <p class="form-help">
                      Cambia esta configuración en Configuración del Sistema → General
                    </p>
                  </div>
                  
                  <div class="domain-checks">
                    <div
                      class="check-item"
                      :class="domainChecks.https ? 'passed' : 'failed'"
                    >
                      <span class="check-icon">{{ domainChecks.https ? '✅' : '❌' }}</span>
                      <span class="check-text">HTTPS Habilitado</span>
                    </div>
                    <div
                      class="check-item"
                      :class="domainChecks.ssl ? 'passed' : 'failed'"
                    >
                      <span class="check-icon">{{ domainChecks.ssl ? '✅' : '❌' }}</span>
                      <span class="check-text">Certificado SSL Válido</span>
                    </div>
                    <div
                      class="check-item"
                      :class="domainChecks.redirect ? 'passed' : 'failed'"
                    >
                      <span class="check-icon">{{ domainChecks.redirect ? '✅' : '❌' }}</span>
                      <span class="check-text">Redirección HTTP → HTTPS</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Pestaña 2: Sesiones Activas -->
        <div
          v-if="activeTab === 'sessions'"
          class="tab-panel"
        >
          <div class="section-card">
            <div class="section-header">
              <h2>👥 Sesiones Activas</h2>
              <p>Sesiones de usuarios actualmente conectados</p>
              <button
                class="btn-refresh-sessions"
                @click="loadActiveSessions"
              >
                🔄 Actualizar
              </button>
            </div>

            <div class="section-content">
              <!-- Estadísticas de sesiones -->
              <div class="session-stats">
                <div class="stat-item">
                  <span class="stat-label">Sesiones Activas</span>
                  <span class="stat-value">{{ sessions.length }}</span>
                </div>
                <div class="stat-item">
                  <span class="stat-label">Usuarios Únicos</span>
                  <span class="stat-value">{{ uniqueUsers }}</span>
                </div>
                <div class="stat-item">
                  <span class="stat-label">Promedio Tiempo</span>
                  <span class="stat-value">{{ avgSessionTime }}</span>
                </div>
              </div>

              <!-- Lista de sesiones -->
              <div class="sessions-table">
                <div class="table-header">
                  <div class="table-col user">
                    Usuario
                  </div>
                  <div class="table-col ip">
                    IP
                  </div>
                  <div class="table-col device">
                    Dispositivo
                  </div>
                  <div class="table-col last-active">
                    Última Actividad
                  </div>
                  <div class="table-col actions">
                    Acciones
                  </div>
                </div>
                
                <div
                  v-if="sessions.length === 0"
                  class="empty-sessions"
                >
                  <p>No hay sesiones activas en las últimas 24 horas</p>
                </div>
                
                <div
                  v-else
                  class="sessions-list"
                >
                  <div
                    v-for="session in sessions"
                    :key="session.id"
                    class="session-item"
                  >
                    <div class="table-col user">
                      <div class="user-info">
                        <div class="user-avatar">
                          {{ session.user_name?.charAt(0)?.toUpperCase() || 'U' }}
                        </div>
                        <div class="user-details">
                          <span class="user-name">{{ session.user_name || 'Usuario' }}</span>
                          <span class="user-email">{{ session.email }}</span>
                          <span class="user-role">{{ session.role }}</span>
                        </div>
                      </div>
                    </div>
                    
                    <div class="table-col ip">
                      <span class="ip-address">{{ session.ip_address || 'N/A' }}</span>
                      <button
                        v-if="session.ip_address" 
                        class="btn-block-ip" 
                        title="Bloquear esta IP"
                        @click="blockIP(session.ip_address, `Sesión usuario: ${session.user_name}`)"
                      >
                        🚫
                      </button>
                    </div>
                    
                    <div class="table-col device">
                      <span
                        class="device-info"
                        :title="session.user_agent"
                      >
                        {{ getDeviceInfo(session.user_agent) }}
                      </span>
                    </div>
                    
                    <div class="table-col last-active">
                      <span
                        class="time-ago"
                        :title="formatDateTime(session.last_activity)"
                      >
                        {{ timeAgo(session.last_activity) }}
                      </span>
                      <span
                        v-if="session.minutes_inactive > 5"
                        class="inactive-warning"
                      >
                        ({{ session.minutes_inactive }} min inactivo)
                      </span>
                    </div>
                    
                    <div class="table-col actions">
                      <button
                        class="btn-terminate"
                        title="Terminar esta sesión"
                        @click="terminateSession(session.id)"
                      >
                        🔓 Terminar
                      </button>
                      <button
                        class="btn-terminate-all"
                        title="Terminar todas las sesiones de este usuario"
                        @click="terminateUserSessions(session.user_id)"
                      >
                        👥 Todas
                      </button>
                    </div>
                  </div>
                </div>
              </div>
              
              <!-- Acciones masivas -->
              <div class="bulk-actions">
                <button
                  class="btn-terminate-all-sessions"
                  :disabled="sessions.length === 0"
                  @click="terminateAllSessions"
                >
                  🚫 Terminar Todas las Sesiones
                </button>
                <p class="warning-text">
                  ⚠️ Esto cerrará la sesión de TODOS los usuarios activos
                </p>
              </div>
            </div>
          </div>
        </div>

        <!-- Pestaña 3: Auditoría -->
        <div
          v-if="activeTab === 'audit'"
          class="tab-panel"
        >
          <div class="section-card">
            <div class="section-header">
              <h2>📋 Registros de Auditoría</h2>
              <p>Historial de actividades del sistema</p>
            </div>

            <div class="section-content">
              <!-- Filtros -->
              <div class="audit-filters">
                <div class="filter-group">
                  <label>Buscar:</label>
                  <input
                    v-model="auditFilters.search"
                    type="text" 
                    placeholder="Acción, detalles, IP..." 
                    @input="debouncedLoadAuditLogs"
                  >
                </div>
                
                <div class="filter-group">
                  <label>Tipo:</label>
                  <select
                    v-model="auditFilters.type"
                    @change="loadAuditLogs"
                  >
                    <option value="">
                      Todos
                    </option>
                    <option
                      v-for="type in auditActionTypes"
                      :key="type"
                      :value="type"
                    >
                      {{ type }}
                    </option>
                  </select>
                </div>
                
                <div class="filter-group">
                  <label>Desde:</label>
                  <input
                    v-model="auditFilters.date_from"
                    type="date"
                    @change="loadAuditLogs"
                  >
                </div>
                
                <div class="filter-group">
                  <label>Hasta:</label>
                  <input
                    v-model="auditFilters.date_to"
                    type="date"
                    @change="loadAuditLogs"
                  >
                </div>
                
                <button
                  class="btn-clear-filters"
                  @click="clearAuditFilters"
                >
                  🗑️ Limpiar
                </button>
              </div>

              <!-- Estadísticas -->
              <div class="audit-stats">
                <div class="stat-card">
                  <span class="stat-label">Registros Totales</span>
                  <span class="stat-value">{{ auditPagination.total }}</span>
                </div>
                <div class="stat-card">
                  <span class="stat-label">Tipos de Acción</span>
                  <span class="stat-value">{{ auditActionTypes.length }}</span>
                </div>
                <div class="stat-card">
                  <span class="stat-label">Último Registro</span>
                  <span class="stat-value">{{ lastAuditLogTime }}</span>
                </div>
              </div>

              <!-- Tabla de logs -->
              <div class="audit-table">
                <div class="table-header">
                  <div class="table-col time">
                    Fecha/Hora
                  </div>
                  <div class="table-col user">
                    Usuario
                  </div>
                  <div class="table-col type">
                    Tipo
                  </div>
                  <div class="table-col action">
                    Acción
                  </div>
                  <div class="table-col ip">
                    IP
                  </div>
                  <div class="table-col details">
                    Detalles
                  </div>
                </div>
                
                <div
                  v-if="loadingAuditLogs"
                  class="loading-logs"
                >
                  <div class="loading-spinner small" />
                  <p>Cargando registros...</p>
                </div>
                
                <div
                  v-else-if="auditLogs.length === 0"
                  class="empty-logs"
                >
                  <p>No hay registros de auditoría</p>
                </div>
                
                <div
                  v-else
                  class="logs-list"
                >
                  <div
                    v-for="log in auditLogs"
                    :key="log.id"
                    class="log-item"
                    :class="log.action_type"
                  >
                    <div class="table-col time">
                      <span class="log-time">{{ formatDateTime(log.created_at) }}</span>
                    </div>
                    
                    <div class="table-col user">
                      <div
                        v-if="log.user_id"
                        class="user-info-small"
                      >
                        <span class="user-name">{{ log.user_name || 'Usuario' }}</span>
                        <span class="user-role">{{ log.role }}</span>
                      </div>
                      <span
                        v-else
                        class="system-label"
                      >Sistema</span>
                    </div>
                    
                    <div class="table-col type">
                      <span
                        class="type-badge"
                        :class="log.action_type"
                      >
                        {{ log.action_type }}
                      </span>
                    </div>
                    
                    <div class="table-col action">
                      <span class="log-action">{{ log.action }}</span>
                    </div>
                    
                    <div class="table-col ip">
                      <span class="log-ip">{{ log.ip_address || 'N/A' }}</span>
                    </div>
                    
                    <div class="table-col details">
                      <span
                        class="log-details"
                        :title="log.details"
                      >
                        {{ truncateText(log.details, 50) }}
                      </span>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Paginación -->
              <div
                v-if="auditPagination.last_page > 1"
                class="audit-pagination"
              >
                <button
                  class="btn-prev"
                  :disabled="auditPagination.current_page === 1"
                  @click="prevAuditPage"
                >
                  ← Anterior
                </button>
                
                <div class="page-numbers">
                  <span class="page-info">
                    Página {{ auditPagination.current_page }} de {{ auditPagination.last_page }}
                  </span>
                  <span class="total-info">
                    ({{ auditPagination.total }} registros)
                  </span>
                </div>
                
                <button
                  class="btn-next"
                  :disabled="auditPagination.current_page === auditPagination.last_page" 
                  @click="nextAuditPage"
                >
                  Siguiente →
                </button>
              </div>

              <!-- Acciones de logs -->
              <div class="audit-actions">
                <button
                  class="btn-export-logs"
                  @click="exportAuditLogs"
                >
                  📄 Exportar a CSV
                </button>
                <button
                  class="btn-clear-old-logs"
                  @click="clearOldAuditLogs"
                >
                  🗑️ Limpiar Registros Antiguos
                </button>
                <button
                  class="btn-refresh-logs"
                  @click="loadAuditLogs"
                >
                  🔄 Actualizar
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Pestaña 4: IPs Bloqueadas -->
        <div
          v-if="activeTab === 'ips'"
          class="tab-panel"
        >
          <div class="section-card">
            <div class="section-header">
              <h2>🚫 IPs Bloqueadas</h2>
              <p>Gestión de direcciones IP bloqueadas</p>
            </div>

            <div class="section-content">
              <!-- Agregar nueva IP -->
              <div class="block-ip-form">
                <h3>Bloquear Nueva IP</h3>
                <div class="form-grid">
                  <div class="form-group">
                    <label class="form-label">Dirección IP</label>
                    <input
                      v-model="newIP.ip_address"
                      type="text" 
                      placeholder="Ej: 192.168.1.100"
                      class="form-input"
                    >
                    <p class="form-help">
                      IP a bloquear (IPv4 o IPv6)
                    </p>
                  </div>
                  
                  <div class="form-group">
                    <label class="form-label">Razón</label>
                    <input
                      v-model="newIP.reason"
                      type="text" 
                      placeholder="Ej: Intentos fallidos de login"
                      class="form-input"
                    >
                  </div>
                  
                  <div class="form-group">
                    <label class="form-label">Expiración</label>
                    <select
                      v-model="newIP.expiration_type"
                      class="form-select"
                    >
                      <option value="1h">
                        1 Hora
                      </option>
                      <option value="24h">
                        24 Horas
                      </option>
                      <option value="7d">
                        7 Días
                      </option>
                      <option value="30d">
                        30 Días
                      </option>
                      <option value="permanent">
                        Permanente
                      </option>
                      <option value="custom">
                        Personalizada
                      </option>
                    </select>
                    <input
                      v-if="newIP.expiration_type === 'custom'" 
                      v-model="newIP.custom_expires"
                      type="datetime-local" 
                      class="form-input"
                      style="margin-top: 8px;"
                    >
                  </div>
                </div>
                
                <button
                  class="btn-block-ip-form"
                  :disabled="!isValidIP(newIP.ip_address)" 
                  @click="blockNewIP"
                >
                  🚫 Bloquear IP
                </button>
              </div>

              <!-- Lista de IPs bloqueadas -->
              <div class="blocked-ips-list">
                <h3>IPs Actualmente Bloqueadas ({{ blockedIPs.active }})</h3>
                
                <div
                  v-if="loadingBlockedIPs"
                  class="loading-ips"
                >
                  <div class="loading-spinner small" />
                  <p>Cargando IPs bloqueadas...</p>
                </div>
                
                <div
                  v-else-if="blockedIPs.list.length === 0"
                  class="empty-ips"
                >
                  <p>No hay IPs bloqueadas</p>
                </div>
                
                <div
                  v-else
                  class="ips-table"
                >
                  <div class="table-header">
                    <div class="table-col ip">
                      IP Address
                    </div>
                    <div class="table-col reason">
                      Razón
                    </div>
                    <div class="table-col blocked-by">
                      Bloqueado Por
                    </div>
                    <div class="table-col created">
                      Fecha
                    </div>
                    <div class="table-col expires">
                      Expira
                    </div>
                    <div class="table-col status">
                      Estado
                    </div>
                    <div class="table-col actions">
                      Acciones
                    </div>
                  </div>
                  
                  <div class="ips-list">
                    <div
                      v-for="ip in blockedIPs.list"
                      :key="ip.id"
                      class="ip-item"
                    >
                      <div class="table-col ip">
                        <span class="ip-value">{{ ip.ip_address }}</span>
                        <button
                          class="btn-copy-ip"
                          title="Copiar IP"
                          @click="copyToClipboard(ip.ip_address)"
                        >
                          📋
                        </button>
                      </div>
                      
                      <div class="table-col reason">
                        <span class="reason-text">{{ ip.reason || 'Sin razón especificada' }}</span>
                      </div>
                      
                      <div class="table-col blocked-by">
                        <span class="blocked-by-text">{{ ip.blocked_by }}</span>
                      </div>
                      
                      <div class="table-col created">
                        <span class="created-date">{{ formatDate(ip.created_at) }}</span>
                      </div>
                      
                      <div class="table-col expires">
                        <span
                          v-if="ip.expires_at"
                          class="expires-date"
                        >
                          {{ formatDate(ip.expires_at) }}
                          <span
                            v-if="ip.status === 'active'"
                            class="expires-in"
                          >
                            ({{ daysUntil(ip.expires_at) }} días)
                          </span>
                        </span>
                        <span
                          v-else
                          class="permanent"
                        >Permanente</span>
                      </div>
                      
                      <div class="table-col status">
                        <span
                          class="status-badge"
                          :class="ip.status"
                        >
                          {{ ip.status === 'active' ? 'Activo' : 
                            ip.status === 'expired' ? 'Expirado' : 'Permanente' }}
                        </span>
                      </div>
                      
                      <div class="table-col actions">
                        <button
                          v-if="ip.status === 'active'" 
                          class="btn-unblock-ip" 
                          @click="unblockIP(ip.id)"
                        >
                          🔓 Desbloquear
                        </button>
                        <button
                          class="btn-delete-ip"
                          @click="deleteIP(ip.id)"
                        >
                          🗑️ Eliminar
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Estadísticas de bloqueos -->
              <div class="ip-stats">
                <div class="stat-card">
                  <span class="stat-label">IPs Bloqueadas Total</span>
                  <span class="stat-value">{{ blockedIPs.total }}</span>
                </div>
                <div class="stat-card">
                  <span class="stat-label">Activas Ahora</span>
                  <span class="stat-value">{{ blockedIPs.active }}</span>
                </div>
                <div class="stat-card">
                  <span class="stat-label">Expiradas</span>
                  <span class="stat-value">{{ blockedIPs.total - blockedIPs.active }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Pestaña 5: Configuración -->
        <div
          v-if="activeTab === 'config'"
          class="tab-panel"
        >
          <div class="section-card">
            <div class="section-header">
              <h2>⚙️ Configuración de Seguridad</h2>
              <p>Políticas y ajustes de seguridad</p>
            </div>

            <div class="section-content">
              <div class="security-settings-grid">
                <!-- Autenticación -->
                <div class="settings-group">
                  <h3>🔐 Autenticación</h3>
                  
                  <div class="setting-item">
                    <div class="setting-info">
                      <h4>Intentos Máximos de Login</h4>
                      <p>Número de intentos fallidos antes de bloquear la cuenta</p>
                    </div>
                    <div class="setting-control">
                      <input
                        v-model.number="securityConfig.max_login_attempts"
                        type="number"
                        min="1"
                        max="10"
                        class="number-input"
                        @input="markAsChanged"
                      >
                      <span class="setting-unit">intentos</span>
                    </div>
                  </div>
                  
                  <div class="setting-item">
                    <div class="setting-info">
                      <h4>Tiempo de Sesión</h4>
                      <p>Minutos de inactividad antes de cerrar sesión automáticamente</p>
                    </div>
                    <div class="setting-control">
                      <input
                        v-model.number="securityConfig.session_timeout_minutes"
                        type="number"
                        min="5"
                        max="1440"
                        class="number-input"
                        @input="markAsChanged"
                      >
                      <span class="setting-unit">minutos</span>
                    </div>
                  </div>
                  
                  <div class="setting-item">
                    <div class="setting-info">
                      <h4>Expiración de Contraseña</h4>
                      <p>Días antes de requerir cambio de contraseña (0 = nunca)</p>
                    </div>
                    <div class="setting-control">
                      <input
                        v-model.number="securityConfig.password_expiration_days"
                        type="number"
                        min="0"
                        max="365"
                        class="number-input"
                        @input="markAsChanged"
                      >
                      <span class="setting-unit">días</span>
                    </div>
                  </div>
                </div>

                <!-- Registro -->
                <div class="settings-group">
                  <h3>👤 Registro de Usuarios</h3>
                  
                  <div class="setting-item">
                    <div class="setting-info">
                      <h4>Permitir Nuevos Registros</h4>
                      <p>Permitir que nuevos usuarios se registren en la plataforma</p>
                    </div>
                    <div class="setting-control">
                      <label class="toggle-switch">
                        <input
                          v-model="securityConfig.allow_user_registration"
                          type="checkbox"
                          true-value="1"
                          false-value="0"
                          @change="markAsChanged"
                        >
                        <span class="toggle-slider" />
                      </label>
                      <span class="toggle-label">
                        {{ securityConfig.allow_user_registration == 1 ? 'PERMITIDO' : 'BLOQUEADO' }}
                      </span>
                    </div>
                  </div>
                  
                  <div class="setting-item">
                    <div class="setting-info">
                      <h4>Verificación por Email</h4>
                      <p>Requerir verificación por email para nuevos usuarios</p>
                    </div>
                    <div class="setting-control">
                      <label class="toggle-switch">
                        <input
                          v-model="securityConfig.email_verification"
                          type="checkbox"
                          true-value="1"
                          false-value="0"
                          @change="markAsChanged"
                        >
                        <span class="toggle-slider" />
                      </label>
                      <span class="toggle-label">
                        {{ securityConfig.email_verification == 1 ? 'REQUERIDA' : 'OPCIONAL' }}
                      </span>
                    </div>
                  </div>
                </div>

                <!-- Políticas Avanzadas -->
                <div class="settings-group">
                  <h3>🛡️ Políticas Avanzadas</h3>
                  
                  <div class="setting-item">
                    <div class="setting-info">
                      <h4>Contraseñas Fuertes</h4>
                      <p>Requerir mínimo 8 caracteres con mayúsculas, minúsculas y números</p>
                    </div>
                    <div class="setting-control">
                      <label class="toggle-switch">
                        <input
                          v-model="securityConfig.strong_passwords"
                          type="checkbox"
                          true-value="1"
                          false-value="0"
                          @change="markAsChanged"
                        >
                        <span class="toggle-slider" />
                      </label>
                      <span class="toggle-label">
                        {{ securityConfig.strong_passwords == 1 ? 'REQUERIDAS' : 'NO REQUERIDAS' }}
                      </span>
                    </div>
                  </div>
                  
                  <div class="setting-item">
                    <div class="setting-info">
                      <h4>Sesiones Múltiples</h4>
                      <p>Permitir múltiples sesiones simultáneas por usuario</p>
                    </div>
                    <div class="setting-control">
                      <label class="toggle-switch">
                        <input
                          v-model="securityConfig.multiple_sessions"
                          type="checkbox"
                          true-value="1"
                          false-value="0"
                          @change="markAsChanged"
                        >
                        <span class="toggle-slider" />
                      </label>
                      <span class="toggle-label">
                        {{ securityConfig.multiple_sessions == 1 ? 'PERMITIDAS' : 'BLOQUEADAS' }}
                      </span>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Estadísticas de seguridad -->
              <div class="security-metrics">
                <h3>📊 Métricas de Seguridad</h3>
                <div class="metrics-grid">
                  <div class="metric-card">
                    <div class="metric-icon">
                      🔐
                    </div>
                    <div class="metric-content">
                      <h4>Intentos Fallidos (7d)</h4>
                      <p class="metric-value">
                        {{ securityStats.failed_logins_7d || 0 }}
                      </p>
                    </div>
                  </div>
                  
                  <div class="metric-card">
                    <div class="metric-icon">
                      👤
                    </div>
                    <div class="metric-content">
                      <h4>Usuarios Bloqueados</h4>
                      <p class="metric-value">
                        {{ securityStats.blocked_users || 0 }}
                      </p>
                    </div>
                  </div>
                  
                  <div class="metric-card">
                    <div class="metric-icon">
                      🌐
                    </div>
                    <div class="metric-content">
                      <h4>Sesiones Activas</h4>
                      <p class="metric-value">
                        {{ securityStats.active_sessions || 0 }}
                      </p>
                    </div>
                  </div>
                  
                  <div class="metric-card">
                    <div class="metric-icon">
                      🛡️
                    </div>
                    <div class="metric-content">
                      <h4>IPs Bloqueadas</h4>
                      <p class="metric-value">
                        {{ blockedIPs.active || 0 }}
                      </p>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Guardar configuración -->
              <div class="save-section">
                <button
                  class="btn-save-security"
                  :disabled="!hasChanges || saving" 
                  @click="saveSecurityConfig"
                >
                  <span
                    v-if="saving"
                    class="save-loading"
                  />
                  <span v-else>💾 Guardar Configuración de Seguridad</span>
                </button>
                <button
                  class="btn-reset-security"
                  @click="resetSecurityConfig"
                >
                  🔄 Restaurar Valores por Defecto
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Footer con acciones globales -->
      <div class="global-actions">
        <div
          class="action-card"
          @click="exportSecurityReport"
        >
          <span class="action-icon">📄</span>
          <h4>Exportar Reporte</h4>
          <p>Generar reporte completo de seguridad</p>
        </div>
        
        <div
          class="action-card"
          @click="runVulnerabilityScan"
        >
          <span class="action-icon">🔍</span>
          <h4>Escaneo Completo</h4>
          <p>Buscar vulnerabilidades del sistema</p>
        </div>
        
        <div
          class="action-card"
          @click="showSecurityTips"
        >
          <span class="action-icon">💡</span>
          <h4>Consejos de Seguridad</h4>
          <p>Mejores prácticas recomendadas</p>
        </div>
      </div>
    </template>
  </div>
</template>

<script  setup>
import { ref, onMounted, computed, watch } from 'vue'
import { useAuthStore } from '@/stores/authStore'
import api from '@/axios'
import { debounce } from 'lodash'

const authStore = useAuthStore()

// Estados
const loading = ref(true)
const scanning = ref(false)
const saving = ref(false)
const activeTab = ref('ssl')
const securityScore = ref(85)
const securityAlerts = ref([])
const hasChanges = ref(false)

// Tabs
const tabs = ref([
  { id: 'ssl', name: 'SSL & Dominio', icon: '🌐' },
  { id: 'sessions', name: 'Sesiones', icon: '👥', badge: 0 },
  { id: 'audit', name: 'Auditoría', icon: '📋' },
  { id: 'ips', name: 'IPs Bloqueadas', icon: '🚫', badge: 0 },
  { id: 'config', name: 'Configuración', icon: '⚙️' }
])

// SSL & Dominio
const sslStatus = ref({})
const securityConfig = ref({
  system_host: '',
  max_login_attempts: 5,
  session_timeout_minutes: 30,
  password_expiration_days: 90,
  allow_user_registration: 1,
  email_verification: 0,
  strong_passwords: 1,
  multiple_sessions: 1
})

const securityStats = ref({})
const domainChecks = ref({
  https: false,
  ssl: false,
  redirect: false
})

// Sesiones
const sessions = ref([])
const loadingSessions = ref(false)

// Auditoría
const auditLogs = ref([])
const auditPagination = ref({})
const auditActionTypes = ref([])
const auditFilters = ref({
  search: '',
  type: '',
  user_id: '',
  date_from: '',
  date_to: ''
})
const loadingAuditLogs = ref(false)

// IPs Bloqueadas
const blockedIPs = ref({
  list: [],
  total: 0,
  active: 0
})
const loadingBlockedIPs = ref(false)
const newIP = ref({
  ip_address: '',
  reason: '',
  expiration_type: '24h',
  custom_expires: ''
})

// Computed
const uniqueUsers = computed(() => {
  const userIds = new Set(sessions.value.map(s => s.user_id))
  return userIds.size
})

const avgSessionTime = computed(() => {
  if (sessions.value.length === 0) return '0m'
  const now = Math.floor(Date.now() / 1000)
  const totalMinutes = sessions.value.reduce((sum, session) => {
    return sum + Math.floor((now - new Date(session.created_at).getTime() / 1000) / 60)
  }, 0)
  const avg = Math.floor(totalMinutes / sessions.value.length)
  return avg < 60 ? `${avg}m` : `${Math.floor(avg / 60)}h ${avg % 60}m`
})

const lastAuditLogTime = computed(() => {
  if (auditLogs.value.length === 0) return 'N/A'
  return timeAgo(auditLogs.value[0].created_at)
})

// Lifecycle
onMounted(async () => {
  await Promise.all([
    loadSecurityConfig(),
    loadActiveSessions(),
    loadBlockedIPs(),
    loadAuditLogs()
  ])
  updateTabBadges()
})

// Métodos de carga
async function loadSecurityConfig() {
  try {
    loading.value = true
    const response = await api.get('/admin/security/config', {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    
    const data = response.data
    sslStatus.value = data.ssl_status || {}
    securityConfig.value = { ...securityConfig.value, ...data.security_config }
    securityStats.value = data.stats || {}
    domainChecks.value = data.checks || {}
    
    // Calcular puntuación de seguridad
    calculateSecurityScore()
    
  } catch (error) {
    console.error('Error cargando configuración de seguridad:', error)
  } finally {
    loading.value = false
  }
}

async function loadActiveSessions() {
  try {
    loadingSessions.value = true
    const response = await api.get('/admin/security/sessions', {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    
    sessions.value = response.data.sessions || []
    
  } catch (error) {
    console.error('Error cargando sesiones:', error)
  } finally {
    loadingSessions.value = false
  }
}

async function loadAuditLogs() {
  try {
    loadingAuditLogs.value = true
    
    const params = new URLSearchParams()
    if (auditFilters.value.search) params.append('search', auditFilters.value.search)
    if (auditFilters.value.type) params.append('type', auditFilters.value.type)
    if (auditFilters.value.user_id) params.append('user_id', auditFilters.value.user_id)
    if (auditFilters.value.date_from) params.append('date_from', auditFilters.value.date_from)
    if (auditFilters.value.date_to) params.append('date_to', auditFilters.value.date_to)
    
    const response = await api.get(`/admin/security/audit-logs?${params.toString()}`, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    
    const data = response.data
    auditLogs.value = data.logs || []
    auditPagination.value = data.pagination || {}
    auditActionTypes.value = data.action_types || []
    
  } catch (error) {
    console.error('Error cargando logs de auditoría:', error)
  } finally {
    loadingAuditLogs.value = false
  }
}

async function loadBlockedIPs() {
  try {
    loadingBlockedIPs.value = true
    const response = await api.get('/admin/security/blocked-ips', {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    
    const data = response.data
    blockedIPs.value = {
      list: data.blocked_ips || [],
      total: data.total || 0,
      active: data.active || 0
    }
    
  } catch (error) {
    console.error('Error cargando IPs bloqueadas:', error)
  } finally {
    loadingBlockedIPs.value = false
  }
}

// Debounced search
const debouncedLoadAuditLogs = debounce(loadAuditLogs, 500)

// Funciones de seguridad
function checkSSLStatus() {
  // Implementar verificación SSL
  console.log('Verificando SSL...')
}

function terminateSession(sessionId) {
  if (!confirm('¿Terminar esta sesión?')) return
  
  api.post('/admin/security/sessions/terminate', { session_id: sessionId }, {
    headers: { Authorization: `Bearer ${authStore.token}` }
  })
  .then(() => {
    loadActiveSessions()
  })
  .catch(error => {
    console.error('Error terminando sesión:', error)
    alert('Error al terminar la sesión')
  })
}

function terminateUserSessions(userId) {
  if (!confirm('¿Terminar TODAS las sesiones de este usuario?')) return
  
  api.post('/admin/security/sessions/terminate', { user_id: userId }, {
    headers: { Authorization: `Bearer ${authStore.token}` }
  })
  .then(() => {
    loadActiveSessions()
  })
  .catch(error => {
    console.error('Error terminando sesiones:', error)
    alert('Error al terminar las sesiones')
  })
}

function terminateAllSessions() {
  if (!confirm('¿Terminar TODAS las sesiones activas? Esto cerrará la sesión de todos los usuarios.')) return
  
  // Implementar terminación masiva
  console.log('Terminando todas las sesiones...')
}

function blockIP(ipAddress, reason) {
  if (!confirm(`¿Bloquear la IP ${ipAddress}?`)) return
  
  api.post('/admin/security/blocked-ips', {
    ip_address: ipAddress,
    reason: reason || 'Bloqueo manual'
  }, {
    headers: { Authorization: `Bearer ${authStore.token}` }
  })
  .then(() => {
    loadBlockedIPs()
  })
  .catch(error => {
    console.error('Error bloqueando IP:', error)
    alert('Error al bloquear la IP')
  })
}

function blockNewIP() {
  if (!isValidIP(newIP.value.ip_address)) {
    alert('IP address inválida')
    return
  }
  
  // Calcular fecha de expiración
  let expires_at = null
  switch (newIP.value.expiration_type) {
    case '1h':
      expires_at = new Date(Date.now() + 3600000).toISOString()
      break
    case '24h':
      expires_at = new Date(Date.now() + 86400000).toISOString()
      break
    case '7d':
      expires_at = new Date(Date.now() + 604800000).toISOString()
      break
    case '30d':
      expires_at = new Date(Date.now() + 2592000000).toISOString()
      break
    case 'custom':
      expires_at = newIP.value.custom_expires
      break
    // 'permanent' queda como null
  }
  
  api.post('/admin/security/blocked-ips', {
    ip_address: newIP.value.ip_address,
    reason: newIP.value.reason,
    expires_at: expires_at
  }, {
    headers: { Authorization: `Bearer ${authStore.token}` }
  })
  .then(() => {
    loadBlockedIPs()
    newIP.value = {
      ip_address: '',
      reason: '',
      expiration_type: '24h',
      custom_expires: ''
    }
  })
  .catch(error => {
    console.error('Error bloqueando IP:', error)
    alert('Error al bloquear la IP')
  })
}

function unblockIP(ipId) {
  if (!confirm('¿Desbloquear esta IP?')) return
  
  api.post('/admin/security/blocked-ips/unblock', { id: ipId }, {
    headers: { Authorization: `Bearer ${authStore.token}` }
  })
  .then(() => {
    loadBlockedIPs()
  })
  .catch(error => {
    console.error('Error desbloqueando IP:', error)
    alert('Error al desbloquear la IP')
  })
}

function deleteIP(ipId) {
  if (!confirm('¿Eliminar permanentemente este registro de IP?')) return
  
  // Implementar eliminación
  console.log('Eliminando IP:', ipId)
}

// Configuración
function markAsChanged() {
  hasChanges.value = true
}

async function saveSecurityConfig() {
  try {
    saving.value = true
    
    await api.put('/admin/security/config', securityConfig.value, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    
    hasChanges.value = false
    alert('Configuración de seguridad guardada')
    
  } catch (error) {
    console.error('Error guardando configuración:', error)
    alert('Error al guardar la configuración')
  } finally {
    saving.value = false
  }
}

function resetSecurityConfig() {
  if (!confirm('¿Restaurar valores por defecto?')) return
  
  securityConfig.value = {
    max_login_attempts: 5,
    session_timeout_minutes: 30,
    password_expiration_days: 90,
    allow_user_registration: 1,
    email_verification: 0,
    strong_passwords: 1,
    multiple_sessions: 1
  }
  
  hasChanges.value = true
}

// Utilidades
function getSecurityScoreClass(score) {
  if (score >= 80) return 'excellent'
  if (score >= 60) return 'good'
  if (score >= 40) return 'warning'
  return 'critical'
}

function calculateSecurityScore() {
  let score = 100
  
  // Descontar por problemas de SSL
  if (!sslStatus.value.valid) score -= 20
  
  // Descontar por falta de HTTPS
  if (!domainChecks.value.https) score -= 15
  
  // Descontar por configuraciones débiles
  if (securityConfig.value.max_login_attempts > 5) score -= 10
  if (securityConfig.value.session_timeout_minutes > 120) score -= 5
  if (securityConfig.value.strong_passwords != 1) score -= 10
  
  // Descontar por muchas IPs bloqueadas (podría indicar ataques)
  if (blockedIPs.value.active > 10) score -= 5
  
  securityScore.value = Math.max(0, Math.min(100, score))
}

function getDeviceInfo(userAgent) {
  if (!userAgent) return 'Desconocido'
  
  if (userAgent.includes('Mobile')) return '📱 Móvil'
  if (userAgent.includes('Tablet')) return '📱 Tablet'
  if (userAgent.includes('Windows')) return '💻 Windows'
  if (userAgent.includes('Mac')) return '💻 Mac'
  if (userAgent.includes('Linux')) return '💻 Linux'
  
  return '💻 Computadora'
}

function timeAgo(dateString) {
  if (!dateString) return 'N/A'
  
  const date = new Date(dateString)
  const now = new Date()
  const diffMs = now - date
  const diffMins = Math.floor(diffMs / 60000)
  const diffHours = Math.floor(diffMs / 3600000)
  const diffDays = Math.floor(diffMs / 86400000)
  
  if (diffMins < 1) return 'Ahora'
  if (diffMins < 60) return `Hace ${diffMins}m`
  if (diffHours < 24) return `Hace ${diffHours}h`
  return `Hace ${diffDays}d`
}

function formatDateTime(dateString) {
  if (!dateString) return 'N/A'
  const date = new Date(dateString)
  return date.toLocaleString('es-ES')
}

function formatDate(dateString) {
  if (!dateString) return 'N/A'
  const date = new Date(dateString)
  return date.toLocaleDateString('es-ES')
}

function truncateText(text, length) {
  if (!text) return ''
  return text.length > length ? text.substring(0, length) + '...' : text
}

function isValidIP(ip) {
  const ipv4Regex = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
  const ipv6Regex = /^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$/
  
  return ipv4Regex.test(ip) || ipv6Regex.test(ip)
}

function daysUntil(dateString) {
  const date = new Date(dateString)
  const now = new Date()
  const diffTime = date - now
  return Math.ceil(diffTime / (1000 * 60 * 60 * 24))
}

function copyToClipboard(text) {
  navigator.clipboard.writeText(text)
  alert('IP copiada al portapapeles')
}

function updateTabBadges() {
  tabs.value.forEach(tab => {
    if (tab.id === 'sessions') {
      tab.badge = sessions.value.length
    } else if (tab.id === 'ips') {
      tab.badge = blockedIPs.value.active
    } else {
      tab.badge = 0
    }
  })
}

// Watch para actualizar badges
watch(sessions, updateTabBadges)
watch(blockedIPs, updateTabBadges)

// Funciones adicionales (placeholder)
function runSecurityScan() {
  scanning.value = true
  setTimeout(() => {
    scanning.value = false
    alert('Escaneo de seguridad completado')
  }, 2000)
}

function clearAuditFilters() {
  auditFilters.value = {
    search: '',
    type: '',
    user_id: '',
    date_from: '',
    date_to: ''
  }
  loadAuditLogs()
}

function prevAuditPage() {
  if (auditPagination.value.current_page > 1) {
    auditPagination.value.current_page--
    loadAuditLogs()
  }
}

function nextAuditPage() {
  if (auditPagination.value.current_page < auditPagination.value.last_page) {
    auditPagination.value.current_page++
    loadAuditLogs()
  }
}

function exportAuditLogs() {
  alert('Exportando logs...')
}

function clearOldAuditLogs() {
  if (confirm('¿Eliminar registros de auditoría antiguos (más de 90 días)?')) {
    alert('Eliminando registros antiguos...')
  }
}

function exportSecurityReport() {
  alert('Generando reporte de seguridad...')
}

function runVulnerabilityScan() {
  alert('Iniciando escaneo de vulnerabilidades...')
}

function showSecurityTips() {
  alert('Mostrando consejos de seguridad...')
}

function executeFix(alert) {
  alert(`Ejecutando fix: ${alert.action}`)
}
</script>

<style scoped>
/* Estilos específicos para el componente de seguridad */
/* Mantengo la misma estructura de CSS que el componente anterior */

.security-score {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 16px;
  border-radius: 20px;
  font-weight: 700;
  font-size: 0.9rem;
}

.security-score.excellent {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
  color: white;
}

.security-score.good {
  background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%);
  color: white;
}

.security-score.warning {
  background: linear-gradient(135deg, #fdcb6e 0%, #e17055 100%);
  color: #5c3c00;
}

.security-score.critical {
  background: linear-gradient(135deg, #ff7675 0%, #d63031 100%);
  color: white;
}

.security-alerts {
  background: #fff9db;
  border: 2px solid #ffd43b;
  border-radius: 16px;
  padding: 20px;
  margin-bottom: 24px;
}

.alert-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
}

.alert-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.alert-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  border-radius: 12px;
  background: white;
  border-left: 4px solid #ffd43b;
}

.alert-item.critical {
  border-left-color: #ff6b6b;
}

.alert-item.warning {
  border-left-color: #ffd43b;
}

.alert-item.info {
  border-left-color: #74b9ff;
}

.alert-content h4 {
  margin: 0 0 8px 0;
  color: #2d3436;
}

.alert-content p {
  margin: 0;
  color: #636e72;
  font-size: 0.9rem;
}

.alert-actions {
  margin-top: 12px;
}

.btn-fix {
  padding: 8px 16px;
  background: #ffd43b;
  color: #5c3c00;
  border: none;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-fix:hover {
  background: #fab005;
}

.alert-level {
  font-size: 0.8rem;
  font-weight: 700;
  padding: 4px 12px;
  border-radius: 20px;
  text-transform: uppercase;
}

.alert-item.critical .alert-level {
  background: #ff6b6b;
  color: white;
}

.alert-item.warning .alert-level {
  background: #ffd43b;
  color: #5c3c00;
}

.alert-item.info .alert-level {
  background: #74b9ff;
  color: white;
}

/* SSL Status */
.ssl-status-card {
  border-radius: 16px;
  padding: 24px;
  margin-bottom: 24px;
}

.ssl-status-card.valid {
  background: linear-gradient(135deg, rgba(0, 184, 148, 0.1) 0%, rgba(0, 160, 133, 0.1) 100%);
  border: 2px solid #00b894;
}

.ssl-status-card.invalid {
  background: linear-gradient(135deg, rgba(255, 107, 107, 0.1) 0%, rgba(214, 48, 49, 0.1) 100%);
  border: 2px solid #ff6b6b;
}

.ssl-header {
  display: flex;
  align-items: center;
  gap: 20px;
  margin-bottom: 20px;
}

.ssl-icon {
  font-size: 3rem;
}

.ssl-info h3 {
  margin: 0 0 8px 0;
  color: #2d3436;
}

.ssl-valid {
  color: #00b894;
  font-weight: 600;
  margin: 0;
}

.ssl-invalid {
  color: #ff6b6b;
  font-weight: 600;
  margin: 0;
}

.ssl-details {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
  margin-bottom: 20px;
}

.ssl-detail {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.detail-label {
  font-size: 0.9rem;
  color: #636e72;
}

.detail-value {
  font-weight: 600;
  color: #2d3436;
}

.expiry-days {
  color: #636e72;
  font-size: 0.9rem;
}

.ssl-actions {
  display: flex;
  gap: 12px;
}

.btn-refresh-ssl, .btn-visit-site {
  padding: 10px 20px;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  text-decoration: none;
}

.btn-refresh-ssl {
  background: #f1f5f9;
  color: #4a5568;
  border: 2px solid #e2e8f0;
}

.btn-refresh-ssl:hover {
  background: #e2e8f0;
}

.btn-visit-site {
  background: #667eea;
  color: white;
  border: none;
}

.btn-visit-site:hover {
  background: #5a67d8;
}

/* Domain Checks */
.domain-checks {
  display: flex;
  gap: 16px;
  margin-top: 16px;
}

.check-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  border-radius: 20px;
  font-weight: 600;
}

.check-item.passed {
  background: rgba(0, 184, 148, 0.1);
  color: #00b894;
}

.check-item.failed {
  background: rgba(255, 107, 107, 0.1);
  color: #ff6b6b;
}

/* Sessions Table */
.sessions-table {
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  overflow: hidden;
}

.table-header {
  display: grid;
  grid-template-columns: 2fr 1fr 1fr 1fr 1fr;
  background: #f8fafc;
  padding: 16px;
  font-weight: 600;
  color: #2d3436;
  border-bottom: 2px solid #e2e8f0;
}

.session-item {
  display: grid;
  grid-template-columns: 2fr 1fr 1fr 1fr 1fr;
  padding: 16px;
  border-bottom: 1px solid #e2e8f0;
  transition: background 0.3s;
}

.session-item:hover {
  background: #f8fafc;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.user-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: #667eea;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 1.2rem;
}

.user-details {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.user-name {
  font-weight: 600;
  color: #2d3436;
}

.user-email, .user-role {
  font-size: 0.8rem;
  color: #636e72;
}

.ip-address {
  font-family: monospace;
  color: #2d3436;
}

.btn-block-ip {
  margin-left: 8px;
  background: none;
  border: none;
  color: #ff6b6b;
  cursor: pointer;
  font-size: 1.2rem;
}

.device-info {
  color: #636e72;
  font-size: 0.9rem;
}

.time-ago {
  color: #2d3436;
  font-weight: 600;
}

.inactive-warning {
  display: block;
  color: #e17055;
  font-size: 0.8rem;
  margin-top: 4px;
}

.btn-terminate, .btn-terminate-all {
  padding: 6px 12px;
  border-radius: 6px;
  font-size: 0.8rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  margin-right: 8px;
}

.btn-terminate {
  background: #ffeaea;
  color: #dc2626;
  border: 1px solid #fecaca;
}

.btn-terminate:hover {
  background: #fecaca;
}

.btn-terminate-all {
  background: #e0f2fe;
  color: #0369a1;
  border: 1px solid #bae6fd;
}

.btn-terminate-all:hover {
  background: #bae6fd;
}

.bulk-actions {
  margin-top: 24px;
  text-align: center;
}

.btn-terminate-all-sessions {
  padding: 12px 24px;
  background: #dc2626;
  color: white;
  border: none;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-terminate-all-sessions:hover:not(:disabled) {
  background: #b91c1c;
  transform: translateY(-2px);
}

.btn-terminate-all-sessions:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.warning-text {
  color: #dc2626;
  font-size: 0.9rem;
  margin-top: 8px;
}

/* Audit Logs */
.audit-filters {
  display: flex;
  gap: 16px;
  flex-wrap: wrap;
  margin-bottom: 24px;
  padding: 20px;
  background: #f8fafc;
  border-radius: 12px;
  border: 2px solid #e2e8f0;
}

.filter-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
  min-width: 150px;
}

.filter-group label {
  font-weight: 600;
  color: #2d3436;
  font-size: 0.9rem;
}

.filter-group input, .filter-group select {
  padding: 10px 12px;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  font-size: 0.9rem;
}

.btn-clear-filters {
  align-self: flex-end;
  padding: 10px 16px;
  background: #f1f5f9;
  color: #4a5568;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-clear-filters:hover {
  background: #e2e8f0;
  color: #2d3436;
}

.audit-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
  margin-bottom: 24px;
}

.audit-table .table-header {
  grid-template-columns: 1fr 1fr 1fr 2fr 1fr 2fr;
}

.log-item {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr 2fr 1fr 2fr;
  padding: 16px;
  border-bottom: 1px solid #e2e8f0;
}

.log-item:hover {
  background: #f8fafc;
}

.log-time {
  color: #636e72;
  font-size: 0.9rem;
}

.user-info-small {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.system-label {
  color: #636e72;
  font-style: italic;
}

.type-badge {
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
  text-transform: uppercase;
}

.type-badge.login {
  background: #d4edda;
  color: #155724;
}

.type-badge.user_status {
  background: #cce5ff;
  color: #004085;
}

.type-badge.security {
  background: #f8d7da;
  color: #721c24;
}

.type-badge.system {
  background: #e2e3e5;
  color: #383d41;
}

.log-action {
  color: #2d3436;
  font-weight: 500;
}

.log-ip {
  font-family: monospace;
  color: #636e72;
  font-size: 0.9rem;
}

.log-details {
  color: #636e72;
  font-size: 0.9rem;
}

.audit-pagination {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin: 24px 0;
  padding: 16px;
  background: #f8fafc;
  border-radius: 12px;
}

.btn-prev, .btn-next {
  padding: 10px 20px;
  background: white;
  color: #4a5568;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-prev:hover:not(:disabled), .btn-next:hover:not(:disabled) {
  background: #e2e8f0;
  color: #2d3436;
}

.btn-prev:disabled, .btn-next:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.page-info {
  font-weight: 600;
  color: #2d3436;
}

.total-info {
  color: #636e72;
  font-size: 0.9rem;
  margin-left: 8px;
}

.audit-actions {
  display: flex;
  gap: 12px;
  justify-content: center;
  margin-top: 24px;
}

.btn-export-logs, .btn-clear-old-logs, .btn-refresh-logs {
  padding: 12px 24px;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-export-logs {
  background: #d4edda;
  color: #155724;
  border: 2px solid #c3e6cb;
}

.btn-export-logs:hover {
  background: #c3e6cb;
}

.btn-clear-old-logs {
  background: #f8d7da;
  color: #721c24;
  border: 2px solid #f5c6cb;
}

.btn-clear-old-logs:hover {
  background: #f5c6cb;
}

.btn-refresh-logs {
  background: #cce5ff;
  color: #004085;
  border: 2px solid #b8daff;
}

.btn-refresh-logs:hover {
  background: #b8daff;
}

/* Blocked IPs */
.block-ip-form {
  background: #f8fafc;
  border-radius: 16px;
  padding: 24px;
  margin-bottom: 32px;
  border: 2px solid #e2e8f0;
}

.block-ip-form h3 {
  margin: 0 0 20px 0;
  color: #2d3436;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
  margin-bottom: 20px;
}

.btn-block-ip-form {
  padding: 12px 24px;
  background: #dc2626;
  color: white;
  border: none;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-block-ip-form:hover:not(:disabled) {
  background: #b91c1c;
  transform: translateY(-2px);
}

.btn-block-ip-form:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.ips-table .table-header {
  grid-template-columns: 1.5fr 2fr 1fr 1fr 1fr 1fr 1fr;
}

.ip-item {
  display: grid;
  grid-template-columns: 1.5fr 2fr 1fr 1fr 1fr 1fr 1fr;
  padding: 16px;
  border-bottom: 1px solid #e2e8f0;
}

.ip-value {
  font-family: monospace;
  color: #2d3436;
  font-weight: 600;
}

.btn-copy-ip {
  margin-left: 8px;
  background: none;
  border: none;
  color: #636e72;
  cursor: pointer;
  font-size: 1rem;
}

.btn-copy-ip:hover {
  color: #2d3436;
}

.reason-text {
  color: #636e72;
  font-size: 0.9rem;
}

.blocked-by-text {
  color: #2d3436;
  font-weight: 500;
}

.created-date, .expires-date {
  color: #636e72;
  font-size: 0.9rem;
}

.expires-in {
  color: #e17055;
  font-size: 0.8rem;
  display: block;
  margin-top: 2px;
}

.permanent {
  color: #2d3436;
  font-weight: 600;
}

.status-badge {
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
  text-align: center;
}

.status-badge.active {
  background: #f8d7da;
  color: #721c24;
}

.status-badge.expired {
  background: #e2e3e5;
  color: #383d41;
}

.status-badge.permanent {
  background: #d4edda;
  color: #155724;
}

.btn-unblock-ip, .btn-delete-ip {
  padding: 6px 12px;
  border-radius: 6px;
  font-size: 0.8rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  margin-right: 8px;
}

.btn-unblock-ip {
  background: #d4edda;
  color: #155724;
  border: 1px solid #c3e6cb;
}

.btn-unblock-ip:hover {
  background: #c3e6cb;
}

.btn-delete-ip {
  background: #f8d7da;
  color: #721c24;
  border: 1px solid #f5c6cb;
}

.btn-delete-ip:hover {
  background: #f5c6cb;
}

.ip-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
  margin-top: 24px;
}

/* Security Settings */
.security-settings-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
  gap: 32px;
  margin-bottom: 32px;
}

.settings-group {
  background: #f8fafc;
  border-radius: 16px;
  padding: 24px;
  border: 2px solid #e2e8f0;
}

.settings-group h3 {
  margin: 0 0 20px 0;
  color: #2d3436;
  padding-bottom: 12px;
  border-bottom: 2px solid #e2e8f0;
}

.setting-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 0;
  border-bottom: 1px solid #e2e8f0;
}

.setting-item:last-child {
  border-bottom: none;
}

.setting-info h4 {
  margin: 0 0 4px 0;
  color: #2d3436;
  font-size: 1rem;
}

.setting-info p {
  margin: 0;
  color: #636e72;
  font-size: 0.9rem;
  max-width: 300px;
}

.setting-control {
  display: flex;
  align-items: center;
  gap: 16px;
}

.number-input {
  width: 80px;
  padding: 10px 12px;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  font-size: 1rem;
  text-align: center;
}

.setting-unit {
  color: #636e72;
  font-weight: 600;
  min-width: 60px;
}

.toggle-label {
  font-weight: 700;
  font-size: 0.9rem;
  min-width: 100px;
  text-align: center;
}

.security-metrics {
  margin: 32px 0;
}

.security-metrics h3 {
  margin: 0 0 20px 0;
  color: #2d3436;
}

.metrics-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
}

.metric-card {
  background: white;
  border: 2px solid #e2e8f0;
  border-radius: 16px;
  padding: 24px;
  display: flex;
  align-items: center;
  gap: 20px;
  transition: all 0.3s;
}

.metric-card:hover {
  transform: translateY(-5px);
  border-color: #667eea;
  box-shadow: 0 10px 25px rgba(102, 126, 234, 0.1);
}

.metric-icon {
  font-size: 2rem;
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(102, 126, 234, 0.1);
  border-radius: 12px;
  color: #667eea;
}

.metric-content h4 {
  font-size: 0.9rem;
  color: #636e72;
  margin-bottom: 4px;
}

.metric-value {
  font-size: 1.8rem;
  font-weight: 700;
  color: #2d3436;
}

.save-section {
  display: flex;
  gap: 16px;
  justify-content: center;
  margin-top: 32px;
  padding-top: 32px;
  border-top: 2px solid #e2e8f0;
}

.btn-save-security {
  padding: 16px 32px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 12px;
  font-weight: 600;
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-save-security:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
}

.btn-save-security:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-reset-security {
  padding: 16px 32px;
  background: #f1f5f9;
  color: #4a5568;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-reset-security:hover {
  background: #e2e8f0;
  color: #2d3436;
}

/* Global Actions */
.global-actions {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 24px;
  margin-top: 40px;
}

.action-card {
  background: white;
  border: 2px solid #e2e8f0;
  border-radius: 16px;
  padding: 32px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s;
}

.action-card:hover {
  transform: translateY(-5px);
  border-color: #667eea;
  box-shadow: 0 10px 25px rgba(102, 126, 234, 0.1);
}

.action-icon {
  font-size: 3rem;
  display: block;
  margin-bottom: 20px;
}

.action-card h4 {
  font-size: 1.2rem;
  color: #2d3436;
  margin-bottom: 12px;
}

.action-card p {
  color: #636e72;
  font-size: 0.9rem;
  margin: 0;
}

/* Responsive */
@media (max-width: 1200px) {
  .security-settings-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 992px) {
  .table-header, .session-item, .log-item, .ip-item {
    grid-template-columns: 1fr;
    gap: 8px;
  }
  
  .table-col {
    display: flex;
    flex-direction: column;
    gap: 4px;
  }
}

@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    gap: 16px;
  }
  
  .header-actions {
    width: 100%;
    flex-direction: column;
    gap: 12px;
  }
  
  .security-tabs {
    overflow-x: auto;
    flex-wrap: nowrap;
  }
  
  .tab-button {
    padding: 10px 16px;
    font-size: 0.9rem;
    white-space: nowrap;
  }
  
  .audit-filters {
    flex-direction: column;
  }
  
  .form-grid {
    grid-template-columns: 1fr;
  }
  
  .save-section {
    flex-direction: column;
  }
  
  .global-actions {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 480px) {
  .ssl-details {
    grid-template-columns: 1fr;
  }
  
  .domain-checks {
    flex-direction: column;
  }
  
  .audit-pagination {
    flex-direction: column;
    gap: 12px;
  }
  
  .audit-actions {
    flex-direction: column;
  }
}
</style>
