<template>
  <div class="p-6 space-y-6">

    <!-- Tarjetas estadísticas -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
      <div
        v-for="card in statCards"
        :key="card.title"
        class="bg-white shadow rounded-lg p-4"
      >
        <div class="flex items-center justify-between">
          <div>
            <p class="text-gray-500 text-sm">{{ t(`stats.${card.title}`) }}</p>
            <h2 class="text-2xl font-bold">{{ card.value }}</h2>
          </div>
          <div class="text-gray-400 text-3xl">
            <component :is="card.icon" class="w-8 h-8" />
          </div>
        </div>
      </div>
    </div>

    <!-- Últimas actividades -->
    <div class="bg-white shadow rounded-lg p-4">
      <h2 class="text-lg font-semibold mb-4">{{ t("latestActivities") }}</h2>
      <ul>
        <li
          v-for="(activity, index) in translatedActivities"
          :key="index"
          class="py-2 border-b last:border-b-0"
        >
          {{ activity }}
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
import { onMounted, reactive, computed } from "vue";
import { useI18n } from "vue-i18n";
import { useAuthStore } from "@/stores/authStore";
import api from "@/axio"; // Importa tu instancia axios configurada
import { Users, ClipboardList, Settings, Bell } from "lucide-vue-next";

export default {
  name: "DashboardAdmin",
  components: {
    Users,
    ClipboardList,
    Settings,
    Bell,
  },
  setup() {
    const { t } = useI18n();
    const authStore = useAuthStore();

    const state = reactive({
      statCards: [
        { title: "users", value: 0, icon: "Users" },
        { title: "services", value: 0, icon: "ClipboardList" },
        { title: "settings", value: "-", icon: "Settings" },
        { title: "notifications", value: 0, icon: "Bell" },
      ],
      activities: [],
    });

    const fetchStats = async () => {
      try {
        const res = await api.get("/admin/stats");
        const data = res.data;

        state.statCards[0].value = data.totalUsers || 0;
        state.statCards[1].value = data.totalServices || 0;
        state.statCards[3].value = data.totalNotifications || 0;
        state.activities = data.latestActivities || [];
      } catch (err) {
        console.error("Error al cargar estadísticas", err);
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

    onMounted(fetchStats);

    return { ...state, t, translatedActivities };
  },
};
</script>
