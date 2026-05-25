<!-- src/pages/admin/ContentManager.vue - COMPLETO CON LAS 4 TABLAS -->
<template>
  <div class="admin-content-manager">
    <!-- Loading State -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner"></div>
      <p>Cargando gestor de contenido...</p>
    </div>
    
    <template v-else>
      <!-- Header -->
      <div class="page-header">
        <div class="header-left">
          <h1 class="page-title">
            <span class="title-icon">📝</span>
            Gestor de Contenido
          </h1>
          <p class="page-subtitle">Administra categorías, páginas, FAQs y contenido estático</p>
        </div>

        <div class="header-actions">
          <button
            class="btn-create"
            @click="showCreateModal = true"
            v-if="showCreateButton"
          >
            <span class="btn-icon">➕</span>
            Crear {{ getCreateButtonText }}
          </button>
          <button class="btn-refresh" @click="loadAllContent">
            🔄 Actualizar
          </button>
        </div>
      </div>

      <!-- Tabs -->
      <div class="content-tabs">
        <button
          v-for="tab in tabs"
          :key="tab.id"
          class="tab-button"
          :class="{ active: activeTab === tab.id }"
          @click="switchTab(tab.id)"
        >
          <span class="tab-icon">{{ tab.icon }}</span>
          {{ tab.name }}
          <span v-if="tab.count > 0" class="tab-count">{{ tab.count }}</span>
        </button>
      </div>

      <!-- Mensajes de estado -->
      <div v-if="successMessage" class="message-success">
        <span class="message-icon">✅</span>
        {{ successMessage }}
        <button class="message-close" @click="successMessage = ''">×</button>
      </div>
      <div v-if="errorMessage" class="message-error">
        <span class="message-icon">❌</span>
        {{ errorMessage }}
        <button class="message-close" @click="errorMessage = ''">×</button>
      </div>
      
      <!-- Contenido de pestañas -->
      <div class="tab-content">
        <!-- Pestaña 1: Categorías -->
        <div v-if="activeTab === 'categories'" class="tab-panel">
          <div class="section-header">
            <h2>🏷️ Categorías de Servicios</h2>
            <p>Organiza los servicios por categorías para mejor navegación</p>
          </div>
          
          <!-- Estadísticas -->
          <div class="stats-cards">
            <div class="stat-card">
              <div class="stat-icon">📊</div>
              <div class="stat-content">
                <h4>Total Categorías</h4>
                <p class="stat-value">{{ categories?.length }}</p>
              </div>
            </div>
            <div class="stat-card">
              <div class="stat-icon">📦</div>
              <div class="stat-content">
                <h4>Categorías Activas</h4>
                <p class="stat-value">{{ activeCategoriesCount }}</p>
              </div>
            </div>
            <div class="stat-card">
              <div class="stat-icon">⭐</div>
              <div class="stat-content">
                <h4>Servicios Totales</h4>
                <p class="stat-value">{{ totalServicesCount }}</p>
              </div>
            </div>
          </div>
          
          <!-- Lista de categorías -->
          <div class="categories-list">
            <div v-if="!categories.length" class="empty-state">
              <div class="empty-icon">🏷️</div>
              <h3>No hay categorías creadas</h3>
              <p>Crea tu primera categoría para organizar los servicios</p>
              <button class="btn-create-empty" @click="showCreateModal = true">
                ➕ Crear Primera Categoría
              </button>
            </div>
            
            <div v-else>
              <!-- Ordenar categorías -->
              <div class="sort-controls">
                <label class="sort-label">
                  Ordenar por:
                  <select v-model="categoriesSortBy" class="sort-select">
                    <option value="sort_order">Orden personalizado</option>
                    <option value="name">Nombre (A-Z)</option>
                    <option value="service_count">Servicios (mayor a menor)</option>
                    <option value="created_at">Más recientes</option>
                  </select>
                </label>
                <button
                  class="btn-save-order"
                  @click="saveCategoriesOrder"
                  :disabled="!orderChanged"
                  v-if="categoriesSortBy === 'sort_order'"
                >
                  💾 Guardar Orden
                </button>
              </div>
              
              <!-- Lista SIMPLE sin draggable -->
              <div class="categories-list-simple">
                <div v-for="category in categories" :key="category.id" class="category-card">
                  <div class="category-header">
                    <div class="category-info">
                      <!-- Quitamos el drag-handle -->
                      <div class="category-icon" :style="{ backgroundColor: category.color || '#667eea' }">
                        {{ category.icon || '📦' }}
                      </div>
                      <div>
                        <h4 class="category-name">{{ category.name }}</h4>
                        <p class="category-description">{{ category.description || 'Sin descripción' }}</p>
                        <div class="category-meta">
                          <span class="meta-item">
                            📅 {{ formatDate(category.created_at) }}
                          </span>
                          <span class="meta-item" v-if="category.updated_at !== category.created_at">
                            ✏️ Actualizado: {{ formatDate(category.updated_at) }}
                          </span>
                        </div>
                      </div>
                    </div>
                    <div class="category-stats">
                      <span class="stat-badge">
                        📦 {{ category?.service_count || 0 }} servicios
                      </span>
                      <span class="stat-badge" :class="category?.is_active ? 'active' : 'inactive'">
                        {{ category?.is_active ? '✅ Activa' : '❌ Inactiva' }}
                      </span>
                    </div>
                  </div>

                  <div class="category-actions">
                    <button class="btn-edit" @click="editCategory(category)">
                      ✏️ Editar
                    </button>
                    <button
                      class="btn-toggle"
                      @click="toggleCategoryStatus(category)"
                      :class="category?.is_active ? 'btn-deactivate' : 'btn-activate'"
                    >
                      {{ category?.is_active ? '❌ Desactivar' : '✅ Activar' }}
                    </button>
                    <button
                      class="btn-delete"
                      @click="deleteCategory(category.id)"
                      :disabled="category?.service_count > 0"
                      :title="category?.service_count > 0 ? 'No se puede eliminar: tiene servicios asignados' : 'Eliminar categoría'"
                    >
                      🗑️ Eliminar
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Pestaña 2: Páginas Estáticas -->
        <div v-if="activeTab === 'pages'" class="tab-panel">
          <div class="section-header">
            <h2>📄 Páginas Estáticas</h2>
            <p>Administra páginas como Términos, Privacidad, Ayuda, etc.</p>
          </div>

          <!-- Estadísticas -->
          <div class="stats-cards">
            <div class="stat-card">
              <div class="stat-icon">📄</div>
              <div class="stat-content">
                <h4>Total Páginas</h4>
                <p class="stat-value">{{ pages?.length }}</p>
              </div>
            </div>
            <div class="stat-card">
              <div class="stat-icon">📱</div>
              <div class="stat-content">
                <h4>En Menú</h4>
                <p class="stat-value">{{ pagesInMenuCount }}</p>
              </div>
            </div>
            <div class="stat-card">
              <div class="stat-icon">✅</div>
              <div class="stat-content">
                <h4>Activas</h4>
                <p class="stat-value">{{ activePagesCount }}</p>
              </div>
            </div>
          </div>

          <!-- Lista de páginas -->
          <div class="pages-list">
            <div v-if="!pages.length" class="empty-state">
              <div class="empty-icon">📄</div>
              <h3>No hay páginas creadas</h3>
              <p>Crea páginas como Términos, Privacidad o Acerca de Nosotros</p>
              <button class="btn-create-empty" @click="showCreateModal = true">
                ➕ Crear Primera Página
              </button>
            </div>

            <div v-else>
              <div class="table-container">
                <table class="pages-table">
                  <thead>
                    <tr>
                      <th>Título</th>
                      <th>URL</th>
                      <th>Estado</th>
                      <th>Menú</th>
                      <th>Acciones</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="page in pages" :key="page.id">
                      <td>
                        <strong>{{ page.title }}</strong>
                        <p class="page-preview">{{ truncateText(page.content || '', 100) }}</p>
                      </td>
                      <td>
                        <code>/{{ page.slug }}</code>
                      </td>
                      <td>
                        <span class="status-badge" :class="page?.is_active ? 'active' : 'inactive'">
                          {{ page?.is_active ? 'Activa' : 'Inactiva' }}
                        </span>
                      </td>
                      <td>
                        <span class="menu-badge" :class="page.is_in_menu ? 'in-menu' : 'not-in-menu'">
                          {{ page.is_in_menu ? '✅ En menú' : '❌ No en menú' }}
                        </span>
                      </td>
                      <td>
                        <div class="action-buttons">
                          <button class="btn-action edit" @click="editPage(page)" title="Editar">
                            ✏️
                          </button>
                          <button
                            class="btn-action toggle"
                            @click="togglePageStatus(page)"
                            :title="page?.is_active ? 'Desactivar' : 'Activar'"
                          >
                            {{ page?.is_active ? '❌' : '✅' }}
                          </button>
                          <button
                            class="btn-action menu"
                            @click="togglePageMenu(page)"
                            :title="page.is_in_menu ? 'Quitar del menú' : 'Agregar al menú'"
                          >
                            {{ page.is_in_menu ? '📋' : '➕' }}
                          </button>
                          <button
                            class="btn-action delete"
                            @click="deletePage(page.id)"
                            title="Eliminar"
                            :disabled="isDefaultPage(page.slug)"
                            :class="{ disabled: isDefaultPage(page.slug) }"
                          >
                            🗑️
                          </button>
                        </div>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>

        <!-- Pestaña 3: FAQs -->
        <div v-if="activeTab === 'faqs'" class="tab-panel">
          <div class="section-header">
            <h2>❓ Preguntas Frecuentes (FAQs)</h2>
            <p>Administra las preguntas frecuentes que ven los usuarios</p>
          </div>
          
          <!-- Estadísticas -->
          <div class="stats-cards">
            <div class="stat-card">
              <div class="stat-icon">❓</div>
              <div class="stat-content">
                <h4>Total FAQs</h4>
                <p class="stat-value">{{ faqs?.length }}</p>
              </div>
            </div>
            <div class="stat-card">
              <div class="stat-icon">✅</div>
              <div class="stat-content">
                <h4>Activas</h4>
                <p class="stat-value">{{ activeFaqsCount }}</p>
              </div>
            </div>
            <div class="stat-card">
              <div class="stat-icon">📊</div>
              <div class="stat-content">
                <h4>Ordenadas</h4>
                <p class="stat-value">{{ sortedFaqsCount }}</p>
              </div>
            </div>
          </div>
          
          <!-- Lista de FAQs -->
          <div class="faqs-list">
            <div v-if="!faqs.length" class="empty-state">
              <div class="empty-icon">❓</div>
              <h3>No hay FAQs creadas</h3>
              <p>Crea preguntas frecuentes para ayudar a tus usuarios</p>
              <button class="btn-create-empty" @click="showCreateModal = true">
                ➕ Crear Primera FAQ
              </button>
            </div>

            <div v-else>
              <!-- Ordenar FAQs -->
              <div class="sort-controls">
                <label class="sort-label">
                  Ordenar por:
                  <select v-model="faqsSortBy" class="sort-select">
                    <option value="sort_order">Orden personalizado</option>
                    <option value="question">Pregunta (A-Z)</option>
                    <option value="created_at">Más recientes</option>
                  </select>
                </label>
                <button
                  class="btn-save-order"
                  @click="saveFaqsOrder"
                  :disabled="!faqsOrderChanged"
                  v-if="faqsSortBy === 'sort_order'"
                >
                  💾 Guardar Orden
                </button>
              </div>

              <!-- Lista SIMPLE sin draggable -->
              <div class="faqs-list-simple">
                <div v-for="faq in faqs" :key="faq.id" class="faq-card">
                  <div class="faq-header">
                    <div class="faq-content">
                      <h4 class="faq-question">{{ faq.question }}</h4>
                      <div class="faq-answer" v-html="truncateText(faq.answer, 150)"></div>
                      <div class="faq-meta">
                        <span class="meta-item">
                          #{{ faq.sort_order || 0 }}
                        </span>
                        <span class="meta-item">
                          📅 {{ formatDate(faq.created_at) }}
                        </span>
                        <span class="meta-item" :class="faq?.is_active ? 'active' : 'inactive'">
                          {{ faq?.is_active ? '✅ Activa' : '❌ Inactiva' }}
                        </span>
                      </div>
                    </div>
                  </div>

                  <div class="faq-actions">
                    <button class="btn-edit" @click="editFaq(faq)">
                      ✏️ Editar
                    </button>
                    <button
                      class="btn-toggle"
                      @click="toggleFaqStatus(faq)"
                      :class="faq?.is_active ? 'btn-deactivate' : 'btn-activate'"
                    >
                      {{ faq?.is_active ? '❌ Desactivar' : '✅ Activar' }}
                    </button>
                    <button class="btn-delete" @click="deleteFaq(faq.id)">
                      🗑️ Eliminar
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        
        <!-- Pestaña 4: Bloques de Contenido -->
        <div v-if="activeTab === 'blocks'" class="tab-panel">
          <div class="section-header">
            <h2>🧱 Bloques de Contenido</h2>
            <p>Administra banners, textos y contenido reutilizable</p>
          </div>
          
          <!-- Estadísticas -->
          <div class="stats-cards">
            <div class="stat-card">
              <div class="stat-icon">🧱</div>
              <div class="stat-content">
                <h4>Total Bloques</h4>
                <p class="stat-value">{{ blocks?.length }}</p>
              </div>
            </div>
            <div class="stat-card">
              <div class="stat-icon">📊</div>
              <div class="stat-content">
                <h4>Tipos</h4>
                <p class="stat-value">{{ blockTypesCount }}</p>
              </div>
            </div>
            <div class="stat-card">
              <div class="stat-icon">✅</div>
              <div class="stat-content">
                <h4>Activos</h4>
                <p class="stat-value">{{ activeBlocksCount }}</p>
              </div>
            </div>
          </div>
          
          <!-- Lista de bloques -->
          <div class="blocks-list">
            <div v-if="!blocks.length" class="empty-state">
              <div class="empty-icon">🧱</div>
              <h3>No hay bloques creados</h3>
              <p>Crea banners, textos o contenido reutilizable</p>
              <button class="btn-create-empty" @click="showCreateModal = true">
                ➕ Crear Primer Bloque
              </button>
            </div>
            
            <div v-else>
              <div class="blocks-grid">
                <div v-for="block in blocks" :key="block.id" class="block-card">
                  <div class="block-header">
                    <div class="block-type" :class="block.type">
                      {{ getBlockTypeIcon(block.type) }}
                    </div>
                    <div>
                      <h4 class="block-name">{{ block.name }}</h4>
                      <code class="block-identifier">{{ block.identifier }}</code>
                    </div>
                  </div>
                  
                  <div class="block-preview">
                    <div v-if="block.type === 'text' || block.type === 'html'" class="text-preview">
                      {{ truncateText(block.content, 100) }}
                    </div>
                    <div v-else-if="block.type === 'banner'" class="banner-preview">
                      🖼️ Banner
                    </div>
                    <div v-else-if="block.type === 'image'" class="image-preview">
                      📷 Imagen
                    </div>
                    <div v-else class="default-preview">
                      {{ block.type }}
                    </div>
                  </div>
                  
                  <div class="block-meta">
                    <span class="meta-item">
                      {{ formatDate(block.created_at) }}
                    </span>
                    <span class="meta-item" :class="block?.is_active ? 'active' : 'inactive'">
                      {{ block?.is_active ? '✅ Activo' : '❌ Inactivo' }}
                    </span>
                  </div>

                  <div class="block-actions">
                    <button class="btn-edit" @click="editBlock(block)">
                      ✏️ Editar
                    </button>
                    <button
                      class="btn-toggle"
                      @click="toggleBlockStatus(block)"
                      :class="block?.is_active ? 'btn-deactivate' : 'btn-activate'"
                    >
                      {{ block?.is_active ? '❌ Desactivar' : '✅ Activar' }}
                    </button>
                    <button class="btn-delete" @click="deleteBlock(block.id)">
                      🗑️ Eliminar
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </template>

    <!-- Modales -->
    <CategoryModal
      v-if="showCreateModal && activeTab === 'categories'"
      :category="editingItem"
      @save="handleSaveCategory"
      @close="closeModal"
    />
    
    <PageModal
      v-if="showCreateModal && activeTab === 'pages'"
      :page="editingItem"
      @save="handleSavePage"
      @close="closeModal"
    />
    
    <FaqModal
      v-if="showCreateModal && activeTab === 'faqs'"
      :faq="editingItem"
      @save="handleSaveFaq"
      @close="closeModal"
    />

    <BlockModal
      v-if="showCreateModal && activeTab === 'blocks'"
      :block="editingItem"
      @save="handleSaveBlock"
      @close="closeModal"
    />
  </div>
