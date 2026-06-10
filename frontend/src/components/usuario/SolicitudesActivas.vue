<template>
  <div class="solicitudes-container">
    <!-- Header -->
    <div class="header-section">
      <div class="header-content">
        <h1><span class="icon">📋</span> Solicitudes Activas</h1>
        <p>Realiza seguimiento a tus servicios en curso</p>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="loading-container">
      <div class="spinner"></div>
      <p>Cargando solicitudes...</p>
    </div>

    <!-- Main Content -->
    <div v-else>
      <!-- Stats Summary - Mejorado para móvil -->
      <div class="stats-summary" v-if="requests.length > 0">
        <div class="stat-item">
          <div class="stat-icon">📊</div>
          <div class="stat-content">
            <h3>{{ requests.length }}</h3>
            <p>Solicitudes totales</p>
          </div>
        </div>
        <div class="stat-item">
          <div class="stat-icon">⏳</div>
          <div class="stat-content">
            <h3>{{ pendingRequests }}</h3>
            <p>En espera</p>
          </div>
        </div>
        <div class="stat-item">
          <div class="stat-icon">🚀</div>
          <div class="stat-content">
            <h3>{{ inProgressRequests }}</h3>
            <p>En progreso</p>
          </div>
        </div>
        <div class="stat-item">
          <div class="stat-icon">💰</div>
          <div class="stat-content">
            <h3>{{ formatPrice(totalAmount) }}</h3>
            <p>Valor total</p>
          </div>
        </div>
      </div>

      <!-- Botón para mostrar/ocultar filtros -->
      <div class="filter-toggle-section" v-if="requests.length > 0">
        <button 
          class="btn-toggle-filters"
          @click="toggleFilters"
          :class="{ active: showFilters }"
        >
          <span class="toggle-icon">{{ showFilters ? '▲' : '▼' }}</span>
          <span>{{ showFilters ? 'Ocultar filtros' : 'Mostrar filtros' }}</span>
          <span class="filter-count" v-if="activeFilterCount > 0">
            ({{ activeFilterCount }})
          </span>
        </button>
      </div>

      <!-- Filtros expandibles -->
      <div class="filters-collapsible" v-if="showFilters && requests.length > 0">
        <div class="filters-section">
          <div class="filter-group">
            <label for="status-filter">Filtrar por estado:</label>
            <select 
              id="status-filter" 
              v-model="filterStatus"
              class="filter-select"
            >
              <option value="all">Todos los estados</option>
              <option value="pending">En espera</option>
              <option value="accepted">Aceptados</option>
              <option value="in_progress">En progreso</option>
              <option value="on_the_way">En camino</option>
              <option value="arrived">Ha llegado</option>
              <option value="completed">Completados</option>
              <option value="cancelled">Cancelados</option>
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
              <option value="pending">Pendiente</option>
              <option value="paid">Pagado</option>
              <option value="failed">Fallido</option>
              <option value="refunded">Reembolsado</option>
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
      </div>

      <!-- Requests Grid -->
      <div v-if="filteredRequests.length > 0" class="requests-grid">
        <div 
          v-for="request in filteredRequests" 
          :key="request.id" 
          class="request-card-modern"
          @click="$emit('open-live-tracking', request)"
        >
          <!-- Badge de estado -->
          <div class="card-badge" :class="getStatusBadgeClass(request.status)">
            {{ getStatusLabel(request.status) }}
          </div>

          <!-- Badge de pago -->
          <div class="payment-badge">
            <PaymentPill :status="request.payment_status" />
          </div>
          
          <!-- Imagen del servicio -->
          <div class="card-image">
            <img
              :src="getServiceImage(request)"
              :alt="sanitize(request.service_title || 'Servicio')"
              @error="handleImageError"
            />
            <div class="image-overlay"></div>
            <div class="tracking-badge" v-if="showTrackingBadge(request.status)">
              <span class="tracking-icon">📍</span>
              <span>Seguimiento disponible</span>
            </div>
          </div>

          <!-- Contenido de la tarjeta -->
          <div class="card-content">
            <!-- Header con fecha y referencia -->
            <div class="card-header">
              <span class="request-date">{{ formatDate(request.created_at) }}</span>
              <span class="request-ref" v-if="request.id">#{{ request.id }}</span>
            </div>

            <!-- Título y descripción -->
            <h3 class="request-title">{{ sanitize(request.service_title || 'Servicio Activo') }}</h3>
            <p class="request-description">{{ sanitize(request.service_description || 'Sin descripción') }}</p>

            <!-- Información del proveedor -->
            <div class="provider-section">
              <div class="provider-info">
                <img
                  :src="getProviderAvatar(request)"
                  :alt="sanitize(request.service_provider_name || 'Proveedor')"
                  class="provider-avatar"
                  @error="handleAvatarError"
                />
                <div class="provider-details">
                  <span class="provider-name">{{ sanitize(request.service_provider_name || 'Proveedor') }}</span>
                  <div class="provider-rating" v-if="request.provider_rating">
                    <span class="stars">⭐</span>
                    <span class="rating-value">{{ parseRating(request.provider_rating).toFixed(1) }}</span>
                  </div>
                </div>
              </div>
              
              <div class="provider-contact">
                <span class="contact-label">Contacto:</span>
                <span class="contact-info" v-if="request.provider_phone">{{ request.provider_phone }}</span>
                <span class="contact-info muted" v-else>No disponible</span>
              </div>
            </div>

            <!-- Timeline del estado -->
            <div class="status-timeline">
              <div class="timeline-steps">
                <div class="timeline-step" :class="{ active: isStepActive(request.status, 'pending') }">
                  <div class="step-icon">📝</div>
                  <div class="step-label">Solicitado</div>
                </div>
                <div class="timeline-step" :class="{ active: isStepActive(request.status, 'accepted') }">
                  <div class="step-icon">✅</div>
                  <div class="step-label">Aceptado</div>
                </div>
                <div class="timeline-step" :class="{ active: isStepActive(request.status, 'in_progress') }">
                  <div class="step-icon">🚀</div>
                  <div class="step-label">En progreso</div>
                </div>
                <div class="timeline-step" :class="{ active: isStepActive(request.status, 'completed') }">
                  <div class="step-icon">🏁</div>
                  <div class="step-label">Completado</div>
                </div>
              </div>
            </div>

            <!-- Footer con precio y acciones -->
            <div class="card-footer">
              <div class="price-section">
                <span class="price-label">Total:</span>
                <span class="price">${{ formatPriceValue(request.service_price) }}</span>
                <span class="price-unit" v-if="request.price_unit">/ {{ request.price_unit }}</span>
              </div>
              
              <div class="card-actions">
                <button 
                  class="btn-track"
                  @click.stop="$emit('open-live-tracking', request)"
                  :disabled="!showTrackingBadge(request.status)"
                  :class="{ disabled: !showTrackingBadge(request.status) }"
                >
                  <span class="btn-icon">📍</span>
                  Seguimiento
                </button>
                <!-- Botón de chat corregido -->
                <button 
                  class="btn-chat"
                  @click.stop="handleChatClick(request)"
                  :title="getChatButtonTitle(request)"
                  :disabled="!canChat(request)"
                  :class="{ disabled: !canChat(request) }"
                >
                  <span class="btn-icon">💬</span>
                  Chat
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div v-else class="empty-state">
        <div class="empty-icon">📋</div>
        <h3 v-if="hasActiveFilters">
          No hay solicitudes con estos filtros
        </h3>
        <h3 v-else>No tienes solicitudes activas</h3>
        
        <p v-if="filterStatus !== 'all'">
          No hay solicitudes con estado "{{ getFilterStatusLabel() }}"
        </p>
        <p v-else-if="filterPayment !== 'all'">
          No hay solicitudes con pago "{{ getFilterPaymentLabel() }}"
        </p>
        <p v-else>
          Cuando solicites un servicio, aparecerá aquí para que puedas hacerle seguimiento
        </p>
        
        <div class="empty-actions" v-if="hasActiveFilters">
          <button 
            class="btn-primary"
            @click="resetFilters"
          >
            Mostrar todas las solicitudes
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import PaymentPill from '@/components/PaymentPill.vue';
import { formatDate as formatDateUtil } from '@/utils/formatDate';

