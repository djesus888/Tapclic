<template>
  <div class="favorites-page">
    <div class="header">
      <div class="title-section">
        <h1><span class="star-icon">⭐</span> Mis Favoritos</h1>
        <p>Servicios que has guardado para ver más tarde</p>
      </div>
      
      <div class="actions" v-if="favoriteServices.length > 0">
        <button 
          class="btn-clear-all"
          @click="showClearConfirm = true"
          :disabled="loading"
        >
          🗑️ Limpiar todos
        </button>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="loading-container">
      <div class="spinner"></div>
      <p>Cargando tus favoritos...</p>
    </div>

    <!-- Main Content -->
    <div v-else>
      <!-- Empty State -->
      <div v-if="favoriteServices.length === 0" class="empty-state">
        <div class="empty-icon">⭐</div>
        <h2>No tienes favoritos aún</h2>
        <p>Marca servicios con la estrella para guardarlos aquí</p>
        <div class="empty-actions">
          <router-link to="/services" class="btn-primary">
            Explorar servicios
          </router-link>
          <button class="btn-secondary" @click="loadSampleData">
            Ver datos de ejemplo
          </button>
        </div>
      </div>

      <!-- Favorites Grid -->
      <div v-else>
        <!-- Summary Stats -->
        <div class="summary-stats">
          <div class="stat-item">
            <div class="stat-icon">⭐</div>
            <div class="stat-content">
              <h3>{{ favoriteServices.length }}</h3>
              <p>Servicios favoritos</p>
            </div>
          </div>
          <div class="stat-item">
            <div class="stat-icon">🏷️</div>
            <div class="stat-content">
              <h3>{{ uniqueCategories.length }}</h3>
              <p>Categorías distintas</p>
            </div>
          </div>
          <div class="stat-item">
            <div class="stat-icon">💰</div>
            <div class="stat-content">
              <h3>{{ formatPrice(totalValue) }}</h3>
              <p>Valor total</p>
            </div>
          </div>
        </div>

        <!-- Filters -->
        <div class="filters-section">
          <div class="filter-group">
            <label for="category-filter">Filtrar por categoría:</label>
            <select 
              id="category-filter" 
              v-model="selectedCategory"
              class="filter-select"
            >
              <option value="">Todas las categorías</option>
              <option v-for="category in categories" :key="category" :value="category">
                {{ category }}
              </option>
            </select>
          </div>

          <div class="filter-group">
            <label for="sort-filter">Ordenar por:</label>
            <select 
              id="sort-filter" 
              v-model="sortBy"
              class="filter-select"
            >
              <option value="recent">Más recientes</option>
              <option value="price-low">Precio: menor a mayor</option>
              <option value="price-high">Precio: mayor a menor</option>
              <option value="name">Nombre (A-Z)</option>
            </select>
          </div>

          <div class="filter-group">
            <label for="price-range">Rango de precio:</label>
            <div class="price-range">
              <span>${{ minPrice }}</span>
              <input 
                type="range" 
                v-model="priceRange" 
                :min="minPrice" 
                :max="maxPrice" 
                step="10"
                class="range-slider"
              >
              <span>${{ priceRange }}</span>
            </div>
          </div>
        </div>

        <!-- Favorites Grid -->
        <div class="favorites-grid">
          <div 
            v-for="service in filteredFavorites" 
            :key="service.id" 
            class="favorite-card"
          >
            <div class="card-badge">⭐ Favorito</div>
            
            <div class="card-image">
              <img 
                :src="service.image || 'https://via.placeholder.com/300x200?text=Servicio'" 
                :alt="service.name"
                @error="handleImageError"
              >
              <button 
                class="remove-favorite"
                @click="removeFromFavorites(service.id)"
                :title="`Quitar ${service.name} de favoritos`"
              >
                ❌
              </button>
            </div>

            <div class="card-content">
              <div class="card-header">
                <span class="service-category">{{ service.category }}</span>
                <span class="service-rating" v-if="service.rating">
                  ⭐ {{ service.rating.toFixed(1) }}
                </span>
              </div>

              <h3 class="service-title">{{ service.name }}</h3>
              <p class="service-description">{{ service.description }}</p>

              <div class="service-provider">
                <span class="provider-avatar">👤</span>
                <span class="provider-name">{{ service.providerName }}</span>
              </div>

              <div class="card-footer">
                <div class="price-section">
                  <span class="price">{{ formatPrice(service.price) }}</span>
                  <span class="price-unit" v-if="service.priceUnit">
                    / {{ service.priceUnit }}
                  </span>
                </div>
                
                <div class="card-actions">
                  <button 
                    class="btn-view"
                    @click="viewService(service.id)"
                  >
                    Ver detalles
                  </button>
                  <button 
                    class="btn-contact"
                    @click="contactProvider(service.providerId)"
                  >
                    Contactar
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Export Options -->
        <div class="export-section">
          <h3>Exportar lista</h3>
          <div class="export-options">
            <button class="export-btn" @click="exportToPDF">
              📄 Exportar a PDF
            </button>
            <button class="export-btn" @click="exportToCSV">
              📊 Exportar a CSV
            </button>
            <button class="export-btn" @click="shareList">
              🔗 Compartir lista
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Clear All Confirmation Modal -->
    <div v-if="showClearConfirm" class="modal-overlay">
      <div class="modal">
        <h3>¿Eliminar todos los favoritos?</h3>
        <p>Esta acción no se puede deshacer. Se eliminarán {{ favoriteServices.length }} servicios.</p>
        <div class="modal-actions">
          <button class="btn-cancel" @click="showClearConfirm = false">
            Cancelar
          </button>
          <button class="btn-confirm" @click="clearAllFavorites">
            Sí, eliminar todos
          </button>
        </div>
      </div>
    </div>

    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast" :class="toast.type">
      {{ toast.message }}
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useFavoritesStore } from '@/stores/favoritesStore'
import { useAuthStore } from '@/stores/authStore'

