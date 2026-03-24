<!-- src/components/admin/modals/PageModal.vue -->
<template>
  <div class="modal-overlay" @click.self="closeModal">
    <div class="modal-container">
      <div class="modal-header">
        <h2>{{ page?.id ? '✏️ Editar Página' : '📄 Crear Nueva Página' }}</h2>
        <button class="modal-close" @click="closeModal">×</button>
      </div>

      <form @submit.prevent="handleSubmit" class="modal-form">
        <!-- Título -->
        <div class="form-group">
          <label class="form-label required">
            Título de la Página
          </label>
          <input
            type="text"
            v-model="formData.title"
            required
            placeholder="Ej: Términos y Condiciones"
            class="form-input"
            maxlength="200"
          >
          <div class="char-counter">{{ formData.title.length }}/200</div>
        </div>

        <!-- Slug -->
        <div class="form-group">
          <label class="form-label required">
            URL (Slug)
          </label>
          <div class="input-with-prefix">
            <span class="input-prefix">/</span>
            <input
              type="text"
              v-model="formData.slug"
              required
              placeholder="terms"
              class="form-input"
              pattern="[a-z0-9-]+"
              title="Solo letras minúsculas, números y guiones"
              @input="formatSlug"
            >
          </div>
          <p class="form-help">
            Solo letras minúsculas, números y guiones. Ej: privacy-policy
          </p>
        </div>

        <!-- Contenido -->
        <div class="form-group">
          <label class="form-label required">
            Contenido
          </label>
          <div class="editor-toolbar">
            <button type="button" @click="insertTag('<strong>', '</strong>')" title="Negrita">
              <strong>B</strong>
            </button>
            <button type="button" @click="insertTag('<em>', '</em>')" title="Itálica">
              <em>I</em>
            </button>
            <button type="button" @click="insertTag('<h2>', '</h2>')" title="Título">
              H2
            </button>
            <button type="button" @click="insertTag('<p>', '</p>')" title="Párrafo">
              P
            </button>
            <button type="button" @click="insertTag('<ul><li>', '</li></ul>')" title="Lista">
              • Lista
            </button>
            <button type="button" @click="insertLink()" title="Enlace">
              🔗
            </button>
          </div>
          <textarea
            v-model="formData.content"
            required
            placeholder="Escribe el contenido de la página aquí..."
            rows="12"
            class="form-textarea"
            ref="contentTextarea"
          ></textarea>
          <div class="char-counter">{{ formData.content.length }}/10000</div>
        </div>

        <!-- SEO -->
        <div class="form-section">
          <h3 class="section-title">🔍 SEO</h3>
          <div class="form-group">
            <label class="form-label">
              Meta Título
            </label>
            <input
              type="text"
              v-model="formData.meta_title"
              placeholder="Optimizado para motores de búsqueda"
              class="form-input"
              maxlength="200"
            >
            <div class="char-counter">{{ formData.meta_title?.length || 0 }}/200</div>
          </div>

          <div class="form-group">
            <label class="form-label">
              Meta Descripción
            </label>
            <textarea
              v-model="formData.meta_description"
              placeholder="Descripción que aparece en Google..."
              rows="3"
              class="form-textarea"
              maxlength="500"
            ></textarea>
            <div class="char-counter">{{ formData.meta_description?.length || 0 }}/500</div>
          </div>

          <div class="form-group">
            <label class="form-label">
              Palabras Clave
            </label>
            <input
              type="text"
              v-model="formData.meta_keywords"
              placeholder="servicios, profesionales, confiable, rápido"
              class="form-input"
            >
            <p class="form-help">Separadas por comas</p>
          </div>
        </div>

        <!-- Configuración -->
        <div class="form-section">
          <h3 class="section-title">⚙️ Configuración</h3>
          <div class="checkbox-group">
            <label class="checkbox-label">
              <input type="checkbox" v-model="formData.is_active" true-value="1" false-value="0">
              <span class="checkbox-custom"></span>
              <span>Página activa (visible para usuarios)</span>
            </label>

            <label class="checkbox-label">
              <input type="checkbox" v-model="formData.is_in_menu" true-value="1" false-value="0">
              <span class="checkbox-custom"></span>
              <span>Mostrar en menú de navegación</span>
            </label>
          </div>

          <div class="form-group">
            <label class="form-label">
              Orden en Menú
            </label>
            <input
              type="number"
              v-model.number="formData.sort_order"
              min="0"
              max="100"
              class="form-input small"
            >
            <p class="form-help">Número menor = aparece primero</p>
          </div>
        </div>

        <!-- Previsualización -->
        <div class="form-section" v-if="formData.content">
          <h3 class="section-title">👁️ Vista Previa</h3>
          <div class="preview-container">
            <div class="preview-content" v-html="formatPreview(formData.content)"></div>
          </div>
        </div>

        <!-- Acciones -->
        <div class="modal-actions">
          <button type="button" class="btn-cancel" @click="closeModal">
            Cancelar
          </button>
          <button type="submit" class="btn-save" :disabled="loading">
            <span v-if="loading" class="save-loading"></span>
            <span v-else>{{ page?.id ? '💾 Guardar Cambios' : '📄 Crear Página' }}</span>
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'

