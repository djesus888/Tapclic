<!-- src/pages/admin/Analytics.vue -->
<template>
  <div class="admin-analytics">
    <!-- Loading State -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner"></div>
      <p>Cargando análisis...</p>
    </div>

    <template v-else>
      <!-- Header -->
      <div class="page-header">
        <div class="header-left">
          <h1 class="page-title">
            <span class="title-icon">📊</span>
            Análisis y Estadísticas
          </h1>
          <p class="page-subtitle">Métricas en tiempo real de la plataforma</p>
        </div>

        <div class="header-actions">
          <div class="period-selector">
            <label class="period-label">Período:</label>
            <select v-model="selectedPeriod" @change="loadAnalyticsData" class="period-select">
              <option value="day">Hoy</option>
              <option value="week">Última semana</option>
              <option value="month">Último mes</option>
              <option value="quarter">Último trimestre</option>
              <option value="year">Último año</option>
            </select>
          </div>

          <div class="header-buttons">
            <button class="btn-refresh" @click="loadAnalyticsData" :disabled="refreshing">
              <span v-if="refreshing" class="refresh-spinner"></span>
              <span v-else>🔄 Actualizar</span>
            </button>
            <button class="btn-export" @click="exportAnalytics">📥 Exportar</button>
            <button class="btn-realtime" :class="{ active: autoRefresh }" @click="toggleAutoRefresh">
              ⏱️ {{ autoRefresh ? 'Auto ON' : 'Auto OFF' }}
            </button>
          </div>
        </div>
      </div>

      <!-- Fecha del período -->
      <div class="period-info">
        <div class="period-card">
          <span class="period-icon">📅</span>
          <div class="period-details">
            <h3>{{ getPeriodLabel(selectedPeriod) }}</h3>
            <p v-if="analyticsData.start_date">
              {{ formatDate(analyticsData.start_date) }} - {{ formatDate(analyticsData.end_date) }}
            </p>
          </div>
        </div>
        <div class="updated-info">
          <span class="update-icon">🕐</span>
          <span class="update-text">Actualizado: {{ lastUpdateTime }}</span>
        </div>
      </div>

      <!-- Métricas en tiempo real -->
      <div class="realtime-metrics">
        <h2 class="section-title"><span class="section-icon">⚡</span>En Tiempo Real</h2>
        <div class="realtime-grid">
          <div class="realtime-card">
            <div class="realtime-icon online">👥</div>
            <div class="realtime-content">
              <h4>Usuarios Online</h4>
              <p class="realtime-value">{{ realtimeData.online_users || 0 }}</p>
              <p class="realtime-label">En los últimos 5 minutos</p>
            </div>
          </div>
          <div class="realtime-card">
            <div class="realtime-icon active">📋</div>
            <div class="realtime-content">
              <h4>Solicitudes Activas</h4>
              <p class="realtime-value">{{ realtimeData.active_requests || 0 }}</p>
              <p class="realtime-label">En progreso ahora</p>
            </div>
          </div>
          <div class="realtime-card">
            <div class="realtime-icon available">🛠️</div>
            <div class="realtime-content">
              <h4>Proveedores Disponibles</h4>
              <p class="realtime-value">{{ realtimeData.available_providers || 0 }}</p>
              <p class="realtime-label">Listos para trabajar</p>
            </div>
          </div>
          <div class="realtime-card">
            <div class="realtime-icon warning">📩</div>
            <div class="realtime-content">
              <h4>Tickets Abiertos</h4>
              <p class="realtime-value">{{ realtimeData.open_tickets || 0 }}</p>
              <p class="realtime-label">Esperando respuesta</p>
            </div>
          </div>
        </div>
        <div class="realtime-footer">
          <span class="timestamp">Última actualización: {{ formatTime(realtimeData.timestamp) }}</span>
          <button class="btn-update-realtime" @click="loadRealtimeData" :disabled="loadingRealtime">
            {{ loadingRealtime ? 'Actualizando...' : 'Actualizar ahora' }}
          </button>
        </div>
      </div>

      <!-- Métricas Principales -->
      <div class="main-metrics">
        <h2 class="section-title"><span class="section-icon">📈</span>Métricas Principales</h2>
        <div class="metrics-grid">
          <div class="metric-card">
            <div class="metric-header">
              <div class="metric-icon user">👤</div>
              <div class="metric-trend" :class="getTrendClass('users')">{{ calculateTrend('users') }}</div>
            </div>
            <div class="metric-content">
              <h3>Nuevos Usuarios</h3>
              <p class="metric-value">{{ analyticsData.new_users || 0 }}</p>
              <p class="metric-change">vs período anterior</p>
            </div>
            <div class="metric-chart"><div class="mini-chart"><canvas ref="usersChart" height="40"></canvas></div></div>
          </div>
          <div class="metric-card">
            <div class="metric-header">
              <div class="metric-icon service">🛠️</div>
              <div class="metric-trend" :class="getTrendClass('services')">{{ calculateTrend('services') }}</div>
            </div>
            <div class="metric-content">
              <h3>Nuevos Servicios</h3>
              <p class="metric-value">{{ analyticsData.new_services || 0 }}</p>
              <p class="metric-change">Servicios activos creados</p>
            </div>
            <div class="metric-chart"><div class="mini-chart"><canvas ref="servicesChart" height="40"></canvas></div></div>
          </div>
          <div class="metric-card">
            <div class="metric-header">
              <div class="metric-icon request">📋</div>
              <div class="metric-trend" :class="getTrendClass('requests')">{{ calculateTrend('requests') }}</div>
            </div>
            <div class="metric-content">
              <h3>Solicitudes</h3>
              <div class="request-stats">
                <div class="request-item"><span class="request-label">Nuevas:</span><span class="request-value">{{ analyticsData.new_requests || 0 }}</span></div>
                <div class="request-item"><span class="request-label">Completadas:</span><span class="request-value">{{ analyticsData.completed_requests || 0 }}</span></div>
              </div>
              <p class="metric-change">Tasa de completado: {{ analyticsData.completion_rate || 0 }}%</p>
            </div>
          </div>
          <div class="metric-card">
            <div class="metric-header">
              <div class="metric-icon revenue">💰</div>
              <div class="metric-trend" :class="getTrendClass('revenue')">{{ calculateTrend('revenue') }}</div>
            </div>
            <div class="metric-content">
              <h3>Ingresos</h3>
              <p class="metric-value">${{ formatCurrency(analyticsData.revenue || 0) }}</p>
              <p class="metric-change">Promedio por solicitud: ${{ formatCurrency((analyticsData.revenue / Math.max(analyticsData.new_requests || 1, 1)).toFixed(2)) }}</p>
            </div>
            <div class="metric-chart"><div class="mini-chart"><canvas ref="revenueChart" height="40"></canvas></div></div>
          </div>
          <div class="metric-card">
            <div class="metric-header">
              <div class="metric-icon review">⭐</div>
              <div class="metric-trend" :class="getTrendClass('reviews')">{{ calculateTrend('reviews') }}</div>
            </div>
            <div class="metric-content">
              <h3>Reseñas</h3>
              <p class="metric-value">{{ analyticsData.new_reviews || 0 }}</p>
              <p class="metric-change">Nuevas reseñas recibidas</p>
            </div>
          </div>
          <div class="metric-card">
            <div class="metric-header">
              <div class="metric-icon ticket">📩</div>
              <div class="metric-trend" :class="getTrendClass('tickets')">{{ calculateTrend('tickets') }}</div>
            </div>
            <div class="metric-content">
              <h3>Tickets de Soporte</h3>
              <p class="metric-value">{{ analyticsData.new_tickets || 0 }}</p>
              <p class="metric-change">Nuevos tickets creados</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Gráficos -->
      <div class="charts-section">
        <h2 class="section-title"><span class="section-icon">📊</span>Gráficos Detallados</h2>
        <div class="charts-grid">
          <div class="chart-card">
            <div class="chart-header"><h3>👤 Nuevos Usuarios por Día</h3></div>
            <div class="chart-container"><canvas ref="usersDetailedChart" height="250"></canvas></div>
          </div>
          <div class="chart-card">
            <div class="chart-header"><h3>🛠️ Nuevos Servicios por Día</h3></div>
            <div class="chart-container"><canvas ref="servicesDetailedChart" height="250"></canvas></div>
          </div>
          <div class="chart-card">
            <div class="chart-header"><h3>📋 Solicitudes por Día</h3></div>
            <div class="chart-container"><canvas ref="requestsDetailedChart" height="250"></canvas></div>
          </div>
          <div class="chart-card">
            <div class="chart-header"><h3>💰 Ingresos por Día</h3></div>
            <div class="chart-container"><canvas ref="revenueDetailedChart" height="250"></canvas></div>
          </div>
          <div class="chart-card wide">
            <div class="chart-header"><h3>🏷️ Categorías más Populares</h3></div>
            <div class="chart-container"><canvas ref="categoriesChart" height="250"></canvas></div>
          </div>
          <div class="chart-card wide">
            <div class="chart-header"><h3>👥 Proveedores más Activos</h3></div>
            <div class="chart-container">
              <div class="providers-list">
                <div v-for="(provider, index) in chartsData.charts?.top_providers" :key="index" class="provider-item">
                  <div class="provider-rank">{{ index + 1 }}</div>
                  <div class="provider-info">
                    <h4>{{ provider.name || 'Proveedor ' + (index + 1) }}</h4>
                    <div class="provider-stats">
                      <span class="stat">📋 {{ provider.request_count || 0 }} solicitudes</span>
                      <span class="stat">🛠️ {{ provider.service_count || 0 }} servicios</span>
                    </div>
                  </div>
                </div>
                <div v-if="!chartsData.charts?.top_providers?.length" class="empty-providers">
                  <p>No hay datos de proveedores para este período</p>
                </div>
              </div>
            </div>
          </div>
          <div class="chart-card">
            <div class="chart-header"><h3>📊 Estado de Solicitudes</h3></div>
            <div class="chart-container"><canvas ref="requestsStatusChart" height="250"></canvas></div>
          </div>
        </div>
      </div>

      <!-- Comparativas -->
      <div class="comparison-section">
        <h2 class="section-title"><span class="section-icon">📉</span>Comparativas y Tendencias</h2>
        <div class="comparison-grid">
          <div class="comparison-card">
            <h3>Tendencia Diaria</h3>
            <div class="trend-indicator" :class="getOverallTrend()">
              <span class="trend-icon">{{ getTrendIcon() }}</span>
              <span class="trend-text">{{ getOverallTrendText() }}</span>
            </div>
            <p class="trend-description">{{ getTrendDescription() }}</p>
          </div>
          <div class="comparison-card">
            <h3>Día más Activo</h3>
            <div v-if="peakDay" class="peak-info">
              <div class="peak-day">{{ formatDay(peakDay.date) }}</div>
              <div class="peak-metrics">
                <span class="peak-metric">👤 {{ peakDay.users || 0 }} usuarios</span>
                <span class="peak-metric">📋 {{ peakDay.requests || 0 }} solicitudes</span>
                <span class="peak-metric">💰 ${{ formatCurrency(peakDay.revenue || 0) }}</span>
              </div>
            </div>
            <p v-else class="no-data">No hay datos suficientes</p>
          </div>
          <div class="comparison-card">
            <h3>Proyección Mensual</h3>
            <div class="projection">
              <div class="projection-value">${{ formatCurrency(calculateMonthlyProjection()) }}</div>
              <p class="projection-label">Ingresos proyectados</p>
            </div>
            <p class="projection-note">Basado en el período actual</p>
          </div>
        </div>
      </div>

      <!-- Exportar -->
      <div class="export-section">
        <h2 class="section-title"><span class="section-icon">📥</span>Exportar Reporte</h2>
        <div class="export-options">
          <button class="export-option" @click="exportToPDF"><span class="export-icon">📄</span><span class="export-text">PDF</span></button>
          <button class="export-option" @click="exportToExcel"><span class="export-icon">📊</span><span class="export-text">Excel</span></button>
        </div>
      </div>
    </template>
  </div>
