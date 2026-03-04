<script setup>
const services = [
  { name: 'Backend API', url: 'http://localhost:8083', description: 'Main API server' },
  { name: 'SSE Frontend', url: 'http://localhost:8889', description: 'Server-Sent Events UI' },
  { name: 'SSE Backend', url: 'http://localhost:8888', description: 'SSE API' },
  { name: 'MinIO Console', url: 'http://localhost:9001', description: 'S3-compatible storage' },
  { name: 'Redpanda Console', url: 'http://localhost:9644', description: 'Kafka messaging' },
]

const workers = [
  { name: 'ID Worker', url: 'http://localhost:8001' },
  { name: 'JSON Dump Worker', url: 'http://localhost:8002' },
  { name: 'TTL Dump Worker', url: 'http://localhost:8003' },
  { name: 'Backlink Stats Worker', url: 'http://localhost:8004' },
  { name: 'General Stats Worker', url: 'http://localhost:8005' },
  { name: 'User Stats Worker', url: 'http://localhost:8006' },
]
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
          <h3>{{ service.name }}</h3>
          <p>{{ service.description }}</p>
          <span class="url">{{ service.url }}</span>
        </a>
      </div>
    </section>

    <section>
      <h2>Workers</h2>
      <div class="grid">
        <a v-for="worker in workers" :key="worker.url" :href="worker.url" class="card worker" target="_blank">
          <h3>{{ worker.name }}</h3>
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