</template>


<script setup>
import { ref, onMounted, computed, watch } from 'vue'
import { useAuthStore } from '@/stores/authStore'
import { VueDraggableNext } from 'vue-draggable-next'
import api from '@/axios'

// Importar modales
import CategoryModal from '@/pages/admin/modals/CategoryModal.vue'
import PageModal from '@/pages/admin/modals/PageModal.vue'
import FaqModal from '@/pages/admin/modals/FaqModal.vue'
import BlockModal from '@/pages/admin/modals/BlockModal.vue'

const authStore = useAuthStore()

// Exponer draggable al template (CORRECCIÓN CLAVE)
const draggable = VueDraggableNext

// Estados
const loading = ref(true)
const activeTab = ref('categories')
const showCreateModal = ref(false)
const editingItem = ref(null)

// Datos
const categories = ref([])
const pages = ref([])
const faqs = ref([])
const blocks = ref([])

// Ordenamiento
const categoriesSortBy = ref('sort_order')
const faqsSortBy = ref('sort_order')
const orderChanged = ref(false)
const faqsOrderChanged = ref(false)

// Tabs
const tabs = ref([
  { id: 'categories', name: 'Categorías', icon: '🏷️', count: 0 },
  { id: 'pages', name: 'Páginas', icon: '📄', count: 0 },
  { id: 'faqs', name: 'FAQs', icon: '❓', count: 0 },
  { id: 'blocks', name: 'Bloques', icon: '🧱', count: 0 }
])

