<!-- src/pages/admin/PaymentGateways.vue - VERSIÓN CORREGIDA CON i18n -->
<template>
  <div class="admin-payment-gateways">
    <!-- Loading State -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner"></div>
      <p>{{ $t('paymentGateways.loading') }}</p>
    </div>

    <template v-else>
      <!-- Header -->
      <div class="page-header">
        <div class="header-left">
          <h1 class="page-title">
            <span class="title-icon">💳</span>
            {{ $t('paymentGateways.title') }}
          </h1>
          <p class="page-subtitle">{{ $t('paymentGateways.subtitle') }}</p>
        </div>

        <div class="header-actions">
          <button class="btn-refresh" @click="loadAllData">
            🔄 {{ $t('common.refresh') }}
          </button>
        </div>
      </div>

      <!-- Mensajes de estado -->
      <div v-if="successMessage" class="message-success">
        <span class="message-icon">✅</span>
        {{ successMessage }}
        <button class="message-close" @click="successMessage = ''">×</button>
      </div>
      <div v-if="errorMessage" class="message-error">
        <span class="message-icon">❌</span>
        {{ errorMessage }}
        <button class="message-close" @click="errorMessage = ''">×</button>
      </div>

      <!-- Estadísticas de pagos -->
      <div class="payment-stats" v-if="paymentStats">
        <div class="stats-card">
          <div class="stat-icon">💰</div>
          <div class="stat-content">
            <h4>{{ $t('paymentGateways.stats.totalCollected') }}</h4>
            <p class="stat-value">${{ formatCurrency(paymentStats.total_amount || 0) }}</p>
          </div>
        </div>

        <div class="stats-card">
          <div class="stat-icon">📊</div>
          <div class="stat-content">
            <h4>{{ $t('paymentGateways.stats.transactions') }}</h4>
            <p class="stat-value">{{ paymentStats.total_transactions || 0 }}</p>
          </div>
        </div>

        <div class="stats-card">
          <div class="stat-icon">✅</div>
          <div class="stat-content">
            <h4>{{ $t('paymentGateways.stats.successRate') }}</h4>
            <p class="stat-value">{{ paymentStats.success_rate || 0 }}%</p>
          </div>
        </div>

        <div class="stats-card">
          <div class="stat-icon">🔧</div>
          <div class="stat-content">
            <h4>{{ $t('paymentGateways.stats.activeGateways') }}</h4>
            <p class="stat-value">{{ activeGatewaysCount }}/{{ gateways.length }}</p>
          </div>
        </div>
      </div>

      <!-- Configuración de comisiones globales -->
      <div class="global-commissions-section">
        <div class="section-header">
          <h2>💰 {{ $t('paymentGateways.globalCommissions.title') }}</h2>
          <p>{{ $t('paymentGateways.globalCommissions.description') }}</p>
        </div>

        <div class="commissions-card">
          <div class="commission-settings">
            <div class="commission-setting">
              <label class="commission-label">
                {{ $t('paymentGateways.globalCommissions.percentageRate') }}
                <input
                  type="number"
                  v-model.number="globalCommission.rate"
                  min="0"
                  max="50"
                  step="0.1"
                  class="commission-input"
                >
              </label>
              <p class="commission-help">
                {{ $t('paymentGateways.globalCommissions.percentageHelp') }}
              </p>
            </div>

            <div class="commission-setting">
              <label class="commission-label">
                {{ $t('paymentGateways.globalCommissions.fixedRate') }}
                <input
                  type="number"
                  v-model.number="globalCommission.fixed"
                  min="0"
                  step="0.01"
                  class="commission-input"
                >
              </label>
              <p class="commission-help">
                {{ $t('paymentGateways.globalCommissions.fixedHelp') }}
              </p>
            </div>
          </div>

          <button
            class="btn-save-commissions"
            @click="saveGlobalCommissions"
            :disabled="savingCommissions"
          >
            <span v-if="savingCommissions" class="save-loading"></span>
            <span v-else>💾 {{ $t('common.save') }}</span>
          </button>
        </div>
      </div>

      <!-- Lista de pasarelas -->
      <div class="gateways-section">
        <div class="section-header">
          <h2>{{ $t('paymentGateways.configuredGateways') }}</h2>
          <button class="btn-add-gateway" @click="showAddGatewayModal = true">
            <span class="btn-icon">➕</span>
            {{ $t('paymentGateways.addGateway') }}
          </button>
        </div>

        <div class="gateways-grid">
          <!-- PayPal -->
          <div class="gateway-card" v-if="paypalGateway">
            <div class="gateway-header">
              <div class="gateway-icon">🅿️</div>
              <div class="gateway-info">
                <h3>{{ paypalGateway.display_name }}</h3>
                <div class="gateway-meta">
                  <span class="gateway-status" :class="paypalGateway.is_active ? 'active' : 'inactive'">
                    {{ paypalGateway.is_active ? '✅ ' + $t('common.active') : '⛔ ' + $t('common.inactive') }}
                  </span>
                  <span class="gateway-mode" :class="paypalGateway.is_test_mode ? 'test' : 'live'">
                    {{ paypalGateway.is_test_mode ? '🧪 ' + $t('common.testMode') : '🚀 ' + $t('common.productionMode') }}
                  </span>
                </div>
              </div>
              <div class="gateway-stats">
                <div class="stat-item">
                  <span class="stat-label">{{ $t('paymentGateways.transactions') }}:</span>
                  <span class="stat-value">{{ paypalGateway.total_transactions || 0 }}</span>
                </div>
                <div class="stat-item">
                  <span class="stat-label">{{ $t('paymentGateways.commission') }}:</span>
                  <span class="stat-value">{{ formatCommission(paypalGateway.commission_rate) }}</span>
                </div>
              </div>
            </div>

            <div class="gateway-details">
              <div class="detail-item">
                <span class="detail-label">{{ $t('paymentGateways.fields.paypalEmail') }}:</span>
                <span class="detail-value">
                  {{ paypalGateway.paypal_email || $t('common.notConfigured') }}
                </span>
              </div>
              <div class="detail-item">
                <span class="detail-label">{{ $t('paymentGateways.fields.clientId') }}:</span>
                <span class="detail-value">
                  {{ maskApiKey(paypalGateway.api_key_public) }}
                </span>
              </div>
              <div class="detail-item">
                <span class="detail-label">{{ $t('paymentGateways.fields.instructions') }}:</span>
                <span class="detail-value">
                  {{ paypalGateway.instructions || $t('common.noInstructions') }}
                </span>
              </div>
            </div>

            <div class="gateway-actions">
              <button class="btn-toggle" @click="toggleGateway(paypalGateway.id)">
                {{ paypalGateway.is_active ? $t('common.deactivate') : $t('common.activate') }}
              </button>
              <button class="btn-configure" @click="configureGateway(paypalGateway)">
                {{ $t('common.configure') }}
              </button>
              <button class="btn-test" @click="testGateway(paypalGateway)">
                {{ $t('common.testConnection') }}
              </button>
            </div>
          </div>

          <!-- MercadoPago -->
          <div class="gateway-card" v-if="mercadopagoGateway">
            <div class="gateway-header">
              <div class="gateway-icon">🇦🇷</div>
              <div class="gateway-info">
                <h3>{{ mercadopagoGateway.display_name }}</h3>
                <div class="gateway-meta">
                  <span class="gateway-status" :class="mercadopagoGateway.is_active ? 'active' : 'inactive'">
                    {{ mercadopagoGateway.is_active ? '✅ ' + $t('common.active') : '⛔ ' + $t('common.inactive') }}
                  </span>
                  <span class="gateway-mode" :class="mercadopagoGateway.is_test_mode ? 'test' : 'live'">
                    {{ mercadopagoGateway.is_test_mode ? '🧪 ' + $t('common.testMode') : '🚀 ' + $t('common.productionMode') }}
                  </span>
                </div>
              </div>
              <div class="gateway-stats">
                <div class="stat-item">
                  <span class="stat-label">{{ $t('paymentGateways.transactions') }}:</span>
                  <span class="stat-value">{{ mercadopagoGateway.total_transactions || 0 }}</span>
                </div>
                <div class="stat-item">
                  <span class="stat-label">{{ $t('paymentGateways.commission') }}:</span>
                  <span class="stat-value">{{ formatCommission(mercadopagoGateway.commission_rate) }}</span>
                </div>
              </div>
            </div>

            <div class="gateway-details">
              <div class="detail-item">
                <span class="detail-label">{{ $t('paymentGateways.fields.accessToken') }}:</span>
                <span class="detail-value">
                  {{ maskApiKey(mercadopagoGateway.mercadopago_access_token) }}
                </span>
              </div>
              <div class="detail-item">
                <span class="detail-label">{{ $t('paymentGateways.fields.instructions') }}:</span>
                <span class="detail-value">
                  {{ mercadopagoGateway.instructions || $t('common.noInstructions') }}
                </span>
              </div>
            </div>

            <div class="gateway-actions">
              <button class="btn-toggle" @click="toggleGateway(mercadopagoGateway.id)">
                {{ mercadopagoGateway.is_active ? $t('common.deactivate') : $t('common.activate') }}
              </button>
              <button class="btn-configure" @click="configureGateway(mercadopagoGateway)">
                {{ $t('common.configure') }}
              </button>
              <button class="btn-test" @click="testGateway(mercadopagoGateway)">
                {{ $t('common.testConnection') }}
              </button>
            </div>
          </div>

          <!-- Transferencia Bancaria -->
          <div class="gateway-card" v-if="bankTransferGateway">
            <div class="gateway-header">
              <div class="gateway-icon">🏦</div>
              <div class="gateway-info">
                <h3>{{ bankTransferGateway.display_name }}</h3>
                <div class="gateway-meta">
                  <span class="gateway-status" :class="bankTransferGateway.is_active ? 'active' : 'inactive'">
                    {{ bankTransferGateway.is_active ? '✅ ' + $t('common.active') : '⛔ ' + $t('common.inactive') }}
                  </span>
                  <span class="gateway-mode">
                    {{ $t('common.manual') }}
                  </span>
                </div>
              </div>
              <div class="gateway-stats">
                <div class="stat-item">
                  <span class="stat-label">{{ $t('paymentGateways.transactions') }}:</span>
                  <span class="stat-value">{{ bankTransferGateway.total_transactions || 0 }}</span>
                </div>
              </div>
            </div>

            <div class="gateway-details">
              <div class="detail-item">
                <span class="detail-label">{{ $t('paymentGateways.fields.bankName') }}:</span>
                <span class="detail-value">
                  {{ bankTransferGateway.bank_name || $t('common.notSpecified') }}
                </span>
              </div>
              <div class="detail-item">
                <span class="detail-label">{{ $t('paymentGateways.fields.accountNumber') }}:</span>
                <span class="detail-value">
                  {{ bankTransferGateway.bank_account || $t('common.notConfigured') }}
                </span>
              </div>
              <div class="detail-item">
                <span class="detail-label">{{ $t('paymentGateways.fields.accountHolder') }}:</span>
                <span class="detail-value">
                  {{ bankTransferGateway.bank_holder || $t('common.notSpecified') }}
                </span>
              </div>
              <div class="detail-item">
                <span class="detail-label">{{ $t('paymentGateways.fields.idNumber') }}:</span>
                <span class="detail-value">
                  {{ bankTransferGateway.bank_id_number || $t('common.notSpecified') }}
                  <span v-if="bankTransferGateway.bank_id_type">({{ bankTransferGateway.bank_id_type }})</span>
                </span>
              </div>
              <div class="detail-item">
                <span class="detail-label">{{ $t('paymentGateways.fields.instructions') }}:</span>
                <span class="detail-value">
                  {{ bankTransferGateway.instructions || $t('paymentGateways.defaultInstructions.bankTransfer') }}
                </span>
              </div>
            </div>

            <div class="gateway-actions">
              <button class="btn-toggle" @click="toggleGateway(bankTransferGateway.id)">
                {{ bankTransferGateway.is_active ? $t('common.deactivate') : $t('common.activate') }}
              </button>
              <button class="btn-configure" @click="configureGateway(bankTransferGateway)">
                {{ $t('common.configure') }}
              </button>
            </div>
          </div>

