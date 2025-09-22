<template>
  <div class="max-w-3xl mx-auto p-6 bg-white rounded-xl shadow-lg mt-8">
    <h2 class="text-3xl font-bold text-gray-800 mb-6 border-b pb-2">
      {{ $t('services.createTitle') }}
    </h2>

    <form @submit.prevent="createService" class="space-y-6">
      <!-- Título -->
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">
          {{ $t('services.title') }} *
        </label>
        <input
          v-model="form.title"
          type="text"
          required
          maxlength="50"
          :placeholder="$t('services.titlePlaceholder')"
          class="w-full border border-gray-300 rounded-md shadow-sm p-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
        <p class="text-right text-xs text-gray-500">{{ form.title.length }}/50</p>
      </div>

      <!-- Descripción -->
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">
          {{ $t('services.description') }} *
        </label>
        <textarea
          v-model="form.description"
          rows="4"
          required
          maxlength="250"
          :placeholder="$t('services.descriptionPlaceholder')"
          class="w-full border border-gray-300 rounded-md shadow-sm p-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
        ></textarea>
        <p class="text-right text-xs text-gray-500">{{ form.description.length }}/250</p>
      </div>

      <!-- Detalles del servicio / Service details -->
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">
          {{ $t('services.serviceDetails') }}
        </label>
        <textarea
          v-model="form.service_details"
          rows="4"
          maxlength="1000"
          :placeholder="$t('services.serviceDetailsPlaceholder')"
          class="w-full border border-gray-300 rounded-md shadow-sm p-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
        ></textarea>
        <p class="text-right text-xs text-gray-500">{{ form.service_details?.length || 0 }}/1000</p>
      </div>

      <!-- Precio (solo entero) -->
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">
          {{ $t('services.price') }} *
        </label>
        <input
          v-model.number="form.price"
          type="number"
          step="1"
          min="0"
          required
          :placeholder="$t('services.pricePlaceholder')"
          class="w-full border border-gray-300 rounded-md shadow-sm p-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
        <p class="text-xs text-gray-500 mt-1">{{ $t('services.priceHint') }}</p>
      </div>

      <!-- Categoría -->
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">
          {{ $t('services.category') }} *
        </label>
        <input
          v-model="form.category"
          type="text"
          required
          maxlength="30"
          :placeholder="$t('services.categoryPlaceholder')"
          class="w-full border border-gray-300 rounded-md shadow-sm p-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
        <p class="text-right text-xs text-gray-500">{{ form.category.length }}/30</p>
      </div>

      <!-- Ubicación -->
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">
          {{ $t('services.location') }} *
        </label>
        <input
          v-model="form.location"
          type="text"
          required
          maxlength="50"
          :placeholder="$t('services.locationPlaceholder')"
          class="w-full border border-gray-300 rounded-md shadow-sm p-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
        <p class="text-right text-xs text-gray-500">{{ form.location.length }}/50</p>
      </div>

      <!-- Imagen con vista previa -->
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-2">
          {{ $t('services.image') }}
        </label>

        <div v-if="previewUrl" class="mb-3">
          <img
            :src="previewUrl"
            alt="Vista previa"
            class="w-full max-h-64 object-cover rounded-md border"
          />
        </div>

        <label
          class="cursor-pointer inline-flex items-center px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition"
        >
          <svg
            class="w-5 h-5 mr-2"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              d="M12 4v16m8-8H4"
            />
          </svg>
          {{ imageFile ? imageFile.name : $t('services.selectImage') }}
          <input
            type="file"
            accept="image/*"
            @change="onImageChange"
            class="hidden"
          />
        </label>

        <button
          v-if="imageFile"
          type="button"
          @click="removeImage"
          class="ml-2 text-sm text-red-600 hover:underline"
        >
          {{ $t('services.removeImage') }}
        </button>
      </div>

      <!-- Botón Crear -->
      <div>
        <button
          type="submit"
          :disabled="!canSubmit"
          :class="[
            'w-full py-3 rounded-md font-semibold transition',
            canSubmit
              ? 'bg-green-600 text-white hover:bg-green-700'
              : 'bg-gray-400 text-white cursor-not-allowed'
          ]"
        >
          <span v-if="loading">{{ $t('services.creating') }}</span>
          <span v-else>{{ $t('services.create') }}</span>
        </button>
        <p v-if="!canSubmit && !loading" class="text-xs text-red-500 mt-2 text-center">
          {{ $t('services.formIncomplete') }}
        </p>
      </div>
    </form>
  </div>
</template>

<script>
import { ref, computed } from 'vue'
import api from '@/axios'
import Swal from 'sweetalert2'
import { useAuthStore } from '@/stores/authStore'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'

export default {
  name: 'CreateService',
  setup() {
    const authStore = useAuthStore()
    const { t } = useI18n()
    const router = useRouter()

    const form = ref({
      title: '',
      description: '',
      service_details: '', // <-- nuevo campo
      price: null,
      category: '',
      location: '',
    })

    const imageFile = ref(null)
    const previewUrl = ref(null)
    const loading = ref(false)

    const canSubmit = computed(() =>
      form.value.title.trim() &&
      form.value.description.trim() &&
      Number.isInteger(form.value.price) &&
      form.value.price >= 0 &&
      form.value.category.trim() &&
      form.value.location.trim()
    )

    const onImageChange = (e) => {
      const file = e.target.files[0]
      if (file) {
        imageFile.value = file
        previewUrl.value = URL.createObjectURL(file)
      }
    }

    const removeImage = () => {
      imageFile.value = null
      previewUrl.value = null
    }

    const createService = async () => {
      loading.value = true

      try {
        const formData = new FormData()
        formData.append('title', form.value.title.trim())
        formData.append('description', form.value.description.trim())
        formData.append('service_details', form.value.service_details.trim())
        formData.append('price', form.value.price)
        formData.append('category', form.value.category.trim())
        formData.append('location', form.value.location.trim())

        if (imageFile.value) {
          formData.append('image', imageFile.value)
        }

        console.log('Token:', authStore.token)
        for (let pair of formData.entries()) {
          console.log(pair[0], pair[1])
        }

        await api.post('/services', formData, {
          headers: {
            Authorization: `Bearer ${authStore.token}`,
            'Content-Type': 'multipart/form-data',
          },
        })

        Swal.fire(t('services.successTitle'), t('services.successMessage'), 'success')
        router.push('/services')
      } catch (err) {
        const message = err.response?.data?.error || t('services.createFailed')
        Swal.fire(t('services.error'), message, 'error')
      } finally {
        loading.value = false
      }
    }

    return {
      form,
      imageFile,
      previewUrl,
      loading,
      canSubmit,
      onImageChange,
      removeImage,
      createService,
    }
  },
}
</script>