// Mensajes
const successMessage = ref('')
const errorMessage = ref('')

// Computed
const showCreateButton = computed(() => {
  return ['categories', 'pages', 'faqs', 'blocks'].includes(activeTab?.value)
})

const getCreateButtonText = computed(() => {
  const texts = {
    'categories': 'Categoría',
    'pages': 'Página',
    'faqs': 'FAQ',
    'blocks': 'Bloque'
  }
  return texts[activeTab?.value] || 'Nuevo'
})

// Estadísticas
const activeCategoriesCount = computed(() => {
  return categories.value.filter(c => c?.is_active).length
})

const totalServicesCount = computed(() => {
  return categories.value.reduce((sum, cat) => sum + (cat?.service_count || 0), 0)
})

const pagesInMenuCount = computed(() => {
  return pages.value.filter(p => p?.is_in_menu).length
})

const activePagesCount = computed(() => {
  return pages.value.filter(p => p?.is_active).length
})

const activeFaqsCount = computed(() => {
  return faqs.value.filter(f => f?.is_active).length
})

const sortedFaqsCount = computed(() => {
  return faqs.value.filter(f => f?.sort_order > 0).length
})

const activeBlocksCount = computed(() => {
  return blocks.value.filter(b => b?.is_active).length
})

const blockTypesCount = computed(() => {
  const types = new Set(blocks.value.map(b => b.type))
  return types.size
})

