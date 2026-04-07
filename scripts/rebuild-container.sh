#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <container-name>"
    echo "Example: $0 create-tables"
    exit 1
fi

CONTAINER="$1"

# Map container names to their image names
case "$CONTAINER" in
    create-tables)
        IMAGE="entitybase-backend-create-tables:latest"
        DOCKERFILE="libs/entitybase-backend/docker/containers/Dockerfile.dev-worker"
        CONTEXT="libs/entitybase-backend/"
        ;;
    create-buckets)
        IMAGE="entitybase-backend-create-buckets:latest"
        DOCKERFILE="libs/entitybase-backend/docker/containers/Dockerfile.dev-worker"
        CONTEXT="libs/entitybase-backend/"
        ;;
    create-topics)
        IMAGE="entitybase-backend-create-topics:latest"
        DOCKERFILE="libs/entitybase-backend/docker/containers/Dockerfile.dev-worker"
        CONTEXT="libs/entitybase-backend/"
        ;;
    *)
        echo "Unknown container: $CONTAINER"
        exit 1
        ;;
esac

# Pull latest backend changes
cd libs/entitybase-backend && git pull
cd ../..

# Build the specific image
docker build --no-cache -t "$IMAGE" -f "$DOCKERFILE" "$CONTEXT"

# Recreate the container
docker compose rm -sf "$CONTAINER"
docker compose up -d "$CONTAINER"