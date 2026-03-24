<template>
  <div class="admin-reports-page">
    <!-- Header con título -->
    <div class="header">
      <div class="title-section">
        <h1><span class="chart-icon">📊</span> Panel de Informes Administrativos</h1>
        <p>Estadísticas y métricas de tu plataforma de servicios</p>
      </div>
      
      <div class="header-actions">
        <button class="btn-export" @click="exportReports">
          📥 Exportar Reporte
        </button>
        <button class="btn-refresh" @click="refreshData">
          🔄 Actualizar
        </button>
      </div>
    </div>

    <!-- Tarjetas de Estadísticas -->
    <section class="summary-stats">
      <div class="stat-card" @click="$router.push('/admin/users')">
        <div class="stat-icon">👥</div>
        <div class="stat-content">
          <h3>{{ stats.totalUsers }}</h3>
          <p>Usuarios Totales</p>
        </div>
        <div class="stat-trend">📈</div>
      </div>

      <div class="stat-card" @click="$router.push('/admin/services')">
        <div class="stat-icon">⚙️</div>
        <div class="stat-content">
          <h3>{{ stats.totalServices }}</h3>
          <p>Servicios Activos</p>
        </div>
        <div class="stat-trend">🔄</div>
      </div>

      <div class="stat-card" @click="$router.push('/admin/requests')">
        <div class="stat-icon">📋</div>
        <div class="stat-content">
          <h3>{{ stats.totalRequests }}</h3>
          <p>Solicitudes Totales</p>
        </div>
        <div class="stat-trend">📈</div>
      </div>

      <div class="stat-card revenue-card">
        <div class="stat-icon">💰</div>
        <div class="stat-content">
          <h3>${{ formatNumber(stats.ingresos) }}</h3>
          <p>Ingresos Totales</p>
        </div>
        <div class="stat-badge">💎</div>
      </div>

      <div class="stat-card warning-card" @click="$router.push('/admin/tickets')">
        <div class="stat-icon">🎫</div>
        <div class="stat-content">
          <div class="stat-header">
            <h3>{{ stats.totalTickets }}</h3>
            <span v-if="stats.totalTickets > 0" class="alert-badge">!</span>
          </div>
          <p>Tickets Abiertos</p>
        </div>
        <div class="stat-action">
          <router-link 
            v-if="stats.totalTickets > 0"
            to="/admin/tickets" 
            class="btn-view-tickets"
          >
            Ver Tickets
          </router-link>
        </div>
      </div>

      <div class="stat-card rating-card">
        <div class="stat-icon">⭐</div>
        <div class="stat-content">
          <h3>{{ stats.avgRating.toFixed(1) }}</h3>
          <p>Rating Promedio</p>
          <div class="rating-stars">
            <span v-for="n in 5" :key="n" :class="n <= Math.round(stats.avgRating) ? 'star-filled' : 'star-empty'">
              ★
            </span>
          </div>
        </div>
        <div class="rating-trend">🏆</div>
      </div>
    </section>

    <!-- Gráfico -->
    <section class="chart-section">
      <div class="section-header">
        <h2><span class="trend-icon">📈</span> Solicitudes últimos 30 días</h2>
        <div class="chart-controls">
          <select class="chart-filter">
            <option>Últimos 30 días</option>
            <option>Últimos 7 días</option>
            <option>Últimos 90 días</option>
          </select>
        </div>
      </div>
      
      <div class="chart-container">
        <canvas
          ref="chartCanvas"
          width="400"
          height="200"
          class="chart-canvas"
        />
        <div v-if="!stats.porDia || stats.porDia.length === 0" class="chart-empty">
          <div class="empty-icon">📊</div>
          <p>No hay datos para mostrar</p>
        </div>
      </div>
    </section>

    <!-- Tablas de datos -->
    <div class="tables-section">
      <!-- Top servicios -->
      <section class="data-table">
        <div class="table-header">
          <h2><span class="top-icon">🏆</span> Top 5 servicios más pedidos</h2>
          <router-link to="/admin/services" class="btn-view-all">
            Ver todos →
          </router-link>
        </div>
        
        <div class="table-container">
          <table>
            <thead>
              <tr>
                <th class="col-service">Servicio</th>
                <th class="col-requests">Solicitudes</th>
                <th class="col-trend">Tendencia</th>
                <th class="col-actions">Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="(s, index) in stats.topServicios"
                :key="s.title"
                :class="['table-row', `row-${index + 1}`]"
              >
                <td class="service-cell">
                  <div class="service-info">
                    <span class="service-rank">#{{ index + 1 }}</span>
                    <div class="service-details">
                      <h4>{{ s.title }}</h4>
                      <span class="service-category">Categoría</span>
                    </div>
                  </div>
                </td>
                <td class="requests-cell">
                  <span class="request-count">{{ s.veces }}</span>
                  <span class="request-label">solicitudes</span>
                </td>
                <td class="trend-cell">
                  <span class="trend-indicator" :class="getTrendClass(index)">
                    {{ getTrendIcon(index) }}
                  </span>
                </td>
                <td class="actions-cell">
                  <button class="btn-action" @click="viewServiceDetails(s)">
                    👁️ Ver
                  </button>
                </td>
              </tr>
              <tr v-if="!stats.topServicios || stats.topServicios.length === 0" class="empty-row">
                <td colspan="4">
                  <div class="table-empty">
                    <span>📊</span>
                    <p>No hay datos de servicios disponibles</p>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>

      <!-- Datos adicionales (puedes agregar más tablas aquí) -->
      <section class="quick-stats">
        <div class="stats-header">
          <h2><span class="stats-icon">📊</span> Resumen Rápido</h2>
        </div>
        <div class="quick-stats-grid">
          <div class="quick-stat">
            <div class="quick-stat-icon">📅</div>
            <div class="quick-stat-content">
              <h4>Hoy</h4>
              <p>0 solicitudes</p>
            </div>
          </div>
          <div class="quick-stat">
            <div class="quick-stat-icon">📱</div>
            <div class="quick-stat-content">
              <h4>Activos ahora</h4>
              <p>0 usuarios</p>
            </div>
          </div>
          <div class="quick-stat">
            <div class="quick-stat-icon">⏱️</div>
            <div class="quick-stat-content">
              <h4>Tiempo promedio</h4>
              <p>0 min</p>
            </div>
          </div>
          <div class="quick-stat">
            <div class="quick-stat-icon">💬</div>
            <div class="quick-stat-content">
              <h4>Satisfacción</h4>
              <p>0%</p>
            </div>
          </div>
        </div>
      </section>
    </div>

    <!-- Toast Notifications -->
    <div v-if="showToast" class="toast" :class="toastType">
      {{ toastMessage }}
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import api from '@/axios'
import { Chart, registerables } from 'chart.js'
Chart.register(...registerables)

