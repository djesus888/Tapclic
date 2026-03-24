<!-- src/components/admin/modals/BlockModal.vue -->
<template>
  <div class="modal-overlay" @click.self="closeModal">
    <div class="modal-content block-modal">
      <div class="modal-header">
        <h2 class="modal-title">
          <span class="modal-icon">{{ isEditing ? '✏️' : '🧱' }}</span>
          {{ isEditing ? 'Editar Bloque' : 'Crear Nuevo Bloque' }}
        </h2>
        <button class="modal-close" @click="closeModal">×</button>
      </div>

      <div class="modal-body">
        <!-- Formulario -->
        <form @submit.prevent="handleSubmit" class="block-form">
          <!-- Tipo de Bloque -->
          <div class="form-group">
            <label class="form-label required">
              <span class="label-icon">📋</span>
              Tipo de Bloque
            </label>
            <div class="block-type-selector">
              <div 
                v-for="type in blockTypes" 
                :key="type.value"
                class="type-option"
                :class="{ selected: form.type === type.value }"
                @click="form.type = type.value"
              >
                <span class="type-icon">{{ type.icon }}</span>
                <span class="type-name">{{ type.label }}</span>
              </div>
            </div>
          </div>

          <!-- Nombre del Bloque -->
          <div class="form-group">
            <label class="form-label required">
              <span class="label-icon">🏷️</span>
              Nombre del Bloque
            </label>
            <input
              type="text"
              v-model="form.name"
              placeholder="Ej: Banner Principal, Texto de Bienvenida"
              class="form-input"
              required
            />
            <p class="form-help">Nombre descriptivo para identificar el bloque</p>
          </div>

          <!-- Identificador -->
          <div class="form-group">
            <label class="form-label required">
              <span class="label-icon">🔤</span>
              Identificador Único
            </label>
            <input
              type="text"
              v-model="form.identifier"
              placeholder="Ej: home_banner, welcome_text, footer_info"
              class="form-input"
              required
              :class="{ error: identifierError }"
            />
            <p class="form-help" :class="{ error: identifierError }">
              {{ identifierError || 'Identificador único para usar en el código (solo letras, números y guiones bajos)' }}
            </p>
          </div>

          <!-- Contenido -->
          <div class="form-group">
            <label class="form-label required">
              <span class="label-icon">📝</span>
              Contenido
            </label>
            
            <!-- Texto/HTML Simple -->
            <div v-if="form.type === 'text' || form.type === 'html'" class="content-editor">
              <textarea
                v-model="form.content"
                :rows="form.type === 'text' ? 6 : 10"
                :placeholder="form.type === 'text' ? 'Texto plano...' : 'Código HTML...'"
                class="form-textarea"
                required
              ></textarea>
              
              <div v-if="form.type === 'html'" class="editor-tools">
                <button type="button" class="tool-btn" @click="insertTag('h1')">H1</button>
                <button type="button" class="tool-btn" @click="insertTag('h2')">H2</button>
                <button type="button" class="tool-btn" @click="insertTag('p')">P</button>
                <button type="button" class="tool-btn" @click="insertTag('strong')">B</button>
                <button type="button" class="tool-btn" @click="insertTag('em')">I</button>
                <button type="button" class="tool-btn" @click="insertTag('a')">Link</button>
              </div>
            </div>

            <!-- Banner -->
            <div v-else-if="form.type === 'banner'" class="banner-editor">
              <div class="banner-preview" :style="previewStyle">
                <div class="preview-content">
                  <h3 v-if="bannerSettings.title">{{ bannerSettings.title }}</h3>
                  <p v-if="bannerSettings.subtitle">{{ bannerSettings.subtitle }}</p>
                  <button v-if="bannerSettings.button_text" class="preview-button">
                    {{ bannerSettings.button_text }}
                  </button>
                </div>
              </div>

              <div class="banner-fields">
                <div class="form-row">
                  <div class="form-col">
                    <label>Título</label>
                    <input
                      type="text"
                      v-model="bannerSettings.title"
                      placeholder="Título del banner"
                      class="form-input"
                    />
                  </div>
                  <div class="form-col">
                    <label>Subtítulo</label>
                    <input
                      type="text"
                      v-model="bannerSettings.subtitle"
                      placeholder="Subtítulo del banner"
                      class="form-input"
                    />
                  </div>
                </div>

                <div class="form-row">
                  <div class="form-col">
                    <label>Texto del Botón</label>
                    <input
                      type="text"
                      v-model="bannerSettings.button_text"
                      placeholder="Ej: Explorar Servicios"
                      class="form-input"
                    />
                  </div>
                  <div class="form-col">
                    <label>Enlace del Botón</label>
                    <input
                      type="text"
                      v-model="bannerSettings.button_link"
                      placeholder="/services"
                      class="form-input"
                    />
                  </div>
                </div>

                <div class="form-row">
                  <div class="form-col">
                    <label>Color de Fondo</label>
                    <input
                      type="color"
                      v-model="bannerSettings.background"
                      class="color-input"
                    />
                    <input
                      type="text"
                      v-model="bannerSettings.background"
                      placeholder="#667eea"
                      class="color-text"
                    />
                  </div>
                  <div class="form-col">
                    <label>Color de Texto</label>
                    <input
                      type="color"
                      v-model="bannerSettings.text_color"
                      class="color-input"
                    />
                    <input
                      type="text"
                      v-model="bannerSettings.text_color"
                      placeholder="#ffffff"
                      class="color-text"
                    />
                  </div>
                </div>
              </div>
            </div>

            <!-- Imagen -->
            <div v-else-if="form.type === 'image'" class="image-editor">
              <div class="image-upload-area" @click="triggerImageUpload">
                <div v-if="imagePreview" class="image-preview">
                  <img :src="imagePreview" alt="Vista previa" class="preview-img" />
                  <button type="button" class="remove-image" @click.stop="removeImage">
                    ×
                  </button>
                </div>
                <div v-else class="upload-placeholder">
                  <span class="upload-icon">🖼️</span>
                  <p>Haz clic para subir imagen</p>
                  <small>JPG, PNG o GIF (max 2MB)</small>
                </div>
                <input
                  type="file"
                  ref="imageInput"
                  @change="handleImageUpload"
                  accept="image/*"
                  class="hidden-input"
                />
              </div>

              <div v-if="imageFile" class="image-info">
                <div class="file-details">
                  <span class="file-name">{{ imageFile.name }}</span>
                  <span class="file-size">{{ formatFileSize(imageFile.size) }}</span>
                </div>
              </div>

              <div class="image-settings">
                <div class="form-row">
                  <div class="form-col">
                    <label>Alt Text</label>
                    <input
                      type="text"
                      v-model="imageSettings.alt"
                      placeholder="Texto alternativo"
                      class="form-input"
                    />
                  </div>
                  <div class="form-col">
                    <label>Enlace</label>
                    <input
                      type="text"
                      v-model="imageSettings.link"
                      placeholder="URL al hacer clic"
                      class="form-input"
                    />
                  </div>
                </div>
              </div>
            </div>

            <!-- Carousel -->
            <div v-else-if="form.type === 'carousel'" class="carousel-editor">
              <div class="carousel-items">
                <div 
                  v-for="(item, index) in carouselItems" 
                  :key="index"
                  class="carousel-item"
                >
                  <div class="item-header">
                    <span class="item-number">#{{ index + 1 }}</span>
                    <button 
                      type="button" 
                      class="item-remove"
                      @click="removeCarouselItem(index)"
                    >
                      ×
                    </button>
                  </div>
                  <div class="item-content">
                    <input
                      type="text"
                      v-model="item.title"
                      placeholder="Título"
                      class="form-input"
                    />
                    <textarea
                      v-model="item.description"
                      placeholder="Descripción"
                      rows="2"
                      class="form-textarea"
                    ></textarea>
                    <input
                      type="text"
                      v-model="item.image"
                      placeholder="URL de la imagen"
                      class="form-input"
                    />
                    <input
                      type="text"
                      v-model="item.link"
                      placeholder="Enlace"
                      class="form-input"
                    />
                  </div>
                </div>
              </div>

              <button type="button" class="btn-add-item" @click="addCarouselItem">
                ➕ Agregar Elemento
              </button>
            </div>
          </div>

          <!-- Configuración Avanzada -->
          <div class="form-group">
            <label class="form-label">
              <span class="label-icon">⚙️</span>
              Configuración Avanzada (JSON)
            </label>
            <div class="json-editor">
              <textarea
                v-model="jsonSettingsText"
                @input="updateJsonSettings"
                placeholder='{"key": "value"}'
                class="json-textarea"
                rows="4"
              ></textarea>
              <div class="json-tools">
                <button type="button" class="btn-format" @click="formatJson">
                  🔧 Formatear
                </button>
                <span class="json-status" :class="jsonValid ? 'valid' : 'invalid'">
                  {{ jsonValid ? '✅ JSON válido' : '❌ JSON inválido' }}
                </span>
              </div>
            </div>
          </div>

          <!-- Estado -->
          <div class="form-group">
            <label class="form-label">
              <span class="label-icon">📊</span>
              Estado del Bloque
            </label>
            <div class="toggle-group">
              <label class="toggle-switch">
                <input 
                  type="checkbox" 
                  v-model="form.is_active" 
                  true-value="1"
                  false-value="0"
                />
                <span class="toggle-slider"></span>
              </label>
              <span class="toggle-label">
                {{ form.is_active ? '✅ Bloque activo' : '❌ Bloque inactivo' }}
              </span>
            </div>
          </div>

          <!-- Errores -->
          <div v-if="formErrors.length > 0" class="form-errors">
            <div v-for="error in formErrors" :key="error" class="error-message">
              ❌ {{ error }}
            </div>
          </div>

          <!-- Acciones -->
          <div class="form-actions">
            <button type="button" class="btn-cancel" @click="closeModal">
              Cancelar
            </button>
            <button type="submit" class="btn-submit" :disabled="loading">
              <span v-if="loading" class="btn-loading"></span>
              <span v-else>{{ isEditing ? '💾 Guardar Cambios' : '➕ Crear Bloque' }}</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'

