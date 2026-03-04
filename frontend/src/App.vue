<script setup>
import { ref, onMounted } from 'vue'

const services = [
  { name: 'Backend API', url: 'http://localhost:8083', description: 'Main API server', healthPath: '/health' },
  { name: 'Server-Sent Events Frontend', url: 'http://localhost:8889', description: 'Server-Sent Events UI', healthPath: '/health' },
  { name: 'Server-Sent Events Backend', url: 'http://localhost:8888', description: 'Server-Sent Events API', healthPath: '/health' },
  { name: 'MinIO Console', url: 'http://localhost:9001', description: 'S3-compatible storage', healthPath: '/minio/health/live' },
  { name: 'Redpanda Console', url: 'http://localhost:9644', description: 'Kafka messaging', healthPath: '' },
]

const workers = [
  { name: 'ID Worker', url: 'http://localhost:8001', healthPath: '/health' },
  { name: 'JSON Dump Worker', url: 'http://localhost:8002', healthPath: '/health' },
  { name: 'TTL Dump Worker', url: 'http://localhost:8003', healthPath: '/health' },
  { name: 'Backlink Stats Worker', url: 'http://localhost:8004', healthPath: '/health' },
  { name: 'General Stats Worker', url: 'http://localhost:8005', healthPath: '/health' },
  { name: 'User Stats Worker', url: 'http://localhost:8006', healthPath: '/health' },
]

const healthStatus = ref({})

async function checkHealth(item) {
  if (!item.healthPath) {
    healthStatus.value[item.url] = 'unknown'
    return
  }
  try {
    await fetch(`${item.url}${item.healthPath}`, { method: 'GET', mode: 'no-cors' })
    healthStatus.value[item.url] = 'healthy'
  } catch {
    healthStatus.value[item.url] = 'unhealthy'
  }
}

function getStatus(item) {
  return healthStatus.value[item.url] || 'unknown'
}

onMounted(async () => {
  for (const service of services) {
    await checkHealth(service)
  }
  for (const worker of workers) {
    await checkHealth(worker)
  }
  setInterval(async () => {
    for (const service of services) {
      await checkHealth(service)
    }
    for (const worker of workers) {
      await checkHealth(worker)
    }
  }, 30000)
})
</script>

<template>
  <div class="container">
    <header>
      <img src="/entitybase-logo.png" alt="Entitybase" class="logo" />
      <h1>Entitybase Orchestrator</h1>
    </header>

    <section>
      <h2>Services</h2>
      <div class="grid">
        <a v-for="service in services" :key="service.url" :href="service.url" class="card" target="_blank">
          <div class="card-header">
            <h3>{{ service.name }}</h3>
            <span class="status" :class="getStatus(service)"></span>
          </div>
          <p>{{ service.description }}</p>
          <span class="url">{{ service.url }}</span>
        </a>
      </div>
    </section>

    <section>
      <h2>Workers</h2>
      <div class="grid">
        <a v-for="worker in workers" :key="worker.url" :href="worker.url" class="card worker" target="_blank">
          <div class="card-header">
            <h3>{{ worker.name }}</h3>
            <span class="status" :class="getStatus(worker)"></span>
          </div>
          <span class="url">{{ worker.url }}</span>
        </a>
      </div>
    </section>
  </div>
</template>

<style scoped>
.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}

header {
  text-align: center;
  margin-bottom: 3rem;
}

.logo {
  max-width: 400px;
  width: 100%;
  height: auto;
  margin-bottom: 1rem;
}

h1 {
  font-size: 2rem;
  color: #333;
  margin: 0;
}

h2 {
  font-size: 1.5rem;
  color: #555;
  margin-bottom: 1rem;
  margin-top: 2rem;
}

.grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 1rem;
}

.card {
  display: flex;
  flex-direction: column;
  padding: 1.5rem;
  border: 1px solid #ddd;
  border-radius: 8px;
  text-decoration: none;
  color: inherit;
  transition: box-shadow 0.2s, transform 0.2s;
  background: #fff;
}

.card:hover {
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
  transform: translateY(-2px);
}

.card h3 {
  margin: 0 0 0.5rem 0;
  font-size: 1.1rem;
}

.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.status {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  flex-shrink: 0;
}

.status.healthy {
  background: #22c55e;
}

.status.unhealthy {
  background: #ef4444;
}

.status.unknown {
  background: #f59e0b;
}

.card p {
  margin: 0 0 0.5rem 0;
  color: #666;
  font-size: 0.9rem;
}

.url {
  font-size: 0.8rem;
  color: #888;
  margin-top: auto;
}

.worker {
  background: #f9f9f9;
}
</style>
