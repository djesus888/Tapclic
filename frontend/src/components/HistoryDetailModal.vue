<!-- Modal inline para detalle historial -->
<template>
  <Teleport to="body">
    <div
      v-if="historyDetailModal"
      class="fixed inset-0 bg-black/40 z-40 flex items-end md:items-center"
      @click.self="historyDetailModal = false"
    >
      <div
        class="w-full max-w-lg bg-white rounded-t-xl md:rounded-lg shadow-xl max-h-[90vh] overflow-y-auto"
      >
        <div class="p-6 space-y-4">
          <h2 class="text-2xl font-bold">{{ selectedHistoryItem.title }}</h2>
          <p class="text-gray-600">{{ selectedHistoryItem.description }}</p>

          <hr />
          <div class="grid grid-cols-2 gap-y-2 text-sm">
            <p class="text-gray-500">{{ $t('provider') }}:</p>
            <p class="font-semibold">{{ selectedHistoryItem.providerName }}</p>

            <p class="text-gray-500">{{ $t('date') }}:</p>
            <p class="font-semibold">{{ formatDate(selectedHistoryItem.date) }}</p>

            <p class="text-gray-500">{{ $t('status') }}:</p>
            <p
              class="font-semibold flex items-center gap-1"
              :class="statusColor(selectedHistoryItem.status)"
            >
              <component :is="statusIcon(selectedHistoryItem.status)" class="w-4 h-4" />
              {{ statusLabel(selectedHistoryItem.status) }}
            </p>

            <p class="text-gray-500">{{ $t('payment_method') }}:</p>
            <p class="font-semibold">{{ selectedHistoryItem.paymentMethod }}</p>

            <p class="text-gray-500">{{ $t('total') }}:</p>
            <p class="text-xl font-bold text-primary">
              ${{ selectedHistoryItem.price.toFixed(2) }}
            </p>
          </div>

          <button
            class="w-full mt-4 py-2 rounded-md bg-gray-100 hover:bg-gray-200"
            @click="historyDetailModal = false"
          >
            {{ $t('close') }}
          </button>
        </div>
      </div>
    </div>
  </Teleport>
</template>
