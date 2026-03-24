<template>
  <div class="historial-container">
    <!-- Header -->
    <div class="header-section">
      <div class="header-content">
        <h1><span class="icon">📜</span> Historial de Servicios</h1>
        <p>Revisa todos los servicios que has solicitado</p>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="loading-container">
      <div class="spinner"></div>
      <p>Cargando historial...</p>
    </div>

    <!-- Main Content -->
    <div v-else>
      <!-- Stats Summary -->
      <div class="stats-summary" v-if="requests.length > 0">
        <div class="stat-item">
          <div class="stat-icon">📊</div>
          <div class="stat-content">
            <h3>{{ requests.length }}</h3>
            <p>Total servicios</p>
          </div>
        </div>
        <div class="stat-item">
          <div class="stat-icon">✅</div>
          <div class="stat-content">
            <h3>{{ completedRequests }}</h3>
            <p>Completados</p>
          </div>
        </div>
        <div class="stat-item">
          <div class="stat-icon">💰</div>
          <div class="stat-content">
            <h3>{{ formatPrice(totalSpent) }}</h3>
            <p>Total gastado</p>
          </div>
        </div>
        <div class="stat-item">
          <div class="stat-icon">📅</div>
          <div class="stat-content">
            <h3>{{ lastMonthRequests }}</h3>
            <p>Último mes</p>
          </div>
        </div>
      </div>

      <!-- Filters -->
      <div class="filters-section" v-if="requests.length > 0">
        <div class="filter-group">
          <label for="status-filter">Filtrar por estado:</label>
          <select 
            id="status-filter" 
            v-model="filterStatus"
            class="filter-select"
          >
            <option value="all">Todos los estados</option>
            <option value="completed">Completados</option>
            <option value="cancelled">Cancelados</option>
            <option value="rejected">Rechazados</option>
            <option value="finalized">Finalizados</option>
          </select>
        </div>
        
        <div class="filter-group">
          <label for="payment-filter">Filtrar por pago:</label>
          <select 
            id="payment-filter" 
            v-model="filterPayment"
            class="filter-select"
          >
            <option value="all">Todos los pagos</option>
            <option value="paid">Pagados</option>
            <option value="pending">Pendientes</option>
            <option value="failed">Fallidos</option>
            <option value="refunded">Reembolsados</option>
          </select>
        </div>

        <div class="filter-group">
          <label for="sort-filter">Ordenar por:</label>
          <select 
            id="sort-filter" 
            v-model="sortBy"
            class="filter-select"
          >
            <option value="recent">Más recientes</option>
            <option value="oldest">Más antiguos</option>
            <option value="price-high">Mayor precio</option>
            <option value="price-low">Menor precio</option>
            <option value="name">Nombre (A-Z)</option>
          </select>
        </div>

        <div class="filter-actions">
          <button 
            class="btn-reset-filters"
            @click="resetFilters"
            :disabled="!hasActiveFilters"
          >
            <span class="btn-icon">🔄</span>
            Reiniciar filtros
          </button>
        </div>
      </div>

      <!-- Timeline View -->
      <div v-if="filteredRequests.length > 0" class="timeline-container">
        <div class="timeline-header">
          <h2>Línea de tiempo de servicios</h2>
          <p class="timeline-subtitle">{{ filteredRequests.length }} servicio{{ filteredRequests.length !== 1 ? 's' : '' }} encontrado{{ filteredRequests.length !== 1 ? 's' : '' }}</p>
        </div>

        <div class="timeline">
          <div 
            v-for="(req, index) in filteredRequests" 
            :key="req.id" 
            class="timeline-item"
            @click="$emit('open-history', req)"
          >
            <!-- Timeline connector -->
            <div class="timeline-connector" v-if="index < filteredRequests.length - 1"></div>
            
            <!-- Timeline dot -->
            <div class="timeline-dot" :class="getStatusDotClass(req.status)">
              <span class="dot-icon">{{ getStatusIcon(req.status) }}</span>
            </div>

            <!-- Timeline content -->
            <div class="timeline-content">
              <div class="timeline-card">
                <!-- Card header -->
                <div class="card-header">
                  <div class="card-badge" :class="getStatusBadgeClass(req.status)">
                    {{ getStatusLabel(req.status) }}
                  </div>
                  <div class="card-date">
                    {{ formatDate(req.completed_at || req.created_at) }}
                  </div>
                </div>

                <!-- Card body -->
                <div class="card-body">
                  <h3 class="card-title">{{ sanitize(req.service_title) }}</h3>
                  <p class="card-description" v-if="req.service_description">
                    {{ sanitize(req.service_description) }}
                  </p>

                  <!-- Provider info -->
                  <div class="provider-info">
                    <div class="provider-avatar-placeholder">
                      <span class="avatar-icon">👤</span>
                    </div>
                    <div class="provider-details">
                      <span class="provider-name">{{ sanitize(req.service_provider_name || 'Proveedor') }}</span>
                      <div class="provider-meta">
                        <span class="meta-rating" v-if="req.provider_rating">
                          ⭐ {{ parseRating(req.provider_rating).toFixed(1) }}
                        </span>
                      </div>
                    </div>
                  </div>

                  <!-- Payment info -->
                  <div class="payment-info">
                    <div class="payment-status">
                      <PaymentPill :status="req.payment_status" />
                    </div>
                    <div class="payment-amount">
                      <span class="amount-label">Pago:</span>
                      <span class="amount-value">{{ formatCurrency(req.service_price) }}</span>
                    </div>
                  </div>
                </div>

                <!-- Card footer -->
                <div class="card-footer">
                  <button 
                    class="btn-view-details"
                    @click.stop="$emit('open-history', req)"
                  >
                    <span class="btn-icon">👁️</span>
                    Ver detalles
                  </button>
                  <div class="card-meta">
                    <span class="meta-item" v-if="req.id">
                      <span class="meta-icon">#</span>
                      {{ req.id }}
                    </span>
                    <span class="meta-item">
                      <span class="meta-icon">📅</span>
                      {{ formatTimeAgo(req.completed_at || req.created_at) }}
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div v-else class="empty-state">
        <div class="empty-icon">📜</div>
        <h3 v-if="hasActiveFilters">
          No hay servicios en el historial con estos filtros
        </h3>
        <h3 v-else>No tienes servicios en el historial</h3>
        
        <p v-if="filterStatus !== 'all'">
          No hay servicios con estado "{{ getFilterStatusLabel() }}"
        </p>
        <p v-else-if="filterPayment !== 'all'">
          No hay servicios con pago "{{ getFilterPaymentLabel() }}"
        </p>
        <p v-else>
          Aquí aparecerán todos los servicios que hayas completado o cancelado
        </p>
        
        <div class="empty-actions" v-if="hasActiveFilters">
          <button 
            class="btn-primary"
            @click="resetFilters"
          >
            Mostrar todos los servicios
          </button>
        </div>
      </div>

      <!-- Export Options -->
      <div class="export-section" v-if="filteredRequests.length > 0">
        <h3>Exportar historial</h3>
        <div class="export-options">
          <button class="export-btn" @click="exportToPDF">
            <span class="export-icon">📄</span>
            Exportar a PDF
          </button>
          <button class="export-btn" @click="exportToCSV">
            <span class="export-icon">📊</span>
            Exportar a CSV
          </button>
          <button class="export-btn" @click="printHistory">
            <span class="export-icon">🖨️</span>
            Imprimir
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import PaymentPill from '@/components/PaymentPill.vue';

