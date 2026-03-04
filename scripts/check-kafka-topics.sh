#!/bin/bash
# Script to check Kafka/Redpanda topic messages

echo "=== Checking entity_change topic ==="
docker exec redpanda rpk topic consume entity_change --num 10 2>&1 || echo "No messages or error"

echo ""
echo "=== Checking entitybase.entity_change topic ==="
docker exec redpanda rpk topic consume entitybase.entity_change --num 10 2>&1 || echo "No messages or error"

echo ""
echo "=== Topic info ==="
docker exec redpanda rpk topic info entity_change 2>&1
docker exec redpanda rpk topic info entitybase.entity_change 2>&1