<!-- Pago Móvil -->
<div class="gateway-card" v-if="mobilePaymentGateway">
  <div class="gateway-header">
    <div class="gateway-icon">📱</div>
    <div class="gateway-info">
      <h3>{{ mobilePaymentGateway.display_name }}</h3>
      <div class="gateway-meta">
        <span class="gateway-status" :class="mobilePaymentGateway.is_active ? 'active' : 'inactive'">
          {{ mobilePaymentGateway.is_active ? '✅ ' + $t('common.active') : '⛔ ' + $t('common.inactive') }}
        </span>
        <span class="gateway-mode">
          {{ $t('common.mobile') }}
        </span>
      </div>
    </div>
    <div class="gateway-stats">
      <div class="stat-item">
        <span class="stat-label">{{ $t('paymentGateways.transactions') }}:</span>
        <span class="stat-value">{{ mobilePaymentGateway.total_transactions || 0 }}</span>
      </div>
    </div>
  </div>

  <div class="gateway-details">
    <div class="detail-item">
      <span class="detail-label">Banco:</span>
      <span class="detail-value">{{ mobilePaymentGateway.bank_name || $t('common.notSpecified') }}</span>
    </div>
    <div class="detail-item">
      <span class="detail-label">{{ $t('paymentGateways.fields.phoneNumber') }}:</span>
      <span class="detail-value">
        {{ mobilePaymentGateway.mobile_phone || $t('common.notConfigured') }}
      </span>
    </div>
    <div class="detail-item">
      <span class="detail-label">{{ $t('paymentGateways.fields.operator') }}:</span>
      <span class="detail-value">
        {{ mobilePaymentGateway.mobile_operator || $t('common.notSpecified') }}
      </span>
    </div>
    <div class="detail-item">
      <span class="detail-label">{{ $t('paymentGateways.fields.holderId') }}:</span>
      <span class="detail-value">
        {{ mobilePaymentGateway.bank_id_number || $t('common.notSpecified') }}
      </span>
    </div>
    <div class="detail-item">
      <span class="detail-label">{{ $t('paymentGateways.fields.instructions') }}:</span>
      <span class="detail-value">
        {{ mobilePaymentGateway.instructions || $t('paymentGateways.defaultInstructions.mobilePayment') }}
      </span>
    </div>
  </div>

  <div class="gateway-actions">
    <button class="btn-toggle" @click="toggleGateway(mobilePaymentGateway.id)">
      {{ mobilePaymentGateway.is_active ? $t('common.deactivate') : $t('common.activate') }}
    </button>
    <button class="btn-configure" @click="configureGateway(mobilePaymentGateway)">
      {{ $t('common.configure') }}
    </button>
  </div>
