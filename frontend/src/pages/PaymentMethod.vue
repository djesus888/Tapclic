<script setup lang="ts">
import { ref, reactive, computed, onMounted, h } from 'vue'
import api from '@/axios'
import { useAuthStore } from '@/stores/authStore'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
const authStore = useAuthStore()

/* ---------- tipos ---------- */
type MethodType = 'pago_movil' | 'transferencia' | 'zelle' | 'paypal' | 'binance'

interface PaymentMethod {
  id?: number
  method_type: MethodType
  bank_name?: string
  holder_name: string
  id_number: string
  phone_number?: string
  account_number?: string
  email?: string
  qr_url?: string
  is_active: boolean
}

/* ---------- estado ---------- */
const methods   = ref<PaymentMethod[]>([])
const loading   = ref(false)
const editingId = ref<number | null>(null)

const form = reactive<PaymentMethod>({
  method_type: 'pago_movil',
  holder_name: '',
  id_number: '',
  phone_number: '',
  bank_name: '',
  account_number: '',
  email: '',
  qr_url: '',
  is_active: true
})

/* ---------- validaciones ---------- */
const isFormValid = computed(() => {
  const f = form
  return !!f.holder_name.trim() && !!f.id_number.trim()
})

/* ---------- iconos (componentes funcionales) ---------- */
const PhoneIcon = () => h('svg', { class: 'w-4 h-4', fill: 'none', stroke: 'currentColor', viewBox: '0 0 24 24' },
  h('path', { 'stroke-linecap': 'round', 'stroke-linejoin': 'round', 'stroke-width': '2', d: 'M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z' }))
const BankIcon  = () => h('svg', { class: 'w-4 h-4', fill: 'none', stroke: 'currentColor', viewBox: '0 0 24 24' },
  h('path', { 'stroke-linecap': 'round', 'stroke-linejoin': 'round', 'stroke-width': '2', d: 'M3 6l3 1m0 0l-3 9a5.002 5.002 0 006.001 0M6 7l3 9M6 7l6-2m6 2l3-1m-3 1l-3 9a5.002 5.002 0 006.001 0M18 7l3 9m-3-9l-6-2m0-2v2m0 16V5m0 16H9m3 0h3' }))
const HashIcon  = () => h('svg', { class: 'w-4 h-4', fill: 'none', stroke: 'currentColor', viewBox: '0 0 24 24' },
  h('path', { 'stroke-linecap': 'round', 'stroke-linejoin': 'round', 'stroke-width': '2', d: 'M7 20l4-16m2 16l4-16M6 9h14M4 15h14' }))
const MailIcon  = () => h('svg', { class: 'w-4 h-4', fill: 'none', stroke: 'currentColor', viewBox: '0 0 24 24' },
  h('path', { 'stroke-linecap': 'round', 'stroke-linejoin': 'round', 'stroke-width': '2', d: 'M3 8l7.89 4.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z' }))

/* ---------- funciones helper ---------- */
const getMethodTypeClass = (type: MethodType) => {
  const classes: Record<MethodType, string> = {
    'pago_movil': 'bg-blue-gradient',
    'transferencia': 'bg-green-gradient',
    'zelle': 'bg-purple-gradient',
    'paypal': 'bg-yellow-gradient',
    'binance': 'bg-orange-gradient'
  }
  return classes[type] || 'bg-blue-gradient'
}

const getMethodTypeIcon = (type: MethodType) => {
  const icons: Record<MethodType, string> = {
    'pago_movil': '📱',
    'transferencia': '🏦',
    'zelle': '💸',
    'paypal': '🔵',
    'binance': '🟡'
  }
  return icons[type] || '💳'
}

