<template>
  <div class="servicios-container">
    <!-- Header simplificado -->
    <div class="header-section">
      <div class="header-content">
        <h1><span class="icon">⚙️</span> Servicios Disponibles</h1>
        <p>Encuentra el servicio perfecto para tus necesidades</p>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="loading-container">
      <div class="spinner"></div>
      <p>Cargando servicios...</p>
    </div>

    <!-- Services Grid -->
    <div v-else>
      <!-- Buscador mejorado -->
      <div class="search-section">
        <div class="search-container">
          <div class="search-icon">🔍</div>
          <input
            type="text"
            v-model="searchQuery"
            placeholder="Buscar servicios, categorías o proveedores..."
            class="search-input"
            @input="handleSearch"
          />
          <div class="search-actions">
            <button 
              class="btn-clear-search"
              @click="clearSearch"
              v-if="searchQuery"
              title="Limpiar búsqueda"
            >
              ✕
            </button>
            <button 
              class="btn-filter-toggle"
              @click="toggleFilters"
              :class="{ active: showFilters }"
              title="Mostrar/ocultar filtros"
            >
              ⚙️
            </button>
          </div>
        </div>
        
        <div class="search-stats" v-if="searchQuery">
          <span class="search-results-count">
            {{ filteredServices.length }} resultado{{ filteredServices.length !== 1 ? 's' : '' }} para "{{ searchQuery }}"
          </span>
        </div>
      </div>

      <!-- Filtros desplegables -->
      <div class="filters-collapsible" v-if="showFilters">
        <div class="filters-section">
          <div class="filter-group">
            <label for="availability-filter">Disponibilidad:</label>
            <select 
              id="availability-filter" 
              v-model="filterAvailability"
              class="filter-select"
            >
              <option value="all">Todos</option>
              <option value="available">Solo disponibles</option>
              <option value="unavailable">No disponibles</option>
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
              <option value="rating">Mejor valorados</option>
              <option value="name">Nombre (A-Z)</option>
            </select>
          </div>

          <div class="filter-group">
            <label for="price-range">Precio máximo: <strong>${{ priceRange }}</strong></label>
            <div class="price-range">
              <span>$1</span>
              <input 
                type="range" 
                v-model="priceRange" 
                min="1"
                :max="maxPrice" 
                step="1"
                class="range-slider"
                @input="updatePriceRange"
              >
              <span>${{ maxPrice }}</span>
            </div>
            <div class="price-range-labels">
              <small>Arrastra para ajustar</small>
              <small>Máx: ${{ priceRange }}</small>
            </div>
          </div>

          <div class="filter-actions">
            <button class="btn-reset-filters" @click="resetFilters">
              🔄 Reiniciar filtros
            </button>
          </div>
        </div>
      </div>

      <!-- Services Grid -->
      <div v-if="filteredServices.length > 0" class="services-grid">
        <div 
          v-for="service in paginatedServices" 
          :key="service.id" 
          class="service-card-modern"
          @click="$emit('open-service-details', service)"
        >
          <!-- Badge de disponibilidad -->
          <div class="card-badge" :class="service.isAvailable === 1 && service.status === 'active' ? 'available' : 'unavailable'">
            {{ service.isAvailable === 1 && service.status === 'active' ? 'Disponible' : 'No disponible' }}
          </div>
          
          <!-- Imagen del servicio -->
          <div class="card-image">
            <img
              :src="getServiceImage(service)"
              :alt="sanitize(service.title)"
              @error="handleImageError"
            />
            <div class="image-overlay"></div>
          </div>

          <!-- Contenido de la tarjeta -->
          <div class="card-content">
            <!-- Header con categoría y fecha -->
            <div class="card-header">
              <span class="service-category">{{ service.category || 'General' }}</span>
              <span class="service-date">{{ formatDate(service.created_at) }}</span>
            </div>

            <!-- Título y descripción -->
            <h3 class="service-title">{{ sanitize(service.title) }}</h3>
            <p class="service-description">{{ sanitize(service.description) }}</p>

            <!-- Información del proveedor -->
            <div class="service-provider">
              <div class="provider-info">
                <img
                  :src="getProviderAvatar(service)"
                  :alt="sanitize(service.provider?.name || 'Proveedor')"
                  class="provider-avatar"
                  @error="handleAvatarError"
                />
                <div class="provider-details">
                  <span class="provider-name">{{ sanitize(service.provider?.name || 'Proveedor') }}</span>
                  <div class="provider-rating" v-if="hasValidRating(service)">
                    <span class="stars">⭐</span>
                    <span class="rating-value">{{ formatRating(service) }}</span>
                  </div>
                </div>
              </div>
            </div>

            <!-- Footer con precio y acciones -->
            <div class="card-footer">
              <div class="price-section">
                <span class="price">${{ formatServicePrice(service) }}</span>
                <span class="price-unit" v-if="service.price_unit">/ {{ service.price_unit }}</span>
              </div>
              
              <div class="card-actions">
                <button 
                  class="btn-view"
                  @click.stop="$emit('open-service-details', service)"
                >
                  Ver detalles
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div v-else class="empty-state">
        <div class="empty-icon">🔍</div>
        <h3 v-if="searchQuery || filterAvailability !== 'all' || priceRange < maxPrice">
          No se encontraron servicios
        </h3>
        <h3 v-else>No hay servicios disponibles</h3>
        
        <p v-if="searchQuery">
          No hay resultados para "{{ searchQuery }}" con los filtros aplicados
        </p>
        <p v-else-if="filterAvailability !== 'all'">
          No hay servicios {{ filterAvailability === 'available' ? 'disponibles' : 'no disponibles' }}
        </p>
        <p v-else-if="priceRange < maxPrice">
          No hay servicios por menos de ${{ priceRange }}
        </p>
        <p v-else>No hay servicios disponibles en este momento</p>
        
        <div class="empty-actions">
          <button 
            class="btn-primary"
            @click="resetFilters"
            v-if="searchQuery || filterAvailability !== 'all' || priceRange < maxPrice"
          >
            Mostrar todos los servicios
          </button>
          <button 
            class="btn-secondary"
            @click="clearSearch"
            v-if="searchQuery"
          >
            Limpiar búsqueda
          </button>
        </div>
      </div>

      <!-- Pagination -->
      <div v-if="filteredServices.length > 12" class="pagination-section">
        <div class="pagination-info">
          Mostrando {{ Math.min(currentPage * itemsPerPage, filteredServices.length) }} de {{ filteredServices.length }} servicios
        </div>
        <div class="pagination-controls">
          <button 
            class="pagination-btn"
            @click="prevPage"
            :disabled="currentPage === 1"
          >
            ← Anterior
          </button>
          <span class="pagination-page">
            Página {{ currentPage }} de {{ totalPages }}
          </span>
          <button 
            class="pagination-btn"
            @click="nextPage"
            :disabled="currentPage === totalPages"
          >
            Siguiente →
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { getImageUrl } from '@/utils/imageHelper'
import { formatDate as formatDateUtil } from '@/utils/formatDate';