const STATUS_LABELS = {
  completed: 'Completado',
  cancelled: 'Cancelado',
  rejected: 'Rechazado',
  finalized: 'Finalizado',
  pending: 'Pendiente',
  accepted: 'Aceptado',
  in_progress: 'En progreso'
};

const PAYMENT_LABELS = {
  paid: 'Pagado',
  pending: 'Pendiente',
  failed: 'Fallido',
  refunded: 'Reembolsado'
};

export default {
  name: 'Historial',
  components: { PaymentPill },
  props: {
    requests: { type: Array, required: true },
    loading: { type: Boolean, default: false }
  },
  emits: ['open-history'],
  data() {
    return {
      filterStatus: 'all',
      filterPayment: 'all',
      sortBy: 'recent'
    }
  },
  computed: {
    completedRequests() {
      return this.requests.filter(r => 
        r.status === 'completed' || r.status === 'finalized'
      ).length;
    },
    totalSpent() {
      return this.requests.reduce((sum, r) => {
        const price = this.parsePrice(r.service_price);
        // Solo contar los que están pagados
        if (r.payment_status === 'paid') {
          return sum + price;
        }
        return sum;
      }, 0);
    },
    lastMonthRequests() {
      const oneMonthAgo = new Date();
      oneMonthAgo.setMonth(oneMonthAgo.getMonth() - 1);
      
      return this.requests.filter(r => {
        const date = r.completed_at || r.created_at;
        return new Date(date) >= oneMonthAgo;
      }).length;
    },
    filteredRequests() {
      let filtered = [...this.requests];
      
      // Filtrar por estado
      if (this.filterStatus !== 'all') {
        filtered = filtered.filter(r => r.status === this.filterStatus);
      }
      
      // Filtrar por estado de pago
      if (this.filterPayment !== 'all') {
        filtered = filtered.filter(r => r.payment_status === this.filterPayment);
      }
      
      // Ordenar
      switch (this.sortBy) {
        case 'recent':
          filtered.sort((a, b) => {
            const dateA = new Date(a.completed_at || a.created_at);
            const dateB = new Date(b.completed_at || b.created_at);
            return dateB - dateA;
          });
          break;
        case 'oldest':
          filtered.sort((a, b) => {
            const dateA = new Date(a.completed_at || a.created_at);
            const dateB = new Date(b.completed_at || b.created_at);
            return dateA - dateB;
          });
          break;
        case 'price-high':
          filtered.sort((a, b) => this.parsePrice(b.service_price) - this.parsePrice(a.service_price));
          break;
        case 'price-low':
          filtered.sort((a, b) => this.parsePrice(a.service_price) - this.parsePrice(b.service_price));
          break;
        case 'name':
          filtered.sort((a, b) => (a.service_title || '').localeCompare(b.service_title || ''));
          break;
      }
      
      return filtered;
    },
    hasActiveFilters() {
      return this.filterStatus !== 'all' || this.filterPayment !== 'all';
    }
  },
  methods: {
    sanitize(str) {
      if (!str || typeof str !== 'string') return str;
      const tempDiv = document.createElement('div');
      tempDiv.textContent = str;
      return tempDiv.innerHTML
        .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
        .replace(/on\w+="[^"]*"/g, '').replace(/on\w+='[^']*'/g, '')
        .replace(/javascript:/gi, '');
    },
    formatCurrency(amount) {
      const locale = this.$i18n?.locale?.value || 'es';
      return new Intl.NumberFormat(locale, { 
        style: 'currency', 
        currency: 'USD' 
      }).format(amount || 0);
    },
    formatPrice(price) {
      return new Intl.NumberFormat('es-ES', {
        style: 'currency',
        currency: 'USD',
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
      }).format(price);
    },
    parsePrice(price) {
      if (!price && price !== 0) return 0;
      const num = Number(price);
      return isNaN(num) ? 0 : num;
    },
    parseRating(rating) {
      if (!rating && rating !== 0) return 0;
      const num = Number(rating);
      return isNaN(num) ? 0 : num;
    },
    formatDate(dateString) {
      if (!dateString) return 'Sin fecha';
      const date = new Date(dateString);
      return date.toLocaleDateString('es-ES', {
        day: 'numeric',
        month: 'long',
        year: 'numeric'
      });
    },
    formatTimeAgo(dateString) {
      if (!dateString) return 'Recientemente';
      const date = new Date(dateString);
      const now = new Date();
      const diffMs = now - date;
      const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));
      
      if (diffDays === 0) return 'Hoy';
      if (diffDays === 1) return 'Ayer';
      if (diffDays < 7) return `Hace ${diffDays} días`;
      if (diffDays < 30) return `Hace ${Math.floor(diffDays / 7)} semana${Math.floor(diffDays / 7) !== 1 ? 's' : ''}`;
      if (diffDays < 365) return `Hace ${Math.floor(diffDays / 30)} mes${Math.floor(diffDays / 30) !== 1 ? 'es' : ''}`;
      return `Hace ${Math.floor(diffDays / 365)} año${Math.floor(diffDays / 365) !== 1 ? 's' : ''}`;
    },
    getStatusLabel(status) {
      return STATUS_LABELS[status] || status;
    },
    getFilterStatusLabel() {
      return STATUS_LABELS[this.filterStatus] || this.filterStatus;
    },
    getFilterPaymentLabel() {
      return PAYMENT_LABELS[this.filterPayment] || this.filterPayment;
    },
    getStatusBadgeClass(status) {
      const classes = {
        completed: 'status-completed',
        finalized: 'status-completed',
        cancelled: 'status-cancelled',
        rejected: 'status-rejected',
        pending: 'status-pending',
        accepted: 'status-accepted',
        in_progress: 'status-in-progress'
      };
      return classes[status] || 'status-default';
    },
    getStatusDotClass(status) {
      const classes = {
        completed: 'dot-completed',
        finalized: 'dot-completed',
        cancelled: 'dot-cancelled',
        rejected: 'dot-rejected',
        pending: 'dot-pending',
        accepted: 'dot-accepted',
        in_progress: 'dot-in-progress'
      };
      return classes[status] || 'dot-default';
    },
    getStatusIcon(status) {
      const icons = {
        completed: '✅',
        finalized: '✅',
        cancelled: '❌',
        rejected: '🚫',
        pending: '⏳',
        accepted: '👍',
        in_progress: '🚀'
      };
      return icons[status] || '📝';
    },
    statusColor(status) {
      const colors = { 
        completed: 'text-green-600', 
        cancelled: 'text-red-600', 
        rejected: 'text-orange-600', 
        finalized: 'text-green-700',
        pending: 'text-yellow-600',
        accepted: 'text-blue-600',
        in_progress: 'text-purple-600'
      };
      return colors[status] || 'text-gray-500';
    },
    resetFilters() {
      this.filterStatus = 'all';
      this.filterPayment = 'all';
      this.sortBy = 'recent';
    },
    exportToPDF() {
      // Implementar exportación a PDF
      console.log('Exportando a PDF...', this.filteredRequests.length);
    },
    exportToCSV() {
      const headers = ['Fecha', 'Servicio', 'Proveedor', 'Estado', 'Pago', 'Precio'];
      const csvData = this.filteredRequests.map(req => [
        this.formatDate(req.completed_at || req.created_at),
        this.sanitize(req.service_title),
        this.sanitize(req.service_provider_name || 'Proveedor'),
        this.getStatusLabel(req.status),
        req.payment_status || 'N/A',
        `$${this.parsePrice(req.service_price).toFixed(2)}`
      ]);
      
      const csvContent = [headers, ...csvData]
        .map(row => row.map(cell => `"${cell}"`).join(','))
        .join('\n');
      
      const blob = new Blob([csvContent], { type: 'text/csv' });
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `historial-servicios-${new Date().toISOString().split('T')[0]}.csv`;
      a.click();
    },
    printHistory() {
      window.print();
    }
  }
};
</script>

