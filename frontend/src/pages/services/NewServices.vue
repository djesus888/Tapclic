<template>
  <div class="create-service-container">
    <!-- Header -->
    <div class="header-section">
      <div class="header-content">
        <h1><span class="icon">✨</span> {{ $t('services.createTitle') }}</h1>
        <p>Crea un nuevo servicio para ofrecer a la comunidad</p>
      </div>
      
      <!-- Progress Steps -->
      <div class="progress-steps">
        <div class="step" :class="{ active: true, completed: true }">
          <div class="step-number">1</div>
          <div class="step-label">Información básica</div>
        </div>
        <div class="step" :class="{ active: false, completed: false }">
          <div class="step-number">2</div>
          <div class="step-label">Detalles del servicio</div>
        </div>
        <div class="step" :class="{ active: false, completed: false }">
          <div class="step-number">3</div>
          <div class="step-label">Publicar</div>
        </div>
      </div>
    </div>

    <!-- Form Container -->
    <div class="form-container">
      <form @submit.prevent="createService" class="service-form">
        <!-- Left Column -->
        <div class="form-left">
          <!-- Title Card -->
          <div class="form-card">
            <div class="card-header">
              <h3><span class="card-icon">📝</span> {{ $t('services.title') }}</h3>
              <div class="character-counter">
                {{ form.title.length }}/50
              </div>
            </div>
            <input
              v-model="form.title"
              type="text"
              required
              maxlength="50"
              :placeholder="$t('services.titlePlaceholder')"
              class="form-input"
            />
            <div class="form-hint">Un título claro y atractivo llama más la atención</div>
          </div>

          <!-- Description Card -->
          <div class="form-card">
            <div class="card-header">
              <h3><span class="card-icon">📄</span> {{ $t('services.description') }}</h3>
              <div class="character-counter">
                {{ form.description.length }}/250
              </div>
            </div>
            <textarea
              v-model="form.description"
              rows="4"
              required
              maxlength="250"
              :placeholder="$t('services.descriptionPlaceholder')"
              class="form-textarea"
            />
            <div class="form-hint">Describe brevemente tu servicio (máximo 250 caracteres)</div>
          </div>

          <!-- Price Card -->
          <div class="form-card">
            <div class="card-header">
              <h3><span class="card-icon">💰</span> {{ $t('services.price') }}</h3>
              <div class="price-badge" v-if="form.price">
                ${{ form.price }}
              </div>
            </div>
            <div class="price-input-container">
              <span class="price-prefix">$</span>
              <input
                v-model.number="form.price"
                type="number"
                step="1"
                min="0"
                required
                :placeholder="$t('services.pricePlaceholder')"
                class="price-input"
              />
            </div>
            <div class="price-slider" v-if="form.price !== null">
              <input
                type="range"
                v-model.number="form.price"
                min="0"
                max="1000"
                step="10"
                class="range-slider"
              />
              <div class="price-range-labels">
                <span>$0</span>
                <span>$500</span>
                <span>$1000+</span>
              </div>
            </div>
            <div class="form-hint">{{ $t('services.priceHint') }}</div>
          </div>
        </div>

        <!-- Right Column -->
        <div class="form-right">
          <!-- Service Details Card -->
          <div class="form-card">
            <div class="card-header">
              <h3><span class="card-icon">🔧</span> {{ $t('services.serviceDetails') }}</h3>
              <div class="character-counter">
                {{ form.service_details?.length || 0 }}/1000
              </div>
            </div>
            <textarea
              v-model="form.service_details"
              rows="6"
              maxlength="1000"
              :placeholder="$t('services.serviceDetailsPlaceholder')"
              class="form-textarea details-textarea"
            />
            <div class="form-hint">Detalles específicos, requisitos, materiales, tiempo estimado, etc.</div>
          </div>

          <!-- Category & Location Card -->
          <div class="form-card">
            <div class="card-header">
              <h3><span class="card-icon">🏷️</span> Categoría y Ubicación</h3>
            </div>
            
            <div class="form-grid">
              <div class="form-group">
                <label class="form-label">
                  <span class="label-icon">📂</span>
                  {{ $t('services.category') }}
                  <span class="required">*</span>
                </label>
                <div class="character-counter-small">
                  {{ form.category.length }}/30
                </div>
                <input
                  v-model="form.category"
                  type="text"
                  required
                  maxlength="30"
                  :placeholder="$t('services.categoryPlaceholder')"
                  class="form-input"
                />
                <div class="suggestions">
                  <span class="suggestion-label">Sugerencias:</span>
                  <div class="suggestion-tags">
                    <span class="tag" @click="form.category = 'Limpieza'">Limpieza</span>
                    <span class="tag" @click="form.category = 'Reparaciones'">Reparaciones</span>
                    <span class="tag" @click="form.category = 'Clases'">Clases</span>
                    <span class="tag" @click="form.category = 'Cuidado'">Cuidado</span>
                  </div>
                </div>
              </div>

              <div class="form-group">
                <label class="form-label">
                  <span class="label-icon">📍</span>
                  {{ $t('services.location') }}
                  <span class="required">*</span>
                </label>
                <div class="character-counter-small">
                  {{ form.location.length }}/50
                </div>
                <input
                  v-model="form.location"
                  type="text"
                  required
                  maxlength="50"
                  :placeholder="$t('services.locationPlaceholder')"
                  class="form-input"
                />
                <div class="location-hint">
                  <span class="hint-icon">ℹ️</span>
                  Esta ubicación será visible para los clientes
                </div>
              </div>
            </div>
          </div>

          <!-- Image Upload Card -->
          <div class="form-card">
            <div class="card-header">
              <h3><span class="card-icon">🖼️</span> {{ $t('services.image') }}</h3>
              <div class="image-requirements">
                <span class="req-icon">📏</span>
                Máx. 5MB
              </div>
            </div>

            <!-- Image Preview -->
            <div v-if="previewUrl" class="image-preview-container">
              <img
                :src="previewUrl"
                alt="Vista previa del servicio"
                class="image-preview"
              />
              <button
                type="button"
                class="btn-remove-image"
                @click="removeImage"
              >
                <span class="remove-icon">🗑️</span>
                Eliminar
              </button>
            </div>

            <!-- Upload Area -->
            <div v-else class="upload-area" @click="triggerFileInput">
              <div class="upload-icon">📁</div>
              <div class="upload-text">
                <h4>{{ $t('services.selectImage') }}</h4>
                <p>Arrastra una imagen o haz clic para seleccionar</p>
              </div>
              <div class="upload-formats">
                <span class="format">JPG</span>
                <span class="format">PNG</span>
                <span class="format">WEBP</span>
              </div>
            </div>

            <!-- Hidden File Input -->
            <input
              ref="fileInput"
              type="file"
              accept="image/*"
              class="hidden"
              @change="onImageChange"
            />

            <!-- Current File Info -->
            <div v-if="imageFile" class="file-info">
              <div class="file-details">
                <span class="file-icon">📄</span>
                <div class="file-text">
                  <span class="file-name">{{ imageFile.name }}</span>
                  <span class="file-size">{{ formatFileSize(imageFile.size) }}</span>
                </div>
              </div>
              <button
                type="button"
                class="btn-change-image"
                @click="triggerFileInput"
              >
                <span class="change-icon">🔄</span>
                Cambiar
              </button>
            </div>

            <div class="image-tips">
              <div class="tip">
                <span class="tip-icon">💡</span>
                Usa imágenes de alta calidad que muestren claramente tu servicio
              </div>
            </div>
          </div>
        </div>

        <!-- Form Actions -->
        <div class="form-actions">
          <div class="form-validation">
            <div class="validation-status" :class="{ valid: canSubmit }">
              <span class="status-icon">{{ canSubmit ? '✅' : '⚠️' }}</span>
              <span class="status-text">
                {{ canSubmit ? 'Formulario completo' : 'Formulario incompleto' }}
              </span>
            </div>
            <div v-if="!canSubmit && !loading" class="validation-hint">
              {{ $t('services.formIncomplete') }}
            </div>
          </div>

          <div class="action-buttons">
            <router-link to="/services" class="btn-cancel">
              <span class="btn-icon">←</span>
              Cancelar
            </router-link>
            <button
              type="submit"
              :disabled="!canSubmit || loading"
              class="btn-submit"
              :class="{ 'btn-loading': loading }"
            >
              <span v-if="loading" class="loading-spinner"></span>
              <span v-else class="btn-icon">🚀</span>
              <span>{{ loading ? $t('services.creating') : $t('services.create') }}</span>
            </button>
          </div>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import api from '@/axios'
