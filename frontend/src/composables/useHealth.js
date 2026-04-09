import { ref } from 'vue'

const healthStatus = ref({})
const producerStatus = ref({})

export function useHealth() {
  async function checkHealth(item) {
    const urlToCheck = item.brokerUrl || item.url
    const healthPath = item.brokerHealthPath || item.healthPath

    if (!healthPath) {
      healthStatus.value[item.url] = 'unhealthy'
      return
    }
    try {
      await fetch(`${urlToCheck}${healthPath}`, { method: 'GET', mode: 'no-cors' })
      healthStatus.value[item.url] = 'healthy'
    } catch {
      healthStatus.value[item.url] = 'unhealthy'
    }
  }

  async function checkProducerHealth(item) {
    if (!item.producerKey) return

    try {
      const response = await fetch(`${item.url}${item.healthPath}`)
      const data = await response.json()
      const status = data.producers?.[item.producerKey] || 'not_configured'
      producerStatus.value[item.producerKey] = status
    } catch {
      producerStatus.value[item.producerKey] = 'disconnected'
    }
  }

  function getStatus(item) {
    if (item.producerKey) {
      return producerStatus.value[item.producerKey] || 'unhealthy'
    }
    return healthStatus.value[item.url] || 'unhealthy'
  }

  async function checkAll(items) {
    for (const item of items) {
      if (item.producerKey) {
        await checkProducerHealth(item)
      } else {
        await checkHealth(item)
      }
    }
  }

  return {
    healthStatus,
    producerStatus,
    checkHealth,
    checkProducerHealth,
    getStatus,
    checkAll,
  }
}