const router = useRouter()

// Estado reactivo (manteniendo tu lógica exactamente igual)
const stats = ref({
  totalUsers: 0,
  totalServices: 0,
  totalRequests: 0,
  totalTickets: 0,
  ingresos: 0,
  porDia: [],
  topServicios: [],
  avgRating: 0
})

const chartCanvas = ref(null)
let chartInstance = null
let abortCtrl = null

// Estados para el nuevo diseño
const showToast = ref(false)
const toastMessage = ref('')
const toastType = ref('success')

/* ---------- MÉTODOS EXISTENTES (NO CAMBIADOS) ---------- */
function drawChartOnce() {
  if (!chartCanvas.value) return

  // destruye anterior
  if (chartInstance) {
    chartInstance.destroy()
    chartInstance = null
  }

  // limpia canvas
  const ctx = chartCanvas.value.getContext('2d')
  ctx.clearRect(0, 0, chartCanvas.value.width, chartCanvas.value.height)

  const labels = stats.value.porDia.map(d => d.dia)
  const values = stats.value.porDia.map(d => d.cant)
  if (!labels.length || !values.length) return

  chartInstance = new Chart(ctx, {
    type: 'line',
    data: {
      labels,
      datasets: [{
        label: 'Solicitudes',
        data: values,
        borderColor: '#667eea',
        backgroundColor: 'rgba(102, 126, 234, 0.1)',
        borderWidth: 3,
        tension: 0.4,
        fill: true,
        pointRadius: 6,
        pointBackgroundColor: '#667eea',
        pointBorderColor: '#ffffff',
        pointBorderWidth: 2,
        pointHoverRadius: 8
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: { 
          display: false 
        },
        tooltip: { 
          enabled: true,
          backgroundColor: 'rgba(0, 0, 0, 0.8)',
          padding: 12,
          cornerRadius: 8
        }
      },
      scales: {
        x: { 
          grid: { display: false },
          ticks: { 
            maxTicksLimit: 7,
            font: { size: 12 }
          }
        },
        y: { 
          beginAtZero: true,
          grid: { 
            color: 'rgba(0, 0, 0, 0.05)'
          },
          ticks: { 
            font: { size: 12 }
          }
        }
      }
    }
  })
}

onMounted(async () => {
  abortCtrl = new AbortController()
  try {
    const { data } = await api.get('/admin/reports', { signal: abortCtrl.signal })
    stats.value = data
    drawChartOnce()
    showNotification('Datos cargados correctamente', 'success')
  } catch (e) {
    if (e.name !== 'CanceledError') {
      console.error(e)
      showNotification('Error al cargar los datos', 'error')
    }
  }
})

onUnmounted(() => {
  abortCtrl?.abort()
  if (chartInstance) {
    chartInstance.destroy()
    chartInstance = null
  }
  // remove canvas listeners
  if (chartCanvas.value) {
    chartCanvas.value.replaceWith(chartCanvas.value.cloneNode(true))
  }
})

/* ---------- NUEVOS MÉTODOS DE DISEÑO ---------- */
function formatNumber(num) {
  return new Intl.NumberFormat('es-ES').format(num)
}

function getTrendClass(index) {
  const trends = ['trend-up', 'trend-up', 'trend-neutral', 'trend-down', 'trend-down']
  return trends[index] || 'trend-neutral'
}

function getTrendIcon(index) {
  const icons = ['📈', '📈', '➡️', '📉', '📉']
  return icons[index] || '➡️'
}

function viewServiceDetails(service) {
  // Aquí puedes implementar la lógica para ver detalles del servicio
  console.log('Ver detalles:', service)
  showNotification(`Viendo detalles de ${service.title}`, 'info')
}

function refreshData() {
  showNotification('Actualizando datos...', 'info')
  // Aquí podrías recargar los datos
  location.reload() // O implementar una recarga más elegante
}

function exportReports() {
  showNotification('Exportando reporte...', 'info')
  // Implementar lógica de exportación
}

function showNotification(message, type) {
  toastMessage.value = message
  toastType.value = type
  showToast.value = true
  setTimeout(() => {
    showToast.value = false
  }, 3000)
}
</script>

<style scoped>
.admin-reports-page {
  max-width: 1400px;
  margin: 0 auto;
  padding: 24px;
  min-height: 100vh;
  background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
  font-family: 'Segoe UI', system-ui, sans-serif;
}

/* Header */
.header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 40px;
  flex-wrap: wrap;
  gap: 20px;
  background: white;
  padding: 32px;
  border-radius: 20px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
}

