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
      <div class="bg-white rounded-xl p-6 w-full max-w-lg max-h-[90vh] overflow-y-auto">
        <h2 class="text-2xl font-bold mb-4">{{ $t('services.editService') }}</h2>

        <form @submit.prevent="updateService" class="space-y-4">
          <label class="block">
            <span class="text-sm font-medium">{{ $t('services.title') }}</span>
            <input v-model="form.title" class="w-full border rounded p-2" />
          </label>

          <label class="block">
            <span class="text-sm font-medium">{{ $t('services.description') }}</span>
            <textarea v-model="form.description" rows="3" class="w-full border rounded p-2"></textarea>
          </label>

          <label class="block">
            <span class="text-sm font-medium">{{ $t('services.price') }}</span>
            <input v-model.number="form.price" type="number" class="w-full border rounded p-2" />
          </label>

          <label class="block">
            <span class="text-sm font-medium">{{ $t('services.category') }}</span>
            <input v-model="form.category" class="w-full border rounded p-2" />
          </label>

          <label class="block">
            <span class="text-sm font-medium">{{ $t('services.location') }}</span>
            <input v-model="form.location" class="w-full border rounded p-2" />
          </label>

          <label class="block">
            <span class="text-sm font-medium">{{ $t('services.imageOptional') }}</span>
            <input
              type="file"
              accept="image/*"
              @change="onImageChange"
              class="w-full border rounded p-2"
            />
            <img
              v-if="previewImage"
              :src="previewImage"
              :alt="$t('services.preview')"
              class="mt-2 w-32 h-32 object-cover rounded"
            />
          </label>

          <div class="flex justify-end space-x-3">
            <button
              type="button"
              class="px-4 py-2 bg-gray-300 rounded hover:bg-gray-400"
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
    Swal.fire(
      t('common.success'),
      t('services.deleted'),
      'success'
    )
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
    Swal.fire(
      t('common.success'),
      t('services.updated'),
      'success'
    )
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