const emit = defineEmits(['save', 'close'])
const props = defineProps({
  block: {
    type: Object,
    default: () => ({})
  }
})

// Estados
const loading = ref(false)
const identifierError = ref('')
const formErrors = ref([])
const jsonValid = ref(true)

// Referencias
const imageInput = ref(null)
const imageFile = ref(null)
const imagePreview = ref(null)

// Tipos de bloque
const blockTypes = ref([
  { value: 'text', label: 'Texto', icon: '📝' },
  { value: 'html', label: 'HTML', icon: '📄' },
  { value: 'image', label: 'Imagen', icon: '🖼️' },
  { value: 'banner', label: 'Banner', icon: '🎪' },
  { value: 'carousel', label: 'Carrusel', icon: '🔄' }
])

// Formulario
const form = ref({
  name: '',
  identifier: '',
  type: 'text',
  content: '',
  settings: '{}',
  is_active: 1
})

// Configuraciones específicas
const bannerSettings = ref({
  title: '',
  subtitle: '',
  button_text: '',
  button_link: '',
  background: '#667eea',
  text_color: '#ffffff'
})

const imageSettings = ref({
  alt: '',
  link: '',
  width: '',
  height: ''
})

const carouselItems = ref([
  { title: '', description: '', image: '', link: '' }
])