.title-section h1 {
  font-size: 2.5rem;
  color: #1e293b;
  margin-bottom: 8px;
  display: flex;
  align-items: center;
  gap: 15px;
}

.chart-icon {
  font-size: 2.2rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.title-section p {
  color: #64748b;
  font-size: 1.2rem;
  font-weight: 400;
}

.header-actions {
  display: flex;
  gap: 15px;
  align-items: center;
}

.btn-export {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: white;
  border: none;
  padding: 14px 28px;
  border-radius: 12px;
  cursor: pointer;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 10px;
  transition: all 0.3s;
  font-size: 1rem;
}

.btn-export:hover {
  transform: translateY(-3px);
  box-shadow: 0 10px 20px rgba(16, 185, 129, 0.3);
}

.btn-refresh {
  background: #3b82f6;
  color: white;
  border: none;
  padding: 14px 28px;
  border-radius: 12px;
  cursor: pointer;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 10px;
  transition: all 0.3s;
  font-size: 1rem;
}

.btn-refresh:hover {
  transform: translateY(-3px);
  box-shadow: 0 10px 20px rgba(59, 130, 246, 0.3);
}

/* Summary Stats Cards */
.summary-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 24px;
  margin-bottom: 40px;
}

.stat-card {
  background: white;
  padding: 28px;
  border-radius: 20px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
  transition: all 0.4s;
  cursor: pointer;
  position: relative;
  overflow: hidden;
  border: 1px solid #f1f5f9;
}

.stat-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.12);
}

