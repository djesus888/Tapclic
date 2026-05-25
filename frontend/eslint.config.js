import js from '@eslint/js'
import pluginVue from 'eslint-plugin-vue'

export default [
  js.configs.recommended,
  ...pluginVue.configs['flat/recommended'],
  {
    languageOptions: {
      globals: {
        window: 'readonly',
        document: 'readonly',
        console: 'readonly',
        localStorage: 'readonly',
        navigator: 'readonly',
        Audio: 'readonly',
        fetch: 'readonly',
        setTimeout: 'readonly',
        clearInterval: 'readonly',
        setInterval: 'readonly',
        atob: 'readonly',
        _: 'readonly',
        confirm: 'readonly',
        clearTimeout: 'readonly',
        FileReader: 'readonly',
        FormData: 'readonly',
        alert: 'readonly',
        prompt: 'readonly',
        URL: 'readonly',
        CustomEvent: 'readonly',
        Blob: 'readonly',
        getImageUrl: 'readonly'
      }
    },
    rules: {
      'no-console': 'off',
      'no-unused-vars': 'warn',
      'no-undef': 'warn',
      'vue/no-undef-components': 'off',
      'vue/no-unused-vars': 'warn',
      'vue/no-unused-components': 'warn',
      'vue/no-v-html': 'warn',
      'no-underscore-dangle': 'off'
    }
  }
]