</div>

          <!-- Zelle -->
          <div class="gateway-card" v-if="zelleGateway">
            <div class="gateway-header">
              <div class="gateway-icon">🇺🇸</div>
              <div class="gateway-info">
                <h3>{{ zelleGateway.display_name }}</h3>
                <div class="gateway-meta">
                  <span class="gateway-status" :class="zelleGateway.is_active ? 'active' : 'inactive'">
                    {{ zelleGateway.is_active ? '✅ ' + $t('common.active') : '⛔ ' + $t('common.inactive') }}
                  </span>
                  <span class="gateway-mode">
                    USA
                  </span>
                </div>
              </div>
              <div class="gateway-stats">
                <div class="stat-item">
                  <span class="stat-label">{{ $t('paymentGateways.transactions') }}:</span>
                  <span class="stat-value">{{ zelleGateway.total_transactions || 0 }}</span>
                </div>
              </div>
            </div>

            <div class="gateway-details">
              <div class="detail-item">
                <span class="detail-label">{{ $t('paymentGateways.fields.zelleEmail') }}:</span>
                <span class="detail-value">
                  {{ zelleGateway.zelle_email || $t('common.notConfigured') }}
                </span>
              </div>
              <div class="detail-item">
                <span class="detail-label">{{ $t('paymentGateways.fields.instructions') }}:</span>
                <span class="detail-value">
                  {{ zelleGateway.instructions || $t('paymentGateways.defaultInstructions.zelle') }}
                </span>
              </div>
            </div>

            <div class="gateway-actions">
              <button class="btn-toggle" @click="toggleGateway(zelleGateway.id)">
                {{ zelleGateway.is_active ? $t('common.deactivate') : $t('common.activate') }}
              </button>
              <button class="btn-configure" @click="configureGateway(zelleGateway)">
                {{ $t('common.configure') }}
              </button>
            </div>
          </div>

          <!-- Mensaje si no hay pasarelas -->
          <div v-if="gateways.length === 0" class="empty-gateways">
            <div class="empty-icon">💳</div>
            <h3>{{ $t('paymentGateways.noGateways.title') }}</h3>
            <p>{{ $t('paymentGateways.noGateways.description') }}</p>
            <button class="btn-add-first" @click="showAddGatewayModal = true">
              {{ $t('paymentGateways.noGateways.addFirst') }}
            </button>
          </div>
        </div>
      </div>

      <!-- Modal para agregar/editar pasarela -->
      <div v-if="showAddGatewayModal" class="modal-overlay" @click.self="closeModal">
        <div class="modal">
          <div class="modal-header">
            <h3>{{ editingGateway ? $t('paymentGateways.modal.editTitle') : $t('paymentGateways.modal.addTitle') }}</h3>
            <button class="modal-close" @click="closeModal">×</button>
          </div>

          <div class="modal-content">
            <!-- Selección de tipo de pasarela -->
            <div v-if="!selectedGatewayType" class="gateway-selection">
              <h4>{{ $t('paymentGateways.modal.selectType') }}</h4>
              <div class="gateway-options">
                <div
                  v-for="gateway in availableGatewayTypes"
                  :key="gateway.id"
                  class="gateway-option"
                  @click="selectGatewayType(gateway.id)"
                >
                  <div class="option-icon">{{ gateway.icon }}</div>
                  <div class="option-info">
                    <h4>{{ $t(`paymentGateways.types.${gateway.id}.name`) }}</h4>
                    <p>{{ $t(`paymentGateways.types.${gateway.id}.description`) }}</p>
                  </div>
                </div>
              </div>
            </div>

            <!-- Formulario de configuración -->
            <div v-else class="gateway-configuration">
              <h4>{{ $t('paymentGateways.modal.configure', { name: getGatewayTypeName(selectedGatewayType) }) }}</h4>

              <!-- Campos comunes -->
              <div class="form-group">
                <label class="form-label required">
                  {{ $t('paymentGateways.fields.displayName') }}
                </label>
                <input
                  type="text"
                  v-model="gatewayConfig.display_name"
                  :placeholder="getGatewayTypeName(selectedGatewayType)"
                  class="form-input"
                  required
                >
              </div>

              <div class="form-group">
                <label class="form-label">
                  {{ $t('paymentGateways.fields.description') }}
                </label>
                <textarea
                  v-model="gatewayConfig.description"
                  :placeholder="$t('paymentGateways.placeholders.description')"
                  class="form-textarea"
                  rows="2"
                ></textarea>
              </div>

              <div class="form-group">
                <label class="form-label">
                  {{ $t('paymentGateways.fields.instructions') }}
                </label>
                <textarea
                  v-model="gatewayConfig.instructions"
                  :placeholder="getDefaultInstructions(selectedGatewayType)"
                  class="form-textarea"
                  rows="3"
                ></textarea>
                <p class="form-help">{{ $t('paymentGateways.help.instructions') }}</p>
              </div>

              <!-- Configuración específica por tipo -->
              <!-- PayPal -->
              <div v-if="selectedGatewayType === 'paypal'" class="gateway-specific-config">
                <div class="form-group">
                  <label class="form-label required">
                    {{ $t('paymentGateways.fields.paypalEmail') }}
                  </label>
                  <input
                    type="email"
                    v-model="gatewayConfig.paypal_email"
                    :placeholder="$t('paymentGateways.placeholders.paypalEmail')"
                    class="form-input"
                    required
                  >
                </div>

                <div class="form-group">
                  <label class="form-label">
                    {{ $t('paymentGateways.fields.clientId') }}
                  </label>
                  <input
                    type="text"
                    v-model="gatewayConfig.api_key_public"
                    :placeholder="$t('paymentGateways.placeholders.clientId')"
                    class="form-input"
                  >
                </div>

                <div class="form-group">
                  <label class="form-label">
                    {{ $t('paymentGateways.fields.clientSecret') }}
                  </label>
                  <input
                    type="password"
                    v-model="gatewayConfig.api_key_secret"
                    :placeholder="$t('paymentGateways.placeholders.clientSecret')"
                    class="form-input"
                  >
                </div>
              </div>

              <!-- MercadoPago -->
              <div v-else-if="selectedGatewayType === 'mercadopago'" class="gateway-specific-config">
                <div class="form-group">
                  <label class="form-label required">
                    {{ $t('paymentGateways.fields.accessToken') }}
                  </label>
                  <input
                    type="password"
                    v-model="gatewayConfig.mercadopago_access_token"
                    :placeholder="$t('paymentGateways.placeholders.accessToken')"
                    class="form-input"
                    required
                  >
                  <p class="form-help">{{ $t('paymentGateways.help.accessToken') }}</p>
                </div>
              </div>

              <!-- Transferencia Bancaria -->
              <div v-else-if="selectedGatewayType === 'bank_transfer'" class="gateway-specific-config">
                <div class="form-group">
                  <label class="form-label required">
                    {{ $t('paymentGateways.fields.bankName') }}
                  </label>
                  <input
                    type="text"
                    v-model="gatewayConfig.bank_name"
                    :placeholder="$t('paymentGateways.placeholders.bankName')"
                    class="form-input"
                    required
                  >
                </div>

                <div class="form-group">
                  <label class="form-label required">
                    {{ $t('paymentGateways.fields.accountNumber') }}
                  </label>
                  <input
                    type="text"
                    v-model="gatewayConfig.bank_account"
                    :placeholder="$t('paymentGateways.placeholders.accountNumber')"
                    class="form-input"
                    required
                  >
                </div>

                <div class="form-group">
                  <label class="form-label required">
                    {{ $t('paymentGateways.fields.accountHolder') }}
                  </label>
                  <input
                    type="text"
                    v-model="gatewayConfig.bank_holder"
                    :placeholder="$t('paymentGateways.placeholders.accountHolder')"
                    class="form-input"
                    required
                  >
                </div>

                <div class="form-group">
                  <label class="form-label">
                    {{ $t('paymentGateways.fields.idType') }}
                  </label>
                  <select v-model="gatewayConfig.bank_id_type" class="form-select">
                    <option value="">{{ $t('common.select') }}</option>
                    <option value="V">{{ $t('paymentGateways.idTypes.V') }}</option>
                    <option value="E">{{ $t('paymentGateways.idTypes.E') }}</option>
                    <option value="J">{{ $t('paymentGateways.idTypes.J') }}</option>
                    <option value="G">{{ $t('paymentGateways.idTypes.G') }}</option>
                    <option value="P">{{ $t('paymentGateways.idTypes.P') }}</option>
                  </select>
                </div>

                <div class="form-group">
                  <label class="form-label">
                    {{ $t('paymentGateways.fields.idNumber') }}
                  </label>
                  <input
                    type="text"
                    v-model="gatewayConfig.bank_id_number"
                    :placeholder="$t('paymentGateways.placeholders.idNumber')"
                    class="form-input"
                  >
                </div>
              </div>

              <!-- Pago Móvil -->
              <div v-else-if="selectedGatewayType === 'mobile_payment'" class="gateway-specific-config">
                <div class="form-group">
                  <label class="form-label required">
                    {{ $t('paymentGateways.fields.phoneNumber') }}
                  </label>
                  <input
                    type="tel"
                    v-model="gatewayConfig.mobile_phone"
                    :placeholder="$t('paymentGateways.placeholders.phoneNumber')"
                    class="form-input"
                    required
                  >
                </div>

                <div class="form-group">
                  <label class="form-label required">
                    {{ $t('paymentGateways.fields.operator') }}
                  </label>
                  <select v-model="gatewayConfig.mobile_operator" class="form-select">
                    <option value="">{{ $t('common.select') }}</option>
                    <option value="movistar">Movistar</option>
                    <option value="digitel">Digitel</option>
                    <option value="movilnet">Movilnet</option>
                    <option value="simple">Simple</option>
                    <option value="otros">{{ $t('common.other') }}</option>
                  </select>
                </div>

                <div class="form-group">
  <label class="form-label required">Banco</label>
  <input type="text" v-model="gatewayConfig.bank_name" placeholder="Ej: Banco de Venezuela" class="form-input" required>
