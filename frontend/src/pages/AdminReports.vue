<template>
  <div class="admin-reports">
    <h2>Informes</h2>

    <!-- Cards -->
    <section class="cards">
      <div class="card"><h3>Usuarios</h3><p>{{ stats.totalUsers }}</p></div>
      <div class="card"><h3>Servicios Activos</h3><p>{{ stats.totalServices }}</p></div>
      <div class="card"><h3>Solicitudes</h3><p>{{ stats.totalRequests }}</p></div>
      <div class="card"><h3>Ingresos</h3><p>$ {{ stats.ingresos }}</p></div>
      <div class="card"><h3>Tickets abiertos</h3>
        <p>{{ stats.totalTickets }}
          <router-link v-if="stats.totalTickets" to="/admin/tickets" class="badge danger">Ver</router-link>
        </p>
      </div>
      <div class="card"><h3>Rating promedio</h3><p>{{ stats.avgRating }} ⭐</p></div>
    </section>

    <!-- Gráfico -->
    <section class="chart">
      <h3>Solicitudes últimos 30 días</h3>
      <canvas ref="chartCanvas" width="400" height="150"></canvas>
    </section>

    <!-- Top servicios -->
    <section class="top">
      <h3>Top 5 servicios más pedidos</h3>
      <table>
        <thead><tr><th>Servicio</th><th>Cantidad</th></tr></thead>
        <tbody>
          <tr v-for="s in stats.topServicios" :key="s.title">
            <td>{{ s.title }}</td><td>{{ s.veces }}</td>
          </tr>
        </tbody>
      </table>
    </section>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import api from '@/axio'
import { Chart, registerables } from 'chart.js'
Chart.register(...registerables)

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

/* ---------- 1.  ÚNICO DIBUJADO: sin plugins que leak ---------- */
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
        borderColor: '#3b82f6',
        tension: 0.3,
        fill: false,
        pointRadius: 0,
        pointHoverRadius: 0
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      animation: false,
      plugins: {
        legend: { display: false },
        tooltip: { enabled: false }
      },
      interaction: { mode: null },
      scales: {
        x: { ticks: { maxTicksLimit: 7 } },
        y: { beginAtZero: true }
      }
    }
  })
}

/* ---------- 2.  FETCH UNA SOLA VEZ ---------- */
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

/* ---------- 3.  LIMPIEZA TOTAL ---------- */
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
</script>

<style scoped>
.admin-reports {
  padding: 1rem;
  font-family: system-ui, sans-serif;
}
h2 { margin-bottom: 1rem; }
.cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 1rem;
  margin-bottom: 2rem;
}
.card {
  background: #fff;
  border: 1px solid #ddd;
  border-radius: 8px;
  padding: 1rem;
  text-align: center;
}
.card h3 { margin: 0 0 0.5rem; font-size: 0.9rem; color: #555; }
.card p { margin: 0; font-size: 1.5rem; font-weight: 600; }
.badge.danger {
  background: #ef4444;
  color: #fff;
  padding: 0.2rem 0.4rem;
  border-radius: 4px;
  font-size: 0.75rem;
  margin-left: 0.5rem;
  text-decoration: none;
}
.chart, .top { margin-bottom: 2rem; }
.chart h3, .top h3 { margin-bottom: 0.5rem; }
table { width: 100%; border-collapse: collapse; }
th, td { padding: 0.5rem; border: 1px solid #ddd; text-align: left; }
th { background: #f5f5f5; }
</style>
