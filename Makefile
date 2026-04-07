.PHONY: help clone build build-no-cache check check-deps check-diskspace clean-all clean-local elastic reclaim release remove run run-build-no-cache run-clean-all-with-elastic run-core run-core-purge run-with-elastic run-workers settings show-images stop tmpfs-setup

help:
	@echo "Available targets:"
	@echo "  make build                   - Build all Docker images for docker-compose"
	@echo "  make build-no-cache          - Build all Docker images without using cache"
	@echo "  make check                   - Check service health status"
	@echo "  make check-deps              - Check required dependencies (poetry, docker, python)"
	@echo "  make check-diskspace         - Check available disk space (requires 2GB minimum)"
	@echo "  make clean-all               - Remove all containers, images, volumes, and build cache"
	@echo "  make clean-local             - Remove locally built images only (keep base images)"
	@echo "  make clone                   - Clone required repositories"
	@echo "  make elastic                 - Start Elasticsearch and elasticsearch-indexer worker"
	@echo "  make reclaim                 - Reclaim disk space (prune unused images, volumes, build cache)"
	@echo "  make release                 - Create release: update version, commit, and tag (e.g., v2026.3.4)"
	@echo "  make remove                  - Stop services and remove containers/volumes"
	@echo "  make run                     - Build images and start core services"
	@echo "  make run-build-no-cache      - Build without cache and start core services"
	@echo "  make run-clean-all-with-elastic - Clean all and run with elasticsearch"
	@echo "  make run-core                - Build images and start core services"
	@echo "  make run-core-purge          - Manually trigger purge worker once"
	@echo "  make run-with-elastic        - Build and run core + workers + elasticsearch"
	@echo "  make run-workers             - Build images and start all services (core + workers)"
	@echo "  make settings                - Query the /settings endpoint on localhost:8083"
	@echo "  make show-images             - Show all entitybase Docker images"
	@echo "  make stop                    - Stop all running containers"
	@echo "  make test-integration        - Run integration tests in container (requires docker)"
	@echo "  make tmpfs-setup             - Setup tmpfs for buildkit cache (requires sudo)"

release:
	./scripts/run-release.sh

clone:
	./scripts/clone-repos.sh

check-deps:
	@echo "Checking dependencies..."
	@command -v docker >/dev/null 2>&1 || { echo "Error: docker is required but not installed."; exit 1; }
	@command -v python3 >/dev/null 2>&1 || { echo "Error: python3 is required but not installed."; exit 1; }
	@command -v poetry >/dev/null 2>&1 || { echo "Error: poetry is required but not installed. Install via your OS package manager (e.g., apt install poetry, pacman -S python-poetry, brew install poetry)"; exit 1; }
	@echo "All dependencies satisfied."

build: check-deps
	./scripts/build-images.sh

build-no-cache: check-deps
	./scripts/build-images.sh --no-cache

run-build-no-cache: clean-local build-no-cache
	docker compose -f docker-compose.yml up -d

check:
	./scripts/check-services.sh

check-diskspace:
	@if df /dev/mapper/arch >/dev/null 2>&1; then \
		DEVICE="/dev/mapper/arch"; \
	elif df /dev/sda1 >/dev/null 2>&1; then \
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
			if [ "$$(echo "$$SIZE >= 2" | awk '{if ($$1 >= 2) print 1; else print 0}')" -eq 1 ]; then exit 0; fi \
		;; \
		*[0-9]M) \
			echo "Error: Less than 2GB available"; \
			exit 1; \
		;; \
	esac; \
	echo "Error: Less than 2GB available"; \
	exit 1

stop:
	docker stop $$(docker ps -q) || true
	docker rm $$(docker ps -aq) || true

remove: stop
	docker compose -f docker-compose.yml down -v --remove-orphans

clean-local: stop
	docker compose -f docker-compose.yml down -v --remove-orphans || true
	docker container prune -f
	docker builder prune -f
	docker images | grep -E "^entitybase-|^kafka2sse-" | awk '{print $$3}' | xargs -r docker rmi -f || true

clean-all: clean-local
	docker image prune -a -f
	docker builder prune -f
	docker volume prune -f

reclaim:
	docker image prune -a -f
	docker volume prune -f
	docker builder prune -f
	@echo "Disk space reclaimed. Run 'docker system df' to check."

tmpfs-setup:
	@if df -T /tmp/docker-buildkit 2>/dev/null | grep -q tmpfs; then \
		echo "tmpfs at /tmp/docker-buildkit already mounted"; \
	else \
		echo "Creating and mounting tmpfs at /tmp/docker-buildkit..."; \
		sudo mkdir -p /tmp/docker-buildkit; \
		sudo mount -t tmpfs -o size=4G,mode=1777 tmpfs /tmp/docker-buildkit; \
		echo "tmpfs mounted successfully"; \
	fi

run: run-core

run-core: check-deps check-diskspace clean-local build
	docker compose -f docker-compose.yml --profile core up -d

run-workers: check-deps check-diskspace clean-local build
	docker compose -f docker-compose.yml --profile workers up -d

run-core-purge: check-deps check-diskspace clean-local build
	docker compose -f docker-compose.yml --profile core up -d
	docker compose up -d purge-worker

reset:
	./scripts/reset.sh

show-images:
	./scripts/show-images.sh

settings:
	curl -s http://localhost:8083/settings | python3 -m json.tool

elastic:
	docker compose -f docker-compose.yml --profile elastic up -d

run-with-elastic: clean-local build check-diskspace
	docker compose -f docker-compose.yml --profile elastic up -d

run-clean-all-with-elastic: clean-all build check-diskspace
	docker compose -f docker-compose.yml --profile elastic up -d

test-integration: clean-local build
	docker compose -f docker-compose.yml --profile test up -d
	@echo "Waiting for tests to complete..."
	@docker compose wait test-runner || EXIT_CODE=$$?; \
	if [ "$$EXIT_CODE" != "0" ]; then \
		echo "Tests failed! Exit code: $$EXIT_CODE"; \
		docker compose logs test-runner; \
		exit 1; \
	fi
	@echo ""
	@echo "Tests passed. Run 'make stop' to stop services."