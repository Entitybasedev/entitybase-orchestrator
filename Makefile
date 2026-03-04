.PHONY: help clone build check run stop remove clean

help:
	@echo "Available targets:"
	@echo "  make clone   - Clone required repositories"
	@echo "  make build   - Build all Docker images for docker-compose"
	@echo "  make check   - Check service health status"
	@echo "  make run     - Build images and start all services"
	@echo "  make stop    - Stop all running services"
	@echo "  make remove  - Stop services and remove containers/volumes"
	@echo "  make clean   - Remove stopped containers, unused images, and build cache"

clone:
	./scripts/clone-repos.sh

build:
	./scripts/build-images.sh

check:
	./scripts/check-services.sh

run: build
	docker compose up -d

stop:
	docker compose stop

remove: stop
	docker compose down -v

clean:
	docker container prune -f
	docker image prune -a -f
	docker builder prune -f