</template>

<script setup>
import { computed, ref, onMounted, onBeforeUnmount } from 'vue'
import { useAuthStore } from '@/stores/authStore'
import api from '@/axios'
import Chart from 'chart.js/auto'

const authStore = useAuthStore()

const loading = ref(true)
const refreshing = ref(false)
const loadingRealtime = ref(false)
const autoRefresh = ref(false)
const selectedPeriod = ref('week')
const lastUpdateTime = ref('')

// ✅ CORREGIDO: estructura plana como viene del backend
const analyticsData = ref({})
const chartsData = ref({})
const realtimeData = ref({})
const previousData = ref({})

const usersChart = ref(null)
const servicesChart = ref(null)
const revenueChart = ref(null)
const usersDetailedChart = ref(null)
const servicesDetailedChart = ref(null)
const requestsDetailedChart = ref(null)
const revenueDetailedChart = ref(null)
const categoriesChart = ref(null)
const requestsStatusChart = ref(null)

let usersChartInstance = null
let servicesChartInstance = null
let revenueChartInstance = null
let usersDetailedChartInstance = null
let servicesDetailedChartInstance = null
let requestsDetailedChartInstance = null
let revenueDetailedChartInstance = null
let categoriesChartInstance = null
let requestsStatusChartInstance = null