<style scoped>
.historial-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 16px;
  min-height: 100vh;
}

/* Header */
.header-section {
  margin-bottom: 32px;
}

.header-content {
  text-align: center;
  margin-bottom: 24px;
}

.header-content h1 {
  font-size: 2.2rem;
  color: #2d3436;
  margin-bottom: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
}

.header-content .icon {
  font-size: 2rem;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.1); }
}

.header-content p {
  color: #636e72;
  font-size: 1rem;
  max-width: 600px;
  margin: 0 auto;
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

.loading-container p {
  color: #636e72;
  font-size: 1.1rem;
}

/* Stats Summary */
.stats-summary {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
  margin-bottom: 32px;
}

.stat-item {
  background: white;
  padding: 20px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  gap: 16px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
  transition: transform 0.3s;
}

.stat-item:hover {
  transform: translateY(-5px);
}

.stat-icon {
  font-size: 2rem;
  width: 50px;
  height: 50px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 12px;
  color: white;
}

.stat-content h3 {
  font-size: 1.5rem;
  color: #2d3436;
  margin-bottom: 4px;
}

.stat-content p {
  color: #636e72;
  font-size: 0.85rem;
}

/* Filters Section */
.filters-section {
  background: white;
  padding: 24px;
  border-radius: 16px;
  margin-bottom: 32px;
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 24px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
}

.filter-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.filter-group label {
  font-weight: 600;
  color: #2d3436;
  font-size: 0.9rem;
}

.filter-select {
  padding: 12px;
  border: 2px solid #dfe6e9;
  border-radius: 10px;
  font-size: 0.95rem;
  transition: all 0.3s;
  background: white;
  cursor: pointer;
}

.filter-select:focus {
  outline: none;
  border-color: #3498db;
  box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
}

.filter-actions {
  grid-column: 1 / -1;
  display: flex;
  justify-content: center;
  margin-top: 8px;
}

.btn-reset-filters {
  background: #dfe6e9;
  color: #2d3436;
  border: none;
  padding: 12px 24px;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  font-size: 0.9rem;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s;
}

.btn-reset-filters:hover:not(:disabled) {
  background: #b2bec3;
  transform: translateY(-2px);
}

.btn-reset-filters:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Timeline Container */
.timeline-container {
  margin-bottom: 40px;
}

.timeline-header {
  text-align: center;
  margin-bottom: 32px;
}

.timeline-header h2 {
  font-size: 1.8rem;
  color: #2d3436;
  margin-bottom: 8px;
}

.timeline-subtitle {
  color: #636e72;
  font-size: 1rem;
}

/* Timeline */
.timeline {
  position: relative;
  padding-left: 40px;
}

.timeline-item {
  position: relative;
  margin-bottom: 40px;
  cursor: pointer;
}

.timeline-connector {
  position: absolute;
  left: 19px;
  top: 48px;
  bottom: -40px;
  width: 2px;
  background: linear-gradient(to bottom, #74b9ff, #dfe6e9);
  z-index: 1;
}

.timeline-dot {
  position: absolute;
  left: 0;
  top: 0;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2;
  border: 3px solid white;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.dot-completed { background: linear-gradient(135deg, #00b894 0%, #00a085 100%); }
.dot-cancelled { background: linear-gradient(135deg, #ff7675 0%, #d63031 100%); }
.dot-rejected { background: linear-gradient(135deg, #fdcb6e 0%, #e17055 100%); }
.dot-pending { background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%); }
.dot-accepted { background: linear-gradient(135deg, #a29bfe 0%, #6c5ce7 100%); }
.dot-in-progress { background: linear-gradient(135deg, #fd79a8 0%, #e84393 100%); }
.dot-default { background: linear-gradient(135deg, #b2bec3 0%, #636e72 100%); }

.dot-icon {
  font-size: 1.2rem;
  color: white;
}

/* Timeline Content */
.timeline-content {
  margin-left: 60px;
}

.timeline-card {
  background: white;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.08);
  transition: all 0.3s;
  border: 1px solid #f1f2f6;
}

.timeline-card:hover {
  transform: translateX(5px);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
}

/* Card Header */
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  background: #f8f9fa;
  border-bottom: 1px solid #e9ecef;
}

.card-badge {
  padding: 6px 16px;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
  color: white;
}

.status-completed { background: linear-gradient(135deg, #00b894 0%, #00a085 100%); }
.status-cancelled { background: linear-gradient(135deg, #ff7675 0%, #d63031 100%); }
.status-rejected { background: linear-gradient(135deg, #fdcb6e 0%, #e17055 100%); }
.status-pending { background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%); }
.status-accepted { background: linear-gradient(135deg, #a29bfe 0%, #6c5ce7 100%); }
.status-in-progress { background: linear-gradient(135deg, #fd79a8 0%, #e84393 100%); }
.status-default { background: linear-gradient(135deg, #b2bec3 0%, #636e72 100%); }

.card-date {
  color: #636e72;
  font-size: 0.85rem;
  font-weight: 600;
}

/* Card Body */
.card-body {
  padding: 20px;
}

.card-title {
  font-size: 1.3rem;
  color: #2d3436;
  margin-bottom: 12px;
  line-height: 1.3;
}

.card-description {
  color: #636e72;
  font-size: 0.95rem;
  line-height: 1.5;
  margin-bottom: 20px;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

/* Provider Info */
.provider-info {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 20px;
  padding: 12px;
  background: #f8f9fa;
  border-radius: 12px;
}

.provider-avatar-placeholder {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
}

.avatar-icon {
  font-size: 1.2rem;
  color: white;
}

.provider-details {
  flex: 1;
}

.provider-name {
  display: block;
  font-weight: 600;
  color: #2d3436;
  margin-bottom: 4px;
}

.provider-meta {
  display: flex;
  align-items: center;
  gap: 8px;
}

.meta-rating {
  color: #fdcb6e;
  font-size: 0.9rem;
  font-weight: 600;
}

/* Payment Info */
.payment-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  background: #f8f9fa;
  border-radius: 12px;
  margin-bottom: 20px;
}

.payment-status {
  flex: 1;
}

.payment-amount {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
}

.amount-label {
  color: #636e72;
  font-size: 0.85rem;
  margin-bottom: 4px;
}

.amount-value {
  font-size: 1.5rem;
  font-weight: 700;
  color: #00b894;
}

/* Card Footer */
.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  border-top: 1px solid #e9ecef;
}

.btn-view-details {
  background: #3498db;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  font-size: 0.9rem;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s;
}

.btn-view-details:hover {
  background: #2980b9;
  transform: translateY(-2px);
}

.card-meta {
  display: flex;
  gap: 16px;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 6px;
  color: #636e72;
  font-size: 0.85rem;
}

.meta-icon {
  font-size: 0.9rem;
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

.empty-state h3 {
  color: #2d3436;
  margin-bottom: 12px;
  font-size: 1.8rem;
}

.empty-state p {
  color: #636e72;
  font-size: 1.1rem;
  margin-bottom: 32px;
  max-width: 500px;
  margin-left: auto;
  margin-right: auto;
}

.empty-actions {
  display: flex;
  gap: 16px;
  justify-content: center;
  flex-wrap: wrap;
}

.btn-primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 14px 32px;
  border-radius: 10px;
  border: none;
  cursor: pointer;
  font-weight: 600;
  transition: transform 0.3s, box-shadow 0.3s;
}

.btn-primary:hover {
  transform: translateY(-3px);
  box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
}

/* Export Section */
.export-section {
  background: white;
  padding: 32px;
  border-radius: 20px;
  text-align: center;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
  margin-bottom: 40px;
}

.export-section h3 {
  color: #2d3436;
  margin-bottom: 24px;
  font-size: 1.5rem;
}

.export-options {
  display: flex;
  justify-content: center;
  gap: 16px;
  flex-wrap: wrap;
}

.export-btn {
  background: linear-gradient(135deg, #a8edea 0%, #fed6e3 100%);
  border: none;
  padding: 14px 28px;
  border-radius: 12px;
  cursor: pointer;
  font-weight: 600;
  color: #2d3436;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s;
}

.export-btn:hover {
  transform: translateY(-3px);
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
}

.export-icon {
  font-size: 1.2rem;
}

/* Responsive Design */
@media (max-width: 768px) {
  .historial-container {
    padding: 0 12px;
  }
  
  .header-content h1 {
    font-size: 1.8rem;
  }
  
  .stats-summary {
    grid-template-columns: repeat(2, 1fr);
    gap: 16px;
  }
  
  .stat-item {
    padding: 16px;
  }
  
  .stat-icon {
    width: 40px;
    height: 40px;
    font-size: 1.6rem;
  }
  
  .filters-section {
    grid-template-columns: 1fr;
    padding: 20px;
  }
  
  .timeline {
    padding-left: 30px;
  }
  
  .timeline-dot {
    width: 30px;
    height: 30px;
    left: -5px;
  }
  
  .timeline-connector {
    left: 10px;
  }
  
  .timeline-content {
    margin-left: 40px;
  }
  
  .card-footer {
    flex-direction: column;
    gap: 16px;
    align-items: stretch;
  }
  
  .btn-view-details {
    width: 100%;
    justify-content: center;
  }
  
  .card-meta {
    justify-content: center;
  }
  
  .export-options {
    flex-direction: column;
    align-items: stretch;
  }
  
  .export-btn {
    justify-content: center;
  }
}

@media (max-width: 480px) {
  .header-content h1 {
    font-size: 1.6rem;
    flex-direction: column;
    gap: 8px;
  }
  
  .stats-summary {
    grid-template-columns: 1fr;
  }
  
  .timeline-dot {
    width: 28px;
    height: 28px;
    left: -6px;
  }
  
  .dot-icon {
    font-size: 1rem;
  }
  
  .payment-info {
    flex-direction: column;
    gap: 16px;
    align-items: stretch;
  }
  
  .payment-amount {
    align-items: flex-start;
  }
}
</style>
