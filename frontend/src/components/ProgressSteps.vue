<template>
  <div>
    <h3 class="font-semibold mb-2">{{ $t('service_progress') }}</h3>
    <div class="space-y-2">
      <div
        v-for="(step, idx) in steps"
        :key="idx"
        class="flex items-center space-x-3"
      >
        <div
          :class="[
            'w-6 h-6 rounded-full flex items-center justify-center text-white',
            step.done ? 'bg-green-500' : step.active ? 'bg-blue-500' : 'bg-gray-300',
          ]"
        >
          <svg
            v-if="step.done"
            class="w-4 h-4"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M5 13l4 4L19 7"
            />
          </svg>
        </div>
        <span :class="step.active ? 'font-semibold' : 'text-gray-500'">
          {{ step.title }}
        </span>
      </div>
    </div>
  </div>
</template>

<script>
const STEP_MAP = {
  accepted: 0,
  'en-route': 1,
  arrived: 2,
  'in-progress': 3,
  completed: 4,
}

export default {
  props: { status: { type: String, required: true } },
  computed: {
    steps() {
      const titles = [
        this.$t('accepted'),
        this.$t('en_route'),
        this.$t('arrived'),
        this.$t('in_progress'),
        this.$t('completed'),
      ]
      const current = STEP_MAP[this.status?.toLowerCase()] ?? -1
      return titles.map((title, idx) => ({
        title,
        done: idx < current,
        active: idx === current,
      }))
    },
  },
}
</script>
