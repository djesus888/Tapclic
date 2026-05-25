<template>
  <div class="admin-update-page">
    <!-- Header -->
    <div class="header">
      <div class="title-section">
        <h1><span class="admin-icon">🔄</span> Actualización del Sistema</h1>
        <p>Sube un archivo ZIP con los archivos de actualización</p>
      </div>
    </div>

    <!-- Info Section -->
    <div class="info-section">
      <div class="info-card">
        <h3>ℹ️ ¿Cómo preparar el archivo de actualización?</h3>
        <ol>
          <li>Crea un archivo <code>.zip</code> con la misma estructura de carpetas del proyecto</li>
          <li>Incluye solo los archivos que han cambiado (no todo el proyecto)</li>
          <li>Si necesitas ejecutar SQL, incluye un archivo <code>migrate.sql</code> en la raíz del ZIP</li>
          <li>Los archivos originales se respaldarán con extensión <code>.bak_fecha</code></li>
          <li>Tamaño máximo: <strong>50MB</strong></li>
        </ol>
      </div>
    </div>

    <!-- Upload Section -->
    <div class="upload-section">
      <div class="upload-card">
        <div class="upload-header">
          <h2>📦 Subir Actualización</h2>
          <p>Selecciona el archivo ZIP con los cambios</p>
        </div>

        <div class="upload-area" @click="triggerUpload" @dragover.prevent @drop.prevent="handleDrop">
          <input type="file" ref="fileInput" @change="handleFile" accept=".zip" class="hidden-input">

          <div v-if="!selectedFile" class="upload-placeholder">
            <div class="upload-icon">📁</div>
            <h3>Arrastra tu archivo aquí o haz clic para seleccionar</h3>
            <p>Solo archivos .zip (máx. 50MB)</p>
          </div>

          <div v-else class="upload-preview">
            <div class="file-info">
              <span class="file-icon">📦</span>
              <div class="file-details">
                <h4>{{ selectedFile.name }}</h4>
                <p>{{ formatFileSize(selectedFile.size) }}</p>
              </div>
            </div>
            <button class="btn-remove" @click.stop="clearFile" title="Quitar archivo">✕</button>
          </div>
        </div>

        <div class="upload-actions">
          <button class="btn-cancel" @click="clearFile" :disabled="!selectedFile || uploading">Cancelar</button>
          <button class="btn-upload" @click="uploadUpdate" :disabled="!selectedFile || uploading">
            <span v-if="uploading" class="spinner"></span>
            <span v-else>🚀</span>
            {{ uploading ? 'Actualizando...' : 'Iniciar Actualización' }}
          </button>
        </div>
      </div>

      <!-- Progress -->
      <div v-if="uploading" class="progress-card">
        <h3>⏳ Aplicando actualización...</h3>
        <div class="progress-bar">
          <div class="progress-fill" :style="{ width: progress + '%' }"></div>
        </div>
        <p class="progress-text">{{ progressMessage }}</p>
      </div>

      <!-- Result -->
      <div v-if="result" class="result-card" :class="result.success ? 'success' : 'error'">
        <div class="result-header">
          <span class="result-icon">{{ result.success ? '✅' : '❌' }}</span>
          <h3>{{ result.success ? 'Actualización completada' : 'Error en la actualización' }}</h3>
        </div>
        <div class="result-content">
          <p>{{ result.message }}</p>
          <div v-if="result.details" class="result-details">
            <div class="detail-item">
              <span class="detail-label">Archivos actualizados:</span>
              <span class="detail-value">{{ result.details.files_updated || 0 }}</span>
            </div>
            <div class="detail-item">
              <span class="detail-label">SQL ejecutado:</span>
              <span class="detail-value">{{ result.details.sql_executed ? '✅ Sí' : '— No' }}</span>
            </div>
            <div v-if="result.details.errors?.length" class="detail-errors">
              <h4>⚠️ Errores:</h4>
              <ul>
                <li v-for="(err, i) in result.details.errors" :key="i">{{ err }}</li>
              </ul>
            </div>
          </div>
        </div>
        <button class="btn-done" @click="clearResult">Aceptar</button>
      </div>
    </div>

    <!-- History Section -->
    <div class="history-section">
      <h2>📋 Historial de actualizaciones</h2>
      <p>Las actualizaciones anteriores dejan backups con extensión <code>.bak_fecha</code> en los directorios correspondientes.</p>
    </div>

    <!-- Toast -->
    <div v-if="toast.show" class="toast" :class="toast.type">{{ toast.message }}</div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useAuthStore } from '@/stores/authStore'