export default {
  name: 'ServiciosUsuario',
  props: {
    services: { type: Array, required: true },
    loading: { type: Boolean, default: false }
  },
  emits: ['open-service-details'],
  data() {
    return {
      filterAvailability: 'all',
      sortBy: 'recent',
      searchQuery: '',
      priceRange: 100, // Valor inicial más bajo
      currentPage: 1,
      itemsPerPage: 12,
      searchTimeout: null,
      showFilters: false
    }
  },
  computed: {
    availableServices() {
      return this.services.filter(s => s.isAvailable === 1 && s.status === 'active').length;
    },
    maxPrice() {
      if (this.services.length === 0) return 100;
      const prices = this.services.map(s => this.parsePrice(s.price));
      const max = Math.max(...prices);
      // Si el máximo es menor a 100, usar 100 como tope
      return max < 100 ? 100 : Math.ceil(max / 10) * 10; // Redondear a múltiplo de 10
    },
    filteredServices() {
      let filtered = [...this.services];
      
      // Filtrar por búsqueda
      if (this.searchQuery) {
        const query = this.searchQuery.toLowerCase();
        filtered = filtered.filter(service => {
          return (
            (service.title && service.title.toLowerCase().includes(query)) ||
            (service.description && service.description.toLowerCase().includes(query)) ||
            (service.category && service.category.toLowerCase().includes(query)) ||
            (service.provider?.name && service.provider.name.toLowerCase().includes(query))
          );
        });
      }
      
      // Filtrar por disponibilidad
      if (this.filterAvailability === 'available') {
        filtered = filtered.filter(s => s.isAvailable === 1 && s.status === 'active');
      } else if (this.filterAvailability === 'unavailable') {
        filtered = filtered.filter(s => s.isAvailable !== 1 || s.status !== 'active');
      }
      
      // Filtrar por precio (rango de 1$ al valor seleccionado)
      filtered = filtered.filter(s => {
        const price = this.parsePrice(s.price);
        return price >= 1 && price <= this.priceRange;
      });
      
      // Ordenar
      switch (this.sortBy) {
        case 'recent':
          filtered.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
          break;
        case 'price-low':
          filtered.sort((a, b) => this.parsePrice(a.price) - this.parsePrice(b.price));
          break;
        case 'price-high':
          filtered.sort((a, b) => this.parsePrice(b.price) - this.parsePrice(a.price));
          break;
        case 'rating':
          filtered.sort((a, b) => {
            const ratingA = this.getProviderRating(a);
            const ratingB = this.getProviderRating(b);
            return ratingB - ratingA;
          });
          break;
        case 'name':
          filtered.sort((a, b) => (a.title || '').localeCompare(b.title || ''));
          break;
      }
      
      return filtered;
    },
    paginatedServices() {
      const start = (this.currentPage - 1) * this.itemsPerPage;
      const end = start + this.itemsPerPage;
      return this.filteredServices.slice(start, end);
    },
    totalPages() {
      return Math.ceil(this.filteredServices.length / this.itemsPerPage);
    }
  },
  watch: {
    priceRange() {
      this.currentPage = 1;
    },
    filterAvailability() {
      this.currentPage = 1;
    },
    sortBy() {
      this.currentPage = 1;
    }
  },
  mounted() {
    // Inicializar el rango de precio
    this.$nextTick(() => {
      this.priceRange = this.maxPrice;
    });
  },
  methods: {
    sanitize(str) {
      if (!str || typeof str !== 'string') return '';
      const tempDiv = document.createElement('div');
      tempDiv.textContent = str;
      return tempDiv.innerHTML
        .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
        .replace(/on\w+="[^"]*"/g, '').replace(/on\w+='[^']*'/g, '')
        .replace(/javascript:/gi, '');
    },
    formatDate(date) {
      return formatDateUtil(date);
    },
    parsePrice(price) {
      if (!price && price !== 0) return 0;
      const num = Number(price);
      return isNaN(num) ? 0 : num;
    },
    formatServicePrice(service) {
      const price = this.parsePrice(service.price);
      return price.toFixed(2);
    },
getServiceImage(service) {
  if (service.image_url) {
    if (service.image_url.startsWith('http')) {
      return service.image_url;
    } else if (service.image_url.startsWith('/uploads/')) {
      return getImageUrl(service.image_url);
    }
    return getImageUrl(`/uploads/${service.image_url}`);
  }
  return 'https://images.unsplash.com/photo-1556761175-b413da4baf72?w=300&h=200&fit=crop&crop=entropy';
},
  getProviderAvatar(service) {
  if (service.provider?.avatar_url) {
    if (service.provider.avatar_url.startsWith('http')) {
      return service.provider.avatar_url;
    }
    return getImageUrl(`/uploads/avatars/${service.provider.avatar_url}`);
  }
  return '/img/default-provider.png';
},
    getProviderRating(service) {
      const rating = service.provider?.rating;
      if (rating === null || rating === undefined) return 0;
      const num = Number(rating);
      return isNaN(num) ? 0 : num;
    },
    hasValidRating(service) {
      const rating = this.getProviderRating(service);
      return rating > 0;
    },
    formatRating(service) {
      const rating = this.getProviderRating(service);
      return rating.toFixed(1);
    },
    handleImageError(event) {
      event.target.src = 'https://images.unsplash.com/photo-1556761175-b413da4baf72?w=300&h=200&fit=crop';
    },
    handleAvatarError(event) {
      event.target.src = '/img/default-provider.png';
    },
    handleSearch() {
      clearTimeout(this.searchTimeout);
      this.searchTimeout = setTimeout(() => {
        this.currentPage = 1;
      }, 300);
    },
    clearSearch() {
      this.searchQuery = '';
      this.currentPage = 1;
    },
    toggleFilters() {
      this.showFilters = !this.showFilters;
    },
    resetFilters() {
      this.filterAvailability = 'all';
      this.sortBy = 'recent';
      this.searchQuery = '';
      this.priceRange = this.maxPrice;
      this.currentPage = 1;
      this.showFilters = false;
    },
    updatePriceRange() {
      this.currentPage = 1;
    },
    prevPage() {
      if (this.currentPage > 1) {
        this.currentPage--;
        this.scrollToTop();
      }
    },
    nextPage() {
      if (this.currentPage < this.totalPages) {
        this.currentPage++;
        this.scrollToTop();
      }
    },
    scrollToTop() {
      window.scrollTo({ top: 0, behavior: 'smooth' });
    }
  }
};
</script>

