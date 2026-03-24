// =============================================
// COMPONENTES DE SOPORTE - PUNTO DE ENTRADA
// =============================================

// 1️⃣ IMPORTACIONES DE COMPONENTES
// ---------------------------------------------
export { default as Soporte } from './Soporte.vue'
export { default as SoporteFaqItem } from './SoporteFaqItem.vue'
export { default as SoporteTicketCard } from './SoporteTicketCard.vue'
export { default as SoporteLoading } from './SoporteLoading.vue'
export { default as SoporteTicketModal } from './SoporteTicketModal.vue'
export { default as SoporteToast } from './SoporteToast.vue'
export { default as SoporteToastContainer } from './SoporteToastContainer.vue'

// 2️⃣ COMPOSABLES (utilidades)
// ---------------------------------------------
// Usando alias @ (recomendado - más seguro)
export { useToast } from '@/composables/useToast'

// 3️⃣ TIPOS (para TypeScript - opcional)
// ---------------------------------------------
// export * from './types'

// 4️⃣ VERSIÓN DEL MÓDULO (opcional - útil para debugging)
// ---------------------------------------------
export const version = '1.0.0'

// 5️⃣ INFORMACIÓN DEL MÓDULO (opcional)
// ---------------------------------------------
export const SoporteModule = {
  name: 'Soporte',
  version: '1.0.0',
  description: 'Módulo de soporte al cliente con FAQs, tickets y chat'
}