// Computed
const isEditing = computed(() => !!props.block?.id)

const jsonSettingsText = computed({
  get() {
    try {
      if (!form.value.settings || form.value.settings.trim() === '') {
        return '{}'
      }
      return JSON.stringify(JSON.parse(form.value.settings), null, 2)
    } catch {
      return form.value.settings || '{}'
    }
  },
  set(value) {
    form.value.settings = value
  }
})

const previewStyle = computed(() => ({
  backgroundColor: bannerSettings.value.background,
  color: bannerSettings.value.text_color
}))

// Lifecycle
onMounted(() => {
  if (props.block?.id) {
    loadBlockData()
  }
})

// Watch
watch(() => form.value.identifier, validateIdentifier)
watch(() => form.value.type, handleTypeChange)

// Métodos
function loadBlockData() {
  const block = props.block
  form.value = { ...form.value, ...block }
  
  // Parsear settings según el tipo
  if (block.settings) {
    try {
      const settings = JSON.parse(block.settings)
      
      if (block.type === 'banner') {
        bannerSettings.value = { ...bannerSettings.value, ...settings }
      } else if (block.type === 'image') {
        imageSettings.value = { ...imageSettings.value, ...settings }
      } else if (block.type === 'carousel') {
        if (settings.items) {
          carouselItems.value = settings.items
        }
      }
    } catch (e) {
      console.error('Error parsing settings:', e)
    }
  }
  
  // Si es imagen y tiene content, mostrar preview
  if (block.type === 'image' && block.content) {
    imagePreview.value = block.content
  }
}

