<!-- ServiceDetailsModal.vue - VERSIÓN SIMPLIFICADA CON ESTILOS GLOBALES -->
<template>
  <!-- Modal Overlay -->
  <div
    v-if="isOpen"
    class="service-modal-overlay"
    @click.self="$emit('on-open-change', false)"
  >
    <!-- Modal Content -->
    <div class="service-modal-content">
      <!-- Header -->
      <div class="service-modal-header">
        <div class="service-header-badge">
          <span class="badge-icon">⭐</span>
          <span class="badge-text">Detalles del Servicio</span>
        </div>
        <button
          class="close-modal-button"
          @click="$emit('on-open-change', false)"
        >
          ✕
        </button>
      </div>

      <!-- Service Image -->
      <div class="service-image-wrapper">
        <img
          :src="serviceImage"
          :alt="request.title || 'Servicio'"
          class="service-main-image"
          @error="handleImageError"
        />
        <div class="availability-badge" :class="request.isAvailable ? 'available' : 'unavailable'">
          {{ request.isAvailable ? 'Disponible' : 'No disponible' }}
        </div>
      </div>

      <!-- Service Info -->
      <div class="service-info-wrapper">
        <h2 class="service-main-title">
          {{ request.title || '—' }}
        </h2>
        <p class="service-main-description">
          {{ request.description || '—' }}
        </p>

        <!-- Location -->
        <div class="service-location" v-if="request.location">
          <span class="location-icon">📍</span>
          <span>{{ request.location }}</span>
        </div>

        <!-- Provider Section -->
        <div class="provider-card-wrapper" @click="openProviderFeedback">
          <div class="provider-card-content">
            <div class="provider-avatar-wrapper">
              <img
                :src="providerAvatar"
                :alt="providerName"
                class="provider-avatar-image"
              />
            </div>
            <div class="provider-info-content">
              <h3 class="provider-name-title">
                {{ providerName }}
              </h3>
              <div class="provider-rating-wrapper" v-if="providerRating !== null">
                <div class="rating-stars">
                  <span v-for="n in 5" :key="n" class="star-item">
                    {{ n <= Math.floor(providerRating) ? '★' : '☆' }}
                  </span>
                </div>
                <span class="rating-value">{{ formattedRating }}</span>
              </div>
            </div>
            <div class="provider-actions-wrapper">
              <button
                class="chat-action-button"
                @click.stop="openChat"
              >
                💬 Chat
              </button>
            </div>
          </div>
        </div>

        <!-- Price -->
        <div class="price-display-wrapper">
          <div class="price-label-wrapper">
            <span>Precio del servicio</span>
          </div>
          <div class="price-amount-wrapper">
            <span class="price-currency">$</span>
            <span class="price-number">{{ formattedPrice }}</span>
          </div>
        </div>
      </div>

      <!-- Footer Buttons -->
      <div class="service-modal-footer">
        <button
          class="secondary-action-button"
          @click="$emit('on-open-change', false)"
        >
          Cerrar
        </button>
        <button
          v-if="request.isAvailable"
          class="primary-action-button"
          @click="$emit('on-request-service')"
        >
          ✨ Solicitar Servicio
        </button>
      </div>
    </div>

    <!-- Provider Feedback Modal -->
    <div v-if="showProviderFeedback" class="provider-feedback-overlay">
      <div class="provider-feedback-content">
        <div class="feedback-header">
          <h3>Reseñas de {{ providerName }}</h3>
          <button class="close-feedback-button" @click="showProviderFeedback = false">
            ✕
          </button>
        </div>
        
        <div class="feedback-body">
          <!-- Loading State -->
          <div v-if="loadingReviews" class="loading-feedback">
            <div class="loading-spinner"></div>
            <p>Cargando reseñas...</p>
          </div>

          <!-- Error State -->
          <div v-else-if="reviewsError" class="error-feedback">
            <span>⚠️</span>
            <p>{{ reviewsError }}</p>
            <button class="retry-button" @click="loadProviderReviews">
              Reintentar
            </button>
          </div>

          <!-- Reviews Content -->
          <div v-else>
            <!-- Stats -->
            <div class="feedback-stats-grid">
              <div class="stat-item-box">
                <span class="stat-number">{{ providerReviewsStats.average?.toFixed(1) || 'N/A' }}</span>
                <span class="stat-label">Rating promedio</span>
              </div>
              <div class="stat-item-box">
                <span class="stat-number">{{ providerReviewsStats.total || '0' }}</span>
                <span class="stat-label">Reseñas totales</span>
              </div>
            </div>

            <!-- Reviews List -->
            <div class="reviews-list-container" v-if="providerReviews.length > 0">
              <div 
                v-for="review in providerReviews" 
                :key="review.id"
                class="review-item-box"
              >
                <div class="review-header-row">
                  <div class="reviewer-info-box">
                    <img
                      :src="getReviewerAvatar(review)"
                      :alt="review.provider_name"
                      class="reviewer-avatar-image"
                    />
                    <div>
                      <span class="reviewer-name-text">{{ review.provider_name }}</span>
                      <div class="review-meta-info">
                        <span class="review-date-text">{{ formatReviewDate(review.created_at) }}</span>
                      </div>
                    </div>
                  </div>
                  <div class="review-rating-box">
                    <span v-for="n in 5" :key="n" class="review-star-item">
                      {{ n <= (review.rating || 0) ? '★' : '☆' }}
                    </span>
                  </div>
                </div>
                
                <!-- Comment -->
                <p class="review-comment-text" v-if="review.comment">
                  {{ review.comment }}
                </p>

                <!-- Provider Response -->
                <div v-if="review.user_reply" class="provider-response-box">
                  <div class="response-header-row">
                    <strong>Respuesta del proveedor:</strong>
                    <span class="response-date-text">{{ formatDate(review.user_reply.created_at) }}</span>
                  </div>
                  <p class="response-text-content">{{ review.user_reply.message }}</p>
                </div>
              </div>
            </div>

            <!-- No Reviews -->
            <div v-else class="no-reviews-box">
              <div class="no-reviews-icon">📝</div>
              <h4>No hay reseñas aún</h4>
              <p>Este proveedor aún no tiene reseñas de clientes.</p>
            </div>
          </div>
        </div>
        <div class="feedback-footer">
          <button class="close-feedback-action" @click="showProviderFeedback = false">
            Cerrar
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { defineProps, computed, ref, watch } from 'vue'
import { useAuthStore } from '@/stores/authStore'
import { getImageUrl } from '@/utils/imageHelper.js'