import Swal from 'sweetalert2'
import { useAuthStore } from '@/stores/authStore'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'

export default {
  name: 'CreateService',
  setup() {
    const authStore = useAuthStore()
    const { t } = useI18n()
    const router = useRouter()
    const fileInput = ref(null)

    const form = ref({
      title: '',
      description: '',
      service_details: '',
      price: null,
      category: '',
      location: '',
    })

    const imageFile = ref(null)
    const previewUrl = ref(null)
    const loading = ref(false)

    const canSubmit = computed(() =>
      form.value.title.trim() &&
      form.value.description.trim() &&
      Number.isInteger(form.value.price) &&
      form.value.price >= 0 &&
      form.value.category.trim() &&
      form.value.location.trim()
    )

    const triggerFileInput = () => {
      fileInput.value?.click()
    }

    const onImageChange = (e) => {
      const file = e.target.files[0]
      if (file) {
        // Validate file type
        if (!file.type.startsWith('image/')) {
          Swal.fire('Error', 'Por favor, selecciona una imagen válida', 'error')
          return
        }
        
        // Validate file size (5MB max)
        if (file.size > 5 * 1024 * 1024) {
          Swal.fire('Error', 'La imagen no debe superar los 5MB', 'error')
          return
        }
        
        imageFile.value = file
        previewUrl.value = URL.createObjectURL(file)
      }
    }

    const removeImage = () => {
      imageFile.value = null
      previewUrl.value = null
      if (fileInput.value) {
        fileInput.value.value = ''
      }
    }

    const formatFileSize = (bytes) => {
      if (bytes === 0) return '0 Bytes'
      const k = 1024
      const sizes = ['Bytes', 'KB', 'MB', 'GB']
      const i = Math.floor(Math.log(bytes) / Math.log(k))
      return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
    }

    const createService = async () => {
      loading.value = true
      
      try {
        const formData = new FormData()
        formData.append('title', form.value.title.trim())
        formData.append('description', form.value.description.trim())
        formData.append('service_details', form.value.service_details.trim())
        formData.append('price', form.value.price)
        formData.append('category', form.value.category.trim())
        formData.append('location', form.value.location.trim())
        
        if (imageFile.value) {
          formData.append('image', imageFile.value)
        }

        console.log('Token:', authStore.token)
        for (let pair of formData.entries()) {
          console.log(pair[0], pair[1])
        }

        await api.post('/services', formData, {
          headers: {
            Authorization: `Bearer ${authStore.token}`,
            'Content-Type': 'multipart/form-data',
          },
        })

        Swal.fire({
          icon: 'success',
          title: t('services.successTitle'),
          text: t('services.successMessage'),
          timer: 2000,
          showConfirmButton: false,
          position: 'top-end',
          toast: true
        })
        
        router.push('/services')
      } catch (err) {
        const message = err.response?.data?.error || t('services.createFailed')
        
        Swal.fire({
          icon: 'error',
          title: t('services.error'),
          text: message,
          confirmButtonText: 'Entendido'
        })
      } finally {
        loading.value = false
      }
    }

    // Initialize form with some placeholder suggestions
    onMounted(() => {
      form.value.category = 'Limpieza'
      form.value.location = 'Ciudad, Zona'
    })

    return {
      form,
      imageFile,
      previewUrl,
      fileInput,
      loading,
      canSubmit,
      triggerFileInput,
      onImageChange,
      removeImage,
      createService,
      formatFileSize
    }
  },
}
</script>

