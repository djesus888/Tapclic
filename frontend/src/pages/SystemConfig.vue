<template>
  <div class="p-6 max-w-4xl mx-auto">
    <h1 class="text-2xl font-bold mb-6">
      {{ t("systemConfig.title") }}
    </h1>

    <!-- Formulario -->
    <form
      class="space-y-4"
      @submit.prevent="save"
    >
      <!-- Campos normales -->
      <div>
        <label class="block text-sm font-medium mb-1">{{ t("systemConfig.systemName") }}</label>
        <input
          v-model="form.system_name"
          type="text"
          class="w-full border rounded px-3 py-2"
          required
        >
      </div>

      <div>
        <label class="block text-sm font-medium mb-1">{{ t("systemConfig.systemHost") }}</label>
        <input
          v-model="form.system_host"
          type="url"
          class="w-full border rounded px-3 py-2"
          required
        >
      </div>

      <div>
        <label class="block text-sm font-medium mb-1">{{ t("systemConfig.companyName") }}</label>
        <input
          v-model="form.company_name"
          type="text"
          class="w-full border rounded px-3 py-2"
          required
        >
      </div>

      <div>
        <label class="block text-sm font-medium mb-1">{{ t("systemConfig.companyAddress") }}</label>
        <textarea
          v-model="form.company_address"
          rows="2"
          class="w-full border rounded px-3 py-2"
          required
        />
      </div>

      <div>
        <label class="block text-sm font-medium mb-1">{{ t("systemConfig.supportEmail") }}</label>
        <input
          v-model="form.support_email"
          type="email"
          class="w-full border rounded px-3 py-2"
          required
        >
      </div>

      <div>
        <label class="block text-sm font-medium mb-1">{{ t("systemConfig.supportPhone") }}</label>
        <input
          v-model="form.support_phone"
          type="tel"
          class="w-full border rounded px-3 py-2"
        >
      </div>

      <div>
        <label class="block text-sm font-medium mb-1">{{ t("systemConfig.defaultLanguage") }}</label>
        <select
          v-model="form.default_language"
          class="w-full border rounded px-3 py-2"
        >
          <option value="es">
            Español
          </option>
          <option value="en">
            English
          </option>
        </select>
      </div>

      <div>
        <label class="block text-sm font-medium mb-1">{{ t("systemConfig.timezone") }}</label>
        <input
          v-model="form.timezone"
          type="text"
          class="w-full border rounded px-3 py-2"
          placeholder="America/Caracas"
        >
      </div>

      <div>
        <label class="block text-sm font-medium mb-1">{{ t("systemConfig.currency") }}</label>
        <input
          v-model="form.currency"
          maxlength="3"
          class="w-full border rounded px-3 py-2"
          placeholder="USD"
        >
      </div>

      <div>
        <label class="block text-sm font-medium mb-1">{{ t("systemConfig.themeColor") }}</label>
        <input
          v-model="form.theme_color"
          type="color"
          class="w-full h-10 border rounded"
        >
      </div>

      <div>
        <label class="block text-sm font-medium mb-1">{{ t("systemConfig.itemsPerPage") }}</label>
        <input
          v-model.number="form.items_per_page"
          type="number"
          min="5"
          max="200"
          class="w-full border rounded px-3 py-2"
        >
      </div>

      <div>
        <label class="block text-sm font-medium mb-1">{{ t("systemConfig.maxLoginAttempts") }}</label>
        <input
          v-model.number="form.max_login_attempts"
          type="number"
          min="1"
          max="20"
          class="w-full border rounded px-3 py-2"
        >
      </div>

      <div>
        <label class="block text-sm font-medium mb-1">{{ t("systemConfig.sessionTimeout") }}</label>
        <input
          v-model.number="form.session_timeout_minutes"
          type="number"
          min="1"
          max="999"
          class="w-full border rounded px-3 py-2"
        >
      </div>

      <div>
        <label class="block text-sm font-medium mb-1">{{ t("systemConfig.passwordExpiration") }}</label>
        <input
          v-model.number="form.password_expiration_days"
          type="number"
          min="0"
          max="999"
          class="w-full border rounded px-3 py-2"
        >
      </div>

      <!-- Switches -->
      <div class="flex items-center gap-2">
        <input
          id="system_active"
          v-model="form.system_active"
          type="checkbox"
          class="switch"
        >
        <label
          for="system_active"
          class="text-sm"
        >{{ t("systemConfig.systemActive") }}</label>
      </div>

      <div class="flex items-center gap-2">
        <input
          id="maintenance_mode"
          v-model="form.maintenance_mode"
          type="checkbox"
          class="switch"
        >
        <label
          for="maintenance_mode"
          class="text-sm"
        >{{ t("systemConfig.maintenanceMode") }}</label>
      </div>

      <div class="flex items-center gap-2">
        <input
          id="allow_user_registration"
          v-model="form.allow_user_registration"
          type="checkbox"
          class="switch"
        >
        <label
          for="allow_user_registration"
          class="text-sm"
        >{{ t("systemConfig.allowRegistration") }}</label>
      </div>

      <!-- Logos -->
      <div>
        <label class="block text-sm font-medium mb-1">{{ t("systemConfig.systemLogo") }}</label>
        <input
          ref="logoFile"
          type="file"
          accept="image/*"
          class="w-full"
          @change="uploadLogo"
        >
        <img
          v-if="form.system_logo"
          :src="form.system_logo"
          class="mt-2 h-16"
        >
      </div>

      <div>
        <label class="block text-sm font-medium mb-1">{{ t("systemConfig.systemFavicon") }}</label>
        <input
          ref="faviconFile"
          type="file"
          accept="image/*"
          class="w-full"
          @change="uploadFavicon"
        >
        <img
          v-if="form.system_favicon"
          :src="form.system_favicon"
          class="mt-2 h-10"
        >
      </div>

      <!-- Botón guardar -->
      <button
        type="submit"
        class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
      >
        {{ t("systemConfig.save") }}
      </button>
    </form>
  </div>