function handleTypeChange(newType) {
  // Reset content al cambiar tipo
  form.value.content = ''
  
  // Inicializar settings según tipo
  if (newType === 'banner') {
    form.value.settings = JSON.stringify(bannerSettings.value, null, 2)
  } else if (newType === 'image') {
    form.value.settings = JSON.stringify(imageSettings.value, null, 2)
  } else if (newType === 'carousel') {
    const settings = { items: carouselItems.value }
    form.value.settings = JSON.stringify(settings, null, 2)
  } else {
    form.value.settings = '{}'
  }
}

function validateIdentifier() {
  const identifier = form.value.identifier.trim()
  
  if (!identifier) {
    identifierError.value = ''
    return
  }
  
  // Validar formato (solo letras, números y guiones bajos)
  const pattern = /^[a-zA-Z0-9_]+$/
  if (!pattern.test(identifier)) {
    identifierError.value = 'Solo letras, números y guiones bajos (_)'
    return
  }
  
  identifierError.value = ''
}

function updateJsonSettings() {
  try {
    JSON.parse(form.value.settings || '{}')
    jsonValid.value = true
  } catch {
    jsonValid.value = false
  }
}

function formatJson() {
  try {
    const parsed = JSON.parse(form.value.settings || '{}')
    form.value.settings = JSON.stringify(parsed, null, 2)
    jsonValid.value = true
  } catch (e) {
    alert('No se puede formatear: JSON inválido')
  }
}

// Métodos para banners
function updateBannerSettings() {
  const settings = { ...bannerSettings.value }
  form.value.settings = JSON.stringify(settings, null, 2)
}

// Métodos para imágenes
function triggerImageUpload() {
  imageInput.value.click()
}

function handleImageUpload(event) {
  const file = event.target.files[0]
  if (!file) return
  
  // Validar tamaño (2MB máximo)
  if (file.size > 2 * 1024 * 1024) {
    alert('La imagen no debe superar 2MB')
    return
  }
  
  // Validar tipo
  const validTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp']
  if (!validTypes.includes(file.type)) {
    alert('Formato de imagen no válido. Use JPG, PNG o GIF')
    return
  }
  
  imageFile.value = file
  
  // Crear preview
  const reader = new FileReader()
  reader.onload = (e) => {
    imagePreview.value = e.target.result
    form.value.content = e.target.result // Guardar como base64 temporalmente
  }
  reader.readAsDataURL(file)
}

function removeImage() {
  imageFile.value = null
  imagePreview.value = null
  form.value.content = ''
  imageInput.value.value = ''
}

// Métodos para carrusel
function addCarouselItem() {
  carouselItems.value.push({
    title: '',
    description: '',
    image: '',
    link: ''
  })
}

function removeCarouselItem(index) {
  if (carouselItems.value.length > 1) {
    carouselItems.value.splice(index, 1)
  }
}

// Métodos para editor HTML
function insertTag(tag) {
  const textarea = document.querySelector('.form-textarea')
  const start = textarea.selectionStart
  const end = textarea.selectionEnd
  const selectedText = form.value.content.substring(start, end)
  
  let wrappedText = ''
  
  switch (tag) {
    case 'h1':
      wrappedText = `<h1>${selectedText || 'Título'}</h1>`
      break
    case 'h2':
      wrappedText = `<h2>${selectedText || 'Subtítulo'}</h2>`
      break
    case 'p':
      wrappedText = `<p>${selectedText || 'Párrafo'}</p>`
      break
    case 'strong':
      wrappedText = `<strong>${selectedText || 'texto'}</strong>`
      break
    case 'em':
      wrappedText = `<em>${selectedText || 'texto'}</em>`
      break
    case 'a':
      wrappedText = `<a href="#" target="_blank">${selectedText || 'enlace'}</a>`
      break
  }
  
  const newContent = form.value.content.substring(0, start) + 
                    wrappedText + 
                    form.value.content.substring(end)
  
  form.value.content = newContent
  
  // Restaurar foco
  setTimeout(() => {
    textarea.focus()
    const newCursorPos = start + wrappedText.length
    textarea.setSelectionRange(newCursorPos, newCursorPos)
  }, 0)
}

