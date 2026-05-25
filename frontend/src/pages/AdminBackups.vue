<template>
  <div class="admin-backups-page">
    <!-- Header -->
    <div class="header">
      <div class="title-section">
        <h1><span class="admin-icon">💾</span> Backups del Sistema</h1>
        <p>Gestiona copias de seguridad de la base de datos</p>
      </div>
      <div class="header-actions">
        <button class="btn-create" @click="createBackup" :disabled="creating">
          {{ creating ? '⏳ Creando...' : '➕ Crear Backup' }}
        </button>
        <button class="btn-refresh" @click="fetchBackups" :disabled="loading">
          {{ loading ? '⏳ Cargando...' : '🔄 Actualizar' }}
        </button>
      </div>
    </div>

    <!-- Stats -->
    <div class="stats-section">
      <div class="stat-card">
        <div class="stat-icon total">💾</div>
        <div class="stat-content">
          <h3>{{ backups.length }}</h3>
          <p>Backups totales</p>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon size">📦</div>
        <div class="stat-content">
          <h3>{{ totalSize }}</h3>
          <p>Espacio total</p>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon latest">🕐</div>
        <div class="stat-content">
          <h3>{{ latestBackup }}</h3>
          <p>Último backup</p>
        </div>
      </div>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="loading-container">
      <div class="spinner"></div>
      <p>Cargando backups...</p>
    </div>

    <!-- Error -->
    <div v-else-if="errorMsg" class="error-state">
      <div class="error-icon">⚠️</div>
      <h3>{{ errorMsg }}</h3>
      <button class="btn-retry" @click="fetchBackups">Reintentar</button>
    </div>

    <!-- Backups Table -->
    <div v-else-if="backups.length > 0" class="backups-table-container">
      <div class="table-header">
        <div class="table-info">
          <strong>{{ backups.length }}</strong> backup(s) disponible(s)
        </div>
      </div>

      <div class="backups-list">
        <div v-for="backup in backups" :key="backup.name" class="backup-item">
          <div class="backup-info">
            <div class="backup-icon">📄</div>
            <div class="backup-details">
              <h4 class="backup-name">{{ backup.name }}</h4>
              <div class="backup-meta">
                <span class="meta-item">📅 {{ backup.date }}</span>
                <span class="meta-item">📦 {{ backup.size_human }}</span>
              </div>
            </div>
          </div>
          <div class="backup-actions">
            <button class="btn-download" @click="downloadBackup(backup.name)" title="Descargar">
              📥 Descargar
            </button>
            <button class="btn-restore" @click="restoreBackup(backup.name)" title="Restaurar" :disabled="restoring === backup.name">
              {{ restoring === backup.name ? '⏳' : '🔄' }} Restaurar
            </button>
            <button class="btn-delete" @click="deleteBackup(backup.name)" title="Eliminar">
              🗑️ Eliminar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Empty -->
    <div v-else class="empty-state">
      <div class="empty-icon">💾</div>
      <h3>No hay backups disponibles</h3>
      <p>Crea tu primer backup para proteger los datos del sistema</p>
      <button class="btn-create-first" @click="createBackup">➕ Crear primer backup</button>
    </div>

    <!-- Info Section -->
    <div class="info-section">
      <div class="info-card">
        <h3>ℹ️ Información importante</h3>
        <ul>
          <li>Los backups se almacenan en el servidor en <code>/backend/backups/</code></li>
          <li>Descarga los backups regularmente para guardarlos en un lugar seguro</li>
          <li>Restaurar un backup sobrescribirá todos los datos actuales</li>
          <li>Se recomienda crear un backup antes de cada actualización del sistema</li>
        </ul>
      </div>
    </div>

    <!-- Toast -->
    <div v-if="toast.show" class="toast" :class="toast.type">{{ toast.message }}</div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAuthStore } from '@/stores/authStore'
import api from '@/axios'

const authStore = useAuthStore()

const backups = ref([])
const loading = ref(true)
const creating = ref(false)
const restoring = ref(null)
const errorMsg = ref('')
const toast = ref({ show: false, message: '', type: 'success' })

// Computed
const totalSize = computed(() => {
  const total = backups.value.reduce((sum, b) => sum + (b.size || 0), 0)
  return formatBytes(total)
})

const latestBackup = computed(() => {
  if (backups.value.length === 0) return 'N/A'
  return backups.value[0]?.date || 'N/A'
})

