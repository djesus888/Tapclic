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

    <!-- Tabs de navegación -->
    <div class="tabs-navigation">
      <button
        class="tab-button"
        :class="{ active: activeTab === 'dashboard' }"
        @click="activeTab = 'dashboard'"
      >
        <span class="tab-icon">📊</span>
        Dashboard
      </button>
      <button
        class="tab-button"
        :class="{ active: activeTab === 'review-reports' }"
        @click="activeTab = 'review-reports'; fetchReviewReports()"
      >
        <span class="tab-icon">🚩</span>
        Reportes de Reseñas
        <span v-if="pendingReviewReports > 0" class="tab-badge">{{ pendingReviewReports }}</span>
      </button>
      <button
        class="tab-button"
        :class="{ active: activeTab === 'disputes' }"
        @click="activeTab = 'disputes'; fetchDisputes()"
      >
        <span class="tab-icon">⚖️</span>
        Disputas
        <span v-if="pendingDisputes > 0" class="tab-badge">{{ pendingDisputes }}</span>
      </button>
    </div>

    <!-- ==================== DASHBOARD (EXISTENTE) ==================== -->
    <div v-if="activeTab === 'dashboard'">
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
    </div>

    <!-- ==================== REPORTES DE RESEÑAS ==================== -->
    <div v-if="activeTab === 'review-reports'" class="review-reports-section">
      <div class="filters-bar">
        <select v-model="reviewFilter" class="filter-select" @change="fetchReviewReports">
          <option value="all">Todos los reportes</option>
          <option value="pending">⏳ Pendientes</option>
          <option value="resolved">✅ Resueltos</option>
        </select>

        <div class="filter-stats">
          <span class="filter-badge badge-pending">{{ pendingReviewReports }} pendientes</span>
          <span class="filter-badge badge-total">{{ reviewPagination.total || 0 }} total</span>
        </div>
      </div>

      <div v-if="reviewLoading" class="loading-container">
        <div class="spinner"></div>
        <p>Cargando reportes...</p>
      </div>

      <div v-else-if="!reviewReports.length" class="empty-state">
        <div class="empty-icon">✅</div>
        <h3>No hay reportes {{ reviewFilter === 'pending' ? 'pendientes' : '' }}</h3>
        <p>Todo en orden por ahora</p>
      </div>

      <div v-else class="reports-list">
        <div
          v-for="report in reviewReports"
          :key="report.id"
          class="review-report-card"
          :class="`status-${report.status}`"
        >
          <div class="report-header">
            <div class="report-meta">
              <span class="report-id">Reporte #{{ report.id }}</span>
              <span class="report-date">{{ formatDate(report.created_at) }}</span>
            </div>
            <span class="status-badge" :class="report.status">
              {{ report.status === 'pending' ? 'Pendiente' : 'Resuelto' }}
            </span>
          </div>

          <div class="report-body">
            <div class="report-info-grid">
              <div class="info-item">
                <span class="info-label">Tipo</span>
                <span class="info-value">{{ getReviewType(report.review_type) }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Reseña ID</span>
                <span class="info-value">#{{ report.review_id }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Reportado por</span>
                <span class="info-value">{{ report.reporter_name }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Motivo</span>
                <span class="info-value reason-text">{{ report.reason }}</span>
              </div>
            </div>

            <div v-if="report.comment" class="report-comment">
              <strong>Comentario:</strong> {{ report.comment }}
            </div>

            <div v-if="report.status === 'resolved'" class="resolution-details">
              <div class="resolution-header">
                <strong>Resolución:</strong>
                <span class="action-badge" :class="report.action_taken">
                  {{ getActionLabel(report.action_taken) }}
                </span>
              </div>
              <div v-if="report.resolver_name" class="resolver-info">
                Resuelto por: {{ report.resolver_name }} - {{ formatDate(report.resolved_at) }}
              </div>
              <div v-if="report.resolution_note" class="resolution-note">
                <strong>Nota:</strong> {{ report.resolution_note }}
              </div>
            </div>
          </div>

          <div v-if="report.status === 'pending'" class="report-actions">
            <button class="btn-resolve btn-dismiss" @click="openResolveModal(report.id, 'dismiss')">
              ✅ Desestimar
            </button>
            <button class="btn-resolve btn-warn" @click="openResolveModal(report.id, 'warn_user')">
              ⚠️ Advertir
            </button>
            <button class="btn-resolve btn-delete" @click="confirmDelete(report)">
              🗑️ Eliminar reseña
            </button>
          </div>
        </div>

        <div v-if="reviewPagination.total_pages > 1" class="pagination">
          <button
            :disabled="reviewPage === 1"
            @click="changeReviewPage(reviewPage - 1)"
            class="page-btn"
          >
            ← Anterior
          </button>
          <span>Página {{ reviewPage }} de {{ reviewPagination.total_pages }}</span>
          <button
            :disabled="reviewPage === reviewPagination.total_pages"
            @click="changeReviewPage(reviewPage + 1)"
            class="page-btn"
          >
            Siguiente →
          </button>
        </div>
      </div>
    </div>

    <!-- ==================== NUEVO: DISPUTAS ==================== -->
    <div v-if="activeTab === 'disputes'" class="review-reports-section">
      <div class="filters-bar">
        <select v-model="disputeFilter" class="filter-select" @change="fetchDisputes">
          <option value="open">⚖️ Abiertas</option>
          <option value="under_review">🔍 En revisión</option>
          <option value="resolved">✅ Resueltas</option>
          <option value="closed">🔒 Cerradas</option>
        </select>

        <div class="filter-stats">
          <span class="filter-badge badge-pending">{{ pendingDisputes }} abiertas</span>
        </div>
      </div>

      <div v-if="disputeLoading" class="loading-container">
        <div class="spinner"></div>
        <p>Cargando disputas...</p>
      </div>

      <div v-else-if="!disputes.length" class="empty-state">
        <div class="empty-icon">⚖️</div>
        <h3>No hay disputas {{ disputeFilter === 'open' ? 'abiertas' : '' }}</h3>
        <p>Todo en orden por ahora</p>
      </div>

      <div v-else class="reports-list">
        <div
          v-for="d in disputes"
          :key="d.id"
          class="review-report-card status-pending"
        >
          <div class="report-header">
            <div class="report-meta">
              <span class="report-id">Disputa #{{ d.id }}</span>
              <span class="report-date">{{ formatDate(d.created_at) }}</span>
            </div>
            <span class="status-badge" :class="d.status === 'open' ? 'pending' : 'resolved'">
              {{ disputeStatusLabel(d.status) }}
            </span>
          </div>

          <div class="report-body">
            <div class="report-info-grid">
              <div class="info-item">
                <span class="info-label">Solicitud ID</span>
                <span class="info-value">#{{ d.request_id }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Reportado por</span>
                <span class="info-value">{{ d.reporter_name }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Motivo</span>
                <span class="info-value reason-text">{{ d.reason }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Monto</span>
                <span class="info-value">${{ d.payment_amount || 'N/A' }}</span>
              </div>
            </div>

            <div v-if="d.description" class="report-comment">
              <strong>Descripción:</strong> {{ d.description }}
            </div>

            <div v-if="d.status === 'resolved'" class="resolution-details">
              <strong>Resolución:</strong> {{ d.resolution }}
            </div>
          </div>

          <div v-if="d.status === 'open'" class="report-actions">
            <button class="btn-resolve btn-dismiss" @click="openDisputeResolveModal(d.id, 'close')">
              ✅ Cerrar disputa
            </button>
            <button class="btn-resolve btn-warn" @click="openDisputeResolveModal(d.id, 'refund_user')">
              💰 Reembolsar
            </button>
            <button class="btn-resolve btn-delete" @click="openDisputeResolveModal(d.id, 'pay_provider')">
              💸 Pagar al proveedor
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de resolución (reseñas) -->
    <Teleport to="body">
      <div v-if="showResolveModal" class="modal-overlay" @click.self="showResolveModal = false">
        <div class="modal-content">
          <div class="modal-header">
            <h3>Resolver Reporte</h3>
            <button @click="showResolveModal = false" class="modal-close">✕</button>
          </div>
          <div class="modal-body">
            <div class="form-group">
              <label>Nota de resolución (opcional)</label>
              <textarea
                v-model="resolveNote"
                rows="3"
                placeholder="Agrega una nota..."
                class="modal-textarea"
              ></textarea>
            </div>
            <div v-if="resolveAction === 'delete_review'" class="warning-box">
              ⚠️ Esta acción eliminará permanentemente la reseña.
            </div>
          </div>
          <div class="modal-footer">
            <button @click="showResolveModal = false" class="btn-cancel">Cancelar</button>
            <button @click="resolveReport" class="btn-confirm" :class="`btn-${resolveAction}`">
              Confirmar
            </button>
          </div>
        </div>
      </div>
    </Teleport>

    <!-- Modal de resolución (disputas) - NUEVO -->
    <Teleport to="body">
      <div v-if="showDisputeResolveModal" class="modal-overlay" @click.self="showDisputeResolveModal = false">
        <div class="modal-content">
          <div class="modal-header dispute-modal-header">
            <h3>⚖️ Resolver Disputa</h3>
            <button @click="showDisputeResolveModal = false" class="modal-close">✕</button>
          </div>
          <div class="modal-body">
            <div class="form-group">
              <label>Nota de resolución (opcional)</label>
              <textarea
                v-model="disputeResolveNote"
                rows="3"
                placeholder="Agrega una nota..."
                class="modal-textarea"
              ></textarea>
            </div>
            <div v-if="disputeResolveAction === 'refund_user'" class="warning-box">
              💰 Se reembolsará el monto al wallet del usuario.
            </div>
          </div>
          <div class="modal-footer">
            <button @click="showDisputeResolveModal = false" class="btn-cancel">Cancelar</button>
            <button @click="resolveDispute" class="btn-confirm btn-dismiss">
              Confirmar
            </button>
          </div>
        </div>
      </div>
    </Teleport>

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
import Swal from 'sweetalert2'
Chart.register(...registerables)

const router = useRouter()

// ==================== ESTADO ====================

const activeTab = ref('dashboard')

// Dashboard
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

// Review Reports
const reviewReports = ref([])
const reviewLoading = ref(false)
const reviewFilter = ref('pending')
const reviewPage = ref(1)
const reviewPagination = ref({})
const pendingReviewReports = ref(0)

// Disputes (NUEVO)
const disputes = ref([])
const disputeLoading = ref(false)
const disputeFilter = ref('open')
const pendingDisputes = ref(0)

// Modal reseñas
const showResolveModal = ref(false)
const selectedReportId = ref(null)
const resolveAction = ref('')
const resolveNote = ref('')

// Modal disputas (NUEVO)
const showDisputeResolveModal = ref(false)
const selectedDisputeId = ref(null)
const disputeResolveAction = ref('')
const disputeResolveNote = ref('')

// Toast
const showToast = ref(false)
const toastMessage = ref('')
const toastType = ref('success')

/* ==================== MÉTODOS DASHBOARD ==================== */

function drawChartOnce() {
  if (!chartCanvas.value) return
  if (chartInstance) {
    chartInstance.destroy()
    chartInstance = null
  }
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
        legend: { display: false },
        tooltip: { enabled: true, backgroundColor: 'rgba(0, 0, 0, 0.8)', padding: 12, cornerRadius: 8 }
      },
      scales: {
        x: { grid: { display: false }, ticks: { maxTicksLimit: 7, font: { size: 12 } } },
        y: { beginAtZero: true, grid: { color: 'rgba(0, 0, 0, 0.05)' }, ticks: { font: { size: 12 } } }
      }
    }
  })
}

