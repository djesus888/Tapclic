<template>
  <div class="register-page">
    <div class="register-container">
      <!-- Header con diseño moderno -->
      <div class="register-header">
        <div class="logo-section">
          <div class="logo-icon">🚀</div>
          <div class="logo-text">
            <h1>Crear Cuenta</h1>
            <p>Únete a nuestra comunidad de servicios</p>
          </div>
        </div>
      </div>

      <!-- Formulario de Registro -->
      <div class="register-form">
        <form @submit.prevent="handleRegister" class="form-card">
          <!-- Nombre -->
          <div class="form-group">
            <label class="form-label">
              <span class="label-icon">👤</span>
              {{ $t('name') }}
            </label>
            <div class="input-group">
              <input
                v-model="form.name"
                type="text"
                required
                placeholder="Ingresa tu nombre completo"
                class="form-input"
              >
              <div class="input-icon">✓</div>
            </div>
          </div>

          <!-- Email -->
          <div class="form-group">
            <label class="form-label">
              <span class="label-icon">✉️</span>
              {{ $t('email') }}
            </label>
            <div class="input-group">
              <input
                v-model="form.email"
                type="email"
                required
                placeholder="ejemplo@correo.com"
                class="form-input"
              >
              <div class="input-icon">@</div>
            </div>
          </div>

          <!-- Teléfono -->
          <div class="form-group">
            <label class="form-label">
              <span class="label-icon">📱</span>
              {{ $t('phone') }}
            </label>
            <div class="input-group">
              <input
                v-model="form.phone"
                type="tel"
                required
                placeholder="+123 456 7890"
                class="form-input"
              >
              <div class="input-icon">📞</div>
            </div>
          </div>

          <!-- Contraseña -->
          <div class="form-group">
            <label class="form-label">
              <span class="label-icon">🔒</span>
              {{ $t('password') }}
            </label>
            <div class="input-group">
              <input
                v-model="form.password"
                :type="showPassword ? 'text' : 'password'"
                required
                placeholder="••••••••"
                class="form-input"
              >
              <div class="input-icon">🔐</div>
            </div>
          </div>

          <!-- Confirmar contraseña -->
          <div class="form-group">
            <label class="form-label">
              <span class="label-icon">✅</span>
              {{ $t('confirm_password') }}
            </label>
            <div class="input-group">
              <input
                v-model="form.confirmPassword"
                :type="showPassword ? 'text' : 'password'"
                required
                placeholder="••••••••"
                class="form-input"
              >
              <div class="input-icon">🔏</div>
            </div>
          </div>

          <!-- Mostrar contraseña -->
          <div class="form-group checkbox-group">
            <label class="checkbox-label">
              <input
                id="showPass"
                v-model="showPassword"
                type="checkbox"
                class="checkbox-input"
              >
              <span class="checkbox-custom"></span>
              <span class="checkbox-text">{{ $t('show_password') }}</span>
            </label>
          </div>

          <!-- Rol -->
          <div class="form-group">
            <label class="form-label">
              <span class="label-icon">🎯</span>
              {{ $t('role') }}
            </label>
            <div class="select-group">
              <select
                v-model="form.role"
                required
                class="form-select"
              >
                <option value="" disabled>
                  {{ $t('select_role') }}
                </option>
                <option value="user">
                  👤 {{ $t('client') }}
                </option>
                <option value="provider">
                  🛠️ {{ $t('provider') }}
                </option>
              </select>
              <div class="select-arrow">▼</div>
            </div>
          </div>

          <!-- Botón de registro -->
          <button
            type="submit"
            :disabled="auth.loading"
            class="register-button"
            :class="{ 'loading': auth.loading }"
          >
            <span v-if="!auth.loading" class="button-content">
              <span class="button-icon">🎉</span>
              {{ $t('register') }}
            </span>
            <span v-else class="button-content">
              <span class="spinner"></span>
              {{ $t('registering') }}
            </span>
          </button>

          <!-- Enlace a login -->
          <div class="login-link">
            <p>{{ $t('already_have_account') }}</p>
            <router-link
              to="/login"
              class="login-link-button"
            >
              <span class="link-icon">→</span>
              {{ $t('login') }}
            </router-link>
          </div>
        </form>

        <!-- Tarjeta informativa -->
        <div class="info-card">
          <div class="info-icon">💡</div>
          <h3>Beneficios de registrarte</h3>
          <ul class="benefits-list">
            <li>
              <span class="benefit-icon">⭐</span>
              <span>Acceso a servicios exclusivos</span>
            </li>
            <li>
              <span class="benefit-icon">🔒</span>
              <span>Protección de datos garantizada</span>
            </li>
            <li>
              <span class="benefit-icon">🚀</span>
              <span>Proceso de contratación rápido</span>
            </li>
            <li>
              <span class="benefit-icon">💬</span>
              <span>Soporte personalizado 24/7</span>
            </li>
          </ul>
          <div class="stats">
            <div class="stat-item">
              <h4>+500</h4>
              <p>Usuarios activos</p>
            </div>
            <div class="stat-item">
              <h4>+100</h4>
              <p>Proveedores</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast" :class="toast.type">
      {{ toast.message }}
    </div>
  </div>

  <!-- Footer legal -->
  <footer class="login-footer">
    <div class="footer-links">
      <a href="/page/terms" class="footer-link">Términos y Condiciones</a>
      <span class="footer-sep">·</span>
      <a href="/page/privacy" class="footer-link">Política de Privacidad</a>
    </div>
  </footer>
