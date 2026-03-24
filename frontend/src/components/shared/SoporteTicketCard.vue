<template>
  <div class="soporte-ticket-card" @click="handleClick">
    <div class="soporte-ticket-header">
      <div class="soporte-ticket-subject">
        <h3 class="soporte-subject-text">{{ ticket.subject }}</h3>
        <p class="soporte-last-message">{{ ticket.last_message }}</p>
      </div>
      <div class="soporte-ticket-status" :class="statusColorClass">
        {{ statusLabel }}
      </div>
    </div>

    <div class="soporte-ticket-footer">
      <div class="soporte-ticket-date">
        <span class="soporte-date-icon">📅</span>
        <span class="soporte-date-text">{{ formatDate }}</span>
      </div>
      <button 
        class="soporte-btn-view-ticket" 
        @click.stop="handleClick"
        :aria-label="`Ver detalles del ticket ${ticket.subject}`"
      >
        Ver detalles
      </button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'SoporteTicketCard',
  props: {
    ticket: {
      type: Object,
      required: true,
      validator: (ticket) => {
        return ticket.id && 
               ticket.subject && 
               ticket.last_message !== undefined &&
               ticket.status &&
               ticket.updated_at
      }
    }
  },
  emits: ['click'],
  computed: {
    formatDate() {
      if (!this.ticket.updated_at) return ''
      const locale = this.$i18n?.locale?.value || 'es'
      try {
        return new Date(this.ticket.updated_at).toLocaleString(locale, {
          year: 'numeric',
          month: 'long',
          day: 'numeric',
          hour: '2-digit',
          minute: '2-digit'
        })
      } catch {
        return this.ticket.updated_at
      }
    },
    
    statusLabel() {
      const key = 'status.' + this.ticket.status
      const translated = this.$t?.(key) || key
      return translated === key ? this.ticket.status : translated
    },
    
    statusColorClass() {
      const colorMap = {
        completed: 'soporte-status-completed',
        cancelled: 'soporte-status-cancelled',
        rejected: 'soporte-status-rejected',
        finalized: 'soporte-status-finalized',
        open: 'soporte-status-open',
        pending: 'soporte-status-pending',
        in_progress: 'soporte-status-in-progress'
      }
      return colorMap[this.ticket.status] || 'soporte-status-default'
    }
  },
  methods: {
    handleClick() {
      this.$emit('click', this.ticket)
    }
  }
}
</script>

<style scoped>
.soporte-ticket-card {
  background: white;
  border-radius: 1rem;
  padding: 1.25rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  cursor: pointer;
  transition: all 0.2s ease;
  border: 1px solid #f0f0f0;
}

.soporte-ticket-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  border-color: #e0e0e0;
}

.soporte-ticket-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 1rem;
}

.soporte-ticket-subject {
  flex: 1;
  margin-right: 1rem;
}

.soporte-subject-text {
  font-size: 1rem;
  font-weight: 600;
  color: #1a1a1a;
  margin: 0 0 0.35rem 0;
  line-height: 1.4;
}

.soporte-last-message {
  font-size: 0.85rem;
  color: #666;
  margin: 0;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.soporte-ticket-status {
  padding: 0.25rem 0.75rem;
  border-radius: 2rem;
  font-size: 0.75rem;
  font-weight: 500;
  white-space: nowrap;
  text-transform: capitalize;
}

.soporte-ticket-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 1rem;
  padding-top: 0.75rem;
  border-top: 1px solid #f0f0f0;
}

.soporte-ticket-date {
  display: flex;
  align-items: center;
  gap: 0.35rem;
  color: #888;
  font-size: 0.8rem;
}

.soporte-date-icon {
  font-size: 0.9rem;
}

.soporte-btn-view-ticket {
  background: none;
  border: none;
  color: #3498db;
  font-size: 0.8rem;
  font-weight: 500;
  cursor: pointer;
  padding: 0.25rem 0.5rem;
  border-radius: 0.25rem;
  transition: background-color 0.2s;
}

.soporte-btn-view-ticket:hover {
  background-color: #f0f7ff;
  text-decoration: underline;
}

/* Estados de tickets */
.soporte-status-completed { background: #e8f5e9; color: #2e7d32; }
.soporte-status-cancelled { background: #ffebee; color: #c62828; }
.soporte-status-rejected { background: #ffebee; color: #c62828; }
.soporte-status-finalized { background: #e8eaf6; color: #283593; }
.soporte-status-open { background: #e3f2fd; color: #1565c0; }
.soporte-status-pending { background: #fff3e0; color: #ef6c00; }
.soporte-status-in-progress { background: #f3e5f5; color: #7b1fa2; }
.soporte-status-default { background: #f5f5f5; color: #616161; }
</style>
