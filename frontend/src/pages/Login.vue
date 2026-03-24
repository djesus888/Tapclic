<template>
  <div class="login-page">
    <!-- Barra superior con diseño mejorado -->
    <header class="login-header">
      <!-- Nombre del sistema con gradiente -->
      <div class="system-title">
        <span class="system-icon">🚀</span>
        <h1 class="gradient-text">
          {{ systemStore.systemName }}
        </h1>
      </div>

      <!-- Selector de idioma con diseño mejorado -->
      <div class="locale-selector">
        <select
          v-model="$i18n.locale"
          class="locale-select"
          @change="changeLocale"
        >
          <option value="es">
            🇪🇸 Español
          </option>
          <option value="en">
            🇺🇸 English
          </option>
        </select>
        <div class="selector-icon">🌐</div>
      </div>
    </header>

    <!-- Contenido principal con fondo gradient -->
    <div class="login-container">
      <div class="login-card">
        <!-- Logo animado -->
        <div class="logo-container">
          <div class="logo-wrapper">
            <img
              v-if="systemStore.logo"
              :src="systemStore.logo"
              alt="Logo"
              class="logo-image"
            >
            <div
              v-else
              class="logo-placeholder"
            >
              <span class="logo-letter">
                {{ systemStore.systemName?.charAt(0) }}
              </span>
            </div>
            <div class="logo-glow"></div>
          </div>
        </div>

        <!-- Encabezado del formulario -->
        <div class="form-header">
          <h2 class="form-title">
            <span class="title-icon">🔐</span>
            {{ $t('login') }}
          </h2>
          <p class="form-subtitle">
            {{ $t('login_prompt') }}
          </p>
        </div>

        <!-- Formulario -->
        <form @submit.prevent="handleLogin" class="login-form">
          <!-- Campo email/teléfono -->
          <div class="form-group">
            <label class="form-label">
              <span class="label-icon">📧</span>
              {{ $t('email_or_phone') }}
            </label>
            <div class="input-container">
              <input
                v-model="form.identifier"
                type="text"
                required
                class="form-input"
                :placeholder="$t('enter_email_or_phone')"
              >
              <div class="input-icon">👤</div>
            </div>
          </div>

          <!-- Campo contraseña -->
          <div class="form-group">
            <label class="form-label">
              <span class="label-icon">🔒</span>
              {{ $t('password') }}
            </label>
            <div class="input-container">
              <input
                v-model="form.password"
                :type="showPassword ? 'text' : 'password'"
                required
                class="form-input"
                :placeholder="$t('enter_password')"
              >
              <div class="input-icon">🗝️</div>
              <button
                type="button"
                class="password-toggle"
                @click="showPassword = !showPassword"
                :title="showPassword ? $t('hide_password') : $t('show_password')"
              >
                {{ showPassword ? '👁️' : '👁️‍🗨️' }}
              </button>
            </div>
          </div>

          <!-- Opciones adicionales -->
          <div class="form-options">
            <label class="checkbox-label">
              <input
                v-model="showPassword"
                type="checkbox"
                class="checkbox-input"
              >
              <span class="checkbox-custom"></span>
              <span class="checkbox-text">{{ $t('show_password') }}</span>
            </label>

            <button
              type="button"
              class="forgot-password"
              @click="goToForgotPassword"
            >
              {{ $t('forgot_password') }}
            </button>
          </div>

          <!-- Botón de login -->
          <button
            type="submit"
            :disabled="auth.loading"
            class="login-button"
            :class="{ 'loading': auth.loading }"
          >
            <span v-if="auth.loading" class="button-loader"></span>
            <span v-else class="button-text">
              <span class="button-icon">→</span>
              {{ auth.loading ? $t('logging_in') : $t('login') }}
            </span>
          </button>

          <!-- Mensaje de error del store -->
          <div v-if="auth.error" class="error-message">
            <span class="error-icon">⚠️</span>
            {{ auth.error }}
          </div>
        </form>

        <!-- Enlace a registro -->
        <div class="register-link">
          <p class="register-text">
            {{ $t('no_account') }}
            <router-link
              to="/register"
              class="register-button"
            >
              <span class="register-icon">✨</span>
              {{ $t('register_here') }}
            </router-link>
          </p>
        </div>

        <!-- Footer decorativo -->
        <div class="login-footer">
          <div class="footer-decoration">
            <span>⚡</span>
            <span>🌟</span>
            <span>💫</span>
          </div>
          <p class="footer-text">Acceso seguro garantizado</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { useAuthStore } from '@/stores/authStore'
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useSystemStore } from '@/stores/systemStore'
import Swal from 'sweetalert2' // ✅ Mantenido igual

