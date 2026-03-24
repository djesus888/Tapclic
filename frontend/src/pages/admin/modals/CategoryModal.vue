<!-- src/components/admin/modals/CategoryModal.vue -->
<template>
  <div class="modal-overlay" @click.self="close">
    <div class="modal">
      <div class="modal-header">
        <h2>{{ category?.id ? '✏️ Editar Categoría' : '➕ Crear Categoría' }}</h2>
        <button class="close-btn" @click="close">×</button>
      </div>

      <div class="modal-content">
        <form @submit.prevent="save">
          <div class="form-group">
            <label class="form-label required">Nombre</label>
            <input
              type="text"
              v-model="formData.name"
              required
              placeholder="Ej: Limpieza"
              class="form-input"
              :disabled="loading"
            >
          </div>

          <div class="form-group">
            <label class="form-label">Descripción</label>
            <textarea
              v-model="formData.description"
              placeholder="Descripción de la categoría..."
              rows="3"
              class="form-input"
              :disabled="loading"
            ></textarea>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="form-label">Icono</label>
              <div class="icon-selector">
                <button
                  type="button"
                  v-for="icon in availableIcons"
                  :key="icon"
                  class="icon-option"
                  :class="{ selected: formData.icon === icon }"
                  @click="formData.icon = icon"
                  :disabled="loading"
                >
                  {{ icon }}
                </button>
              </div>
            </div>

            <div class="form-group">
              <label class="form-label">Color</label>
              <div class="color-picker">
                <input
                  type="color"
                  v-model="formData.color"
                  class="color-input"
                  :disabled="loading"
                >
                <input
                  type="text"
                  v-model="formData.color"
                  placeholder="#667eea"
                  class="color-text"
                  :disabled="loading"
                  @input="validateColor"
                >
              </div>
            </div>
          </div>

          <div v-if="category?.id" class="form-group">
            <label class="form-label">Estado</label>
            <label class="toggle-switch">
              <input
                type="checkbox"
                v-model="formData.is_active"
                :true-value="1"
                :false-value="0"
                :disabled="loading"
              >
              <span class="toggle-slider"></span>
              <span class="toggle-label">
                {{ formData.is_active == 1 ? 'Activa' : 'Inactiva' }}
              </span>
            </label>
          </div>

          <div class="modal-actions">
            <button 
              type="button" 
              class="btn-cancel" 
              @click="close"
              :disabled="loading"
            >
              Cancelar
            </button>
            <button 
              type="submit" 
              class="btn-save" 
              :disabled="loading || !formData.name.trim()"
            >
              {{ loading ? 'Guardando...' : (category?.id ? 'Actualizar' : 'Crear') }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, onMounted } from 'vue'

const props = defineProps({
  category: {
    type: Object,
    default: () => null
  }
})

const emit = defineEmits(['save', 'close'])

const loading = ref(false)
const formData = ref({
  name: '',
  description: '',
  icon: '📦',
  color: '#667eea',
  is_active: 1
})

const availableIcons = ['🧹', '🔧', '📚', '🏥', '💅', '🍕', '🚗', '💻', '🎉', '📦']

// Inicializar formulario cuando cambia la categoría
watch(() => props.category, (newCategory) => {
  if (newCategory?.id) {
    // Modo edición: cargar datos existentes
    formData.value = {
      name: newCategory.name || '',
      description: newCategory.description || '',
      icon: newCategory.icon || '📦',
      color: newCategory.color || '#667eea',
      is_active: newCategory.is_active !== undefined ? newCategory.is_active : 1
    }
  } else {
    // Modo creación: resetear formulario
    resetForm()
  }
}, { immediate: true })

// Función para resetear formulario
function resetForm() {
  formData.value = {
    name: '',
    description: '',
    icon: '📦',
    color: '#667eea',
    is_active: 1
  }
}