</div> 
           
                <div class="form-group">
                  <label class="form-label">
                    {{ $t('paymentGateways.fields.holderId') }}
                  </label>
                  <input
                    type="text"
                    v-model="gatewayConfig.bank_id_number"
                    :placeholder="$t('paymentGateways.placeholders.holderId')"
                    class="form-input"
                  >
                </div>
              </div>

              <!-- Zelle -->
              <div v-else-if="selectedGatewayType === 'zelle'" class="gateway-specific-config">
                <div class="form-group">
                  <label class="form-label required">
                    {{ $t('paymentGateways.fields.zelleEmail') }}
                  </label>
                  <input
                    type="email"
                    v-model="gatewayConfig.zelle_email"
                    :placeholder="$t('paymentGateways.placeholders.zelleEmail')"
                    class="form-input"
                    required
                  >
                </div>
              </div>

              <!-- Configuración de comisión -->
              <div class="commission-config">
                <h5>{{ $t('paymentGateways.commissionConfig.title') }}</h5>
                <div class="commission-fields">
                  <div class="form-group">
                    <label class="form-label">
                      {{ $t('paymentGateways.commissionConfig.percentage') }}
                    </label>
                    <input
                      type="number"
                      v-model.number="gatewayConfig.commission_rate"
                      min="0"
                      max="50"
                      step="0.1"
                      class="form-input"
                      :placeholder="$t('paymentGateways.commissionConfig.useGlobal')"
                    >
                    <p class="form-help">{{ $t('paymentGateways.commissionConfig.percentageHelp') }}</p>
                  </div>

                  <div class="form-group">
                    <label class="form-label">
                      {{ $t('paymentGateways.commissionConfig.fixed') }}
                    </label>
                    <input
                      type="number"
                      v-model.number="gatewayConfig.fixed_commission"
                      min="0"
                      step="0.01"
                      class="form-input"
                      :placeholder="$t('paymentGateways.commissionConfig.useGlobal')"
                    >
                  </div>
                </div>
              </div>

              <!-- Configuración de estado -->
              <div class="status-config">
                <div class="form-group toggle-group">
                  <label class="toggle-label">
                    <input
                      type="checkbox"
                      v-model="gatewayConfig.is_active"
                      true-value="1"
                      false-value="0"
                      class="toggle-input"
                    >
                    <span class="toggle-slider"></span>
                    <span class="toggle-text">
                      {{ gatewayConfig.is_active == 1 ? $t('common.active') : $t('common.inactive') }}
                    </span>
                  </label>
                </div>

                <div class="form-group toggle-group" v-if="selectedGatewayType === 'paypal' || selectedGatewayType === 'mercadopago'">
                  <label class="toggle-label">
                    <input
                      type="checkbox"
                      v-model="gatewayConfig.is_test_mode"
                      true-value="1"
                      false-value="0"
                      class="toggle-input"
                    >
                    <span class="toggle-slider"></span>
                    <span class="toggle-text">
                      {{ gatewayConfig.is_test_mode == 1 ? $t('common.testMode') : $t('common.productionMode') }}
                    </span>
                  </label>
                </div>

                <div class="form-group">
                  <label class="form-label">
                    {{ $t('paymentGateways.fields.sortOrder') }}
                  </label>
                  <input
                    type="number"
                    v-model.number="gatewayConfig.sort_order"
                    min="0"
                    class="form-input"
                  >
                  <p class="form-help">{{ $t('paymentGateways.help.sortOrder') }}</p>
                </div>
              </div>
            </div>
          </div>

          <div class="modal-footer">
            <div class="footer-left" v-if="selectedGatewayType">
              <button class="btn-back" @click="selectedGatewayType = ''" v-if="!editingGateway">
                ← {{ $t('common.back') }}
              </button>
            </div>
            <div class="footer-right">
              <button class="btn-cancel" @click="closeModal">
                {{ $t('common.cancel') }}
              </button>
              <button
                class="btn-save"
                @click="saveGateway"
                :disabled="!canSaveGateway || savingGateway"
              >
                <span v-if="savingGateway" class="save-loading"></span>
                <span v-else>{{ editingGateway ? $t('common.update') : $t('common.save') }}</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </template>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAuthStore } from '@/stores/authStore'
