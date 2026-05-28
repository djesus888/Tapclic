<template>
  <div class="static-page-wrapper">
    <!-- Header igual al de Login -->
    <header class="static-header">
      <div class="header-content">
        <div class="logo-section">
          <span class="logo-icon">✨</span>
          <h1 class="logo-text">TapClic</h1>
        </div>
        <div class="header-actions">
          <router-link to="/login" class="header-btn">Iniciar Sesión</router-link>
          <router-link to="/register" class="header-btn header-btn-primary">Registrarse</router-link>
        </div>
      </div>
    </header>

    <!-- Contenido principal -->
    <main class="static-main">
      <div v-if="loading" class="loading-container">
        <div class="spinner"></div>
        <p>Cargando...</p>
      </div>

      <div v-else-if="error" class="error-container">
        <div class="error-card">
          <span class="error-icon">😕</span>
          <h2>Página no encontrada</h2>
          <p>{{ error }}</p>
          <router-link to="/" class="back-btn">← Volver al inicio</router-link>
        </div>
      </div>

      <article v-else class="page-article">
        <div class="article-header">
          <h1 class="article-title">{{ page.title }}</h1>
          <div class="title-underline"></div>
        </div>
        <div class="article-body" v-html="page.content"></div>
      </article>
    </main>

    <!-- Footer -->
    <footer class="static-footer">
      <div class="footer-content">
        <div class="footer-links">
          <router-link to="/page/terms" class="footer-link">Términos</router-link>
          <span class="footer-sep">·</span>
          <router-link to="/page/privacy" class="footer-link">Privacidad</router-link>
          <span class="footer-sep">·</span>
          <router-link to="/page/about" class="footer-link">Acerca de</router-link>
          <span class="footer-sep">·</span>
          <router-link to="/page/help" class="footer-link">Ayuda</router-link>
          <span class="footer-sep">·</span>
          <router-link to="/page/contact" class="footer-link">Contacto</router-link>
        </div>
        <p class="footer-copy">© 2026 TapClic. Todos los derechos reservados.</p>
      </div>
    </footer>
  </div>
</template>

<script>
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
        const API_URL = import.meta.env.VITE_API_URL || 'http://192.168.206.12:8000/api'
        const res = await fetch(`${API_URL}/page/${slug}`)
        if (!res.ok) throw new Error('Página no encontrada')
        this.page = await res.json()
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
/* ========== WRAPPER ========== */
.static-page-wrapper {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
}

/* ========== HEADER ========== */
.static-header {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-bottom: 1px solid rgba(255, 255, 255, 0.2);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  position: sticky;
  top: 0;
  z-index: 100;
}

.header-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 16px 24px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.logo-section {
  display: flex;
  align-items: center;
  gap: 10px;
}

.logo-icon {
  font-size: 28px;
}

.logo-text {
  font-size: 24px;
  font-weight: 800;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  margin: 0;
}

.header-actions {
  display: flex;
  gap: 12px;
}

.header-btn {
  padding: 10px 20px;
  border-radius: 10px;
  text-decoration: none;
  font-weight: 600;
  font-size: 14px;
  transition: all 0.3s;
  color: #4a5568;
  border: 2px solid #e2e8f0;
}

.header-btn:hover {
  border-color: #667eea;
  color: #667eea;
}

.header-btn-primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
}

.header-btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
  color: white;
}

/* ========== MAIN CONTENT ========== */
.static-main {
  flex: 1;
  padding: 40px 24px;
  display: flex;
  justify-content: center;
}

/* ========== LOADING ========== */
.loading-container {
  text-align: center;
  color: white;
  padding: 80px 20px;
}

.spinner {
  width: 48px;
  height: 48px;
  border: 4px solid rgba(255, 255, 255, 0.3);
  border-top-color: white;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
  margin: 0 auto 16px;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* ========== ERROR ========== */
.error-container {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100%;
}

.error-card {
  background: white;
  border-radius: 20px;
  padding: 48px 32px;
  text-align: center;
  max-width: 480px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15);
}

.error-icon {
  font-size: 64px;
  display: block;
  margin-bottom: 16px;
}

.error-card h2 {
  color: #2d3436;
  margin-bottom: 8px;
  font-size: 24px;
}

.error-card p {
  color: #636e72;
  margin-bottom: 24px;
}

.back-btn {
  display: inline-block;
  padding: 12px 24px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  text-decoration: none;
  border-radius: 10px;
  font-weight: 600;
  transition: all 0.3s;
}

.back-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 20px rgba(102, 126, 234, 0.4);
}

/* ========== ARTICLE ========== */
.page-article {
  background: white;
  border-radius: 20px;
  padding: 48px 40px;
  max-width: 900px;
  width: 100%;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.1);
}

.article-header {
  margin-bottom: 32px;
  text-align: center;
}

.article-title {
  font-size: 2.2rem;
  font-weight: 800;
  color: #2d3436;
  margin: 0 0 12px 0;
}

.title-underline {
  width: 80px;
  height: 4px;
  background: linear-gradient(90deg, #667eea, #764ba2);
  border-radius: 2px;
  margin: 0 auto;
}

/* ========== ARTICLE BODY ========== */
.article-body {
  color: #4a5568;
  line-height: 1.8;
  font-size: 1.05rem;
}

.article-body :deep(h1) {
  font-size: 2rem;
  color: #2d3436;
  margin: 32px 0 16px;
  padding-bottom: 8px;
  border-bottom: 2px solid #e2e8f0;
}

.article-body :deep(h2) {
  font-size: 1.5rem;
  color: #2d3436;
  margin: 28px 0 12px;
}

.article-body :deep(h3) {
  font-size: 1.2rem;
  color: #4a5568;
  margin: 20px 0 10px;
}

.article-body :deep(p) {
  margin: 12px 0;
}

.article-body :deep(ul),
.article-body :deep(ol) {
  margin: 12px 0;
  padding-left: 24px;
}

.article-body :deep(li) {
  margin: 8px 0;
}

.article-body :deep(strong) {
  color: #2d3436;
}

/* ========== FOOTER ========== */
.static-footer {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-top: 1px solid rgba(255, 255, 255, 0.2);
  padding: 20px 24px;
}

.footer-content {
  max-width: 1200px;
  margin: 0 auto;
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 12px;
}

.footer-links {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.footer-link {
  color: #64748b;
  text-decoration: none;
  font-size: 13px;
  transition: color 0.2s;
}

.footer-link:hover {
  color: #667eea;
  text-decoration: underline;
}

.footer-sep {
  color: #cbd5e1;
  font-size: 13px;
}

.footer-copy {
  color: #94a3b8;
  font-size: 12px;
  margin: 0;
}

/* ========== RESPONSIVE ========== */
@media (max-width: 768px) {
  .page-article {
    padding: 32px 24px;
  }

  .article-title {
    font-size: 1.8rem;
  }

  .header-content {
    padding: 12px 16px;
  }

  .logo-text {
    font-size: 20px;
  }

  .header-btn {
    padding: 8px 14px;
    font-size: 13px;
  }

  .footer-content {
    flex-direction: column;
    text-align: center;
  }
}

@media (max-width: 480px) {
  .page-article {
    padding: 24px 16px;
  }

  .article-title {
    font-size: 1.5rem;
  }
}
</style>