const props = defineProps({
  page: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['save', 'close'])

// Estados
const loading = ref(false)
const contentTextarea = ref(null)

// Datos del formulario
const formData = ref({
  title: '',
  slug: '',
  content: '',
  meta_title: '',
  meta_description: '',
  meta_keywords: '',
  is_active: 1,
  is_in_menu: 0,
  sort_order: 0
})

// Inicializar con datos de props
onMounted(() => {
  if (props.page?.id) {
    formData.value = { ...props.page }
    // Asegurar valores booleanos como strings para los checkboxes
    formData.value.is_active = props.page.is_active ? '1' : '0'
    formData.value.is_in_menu = props.page.is_in_menu ? '1' : '0'
  }
})

// Métodos
function formatSlug(event) {
  let value = event.target.value
  // Convertir a minúsculas, reemplazar espacios y caracteres especiales
  value = value.toLowerCase()
    .replace(/[^a-z0-9-]/g, '-')  // Solo letras, números y guiones
    .replace(/-+/g, '-')          // No guiones múltiples consecutivos
    .replace(/^-|-$/g, '')        // No guiones al inicio o final
  formData.value.slug = value
}

function insertTag(startTag, endTag) {
  const textarea = contentTextarea.value
  if (!textarea) return
  
  const start = textarea.selectionStart
  const end = textarea.selectionEnd
  const text = textarea.value
  const selectedText = text.substring(start, end)
  
  // Insertar tags alrededor del texto seleccionado
  const newText = text.substring(0, start) + startTag + selectedText + endTag + text.substring(end)
  formData.value.content = newText
  
  // Restaurar foco y posición del cursor
  setTimeout(() => {
    textarea.focus()
    const newCursorPos = start + startTag.length + selectedText.length + endTag.length
    textarea.setSelectionRange(newCursorPos, newCursorPos)
  }, 0)
}

function insertLink() {
  const url = prompt('Ingresa la URL del enlace:')
  if (!url) return
  
  const text = prompt('Ingresa el texto del enlace (opcional):', url)
  const linkText = text || url
  
  const startTag = `<a href="${url}" target="_blank">`
  const endTag = '</a>'
  insertTag(startTag, endTag)
}

function formatPreview(content) {
  // Convertir saltos de línea a <br> y escape básico
  return content
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/\n/g, '<br>')
    .replace(/&lt;(strong|em|h[1-6]|p|ul|ol|li|a|br|span|div)&gt;/g, '<$1>')
    .replace(/&lt;\/(strong|em|h[1-6]|p|ul|ol|li|a|br|span|div)&gt;/g, '</$1>')
    .replace(/&lt;a href="([^"]+)" target="_blank"&gt;/g, '<a href="$1" target="_blank">')
}

function handleSubmit() {
  // Validaciones
  if (!formData.value.title.trim()) {
    alert('El título es requerido')
    return
  }
  
  if (!formData.value.slug.trim()) {
    alert('El slug es requerido')
    return
  }
  
  if (!formData.value.content.trim()) {
    alert('El contenido es requerido')
    return
  }
  
  // Enviar datos
  loading.value = true
  emit('save', {
    ...formData.value,
    // Convertir strings '1'/'0' a números 1/0 para el backend
    is_active: parseInt(formData.value.is_active),
    is_in_menu: parseInt(formData.value.is_in_menu)
  })
  loading.value = false
}

function closeModal() {
  emit('close')
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
}

