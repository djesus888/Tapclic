import { mount } from '@vue/test-utils'
import { describe, it, expect, vi, beforeEach } from 'vitest'
import Soporte from '../../components/shared/Soporte.vue'
import { useToast } from '../../composables/useToast'

// Mock del composable useToast
vi.mock('../../composables/useToast', () => ({
  useToast: vi.fn(() => ({
    success: vi.fn(),
    error: vi.fn(),
    info: vi.fn(),
    warning: vi.fn()
  }))
}))

// Mock de $t y $i18n
const mockI18n = {
  locale: { value: 'es' },
  t: (key) => key
}

describe('Soporte.vue', () => {
  const mockTickets = [
    {
      id: 1,
      subject: 'Problema con el pago',
      last_message: 'No puedo procesar mi pago',
      status: 'open',
      updated_at: '2024-01-15T10:00:00Z',
      created_at: '2024-01-15T09:00:00Z',
      priority: 'high'
    },
    {
      id: 2,
      subject: 'Duda sobre mi suscripción',
      last_message: '¿Cómo cancelo mi plan?',
      status: 'pending',
      updated_at: '2024-01-14T15:30:00Z',
      created_at: '2024-01-14T14:00:00Z'
    }
  ]

  const mockFaqItems = [
    {
      id: 1,
      question: '¿Cómo cambio mi contraseña?',
      answer: 'Puedes cambiarla en Configuración > Seguridad'
    },
    {
      id: 2,
      question: '¿Cuánto tarda el soporte?',
      answer: 'Normalmente respondemos en menos de 24 horas'
    }
  ]

  const wrapper = mount(Soporte, {
    props: {
      tickets: mockTickets,
      faqItems: mockFaqItems,
      loadingTickets: false,
      loadingFaq: false
    },
    global: {
      mocks: {
        $t: mockI18n.t,
        $i18n: mockI18n
      },
      stubs: {
        SoporteFaqItem: true,
        SoporteTicketCard: true,
        SoporteLoading: true,
        SoporteTicketModal: true,
        SoporteToastContainer: true
      }
    }
  })

  it('renderiza correctamente con datos', () => {
    expect(wrapper.exists()).toBe(true)
    expect(wrapper.find('.soporte-section-title').text()).toContain('faq')
  })

  it('muestra estado vacío cuando no hay tickets', async () => {
    await wrapper.setProps({ tickets: [] })
    expect(wrapper.find('.soporte-empty-state').exists()).toBe(true)
  })

  it('muestra loading states cuando está cargando', async () => {
    await wrapper.setProps({ 
      loadingTickets: true,
      loadingFaq: true 
    })
    expect(wrapper.findAllComponents({ name: 'SoporteLoading' })).toHaveLength(2)
  })

  it('emite evento open-support-chat al hacer clic en el botón de chat', async () => {
    await wrapper.setProps({ loadingTickets: false })
    const chatButton = wrapper.find('.soporte-btn-support-chat')
    await chatButton.trigger('click')
    expect(wrapper.emitted('open-support-chat')).toBeTruthy()
  })

  it('emite evento show-new-ticket al hacer clic en el botón flotante', async () => {
    const fabButton = wrapper.find('.soporte-floating-btn')
    await fabButton.trigger('click')
    expect(wrapper.emitted('show-new-ticket')).toBeTruthy()
  })

  it('toggle FAQ correctamente', async () => {
    const faqComponent = wrapper.findComponent({ name: 'SoporteFaqItem' })
    await faqComponent.vm.$emit('toggle', 1)
    
    // Verificar que el estado interno cambió
    expect(wrapper.vm.activeFaq).toBe(1)
  })

  it('abre modal de ticket correctamente', async () => {
    const ticketCard = wrapper.findComponent({ name: 'SoporteTicketCard' })
    await ticketCard.vm.$emit('click', mockTickets[0])
    
    expect(wrapper.vm.showModal).toBe(true)
    expect(wrapper.vm.selectedTicket).toEqual(mockTickets[0])
    expect(wrapper.emitted('open-ticket')).toBeTruthy()
  })
})

describe('SoporteFaqItem.vue', () => {
  import SoporteFaqItem from '../../components/shared/SoporteFaqItem.vue'
  
  const mockItem = {
    id: 1,
    question: '¿Pregunta de prueba?',
    answer: '<p>Respuesta con <b>HTML</b></p>'
  }

  it('sanitiza HTML correctamente', () => {
    const wrapper = mount(SoporteFaqItem, {
      props: {
        item: mockItem,
        isActive: false
      }
    })
    
    // El HTML debería estar sanitizado pero mantener etiquetas permitidas
    expect(wrapper.vm.sanitizedQuestion).toBe('¿Pregunta de prueba?')
    expect(wrapper.vm.sanitizedAnswer).toContain('<b>HTML</b>')
    expect(wrapper.vm.sanitizedAnswer).not.toContain('<script>')
  })
})
