<template>
  <div class="admin-monetization">
    <!-- Header -->
    <div class="header">
      <div class="title-section">
        <h1><span class="admin-icon">💰</span> Monetización</h1>
        <p>Configura cómo gana dinero la plataforma</p>
      </div>
      <button class="btn-refresh" @click="loadConfig" :disabled="loading">
        {{ loading ? '⏳' : '🔄' }} Actualizar
      </button>
    </div>

    <!-- Earnings Overview -->
    <div class="earnings-section">
      <div class="earnings-card total">
        <div class="earnings-icon">💵</div>
        <div class="earnings-content">
          <h3>Ganancias Totales</h3>
          <p class="earnings-value">${{ formatCurrency(earnings.total) }}</p>
        </div>
      </div>
      <div class="earnings-card commissions">
        <div class="earnings-icon">📊</div>
        <div class="earnings-content">
          <h3>Por Comisiones</h3>
          <p class="earnings-value">${{ formatCurrency(earnings.commissions) }}</p>
        </div>
      </div>
      <div class="earnings-card publications">
        <div class="earnings-icon">📦</div>
        <div class="earnings-content">
          <h3>Por Publicaciones</h3>
          <p class="earnings-value">${{ formatCurrency(earnings.publications) }}</p>
        </div>
      </div>
      <div class="earnings-card month">
        <div class="earnings-icon">📅</div>
        <div class="earnings-content">
          <h3>Este Mes</h3>
          <p class="earnings-value">${{ formatCurrency(earnings.this_month) }}</p>
        </div>
      </div>
    </div>

    <!-- Config Section -->
    <div class="config-section">
      <div class="config-card">
        <h2>⚙️ Modelo de Monetización</h2>
        <p class="config-desc">Elige cómo quieres generar ingresos con la plataforma</p>

        <div class="model-selector">
          <div v-for="model in models" :key="model.value"
            :class="['model-option', { active: config.monetization_model === model.value }]"
            @click="config.monetization_model = model.value">
            <span class="model-icon">{{ model.icon }}</span>
            <div class="model-info">
              <h4>{{ model.label }}</h4>
              <p>{{ model.desc }}</p>
            </div>
            <span v-if="config.monetization_model === model.value" class="model-check">✅</span>
          </div>
        </div>

        <!-- Commission Settings -->
        <div v-if="config.monetization_model === 'commission' || config.monetization_model === 'both'" class="sub-config">
          <h3>📊 Configuración de Comisiones</h3>
          <div class="form-grid">
            <div class="form-group">
              <label>Porcentaje de comisión (%)</label>
              <input type="number" v-model.number="config.commission_percentage" min="0" max="100" step="0.1" class="form-input" />
              <p class="form-hint">Porcentaje que se retiene de cada transacción</p>
            </div>
            <div class="form-group">
              <label>Comisión mínima ($)</label>
              <input type="number" v-model.number="config.commission_min" min="0" step="0.01" class="form-input" />
              <p class="form-hint">Monto mínimo a cobrar por transacción</p>
            </div>
          </div>
          <div class="example-box">
            <h4>💡 Ejemplo:</h4>
            <p>Para un servicio de <strong>$100</strong> con comisión del <strong>{{ config.commission_percentage }}%</strong>:</p>
            <p>Comisión = <strong>${{ formatCurrency(Math.max(100 * config.commission_percentage / 100, config.commission_min)) }}</strong></p>
          </div>
        </div>

        <!-- Publish Settings -->
        <div v-if="config.monetization_model === 'publish' || config.monetization_model === 'both'" class="sub-config">
          <h3>📦 Pago por Publicar Servicios</h3>
          <div class="form-grid">
            <div class="form-group">
              <label>Costo por publicación ($)</label>
              <input type="number" v-model.number="config.publish_cost" min="0" step="0.01" class="form-input" />
              <p class="form-hint">Monto que paga el proveedor por publicar (0 = gratis)</p>
            </div>
            <div class="form-group">
              <label>Duración de la publicación (días)</label>
              <input type="number" v-model.number="config.publish_duration_days" min="1" max="365" class="form-input" />
              <p class="form-hint">Tiempo que el servicio permanece activo después del pago</p>
            </div>
          </div>
        </div>

        <div class="config-actions">
          <span v-if="saved" class="saved-msg">✅ Guardado</span>
          <button class="btn-save" @click="saveConfig" :disabled="saving">
            {{ saving ? '💾 Guardando...' : '💾 Guardar Configuración' }}
          </button>
        </div>
      </div>
    </div>

    <!-- History -->
    <div class="history-section">
      <h2>📋 Historial de Ganancias</h2>
      <div v-if="history.length === 0" class="empty">No hay registros aún</div>
      <div v-else class="history-table">
        <table>
          <thead>
            <tr>
              <th>Fecha</th>
              <th>Tipo</th>
              <th>Monto</th>
              <th>Usuario</th>
              <th>Ref. ID</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in history" :key="item.id">
              <td>{{ formatDate(item.created_at) }}</td>
              <td><span class="type-badge" :class="item.type">{{ getTypeLabel(item.type) }}</span></td>
              <td class="amount">${{ formatCurrency(item.amount) }}</td>
              <td>{{ item.user_name || '—' }}</td>
              <td>{{ item.reference_id || '—' }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Toast -->
    <div v-if="toast.show" class="toast" :class="toast.type">{{ toast.message }}</div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useAuthStore } from '@/stores/authStore'
