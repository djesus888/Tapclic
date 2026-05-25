<template>
  <div class="admin-tickets-page">
    <!-- Header principal -->
    <div class="tickets-header">
      <div class="header-content">
        <h1 class="page-title">🎫 Gestión de Tickets</h1>
        <p class="page-subtitle">Administra y resuelve solicitudes de soporte</p>
      </div>
      <div class="header-actions">
        <button class="btn-create-ticket" @click="openCreateTicketModal">
          + Crear Ticket
        </button>
        <button class="btn-refresh" @click="refreshTickets" :disabled="loading">
          🔄 Actualizar
        </button>
      </div>
    </div>

    <!-- Estadísticas rápidas -->
    <div class="stats-grid">
      <div class="stat-card total">
        <div class="stat-icon">📋</div>
        <div class="stat-content">
          <h3>{{ stats.total }}</h3>
          <p>Tickets Totales</p>
        </div>
      </div>
      <div class="stat-card open">
        <div class="stat-icon">⏳</div>
        <div class="stat-content">
          <h3>{{ stats.open }}</h3>
          <p>Abiertos</p>
        </div>
      </div>
      <div class="stat-card high-priority">
        <div class="stat-icon">🚨</div>
        <div class="stat-content">
          <h3>{{ stats.highPriority }}</h3>
          <p>Alta Prioridad</p>
        </div>
      </div>
      <div class="stat-card closed">
        <div class="stat-icon">✅</div>
        <div class="stat-content">
          <h3>{{ stats.closed }}</h3>
          <p>Resueltos</p>
        </div>
      </div>
      <div class="stat-card assigned">
        <div class="stat-icon">👥</div>
        <div class="stat-content">
          <h3>{{ stats.assignedToMe }}</h3>
          <p>Asignados a mí</p>
        </div>
      </div>
    </div>

    <!-- Filtros y búsqueda -->
    <div class="filters-section">
      <div class="search-box">
        <span class="search-icon">🔍</span>
        <input
          type="text"
          v-model="searchQuery"
          placeholder="Buscar tickets por ID, título, usuario..."
          class="search-input"
          @input="debouncedSearch"
        />
        <button v-if="searchQuery" class="clear-search" @click="clearSearch">
          ✕
        </button>
      </div>

      <div class="filter-controls">
        <div class="filter-group">
          <label>Estado:</label>
          <select v-model="filters.status" @change="applyFilters">
            <option value="">Todos</option>
            <option value="open">Abierto</option>
            <option value="in_progress">En Progreso</option>
            <option value="resolved">Resuelto</option>
            <option value="closed">Cerrado</option>
            <option value="pending">Pendiente</option>
          </select>
        </div>

        <div class="filter-group">
          <label>Prioridad:</label>
          <select v-model="filters.priority" @change="applyFilters">
            <option value="">Todas</option>
            <option value="low">Baja</option>
            <option value="medium">Media</option>
            <option value="high">Alta</option>
            <option value="urgent">Urgente</option>
          </select>
        </div>

        <div class="filter-group">
          <label>Categoría:</label>
          <select v-model="filters.category" @change="applyFilters">
            <option value="">Todas</option>
            <option value="technical">Técnico</option>
            <option value="billing">Facturación</option>
            <option value="account">Cuenta</option>
            <option value="service">Servicio</option>
            <option value="bug">Error/Bug</option>
            <option value="feature">Solicitud de Función</option>
          </select>
        </div>

        <div class="filter-group">
          <label>Asignado a:</label>
          <select v-model="filters.assignedTo" @change="applyFilters">
            <option value="">Todos</option>
            <option value="me">Asignados a mí</option>
            <option value="unassigned">Sin asignar</option>
            <option v-for="admin in admins" :key="admin.id" :value="admin.id">
              {{ admin.name }}
            </option>
          </select>
        </div>

        <div class="filter-group">
          <label>Fecha:</label>
          <select v-model="filters.dateRange" @change="applyFilters">
            <option value="">Todo el tiempo</option>
            <option value="today">Hoy</option>
            <option value="yesterday">Ayer</option>
            <option value="week">Esta semana</option>
            <option value="month">Este mes</option>
            <option value="last_month">Mes pasado</option>
          </select>
        </div>
        <button class="btn-clear-filters" @click="clearFilters">
          Limpiar Filtros
        </button>
      </div>
    </div>

    <!-- Lista de tickets -->
    <div class="tickets-container">
      <div class="tickets-table-container">
        <div v-if="loading" class="loading-container">
          <div class="spinner"></div>
          <p>Cargando tickets...</p>
        </div>

        <div v-else-if="filteredTickets.length === 0" class="empty-state">
          <div class="empty-icon">📭</div>
          <h3>No se encontraron tickets</h3>
          <p>No hay tickets que coincidan con tus filtros</p>
          <button class="btn-create-ticket" @click="clearFilters">
            Ver todos los tickets
          </button>
        </div>

        <table v-else class="tickets-table">
          <thead>
            <tr>
              <th class="checkbox-col">
                <input
                  type="checkbox"
                  v-model="selectAll"
                  @change="toggleSelectAll"
                />
              </th>
              <th class="id-col">ID</th>
              <th class="subject-col">Asunto</th>
              <th class="user-col">Usuario</th>
              <th class="category-col">Categoría</th>
              <th class="priority-col">Prioridad</th>
              <th class="status-col">Estado</th>
              <th class="assigned-col">Asignado a</th>
              <th class="date-col">Creado</th>
              <th class="actions-col">Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="ticket in paginatedTickets"
              :key="ticket.id"
              :class="[
                'ticket-row',
                `priority-${ticket.priority}`,
                { selected: selectedTickets.includes(ticket.id) },
              ]"
              @click="selectTicket(ticket)"
            >
              <td class="checkbox-col">
                <input
                  type="checkbox"
                  :value="ticket.id"
                  v-model="selectedTickets"
                  @click.stop
                />
              </td>
              <td class="id-col">
                <span class="ticket-id">#{{ ticket.id }}</span>
              </td>
              <td class="subject-col">
                <div class="subject-content">
                  <h4 class="ticket-subject">{{ ticket.subject }}</h4>
                  <p class="ticket-preview">{{ ticket.message_preview }}</p>
                </div>
              </td>
              <td class="user-col">
                <div class="user-info">
                  <img
                    :src="getUserAvatar(ticket.user)"
                    :alt="ticket.user?.name"
                    class="user-avatar"
                  />
                  <div>
                    <p class="user-name">{{ ticket.user?.name }}</p>
                    <p class="user-email">{{ ticket.user?.email }}</p>
                  </div>
                </div>
              </td>
              <td class="category-col">
                <span class="category-badge" :class="ticket.category">
                  {{ getCategoryLabel(ticket.category) }}
                </span>
              </td>
              <td class="priority-col">
                <span class="priority-badge" :class="ticket.priority">
                  {{ getPriorityLabel(ticket.priority) }}
                </span>
              </td>
              <td class="status-col">
                <span class="status-badge" :class="ticket.status">
                  {{ getStatusLabel(ticket.status) }}
                </span>
              </td>
              <td class="assigned-col">
                <div v-if="ticket.assigned_to" class="assigned-info">
                  <img
                    :src="getAdminAvatar(ticket.assigned_to)"
                    :alt="ticket.assigned_to?.name"
                    class="admin-avatar"
                  />
                  <span>{{ ticket.assigned_to?.name }}</span>
                </div>
                <span v-else class="unassigned">Sin asignar</span>
              </td>
              <td class="date-col">
                <div class="date-info">
                  <span class="date">{{ formatDate(ticket.created_at) }}</span>
                  <span class="time">{{ formatTime(ticket.created_at) }}</span>
                </div>
              </td>
              <td class="actions-col">
                <div class="action-buttons">
                  <button
                    class="btn-action view"
                    @click.stop="viewTicket(ticket)"
                    title="Ver detalles"
                  >
                    👁️
                  </button>
                  <button
                    class="btn-action edit"
                    @click.stop="editTicket(ticket)"
                    title="Editar"
                  >
                    ✏️
                  </button>
                  <button
                    class="btn-action assign"
                    @click.stop="assignTicket(ticket)"
                    title="Asignar"
                  >
                    👤
                  </button>
                  <button
                    class="btn-action close"
                    @click.stop="closeTicket(ticket)"
                    v-if="ticket.status !== 'closed'"
                    title="Cerrar ticket"
                  >
                    ✅
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>

        <!-- Paginación -->
        <div v-if="filteredTickets.length > 0" class="pagination">
          <div class="pagination-info">
            Mostrando {{ pagination.startIndex + 1 }} -
            {{ Math.min(pagination.endIndex, filteredTickets.length) }} de
            {{ filteredTickets.length }} tickets
          </div>
          <div class="pagination-controls">
            <button
              class="pagination-btn"
              @click="prevPage"
              :disabled="pagination.currentPage === 1"
            >
              ← Anterior
            </button>
            <div class="page-numbers">
              <button
                v-for="page in visiblePages"
                :key="page"
                @click="goToPage(page)"
                :class="['page-btn', { active: page === pagination.currentPage }]"
              >
                {{ page }}
              </button>
            </div>
            <button
              class="pagination-btn"
              @click="nextPage"
              :disabled="pagination.currentPage === pagination.totalPages"
            >
              Siguiente →
            </button>
          </div>
          <div class="items-per-page">
            <label>Mostrar:</label>
            <select v-model="pagination.itemsPerPage" @change="updatePagination">
              <option>10</option>
              <option>25</option>
              <option>50</option>
              <option>100</option>
            </select>
          </div>
        </div>
      </div>

      <!-- Panel lateral de acciones masivas -->
      <div v-if="selectedTickets.length > 0" class="bulk-actions-panel">
        <div class="bulk-header">
          <h3>{{ selectedTickets.length }} tickets seleccionados</h3>
          <button class="btn-clear-selection" @click="clearSelection">
            ✕
          </button>
        </div>
        <div class="bulk-actions">
          <select v-model="bulkAction" class="bulk-select">
            <option value="">Acción en masa...</option>
            <option value="assign">Asignar a...</option>
            <option value="change_status">Cambiar estado</option>
            <option value="change_priority">Cambiar prioridad</option>
            <option value="add_tag">Agregar etiqueta</option>
            <option value="delete">Eliminar</option>
          </select>

          <div v-if="bulkAction === 'assign'" class="bulk-action-form">
            <select v-model="bulkAssignTo" class="bulk-input">
              <option value="">Seleccionar administrador</option>
              <option v-for="admin in admins" :key="admin.id" :value="admin.id">
                {{ admin.name }}
              </option>
            </select>
            <button
              class="btn-apply"
              @click="applyBulkAssign"
              :disabled="!bulkAssignTo"
            >
              Asignar
            </button>
          </div>

          <div v-if="bulkAction === 'change_status'" class="bulk-action-form">
            <select v-model="bulkStatus" class="bulk-input">
              <option value="">Seleccionar estado</option>
              <option value="open">Abierto</option>
              <option value="in_progress">En Progreso</option>
              <option value="resolved">Resuelto</option>
              <option value="closed">Cerrado</option>
            </select>
            <button
              class="btn-apply"
              @click="applyBulkStatus"
              :disabled="!bulkStatus"
            >
              Cambiar
            </button>
          </div>

          <div v-if="bulkAction === 'change_priority'" class="bulk-action-form">
            <select v-model="bulkPriority" class="bulk-input">
              <option value="">Seleccionar prioridad</option>
              <option value="low">Baja</option>
              <option value="medium">Media</option>
              <option value="high">Alta</option>
              <option value="urgent">Urgente</option>
            </select>
            <button
              class="btn-apply"
              @click="applyBulkPriority"
              :disabled="!bulkPriority"
            >
              Cambiar
            </button>
          </div>

          <div v-if="bulkAction === 'add_tag'" class="bulk-action-form">
            <input
              v-model="bulkTag"
              type="text"
              class="bulk-input"
              placeholder="Nombre de la etiqueta"
            />
            <select v-model="bulkTagColor" class="bulk-input color-select">
              <option value="blue">Azul</option>
              <option value="green">Verde</option>
              <option value="red">Rojo</option>
              <option value="yellow">Amarillo</option>
              <option value="purple">Morado</option>
              <option value="orange">Naranja</option>
            </select>
            <button
              class="btn-apply"
              @click="applyBulkTag"
              :disabled="!bulkTag"
            >
              Agregar
            </button>
          </div>

          <button
            v-if="bulkAction === 'delete'"
            class="btn-delete-bulk"
            @click="confirmBulkDelete"
          >
            🗑️ Eliminar seleccionados
          </button>
        </div>
      </div>
    </div>

    <!-- Modales -->
    <!-- Modal de creación/edición de ticket -->
    <TicketModal
      v-if="showTicketModal"
      :ticket="selectedTicket"
      :mode="modalMode"
      @save="handleSaveTicket"
      @close="closeTicketModal"
    />

    <!-- Modal de detalles del ticket -->
    <TicketDetailModal
      v-if="showDetailModal"
      :ticket="selectedTicket"
      @update="handleTicketUpdate"
      @close="closeDetailModal"
    />

    <!-- Modal de asignación -->
    <AssignModal
      v-if="showAssignModal"
      :ticket="selectedTicket"
      :admins="admins"
      @assign="handleAssign"
      @close="closeAssignModal"
    />

    <!-- Modal de confirmación de cierre -->
    <ConfirmModal
      v-if="showCloseConfirm"
      title="Cerrar Ticket"
      message="¿Estás seguro de que deseas cerrar este ticket?"
      confirm-text="Sí, cerrar"
      cancel-text="Cancelar"
      @confirm="confirmCloseTicket"
      @cancel="showCloseConfirm = false"
    />

    <!-- Modal de confirmación de eliminación masiva -->
    <ConfirmModal
      v-if="showBulkDeleteConfirm"
      title="Eliminar Tickets"
      :message="`¿Estás seguro de que deseas eliminar ${selectedTickets.length} tickets? Esta acción no se puede deshacer.`"
      confirm-text="Sí, eliminar"
      cancel-text="Cancelar"
      confirm-type="danger"
      @confirm="executeBulkDelete"
      @cancel="showBulkDeleteConfirm = false"
    />

    <!-- Toast notifications -->
    <div v-if="toast.show" class="toast" :class="toast.type">
      {{ toast.message }}
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/authStore'
import api from '@/axios'
import TicketModal from '@/components/admin/TicketModal.vue'
import TicketDetailModal from '@/components/admin/TicketDetailModal.vue'
import AssignModal from '@/components/admin/AssignModal.vue'
import ConfirmModal from '@/components/admin/ConfirmModal.vue'
import { debounce } from 'lodash'