const router = useRouter()
const favoritesStore = useFavoritesStore()
const authStore = useAuthStore()

// Estado reactivo
const loading = ref(true)
const selectedCategory = ref('')
const sortBy = ref('recent')
const priceRange = ref(500)
const showClearConfirm = ref(false)

// Toast notifications
const toast = ref({
  show: false,
  message: '',
  type: 'success' // 'success' | 'error' | 'info'
})

// Datos de ejemplo (reemplazar con API real)
const sampleData = [
  {
    id: 1,
    name: 'Diseño de Logotipo Profesional',
    description: 'Creación de identidad visual para tu marca',
    category: 'Diseño Gráfico',
    price: 299,
    priceUnit: 'proyecto',
    providerName: 'Creative Designs Co.',
    providerId: 101,
    rating: 4.8,
    image: 'https://images.unsplash.com/photo-1634942537034-2531766767d1?w=300&h=200&fit=crop',
    addedAt: new Date().toISOString()
  },
  {
    id: 2,
    name: 'Clases de Yoga Personalizadas',
    description: 'Sesiones de yoga adaptadas a tus necesidades',
    category: 'Bienestar',
    price: 35,
    priceUnit: 'sesión',
    providerName: 'Yoga Harmony Studio',
    providerId: 102,
    rating: 4.9,
    image: 'https://images.unsplash.com/photo-1545389336-cf573b442d45?w=300&h=200&fit=crop',
    addedAt: new Date(Date.now() - 86400000).toISOString()
  },
  {
    id: 3,
    name: 'Reparación de Computadoras a Domicilio',
    description: 'Solución rápida para problemas técnicos',
    category: 'Tecnología',
    price: 50,
    priceUnit: 'hora',
    providerName: 'TechFix Solutions',
    providerId: 103,
    rating: 4.7,
    image: 'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w-300&h=200&fit=crop',
    addedAt: new Date(Date.now() - 172800000).toISOString()
  },
  {
    id: 4,
    name: 'Catering para Eventos Empresariales',
    description: 'Servicio gastronómico premium para empresas',
    category: 'Gastronomía',
    price: 1500,
    priceUnit: 'evento',
    providerName: 'Elite Catering Services',
    providerId: 104,
    rating: 4.6,
    image: 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300&h=200&fit=crop',
    addedAt: new Date(Date.now() - 259200000).toISOString()
  }
]

