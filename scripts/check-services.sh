#!/bin/bash
cd "$(dirname "$0")/.."
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

overall_status=0

check_running_service() {
    local container_name=$1
    local health_status=$(docker inspect --format='{{.State.Health.Status}}' "$container_name" 2>/dev/null || echo "not_found")

    if [ "$health_status" = "healthy" ]; then
        echo -e "${GREEN}✅ $container_name - healthy${NC}"
        return 0
    else
        echo -e "${RED}❌ $container_name - $health_status${NC}"
        return 1
    fi
}

check_completed_job() {
    local container_name=$1
    local state=$(docker inspect --format='{{.State.Status}}' "$container_name" 2>/dev/null || echo "not_found")
    local exit_code=$(docker inspect --format='{{.State.ExitCode}}' "$container_name" 2>/dev/null || echo "255")

    if [ "$state" = "exited" ] && [ "$exit_code" = "0" ]; then
        echo -e "${GREEN}✅ $container_name - completed successfully${NC}"
        return 0
    else
        echo -e "${RED}❌ $container_name - state: $state, exit code: $exit_code${NC}"
        return 1
    fi
}

echo "=== Checking containers ==="

check_running_service "mysql" || overall_status=1
check_running_service "minio" || overall_status=1
check_running_service "redpanda" || overall_status=1
check_running_service "entitybase-backend" || overall_status=1
check_running_service "idworker" || overall_status=1
check_running_service "entitybase-sse-backend" || overall_status=1
check_running_service "entitybase-sse-frontend" || overall_status=1

check_completed_job "create-buckets" || overall_status=1
check_completed_job "create-tables" || overall_status=1
check_completed_job "create-topics" || overall_status=1

echo ""
echo "=== Checking images ==="
docker images | grep -E "entitybase-" || echo -e "${YELLOW}⚠️  No entitybase images found${NC}"

echo ""
if [ $overall_status -eq 0 ]; then
    echo -e "${GREEN}✅ All services healthy${NC}"
else
    echo -e "${RED}❌ Some services are not healthy${NC}"
fi

exit $overall_status