// Lifecycle
onMounted(async () => {
  await loadAllContent()
})

// Watch para ordenamiento
watch(categoriesSortBy, (newSort) => {
  sortCategories(newSort)
})

watch(faqsSortBy, (newSort) => {
  sortFaqs(newSort)
})

// Métodos principales
async function loadAllContent() {
  try {
    loading.value = true
    await Promise.all([
      loadCategories(),
      loadPages(),
      loadFaqs(),
      loadBlocks()
    ])

    // Actualizar contadores de tabs
    tabs.value[0].count = categories?.value?.length
    tabs.value[1].count = pages?.value?.length
    tabs.value[2].count = faqs?.value?.length
    tabs.value[3].count = blocks?.value?.length

    // Ordenar inicialmente
    sortCategories(categoriesSortBy?.value)
    sortFaqs(faqsSortBy?.value)

  } catch (error) {
    console.error('Error cargando contenido:', error)
    showError('Error al cargar el contenido')
  } finally {
    loading.value = false
  }
}

// Carga de datos
async function loadCategories() {
  try {
    const response = await api.get('/admin/content/categories', {
      headers: getHeaders()
    })
    categories.value = response.data.categories || []
  } catch (error) {
    console.error('Error cargando categorías:', error)
    categories.value = []
  }
}

async function loadPages() {
  try {
    const response = await api.get('/admin/content/pages', {
      headers: getHeaders()
    })
    pages.value = response.data.pages || []
  } catch (error) {
    console.error('Error cargando páginas:', error)
    pages.value = []
  }
}

async function loadFaqs() {
  try {
    const response = await api.get('/admin/content/faqs', {
      headers: getHeaders()
    })
    faqs.value = response.data.faqs || []
  } catch (error) {
    console.error('Error cargando FAQs:', error)
    faqs.value = []
  }
}

async function loadBlocks() {
  try {
    const response = await api.get('/admin/content/blocks', {
      headers: getHeaders()
    })
    blocks.value = response.data.blocks || []
  } catch (error) {
    console.error('Error cargando bloques:', error)
    blocks.value = []
  }
}

// Métodos para categorías
function editCategory(category) {
  editingItem.value = { ...category }
  showCreateModal.value = true
}

async function toggleCategoryStatus(category) {
  try {
    const newStatus = !category?.is_active
    await api.put(`/admin/content/categories/${category.id}/status`, {
      is_active: newStatus
    }, {
      headers: getHeaders()
    })

    // Actualizar estado local
    const index = categories.value.findIndex(c => c.id === category.id)
    if (categories.value && categories.value[index]) {
      categories.value[index].is_active = newStatus
    }

    showSuccess(`Categoría ${newStatus ? 'activada' : 'desactivada'} correctamente`)
  } catch (error) {
    console.error('Error cambiando estado:', error)
    showError('Error al cambiar el estado')
  }
}

async function deleteCategory(categoryId) {
  if (!confirm('¿Estás seguro de eliminar esta categoría?')) return

  try {
    await api.delete(`/admin/content/categories/${categoryId}`, {
      headers: getHeaders()
    })

    categories.value = categories.value.filter(c => c.id !== categoryId)
    showSuccess('Categoría eliminada correctamente')
  } catch (error) {
    console.error('Error eliminando categoría:', error)
    showError('Error al eliminar la categoría')
  }
}

function handleSaveCategory(categoryData) {
  if (categoryData.id) {
    updateCategory(categoryData)
  } else {
    createCategory(categoryData)
  }
}

async function createCategory(categoryData) {
  try {
    const response = await api.post('/admin/content/categories', categoryData, {
      headers: getHeaders()
    })

    categories?.value.unshift(response.data.category)
    closeModal()
    showSuccess('Categoría creada correctamente')
  } catch (error) {
    console.error('Error creando categoría:', error)
    showError('Error al crear la categoría')
  }
}

async function updateCategory(categoryData) {
  try {
    const response = await api.put(`/admin/content/categories/${categoryData.id}`, categoryData, {
      headers: getHeaders()
    })

    const index = categories.value.findIndex(c => c.id === categoryData.id)
    if (index !== -1) {
      categories.value[index] = response.data.category
    }

    closeModal()
    showSuccess('Categoría actualizada correctamente')
  } catch (error) {
    console.error('Error actualizando categoría:', error)
    showError('Error al actualizar la categoría')
  }
}

// Métodos para páginas
function editPage(page) {
  editingItem.value = { ...page }
  showCreateModal.value = true
}

async function togglePageStatus(page) {
  try {
    const newStatus = !page?.is_active
    await api.put(`/admin/content/pages/${page.id}/status`, {
      is_active: newStatus
    }, {
      headers: getHeaders()
    })

    const index = pages.value.findIndex(p => p.id === page.id)
    if (index !== -1) {
      pages.value[index].is_active = newStatus
    }

    showSuccess(`Página ${newStatus ? 'activada' : 'desactivada'} correctamente`)
  } catch (error) {
    console.error('Error cambiando estado:', error)
    showError('Error al cambiar el estado')
  }
}

