.PHONY: build build-no-cache check check-deps check-diskspace clean-all clean-all-except-base-images clean-build-cache clean-build-run-all-with-elastic clean-build-run-core clean-build-run-core-purge clean-build-run-core-workers-meilisearch clean-build-run-no-cache clean-build-run-with-elastic clean-build-run-with-meilisearch clean-build-run-workers clean-cache-volumes clean-local-images clone elastic help meilisearch pull reclaim release remove reset run-core run-core-purge run-core-workers-meilisearch run-with-elastic run-with-meilisearch run-workers settings show-images stop tmpfs-setup

help:
	@echo "Available targets:"
	@echo "  make build                   - Build all Docker images for docker-compose"
	@echo "  make build-no-cache          - Build all Docker images without using cache"
	@echo "  make check                   - Check service health status"
	@echo "  make check-deps              - Check required dependencies (poetry, docker, python)"
	@echo "  make check-diskspace         - Check available disk space (requires 2GB minimum)"
	@echo "  make clean-all               - Remove all containers, images, volumes, and build cache"
	@echo "  make clean-all-except-base-images - Remove containers and non-base images, keep base images"
	@echo "  make clean-build-cache      - Clear only Docker build cache (keep images/containers)"
	@echo "  make clean-cache-volumes    - Stop services, remove containers, volumes, and build cache"
	@echo "  make clean-local-images     - Remove locally built images only (keep base images)"
	@echo "  make clone                   - Clone required repositories"
	@echo "  make elastic                 - Start Elasticsearch and elasticsearch-indexer worker"
	@echo "  make pull                    - Pull latest changes in orchestrator and backend"
	@echo "  make reclaim                 - Reclaim disk space (prune unused images, volumes, build cache)"
	@echo "  make release                 - Create release: update version, commit, and tag (e.g., v2026.3.4)"
	@echo "  make remove                  - Stop services and remove containers/volumes"
	@echo "  make reset                   - Reset the environment (experimental)"
	@echo "  make run-core                - Start core services (no build)"
	@echo "  make run-workers             - Start all services (core + workers, no build)"
	@echo "  make run-core-purge          - Start core + workers + purge worker (no build)"
	@echo "  make run-core-workers-meilisearch - Start core + workers + meilisearch (no build)"
	@echo "  make run-with-elastic        - Start core + elasticsearch (no build)"
	@echo "  make run-with-meilisearch    - Start core + meilisearch (no build)"
	@echo "  make clean-build-run-core                - Clean, build, and start core services"
	@echo "  make clean-build-run-workers             - Clean, build, and start all services (core + workers)"
	@echo "  make clean-build-run-core-purge          - Clean, build, and start core + workers + purge worker"
	@echo "  make clean-build-run-core-workers-meilisearch - Clean, build, and start core + workers + meilisearch"
	@echo "  make clean-build-run-with-elastic        - Clean, build, and start core + elasticsearch"
	@echo "  make clean-build-run-with-meilisearch    - Clean, build, and start core + meilisearch"
	@echo "  make clean-build-run-all-with-elastic    - Clean all, build, and start core + elasticsearch"
	@echo "  make clean-build-run-no-cache             - Clean, build without cache, and start core services"
	@echo "  make settings                - Query the /settings endpoint on localhost:8083"
	@echo "  make show-images             - Show all entitybase Docker images"
	@echo "  make stop                    - Stop all running containers"
	@echo "  make tmpfs-setup             - Setup tmpfs for buildkit cache (requires sudo)"

build: check-deps
	./scripts/build-images.sh

build-no-cache: check-deps
	./scripts/build-images.sh --no-cache

check:
	./scripts/check-services.sh

check-deps:
	@echo "Checking dependencies..."
	@command -v docker >/dev/null 2>&1 || { echo "Error: docker is required but not installed."; exit 1; }
	@command -v python3 >/dev/null 2>&1 || { echo "Error: python3 is required but not installed."; exit 1; }
	@command -v poetry >/dev/null 2>&1 || { echo "Error: poetry is required but not installed. Install via your OS package manager (e.g., apt install poetry, pacman -S python-poetry, brew install poetry)"; exit 1; }
	@echo "All dependencies satisfied."