let refreshInterval = null
let realtimeInterval = null

onMounted(async () => {
  await Promise.all([loadAnalyticsData(), loadRealtimeData()])
  startAutoRefresh()
})

onBeforeUnmount(() => {
  stopAutoRefresh()
  destroyCharts()
})

async function loadAnalyticsData() {
  try {
    refreshing.value = true
    const [overviewRes, chartsRes] = await Promise.all([
      api.get(`/admin/analytics/overview?period=${selectedPeriod.value}`, { headers: { Authorization: `Bearer ${authStore.token}` } }),
      api.get(`/admin/analytics/charts?period=${selectedPeriod.value}`, { headers: { Authorization: `Bearer ${authStore.token}` } })
    ])

    // ✅ CORREGIDO: el backend devuelve {success:true, data:{...}}
    const newData = overviewRes.data?.data || overviewRes.data

    // Guardar anteriores
    if (analyticsData.value && Object.keys(analyticsData.value).length) {
      previousData.value = { ...analyticsData.value }
    }

    analyticsData.value = newData
    chartsData.value = chartsRes.data

    lastUpdateTime.value = new Date().toLocaleTimeString('es-ES', { hour: '2-digit', minute: '2-digit' })
    renderCharts()
  } catch (error) {
    console.error('Error cargando analytics:', error)
  } finally {
    loading.value = false
    refreshing.value = false
  }
}