async function togglePageMenu(page) {
  try {
    const newMenuStatus = !page.is_in_menu
    await api.put(`/admin/content/pages/${page.id}/menu`, {
      is_in_menu: newMenuStatus
    }, {
      headers: getHeaders()
    })

    const index = pages.value.findIndex(p => p.id === page.id)
    if (index !== -1) {
      pages.value[index].is_in_menu = newMenuStatus
    }

    showSuccess(`Página ${newMenuStatus ? 'agregada al' : 'quitada del'} menú`)
  } catch (error) {
    console.error('Error cambiando menú:', error)
    showError('Error al cambiar el menú')
  }
}

async function deletePage(pageId) {
  if (!confirm('¿Estás seguro de eliminar esta página?')) return

  try {
    await api.delete(`/admin/content/pages/${pageId}`, {
      headers: getHeaders()
    })

    pages.value = pages.value.filter(p => p.id !== pageId)
    showSuccess('Página eliminada correctamente')
  } catch (error) {
    console.error('Error eliminando página:', error)
    showError('Error al eliminar la página')
  }
}

function handleSavePage(pageData) {
  if (pageData.id) {
    updatePage(pageData)
  } else {
    createPage(pageData)
  }
}

async function createPage(pageData) {
  try {
    const response = await api.post('/admin/content/pages', pageData, {
      headers: getHeaders()
    })

    pages?.value.unshift(response.data.page)
    closeModal()
    showSuccess('Página creada correctamente')
  } catch (error) {
    console.error('Error creando página:', error)
    showError('Error al crear la página')
  }
}

async function updatePage(pageData) {
  try {
    const response = await api.put(`/admin/content/pages/${pageData.id}`, pageData, {
      headers: getHeaders()
    })

    const index = pages.value.findIndex(p => p.id === pageData.id)
    if (index !== -1) {
      pages.value[index] = response.data.page
    }

    closeModal()
    showSuccess('Página actualizada correctamente')
  } catch (error) {
    console.error('Error actualizando página:', error)
    showError('Error al actualizar la página')
  }
}

// Métodos para FAQs
function editFaq(faq) {
  editingItem.value = { ...faq }
  showCreateModal.value = true
}

async function toggleFaqStatus(faq) {
  try {
    const newStatus = !faq?.is_active
    await api.put(`/admin/content/faqs/${faq.id}/status`, {
      is_active: newStatus
    }, {
      headers: getHeaders()
    })

    const index = faqs.value.findIndex(f => f.id === faq.id)
    if (index !== -1) {
      faqs.value[index].is_active = newStatus
    }

    showSuccess(`FAQ ${newStatus ? 'activada' : 'desactivada'} correctamente`)
  } catch (error) {
    console.error('Error cambiando estado FAQ:', error)
    showError('Error al cambiar el estado')
  }
}

async function deleteFaq(faqId) {
  if (!confirm('¿Estás seguro de eliminar esta FAQ?')) return

  try {
    await api.delete(`/admin/content/faqs/${faqId}`, {
      headers: getHeaders()
    })

    faqs.value = faqs.value.filter(f => f.id !== faqId)
    showSuccess('FAQ eliminada correctamente')
  } catch (error) {
    console.error('Error eliminando FAQ:', error)
    showError('Error al eliminar la FAQ')
  }
}

function handleSaveFaq(faqData) {
  if (faqData.id) {
    updateFaq(faqData)
  } else {
    createFaq(faqData)
  }
}

async function createFaq(faqData) {
  try {
    const response = await api.post('/admin/content/faqs', faqData, {
      headers: getHeaders()
    })

    faqs?.value.unshift(response.data.faq)
    closeModal()
    showSuccess('FAQ creada correctamente')
  } catch (error) {
    console.error('Error creando FAQ:', error)
    showError('Error al crear la FAQ')
  }
}

async function updateFaq(faqData) {
  try {
    const response = await api.put(`/admin/content/faqs/${faqData.id}`, faqData, {
      headers: getHeaders()
    })

    const index = faqs.value.findIndex(f => f.id === faqData.id)
    if (index !== -1) {
      faqs.value[index] = response.data.faq
    }

    closeModal()
    showSuccess('FAQ actualizada correctamente')
  } catch (error) {
    console.error('Error actualizando FAQ:', error)
    showError('Error al actualizar la FAQ')
  }
}

// Métodos para bloques
function editBlock(block) {
  editingItem.value = { ...block }
  showCreateModal.value = true
}

async function toggleBlockStatus(block) {
  try {
    const newStatus = !block?.is_active
    await api.put(`/admin/content/blocks/${block.id}/status`, {
      is_active: newStatus
    }, {
      headers: getHeaders()
    })

    const index = blocks.value.findIndex(b => b.id === block.id)
    if (index !== -1) {
      blocks.value[index].is_active = newStatus
    }

    showSuccess(`Bloque ${newStatus ? 'activado' : 'desactivado'} correctamente`)
  } catch (error) {
    console.error('Error cambiando estado bloque:', error)
    showError('Error al cambiar el estado')
  }
}

async function deleteBlock(blockId) {
  if (!confirm('¿Estás seguro de eliminar este bloque?')) return

  try {
    await api.delete(`/admin/content/blocks/${blockId}`, {
      headers: getHeaders()
    })

    blocks.value = blocks.value.filter(b => b.id !== blockId)
    showSuccess('Bloque eliminado correctamente')
  } catch (error) {
    console.error('Error eliminando bloque:', error)
    showError('Error al eliminar el bloque')
  }
}

function handleSaveBlock(blockData) {
  if (blockData.id) {
    updateBlock(blockData)
  } else {
    createBlock(blockData)
  }
}

async function createBlock(blockData) {
  try {
    const response = await api.post('/admin/content/blocks', blockData, {
      headers: getHeaders()
    })

    blocks?.value.unshift(response.data.block)
    closeModal()
    showSuccess('Bloque creado correctamente')
  } catch (error) {
    console.error('Error creando bloque:', error)
    showError('Error al crear el bloque')
  }
}