// Computed properties
const favoriteServices = ref([])

const categories = computed(() => {
  const cats = new Set(favoriteServices.value.map(s => s.category))
  return Array.from(cats).sort()
})

const uniqueCategories = computed(() => categories.value)

const minPrice = computed(() => {
  if (favoriteServices.value.length === 0) return 0
  return Math.min(...favoriteServices.value.map(s => s.price))
})

const maxPrice = computed(() => {
  if (favoriteServices.value.length === 0) return 1000
  return Math.max(...favoriteServices.value.map(s => s.price))
})

const totalValue = computed(() => {
  return favoriteServices.value.reduce((sum, service) => sum + service.price, 0)
})

const filteredFavorites = computed(() => {
  let services = [...favoriteServices.value]
  
  // Filtrar por categoría
  if (selectedCategory.value) {
    services = services.filter(s => s.category === selectedCategory.value)
  }
  
  // Filtrar por precio
  services = services.filter(s => s.price <= priceRange.value)
  
  // Ordenar
  switch (sortBy.value) {
    case 'recent':
      services.sort((a, b) => new Date(b.addedAt) - new Date(a.addedAt))
      break
    case 'price-low':
      services.sort((a, b) => a.price - b.price)
      break
    case 'price-high':
      services.sort((a, b) => b.price - a.price)
      break
    case 'name':
      services.sort((a, b) => a.name.localeCompare(b.name))
      break
  }
  
  return services
})

// Lifecycle
onMounted(async () => {
  await loadFavorites()
})

// Methods
async function loadFavorites() {
  loading.value = true
  try {
    if (authStore.user) {
      // Llamada real a la API
      // favoriteServices.value = await favoritesStore.fetchFavorites()
      
      // Por ahora usamos datos de ejemplo
      favoriteServices.value = sampleData
      
      // Configurar rango de precio inicial
      if (favoriteServices.value.length > 0) {
        priceRange.value = maxPrice.value
      }
    }
  } catch (error) {
    console.error('Error cargando favoritos:', error)
    showToast('Error al cargar favoritos', 'error')
  } finally {
    loading.value = false
  }
}

function loadSampleData() {
  favoriteServices.value = sampleData
  showToast('Datos de ejemplo cargados', 'info')
}

function formatPrice(price) {
  return new Intl.NumberFormat('es-ES', {
    style: 'currency',
    currency: 'USD'
  }).format(price)
}

function viewService(serviceId) {
  router.push(`/services/${serviceId}`)
}

function contactProvider(providerId) {
  // Implementar lógica de contacto
  showToast('Función de contacto próximamente', 'info')
}

function removeFromFavorites(serviceId) {
  const service = favoriteServices.value.find(s => s.id === serviceId)
  favoriteServices.value = favoriteServices.value.filter(s => s.id !== serviceId)
  
  showToast(`"${service.name}" eliminado de favoritos`, 'success')
}

async function clearAllFavorites() {
  try {
    // await favoritesStore.clearAllFavorites()
    favoriteServices.value = []
    showClearConfirm.value = false
    showToast('Todos los favoritos han sido eliminados', 'success')
  } catch (error) {
    showToast('Error al eliminar favoritos', 'error')
  }
}

function exportToPDF() {
  showToast('Exportando a PDF...', 'info')
  // Implementar exportación a PDF
}

function exportToCSV() {
  const headers = ['Nombre', 'Categoría', 'Precio', 'Proveedor']
  const csvData = favoriteServices.value.map(s => [
    s.name,
    s.category,
    s.price,
    s.providerName
  ])
  
  const csvContent = [headers, ...csvData]
    .map(row => row.join(','))
    .join('\n')
  
  const blob = new Blob([csvContent], { type: 'text/csv' })
  const url = window.URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = 'mis-favoritos.csv'
  a.click()
  
  showToast('Lista exportada a CSV', 'success')
}

function shareList() {
  if (navigator.share) {
    navigator.share({
      title: 'Mis servicios favoritos',
      text: `Tengo ${favoriteServices.value.length} servicios guardados como favoritos`,
      url: window.location.href
    })
  } else {
    navigator.clipboard.writeText(window.location.href)
    showToast('Enlace copiado al portapapeles', 'success')
  }
}

