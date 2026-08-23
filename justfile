# Entitybase Orchestrator task runner (replacement for Makefile)
# Requires: just (https://github.com/casey/just), docker, docker compose, python3, poetry

set shell := ["bash", "-cu"]

compose_file := env_var_or_default("COMPOSE_FILE", "docker-compose.yml")
compose := "docker compose -f " + compose_file
full_compose := "docker compose -f docker-compose.mysql.yml"
worker_flags := "JSON_WORKER_ENABLED=true TTL_WORKER_ENABLED=true STATS_WORKER_ENABLED=true PURGE_WORKER_ENABLED=true INCREMENTAL_RDF_WORKER_ENABLED=true"
meilisearch_flags := worker_flags + " MEILISEARCH_ENABLED=true"

alias clean := clean-all
alias gpla := git-pull-all
alias gpsa := git-push-all
alias gsa := git-status-all

# List available recipes
@default:
    @just --list --list-heading "Available recipes:" --list-subheading ""

setup:
    python3 ./scripts/setup.py

check-deps:
    #!/usr/bin/env bash
    echo "Checking dependencies..."
    command -v docker >/dev/null 2>&1 || { echo "Error: docker is required but not installed."; exit 1; }
    docker compose version >/dev/null 2>&1 || { echo "Error: docker compose plugin is required but not installed."; exit 1; }
    command -v python3 >/dev/null 2>&1 || { echo "Error: python3 is required but not installed."; exit 1; }
    command -v poetry >/dev/null 2>&1 || { echo "Error: poetry is required but not installed. Install via your OS package manager (e.g., apt install poetry, pacman -S python-poetry, brew install poetry)"; exit 1; }
    echo "All dependencies satisfied."

check-diskspace:
    #!/usr/bin/env bash
    echo "Disk space:"
    df -h / | tail -1 | awk '{print "  /:              " $4 " free (" $3 " used / " $2 " total")}'
    if mountpoint -q /media/storage 2>/dev/null; then
        df -h /media/storage | tail -1 | awk '{print "  /media/storage: " $4 " free (" $3 " used / " $2 " total")}'
        AVAILABLE_STORAGE=$(df -h /media/storage | tail -1 | awk '{print $4}')
    else
        echo "  /media/storage: not mounted"
        AVAILABLE_STORAGE=""
    fi
    AVAILABLE_ROOT=$(df -h / | tail -1 | awk '{print $4}')
    check_available() {
        val="$1"
        name="$2"
        case "$val" in
            *[0-9]G)
                SIZE=${val%G}
                if [ "$(echo "$SIZE >= 1" | awk '{if ($1 >= 1) print 1; else print 0}')" -eq 1 ]; then
                    return 0
                fi
                ;;
            *[0-9]M)
                echo "Error: Less than 1GB available on $name"
                exit 1
                ;;
        esac
        echo "Error: Less than 1GB available on $name"
        exit 1
    }
    check_available "$AVAILABLE_ROOT" "/"
    if [ -n "$AVAILABLE_STORAGE" ]; then
        check_available "$AVAILABLE_STORAGE" "/media/storage"
    fi

[private]
check-setup:
    #!/usr/bin/env bash
    if [ -f .env ]; then
        SETUP=$(grep "^SETUP_COMPLETED=" .env | cut -d'=' -f2)
        if [ "$SETUP" != "true" ]; then
            echo "Error: Run 'just setup' first to initialize the environment."
            exit 1
        fi
    else
        echo "Error: .env file not found. Run 'just setup' first."
        exit 1
    fi

check:
    python3 ./scripts/check_services.py

settings:
    curl -s http://localhost:8083/settings | python3 -m json.tool

show-images:
    ./scripts/show-images.sh

build *args: check-deps
    ./scripts/build-images.sh {{args}}

build-no-cache: check-deps
    ./scripts/build-images.sh --no-cache

rebuild *containers:
    python3 scripts/rebuild_containers.py {{containers}}

run-core: check-setup
    ID_WORKER_ENABLED=false {{compose}} --profile core up -d

run-core-purge: check-setup
    ID_WORKER_ENABLED=false PURGE_WORKER_ENABLED=true {{full_compose}} --profile core up -d
    {{full_compose}} --profile workers up -d purge-worker