<style scoped>
.create-service-container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 0 16px;
  min-height: 100vh;
}

/* Header Section */
.header-section {
  margin-bottom: 40px;
}

.header-content {
  text-align: center;
  margin-bottom: 32px;
}

.header-content h1 {
  font-size: 2.5rem;
  color: #2d3436;
  margin-bottom: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
}

.header-content .icon {
  font-size: 2.2rem;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.1); }
}

.header-content p {
  color: #636e72;
  font-size: 1.1rem;
  max-width: 600px;
  margin: 0 auto;
}

/* Progress Steps */
.progress-steps {
  display: flex;
  justify-content: center;
  gap: 40px;
  margin-top: 32px;
}

.step {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  position: relative;
}

.step::before {
  content: '';
  position: absolute;
  top: 20px;
  left: 60px;
  right: -40px;
  height: 3px;
  background: #dfe6e9;
  z-index: 0;
}

.step:last-child::before {
  display: none;
}

.step.completed::before {
  background: #00b894;
}

.step-number {
  width: 40px;
  height: 40px;
  background: #dfe6e9;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  color: #636e72;
  position: relative;
  z-index: 1;
  transition: all 0.3s;
}

.step.active .step-number {
  background: #3498db;
  color: white;
  transform: scale(1.1);
  box-shadow: 0 4px 12px rgba(52, 152, 219, 0.3);
}

