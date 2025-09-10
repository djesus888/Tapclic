<template>
  <div class="max-w-6xl mx-auto p-4">
    <h1 class="text-3xl font-bold mb-6">{{ $t('services.myServices') }}</h1>

    <router-link
      to="/services/new"
      class="mb-6 inline-block bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
    >
      {{ $t('services.createNew') }}
    </router-link>

    <div v-if="services.length" class="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
      <div
        v-for="s in services"
        :key="s.id"
        class="border rounded-lg p-4 hover:shadow-lg cursor-pointer"
        @click="openEditModal(s)"
      >
        <img
          v-if="s.image_url"
          :src="s.image_url"
          :alt="$t('services.image')"
          class="w-full h-40 object-cover rounded mb-2"
        />
        <h2 class="text-xl font-semibold">{{ s.title }}</h2>
        <p class="text-gray-600">{{ s.description.slice(0, 60) }}...</p>
        <p class="text-green-600 font-bold mt-1">${{ s.price }}</p>
        <p class="text-sm text-gray-500">{{ s.category }} · {{ s.location }}</p>

        <button
          class="mt-3 text-sm text-red-600 hover:underline"
          @click.stop="deleteService(s.id)"
        >
          {{ $t('services.delete') }}
        </button>
      </div>
    </div>

    <div v-else class="text-center text-gray-500">
      {{ $t('services.noServices') }}
    </div>

    <!-- Modal Edición -->
    <div
      v-if="showModal"
      class="fixed inset-0 bg-black/50 flex items-center justify-center z-50"
      @click.self="closeEditModal"
    >
      <div class="bg-white dark:bg-gray-800 rounded-xl p-6 w-full max-w-lg max-h-[90vh] overflow-y-auto">
        <h2 class="text-2xl font-bold mb-4 text-gray-800 dark:text-gray-100">
          {{ $t('services.editService') }}
        </h2>

        <form @submit.prevent="updateService" class="space-y-4">
          <label class="block">
            <span class="text-sm font-medium text-gray-700 dark:text-gray-300">{{ $t('services.title') }}</span>
            <input v-model="form.title" class="w-full border rounded p-2 dark:bg-gray-700 dark:border-gray-600" />
          </label>

          <label class="block">
            <span class="text-sm font-medium text-gray-700 dark:text-gray-300">{{ $t('services.description') }}</span>
            <textarea v-model="form.description" rows="3" class="w-full border rounded p-2 dark:bg-gray-700 dark:border-gray-600"></textarea>
          </label>

          <label class="block">
            <span class="text-sm font-medium text-gray-700 dark:text-gray-300">{{ $t('services.price') }}</span>
            <input v-model.number="form.price" type="number" class="w-full border rounded p-2 dark:bg-gray-700 dark:border-gray-600" />
          </label>

          <label class="block">
            <span class="text-sm font-medium text-gray-700 dark:text-gray-300">{{ $t('services.category') }}</span>
            <input v-model="form.category" class="w-full border rounded p-2 dark:bg-gray-700 dark:border-gray-600" />
          </label>

          <label class="block">
            <span class="text-sm font-medium text-gray-700 dark:text-gray-300">{{ $t('services.location') }}</span>
            <input v-model="form.location" class="w-full border rounded p-2 dark:bg-gray-700 dark:border-gray-600" />
          </label>

          <!--  >>>  Selector de imagen profesional  <<<  -->
          <label class="block">
            <span class="text-sm font-medium text-gray-700 dark:text-gray-300 mb-2 block">
              {{ $t('services.imageOptional') }}
            </span>

            <!-- Preview + botón cambiar -->
            <div v-if="previewImage" class="flex items-end gap-4 mb-3">
              <img
                :src="previewImage"
                alt="Preview"
                class="w-24 h-24 rounded-xl object-cover shadow"
              />
              <button
                type="button"
                @click="triggerFilePicker"
                class="px-3 py-2 rounded-lg bg-gray-100 dark:bg-gray-700 text-sm text-gray-700 dark:text-gray-200 hover:bg-gray-200 dark:hover:bg-gray-600"
              >
                Cambiar
              </button>
            </div>

            <!-- Drop zone / botón principal -->
            <div
              v-if="!previewImage"
              @drop.prevent="handleDrop"
              @dragover.prevent
              class="border-2 border-dashed border-gray-300 dark:border-gray-600 rounded-xl p-6 text-center cursor-pointer hover:border-blue-500 dark:hover:border-blue-400 transition"
              @click="triggerFilePicker"
            >
              <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                      d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
              </svg>
              <p class="mt-2 text-sm text-gray-500 dark:text-gray-400">
                Arrastra una imagen o <span class="text-blue-600 dark:text-blue-400 font-medium">haz clic aquí</span>
              </p>
              <p class="text-xs text-gray-400">PNG, JPG hasta 2 MB</p>
            </div>

            <!-- Input oculto -->
            <input
              ref="fileInput"
              type="file"
              accept="image/*"
              class="hidden"
              @change="onImageChange"
            />
          </label>

          <div class="flex justify-end space-x-3">
            <button
              type="button"
              class="px-4 py-2 bg-gray-300 dark:bg-gray-600 text-gray-800 dark:text-gray-100 rounded hover:bg-gray-400 dark:hover:bg-gray-500"
              @click="closeEditModal"
            >
              {{ $t('common.cancel') }}
            </button>
            <button
              type="submit"
              class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
            >
              {{ $t('common.save') }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>


<script setup>
import { ref, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'
import api from '@/axio'
import { useAuthStore } from '@/stores/authStore'
import Swal from 'sweetalert2'

const { t } = useI18n()
const authStore = useAuthStore()
const services = ref([])
const showModal = ref(false)

const form = ref({
  id: null,
  title: '',
  description: '',
  price: 0,
  category: '',
  location: '',
  image: null
})

const previewImage = ref('')

/* ----------  Cargar servicios  ---------- */
const loadServices = async () => {
  try {
    const { data } = await api.get('/services/mine', {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    services.value = data
  } catch (err) {
    Swal.fire(
      t('common.error'),
      err.response?.data?.error || t('services.loadError'),
      'error'
    )
  }
}

/* ----------  Eliminar servicio  ---------- */
const deleteService = async (id) => {
  const confirm = await Swal.fire({
    title: t('services.confirmDeleteTitle'),
    text: t('services.confirmDeleteText'),
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#d33',
    cancelButtonColor: '#6b7280',
    confirmButtonText: t('common.yes')
  })
  if (!confirm.isConfirmed) return

  try {
    await api.post('/services/delete', { id }, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    Swal.fire(t('common.success'), t('services.deleted'), 'success')
    loadServices()
  } catch (err) {
    Swal.fire(
      t('common.error'),
      err.response?.data?.error || t('services.deleteError'),
      'error'
    )
  }
}

/* ----------  Modal Editar  ---------- */
const openEditModal = (service) => {
  form.value = { ...service, image: null }
  previewImage.value = service.image_url || ''
  showModal.value = true
}

const closeEditModal = () => {
  showModal.value = false
  form.value = { id: null, title: '', description: '', price: 0, category: '', location: '', image: null }
  previewImage.value = ''
}

const onImageChange = (e) => {
  const file = e.target.files[0]
  if (file) {
    form.value.image = file
    previewImage.value = URL.createObjectURL(file)
  }
}

const updateService = async () => {
  const formData = new FormData()
  Object.entries(form.value).forEach(([k, v]) => formData.append(k, v))

  try {
    await api.post('/services/update', formData, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    Swal.fire(t('common.success'), t('services.updated'), 'success')
    closeEditModal()
    loadServices()
  } catch (err) {
    Swal.fire(
      t('common.error'),
      err.response?.data?.error || t('services.updateError'),
      'error'
    )
  }
}

onMounted(loadServices)
</script>