interface User {
  id: number
  name: string
  email: string
  avatar_url?: string
  role: string
}

interface Admin {
  id: number
  name: string
  email: string
  avatar_url?: string
  role: string
}

interface Ticket {
  id: number
  subject: string
  description: string
  message_preview: string
  category: string
  priority: 'low' | 'medium' | 'high' | 'urgent'
  status: 'open' | 'in_progress' | 'resolved' | 'closed' | 'pending'
  user_id: number
  user: User
  assigned_to_id?: number
  assigned_to?: Admin
  created_at: string
  updated_at: string
  last_response_at?: string
  response_count: number
  attachments?: string[]
  tags?: string[]
}

interface Filters {
  status: string
  priority: string
  category: string
  assignedTo: string
  dateRange: string
}

interface Stats {
  total: number
  open: number
  highPriority: number
  closed: number
  assignedToMe: number
}

// Router y stores
const router = useRouter()
const authStore = useAuthStore()

// Estado reactivo
const tickets = ref<Ticket[]>([])
const loading = ref(true)
const searchQuery = ref('')
const filters = ref<Filters>({
  status: '',
  priority: '',
  category: '',
  assignedTo: '',
  dateRange: '',
})
const selectedTickets = ref<number[]>([])
const selectAll = ref(false)
const admins = ref<Admin[]>([])