</template>

<script>
import { ref } from 'vue'
import { useAuthStore } from '@/stores/authStore'
import { useRouter } from 'vue-router'
import Swal from 'sweetalert2'

export default {
  setup() {
    const auth = useAuthStore()
    const router = useRouter()

    const form = ref({
      name: '',
      role: '',
      email: '',
      phone: '',
      password: '',
      confirmPassword: ''
    })

    const showPassword = ref(false)
    const toast = ref({
      show: false,
      message: '',
      type: 'success'
    })

    const handleRegister = async () => {
      if (form.value.password !== form.value.confirmPassword) {
        return Swal.fire({
          icon: 'warning',
          title: 'Contraseñas no coinciden',
          text: 'Por favor asegúrate de que ambas contraseñas sean iguales.',
        })
      }

      const credentials = {
        name: form.value.name,
        role: form.value.role,
        email: form.value.email,
        phone: form.value.phone,
        password: form.value.password
      }

      try {
        auth.loading = true
        const res = await auth.register(credentials)

        if (res.role === 'admin') {
          router.push('/dashboard/admin')
        } else if (res.role === 'provider') {
          router.push('/dashboard/provider')
        } else {
          router.push('/dashboard/user')
        }

      } catch (error) {
        const msg = error?.response?.data?.message || error?.response?.data?.error || 'Error al registrar. Intenta de nuevo.'

        if (msg.includes('correo') || msg.includes('email')) {
          Swal.fire('Correo existente', 'El correo electrónico ya está registrado.', 'warning')
        } else if (msg.includes('teléfono') || msg.includes('phone')) {
          Swal.fire('Teléfono existente', 'El número de teléfono ya está registrado.', 'warning')
        } else {
          Swal.fire('Error', msg, 'error')
        }

        console.error('Error de registro:', error?.response?.data)

      } finally {
        auth.loading = false
      }
    }

    return { form, handleRegister, auth, showPassword, toast }
  }
}
</script>

<style scoped>
.register-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
}

.register-container {
  width: 100%;
  max-width: 1200px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-radius: 30px;
  overflow: hidden;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  animation: slideUp 0.6s ease-out;
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.register-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 40px;
  border-bottom-left-radius: 50% 20%;
  border-bottom-right-radius: 50% 20%;
}

.logo-section {
  display: flex;
  align-items: center;
  gap: 20px;
  justify-content: center;
  text-align: center;
}

.logo-icon {
  font-size: 48px;
  animation: bounce 2s infinite;
}

@keyframes bounce {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-10px); }
}

.logo-text h1 {
  color: white;
  font-size: 2.5rem;
  margin-bottom: 8px;
  font-weight: 700;
}

.logo-text p {
  color: rgba(255, 255, 255, 0.9);
  font-size: 1.1rem;
}

.register-form {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 40px;
  padding: 40px;
}

@media (max-width: 900px) {
  .register-form {
    grid-template-columns: 1fr;
  }
}

.form-card {
  background: white;
  padding: 40px;
  border-radius: 20px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);
}

.form-group {
  margin-bottom: 30px;
}

.form-label {
  display: flex;
  align-items: center;
  gap: 10px;
  font-weight: 600;
  color: #2d3436;
  margin-bottom: 10px;
  font-size: 0.95rem;
}

.label-icon {
  font-size: 1.2rem;
}

.input-group {
  position: relative;
  display: flex;
  align-items: center;
}

.form-input {
  width: 100%;
  padding: 16px 20px 16px 50px;
  border: 2px solid #e0e0e0;
  border-radius: 12px;
  font-size: 16px;
  transition: all 0.3s;
  background: #f8f9fa;
}

.form-input:focus {
  outline: none;
  border-color: #667eea;
  background: white;
  box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.1);
}

.input-icon {
  position: absolute;
  left: 16px;
  color: #667eea;
  font-size: 1.2rem;
}

.checkbox-group {
  margin-top: 20px;
}

.checkbox-label {
  display: flex;
  align-items: center;
  cursor: pointer;
  user-select: none;
}

.checkbox-input {
  display: none;
}

.checkbox-custom {
  width: 22px;
  height: 22px;
  border: 2px solid #667eea;
  border-radius: 6px;
  margin-right: 12px;
  position: relative;
  transition: all 0.3s;
}

.checkbox-input:checked + .checkbox-custom {
  background: #667eea;
}

.checkbox-input:checked + .checkbox-custom::after {
  content: '✓';
  position: absolute;
  color: white;
  font-size: 14px;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
}

.checkbox-text {
  color: #2d3436;
  font-weight: 500;
}

.select-group {
  position: relative;
}