<style scoped>
.servicios-container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 0 16px;
  min-height: 100vh;
}

/* Header simplificado */
.header-section {
 margin-bottom: 32px;
}

.header-content {
  text-align: center;
  margin-bottom: 24px;
}

.header-content h1 {
  font-size: 2.2rem;
  color: #2d3436;
  margin-bottom: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
}

.header-content .icon {
  font-size: 2rem;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.1); }
}

.header-content p {
  color: #636e72;
  font-size: 1rem;
  max-width: 600px;
  margin: 0 auto;
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

.loading-container p {
  color: #636e72;
  font-size: 1.1rem;
}

/* Buscador mejorado */
.search-section {
  margin-bottom: 24px;
}

.search-container {
  position: relative;
  display: flex;
  align-items: center;
  background: white;
  border-radius: 50px;
  padding: 8px 20px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  border: 2px solid #e0e0e0;
  transition: all 0.3s;
}

.search-container:focus-within {
  border-color: #3498db;
  box-shadow: 0 6px 25px rgba(52, 152, 219, 0.15);
  transform: translateY(-2px);
}

.search-icon {
  font-size: 1.3rem;
  margin-right: 12px;
  color: #636e72;
}

.search-input {
  flex: 1;
  border: none;
  outline: none;
  padding: 16px 0;
  font-size: 1rem;
  background: transparent;
  color: #2d3436;
}

.search-input::placeholder {
  color: #b2bec3;
}

.search-actions {
  display: flex;
  align-items: center;
  gap: 8px;
}

.btn-clear-search {
  background: #ff7675;
  color: white;
  border: none;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  cursor: pointer;
  font-size: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s;
}

.btn-clear-search:hover {
  background: #d63031;
  transform: rotate(90deg);
}

.btn-filter-toggle {
  background: #74b9ff;
  color: white;
  border: none;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  cursor: pointer;
  font-size: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s;
}

.btn-filter-toggle:hover {
  background: #0984e3;
  transform: rotate(90deg);
}

.btn-filter-toggle.active {
  background: #0984e3;
  box-shadow: 0 0 0 3px rgba(9, 132, 227, 0.2);
}

.search-stats {
  margin-top: 12px;
  text-align: center;
}

.search-results-count {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 6px 16px;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 600;
  display: inline-block;
  box-shadow: 0 3px 10px rgba(102, 126, 234, 0.3);
}

/* Filtros desplegables */
.filters-collapsible {
  background: white;
  border-radius: 16px;
  margin-bottom: 32px;
  overflow: hidden;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
  animation: slideDown 0.3s ease-out;
}

@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.filters-section {
  padding: 24px;
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 24px;
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
  display: flex;
  justify-content: space-between;
}

.filter-select {
  padding: 12px;
  border: 2px solid #dfe6e9;
  border-radius: 10px;
  font-size: 0.95rem;
  transition: all 0.3s;
  background: white;
  cursor: pointer;
}

.filter-select:focus {
  outline: none;
  border-color: #3498db;
  box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
}

/* Price Range */
.price-range {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-top: 8px;
}

.price-range span {
  color: #636e72;
  font-size: 0.9rem;
  min-width: 40px;
  text-align: center;
}

.range-slider {
  flex: 1;
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
  transition: all 0.2s;
}

.range-slider::-webkit-slider-thumb:hover {
  transform: scale(1.1);
  box-shadow: 0 3px 12px rgba(0, 0, 0, 0.4);
}

.price-range-labels {
  display: flex;
  justify-content: space-between;
  margin-top: 4px;
  color: #636e72;
  font-size: 0.8rem;
}

/* Filter Actions */
.filter-actions {
  grid-column: 1 / -1;
  display: flex;
  justify-content: center;
  margin-top: 8px;
}

.btn-reset-filters {
  background: #dfe6e9;
  color: #2d3436;
  border: none;
  padding: 10px 20px;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  font-size: 0.9rem;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s;
}

.btn-reset-filters:hover {
  background: #b2bec3;
  transform: translateY(-2px);
}

/* Services Grid - LOS ESTILOS DE LAS TARJETAS SE MANTIENEN IGUAL */
.services-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 32px;
  margin-bottom: 40px;
}

