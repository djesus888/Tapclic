<template>
  <div>
    <transition name="modal-fade">
      <div
        v-if="isOpen"
        class="fixed inset-0 bg-black bg-opacity-50 flex justify-center items-end z-50"
      >
        <div class="bg-white w-full md:w-1/2 rounded-t-lg p-6 max-h-[80vh] overflow-y-auto">
          <div class="mb-4">
            <h2 class="text-2xl font-bold">
              {{ item.title }}
            </h2>
            <p class="text-gray-600">
              {{ item.description }}
            </p>
          </div>

          <div class="space-y-3">
            <div class="flex justify-between items-center text-sm text-gray-700">
              <span>{{ $t('provider') }}</span>
              <span class="font-semibold">{{ item.providerName }}</span>
            </div>

            <div class="flex justify-between items-center text-sm text-gray-700">
              <span>{{ $t('date_time') }}</span>
              <span class="font-semibold">{{ formattedDate }}</span>
            </div>

            <div class="flex justify-between items-center text-sm">
              <span>{{ $t('status') }}</span>
              <span
                :class="statusColor(item.status)"
                class="font-semibold"
              >{{ $t(item.status) }}</span>
            </div>

            <div class="flex justify-between items-center text-sm text-gray-700">
              <span>{{ $t('payment_method') }}</span>
              <span class="font-semibold">{{ $t(paymentMethodLabel) }}</span>
            </div>

            <div class="flex justify-between items-center text-gray-700">
              <span>{{ $t('total_paid') }}</span>
              <span class="text-xl font-bold text-primary">${{ item.price.toFixed(2) }}</span>
            </div>
          </div>

          <div class="mt-6">
            <button
              class="w-full py-2 bg-gray-200 rounded-md font-semibold hover:bg-gray-300"
              @click="$emit('on-open-change', false)"
            >
              {{ $t('close') }}
            </button>
          </div>
        </div>
      </div>
    </transition>
  </div>
</template>

<script>

export default {
  name: 'HistoryDetailsModal',
  props: {
    isOpen: { type: Boolean, required: true },
    item: {
      type: Object,
      required: true,
      default: () => ({ title: '', description: '', providerName: '', date: '', status: '', paymentMethod: '', price: 0 })
    }
  },
  computed: {
    formattedDate() {
      if (!this.item.date) return '';
      return format(new Date(this.item.date), "dd 'de' MMMM, yyyy 'a las' HH:mm", { locale: es });
    },
    statusColor() {
      const colors = {
        completado: 'text-green-600',
        fallido: 'text-red-600',
        inconcluso: 'text-yellow-600',
        cancelado: 'text-gray-500'
      };
      return colors[this.item.status] || 'text-gray-700';
    },
    paymentMethodLabel() {
      const labels = {
        efectivo: 'cash',
        'pago-movil': 'mobile_payment',
        transferencia: 'transfer',
        wallet: 'wallet'
      };
      return labels[this.item.paymentMethod] || '';
    }
  }
};
</script>

<style scoped>
.modal-fade-enter-active,
.modal-fade-leave-active {
  transition: opacity 0.3s;
}
.modal-fade-enter-from,
.modal-fade-leave-to {
  opacity: 0;
}
</style>