// Methods
const formatBytes = (bytes) => {
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

const getHeaders = () => ({
  Authorization: `Bearer ${authStore.token}`
})

const fetchBackups = async () => {
  loading.value = true
  errorMsg.value = ''
  try {
    const { data } = await api.get('/admin/backups/list', { headers: getHeaders() })
    backups.value = data?.backups || []
  } catch (e) {
    errorMsg.value = 'Error al cargar backups'
    showToast('Error al cargar la lista de backups', 'error')
  } finally {
    loading.value = false
  }
}

const createBackup = async () => {
  if (creating.value) return
  if (!confirm('¿Crear un nuevo backup de la base de datos?')) return

  creating.value = true
  try {
    const { data } = await api.post('/admin/backups/create', {}, { headers: getHeaders() })
    showToast(`Backup creado: ${data.filename} (${data.size_human})`)
    await fetchBackups()
  } catch (e) {
    showToast('Error al crear el backup', 'error')
  } finally {
    creating.value = false
  }
}

const downloadBackup = (filename) => {
  const token = authStore.token
  const url = `${import.meta.env.VITE_API_URL || ''}/api/admin/backups/download?file=${encodeURIComponent(filename)}&token=${token}`
  window.open(url, '_blank')
}

const restoreBackup = async (filename) => {
  if (!confirm(`¿Restaurar el backup "${filename}"? Esta acción sobrescribirá TODOS los datos actuales y no se puede deshacer.`)) return
  if (!confirm('¿Estás COMPLETAMENTE SEGURO? Esta acción es irreversible.')) return

  restoring.value = filename
  try {
    const { data } = await api.post('/admin/backups/restore', { file: filename }, { headers: getHeaders() })
    showToast('Backup restaurado exitosamente. La página se recargará.', 'success')
    setTimeout(() => { window.location.reload() }, 2000)
  } catch (e) {
    showToast('Error al restaurar el backup', 'error')
  } finally {
    restoring.value = null
  }
}

const deleteBackup = async (filename) => {
  if (!confirm(`¿Eliminar el backup "${filename}"?`)) return

  try {
    await api.post('/admin/backups/delete', { file: filename }, { headers: getHeaders() })
    showToast('Backup eliminado')
    await fetchBackups()
  } catch (e) {
    showToast('Error al eliminar el backup', 'error')
  }
}

onMounted(fetchBackups)
</script>

<style scoped>
.admin-backups-page {
  padding: 24px;
  max-width: 1200px;
  margin: 0 auto;
}

/* Header */
.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  flex-wrap: wrap;
  gap: 16px;
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

.admin-icon {
  margin-right: 8px;
}

.header-actions {
  display: flex;
  gap: 10px;
}

.btn-create {
  padding: 10px 20px;
  background: #4caf50;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s;
}

.btn-create:hover:not(:disabled) {
  background: #43a047;
}

.btn-refresh {
  padding: 10px 20px;
  background: #667eea;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s;
}

.btn-refresh:hover:not(:disabled) {
  background: #5a6fd6;
}

button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

/* Stats */
.stats-section {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 16px;
  margin-bottom: 24px;
}

.stat-card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 14px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
}

.stat-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.4rem;
}

.stat-icon.total { background: #e8f0fe; }
.stat-icon.size { background: #fff3e0; }
.stat-icon.latest { background: #e8f5e9; }

.stat-content h3 {
  font-size: 1.3rem;
  margin: 0;
}

.stat-content p {
  margin: 2px 0 0;
  font-size: 0.8rem;
  color: #888;
}

/* Loading */
.loading-container {
  text-align: center;
  padding: 60px 0;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #e0e0e0;
  border-top-color: #667eea;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
  margin: 0 auto 16px;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* Error */
.error-state {
  text-align: center;
  padding: 60px 0;
  background: white;
  border-radius: 12px;
}

.btn-retry {
  margin-top: 12px;
  padding: 10px 24px;
  background: #667eea;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
}

/* Backups List */
.backups-table-container {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
  margin-bottom: 24px;
}

.table-header {
  margin-bottom: 16px;
}

.table-info {
  color: #666;
  font-size: 0.9rem;
}

.backups-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.backup-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 14px 16px;
  border: 1px solid #eee;
  border-radius: 10px;
  transition: all 0.3s;
  flex-wrap: wrap;
  gap: 12px;
}

.backup-item:hover {
  background: #fafafa;
  border-color: #ddd;
}

.backup-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.backup-icon {
  font-size: 1.5rem;
}

.backup-details h4 {
  margin: 0;
  font-size: 0.95rem;
  color: #1a1a2e;
  word-break: break-all;
}

.backup-meta {
  display: flex;
  gap: 14px;
  margin-top: 4px;
}

.meta-item {
  font-size: 0.8rem;
  color: #888;
}

.backup-actions {
  display: flex;
  gap: 8px;
}

.btn-download, .btn-restore, .btn-delete {
  padding: 7px 14px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.8rem;
  font-weight: 500;
  transition: all 0.3s;
}

.btn-download {
  background: #e8f0fe;
  color: #1a73e8;
}

.btn-download:hover {
  background: #d2e3fc;
}

.btn-restore {
  background: #fff3e0;
  color: #e65100;
}

.btn-restore:hover:not(:disabled) {
  background: #ffe0b2;
}

.btn-delete {
  background: #fce4ec;
  color: #c62828;
}

.btn-delete:hover {
  background: #f8bbd0;
}

/* Empty */
.empty-state {
  text-align: center;
  padding: 60px 0;
  background: white;
  border-radius: 12px;
  margin-bottom: 24px;
}

.empty-icon {
  font-size: 3rem;
  margin-bottom: 12px;
}

.btn-create-first {
  margin-top: 12px;
  padding: 10px 24px;
  background: #4caf50;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
}

/* Info */
.info-section {
  margin-top: 24px;
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

.info-card ul {
  margin: 0;
  padding-left: 20px;
}

.info-card li {
  margin-bottom: 6px;
  color: #666;
  font-size: 0.9rem;
}

.info-card code {
  background: #f5f5f5;
  padding: 2px 6px;
  border-radius: 4px;
  font-size: 0.85rem;
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
.toast.info { background: #2196f3; }

@keyframes slideIn {
  from { transform: translateX(100%); opacity: 0; }
  to { transform: translateX(0); opacity: 1; }
}

@media (max-width: 768px) {
  .admin-backups-page { padding: 16px; }
  .backup-item { flex-direction: column; align-items: flex-start; }
  .backup-actions { width: 100%; justify-content: flex-end; }
}
</style>
