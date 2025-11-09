import { defineStore } from 'pinia'
import api from '@/axios'

export const useSystemStore = defineStore('system', {
  state: () => ({
    config: null,
    loading: false,
    error: null,
  }),

  actions: {
    async fetchConfig() {
      this.loading = true
      this.error = null
      try {
        const res = await api.get('/system')
        this.config = res.data
      } catch (err) {
        console.error("Error cargando configuración del sistema:", err)
        this.error = err
      } finally {
        this.loading = false
      }
    }
  },

  getters: {
    systemName: (state) => state.config?.system_name || 'Mi Sistema',
    systemHost: (state) => state.config?.system_host || 'localhost',
    systemActive: (state) => state.config?.system_active === 1,
    themeColor: (state) => state.config?.theme_color || '#1E90FF',
  }
})