// Modales
const showTicketModal = ref(false)
const showDetailModal = ref(false)
const showAssignModal = ref(false)
const showCloseConfirm = ref(false)
const showBulkDeleteConfirm = ref(false)
const modalMode = ref<'create' | 'edit'>('create')

// Ticket seleccionado
const selectedTicket = ref<Ticket | null>(null)

// Acciones masivas
const bulkAction = ref('')
const bulkAssignTo = ref('')
const bulkStatus = ref('')
const bulkPriority = ref('')

// Paginación
const pagination = ref({
  currentPage: 1,
  itemsPerPage: 25,
  totalPages: 1,
  startIndex: 0,
  endIndex: 0,
})

// Toast notifications
const toast = ref({
  show: false,
  message: '',
  type: 'success' as 'success' | 'error' | 'info',
})

// Acciones masivas (agregar estas variables)
const bulkTag = ref('')
const bulkTagColor = ref('blue')

// Computed properties
const stats = computed<Stats>(() => {
  const total = tickets.value.length
  const open = tickets.value.filter(t =>
    ['open', 'in_progress', 'pending'].includes(t.status)
  ).length
  const highPriority = tickets.value.filter(t =>
    ['high', 'urgent'].includes(t.priority)
  ).length
  const closed = tickets.value.filter(t => t.status === 'closed').length
  const assignedToMe = tickets.value.filter(t =>
    t.assigned_to_id === authStore.user?.id
  ).length

  return { total, open, highPriority, closed, assignedToMe }
})

