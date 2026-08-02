<template>
  <div class="account-blocked-page">
    <!-- Banner -->
    <div class="blocked-banner">
      <div class="banner-icon">🚫</div>
      <h1>Cuenta Bloqueada</h1>
      <p>Tu cuenta ha sido suspendida por facturas vencidas con más de 7 días de retraso</p>
    </div>

    <!-- Contenido -->
    <div class="blocked-content">
      <div class="info-grid">
        <div class="info-card restrictions">
          <h3>📋 Restricciones</h3>
          <ul>
            <li>❌ No puedes publicar nuevos servicios</li>
            <li>❌ No puedes destacar servicios</li>
            <li>❌ No puedes aceptar nuevas solicitudes</li>
            <li>❌ Tus servicios no aparecen en las búsquedas</li>
          </ul>
        </div>

        <div class="info-card allowed">
          <h3>✅ Lo que sí puedes hacer</h3>
          <ul>
            <li>✅ Iniciar sesión normalmente</li>
            <li>✅ Ver tus facturas pendientes</li>
            <li>✅ Reportar pagos de facturas</li>
            <li>✅ Contactar a soporte</li>
          </ul>
        </div>
      </div>

      <div class="recovery-section">
        <h3>💡 ¿Cómo recupero mi cuenta?</h3>
        <div class="steps">
          <div class="step">
            <span class="step-number">1</span>
            <span>Ve a <strong>Mis Facturas</strong></span>
          </div>
          <div class="step">
            <span class="step-number">2</span>
            <span>Revisa las facturas <strong>Vencidas</strong></span>
          </div>
          <div class="step">
            <span class="step-number">3</span>
            <span>Realiza el pago y sube el comprobante</span>
          </div>
          <div class="step">
            <span class="step-number">4</span>
            <span>Tu cuenta se reactivará automáticamente</span>
          </div>
        </div>
      </div>

      <div class="actions">
        <router-link to="/provider/billing" class="btn-primary">💳 Ir a Mis Facturas</router-link>
        <router-link to="/" class="btn-secondary">🏠 Ir al Inicio</router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
</script>

<style scoped>
* {
  box-sizing: border-box;
}

.account-blocked-page {
  min-height: 100vh;
  background: #f5f5f5;
}

/* Banner */
.blocked-banner {
  background: linear-gradient(135deg, #dc3545, #a71d2a);
  color: white;
  text-align: center;
  padding: 2.5rem 1.5rem;
}

.banner-icon {
  font-size: 3.5rem;
  margin-bottom: 0.5rem;
}

.blocked-banner h1 {
  margin: 0 0 0.5rem;
  font-size: clamp(1.5rem, 4vw, 2.2rem);
  font-weight: 700;
}

.blocked-banner p {
  margin: 0;
  font-size: clamp(0.9rem, 2.5vw, 1.1rem);
  opacity: 0.9;
}

/* Contenido */
.blocked-content {
  max-width: 900px;
  margin: 0 auto;
  padding: 1.5rem;
}

/* Grid de info */
.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1.2rem;
  margin-bottom: 1.5rem;
}

.info-card {
  background: white;
  border-radius: 12px;
  padding: 1.5rem;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
}

.info-card.restrictions {
  border-left: 4px solid #dc3545;
}

.info-card.allowed {
  border-left: 4px solid #28a745;
}

.info-card h3 {
  margin: 0 0 1rem;
  font-size: 1.05rem;
  color: #333;
}

.info-card ul {
  margin: 0;
  padding-left: 0;
  list-style: none;
}

.info-card li {
  padding: 0.4rem 0;
  color: #555;
  font-size: 0.95rem;
  line-height: 1.4;
}

/* Recuperación */
.recovery-section {
  background: white;
  border-radius: 12px;
  padding: 1.5rem;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
  margin-bottom: 1.5rem;
}

.recovery-section h3 {
  margin: 0 0 1.2rem;
  font-size: 1.1rem;
  color: #333;
  text-align: center;
}

.steps {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  justify-content: center;
}

.step {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  background: #f8f9fa;
  padding: 0.75rem 1.2rem;
  border-radius: 8px;
  font-size: 0.95rem;
  color: #444;
  flex: 1;
  min-width: 200px;
}

.step-number {
  background: #007bff;
  color: white;
  width: 28px;
  height: 28px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 0.85rem;
  flex-shrink: 0;
}

/* Botones */
.actions {
  display: flex;
  gap: 1rem;
  justify-content: center;
  flex-wrap: wrap;
}

.btn-primary {
  background: #007bff;
  color: white;
  padding: 0.85rem 2rem;
  border-radius: 10px;
  text-decoration: none;
  font-weight: 600;
  font-size: 1rem;
  transition: background 0.2s;
  text-align: center;
}

.btn-primary:hover {
  background: #0056b3;
}

.btn-secondary {
  background: #6c757d;
  color: white;
  padding: 0.85rem 2rem;
  border-radius: 10px;
  text-decoration: none;
  font-weight: 600;
  font-size: 1rem;
  transition: background 0.2s;
}

.btn-secondary:hover {
  background: #545b62;
}

/* Responsive */
@media (max-width: 600px) {
  .blocked-banner {
    padding: 1.8rem 1rem;
  }

  .blocked-content {
    padding: 1rem;
  }

  .info-card {
    padding: 1.2rem;
  }

  .steps {
    flex-direction: column;
  }

  .step {
    min-width: auto;
  }

  .actions {
    flex-direction: column;
  }

  .btn-primary, .btn-secondary {
    width: 100%;
  }
}
</style>
