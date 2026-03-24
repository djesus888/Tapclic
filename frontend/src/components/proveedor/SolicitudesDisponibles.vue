<template>
  <div class="solicitudes-container">
    <!-- Loading State -->
    <div v-if="loading" class="loading-state">
      <div class="spinner"></div>
      <p class="loading-text">{{ $t('loading') }}…</p>
    </div>

    <!-- Empty State -->
    <div v-else-if="!requests.length" class="empty-state">
      <div class="empty-icon">📋</div>
      <h3 class="empty-title">{{ $t('no_available_requests') }}</h3>
      <p class="empty-description">No hay solicitudes disponibles en este momento</p>
    </div>

    <!-- Solicitudes Grid -->
    <div v-else class="solicitudes-grid">
      <div
        v-for="req in requests"
        :key="`${req.id}-${$i18n.locale}`"
        class="solicitud-card"
      >
        <!-- Card Badge -->
        <div class="card-badge">
          <PaymentPill :status="req.payment_status" />
        </div>

        <!-- Card Content -->
        <div class="card-content">
          <!-- Header -->
          <div class="card-header">
            <h3 class="service-title">{{ sanitize(req.service_title) }}</h3>
            <div class="price-tag">
              {{ formatCurrency(req.service_price) }}
            </div>
          </div>

          <!-- Service Description -->
          <p class="service-description">{{ sanitize(req.service_description) }}</p>

          <!-- Service Details -->
          <div class="service-details">
            <div class="detail-item">
              <span class="detail-icon">📍</span>
              <span class="detail-text">{{ req.service_location }}</span>
            </div>
            <div class="detail-item">
              <span class="detail-icon">👤</span>
              <span class="detail-text">{{ sanitize(req.service_provider_name) }}</span>
            </div>
          </div>

          <!-- Additional Details -->
          <div 
            v-if="req.additional_details?.trim()" 
            class="additional-details"
          >
            <div class="alert-icon">🔔</div>
            <div class="alert-content">
              <span class="alert-title">Nota adicional:</span>
              <p class="alert-text">{{ req.additional_details }}</p>
            </div>
          </div>

          <!-- Action Buttons -->
          <div class="action-buttons">
            <button 
              class="btn-accept"
              @click="$emit('accept', req.id)"
              :title="$t('accept')"
            >
              <span class="btn-icon">✓</span>
              <span class="btn-text">{{ $t('accept') }}</span>
            </button>
            
            <button 
              class="btn-reject"
              @click="$emit('reject', req.id)"
              :title="$t('reject')"
            >
              <span class="btn-icon">✕</span>
              <span class="btn-text">{{ $t('reject') }}</span>
            </button>
            
            <button 
              class="btn-busy"
              @click="$emit('busy', req.id)"
              :title="$t('busy')"
            >
              <span class="btn-icon">⏰</span>
              <span class="btn-text">{{ $t('busy') }}</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import PaymentPill from '@/components/PaymentPill.vue';

export default {
  name: 'SolicitudesDisponibles',
  components: { PaymentPill },
  props: {
    requests: { type: Array, required: true },
    loading: { type: Boolean, default: false }
  },
  emits: ['accept', 'reject', 'busy'],
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
      const locale = this.$i18n.locale.value || 'es';
      return new Intl.NumberFormat(locale, { style: 'currency', currency: 'USD' }).format(amount || 0);
    }
  }
};
</script>

<style scoped>
.solicitudes-container {
  width: 100%;
  min-height: 400px;
}

/* Loading State */
.loading-state {
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

.loading-text {
  color: #636e72;
  font-size: 1.1rem;
  font-weight: 500;
}

/* Empty State */
.empty-state {
  text-align: center;
  padding: 80px 20px;
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  border-radius: 20px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
  margin: 20px 0;
}

.empty-icon {
  font-size: 80px;
  margin-bottom: 24px;
  animation: float 3s ease-in-out infinite;
}

@keyframes float {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-10px); }
}

.empty-title {
  color: #2d3436;
  margin-bottom: 12px;
  font-size: 1.8rem;
  font-weight: 700;
}

.empty-description {
  color: #636e72;
  font-size: 1.1rem;
  max-width: 400px;
  margin: 0 auto;
  line-height: 1.5;
}

/* Solicitudes Grid */
.solicitudes-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(380px, 1fr));
  gap: 30px;
  padding: 10px 0;
}

.solicitud-card {
  background: white;
  border-radius: 20px;
  overflow: hidden;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
  transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
  border: 1px solid #f1f2f6;
  position: relative;
}

.solicitud-card:hover {
  transform: translateY(-10px);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
}

.card-badge {
  position: absolute;
  top: 16px;
  right: 16px;
  z-index: 2;
}

.card-content {
  padding: 24px;
}

/* Card Header */
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 16px;
  gap: 15px;
}