/* ---------- CRUD ---------- */
async function fetchMethods() {
  try {
    const { data } = await api.get('/provider/payment-methods', {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    methods.value = (data.methods || []).filter((m: any) => m?.method_type)
  } catch {
    methods.value = []
  }
}

async function saveMethod() {
  if (!isFormValid.value) return
  loading.value = true
  try {
    const payload = { ...form }
    if (editingId.value) {
      await api.put(`/provider/payment-methods/${editingId.value}`, payload, {
        headers: { Authorization: `Bearer ${authStore.token}` }
      })
    } else {
      await api.post('/provider/payment-methods', payload, {
        headers: { Authorization: `Bearer ${authStore.token}` }
      })
    }
    resetForm()
    await fetchMethods()
  } catch (e: any) {
    alert(e?.response?.data?.error || t('errors.save'))
  } finally {
    loading.value = false
  }
}

async function deleteMethod(id: number) {
  if (!confirm(t('confirm.delete'))) return
  try {
    await api.delete(`/provider/payment-methods/${id}`, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    await fetchMethods()
  } catch {
    alert(t('errors.delete'))
  }
}

async function toggleStatus(m: PaymentMethod) {
  try {
    await api.put(`/provider/payment-methods/${m.id}`, { ...m, is_active: !m.is_active }, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    await fetchMethods()
  } catch {
    alert(t('errors.toggle'))
  }
}

function editMethod(m: PaymentMethod) {
  if (!m || !m.id || !m.method_type) return
  Object.assign(form, { ...m })
  editingId.value = m.id
}

function resetForm() {
  Object.assign(form, {
    method_type: 'pago_movil',
    holder_name: '',
    id_number: '',
    phone_number: '',
    bank_name: '',
    account_number: '',
    email: '',
    qr_url: '',
    is_active: true
  })
  editingId.value = null
}

onMounted(fetchMethods)
</script>

<template>
  <div class="payment-methods-page">
    <!-- Header -->
    <div class="header">
      <div class="title-section">
        <h1><span class="header-icon">💳</span> {{ $t('paymentMethods.title') }}</h1>
        <p>Gestiona tus métodos de pago para recibir pagos de clientes</p>
      </div>
      
      <div class="actions" v-if="methods.length > 0">
        <div class="summary-badge">
          <span class="badge-icon">📊</span>
          <span>{{ methods.length }} métodos</span>
        </div>
      </div>
    </div>

    <!-- Formulario -->
    <form @submit.prevent="saveMethod" class="form-section">
      <div class="form-card">
        <div class="form-header">
          <h2>{{ editingId ? $t('actions.update') : $t('actions.add') }} Método de Pago</h2>
          <div class="form-badge">
            {{ editingId ? '✏️ Editando' : '➕ Nuevo' }}
          </div>
        </div>
        
        <div class="form-grid">
          <div class="form-group">
            <label class="form-label">{{ $t('paymentMethods.type') }}</label>
            <select v-model="form.method_type" class="form-select">
              <option value="pago_movil">{{ $t('methods.pagoMovil') }}</option>
              <option value="transferencia">{{ $t('methods.transferencia') }}</option>
              <option value="zelle">Zelle</option>
              <option value="paypal">PayPal</option>
              <option value="binance">Binance</option>
            </select>
          </div>

          <div class="form-group">
            <label class="form-label">{{ $t('paymentMethods.holder') }}</label>
            <input v-model="form.holder_name" maxlength="100" required class="form-input" />
          </div>

          <div class="form-group">
            <label class="form-label">{{ $t('paymentMethods.idNumber') }}</label>
            <input v-model="form.id_number" maxlength="20" required class="form-input" />
          </div>

          <div v-if="form.method_type === 'pago_movil'" class="form-group">
            <label class="form-label">{{ $t('paymentMethods.phone') }}</label>
            <input v-model="form.phone_number" maxlength="20" class="form-input" />
          </div>

          <div v-if="['pago_movil','transferencia'].includes(form.method_type)" class="form-group">
            <label class="form-label">{{ $t('paymentMethods.bank') }}</label>
            <input v-model="form.bank_name" maxlength="50" class="form-input" />
          </div>

          <div v-if="form.method_type === 'transferencia'" class="form-group">
            <label class="form-label">{{ $t('paymentMethods.account') }}</label>
            <input v-model="form.account_number" maxlength="20" class="form-input" />
          </div>

          <div v-if="['zelle','paypal','binance'].includes(form.method_type)" class="form-group">
            <label class="form-label">Email</label>
            <input v-model="form.email" type="email" maxlength="100" class="form-input" />
          </div>

          <div class="form-group">
            <label class="toggle-label">
              <div class="toggle-wrapper">
                <input v-model="form.is_active" type="checkbox" class="toggle-input" />
                <div class="toggle-slider"></div>
              </div>
              <span class="toggle-text">{{ $t('paymentMethods.active') }}</span>
            </label>
          </div>
        </div>

        <div class="form-actions">
          <button 
            type="submit" 
            :disabled="!isFormValid || loading" 
            class="btn-primary"
          >
            <span v-if="loading" class="spinner-small"></span>
            <span v-else>{{ editingId ? $t('actions.update') : $t('actions.add') }}</span>
          </button>
          <button 
            type="button" 
            @click="resetForm" 
            class="btn-secondary"
          >
            {{ $t('actions.cancel') }}
          </button>
        </div>
      </div>
    </form>

    <!-- Lista de Métodos -->
    <div v-if="loading && methods.length === 0" class="loading-container">
      <div class="spinner"></div>
      <p>Cargando métodos de pago...</p>
    </div>

    <div v-else>
      <!-- Empty State -->
      <div v-if="!methods.length" class="empty-state">
        <div class="empty-icon">💳</div>
        <h2>No tienes métodos de pago registrados</h2>
        <p>Agrega tus métodos de pago para poder recibir pagos de tus clientes</p>
      </div>

      <!-- Métodos Grid -->
      <div v-else class="methods-grid">
        <div 
          v-for="m in methods" 
          :key="m.id" 
          class="method-card"
          :class="{ 'inactive': !m.is_active }"
        >
          <!-- Card Badge -->
          <div class="card-badge" :class="getMethodTypeClass(m.method_type)">
            {{ getMethodTypeIcon(m.method_type) }} {{ $t('methods.' + m.method_type) }}
          </div>
          
          <!-- Card Content -->
          <div class="card-content">
            <!-- Header con toggle -->
            <div class="card-header">
              <div class="card-title">
                <h3>{{ m.holder_name }}</h3>
                <p class="card-subtitle">{{ $t('paymentMethods.id') }}: {{ m.id_number }}</p>
              </div>
              
              <div class="card-status">
                <label class="status-toggle">
                  <input 
                    type="checkbox" 
                    :checked="m.is_active" 
                    @change="toggleStatus(m)" 
                    class="status-input"
                  />
                  <div class="status-slider"></div>
                </label>
                <span class="status-text">{{ m.is_active ? 'Activo' : 'Inactivo' }}</span>
              </div>
            </div>
            
            <!-- Detalles del método -->
            <div class="method-details">
              <div v-if="m.phone_number" class="detail-item">
                <PhoneIcon />
                <span>{{ m.phone_number }}</span>
              </div>
              
              <div v-if="m.bank_name" class="detail-item">
                <BankIcon />
                <span>{{ m.bank_name }}</span>
              </div>
              
              <div v-if="m.account_number" class="detail-item">
                <HashIcon />
                <span>{{ m.account_number }}</span>
              </div>
              
              <div v-if="m.email" class="detail-item">
                <MailIcon />
                <span>{{ m.email }}</span>
              </div>
            </div>
            
            <!-- Footer con acciones -->
            <div class="card-footer">
              <button 
                @click="editMethod(m)" 
                class="card-action edit"
              >
                ✏️ {{ $t('actions.edit') }}
              </button>
              <button 
                @click="deleteMethod(m.id!)" 
                class="card-action delete"
              >
                🗑️ {{ $t('actions.delete') }}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Toast Notification -->
    <div v-if="false" class="toast success">
      Método actualizado correctamente
    </div>
  </div>
</template>

<style scoped>
/* Estructura principal */
.payment-methods-page {
  max-width: 1400px;
  margin: 0 auto;
  padding: 24px;
  min-height: 100vh;
  background: linear-gradient(135deg, #f5f7fa 0%, #e4edf5 100%);
}

/* Header */
.header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 40px;
  flex-wrap: wrap;
  gap: 20px;
}

.title-section h1 {
  font-size: 2.5rem;
  color: #2d3436;
  margin-bottom: 8px;
  display: flex;
  align-items: center;
  gap: 10px;
}

.header-icon {
  font-size: 2.2rem;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.1); }
}

.title-section p {
  color: #636e72;
  font-size: 1.1rem;
}

.summary-badge {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 10px 20px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 600;
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
}

.badge-icon {
  font-size: 1.2rem;
}

/* Form Section */
.form-section {
  margin-bottom: 40px;
}

.form-card {
  background: white;
  border-radius: 20px;
  padding: 32px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
  border: 1px solid #f1f2f6;
}

.form-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.form-header h2 {
  font-size: 1.5rem;
  color: #2d3436;
}

.form-badge {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: white;
  padding: 6px 16px;
  border-radius: 20px;
  font-size: 0.9rem;
  font-weight: 600;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 20px;
  margin-bottom: 24px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-label {
  font-weight: 600;
  color: #2d3436;
  font-size: 0.9rem;
}

.form-input, .form-select {
  padding: 12px;
  border: 2px solid #dfe6e9;
  border-radius: 10px;
  font-size: 1rem;
  transition: all 0.3s;
  background: white;
}

.form-input:focus, .form-select:focus {
  outline: none;
  border-color: #3498db;
  box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
}

.toggle-label {
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
  margin-top: 8px;
}

.toggle-wrapper {
  position: relative;
  display: inline-block;
  width: 48px;
  height: 24px;
}

.toggle-input {
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
  background-color: #dfe6e9;
  border-radius: 34px;
  transition: .4s;
}

.toggle-slider:before {
  position: absolute;
  content: "";
  height: 16px;
  width: 16px;
  left: 4px;
  bottom: 4px;
  background-color: white;
  border-radius: 50%;
  transition: .4s;
}

.toggle-input:checked + .toggle-slider {
  background-color: #00b894;
}

.toggle-input:checked + .toggle-slider:before {
  transform: translateX(24px);
}

.toggle-text {
  font-weight: 600;
  color: #2d3436;
}

.form-actions {
  display: flex;
  gap: 12px;
  align-items: center;
}

.btn-primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 12px 32px;
  border-radius: 10px;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s;
}

.btn-primary:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
}

.btn-primary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-secondary {
  background: white;
  color: #636e72;
  border: 2px solid #dfe6e9;
  padding: 12px 32px;
  border-radius: 10px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-secondary:hover {
  border-color: #3498db;
  color: #3498db;
}

.spinner-small {
  width: 16px;
  height: 16px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top: 2px solid white;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

/* Loading State */
.loading-container {
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

/* Empty State */
.empty-state {
  text-align: center;
  padding: 80px 20px;
  background: white;
  border-radius: 20px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
  margin: 40px 0;
}

.empty-icon {
  font-size: 80px;
  margin-bottom: 24px;
  animation: bounce 2s infinite;
}

@keyframes bounce {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-20px); }
}

.empty-state h2 {
  color: #2d3436;
  margin-bottom: 12px;
  font-size: 2rem;
}

.empty-state p {
  color: #636e72;
  font-size: 1.2rem;
  margin-bottom: 32px;
  max-width: 500px;
  margin-left: auto;
  margin-right: auto;
}

/* Methods Grid */
.methods-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 32px;
  margin-bottom: 40px;
}

.method-card {
  background: white;
  border-radius: 20px;
  overflow: hidden;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
  transition: all 0.4s;
  position: relative;
  border: 1px solid #f1f2f6;
}

.method-card:hover {
  transform: translateY(-10px);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
}

.method-card.inactive {
  opacity: 0.7;
}

.method-card.inactive .card-badge {
  background: linear-gradient(135deg, #95a5a6 0%, #7f8c8d 100%);
}

/* Card Badge */
.card-badge {
  position: absolute;
  top: 16px;
  left: 16px;
  color: white;
  padding: 6px 16px;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
  z-index: 2;
}

/* Card Content */
.card-content {
  padding: 24px;
  padding-top: 48px;
}

/* Card Header */
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 16px;
}

.card-title h3 {
  font-size: 1.4rem;
  color: #2d3436;
  margin-bottom: 4px;
}

.card-subtitle {
  color: #636e72;
  font-size: 0.9rem;
}

.card-status {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 4px;
}

.status-toggle {
  position: relative;
  display: inline-block;
  width: 40px;
  height: 20px;
}

.status-input {
  opacity: 0;
  width: 0;
  height: 0;
}

.status-slider {
  position: absolute;
  cursor: pointer;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: #ff7675;
  border-radius: 34px;
  transition: .4s;
}

.status-slider:before {
  position: absolute;
  content: "";
  height: 14px;
  width: 14px;
  left: 3px;
  bottom: 3px;
  background-color: white;
  border-radius: 50%;
  transition: .4s;
}

.status-input:checked + .status-slider {
  background-color: #00b894;
}

.status-input:checked + .status-slider:before {
  transform: translateX(20px);
}

.status-text {
  font-size: 0.8rem;
  color: #636e72;
  font-weight: 600;
}

/* Method Details */
.method-details {
  margin: 20px 0;
  padding: 16px;
  background: #f8f9fa;
  border-radius: 12px;
}

.detail-item {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 8px;
  font-size: 0.9rem;
  color: #2d3436;
}

.detail-item:last-child {
  margin-bottom: 0;
}

.detail-item svg {
  color: #636e72;
  flex-shrink: 0;
}

/* Card Footer */
.card-footer {
  display: flex;
  gap: 12px;
  padding-top: 16px;
  border-top: 1px solid #eee;
}

.card-action {
  flex: 1;
  padding: 10px 16px;
  border-radius: 8px;
  border: none;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  transition: all 0.3s;
}

.card-action.edit {
  background: #3498db;
  color: white;
}

.card-action.edit:hover {
  background: #2980b9;
  transform: translateY(-2px);
}

.card-action.delete {
  background: #ff7675;
  color: white;
}

.card-action.delete:hover {
  background: #d63031;
  transform: translateY(-2px);
}

/* Toast */
.toast {
  position: fixed;
  bottom: 24px;
  right: 24px;
  padding: 16px 24px;
  border-radius: 10px;
  color: white;
  font-weight: 600;
  z-index: 1001;
  animation: slideIn 0.3s ease-out;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
}

.toast.success {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
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
  .methods-grid {
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  }
}

@media (max-width: 768px) {
  .payment-methods-page {
    padding: 16px;
  }
  
  .header {
    flex-direction: column;
    align-items: stretch;
  }
  
  .title-section h1 {
    font-size: 2rem;
  }
  
  .form-grid {
    grid-template-columns: 1fr;
  }
  
  .methods-grid {
    grid-template-columns: 1fr;
    gap: 24px;
  }
  
  .form-card {
    padding: 24px;
  }
  
  .card-header {
    flex-direction: column;
    gap: 12px;
  }
  
  .card-status {
    align-items: flex-start;
  }
  
  .card-footer {
    flex-direction: column;
  }
}

@media (max-width: 480px) {
  .title-section h1 {
    font-size: 1.8rem;
  }
  
  .form-actions {
    flex-direction: column;
    align-items: stretch;
  }
  
  .btn-primary, .btn-secondary {
    width: 100%;
  }
}
</style>

<style>
/* Gradientes para los badges */
.bg-blue-gradient {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.bg-green-gradient {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
}

.bg-purple-gradient {
  background: linear-gradient(135deg, #a29bfe 0%, #6c5ce7 100%);
}

.bg-yellow-gradient {
  background: linear-gradient(135deg, #fdcb6e 0%, #e17055 100%);
}

.bg-orange-gradient {
  background: linear-gradient(135deg, #e17055 0%, #d63031 100%);
}
</style>
