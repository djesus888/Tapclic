<template>
  <!-- Modal Overlay -->
  <div
    v-if="isOpen"
    class="confirmation-modal-overlay"
    @click.self="closeModal"
  >
    <!-- Modal Content -->
    <div class="confirmation-modal-content">
      <!-- Header -->
      <div class="confirmation-modal-header">
        <div class="confirmation-header-badge">
          <span class="badge-icon">✅</span>
          <span class="badge-text">{{ $t('confirmServiceRequest') }}</span>
        </div>
        <button
          class="close-confirmation-button"
          @click="closeModal"
        >
          ✕
        </button>
      </div>

      <!-- Service Preview -->
      <div class="service-preview-card">
        <div class="service-preview-header">
          <h3 class="preview-title">{{ serviceDetails.title || serviceDetails.name || 'Servicio' }}</h3>
          <div class="preview-price" v-if="serviceDetails.price">
            <span class="price-currency">$</span>
            <span class="price-amount">{{ formattedPrice }}</span>
          </div>
        </div>
        
        <div class="service-preview-provider" v-if="providerName || providerAvatar">
          <img
            v-if="providerAvatar"
            :src="providerAvatar"
            :alt="providerName"
            class="preview-provider-avatar"
          />
          <div class="preview-provider-info" v-if="providerName">
            <span class="provider-name">{{ providerName }}</span>
            <div class="provider-rating" v-if="providerRating !== null">
              <span class="stars">
                <span v-for="n in 5" :key="n" class="star">
                  {{ n <= Math.floor(providerRating) ? '★' : '☆' }}
                </span>
              </span>
              <span class="rating-value">{{ formattedRating }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Expandable Details -->
      <div class="expandable-details-section">
        <div 
          class="expandable-header"
          :class="{ 'expanded': showDetails }"
          @click="showDetails = !showDetails"
        >
          <div class="expandable-title">
            <span class="details-icon">📋</span>
            <span>{{ $t('checkDetailsBeforeSending') }}</span>
          </div>
          <span class="expandable-arrow">{{ showDetails ? '▼' : '▶' }}</span>
        </div>
        
        <div v-if="showDetails" class="expandable-content">
          <div class="service-details-content">
            <template v-if="hasServiceDetails">
              <p>{{ serviceDetails.service_details || serviceDetails.description || serviceDetails.details }}</p>
            </template>
            <div
              v-else
              class="no-details-message"
            >
              <span class="no-details-icon">📄</span>
              <span>{{ $t('noServiceDetails') }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Additional Conditions -->
      <div class="conditions-section">
        <div class="conditions-toggle">
          <input
            id="addSpec"
            v-model="addSpec"
            type="checkbox"
            class="toggle-checkbox"
          />
          <label for="addSpec" class="toggle-label">
            <span class="toggle-icon">{{ addSpec ? '✓' : '+' }}</span>
            <span>{{ $t('add condition in service request.') }}</span>
          </label>
        </div>
        
        <div v-if="addSpec" class="conditions-input-section">
          <div class="input-header">
            <span class="input-label">Condiciones adicionales</span>
            <span class="char-counter">{{ specDetails.length }}/200</span>
          </div>
          <textarea
            v-model="specDetails"
            class="conditions-textarea"
            :placeholder="$t('additionalDetails')"
            maxlength="200"
            rows="4"
          />
          <div class="textarea-footer">
            <span class="hint-text">Describe cualquier requisito o condición especial</span>
          </div>
        </div>
      </div>

      <!-- Contract Agreement -->
      <div class="contract-section">
        <div class="contract-header">
          <span class="contract-icon">📜</span>
          <h4 class="contract-title">Términos del Contrato</h4>
        </div>
        <div class="contract-content">
          <p class="contract-text">
            Al confirmar este servicio aceptas las siguientes condiciones:
          </p>
          <ul class="contract-terms">
            <li>✅ El servicio será prestado según lo descrito</li>
            <li>✅ El pago se procesará al confirmar la solicitud</li>
            <li>✅ No habrá reembolso una vez iniciado el servicio</li>
            <li>✅ Ambos deben respetar los términos acordados</li>
            <li>✅ Cualquier modificación requiere acuerdo mutuo</li>
          </ul>
        </div>
        <div class="contract-agreement">
          <div class="agreement-checkbox">
            <input
              v-model="acceptedContract"
              type="checkbox"
              id="contractAccept"
              class="agreement-input"
            />
            <div class="custom-checkbox" :class="{ 'checked': acceptedContract }">
              <span v-if="acceptedContract" class="check-icon">✓</span>
            </div>
            <label for="contractAccept" class="agreement-label">
              Acepto las condiciones del servicio y contrato
            </label>
          </div>
        </div>
      </div>

      <!-- Action Buttons -->
      <div class="confirmation-actions">
        <button
          class="cancel-action-button"
          @click="closeModal"
        >
          <span class="button-icon">←</span>
          {{ $t('cancel') }}
        </button>
        <button
          class="confirm-action-button"
          :disabled="(!acceptedContract) || (addSpec && specDetails.length > 200)"
          @click="submitRequest"
        >
          <span class="button-icon">✅</span>
          {{ $t('confirm') }}
          <span class="button-subtext">Solicitar Servicio</span>
        </button>
      </div>

      <!-- Footer Note -->
      <div class="confirmation-footer">
        <p class="footer-note">
          <span class="note-icon">ℹ️</span>
          Tu solicitud será enviada al proveedor para confirmación.
        </p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, computed } from 'vue'

const props = defineProps({
  isOpen: { type: Boolean, default: false },
  serviceDetails: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['on-open-change', 'confirm'])

const addSpec = ref(false)
const specDetails = ref('')
const acceptedContract = ref(false)
const showDetails = ref(false)

// Computed properties seguras
const formattedPrice = computed(() => {
  const price = props.serviceDetails?.price
  if (price === null || price === undefined || price === '') {
    return '0.00'
  }
  
  // Convertir a número si es string
  const numPrice = typeof price === 'string' ? parseFloat(price) : Number(price)
  return isNaN(numPrice) ? '0.00' : numPrice.toFixed(2)
})

const providerName = computed(() => {
  return props.serviceDetails?.provider?.name || 
         props.serviceDetails?.provider_name || 
         props.serviceDetails?.user?.name ||
         'Proveedor'
})

const providerAvatar = computed(() => {
  const provider = props.serviceDetails?.provider
  const user = props.serviceDetails?.user

  if (provider?.avatar_url) {
    return getImageUrl(`/uploads/avatars/${provider.avatar_url}`)
  }
  if (provider?.avatar) {
    return getImageUrl(`/uploads/avatars/${provider.avatar}`)
  }
  if (user?.avatar_url) {
    return getImageUrl(`/uploads/avatars/${user.avatar_url}`)
  }
  if (user?.avatar) {
    return getImageUrl(`/uploads/avatars/${user.avatar}`)
  }
  return null // No mostrar avatar si no existe
})

const providerRating = computed(() => {
  const rating = props.serviceDetails?.provider?.rating ||
                props.serviceDetails?.user?.rating ||
                props.serviceDetails?.rating
  
  if (rating === null || rating === undefined || rating === '') {
    return null
  }
  
  // Si es string, convertir a número
  if (typeof rating === 'string') {
    const num = parseFloat(rating)
    return isNaN(num) ? null : num
  }
  
  // Si es número, asegurar que esté entre 0-5
  if (typeof rating === 'number') {
    return Math.min(Math.max(rating, 0), 5)
  }
  
  return null
})

const formattedRating = computed(() => {
  if (providerRating.value === null) return 'N/A'
  return providerRating.value.toFixed(1)
})

const hasServiceDetails = computed(() => {
  const details = props.serviceDetails?.service_details ||
                  props.serviceDetails?.description ||
                  props.serviceDetails?.details
  return details && details.trim().length > 0
})

// Methods
const closeModal = () => {
  emit('on-open-change', false)
  resetState()
}

const submitRequest = () => {
  if (!acceptedContract.value) {
    alert('Debes aceptar las condiciones del contrato.')
    return
  }
  
  if (addSpec.value && specDetails.value.length > 200) {
    alert('Las condiciones adicionales no pueden exceder 200 caracteres.')
    return
  }
  
  emit('confirm', {
    details: specDetails.value,
    contractAccepted: acceptedContract.value
  })
}

const resetState = () => {
  addSpec.value = false
  specDetails.value = ''
  acceptedContract.value = false
  showDetails.value = false
}

watch(() => props.isOpen, val => { 
  if (!val) resetState() 
})
</script>

<style>
/* Confirmation Modal Styles */

.confirmation-modal-overlay {
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
  padding: 16px;
  backdrop-filter: blur(4px);
}

.confirmation-modal-content {
  background: white;
  border-radius: 20px;
  width: 100%;
  max-width: 500px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 20px 60px rgba(0,0,0,0.3);
  animation: slideUp 0.3s ease-out;
}

@keyframes slideUp {
  from {
    transform: translateY(100px);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

/* Header */
.confirmation-modal-header {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
  padding: 20px;
  border-radius: 20px 20px 0 0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  color: white;
}

.confirmation-header-badge {
  display: flex;
  align-items: center;
  gap: 10px;
}

.badge-icon {
  font-size: 1.5rem;
}

.badge-text {
  font-weight: 600;
  font-size: 1.1rem;
}

.close-confirmation-button {
  background: rgba(255,255,255,0.2);
  border: none;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  color: white;
  font-size: 1.2rem;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background 0.3s;
}

.close-confirmation-button:hover {
  background: rgba(255,255,255,0.3);
}

/* Service Preview */
.service-preview-card {
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  margin: 20px;
  padding: 20px;
  border-radius: 16px;
  border: 1px solid #dfe6e9;
}

.service-preview-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding-bottom: 16px;
  border-bottom: 1px solid rgba(0,0,0,0.1);
}

.preview-title {
  font-size: 1.3rem;
  color: #2d3436;
  font-weight: 700;
  margin: 0;
}

.preview-price {
  display: flex;
  align-items: baseline;
  gap: 4px;
}

.price-currency {
  font-size: 1.2rem;
  color: #00b894;
  font-weight: 600;
}

.price-amount {
  font-size: 2rem;
  font-weight: 800;
  color: #2d3436;
}

.service-preview-provider {
  display: flex;
  align-items: center;
  gap: 16px;
}

.preview-provider-avatar {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid white;
  box-shadow: 0 4px 10px rgba(0,0,0,0.1);
}

.preview-provider-info {
  flex: 1;
}

.provider-name {
  font-weight: 600;
  color: #2d3436;
  display: block;
  margin-bottom: 4px;
  font-size: 1.1rem;
}

.provider-rating {
  display: flex;
  align-items: center;
  gap: 8px;
}

.stars {
  color: #fdcb6e;
  font-size: 1rem;
}

.rating-value {
  font-weight: 600;
  color: #636e72;
  font-size: 0.9rem;
}

/* Expandable Details */
.expandable-details-section {
  margin: 0 20px 20px;
  border: 1px solid #dfe6e9;
  border-radius: 12px;
  overflow: hidden;
}

.expandable-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  background: #f8f9fa;
  cursor: pointer;
  transition: background 0.3s;
}

.expandable-header:hover {
  background: #e9ecef;
}

.expandable-header.expanded {
  background: #e3f2fd;
  border-bottom: 1px solid #bbdefb;
}

.expandable-title {
  display: flex;
  align-items: center;
  gap: 10px;
  font-weight: 600;
  color: #2d3436;
}

.details-icon {
  font-size: 1.2rem;
}

.expandable-arrow {
  color: #636e72;
  font-size: 0.9rem;
  transition: transform 0.3s;
}

.expandable-header.expanded .expandable-arrow {
  transform: rotate(90deg);
}

.expandable-content {
  padding: 16px;
  background: white;
}

.service-details-content {
  color: #2d3436;
  line-height: 1.6;
  font-size: 0.95rem;
}

.no-details-message {
  display: flex;
  align-items: center;
  gap: 10px;
  color: #b2bec3;
  font-style: italic;
}

.no-details-icon {
  font-size: 1.2rem;
}

/* Conditions Section */
.conditions-section {
  margin: 0 20px 20px;
}

.conditions-toggle {
  margin-bottom: 16px;
}

.toggle-checkbox {
  display: none;
}

.toggle-label {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  background: #f8f9fa;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s;
  border: 2px solid transparent;
}

.toggle-label:hover {
  background: #e9ecef;
  border-color: #74b9ff;
}

.toggle-icon {
  width: 24px;
  height: 24px;
  background: #74b9ff;
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  transition: background 0.3s;
}

.toggle-checkbox:checked + .toggle-label .toggle-icon {
  background: #00b894;
}

.conditions-input-section {
  background: white;
  border: 1px solid #dfe6e9;
  border-radius: 12px;
  padding: 16px;
  margin-top: 12px;
  animation: fadeIn 0.3s ease-out;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(-10px); }
  to { opacity: 1; transform: translateY(0); }
}

.input-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.input-label {
  font-weight: 600;
  color: #2d3436;
  font-size: 0.95rem;
}

.char-counter {
  font-size: 0.8rem;
  color: #636e72;
  font-weight: 500;
}

.conditions-textarea {
  width: 100%;
  padding: 14px;
  border: 2px solid #dfe6e9;
  border-radius: 8px;
  font-size: 1rem;
  font-family: inherit;
  resize: vertical;
  transition: border-color 0.3s;
  line-height: 1.5;
}

.conditions-textarea:focus {
  outline: none;
  border-color: #74b9ff;
}

.conditions-textarea::placeholder {
  color: #b2bec3;
}

.textarea-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 8px;
}