.step.completed .step-number {
  background: #00b894;
  color: white;
}

.step-label {
  font-size: 0.9rem;
  color: #636e72;
  font-weight: 600;
}

.step.active .step-label {
  color: #3498db;
}

/* Form Container */
.form-container {
  background: white;
  border-radius: 20px;
  padding: 32px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
  border: 1px solid #f1f2f6;
  margin-bottom: 40px;
}

.service-form {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 32px;
}

/* Form Cards */
.form-card {
  background: #f8f9fa;
  border-radius: 16px;
  padding: 24px;
  margin-bottom: 24px;
  border: 1px solid #e9ecef;
  transition: all 0.3s;
}

.form-card:hover {
  border-color: #3498db;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.card-header h3 {
  font-size: 1.3rem;
  color: #2d3436;
  display: flex;
  align-items: center;
  gap: 10px;
}

.card-icon {
  font-size: 1.2rem;
}

.character-counter {
  background: #dfe6e9;
  color: #636e72;
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 0.85rem;
  font-weight: 600;
}

.character-counter-small {
  font-size: 0.8rem;
  color: #636e72;
  text-align: right;
  margin-bottom: 4px;
}

/* Form Elements */
.form-input,
.form-textarea,
.price-input {
  width: 100%;
  padding: 14px;
  border: 2px solid #dfe6e9;
  border-radius: 10px;
  font-size: 1rem;
  transition: all 0.3s;
  background: white;
}

.form-input:focus,
.form-textarea:focus,
.price-input:focus {
  outline: none;
  border-color: #3498db;
  box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
}

.form-textarea {
  min-height: 120px;
  resize: vertical;
}

.details-textarea {
  min-height: 180px;
}

.form-hint {
  color: #636e72;
  font-size: 0.85rem;
  margin-top: 8px;
  font-style: italic;
}

/* Price Section */
.price-badge {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
  color: white;
  padding: 6px 16px;
  border-radius: 20px;
  font-weight: 700;
  font-size: 1.1rem;
  box-shadow: 0 3px 10px rgba(0, 184, 148, 0.3);
}