async function loadRealtimeData() {
  try {
    loadingRealtime.value = true
    const response = await api.get('/admin/analytics/realtime', { headers: { Authorization: `Bearer ${authStore.token}` } })
    realtimeData.value = response.data
  } catch (error) {
    console.error('Error cargando datos en tiempo real:', error)
  } finally {
    loadingRealtime.value = false
  }
}

function startAutoRefresh() {
  stopAutoRefresh()
  refreshInterval = setInterval(() => { if (autoRefresh.value) loadAnalyticsData() }, 300000)
  realtimeInterval = setInterval(() => { if (autoRefresh.value) loadRealtimeData() }, 30000)
}

function stopAutoRefresh() {
  if (refreshInterval) clearInterval(refreshInterval)
  if (realtimeInterval) clearInterval(realtimeInterval)
}

function toggleAutoRefresh() {
  autoRefresh.value = !autoRefresh.value
  autoRefresh.value ? startAutoRefresh() : stopAutoRefresh()
}

function renderCharts() {
  destroyCharts()
  renderMiniCharts()
  renderDetailedCharts()
  renderCategoriesChart()
  renderRequestsStatusChart()
}

function renderMiniCharts() {
  const miniData = [30, 50, 40, 60, 45, 70, 55]
  const miniOptions = { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } }, scales: { x: { display: false }, y: { display: false } }, elements: { line: { tension: 0.4, borderWidth: 2 }, point: { radius: 0 } } }

  if (usersChart.value) {
    usersChartInstance = new Chart(usersChart.value, { type: 'line', data: { labels: ['','','','','','',''], datasets: [{ data: miniData, borderColor: '#667eea', backgroundColor: 'rgba(102,126,234,0.1)', fill: true }] }, options: miniOptions })
  }
  if (servicesChart.value) {
    servicesChartInstance = new Chart(servicesChart.value, { type: 'line', data: { labels: ['','','','','','',''], datasets: [{ data: miniData, borderColor: '#00b894', backgroundColor: 'rgba(0,184,148,0.1)', fill: true }] }, options: miniOptions })
  }
  if (revenueChart.value) {
    revenueChartInstance = new Chart(revenueChart.value, { type: 'line', data: { labels: ['','','','','','',''], datasets: [{ data: miniData, borderColor: '#fdcb6e', backgroundColor: 'rgba(253,203,110,0.1)', fill: true }] }, options: miniOptions })
  }
}

function renderDetailedCharts() {
  const chartOptions = { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'top' }, tooltip: { mode: 'index', intersect: false } }, scales: { x: { grid: { display: false } }, y: { beginAtZero: true, grid: { borderDash: [2,2] } } } }
  const charts = chartsData.value.charts || {}

  if (usersDetailedChart.value && charts.users_by_day?.length) {
    const data = charts.users_by_day
    usersDetailedChartInstance = new Chart(usersDetailedChart.value, { type: 'line', data: { labels: data.map(d => formatChartDate(d.date)), datasets: [{ label: 'Usuarios', data: data.map(d => d.count), borderColor: '#667eea', backgroundColor: 'rgba(102,126,234,0.1)', fill: true, tension: 0.4 }] }, options: chartOptions })
  }
  if (servicesDetailedChart.value && charts.services_by_day?.length) {
    const data = charts.services_by_day
    servicesDetailedChartInstance = new Chart(servicesDetailedChart.value, { type: 'bar', data: { labels: data.map(d => formatChartDate(d.date)), datasets: [{ label: 'Servicios', data: data.map(d => d.count), backgroundColor: '#00b894' }] }, options: chartOptions })
  }
  if (requestsDetailedChart.value && charts.requests_by_day?.length) {
    const data = charts.requests_by_day
    requestsDetailedChartInstance = new Chart(requestsDetailedChart.value, { type: 'line', data: { labels: data.map(d => formatChartDate(d.date)), datasets: [{ label: 'Solicitudes', data: data.map(d => d.count), borderColor: '#ff6b6b', backgroundColor: 'rgba(255,107,107,0.1)', fill: true, tension: 0.4 }] }, options: chartOptions })
  }
  if (revenueDetailedChart.value && charts.revenue_by_day?.length) {
    const data = charts.revenue_by_day
    revenueDetailedChartInstance = new Chart(revenueDetailedChart.value, { type: 'line', data: { labels: data.map(d => formatChartDate(d.date)), datasets: [{ label: 'Ingresos ($)', data: data.map(d => d.amount), borderColor: '#fdcb6e', backgroundColor: 'rgba(253,203,110,0.1)', fill: true, tension: 0.4 }] }, options: chartOptions })
  }
}

