<template>
  <div class="not-found-container">
    <div class="not-found-content">
      <!-- Ilustración SVG -->
      <div class="illustration">
        <svg viewBox="0 0 400 200" xmlns="http://www.w3.org/2000/svg">
          <!-- Página rota -->
          <rect x="120" y="60" width="100" height="120" rx="5" fill="#f0f0f0" stroke="#667eea" stroke-width="2" transform="rotate(-10, 170, 120)"/>
          <rect x="130" y="70" width="80" height="8" rx="2" fill="#ddd" transform="rotate(-10, 170, 120)"/>
          <rect x="130" y="85" width="60" height="8" rx="2" fill="#ddd" transform="rotate(-10, 170, 120)"/>
          <rect x="130" y="100" width="70" height="8" rx="2" fill="#ddd" transform="rotate(-10, 170, 120)"/>
          <!-- Grieta -->
          <line x1="170" y1="100" x2="140" y2="160" stroke="#667eea" stroke-width="2" transform="rotate(-10, 170, 120)"/>
          
          <!-- Robot -->
          <rect x="260" y="80" width="50" height="60" rx="8" fill="#667eea"/>
          <rect x="270" y="60" width="30" height="25" rx="5" fill="#667eea"/>
          <!-- Ojos robot -->
          <circle cx="280" cy="72" r="4" fill="white"/>
          <circle cx="290" cy="72" r="4" fill="white"/>
          <!-- Antena -->
          <line x1="285" y1="60" x2="285" y2="45" stroke="#667eea" stroke-width="2"/>
          <circle cx="285" cy="42" r="4" fill="#ff6b6b"/>
          <!-- Brazos robot (signo de interrogación) -->
          <text x="240" y="100" font-size="20" fill="#667eea" font-weight="bold">?</text>
          <text x="315" y="100" font-size="20" fill="#667eea" font-weight="bold">?</text>
          
          <!-- Fantasma -->
          <g transform="translate(60, 50)">
            <ellipse cx="35" cy="40" rx="22" ry="30" fill="#a0a0ff" opacity="0.8"/>
            <ellipse cx="35" cy="65" rx="22" ry="8" fill="#a0a0ff" opacity="0.8"/>
            <circle cx="28" cy="38" r="4" fill="white"/>
            <circle cx="42" cy="38" r="4" fill="white"/>
            <circle cx="28" cy="39" r="2" fill="#333"/>
            <circle cx="42" cy="39" r="2" fill="#333"/>
            <ellipse cx="35" cy="48" rx="5" ry="3" fill="#333"/>
          </g>
          
          <!-- Signo 404 -->
          <text x="200" y="190" text-anchor="middle" font-size="16" fill="#999" font-weight="bold">404</text>
        </svg>
      </div>
      
      <h1 class="error-code">404</h1>
      <h2 class="error-title">¡Ups! Página no encontrada</h2>
      <p class="error-message">La página que buscas se ha perdido en el ciberespacio.</p>
      <router-link to="/" class="btn-home">
        <span class="btn-icon">🏠</span>
        Volver al inicio
      </router-link>
    </div>
  </div>
</template>

<script setup>
</script>

<style scoped>
.not-found-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 80vh;
  background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
}
.not-found-content {
  text-align: center;
  padding: 40px;
}
.illustration {
  margin-bottom: 20px;
  animation: float 3s ease-in-out infinite;
}
.illustration svg {
  width: 100%;
  max-width: 400px;
  height: auto;
}
.error-code {
  font-size: 6rem;
  font-weight: 700;
  background: linear-gradient(135deg, #667eea, #764ba2);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  margin: 0;
  line-height: 1;
}
.error-title {
  font-size: 1.8rem;
  color: #e0e0e0;
  margin: 10px 0;
}
.error-message {
  color: #aaa;
  margin: 10px 0 30px;
  font-size: 1.1rem;
}
.btn-home {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 14px 35px;
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
  border-radius: 50px;
  text-decoration: none;
  font-weight: 600;
  font-size: 1.1rem;
  transition: all 0.3s;
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
}
.btn-home:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.6);
}
.btn-icon {
  font-size: 1.2rem;
}

@keyframes float {
  0%, 100% { transform: translateY(0px); }
  50% { transform: translateY(-15px); }
}
</style>