// Validación del formulario
function validateForm() {
  formErrors.value = []
  
  if (!form.value.name.trim()) {
    formErrors.value.push('El nombre es requerido')
  }
  
  if (!form.value.identifier.trim()) {
    formErrors.value.push('El identificador es requerido')
  } else if (identifierError.value) {
    formErrors.value.push(identifierError.value)
  }
  
  if (!form.value.content.trim() && form.value.type !== 'carousel') {
    formErrors.value.push('El contenido es requerido')
  }
  
  // Validar JSON
  if (!jsonValid.value) {
    formErrors.value.push('La configuración JSON no es válida')
  }
  
  return formErrors.value.length === 0
}

// Envío del formulario
async function handleSubmit() {
  if (!validateForm()) {
    return
  }
  
  loading.value = true
  
  try {
    // Preparar datos según el tipo
    const blockData = { ...form.value }
    
    // Preparar settings según el tipo
    if (blockData.type === 'banner') {
      const settings = { ...bannerSettings.value }
      blockData.settings = JSON.stringify(settings)
      blockData.content = JSON.stringify(settings) // Para búsqueda
    } else if (blockData.type === 'image') {
      const settings = { ...imageSettings.value }
      blockData.settings = JSON.stringify(settings)
      // El contenido es la imagen (base64 o URL)
    } else if (blockData.type === 'carousel') {
      const settings = { items: carouselItems.value }
      blockData.settings = JSON.stringify(settings)
      blockData.content = JSON.stringify(carouselItems.value.map(item => item.title))
    } else {
      // Para text/html, el settings es JSON
      try {
        JSON.parse(blockData.settings || '{}')
      } catch {
        blockData.settings = '{}'
      }
    }
    
    emit('save', blockData)
    
  } catch (error) {
    console.error('Error preparando datos:', error)
    formErrors.value.push('Error al preparar los datos')
  } finally {
    loading.value = false
  }
}

function closeModal() {
  emit('close')
}

function formatFileSize(bytes) {
  if (bytes === 0) return '0 Bytes'
  const k = 1024
  const sizes = ['Bytes', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
}
</script>


<style scoped>
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
  animation: fadeIn 0.3s ease-out;
  padding: 20px;
}

.block-modal {
  background: white;
  border-radius: 20px;
  width: 100%;
  max-width: 800px;
  max-height: 90vh;
  overflow-y: auto;
  animation: slideUp 0.3s ease-out;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes slideUp {
  from { transform: translateY(30px) scale(0.95); opacity: 0; }
  to { transform: translateY(0) scale(1); opacity: 1; }
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px 32px;
  border-bottom: 2px solid #e2e8f0;
  background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
  border-radius: 20px 20px 0 0;
}

.modal-title {
  font-size: 1.5rem;
  color: #2d3436;
  display: flex;
  align-items: center;
  gap: 12px;
  margin: 0;
  font-weight: 700;
}

.modal-icon {
  font-size: 1.8rem;
}

.modal-close {
  width: 40px;
  height: 40px;
  border: none;
  background: #f1f5f9;
  border-radius: 50%;
  font-size: 24px;
  color: #64748b;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  line-height: 1;
}

.modal-close:hover,
.modal-close:focus {
  background: #e2e8f0;
  color: #334155;
  transform: rotate(90deg);
  outline: 2px solid #667eea;
  outline-offset: 2px;
}

.modal-body {
  padding: 32px;
}

.block-form {
  display: flex;
  flex-direction: column;
  gap: 28px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.form-label {
  font-weight: 600;
  color: #2d3436;
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 1rem;
}

.form-label.required::after {
  content: '*';
  color: #ff6b6b;
  margin-left: 4px;
  font-size: 1.2em;
}

.label-icon {
  font-size: 1.2rem;
}

/* Selector de tipo */
.block-type-selector {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 16px;
}

.type-option {
  border: 2px solid #e2e8f0;
  border-radius: 16px;
  padding: 24px 16px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  text-align: center;
  background: white;
}

.type-option:hover {
  border-color: #cbd5e1;
  background: #f8fafc;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.type-option:focus {
  outline: 2px solid #667eea;
  outline-offset: 2px;
}

.type-option.selected {
  border-color: #667eea;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(102, 126, 234, 0.05) 100%);
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.15);
  transform: translateY(-2px);
}

.type-icon {
  font-size: 2.5rem;
  transition: transform 0.3s;
}

.type-option.selected .type-icon {
  transform: scale(1.1);
}

.type-name {
  font-weight: 700;
  font-size: 1rem;
  color: #4a5568;
  transition: color 0.3s;
}

.type-option.selected .type-name {
  color: #667eea;
}

/* Inputs */
.form-input, .form-textarea {
  padding: 16px 20px;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  font-size: 1rem;
  background: white;
  transition: all 0.3s;
  width: 100%;
  font-family: inherit;
}

.form-input:focus, 
.form-textarea:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.1);
}

