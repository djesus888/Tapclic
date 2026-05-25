<template>
  <div class="my-services-page">
    <!-- Header -->
    <div class="header">


<!-- ✅ Aviso para configurar métodos de pago -->
<div v-if="!hasPaymentMethods" class="warning-banner">
  <div class="warning-icon">💳</div>
  <div class="warning-content">
    <h3>Configura tus métodos de pago</h3>
    <p>Para recibir pagos de tus clientes, agrega al menos un método de pago (Pago Móvil, Transferencia, Zelle o PayPal).</p>
    <router-link to="/payment" class="warning-link">Ir a configurar →</router-link>
  </div>
</div>


      <div class="title-section">
        <h1><span class="services-icon">📋</span> {{ $t('services.myServices') }}</h1>
        <p>{{ $t('services.manageYourServices') }}</p>
      </div>

      <router-link
        to="/services/new"
        class="btn-create"
      >
        ➕ {{ $t('services.createNew') }}
      </router-link>
    </div>

    <!-- Services Grid -->
    <div v-if="services.length" class="services-grid">
      <div
        v-for="s in services"
        :key="s.id"
        class="service-card"
        @click="openEditModal(s)"
      >
        <!-- Badge Estado -->
        <div class="card-badge" :class="statusBadgeClass(s.status)">
          {{ getStatusLabel(s.status) }}
        </div>

        <!-- Imagen -->
        <div class="card-image" v-if="s.image_url">
          <img
            :src="getImageUrl(s.image_url)"
            :alt="$t('services.image')"
            @error="handleImageError"
          >
        </div>
        <div class="card-image placeholder" v-else>
          <span class="placeholder-icon">📷</span>
          <p>{{ $t('services.noImage') }}</p>
        </div>

        <!-- Contenido -->
        <div class="card-content">
          <div class="card-header">
            <span class="service-category">{{ s.category }}</span>
            <span class="service-location">📍 {{ s.location }}</span>
          </div>

          <h3 class="service-title">{{ s.title }}</h3>
          <p class="service-description">{{ (s.description || '').slice(0, 80) }}...</p>

          <div class="service-details-preview" v-if="s.service_details">
            <span class="details-icon">📝</span>
            <span>{{ (s.service_details || '').slice(0, 40) }}...</span>
          </div>

          <div class="card-footer">
            <div class="price-section">
              <span class="price">${{ s.price }}</span>
              <span class="price-label">{{ $t('services.price') }}</span>
            </div>

            <div class="card-actions">
              <!-- ✅ Botón para pagar servicio pendiente -->
              <button
                v-if="s.status === 'pending' || s.status === 'pending_payment'"
                class="btn-pay-now"
                @click.stop="goToPay(s.id)"
                title="Pagar publicación"
              >
                💳 Pagar
              </button>

              <button
                class="btn-delete"
                @click.stop="deleteService(s.id)"
                :title="$t('services.delete')"
              >
                🗑️
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="empty-state">
      <div class="empty-icon">📋</div>
      <h2>{{ $t('services.noServices') }}</h2>
      <p>{{ $t('services.createFirstService') }}</p>
      <router-link to="/services/new" class="btn-primary">
        {{ $t('services.createFirst') }}
      </router-link>
    </div>

    <!-- Edit Modal -->
    <div
      v-if="showModal"
      class="modal-overlay"
      @click.self="closeEditModal"
    >
      <div class="modal">
        <div class="modal-header">
          <h2><span class="edit-icon">✏️</span> {{ $t('services.editService') }}</h2>
          <button class="btn-close" @click="closeEditModal">×</button>
        </div>

        <form class="modal-form" @submit.prevent="updateService">
          <div class="form-grid">
            <!-- Título -->
            <div class="form-group">
              <label class="form-label">
                <span class="label-icon">📌</span>
                {{ $t('services.title') }}
              </label>
              <input
                v-model="form.title"
                type="text"
                class="form-input"
                :placeholder="$t('services.titlePlaceholder')"
                required
              >
            </div>

            <!-- Descripción -->
            <div class="form-group">
              <label class="form-label">
                <span class="label-icon">📋</span>
                {{ $t('services.description') }}
              </label>
              <textarea
                v-model="form.description"
                rows="3"
                class="form-textarea"
                :placeholder="$t('services.descriptionPlaceholder')"
                required
              ></textarea>
            </div>

            <!-- Detalles del Servicio -->
            <div class="form-group full-width">
              <label class="form-label">
                <span class="label-icon">📝</span>
                {{ $t('services.serviceDetails') }}
                <span class="char-count">
                  {{ (form.service_details || '').length }}/1000
                </span>
              </label>
              <textarea
                v-model="form.service_details"
                rows="4"
                maxlength="1000"
                class="form-textarea details-textarea"
                :placeholder="$t('services.detailsPlaceholder')"
              ></textarea>
            </div>

            <!-- Precio -->
            <div class="form-group">
              <label class="form-label">
                <span class="label-icon">💰</span>
                {{ $t('services.price') }}
              </label>
              <div class="price-input-group">
                <span class="currency">$</span>
                <input
                  v-model.number="form.price"
                  type="number"
                  min="0"
                  step="0.01"
                  class="form-input price-input"
                  :placeholder="$t('services.pricePlaceholder')"
                  required
                >
              </div>
            </div>

            <!-- Categoría -->
            <div class="form-group">
              <label class="form-label">
                <span class="label-icon">🏷️</span>
                {{ $t('services.category') }}
              </label>
              <input
                v-model="form.category"
                type="text"
                class="form-input"
                :placeholder="$t('services.categoryPlaceholder')"
                required
              >
            </div>

            <!-- Ubicación -->
            <div class="form-group">
              <label class="form-label">
                <span class="label-icon">📍</span>
                {{ $t('services.location') }}
              </label>
              <input
                v-model="form.location"
                type="text"
                class="form-input"
                :placeholder="$t('services.locationPlaceholder')"
                required
              >
            </div>

            <!-- Imagen -->
            <div class="form-group full-width">
              <label class="form-label">
                <span class="label-icon">🖼️</span>
                {{ $t('services.imageOptional') }}
              </label>

              <div v-if="previewImage" class="image-preview-container">
                <div class="image-preview">
                  <img :src="previewImage" alt="Preview" class="preview-image">
                  <button
                    type="button"
                    class="btn-change-image"
                    @click="triggerFilePicker"
                  >
                    🔄 {{ $t('services.changeImage') }}
                  </button>
                </div>
              </div>

              <div
                v-else
                class="image-upload-area"
                @drop.prevent="handleDrop"
                @dragover.prevent
                @click="triggerFilePicker"
              >
                <div class="upload-icon">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                      d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"
                    />
                  </svg>
                </div>
                <p class="upload-text">
                  {{ $t('services.dragDropImage') }}
                  <span class="upload-click">{{ $t('services.clickToUpload') }}</span>
                </p>
                <p class="upload-hint">{{ $t('services.imageHint') }}</p>
              </div>

              <input
                ref="fileInput"
                type="file"
                accept="image/*"
                class="hidden-input"
                @change="onImageChange"
              >
            </div>
          </div>

          <!-- Modal Actions -->
          <div class="modal-actions">
            <button
              type="button"
              class="btn-cancel"
              @click="closeEditModal"
            >
              {{ $t('common.cancel') }}
            </button>
            <button
              type="submit"
              class="btn-save"
            >
              💾 {{ $t('common.save') }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast" :class="toast.type">
      {{ toast.message }}
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import api from '@/axios'
import { useAuthStore } from '@/stores/authStore'
import Swal from 'sweetalert2'

const { t } = useI18n()
const authStore = useAuthStore()
const router = useRouter()
const services = ref([])
const showModal = ref(false)

const form = ref({
  id: null,
  title: '',
  description: '',
  service_details: '',
  price: 0,
  category: '',
  location: '',
  image: null
})

const previewImage = ref('')
const fileInput = ref(null)

const toast = ref({
  show: false,
  message: '',
  type: 'success'
})

/* ----------  Utils  ---------- */
const getImageUrl = (path) => {
  if (!path) return ''
  if (path.startsWith('http')) return path
  // Quitar /api del final de VITE_API_URL si existe
  const base = (import.meta.env.VITE_API_URL || '').replace(/\/api\/?$/, '')
  return `${base}${path}`
}

const getStatusLabel = (status) => {
  const labels = {
    'pending': 'Pendiente',
    'active': 'Activo',
    'inactive': 'Inactivo',
    'pending_payment': 'Pendiente de pago',
    'approved': 'Aprobado',
    'rejected': 'Rechazado'
  }
  return labels[status] || status
}

const statusBadgeClass = (status) => {
  switch (status) {
    case 'pending':  return 'status-pending'
    case 'approved': return 'status-approved'
    case 'rejected': return 'status-rejected'
    case 'active':   return 'status-approved'
    case 'pending_payment': return 'status-pending'
    default:         return 'status-default'
  }
}

const handleImageError = (event) => {
  event.target.src = 'https://via.placeholder.com/400x250?text=Imagen+No+Disponible'
}

const showToast = (message, type = 'info') => {
  toast.value = { show: true, message, type }
  setTimeout(() => {
    toast.value.show = false
  }, 3000)
}

// ✅ Ir a la página de pago
const goToPay = (serviceId) => {
  router.push(`/service/${serviceId}/publish`)
}

/* ----------  Cargar servicios  ---------- */
const loadServices = async () => {
  try {
    const { data } = await api.get('/services/mine', {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    services.value = data
  } catch (err) {
    Swal.fire(t('common.error'), err.response?.data?.error || t('services.loadError'), 'error')
  }
}

/* ----------  Eliminar servicio  ---------- */
const deleteService = async (id) => {
  const confirm = await Swal.fire({
    title: t('services.confirmDeleteTitle'),
    text: t('services.confirmDeleteText'),
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#d33',
    cancelButtonColor: '#6b7280',
    confirmButtonText: t('common.yes'),
    cancelButtonText: t('common.cancel'),
    buttonsStyling: false,
    customClass: {
      confirmButton: 'swal-confirm-btn',
      cancelButton: 'swal-cancel-btn'
    }
  })

  if (!confirm.isConfirmed) return

  try {
    await api.post('/services/delete', { id }, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    Swal.fire(t('common.success'), t('services.deleted'), 'success')
    loadServices()
  } catch (err) {
    Swal.fire(t('common.error'), err.response?.data?.message || t('services.deleteError'), 'error')
  }
}

/* ----------  Modal Editar  ---------- */
const openEditModal = (service) => {
  form.value = { ...service, image: null }
  previewImage.value = getImageUrl(service.image_url)
  showModal.value = true
}

const closeEditModal = () => {
  showModal.value = false
  form.value = { id: null, title: '', description: '', service_details: '', price: 0, category: '', location: '', image: null }
  previewImage.value = ''
}

const triggerFilePicker = () => fileInput.value.click()

const handleDrop = (e) => {
  const file = e.dataTransfer.files[0]
  if (file) onImageChange({ target: { files: [file] } })
}

const onImageChange = (e) => {
  const file = e.target.files[0]
  if (file) {
    form.value.image = file
    previewImage.value = URL.createObjectURL(file)
  }
}

const updateService = async () => {
  const formData = new FormData()
  formData.append('id', String(form.value.id))
  formData.append('title', form.value.title)
  formData.append('description', form.value.description)
  formData.append('service_details', form.value.service_details ?? '')
  formData.append('price', String(form.value.price))
  formData.append('category', form.value.category)
  formData.append('location', form.value.location)

  if (form.value.image) formData.append('image', form.value.image)

  try {
    await api.post('/services/update', formData, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    Swal.fire(t('common.success'), t('services.updated'), 'success')
    closeEditModal()
    loadServices()
  } catch (err) {
    Swal.fire(t('common.error'), err.response?.data?.error || t('services.updateError'), 'error')
  }
}
const hasPaymentMethods = ref(true)

// Verificar métodos de pago al cargar
const checkPaymentMethods = async () => {
  try {
    const { data } = await api.get('/payments/public', {
      params: { provider_id: authStore.user?.id }
    })
    const info = data?.paymentInfo || {}
    hasPaymentMethods.value = !!(info.pagoMovil || info.transferencia || info.zelle || info.paypal)
  } catch { hasPaymentMethods.value = false }
}


onMounted(loadServices)
checkPaymentMethods()
</script>

<style scoped>
.warning-banner {
  background: linear-gradient(135deg, #fff3e0, #ffe0b2);
  border: 1px solid #ffb74d;
  border-radius: 12px;
  padding: 16px 20px;
  display: flex;
  align-items: center;
  gap: 14px;
  margin-bottom: 20px;
}
.warning-icon { font-size: 2rem; }
.warning-content h3 { margin: 0 0 4px; color: #e65100; }
.warning-content p { margin: 0; color: #bf360c; font-size: 0.9rem; }
.warning-link {
  display: inline-block;
  margin-top: 8px;
  color: #667eea;
  font-weight: 600;
  text-decoration: none;
}

.my-services-page {
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

.services-icon {
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

.btn-create {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 14px 28px;
  border-radius: 12px;
  text-decoration: none;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: transform 0.3s, box-shadow 0.3s;
  border: none;
  cursor: pointer;
  font-size: 1rem;
}

.btn-create:hover {
  transform: translateY(-3px);
  box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
}

/* Services Grid */
.services-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 32px;
  margin-bottom: 40px;
}

.service-card {
  background: white;
  border-radius: 20px;
  overflow: hidden;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
  transition: all 0.4s;
  cursor: pointer;
  border: 1px solid #f1f2f6;
  position: relative;
}

.service-card:hover {
  transform: translateY(-10px);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
}

/* Badge */
.card-badge {
  position: absolute;
  top: 16px;
  left: 16px;
  padding: 6px 16px;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
  z-index: 2;
}

.status-pending {
  background: linear-gradient(135deg, #fdcb6e 0%, #e17055 100%);
  color: white;
}

.status-approved {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
  color: white;
}

.status-rejected {
  background: linear-gradient(135deg, #ff7675 0%, #d63031 100%);
  color: white;
}

.status-default {
  background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%);
  color: white;
}

/* Image */
.card-image {
  height: 200px;
  overflow: hidden;
  position: relative;
}

.card-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.5s;
}

.service-card:hover .card-image img {
  transform: scale(1.05);
}

.card-image.placeholder {
  background: linear-gradient(135deg, #a8edea 0%, #fed6e3 100%);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: #636e72;
}

.placeholder-icon {
  font-size: 3rem;
  margin-bottom: 12px;
}

/* Content */
.card-content {
  padding: 24px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.service-category {
  background: #dfe6e9;
  color: #2d3436;
  padding: 4px 12px;
  border-radius: 15px;
  font-size: 0.8rem;
  font-weight: 600;
}

.service-location {
  color: #636e72;
  font-size: 0.8rem;
  display: flex;
  align-items: center;
  gap: 4px;
}

.service-title {
  font-size: 1.4rem;
  color: #2d3436;
  margin-bottom: 12px;
  line-height: 1.3;
}

.service-description {
  color: #636e72;
  font-size: 0.95rem;
  line-height: 1.5;
  margin-bottom: 16px;
}

.service-details-preview {
  background: #f8f9fa;
  padding: 10px 14px;
  border-radius: 10px;
  margin-bottom: 20px;
  display: flex;
  align-items: center;
  gap: 10px;
  color: #636e72;
  font-size: 0.9rem;
}

.details-icon {
  font-size: 1rem;
}

/* Footer */
.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.price-section {
  display: flex;
  flex-direction: column;
}

.price {
  font-size: 1.8rem;
  font-weight: 700;
  color: #00b894;
}

.price-label {
  color: #636e72;
  font-size: 0.8rem;
}

.btn-delete {
  background: #ff7675;
  color: white;
  border: none;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  cursor: pointer;
  font-size: 1.2rem;
  transition: all 0.3s;
  display: flex;
  align-items: center;
  justify-content: center;
}

.btn-delete:hover {
  background: #d63031;
  transform: rotate(15deg);
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

.btn-primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 14px 32px;
  border-radius: 10px;
  text-decoration: none;
  font-weight: 600;
  display: inline-block;
  transition: transform 0.3s, box-shadow 0.3s;
}

.btn-primary:hover {
  transform: translateY(-3px);
  box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
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
  padding: 20px;
}

.modal {
  background: white;
  border-radius: 24px;
  overflow: hidden;
  max-width: 800px;
  width: 100%;
  max-height: 90vh;
  display: flex;
  flex-direction: column;
  box-shadow: 0 25px 50px rgba(0, 0, 0, 0.25);
}

.modal-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 24px 32px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-header h2 {
  font-size: 1.8rem;
  display: flex;
  align-items: center;
  gap: 12px;
}

.btn-close {
  background: rgba(255, 255, 255, 0.2);
  color: white;
  border: none;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  cursor: pointer;
  font-size: 1.5rem;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background 0.3s;
}

.btn-close:hover {
  background: rgba(255, 255, 255, 0.3);
}

/* Form */
.modal-form {
  padding: 32px;
  overflow-y: auto;
  flex: 1;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 24px;
  margin-bottom: 32px;
}

.form-group {
  display: flex;
  flex-direction: column;
}

.form-group.full-width {
  grid-column: 1 / -1;
}

.form-label {
  font-weight: 600;
  color: #2d3436;
  margin-bottom: 8px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.label-icon {
  font-size: 1.1rem;
}

.char-count {
  margin-left: auto;
  font-size: 0.85rem;
  color: #636e72;
  font-weight: normal;
}

.form-input, .form-textarea {
  padding: 14px;
  border: 2px solid #dfe6e9;
  border-radius: 12px;
  font-size: 1rem;
  transition: border-color 0.3s;
  background: #f8f9fa;
}

.form-input:focus, .form-textarea:focus {
  outline: none;
  border-color: #667eea;
  background: white;
}

.form-textarea {
  resize: vertical;
  min-height: 80px;
}

.details-textarea {
  min-height: 120px;
}

/* Price Input */
.price-input-group {
  position: relative;
  display: flex;
  align-items: center;
}

.currency {
  position: absolute;
  left: 14px;
  font-size: 1.2rem;
  font-weight: 600;
  color: #00b894;
}

.price-input {
  padding-left: 36px;
}

/* Image Upload */
.image-upload-area {
  border: 2px dashed #b2bec3;
  border-radius: 16px;
  padding: 40px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s;
  background: #f8f9fa;
}

.image-upload-area:hover {
  border-color: #667eea;
  background: #edf2f7;
}

.upload-icon {
  width: 60px;
  height: 60px;
  margin: 0 auto 20px;
  color: #b2bec3;
}

.upload-icon svg {
  width: 100%;
  height: 100%;
}

.upload-text {
  color: #636e72;
  margin-bottom: 8px;
  font-size: 1.1rem;
}

.upload-click {
  color: #667eea;
  font-weight: 600;
}

.upload-hint {
  color: #b2bec3;
  font-size: 0.9rem;
}

.image-preview-container {
  display: flex;
  justify-content: center;
}

.image-preview {
  text-align: center;
}

.preview-image {
  width: 200px;
  height: 150px;
  object-fit: cover;
  border-radius: 12px;
  margin-bottom: 16px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
}

.btn-change-image {
  background: #74b9ff;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 8px;
  margin: 0 auto;
  transition: background 0.3s;
}

.btn-change-image:hover {
  background: #0984e3;
}

.hidden-input {
  display: none;
}

/* Modal Actions */
.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 16px;
  padding-top: 24px;
  border-top: 1px solid #dfe6e9;
}

.btn-cancel {
  background: #dfe6e9;
  color: #2d3436;
  border: none;
  padding: 14px 32px;
  border-radius: 12px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s;
}

.btn-cancel:hover {
  background: #b2bec3;
}

.btn-save {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
  color: white;
  border: none;
  padding: 14px 32px;
  border-radius: 12px;
  cursor: pointer;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: transform 0.3s, box-shadow 0.3s;
}

.btn-save:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 20px rgba(0, 184, 148, 0.3);
}

/* Toast */
.toast {
  position: fixed;
  bottom: 24px;
  right: 24px;
  padding: 16px 24px;
  border-radius: 12px;
  color: white;
  font-weight: 600;
  z-index: 1001;
  animation: slideIn 0.3s ease-out;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
}

.toast.success {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
}

.toast.error {
  background: linear-gradient(135deg, #ff7675 0%, #d63031 100%);
}

.toast.info {
  background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%);
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

/* Responsive */
@media (max-width: 1200px) {
  .services-grid {
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  }
}

@media (max-width: 768px) {
  .my-services-page {
    padding: 16px;
  }
  
  .header {
    flex-direction: column;
    align-items: stretch;
  }
  
  .title-section h1 {
    font-size: 2rem;
  }
  
  .services-grid {
    grid-template-columns: 1fr;
    gap: 24px;
  }
  
  .form-grid {
    grid-template-columns: 1fr;
  }
  
  .modal {
    margin: 10px;
  }
  
  .modal-header, .modal-form {
    padding: 20px;
  }
}

@media (max-width: 480px) {
  .title-section h1 {
    font-size: 1.8rem;
  }
  
  .btn-create, .btn-primary {
    width: 100%;
    justify-content: center;
  }
  
  .modal-actions {
    flex-direction: column;
  }
  
  .btn-cancel, .btn-save {
    width: 100%;
    justify-content: center;
  }
}
</style>