check-diskspace:
	@if df -T /dev/mapper/arch >/dev/null 2>&1; then \
		DEVICE="/dev/mapper/arch"; \
	elif df -T /dev/sda1 >/dev/null 2>&1; then \
		DEVICE="/dev/sda1"; \
	else \
		echo "Disk check skipped: no known device found"; \
		exit 0; \
	fi; \
	AVAILABLE=$$(df -h $$DEVICE | tail -1 | awk '{print $$4}'); \
	echo "Available space: $$AVAILABLE"; \
	case $$AVAILABLE in \
		*[0-9]G) \
	SIZE=$${AVAILABLE%G}; \
			if [ "$$(echo "$$SIZE >= 1" | awk '{if ($$1 >= 1) print 1; else print 0}')" -eq 1 ]; then exit 0; fi \
	;; \
		*[0-9]M) \
			echo "Error: Less than 1GB available"; \
			exit 1; \
	;; \
	esac; \
	echo "Error: Less than 1GB available"; \
	exit 1

clean-all: clean-local-images
	docker image prune -a -f
	docker builder prune -f
	docker volume prune -f

clean-all-except-base-images: clean-local-images
	docker builder prune -af
	docker volume prune -f
	@echo "Build cache and volumes cleared"

clean-build-cache:
	docker builder prune -f
	@echo "Build cache cleared. Run 'docker system df' to check."

clean-build-run-all-with-elastic: clean-all build check-diskspace
	docker compose -f docker-compose.yml --profile elastic up -d

clean-build-run-core: check-deps check-diskspace clean-local-images build
	docker compose -f docker-compose.yml --profile core up -d

clean-build-run-core-purge: check-deps check-diskspace clean-local-images build
	docker compose -f docker-compose.yml --profile core up -d
	docker compose -f docker-compose.yml --profile workers up -d purge-worker

clean-build-run-core-workers-meilisearch: check-deps check-diskspace clean-local-images build
	docker compose -f docker-compose.yml --profile core --profile workers --profile meilisearch up -d

clean-build-run-no-cache: clean-local-images build-no-cache
	docker compose -f docker-compose.yml --profile core up -d

clean-build-run-with-elastic: check-deps check-diskspace clean-local-images build
	docker compose -f docker-compose.yml --profile elastic up -d

clean-build-run-with-meilisearch: check-deps check-diskspace clean-local-images build
	docker compose -f docker-compose.yml --profile meilisearch up -d

clean-build-run-workers: check-deps check-diskspace clean-local-images build
	docker compose -f docker-compose.yml --profile workers up -d

clean-cache-volumes: remove
	docker builder prune -f
	@echo "Build cache cleared"

clean-local-images: remove
	docker container prune -f
	docker builder prune -f
	docker images | grep -E "^entitybase-|^kafka2sse-" | awk '{print $$3}' | xargs -r docker rmi -f || true

clone:
	./scripts/clone-repos.sh

elastic:
	docker compose -f docker-compose.yml --profile elastic up -d

meilisearch:
	docker compose -f docker-compose.yml --profile meilisearch up -d

pull:
	git pull
	cd libs/entitybase-backend && git pull
	cd libs/kafka2sse-backend && git pull
	cd libs/kafka2sse-frontend && git pull

reclaim:
	docker image prune -a -f
	docker volume prune -f
	docker builder prune -f
	@echo "Disk space reclaimed. Run 'docker system df' to check."

release:
	./scripts/run-release.sh

remove: stop
	docker rm $$(docker ps -aq) || true
	docker network rm $$(docker network ls -q) || true
	docker compose -f docker-compose.yml down -v --remove-orphans

reset:
	./scripts/reset.sh

run-core:
	docker compose -f docker-compose.yml --profile core up -d

run-core-purge:
	docker compose -f docker-compose.yml --profile core up -d
	docker compose -f docker-compose.yml --profile workers up -d purge-worker

run-core-workers-meilisearch:
	docker compose -f docker-compose.yml --profile core --profile workers --profile meilisearch up -d

run-with-elastic:
	docker compose -f docker-compose.yml --profile elastic up -d

run-with-meilisearch:
	docker compose -f docker-compose.yml --profile meilisearch up -d

run-workers:
	docker compose -f docker-compose.yml --profile workers up -d

settings:
	curl -s http://localhost:8083/settings | python3 -m json.tool

show-images:
	./scripts/show-images.sh

stop:
	docker stop $$(docker ps -q) || true

tmpfs-setup:
	@if df -T /tmp/docker-buildkit 2>/dev/null | grep -q tmpfs; then \
		echo "tmpfs at /tmp/docker-buildkit already mounted"; \
	else \
		echo "Creating and mounting tmpfs at /tmp/docker-buildkit..."; \
		sudo mkdir -p /tmp/docker-buildkit; \
		sudo mount -t tmpfs -o size=4G,mode=1777 tmpfs /tmp/docker-buildkit; \
		echo "tmpfs mounted successfully"; \
	fi