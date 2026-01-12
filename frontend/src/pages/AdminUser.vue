<template>
  <div class="min-h-screen bg-gray-100 p-6">
    <div class="max-w-7xl mx-auto">
      <h1 class="text-3xl font-bold text-gray-800 mb-6">
        Gestión de Usuarios
      </h1>

      <!-- Filtros -->
      <div class="bg-white rounded-lg shadow p-4 mb-6 flex flex-wrap gap-4 items-end">
        <div class="flex-1 min-w-[200px]">
          <label class="block text-sm font-medium text-gray-700 mb-1">Buscar</label>
          <input
            v-model="filters.search"
            placeholder="Nombre, email o teléfono"
            class="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
            @input="debouncedSearch"
          >
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Rol</label>
          <select
            v-model="filters.role"
            class="border border-gray-300 rounded-md px-3 py-2"
            @change="fetchUsers"
          >
            <option value="">
              Todos
            </option>
            <option value="client">
              Cliente
            </option>
            <option value="provider">
              Proveedor
            </option>
            <option value="driver">
              Conductor
            </option>
          </select>
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Estado</label>
          <select
            v-model="filters.active"
            class="border border-gray-300 rounded-md px-3 py-2"
            @change="fetchUsers"
          >
            <option value="">
              Todos
            </option>
            <option value="1">
              Activo
            </option>
            <option value="0">
              Inactivo
            </option>
          </select>
        </div>
        <button
          class="bg-gray-200 hover:bg-gray-300 text-gray-800 px-4 py-2 rounded-md"
          @click="resetFilters"
        >
          Limpiar
        </button>
      </div>

      <!-- Tabla -->
      <div class="bg-white rounded-lg shadow overflow-hidden">
        <table
          v-if="users.length"
          class="min-w-full divide-y divide-gray-200"
        >
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                Avatar
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                Nombre
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                Email
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                Teléfono
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                Rol
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                Acciones
              </th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr
              v-for="user in users"
              :key="user.id"
            >
              <td class="px-6 py-4 whitespace-nowrap">
                <img
                  :src="avatarUrl(user?.avatar_url || '')"
                  alt="Avatar"
                  class="w-10 h-10 rounded-full object-cover"
                >
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                {{ user?.name }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {{ user?.email }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {{ user?.phone }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 capitalize">
                {{ user?.role }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm space-x-2">
                <button
                  class="text-blue-600 hover:text-blue-800"
                  @click="openModal(user)"
                >
                  Editar
                </button>
                <button
                  class="text-red-600 hover:text-red-800"
                  @click="deleteUser(user?.id)"
                >
                  Eliminar
                </button>
              </td>
            </tr>
          </tbody>
        </table>
        <p
          v-else-if="loading"
          class="p-4 text-gray-500"
        >
          Cargando usuarios…
        </p>
        <p
          v-else
          class="p-4 text-red-500"
        >
          {{ errorMsg }}
        </p>
      </div>

      <!-- Paginación -->
      <div
        v-if="lastPage > 1"
        class="mt-4 flex justify-between items-center"
      >
        <div class="text-sm text-gray-700">
          Mostrando {{ from }} - {{ to }} de {{ total }} usuarios
        </div>
        <div class="flex gap-2">
          <button
            v-for="page in pages"
            :key="page"
            :class="[
              'px-3 py-1 rounded',
              page === currentPage ? 'bg-blue-600 text-white' : 'bg-gray-200 hover:bg-gray-300'
            ]"
            @click="goToPage(page)"
          >
            {{ page }}
          </button>
        </div>
      </div>
    </div>

    <!-- Modal integrado -->
    <div
      v-if="modalOpen"
      class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50"
    >
      <div class="bg-white rounded-xl shadow-xl w-full max-w-2xl p-6">
        <h2 class="text-xl font-semibold mb-4">
          Editar Usuario
        </h2>

        <form @submit.prevent="submitModal">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700">Nombre</label>
              <input
                v-model="form.name"
                required
                class="mt-1 w-full border rounded-md px-3 py-2"
              >
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700">Email</label>
              <input
                v-model="form.email"
                type="email"
                required
                class="mt-1 w-full border rounded-md px-3 py-2"
              >
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700">Teléfono</label>
              <input
                v-model="form.phone"
                class="mt-1 w-full border rounded-md px-3 py-2"
              >
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700">Rol</label>
              <select
                v-model="form.role"
                class="mt-1 w-full border rounded-md px-3 py-2"
              >
                <option value="client">
                  Cliente
                </option>
                <option value="provider">
                  Proveedor
                </option>
                <option value="driver">
                  Conductor
                </option>
              </select>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700">Dirección</label>
              <input
                v-model="form.address"
                class="mt-1 w-full border rounded-md px-3 py-2"
              >
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700">Dirección Comercial</label>
              <input
                v-model="form.business_address"
                class="mt-1 w-full border rounded-md px-3 py-2"
              >
            </div>
            <div class="md:col-span-2">
              <label class="block text-sm font-medium text-gray-700">Categorías de Servicio</label>
              <input
                v-model="form.service_categories"
                placeholder="Separadas por coma"
                class="mt-1 w-full border rounded-md px-3 py-2"
              >
            </div>
            <div class="md:col-span-2">
              <label class="block text-sm font-medium text-gray-700">Área de Cobertura</label>
              <input
                v-model="form.coverage_area"
                class="mt-1 w-full border rounded-md px-3 py-2"
              >
            </div>
            <div class="md:col-span-2">
              <label class="block text-sm font-medium text-gray-700">Avatar</label>
              <input
                type="file"
                accept="image/*"
                class="mt-1"
                @change="onFileChange"
              >
              <img
                v-if="preview"
                :src="preview"
                class="mt-2 w-20 h-20 rounded object-cover"
              >
            </div>
          </div>

          <div class="mt-6 flex justify-end gap-3">
            <button
              type="button"
              class="px-4 py-2 bg-gray-200 rounded-md hover:bg-gray-300"
              @click="modalOpen = false"
            >
              Cancelar
            </button>
            <button
              type="submit"
              class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
            >
              Guardar
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue';
import api from '@/axios';

const users = ref([]);
const currentPage = ref(1);
const lastPage = ref(1);
const total = ref(0);
const from = ref(0);
const to = ref(0);
const loading = ref(true);
const errorMsg = ref('');

const filters = reactive({ search: '', role: '', active: '' });

const modalOpen = ref(false);
const form = ref({});
const preview = ref(null);
const file = ref(null);

const debounce = (fn, delay) => {
  let timeout;
  return (...args) => {
    clearTimeout(timeout);
    timeout = setTimeout(() => fn(...args), delay);
  };
};

const fetchUsers = async () => {
  loading.value = true;
  errorMsg.value = '';
  try {
    const params = {
      page: currentPage.value,
      search: filters.search,
      role: filters.role,
      active: filters.active
    };
    const { data } = await api.get('/admin/users', { params });
    users.value = Array.isArray(data?.data) ? data.data : [];
    currentPage.value = data?.current_page || 1;
    lastPage.value = data?.last_page || 1;
    total.value = data?.total || 0;
    from.value = data?.from || 0;
    to.value = data?.to || 0;
  } catch (e) {
    console.error('[fetchUsers] error', e);
    errorMsg.value = 'No se pudieron cargar los usuarios.';
    users.value = [];
  } finally {
    loading.value = false;
  }
};

const debouncedSearch = debounce(fetchUsers, 300);
const resetFilters = () => {
  Object.assign(filters, { search: '', role: '', active: '' });
  currentPage.value = 1;
  fetchUsers();
};
const goToPage = page => {
  currentPage.value = page;
  fetchUsers();
};

const openModal = user => {
  form.value = { ...user };
  preview.value = user?.avatar_url
    ? `http://localhost:8000/backend/public/uploads/avatars/${user.avatar_url}`
    : null;
  modalOpen.value = true;
};

const onFileChange = e => {
  file.value = e.target.files[0];
  preview.value = URL.createObjectURL(file.value);
};

const submitModal = async () => {
  const fd = new FormData();
  Object.keys(form.value).forEach(k => fd.append(k, form.value[k]));
  if (file.value) fd.append('avatar', file.value);

  await api.post(`/admin/users.php?id=${form.value.id}`, fd, {
    headers: { 'Content-Type': 'multipart/form-data' }
  });
  modalOpen.value = false;
  fetchUsers();
};

const deleteUser = async id => {
  if (!confirm('¿Eliminar este usuario?')) return;
  await api.delete(`/admin/users.php?id=${id}`);
  fetchUsers();
};

const avatarUrl = name =>
  name
    ? `http://localhost:8000/backend/public/uploads/avatars/${name}`
    : 'https://via.placeholder.com/40';

const pages = computed(() => {
  const totalPages = Number(lastPage.value) || 1;
  return Array.from({ length: totalPages }, (_, i) => i + 1);
});

onMounted(fetchUsers);
</script>

