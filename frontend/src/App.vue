<script setup>
import { ref, onMounted } from 'vue'

const HOST = import.meta.env.VITE_HOST || 'localhost'

const infrastructure = [
  { name: 'MinIO', url: `http://${HOST}:9001`, description: 'S3 storage + console', healthPath: '/minio/health/live', linkUrl: `http://${HOST}:9001` },
  { name: 'MySQL', url: `http://${HOST}:3307`, description: 'Database (no HTTP interface)', healthPath: '/' },
  { name: 'Redpanda', url: `http://${HOST}:8084`, description: 'Kafka messaging + console', healthPath: '', linkUrl: `http://${HOST}:8084`, brokerUrl: `http://${HOST}:9644`, brokerHealthPath: '/status' },
]

const services = [
  { name: 'Backend API', url: `http://${HOST}:8083`, description: 'Main API server', healthPath: '/health' },
  { name: 'Server-Sent Events Frontend', url: `http://${HOST}:8889`, description: 'Server-Sent Events UI', healthPath: '/health' },
  { name: 'Server-Sent Events Backend', url: `http://${HOST}:8888`, description: 'Server-Sent Events API', healthPath: '/health' },
]

const workers = [
  { name: 'ID Worker', url: `http://${HOST}:8001`, healthPath: '/health' },
  { name: 'JSON Dump Worker', url: `http://${HOST}:8002`, healthPath: '/health' },
  { name: 'TTL Dump Worker', url: `http://${HOST}:8003`, healthPath: '/health' },
  { name: 'Backlink Stats Worker', url: `http://${HOST}:8004`, healthPath: '/health' },
  { name: 'General Stats Worker', url: `http://${HOST}:8005`, healthPath: '/health' },
  { name: 'User Stats Worker', url: `http://${HOST}:8006`, healthPath: '/health' },
]

const healthStatus = ref({})

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

function getStatus(item) {
  return healthStatus.value[item.url] || 'unhealthy'
}

onMounted(async () => {
  for (const item of infrastructure) {
    await checkHealth(item)
  }
  for (const service of services) {
    await checkHealth(service)
  }
  for (const worker of workers) {
    await checkHealth(worker)
  }
  setInterval(async () => {
    for (const item of infrastructure) {
      await checkHealth(item)
    }
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
      <h2>Infrastructure</h2>
      <div class="grid">
        <template v-for="item in infrastructure" :key="item.url">
          <a v-if="item.linkUrl" :href="item.linkUrl" class="card infrastructure" target="_blank">
            <div class="card-header">
              <h3>{{ item.name }}</h3>
              <span class="status" :class="getStatus(item)"></span>
            </div>
            <p>{{ item.description }}</p>
            <span class="url">{{ item.url }}</span>
          </a>
          <div v-else class="card infrastructure">
            <div class="card-header">
              <h3>{{ item.name }}</h3>
              <span class="status" :class="getStatus(item)"></span>
            </div>
            <p>{{ item.description }}</p>
            <span class="url">{{ item.url }}</span>
          </div>
        </template>
      </div>
    </section>

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

    <footer class="legend">
      <span class="legend-item"><span class="dot healthy"></span> Healthy</span>
      <span class="legend-item"><span class="dot unhealthy"></span> Unhealthy</span>
    </footer>
  </div>
</template>

<style scoped>
.container {
  max-width: 1400px;
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

.legend {
  display: flex;
  justify-content: center;
  gap: 1.5rem;
  margin-top: 1rem;
  font-size: 0.9rem;
  color: #666;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
}

.dot.healthy { background: #22c55e; }
.dot.unhealthy { background: #ef4444; }

h2 {
  font-size: 1.5rem;
  color: #555;
  margin-bottom: 1rem;
  margin-top: 2rem;
  padding-bottom: 0.5rem;
  text-align: center;
  border-bottom: 1px solid #eee;
}

.grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
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

footer {
  text-align: center;
  margin-top: 3rem;
  padding-top: 2rem;
  border-top: 1px solid #eee;
}

.legend {
  display: flex;
  justify-content: center;
  gap: 1.5rem;
  font-size: 0.9rem;
  color: #666;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
}

.dot.healthy { background: #22c55e; }
.dot.unhealthy { background: #ef4444; }
</style>
