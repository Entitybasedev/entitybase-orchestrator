#!/bin/bash
set -e

cd "$(dirname "$0")/.."

echo "Building entitybase-backend-api:latest..."
docker build -t entitybase-backend-api:latest -f entitybase-backend/docker/containers/Dockerfile.api entitybase-backend/

echo "Building entitybase-backend-idworker:latest..."
docker build -t entitybase-backend-idworker:latest -f entitybase-backend/docker/containers/Dockerfile.id-generator entitybase-backend/

echo "Building entitybase-backend-create-buckets:latest..."
docker build -t entitybase-backend-create-buckets:latest -f entitybase-backend/docker/containers/Dockerfile.api entitybase-backend/

echo "Building entitybase-backend-create-tables:latest..."
docker build -t entitybase-backend-create-tables:latest -f entitybase-backend/docker/containers/Dockerfile.api entitybase-backend/

echo "Building entitybase-backend-create-topics:latest..."
docker build -t entitybase-backend-create-topics:latest -f entitybase-backend/docker/containers/Dockerfile.api entitybase-backend/

echo "Building entitybase-backend-json-dump-worker:latest..."
docker build -t entitybase-backend-json-dump-worker:latest -f entitybase-backend/docker/containers/Dockerfile.dump-workers entitybase-backend/

echo "Building entitybase-backend-ttl-dump-worker:latest..."
docker build -t entitybase-backend-ttl-dump-worker:latest -f entitybase-backend/docker/containers/Dockerfile.dump-workers entitybase-backend/

echo "Building entitybase-backend-backlink-stats-worker:latest..."
docker build -t entitybase-backend-backlink-stats-worker:latest -f entitybase-backend/docker/containers/Dockerfile.dump-workers entitybase-backend/

echo "Building entitybase-backend-general-stats-worker:latest..."
docker build -t entitybase-backend-general-stats-worker:latest -f entitybase-backend/docker/containers/Dockerfile.dump-workers entitybase-backend/

echo "Building entitybase-backend-user-stats-worker:latest..."
docker build -t entitybase-backend-user-stats-worker:latest -f entitybase-backend/docker/containers/Dockerfile.dump-workers entitybase-backend/

echo "Building entitybase-sse-backend:latest..."
docker build -t entitybase-sse-backend:latest -f entitybase-sse/Dockerfile entitybase-sse/

echo "Building entitybase-sse-frontend:latest..."
docker build -t entitybase-sse-frontend:latest -f entitybase-sse/frontend/Dockerfile entitybase-sse/frontend/

echo "Done! Images built:"
docker images | grep -E "entitybase-"
