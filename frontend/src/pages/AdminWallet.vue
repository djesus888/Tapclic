<template>
  <div class="admin-wallet">
    <div class="admin-header">
      <h1>💰 Administración de Wallet</h1>
      <div class="stats-cards">
        <div class="stat-card">
          <span class="stat-value">{{ stats.pending_requests || 0 }}</span>
          <span class="stat-label">Pendientes</span>
        </div>
        <div class="stat-card">
          <span class="stat-value">€{{ stats.pending_amount?.toFixed(2) || 0 }}</span>
          <span class="stat-label">Monto pendiente</span>
        </div>
        <div class="stat-card">
          <span class="stat-value">€{{ stats.total_balance?.toFixed(2) || 0 }}</span>
          <span class="stat-label">Saldo total usuarios</span>
        </div>
      </div>
    </div>

    <!-- Tabs -->
    <div class="tabs">
      <button 
        class="tab" 
        :class="{ active: activeTab === 'requests' }"
        @click="activeTab = 'requests'"
      >
        📋 Solicitudes de recarga
      </button>
      <button 
        class="tab" 
        :class="{ active: activeTab === 'methods' }"
        @click="activeTab = 'methods'"
      >
        💳 Métodos de pago
      </button>
    </div>

    <!-- SECCIÓN SOLICITUDES -->
    <div v-if="activeTab === 'requests'" class="requests-section">
      <div class="filters">
        <select v-model="statusFilter" class="filter-select">
          <option value="pending">⏳ Pendientes</option>
          <option value="completed">✅ Completadas</option>
          <option value="cancelled">❌ Canceladas</option>
        </select>
      </div>

      <div v-if="loading" class="loading-container">
        <div class="spinner"></div>
        <p>Cargando solicitudes...</p>
      </div>

      <div v-else class="requests-grid">
        <div v-for="req in requests" :key="req.id" class="request-card">
          <div class="request-header">
            <span class="request-id">#{{ req.id }}</span>
            <span class="request-status" :class="req.status">{{ req.status }}</span>
          </div>

          <div class="user-info">
            <span class="user-name">{{ req.user_name }}</span>
            <span class="user-email">{{ req.email }}</span>
            <span class="user-phone">{{ req.phone }}</span>
          </div>

          <div class="amount-box">
            <span class="currency">€</span>
            <span class="amount">{{ req.amount?.toFixed(2) }}</span>
          </div>

          <div class="details">
            <div class="detail-row">
              <span>📅 Fecha:</span>
              <strong>{{ formatDate(req.created_at) }}</strong>
            </div>
            <div class="detail-row">
              <span>💳 Método:</span>
              <strong>{{ formatPaymentMethod(req.payment_method) }}</strong>
            </div>
            <div class="detail-row">
              <span>🔖 Referencia:</span>
              <strong>{{ req.reference }}</strong>
            </div>
            <div v-if="req.payment_proof" class="detail-row">
              <span>📎 Comprobante:</span>
              <a :href="req.payment_proof" target="_blank" class="proof-link">Ver archivo</a>
            </div>
          </div>

          <div v-if="req.status === 'pending'" class="actions">
            <button @click="openApproveModal(req)" class="btn-approve">
              ✅ Aprobar
            </button>
            <button @click="openRejectModal(req)" class="btn-reject">
              ❌ Rechazar
            </button>
          </div>
        </div>

        <div v-if="requests.length === 0" class="empty-state">
          <div class="empty-icon">📭</div>
          <h3>No hay solicitudes</h3>
          <p>No se encontraron solicitudes con el filtro seleccionado</p>
        </div>
      </div>
    </div>

    <!-- SECCIÓN MÉTODOS DE PAGO -->
    <div v-if="activeTab === 'methods'" class="methods-section">
      <div class="section-header">
        <h2>💳 Métodos de pago</h2>
        <button @click="openCreateMethodModal" class="btn-create">
          <span class="btn-icon">➕</span>
          Nuevo método
        </button>
      </div>

      <div v-if="methodsLoading" class="loading-container">
        <div class="spinner"></div>
        <p>Cargando métodos de pago...</p>
      </div>

      <div v-else class="methods-grid">
        <div v-for="method in paymentMethods" :key="method.id" class="method-card" :class="{ inactive: !method.is_active }">
          <div class="method-header">
            <span class="method-icon">{{ getMethodIcon(method.value) }}</span>
            <span class="method-label">{{ method.label }}</span>
            <span class="method-status" :class="{ active: method.is_active, inactive: !method.is_active }">
              {{ method.is_active ? 'Activo' : 'Inactivo' }}
            </span>
          </div>

          <div class="method-value">
            <code>{{ method.value }}</code>
          </div>

          <div v-if="method.title" class="method-title">
            <strong>Título:</strong> {{ method.title }}
          </div>

          <div v-if="method.fields && Object.keys(method.fields).length > 0" class="method-fields">
            <strong>Campos:</strong>
            <div v-for="(value, key) in method.fields" :key="key" class="field-row">
              <span class="field-key">{{ key }}:</span>
              <span class="field-value">{{ value }}</span>
            </div>
          </div>

          <div v-if="method.concept" class="method-concept">
            <strong>Concepto:</strong> {{ method.concept }}
          </div>

          <div class="method-actions">
            <button @click="openEditMethodModal(method)" class="btn-edit">
              ✏️ Editar
            </button>
            <button 
              @click="toggleMethodStatus(method)" 
              class="btn-toggle"
              :class="{ activate: !method.is_active, deactivate: method.is_active }"
            >
              {{ method.is_active ? '🔴 Desactivar' : '🟢 Activar' }}
            </button>
            <button @click="confirmDeleteMethod(method)" class="btn-delete">
              🗑️ Eliminar
            </button>
          </div>
        </div>

        <div v-if="paymentMethods.length === 0" class="empty-state">
          <div class="empty-icon">💳</div>
          <h3>No hay métodos de pago</h3>
          <p>Comienza creando un nuevo método de pago</p>
          <button @click="openCreateMethodModal" class="btn-create empty-btn">
            <span class="btn-icon">➕</span> Crear método
          </button>
        </div>
      </div>
    </div>

    <!-- Modal Aprobar Recarga -->
    <div v-if="showApproveModal" class="modal-overlay" @click.self="showApproveModal = false">
      <div class="modal" @click.stop>
        <div class="modal-header approve">
          <div class="modal-icon">✅</div>
          <h3>Aprobar recarga</h3>
          <button class="modal-close" @click="showApproveModal = false">✕</button>
        </div>
        <div class="modal-content">
          <p>¿Estás seguro de aprobar esta recarga?</p>
          <div class="confirm-box">
            <p><strong>Usuario:</strong> {{ selectedRequest?.user_name }}</p>
            <p><strong>Monto:</strong> €{{ selectedRequest?.amount?.toFixed(2) }}</p>
            <p><strong>Referencia:</strong> {{ selectedRequest?.reference }}</p>
          </div>
          <p class="warning">⚠️ El saldo del usuario se incrementará automáticamente</p>
        </div>
        <div class="modal-actions">
          <button @click="showApproveModal = false" class="btn-cancel">Cancelar</button>
          <button @click="approveRequest" class="btn-confirm approve" :disabled="approving">
            {{ approving ? 'Procesando...' : 'Confirmar aprobación' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Modal Rechazar Recarga -->
    <div v-if="showRejectModal" class="modal-overlay" @click.self="showRejectModal = false">
      <div class="modal" @click.stop>
        <div class="modal-header reject">
          <div class="modal-icon">❌</div>
          <h3>Rechazar recarga</h3>
          <button class="modal-close" @click="showRejectModal = false">✕</button>
        </div>
        <div class="modal-content">
          <p>Indica el motivo del rechazo:</p>
          <textarea
            v-model="rejectReason"
            class="form-input"
            rows="4"
            placeholder="Ej: Comprobante ilegible, referencia incorrecta, datos no coinciden, etc."
          ></textarea>
        </div>
        <div class="modal-actions">
          <button @click="showRejectModal = false" class="btn-cancel">Cancelar</button>
          <button @click="rejectRequest" class="btn-confirm reject" :disabled="rejecting">
            {{ rejecting ? 'Procesando...' : 'Rechazar solicitud' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Modal Crear/Editar Método de Pago -->
    <div v-if="showMethodModal" class="modal-overlay" @click.self="showMethodModal = false">
      <div class="modal modal-large" @click.stop>
        <div class="modal-header method">
          <div class="modal-icon">{{ editingMethod ? '✏️' : '➕' }}</div>
          <h3>{{ editingMethod ? 'Editar método de pago' : 'Nuevo método de pago' }}</h3>
          <button class="modal-close" @click="showMethodModal = false">✕</button>
        </div>
        <div class="modal-content">
          <form @submit.prevent="saveMethod" class="method-form">
            <div class="form-row">
              <div class="form-group half">
                <label>Valor (identificador) *</label>
                <input
                  type="text"
                  v-model="methodForm.value"
                  class="form-input"
                  :disabled="editingMethod"
                  placeholder="Ej: transferencia, pago_movil, paypal"
                  required
                />
                <small class="form-hint">Sin espacios, usar guión bajo</small>
              </div>
              <div class="form-group half">
                <label>Etiqueta (mostrar al usuario) *</label>
                <input
                  type="text"
                  v-model="methodForm.label"
                  class="form-input"
                  placeholder="Ej: 🏦 Transferencia bancaria"
                  required
                />
              </div>
            </div>

            <div class="form-group">
              <label>Título (para el modal)</label>
              <input
                type="text"
                v-model="methodForm.title"
                class="form-input"
                placeholder="Ej: 🏦 Datos para transferencia"
              />
            </div>

            <div class="form-group">
              <label>Concepto (para referencia)</label>
              <input
                type="text"
                v-model="methodForm.concept"
                class="form-input"
                placeholder="Ej: RECARGA"
              />
            </div>

            <div class="form-group">
              <label>Campos del formulario</label>
              <div class="fields-editor">
                <div v-for="(field, index) in methodFields" :key="index" class="field-editor-row">
                  <input
                    type="text"
                    v-model="field.key"
                    class="field-key-input"
                    placeholder="Nombre del campo"
                  />
                  <input
                    type="text"
                    v-model="field.value"
                    class="field-value-input"
                    placeholder="Valor"
                  />
                  <button @click="removeField(index)" type="button" class="btn-remove-field">✕</button>
                </div>
                <button @click="addField" type="button" class="btn-add-field">
                  + Agregar campo
                </button>
              </div>
            </div>

            <div class="form-group checkbox">
              <label class="checkbox-label">
                <input type="checkbox" v-model="methodForm.is_active" />
                <span>Activo (visible para usuarios)</span>
              </label>
            </div>
          </form>
        </div>
        <div class="modal-actions">
          <button @click="showMethodModal = false" class="btn-cancel" type="button">Cancelar</button>
          <button @click="saveMethod" class="btn-confirm method" :disabled="methodSubmitting">
            {{ methodSubmitting ? 'Guardando...' : (editingMethod ? 'Actualizar' : 'Crear método') }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch, reactive } from 'vue'
import api from '@/axios'
import Swal from 'sweetalert2'

// ========== ESTADO GENERAL ==========
const activeTab = ref('requests')

// ========== ESTADO SOLICITUDES ==========
const requests = ref([])
const stats = ref({})
const loading = ref(true)
const statusFilter = ref('pending')
const showApproveModal = ref(false)
const showRejectModal = ref(false)
const selectedRequest = ref(null)
const rejectReason = ref('')
const approving = ref(false)
const rejecting = ref(false)

// ========== ESTADO MÉTODOS DE PAGO ==========
const paymentMethods = ref([])
const methodsLoading = ref(false)
const showMethodModal = ref(false)
const editingMethod = ref(false)
const methodSubmitting = ref(false)
const methodForm = reactive({
  id: null,
  value: '',
  label: '',
  title: '',
  concept: '',
  fields: {},
  is_active: true
})
const methodFields = ref<Array<{key: string, value: string}>>([])

// ========== FUNCIONES SOLICITUDES ==========
const loadRequests = async () => {
  loading.value = true
  try {
    const [requestsRes, statsRes] = await Promise.all([
      api.get(`/admin/wallet/requests?status=${statusFilter.value}`),
      api.get('/admin/wallet/stats')
    ])
    requests.value = requestsRes.data
    stats.value = statsRes.data
  } catch (err) {
    console.error(err)
    Swal.fire('Error', 'No se pudieron cargar las solicitudes', 'error')
  } finally {
    loading.value = false
  }
}

const openApproveModal = (req) => {
  selectedRequest.value = req
  showApproveModal.value = true
}

const openRejectModal = (req) => {
  selectedRequest.value = req
  rejectReason.value = ''
  showRejectModal.value = true
}

const approveRequest = async () => {
  approving.value = true
  try {
    await api.put(`/admin/wallet/approve/${selectedRequest.value.id}`)
    showApproveModal.value = false
    await loadRequests()
    Swal.fire({
      icon: 'success',
      title: '✅ Aprobada',
      text: 'Recarga aprobada y saldo actualizado',
      timer: 2000,
      showConfirmButton: false
    })
  } catch (err) {
    Swal.fire('Error', 'No se pudo aprobar la recarga', 'error')
  } finally {
    approving.value = false
  }
}

const rejectRequest = async () => {
  if (!rejectReason.value.trim()) {
    Swal.fire('Error', 'Debes indicar el motivo del rechazo', 'warning')
    return
  }

  rejecting.value = true
  try {
    await api.put(`/admin/wallet/reject/${selectedRequest.value.id}`, {
      reason: rejectReason.value
    })
    showRejectModal.value = false
    await loadRequests()
    Swal.fire({
      icon: 'success',
      title: '❌ Rechazada',
      text: 'Recarga rechazada correctamente',
      timer: 2000,
      showConfirmButton: false
    })
  } catch (err) {
    Swal.fire('Error', 'No se pudo rechazar la recarga', 'error')
  } finally {
    rejecting.value = false
  }
}

// ========== FUNCIONES MÉTODOS DE PAGO ==========
const loadPaymentMethods = async () => {
  methodsLoading.value = true
  try {
    const { data } = await api.get('/admin/payment-methods')
    paymentMethods.value = data.data || []
  } catch (err) {
    console.error(err)
    Swal.fire('Error', 'No se pudieron cargar los métodos de pago', 'error')
  } finally {
    methodsLoading.value = false
  }
}

const getMethodIcon = (value: string) => {
  const icons = {
    transferencia: '🏦',
    pago_movil: '📱',
    paypal: '🌐',
    zelle: '💵',
    binance: '🪙',
    efectivo: '💵',
    card: '💳',
    bizum: '📱'
  }
  return icons[value] || '💳'
}

const resetMethodForm = () => {
  methodForm.id = null
  methodForm.value = ''
  methodForm.label = ''
  methodForm.title = ''
  methodForm.concept = ''
  methodForm.fields = {}
  methodForm.is_active = true
  methodFields.value = []
}

const openCreateMethodModal = () => {
  resetMethodForm()
  editingMethod.value = false
  showMethodModal.value = true
}

const openEditMethodModal = (method) => {
  editingMethod.value = true
  methodForm.id = method.id
  methodForm.value = method.value
  methodForm.label = method.label
  methodForm.title = method.title || ''
  methodForm.concept = method.concept || ''
  methodForm.fields = method.fields || {}
  methodForm.is_active = method.is_active == 1 || method.is_active === true
  
  // Convertir fields a array para el editor
  methodFields.value = []
  if (method.fields) {
    Object.entries(method.fields).forEach(([key, value]) => {
      methodFields.value.push({ key, value: String(value) })
    })
  }
  
  showMethodModal.value = true
}

const addField = () => {
  methodFields.value.push({ key: '', value: '' })
}

const removeField = (index: number) => {
  methodFields.value.splice(index, 1)
}

const saveMethod = async () => {
  // Validar campos requeridos
  if (!methodForm.value || !methodForm.label) {
    Swal.fire('Error', 'El valor y la etiqueta son requeridos', 'warning')
    return
  }

  // Construir objeto fields desde el array
  const fields = {}
  methodFields.value.forEach(field => {
    if (field.key.trim() && field.value.trim()) {
      fields[field.key.trim()] = field.value.trim()
    }
  })

  const methodData = {
    value: methodForm.value,
    label: methodForm.label,
    title: methodForm.title || null,
    concept: methodForm.concept || null,
    fields: fields,
    is_active: methodForm.is_active ? 1 : 0
  }

  methodSubmitting.value = true
  try {
    if (editingMethod.value) {
      await api.put(`/admin/payment-methods/${methodForm.id}`, methodData)
      Swal.fire('Éxito', 'Método de pago actualizado', 'success')
    } else {
      await api.post('/admin/payment-methods', methodData)
      Swal.fire('Éxito', 'Método de pago creado', 'success')
    }
    
    showMethodModal.value = false
    await loadPaymentMethods()
  } catch (err: any) {
    Swal.fire('Error', err.response?.data?.error || 'Error al guardar', 'error')
  } finally {
    methodSubmitting.value = false
  }
}

const toggleMethodStatus = async (method) => {
  const newStatus = !method.is_active
  const action = newStatus ? 'activar' : 'desactivar'
  
  const result = await Swal.fire({
    title: `¿${action} método?`,
    text: `¿Estás seguro de ${action} "${method.label}"?`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: newStatus ? '#00b894' : '#ff7675',
    confirmButtonText: `Sí, ${action}`,
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    try {
      await api.put(`/admin/payment-methods/${method.id}`, {
        is_active: newStatus ? 1 : 0
      })
      await loadPaymentMethods()
      Swal.fire('Éxito', `Método ${action}do correctamente`, 'success')
    } catch (err) {
      Swal.fire('Error', 'No se pudo cambiar el estado', 'error')
    }
  }
}

const confirmDeleteMethod = async (method) => {
  const result = await Swal.fire({
    title: '¿Eliminar método?',
    text: `¿Estás seguro de eliminar "${method.label}"? Esta acción no se puede deshacer.`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#ff7675',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    try {
      await api.delete(`/admin/payment-methods/${method.id}`)
      await loadPaymentMethods()
      Swal.fire('Eliminado', 'Método de pago eliminado', 'success')
    } catch (err) {
      Swal.fire('Error', 'No se pudo eliminar', 'error')
    }
  }
}

// ========== FUNCIONES AUXILIARES ==========
const formatDate = (date) => {
  return new Date(date).toLocaleDateString('es-ES', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const formatPaymentMethod = (method) => {
  const found = paymentMethods.value.find(m => m.value === method)
  return found?.label || method
}

// ========== WATCHERS ==========
watch(statusFilter, () => loadRequests())
watch(activeTab, (newTab) => {
  if (newTab === 'methods') {
    loadPaymentMethods()
  }
})

// ========== LIFECYCLE ==========
onMounted(() => {
  loadRequests()
})
</script>

<style scoped>
.admin-wallet {
  padding: 24px;
  max-width: 1400px;
  margin: 0 auto;
  background: linear-gradient(135deg, #f5f7fa 0%, #e4edf5 100%);
  min-height: 100vh;
}

/* Header */
.admin-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 32px;
  flex-wrap: wrap;
  gap: 20px;
}

.admin-header h1 {
  font-size: 2.2rem;
  color: #2d3436;
  font-weight: 700;
  display: flex;
  align-items: center;
  gap: 12px;
}

/* Stats Cards */
.stats-cards {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
  margin-bottom: 32px;
}

.stat-card {
  background: white;
  padding: 24px;
  border-radius: 20px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
  border: 1px solid #f1f2f6;
  transition: all 0.3s;
}

.stat-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
}

.stat-value {
  display: block;
  font-size: 2.2rem;
  font-weight: 700;
  color: #2d3436;
  margin-bottom: 8px;
}

.stat-label {
  color: #636e72;
  font-size: 0.9rem;
  text-transform: uppercase;
  letter-spacing: 1px;
}

/* Tabs */
.tabs {
  display: flex;
  gap: 16px;
  margin-bottom: 32px;
  border-bottom: 2px solid #e9ecef;
  padding-bottom: 16px;
}

.tab {
  padding: 12px 32px;
  border: none;
  border-radius: 12px;
  font-weight: 600;
  font-size: 1.1rem;
  cursor: pointer;
  transition: all 0.3s;
  background: transparent;
  color: #636e72;
}

.tab.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
}

/* Filters */
.filters {
  margin-bottom: 32px;
}

.filter-select {
  padding: 12px 24px;
  border: 2px solid #dfe6e9;
  border-radius: 12px;
  font-size: 1rem;
  min-width: 250px;
  background: white;
  cursor: pointer;
  transition: all 0.3s;
}

.filter-select:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

/* Loading */
.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 400px;
}

.spinner {
  width: 50px;
  height: 50px;
  border: 4px solid rgba(102, 126, 234, 0.2);
  border-top: 4px solid #667eea;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 20px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* Requests Grid */
.requests-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
  gap: 24px;
}

.request-card {
  background: white;
  border-radius: 20px;
  padding: 24px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
  border: 1px solid #f1f2f6;
  transition: all 0.3s;
}

.request-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
}

.request-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.request-id {
  background: #f8f9fa;
  padding: 6px 14px;
  border-radius: 50px;
  font-weight: 600;
  color: #2d3436;
  font-size: 0.85rem;
}

.request-status {
  padding: 6px 14px;
  border-radius: 50px;
  font-size: 0.8rem;
  font-weight: 600;
  text-transform: uppercase;
}

.request-status.pending {
  background: #fff3cd;
  color: #856404;
  border: 1px solid #ffeeba;
}

.request-status.completed {
  background: #d4edda;
  color: #155724;
  border: 1px solid #c3e6cb;
}

.request-status.cancelled {
  background: #f8d7da;
  color: #721c24;
  border: 1px solid #f5c6cb;
}

/* User Info */
.user-info {
  background: linear-gradient(135deg, #667eea0d 0%, #764ba20d 100%);
  padding: 16px;
  border-radius: 16px;
  margin-bottom: 20px;
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.user-name {
  font-weight: 700;
  color: #2d3436;
  font-size: 1.1rem;
}

.user-email,
.user-phone {
  color: #636e72;
  font-size: 0.9rem;
}

/* Amount Box */
.amount-box {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 16px;
  border-radius: 16px;
  margin-bottom: 20px;
  display: inline-flex;
  align-items: baseline;
  gap: 4px;
}

.amount-box .currency {
  color: rgba(255, 255, 255, 0.9);
  font-size: 1.2rem;
}

.amount-box .amount {
  color: white;
  font-size: 2rem;
  font-weight: 700;
}

/* Details */
.details {
  background: #f8f9fa;
  padding: 16px;
  border-radius: 16px;
  margin-bottom: 20px;
}

.detail-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
  border-bottom: 1px solid #e9ecef;
}

.detail-row:last-child {
  border-bottom: none;
}

.detail-row span {
  color: #636e72;
  font-size: 0.9rem;
}

.detail-row strong {
  color: #2d3436;
  font-weight: 600;
}

.proof-link {
  color: #667eea;
  text-decoration: none;
  font-weight: 600;
  padding: 4px 12px;
  background: white;
  border-radius: 50px;
  transition: all 0.3s;
}

.proof-link:hover {
  background: #667eea;
  color: white;
}

/* Actions */
.actions {
  display: flex;
  gap: 12px;
}

.btn-approve {
  flex: 1;
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
  color: white;
  border: none;
  padding: 12px;
  border-radius: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-approve:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 16px rgba(0, 184, 148, 0.3);
}

.btn-reject {
  flex: 1;
  background: linear-gradient(135deg, #ff7675 0%, #d63031 100%);
  color: white;
  border: none;
  padding: 12px;
  border-radius: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-reject:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 16px rgba(255, 118, 117, 0.3);
}

/* Section Header */
.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 32px;
}

.section-header h2 {
  font-size: 1.8rem;
  color: #2d3436;
  font-weight: 700;
}

.btn-create {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
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

.btn-create:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 16px rgba(0, 184, 148, 0.3);
}

/* Methods Grid */
.methods-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
  gap: 24px;
}

.method-card {
  background: white;
  border-radius: 20px;
  padding: 24px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
  border: 2px solid #00b894;
  transition: all 0.3s;
}

.method-card.inactive {
  border-color: #ff7675;
  opacity: 0.7;
}

.method-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
}

.method-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
}

.method-icon {
  font-size: 2rem;
}

.method-label {
  font-size: 1.2rem;
  font-weight: 600;
  color: #2d3436;
  flex: 1;
}

.method-status {
  padding: 4px 12px;
  border-radius: 50px;
  font-size: 0.8rem;
  font-weight: 600;
}

.method-status.active {
  background: #d4edda;
  color: #155724;
}

.method-status.inactive {
  background: #f8d7da;
  color: #721c24;
}

.method-value {
  background: #f8f9fa;
  padding: 8px;
  border-radius: 8px;
  margin-bottom: 12px;
  font-family: monospace;
}

.method-title,
.method-concept {
  margin: 8px 0;
  color: #2d3436;
}

.method-fields {
  background: #f8f9fa;
  padding: 12px;
  border-radius: 12px;
  margin: 12px 0;
}

.field-row {
  display: flex;
  justify-content: space-between;
  padding: 4px 0;
  border-bottom: 1px dashed #dfe6e9;
}

.field-key {
  font-weight: 600;
  color: #2d3436;
}

.field-value {
  color: #636e72;
}

.method-actions {
  display: flex;
  gap: 8px;
  margin-top: 16px;
}

.btn-edit {
  flex: 1;
  background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%);
  color: white;
  border: none;
  padding: 10px;
  border-radius: 10px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-edit:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(9, 132, 227, 0.3);
}