.service-title {
  font-size: 1.4rem;
  color: #2d3436;
  font-weight: 700;
  line-height: 1.3;
  flex: 1;
  margin: 0;
}

.price-tag {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
  color: white;
  padding: 8px 16px;
  border-radius: 12px;
  font-weight: 700;
  font-size: 1.2rem;
  white-space: nowrap;
  box-shadow: 0 4px 12px rgba(0, 184, 148, 0.3);
}

/* Service Description */
.service-description {
  color: #636e72;
  font-size: 0.95rem;
  line-height: 1.5;
  margin-bottom: 20px;
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

/* Service Details */
.service-details {
  display: flex;
  flex-direction: column;
  gap: 12px;
  margin-bottom: 20px;
  padding: 16px;
  background: #f8f9fa;
  border-radius: 12px;
  border-left: 4px solid #3498db;
}

.detail-item {
  display: flex;
  align-items: center;
  gap: 10px;
}

.detail-icon {
  font-size: 1.1rem;
  width: 24px;
  text-align: center;
}

.detail-text {
  color: #2d3436;
  font-size: 0.95rem;
  font-weight: 500;
}

/* Additional Details */
.additional-details {
  display: flex;
  gap: 12px;
  padding: 16px;
  background: linear-gradient(135deg, #fff9db 0%, #fff3bf 100%);
  border-radius: 12px;
  margin-bottom: 24px;
  border: 1px solid #ffd43b;
  animation: pulse-glow 2s infinite;
}

@keyframes pulse-glow {
  0%, 100% { box-shadow: 0 0 0 rgba(255, 212, 59, 0); }
  50% { box-shadow: 0 0 0 4px rgba(255, 212, 59, 0.2); }
}

.alert-icon {
  font-size: 1.5rem;
  color: #f59f00;
  flex-shrink: 0;
  margin-top: 2px;
}

.alert-content {
  flex: 1;
}

.alert-title {
  display: block;
  color: #e67700;
  font-weight: 700;
  font-size: 0.9rem;
  margin-bottom: 4px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.alert-text {
  color: #5c3c00;
  font-size: 0.9rem;
  line-height: 1.5;
  margin: 0;
  white-space: pre-wrap;
  word-break: break-word;
}

/* Action Buttons */
.action-buttons {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
  margin-top: 10px;
}

.action-buttons button {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 6px;
  padding: 14px 8px;
  border: none;
  border-radius: 12px;
  cursor: pointer;
  font-weight: 600;
  font-size: 0.9rem;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.action-buttons button:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);
}

.action-buttons button:active {
  transform: translateY(-1px);
}

.btn-icon {
  font-size: 1.4rem;
  font-weight: 700;
}

.btn-text {
  font-size: 0.8rem;
}

/* Accept Button */
.btn-accept {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
  color: white;
}

.btn-accept:hover {
  background: linear-gradient(135deg, #00a085 0%, #008b74 100%);
  box-shadow: 0 8px 20px rgba(0, 184, 148, 0.3);
}

/* Reject Button */
.btn-reject {
  background: linear-gradient(135deg, #ff7675 0%, #d63031 100%);
  color: white;
}

.btn-reject:hover {
  background: linear-gradient(135deg, #d63031 0%, #c0392b 100%);
  box-shadow: 0 8px 20px rgba(255, 118, 117, 0.3);
}

/* Busy Button */
.btn-busy {
  background: linear-gradient(135deg, #fdcb6e 0%, #e17055 100%);
  color: white;
}

.btn-busy:hover {
  background: linear-gradient(135deg, #e17055 0%, #d63031 100%);
  box-shadow: 0 8px 20px rgba(253, 203, 110, 0.3);
}

/* Responsive Design */
@media (max-width: 1200px) {
  .solicitudes-grid {
    grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  }
}

@media (max-width: 768px) {
  .solicitudes-grid {
    grid-template-columns: 1fr;
    gap: 20px;
  }
  
  .card-header {
    flex-direction: column;
    align-items: stretch;
    gap: 12px;
  }
  
  .price-tag {
    align-self: flex-start;
  }
  
  .action-buttons {
    grid-template-columns: 1fr;
    gap: 10px;
  }
  
  .action-buttons button {
    flex-direction: row;
    justify-content: flex-start;
    padding: 16px 20px;
    gap: 12px;
  }
  
  .btn-icon {
    font-size: 1.2rem;
  }
  
  .btn-text {
    font-size: 0.9rem;
  }
}

@media (max-width: 480px) {
  .solicitud-card {
    border-radius: 16px;
  }
  
  .card-content {
    padding: 20px;
  }
  
  .service-title {
    font-size: 1.2rem;
  }
  
  .price-tag {
    font-size: 1rem;
    padding: 6px 12px;
  }
  
  .empty-state {
    padding: 60px 16px;
  }
  
  .empty-title {
    font-size: 1.5rem;
  }
  
  .empty-description {
    font-size: 1rem;
  }
}
</style>
