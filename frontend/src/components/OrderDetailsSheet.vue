<template>
  <div
    class="bg-white rounded-t-xl shadow-2xl max-h-[80vh] overflow-y-auto"
  >
    <!-- Handle -->
    <div class="flex justify-center pt-2">
      <div class="w-12 h-1 bg-gray-300 rounded-full"></div>
    </div>

    <div class="px-4 py-3 space-y-4">
      <!-- Header -->
      <div class="flex justify-between items-start">
        <div>
          <h2 class="font-bold text-lg">#{{ order.id }}</h2>
          <p class="text-sm text-gray-600">{{ order.serviceName }}</p>
        </div>
        <span :class="badgeClass" class="px-2 py-1 text-xs font-semibold rounded-full">
          {{ order.status }}
        </span>
      </div>

      <!-- Provider -->
      <div class="flex items-center space-x-3">
        <img
          :src="order.provider?.avatar_url || '/img/default-avatar.png'"
          alt="Provider"
          class="w-12 h-12 rounded-full object-cover"
        />
        <div>
          <p class="font-semibold">{{ order.provider?.name }}</p>
          <p class="text-sm text-yellow-500">
            ⭐ {{ order.provider?.rating || '-' }}
          </p>
        </div>
      </div>

      <!-- Progress -->
      <ProgressSteps :status="order.status" />

      <!-- Action buttons -->
      <div class="grid grid-cols-3 gap-2">
        <button
          @click="$emit('chat')"
          class="border border-blue-600 text-blue-600 rounded py-2"
        >
          💬
        </button>
        <button
          @click="$emit('call')"
          class="border border-blue-600 text-blue-600 rounded py-2"
        >
          📞
        </button>
        <button
          @click="$emit('emergency')"
          class="border border-red-600 text-red-600 rounded py-2"
        >
          🚨
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import ProgressSteps from './ProgressSteps.vue'

export default {
  components: { ProgressSteps },
  props: { order: { type: Object, required: true } },
  emits: ['chat', 'call', 'emergency'],
  computed: {
    badgeClass() {
      const map = {
        accepted: 'bg-green-100 text-green-800',
        'en-route': 'bg-yellow-100 text-yellow-800',
        arrived: 'bg-blue-100 text-blue-800',
        completed: 'bg-gray-100 text-gray-800',
      }
      return map[this.order.status?.toLowerCase()] || 'bg-gray-100 text-gray-800'
    },
  },
}
</script>