.price-input-container {
  position: relative;
  margin-bottom: 16px;
}

.price-prefix {
  position: absolute;
  left: 16px;
  top: 50%;
  transform: translateY(-50%);
  font-size: 1.2rem;
  font-weight: 700;
  color: #00b894;
}

.price-input {
  padding-left: 40px;
  font-size: 1.2rem;
  font-weight: 600;
  color: #2d3436;
}

.price-slider {
  margin-top: 16px;
}

.range-slider {
  width: 100%;
  height: 8px;
  -webkit-appearance: none;
  background: linear-gradient(to right, #74b9ff, #0984e3);
  border-radius: 4px;
  outline: none;
}

.range-slider::-webkit-slider-thumb {
  -webkit-appearance: none;
  width: 24px;
  height: 24px;
  background: #0984e3;
  border-radius: 50%;
  cursor: pointer;
  border: 3px solid white;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
}

.price-range-labels {
  display: flex;
  justify-content: space-between;
  margin-top: 8px;
  color: #636e72;
  font-size: 0.85rem;
}

/* Form Grid */
.form-grid {
  display: grid;
  gap: 20px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.form-label {
  font-weight: 700;
  color: #2d3436;
  font-size: 0.95rem;
  display: flex;
  align-items: center;
  gap: 8px;
}

.label-icon {
  font-size: 1.1rem;
}

.required {
  color: #e74c3c;
}

/* Suggestions */
.suggestions {
  margin-top: 12px;
}

.suggestion-label {
  font-size: 0.85rem;
  color: #636e72;
  margin-right: 8px;
}

.suggestion-tags {
  display: flex;
  gap: 8px;
  margin-top: 6px;
  flex-wrap: wrap;
}

.tag {
  background: #dfe6e9;
  color: #2d3436;
  padding: 6px 12px;
  border-radius: 16px;
  font-size: 0.85rem;
  cursor: pointer;
  transition: all 0.3s;
}

.tag:hover {
  background: #3498db;
  color: white;
  transform: translateY(-2px);
}

.location-hint {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #636e72;
  font-size: 0.85rem;
  margin-top: 8px;
}

.hint-icon {
  font-size: 1rem;
}

/* Image Upload */
.image-requirements {
  display: flex;
  align-items: center;
  gap: 6px;
  color: #636e72;
  font-size: 0.85rem;
}

.req-icon {
  font-size: 1rem;
}

.image-preview-container {
  position: relative;
  margin-bottom: 16px;
}

.image-preview {
  width: 100%;
  height: 200px;
  object-fit: cover;
  border-radius: 12px;
  border: 2px solid #dfe6e9;
}

.btn-remove-image {
  position: absolute;
  top: 12px;
  right: 12px;
  background: rgba(231, 76, 60, 0.9);
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 8px;
  font-weight: 600;
  font-size: 0.9rem;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 6px;
  transition: all 0.3s;
}

.btn-remove-image:hover {
  background: #e74c3c;
  transform: translateY(-2px);
}

.remove-icon {
  font-size: 1rem;
}

.upload-area {
  border: 2px dashed #b2bec3;
  border-radius: 12px;
  padding: 40px 20px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s;
  background: #f8f9fa;
  margin-bottom: 16px;
}

.upload-area:hover {
  border-color: #3498db;
  background: #e3f2fd;
}

.upload-icon {
  font-size: 3rem;
  margin-bottom: 16px;
}

.upload-text h4 {
  font-size: 1.2rem;
  color: #2d3436;
  margin-bottom: 8px;
}

.upload-text p {
  color: #636e72;
  font-size: 0.9rem;
}

.upload-formats {
  display: flex;
  justify-content: center;
  gap: 12px;
  margin-top: 16px;
}

.format {
  background: #dfe6e9;
  color: #636e72;
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: 600;
}

.file-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px;
  background: white;
  border-radius: 10px;
  border: 2px solid #dfe6e9;
  margin-bottom: 16px;
}

.file-details {
  display: flex;
  align-items: center;
  gap: 12px;
}

.file-icon {
  font-size: 1.5rem;
}

.file-text {
  display: flex;
  flex-direction: column;
}

.file-name {
  font-weight: 600;
  color: #2d3436;
  font-size: 0.95rem;
}

.file-size {
  color: #636e72;
  font-size: 0.85rem;
}

.btn-change-image {
  background: #3498db;
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 8px;
  font-weight: 600;
  font-size: 0.9rem;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 6px;
  transition: all 0.3s;
}

.btn-change-image:hover {
  background: #2980b9;
  transform: translateY(-2px);
}

.change-icon {
  font-size: 1rem;
}

.image-tips {
  margin-top: 16px;
  padding: 12px;
  background: #e3f2fd;
  border-radius: 10px;
}

.tip {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  color: #2d3436;
  font-size: 0.9rem;
}

.tip-icon {
  font-size: 1rem;
  color: #3498db;
}

/* Form Actions */
.form-actions {
  grid-column: 1 / -1;
  padding-top: 32px;
  border-top: 2px solid #f1f2f6;
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 24px;
}

.form-validation {
  flex: 1;
}

.validation-status {
  display: flex;
  align-items: center;
  gap: 10px;
  font-weight: 700;
  font-size: 1.1rem;
}

.validation-status.valid .status-icon {
  color: #00b894;
}

.validation-status:not(.valid) .status-icon {
  color: #fdcb6e;
}

.status-icon {
  font-size: 1.3rem;
}

.validation-hint {
  color: #e74c3c;
  font-size: 0.9rem;
  margin-top: 8px;
  font-weight: 600;
}

.action-buttons {
  display: flex;
  gap: 16px;
}

.btn-cancel {
  background: #dfe6e9;
  color: #2d3436;
  padding: 14px 28px;
  border-radius: 10px;
  text-decoration: none;
  font-weight: 700;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s;
}

.btn-cancel:hover {
  background: #b2bec3;
  transform: translateY(-2px);
}

.btn-submit {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
  color: white;
  border: none;
  padding: 14px 40px;
  border-radius: 10px;
  font-weight: 700;
  font-size: 1.1rem;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 10px;
  transition: all 0.3s;
  min-width: 200px;
  justify-content: center;
}

.btn-submit:hover:not(:disabled) {
  transform: translateY(-3px);
  box-shadow: 0 10px 20px rgba(0, 184, 148, 0.3);
}

.btn-submit:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  background: #b2bec3;
}