const STATUS_LABELS = {
  pending: 'En espera',
  accepted: 'Aceptado', 
  in_progress: 'En progreso',
  on_the_way: 'En camino',
  arrived: 'Ha llegado',
  completed: 'Completado',
  finalized: 'Finalizado',
  cancelled: 'Cancelado',
  rejected: 'Rechazado',
  busy: 'Ocupado',
  fallido: 'Fallido',
  inconcluso: 'Inconcluso'
};

const PAYMENT_LABELS = {
  pending: 'Pendiente',
  paid: 'Pagado',
  failed: 'Fallido',
  refunded: 'Reembolsado'
};

export default {
  name: 'SolicitudesActivasUsuario',
  components: { PaymentPill },
  props: {
    requests: { type: Array, required: true },
    loading: { type: Boolean, default: false }
  },
  emits: ['open-live-tracking', 'open-chat'],
  data() {
    return {
      filterStatus: 'all',
      filterPayment: 'all',
      sortBy: 'recent',
      showFilters: false
    }
  },
  computed: {
    pendingRequests() {
      return this.requests.filter(r => r.status === 'pending' || r.status === 'accepted').length;
    },
    inProgressRequests() {
      return this.requests.filter(r => 
        r.status === 'in_progress' || 
        r.status === 'on_the_way' || 
        r.status === 'arrived'
      ).length;
    },
    totalAmount() {
      return this.requests.reduce((sum, r) => {
        const price = this.parsePrice(r.service_price);
        return sum + price;
      }, 0);
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
          filtered.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
          break;
        case 'oldest':
          filtered.sort((a, b) => new Date(a.created_at) - new Date(b.created_at));
          break;
        case 'price-high':
          filtered.sort((a, b) => this.parsePrice(b.service_price) - this.parsePrice(a.service_price));
          break;
        case 'price-low':
          filtered.sort((a, b) => this.parsePrice(a.service_price) - this.parsePrice(b.service_price));
          break;
      }
      
      return filtered;
    },
    hasActiveFilters() {
      return this.filterStatus !== 'all' || this.filterPayment !== 'all';
    },
    activeFilterCount() {
      let count = 0;
      if (this.filterStatus !== 'all') count++;
      if (this.filterPayment !== 'all') count++;
      return count;
    }
  },
  methods: {
    sanitize(str) {
      if (!str || typeof str !== 'string') return '';
      const tempDiv = document.createElement('div');
      tempDiv.textContent = str;
      return tempDiv.innerHTML
        .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
        .replace(/on\w+="[^"]*"/g, '').replace(/on\w+='[^']*'/g, '')
        .replace(/javascript:/gi, '');
    },
    formatDate(date) {
      return formatDateUtil(date);
    },
    formatPrice(price) {
      return new Intl.NumberFormat('es-ES', {
        style: 'currency',
        currency: 'USD',
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
      }).format(price);
    },
    formatPriceValue(price) {
      const num = this.parsePrice(price);
      return num.toFixed(2);
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
        pending: 'status-pending',
        accepted: 'status-accepted',
        in_progress: 'status-in-progress',
        on_the_way: 'status-on-way',
        arrived: 'status-arrived',
        completed: 'status-completed',
        finalized: 'status-completed',
        cancelled: 'status-cancelled',
        rejected: 'status-rejected',
        busy: 'status-busy',
        fallido: 'status-failed',
        inconcluso: 'status-incomplete'
      };
      return classes[status] || 'status-default';
    },
   getServiceImage(request) {
  if (request.service_image_url) {
    if (request.service_image_url.startsWith('http')) {
      return request.service_image_url;
    } else if (request.service_image_url.startsWith('/uploads/')) {
      return getImageUrl(request.service_image_url);
    }
    return getImageUrl(`/uploads/${request.service_image_url}`);
  }
  return 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=300&h=200&fit=crop&crop=entropy';
},
  getProviderAvatar(request) {
  if (request.provider_avatar_url) {
    if (request.provider_avatar_url.startsWith('http')) {
      return request.provider_avatar_url;
    }
    return getImageUrl(request.provider_avatar_url, 'avatar');
  }
  return '/img/default-provider.png';
},
handleImageError(event) {
  event.target.src = 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=300&h=200&fit=crop&crop=entropy';
},
    handleAvatarError(event) {
      event.target.src = '/img/default-provider.png';
    },
    showTrackingBadge(status) {
      const trackableStatuses = ['accepted', 'in_progress', 'on_the_way', 'arrived'];
      return trackableStatuses.includes(status);
    },
    isStepActive(currentStatus, stepStatus) {
      const statusOrder = {
        pending: 1,
        accepted: 2,
        in_progress: 3,
        on_the_way: 3.5,
        arrived: 3.7,
        completed: 4,
        finalized: 4
      };
      
      const currentStep = statusOrder[currentStatus] || 0;
      const targetStep = statusOrder[stepStatus] || 0;
      
      return currentStep >= targetStep;
    },
    // Métodos nuevos para el chat
    canChat(request) {
      // Solo se puede chatear si la solicitud está aceptada o en progreso
      const chatStatuses = ['accepted', 'in_progress', 'on_the_way', 'arrived'];
      return chatStatuses.includes(request.status);
    },
    getChatButtonTitle(request) {
      if (!this.canChat(request)) {
        return 'Chat disponible cuando la solicitud sea aceptada';
      }
      return `Chat con ${request.service_provider_name || 'el proveedor'}`;
    },
    handleChatClick(request) {
      if (!this.canChat(request)) {
        // Mostrar mensaje informativo
        this.showChatNotAvailableMessage();
        return;
      }
      
      // Emitir evento para abrir el chat
      this.$emit('open-chat', {
        providerId: request.provider_id || request.service_provider_id,
        providerName: request.service_provider_name,
        requestId: request.id,
        canChat: true
      });
    },
    showChatNotAvailableMessage() {
      // Puedes implementar un toast o alerta aquí
      console.log('Chat disponible cuando la solicitud sea aceptada');
      // Ejemplo con alerta:
      // this.$swal.fire({
      //   icon: 'info',
      //   title: 'Chat no disponible',
      //   text: 'Podrás chatear con el proveedor una vez que acepte tu solicitud'
      // });
    },
    toggleFilters() {
      this.showFilters = !this.showFilters;
    },
    resetFilters() {
      this.filterStatus = 'all';
      this.filterPayment = 'all';
      this.sortBy = 'recent';
      this.showFilters = false;
    }
  }
};
</script>

