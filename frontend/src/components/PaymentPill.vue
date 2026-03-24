<template>
  <span
    class="payment-pill"
    :class="[pillClass, status]"
    :title="tooltipText"
  >
    <span class="pill-icon">{{ pillIcon }}</span>
    <span class="pill-text">{{ label }}</span>
  </span>
</template>

<script>
export default {
  name: 'PaymentPill',
  props: { status: { type: String, default: '' } },
  computed: {
    label() {
      const map = {
        pending: this.$t('pending'),
        paid: this.$t('paid'),
        cancelled: this.$t('cancelled'),
        rejected: this.$t('rejected'),
        verifying: this.$t('verifying'),
        refunded: this.$t('refunded'),
        partially_refunded: this.$t('partially_refunded'),
        disputed: this.$t('disputed'),
        expired: this.$t('expired'),
        confirmed: this.$t('confirmed'),
        failed: this.$t('failed'),
        processing: this.$t('processing'),
        cancelled_by_user: this.$t('cancelled_by_user'),
        cancelled_by_provider: this.$t('cancelled_by_provider'),
        on_hold: this.$t('payment.on_hold')
      }
      return map[this.status] || this.$t('payment.unknown')
    },
    
    pillIcon() {
      const iconMap = {
        pending: '⏳',
        paid: '✅',
        cancelled: '❌',
        rejected: '🚫',
        verifying: '🔍',
        refunded: '↩️',
        partially_refunded: '↪️',
        disputed: '⚖️',
        expired: '⌛',
        confirmed: '✓',
        failed: '❌',
        processing: '⚙️',
        cancelled_by_user: '👤❌',
        cancelled_by_provider: '👨‍💼❌',
        on_hold: '⏸️'
      }
      return iconMap[this.status] || '❓'
    },
    
    tooltipText() {
      const tooltips = {
        pending: 'Pago pendiente de confirmación',
        paid: 'Pago completado exitosamente',
        cancelled: 'Pago cancelado',
        rejected: 'Pago rechazado',
        verifying: 'Verificación en proceso',
        refunded: 'Pago reembolsado totalmente',
        partially_refunded: 'Pago reembolsado parcialmente',
        disputed: 'Pago en disputa',
        expired: 'Tiempo de pago expirado',
        confirmed: 'Pago confirmado',
        failed: 'Pago fallido',
        processing: 'Procesando pago',
        cancelled_by_user: 'Cancelado por el cliente',
        cancelled_by_provider: 'Cancelado por el proveedor',
        on_hold: 'Pago en espera'
      }
      return tooltips[this.status] || 'Estado desconocido'
    },
    
    pillClass() {
      // Mantengo las clases base y ahora añado estilos personalizados
      const baseClass = 'payment-pill-base'
      return baseClass
    }
  }
}
</script>

<style scoped>
.payment-pill {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 6px 14px;
  border-radius: 50px;
  font-size: 0.8rem;
  font-weight: 700;
  letter-spacing: 0.3px;
  text-transform: uppercase;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  cursor: default;
  user-select: none;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  border: 2px solid transparent;
  min-width: 100px;
  justify-content: center;
  backdrop-filter: blur(10px);
  animation: fadeIn 0.5s ease-out;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(-5px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.pill-icon {
  font-size: 1rem;
  display: flex;
  align-items: center;
  justify-content: center;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.1); }
}

.pill-text {
  font-size: 0.75rem;
  font-weight: 800;
}

/* Estados de pago con gradientes y efectos */