.btn-loading {
  position: relative;
  color: transparent;
}

.loading-spinner {
  position: absolute;
  width: 24px;
  height: 24px;
  border: 3px solid rgba(255, 255, 255, 0.3);
  border-top-color: white;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.btn-icon {
  font-size: 1.2rem;
}

.hidden {
  display: none;
}

/* Responsive Design */
@media (max-width: 1200px) {
  .service-form {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .create-service-container {
    padding: 0 12px;
  }
  
  .header-content h1 {
    font-size: 2rem;
  }
  
  .progress-steps {
    flex-direction: column;
    gap: 24px;
    align-items: center;
  }
  
  .step::before {
    display: none;
  }
  
  .form-container {
    padding: 24px;
    border-radius: 16px;
  }
  
  .form-actions {
    flex-direction: column;
    align-items: stretch;
    gap: 16px;
  }
  
  .action-buttons {
    flex-direction: column;
  }
  
  .btn-cancel, .btn-submit {
    width: 100%;
    justify-content: center;
  }
}

@media (max-width: 480px) {
  .header-content h1 {
    font-size: 1.8rem;
    flex-direction: column;
    gap: 8px;
  }
  
  .card-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }
  
  .character-counter, .price-badge {
    align-self: flex-start;
  }
  
  .suggestion-tags {
    justify-content: center;
  }
}
</style>