<style scoped>
.solicitudes-container {
  max-width: 1400px;
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

/* Stats Summary - MEJORADO para móvil */
.stats-summary {
  display: grid;
  grid-template-columns: repeat(4, 1fr); /* Siempre 4 columnas */
  gap: 16px;
  margin-bottom: 32px;
}

.stat-item {
  background: white;
  padding: 20px 16px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  gap: 16px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
  transition: transform 0.3s;
  min-height: 90px;
}

.stat-item:hover {
  transform: translateY(-5px);
}

.stat-icon {
  font-size: 1.8rem;
  width: 50px;
  height: 50px;
  min-width: 50px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 12px;
  color: white;
}

.stat-content {
  flex: 1;
  min-width: 0; /* Permite que el texto se ajuste */
}

.stat-content h3 {
  font-size: 1.5rem;
  color: #2d3436;
  margin-bottom: 4px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.stat-content p {
  color: #636e72;
  font-size: 0.85rem;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

/* Botón para mostrar/ocultar filtros */
.filter-toggle-section {
  margin-bottom: 20px;
  display: flex;
  justify-content: center;
}

.btn-toggle-filters {
  background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%);
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 10px;
  cursor: pointer;
  font-weight: 600;
  font-size: 0.95rem;
  display: flex;
  align-items: center;
  gap: 10px;
  transition: all 0.3s;
  box-shadow: 0 4px 12px rgba(116, 185, 255, 0.3);
}

.btn-toggle-filters:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 18px rgba(116, 185, 255, 0.4);
}

.btn-toggle-filters.active {
  background: linear-gradient(135deg, #0984e3 0%, #074b8a 100%);
}

.toggle-icon {
  font-size: 0.9rem;
  transition: transform 0.3s;
}

.btn-toggle-filters.active .toggle-icon {
  transform: rotate(180deg);
}

.filter-count {
  background: rgba(255, 255, 255, 0.2);
  padding: 2px 8px;
  border-radius: 12px;
  font-size: 0.8rem;
}

/* Filtros expandibles */
.filters-collapsible {
  background: white;
  border-radius: 16px;
  margin-bottom: 32px;
  overflow: hidden;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  animation: slideDown 0.3s ease-out;
}

@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-10px);
    max-height: 0;
  }
  to {
    opacity: 1;
    transform: translateY(0);
    max-height: 500px;
  }
}