function formatNumber(num) {
  return new Intl.NumberFormat('es-ES').format(num)
}

function getTrendClass(index) {
  return ['trend-up', 'trend-up', 'trend-neutral', 'trend-down', 'trend-down'][index] || 'trend-neutral'
}

function getTrendIcon(index) {
  return ['📈', '📈', '➡️', '📉', '📉'][index] || '➡️'
}

function viewServiceDetails(service) {
  showNotification(`Viendo detalles de ${service.title}`, 'info')
}

function refreshData() {
  showNotification('Actualizando datos...', 'info')
  if (activeTab.value === 'dashboard') location.reload()
  else if (activeTab.value === 'review-reports') fetchReviewReports()
  else if (activeTab.value === 'disputes') fetchDisputes()
}

function exportReports() {
  showNotification('Exportando reporte...', 'info')
}

/* ==================== REVIEW REPORTS ==================== */

async function fetchReviewReports() {
  reviewLoading.value = true
  try {
    const { data } = await api.get('/api/admin/reports/reviews', {
      params: { status: reviewFilter.value, page: reviewPage.value, limit: 20 },
      headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
    })
    reviewReports.value = data.data || []
    reviewPagination.value = data.pagination || {}
    if (reviewFilter.value !== 'pending') {
      const pendingRes = await api.get('/api/admin/reports/reviews', {
        params: { status: 'pending', limit: 1 },
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
      })
      pendingReviewReports.value = pendingRes.data.pagination?.total || 0
    } else {
      pendingReviewReports.value = data.pagination?.total || 0
    }
  } catch (err) {
    showNotification('Error al cargar reportes', 'error')
  } finally {
    reviewLoading.value = false
  }
}