.service-card-modern {
  background: white;
  border-radius: 20px;
  overflow: hidden;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
  transition: all 0.4s;
  position: relative;
  border: 1px solid #f1f2f6;
  cursor: pointer;
}

.service-card-modern:hover {
  transform: translateY(-10px);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
}

/* Badge */
.card-badge {
  position: absolute;
  top: 16px;
  left: 16px;
  color: white;
  padding: 6px 16px;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
  z-index: 2;
}

.card-badge.available {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
}

.card-badge.unavailable {
  background: linear-gradient(135deg, #ff7675 0%, #d63031 100%);
}

/* Card Image */
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

.service-card-modern:hover .card-image img {
  transform: scale(1.05);
}

.image-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(to bottom, transparent 50%, rgba(0,0,0,0.3));
}

/* Card Content */
.card-content {
  padding: 24px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.service-category {
  background: #dfe6e9;
  color: #2d3436;
  padding: 6px 16px;
  border-radius: 15px;
  font-size: 0.8rem;
  font-weight: 600;
}

.service-date {
  color: #636e72;
  font-size: 0.8rem;
}

.service-title {
  font-size: 1.4rem;
  color: #2d3436;
  margin-bottom: 12px;
  line-height: 1.3;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.service-description {
  color: #636e72;
  font-size: 0.95rem;
  line-height: 1.5;
  margin-bottom: 20px;
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

/* Provider Info */
.service-provider {
  margin-bottom: 24px;
}

.provider-info {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  background: #f8f9fa;
  border-radius: 12px;
}

.provider-avatar {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  object-fit: cover;
  border: 3px solid white;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.provider-details {
  flex: 1;
}

.provider-name {
  display: block;
  font-weight: 600;
  color: #2d3436;
  margin-bottom: 4px;
}

.provider-rating {
  display: flex;
  align-items: center;
  gap: 4px;
}

.stars {
  color: #fdcb6e;
}

.rating-value {
  font-weight: 600;
  color: #636e72;
  font-size: 0.9rem;
}

/* Card Footer */
.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 20px;
  border-top: 1px solid #f1f2f6;
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
  padding: 12px 24px;
  border-radius: 10px;
  cursor: pointer;
  font-weight: 600;
  font-size: 0.9rem;
  transition: all 0.3s;
  white-space: nowrap;
}

.btn-view:hover {
  background: #2980b9;
  transform: translateY(-2px);
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

.empty-state h3 {
  color: #2d3436;
  margin-bottom: 12px;
  font-size: 1.8rem;
}

.empty-state p {
  color: #636e72;
  font-size: 1.1rem;
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
  border: none;
  cursor: pointer;
  font-weight: 600;
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
  transform: translateY(-2px);
}

/* Pagination */
.pagination-section {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px;
  background: white;
  border-radius: 16px;
  margin-top: 32px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
}

.pagination-info {
  color: #636e72;
  font-size: 0.9rem;
}

.pagination-controls {
  display: flex;
  align-items: center;
  gap: 24px;
}

.pagination-btn {
  background: #3498db;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s;
}

.pagination-btn:hover:not(:disabled) {
  background: #2980b9;
  transform: translateY(-2px);
}

.pagination-btn:disabled {
  background: #b2bec3;
  cursor: not-allowed;
  opacity: 0.6;
}

.pagination-page {
  color: #2d3436;
  font-weight: 600;
  min-width: 120px;
  text-align: center;
}

/* Responsive */
@media (max-width: 1200px) {
  .services-grid {
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  }
}

@media (max-width: 768px) {
  .servicios-container {
    padding: 0 12px;
  }
  
  .header-content h1 {
    font-size: 1.8rem;
  }
  
  .search-container {
    padding: 6px 16px;
    border-radius: 40px;
  }
  
  .search-input {
    font-size: 0.95rem;
    padding: 14px 0;
  }
  
  .search-icon {
    font-size: 1.2rem;
    margin-right: 8px;
  }
  
  .filters-section {
    grid-template-columns: 1fr;
    padding: 20px;
  }
  
  .services-grid {
    grid-template-columns: 1fr;
    gap: 24px;
  }
  
  .card-footer {
    flex-direction: column;
    gap: 16px;
    align-items: stretch;
  }
  
  .btn-view {
    width: 100%;
  }
  
  .pagination-section {
    flex-direction: column;
    gap: 16px;
    text-align: center;
  }
  
  .empty-actions {
    flex-direction: column;
    align-items: center;
  }
  
  .btn-primary, .btn-secondary {
    width: 100%;
    max-width: 300px;
  }
}

@media (max-width: 480px) {
  .header-content h1 {
    font-size: 1.6rem;
    flex-direction: column;
    gap: 8px;
  }
  
  .price-range {
    flex-direction: column;
    align-items: stretch;
    gap: 8px;
  }
  
  .search-input::placeholder {
    font-size: 0.9rem;
  }
  
  .service-card-modern {
    border-radius: 16px;
  }
  
  .card-content {
    padding: 20px;
  }
}
</style>
