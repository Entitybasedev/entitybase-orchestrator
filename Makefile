.PHONY: help clone build build-no-cache check run_core run_workers run-build-no-cache stop remove clean release show-images

help:
	@echo "Available targets:"
	@echo "  make clone          - Clone required repositories"
	@echo "  make build         - Build all Docker images for docker-compose"
	@echo "  make build-no-cache  - Build all Docker images without using cache"
	@echo "  make run-build-no-cache - Build without cache and start core services"
	@echo "  make check         - Check service health status"
	@echo "  make run_core       - Build images and start core services"
	@echo "  make run_workers   - Build images and start all services (core + workers)"
	@echo "  make stop          - Stop all running services"
	@echo "  make remove        - Stop services and remove containers/volumes"
	@echo "  make clean         - Remove stopped containers, unused images, and build cache"
	@echo "  make release       - Create release: update version, commit, and tag (e.g., v2026.3.4)"
	@echo "  make show-images  - Show all entitybase Docker images"

release:
	./scripts/run-release.sh

clone:
	./scripts/clone-repos.sh

build:
	./scripts/build-images.sh

build-no-cache:
	./scripts/build-images.sh --no-cache

run-build-no-cache: stop clean build-no-cache
	docker compose --profile core up -d

check:
	./scripts/check-services.sh

stop:
	docker compose stop

remove: stop
	docker compose down -v --remove-orphans

clean:
	docker compose down --remove-orphans || true
	# Clean network
	# docker network rm entitybase-network 2>/dev/null || true
	# Clean containers so they are rebuilt with new changes
	docker container prune -f
	# docker image prune -a -f
	# docker builder prune -f

run: run_core

run_core: stop clean build
	docker compose --profile core up -d

run_workers: stop clean build
	docker compose --profile workers up -d

reset:
	./scripts/reset.sh

show-images:
	./scripts/show-images.sh