export default {
  setup() {
    const auth = useAuthStore()
    const router = useRouter()
    const systemStore = useSystemStore()

    const form = ref({
      identifier: '',
      password: '',
    })
    const showPassword = ref(false)

    const handleLogin = () => {
      auth.login(form.value) // ✅ Lógica exactamente igual
    }

    const goToForgotPassword = () => {
      router.push('/forgot-password')
    }

    const changeLocale = (event) => {
      const newLocale = event.target.value
      auth.setLocale(newLocale)
    }

    return {
      form,
      handleLogin,
      auth,
      showPassword,
      goToForgotPassword,
      systemStore,
      changeLocale
    }
  }
}
</script>

<style scoped>
.login-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  position: relative;
  overflow: hidden;
}

.login-page::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: radial-gradient(circle at 20% 80%, rgba(120, 119, 198, 0.3) 0%, transparent 50%),
              radial-gradient(circle at 80% 20%, rgba(255, 119, 184, 0.2) 0%, transparent 50%);
  z-index: 0;
}

/* Header */
.login-header {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  padding: 16px 32px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid rgba(255, 255, 255, 0.2);
  box-shadow: 0 4px 30px rgba(0, 0, 0, 0.1);
  position: relative;
  z-index: 10;
}

.system-title {
  display: flex;
  align-items: center;
  gap: 12px;
}

.system-icon {
  font-size: 1.8rem;
  animation: float 3s ease-in-out infinite;
}

@keyframes float {
  0%, 100% { transform: translateY(0px); }
  50% { transform: translateY(-5px); }
}

.gradient-text {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
  font-size: 1.8rem;
  font-weight: 800;
  margin: 0;
}

.locale-selector {
  position: relative;
  display: flex;
  align-items: center;
}

.locale-select {
  background: white;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  padding: 10px 40px 10px 16px;
  font-size: 0.95rem;
  font-weight: 600;
  color: #4a5568;
  cursor: pointer;
  appearance: none;
  transition: all 0.3s;
  min-width: 140px;
}

.locale-select:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.locale-select:hover {
  border-color: #a0aec0;
}

.selector-icon {
  position: absolute;
  right: 12px;
  pointer-events: none;
  font-size: 1.2rem;
}

/* Contenedor principal */
.login-container {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: calc(100vh - 80px);
  padding: 40px 20px;
  position: relative;
  z-index: 1;
}

.login-card {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 24px;
  padding: 40px;
  width: 100%;
  max-width: 440px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15);
  border: 1px solid rgba(255, 255, 255, 0.3);
  position: relative;
  overflow: hidden;
}

.login-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: linear-gradient(90deg, #667eea, #764ba2);
}

/* Logo */
.logo-container {
  display: flex;
  justify-content: center;
  margin-bottom: 32px;
}

.logo-wrapper {
  position: relative;
  width: 100px;
  height: 100px;
}

.logo-image {
  width: 100%;
  height: 100%;
  object-fit: contain;
  border-radius: 20px;
  position: relative;
  z-index: 2;
}

.logo-placeholder {
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  z-index: 2;
}

.logo-letter {
  font-size: 2.5rem;
  font-weight: 800;
  color: white;
}

.logo-glow {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 120px;
  height: 120px;
  background: linear-gradient(135deg, #667eea, #764ba2);
  border-radius: 50%;
  filter: blur(20px);
  opacity: 0.4;
  animation: pulse-glow 2s ease-in-out infinite;
}

@keyframes pulse-glow {
  0%, 100% { opacity: 0.4; transform: translate(-50%, -50%) scale(1); }
  50% { opacity: 0.6; transform: translate(-50%, -50%) scale(1.05); }
}

/* Encabezado del formulario */
.form-header {
  text-align: center;
  margin-bottom: 32px;
}

.form-title {
  font-size: 2rem;
  font-weight: 800;
  color: #2d3436;
  margin-bottom: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
}

.title-icon {
  font-size: 1.8rem;
}

.form-subtitle {
  color: #636e72;
  font-size: 1rem;
  line-height: 1.5;
}

/* Formulario */
.login-form {
  margin-bottom: 32px;
}

.form-group {
  margin-bottom: 24px;
}

.form-label {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 600;
  color: #4a5568;
  margin-bottom: 8px;
  font-size: 0.95rem;
}

.label-icon {
  font-size: 1.1rem;
}

.input-container {
  position: relative;
}

.form-input {
  width: 100%;
  padding: 16px 52px 16px 52px;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  font-size: 1rem;
  transition: all 0.3s;
  background: white;
  color: #4a5568;
}

.form-input:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.form-input::placeholder {
  color: #a0aec0;
}

.input-icon {
  position: absolute;
  left: 16px;
  top: 50%;
  transform: translateY(-50%);
  font-size: 1.2rem;
  color: #a0aec0;
  pointer-events: none;
}

.password-toggle {
  position: absolute;
  right: 16px;
  top: 50%;
  transform: translateY(-50%);
  background: none;
  border: none;
  font-size: 1.2rem;
  cursor: pointer;
  color: #a0aec0;
  padding: 4px;
  transition: color 0.3s;
}

.password-toggle:hover {
  color: #667eea;
}

/* Opciones del formulario */
.form-options {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 32px;
}

.checkbox-label {
  display: flex;
  align-items: center;
  cursor: pointer;
  gap: 8px;
}

.checkbox-input {
  display: none;
}

.checkbox-custom {
  width: 20px;
  height: 20px;
  border: 2px solid #e2e8f0;
  border-radius: 6px;
  position: relative;
  transition: all 0.3s;
}

.checkbox-input:checked + .checkbox-custom {
  background: #667eea;
  border-color: #667eea;
}

.checkbox-input:checked + .checkbox-custom::after {
  content: '✓';
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  color: white;
  font-size: 12px;
  font-weight: bold;
}

.checkbox-text {
  font-size: 0.9rem;
  color: #4a5568;
}

.forgot-password {
  background: none;
  border: none;
  color: #667eea;
  font-size: 0.9rem;
  font-weight: 600;
  cursor: pointer;
  padding: 8px;
  transition: all 0.3s;
  text-decoration: none;
}

.forgot-password:hover {
  color: #764ba2;
  text-decoration: underline;
}

/* Botón de login */
.login-button {
  width: 100%;
  padding: 18px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  border-radius: 12px;
  color: white;
  font-size: 1.1rem;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.3s;
  position: relative;
  overflow: hidden;
}

.login-button:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 10px 25px rgba(102, 126, 234, 0.4);
}

