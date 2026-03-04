import { mount } from '@vue/test-utils'
import { describe, it, expect } from 'vitest'
import App from '../src/App.vue'

describe('App.vue', () => {
  it('renders logo and title', () => {
    const wrapper = mount(App)
    expect(wrapper.find('h1').text()).toBe('Entitybase Orchestrator')
  })

  it('renders all services', () => {
    const wrapper = mount(App)
    const cards = wrapper.findAll('.card')
    expect(cards.length).toBe(11)
  })

  it('renders services section with correct links', () => {
    const wrapper = mount(App)
    const serviceCards = wrapper.findAll('.card:not(.worker)')
    expect(serviceCards.length).toBe(5)
  })

  it('renders workers section with correct links', () => {
    const wrapper = mount(App)
    const workerCards = wrapper.findAll('.card.worker')
    expect(workerCards.length).toBe(6)
  })
})
