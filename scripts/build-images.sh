#!/bin/bash
set -e

NO_CACHE=""
if [ "$1" = "--no-cache" ]; then
    NO_CACHE="--no-cache"
fi

cd "$(dirname "$0")/.."

echo "Building entitybase-backend-api:latest..."
docker build $NO_CACHE -t entitybase-backend-api:latest -f libs/entitybase-backend/docker/containers/Dockerfile.api libs/entitybase-backend/

echo "Building entitybase-backend-idworker:latest..."
docker build $NO_CACHE -t entitybase-backend-idworker:latest -f libs/entitybase-backend/docker/containers/Dockerfile.idworker libs/entitybase-backend/

echo "Building entitybase-backend-stats-worker:latest..."
docker build $NO_CACHE -t entitybase-backend-stats-worker:latest -f libs/entitybase-backend/docker/containers/Dockerfile.stats-workers libs/entitybase-backend/

echo "Building entitybase-backend-json-worker:latest..."
docker build $NO_CACHE -t entitybase-backend-json-worker:latest -f libs/entitybase-backend/docker/containers/Dockerfile.json-worker libs/entitybase-backend/

echo "Building entitybase-backend-ttl-worker:latest..."
docker build $NO_CACHE -t entitybase-backend-ttl-worker:latest -f libs/entitybase-backend/docker/containers/Dockerfile.ttl-worker libs/entitybase-backend/

echo "Building entitybase-backend-create-buckets:latest..."
docker build $NO_CACHE -t entitybase-backend-create-buckets:latest -f libs/entitybase-backend/docker/containers/Dockerfile.api libs/entitybase-backend/

echo "Building entitybase-backend-create-tables:latest..."
docker build $NO_CACHE -t entitybase-backend-create-tables:latest -f libs/entitybase-backend/docker/containers/Dockerfile.api libs/entitybase-backend/

echo "Building entitybase-backend-create-topics:latest..."
docker build $NO_CACHE -t entitybase-backend-create-topics:latest -f libs/entitybase-backend/docker/containers/Dockerfile.api libs/entitybase-backend/

echo "Building kafka2sse-backend:latest..."
docker build $NO_CACHE -t kafka2sse-backend:latest -f libs/kafka2sse-backend/Dockerfile libs/kafka2sse-backend/

echo "Building kafka2sse-frontend:latest..."
docker build $NO_CACHE -t kafka2sse-frontend:latest -f libs/kafka2sse-frontend/Dockerfile libs/kafka2sse-frontend/

echo "Done! Images built:"
docker images | grep -E "entitybase-|kafka2sse-"