import api from '@/axios'

const authStore = useAuthStore()

const fileInput = ref(null)
const selectedFile = ref(null)
const uploading = ref(false)
const progress = ref(0)
const progressMessage = ref('')
const result = ref(null)
const toast = ref({ show: false, message: '', type: 'success' })

// Methods
const formatFileSize = (bytes) => {
  if (bytes === 0) return '0 Bytes'
  const k = 1024
  const sizes = ['Bytes', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
}

const showToast = (message, type = 'success') => {
  toast.value = { show: true, message, type }
  setTimeout(() => { toast.value.show = false }, 4000)
}

const triggerUpload = () => {
  fileInput.value?.click()
}

const handleFile = (event) => {
  const file = event.target.files?.[0]
  if (!file) return
  validateAndSet(file)
}

const handleDrop = (event) => {
  const file = event.dataTransfer?.files?.[0]
  if (!file) return
  validateAndSet(file)
}

const validateAndSet = (file) => {
  result.value = null

  if (!file.name.endsWith('.zip')) {
    showToast('Solo se permiten archivos .zip', 'error')
    return
  }

  if (file.size > 50 * 1024 * 1024) {
    showToast('El archivo no debe superar 50MB', 'error')
    return
  }

  selectedFile.value = file
}

const clearFile = () => {
  selectedFile.value = null
  if (fileInput.value) fileInput.value.value = ''
}

const clearResult = () => {
  result.value = null
  clearFile()
}

const uploadUpdate = async () => {
  if (!selectedFile.value) return

  if (!confirm('¿Estás seguro de aplicar esta actualización? Se recomienda hacer un backup antes.')) return
  if (!confirm('¿CONFIRMAS que quieres actualizar el sistema? Esta acción no se puede deshacer fácilmente.')) return

  uploading.value = true
  progress.value = 0
  progressMessage.value = 'Subiendo archivo...'
  result.value = null

  try {
    // Simular progreso de subida
    const progressInterval = setInterval(() => {
      if (progress.value < 90) {
        progress.value += Math.random() * 15
        if (progress.value > 90) progress.value = 90
        if (progress.value > 50) progressMessage.value = 'Extrayendo archivos...'
        if (progress.value > 75) progressMessage.value = 'Aplicando cambios...'
      }
    }, 500)

    const formData = new FormData()
    formData.append('update_file', selectedFile.value)

    const { data } = await api.post('/admin/update/upload', formData, {
      headers: {
        Authorization: `Bearer ${authStore.token}`,
        'Content-Type': 'multipart/form-data'
      },
      timeout: 120000 // 2 minutos
    })

    clearInterval(progressInterval)
    progress.value = 100
    progressMessage.value = '¡Completado!'

    result.value = data
    showToast('Actualización aplicada correctamente')

  } catch (error) {
    progress.value = 0
    progressMessage.value = ''
    result.value = {
      success: false,
      message: error.response?.data?.error || error.message || 'Error al aplicar la actualización',
      details: null
    }
    showToast('Error en la actualización', 'error')
  } finally {
    uploading.value = false
  }
}
</script>

<style scoped>
.admin-update-page {
  padding: 24px;
  max-width: 900px;
  margin: 0 auto;
}

/* Header */
.header {
  margin-bottom: 24px;
}

.title-section h1 {
  font-size: 1.8rem;
  font-weight: 700;
  color: #1a1a2e;
  margin: 0 0 4px 0;
}

.title-section p {
  color: #666;
  margin: 0;
}

.admin-icon { margin-right: 8px; }

/* Info */
.info-section {
  margin-bottom: 24px;
}

.info-card {
  background: #fffde7;
  border: 1px solid #fff9c4;
  border-radius: 12px;
  padding: 20px;
}

.info-card h3 {
  margin: 0 0 12px;
  color: #f57f17;
}

.info-card ol {
  margin: 0;
  padding-left: 20px;
}

.info-card li {
  margin-bottom: 6px;
  color: #555;
  font-size: 0.9rem;
}

.info-card code {
  background: #f5f5f5;
  padding: 2px 6px;
  border-radius: 4px;
}

/* Upload */
.upload-section {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.upload-card {
  background: white;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
}

.upload-header {
  margin-bottom: 16px;
}

.upload-header h2 {
  margin: 0 0 4px;
  font-size: 1.2rem;
}

.upload-header p {
  color: #888;
  margin: 0;
}

.upload-area {
  border: 2px dashed #ddd;
  border-radius: 12px;
  padding: 40px 20px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s;
  margin-bottom: 16px;
}

.upload-area:hover {
  border-color: #667eea;
  background: #f8f9ff;
}

.upload-icon {
  font-size: 3rem;
  margin-bottom: 12px;
}

.upload-placeholder h3 {
  margin: 0 0 8px;
  color: #555;
}

.upload-placeholder p {
  color: #aaa;
  margin: 0;
}

.upload-preview {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 16px;
}

.file-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.file-icon {
  font-size: 2rem;
}

.file-details h4 {
  margin: 0;
  color: #333;
}

.file-details p {
  margin: 4px 0 0;
  color: #888;
  font-size: 0.85rem;
}

.btn-remove {
  background: #fce4ec;
  color: #c62828;
  border: none;
  border-radius: 50%;
  width: 32px;
  height: 32px;
  cursor: pointer;
  font-size: 1rem;
}

.hidden-input {
  display: none;
}

.upload-actions {
  display: flex;
  gap: 10px;
  justify-content: flex-end;
}

.btn-cancel {
  padding: 10px 20px;
  background: #f5f5f5;
  border: 1px solid #ddd;
  border-radius: 8px;
  cursor: pointer;
}

.btn-upload {
  padding: 10px 24px;
  background: #667eea;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 8px;
}

.btn-upload:hover:not(:disabled) {
  background: #5a6fd6;
}

.btn-upload:disabled, .btn-cancel:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Progress */
.progress-card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
  text-align: center;
}

.progress-card h3 {
  margin: 0 0 12px;
}

.progress-bar {
  height: 8px;
  background: #eee;
  border-radius: 4px;
  overflow: hidden;
  margin-bottom: 8px;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #667eea, #764ba2);
  transition: width 0.3s;
  border-radius: 4px;
}

.progress-text {
  color: #888;
  font-size: 0.9rem;
}

/* Result */
.result-card {
  border-radius: 12px;
  padding: 24px;
}

.result-card.success {
  background: #e8f5e9;
  border: 1px solid #c8e6c9;
}

.result-card.error {
  background: #fce4ec;
  border: 1px solid #f8bbd0;
}

.result-header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 12px;
}

