<template>
  <div class="solicitudes-activas-page">
    <div class="page-header">
      <h1><span class="header-icon">📋</span> Solicitudes Activas</h1>
      <p>Solicitudes en curso de tus servicios publicados</p>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="loading-container">
      <div class="spinner"></div>
      <p>Cargando solicitudes...</p>
    </div>

    <!-- Empty State -->
    <div v-else-if="!requests.length" class="empty-state">
      <div class="empty-icon">📭</div>
      <h3>No hay solicitudes activas</h3>
      <p>Las solicitudes que recibas aparecerán aquí</p>
    </div>


    <!-- Solicitudes Grid -->
    <div v-else class="requests-grid">
      <div 
        v-for="req in requests" 
        :key="`${req.id}-${$i18n.locale}`" 
        class="request-card"
        :class="getStatusClass(req.status)"
      >
        <!-- Card Header -->
        <div class="card-header">
          <div class="service-info">
            <h3 class="service-title">{{ sanitize(req.service_title) }}</h3>
            <div class="status-badge">
              <span class="status-emoji">{{ emoji(req.status) }}</span>
              <span class="status-text">{{ statusLabel(req.status) }}</span>
            </div>
          </div>
          <PaymentPill :status="req.payment_status" />
        </div>

        <!-- Service Description -->
        <div class="card-content">
          <p class="service-description">{{ sanitize(req.service_description) }}</p>
          
          <!-- Client Info -->
          <div class="client-info">
            <div class="client-avatar">👤</div>
            <div class="client-details">
              <p class="client-name">{{ sanitize(req.user_name || $t('user')) }}</p>
              <p class="elapsed-time">
                <span class="time-icon">⏱️</span>
                {{ elapsed(req.updated_at) }}
              </p>
            </div>
          </div>

          <!-- Cancellation Info -->
          <div v-if="req.status === 'cancelled' && req.cancelled_by" class="cancelled-info">
            <span class="warning-icon">⚠️</span>
            <span class="cancelled-text">
              {{ $t('cancelled_by') }}: {{ req.cancelled_by }}
            </span>
          </div>

          <!-- Payment Proof Button -->
          <div v-if="req.payment_status === 'verifying'" class="proof-section">
            <button 
              class="btn-proof"
              @click="$emit('open-proof', req.id)"
            >
              <span class="proof-icon">👁️</span>
              {{ $t('see_proof') }}
            </button>
          </div>

          <!-- Timeline Accordion -->
          <div class="timeline-section">
            <div class="timeline-header" @click="toggleTimeline(req.id)">
              <span class="timeline-icon">📅</span>
              <span class="timeline-title">{{ $t('timeline') }}</span>
              <span class="timeline-arrow" :class="{ 'open': openTimeline === req.id }">▼</span>
            </div>
            <div v-if="openTimeline === req.id" class="timeline-content">
              <div 
                v-for="(l,i) in timeline(req)" 
                :key="i" 
                class="timeline-item"
              >
                <div class="timeline-dot"></div>
                <div class="timeline-status">
                  <span class="status-label">{{ $t(l.status) }}</span>
                  <span class="status-time">{{ formatDate(l.updated_at, 'time') }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Actions Footer -->
        <div class="card-footer">
          <!-- Status Dropdown -->
          <div class="status-dropdown">
            <button 
              class="dropdown-toggle"
              @click="toggleDropdown(req.id)"
            >
              <span class="dropdown-icon">⚙️</span>
              {{ $t('status') }}
              <span class="dropdown-arrow" :class="{ 'open': openDropdown === req.id }">▼</span>
            </button>
            
            <div v-if="openDropdown === req.id" class="dropdown-menu">
              <button 
                v-for="st in allowedNext(req.status)" 
                :key="st" 
                class="dropdown-item"
                @click="$emit('set-status', req.id, st)"
              >
                <span class="item-emoji">{{ emoji(st) }}</span>
                <span class="item-text">{{ $t('status.'+st) }}</span>
              </button>
            </div>
          </div>

          <!-- Action Buttons -->
          <div class="action-buttons">
            <button 
              class="btn-chat"
              @click="$emit('open-chat', req.user_id, 'user')"
            >
              <span class="chat-icon">💬</span>
              <span class="chat-text">Chat</span>
            </button>
          </div>
        </div>

        <!-- Update Time -->
        <div class="card-update">
          <span class="update-icon">🔄</span>
          <span class="update-text">Actualizado: {{ formatDate(req.updated_at) }}</span>
        </div>
      </div>
    </div>

    <!-- Stats Summary -->
    <div v-if="requests.length > 0" class="stats-summary">
      <div class="stat-item">
        <div class="stat-icon">📋</div>
        <div class="stat-content">
          <h3>{{ requests.length }}</h3>
          <p>Solicitudes totales</p>
        </div>
      </div>
      <div class="stat-item">
        <div class="stat-icon">💰</div>
        <div class="stat-content">
          <h3>{{ activeRequestsCount }}</h3>
          <p>En progreso</p>
        </div>
      </div>
      <div class="stat-item">
        <div class="stat-icon">✅</div>
        <div class="stat-content">
          <h3>{{ pendingPaymentCount }}</h3>
          <p>Pago pendiente</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import PaymentPill from '@/components/PaymentPill.vue';

const ACTIVE_STATUSES = ['accepted', 'in_progress', 'on_the_way', 'arrived', 'finalized'];
const STATUS_FLOW = {
  pending: ['accepted', 'rejected'], accepted: ['in_progress'],
  in_progress: ['on_the_way'], on_the_way: ['arrived'],
  arrived: ['finalized'], finalized: ['completed'], completed: [],
  cancelled: [], rejected: []
};
const STATUS_EMOJIS = {
  pending: '⏳', accepted: '👍', rejected: '👎', in_progress: '📦',
  on_the_way: '🚚', arrived: '📍', finalized: '✅', completed: '✅', cancelled: '❌'
};

export default {
  name: 'SolicitudesActivas',
  components: { PaymentPill },
  props: {
    requests: { type: Array, required: true },
    loading: { type: Boolean, default: false },
    dropdownState: { type: [String, Number], default: null }
  },
  emits: ['set-status', 'open-chat', 'open-proof', 'toggle-dropdown'],
  data() {
    return {
      openTimeline: null
    };
  },
  computed: {
    openDropdown() {
      return this.dropdownState;
    },
    activeRequestsCount() {
      return this.requests.filter(r => 
        ['accepted', 'in_progress', 'on_the_way', 'arrived'].includes(r.status)
      ).length;
    },
    pendingPaymentCount() {
      return this.requests.filter(r => 
        r.payment_status === 'pending' || r.payment_status === 'verifying'
      ).length;
    }
  },
  methods: {
    getStatusClass(status) {
      const classes = {
        pending: 'status-pending',
        accepted: 'status-accepted',
        in_progress: 'status-in-progress',
        on_the_way: 'status-on-the-way',
        arrived: 'status-arrived',
        finalized: 'status-finalized',
        completed: 'status-completed',
        cancelled: 'status-cancelled',
        rejected: 'status-rejected'
      };
      return classes[status] || '';
    },
    
    sanitize(str) {
      if (!str || typeof str !== 'string') return str;
      const tempDiv = document.createElement('div');
      tempDiv.textContent = str;
      return tempDiv.innerHTML.replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
        .replace(/on\w+="[^"]*"/g, '').replace(/on\w+='[^']*'/g, '')
        .replace(/javascript:/gi, '');
    },
    
    formatDate(d, onlyTime = false) {
      if (!d) return '';
      const locale = this.$i18n.locale.value || 'es';
      const opts = onlyTime ? { hour: '2-digit', minute: '2-digit', second: '2-digit' }
        : { year: 'numeric', month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit' };
      try { return new Date(d).toLocaleString(locale, opts); } catch { return d; }
    },
    
    formatCurrency(amount) {
      const locale = this.$i18n.locale.value || 'es';
      return new Intl.NumberFormat(locale, { style: 'currency', currency: 'USD' }).format(amount || 0);
    },
    
    statusLabel(status) {
      const key = 'status.' + status;
      const translated = this.$t(key);
      return translated === key ? status : translated;
    },
    
    emoji(status) { return STATUS_EMOJIS[status] || '•'; },
    
    allowedNext(status) { return STATUS_FLOW[status] || []; },
    
    toggleDropdown(id) { 
      this.$emit('toggle-dropdown', id); 
    },
    
    toggleTimeline(id) {
      this.openTimeline = this.openTimeline === id ? null : id;
    },
    
    elapsed(updatedAt) {
      if (!updatedAt) return '00:00:00';
      try {
        const seconds = Math.floor((Date.now() - new Date(updatedAt)) / 1000);
        const h = String(Math.floor(seconds / 3600)).padStart(2, '0');
        const m = String(Math.floor((seconds % 3600) / 60)).padStart(2, '0');
        const s = String(seconds % 60).padStart(2, '0');
        return `${h}:${m}:${s}`;
      } catch { return '00:00:00'; }
    },
    
    timeline(req) { 
      return [{ status: req.status, updated_at: req.updated_at }]; 
    }
  }
};
</script>

<style scoped>
.solicitudes-activas-page {
  max-width: 1400px;
  margin: 0 auto;
  padding: 24px;
  min-height: 100vh;
  background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
}

/* Header */
.page-header {
  text-align: center;
  margin-bottom: 40px;
  padding: 30px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 20px;
  color: white;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
}

.page-header h1 {
  font-size: 2.5rem;
  margin-bottom: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 15px;
}

.header-icon {
  font-size: 2.2rem;
  animation: bounce 2s infinite;
}

@keyframes bounce {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-10px); }
}
1a
.page-header p {
  font-size: 1.2rem;
  opacity: 0.9;
}