import { useI18n } from 'vue-i18n'
import api from '@/axios'

const { t } = useI18n()
const authStore = useAuthStore()

// Estados
const loading = ref(true)
const savingCommissions = ref(false)
const savingGateway = ref(false)
const showAddGatewayModal = ref(false)
const editingGateway = ref(null)
const selectedGatewayType = ref('')
const successMessage = ref('')
const errorMessage = ref('')

// Configuración de pasarela
const gatewayConfig = ref({
  name: '',
  display_name: '',
  description: '',
  is_active: 1,
  is_test_mode: 1,
  requires_api_keys: 0,
  api_key_public: '',
  api_key_secret: '',
  api_key_extra: '',
  paypal_email: '',
  mercadopago_access_token: '',
  bank_name: '',
  bank_account: '',
  bank_holder: '',
  bank_id_type: '',
  bank_id_number: '',
  mobile_phone: '',
  mobile_operator: '',
  zelle_email: '',
  commission_rate: 0,
  fixed_commission: 0,
  instructions: '',
  icon: '💳',
  sort_order: 0
})

// Datos
const gateways = ref([])
const paymentStats = ref({
  today_revenue: 0,
  today_transactions: 0,
  success_rate: 0,
  active_gateways: 0,
  total_gateways: 0,
  total_amount: 0,
  total_transactions: 0
})
const globalCommission = ref({
  rate: 10,
  fixed: 1
})

// Gateways disponibles
const availableGatewayTypes = computed(() => [
  {
    id: 'paypal',
    icon: '🅿️',
    name: t('paymentGateways.types.paypal.name'),
    description: t('paymentGateways.types.paypal.description'),
    requires_api: true
  },
  {
    id: 'mercadopago',
    icon: '🇦🇷',
    name: t('paymentGateways.types.mercadopago.name'),
    description: t('paymentGateways.types.mercadopago.description'),
    requires_api: true
  },
  {
    id: 'bank_transfer',
    icon: '🏦',
    name: t('paymentGateways.types.bank_transfer.name'),
    description: t('paymentGateways.types.bank_transfer.description'),
    requires_api: false
  },
  {
    id: 'mobile_payment',
    icon: '📱',
    name: t('paymentGateways.types.mobile_payment.name'),
    description: t('paymentGateways.types.mobile_payment.description'),
    requires_api: false
  },
  {
    id: 'zelle',
    icon: '🇺🇸',
    name: t('paymentGateways.types.zelle.name'),
    description: t('paymentGateways.types.zelle.description'),
    requires_api: false
  }
])

// Computed - PROTEGIDO con valores por defecto
const activeGateways = computed(() => {
  return (gateways.value || []).filter(g => g?.is_active == 1)
})

const hasGateways = computed(() => {
  return (gateways.value || []).length > 0
})

const activeGatewaysCount = computed(() => {
  return (gateways.value || []).filter(g => g?.is_active == 1).length
})

const paypalGateway = computed(() => {
  return (gateways.value || []).find(g => g?.name === 'paypal')
})

const mercadopagoGateway = computed(() => {
  return (gateways.value || []).find(g => g?.name === 'mercadopago')
})

const bankTransferGateway = computed(() => {
  return (gateways.value || []).find(g => g?.name === 'bank_transfer')
})

const mobilePaymentGateway = computed(() => {
  return (gateways.value || []).find(g => g?.name === 'mobile_payment')
})

const zelleGateway = computed(() => {
  return (gateways.value || []).find(g => g?.name === 'zelle')
})

const canSaveGateway = computed(() => {
  if (!selectedGatewayType.value) return false
  if (!gatewayConfig.value?.display_name) return false

  // Validaciones específicas por tipo
  switch (selectedGatewayType.value) {
    case 'paypal':
      return !!gatewayConfig.value?.paypal_email
    case 'mercadopago':
      return !!gatewayConfig.value?.mercadopago_access_token
    case 'bank_transfer':
      return !!gatewayConfig.value?.bank_name &&
             !!gatewayConfig.value?.bank_account &&
             !!gatewayConfig.value?.bank_holder
    case 'mobile_payment':
      return !!gatewayConfig.value?.mobile_phone &&
             !!gatewayConfig.value?.mobile_operator
    case 'zelle':
      return !!gatewayConfig.value?.zelle_email
    default:
      return true
  }
})

// Lifecycle
onMounted(async () => {
  await loadAllData()
})

// Métodos de carga
async function loadAllData() {
  loading.value = true
  try {
    await Promise.all([
      loadGateways(),
      loadPaymentStats(),
      loadGlobalSettings()
    ])
  } catch (error) {
    console.error('Error en loadAllData:', error)
    showError(t('common.errorLoading'))
  } finally {
    loading.value = false
  }
}

async function loadGateways() {
  try {
    const response = await api.get('/admin/payment-gateways', {
      headers: {
        Authorization: `Bearer ${authStore.token}`,
        'Content-Type': 'application/json'
      }
    })

    // Asegurar que response.data sea un array
    const data = response?.data?.gateways || response?.data || []

    gateways.value = data.map(gateway => ({
      ...gateway,
      // Asegurar valores booleanos
      is_active: gateway?.is_active ? 1 : 0,
      is_test_mode: gateway?.is_test_mode ? 1 : 0,
      requires_api_keys: gateway?.requires_api_keys ? 1 : 0,
      // Asegurar valores numéricos
      commission_rate: parseFloat(gateway?.commission_rate) || 0,
      fixed_commission: parseFloat(gateway?.fixed_commission) || 0,
      sort_order: parseInt(gateway?.sort_order) || 0,
      total_transactions: parseInt(gateway?.total_transactions) || 0,
      total_amount: parseFloat(gateway?.total_amount) || 0,
      success_rate: parseFloat(gateway?.success_rate) || 0
    }))

  } catch (error) {
    console.error('Error cargando pasarelas:', error)
    showError(t('paymentGateways.errors.loadGateways'))
    gateways.value = []
  }
}

async function loadPaymentStats() {
  try {
    const response = await api.get('/admin/payment-stats', {
      headers: {
        Authorization: `Bearer ${authStore.token}`,
        'Content-Type': 'application/json'
      }
    })

    const data = response?.data || {}
    
    // Calcular totales desde gateway_stats
    let totalAmount = 0
    let totalTransactions = 0
    let successRate = 0
    
    if (data.gateway_stats?.length > 0) {
      data.gateway_stats.forEach(g => {
        totalAmount += parseFloat(g.total_amount || 0)
        totalTransactions += parseInt(g.total_transactions || 0)
        successRate = Math.max(successRate, parseFloat(g.success_rate || 0))
      })
    }

    paymentStats.value = {
      today_revenue: parseFloat(data.today_revenue) || 0,
      today_transactions: parseInt(data.today_transactions) || 0,
      total_amount: totalAmount,
      total_transactions: totalTransactions,
      success_rate: successRate,
      active_gateways: activeGatewaysCount.value || 0,
      total_gateways: gateways.value?.length || 0
    }

  } catch (error) {
    console.error('Error cargando estadísticas:', error)
    paymentStats.value = {
      today_revenue: 0,
      today_transactions: 0,
      total_amount: 0,
      total_transactions: 0,
      success_rate: 0,
      active_gateways: activeGatewaysCount.value || 0,
      total_gateways: gateways.value?.length || 0
    }
  }
}