const filteredTickets = computed(() => {
  let filtered = [...tickets.value]

  // Búsqueda por texto
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(ticket =>
      ticket.subject.toLowerCase().includes(query) ||
      ticket.description.toLowerCase().includes(query) ||
      ticket.user?.name?.toLowerCase().includes(query) ||
      ticket.user?.email?.toLowerCase().includes(query) ||
      ticket.id.toString().includes(query)
    )
  }

  // Filtros
  if (filters.value.status) {
    filtered = filtered.filter(ticket => ticket.status === filters.value.status)
  }

  if (filters.value.priority) {
    filtered = filtered.filter(ticket => ticket.priority === filters.value.priority)
  }

  if (filters.value.category) {
    filtered = filtered.filter(ticket => ticket.category === filters.value.category)
  }

  if (filters.value.assignedTo) {
    if (filters.value.assignedTo === 'me') {
      filtered = filtered.filter(ticket => ticket.assigned_to_id === authStore.user?.id)
    } else if (filters.value.assignedTo === 'unassigned') {
      filtered = filtered.filter(ticket => !ticket.assigned_to_id)
    } else {
      filtered = filtered.filter(ticket =>
        ticket.assigned_to_id === parseInt(filters.value.assignedTo)
      )
    }
  }

  // Filtro por fecha
  if (filters.value.dateRange) {
    const now = new Date()
    filtered = filtered.filter(ticket => {
      const ticketDate = new Date(ticket.created_at)
      switch (filters.value.dateRange) {
        case 'today':
          return ticketDate.toDateString() === now.toDateString()
        case 'yesterday':
          const yesterday = new Date(now)
          yesterday.setDate(yesterday.getDate() - 1)
          return ticketDate.toDateString() === yesterday.toDateString()
        case 'week':
          const weekAgo = new Date(now)
          weekAgo.setDate(weekAgo.getDate() - 7)
          return ticketDate >= weekAgo
        case 'month':
          const monthAgo = new Date(now)
          monthAgo.setMonth(monthAgo.getMonth() - 1)
          return ticketDate >= monthAgo
        case 'last_month':
          const lastMonthStart = new Date(now.getFullYear(), now.getMonth() - 1, 1)
          const lastMonthEnd = new Date(now.getFullYear(), now.getMonth(), 0)
          return ticketDate >= lastMonthStart && ticketDate <= lastMonthEnd
        default:
          return true
      }
    })
  }

  // Ordenar por prioridad y fecha (los más urgentes primero)
  filtered.sort((a, b) => {
    const priorityOrder = { urgent: 0, high: 1, medium: 2, low: 3 }
    if (priorityOrder[a.priority] !== priorityOrder[b.priority]) {
      return priorityOrder[a.priority] - priorityOrder[b.priority]
    }
    return new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
  })

  return filtered
})

const paginatedTickets = computed(() => {
  updatePagination()
  return filteredTickets.value.slice(
    pagination.value.startIndex,
    pagination.value.endIndex
  )
})

const visiblePages = computed(() => {
  const pages = []
  const totalPages = pagination.value.totalPages
  const current = pagination.value.currentPage

  let start = Math.max(1, current - 2)
  let end = Math.min(totalPages, current + 2)

  if (current <= 3) {
    end = Math.min(5, totalPages)
  }
  if (current >= totalPages - 2) {
    start = Math.max(1, totalPages - 4)
  }

  for (let i = start; i <= end; i++) {
    pages.push(i)
  }

  return pages
})

// Lifecycle hooks
onMounted(async () => {
  await Promise.all([
    loadTickets(),
    loadAdmins()
  ])

  // Configurar WebSocket para actualizaciones en tiempo real
  setupWebSocket()
})

// Métodos
async function loadTickets() {
  loading.value = true
  try {
    const response = await api.get('/admin/tickets', {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })

    // ✅ DATOS CORRECTOS DEL BACKEND
    const backendTickets = response.data.tickets || []

    tickets.value = backendTickets.map((ticket: any) => ({
      id: ticket.id,
      subject: ticket.subject,
      description: ticket.description || '',
      message_preview: (ticket.description || '').substring(0, 100) +
        ((ticket.description || '').length > 100 ? '...' : ''),
      category: ticket.category || 'general',
      priority: ticket.priority || 'medium',      // ← AHORA VIENE DEL BACKEND
      status: ticket.status || 'open',
      user_id: ticket.user_id,
      user: {
        id: ticket.user_id,
        name: ticket.user_name || 'Usuario',
        email: ticket.user_email || '',
        avatar_url: null,
        role: 'user'
      },
      assigned_to_id: ticket.assigned_to || null,
      assigned_to: ticket.assigned_to ? {
        id: ticket.assigned_to,
        name: 'Admin',  // Podrías mejorar esto si tienes los nombres
        email: '',
        avatar_url: null,
        role: 'admin'
      } : null,
      created_at: ticket.created_at,
      updated_at: ticket.updated_at,
      last_response_at: ticket.last_response_at || null,
      response_count: ticket.response_count || 0,
      attachments: [],
      tags: ticket.tags ? JSON.parse(ticket.tags) : []  // ← PARSEAR TAGS
    }))

    console.log('✅ Tickets cargados:', tickets.value)

  } catch (error: any) {
    console.error('Error cargando tickets:', error)
    showToast('Error al cargar tickets', 'error')
  } finally {
    loading.value = false
  }
}

async function loadAdmins() {
  try {
    const response = await api.get('/admin/users/admins', {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })

    // ✅ ADAPTAR SEGÚN LA RESPUESTA DE TU BACKEND
    const adminData = response.data.data || response.data.admins || []
    admins.value = adminData.map((admin: any) => ({
      id: admin.id,
      name: admin.name || admin.user_name,
      email: admin.email || admin.user_email,
      avatar_url: admin.avatar_url,
      role: 'admin'
    }))
  } catch (error) {
    console.error('Error cargando administradores:', error)
    // Si falla, crear admins por defecto
    admins.value = [{
      id: authStore.user?.id || 1,
      name: authStore.user?.name || 'Admin',
      email: authStore.user?.email || '',
      avatar_url: null,
      role: 'admin'
    }]
  }
}