import api from '@/axios'

const authStore = useAuthStore()

const loading = ref(false)
const saving = ref(false)
const saved = ref(false)

const config = reactive({
  monetization_model: 'commission',
  commission_percentage: 10,
  commission_min: 1,
  publish_cost: 0,
  publish_duration_days: 30
})

const earnings = reactive({
  total: 0,
  commissions: 0,
  publications: 0,
  this_month: 0
})

const history = ref([])
const toast = ref({ show: false, message: '', type: 'success' })

const models = [
  { value: 'commission', label: 'Solo Comisiones', icon: '📊', desc: 'Cobra un % de cada transacción entre usuario y proveedor' },
  { value: 'publish', label: 'Pago por Publicar', icon: '📦', desc: 'Los proveedores pagan por publicar sus servicios' },
  { value: 'both', label: 'Ambos modelos', icon: '💵', desc: 'Combina comisiones por transacción + pago por publicar' }
]

const formatCurrency = (v) => Number(v || 0).toFixed(2)
const formatDate = (d) => d ? new Date(d).toLocaleDateString('es-ES', { day: '2-digit', month: 'short', year: 'numeric' }) : ''
const getTypeLabel = (t) => ({ transaction_commission: 'Comisión', service_publish: 'Publicación' }[t] || t)

const showToast = (msg, type = 'success') => {
  toast.value = { show: true, message: msg, type }
  setTimeout(() => { toast.value.show = false }, 3000)
}

const loadConfig = async () => {
  loading.value = true
  try {
    const { data } = await api.get('/admin/monetization/config', { headers: { Authorization: `Bearer ${authStore.token}` } })
    if (data?.config) Object.assign(config, data.config)
    if (data?.config?.platform_earnings) Object.assign(earnings, data.config.platform_earnings)

    // Cargar historial
    const earnRes = await api.get('/admin/monetization/earnings', { headers: { Authorization: `Bearer ${authStore.token}` } })
    if (earnRes.data?.summary) Object.assign(earnings, earnRes.data.summary)
    history.value = earnRes.data?.history || []
  } catch (e) {
    showToast('Error al cargar configuración', 'error')
  } finally {
    loading.value = false
  }
}

const saveConfig = async () => {
  saving.value = true
  saved.value = false
  try {
    await api.put('/admin/monetization/config', { ...config }, { headers: { Authorization: `Bearer ${authStore.token}` } })
    saved.value = true
    showToast('Configuración guardada')
    setTimeout(() => { saved.value = false }, 3000)
  } catch (e) {
    showToast('Error al guardar', 'error')
  } finally {
    saving.value = false
  }
}