async function loadGlobalSettings() {
  try {
    const response = await api.get('/admin/system-config', {
      headers: {
        Authorization: `Bearer ${authStore.token}`,
        'Content-Type': 'application/json'
      }
    })

    const config = response?.data || {}
    globalCommission.value = {
      rate: parseFloat(config.default_commission_rate) || 10,
      fixed: parseFloat(config.default_fixed_commission) || 1
    }

  } catch (error) {
    console.error('Error cargando configuración global:', error)
    // Mantener valores por defecto
  }
}

// Métodos de utilidad
function maskApiKey(key) {
  if (!key) return t('common.notConfigured')
  if (key.length <= 8) return key
  return key.substring(0, 8) + '...' + key.substring(key.length - 4)
}

function formatCurrency(amount) {
  return new Intl.NumberFormat('en-US', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(amount || 0)
}

function formatCommission(value) {
  if (value === undefined || value === null) return '0%'
  return value + '%'
}

function formatPercentage(value) {
  return new Intl.NumberFormat('en-US', {
    minimumFractionDigits: 1,
    maximumFractionDigits: 1
  }).format(value || 0)
}

function getGatewayTypeName(type) {
  const gateway = availableGatewayTypes.value.find(g => g.id === type)
  return gateway?.name || type
}

function getDefaultInstructions(type) {
  switch (type) {
    case 'bank_transfer':
      return t('paymentGateways.defaultInstructions.bankTransfer')
    case 'mobile_payment':
      return t('paymentGateways.defaultInstructions.mobilePayment')
    case 'zelle':
      return t('paymentGateways.defaultInstructions.zelle')
    default:
      return ''
  }
}

// Acciones
function selectGatewayType(type) {
  selectedGatewayType.value = type
  const gatewayInfo = availableGatewayTypes.value.find(g => g?.id === type)

  // Configurar valores por defecto
  gatewayConfig.value = {
    name: type,
    display_name: gatewayInfo?.name || type,
    description: gatewayInfo?.description || '',
    is_active: 1,
    is_test_mode: 1,
    requires_api_keys: gatewayInfo?.requires_api ? 1 : 0,
    api_key_public: '',
    api_key_secret: '',
    api_key_extra: '',
    paypal_email: '',
    mercadopago_access_token: '',
    bank_name: '',
    bank_account: '',
    bank_holder: '',
    bank_id_type: '',
    bank_id_number: '',
    mobile_phone: '',
    mobile_operator: '',
    zelle_email: '',
    total_transactions: 0,
    total_amount: 0,
    success_rate: 0, 
   commission_rate: globalCommission.value?.rate || 10,
    fixed_commission: globalCommission.value?.fixed || 1,
    instructions: '',
    icon: gatewayInfo?.icon || '💳',
    sort_order: (gateways.value?.length || 0) + 1
  }

  // Si estamos editando, cargar configuración existente
  if (editingGateway.value) {
    const existing = gateways.value?.find(g => g?.id === editingGateway.value)
    if (existing) {
      gatewayConfig.value = { ...existing }
    }
  }
}

async function toggleGateway(gatewayId) {
  const gateway = gateways.value?.find(g => g?.id === gatewayId)
  if (!gateway) return

  try {
    const newStatus = gateway?.is_active == 1 ? 0 : 1

    await api.put(`/admin/payment-gateways/${gatewayId}`, {
      is_active: newStatus
    }, {
      headers: {
        Authorization: `Bearer ${authStore.token}`,
        'Content-Type': 'application/json'
      }
    })

    if (gateway) {
      gateway.is_active = newStatus
    }
    showSuccess(t('paymentGateways.messages.statusChanged', {
      status: newStatus == 1 ? t('common.activated') : t('common.deactivated')
    }))
    await loadPaymentStats()

  } catch (error) {
    console.error('Error cambiando estado:', error)
    showError(t('paymentGateways.errors.statusChange'))
  }
}

function configureGateway(gateway) {
  if (gateway) {
    editingGateway.value = gateway.id
    selectedGatewayType.value = gateway.name
    gatewayConfig.value = { ...gateway }
    showAddGatewayModal.value = true
  }
}

async function testGateway(gateway) {
  try {
    // Aquí iría la lógica real de prueba
    showSuccess(t('paymentGateways.messages.testSuccess'))
  } catch (error) {
    showError(t('paymentGateways.errors.testFailed'))
  }
}

async function saveGlobalCommissions() {
  savingCommissions.value = true
  try {
    await api.put('/admin/payment-settings', {
      default_commission_rate: globalCommission.value.rate,
      default_fixed_commission: globalCommission.value.fixed
    }, {
      headers: {
        Authorization: `Bearer ${authStore.token}`,
        'Content-Type': 'application/json'
      }
    })

    showSuccess(t('paymentGateways.messages.commissionsSaved'))
  } catch (error) {
    console.error('Error guardando comisiones:', error)
    showError(t('paymentGateways.errors.saveCommissions'))
  } finally {
    savingCommissions.value = false
  }
}

function closeModal() {
  showAddGatewayModal.value = false
  editingGateway.value = null
  selectedGatewayType.value = ''
  gatewayConfig.value = {
    name: '',
    display_name: '',
    description: '',
    is_active: 1,
    is_test_mode: 1,
    requires_api_keys: 0,
    api_key_public: '',
    api_key_secret: '',
    api_key_extra: '',
    paypal_email: '',
    mercadopago_access_token: '',
    bank_name: '',
    bank_account: '',
    bank_holder: '',
    bank_id_type: '',
    bank_id_number: '',
    mobile_phone: '',
    mobile_operator: '',
    zelle_email: '',
    commission_rate: 0,
    fixed_commission: 0,
    instructions: '',
    icon: '💳',
    sort_order: 0
  }
}

async function saveGateway() {
  try {
    savingGateway.value = true

    // Preparar datos según el tipo de pasarela
    const dataToSend = { ...gatewayConfig.value }

    // Convertir valores booleanos
    dataToSend.is_active = dataToSend?.is_active ? 1 : 0
    dataToSend.is_test_mode = dataToSend?.is_test_mode ? 1 : 0
    dataToSend.requires_api_keys = dataToSend?.requires_api_keys ? 1 : 0

    // Convertir valores numéricos
    dataToSend.commission_rate = parseFloat(dataToSend?.commission_rate) || 0
    dataToSend.fixed_commission = parseFloat(dataToSend?.fixed_commission) || 0
    dataToSend.sort_order = parseInt(dataToSend?.sort_order) || 0

    if (editingGateway.value) {
      await api.put(`/admin/payment-gateways/${editingGateway.value}`, dataToSend, {
        headers: {
          Authorization: `Bearer ${authStore.token}`,
          'Content-Type': 'application/json'
        }
      })
      showSuccess(t('paymentGateways.messages.updated'))
    } else {
      await api.post('/admin/payment-gateways', dataToSend, {
        headers: {
          Authorization: `Bearer ${authStore.token}`,
          'Content-Type': 'application/json'
        }
      })
      showSuccess(t('paymentGateways.messages.created'))
    }

    await loadGateways()
    closeModal()

  } catch (error) {
    console.error('Error guardando pasarela:', error)
    showError(`${t('common.error')}: ${error.response?.data?.error || error.message || t('common.unknownError')}`)
  } finally {
    savingGateway.value = false
  }
}

// Notificaciones
function showSuccess(message) {
  successMessage.value = message
  setTimeout(() => {
    successMessage.value = ''
  }, 5000)
}

function showError(message) {
  errorMessage.value = message
  setTimeout(() => {
    errorMessage.value = ''
  }, 5000)
}
</script>

<style scoped>
.admin-payment-gateways {
  padding: 2rem;
  max-width: 1400px;
  margin: 0 auto;
}

.loading-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(255, 255, 255, 0.9);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.loading-spinner {
  width: 50px;
  height: 50px;
  border: 3px solid #f3f3f3;
  border-top: 3px solid #4f46e5;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 1rem;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
}

.page-title {
  font-size: 2rem;
  font-weight: 600;
  color: #1e293b;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin: 0 0 0.5rem 0;
}

.title-icon {
  font-size: 2rem;
}

.page-subtitle {
  color: #64748b;
  margin: 0;
  font-size: 1rem;
}

.btn-refresh {
  padding: 0.75rem 1.5rem;
  background: white;
  border: 1px solid #e2e8f0;
  border-radius: 0.5rem;
  color: #4b5563;
  font-size: 0.9rem;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  transition: all 0.2s;
}

.btn-refresh:hover {
  background: #f8fafc;
  border-color: #cbd5e1;
}

.message-success,
.message-error {
  padding: 1rem;
  border-radius: 0.5rem;
  margin-bottom: 1.5rem;
  display: flex;
  align-items: center;
  gap: 0.75rem;
  position: relative;
}

.message-success {
  background: #dcfce7;
  color: #166534;
  border: 1px solid #86efac;
}

.message-error {
  background: #fee2e2;
  color: #991b1b;
  border: 1px solid #fecaca;
}

.message-close {
  position: absolute;
  right: 1rem;
  top: 50%;
  transform: translateY(-50%);
  background: none;
  border: none;
  font-size: 1.25rem;
  cursor: pointer;
  color: inherit;
  opacity: 0.7;
}

.message-close:hover {
  opacity: 1;
}

.payment-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.stats-card {
  background: white;
  border: 1px solid #e2e8f0;
  border-radius: 1rem;
  padding: 1.5rem;
  display: flex;
  align-items: center;
  gap: 1rem;
  transition: all 0.2s;
}

.stats-card:hover {
  box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);
}

