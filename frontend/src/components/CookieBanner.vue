<template>
  <Transition name="cookie-slide">
    <div v-if="show" class="cookie-banner">
      <div class="cookie-content">
        <div class="cookie-icon">🍪</div>
        <div class="cookie-text">
          <p><strong>Este sitio usa cookies</strong></p>
          <p>Utilizamos cookies propias y de terceros para mejorar tu experiencia, mostrar contenido personalizado y analizar el tráfico. Al hacer clic en "Aceptar", consientes el uso de todas las cookies.</p>
          <div class="cookie-links">
            <router-link to="/page/privacy" class="cookie-link">Política de Privacidad</router-link>
            <router-link to="/page/terms" class="cookie-link">Términos y Condiciones</router-link>
          </div>
        </div>
      </div>
      <div class="cookie-actions">
        <button @click="reject" class="btn-cookie-reject">Solo esenciales</button>
        <button @click="accept" class="btn-cookie-accept">Aceptar todas</button>
      </div>
    </div>
  </Transition>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const show = ref(false)

onMounted(() => {
  const accepted = localStorage.getItem('cookies_accepted')
  if (!accepted) {
    setTimeout(() => { show.value = true }, 1000)
  }
})

const accept = () => {
  localStorage.setItem('cookies_accepted', 'all')
  show.value = false
}

const reject = () => {
  localStorage.setItem('cookies_accepted', 'essential')
  show.value = false
}
</script>

<style scoped>
.cookie-banner {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: rgba(255, 255, 255, 0.98);
  backdrop-filter: blur(10px);
  border-top: 2px solid #667eea;
  padding: 16px 24px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 20px;
  z-index: 9998;
  box-shadow: 0 -4px 20px rgba(0, 0, 0, 0.1);
  flex-wrap: wrap;
}

.cookie-content {
  display: flex;
  align-items: flex-start;
  gap: 14px;
  flex: 1;
  min-width: 280px;
}

.cookie-icon {
  font-size: 2rem;
  flex-shrink: 0;
}

.cookie-text p {
  margin: 0 0 6px;
  font-size: 0.9rem;
  color: #636e72;
  line-height: 1.5;
}

.cookie-text strong {
  color: #2d3436;
  font-size: 1rem;
}

.cookie-links {
  display: flex;
  gap: 16px;
  margin-top: 4px;
}

.cookie-link {
  color: #667eea;
  text-decoration: none;
  font-size: 0.85rem;
  font-weight: 600;
}

.cookie-link:hover {
  text-decoration: underline;
}

.cookie-actions {
  display: flex;
  gap: 10px;
  flex-shrink: 0;
}

.btn-cookie-reject {
  padding: 10px 20px;
  background: #f1f2f6;
  border: 1px solid #dfe6e9;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  color: #636e72;
  font-size: 0.9rem;
  transition: all 0.3s;
}

.btn-cookie-reject:hover {
  background: #e2e8f0;
}

.btn-cookie-accept {
  padding: 10px 24px;
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  font-size: 0.9rem;
  transition: all 0.3s;
}

.btn-cookie-accept:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 15px rgba(102, 126, 234, 0.3);
}

/* Animación */
.cookie-slide-enter-active {
  transition: all 0.5s cubic-bezier(0.4, 0, 0.2, 1);
}

.cookie-slide-leave-active {
  transition: all 0.3s ease;
}

.cookie-slide-enter-from,
.cookie-slide-leave-to {
  transform: translateY(100%);
  opacity: 0;
}

@media (max-width: 600px) {
  .cookie-banner {
    flex-direction: column;
    padding: 16px;
  }
  .cookie-actions {
    width: 100%;
  }
  .btn-cookie-accept,
  .btn-cookie-reject {
    flex: 1;
    text-align: center;
  }
}
</style>
