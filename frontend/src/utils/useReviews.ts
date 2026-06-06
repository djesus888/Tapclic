// src/utils/useReviews.ts
import { ref, computed, type Ref } from 'vue'

export interface Review {
  id: string | number
  user_avatar?: string
  user_name?: string
  provider_name?: string
  provider_avatar?: string
  service_title: string
  rating: number
  comment?: string
  created_at: string
  is_verified?: boolean
  photos?: string[] | string
  tags?: string[] | string
  helpful_count?: number
  provider_reply?: { message: string; createdAt: string } | null
  user_reply?: { message: string; createdAt: string } | null
  review_type?: 'service' | 'user'
  type?: string
  user_id?: number
  provider_id?: number
  service_history_id?: number
}

export function useReviews(raw: Ref<Review[]>) {
  const filters = ref({
    stars: [] as number[],
    verified: false,
    withPhoto: false,
    sort: 'newest' as 'newest' | 'oldest' | 'highest' | 'lowest'
  })

  const filtered = computed(() => {
    // Salida temprana si no hay datos
    if (!raw.value || !Array.isArray(raw.value)) return []

    let list = raw.value.slice()

    // 1) Filtro por estrellas
    if (filters.value.stars.length) {
      list = list.filter(r => filters.value.stars.includes(r.rating))
    }

    // 2) Solo verificadas
    if (filters.value.verified) {
      list = list.filter(r => r.is_verified)
    }

    // 3) Solo con foto
    if (filters.value.withPhoto) {
      list = list.filter(r => {
        const photos = r.photos
        if (!photos) return false
        if (Array.isArray(photos)) return photos.length > 0
        if (typeof photos === 'string') {
          try {
            const parsed = JSON.parse(photos)
            return Array.isArray(parsed) && parsed.length > 0
          } catch {
            return photos.length > 0
          }
        }
        return false
      })
    }

    // 4) Orden
    switch (filters.value.sort) {
      case 'oldest':
        list.sort((a, b) => +new Date(a.created_at) - +new Date(b.created_at))
        break
      case 'highest':
        list.sort((a, b) => b.rating - a.rating)
        break
      case 'lowest':
        list.sort((a, b) => a.rating - b.rating)
        break
      default:
        list.sort((a, b) => +new Date(b.created_at) - +new Date(a.created_at))
    }

    return list
  })

  return { filters, filtered }
}