function renderCategoriesChart() {
  const data = chartsData.value.charts?.top_categories
  if (categoriesChart.value && data?.length) {
    categoriesChartInstance = new Chart(categoriesChart.value, { type: 'doughnut', data: { labels: data.map(d => d.name), datasets: [{ data: data.map(d => d.service_count), backgroundColor: ['#667eea','#764ba2','#f093fb','#f5576c','#4facfe','#00f2fe','#43e97b','#38f9d7','#fa709a','#fee140'], borderWidth: 2, borderColor: '#fff' }] }, options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'right' } } } })
  }
}

function renderRequestsStatusChart() {
  const data = chartsData.value.charts?.requests_status
  if (requestsStatusChart.value && data?.length) {
    requestsStatusChartInstance = new Chart(requestsStatusChart.value, { type: 'pie', data: { labels: data.map(d => getStatusLabel(d.status)), datasets: [{ data: data.map(d => d.count), backgroundColor: ['#667eea','#00b894','#fdcb6e','#ff6b6b','#a8edea'], borderWidth: 2, borderColor: '#fff' }] }, options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'right' } } } })
  }
}

function destroyCharts() {
  [usersChartInstance, servicesChartInstance, revenueChartInstance, usersDetailedChartInstance, servicesDetailedChartInstance, requestsDetailedChartInstance, revenueDetailedChartInstance, categoriesChartInstance, requestsStatusChartInstance].forEach(c => { if (c) c.destroy() })
}