async function applyBulkTag() {
  if (!bulkTag.value || selectedTickets.value.length === 0) return

  try {
    await api.post('/admin/tickets/bulk/tag', {
      ticket_ids: selectedTickets.value,
      tag: bulkTag.value,
      color: bulkTagColor.value
    }, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })

    // Actualizar localmente (simulado)
    tickets.value = tickets.value.map(ticket => {
      if (selectedTickets.value.includes(ticket.id)) {
        const currentTags = ticket.tags || []
        return {
          ...ticket,
          tags: [...currentTags, bulkTag.value]
        }
      }
      return ticket
    })

    showToast(`Etiqueta "${bulkTag.value}" agregada a ${selectedTickets.value.length} tickets`, 'success')
    clearSelection()
    bulkAction.value = ''
    bulkTag.value = ''
    bulkTagColor.value = 'blue'
  } catch (error: any) {
    console.error('Error agregando etiqueta:', error)
    showToast(error.response?.data?.error || 'Error agregando etiqueta', 'error')
  }
}

function setupWebSocket() {
  // Aquí configurarías la conexión WebSocket para notificaciones en tiempo real
  // Por ahora usamos polling cada 30 segundos
  setInterval(() => {
    if (!loading.value) {
      loadTickets()
    }
  }, 30000)
}

function applyFilters() {
  pagination.value.currentPage = 1
}

function clearFilters() {
  filters.value = {
    status: '',
    priority: '',
    category: '',
    assignedTo: '',
    dateRange: '',
  }
  searchQuery.value = ''
}

function clearSearch() {
  searchQuery.value = ''
}

const debouncedSearch = debounce(() => {
  applyFilters()
}, 300)

function updatePagination() {
  const totalItems = filteredTickets.value.length
  const totalPages = Math.ceil(totalItems / pagination.value.itemsPerPage)

  pagination.value.totalPages = totalPages || 1
  pagination.value.currentPage = Math.min(
    pagination.value.currentPage,
    totalPages || 1
  )

  pagination.value.startIndex = (pagination.value.currentPage - 1) * pagination.value.itemsPerPage
  pagination.value.endIndex = Math.min(
    pagination.value.startIndex + pagination.value.itemsPerPage,
    totalItems
  )
}

function nextPage() {
  if (pagination.value.currentPage < pagination.value.totalPages) {
    pagination.value.currentPage++
  }
}

function prevPage() {
  if (pagination.value.currentPage > 1) {
    pagination.value.currentPage--
  }
}

function goToPage(page: number) {
  pagination.value.currentPage = page
}

function refreshTickets() {
  loadTickets()
}

// Funciones de tickets
function selectTicket(ticket: Ticket) {
  const index = selectedTickets.value.indexOf(ticket.id)
  if (index > -1) {
    selectedTickets.value.splice(index, 1)
  } else {
    selectedTickets.value.push(ticket.id)
  }
}

function toggleSelectAll() {
  if (selectAll.value) {
    selectedTickets.value = paginatedTickets.value.map(ticket => ticket.id)
  } else {
    selectedTickets.value = []
  }
}

function clearSelection() {
  selectedTickets.value = []
  selectAll.value = false
}

function viewTicket(ticket: Ticket) {
  selectedTicket.value = ticket
  showDetailModal.value = true
}

function editTicket(ticket: Ticket) {
  selectedTicket.value = ticket
  modalMode.value = 'edit'
  showTicketModal.value = true
}

function assignTicket(ticket: Ticket) {
  selectedTicket.value = ticket
  showAssignModal.value = true
}

function closeTicket(ticket: Ticket) {
  selectedTicket.value = ticket
  showCloseConfirm.value = true
}

async function confirmCloseTicket() {
  if (!selectedTicket.value) return

  try {
    await api.put(`/admin/tickets/${selectedTicket.value.id}/close`, {}, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })

    // Actualizar el ticket localmente
    const index = tickets.value.findIndex(t => t.id === selectedTicket.value!.id)
    if (index > -1) {
      tickets.value[index].status = 'closed'
      tickets.value[index].updated_at = new Date().toISOString()
    }

    showToast('Ticket cerrado exitosamente', 'success')
    showCloseConfirm.value = false
  } catch (error: any) {
    console.error('Error cerrando ticket:', error)
    showToast(error.response?.data?.error || 'Error al cerrar ticket', 'error')
  }
}

// Modal de creación
function openCreateTicketModal() {
  selectedTicket.value = null
  modalMode.value = 'create'
  showTicketModal.value = true
}

function closeTicketModal() {
  showTicketModal.value = false
  selectedTicket.value = null
}

function closeDetailModal() {
  showDetailModal.value = false
  selectedTicket.value = null
}

function closeAssignModal() {
  showAssignModal.value = false
  selectedTicket.value = null
}

async function handleSaveTicket(ticketData: any) {
  try {
    if (modalMode.value === 'create') {
      const response = await api.post('/admin/tickets', ticketData, {
        headers: { Authorization: `Bearer ${authStore.token}` }
      })
      tickets.value.unshift(response.data.data)
      showToast('Ticket creado exitosamente', 'success')
    } else {
      const response = await api.put(`/admin/tickets/${selectedTicket.value?.id}`, ticketData, {
        headers: { Authorization: `Bearer ${authStore.token}` }
      })

      const index = tickets.value.findIndex(t => t.id === selectedTicket.value!.id)
      if (index > -1) {
        tickets.value[index] = response.data.data
      }
      showToast('Ticket actualizado exitosamente', 'success')
    }

    closeTicketModal()
  } catch (error: any) {
    console.error('Error guardando ticket:', error)
    showToast(error.response?.data?.error || 'Error guardando ticket', 'error')
  }
}

async function handleAssign(adminId: number) {
  if (!selectedTicket.value) return

  try {
    const response = await api.put(
      `/admin/tickets/${selectedTicket.value.id}/assign`,
      { admin_id: adminId },
      { headers: { Authorization: `Bearer ${authStore.token}` } }
    )

    const index = tickets.value.findIndex(t => t.id === selectedTicket.value!.id)
    if (index > -1) {
      tickets.value[index] = response.data.data
    }

    showToast('Ticket asignado exitosamente', 'success')
    closeAssignModal()
  } catch (error: any) {
    console.error('Error asignando ticket:', error)
    showToast(error.response?.data?.error || 'Error asignando ticket', 'error')
  }
}

async function handleTicketUpdate(updatedTicket: Ticket) {
  const index = tickets.value.findIndex(t => t.id === updatedTicket.id)
  if (index > -1) {
    tickets.value[index] = updatedTicket
  }
}

