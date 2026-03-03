.PHONY: help build run stop remove

help:
	@echo "Available targets:"
	@echo "  make build   - Build all Docker images for docker-compose"
	@echo "  make run     - Build images and start all services"
	@echo "  make stop    - Stop all running services"
	@echo "  make remove  - Stop services and remove containers/volumes"

build:
	./scripts/build-images.sh

run: build
	docker compose up -d

stop:
	docker compose stop

remove: stop
	docker compose down -v
