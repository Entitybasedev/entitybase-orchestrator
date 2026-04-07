#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <container-name>"
    echo "Example: $0 create-tables"
    exit 1
fi

CONTAINER="$1"

docker compose rm -sf "$CONTAINER"
docker compose build --no-cache "$CONTAINER"
docker compose up -d "$CONTAINER"