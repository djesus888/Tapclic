import { createI18n } from 'vue-i18n'
import es from './translations/es.json'
import en from './translations/en.json'

// Leer idioma guardado por el usuario (si existe)
const savedLocale = localStorage.getItem('userLocale') || 'es'

export const i18n = createI18n({
  legacy: false,
  locale: savedLocale, // <-- Aquí usamos el idioma guardado
  fallbackLocale: 'en',
  globalInjection: true,
  messages: {
    es,
    en
  }
})