/* Loading State */
.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 300px;
  background: white;
  border-radius: 20px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
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

.loading-container p {
  color: #636e72;
  font-size: 1.1rem;
}

/* Empty State */
.empty-state {
  text-align: center;
  padding: 60px 20px;
  background: white;
  border-radius: 20px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
}

.empty-icon {
  font-size: 80px;
  margin-bottom: 24px;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}

.empty-state h3 {
  color: #2d3436;
  margin-bottom: 12px;
  font-size: 1.8rem;
}

.empty-state p {
  color: #636e72;
  font-size: 1.1rem;
  max-width: 400px;
  margin: 0 auto;
}

/* Requests Grid */
.requests-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
  gap: 30px;
  margin-bottom: 40px;
}

.request-card {
  background: white;
  border-radius: 20px;
  overflow: hidden;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
  transition: all 0.4s;
  position: relative;
  border: 1px solid #f1f2f6;
}

.request-card:hover {
  transform: translateY(-10px);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
}

/* Status Classes */
.status-pending { border-left: 6px solid #fdcb6e; }
.status-accepted { border-left: 6px solid #74b9ff; }
.status-in-progress { border-left: 6px solid #a29bfe; }
.status-on-the-way { border-left: 6px solid #fd79a8; }
.status-arrived { border-left: 6px solid #55efc4; }
.status-finalized { border-left: 6px solid #00b894; }
.status-completed { border-left: 6px solid #00cec9; }
.status-cancelled { border-left: 6px solid #ff7675; }
.status-rejected { border-left: 6px solid #636e72; }

/* Card Header */
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  padding: 24px 24px 16px;
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  border-bottom: 1px solid #dee2e6;
}

.service-info {
  flex: 1;
}

.service-title {
  font-size: 1.4rem;
  color: #2d3436;
  margin-bottom: 12px;
  line-height: 1.3;
  font-weight: 700;
}

.status-badge {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 6px 16px;
  border-radius: 20px;
  background: white;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.status-emoji {
  font-size: 1.2rem;
}

.status-text {
  font-weight: 600;
  font-size: 0.9rem;
  color: #2d3436;
}

/* Card Content */
.card-content {
  padding: 20px 24px;
}

.service-description {
  color: #636e72;
  font-size: 0.95rem;
  line-height: 1.5;
  margin-bottom: 20px;
  padding-bottom: 20px;
  border-bottom: 1px solid #f1f2f6;
}

/* Client Info */
.client-info {
  display: flex;
  align-items: center;
  gap: 15px;
  margin-bottom: 20px;
  padding: 15px;
  background: #f8f9fa;
  border-radius: 12px;
}

.client-avatar {
  width: 45px;
  height: 45px;
  background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 1.5rem;
}

.client-details {
  flex: 1;
}

.client-name {
  font-weight: 600;
  color: #2d3436;
  margin-bottom: 4px;
}

.elapsed-time {
  display: flex;
  align-items: center;
  gap: 6px;
  color: #636e72;
  font-size: 0.9rem;
}

.time-icon {
  font-size: 0.9rem;
}

/* Cancellation Info */
.cancelled-info {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 12px;
  background: linear-gradient(135deg, #ffebee 0%, #ffcdd2 100%);
  border-radius: 10px;
  margin-bottom: 20px;
  border-left: 4px solid #ff7675;
}

.warning-icon {
  font-size: 1.2rem;
}

.cancelled-text {
  color: #d63031;
  font-weight: 600;
  font-size: 0.9rem;
}

/* Proof Section */
.proof-section {
  margin-bottom: 20px;
}

.btn-proof {
  background: linear-gradient(135deg, #fdcb6e 0%, #e17055 100%);
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 10px;
  cursor: pointer;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 10px;
  transition: all 0.3s;
  width: 100%;
  justify-content: center;
}

.btn-proof:hover {
  transform: translateY(-3px);
  box-shadow: 0 10px 20px rgba(225, 112, 85, 0.3);
}

.proof-icon {
  font-size: 1.2rem;
}

/* Timeline Section */
.timeline-section {
  background: white;
  border-radius: 12px;
  border: 1px solid #e9ecef;
  margin-bottom: 20px;
}

.timeline-header {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 15px 20px;
  cursor: pointer;
  background: #f8f9fa;
  border-radius: 12px 12px 0 0;
  transition: background 0.3s;
}

.timeline-header:hover {
  background: #e9ecef;
}

.timeline-icon {
  font-size: 1.2rem;
}

.timeline-title {
  font-weight: 600;
  color: #2d3436;
  flex: 1;
}

.timeline-arrow {
  font-size: 0.8rem;
  transition: transform 0.3s;
}

.timeline-arrow.open {
  transform: rotate(180deg);
}

.timeline-content {
  padding: 20px;
  border-top: 1px solid #e9ecef;
}

.timeline-item {
  display: flex;
  align-items: center;
  gap: 15px;
  padding: 10px 0;
  border-bottom: 1px solid #f1f2f6;
}

.timeline-item:last-child {
  border-bottom: none;
}

.timeline-dot {
  width: 12px;
  height: 12px;
  background: #3498db;
  border-radius: 50%;
  flex-shrink: 0;
}

.timeline-status {
  flex: 1;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.status-label {
  font-weight: 600;
  color: #2d3436;
  font-size: 0.9rem;
}

.status-time {
  color: #636e72;
  font-size: 0.85rem;
  font-family: monospace;
}

/* Card Footer */
.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 24px;
  background: #f8f9fa;
  border-top: 1px solid #dee2e6;
  gap: 20px;
}

/* Status Dropdown */
.status-dropdown {
  position: relative;
  flex: 1;
}

.dropdown-toggle {
  background: linear-gradient(135deg, #6c5ce7 0%, #a29bfe 100%);
  color: white;
  border: none;
  padding: 12px 20px;
  border-radius: 10px;
  cursor: pointer;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 10px;
  width: 100%;
  transition: all 0.3s;
}

.dropdown-toggle:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 20px rgba(108, 92, 231, 0.3);
}

.dropdown-icon {
  font-size: 1.1rem;
}

.dropdown-arrow {
  font-size: 0.8rem;
  margin-left: auto;
  transition: transform 0.3s;
}

.dropdown-arrow.open {
  transform: rotate(180deg);
}

.dropdown-menu {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  margin-top: 8px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
  z-index: 100;
  overflow: hidden;
  border: 1px solid #e9ecef;
}

.dropdown-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px 20px;
  width: 100%;
  border: none;
  background: white;
  cursor: pointer;
  text-align: left;
  transition: all 0.2s;
  border-bottom: 1px solid #f1f2f6;
}

.dropdown-item:last-child {
  border-bottom: none;
}

.dropdown-item:hover {
  background: #f8f9fa;
}

.item-emoji {
  font-size: 1.2rem;
  width: 24px;
  text-align: center;
}

.item-text {
  font-weight: 600;
  color: #2d3436;
  font-size: 0.9rem;
}

/* Action Buttons */
.action-buttons {
  display: flex;
  gap: 12px;
}

.btn-chat {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
  color: white;
  border: none;
  padding: 12px 20px;
  border-radius: 10px;
  cursor: pointer;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s;
  min-width: 100px;
  justify-content: center;
}

.btn-chat:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 20px rgba(0, 184, 148, 0.3);
}

.chat-icon {
  font-size: 1.1rem;
}

.chat-text {
  font-size: 0.9rem;
}

/* Card Update */
.card-update {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 15px 24px;
  background: #2d3436;
  color: white;
  font-size: 0.85rem;
}

.update-icon {
  font-size: 0.9rem;
}

.update-text {
  opacity: 0.9;
}

/* Stats Summary */
.stats-summary {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 24px;
  margin-top: 40px;
}

.stat-item {
  background: white;
  padding: 24px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  gap: 20px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
  transition: transform 0.3s;
}

.stat-item:hover {
  transform: translateY(-5px);
}

.stat-icon {
  font-size: 2rem;
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 12px;
  color: white;
}

.stat-content h3 {
  font-size: 2rem;
  color: #2d3436;
  margin-bottom: 4px;
}

.stat-content p {
  color: #636e72;
  font-size: 0.9rem;
}

/* Responsive Design */
@media (max-width: 1200px) {
  .requests-grid {
    grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  }
}

@media (max-width: 768px) {
  .solicitudes-activas-page {
    padding: 16px;
  }
  
  .page-header h1 {
    font-size: 2rem;
  }
  
  .requests-grid {
    grid-template-columns: 1fr;
    gap: 24px;
  }
  
  .card-footer {
    flex-direction: column;
  }
  
  .status-dropdown {
    width: 100%;
  }
  
  .action-buttons {
    width: 100%;
  }
  
  .btn-chat {
    width: 100%;
  }
  
  .stats-summary {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 480px) {
  .page-header {
    padding: 20px;
  }
  
  .page-header h1 {
    font-size: 1.8rem;
    flex-direction: column;
    gap: 10px;
  }
  
  .card-header {
    flex-direction: column;
    gap: 15px;
    align-items: stretch;
  }
  
  .timeline-header {
    padding: 12px 16px;
  }
  
  .card-update {
    flex-direction: column;
    text-align: center;
    gap: 8px;
  }
}
</style>