.stat-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.stat-card.revenue-card::before {
  background: linear-gradient(135deg, #fbbf24 0%, #f59e0b 100%);
}

.stat-card.warning-card::before {
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
}

.stat-card.rating-card::before {
  background: linear-gradient(135deg, #f472b6 0%, #db2777 100%);
}

.stat-icon {
  font-size: 3rem;
  margin-bottom: 20px;
}

.stat-content h3 {
  font-size: 2.8rem;
  color: #1e293b;
  margin-bottom: 8px;
  font-weight: 700;
}

.stat-content p {
  color: #64748b;
  font-size: 1rem;
  font-weight: 500;
}

.stat-trend, .stat-badge {
  position: absolute;
  top: 24px;
  right: 24px;
  font-size: 2rem;
  opacity: 0.7;
}

/* Warning Card Specific */
.stat-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 8px;
}

.alert-badge {
  background: #ef4444;
  color: white;
  width: 24px;
  height: 24px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.8rem;
  font-weight: bold;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.1); }
}

.btn-view-tickets {
  display: inline-block;
  background: #ef4444;
  color: white;
  padding: 8px 20px;
  border-radius: 8px;
  text-decoration: none;
  font-weight: 600;
  font-size: 0.9rem;
  margin-top: 12px;
  transition: all 0.3s;
}

.btn-view-tickets:hover {
  background: #dc2626;
  transform: translateY(-2px);
}

/* Rating Card Specific */
.rating-stars {
  display: flex;
  gap: 4px;
  margin-top: 12px;
}

.star-filled {
  color: #fbbf24;
  font-size: 1.2rem;
}

.star-empty {
  color: #e5e7eb;
  font-size: 1.2rem;
}

/* Chart Section */
.chart-section {
  background: white;
  padding: 32px;
  border-radius: 20px;
  margin-bottom: 40px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 32px;
  flex-wrap: wrap;
  gap: 20px;
}

.section-header h2 {
  font-size: 1.8rem;
  color: #1e293b;
  display: flex;
  align-items: center;
  gap: 12px;
}

