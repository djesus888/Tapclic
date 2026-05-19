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
        console.log('🔥 fetchConfig: iniciando llamada al backend')
        const res = await api.get('/system/config', { timeout: 5000 })
        this.config = res.data.config || res.data
        console.log('✅ fetchConfig: datos cargados', this.config)
        return res.data
      } catch (err) {
        console.error('❌ Error cargando configuración del sistema:', err)
        this.error = err
        return null
      } finally {
        this.loading = false
      }
    }
  },

  getters: {
    systemName: (state) => state.config?.system_name || 'Mi Sistema',
    systemHost: (state) => state.config?.system_host || 'localhost',
    systemActive: (state) => state.config?.system_active == 1,
    themeColor: (state) => state.config?.theme_color || '#1E90FF',
    
    // ✅ Features del sistema
    walletEnabled: (state) => state.config?.wallet_enabled == 1,
    reviewsEnabled: (state) => state.config?.reviews_enabled == 1,
    chatEnabled: (state) => state.config?.chat_enabled == 1,
    ticketsEnabled: (state) => state.config?.tickets_enabled == 1,
    analyticsEnabled: (state) => state.config?.analytics_enabled == 1,
    
    // ✅ Estados generales
    maintenanceMode: (state) => state.config?.maintenance_mode == 1,
    registrationAllowed: (state) => state.config?.allow_user_registration == 1,
    currency: (state) => state.config?.currency || 'USD',
    defaultLanguage: (state) => state.config?.default_language || 'es',
    supportEmail: (state) => state.config?.support_email || '',
    supportPhone: (state) => state.config?.support_phone || '',
    itemsPerPage: (state) => parseInt(state.config?.items_per_page) || 20,
  }
})
