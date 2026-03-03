#!/bin/bash
set -e

cd "$(dirname "$0")"

echo "Building entitybase-backend:latest..."
docker build -t entitybase-backend:latest -f entitybase-backend/docker/containers/Dockerfile.api entitybase-backend/

echo "Building entitybase-sse-backend:latest..."
docker build -t entitybase-sse-backend:latest -f entitybase-sse/Dockerfile entitybase-sse/

echo "Building entitybase-sse-frontend:latest..."
docker build -t entitybase-sse-frontend:latest -f entitybase-sse/frontend/Dockerfile entitybase-sse/frontend/

echo "Done! Images built:"
docker images | grep -E "entitybase-"