// Acciones masivas
async function applyBulkAssign() {
  if (!bulkAssignTo.value || selectedTickets.value.length === 0) return

  try {
    await api.post('/admin/tickets/bulk/assign', {
      ticket_ids: selectedTickets.value,
      admin_id: parseInt(bulkAssignTo.value)
    }, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })

    // Actualizar localmente
    tickets.value = tickets.value.map(ticket => {
      if (selectedTickets.value.includes(ticket.id)) {
        const admin = admins.value.find(a => a.id === parseInt(bulkAssignTo.value))
        return {
          ...ticket,
          assigned_to_id: admin?.id,
          assigned_to: admin
        }
      }
      return ticket
    })

    showToast(`${selectedTickets.value.length} tickets asignados`, 'success')
    clearSelection()
    bulkAction.value = ''
    bulkAssignTo.value = ''
  } catch (error: any) {
    console.error('Error en asignación masiva:', error)
    showToast(error.response?.data?.error || 'Error en asignación masiva', 'error')
  }
}

async function applyBulkStatus() {
  if (!bulkStatus.value || selectedTickets.value.length === 0) return

  try {
    await api.post('/admin/tickets/bulk/status', {
      ticket_ids: selectedTickets.value,
      status: bulkStatus.value
    }, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })

    // Actualizar localmente
    tickets.value = tickets.value.map(ticket => {
      if (selectedTickets.value.includes(ticket.id)) {
        return { ...ticket, status: bulkStatus.value as any }
      }
      return ticket
    })

    showToast(`Estado actualizado en ${selectedTickets.value.length} tickets`, 'success')
    clearSelection()
    bulkAction.value = ''
    bulkStatus.value = ''
  } catch (error: any) {
    console.error('Error en cambio masivo de estado:', error)
    showToast(error.response?.data?.error || 'Error cambiando estado', 'error')
  }
}

async function applyBulkPriority() {
  if (!bulkPriority.value || selectedTickets.value.length === 0) return

  try {
    await api.post('/admin/tickets/bulk/priority', {
      ticket_ids: selectedTickets.value,
      priority: bulkPriority.value
    }, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })

    // Actualizar localmente
    tickets.value = tickets.value.map(ticket => {
      if (selectedTickets.value.includes(ticket.id)) {
        return { ...ticket, priority: bulkPriority.value as any }
      }
      return ticket
    })

    showToast(`Prioridad actualizada en ${selectedTickets.value.length} tickets`, 'success')
    clearSelection()
    bulkAction.value = ''
    bulkPriority.value = ''
  } catch (error: any) {
    console.error('Error en cambio masivo de prioridad:', error)
    showToast(error.response?.data?.error || 'Error cambiando prioridad', 'error')
  }
}

function confirmBulkDelete() {
  showBulkDeleteConfirm.value = true
}

async function executeBulkDelete() {
  try {
    await api.post('/admin/tickets/bulk/delete', {
      ticket_ids: selectedTickets.value
    }, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })

    // Remover localmente
    tickets.value = tickets.value.filter(
      ticket => !selectedTickets.value.includes(ticket.id)
    )

    showToast(`${selectedTickets.value.length} tickets eliminados`, 'success')
    clearSelection()
    bulkAction.value = ''
    showBulkDeleteConfirm.value = false
  } catch (error: any) {
    console.error('Error en eliminación masiva:', error)
    showToast(error.response?.data?.error || 'Error eliminando tickets', 'error')
  }
}

// Helpers
function getCategoryLabel(category: string): string {
  const labels: Record<string, string> = {
    technical: 'Técnico',
    billing: 'Facturación',
    account: 'Cuenta',
    service: 'Servicio',
    bug: 'Error/Bug',
    feature: 'Solicitud de Función',
  }
  return labels[category] || category
}

function getPriorityLabel(priority: string): string {
  const labels: Record<string, string> = {
    low: 'Baja',
    medium: 'Media',
    high: 'Alta',
    urgent: 'Urgente',
  }
  return labels[priority] || priority
}

function getStatusLabel(status: string): string {
  const labels: Record<string, string> = {
    open: 'Abierto',
    in_progress: 'En Progreso',
    resolved: 'Resuelto',
    closed: 'Cerrado',
    pending: 'Pendiente',
  }
  return labels[status] || status
}

function getUserAvatar(user?: User): string {
  if (user?.avatar_url) {
    return getImageUrl(user.avatar_url)
  }
  return '/img/default-avatar.png'
}

function getAdminAvatar(admin?: Admin): string {
  if (admin?.avatar_url) {
    return getImageUrl(admin.avatar_url)
  }
  return '/img/default-admin.png'
}

function formatDate(dateString: string): string {
  const date = new Date(dateString)
  return date.toLocaleDateString('es-ES', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric'
  })
}

function formatTime(dateString: string): string {
  const date = new Date(dateString)
  return date.toLocaleTimeString('es-ES', {
    hour: '2-digit',
    minute: '2-digit'
  })
}

function showToast(message: string, type: 'success' | 'error' | 'info' = 'info') {
  toast.value = { show: true, message, type }
  setTimeout(() => {
    toast.value.show = false
  }, 3000)
}

// Watchers
watch(selectedTickets, (newVal) => {
  if (paginatedTickets.value.length > 0) {
    selectAll.value = newVal.length === paginatedTickets.value.length
  }
})

watch(
  () => pagination.value.itemsPerPage,
  () => {
    pagination.value.currentPage = 1
    updatePagination()
  }
)
</script>

<style scoped>
.admin-tickets-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #f5f7fa 0%, #e4edf5 100%);
  padding: 24px;
}

/* Header */
.tickets-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 32px;
  flex-wrap: wrap;
  gap: 20px;
}

.header-content {
  flex: 1;
}

.page-title {
  font-size: 2.5rem;
  color: #2d3436;
  margin: 0 0 8px 0;
}

.page-subtitle {
  color: #636e72;
  font-size: 1.1rem;
  margin: 0;
}

.header-actions {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}

.btn-create-ticket {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 10px;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s;
}

.btn-create-ticket:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
}

