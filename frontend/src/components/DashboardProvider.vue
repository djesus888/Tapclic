
<template>
  <div class="p-4 space-y-6">
    <!-- Tabs -->
    <div>
      <div class="flex border-b border-gray-200 mb-4">
        <button
          v-for="tab in tabs"
          :key="tab.value"
          @click="activeTab = tab.value"
          :class="[
            'px-4 py-2 text-sm font-medium',
            activeTab === tab.value
              ? 'border-b-2 border-blue-500 text-blue-600'
              : 'text-gray-500 hover:text-gray-700'
          ]"
        >
          {{ tab.label }}
        </button>
      </div>

      <!-- Available Requests -->
      <div v-if="activeTab === 'available'" class="grid gap-4 md:grid-cols-2">
        <div
          v-for="req in availableRequests"
          :key="req.id"
          class="bg-white rounded-lg shadow p-4 flex flex-col justify-between"
        >
          <div>
            <h3 class="text-lg font-semibold text-gray-800">{{ req.service_title }}</h3>
            <p class="text-sm text-gray-600">{{ req.service_description }}</p>
            <p class="text-sm mt-2 text-gray-500">{{ req.service_location }}</p>
            <p class="text-sm mt-2 text-gray-500">{{ req.service_provider_name }}</p>
            <p class="text-sm mt-1 font-bold text-green-600">
               ${{ req.service_price ? Number(req.service_price).toFixed(2) : '0.00' }}
              </p>
          </div>
          <div class="flex gap-2 mt-4">
            <button
              class="bg-green-500 text-white px-3 py-1 rounded hover:bg-green-600"
              @click="acceptRequest(req.id)"
            >
              Aceptar
            </button>
            <button
              class="bg-red-500 text-white px-3 py-1 rounded hover:bg-red-600"
              @click="rejectRequest(req.id)"
            >
              Rechazar
            </button>
              <button
              class="bg-blue-500 text-white px-3 py-1 rounded hover:bg-blue-600"
              @click="busyRequest(req.id)"
            >
              Ocupadoo
            </button>
          </div>
        </div>
      </div>

      <!-- In Progress -->
      <div v-if="activeTab === 'in-progress'" class="grid gap-4 md:grid-cols-2">
        <div
          v-for="req in inProgressRequests"
          :key="req.id"
          class="bg-white rounded-lg shadow p-4"
        >
          <h3 class="text-lg font-semibold text-gray-800">{{ req.service_title }}</h3>
          <p class="text-sm text-gray-600">{{ req.service_description }}</p>
        </div>
      </div>

      <!-- Completed -->
      <div v-if="activeTab === 'completed'" class="grid gap-4 md:grid-cols-2">
        <div
          v-for="req in completedRequests"
          :key="req.id"
          class="bg-gray-50 border border-gray-200 rounded-lg shadow p-4"
        >
          <h3 class="text-lg font-semibold text-gray-800">{{ req.service_title }}</h3>
          <p class="text-sm text-gray-600">{{ req.service_description }}</p>
          <p class="text-xs text-green-600 mt-2">Completado ✅</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import api from "@/axio";
import { useAuthStore } from "@/stores/authStore";
import { useSocketStore } from '../stores/socketStore'; // <-- Importar el store

export default {
  name: "DashboardProvider",
  data() {
    return {
      tabs: [
        { value: "available", label: "Solicitudes" },
        { value: "in-progress", label: "Activas" },
        { value: "completed", label: "Completadas" },
      ],
      activeTab: "available",
      availableRequests: [],
      inProgressRequests: [],
      completedRequests: [],
    };
  },
  async created() {
    const socketStore = useSocketStore();
    socketStore.init();  // <-- Conexión WebSocket

    const auth = useAuthStore();
    const headers = { Authorization: `Bearer ${auth.token}` };

    // Funciones para recargar cada tipo de solicitudes
    const fetchPendingRequests = async () => {
      try {
        const res = await api.get("/requests/pending", { headers });
        this.availableRequests = Array.isArray(res.data.data) ? res.data.data : [];
      } catch (err) {
        console.error("Error recargando solicitudes pendientes:", err);
      }
    };

    const fetchActiveRequests = async () => {
      try {
        const res = await api.get("/requests/active", { headers });
        this.inProgressRequests = Array.isArray(res.data.data) ? res.data.data : [];
      } catch (err) {
        console.error("Error recargando solicitudes activas:", err);
      }
    };

    const fetchCompletedRequests = async () => {
      try {
        const res = await api.get("/requests/completed", { headers });
        this.completedRequests = Array.isArray(res.data.data) ? res.data.data : [];
      } catch (err) {
        console.error("Error recargando solicitudes completadas:", err);
      }
    };

    // 🔔 Observar nuevas notificaciones y actualizar listas según tipo
    this.$watch(
  () => socketStore.notifications,
  (newVal) => {
    if (newVal.length > 0) {
      const last = newVal[newVal.length - 1]; // última notificación

      if (last.type === "request.accepted" || last.type === "request.busy") {
        fetchActiveRequests();
      } else if (last.type === "request.rejected") {
        fetchPendingRequests();
      } else if (last.type === "request.completed") {
        fetchCompletedRequests();
      }
    }
  },
  { deep: true }
);

    // Cargar inicialmente todas las listas
    try {
      await fetchPendingRequests();
      await fetchActiveRequests();
      await fetchCompletedRequests();
    } catch (err) {
      console.error("Error cargando Dashboard:", err);
    }
  },
  methods: {
  async acceptRequest(id) {
    try {
      const res = await api.post("/requests/accept", { id });
      if (res.data.success) {
        // Solo sacamos de available, el WebSocket se encarga de meter en inProgress
        this.availableRequests = this.availableRequests.filter(r => r.id !== id);
      }
    } catch (err) {
      console.error(err);
    }
  },

  async rejectRequest(id) {
    try {
      const res = await api.post("/requests/reject", { id });
      if (res.data.success) {
        this.availableRequests = this.availableRequests.filter(r => r.id !== id);
      }
    } catch (err) {
      console.error(err);
    }
  },

  async busyRequest(id) {
    try {
      const res = await api.post("/requests/busy", { id });
      if (res.data.success) {
        // Igual que en accept, no hacemos push
        this.availableRequests = this.availableRequests.filter(r => r.id !== id);
      }
    } catch (err) {
      console.error(err);
    }
  },
 }
};
</script>
