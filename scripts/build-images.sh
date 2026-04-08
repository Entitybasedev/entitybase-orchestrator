#!/bin/bash
set -e

NO_CACHE=""
if [ "$1" = "--no-cache" ]; then
    NO_CACHE="--no-cache"
fi

cd "$(dirname "$0")/.."

CACHE_ARGS=""
if df -T /tmp/docker-buildkit 2>/dev/null | grep -q tmpfs; then
    CACHE_ARGS="--cache-to=type=local,dest=/tmp/docker-buildkit --cache-from=type=local,src=/tmp/docker-buildkit"
fi

echo "=========================================="
echo "Generating requirements from pyproject.toml"
echo "=========================================="
./libs/entitybase-backend/scripts/shell/export-requirements.sh

echo ""
echo "=========================================="
echo "Building Docker images for Entitybase"
echo "=========================================="

if [ -n "$CACHE_ARGS" ]; then
    echo "Using tmpfs build cache at /tmp/docker-buildkit"
else
    echo "Using default Docker build cache"
fi

echo ""
echo "[1/12] Building entitybase-api:latest..."
docker build $NO_CACHE $CACHE_ARGS -t entitybase-api:latest -f libs/entitybase-backend/docker/containers/Dockerfile.api libs/entitybase-backend/

echo ""
echo "[2/12] Building entitybase-backend-idworker:latest..."
docker build $NO_CACHE $CACHE_ARGS -t entitybase-backend-idworker:latest -f libs/entitybase-backend/docker/containers/Dockerfile.idworker libs/entitybase-backend/

echo ""
echo "[3/12] Building entitybase-backend-stats-worker:latest..."
docker build $NO_CACHE $CACHE_ARGS -t entitybase-backend-stats-worker:latest -f libs/entitybase-backend/docker/containers/Dockerfile.stats-workers libs/entitybase-backend/

echo ""
echo "[4/12] Building entitybase-backend-json-worker:latest..."
docker build $NO_CACHE $CACHE_ARGS -t entitybase-backend-json-worker:latest -f libs/entitybase-backend/docker/containers/Dockerfile.json-worker libs/entitybase-backend/

echo ""
echo "[5/12] Building entitybase-backend-ttl-worker:latest..."
docker build $NO_CACHE $CACHE_ARGS -t entitybase-backend-ttl-worker:latest -f libs/entitybase-backend/docker/containers/Dockerfile.ttl-worker libs/entitybase-backend/

echo ""
echo "[6/12] Building entitybase-backend-create-buckets:latest..."
docker build $NO_CACHE $CACHE_ARGS -t entitybase-backend-create-buckets:latest -f libs/entitybase-backend/docker/containers/Dockerfile.create-buckets libs/entitybase-backend/

echo ""
echo "[7/12] Building entitybase-backend-create-tables:latest..."
docker build $NO_CACHE $CACHE_ARGS -t entitybase-backend-create-tables:latest -f libs/entitybase-backend/docker/containers/Dockerfile.create-tables libs/entitybase-backend/

echo ""
echo "[8/12] Building entitybase-backend-create-topics:latest..."
docker build $NO_CACHE $CACHE_ARGS -t entitybase-backend-create-topics:latest -f libs/entitybase-backend/docker/containers/Dockerfile.create-topics libs/entitybase-backend/

echo ""
echo "[9/12] Building entitybase-backend-elasticsearch-worker:latest..."
docker build $NO_CACHE $CACHE_ARGS -t entitybase-backend-elasticsearch-worker:latest -f libs/entitybase-backend/docker/containers/Dockerfile.api libs/entitybase-backend/

echo ""
echo "[10/12] Building kafka2sse-backend:latest..."
docker build $NO_CACHE $CACHE_ARGS -t kafka2sse-backend:latest -f libs/kafka2sse-backend/Dockerfile libs/kafka2sse-backend/

echo ""
echo "[11/12] Building kafka2sse-frontend:latest..."
docker build $NO_CACHE $CACHE_ARGS -t kafka2sse-frontend:latest -f libs/kafka2sse-frontend/Dockerfile libs/kafka2sse-frontend/

echo ""
echo "[12/13] Building entitybase-orchestrator-frontend:latest..."
docker build $NO_CACHE $CACHE_ARGS -t entitybase-orchestrator-frontend:latest -f frontend/Dockerfile frontend/

echo ""
echo "[13/13] Building entitybase-backend-purge-worker:latest..."
docker build $NO_CACHE $CACHE_ARGS -t entitybase-backend-purge-worker:latest -f libs/entitybase-backend/docker/containers/Dockerfile.purge-worker libs/entitybase-backend/

echo ""
echo "=========================================="
echo "Done! Images built:"
echo "=========================================="
docker images | grep -E "entitybase-|kafka2sse-"