async function updateBlock(blockData) {
  try {
    const response = await api.put(`/admin/content/blocks/${blockData.id}`, blockData, {
      headers: getHeaders()
    })

    const index = blocks.value.findIndex(b => b.id === blockData.id)
    if (index !== -1) {
      blocks.value[index] = response.data.block
    }

    closeModal()
    showSuccess('Bloque actualizado correctamente')
  } catch (error) {
    console.error('Error actualizando bloque:', error)
    showError('Error al actualizar el bloque')
  }
}

// Métodos de utilidad
function getHeaders() {
  return {
    Authorization: `Bearer ${authStore.token}`,
    'Content-Type': 'application/json'
  }
}

function switchTab(tabId) {
  activeTab.value = tabId
  showCreateModal.value = false
  editingItem.value = null
}

function closeModal() {
  showCreateModal.value = false
  editingItem.value = null
}

function sortCategories(sortBy) {
  if (sortBy === 'sort_order') {
    categories.value.sort((a, b) => (a.sort_order || 0) - (b.sort_order || 0))
  } else if (sortBy === 'name') {
    categories.value.sort((a, b) => a.name.localeCompare(b.name))
  } else if (sortBy === 'service_count') {
    categories.value.sort((a, b) => (b?.service_count || 0) - (a?.service_count || 0))
  } else if (sortBy === 'created_at') {
    categories.value.sort((a, b) => new Date(b.created_at) - new Date(a.created_at))
  }
}

function sortFaqs(sortBy) {
  if (sortBy === 'sort_order') {
    faqs.value.sort((a, b) => (a.sort_order || 0) - (b.sort_order || 0))
  } else if (sortBy === 'question') {
    faqs.value.sort((a, b) => a.question.localeCompare(b.question))
  } else if (sortBy === 'created_at') {
    faqs.value.sort((a, b) => new Date(b.created_at) - new Date(a.created_at))
  }
}

function onDragEnd() {
  orderChanged.value = true
}

function onFaqsDragEnd() {
  faqsOrderChanged.value = true
}

async function saveCategoriesOrder() {
  try {
    const orderData = categories.value.map((cat, index) => ({
      id: cat.id,
      sort_order: index + 1
    }))

    await api.put('/admin/content/categories/order', { order: orderData }, {
      headers: getHeaders()
    })

    orderChanged.value = false
    showSuccess('Orden de categorías guardado correctamente')
  } catch (error) {
    console.error('Error guardando orden:', error)
    showError('Error al guardar el orden')
  }
}

async function saveFaqsOrder() {
  try {
    const orderData = faqs.value.map((faq, index) => ({
      id: faq.id,
      sort_order: index + 1
    }))

    await api.put('/admin/content/faqs/order', { order: orderData }, {
      headers: getHeaders()
    })

    faqsOrderChanged.value = false
    showSuccess('Orden de FAQs guardado correctamente')
  } catch (error) {
    console.error('Error guardando orden FAQs:', error)
    showError('Error al guardar el orden')
  }
}

function truncateText(text, maxLength) {
  if (!text) return ''
  if (text.length <= maxLength) return text
  return text.substring(0, maxLength) + '...'
}

function formatDate(dateString) {
  if (!dateString) return 'N/A'
  const date = new Date(dateString)
  return date.toLocaleDateString('es-ES', {
    day: 'numeric',
    month: 'short',
    year: 'numeric'
  })
}

function getBlockTypeIcon(type) {
  const icons = {
    'text': '📝',
    'html': '📄',
    'image': '🖼️',
    'banner': '🎪',
    'carousel': '🔄',
    'default': '🧱'
  }
  return icons[type] || icons.default
}

function isDefaultPage(slug) {
  const defaultPages = ['terms', 'privacy', 'about', 'help', 'contact']
  return defaultPages.includes(slug)
}

function showSuccess(message) {
  successMessage.value = message
  setTimeout(() => successMessage.value = '', 5000)
}

function showError(message) {
  errorMessage.value = message
  setTimeout(() => errorMessage.value = '', 8000)
}
</script>

<style scoped>
/* ===== LAYOUT & CONTENEDORES ===== */
.admin-content-manager {
  max-width: 1200px;
  margin: 0 auto;
  padding: 24px;
}

/* ===== ESTADOS DE CARGA ===== */
.loading-overlay {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 400px;
}

.loading-spinner {
  width: 50px;
  height: 50px;
  border: 5px solid #f3f3f3;
  border-top: 5px solid #667eea;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 20px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* ===== ENCABEZADO ===== */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 32px;
  padding-bottom: 24px;
  border-bottom: 2px solid #e2e8f0;
}

.header-left h1 {
  font-size: 2rem;
  font-weight: 700;
  color: #2d3436;
  margin-bottom: 8px;
  display: flex;
  align-items: center;
  gap: 12px;
}

.page-subtitle {
  color: #636e72;
  font-size: 1.1rem;
}

.header-actions {
  display: flex;
  gap: 12px;
}

/* ===== BOTONES PRINCIPALES ===== */
.btn-create,
.btn-refresh,
.btn-create-empty,
.btn-save-order {
  padding: 12px 24px;
  border-radius: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  border: none;
  display: flex;
  align-items: center;
  gap: 8px;
}

.btn-create {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.btn-create:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
}

.btn-refresh {
  background: #f1f5f9;
  color: #4a5568;
  border: 2px solid #e2e8f0;
}

.btn-refresh:hover {
  background: #e2e8f0;
  color: #2d3436;
}

/* ===== PESTAÑAS ===== */
.content-tabs {
  display: flex;
  gap: 8px;
  margin-bottom: 32px;
  border-bottom: 2px solid #e2e8f0;
  padding-bottom: 8px;
  overflow-x: auto;
}

.tab-button {
  padding: 12px 24px;
  border: none;
  background: none;
  border-radius: 12px 12px 0 0;
  font-weight: 600;
  color: #636e72;
  cursor: pointer;
  transition: all 0.3s;
  display: flex;
  align-items: center;
  gap: 8px;
  white-space: nowrap;
  position: relative;
}

.tab-button:hover {
  background: #f1f5f9;
  color: #2d3436;
}

.tab-button.active {
  background: #667eea;
  color: white;
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
}

.tab-icon {
  font-size: 1.2rem;
}

.tab-count {
  background: rgba(255, 255, 255, 0.2);
  padding: 2px 8px;
  border-radius: 12px;
  font-size: 0.8rem;
  margin-left: 4px;
}

