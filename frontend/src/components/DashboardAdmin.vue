<template>
  <div class="dashboard-admin">
    <!-- Header del Dashboard -->
    <div class="dashboard-header">
      <div class="header-content">
        <h1>📊 Panel de Administración</h1>
        <p>Resumen completo de estadísticas y actividades</p>
      </div>
      <div class="header-actions">
        <button class="btn-refresh" @click="fetchStats">
          🔄 Actualizar
        </button>
      </div>
    </div>

    <!-- Tarjetas estadísticas -->
    <div class="stats-grid">
      <div 
        v-for="card in statCards" 
        :key="card.title"
        class="stat-card"
        :class="`stat-${card.title.replace(/([A-Z])/g, '-$1').toLowerCase()}`"
      >
        <div class="card-badge" v-if="card.title === 'onlineUsers' && card.value > 0">
          En línea
        </div>
        
        <div class="card-icon">
          <component :is="card.icon" class="icon" />
        </div>
        
        <div class="card-content">
          <p class="card-title">{{ t(`stats.${card.title}`) }}</p>
          <h3 class="card-value">{{ formatValue(card) }}</h3>
          
          <div class="card-trend" v-if="showTrend(card.title)">
            <span :class="getTrendClass(card.title)">
              {{ getTrendIcon(card.title) }} {{ getTrendText(card.title) }}
            </span>
          </div>
        </div>
      </div>
    </div>

    <!-- Últimas actividades -->
    <div class="activities-section">
      <div class="section-header">
        <h2>📋 {{ t("latestActivities") }}</h2>
        <span class="activity-count">{{ translatedActivities.length }} actividades</span>
      </div>
      
      <div class="activities-container">
        <div v-if="translatedActivities.length === 0" class="empty-activities">
          <div class="empty-icon">📊</div>
          <h3>No hay actividades recientes</h3>
          <p>Las actividades del sistema aparecerán aquí</p>
        </div>
        
        <div v-else class="activities-list">
          <div 
            v-for="(activity, index) in translatedActivities" 
            :key="index"
            class="activity-item"
            :class="`activity-${(index % 3) + 1}`"
          >
            <div class="activity-icon">
              <span>{{ getActivityIcon(index) }}</span>
            </div>
            
            <div class="activity-content">
              <p class="activity-text">{{ activity }}</p>
              <span class="activity-time">{{ getRelativeTime(index) }}</span>
            </div>
            
            <div class="activity-status" :class="getStatusClass(index)">
              {{ getStatusText(index) }}
            </div>
          </div>
        </div>
      </div>
      
      <!-- Resumen rápido -->
      <div class="quick-summary">
        <div class="summary-item">
          <div class="summary-icon">👥</div>
          <div class="summary-content">
            <h4>Usuarios totales</h4>
            <p>{{ statCards[0].value }}</p>
          </div>
        </div>
        
        <div class="summary-item">
          <div class="summary-icon">💰</div>
          <div class="summary-content">
            <h4>Ingresos mensuales</h4>
            <p>{{ formatPrice(statCards[4].value) }}</p>
          </div>
        </div>
        
        <div class="summary-item">
          <div class="summary-icon">⏱️</div>
          <div class="summary-content">
            <h4>Tasa de actividad</h4>
            <p>{{ calculateActivityRate() }}%</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { onMounted, reactive, computed } from "vue";
import { useI18n } from "vue-i18n";
import { useAuthStore } from "@/stores/authStore";
import api from "@/axios";
import {
  Users,
  ClipboardList,
  Settings,
  Bell,
  Activity,
  Package,
  UserCheck,
  DollarSign,
  Star,
} from "lucide-vue-next";