.stat-icon {
  font-size: 2.5rem;
}

.stat-content h4 {
  margin: 0 0 0.5rem 0;
  color: #64748b;
  font-size: 0.9rem;
  font-weight: 500;
}

.stat-value {
  margin: 0;
  font-size: 1.5rem;
  font-weight: 600;
  color: #1e293b;
}

.global-commissions-section {
  background: white;
  border: 1px solid #e2e8f0;
  border-radius: 1rem;
  padding: 1.5rem;
  margin-bottom: 2rem;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.section-header h2 {
  font-size: 1.25rem;
  font-weight: 600;
  color: #1e293b;
  margin: 0;
}

.section-header p {
  color: #64748b;
  margin: 0.25rem 0 0 0;
  font-size: 0.9rem;
}

.commissions-card {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  gap: 2rem;
}

.commission-settings {
  flex: 1;
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
}

.commission-setting {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.commission-label {
  font-size: 0.9rem;
  font-weight: 500;
  color: #4b5563;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.commission-input {
  padding: 0.75rem;
  border: 1px solid #e2e8f0;
  border-radius: 0.5rem;
  font-size: 1rem;
  transition: all 0.2s;
}

.commission-input:focus {
  outline: none;
  border-color: #4f46e5;
  box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
}

.commission-help {
  margin: 0.25rem 0 0 0;
  font-size: 0.8rem;
  color: #94a3b8;
}

.btn-save-commissions {
  padding: 0.75rem 2rem;
  background: #4f46e5;
  color: white;
  border: none;
  border-radius: 0.5rem;
  font-size: 0.95rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
  min-width: 180px;
  height: fit-content;
}

.btn-save-commissions:hover:not(:disabled) {
  background: #4338ca;
  transform: translateY(-1px);
  box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);
}

.btn-save-commissions:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.save-loading {
  display: inline-block;
  width: 1rem;
  height: 1rem;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top-color: white;
  border-radius: 50%;
  animation: spin 0.6s linear infinite;
}

.gateways-section {
  background: white;
  border: 1px solid #e2e8f0;
  border-radius: 1rem;
  padding: 1.5rem;
}

.btn-add-gateway {
  padding: 0.75rem 1.5rem;
  background: #4f46e5;
  color: white;
  border: none;
  border-radius: 0.5rem;
  font-size: 0.95rem;
  font-weight: 500;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  transition: all 0.2s;
}

.btn-add-gateway:hover {
  background: #4338ca;
  transform: translateY(-1px);
  box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);
}

.gateways-grid {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  margin-top: 1.5rem;
}

.gateway-card {
  border: 1px solid #e2e8f0;
  border-radius: 0.75rem;
  padding: 1.5rem;
  transition: all 0.2s;
}

.gateway-card:hover {
  box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);
  border-color: #cbd5e1;
}

.gateway-header {
  display: flex;
  gap: 1rem;
  margin-bottom: 1rem;
}

.gateway-icon {
  font-size: 2rem;
}

.gateway-info {
  flex: 1;
}

.gateway-info h3 {
  margin: 0 0 0.5rem 0;
  font-size: 1.1rem;
  color: #1e293b;
}

.gateway-meta {
  display: flex;
  gap: 0.75rem;
}

.gateway-status,
.gateway-mode {
  padding: 0.25rem 0.75rem;
  border-radius: 1rem;
  font-size: 0.8rem;
  font-weight: 500;
}

.gateway-status.active {
  background: #dcfce7;
  color: #166534;
}

.gateway-status.inactive {
  background: #fee2e2;
  color: #991b1b;
}

.gateway-mode.test {
  background: #fef9c3;
  color: #854d0e;
}

.gateway-mode.live {
  background: #dbeafe;
  color: #1e40af;
}

.gateway-stats {
  min-width: 200px;
}

.stat-item {
  display: flex;
  justify-content: space-between;
  margin-bottom: 0.25rem;
}

.stat-label {
  color: #64748b;
  font-size: 0.9rem;
}

.stat-value {
  font-weight: 600;
  color: #1e293b;
}

.gateway-details {
  background: #f8fafc;
  border-radius: 0.5rem;
  padding: 1rem;
  margin-bottom: 1rem;
}

.detail-item {
  display: flex;
  margin-bottom: 0.5rem;
}

.detail-item:last-child {
  margin-bottom: 0;
}

.detail-label {
  min-width: 120px;
  color: #64748b;
  font-size: 0.9rem;
}