.tab-button.active .tab-count {
  background: rgba(255, 255, 255, 0.3);
}

/* ===== MENSAJES ===== */
.message-success,
.message-error {
  padding: 16px 24px;
  border-radius: 12px;
  margin-bottom: 24px;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 12px;
  justify-content: space-between;
}

.message-success {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
  color: white;
}

.message-error {
  background: linear-gradient(135deg, #ff7675 0%, #d63031 100%);
  color: white;
}

.message-close {
  background: none;
  border: none;
  color: inherit;
  font-size: 1.2rem;
  cursor: pointer;
  padding: 0;
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* ===== SECCIONES ===== */
.section-header {
  margin-bottom: 32px;
}

.section-header h2 {
  font-size: 1.8rem;
  color: #2d3436;
  margin-bottom: 8px;
  display: flex;
  align-items: center;
  gap: 12px;
}

.section-header p {
  color: #636e72;
  font-size: 1.1rem;
}

/* ===== ESTADÍSTICAS ===== */
.stats-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
  margin-bottom: 32px;
}

.stat-card {
  background: white;
  border: 2px solid #e2e8f0;
  border-radius: 16px;
  padding: 24px;
  display: flex;
  align-items: center;
  gap: 20px;
  transition: all 0.3s;
}

.stat-card:hover {
  transform: translateY(-5px);
  border-color: #667eea;
  box-shadow: 0 10px 25px rgba(102, 126, 234, 0.1);
}

.stat-icon {
  font-size: 2.5rem;
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 12px;
  color: white;
}

.stat-content h4 {
  font-size: 0.9rem;
  color: #636e72;
  margin-bottom: 4px;
}

.stat-value {
  font-size: 1.8rem;
  font-weight: 700;
  color: #2d3436;
}

/* ===== ESTADO VACÍO ===== */
.empty-state {
  text-align: center;
  padding: 60px 24px;
  background: #f8fafc;
  border-radius: 20px;
  border: 2px dashed #cbd5e1;
  margin: 40px 0;
}

.empty-icon {
  font-size: 64px;
  margin-bottom: 20px;
  opacity: 0.5;
}

.empty-state h3 {
  color: #2d3436;
  margin-bottom: 12px;
  font-size: 1.5rem;
}

.empty-state p {
  color: #636e72;
  margin-bottom: 24px;
  max-width: 400px;
  margin-left: auto;
  margin-right: auto;
}

.btn-create-empty {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 14px 32px;
  border-radius: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.btn-create-empty:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
}

/* ===== CONTROLES DE ORDENACIÓN ===== */
.sort-controls {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  padding: 16px;
  background: #f8fafc;
  border-radius: 12px;
  border: 2px solid #e2e8f0;
}

.sort-label {
  display: flex;
  align-items: center;
  gap: 12px;
  font-weight: 600;
  color: #2d3436;
}

.sort-select {
  padding: 10px 16px;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  font-size: 1rem;
  background: white;
  min-width: 180px;
}

.btn-save-order {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
  color: white;
  padding: 10px 20px;
  border-radius: 8px;
}

.btn-save-order:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(0, 184, 148, 0.3);
}

.btn-save-order:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  transform: none !important;
}

/* ===== LISTAS ARRASTRABLES ===== */
.draggable-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.drag-handle {
  cursor: grab;
  padding: 8px;
  color: #94a3b8;
  font-size: 1.2rem;
  user-select: none;
}

.drag-handle:active {
  cursor: grabbing;
}

/* ===== TARJETAS DE CATEGORÍA/FAQ ===== */
.category-card,
.faq-card {
  background: white;
  border: 2px solid #e2e8f0;
  border-radius: 16px;
  padding: 24px;
  transition: all 0.3s;
}

.category-card:hover,
.faq-card:hover {
  border-color: #667eea;
  box-shadow: 0 5px 15px rgba(102, 126, 234, 0.1);
}

.category-header,
.faq-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 20px;
}

.category-info,
.faq-header {
  display: flex;
  align-items: flex-start;
  gap: 16px;
}

.category-icon {
  font-size: 2rem;
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 12px;
  color: white;
  flex-shrink: 0;
}

.category-name {
  font-size: 1.3rem;
  color: #2d3436;
  margin-bottom: 4px;
}

.category-description {
  color: #636e72;
  font-size: 0.95rem;
  max-width: 500px;
  margin-bottom: 12px;
}

.category-meta,
.faq-meta {
  display: flex;
  gap: 16px;
  flex-wrap: wrap;
}

.meta-item {
  font-size: 0.85rem;
  color: #94a3b8;
  display: flex;
  align-items: center;
  gap: 4px;
}

.meta-item.active {
  color: #00b894;
  font-weight: 600;
}

.meta-item.inactive {
  color: #ff7675;
  font-weight: 600;
}

.category-stats {
  display: flex;
  gap: 12px;
  flex-shrink: 0;
}

.stat-badge {
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 600;
  background: #f1f5f9;
  color: #4a5568;
}

.stat-badge.active {
  background: rgba(0, 184, 148, 0.1);
  color: #00b894;
  border: 1px solid rgba(0, 184, 148, 0.3);
}

.stat-badge.inactive {
  background: rgba(255, 118, 117, 0.1);
  color: #ff7675;
  border: 1px solid rgba(255, 118, 117, 0.3);
}

/* ===== BOTONES DE ACCIÓN ===== */
.category-actions,
.faq-actions {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
}

.btn-edit,
.btn-toggle,
.btn-delete {
  padding: 10px 20px;
  border-radius: 10px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  border: none;
  display: flex;
  align-items: center;
  gap: 8px;
}

.btn-edit {
  background: #f1f5f9;
  color: #4a5568;
  border: 2px solid #e2e8f0;
}

.btn-edit:hover {
  background: #e2e8f0;
  color: #2d3436;
}

.btn-toggle.btn-activate {
  background: rgba(0, 184, 148, 0.1);
  color: #00b894;
  border: 2px solid rgba(0, 184, 148, 0.3);
}

.btn-toggle.btn-activate:hover {
  background: rgba(0, 184, 148, 0.2);
}

.btn-toggle.btn-deactivate {
  background: rgba(255, 118, 117, 0.1);
  color: #ff7675;
  border: 2px solid rgba(255, 118, 117, 0.3);
}