/* PENDING */
.payment-pill.pending {
  background: linear-gradient(135deg, #f6e05e 0%, #d69e2e 100%);
  color: #5c3c00;
  border-color: #ecc94b;
}

.payment-pill.pending:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(214, 158, 46, 0.4);
  background: linear-gradient(135deg, #ecc94b 0%, #b7791f 100%);
}

/* PAID */
.payment-pill.paid {
  background: linear-gradient(135deg, #68d391 0%, #38a169 100%);
  color: #ffffff;
  border-color: #48bb78;
  animation: glow-green 2s infinite alternate;
}

@keyframes glow-green {
  from {
    box-shadow: 0 2px 8px rgba(56, 161, 105, 0.4);
  }
  to {
    box-shadow: 0 4px 16px rgba(56, 161, 105, 0.6);
  }
}

.payment-pill.paid:hover {
  transform: translateY(-2px);
  background: linear-gradient(135deg, #48bb78 0%, #2f855a 100%);
}

/* CANCELLED */
.payment-pill.cancelled {
  background: linear-gradient(135deg, #fc8181 0%, #e53e3e 100%);
  color: #ffffff;
  border-color: #f56565;
}

.payment-pill.cancelled:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(229, 62, 62, 0.4);
  background: linear-gradient(135deg, #f56565 0%, #c53030 100%);
}

/* REJECTED */
.payment-pill.rejected {
  background: linear-gradient(135deg, #a0aec0 0%, #718096 100%);
  color: #ffffff;
  border-color: #90a4ae;
}

.payment-pill.rejected:hover {
  transform: translateY(-2px);
  background: linear-gradient(135deg, #718096 0%, #4a5568 100%);
}

/* VERIFYING */
.payment-pill.verifying {
  background: linear-gradient(135deg, #ed8936 0%, #dd6b20 100%);
  color: #ffffff;
  border-color: #ed8936;
  animation: pulse-orange 1.5s infinite;
}

@keyframes pulse-orange {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.8; }
}

.payment-pill.verifying:hover {
  background: linear-gradient(135deg, #dd6b20 0%, #c05621 100%);
}

/* REFUNDED */
.payment-pill.refunded {
  background: linear-gradient(135deg, #d6bcfa 0%, #9f7aea 100%);
  color: #4c1d95;
  border-color: #b794f4;
}

.payment-pill.refunded:hover {
  transform: translateY(-2px);
  background: linear-gradient(135deg, #b794f4 0%, #805ad5 100%);
}

/* PARTIALLY REFUNDED */
.payment-pill.partially_refunded {
  background: linear-gradient(135deg, #e9d8fd 0%, #d6bcfa 100%);
  color: #553c9a;
  border-color: #d6bcfa;
  border-style: dashed;
}

.payment-pill.partially_refunded:hover {
  background: linear-gradient(135deg, #d6bcfa 0%, #b794f4 100%);
}

/* DISPUTED */
.payment-pill.disputed {
  background: linear-gradient(135deg, #fed7d7 0%, #fc8181 100%);
  color: #9b2c2c;
  border-color: #feb2b2;
  animation: shake 0.5s infinite;
}

@keyframes shake {
  0%, 100% { transform: translateX(0); }
  25% { transform: translateX(-2px); }
  75% { transform: translateX(2px); }
}

.payment-pill.disputed:hover {
  background: linear-gradient(135deg, #fc8181 0%, #e53e3e 100%);
  color: white;
}

/* EXPIRED */
.payment-pill.expired {
  background: linear-gradient(135deg, #e2e8f0 0%, #a0aec0 100%);
  color: #4a5568;
  border-color: #cbd5e0;
  text-decoration: line-through;
}

.payment-pill.expired:hover {
  background: linear-gradient(135deg, #cbd5e0 0%, #a0aec0 100%);
}

/* CONFIRMED */
.payment-pill.confirmed {
  background: linear-gradient(135deg, #c6f6d5 0%, #68d391 100%);
  color: #22543d;
  border-color: #9ae6b4;
}

.payment-pill.confirmed:hover {
  background: linear-gradient(135deg, #9ae6b4 0%, #48bb78 100%);
}

/* FAILED */
.payment-pill.failed {
  background: linear-gradient(135deg, #fed7e2 0%, #fbb6ce 100%);
  color: #9d174d;
  border-color: #f687b3;
  animation: heartbeat 1.5s infinite;
}

@keyframes heartbeat {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.05); }
}

.payment-pill.failed:hover {
  background: linear-gradient(135deg, #fbb6ce 0%, #f687b3 100%);
}

/* PROCESSING */
.payment-pill.processing {
  background: linear-gradient(135deg, #bee3f8 0%, #63b3ed 100%);
  color: #2c5282;
  border-color: #90cdf4;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.payment-pill.processing:hover {
  background: linear-gradient(135deg, #90cdf4 0%, #4299e1 100%);
}

/* CANCELLED BY USER */
.payment-pill.cancelled_by_user {
  background: linear-gradient(135deg, #e2e8f0 0%, #cbd5e0 100%);
  color: #4a5568;
  border-color: #a0aec0;
}

.payment-pill.cancelled_by_user:hover {
  background: linear-gradient(135deg, #cbd5e0 0%, #a0aec0 100%);
}

/* CANCELLED BY PROVIDER */
.payment-pill.cancelled_by_provider {
  background: linear-gradient(135deg, #feebc8 0%, #f6ad55 100%);
  color: #9c4221;
  border-color: #fbd38d;
}

.payment-pill.cancelled_by_provider:hover {
  background: linear-gradient(135deg, #fbd38d 0%, #ed8936 100%);
}

/* ON HOLD */
.payment-pill.on_hold {
  background: linear-gradient(135deg, #fef3c7 0%, #f59e0b 100%);
  color: #92400e;
  border-color: #fbbf24;
  animation: breathing 2s infinite;
}

@keyframes breathing {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.05); }
}

.payment-pill.on_hold:hover {
  background: linear-gradient(135deg, #fbbf24 0%, #f59e0b 100%);
}

/* DEFAULT / UNKNOWN */
.payment-pill:not([class*="pending"]):not([class*="paid"]):not([class*="cancelled"]):not([class*="rejected"]):not([class*="verifying"]):not([class*="refunded"]):not([class*="partially_refunded"]):not([class*="disputed"]):not([class*="expired"]):not([class*="confirmed"]):not([class*="failed"]):not([class*="processing"]):not([class*="cancelled_by_user"]):not([class*="cancelled_by_provider"]):not([class*="on_hold"]) {
  background: linear-gradient(135deg, #e2e8f0 0%, #cbd5e0 100%);
  color: #4a5568;
  border-color: #a0aec0;
  opacity: 0.7;
}

/* Responsive adjustments */
@media (max-width: 768px) {
  .payment-pill {
    padding: 5px 10px;
    font-size: 0.7rem;
    min-width: 85px;
    gap: 4px;
  }
  
  .pill-icon {
    font-size: 0.9rem;
  }
  
  .pill-text {
    font-size: 0.65rem;
  }
}

@media (max-width: 480px) {
  .payment-pill {
    padding: 4px 8px;
    min-width: 70px;
    gap: 3px;
  }
  
  .pill-icon {
    font-size: 0.8rem;
  }
  
  .pill-text {
    font-size: 0.6rem;
    display: none; /* Ocultar texto en móviles muy pequeños */
  }
  
  .pill-text + .pill-icon {
    display: inline; /* Mostrar solo ícono */
  }
}

/* Efecto de brillo para estados importantes */
.payment-pill.paid::after,
.payment-pill.confirmed::after {
  content: '';
  position: absolute;
  top: -2px;
  left: -2px;
  right: -2px;
  bottom: -2px;
  background: inherit;
  border-radius: inherit;
  z-index: -1;
  filter: blur(8px);
  opacity: 0.4;
  animation: glow 2s infinite alternate;
}

@keyframes glow {
  from {
    opacity: 0.3;
  }
  to {
    opacity: 0.6;
  }
}
</style>
