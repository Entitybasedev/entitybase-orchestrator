.PHONY: build build-core-workers build-no-cache build-run-core build-run-core-purge build-run-core-workers build-run-core-workers-meilisearch build-run-workers check check-deps check-diskspace check-setup clean-all clean-all-except-base-images clean-build-cache clean-build-run-core clean-build-run-core-purge clean-build-run-core-workers clean-build-run-core-workers-meilisearch clean-build-run-workers clean-cache-volumes clean-local-images gpla gpsa gsa git-clone-all git-push-all git-pull-all git-status-all elastic help meilisearch pull release remove run-core run-core-purge run-core-workers run-core-workers-meilisearch settings setup show-images stop test-frontend

help:
	@echo "Available targets:"
	@echo "  make build                   - Build all Docker images for docker-compose"
	@echo "  make build-core-workers     - Build and start core + workers"
	@echo "  make build-no-cache          - Build all Docker images without using cache"
	@echo "  make check                   - Check service health status"
	@echo "  make check-deps              - Check required dependencies (poetry, docker, python)"
	@echo "  make check-diskspace         - Check available disk space (requires 2GB minimum)"
	@echo "  make clean-all               - Remove locally built images, containers, volumes, and build cache"
	@echo "  make clean-all-except-base-images - Remove locally built images, containers, volumes, and build cache (keep base images)"
	@echo "  make clean-build-cache       - Clear Docker build cache only (keeps images and containers)"
	@echo "  make build-run-core    - Build and start core services"
	@echo "  make build-run-core-purge - Build and start core + workers + purge worker"
	@echo "  make build-run-core-workers - Build and start core + workers"
	@echo "  make build-run-core-workers-meilisearch - Build and start core + workers + meilisearch"
	@echo "  make build-run-workers - Build and start all services (core + workers)"
	@echo "  make clean-cache-volumes     - Remove containers, volumes, and build cache (keeps images)"
	@echo "  make clean-local-images      - Remove locally built entitybase/kafka2sse images (keeps base images)"
	@echo "  make git-clone-all          - Clone all repositories from LIBS.yml"
	@echo "  make git-push-all           - Push all repos in LIBS.yml (requires git remote)"
	@echo "  make git-pull-all           - Pull all repos in LIBS.yml"
	@echo "  make git-status-all         - Show git status of all repos in LIBS.yml"
	@echo "  make gpla                   - Shortcut for git-pull-all"
	@echo "  make gpsa                   - Shortcut for git-push-all"
	@echo "  make gsa                    - Shortcut for git-status-all"
	@echo "  make elastic                 - Start Elasticsearch and elasticsearch-indexer worker"
	@echo "  make meilisearch              - Start Meilisearch and meilisearch-indexer worker"
	@echo "  make pull                    - Pull latest changes in orchestrator and libs"
	@echo "  make release                 - Create release: update version, commit, and tag (e.g., v2026.3.4)"
	@echo "  make remove                  - Stop services and remove containers/volumes"
	@echo "  make run-core                - Start core services (no build)"
	@echo "  make run-core-purge          - Start core + workers + purge worker (no build)"
	@echo "  make run-core-workers             - Start all services (core + workers, no build)"
	@echo "  make run-core-workers-meilisearch - Start core + workers + meilisearch (no build)"
	@echo "  make settings                - Query the /settings endpoint on localhost:8083"
	@echo "  make setup                   - Initialize environment (run once before first make run)"
	@echo "  make show-images             - Show all entitybase Docker images"
	@echo "  make stop                    - Stop all running containers"
	@echo "  make test-frontend           - Run frontend tests (requires npm)"

setup:
	python3 ./scripts/setup.py

build: check-deps
	@ID_WORKER_ENABLED=${ID_WORKER_ENABLED} JSON_WORKER_ENABLED=${JSON_WORKER_ENABLED} TTL_WORKER_ENABLED=${TTL_WORKER_ENABLED} STATS_WORKER_ENABLED=${STATS_WORKER_ENABLED} ELASTICSEARCH_ENABLED=${ELASTICSEARCH_ENABLED} MEILISEARCH_ENABLED=${MEILISEARCH_ENABLED} PURGE_WORKER_ENABLED=${PURGE_WORKER_ENABLED} INCREMENTAL_RDF_WORKER_ENABLED=${INCREMENTAL_RDF_WORKER_ENABLED} ./scripts/build-images.sh

build-no-cache: check-deps
	@ID_WORKER_ENABLED=${ID_WORKER_ENABLED} JSON_WORKER_ENABLED=${JSON_WORKER_ENABLED} TTL_WORKER_ENABLED=${TTL_WORKER_ENABLED} STATS_WORKER_ENABLED=${STATS_WORKER_ENABLED} ELASTICSEARCH_ENABLED=${ELASTICSEARCH_ENABLED} MEILISEARCH_ENABLED=${MEILISEARCH_ENABLED} PURGE_WORKER_ENABLED=${PURGE_WORKER_ENABLED} INCREMENTAL_RDF_WORKER_ENABLED=${INCREMENTAL_RDF_WORKER_ENABLED} ./scripts/build-images.sh --no-cache

check:
	python3 ./scripts/check_services.py

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

check-setup:
	@if [ -f .env ]; then \
		SETUP=$$(grep "^SETUP_COMPLETED=" .env | cut -d'=' -f2); \
		if [ "$$SETUP" != "true" ]; then \
			echo "Error: Run 'make setup' first to initialize the environment."; \
			exit 1; \
		fi; \
	else \
		echo "Error: .env file not found. Run 'make setup' first."; \
		exit 1; \
	fi