</template>

<script setup>
import { reactive, ref, onMounted } from "vue";
import { useI18n } from "vue-i18n";
import api from "@/axios";

const { t } = useI18n();

const logoFile   = ref();
const faviconFile = ref();

const form = reactive({
  system_name: "",
  system_host: "",
  company_name: "",
  company_address: "",
  support_email: "",
  support_phone: "",
  default_language: "es",
  timezone: "",
  currency: "USD",
  theme_color: "#409EFF",
  items_per_page: 20,
  max_login_attempts: 5,
  session_timeout_minutes: 30,
  password_expiration_days: 90,
  system_active: true,
  maintenance_mode: false,
  allow_user_registration: true,
  system_logo: "",
  system_favicon: "",
});

/* ---------- Cargar valores actuales ---------- */
onMounted(async () => {
  const { data } = await api.get("/admin/system-config");
  Object.assign(form, data);
});

/* ---------- Subir logo ---------- */
async function uploadLogo() {
  const file = logoFile.value.files[0];
  if (!file) return;
  const fd = new FormData();
  fd.append("file", file);
  const { data } = await api.post("/admin/upload-logo", fd, {
    headers: { "Content-Type": "multipart/form-data" },
  });
  form.system_logo = data.url;
}

/* ---------- Subir favicon ---------- */
async function uploadFavicon() {
  const file = faviconFile.value.files[0];
  if (!file) return;
  const fd = new FormData();
  fd.append("file", file);
  const { data } = await api.post("/admin/upload-favicon", fd, {
    headers: { "Content-Type": "multipart/form-data" },
  });
  form.system_favicon = data.url;
}

/* ---------- Guardar cambios ---------- */
async function save() {
  await api.put("/admin/system-config", form);
  alert(t("systemConfig.saved"));
}
</script>

<style scoped>
.switch {
  @apply w-4 h-4 text-blue-600 rounded focus:ring-blue-500;
}
</style>