.hint-text {
  font-size: 0.8rem;
  color: #636e72;
}

/* Contract Section */
.contract-section {
  margin: 0 20px 20px;
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  border-radius: 16px;
  padding: 20px;
  border: 1px solid #dfe6e9;
}

.contract-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
}

.contract-icon {
  font-size: 1.5rem;
}

.contract-title {
  font-size: 1.2rem;
  color: #2d3436;
  margin: 0;
  font-weight: 700;
}

.contract-content {
  margin-bottom: 20px;
}

.contract-text {
  color: #636e72;
  margin-bottom: 12px;
  font-size: 0.95rem;
  line-height: 1.5;
}

.contract-terms {
  list-style: none;
  padding: 0;
  margin: 0;
}

.contract-terms li {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 8px;
  color: #2d3436;
  font-size: 0.9rem;
}

.contract-agreement {
  background: white;
  padding: 16px;
  border-radius: 12px;
  border: 1px solid #dfe6e9;
}

.agreement-checkbox {
  display: flex;
  align-items: center;
  gap: 12px;
}

.agreement-input {
  display: none;
}

.custom-checkbox {
  width: 24px;
  height: 24px;
  border: 2px solid #b2bec3;
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.3s;
  flex-shrink: 0;
}

.custom-checkbox.checked {
  background: #00b894;
  border-color: #00b894;
}

