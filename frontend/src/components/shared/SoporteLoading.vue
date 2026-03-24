<template>
  <div class="soporte-loading-state">
    <div class="soporte-spinner"></div>
    <p class="soporte-loading-text">
      <slot>{{ $t('loading') }}…</slot>
    </p>
  </div>
</template>

<script>
export default {
  name: 'SoporteLoading'
}
</script>

<style scoped>
.soporte-loading-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 3rem 1rem;
  background: white;
  border-radius: 1rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.soporte-spinner {
  width: 40px;
  height: 40px;
  border: 3px solid #f3f3f3;
  border-top: 3px solid #3498db;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 1rem;
}

.soporte-loading-text {
  color: #666;
  font-size: 0.95rem;
  margin: 0;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
</style>
