.PHONY: help clone build check run stop remove clean release

help:
	@echo "Available targets:"
	@echo "  make clone   - Clone required repositories"
	@echo "  make build   - Build all Docker images for docker-compose"
	@echo "  make check   - Check service health status"
	@echo "  make run     - Build images and start all services"
	@echo "  make stop    - Stop all running services"
	@echo "  make remove  - Stop services and remove containers/volumes"
	@echo "  make clean   - Remove stopped containers, unused images, and build cache"
	@echo "  make release - Create release: update version, commit, and tag (e.g., v2026.3.4)"

release:
	./scripts/run-release.sh

clone:
	./scripts/clone-repos.sh

build:
	./scripts/build-images.sh

check:
	./scripts/check-services.sh

stop:
	docker compose stop

remove: stop
	docker compose down -v

clean:
	docker compose down --remove-orphans || true
	docker network rm entitybase-network 2>/dev/null || true
	docker container prune -f
	docker image prune -a -f
	docker builder prune -f

run: stop clean build
	docker compose up -d