.check-icon {
  color: white;
  font-weight: bold;
  font-size: 0.9rem;
}

.agreement-label {
  color: #2d3436;
  font-weight: 600;
  cursor: pointer;
  font-size: 0.95rem;
  line-height: 1.4;
}

/* Action Buttons */
.confirmation-actions {
  display: flex;
  gap: 16px;
  padding: 0 20px 20px;
}

.cancel-action-button {
  flex: 1;
  background: white;
  color: #636e72;
  border: 2px solid #dfe6e9;
  padding: 16px;
  border-radius: 12px;
  font-weight: 600;
  cursor: pointer;
  font-size: 1rem;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  transition: all 0.3s;
}

.cancel-action-button:hover {
  border-color: #3498db;
  color: #3498db;
  transform: translateY(-2px);
}

.confirm-action-button {
  flex: 1;
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
  color: white;
  border: none;
  padding: 16px;
  border-radius: 12px;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 4px;
  transition: all 0.3s;
  position: relative;
  overflow: hidden;
}

.confirm-action-button:not(:disabled):hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 20px rgba(0, 184, 148, 0.3);
}

.confirm-action-button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  background: linear-gradient(135deg, #b2bec3 0%, #636e72 100%);
}

.confirm-action-button:disabled:hover {
  transform: none;
  box-shadow: none;
}