onMounted(loadConfig)
</script>

<style scoped>
.admin-monetization {
  padding: 24px;
  max-width: 1000px;
  margin: 0 auto;
}

/* Header */
.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  flex-wrap: wrap;
  gap: 12px;
}

.title-section h1 {
  font-size: 1.8rem;
  font-weight: 700;
  color: #1a1a2e;
  margin: 0;
}

.title-section p {
  color: #666;
  margin: 4px 0 0;
}

.admin-icon { margin-right: 8px; }

.btn-refresh {
  padding: 10px 20px;
  background: #667eea;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
}

.btn-refresh:disabled { opacity: 0.6; }

/* Earnings */
.earnings-section {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
  margin-bottom: 24px;
}

.earnings-card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 14px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
}

.earnings-icon { font-size: 2rem; }

.earnings-content h3 {
  margin: 0;
  font-size: 0.85rem;
  color: #888;
}

.earnings-value {
  font-size: 1.5rem;
  font-weight: 700;
  color: #1a1a2e;
  margin: 4px 0 0;
}

/* Config */
.config-section {
  margin-bottom: 24px;
}

.config-card {
  background: white;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
}

.config-card h2 { margin: 0 0 8px; }

.config-desc { color: #888; margin: 0 0 20px; }

.model-selector {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 12px;
  margin-bottom: 20px;
}

.model-option {
  border: 2px solid #eee;
  border-radius: 12px;
  padding: 16px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 12px;
  transition: all 0.3s;
}

.model-option:hover { border-color: #667eea; }
.model-option.active { border-color: #667eea; background: #f8f9ff; }

.model-icon { font-size: 1.8rem; }
.model-info h4 { margin: 0 0 4px; }
.model-info p { margin: 0; font-size: 0.85rem; color: #888; }
.model-check { font-size: 1.2rem; }

.sub-config {
  background: #fafafa;
  border-radius: 10px;
  padding: 20px;
  margin-top: 16px;
}

.sub-config h3 { margin: 0 0 16px; }

.form-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.form-group label {
  display: block;
  font-weight: 600;
  margin-bottom: 6px;
  font-size: 0.9rem;
}

.form-input {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 1rem;
  max-width: 200px;
}

.form-hint {
  font-size: 0.8rem;
  color: #aaa;
  margin: 4px 0 0;
}

.example-box {
  margin-top: 12px;
  background: #fffde7;
  padding: 12px 16px;
  border-radius: 8px;
}

.example-box h4 { margin: 0 0 6px; }
.example-box p { margin: 2px 0; font-size: 0.9rem; }

.config-actions {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 12px;
  margin-top: 20px;
}

.saved-msg { color: #4caf50; font-weight: 600; }

.btn-save {
  padding: 12px 28px;
  background: #667eea;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
}

.btn-save:disabled { opacity: 0.6; }

/* History */
.history-section {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
}

.history-section h2 { margin: 0 0 16px; }

.empty { text-align: center; color: #aaa; padding: 40px; }

.history-table { overflow-x: auto; }

table { width: 100%; border-collapse: collapse; }

th {
  text-align: left;
  padding: 10px;
  border-bottom: 2px solid #eee;
  font-size: 0.85rem;
  color: #888;
}

td {
  padding: 10px;
  border-bottom: 1px solid #f0f0f0;
  font-size: 0.9rem;
}

.amount { font-weight: 600; color: #2e7d32; }

.type-badge {
  padding: 3px 10px;
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: 500;
}

.type-badge.transaction_commission { background: #e8f0fe; color: #1a73e8; }
.type-badge.service_publish { background: #e8f5e9; color: #2e7d32; }

/* Toast */
.toast {
  position: fixed;
  bottom: 24px;
  right: 24px;
  padding: 12px 24px;
  border-radius: 8px;
  color: white;
  z-index: 1000;
}

.toast.success { background: #4caf50; }
.toast.error { background: #f44336; }
</style>
