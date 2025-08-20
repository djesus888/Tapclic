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
            <h3 class="text-lg font-semibold text-gray-800">{{ req.title }}</h3>
            <p class="text-sm text-gray-600">{{ req.description }}</p>
            <p class="text-sm mt-2 text-gray-500">{{ req.location }}</p>
            <p class="text-sm mt-1 font-bold text-green-600">
              ${{ req.price.toFixed(2) }}
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
          <h3 class="text-lg font-semibold text-gray-800">{{ req.title }}</h3>
          <p class="text-sm text-gray-600">{{ req.description }}</p>
        </div>
      </div>

      <!-- Completed -->
      <div v-if="activeTab === 'completed'" class="grid gap-4 md:grid-cols-2">
        <div
          v-for="req in completedRequests"
          :key="req.id"
          class="bg-gray-50 border border-gray-200 rounded-lg shadow p-4"
        >
          <h3 class="text-lg font-semibold text-gray-800">{{ req.title }}</h3>
          <p class="text-sm text-gray-600">{{ req.description }}</p>
          <p class="text-xs text-green-600 mt-2">Completado ✅</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import api from "@/axio";
import { useAuthStore } from "@/stores/authStore";

export default {
  name: "DashboardDriver",
  data() {
    return {
      tabs: [
        { value: "available", label: "Solicitudes" },
        { value: "in-progress", label: "En Progreso" },
        { value: "completed", label: "Completadas" },
      ],
      activeTab: "available",
      availableRequests: [],
      inProgressRequests: [],
      completedRequests: [],
    };
  },
  async created() {
    const auth = useAuthStore();
    const headers = { Authorization: `Bearer ${auth.token}` };

    try {
      // Asignadas
      const resAssigned = await api.get("/api/requests/assigned", { headers });
      this.availableRequests = resAssigned.data.requests;

      // Progreso
      const resProgress = await api.get("/api/requests/in-progress", { headers });
      this.inProgressRequests = resProgress.data.requests;

      // Completadas
      const resCompleted = await api.get("/api/requests/completed", { headers });
      this.completedRequests = resCompleted.data.requests;
    } catch (err) {
      console.error("Error cargando Dashboard:", err);
    }
  },
  methods: {
    async acceptRequest(id) {
      console.log("Aceptar", id);
      // Aquí puedes integrar POST a /api/requests/accept
    },
    async rejectRequest(id) {
      console.log("Rechazar", id);
      // Aquí puedes integrar POST a /api/requests/reject
    },
  },
};
</script>