export default {
  name: "DashboardAdmin",
  components: {
    Users,
    ClipboardList,
    Settings,
    Bell,
    Activity,
    Package,
    UserCheck,
    DollarSign,
    Star,
  },
  setup() {
    const { t } = useI18n();
    const authStore = useAuthStore();
    const state = reactive({
      statCards: [
        { title: "users", value: 0, icon: "Users" },
        { title: "onlineUsers", value: 0, icon: "Activity" },
        { title: "pendingOrders", value: 0, icon: "Package" },
        { title: "activeProviders", value: 0, icon: "UserCheck" },
        { title: "monthIncome", value: 0, icon: "DollarSign" },
        { title: "pendingReviews", value: 0, icon: "Star" },
        { title: "services", value: 0, icon: "ClipboardList" },
        { title: "notifications", value: 0, icon: "Bell" },
        { title: "settings", value: "-", icon: "Settings" },
      ],
      activities: [],
      loading: false,
    });

    const fetchStats = async () => {
      state.loading = true;
      try {
        const res = await api.get("/admin/stats");
        const data = res.data;

        // Actualiza todas las tarjetas
        state.statCards[0].value = data.totalUsers || 0;
        state.statCards[1].value = data.onlineUsers || 0;
        state.statCards[2].value = data.pendingOrders || 0;
        state.statCards[3].value = data.activeProviders || 0;
        state.statCards[4].value = data.monthIncome || 0;
        state.statCards[5].value = data.pendingReviews || 0;
        state.statCards[6].value = data.totalServices || 0;
        state.statCards[7].value = data.totalNotifications || 0;
        state.statCards[8].value = data.settings ?? 0;
        state.activities = data.latestActivities || [];
      } catch (err) {
        console.error("Error al cargar estadísticas", err);
      } finally {
        state.loading = false;
      }
    };

    const translatedActivities = computed(() =>
      state.activities.map(({ message_key, params }) => {
        if (!params || Object.keys(params).length === 0) {
          return t(message_key);
        } else {
          return t(message_key, params);
        }
      })
    );

    // Métodos para formatear valores
    const formatValue = (card) => {
      if (card.title === 'monthIncome') {
        return formatPrice(card.value);
      }
      return card.value;
    };

    const formatPrice = (amount) => {
      if (amount === 0 || amount === '-') return '$0';
      return new Intl.NumberFormat('es-ES', {
        style: 'currency',
        currency: 'USD',
        minimumFractionDigits: 0,
        maximumFractionDigits: 0
      }).format(amount);
    };

    // Métodos para tendencias (simulados)
    const showTrend = (title) => {
      return ['users', 'monthIncome', 'activeProviders'].includes(title);
    };

    const getTrendClass = (title) => {
      const trends = {
        'users': 'trend-up',
        'monthIncome': 'trend-up',
        'activeProviders': 'trend-neutral'
      };
      return trends[title] || 'trend-neutral';
    };

    const getTrendIcon = (title) => {
      const icons = {
        'users': '📈',
        'monthIncome': '💰',
        'activeProviders': '➡️'
      };
      return icons[title] || '📊';
    };

    const getTrendText = (title) => {
      const texts = {
        'users': '+12%',
        'monthIncome': '+23%',
        'activeProviders': '+5%'
      };
      return texts[title] || '0%';
    };

    // Métodos para actividades
    const getActivityIcon = (index) => {
      const icons = ['👤', '🛠️', '💰', '⭐', '🔔', '⚙️'];
      return icons[index % icons.length];
    };

    const getRelativeTime = (index) => {
      const times = ['Hace 5 min', 'Hace 15 min', 'Hace 1 hora', 'Hace 3 horas', 'Hace 1 día', 'Hace 2 días'];
      return times[index % times.length];
    };

    const getStatusClass = (index) => {
      const statuses = ['success', 'warning', 'info', 'error', 'success', 'info'];
      return `status-${statuses[index % statuses.length]}`;
    };

    const getStatusText = (index) => {
      const texts = ['Completado', 'Pendiente', 'En progreso', 'Error', 'Completado', 'Info'];
      return texts[index % texts.length];
    };

    // Método para calcular tasa de actividad
    const calculateActivityRate = () => {
      const totalUsers = state.statCards[0].value || 1;
      const onlineUsers = state.statCards[1].value || 0;
      return Math.round((onlineUsers / totalUsers) * 100);
    };

    onMounted(fetchStats);

    return {
      ...state,
      t,
      translatedActivities,
      fetchStats,
      formatValue,
      formatPrice,
      showTrend,
      getTrendClass,
      getTrendIcon,
      getTrendText,
      getActivityIcon,
      getRelativeTime,
      getStatusClass,
      getStatusText,
      calculateActivityRate,
    };
  },
};
</script>

<style scoped>
.dashboard-admin {
  padding: 24px;
  background: linear-gradient(135deg, #f5f7fa 0%, #e4edf5 100%);
  min-height: 100vh;
}

/* Header */
.dashboard-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 40px;
  flex-wrap: wrap;
  gap: 20px;
}

.header-content h1 {
  font-size: 2.5rem;
  color: #2d3436;
  margin-bottom: 8px;
  display: flex;
  align-items: center;
  gap: 10px;
}

.header-content p {
  color: #636e72;
  font-size: 1.1rem;
}

.header-actions {
  display: flex;
  gap: 12px;
}

.btn-refresh {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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

.btn-refresh:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
}

/* Stats Grid */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 24px;
  margin-bottom: 40px;
}

.stat-card {
  background: white;
  padding: 24px;
  border-radius: 20px;
  position: relative;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
  transition: all 0.4s;
  border: 1px solid #f1f2f6;
  overflow: hidden;
}

.stat-card:hover {
  transform: translateY(-10px);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
}

.stat-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: linear-gradient(90deg, #667eea, #764ba2);
}

.card-badge {
  position: absolute;
  top: 16px;
  right: 16px;
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
  color: white;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 0.75rem;
  font-weight: 600;
  z-index: 2;
}