function getPeriodLabel(p) { return { day: 'Hoy', week: 'Última Semana', month: 'Último Mes', quarter: 'Último Trimestre', year: 'Último Año' }[p] || p }
function formatDate(d) { if (!d) return ''; return new Date(d).toLocaleDateString('es-ES', { day: 'numeric', month: 'short', year: 'numeric' }) }
function formatChartDate(d) { if (!d) return ''; return new Date(d).toLocaleDateString('es-ES', { day: 'numeric', month: 'short' }) }
function formatTime(d) { if (!d) return ''; return new Date(d).toLocaleTimeString('es-ES', { hour: '2-digit', minute: '2-digit', second: '2-digit' }) }
function formatCurrency(a) { return new Intl.NumberFormat('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(a) }
function formatDay(d) { if (!d) return ''; const dt = new Date(d); const days = ['Dom','Lun','Mar','Mié','Jue','Vie','Sáb']; const months = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic']; return `${days[dt.getDay()]}, ${dt.getDate()} ${months[dt.getMonth()]}` }
function getStatusLabel(s) { return { pending:'Pendiente', accepted:'Aceptada', in_progress:'En Progreso', completed:'Completada', cancelled:'Cancelada', rejected:'Rechazada', busy:'Ocupado' }[s] || s }

// ✅ CORREGIDO: acceder directo a analyticsData.value sin .metrics
function calculateTrend(metric) {
  const map = { users: 'new_users', services: 'new_services', requests: 'new_requests', revenue: 'revenue', reviews: 'new_reviews', tickets: 'new_tickets' }
  const key = map[metric] || `new_${metric}`
  const current = analyticsData.value?.[key] || 0
  const previous = previousData.value?.[key] || 0
  if (previous === 0) return current > 0 ? '+100%' : '0%'
  const change = ((current - previous) / previous) * 100
  return change >= 0 ? `+${change.toFixed(1)}%` : `${change.toFixed(1)}%`
}

function getTrendClass(metric) {
  const map = { users: 'new_users', services: 'new_services', requests: 'new_requests', revenue: 'revenue', reviews: 'new_reviews', tickets: 'new_tickets' }
  const key = map[metric] || `new_${metric}`
  const current = analyticsData.value?.[key] || 0
  const previous = previousData.value?.[key] || 0
  if (previous === 0) return current > 0 ? 'positive' : 'neutral'
  return ((current - previous) / previous) >= 0 ? 'positive' : 'negative'
}

function getOverallTrend() {
  const metrics = ['users','services','requests','revenue']
  let pos = 0
  metrics.forEach(m => { if (getTrendClass(m) === 'positive') pos++ })
  const pct = (pos / metrics.length) * 100
  return pct >= 75 ? 'positive' : pct >= 50 ? 'neutral' : 'negative'
}
function getTrendIcon() { const t = getOverallTrend(); return t === 'positive' ? '📈' : t === 'neutral' ? '➡️' : '📉' }
function getOverallTrendText() { const t = getOverallTrend(); return t === 'positive' ? 'Crecimiento positivo' : t === 'neutral' ? 'Estable' : 'En descenso' }
function getTrendDescription() {
  const d = analyticsData.value || {}
  let best = { key: '', value: 0 }
  Object.entries(d).forEach(([k, v]) => { if (typeof v === 'number' && v > best.value) best = { key: k, value: v } })
  return `Métrica más fuerte: ${getMetricLabel(best.key)} con ${best.value || 0}`
}
function getMetricLabel(k) { return { new_users: 'Usuarios nuevos', new_services: 'Servicios nuevos', new_requests: 'Solicitudes nuevas', revenue: 'Ingresos', new_reviews: 'Reseñas nuevas' }[k] || k }

function calculateMonthlyProjection() {
  const revenue = analyticsData.value?.revenue || 0
  const days = selectedPeriod.value === 'day' ? 1 : selectedPeriod.value === 'week' ? 7 : selectedPeriod.value === 'month' ? 30 : selectedPeriod.value === 'quarter' ? 90 : 365
  return (revenue / Math.max(days, 1)) * 30
}

function findPeakDay() {
  const charts = chartsData.value.charts || {}
  const users = charts.users_by_day || []
  const requests = charts.requests_by_day || []
  const revenue = charts.revenue_by_day || []
  if (!users.length && !requests.length) return null
  const map = {}
  users.forEach(d => { map[d.date] = { ...map[d.date], users: d.count } })
  requests.forEach(d => { map[d.date] = { ...map[d.date], requests: d.count } })
  revenue.forEach(d => { map[d.date] = { ...map[d.date], revenue: d.amount } })
  let peak = null, max = 0
  Object.entries(map).forEach(([date, data]) => { if ((data.requests || 0) > max) { max = data.requests; peak = { date, ...data } } })
  return peak
}
const peakDay = computed(() => findPeakDay())

function exportAnalytics() { console.log('Exportando...') }
function exportToPDF() { console.log('PDF...') }
function exportToExcel() { console.log('Excel...') }
</script>

<style scoped>
.admin-analytics {
  max-width: 1400px;
  margin: 0 auto;
  padding: 24px;
}

/* Loading */
.loading-overlay {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 400px;
}

.loading-spinner {
  width: 50px;
  height: 50px;
  border: 5px solid #f3f3f3;
  border-top: 5px solid #667eea;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 20px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* Header */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 32px;
  padding-bottom: 24px;
  border-bottom: 2px solid #e2e8f0;
}

.header-left h1 {
  font-size: 2rem;
  font-weight: 700;
  color: #2d3436;
  margin-bottom: 8px;
  display: flex;
  align-items: center;
  gap: 12px;
}

.page-subtitle {
  color: #636e72;
  font-size: 1.1rem;
}

.header-actions {
  display: flex;
  flex-direction: column;
  gap: 16px;
  align-items: flex-end;
}

.period-selector {
  display: flex;
  align-items: center;
  gap: 12px;
}

.period-label {
  font-weight: 600;
  color: #2d3436;
}

.period-select {
  padding: 10px 16px;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  font-size: 1rem;
  background: white;
  cursor: pointer;
  min-width: 180px;
}

.period-select:focus {
  outline: none;
  border-color: #667eea;
}

.header-buttons {
  display: flex;
  gap: 12px;
}

.btn-refresh, .btn-export, .btn-realtime {
  padding: 12px 24px;
  border-radius: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  border: none;
  display: flex;
  align-items: center;
  gap: 8px;
}

.btn-refresh {
  background: #f1f5f9;
  color: #4a5568;
  border: 2px solid #e2e8f0;
}

.btn-refresh:hover:not(:disabled) {
  background: #e2e8f0;
  color: #2d3436;
}

.btn-refresh:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-export {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
  color: white;
}

.btn-export:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 20px rgba(0, 184, 148, 0.3);
}

.btn-realtime {
  background: #f1f5f9;
  color: #4a5568;
  border: 2px solid #e2e8f0;
}

.btn-realtime.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-color: #667eea;
}

.btn-realtime:hover {
  transform: translateY(-2px);
}

.refresh-spinner {
  width: 16px;
  height: 16px;
  border: 2px solid rgba(74, 85, 104, 0.3);
  border-top: 2px solid #4a5568;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

/* Period Info */
.period-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 32px;
  padding: 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 20px;
  color: white;
}

.period-card {
  display: flex;
  align-items: center;
  gap: 20px;
}

.period-icon {
  font-size: 3rem;
}

.period-details h3 {
  font-size: 1.5rem;
  margin: 0 0 8px 0;
  font-weight: 700;
}

.period-details p {
  margin: 0;
  opacity: 0.9;
  font-size: 0.95rem;
}

.updated-info {
  display: flex;
  align-items: center;
  gap: 12px;
  background: rgba(255, 255, 255, 0.2);
  padding: 12px 24px;
  border-radius: 20px;
  backdrop-filter: blur(10px);
}

.update-icon {
  font-size: 1.5rem;
}

.update-text {
  font-weight: 600;
  font-size: 0.95rem;
}

/* Realtime Metrics */
.realtime-metrics {
  margin-bottom: 40px;
}

.section-title {
  font-size: 1.5rem;
  color: #2d3436;
  margin-bottom: 24px;
  display: flex;
  align-items: center;
  gap: 12px;
}

.section-icon {
  font-size: 1.8rem;
}

.realtime-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
  margin-bottom: 20px;
}