const props = defineProps({
  isOpen: Boolean,
  request: Object
})

const authStore = useAuthStore()
const showProviderFeedback = ref(false)
const loadingReviews = ref(false)
const reviewsError = ref(null)
const providerReviews = ref([])

// Computed properties
const serviceImage = computed(() => {
  return props.request.image_url
    ? getImageUrl(props.request.image_url)
    : '/img/default-service.jpg'
})

const formattedPrice = computed(() => {
  return Number(props.request?.price || 0).toFixed(2)
})

const providerName = computed(() => {
  return props.request?.provider?.name || 
         props.request?.provider_name || 
         'Proveedor'
})

const providerAvatar = computed(() => {
  const provider = props.request?.provider
  if (provider?.avatar_url) {
    return getImageUrl(provider.avatar_url, 'avatar')
  }
  if (provider?.avatar) {
    return getImageUrl(provider.avatar, 'avatar')
  }
  return '/img/default-provider.png'
})

const providerRating = computed(() => {
  const rating = props.request?.provider?.rating
  if (rating === null || rating === undefined || rating === '') {
    return null
  }
  
  if (typeof rating === 'string') {
    const num = parseFloat(rating)
    return isNaN(num) ? null : num
  }
  
  if (typeof rating === 'number') {
    return Math.min(Math.max(rating, 0), 5)
  }
  
  return null
})

const formattedRating = computed(() => {
  if (providerRating.value === null) return 'N/A'
  return providerRating.value.toFixed(1)
})