.card-icon {
  width: 60px;
  height: 60px;
  background: linear-gradient(135deg, #a8edea 0%, #fed6e3 100%);
  border-radius: 15px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 20px;
}

.card-icon .icon {
  width: 30px;
  height: 30px;
  color: #2d3436;
}

.card-content {
  position: relative;
}

.card-title {
  color: #636e72;
  font-size: 0.9rem;
  font-weight: 600;
  margin-bottom: 8px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.card-value {
  font-size: 2.2rem;
  font-weight: 700;
  color: #2d3436;
  margin-bottom: 12px;
}

.card-trend {
  display: flex;
  align-items: center;
  gap: 6px;
}

.trend-up {
  color: #00b894;
  font-weight: 600;
  font-size: 0.9rem;
}

.trend-down {
  color: #ff7675;
  font-weight: 600;
  font-size: 0.9rem;
}

.trend-neutral {
  color: #636e72;
  font-weight: 600;
  font-size: 0.9rem;
}

/* Activities Section */
.activities-section {
  background: white;
  border-radius: 20px;
  padding: 32px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.section-header h2 {
  font-size: 1.8rem;
  color: #2d3436;
  display: flex;
  align-items: center;
  gap: 10px;
}

.activity-count {
  background: #f8f9fa;
  color: #636e72;
  padding: 6px 16px;
  border-radius: 20px;
  font-size: 0.9rem;
  font-weight: 600;
}

.activities-container {
  margin-bottom: 32px;
}

.empty-activities {
  text-align: center;
  padding: 60px 20px;
  background: #f8f9fa;
  border-radius: 15px;
}

.empty-icon {
  font-size: 64px;
  margin-bottom: 20px;
  opacity: 0.5;
}

.empty-activities h3 {
  color: #2d3436;
  margin-bottom: 10px;
}

.empty-activities p {
  color: #636e72;
  max-width: 300px;
  margin: 0 auto;
}

.activities-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.activity-item {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px;
  background: #f8f9fa;
  border-radius: 12px;
  transition: all 0.3s;
  border-left: 4px solid #667eea;
}

.activity-item:hover {
  background: #f1f2f6;
  transform: translateX(5px);
}

.activity-2 {
  border-left-color: #00b894;
}

.activity-3 {
  border-left-color: #fdcb6e;
}

.activity-icon {
  width: 40px;
  height: 40px;
  background: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.2rem;
  flex-shrink: 0;
}

.activity-content {
  flex: 1;
}

.activity-text {
  color: #2d3436;
  font-weight: 500;
  margin-bottom: 4px;
}

.activity-time {
  color: #636e72;
  font-size: 0.85rem;
}

.activity-status {
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  flex-shrink: 0;
}

.status-success {
  background: rgba(0, 184, 148, 0.1);
  color: #00b894;
  border: 1px solid rgba(0, 184, 148, 0.2);
}

.status-warning {
  background: rgba(253, 203, 110, 0.1);
  color: #fdcb6e;
  border: 1px solid rgba(253, 203, 110, 0.2);
}

.status-info {
  background: rgba(116, 185, 255, 0.1);
  color: #74b9ff;
  border: 1px solid rgba(116, 185, 255, 0.2);
}

.status-error {
  background: rgba(255, 118, 117, 0.1);
  color: #ff7675;
  border: 1px solid rgba(255, 118, 117, 0.2);
}

/* Quick Summary */
.quick-summary {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
  padding-top: 32px;
  border-top: 2px solid #f1f2f6;
}

.summary-item {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px;
  background: #f8f9fa;
  border-radius: 12px;
  transition: all 0.3s;
}

.summary-item:hover {
  background: #f1f2f6;
  transform: translateY(-3px);
}

.summary-icon {
  width: 50px;
  height: 50px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
  flex-shrink: 0;
}

.summary-content h4 {
  color: #636e72;
  font-size: 0.9rem;
  margin-bottom: 4px;
}

.summary-content p {
  color: #2d3436;
  font-size: 1.3rem;
  font-weight: 700;
}

/* Loading State */
.loading-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(255, 255, 255, 0.9);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  backdrop-filter: blur(4px);
}

/* Responsive Design */
@media (max-width: 1200px) {
  .stats-grid {
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  }
}

@media (max-width: 768px) {
  .dashboard-admin {
    padding: 16px;
  }
  
  .dashboard-header {
    flex-direction: column;
    align-items: stretch;
  }
  
  .header-content h1 {
    font-size: 2rem;
  }
  
  .stats-grid {
    grid-template-columns: 1fr;
  }
  
  .activities-section {
    padding: 20px;
  }
  
  .section-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }
  
  .quick-summary {
    grid-template-columns: 1fr;
  }
  
  .activity-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }
  
  .activity-status {
    align-self: flex-end;
  }
}

@media (max-width: 480px) {
  .header-content h1 {
    font-size: 1.8rem;
  }
  
  .card-value {
    font-size: 1.8rem;
  }
  
  .activity-status {
    align-self: stretch;
    text-align: center;
  }
}
</style>