.form-input:disabled,
.form-textarea:disabled {
  background: #f8fafc;
  cursor: not-allowed;
  opacity: 0.7;
}

.form-input.error {
  border-color: #ff6b6b;
}

.form-textarea {
  resize: vertical;
  min-height: 120px;
  line-height: 1.5;
}

.form-help {
  color: #64748b;
  font-size: 0.875rem;
  margin-top: 4px;
  line-height: 1.4;
}

/* Form Rows */
.form-row {
  display: grid;
  grid-template-columns: 1fr 2fr;
  gap: 20px;
}

.form-col {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

/* Toggle Switch */
.toggle-group {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  padding: 12px 16px;
  background: #f8fafc;
  border-radius: 12px;
  border: 2px solid #e2e8f0;
}

.toggle-text {
  font-weight: 700;
  font-size: 1rem;
  color: #2d3436;
}

.toggle-switch {
  position: relative;
  display: inline-block;
  width: 60px;
  height: 34px;
}

.toggle-switch input {
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
  background: linear-gradient(135deg, #e2e8f0 0%, #cbd5e1 100%);
  transition: .4s;
  border-radius: 34px;
}

.toggle-slider:before {
  position: absolute;
  content: "";
  height: 26px;
  width: 26px;
  left: 4px;
  bottom: 4px;
  background-color: white;
  transition: .4s;
  border-radius: 50%;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);
}

input:checked + .toggle-slider {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
}

input:checked + .toggle-slider:before {
  transform: translateX(26px);
}

input:disabled + .toggle-slider {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Security Grid */
.security-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 24px;
}

.security-item {
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding: 20px;
  background: #f8fafc;
  border-radius: 12px;
  border: 2px solid #e2e8f0;
  transition: all 0.3s;
}

.security-item:hover {
  border-color: #cbd5e1;
  background: white;
  transform: translateY(-2px);
}

.security-label {
  font-weight: 600;
  color: #2d3436;
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 1rem;
  cursor: pointer;
}

.security-label input[type="checkbox"] {
  width: 20px;
  height: 20px;
  cursor: pointer;
}

.security-help {
  color: #64748b;
  font-size: 0.875rem;
  line-height: 1.4;
  padding-left: 32px;
}

/* Action Footer */
.action-footer {
  display: flex;
  justify-content: flex-end;
  gap: 20px;
  margin-top: 40px;
  padding-top: 32px;
  border-top: 2px solid #e2e8f0;
}

.btn-discard {
  padding: 16px 32px;
  background: #f1f5f9;
  color: #4a5568;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  min-width: 140px;
  font-size: 1rem;
}

.btn-discard:hover:not(:disabled) {
  background: #e2e8f0;
  color: #2d3436;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.btn-discard:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  transform: none !important;
  box-shadow: none !important;
}

.btn-save {
  padding: 16px 32px;
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
  color: white;
  border: none;
  border-radius: 12px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.3s;
  min-width: 180px;
  font-size: 1rem;
  letter-spacing: 0.5px;
}

.btn-save:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(239, 68, 68, 0.3);
  background: linear-gradient(135deg, #dc2626 0%, #b91c1c 100%);
}

.btn-save:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  transform: none !important;
  box-shadow: none !important;
}

/* Responsive */
@media (max-width: 768px) {
  .modal-header {
    padding: 20px 24px;
  }

  .modal-body {
    padding: 24px;
  }

  .block-type-selector {
    grid-template-columns: 1fr;
  }

  .form-row {
    grid-template-columns: 1fr;
    gap: 16px;
  }

  .action-footer {
    flex-direction: column;
    gap: 16px;
  }

  .btn-discard, .btn-save {
    width: 100%;
    min-width: auto;
  }
  
  .modal-overlay {
    padding: 10px;
  }
}

@media (max-width: 480px) {
  .modal-title {
    font-size: 1.2rem;
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }

  .security-grid {
    grid-template-columns: 1fr;
  }

  .toggle-group {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }
  
  .block-form {
    gap: 24px;
  }
  
  .modal-close {
    width: 36px;
    height: 36px;
    font-size: 20px;
  }
}
</style>