function openResolveModal(reportId, action) {
  selectedReportId.value = reportId
  resolveAction.value = action
  resolveNote.value = ''
  showResolveModal.value = true
}

async function resolveReport() {
  try {
    await api.post('/api/admin/reports/resolve', {
      report_id: selectedReportId.value,
      action: resolveAction.value,
      resolution_note: resolveNote.value
    }, { headers: { Authorization: `Bearer ${localStorage.getItem('token')}` } })
    showResolveModal.value = false
    showNotification('Reporte resuelto correctamente', 'success')
    fetchReviewReports()
  } catch (err) {
    showNotification('Error al resolver reporte', 'error')
  }
}

function confirmDelete(report) {
  Swal.fire({
    title: '¿Eliminar esta reseña?',
    text: 'Esta acción no se puede deshacer.',
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  }).then((result) => {
    if (result.isConfirmed) openResolveModal(report.id, 'delete_review')
  })
}

function changeReviewPage(page) {
  reviewPage.value = page
  fetchReviewReports()
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

/* ==================== DISPUTES (NUEVO) ==================== */

async function fetchDisputes() {
  disputeLoading.value = true
  try {
    const { data } = await api.get('/api/admin/disputes', {
      params: { status: disputeFilter.value },
      headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
    })
    disputes.value = data.disputes || []
    pendingDisputes.value = data.disputes?.filter(d => d.status === 'open').length || 0
  } catch (err) {
    showNotification('Error al cargar disputas', 'error')
  } finally {
    disputeLoading.value = false
  }
}

function openDisputeResolveModal(disputeId, action) {
  selectedDisputeId.value = disputeId
  disputeResolveAction.value = action
  disputeResolveNote.value = ''
  showDisputeResolveModal.value = true
}

async function resolveDispute() {
  try {
    await api.post('/api/admin/disputes/resolve', {
      dispute_id: selectedDisputeId.value,
      action: disputeResolveAction.value,
      resolution: disputeResolveNote.value
    }, { headers: { Authorization: `Bearer ${localStorage.getItem('token')}` } })
    showDisputeResolveModal.value = false
    showNotification('Disputa resuelta correctamente', 'success')
    fetchDisputes()
  } catch (err) {
    showNotification('Error al resolver disputa', 'error')
  }
}

function disputeStatusLabel(status) {
  const labels = { open: 'Abierta', under_review: 'En revisión', resolved: 'Resuelta', closed: 'Cerrada' }
  return labels[status] || status
}

/* ==================== HELPERS ==================== */

function formatDate(dateStr) {
  if (!dateStr) return 'N/A'
  return new Date(dateStr).toLocaleDateString('es-ES', {
    year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit'
  })
}

function getReviewType(type) {
  return { service: 'Servicio', service_review: 'Servicio', user: 'Usuario', user_review: 'Usuario' }[type] || type
}

function getActionLabel(action) {
  return { dismiss: 'Desestimado', warn_user: 'Usuario advertido', delete_review: 'Reseña eliminada' }[action] || action || 'N/A'
}

function showNotification(message, type) {
  toastMessage.value = message
  toastType.value = type
  showToast.value = true
  setTimeout(() => { showToast.value = false }, 3000)
}

/* ==================== LIFECYCLE ==================== */

onMounted(async () => {
  abortCtrl = new AbortController()
  try {
    const { data } = await api.get('/admin/reports', { signal: abortCtrl.signal })
    stats.value = data
    drawChartOnce()
  } catch (e) {
    if (e.name !== 'CanceledError') console.error(e)
  }
})

onUnmounted(() => {
  abortCtrl?.abort()
  if (chartInstance) { chartInstance.destroy(); chartInstance = null }
  if (chartCanvas.value) chartCanvas.value.replaceWith(chartCanvas.value.cloneNode(true))
})
</script>

<style scoped>
/* ==================== TABS NAVIGATION ==================== */
.tabs-navigation {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 2rem;
  border-bottom: 2px solid #e0e0e0;
  padding-bottom: 0;
}

.tab-button {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.5rem;
  border: none;
  background: none;
  cursor: pointer;
  font-size: 1rem;
  color: #666;
  border-bottom: 3px solid transparent;
  transition: all 0.3s;
  position: relative;
  bottom: -2px;
}

.tab-button:hover { color: #333; background: #f5f5f5; }

.tab-button.active { color: #667eea; border-bottom-color: #667eea; font-weight: 600; }

.tab-badge { background: #dc3545; color: white; padding: 0.15rem 0.5rem; border-radius: 10px; font-size: 0.75rem; font-weight: bold; }

/* ==================== REVIEW REPORTS SECTION ==================== */
.review-reports-section { animation: fadeIn 0.3s ease; }

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

.filters-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; gap: 1rem; flex-wrap: wrap; }

.filter-select { padding: 0.5rem 1rem; border: 1px solid #ddd; border-radius: 8px; font-size: 0.95rem; background: white; cursor: pointer; }

.filter-stats { display: flex; gap: 0.5rem; }

.filter-badge { padding: 0.25rem 0.75rem; border-radius: 20px; font-size: 0.85rem; font-weight: 500; }

.badge-pending { background: #fff3cd; color: #856404; }

.badge-total { background: #e2e3e5; color: #383d41; }

.reports-list { display: flex; flex-direction: column; gap: 1rem; }

.review-report-card { background: white; border-radius: 12px; box-shadow: 0 2px 8px rgba(0,0,0,0.08); overflow: hidden; transition: transform 0.2s; }

.review-report-card:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,0.12); }

.review-report-card.status-pending { border-left: 4px solid #ffc107; }

.review-report-card.status-resolved { border-left: 4px solid #28a745; }

.report-header { display: flex; justify-content: space-between; align-items: center; padding: 1rem 1.5rem; background: #f8f9fa; border-bottom: 1px solid #eee; }

.report-meta { display: flex; gap: 1rem; align-items: center; }

.report-id { font-weight: 600; color: #333; }

.report-date { color: #888; font-size: 0.9rem; }

.status-badge { padding: 0.25rem 0.75rem; border-radius: 20px; font-size: 0.85rem; font-weight: 500; }

.status-badge.pending { background: #fff3cd; color: #856404; }

.status-badge.resolved { background: #d4edda; color: #155724; }

.report-body { padding: 1.5rem; }

.report-info-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; }

.info-item { display: flex; flex-direction: column; }

.info-label { font-size: 0.8rem; color: #888; text-transform: uppercase; margin-bottom: 0.25rem; }

.info-value { font-weight: 500; color: #333; }

.reason-text { color: #dc3545; }

.report-comment { margin-top: 1rem; padding: 1rem; background: #f8f9fa; border-radius: 8px; color: #666; }

.resolution-details { margin-top: 1rem; padding: 1rem; background: #f0f8ff; border-radius: 8px; }

.action-badge { padding: 0.2rem 0.5rem; border-radius: 4px; font-size: 0.85rem; margin-left: 0.5rem; }

.action-badge.dismiss { background: #e2e3e5; color: #383d41; }

.action-badge.warn_user { background: #fff3cd; color: #856404; }

.action-badge.delete_review { background: #f8d7da; color: #721c24; }

.resolver-info { margin-top: 0.5rem; font-size: 0.9rem; color: #666; }

.resolution-note { margin-top: 0.5rem; font-style: italic; }

.report-actions { display: flex; gap: 0.5rem; padding: 1rem 1.5rem; background: #f8f9fa; border-top: 1px solid #eee; }

.btn-resolve { display: flex; align-items: center; gap: 0.5rem; padding: 0.5rem 1rem; border: none; border-radius: 6px; cursor: pointer; font-size: 0.9rem; transition: all 0.2s; color: white; }

.btn-dismiss { background: #28a745; }
.btn-dismiss:hover { background: #218838; }

.btn-warn { background: #ffc107; color: #000; }
.btn-warn:hover { background: #e0a800; }

.btn-delete { background: #dc3545; }
.btn-delete:hover { background: #c82333; }

/* Modal */
.modal-overlay { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); display: flex; align-items: center; justify-content: center; z-index: 1000; }

.modal-content { background: white; border-radius: 12px; width: 90%; max-width: 500px; }

.modal-header { display: flex; justify-content: space-between; align-items: center; padding: 1.5rem; border-bottom: 1px solid #eee; }

.dispute-modal-header { background: linear-gradient(135deg, #d63031 0%, #e17055 100%); color: white; border-radius: 12px 12px 0 0; }

.dispute-modal-header h3 { color: white; }

.modal-close { background: none; border: none; font-size: 1.5rem; cursor: pointer; color: #666; }

.dispute-modal-header .modal-close { color: white; }

.modal-body { padding: 1.5rem; }

.modal-textarea { width: 100%; padding: 0.75rem; border: 1px solid #ddd; border-radius: 8px; resize: vertical; }

.warning-box { margin-top: 1rem; padding: 1rem; background: #fff3cd; border-radius: 8px; color: #856404; }

.modal-footer { display: flex; justify-content: flex-end; gap: 0.5rem; padding: 1rem 1.5rem; border-top: 1px solid #eee; }

.btn-cancel { padding: 0.5rem 1rem; border: 1px solid #ddd; background: white; border-radius: 6px; cursor: pointer; }

.btn-confirm { padding: 0.5rem 1rem; border: none; border-radius: 6px; color: white; cursor: pointer; }

.btn-dismiss { background: #28a745; }
.btn-warn_user { background: #ffc107; color: #000; }
.btn-delete_review { background: #dc3545; }

.pagination { display: flex; justify-content: center; align-items: center; gap: 1rem; margin-top: 2rem; }

.page-btn { padding: 0.5rem 1rem; border: 1px solid #ddd; background: white; border-radius: 6px; cursor: pointer; }

.page-btn:disabled { opacity: 0.5; cursor: not-allowed; }

.loading-container { text-align: center; padding: 4rem; }

.spinner { width: 40px; height: 40px; border: 4px solid #f3f3f3; border-top: 4px solid #667eea; border-radius: 50%; animation: spin 1s linear infinite; margin: 0 auto 1rem; }

@keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }

.empty-state { text-align: center; padding: 4rem; }

.empty-icon { font-size: 4rem; margin-bottom: 1rem; }

.toast { position: fixed; bottom: 20px; right: 20px; padding: 1rem 1.5rem; border-radius: 8px; color: white; z-index: 2000; animation: slideIn 0.3s ease; }

.toast.success { background: #28a745; }
.toast.error { background: #dc3545; }
.toast.info { background: #17a2b8; }

@keyframes slideIn { from { transform: translateX(100%); opacity: 0; } to { transform: translateX(0); opacity: 1; } }

/* ... (todos los estilos existentes del dashboard se mantienen igual) ... */
</style>
