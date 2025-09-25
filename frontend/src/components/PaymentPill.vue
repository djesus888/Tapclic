<template>
  <span class="px-2 py-1 rounded-full text-xs font-semibold select-none" :class="pillClass">
    {{ label }}
  </span>
</template>

<script>
export default {
  name: 'PaymentPill',
  props: { status: { type: String, default: '' } },
  computed: {
    label() {
      const map = {
        pending: this.$t('payment.pending'),
        paid: this.$t('payment.paid'),
        cancelled: this.$t('payment.cancelled'),
        rejected: this.$t('payment.rejected'),
        verifying: this.$t('payment.verifying'),
        refunded: this.$t('payment.refunded'),
        partially_refunded: this.$t('payment.partially_refunded'),
        disputed: this.$t('payment.disputed'),
        expired: this.$t('payment.expired'),
        confirmed: this.$t('payment.confirmed'),
        failed: this.$t('payment.failed'),
        processing: this.$t('payment.processing'),
        cancelled_by_user: this.$t('payment.cancelled_by_user'),
        cancelled_by_provider: this.$t('payment.cancelled_by_provider'),
        on_hold: this.$t('payment.on_hold')
      }
      return map[this.status] || this.$t('payment.unknown')
    },
    pillClass() {
      const map = {
        pending: 'bg-yellow-100 text-yellow-800',
        paid: 'bg-green-100 text-green-800',
        cancelled: 'bg-red-100 text-red-800',
        rejected: 'bg-gray-100 text-gray-800',
        verifying: 'bg-orange-100 text-orange-800',
        refunded: 'bg-purple-100 text-purple-800',
        partially_refunded: 'bg-purple-200 text-purple-900',
        disputed: 'bg-red-200 text-red-900',
        expired: 'bg-gray-200 text-gray-900',
        confirmed: 'bg-green-200 text-green-900',
        failed: 'bg-rose-100 text-rose-800',
        processing: 'bg-blue-100 text-blue-800',
        cancelled_by_user: 'bg-gray-100 text-gray-800',
        cancelled_by_provider: 'bg-orange-100 text-orange-800',
        on_hold: 'bg-amber-100 text-amber-800'
      }
      return map[this.status] || 'bg-gray-100 text-gray-800'
    }
  }
}
</script>