function handleImageError(event) {
  event.target.src = 'https://via.placeholder.com/300x200?text=Imagen+No+Disponible'
}

function showToast(message, type = 'info') {
  toast.value = { show: true, message, type }
  setTimeout(() => {
    toast.value.show = false
  }, 3000)
}
</script>

<style scoped>
.favorites-page {
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

.star-icon {
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

.actions {
  display: flex;
  gap: 12px;
}

.btn-clear-all {
  background: #ff7675;
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s;
}

.btn-clear-all:hover:not(:disabled) {
  background: #d63031;
  transform: translateY(-2px);
}

.btn-clear-all:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Loading State */
.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 400px;
}

.spinner {
  width: 60px;
  height: 60px;
  border: 4px solid rgba(52, 152, 219, 0.2);
  border-top: 4px solid #3498db;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 20px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
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

.empty-actions {
  display: flex;
  gap: 16px;
  justify-content: center;
  flex-wrap: wrap;
}

.btn-primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 14px 32px;
  border-radius: 10px;
  text-decoration: none;
  font-weight: 600;
  border: none;
  cursor: pointer;
  transition: transform 0.3s, box-shadow 0.3s;
}

.btn-primary:hover {
  transform: translateY(-3px);
  box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
}

.btn-secondary {
  background: white;
  color: #636e72;
  padding: 14px 32px;
  border-radius: 10px;
  border: 2px solid #dfe6e9;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s;
}

.btn-secondary:hover {
  border-color: #3498db;
  color: #3498db;
}

/* Summary Stats */
.summary-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 24px;
  margin-bottom: 40px;
}

.stat-item {
  background: white;
  padding: 24px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  gap: 20px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
  transition: transform 0.3s;
}

.stat-item:hover {
  transform: translateY(-5px);
}

.stat-icon {
  font-size: 2.5rem;
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  border-radius: 12px;
  color: white;
}

.stat-content h3 {
  font-size: 2rem;
  color: #2d3436;
  margin-bottom: 4px;
}

.stat-content p {
  color: #636e72;
  font-size: 0.9rem;
}

/* Filters Section */
.filters-section {
  background: white;
  padding: 24px;
  border-radius: 16px;
  margin-bottom: 32px;
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 24px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
}

.filter-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.filter-group label {
  font-weight: 600;
  color: #2d3436;
  font-size: 0.9rem;
}

.filter-select {
  padding: 12px;
  border: 2px solid #dfe6e9;
  border-radius: 8px;
  font-size: 1rem;
  transition: border-color 0.3s;
  background: white;
}

.filter-select:focus {
  outline: none;
  border-color: #3498db;
}

.price-range {
  display: flex;
  align-items: center;
  gap: 16px;
}

.range-slider {
  flex: 1;
  height: 6px;
  -webkit-appearance: none;
  background: linear-gradient(to right, #74b9ff, #0984e3);
  border-radius: 3px;
  outline: none;
}

.range-slider::-webkit-slider-thumb {
  -webkit-appearance: none;
  width: 22px;
  height: 22px;
  background: #0984e3;
  border-radius: 50%;
  cursor: pointer;
  border: 3px solid white;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.2);
}

/* Favorites Grid */
.favorites-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 32px;
  margin-bottom: 40px;
}

.favorite-card {
  background: white;
  border-radius: 20px;
  overflow: hidden;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
  transition: all 0.4s;
  position: relative;
  border: 1px solid #f1f2f6;
}

.favorite-card:hover {
  transform: translateY(-10px);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
}

.card-badge {
  position: absolute;
  top: 16px;
  left: 16px;
  background: linear-gradient(135deg, #fdcb6e 0%, #e17055 100%);
  color: white;
  padding: 6px 16px;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
  z-index: 2;
}

.card-image {
  position: relative;
  height: 200px;
  overflow: hidden;
}

.card-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.5s;
}

.favorite-card:hover .card-image img {
  transform: scale(1.05);
}