.btn-refresh {
  background: white;
  color: #2d3436;
  border: 2px solid #dfe6e9;
  padding: 12px 24px;
  border-radius: 10px;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s;
}

.btn-refresh:hover:not(:disabled) {
  border-color: #3498db;
  color: #3498db;
}

.btn-refresh:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Stats Grid */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
  margin-bottom: 32px;
}

.stat-card {
  background: white;
  padding: 24px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  gap: 20px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
  transition: transform 0.3s;
}

.stat-card:hover {
  transform: translateY(-5px);
}

.stat-card.total {
  border-top: 4px solid #3498db;
}

.stat-card.open {
  border-top: 4px solid #fdcb6e;
}

.stat-card.high-priority {
  border-top: 4px solid #e17055;
}

.stat-card.closed {
  border-top: 4px solid #00b894;
}

.stat-card.assigned {
  border-top: 4px solid #6c5ce7;
}

.stat-icon {
  font-size: 2.5rem;
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 12px;
  color: white;
}

.stat-card.total .stat-icon {
  background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%);
}

.stat-card.open .stat-icon {
  background: linear-gradient(135deg, #fdcb6e 0%, #e17055 100%);
}

.stat-card.high-priority .stat-icon {
  background: linear-gradient(135deg, #ff7675 0%, #d63031 100%);
}

.stat-card.closed .stat-icon {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
}

.stat-card.assigned .stat-icon {
  background: linear-gradient(135deg, #a29bfe 0%, #6c5ce7 100%);
}

.stat-content h3 {
  font-size: 2rem;
  color: #2d3436;
  margin: 0 0 4px 0;
}

.stat-content p {
  color: #636e72;
  font-size: 0.9rem;
  margin: 0;
}

/* Filters Section */
.filters-section {
  background: white;
  padding: 24px;
  border-radius: 16px;
  margin-bottom: 32px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
}

.search-box {
  position: relative;
  margin-bottom: 24px;
}

.search-icon {
  position: absolute;
  left: 16px;
  top: 50%;
  transform: translateY(-50%);
  font-size: 1.2rem;
  color: #636e72;
}

.search-input {
  width: 100%;
  padding: 14px 16px 14px 48px;
  border: 2px solid #dfe6e9;
  border-radius: 10px;
  font-size: 1rem;
  transition: border-color 0.3s;
}

.search-input:focus {
  outline: none;
  border-color: #3498db;
}

.clear-search {
  position: absolute;
  right: 16px;
  top: 50%;
  transform: translateY(-50%);
  background: #dfe6e9;
  border: none;
  width: 24px;
  height: 24px;
  border-radius: 50%;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
}

.clear-search:hover {
  background: #b2bec3;
}

.filter-controls {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 16px;
  align-items: end;
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

.filter-group select {
  padding: 10px;
  border: 2px solid #dfe6e9;
  border-radius: 8px;
  font-size: 0.95rem;
  background: white;
  transition: border-color 0.3s;
}

.filter-group select:focus {
  outline: none;
  border-color: #3498db;
}

.btn-clear-filters {
  background: #dfe6e9;
  color: #2d3436;
  border: none;
  padding: 10px 20px;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  align-self: flex-end;
}

.btn-clear-filters:hover {
  background: #b2bec3;
}

/* Tickets Container */
.tickets-container {
  display: grid;
  grid-template-columns: 1fr auto;
  gap: 24px;
}

@media (max-width: 1200px) {
  .tickets-container {
    grid-template-columns: 1fr;
  }
}

.tickets-table-container {
  background: white;
  border-radius: 16px;
  overflow: auto;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
}

.loading-container {
  padding: 60px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

.spinner {
  width: 50px;
  height: 50px;
  border: 4px solid #f3f3f3;
  border-top: 4px solid #3498db;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 20px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.empty-state {
  padding: 80px 40px;
  text-align: center;
}

.empty-icon {
  font-size: 64px;
  margin-bottom: 20px;
  opacity: 0.5;
}

.empty-state h3 {
  color: #2d3436;
  margin-bottom: 12px;
}

.empty-state p {
  color: #636e72;
  margin-bottom: 24px;
}

/* Tickets Table */
.tickets-table {
  width: 100%;
  border-collapse: collapse;
}

.tickets-table thead {
  background: #f8f9fa;
  border-bottom: 2px solid #e0e6ed;
}

.tickets-table th {
  padding: 16px;
  text-align: left;
  font-weight: 600;
  color: #2d3436;
  font-size: 0.9rem;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.tickets-table td {
  padding: 16px;
  border-bottom: 1px solid #f1f2f6;
}

.ticket-row {
  transition: all 0.3s;
  cursor: pointer;
}

.ticket-row:hover {
  background: #f8f9fa;
}

.ticket-row.selected {
  background: #e3f2fd;
}

.ticket-row.priority-urgent {
  border-left: 4px solid #d63031;
}

.ticket-row.priority-high {
  border-left: 4px solid #e17055;
}

.ticket-row.priority-medium {
  border-left: 4px solid #fdcb6e;
}

.ticket-row.priority-low {
  border-left: 4px solid #00b894;
}

.checkbox-col {
  width: 40px;
}

.id-col {
  width: 80px;
}

.ticket-id {
  font-family: 'Courier New', monospace;
  font-weight: 600;
  color: #3498db;
}

.subject-col {
  min-width: 250px;
}

.subject-content {
  max-width: 300px;
}

.ticket-subject {
  font-weight: 600;
  color: #2d3436;
  margin: 0 0 4px 0;
  font-size: 0.95rem;
}

.ticket-preview {
  color: #636e72;
  font-size: 0.85rem;
  margin: 0;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.user-col {
  min-width: 200px;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.user-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  object-fit: cover;
}

.user-name {
  font-weight: 600;
  color: #2d3436;
  margin: 0 0 2px 0;
  font-size: 0.9rem;
}

.user-email {
  color: #636e72;
  font-size: 0.8rem;
  margin: 0;
}

.category-col,
.priority-col,
.status-col {
  width: 120px;
}

.category-badge,
.priority-badge,
.status-badge {
  display: inline-block;
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
  text-align: center;
}

.category-badge.technical { background: #e3f2fd; color: #1976d2; }
.category-badge.billing { background: #f3e5f5; color: #7b1fa2; }
.category-badge.account { background: #e8f5e9; color: #388e3c; }
.category-badge.service { background: #fff3e0; color: #f57c00; }
.category-badge.bug { background: #ffebee; color: #d32f2f; }
.category-badge.feature { background: #e0f7fa; color: #0097a7; }

.priority-badge.low { background: #e8f5e9; color: #388e3c; }
.priority-badge.medium { background: #fff3e0; color: #f57c00; }
.priority-badge.high { background: #ffebee; color: #d32f2f; }
.priority-badge.urgent { background: #d32f2f; color: white; }

.status-badge.open { background: #fff3e0; color: #f57c00; }
.status-badge.in_progress { background: #e3f2fd; color: #1976d2; }
.status-badge.resolved { background: #e8f5e9; color: #388e3c; }
.status-badge.closed { background: #f5f5f5; color: #616161; }
.status-badge.pending { background: #f3e5f5; color: #7b1fa2; }

.assigned-col {
  width: 150px;
}

.assigned-info {
  display: flex;
  align-items: center;
  gap: 8px;
}

.admin-avatar {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  object-fit: cover;
}

.unassigned {
  color: #b2bec3;
  font-style: italic;
}

.date-col {
  width: 120px;
}

.date-info {
  display: flex;
  flex-direction: column;
}

.date {
  font-size: 0.9rem;
  color: #2d3436;
  font-weight: 500;
}

.time {
  font-size: 0.8rem;
  color: #636e72;
}

.actions-col {
  width: 160px;
}

.action-buttons {
  display: flex;
  gap: 8px;
}

.btn-action {
  background: white;
  border: 1px solid #dfe6e9;
  width: 36px;
  height: 36px;
  border-radius: 8px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  transition: all 0.3s;
}

.btn-action:hover {
  transform: translateY(-2px);
}

.btn-action.view:hover {
  background: #e3f2fd;
  border-color: #3498db;
  color: #3498db;
}

.btn-action.edit:hover {
  background: #fff3e0;
  border-color: #fdcb6e;
  color: #f57c00;
}

.btn-action.assign:hover {
  background: #f3e5f5;
  border-color: #a29bfe;
  color: #6c5ce7;
}

.btn-action.close:hover {
  background: #e8f5e9;
  border-color: #00b894;
  color: #00a085;
}

/* Pagination */
.pagination {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  background: #f8f9fa;
  border-top: 1px solid #e0e6ed;
}

.pagination-info {
  color: #636e72;
  font-size: 0.9rem;
}

.pagination-controls {
  display: flex;
  align-items: center;
  gap: 8px;
}

.pagination-btn {
  background: white;
  border: 1px solid #dfe6e9;
  padding: 8px 16px;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.3s;
}

.pagination-btn:hover:not(:disabled) {
  border-color: #3498db;
  color: #3498db;
}

.pagination-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.page-numbers {
  display: flex;
  gap: 4px;
}

.page-btn {
  background: white;
  border: 1px solid #dfe6e9;
  width: 36px;
  height: 36px;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.3s;
}

.page-btn:hover {
  border-color: #3498db;
  color: #3498db;
}

.page-btn.active {
  background: #3498db;
  color: white;
  border-color: #3498db;
}

.items-per-page {
  display: flex;
  align-items: center;
  gap: 8px;
}

.items-per-page label {
  color: #636e72;
  font-size: 0.9rem;
}

.items-per-page select {
  padding: 6px 12px;
  border: 1px solid #dfe6e9;
  border-radius: 6px;
  background: white;
}

/* Bulk Actions Panel */
.bulk-actions-panel {
  background: white;
  border-radius: 16px;
  padding: 20px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
  width: 300px;
  align-self: flex-start;
}

@media (max-width: 1200px) {
  .bulk-actions-panel {
    width: 100%;
  }
}

.bulk-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding-bottom: 16px;
  border-bottom: 1px solid #e0e6ed;
}

.bulk-header h3 {
  color: #2d3436;
  margin: 0;
  font-size: 1.1rem;
}

.btn-clear-selection {
  background: #dfe6e9;
  border: none;
  width: 28px;
  height: 28px;
  border-radius: 50%;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
}

.btn-clear-selection:hover {
  background: #b2bec3;
}

.bulk-actions {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.bulk-select,
.bulk-input {
  width: 100%;
  padding: 10px;
  border: 2px solid #dfe6e9;
  border-radius: 8px;
  font-size: 0.95rem;
  background: white;
}

.bulk-select:focus,
.bulk-input:focus {
  outline: none;
  border-color: #3498db;
}

.bulk-action-form {
  display: flex;
  gap: 8px;
}

.btn-apply {
  background: #3498db;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  white-space: nowrap;
}

.btn-apply:hover:not(:disabled) {
  background: #2980b9;
}

.btn-apply:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-delete-bulk {
  width: 100%;
  background: #ffebee;
  color: #d32f2f;
  border: 2px solid #ffcdd2;
  padding: 12px;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  transition: all 0.3s;
}

.btn-delete-bulk:hover {
  background: #ffcdd2;
  border-color: #d32f2f;
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
  z-index: 1000;
  animation: slideInRight 0.3s ease-out;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
  max-width: 400px;
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

@keyframes slideInRight {
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
@media (max-width: 768px) {
  .admin-tickets-page {
    padding: 16px;
  }
  
  .tickets-header {
    flex-direction: column;
    align-items: stretch;
  }
  
  .header-actions {
    justify-content: stretch;
  }
  
  .btn-create-ticket,
  .btn-refresh {
    flex: 1;
    justify-content: center;
  }
  
  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .filter-controls {
    grid-template-columns: 1fr;
  }
  
  .tickets-table {
    display: block;
    overflow-x: auto;
  }
  
  .pagination {
    flex-direction: column;
    gap: 16px;
    align-items: stretch;
  }
  
  .pagination-controls {
    justify-content: center;
  }
}
</style>
