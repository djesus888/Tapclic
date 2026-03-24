// stores/favoritesStore.js
import { defineStore } from 'pinia'
import { ref } from 'vue'
import api from '@/axios'

export const useFavoritesStore = defineStore('favorites', () => {
  const favorites = ref([])
  const loading = ref(false)
  const error = ref(null)

  const fetchFavorites = async () => {
    loading.value = true
    error.value = null
    try {
      const response = await api.get('/favorites')
      favorites.value = response.data
      return favorites.value
    } catch (err) {
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }

  const addToFavorites = async (serviceId) => {
    try {
      const response = await api.post('/favorites', { serviceId })
      favorites.value.push(response.data)
      return response.data
    } catch (err) {
      error.value = err.message
      throw err
    }
  }

  const removeFromFavorites = async (serviceId) => {
    try {
      await api.delete(`/favorites/${serviceId}`)
      favorites.value = favorites.value.filter(fav => fav.serviceId !== serviceId)
    } catch (err) {
      error.value = err.message
      throw err
    }
  }

  const clearAllFavorites = async () => {
    try {
      await api.delete('/favorites')
      favorites.value = []
    } catch (err) {
      error.value = err.message
      throw err
    }
  }

  const isFavorite = (serviceId) => {
    return favorites.value.some(fav => fav.serviceId === serviceId)
  }

  return {
    favorites,
    loading,
    error,
    fetchFavorites,
    addToFavorites,
    removeFromFavorites,
    clearAllFavorites,
    isFavorite
  }
})