const providerReviewsStats = computed(() => {
  if (providerReviews.value.length === 0) {
    return { average: 0, total: 0 }
  }
  
  const total = providerReviews.value.length
  const sum = providerReviews.value.reduce((acc, review) => acc + (review.rating || 0), 0)
  const average = sum / total
  
  return { average, total }
})

// Methods
const openChat = () => {
  const provider = props.request?.provider
  const avatar = provider?.avatar_url
    ? getImageUrl(provider.avatar_url, 'avatar')
    : '/img/default-provider.png'

  
  const target = {
    id: provider?.id ?? props.request?.provider_id ?? props.request?.user_id,
    name: providerName.value,
    role: 'provider',
    avatarUrl: avatar
  }
  
  emit('on-start-chat', target)
}

const openProviderFeedback = async () => {
  showProviderFeedback.value = true
  await loadProviderReviews()
}

const loadProviderReviews = async () => {
  if (!props.request?.provider) return
  
  loadingReviews.value = true
  reviewsError.value = null
  
 try {
    const response = await fetch(`${import.meta.env.VITE_API_URL}/reviews/received`, {
      headers: {
        'Authorization': `Bearer ${authStore.token}`,
        'Accept': 'application/json'
      }
    })
    
    if (!response.ok) {
      throw new Error(`Error ${response.status}: ${response.statusText}`)
    }
    
    const data = await response.json()
    
    if (data.success && data.reviews) {
      providerReviews.value = data.reviews
    } else {
      throw new Error(data.error || 'Error al cargar reviews')
    }
    
  } catch (error) {
    console.error('Error cargando reviews:', error)
    reviewsError.value = 'No se pudieron cargar las reseñas.'
  } finally {
    loadingReviews.value = false
  }
}


const getReviewerAvatar = (review) => {
  if (review.provider_avatar) {
    return getImageUrl(review.provider_avatar, 'avatar')
  }
  return '/img/default-user.png'
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-ES', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    })
  } catch (e) {
    return 'Fecha inválida'
  }
}

const formatReviewDate = (dateString) => {
  if (!dateString) return ''
  try {
    const date = new Date(dateString)
    const now = new Date()
    const diffMs = now - date
    const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24))
    
    if (diffDays === 0) return 'Hoy'
    if (diffDays === 1) return 'Ayer'
    if (diffDays < 7) return `Hace ${diffDays} días`
    if (diffDays < 30) {
      const weeks = Math.floor(diffDays / 7)
      return `Hace ${weeks} semana${weeks > 1 ? 's' : ''}`
    }
    return date.toLocaleDateString('es-ES', {
      day: 'numeric',
      month: 'short'
    })
  } catch (e) {
    return ''
  }
}

const handleImageError = (event) => {
  event.target.src = '/img/default-service.jpg'
}

const handleAvatarError = (event) => {
  event.target.src = '/img/default-provider.png'
}

// Watch
watch(() => props.isOpen, (newVal) => {
  if (!newVal) {
    showProviderFeedback.value = false
  }
})

const emit = defineEmits([
  'on-open-change',
  'on-request-service',
  'on-start-chat'
])
</script>

<style>
/* ESTILOS GLOBALES - NO SCOPED */

/* Modal Principal */
.service-modal-overlay {
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
}

.service-modal-content {
  background: white;
  border-radius: 16px;
  width: 100%;
  max-width: 450px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 10px 30px rgba(0,0,0,0.3);
}

.service-modal-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px;
  border-radius: 16px 16px 0 0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  color: white;
}

