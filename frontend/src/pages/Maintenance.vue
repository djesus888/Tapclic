<template>
  <div class="maintenance-page">
    <div class="maintenance-card">
      <div class="maintenance-icon">🔧</div>
      <h1 class="maintenance-title">Sistema en Mantenimiento</h1>
      <p class="maintenance-text">
        Estamos realizando mejoras en la plataforma para brindarte un mejor servicio.
      </p>
      <p class="maintenance-subtext">
        Por favor, vuelve en unos minutos. Si eres administrador, 
        <router-link to="/login" class="admin-link">inicia sesión aquí</router-link>.
      </p>
      <div class="maintenance-loader">
        <span class="loader-dot"></span>
        <span class="loader-dot"></span>
        <span class="loader-dot"></span>
      </div>
    </div>
  </div>
</template>

<script setup>
// Página estática de mantenimiento
</script>

<style scoped>
.maintenance-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
}

.maintenance-card {
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

.maintenance-icon {
  font-size: 80px;
  animation: wrench 2s ease-in-out infinite;
}

@keyframes wrench {
  0%, 100% { transform: rotate(0); }
  25% { transform: rotate(-15deg); }
  75% { transform: rotate(15deg); }
}

.maintenance-title {
  font-size: 2rem;
  font-weight: 800;
  color: #2d3436;
  margin: 24px 0 12px;
}

.maintenance-text {
  color: #636e72;
  font-size: 1.1rem;
  line-height: 1.6;
  margin-bottom: 12px;
}

.maintenance-subtext {
  color: #b2bec3;
  font-size: 0.9rem;
  margin-bottom: 32px;
}

.admin-link {
  color: #667eea;
  font-weight: 600;
  text-decoration: none;
}

.admin-link:hover {
  text-decoration: underline;
}

.maintenance-loader {
  display: flex;
  gap: 8px;
  justify-content: center;
}

.loader-dot {
  width: 10px;
  height: 10px;
  background: #667eea;
  border-radius: 50%;
  animation: dotPulse 1.4s infinite both;
}

.loader-dot:nth-child(2) { animation-delay: 0.2s; }
.loader-dot:nth-child(3) { animation-delay: 0.4s; }

@keyframes dotPulse {
  0%, 80%, 100% { transform: scale(0.6); opacity: 0.4; }
  40% { transform: scale(1); opacity: 1; }
}
</style>
