<template>
  <div 
    class="soporte-faq-item" 
    @click="toggle"
    :class="{ 'soporte-faq-active': isActive }"
  >
    <div class="soporte-faq-question">
      <h3 class="soporte-faq-question-text" v-html="sanitizedQuestion"></h3>
      <span class="soporte-faq-toggle">{{ isActive ? '−' : '+' }}</span>
    </div>
    <div class="soporte-faq-answer" v-if="isActive">
      <p class="soporte-faq-answer-text" v-html="sanitizedAnswer"></p>
    </div>
  </div>
</template>

<script>
import DOMPurify from 'dompurify'

export default {
  name: 'SoporteFaqItem',
  props: {
    item: {
      type: Object,
      required: true,
      validator: (item) => {
        return item.id && 
               typeof item.question === 'string' &&
               typeof item.answer === 'string'
      }
    },
    isActive: {
      type: Boolean,
      default: false
    }
  },
  emits: ['toggle'],
  computed: {
    sanitizedQuestion() {
      return DOMPurify.sanitize(this.item.question, {
        ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a', 'p', 'br', 'ul', 'ol', 'li'],
        ALLOWED_ATTR: ['href', 'target', 'rel'],
        FORBID_TAGS: ['script', 'style', 'iframe', 'object', 'embed'],
        FORBID_ATTR: ['onerror', 'onload', 'onclick']
      })
    },
    sanitizedAnswer() {
      return DOMPurify.sanitize(this.item.answer, {
        ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a', 'p', 'br', 'ul', 'ol', 'li'],
        ALLOWED_ATTR: ['href', 'target', 'rel'],
        FORBID_TAGS: ['script', 'style', 'iframe', 'object', 'embed'],
        FORBID_ATTR: ['onerror', 'onload', 'onclick']
      })
    }
  },
  methods: {
    toggle() {
      this.$emit('toggle', this.item.id)
    }
  }
}
</script>

<style scoped>
.soporte-faq-item {
  background: white;
  border-radius: 0.75rem;
  padding: 1rem 1.25rem;
  cursor: pointer;
  transition: all 0.2s ease;
  border: 1px solid #f0f0f0;
}

.soporte-faq-item:hover {
  border-color: #e0e0e0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.soporte-faq-active {
  border-color: #3498db;
  background: #f8fcff;
}

.soporte-faq-question {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
}

.soporte-faq-question-text {
  font-size: 0.95rem;
  font-weight: 500;
  color: #1a1a1a;
  margin: 0;
  flex: 1;
}

.soporte-faq-toggle {
  font-size: 1.25rem;
  font-weight: 500;
  color: #3498db;
  width: 20px;
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.soporte-faq-answer {
  margin-top: 0.75rem;
  padding-top: 0.75rem;
  border-top: 1px solid #e0e0e0;
}

.soporte-faq-answer-text {
  font-size: 0.9rem;
  color: #4a4a4a;
  margin: 0;
  line-height: 1.6;
}
</style>