.filters-section {
  padding: 24px;
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 24px;
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

.btn-reset-filters:disabled:hover {
  background: #dfe6e9;
  transform: none;
}

/* El resto del CSS se mantiene IGUAL... */

/* Requests Grid */
.requests-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 32px;
  margin-bottom: 40px;
}

.request-card-modern {
  background: white;
  border-radius: 20px;
  overflow: hidden;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
  transition: all 0.4s;
  position: relative;
  border: 1px solid #f1f2f6;
  cursor: pointer;
}

.request-card-modern:hover {
  transform: translateY(-10px);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
}

/* Badges */
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

.status-pending { background: linear-gradient(135deg, #fdcb6e 0%, #e17055 100%); }
.status-accepted { background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%); }
.status-in-progress { background: linear-gradient(135deg, #a29bfe 0%, #6c5ce7 100%); }
.status-on-way { background: linear-gradient(135deg, #fd79a8 0%, #e84393 100%); }
.status-arrived { background: linear-gradient(135deg, #81ecec 0%, #00cec9 100%); }
.status-completed { background: linear-gradient(135deg, #00b894 0%, #00a085 100%); }
.status-cancelled { background: linear-gradient(135deg, #636e72 0%, #2d3436 100%); }
.status-rejected { background: linear-gradient(135deg, #ff7675 0%, #d63031 100%); }
.status-busy { background: linear-gradient(135deg, #fab1a0 0%, #e17055 100%); }
.status-failed { background: linear-gradient(135deg, #ff7675 0%, #d63031 100%); }
.status-incomplete { background: linear-gradient(135deg, #fdcb6e 0%, #f39c12 100%); }
.status-default { background: linear-gradient(135deg, #b2bec3 0%, #636e72 100%); }

.payment-badge {
  position: absolute;
  top: 16px;
  right: 16px;
  z-index: 2;
}

/* Card Image */
.card-image {
  position: relative;
  height: 200px;
  overflow: hidden;
}

.card-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.5s;
}

.request-card-modern:hover .card-image img {
  transform: scale(1.05);
}

.image-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(to bottom, transparent 50%, rgba(0,0,0,0.3));
}

.tracking-badge {
  position: absolute;
  bottom: 16px;
  left: 50%;
  transform: translateX(-50%);
  background: rgba(255, 255, 255, 0.95);
  padding: 8px 16px;
  border-radius: 20px;
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.85rem;
  font-weight: 600;
  color: #2d3436;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  z-index: 1;
}

.tracking-icon {
  font-size: 1rem;
}

/* Card Content */
.card-content {
  padding: 24px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.request-date {
  color: #636e72;
  font-size: 0.85rem;
}

.request-ref {
  background: #dfe6e9;
  color: #2d3436;
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: 600;
}

.request-title {
  font-size: 1.4rem;
  color: #2d3436;
  margin-bottom: 12px;
  line-height: 1.3;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.request-description {
  color: #636e72;
  font-size: 0.95rem;
  line-height: 1.5;
  margin-bottom: 20px;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

/* Provider Section */
.provider-section {
  margin-bottom: 24px;
  padding: 16px;
  background: #f8f9fa;
  border-radius: 12px;
}

.provider-info {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
}

.provider-avatar {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  object-fit: cover;
  border: 3px solid white;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
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

.provider-rating {
  display: flex;
  align-items: center;
  gap: 4px;
}

.stars {
  color: #fdcb6e;
}

.rating-value {
  font-weight: 600;
  color: #636e72;
  font-size: 0.9rem;
}

.provider-contact {
  display: flex;
  align-items: center;
  gap: 8px;
  padding-top: 12px;
  border-top: 1px solid #dfe6e9;
}

.contact-label {
  font-weight: 600;
  color: #2d3436;
  font-size: 0.9rem;
}

.contact-info {
  color: #3498db;
  font-weight: 600;
}

.contact-info.muted {
  color: #b2bec3;
  font-style: italic;
}

/* Status Timeline */
.status-timeline {
  margin-bottom: 24px;
  padding: 16px;
  background: #f8f9fa;
  border-radius: 12px;
}

.timeline-steps {
  display: flex;
  justify-content: space-between;
  position: relative;
}

.timeline-steps::before {
  content: '';
  position: absolute;
  top: 24px;
  left: 10%;
  right: 10%;
  height: 3px;
  background: #dfe6e9;
  z-index: 0;
}

.timeline-step {
  display: flex;
  flex-direction: column;
  align-items: center;
  position: relative;
  z-index: 1;
  flex: 1;
}

.timeline-step.active .step-icon {
  background: #3498db;
  color: white;
  transform: scale(1.1);
  box-shadow: 0 4px 12px rgba(52, 152, 219, 0.3);
}

.step-icon {
  width: 48px;
  height: 48px;
  background: #dfe6e9;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.2rem;
  margin-bottom: 8px;
  transition: all 0.3s;
}

.step-label {
  font-size: 0.8rem;
  color: #636e72;
  text-align: center;
  font-weight: 600;
}

.timeline-step.active .step-label {
  color: #3498db;
}

/* Card Footer */
.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 20px;
  border-top: 1px solid #f1f2f6;
}

.price-section {
  display: flex;
  align-items: baseline;
  gap: 6px;
}

.price-label {
  color: #636e72;
  font-size: 0.9rem;
}

.price {
  font-size: 1.8rem;
  font-weight: 700;
  color: #00b894;
}

.price-unit {
  color: #636e72;
  font-size: 0.9rem;
}

.card-actions {
  display: flex;
  gap: 10px;
}

.btn-track, .btn-chat {
  display: flex;
  align-items: center;
  gap: 8px;
  border: none;
  padding: 10px 16px;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  font-size: 0.85rem;
  transition: all 0.3s;
  white-space: nowrap;
}

.btn-track {
  background: #3498db;
  color: white;
}

.btn-track:hover:not(.disabled) {
  background: #2980b9;
  transform: translateY(-2px);
}

.btn-track.disabled {
  background: #b2bec3;
  cursor: not-allowed;
  opacity: 0.6;
}

/* Botón de chat MEJORADO */
.btn-chat {
  background: #00b894;
  color: white;
  position: relative;
}

.btn-chat:hover:not(.disabled) {
  background: #00a085;
  transform: translateY(-2px);
}

.btn-chat.disabled {
  background: #dfe6e9;
  color: #b2bec3;
  cursor: not-allowed;
  opacity: 0.7;
}

.btn-chat.disabled:hover {
  transform: none;
  background: #dfe6e9;
}

.btn-icon {
  font-size: 1rem;
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

/* Responsive MEJORADO */
@media (max-width: 1200px) {
  .requests-grid {
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  }
  
  .stats-summary {
    grid-template-columns: repeat(4, 1fr); /* Mantiene 4 columnas */
  }
}

@media (max-width: 992px) {
  .stats-summary {
    grid-template-columns: repeat(2, 1fr); /* 2 columnas en tablet */
    gap: 12px;
  }
  
  .stat-item {
    padding: 16px 12px;
    gap: 12px;
  }
  
  .stat-icon {
    width: 45px;
    height: 45px;
    min-width: 45px;
    font-size: 1.6rem;
  }
  
  .stat-content h3 {
    font-size: 1.3rem;
  }
}

@media (max-width: 768px) {
  .solicitudes-container {
    padding: 0 12px;
  }
  
  .header-content h1 {
    font-size: 1.8rem;
  }
  
  .stats-summary {
    grid-template-columns: repeat(2, 1fr); /* 2 columnas en móvil */
    gap: 12px;
  }
  
  .stat-item {
    min-height: 85px;
  }
  
  .stat-icon {
    width: 40px;
    height: 40px;
    min-width: 40px;
    font-size: 1.4rem;
  }
  
  .stat-content h3 {
    font-size: 1.2rem;
  }
  
  .stat-content p {
    font-size: 0.8rem;
  }
  
  .filters-section {
    grid-template-columns: 1fr;
    padding: 20px;
    gap: 20px;
  }
  
  .requests-grid {
    grid-template-columns: 1fr;
    gap: 24px;
  }
  
  .card-footer {
    flex-direction: column;
    gap: 16px;
    align-items: stretch;
  }
  
  .card-actions {
    flex-direction: column;
    width: 100%;
  }
  
  .btn-track, .btn-chat {
    width: 100%;
    justify-content: center;
    padding: 12px;
  }
  
  .timeline-steps::before {
    left: 5%;
    right: 5%;
  }
  
  .step-label {
    font-size: 0.75rem;
  }
}

@media (max-width: 480px) {
  .header-content h1 {
    font-size: 1.6rem;
    flex-direction: column;
    gap: 8px;
  }
  
  .stats-summary {
    grid-template-columns: repeat(2, 1fr); /* Mantiene 2 columnas */
  }
  
  .stat-item {
    flex-direction: column;
    text-align: center;
    gap: 10px;
    padding: 12px 8px;
  }
  
  .stat-icon {
    margin: 0 auto;
  }
  
  .stat-content h3 {
    font-size: 1.3rem;
  }
  
  .timeline-step {
    min-width: 60px;
  }
  
  .step-icon {
    width: 36px;
    height: 36px;
    font-size: 1rem;
  }
  
  .price {
    font-size: 1.5rem;
  }
  
  .btn-toggle-filters {
    width: 100%;
    justify-content: center;
  }
}

@media (max-width: 360px) {
  .stats-summary {
    grid-template-columns: repeat(2, 1fr); /* Mantiene 2 columnas incluso en móviles muy pequeños */
  }
  
  .stat-content h3 {
    font-size: 1.1rem;
  }
  
  .stat-content p {
    font-size: 0.75rem;
  }
}
</style>
