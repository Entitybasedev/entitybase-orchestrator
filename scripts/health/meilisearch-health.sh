#!/bin/sh

MEILISEARCH_HOST="${MEILISEARCH_HOST:-meilisearch}"
MEILISEARCH_PORT="${MEILISEARCH_PORT:-7700}"

while true; do
    response=$(wget -q -O - "http://${MEILISEARCH_HOST}:${MEILISEARCH_PORT}/health" 2>&1)
    if [ $? -eq 0 ]; then
        echo "healthy"
    else
        echo "unhealthy"
    fi
    sleep 30
done