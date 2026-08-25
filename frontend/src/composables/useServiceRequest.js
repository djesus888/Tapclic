// frontend/src/composables/useServiceRequest.js
import { ref } from 'vue'
import { useAuthStore } from '@/stores/authStore'
import { useSocketStore } from '@/stores/socketStore'
import api from '@/axios'
import Swal from 'sweetalert2'

export function useServiceRequest() {
  const authStore = useAuthStore()
  const socketStore = useSocketStore()

  // Estados reactivos
  const modalService = ref(null)
  const showRequestConfirmation = ref(false)
  const showProviderContact = ref(false)
  const showPayment = ref(false)
  const showLiveTracking = ref(false)
  const liveOrder = ref(null)
  const showReviewModal = ref(false)
  const reviewData = ref({ rating: 0, comment: '', tags: [], photos: [] })
  const reviewServiceHistoryId = ref(null)
  const lastSpecDetails = ref('')

  // Callbacks para refrescar datos (se configuran desde el Dashboard)
  let refreshCallbacks = {
    activeRequests: null,
    history: null,
    services: null
  }

  // Configurar callbacks de refresco
  function setRefreshCallbacks(callbacks) {
    refreshCallbacks = { ...refreshCallbacks, ...callbacks }
  }

  // Normalizar datos del servicio (VERSIÓN COMPLETA)
  function normalizeService(service) {
    if (!service) return null

    const p = service.provider && typeof service.provider === 'object' ? service.provider : {}

    // Parsear métodos de pago
    let paymentInfo = {}
    try {
      const methods = typeof service.payment_methods === 'string'
        ? JSON.parse(service.payment_methods)
        : service.payment_methods || []

      if (Array.isArray(methods)) {
        methods.forEach(m => {
          if (m.method_type === 'pago_movil') {
            paymentInfo.pagoMovil = {
              banco: m.bank_name,
              telefono: m.phone_number,
              cedula: m.id_number
            }
          }
          if (m.method_type === 'transferencia') {
            paymentInfo.transferencia = {
              banco: m.bank_name,
              cuenta: m.account_number,
              cedula: m.id_number
            }
          }
          if (m.method_type === 'paypal') {
            paymentInfo.paypal = { email: m.email }
          }
          if (m.method_type === 'zelle') {
            paymentInfo.zelle = { email: m.email }
          }
        })
      }
    } catch (e) {
      console.warn('Error parseando payment_methods:', e)
    }

    return {
      ...service,
      id: service.id || service.service_id,
      title: service.title || service.name || service.service_title || 'Servicio',
      description: service.description || service.details || service.service_details || '',
      price: Number(service.price || service.total_price || service.service_price || 0),
      service_details: service.service_details || service.details || '',
      provider: {
        id: p.id || service.provider_id || service.providerId || service.user_id || null,
        name: p.name || service.provider_name || 'Proveedor',
        avatar_url: p.avatar_url || service.provider_avatar_url || '',
        rating: p.rating ?? service.provider_rating ?? null,
        paymentInfo: Object.keys(paymentInfo).length ? paymentInfo : undefined,
      },
      requestId: service.requestId || service.request_id || null,
      status: service.status || 'pending',
      payment_status: service.payment_status || 'pending',
      payment_methods: service.payment_methods || [],
    }
  }

  // Abrir detalles del servicio
  function openServiceDetails(service) {
    resetFlow()
    modalService.value = normalizeService(service)
    showRequestConfirmation.value = false
    // El modal de detalles se maneja con evento en el template
  }

  // Ir a confirmación de solicitud
  function goToRequestConfirmation() {
    showRequestConfirmation.value = true
  }

  // Confirmar solicitud (llama a la API)
  async function onConfirmRequest(payload) {
    try {
      const { details, contractAccepted } = payload || {}

      if (!contractAccepted) {
        Swal.fire({
          icon: 'warning',
          title: 'Contrato',
          text: 'Debes aceptar las condiciones del servicio.'
        })
        return false
      }

      const serviceId = modalService.value?.id
      const providerId = modalService.value?.provider?.id

      if (!serviceId || !providerId) {
        Swal.fire({
          icon: 'error',
          title: 'Error',
          text: 'Faltan datos del servicio o proveedor.'
        })
        return false
      }

      const payloadRequest = {
        service_id: serviceId,
        provider_id: providerId,
        price: Number(modalService.value.price) || 0,
        payment_method: 'efectivo',
        additional_details: details || '',
      }

      const res = await api.post('/requests/create', payloadRequest, {
        headers: authStore?.token ? { Authorization: `Bearer ${authStore.token}` } : {},
      })

      if (!res.data?.success) {
        throw new Error(res.data?.error || 'No se pudo crear la solicitud')
      }

      modalService.value = {
        ...modalService.value,
        requestId: res.data.requestId,
        status: res.data.status || 'pending',
      }

      lastSpecDetails.value = details || ''
      showRequestConfirmation.value = false
      showProviderContact.value = true

      return true
    } catch (err) {
      console.error('Error al crear solicitud:', err)
      const status = err.response?.status
      let title = 'Error'
      let text = err.message

      if (status === 409) {
        title = 'Solicitud duplicada'
        text = 'Ya tienes una solicitud activa con este proveedor'
      }

      Swal.fire({ icon: 'error', title, text })
      return false
    }
  }

  // Respuesta del proveedor (aceptó/rechazó/ocupado)
  async function onProviderResponse(status) {
    showProviderContact.value = false

    if (status === 'accepted' && modalService.value?.requestId) {
      openPaymentModal()
    } else {
      const { isConfirmed } = await Swal.fire({
        icon: status === 'rejected' ? 'error' : 'warning',
        title: status === 'rejected' ? 'Solicitud rechazada' : 'Proveedor ocupado',
        text: status === 'rejected'
          ? 'El proveedor ha rechazado tu solicitud. ¿Deseas intentar de nuevo?'
          : 'El proveedor está ocupado en este momento. ¿Deseas intentar más tarde?',
        showCancelButton: true,
        confirmButtonText: 'Intentar de nuevo',
        cancelButtonText: 'Cancelar',
      })

      if (isConfirmed) {
        // Reintentar
        showRequestConfirmation.value = true
      } else {
        resetFlow()
      }
    }
  }

  // Abrir modal de pago
  function openPaymentModal(order = null) {
    if (order) {
      modalService.value = normalizeService(order)
    }

    if (!modalService.value) {
      console.error('❌ [useServiceRequest] modalService es null. No se puede abrir el pago.')
      return
    }

    showRequestConfirmation.value = false
    showProviderContact.value = false
    showPayment.value = true
  }

  // Pago enviado
  function handlePaymentSubmit(method) {
    if (!modalService.value?.requestId) return

    showPayment.value = false

    Swal.fire({
      icon: 'success',
      title: 'Pago completado',
      text: `${modalService.value?.title || 'Servicio'} - ${method}`,
      timer: 2000,
      showConfirmButton: false
    })

    // Refrescar datos
    if (refreshCallbacks.activeRequests) refreshCallbacks.activeRequests()
    if (refreshCallbacks.history) refreshCallbacks.history()

    resetFlow()
  }

  // Abrir LiveTracking
  function openLiveTracking(request) {
    liveOrder.value = {
      id: request.id || request.requestId,
      requestId: request.id || request.requestId,
      serviceName: request.service_title || request.title || 'Servicio',
      description: request.service_description || request.description || 'Sin descripción',
      price: Number(request.service_price || request.price || 0),
      payment_method: request.payment_method || 'Efectivo',
      created_at: request.created_at || request.date,
      address: request.provider_address || 'No especificada',
      provider: {
        name: request.provider_name || request.provider?.name || 'Proveedor',
        avatar_url: request.provider_avatar_url || request.provider?.avatar_url || '/img/default-provider.png',
        rating: request.provider_rating || request.provider?.rating || null,
        phone: request.provider_phone || request.provider?.phone || null,
        current_address: request.provider_address || 'No especificada',
      },
      provider_id: request.provider_id || request.provider?.id,
      user_id: request.user_id,
      status: request.status || 'accepted',
      payment_methods: request.payment_methods || [],
    }
    showLiveTracking.value = true
  }

  // Abrir modal de reseña
  function openReviewModal(requestId, targetRole = 'provider') {
    reviewData.value = { rating: 0, comment: '', tags: [], photos: [] }
    reviewServiceHistoryId.value = requestId
    showReviewModal.value = true
  }

  // Reseña guardada
  function onReviewSaved() {
    console.log('✅ Reseña guardada correctamente')
    showReviewModal.value = false
    reviewServiceHistoryId.value = null
    if (refreshCallbacks.history) refreshCallbacks.history()
  }

  // Reiniciar flujo completo
  function resetFlow() {
    showRequestConfirmation.value = false
    showProviderContact.value = false
    showPayment.value = false
    showLiveTracking.value = false
    showReviewModal.value = false
    modalService.value = null
    liveOrder.value = null
    lastSpecDetails.value = ''
  }

  // Reintentar solicitud
  function handleRetry() {
    showRequestConfirmation.value = true
  }

  // ===== SOCKET HANDLERS PARA CLIENTE =====
  let socketHandlers = []

  function setupClientSocketHandlers() {
    if (!socketStore) return

    const requestUpdatedHandler = (data) => {
      console.log('🔔 [Cliente] Evento request_updated recibido:', data)
      const requestData = data.request || data
      const requestId = requestData.id || requestData.request_id
      const status = requestData.status

      if (requestId && status) {
        // Actualizar liveOrder si está abierto
        if (showLiveTracking.value && liveOrder.value?.requestId === requestId) {
          liveOrder.value = { ...liveOrder.value, status }
        }

        // Si se completó/canceló/rechazó, refrescar
        if (['completed', 'cancelled', 'rejected'].includes(status)) {
          if (refreshCallbacks.activeRequests) refreshCallbacks.activeRequests()
          if (refreshCallbacks.history) refreshCallbacks.history()
        } else {
          if (refreshCallbacks.activeRequests) refreshCallbacks.activeRequests()
        }

        // Notificación sonora
        socketStore.playNotificationSound?.()
      }
    }

    const paymentUpdatedHandler = (data) => {
      console.log('🔔 [Cliente] Evento payment_updated recibido:', data)
      if (data.request_id && data.payment_status) {
        if (showPayment.value && modalService.value?.requestId === data.request_id) {
          modalService.value = {
            ...modalService.value,
            payment_status: data.payment_status
          }
        }
      }
    }


    socketStore.on('request_updated', requestUpdatedHandler)
    socketStore.on('payment_updated', paymentUpdatedHandler)

    socketHandlers = [
      { event: 'request_updated', handler: requestUpdatedHandler },
      { event: 'payment_updated', handler: paymentUpdatedHandler },
    ]
  }

  function cleanupClientSocketHandlers() {
    if (!socketStore) return
    socketHandlers.forEach(({ event, handler }) => {
      socketStore.off(event, handler)
    })
    socketHandlers = []
  }

  return {
    // Estados
    modalService,
    showRequestConfirmation,
    showProviderContact,
    showPayment,
    showLiveTracking,
    liveOrder,
    showReviewModal,
    reviewData,
    reviewServiceHistoryId,
    lastSpecDetails,

    // Configuración
    setRefreshCallbacks,

    // Métodos de normalización
    normalizeService,

    // Flujo de solicitud
    openServiceDetails,
    goToRequestConfirmation,
    onConfirmRequest,
    onProviderResponse,

    // Pago
    openPaymentModal,
    handlePaymentSubmit,

    // Tracking
    openLiveTracking,

    // Reseñas
    openReviewModal,
    onReviewSaved,

    // Control de flujo
    resetFlow,
    handleRetry,

    // Socket handlers
    setupClientSocketHandlers,
    cleanupClientSocketHandlers,
  }
}
