# AGENTS.md - Entitybase Orchestrator

Agent instructions for the Entitybase Orchestrator project.

## Project Overview

Docker orchestration for Entitybase services - a billion-scale Wikibase JSON and RDF schema compatible backend.

## Directory Structure

```
entitybase-orchestrator/
├── libs/                    # Cloned git repositories (DO NOT edit directly)
│   ├── entitybase-backend/  # Main REST API (Python/FastAPI)
│   ├── entitybase-frontend/ # Frontend application
│   ├── kafka2sse-backend/  # Kafka to SSE gateway (Python/Litestar)
│   ├── kafka2sse-frontend/  # SSE Frontend
│   └── entitybase-artwork/ # Logo and assets
├── frontend/                # Orchestrator's own frontend (Vite)
├── scripts/                # Automation scripts
├── docker-compose.yml      # Main Docker Compose configuration
├── Makefile                # Build and run commands
└── AGENTS.md              # This file
```

## Key Commands

```bash
# Clone all repositories (run once)
make clone

# Build and start services
make run           # Core services only (default)
make run_workers   # Core + workers

# Build only
make build         # Build all Docker images

# Stop and cleanup
make stop          # Stop running services
make remove        # Stop and remove containers/volumes
make clean         # Prune Docker system

# Check status
make check         # Check service health
make show-images   # Show built Docker images
```

## Services

| Service | Port | Description |
|---------|------|-------------|
| mysql | 3306 | MySQL 8.0 database |
| minio | 9000, 9001 | S3 storage (API + console) |
| redpanda | 9092, 9644 | Kafka broker |
| redpanda-console | 8084 | Kafka UI |
| entitybase-backend | 8080 | REST API |
| entitybase-sse-backend | 8888 | SSE API |
| entitybase-sse-frontend | 8889 | SSE Frontend |
| idworker | 8001 | ID generation service |

## Development Workflow

1. **Clone repositories first**:
   ```bash
   make clone
   ```

2. **Make changes in `libs/` sub-projects**:
   - Each sub-project in `libs/` is an independent git repository
   - Edit, commit, and push changes within each sub-project directly
   - See each sub-project's AGENTS.md for specific coding guidelines

3. **Rebuild images after changes**:
   ```bash
   make build
   ```

4. **Restart services**:
   ```bash
   make run
   ```

## Sub-project AGENTS.md Files

Each sub-project in `libs/` has its own AGENTS.md:
- [libs/entitybase-backend/AGENTS.md](libs/entitybase-backend/AGENTS.md) - Main backend (FastAPI, Python 3.13+, Poetry)

## Technology Stack

- **Container**: Docker, Docker Compose
- **Database**: MySQL 8.0
- **Storage**: MinIO (S3-compatible)
- **Messaging**: Redpanda (Kafka-compatible)
- **Backend**: Python, FastAPI, Pydantic v2
- **SSE Gateway**: Python, Litestar

## Environment Variables

Copy `.env.example` to `.env` before running:
```bash
cp .env.example .env
```

Key variables:
- `MYSQL_ROOT_PASSWORD` - MySQL root password
- `MINIO_ROOT_USER` - MinIO access key (default: fakekey)
- `MINIO_ROOT_PASSWORD` - MinIO secret key (default: fakesecret)

## Notes

- The `libs/` directory contains cloned git repositories - work within them as separate projects
- The orchestrator only manages Docker Compose; it doesn't contain application code
- Each sub-project has its own build process and tests