.login-button:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.login-button.loading {
  background: linear-gradient(135deg, #a0aec0 0%, #718096 100%);
}

.button-loader {
  display: inline-block;
  width: 20px;
  height: 20px;
  border: 3px solid rgba(255, 255, 255, 0.3);
  border-radius: 50%;
  border-top-color: white;
  animation: spin 1s ease-in-out infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.button-text {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.button-icon {
  font-size: 1.2rem;
  transition: transform 0.3s;
}

.login-button:hover .button-icon {
  transform: translateX(4px);
}

/* Mensaje de error */
.error-message {
  margin-top: 16px;
  padding: 12px 16px;
  background: linear-gradient(135deg, #ff6b6b 0%, #ee5a52 100%);
  border-radius: 10px;
  color: white;
  font-size: 0.9rem;
  display: flex;
  align-items: center;
  gap: 10px;
  animation: slideIn 0.3s ease-out;
}

.error-icon {
  font-size: 1.2rem;
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* Enlace a registro */
.register-link {
  text-align: center;
  margin-bottom: 24px;
  padding-top: 24px;
  border-top: 1px solid #e2e8f0;
}

.register-text {
  color: #4a5568;
  font-size: 0.95rem;
}

.register-button {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  color: #667eea;
  font-weight: 700;
  text-decoration: none;
  transition: all 0.3s;
  padding: 4px 8px;
  border-radius: 6px;
}

.register-button:hover {
  color: #764ba2;
  background: rgba(102, 126, 234, 0.1);
}

.register-icon {
  font-size: 1rem;
  transition: transform 0.3s;
}

.register-button:hover .register-icon {
  transform: rotate(15deg);
}

/* Footer decorativo */
.login-footer {
  text-align: center;
}

.footer-decoration {
  display: flex;
  justify-content: center;
  gap: 16px;
  margin-bottom: 12px;
}

.footer-decoration span {
  font-size: 1.2rem;
  animation: bounce 2s infinite;
}

.footer-decoration span:nth-child(1) { animation-delay: 0s; }
.footer-decoration span:nth-child(2) { animation-delay: 0.2s; }
.footer-decoration span:nth-child(3) { animation-delay: 0.4s; }

@keyframes bounce {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-5px); }
}

.footer-text {
  color: #a0aec0;
  font-size: 0.85rem;
  font-weight: 500;
}

/* Responsive */
@media (max-width: 768px) {
  .login-header {
    padding: 12px 20px;
  }

  .gradient-text {
    font-size: 1.5rem;
  }

  .login-card {
    padding: 32px 24px;
    margin: 0 16px;
  }

  .form-title {
    font-size: 1.8rem;
  }

  .form-options {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }

  .forgot-password {
    align-self: flex-end;
  }
}

@media (max-width: 480px) {
  .login-card {
    padding: 24px 20px;
  }

  .logo-wrapper {
    width: 80px;
    height: 80px;
  }

  .logo-glow {
    width: 100px;
    height: 100px;
  }

  .form-title {
    font-size: 1.6rem;
  }

  .form-input {
    padding: 14px 48px 14px 48px;
  }
}
</style>