.realtime-card {
  background: white;
  border-radius: 16px;
  padding: 24px;
  display: flex;
  align-items: center;
  gap: 20px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
  border: 2px solid #e2e8f0;
  transition: all 0.3s;
}

.realtime-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.12);
}

.realtime-icon {
  font-size: 3rem;
  width: 80px;
  height: 80px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 16px;
}

.realtime-icon.online {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.realtime-icon.active {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
  color: white;
}

.realtime-icon.available {
  background: linear-gradient(135deg, #fdcb6e 0%, #f9a825 100%);
  color: #5c3c00;
}

.realtime-icon.warning {
  background: linear-gradient(135deg, #ff6b6b 0%, #c92a2a 100%);
  color: white;
}

.realtime-content {
  flex: 1;
}

.realtime-content h4 {
  font-size: 1rem;
  color: #636e72;
  margin-bottom: 8px;
  font-weight: 600;
}

.realtime-value {
  font-size: 2.2rem;
  font-weight: 700;
  color: #2d3436;
  margin-bottom: 4px;
  line-height: 1;
}

.realtime-label {
  font-size: 0.9rem;
  color: #94a3b8;
}

.realtime-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 24px;
  background: #f8fafc;
  border-radius: 12px;
  border: 2px solid #e2e8f0;
}

.timestamp {
  color: #636e72;
  font-size: 0.9rem;
}

.btn-update-realtime {
  padding: 10px 20px;
  background: #667eea;
  color: white;
  border: none;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-update-realtime:hover:not(:disabled) {
  background: #5a6fd8;
  transform: translateY(-2px);
}

.btn-update-realtime:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Main Metrics */
.metrics-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 24px;
}

.metric-card {
  background: white;
  border-radius: 16px;
  padding: 24px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
  border: 2px solid #e2e8f0;
  transition: all 0.3s;
}

.metric-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.12);
}

.metric-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.metric-icon {
  font-size: 2.5rem;
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 12px;
}

.metric-icon.user {
  background: rgba(102, 126, 234, 0.1);
  color: #667eea;
}

.metric-icon.service {
  background: rgba(0, 184, 148, 0.1);
  color: #00b894;
}

.metric-icon.request {
  background: rgba(255, 107, 107, 0.1);
  color: #ff6b6b;
}

.metric-icon.revenue {
  background: rgba(253, 203, 110, 0.1);
  color: #fdcb6e;
}

.metric-icon.review {
  background: rgba(250, 112, 154, 0.1);
  color: #fa709a;
}

.metric-icon.ticket {
  background: rgba(168, 237, 234, 0.1);
  color: #a8edea;
}

.metric-trend {
  padding: 6px 12px;
  border-radius: 20px;
  font-weight: 700;
  font-size: 0.85rem;
}

.metric-trend.positive {
  background: rgba(0, 184, 148, 0.1);
  color: #00b894;
}

.metric-trend.negative {
  background: rgba(255, 107, 107, 0.1);
  color: #ff6b6b;
}

.metric-content h3 {
  font-size: 1.1rem;
  color: #636e72;
  margin-bottom: 12px;
  font-weight: 600;
}

.metric-value {
  font-size: 2.5rem;
  font-weight: 700;
  color: #2d3436;
  margin-bottom: 8px;
  line-height: 1;
}

.metric-change {
  color: #94a3b8;
  font-size: 0.9rem;
}

.request-stats {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-bottom: 12px;
}

.request-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.request-label {
  color: #636e72;
  font-size: 0.9rem;
}

.request-value {
  font-weight: 600;
  color: #2d3436;
}

.metric-chart {
  margin-top: 20px;
}

.mini-chart {
  height: 40px;
  width: 100%;
}

/* Charts Section */
.charts-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
  gap: 24px;
  margin-bottom: 40px;
}

.chart-card {
  background: white;
  border-radius: 16px;
  padding: 24px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
  border: 2px solid #e2e8f0;
}

.chart-card.wide {
  grid-column: span 2;
}

.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.chart-header h3 {
  font-size: 1.1rem;
  color: #2d3436;
  margin: 0;
  display: flex;
  align-items: center;
  gap: 8px;
}

.chart-actions {
  display: flex;
  gap: 8px;
}

.chart-action {
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f1f5f9;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s;
}

.chart-action:hover {
  background: #e2e8f0;
}

.chart-container {
  height: 250px;
  position: relative;
}