run-core-workers: check-setup
    ID_WORKER_ENABLED=false {{worker_flags}} {{full_compose}} --profile core --profile workers up -d

run-core-workers-meilisearch: check-setup
    ID_WORKER_ENABLED=false {{meilisearch_flags}} {{full_compose}} --profile core --profile workers --profile meilisearch up -d

build-run-core: check-deps check-diskspace
    ID_WORKER_ENABLED=false just build
    {{compose}} --profile core up -d

build-run-core-purge: check-deps check-diskspace
    ID_WORKER_ENABLED=false PURGE_WORKER_ENABLED=true just build
    {{full_compose}} --profile core up -d
    {{full_compose}} --profile workers up -d purge-worker

build-run-core-workers: check-deps check-diskspace
    ID_WORKER_ENABLED=false {{worker_flags}} just build
    {{full_compose}} --profile core --profile workers up -d

build-run-core-workers-meilisearch: check-deps check-diskspace
    ID_WORKER_ENABLED=false {{meilisearch_flags}} just build
    {{full_compose}} --profile core --profile workers --profile meilisearch up -d

alias build-run-workers := build-run-core-workers
alias build-core-workers := build-run-core-workers
alias clean-build-run-core := build-run-core
alias clean-build-run-core-purge := build-run-core-purge
alias clean-build-run-core-workers := build-run-core-workers
alias clean-build-run-core-workers-meilisearch := build-run-core-workers-meilisearch

elastic: check-setup
    ELASTICSEARCH_ENABLED=true {{full_compose}} --profile elastic up -d

meilisearch: check-setup
    MEILISEARCH_ENABLED=true {{full_compose}} --profile meilisearch up -d

git-clone-all:
    ./scripts/clone-repos.sh

git-status-all:
    poetry run python ./scripts/git-all.py

git-push-all:
    poetry run python ./scripts/git-all.py push

git-pull-all:
    poetry run python ./scripts/git-all.py pull

pull:
    git pull
    poetry run python ./scripts/git-all.py pull

stop:
    docker stop $(docker ps -q) || true

remove: stop
    docker rm $(docker ps -aq) || true
    docker network rm $(docker network ls -q) || true
    docker compose -f docker-compose.yml down -v --remove-orphans
    docker volume prune -f

clean-cache-volumes: remove
    docker builder prune -af
    @echo "Build cache cleared"

clean-local-images: remove
    docker container prune -f
    docker builder prune -f
    docker images | grep -E "^entitybase-|^kafka2sse-" | awk '{print $3}' | xargs -r docker rmi -f || true

clean-all-except-base-images: clean-local-images
    docker builder prune -af
    docker volume prune -f
    @echo "Build cache and volumes cleared"

clean-all: clean-local-images
    docker image prune -a -f
    docker builder prune -f
    docker volume prune -f

release:
    ./scripts/run-release.sh

test-frontend:
    cd frontend && npm install && npm run lint && npm run test && npm run build

ps:
    {{compose}} ps

logs service:
    {{compose}} logs -f {{service}}

restart service:
    {{compose}} restart {{service}}

# Native local dev services (systemd, no Docker) - see DEV.md
dev-up:
    sudo systemctl enable --now mariadb rustfs valkey meilisearch

dev-stop:
    sudo systemctl stop mariadb rustfs valkey meilisearch

dev-status:
    systemctl status mariadb rustfs valkey meilisearch --no-pager || true

dev-check:
    #!/usr/bin/env bash
    fail=0
    if sudo mariadb -e "SELECT 1" >/dev/null 2>&1; then echo "mysql     : OK"; else echo "mysql     : FAIL"; fail=1; fi
    if curl -sf http://localhost:9000/health >/dev/null 2>&1; then echo "rustfs    : OK"; else echo "rustfs    : FAIL"; fail=1; fi
    if valkey-cli ping 2>/dev/null | grep -q PONG; then echo "valkey    : OK"; else echo "valkey    : FAIL"; fail=1; fi
    if curl -sf http://localhost:7700/health >/dev/null 2>&1; then echo "meilisearch: OK"; else echo "meilisearch: FAIL"; fail=1; fi
    exit $fail
