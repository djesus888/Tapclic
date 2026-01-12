<!-- utils/WalletCard.vue -->
<template>
  <div class="bg-white dark:bg-gray-900 rounded-2xl shadow p-5">
    <h3 class="text-lg font-semibold text-gray-800 dark:text-white mb-2">
      {{ $t('wallet.title') }}
    </h3>
    <p class="text-3xl font-bold text-green-500">
      ${{ balance.toFixed(2) }}
    </p>
    <p class="text-sm text-gray-500 mt-1">
      {{ $t('wallet.available') }}
    </p>
  </div>
</template>

<script>
export default {
  name: 'WalletCard',
  props: {
    balance: {
      type: Number,
      required: true
    }
  }
}
</script>