.providers-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.provider-item {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px;
  background: #f8fafc;
  border-radius: 12px;
  border: 2px solid #e2e8f0;
}

.provider-rank {
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #667eea;
  color: white;
  border-radius: 8px;
  font-weight: 700;
  font-size: 1.1rem;
}

.provider-info {
  flex: 1;
}

.provider-info h4 {
  font-size: 1rem;
  color: #2d3436;
  margin: 0 0 4px 0;
  font-weight: 600;
}

.provider-stats {
  display: flex;
  gap: 16px;
}

.provider-stats .stat {
  font-size: 0.85rem;
  color: #636e72;
}

.provider-score {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 8px;
  min-width: 100px;
}

.score-bar {
  width: 100px;
  height: 8px;
  background: #e2e8f0;
  border-radius: 4px;
  overflow: hidden;
}

.score-fill {
  height: 100%;
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
  border-radius: 4px;
  transition: width 1s ease;
}

.score-value {
  font-weight: 700;
  color: #2d3436;
  font-size: 0.9rem;
}

.empty-providers {
  text-align: center;
  padding: 40px 20px;
  color: #94a3b8;
}

/* Comparison Section */
.comparison-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 24px;
  margin-bottom: 40px;
}

.comparison-card {
  background: white;
  border-radius: 16px;
  padding: 24px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
  border: 2px solid #e2e8f0;
}

.comparison-card h3 {
  font-size: 1.1rem;
  color: #2d3436;
  margin: 0 0 20px 0;
  font-weight: 600;
}

.trend-indicator {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
}

.trend-icon {
  font-size: 2.5rem;
}

.trend-text {
  font-size: 1.2rem;
  font-weight: 700;
}

.trend-indicator.positive .trend-text {
  color: #00b894;
}

.trend-indicator.neutral .trend-text {
  color: #fdcb6e;
}

.trend-indicator.negative .trend-text {
  color: #ff6b6b;
}

.trend-description {
  color: #636e72;
  font-size: 0.95rem;
  line-height: 1.5;
}

.peak-info {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.peak-day {
  font-size: 1.5rem;
  font-weight: 700;
  color: #2d3436;
  text-align: center;
  padding: 12px;
  background: #f8fafc;
  border-radius: 12px;
  border: 2px solid #e2e8f0;
}

.peak-metrics {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.peak-metric {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 12px;
  background: #f1f5f9;
  border-radius: 8px;
  font-size: 0.9rem;
}

.projection {
  text-align: center;
  padding: 20px 0;
}

.projection-value {
  font-size: 2.5rem;
  font-weight: 700;
  color: #667eea;
  margin-bottom: 8px;
}

.projection-label {
  color: #636e72;
  font-size: 0.9rem;
  margin-bottom: 12px;
}

.projection-note {
  color: #94a3b8;
  font-size: 0.8rem;
  font-style: italic;
}

.no-data {
  color: #94a3b8;
  text-align: center;
  padding: 40px 20px;
  font-style: italic;
}

/* Export Section */
.export-options {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
}

.export-option {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
  padding: 24px;
  background: white;
  border: 2px solid #e2e8f0;
  border-radius: 16px;
  cursor: pointer;
  transition: all 0.3s;
}

.export-option:hover {
  transform: translateY(-5px);
  border-color: #667eea;
  box-shadow: 0 10px 25px rgba(102, 126, 234, 0.1);
}

.export-icon {
  font-size: 2.5rem;
}

.export-text {
  font-weight: 600;
  color: #2d3436;
}

/* Responsive */
@media (max-width: 1200px) {
  .charts-grid {
    grid-template-columns: 1fr;
  }
  
  .chart-card.wide {
    grid-column: span 1;
  }
}

@media (max-width: 768px) {
  .admin-analytics {
    padding: 16px;
  }
  
  .page-header {
    flex-direction: column;
    gap: 20px;
    align-items: stretch;
  }
  
  .header-actions {
    align-items: stretch;
  }
  
  .header-buttons {
    flex-wrap: wrap;
  }
  
  .period-info {
    flex-direction: column;
    gap: 20px;
    text-align: center;
  }
  
  .period-card {
    flex-direction: column;
    text-align: center;
    gap: 12px;
  }
  
  .metrics-grid,
  .comparison-grid,
  .export-options {
    grid-template-columns: 1fr;
  }
  
  .realtime-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 480px) {
  .period-select {
    min-width: 100%;
  }
  
  .header-buttons {
    flex-direction: column;
  }
  
  .btn-refresh, .btn-export, .btn-realtime {
    width: 100%;
    justify-content: center;
  }
  
  .chart-header {
    flex-direction: column;
    gap: 12px;
    align-items: flex-start;
  }
  
  .provider-item {
    flex-direction: column;
    text-align: center;
    gap: 12px;
  }
  
  .provider-stats {
    flex-direction: column;
    gap: 8px;
  }
}
</style>
