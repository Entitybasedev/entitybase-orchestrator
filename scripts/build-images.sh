#!/bin/bash
set -e

NO_CACHE=""
if [ "$1" = "--no-cache" ]; then
    NO_CACHE="--no-cache"
fi

cd "$(dirname "$0")/.."

echo "Building entitybase-backend-api:latest..."
docker build $NO_CACHE -t entitybase-backend-api:latest -f entitybase-backend/docker/containers/Dockerfile.api entitybase-backend/

echo "Building entitybase-backend-idworker:latest..."
docker build $NO_CACHE -t entitybase-backend-idworker:latest -f entitybase-backend/docker/containers/Dockerfile.idworker entitybase-backend/

echo "Building entitybase-backend-stats-worker:latest..."
docker build $NO_CACHE -t entitybase-backend-stats-worker:latest -f entitybase-backend/docker/containers/Dockerfile.stats-workers entitybase-backend/

echo "Building entitybase-backend-json-worker:latest..."
docker build $NO_CACHE -t entitybase-backend-json-worker:latest -f entitybase-backend/docker/containers/Dockerfile.json-worker entitybase-backend/

echo "Building entitybase-backend-ttl-worker:latest..."
docker build $NO_CACHE -t entitybase-backend-ttl-worker:latest -f entitybase-backend/docker/containers/Dockerfile.ttl-worker entitybase-backend/

echo "Building entitybase-backend-create-buckets:latest..."
docker build $NO_CACHE -t entitybase-backend-create-buckets:latest -f entitybase-backend/docker/containers/Dockerfile.api entitybase-backend/

echo "Building entitybase-backend-create-tables:latest..."
docker build $NO_CACHE -t entitybase-backend-create-tables:latest -f entitybase-backend/docker/containers/Dockerfile.api entitybase-backend/

echo "Building entitybase-backend-create-topics:latest..."
docker build $NO_CACHE -t entitybase-backend-create-topics:latest -f entitybase-backend/docker/containers/Dockerfile.api entitybase-backend/

echo "Building entitybase-sse-backend:latest..."
docker build $NO_CACHE -t entitybase-sse-backend:latest -f entitybase-sse/Dockerfile entitybase-sse/

echo "Building entitybase-sse-frontend:latest..."
docker build $NO_CACHE -t entitybase-sse-frontend:latest -f entitybase-sse/frontend/Dockerfile entitybase-sse/frontend/

echo "Done! Images built:"
docker images | grep -E "entitybase-"