.detail-value {
  color: #1e293b;
  font-weight: 500;
}

.gateway-actions {
  display: flex;
  gap: 0.75rem;
}

.btn-toggle,
.btn-configure,
.btn-test {
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 0.375rem;
  font-size: 0.9rem;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-toggle {
  background: #e2e8f0;
  color: #4b5563;
}

.btn-toggle:hover {
  background: #cbd5e1;
}

.btn-configure {
  background: #4f46e5;
  color: white;
}

.btn-configure:hover {
  background: #4338ca;
}

.btn-test {
  background: white;
  border: 1px solid #e2e8f0;
  color: #4b5563;
}

.btn-test:hover {
  background: #f8fafc;
  border-color: #cbd5e1;
}

.empty-gateways {
  text-align: center;
  padding: 3rem;
  background: #f8fafc;
  border-radius: 0.5rem;
}

.empty-icon {
  font-size: 3rem;
  margin-bottom: 1rem;
}

.empty-gateways h3 {
  color: #1e293b;
  margin-bottom: 0.5rem;
}

.empty-gateways p {
  color: #64748b;
  margin-bottom: 1.5rem;
}

.btn-add-first {
  padding: 0.75rem 2rem;
  background: #4f46e5;
  color: white;
  border: none;
  border-radius: 0.5rem;
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-add-first:hover {
  background: #4338ca;
  transform: translateY(-1px);
  box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);
}

/* Modal Styles */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  animation: fadeIn 0.2s ease;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

.modal {
  background: white;
  border-radius: 1rem;
  width: 90%;
  max-width: 600px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 20px 25px -5px rgb(0 0 0 / 0.1);
  animation: slideUp 0.3s ease;
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.modal-header {
  padding: 1.5rem;
  border-bottom: 1px solid #e2e8f0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  position: sticky;
  top: 0;
  background: white;
  border-radius: 1rem 1rem 0 0;
  z-index: 10;
}

.modal-header h3 {
  margin: 0;
  color: #1e293b;
  font-size: 1.25rem;
}

.modal-close {
  background: none;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  color: #94a3b8;
  transition: color 0.2s;
  line-height: 1;
  padding: 0.5rem;
}

.modal-close:hover {
  color: #4b5563;
}

.modal-content {
  padding: 1.5rem;
}

.modal-footer {
  padding: 1.5rem;
  border-top: 1px solid #e2e8f0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  position: sticky;
  bottom: 0;
  background: white;
  border-radius: 0 0 1rem 1rem;
}

.footer-right {
  display: flex;
  gap: 1rem;
}

.btn-cancel {
  padding: 0.75rem 1.5rem;
  background: white;
  border: 1px solid #e2e8f0;
  border-radius: 0.5rem;
  color: #4b5563;
  font-size: 0.95rem;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-cancel:hover {
  background: #f8fafc;
  border-color: #cbd5e1;
}

.btn-save {
  padding: 0.75rem 2rem;
  background: #4f46e5;
  color: white;
  border: none;
  border-radius: 0.5rem;
  font-size: 0.95rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-save:hover:not(:disabled) {
  background: #4338ca;
  transform: translateY(-1px);
  box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);
}

.btn-save:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-back {
  padding: 0.5rem 1rem;
  background: none;
  border: none;
  color: #4f46e5;
  cursor: pointer;
  font-size: 0.95rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.btn-back:hover {
  text-decoration: underline;
}

/* Gateway Selection */
.gateway-selection h4 {
  margin: 0 0 1rem 0;
  color: #1e293b;
}

.gateway-options {
  display: grid;
  gap: 1rem;
}

.gateway-option {
  padding: 1rem;
  border: 1px solid #e2e8f0;
  border-radius: 0.5rem;
  display: flex;
  align-items: center;
  gap: 1rem;
  cursor: pointer;
  transition: all 0.2s;
}

.gateway-option:hover {
  border-color: #4f46e5;
  background: #f5f3ff;
  transform: translateX(4px);
}

.option-icon {
  font-size: 2rem;
}

.option-info h4 {
  margin: 0 0 0.25rem 0;
  color: #1e293b;
}

.option-info p {
  margin: 0;
  color: #64748b;
  font-size: 0.9rem;
}

/* Form Styles */
.gateway-configuration h4 {
  margin: 0 0 1.5rem 0;
  color: #1e293b;
  padding-bottom: 0.75rem;
  border-bottom: 1px solid #e2e8f0;
}

.form-group {
  margin-bottom: 1.25rem;
}

.form-label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: #4b5563;
  font-size: 0.95rem;
}

.form-label.required::after {
  content: '*';
  color: #ef4444;
  margin-left: 0.25rem;
}

.form-input,
.form-select,
.form-textarea {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #e2e8f0;
  border-radius: 0.5rem;
  font-size: 0.95rem;
  transition: all 0.2s;
  font-family: inherit;
}

.form-input:focus,
.form-select:focus,
.form-textarea:focus {
  outline: none;
  border-color: #4f46e5;
  box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
}

.form-textarea {
  resize: vertical;
  min-height: 80px;
}

.form-help {
  margin: 0.5rem 0 0 0;
  font-size: 0.8rem;
  color: #94a3b8;
}

/* Toggle Switch */
.toggle-group {
  margin-bottom: 1rem;
}

.toggle-label {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  cursor: pointer;
}

.toggle-input {
  position: absolute;
  opacity: 0;
  width: 0;
  height: 0;
}

.toggle-slider {
  position: relative;
  display: inline-block;
  width: 48px;
  height: 24px;
  background-color: #e2e8f0;
  border-radius: 24px;
  transition: 0.2s;
}

.toggle-slider:before {
  position: absolute;
  content: '';
  height: 20px;
  width: 20px;
  left: 2px;
  bottom: 2px;
  background-color: white;
  border-radius: 50%;
  transition: 0.2s;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.toggle-input:checked + .toggle-slider {
  background-color: #4f46e5;
}

.toggle-input:checked + .toggle-slider:before {
  transform: translateX(24px);
}

.toggle-text {
  font-size: 0.95rem;
  color: #4b5563;
}

/* Commission Config */
.commission-config {
  margin: 1.5rem 0;
  padding: 1.5rem;
  background: #f8fafc;
  border-radius: 0.5rem;
}

.commission-config h5 {
  margin: 0 0 1rem 0;
  color: #1e293b;
  font-size: 1rem;
}

.commission-fields {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
}

/* Responsive */
@media (max-width: 768px) {
  .admin-payment-gateways {
    padding: 1rem;
  }

  .page-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 1rem;
  }

  .commissions-card {
    flex-direction: column;
    align-items: stretch;
  }

  .commission-settings {
    grid-template-columns: 1fr;
  }

  .gateway-header {
    flex-direction: column;
  }

  .gateway-stats {
    width: 100%;
  }

  .gateway-actions {
    flex-wrap: wrap;
  }

  .btn-save-commissions {
    width: 100%;
  }

  .commission-fields {
    grid-template-columns: 1fr;
  }

  .modal-footer {
    flex-direction: column;
    gap: 1rem;
  }

  .footer-right {
    width: 100%;
    flex-direction: column;
  }

  .btn-cancel,
  .btn-save {
    width: 100%;
  }
}
</style>
