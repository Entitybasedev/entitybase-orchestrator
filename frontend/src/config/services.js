const HOST = import.meta.env.VITE_HOST || 'localhost'

export const infrastructure = [
  { name: 'MinIO', url: `http://${HOST}:9001`, description: 'S3 storage + console', healthPath: '/minio/health/live', linkUrl: `http://${HOST}:9001` },
  { name: 'MySQL', url: `http://${HOST}:3307`, description: 'Database (no HTTP interface)', healthPath: '/' },
  { name: 'Redpanda', url: `http://${HOST}:9645`, description: 'Kafka messaging + console', healthPath: '/', linkUrl: `http://${HOST}:8084` },
  { name: 'Entitybase API', url: `http://${HOST}:8083`, description: 'Main API server', healthPath: '/health' },
  { name: 'Valkey', url: `http://${HOST}:6378`, description: 'Redis-compatible caching', healthPath: '/' },
  { name: 'Elasticsearch', url: `http://${HOST}:9201`, description: 'Search engine', healthPath: '/', configKey: 'elasticsearch_enabled' },
  { name: 'Meilisearch', url: `http://${HOST}:7700`, description: 'Full-text search', healthPath: '/', linkUrl: `http://${HOST}:7700`, configKey: 'meilisearch_enabled' },
]

export const eventStreaming = [
  { name: 'Server-Sent Events Backend', url: `http://${HOST}:8888`, description: 'SSE API', healthPath: '/health' },
  { name: 'Server-Sent Events Frontend', url: `http://${HOST}:8889`, description: 'SSE UI', healthPath: '/health' },
  { name: 'Entity Change Producer', url: `http://${HOST}:8083`, healthPath: '/health', producerKey: 'entity_change', topic: 'entity_change' },
  { name: 'Entity Diff Producer', url: `http://${HOST}:8083`, healthPath: '/health', producerKey: 'entitydiff', topic: 'entity_diff' },
  { name: 'User Change Producer', url: `http://${HOST}:8083`, healthPath: '/health', producerKey: 'user_change', topic: 'user_change' },
]

export const workers = [
  { name: 'ID Worker', url: `http://${HOST}:8001`, healthPath: '/health' },
  { name: 'JSON Dump Worker', url: `http://${HOST}:8002`, healthPath: '/health' },
  { name: 'TTL Dump Worker', url: `http://${HOST}:8003`, healthPath: '/health' },
  { name: 'Backlink Stats Worker', url: `http://${HOST}:8004`, healthPath: '/health' },
  { name: 'General Stats Worker', url: `http://${HOST}:8005`, healthPath: '/health' },
  { name: 'User Stats Worker', url: `http://${HOST}:8006`, healthPath: '/health' },
  { name: 'Elasticsearch Indexer Worker', url: `http://${HOST}:8007`, healthPath: '/health' },
  { name: 'Meilisearch Indexer Worker', url: `http://${HOST}:8009`, healthPath: '/health' },
  { name: 'Purge Worker', url: `http://${HOST}:8008`, healthPath: '/health' },
]

export const producers = eventStreaming.filter(item => item.producerKey)
export const streamingServices = eventStreaming.filter(item => !item.producerKey)