.confirm-action-button:not(:disabled):before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
  transition: 0.5s;
}

.confirm-action-button:not(:disabled):hover:before {
  left: 100%;
}

.button-icon {
  font-size: 1.2rem;
}

.button-subtext {
  font-size: 0.8rem;
  opacity: 0.9;
  font-weight: 400;
}

/* Footer Note */
.confirmation-footer {
  padding: 0 20px 20px;
  text-align: center;
}

.footer-note {
  background: #e3f2fd;
  padding: 12px 16px;
  border-radius: 12px;
  color: #1976d2;
  font-size: 0.9rem;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  border: 1px solid #bbdefb;
}

.note-icon {
  font-size: 1rem;
}

/* Responsive Design */
@media (max-width: 768px) {
  .confirmation-modal-content {
    max-width: 100%;
    margin: 0;
  }
  
  .service-preview-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }
  
  .confirmation-actions {
    flex-direction: column;
  }
  
  .contract-terms li {
    font-size: 0.85rem;
  }
}

@media (max-width: 480px) {
  .confirmation-modal-header {
    padding: 16px;
  }
  
  .service-preview-card,
  .expandable-details-section,
  .conditions-section,
  .contract-section {
    margin: 16px;
  }
  
  .confirmation-actions {
    padding: 0 16px 16px;
  }
  
  .footer-note {
    flex-direction: column;
    gap: 8px;
    text-align: center;
  }
}

/* Scrollbar */
.confirmation-modal-content::-webkit-scrollbar {
  width: 6px;
}

.confirmation-modal-content::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 3px;
}

.confirmation-modal-content::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 3px;
}

.confirmation-modal-content::-webkit-scrollbar-thumb:hover {
  background: #a1a1a1;
}
</style>