.btn-toggle.btn-deactivate:hover {
  background: rgba(255, 118, 117, 0.2);
}

.btn-delete {
  background: rgba(220, 38, 38, 0.1);
  color: #dc2626;
  border: 2px solid rgba(220, 38, 38, 0.3);
}

.btn-delete:hover:not(:disabled) {
  background: rgba(220, 38, 38, 0.2);
}

.btn-delete:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* ===== TABLA DE PÁGINAS ===== */
.pages-list {
  margin-top: 32px;
}

.table-container {
  overflow-x: auto;
  border-radius: 16px;
  border: 2px solid #e2e8f0;
}

.pages-table {
  width: 100%;
  border-collapse: collapse;
  background: white;
}

.pages-table thead {
  background: #f8fafc;
}

.pages-table th {
  padding: 16px 20px;
  text-align: left;
  font-weight: 600;
  color: #2d3436;
  border-bottom: 2px solid #e2e8f0;
}

.pages-table td {
  padding: 20px;
  border-bottom: 1px solid #e2e8f0;
  vertical-align: top;
}

.pages-table tr:hover {
  background: #f8fafc;
}

.pages-table tr:last-child td {
  border-bottom: none;
}

.page-preview {
  color: #636e72;
  font-size: 0.9rem;
  margin-top: 8px;
  line-height: 1.4;
}

code {
  background: #f1f5f9;
  padding: 4px 8px;
  border-radius: 6px;
  font-family: monospace;
  font-size: 0.9rem;
  color: #4a5568;
}

.status-badge,
.menu-badge {
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 600;
}

.status-badge.active,
.menu-badge.in-menu {
  background: rgba(0, 184, 148, 0.1);
  color: #00b894;
  border: 1px solid rgba(0, 184, 148, 0.3);
}

.status-badge.inactive,
.menu-badge.not-in-menu {
  background: rgba(255, 118, 117, 0.1);
  color: #ff7675;
  border: 1px solid rgba(255, 118, 117, 0.3);
}

.action-buttons {
  display: flex;
  gap: 8px;
}

.btn-action {
  width: 36px;
  height: 36px;
  border-radius: 8px;
  border: none;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.1rem;
  transition: all 0.3s;
  background: #f1f5f9;
  color: #4a5568;
}

.btn-action:hover:not(.disabled) {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

.btn-action.edit:hover {
  background: #e2e8f0;
  color: #2d3436;
}

.btn-action.toggle:hover {
  background: #ffeaa7;
  color: #5c3c00;
}

.btn-action.menu:hover {
  background: #a29bfe;
  color: white;
}

.btn-action.delete:hover:not(.disabled) {
  background: #ff7675;
  color: white;
}

.btn-action.disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* ===== COMPONENTE FAQ ===== */
.faq-header {
  align-items: flex-start;
}

.faq-content {
  flex: 1;
}

.faq-question {
  font-size: 1.2rem;
  color: #2d3436;
  margin-bottom: 12px;
}

.faq-answer {
  color: #636e72;
  font-size: 0.95rem;
  line-height: 1.5;
  margin-bottom: 16px;
}

/* ===== BLOQUES ===== */
.blocks-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
}

.block-card {
  background: white;
  border: 2px solid #e2e8f0;
  border-radius: 16px;
  padding: 24px;
  transition: all 0.3s;
}

.block-card:hover {
  border-color: #667eea;
  box-shadow: 0 5px 15px rgba(102, 126, 234, 0.1);
}

.block-header {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 20px;
}

.block-type {
  font-size: 2rem;
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f8fafc;
  border-radius: 12px;
  border: 2px solid #e2e8f0;
  flex-shrink: 0;
}

.block-name {
  font-size: 1.2rem;
  color: #2d3436;
  margin-bottom: 4px;
}

.block-identifier {
  font-size: 0.85rem;
  color: #94a3b8;
}

.block-preview {
  padding: 16px;
  background: #f8fafc;
  border-radius: 12px;
  margin-bottom: 16px;
  min-height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #636e72;
  font-size: 0.9rem;
}

.block-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding-top: 16px;
  border-top: 1px solid #e2e8f0;
}

.block-actions {
  display: flex;
  gap: 8px;
}

.block-actions .btn-edit,
.block-actions .btn-toggle,
.block-actions .btn-delete {
  flex: 1;
  justify-content: center;
  padding: 10px;
  font-size: 0.9rem;
}

/* ===== RESPONSIVE ===== */
@media (max-width: 1024px) {
  .page-header {
    flex-direction: column;
    gap: 20px;
  }
  
  .header-actions {
    width: 100%;
    flex-wrap: wrap;
  }
}

@media (max-width: 768px) {
  .admin-content-manager {
    padding: 16px;
  }
  
  .content-tabs {
    flex-wrap: nowrap;
    overflow-x: auto;
  }
  
  .tab-button {
    padding: 10px 16px;
    font-size: 0.9rem;
  }
  
  .category-header,
  .faq-header {
    flex-direction: column;
    gap: 16px;
  }
  
  .category-stats {
    align-self: flex-start;
  }
  
  .category-actions,
  .faq-actions {
    flex-wrap: wrap;
    justify-content: flex-start;
  }
  
  .category-actions .btn-edit,
  .category-actions .btn-toggle,
  .category-actions .btn-delete,
  .faq-actions .btn-edit,
  .faq-actions .btn-toggle,
  .faq-actions .btn-delete {
    flex: 1;
    min-width: 120px;
    justify-content: center;
  }
  
  .blocks-grid {
    grid-template-columns: 1fr;
  }
  
  .table-container {
    border-radius: 12px;
  }
  
  .pages-table th,
  .pages-table td {
    padding: 12px;
  }
}

@media (max-width: 480px) {
  .stats-cards {
    grid-template-columns: 1fr;
  }
  
  .sort-controls {
    flex-direction: column;
    gap: 16px;
    align-items: stretch;
  }
  
  .sort-select {
    width: 100%;
  }
  
  .btn-save-order {
    width: 100%;
  }
  
  .action-buttons {
    flex-wrap: wrap;
  }
  
  .btn-action {
    flex: 1;
    min-width: 40px;
  }
}
</style>