.modal-container {
  background: white;
  border-radius: 20px;
  width: 90%;
  max-width: 800px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 25px 50px rgba(0, 0, 0, 0.25);
  animation: slideUp 0.4s ease-out;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes slideUp {
  from {
    transform: translateY(20px);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px 32px;
  border-bottom: 2px solid #e2e8f0;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 20px 20px 0 0;
}

.modal-header h2 {
  margin: 0;
  font-size: 1.5rem;
  display: flex;
  align-items: center;
  gap: 12px;
}

.modal-close {
  background: rgba(255, 255, 255, 0.2);
  border: none;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  color: white;
  font-size: 24px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s;
}

.modal-close:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: rotate(90deg);
}

.modal-form {
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

.form-input, .form-textarea {
  width: 100%;
  padding: 14px 16px;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  font-size: 1rem;
  background: white;
  transition: all 0.3s;
}

.form-input:focus, .form-textarea:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.form-input.small {
  max-width: 100px;
}

.form-textarea {
  resize: vertical;
  min-height: 150px;
  font-family: 'Inter', sans-serif;
}

.char-counter {
  text-align: right;
  color: #636e72;
  font-size: 0.85rem;
  margin-top: 4px;
}

.input-with-prefix {
  display: flex;
  align-items: center;
}

.input-prefix {
  background: #f1f5f9;
  padding: 14px 16px;
  border: 2px solid #e2e8f0;
  border-right: none;
  border-radius: 12px 0 0 12px;
  color: #4a5568;
  font-weight: 500;
}

.input-with-prefix .form-input {
  border-radius: 0 12px 12px 0;
}

.form-help {
  color: #636e72;
  font-size: 0.9rem;
  margin-top: 4px;
}

/* Editor Toolbar */
.editor-toolbar {
  display: flex;
  gap: 8px;
  margin-bottom: 12px;
  flex-wrap: wrap;
}

.editor-toolbar button {
  padding: 8px 12px;
  background: #f1f5f9;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  cursor: pointer;
  font-size: 0.9rem;
  font-weight: 600;
  transition: all 0.3s;
  display: flex;
  align-items: center;
  gap: 4px;
}

.editor-toolbar button:hover {
  background: #e2e8f0;
  border-color: #667eea;
  transform: translateY(-2px);
}

.editor-toolbar button strong {
  font-weight: 700;
}

.editor-toolbar button em {
  font-style: italic;
}

/* Form Sections */
.form-section {
  margin-top: 32px;
  padding-top: 24px;
  border-top: 2px solid #f1f5f9;
}

.section-title {
  font-size: 1.2rem;
  color: #2d3436;
  margin-bottom: 20px;
  display: flex;
  align-items: center;
  gap: 8px;
}

/* Checkboxes */
.checkbox-group {
  display: flex;
  flex-direction: column;
  gap: 16px;
  margin-bottom: 24px;
}

.checkbox-label {
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
  color: #4a5568;
}

.checkbox-label input[type="checkbox"] {
  display: none;
}

.checkbox-custom {
  width: 20px;
  height: 20px;
  border: 2px solid #cbd5e1;
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s;
  flex-shrink: 0;
}

.checkbox-label input[type="checkbox"]:checked + .checkbox-custom {
  background: #667eea;
  border-color: #667eea;
}

.checkbox-label input[type="checkbox"]:checked + .checkbox-custom::after {
  content: '✓';
  color: white;
  font-weight: bold;
  font-size: 14px;
}

.checkbox-label:hover .checkbox-custom {
  border-color: #667eea;
}

/* Preview */
.preview-container {
  background: #f8fafc;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  padding: 24px;
  max-height: 200px;
  overflow-y: auto;
}

.preview-content {
  line-height: 1.6;
  color: #2d3436;
}

.preview-content h1, .preview-content h2, .preview-content h3 {
  margin-top: 0;
  color: #2d3436;
}

.preview-content p {
  margin-bottom: 16px;
}

.preview-content ul, .preview-content ol {
  padding-left: 20px;
  margin-bottom: 16px;
}

.preview-content a {
  color: #667eea;
  text-decoration: none;
}

.preview-content a:hover {
  text-decoration: underline;
}

/* Modal Actions */
.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 16px;
  margin-top: 32px;
  padding-top: 24px;
  border-top: 2px solid #e2e8f0;
}

.btn-cancel, .btn-save {
  padding: 14px 28px;
  border-radius: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  border: none;
  min-width: 140px;
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
  position: relative;
}

.btn-save:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
}

.btn-save:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.save-loading {
  width: 20px;
  height: 20px;
  border: 3px solid rgba(255, 255, 255, 0.3);
  border-top: 3px solid white;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  display: inline-block;
  margin-right: 8px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* Responsive */
@media (max-width: 768px) {
  .modal-container {
    width: 95%;
    padding: 0;
  }
  
  .modal-form {
    padding: 24px;
  }
  
  .modal-actions {
    flex-direction: column;
  }
  
  .btn-cancel, .btn-save {
    width: 100%;
  }
}

@media (max-width: 480px) {
  .modal-header {
    padding: 20px;
  }
  
  .modal-form {
    padding: 20px;
  }
  
  .editor-toolbar {
    justify-content: center;
  }
  
  .editor-toolbar button {
    flex: 1;
    justify-content: center;
  }
}
</style>