.result-header h3 {
  margin: 0;
}

.result-icon {
  font-size: 1.5rem;
}

.result-details {
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px solid rgba(0,0,0,0.1);
}

.detail-item {
  display: flex;
  justify-content: space-between;
  padding: 4px 0;
  font-size: 0.9rem;
}

.detail-label {
  color: #666;
}

.detail-value {
  font-weight: 600;
}

.detail-errors {
  margin-top: 8px;
  background: rgba(255,0,0,0.05);
  padding: 10px;
  border-radius: 6px;
}

.detail-errors h4 {
  margin: 0 0 6px;
  color: #c62828;
}

.detail-errors ul {
  margin: 0;
  padding-left: 20px;
}

.detail-errors li {
  color: #c62828;
  font-size: 0.85rem;
}

.btn-done {
  margin-top: 16px;
  padding: 10px 24px;
  background: #667eea;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  float: right;
}

/* History */
.history-section {
  margin-top: 24px;
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
}

.history-section h2 {
  margin: 0 0 8px;
}

.history-section p {
  color: #888;
  margin: 0;
}

.history-section code {
  background: #f5f5f5;
  padding: 2px 6px;
  border-radius: 4px;
}

/* Spinner */
.spinner {
  width: 18px;
  height: 18px;
  border: 2px solid rgba(255,255,255,0.3);
  border-top-color: white;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
  display: inline-block;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* Toast */
.toast {
  position: fixed;
  bottom: 24px;
  right: 24px;
  padding: 12px 24px;
  border-radius: 8px;
  color: white;
  font-weight: 500;
  z-index: 1000;
  animation: slideIn 0.3s ease;
}

.toast.success { background: #4caf50; }
.toast.error { background: #f44336; }

@keyframes slideIn {
  from { transform: translateX(100%); opacity: 0; }
  to { transform: translateX(0); opacity: 1; }
}

@media (max-width: 768px) {
  .admin-update-page { padding: 16px; }
}
</style>