.btn-toggle {
  flex: 1;
  border: none;
  padding: 10px;
  border-radius: 10px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-toggle.activate {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
  color: white;
}

.btn-toggle.deactivate {
  background: linear-gradient(135deg, #ff7675 0%, #d63031 100%);
  color: white;
}

.btn-toggle:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
}

.btn-delete {
  flex: 1;
  background: linear-gradient(135deg, #636e72 0%, #2d3436 100%);
  color: white;
  border: none;
  padding: 10px;
  border-radius: 10px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-delete:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(45, 52, 54, 0.3);
}

/* Empty State */
.empty-state {
  grid-column: 1 / -1;
  text-align: center;
  padding: 60px 20px;
  background: white;
  border-radius: 30px;
}

.empty-icon {
  font-size: 64px;
  margin-bottom: 24px;
  animation: bounce 2s infinite;
}

@keyframes bounce {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-20px); }
}

.empty-state h3 {
  color: #2d3436;
  margin-bottom: 12px;
  font-size: 1.8rem;
}

.empty-state p {
  color: #636e72;
  margin-bottom: 24px;
  font-size: 1.1rem;
}

.empty-btn {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 12px 32px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.empty-btn:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 16px rgba(102, 126, 234, 0.3);
}

/* Modal */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  backdrop-filter: blur(4px);
}

