#!/bin/bash
set -e

NO_CACHE=""
if [ "$1" = "--no-cache" ]; then
    NO_CACHE="--no-cache"
fi

cd "$(dirname "$0")/.."

if [ -f .env ]; then
    set -a
    source .env
    set +a
fi

ID_WORKER_ENABLED=${ID_WORKER_ENABLED:-false}
JSON_WORKER_ENABLED=${JSON_WORKER_ENABLED:-false}
TTL_WORKER_ENABLED=${TTL_WORKER_ENABLED:-false}
STATS_WORKER_ENABLED=${STATS_WORKER_ENABLED:-false}
ELASTICSEARCH_ENABLED=${ELASTICSEARCH_ENABLED:-false}
MEILISEARCH_ENABLED=${MEILISEARCH_ENABLED:-false}
PURGE_WORKER_ENABLED=${PURGE_WORKER_ENABLED:-false}
INCREMENTAL_RDF_WORKER_ENABLED=${INCREMENTAL_RDF_WORKER_ENABLED:-false}

echo "=========================================="
echo "Building Docker images for Entitybase"
echo "=========================================="

echo ""
echo "[api] Building entitybase-api:latest..."
docker build $NO_CACHE -t entitybase-api:latest -f libs/entitybase-backend/docker/containers/Dockerfile.api libs/entitybase-backend/

if [ "$ID_WORKER_ENABLED" = "true" ]; then
    echo ""
    echo "[idworker] Building entitybase-backend-idworker:latest..."
    docker build $NO_CACHE -t entitybase-backend-idworker:latest -f libs/entitybase-backend/docker/containers/Dockerfile.idworker libs/entitybase-backend/
fi

if [ "$STATS_WORKER_ENABLED" = "true" ]; then
    echo ""
    echo "[stats-worker] Building entitybase-backend-stats-worker:latest..."
    docker build $NO_CACHE -t entitybase-backend-stats-worker:latest -f libs/entitybase-backend/docker/containers/Dockerfile.stats-workers libs/entitybase-backend/
fi

if [ "$JSON_WORKER_ENABLED" = "true" ]; then
    echo ""
    echo "[json-worker] Building entitybase-backend-json-worker:latest..."
    docker build $NO_CACHE -t entitybase-backend-json-worker:latest -f libs/entitybase-backend/docker/containers/Dockerfile.json-worker libs/entitybase-backend/
fi

if [ "$TTL_WORKER_ENABLED" = "true" ]; then
    echo ""
    echo "[ttl-worker] Building entitybase-backend-ttl-worker:latest..."
    docker build $NO_CACHE -t entitybase-backend-ttl-worker:latest -f libs/entitybase-backend/docker/containers/Dockerfile.ttl-worker libs/entitybase-backend/
fi

echo ""
echo "[create-buckets] Building entitybase-backend-create-buckets:latest..."
docker build $NO_CACHE -t entitybase-backend-create-buckets:latest -f libs/entitybase-backend/docker/containers/Dockerfile.create-buckets libs/entitybase-backend/

echo ""
echo "[create-tables] Building entitybase-backend-create-tables:latest..."
docker build $NO_CACHE -t entitybase-backend-create-tables:latest -f libs/entitybase-backend/docker/containers/Dockerfile.create-tables libs/entitybase-backend/

echo ""
echo "[create-topics] Building entitybase-backend-create-topics:latest..."
docker build $NO_CACHE -t entitybase-backend-create-topics:latest -f libs/entitybase-backend/docker/containers/Dockerfile.create-topics libs/entitybase-backend/

if [ "$ELASTICSEARCH_ENABLED" = "true" ]; then
    echo ""
    echo "[elasticsearch-worker] Building entitybase-backend-elasticsearch-worker:latest..."
    docker build $NO_CACHE -t entitybase-backend-elasticsearch-worker:latest -f libs/entitybase-backend/docker/containers/Dockerfile.api libs/entitybase-backend/
fi

if [ "$MEILISEARCH_ENABLED" = "true" ]; then
    echo ""
    echo "[meilisearch-worker] Building entitybase-backend-meilisearch-worker:latest..."
    docker build $NO_CACHE -t entitybase-backend-meilisearch-worker:latest -f libs/entitybase-backend/docker/containers/Dockerfile.api libs/entitybase-backend/
fi

echo ""
echo "[kafka2sse-backend] Building kafka2sse-backend:latest..."
docker build $NO_CACHE -t kafka2sse-backend:latest -f libs/kafka2sse-backend/Dockerfile libs/kafka2sse-backend/

echo ""
echo "[kafka2sse-frontend] Building kafka2sse-frontend:latest..."
docker build $NO_CACHE -t kafka2sse-frontend:latest -f libs/kafka2sse-frontend/Dockerfile libs/kafka2sse-frontend/

echo ""
echo "[orchestrator-frontend] Building entitybase-orchestrator-frontend:latest..."
docker build $NO_CACHE --build-arg VITE_APP_VERSION=${VERSION_ORCHESTRATOR_FRONTEND} -t entitybase-orchestrator-frontend:latest -f frontend/Dockerfile frontend/

if [ "$PURGE_WORKER_ENABLED" = "true" ]; then
    echo ""
    echo "[purge-worker] Building entitybase-backend-purge-worker:latest..."
    docker build $NO_CACHE -t entitybase-backend-purge-worker:latest -f libs/entitybase-backend/docker/containers/Dockerfile.purge-worker libs/entitybase-backend/
fi

if [ "$INCREMENTAL_RDF_WORKER_ENABLED" = "true" ]; then
    echo ""
    echo "[incremental-rdf-worker] Building entitybase-backend-incremental-rdf-worker:latest..."
    docker build $NO_CACHE -t entitybase-backend-incremental-rdf-worker:latest -f libs/entitybase-backend/docker/containers/Dockerfile.incremental-rdf-worker libs/entitybase-backend/
fi

echo ""
echo "=========================================="
echo "Done! Images built:"
echo "=========================================="
docker images | grep -E "entitybase-|kafka2sse-"
