<template>
  <div class="error-page">
    <div class="error-card">
      <div class="error-icon">🔧</div>
      <h1 class="error-code">500</h1>
      <h2 class="error-title">Error del servidor</h2>
      <p class="error-text">
        Algo salió mal en nuestro servidor. Estamos trabajando para solucionarlo.
      </p>
      <p class="error-subtext">
        Por favor, intenta de nuevo en unos minutos.
      </p>
      <div class="error-actions">
        <router-link to="/" class="btn-home">🏠 Volver al inicio</router-link>
        <button @click="retry" class="btn-retry">🔄 Reintentar</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
const router = useRouter()
const retry = () => router.go(0)
</script>

<style scoped>
.error-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
}

.error-card {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 24px;
  padding: 48px 40px;
  text-align: center;
  max-width: 500px;
  width: 100%;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.2);
  animation: slideUp 0.6s ease-out;
}

@keyframes slideUp {
  from { opacity: 0; transform: translateY(30px); }
  to { opacity: 1; transform: translateY(0); }
}

.error-icon {
  font-size: 80px;
  animation: wrench 2s ease-in-out infinite;
}

@keyframes wrench {
  0%, 100% { transform: rotate(0); }
  25% { transform: rotate(-15deg); }
  75% { transform: rotate(15deg); }
}

.error-code {
  font-size: 6rem;
  font-weight: 900;
  background: linear-gradient(135deg, #667eea, #764ba2);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  margin: 16px 0;
  line-height: 1;
}

.error-title {
  font-size: 1.8rem;
  font-weight: 800;
  color: #2d3436;
  margin-bottom: 12px;
}

.error-text {
  color: #636e72;
  font-size: 1.1rem;
  line-height: 1.6;
  margin-bottom: 8px;
}

.error-subtext {
  color: #b2bec3;
  font-size: 0.9rem;
  margin-bottom: 32px;
}

.error-actions {
  display: flex;
  gap: 12px;
  justify-content: center;
  flex-wrap: wrap;
}

.btn-home {
  padding: 14px 28px;
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
  text-decoration: none;
  border-radius: 10px;
  font-weight: 600;
  transition: all 0.3s;
}

.btn-home:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 20px rgba(102, 126, 234, 0.3);
}

.btn-retry {
  padding: 14px 28px;
  background: white;
  color: #667eea;
  border: 2px solid #667eea;
  border-radius: 10px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s;
}

.btn-retry:hover {
  background: #f8f9ff;
  transform: translateY(-2px);
}

@media (max-width: 480px) {
  .error-card {
    padding: 32px 20px;
  }
  .error-code {
    font-size: 4rem;
  }
  .error-actions {
    flex-direction: column;
  }
}
</style>
