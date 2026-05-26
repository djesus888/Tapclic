<template>
  <div class="static-page-container">
    <div v-if="loading" class="loading-state">
      <div class="spinner"></div>
      <p>Cargando...</p>
    </div>

    <div v-else-if="error" class="error-state">
      <h2>😕 Página no encontrada</h2>
      <p>{{ error }}</p>
      <router-link to="/" class="back-link">← Volver al inicio</router-link>
    </div>

    <div v-else class="page-content">
      <h1 class="page-title">{{ page.title }}</h1>
      <div class="page-body" v-html="page.content"></div>
    </div>
  </div>
</template>

<script>
import axios from '../axios'

export default {
  name: 'StaticPage',
  data() {
    return {
      page: null,
      loading: true,
      error: null
    }
  },
  watch: {
    '$route.params.slug': {
      immediate: true,
      handler() {
        this.fetchPage()
      }
    }
  },
  methods: {
    async fetchPage() {
      this.loading = true
      this.error = null
      try {
        const slug = this.$route.params.slug
        const { data } = await axios.get(`/page/${slug}`)
        this.page = data
      } catch (err) {
        this.error = 'La página que buscas no existe o no está disponible.'
      } finally {
        this.loading = false
      }
    }
  }
}
</script>

<style scoped>
.static-page-container {
  max-width: 800px;
  margin: 2rem auto;
  padding: 1.5rem;
}

.loading-state {
  text-align: center;
  padding: 3rem;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #e0e0e0;
  border-top-color: #4a90d9;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
  margin: 0 auto 1rem;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.error-state {
  text-align: center;
  padding: 3rem;
}

.back-link {
  color: #4a90d9;
  text-decoration: none;
  font-weight: 500;
}

.page-title {
  font-size: 2rem;
  margin-bottom: 1.5rem;
  color: #1a1a1a;
}

.page-body {
  line-height: 1.8;
  color: #333;
}
</style>