.modal {
  background: white;
  border-radius: 30px;
  max-width: 500px;
  width: 90%;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  overflow: hidden;
}

.modal-large {
  max-width: 700px !important;
}

.modal-header {
  padding: 24px;
  display: flex;
  align-items: center;
  gap: 16px;
  color: white;
}

.modal-header.approve {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
}

.modal-header.reject {
  background: linear-gradient(135deg, #ff7675 0%, #d63031 100%);
}

.modal-header.method {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.modal-icon {
  width: 48px;
  height: 48px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
}

.modal-header h3 {
  flex: 1;
  font-size: 1.3rem;
  color: white;
  margin: 0;
}

.modal-close {
  background: rgba(255, 255, 255, 0.2);
  border: none;
  color: white;
  font-size: 20px;
  cursor: pointer;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background 0.3s;
}

.modal-close:hover {
  background: rgba(255, 255, 255, 0.3);
}

.modal-content {
  padding: 32px;
  max-height: 70vh;
  overflow-y: auto;
}

/* Form */
.method-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.form-row {
  display: flex;
  gap: 20px;
}

.form-group {
  flex: 1;
}

.form-group.half {
  flex: 1;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  font-weight: 600;
  color: #2d3436;
}

.form-input {
  width: 100%;
  padding: 12px 16px;
  border: 2px solid #dfe6e9;
  border-radius: 12px;
  font-size: 1rem;
  transition: all 0.3s;
}

.form-input:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.form-input:disabled {
  background: #f8f9fa;
  cursor: not-allowed;
}

.form-hint {
  display: block;
  margin-top: 4px;
  color: #636e72;
  font-size: 0.8rem;
}

.checkbox {
  display: flex;
  align-items: center;
}

.checkbox-label {
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
}

.checkbox-label input[type="checkbox"] {
  width: 20px;
  height: 20px;
  cursor: pointer;
}

/* Fields Editor */
.fields-editor {
  border: 2px solid #dfe6e9;
  border-radius: 16px;
  padding: 20px;
  background: #f8f9fa;
}

.field-editor-row {
  display: flex;
  gap: 12px;
  margin-bottom: 12px;
}

.field-key-input,
.field-value-input {
  flex: 1;
  padding: 10px;
  border: 2px solid #dfe6e9;
  border-radius: 8px;
  font-size: 0.9rem;
}

.field-key-input:focus,
.field-value-input:focus {
  outline: none;
  border-color: #667eea;
}

.btn-remove-field {
  background: #ff7675;
  color: white;
  border: none;
  width: 36px;
  height: 36px;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-remove-field:hover {
  background: #d63031;
  transform: scale(1.05);
}

.btn-add-field {
  width: 100%;
  padding: 12px;
  background: #dfe6e9;
  border: 2px dashed #b2bec3;
  border-radius: 8px;
  color: #2d3436;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-add-field:hover {
  background: #b2bec3;
  border-color: #636e72;
}

/* Confirm Box */
.confirm-box {
  background: #f8f9fa;
  padding: 20px;
  border-radius: 16px;
  margin: 20px 0;
}

.confirm-box p {
  margin: 8px 0;
  color: #2d3436;
}

.warning {
  color: #ff7675;
  font-size: 0.9rem;
  display: flex;
  align-items: center;
  gap: 8px;
  background: #fff5f5;
  padding: 12px;
  border-radius: 12px;
}

/* Modal Actions */
.modal-actions {
  padding: 24px;
  border-top: 2px solid #f1f2f6;
  display: flex;
  gap: 16px;
  justify-content: flex-end;
}

.btn-cancel {
  padding: 12px 24px;
  border: 2px solid #dfe6e9;
  border-radius: 12px;
  background: white;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-cancel:hover {
  background: #dfe6e9;
}

.btn-confirm {
  padding: 12px 32px;
  border: none;
  border-radius: 12px;
  font-weight: 600;
  color: white;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-confirm.approve {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
}

.btn-confirm.reject {
  background: linear-gradient(135deg, #ff7675 0%, #d63031 100%);
}

.btn-confirm.method {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.btn-confirm:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
}

.btn-confirm:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Responsive */
@media (max-width: 1024px) {
  .stats-cards {
    grid-template-columns: repeat(3, 1fr);
  }

  .requests-grid,
  .methods-grid {
    grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  }
}

@media (max-width: 768px) {
  .admin-wallet {
    padding: 16px;
  }

  .admin-header {
    flex-direction: column;
    align-items: flex-start;
  }

  .admin-header h1 {
    font-size: 1.8rem;
  }

  .stats-cards {
    grid-template-columns: 1fr;
  }

  .tabs {
    flex-direction: column;
  }

  .tab {
    width: 100%;
  }

  .section-header {
    flex-direction: column;
    gap: 16px;
    align-items: flex-start;
  }

  .btn-create {
    width: 100%;
    justify-content: center;
  }

  .requests-grid,
  .methods-grid {
    grid-template-columns: 1fr;
  }

  .filter-select {
    width: 100%;
  }

  .form-row {
    flex-direction: column;
  }

  .modal {
    width: 95%;
    margin: 16px;
  }

  .modal-actions {
    flex-direction: column;
  }

  .btn-cancel,
  .btn-confirm {
    width: 100%;
  }
}

@media (max-width: 480px) {
  .actions,
  .method-actions {
    flex-direction: column;
  }

  .btn-approve,
  .btn-reject,
  .btn-edit,
  .btn-toggle,
  .btn-delete {
    width: 100%;
  }

  .amount-box {
    width: 100%;
    justify-content: center;
  }

  .method-header {
    flex-wrap: wrap;
  }

  .field-editor-row {
    flex-direction: column;
  }

  .btn-remove-field {
    width: 100%;
  }
}
</style>