.form-select {
  width: 100%;
  padding: 16px 50px 16px 20px;
  border: 2px solid #e0e0e0;
  border-radius: 12px;
  font-size: 16px;
  background: #f8f9fa;
  appearance: none;
  cursor: pointer;
  transition: all 0.3s;
}

.form-select:focus {
  outline: none;
  border-color: #667eea;
  background: white;
  box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.1);
}

.select-arrow {
  position: absolute;
  right: 20px;
  top: 50%;
  transform: translateY(-50%);
  color: #667eea;
  pointer-events: none;
}

.register-button {
  width: 100%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 18px;
  border-radius: 12px;
  font-size: 18px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  margin-top: 20px;
  position: relative;
  overflow: hidden;
}

.register-button:hover:not(:disabled) {
  transform: translateY(-3px);
  box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
}

.register-button:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.register-button.loading {
  background: linear-gradient(135deg, #a8edea 0%, #fed6e3 100%);
}

.button-content {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
}

.button-icon {
  font-size: 1.2rem;
}

.spinner {
  width: 24px;
  height: 24px;
  border: 3px solid rgba(255, 255, 255, 0.3);
  border-top: 3px solid white;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.login-link {
  text-align: center;
  margin-top: 30px;
  padding-top: 30px;
  border-top: 1px solid #eee;
}

.login-link p {
  color: #636e72;
  margin-bottom: 12px;
}

.login-link-button {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  color: #667eea;
  font-weight: 600;
  text-decoration: none;
  padding: 10px 20px;
  border: 2px solid #667eea;
  border-radius: 8px;
  transition: all 0.3s;
}

.login-link-button:hover {
  background: #667eea;
  color: white;
  transform: translateX(5px);
}

.link-icon {
  transition: transform 0.3s;
}

.login-link-button:hover .link-icon {
  transform: translateX(3px);
}

.info-card {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 40px;
  border-radius: 20px;
  color: white;
  display: flex;
  flex-direction: column;
}

.info-icon {
  font-size: 48px;
  margin-bottom: 20px;
  text-align: center;
}

.info-card h3 {
  font-size: 1.8rem;
  margin-bottom: 30px;
  text-align: center;
}

.benefits-list {
  list-style: none;
  margin-bottom: 40px;
}

.benefits-list li {
  display: flex;
  align-items: center;
  gap: 15px;
  margin-bottom: 20px;
  padding: 15px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 10px;
  transition: transform 0.3s;
}

.benefits-list li:hover {
  transform: translateX(10px);
  background: rgba(255, 255, 255, 0.2);
}

.benefit-icon {
  font-size: 1.5rem;
  min-width: 30px;
}

.benefits-list li span:last-child {
  font-size: 1rem;
  opacity: 0.9;
}

.stats {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
  margin-top: auto;
}

.stat-item {
  background: rgba(255, 255, 255, 0.1);
  padding: 20px;
  border-radius: 12px;
  text-align: center;
  transition: transform 0.3s;
}

.stat-item:hover {
  transform: translateY(-5px);
  background: rgba(255, 255, 255, 0.2);
}

.stat-item h4 {
  font-size: 2rem;
  margin-bottom: 5px;
  font-weight: 700;
}

.stat-item p {
  font-size: 0.9rem;
  opacity: 0.8;
}

.toast {
  position: fixed;
  bottom: 24px;
  right: 24px;
  padding: 16px 24px;
  border-radius: 10px;
  color: white;
  font-weight: 600;
  z-index: 1001;
  animation: slideIn 0.3s ease-out;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
}

.toast.success {
  background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
}

.toast.error {
  background: linear-gradient(135deg, #ff7675 0%, #d63031 100%);
}

.toast.info {
  background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%);
}

@keyframes slideIn {
  from {
    transform: translateX(100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

/* Responsive Design */
@media (max-width: 768px) {
  .register-container {
    border-radius: 20px;
  }
  
  .register-header {
    padding: 30px 20px;
  }
  
  .logo-section {
    flex-direction: column;
    text-align: center;
    gap: 15px;
  }
  
  .logo-text h1 {
    font-size: 2rem;
  }
  
  .register-form {
    padding: 20px;
    gap: 20px;
  }
  
  .form-card,
  .info-card {
    padding: 30px 20px;
  }
  
  .stats {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 480px) {
  .register-page {
    padding: 10px;
  }
  
  .form-input,
  .form-select {
    padding: 14px 14px 14px 45px;
  }

.login-footer {
  text-align: center;
  padding: 16px 24px;
  margin-top: 24px;
  border-top: 1px solid #e2e8f0;
}

.footer-links {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 8px;
}

.footer-link {
  color: #94a3b8;
  text-decoration: none;
  font-size: 12px;
  transition: color 0.2s;
}

.footer-link:hover {
  color: #667eea;
  text-decoration: underline;
}

.footer-sep {
  color: #cbd5e1;
  font-size: 12px;
}
  
  .input-icon {
    left: 14px;
  }
  
  .benefits-list li {
    padding: 12px;
  }
}
</style>
