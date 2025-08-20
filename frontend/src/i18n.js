import { createI18n } from 'vue-i18n'
import es from './translations/es.json'
import en from './translations/en.json'

export const i18n = createI18n({
  legacy: false,
  locale: 'es', // Idioma por defecto
  fallbackLocale: 'en', // Idioma alternativo si falta una clave
  globalInjection: true, // Permite usar $t en templates sin inyectar manualmente
  messages: {
    es,
    en
  }
})