.service-header-badge {
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

.close-modal-button {
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
}

/* Service Image */
.service-image-wrapper {
  position: relative;
  height: 200px;
  overflow: hidden;
}

.service-main-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.availability-badge {
  position: absolute;
  top: 16px;
  right: 16px;
  padding: 8px 16px;
  border-radius: 20px;
  font-size: 0.9rem;
  font-weight: 600;
  color: white;
}

.availability-badge.available {
  background: #00b894;
}

.availability-badge.unavailable {
  background: #ff7675;
}

/* Service Info */
.service-info-wrapper {
  padding: 20px;
}

.service-main-title {
  font-size: 1.5rem;
  color: #333;
  margin-bottom: 10px;
  font-weight: 700;
}

.service-main-description {
  color: #666;
  line-height: 1.5;
  margin-bottom: 20px;
}

.service-location {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 20px;
  padding: 12px;
  background: #f8f9fa;
  border-radius: 10px;
  color: #555;
}

.location-icon {
  font-size: 1.2rem;
}

/* Provider Card */
.provider-card-wrapper {
  margin-bottom: 20px;
  cursor: pointer;
}

.provider-card-content {
  display: flex;
  align-items: center;
  gap: 15px;
  padding: 16px;
  background: #f8f9fa;
  border-radius: 12px;
  border: 2px solid transparent;
  transition: border-color 0.3s;
}

.provider-card-wrapper:hover .provider-card-content {
  border-color: #667eea;
}

.provider-avatar-wrapper {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  overflow: hidden;
  border: 3px solid white;
  box-shadow: 0 4px 10px rgba(0,0,0,0.1);
}

.provider-avatar-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.provider-info-content {
  flex: 1;
}

.provider-name-title {
  font-size: 1.2rem;
  color: #333;
  margin-bottom: 8px;
  font-weight: 600;
}

.provider-rating-wrapper {
  display: flex;
  align-items: center;
  gap: 8px;
}

.rating-stars {
  color: #fdcb6e;
  font-size: 1.1rem;
}

.rating-value {
  font-weight: 600;
  color: #333;
}

.provider-actions-wrapper {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.chat-action-button {
  background: #3498db;
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 20px;
  cursor: pointer;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 0.9rem;
}

/* Price */
.price-display-wrapper {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  background: linear-gradient(135deg, #a8edea 0%, #fed6e3 100%);
  border-radius: 12px;
  margin-bottom: 20px;
}

.price-label-wrapper {
  font-size: 1.1rem;
  color: #333;
  font-weight: 600;
}

.price-amount-wrapper {
  display: flex;
  align-items: baseline;
  gap: 4px;
}

.price-currency {
  font-size: 1.2rem;
  color: #00b894;
  font-weight: 600;
}

.price-number {
  font-size: 2rem;
  font-weight: 800;
  color: #333;
}

/* Footer Buttons */
.service-modal-footer {
  padding: 20px;
  display: flex;
  gap: 15px;
  border-top: 1px solid #eee;
}

.secondary-action-button {
  flex: 1;
  background: white;
  color: #666;
  border: 2px solid #ddd;
  padding: 14px;
  border-radius: 12px;
  font-weight: 600;
  cursor: pointer;
  font-size: 1rem;
}

.primary-action-button {
  flex: 1;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 14px;
  border-radius: 12px;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  font-size: 1rem;
}

/* Provider Feedback Modal */
.provider-feedback-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0,0,0,0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1001;
  padding: 16px;
  backdrop-filter: blur(4px);
}

.provider-feedback-content {
  background: white;
  border-radius: 16px;
  width: 100%;
  max-width: 500px;
  max-height: 80vh;
  overflow-y: auto;
}

.feedback-header {
  background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%);
  padding: 20px;
  border-radius: 16px 16px 0 0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  color: white;
}

.feedback-header h3 {
  font-size: 1.3rem;
  font-weight: 600;
  margin: 0;
}

.close-feedback-button {
  background: rgba(255,255,255,0.2);
  border: none;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  color: white;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
}

.feedback-body {
  padding: 20px;
}

/* Loading State */
.loading-feedback {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #f3f3f3;
  border-top: 4px solid #3498db;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 16px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* Error State */
.error-feedback {
  text-align: center;
  padding: 40px 20px;
}

.error-feedback span {
  font-size: 3rem;
  margin-bottom: 16px;
  display: block;
}

.error-feedback p {
  color: #666;
  margin-bottom: 20px;
}

.retry-button {
  background: #3498db;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
}

/* Stats */
.feedback-stats-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
  margin-bottom: 24px;
}

.stat-item-box {
  background: #f8f9fa;
  padding: 20px;
  border-radius: 12px;
  text-align: center;
}

.stat-number {
  display: block;
  font-size: 2rem;
  font-weight: 700;
  color: #333;
  margin-bottom: 4px;
}

.stat-label {
  font-size: 0.9rem;
  color: #666;
}

/* Reviews List */
.reviews-list-container {
  display: flex;
  flex-direction: column;
  gap: 16px;
  max-height: 400px;
  overflow-y: auto;
  padding-right: 8px;
}

.review-item-box {
  background: white;
  padding: 16px;
  border-radius: 12px;
  border: 1px solid #eee;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}

.review-header-row {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 12px;
}

.reviewer-info-box {
  display: flex;
  align-items: center;
  gap: 12px;
}

.reviewer-avatar-image {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  object-fit: cover;
}

.reviewer-name-text {
  font-weight: 600;
  color: #333;
  display: block;
}

.review-meta-info {
  margin-top: 2px;
}

.review-date-text {
  font-size: 0.8rem;
  color: #888;
}

.review-rating-box {
  color: #fdcb6e;
  font-size: 1.1rem;
}

.review-comment-text {
  color: #555;
  line-height: 1.5;
  margin-bottom: 12px;
  font-size: 0.95rem;
}

/* Provider Response */
.provider-response-box {
  background: #f8f9fa;
  padding: 12px;
  border-radius: 8px;
  border-left: 3px solid #3498db;
  margin-top: 12px;
}

.response-header-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.response-header-row strong {
  color: #333;
  font-size: 0.9rem;
}

.response-date-text {
  font-size: 0.8rem;
  color: #888;
}

.response-text-content {
  color: #555;
  font-size: 0.9rem;
  line-height: 1.4;
}

/* No Reviews */
.no-reviews-box {
  text-align: center;
  padding: 40px 20px;
}

.no-reviews-icon {
  font-size: 3rem;
  margin-bottom: 16px;
  display: block;
}

.no-reviews-box h4 {
  color: #333;
  margin-bottom: 8px;
  font-size: 1.2rem;
}

.no-reviews-box p {
  color: #666;
  max-width: 300px;
  margin: 0 auto;
}

/* Feedback Footer */
.feedback-footer {
  padding: 20px;
  border-top: 1px solid #eee;
  text-align: center;
}

.close-feedback-action {
  background: #666;
  color: white;
  border: none;
  padding: 12px 32px;
  border-radius: 12px;
  cursor: pointer;
  font-weight: 600;
  font-size: 1rem;
}

/* Scrollbar */
.service-modal-content::-webkit-scrollbar,
.provider-feedback-content::-webkit-scrollbar,
.reviews-list-container::-webkit-scrollbar {
  width: 6px;
}

.service-modal-content::-webkit-scrollbar-track,
.provider-feedback-content::-webkit-scrollbar-track,
.reviews-list-container::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 3px;
}

.service-modal-content::-webkit-scrollbar-thumb,
.provider-feedback-content::-webkit-scrollbar-thumb,
.reviews-list-container::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 3px;
}

.service-modal-content::-webkit-scrollbar-thumb:hover,
.provider-feedback-content::-webkit-scrollbar-thumb:hover,
.reviews-list-container::-webkit-scrollbar-thumb:hover {
  background: #a1a1a1;
}

/* Responsive */
@media (max-width: 480px) {
  .service-modal-header,
  .feedback-header {
    padding: 16px;
  }
  
  .service-info-wrapper,
  .feedback-body {
    padding: 16px;
  }
  
  .service-main-title {
    font-size: 1.3rem;
  }
  
  .price-number {
    font-size: 1.8rem;
  }
  
  .service-modal-footer {
    flex-direction: column;
  }
  
  .provider-card-content {
    flex-direction: column;
    text-align: center;
  }
  
  .provider-avatar-wrapper {
    width: 80px;
    height: 80px;
  }
  
  .feedback-stats-grid {
    grid-template-columns: 1fr;
  }
}
</style>