.remove-favorite {
  position: absolute;
  top: 16px;
  right: 16px;
  background: rgba(255, 255, 255, 0.9);
  border: none;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  cursor: pointer;
  font-size: 14px;
  transition: all 0.3s;
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2;
}

.remove-favorite:hover {
  background: #ff7675;
  color: white;
  transform: rotate(90deg);
}

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

.service-rating {
  color: #fdcb6e;
  font-weight: 600;
  font-size: 0.9rem;
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
  margin-bottom: 20px;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.service-provider {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 20px;
  padding: 12px;
  background: #f8f9fa;
  border-radius: 10px;
}

.provider-avatar {
  width: 32px;
  height: 32px;
  background: #74b9ff;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.provider-name {
  font-weight: 600;
  color: #2d3436;
}

.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.price-section {
  display: flex;
  align-items: baseline;
  gap: 4px;
}

.price {
  font-size: 1.8rem;
  font-weight: 700;
  color: #00b894;
}

.price-unit {
  color: #636e72;
  font-size: 0.9rem;
}

.card-actions {
  display: flex;
  gap: 10px;
}

.btn-view {
  background: #3498db;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  font-size: 0.9rem;
  transition: all 0.3s;
}

.btn-view:hover {
  background: #2980b9;
  transform: translateY(-2px);
}

.btn-contact {
  background: #00b894;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  font-size: 0.9rem;
  transition: all 0.3s;
}

.btn-contact:hover {
  background: #00a085;
  transform: translateY(-2px);
}

/* Export Section */
.export-section {
  background: white;
  padding: 32px;
  border-radius: 20px;
  text-align: center;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
}

.export-section h3 {
  color: #2d3436;
  margin-bottom: 24px;
  font-size: 1.5rem;
}

.export-options {
  display: flex;
  justify-content: center;
  gap: 16px;
  flex-wrap: wrap;
}

.export-btn {
  background: linear-gradient(135deg, #a8edea 0%, #fed6e3 100%);
  border: none;
  padding: 14px 28px;
  border-radius: 12px;
  cursor: pointer;
  font-weight: 600;
  color: #2d3436;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s;
}

.export-btn:hover {
  transform: translateY(-3px);
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
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
}

.modal {
  background: white;
  padding: 40px;
  border-radius: 20px;
  max-width: 400px;
  width: 90%;
  text-align: center;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
}

.modal h3 {
  color: #2d3436;
  margin-bottom: 16px;
  font-size: 1.5rem;
}

.modal p {
  color: #636e72;
  margin-bottom: 32px;
  line-height: 1.5;
}

.modal-actions {
  display: flex;
  gap: 16px;
  justify-content: center;
}

.btn-cancel {
  background: #dfe6e9;
  color: #2d3436;
  border: none;
  padding: 12px 32px;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s;
}

.btn-cancel:hover {
  background: #b2bec3;
}

.btn-confirm {
  background: #ff7675;
  color: white;
  border: none;
  padding: 12px 32px;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s;
}

.btn-confirm:hover {
  background: #d63031;
}

/* Toast */
.toast {
  position: fixed;
  bottom: 24px;
  right: 24px;
  padding: 16px 24px;
  border-radius: 10px;
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

/* Responsive Design */
@media (max-width: 1200px) {
  .favorites-grid {
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  }
}

@media (max-width: 768px) {
  .favorites-page {
    padding: 16px;
  }
  
  .header {
    flex-direction: column;
    align-items: stretch;
  }
  
  .title-section h1 {
    font-size: 2rem;
  }
  
  .favorites-grid {
    grid-template-columns: 1fr;
    gap: 24px;
  }
  
  .summary-stats {
    grid-template-columns: 1fr;
  }
  
  .filters-section {
    grid-template-columns: 1fr;
  }
  
  .modal {
    width: 95%;
    padding: 24px;
  }
  
  .modal-actions {
    flex-direction: column;
  }
}

@media (max-width: 480px) {
  .title-section h1 {
    font-size: 1.8rem;
  }
  
  .empty-actions {
    flex-direction: column;
  }
  
  .card-actions {
    flex-direction: column;
  }
  
  .export-options {
    flex-direction: column;
    align-items: stretch;
  }
}
</style>