clean-all: clean-local-images
	docker image prune -a -f
	docker builder prune -f
	docker volume prune -f

clean-all-except-base-images: clean-local-images
	docker builder prune -af
	docker volume prune -f
	@echo "Build cache and volumes cleared"

clean-build-cache:
	docker builder prune -af
	@echo "Build cache cleared. Run 'docker system df' to check."

build-run-core: check-deps check-diskspace
	ID_WORKER_ENABLED=false make build
	docker compose -f docker-compose.yml --profile core up -d

clean-build-run-core: build-run-core

build-run-core-purge: check-deps check-diskspace
	ID_WORKER_ENABLED=false PURGE_WORKER_ENABLED=true make build
	docker compose -f docker-compose.yml --profile core up -d
	docker compose -f docker-compose.yml --profile workers up -d purge-worker

clean-build-run-core-purge: build-run-core-purge

build-run-core-workers-meilisearch: check-deps check-diskspace
	ID_WORKER_ENABLED=false JSON_WORKER_ENABLED=true TTL_WORKER_ENABLED=true STATS_WORKER_ENABLED=true MEILISEARCH_ENABLED=true PURGE_WORKER_ENABLED=true INCREMENTAL_RDF_WORKER_ENABLED=true make build
	docker compose -f docker-compose.yml --profile core --profile workers --profile meilisearch up -d

clean-build-run-core-workers-meilisearch: build-run-core-workers-meilisearch

build-run-workers: check-deps check-diskspace
	ID_WORKER_ENABLED=false JSON_WORKER_ENABLED=true TTL_WORKER_ENABLED=true STATS_WORKER_ENABLED=true PURGE_WORKER_ENABLED=true INCREMENTAL_RDF_WORKER_ENABLED=true make build
	docker compose -f docker-compose.yml --profile workers up -d

clean-build-run-workers: build-run-workers

build-core-workers: check-deps check-diskspace
	ID_WORKER_ENABLED=false JSON_WORKER_ENABLED=true TTL_WORKER_ENABLED=true STATS_WORKER_ENABLED=true PURGE_WORKER_ENABLED=true INCREMENTAL_RDF_WORKER_ENABLED=true make build
	docker compose -f docker-compose.yml --profile core --profile workers up -d

clean-build-run-core-workers: build-run-core-workers

build-run-core-workers: check-deps check-diskspace
	ID_WORKER_ENABLED=false JSON_WORKER_ENABLED=true TTL_WORKER_ENABLED=true STATS_WORKER_ENABLED=true PURGE_WORKER_ENABLED=true INCREMENTAL_RDF_WORKER_ENABLED=true make build
	docker compose -f docker-compose.yml --profile core --profile workers up -d

clean-cache-volumes: remove
	docker builder prune -af
	@echo "Build cache cleared"

clean-local-images: remove
	docker container prune -f
	docker builder prune -f
	docker images | grep -E "^entitybase-|^kafka2sse-" | awk '{print $$3}' | xargs -r docker rmi -f || true

git-clone-all:
	./scripts/clone-repos.sh

git-status-all:
	poetry run python ./scripts/git-all.py

git-push-all:
	poetry run python ./scripts/git-all.py push

git-pull-all:
	poetry run python ./scripts/git-all.py pull

gpla: git-pull-all
gpsa: git-push-all
gsa: git-status-all

elastic: check-setup
	ELASTICSEARCH_ENABLED=true docker compose -f docker-compose.yml --profile elastic up -d

meilisearch: check-setup
	MEILISEARCH_ENABLED=true docker compose -f docker-compose.yml --profile meilisearch up -d

pull:
	git pull
	cd libs/entitybase-backend && git pull
	cd libs/entitybase-import && git pull
	cd libs/kafka2sse-backend && git pull
	cd libs/kafka2sse-frontend && git pull

release:
	./scripts/run-release.sh

remove: stop
	docker rm $$(docker ps -aq) || true
	docker network rm $$(docker network ls -q) || true
	docker compose -f docker-compose.yml down -v --remove-orphans
	docker volume prune -f

run-core: check-setup
	ID_WORKER_ENABLED=false docker compose -f docker-compose.yml --profile core up -d

run-core-purge: check-setup
	ID_WORKER_ENABLED=false PURGE_WORKER_ENABLED=true docker compose -f docker-compose.yml --profile core up -d
	docker compose -f docker-compose.yml --profile workers up -d purge-worker

run-core-workers-meilisearch: check-setup
	ID_WORKER_ENABLED=false JSON_WORKER_ENABLED=true TTL_WORKER_ENABLED=true STATS_WORKER_ENABLED=true MEILISEARCH_ENABLED=true PURGE_WORKER_ENABLED=true docker compose -f docker-compose.yml --profile core --profile workers --profile meilisearch up -d

run-core-workers: check-setup
	ID_WORKER_ENABLED=false JSON_WORKER_ENABLED=true TTL_WORKER_ENABLED=true STATS_WORKER_ENABLED=true PURGE_WORKER_ENABLED=true docker compose -f docker-compose.yml --profile core --profile workers up -d

settings:
	curl -s http://localhost:8083/settings | python3 -m json.tool

show-images:
	./scripts/show-images.sh

stop:
	docker stop $$(docker ps -q) || true

test-frontend:
	cd frontend && npm install && npm run lint && npm run test && npm run build