// Validar formato de color
function validateColor(event) {
  const value = event.target.value
  if (!value.startsWith('#')) {
    formData.value.color = '#' + value.replace(/^#/, '')
  }
}

// Guardar categoría
async function save() {
  if (!formData.value.name.trim()) {
    alert('El nombre es requerido')
    return
  }

  loading.value = true
  try {
    // Preparar datos para enviar
    const categoryData = {
      ...formData.value,
      name: formData.value.name.trim(),
      description: formData.value.description.trim()
    }

    // Si estamos editando, añadir el ID
    if (props.category?.id) {
      categoryData.id = props.category.id
    }

    // Emitir evento para guardar
    emit('save', categoryData)
  } catch (error) {
    console.error('Error al guardar categoría:', error)
    alert('Error al guardar la categoría. Por favor, inténtalo de nuevo.')
  } finally {
    loading.value = false
  }
}

// Cerrar modal
function close() {
  if (!loading.value) {
    emit('close')
  }
}

// Tecla ESC para cerrar
onMounted(() => {
  const handleEsc = (event) => {
    if (event.key === 'Escape' && !loading.value) {
      close()
    }
  }
  
  window.addEventListener('keydown', handleEsc)
  
  return () => {
    window.removeEventListener('keydown', handleEsc)
  }
})
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
}

.modal {
  background: white;
  border-radius: 20px;
  width: 90%;
  max-width: 500px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px 32px;
  border-bottom: 2px solid #e2e8f0;
}

.modal-header h2 {
  font-size: 1.5rem;
  color: #2d3436;
  margin: 0;
  display: flex;
  align-items: center;
  gap: 8px;
}

.close-btn {
  background: none;
  border: none;
  font-size: 2rem;
  cursor: pointer;
  color: #94a3b8;
  padding: 4px;
  line-height: 1;
}

.close-btn:hover {
  color: #2d3436;
}

.modal-content {
  padding: 32px;
}

.form-group {
  margin-bottom: 24px;
}

.form-label {
  display: block;
  font-weight: 600;
  color: #2d3436;
  margin-bottom: 8px;
}

.form-label.required::after {
  content: '*';
  color: #ff6b6b;
  margin-left: 4px;
}

.form-input {
  width: 100%;
  padding: 14px 16px;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  font-size: 1rem;
  transition: all 0.3s;
}

.form-input:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
}

.icon-selector {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.icon-option {
  width: 44px;
  height: 44px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  background: white;
  cursor: pointer;
  font-size: 1.5rem;
  transition: all 0.3s;
}

.icon-option:hover {
  border-color: #667eea;
  transform: translateY(-2px);
}

.icon-option.selected {
  border-color: #667eea;
  background: rgba(102, 126, 234, 0.1);
}

.color-picker {
  display: flex;
  gap: 12px;
  align-items: center;
}

.color-input {
  width: 60px;
  height: 60px;
  border: none;
  border-radius: 12px;
  cursor: pointer;
  border: 2px solid #e2e8f0;
}

.color-text {
  flex: 1;
  padding: 14px 16px;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  font-family: monospace;
}

.toggle-switch {
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
}

.toggle-switch input {
  opacity: 0;
  width: 0;
  height: 0;
}

.toggle-slider {
  position: relative;
  display: inline-block;
  width: 50px;
  height: 26px;
  background: #e2e8f0;
  border-radius: 34px;
  transition: .4s;
}

.toggle-slider:before {
  position: absolute;
  content: "";
  height: 18px;
  width: 18px;
  left: 4px;
  bottom: 4px;
  background: white;
  transition: .4s;
  border-radius: 50%;
}

input:checked + .toggle-slider {
  background: #667eea;
}

input:checked + .toggle-slider:before {
  transform: translateX(24px);
}

.modal-actions {
  display: flex;
  gap: 12px;
  margin-top: 32px;
}

.btn-cancel, .btn-save {
  flex: 1;
  padding: 16px 24px;
  border-radius: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  border: none;
}

.btn-cancel {
  background: #f1f5f9;
  color: #4a5568;
  border: 2px solid #e2e8f0;
}

.btn-cancel:hover {
  background: #e2e8f0;
  color: #2d3436;
}

.btn-save {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.btn-save:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
}

.btn-save:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
</style>