.trend-icon {
  font-size: 2rem;
  background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.chart-controls {
  display: flex;
  gap: 12px;
}

.chart-filter {
  padding: 10px 20px;
  border: 2px solid #e2e8f0;
  border-radius: 10px;
  font-size: 1rem;
  background: white;
  cursor: pointer;
  transition: all 0.3s;
}

.chart-filter:focus {
  outline: none;
  border-color: #3b82f6;
}

.chart-container {
  position: relative;
  height: 300px;
  width: 100%;
}

.chart-canvas {
  width: 100% !important;
  height: 100% !important;
}

.chart-empty {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: #94a3b8;
}

.chart-empty .empty-icon {
  font-size: 4rem;
  margin-bottom: 16px;
  opacity: 0.5;
}

/* Tables Section */
.tables-section {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 32px;
  margin-bottom: 40px;
}

@media (max-width: 1200px) {
  .tables-section {
    grid-template-columns: 1fr;
  }
}

.data-table, .quick-stats {
  background: white;
  padding: 32px;
  border-radius: 20px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
}

.table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.table-header h2 {
  font-size: 1.8rem;
  color: #1e293b;
  display: flex;
  align-items: center;
  gap: 12px;
}

.top-icon {
  font-size: 2rem;
  background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.btn-view-all {
  color: #3b82f6;
  text-decoration: none;
  font-weight: 600;
  font-size: 1rem;
  transition: all 0.3s;
  padding: 8px 16px;
  border-radius: 8px;
  border: 2px solid transparent;
}

.btn-view-all:hover {
  border-color: #3b82f6;
  background: rgba(59, 130, 246, 0.05);
}

.table-container {
  overflow-x: auto;
}

table {
  width: 100%;
  border-collapse: separate;
  border-spacing: 0;
}

thead {
  background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
}

th {
  padding: 20px;
  text-align: left;
  color: #64748b;
  font-weight: 600;
  font-size: 0.9rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  border-bottom: 2px solid #e2e8f0;
}

.col-service { width: 40%; }
.col-requests { width: 20%; }
.col-trend { width: 20%; }
.col-actions { width: 20%; }

.table-row {
  transition: all 0.3s;
  border-bottom: 1px solid #f1f5f9;
}

.table-row:hover {
  background: #f8fafc;
  transform: scale(1.002);
}

.table-row.row-1 { border-left: 4px solid #fbbf24; }
.table-row.row-2 { border-left: 4px solid #94a3b8; }
.table-row.row-3 { border-left: 4px solid #f59e0b; }
.table-row.row-4 { border-left: 4px solid #64748b; }
.table-row.row-5 { border-left: 4px solid #475569; }

td {
  padding: 20px;
  vertical-align: middle;
}

.service-cell .service-info {
  display: flex;
  align-items: center;
  gap: 16px;
}

.service-rank {
  background: #f1f5f9;
  color: #64748b;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 1rem;
}

.service-details h4 {
  margin: 0 0 4px 0;
  color: #1e293b;
  font-size: 1.1rem;
}

.service-category {
  color: #94a3b8;
  font-size: 0.85rem;
  background: #f8fafc;
  padding: 4px 12px;
  border-radius: 20px;
}

.requests-cell {
  text-align: center;
}

.request-count {
  font-size: 2rem;
  font-weight: 700;
  color: #1e293b;
  display: block;
}

.request-label {
  color: #94a3b8;
  font-size: 0.9rem;
}

.trend-cell {
  text-align: center;
}

.trend-indicator {
  font-size: 1.5rem;
  display: inline-block;
  padding: 10px;
  border-radius: 12px;
  background: #f1f5f9;
}

.trend-up { color: #10b981; }
.trend-down { color: #ef4444; }
.trend-neutral { color: #94a3b8; }

.actions-cell {
  text-align: center;
}

.btn-action {
  background: #3b82f6;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  font-size: 0.9rem;
  transition: all 0.3s;
}

.btn-action:hover {
  background: #2563eb;
  transform: translateY(-2px);
}

.empty-row td {
  padding: 60px 20px;
  text-align: center;
}

.table-empty {
  color: #94a3b8;
  font-size: 1.1rem;
}

.table-empty span {
  font-size: 3rem;
  display: block;
  margin-bottom: 16px;
  opacity: 0.5;
}

/* Quick Stats */
.stats-header h2 {
  font-size: 1.8rem;
  color: #1e293b;
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 24px;
}

.stats-icon {
  font-size: 2rem;
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.quick-stats-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
}

.quick-stat {
  background: #f8fafc;
  padding: 24px;
  border-radius: 16px;
  transition: all 0.3s;
  border: 2px solid transparent;
}

.quick-stat:hover {
  border-color: #e2e8f0;
  transform: translateY(-4px);
}

.quick-stat-icon {
  font-size: 2rem;
  margin-bottom: 16px;
}

.quick-stat-content h4 {
  margin: 0 0 8px 0;
  color: #64748b;
  font-size: 0.9rem;
  font-weight: 600;
}

.quick-stat-content p {
  margin: 0;
  color: #1e293b;
  font-size: 1.5rem;
  font-weight: 700;
}

/* Toast */
.toast {
  position: fixed;
  bottom: 32px;
  right: 32px;
  padding: 20px 32px;
  border-radius: 12px;
  color: white;
  font-weight: 600;
  z-index: 1000;
  animation: slideIn 0.3s ease-out;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
  min-width: 300px;
  text-align: center;
}

.toast.success {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
}

.toast.error {
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
}

.toast.info {
  background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
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

/* Responsive */
@media (max-width: 1024px) {
  .header {
    flex-direction: column;
    text-align: center;
  }
  
  .title-section h1 {
    font-size: 2rem;
  }
  
  .summary-stats {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 768px) {
  .admin-reports-page {
    padding: 16px;
  }
  
  .header {
    padding: 24px;
  }
  
  .title-section h1 {
    font-size: 1.8rem;
  }
  
  .summary-stats {
    grid-template-columns: 1fr;
  }
  
  .header-actions {
    flex-direction: column;
    width: 100%;
  }
  
  .btn-export, .btn-refresh {
    width: 100%;
    justify-content: center;
  }
  
  .section-header {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .quick-stats-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 480px) {
  .chart-container {
    height: 250px;
  }
  
  .table-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 16px;
  }
  
  .btn-view-all {
    align-self: flex-start;
  }
  
  .toast {
    left: 16px;
    right: 16px;
    bottom: 16px;
    min-width: auto;
  }
}
</style>
