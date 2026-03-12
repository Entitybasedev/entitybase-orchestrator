.PHONY: help clone build build-no-cache check check-diskspace run_core run_workers run-build-no-cache stop remove clean clean-all reclaim release show-images settings

help:
	@echo "Available targets:"
	@echo "  make clone          - Clone required repositories"
	@echo "  make build         - Build all Docker images for docker-compose"
	@echo "  make build-no-cache  - Build all Docker images without using cache"
	@echo "  make run-build-no-cache - Build without cache and start core services"
	@echo "  make check         - Check service health status"
	@echo "  make check-diskspace - Check available disk space (requires 2GB minimum)"
	@echo "  make run_core       - Build images and start core services"
	@echo "  make run_workers   - Build images and start all services (core + workers)"
	@echo "  make stop          - Stop all running services"
	@echo "  make remove        - Stop services and remove containers/volumes"
	@echo "  make clean         - Remove stopped containers, volumes, and unused images"
	@echo "  make clean-all     - Remove all containers, images, volumes, and build cache"
	@echo "  make reclaim      - Reclaim disk space (prune unused images, volumes, build cache)"
	@echo "  make release       - Create release: update version, commit, and tag (e.g., v2026.3.4)"
	@echo "  make show-images  - Show all entitybase Docker images"
	@echo "  make settings      - Query the /settings endpoint on localhost:8083"

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
	docker compose stop

remove: stop
	docker compose down -v --remove-orphans

clean:
	docker compose down -v --remove-orphans || true
	docker container prune -f

clean-all: stop
	docker compose down -v --remove-orphans || true
	docker container prune -f
	docker image prune -a -f
	docker builder prune -f
	docker volume prune -f

reclaim:
	docker image prune -a -f
	docker volume prune -f
	docker builder prune -f
	@echo "Disk space reclaimed. Run 'docker system df' to check."

run: run_core

run_core: check-diskspace stop clean build
	docker compose --profile core up -d

run_workers: check-diskspace stop clean build
	docker compose --profile workers up -d

reset:
	./scripts/reset.sh

show-images:
	./scripts/show-images.sh

settings:
	curl -s http://localhost:8083/settings | python3 -m json.tool
