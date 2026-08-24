# Development

Local development on Arch Linux using native services via systemd. No Docker.

| Service     | Port(s)   | Purpose                    |
|-------------|-----------|----------------------------|
| MariaDB     | 3306      | Database                   |
| rustfs      | 9000/9001 | S3-compatible storage + UI |
| Valkey      | 6379      | Cache                      |
| Meilisearch | 7700      | Full-text search           |

Note: `redpanda-bin` provides the `rpk` CLI, but the broker binary is not packaged
for Arch yet, so change streaming is disabled locally (`STREAMING_ENABLED=false`).

## 1. Install packages

```bash
sudo pacman -S --needed mariadb valkey
yay -S --needed rustfs-bin redpanda-bin meilisearch-bin
```

## 2. One-time setup per service

### MySQL (MariaDB)

Initialize data directory, start the service, create database and user:

```bash
sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
sudo systemctl enable --now mariadb

sudo mariadb <<'SQL'
CREATE DATABASE IF NOT EXISTS entitybase;
CREATE USER IF NOT EXISTS 'entitybase'@'localhost' IDENTIFIED BY 'entitybase';
CREATE USER IF NOT EXISTS 'entitybase'@'127.0.0.1' IDENTIFIED BY 'entitybase';
GRANT ALL PRIVILEGES ON entitybase.* TO 'entitybase'@'localhost';
GRANT ALL PRIVILEGES ON entitybase.* TO 'entitybase'@'127.0.0.1';
FLUSH PRIVILEGES;
SQL
```

### rustfs

Create directories and set config in `/etc/default/rustfs`:

```bash
sudo mkdir -p /var/lib/rustfs /var/log/rustfs

sudo tee /etc/default/rustfs > /dev/null <<'EOF'
RUSTFS_ACCESS_KEY=fakekey
RUSTFS_SECRET_KEY=fakesecret
RUSTFS_VOLUMES="/var/lib/rustfs"
RUSTFS_ADDRESS=":9000"
RUSTFS_CONSOLE_ENABLE=true
RUSTFS_CONSOLE_ADDRESS=":9001"
RUSTFS_OBS_LOGGER_LEVEL=error
RUSTFS_OBS_LOG_DIRECTORY="/var/log/rustfs/"
EOF
```

Then start it:

```bash
sudo systemctl enable --now rustfs
```

### Valkey

Zero config needed for development:

```bash
sudo systemctl enable --now valkey
```

### Meilisearch

Install via AUR:

```bash
yay -S --needed meilisearch-bin
```

Start the service:

```bash
sudo systemctl enable --now meilisearch
```

By default it runs on port 7700 with no master key. To configure, create `/etc/default/meilisearch`:

```bash
MEILI_ENV=development
MEILI_MASTER_KEY=
```

## 3. Daily use

```bash
just dev-up       # start all four
just dev-stop     # stop all four
just dev-status   # show status
just dev-check    # health-check all four
```

## 4. Run the backend API

```bash
just git-clone-all
cd libs/entitybase-backend
poetry install --with dev

export PYTHONPATH=src
export DB_TYPE=vitess
export DB_HOST=127.0.0.1 DB_PORT=3306
export DB_DATABASE=entitybase DB_USER=entitybase DB_PASSWORD=entitybase
export S3_ENDPOINT=http://localhost:9000
export STREAMING_ENABLED=false
export MEILISEARCH_HOST=127.0.0.1
export MEILISEARCH_PORT=7700

poetry run uvicorn models.rest_api.main:app --port 8081 --workers 4
```

API docs: <http://localhost:8081/docs>

> Use 1 worker per CPU core. For local dev with `--reload`, uvicorn uses a single worker by default. For production-like load, see section 6 (HAProxy with 4 instances).

## 5. Running tests

```bash
cd libs/entitybase-backend

# Unit tests (no Docker needed, all dependencies mocked)
just test-unit

# Individual unit test groups
just test-unit-01   # config, data, services, validation, json_parser
just test-unit-02   # internal_representation, workers
just test-unit-03   # infrastructure, rdf_builder
just test-unit-04   # rest_api

# E2E tests (needs running services: just dev-up)
just test-e2e

# Integration tests (needs running API)
just test-integration

# Contract tests
just test-contract

# All tests
just tests

# Fast tests (unit + e2e + contract, no integration)
just test-fast

# Linting
just lint

# Lint + all tests
just lint-test-all
```

## 6. Load Balancer with HAProxy

Run 4 backend instances (one per CPU) behind HAProxy on port 8080.

### Install HAProxy

```bash
sudo pacman -S haproxy
```

### HAProxy config

Create `/etc/haproxy/haproxy.cfg`:

```cfg
global
    log stdout format raw local0
    maxconn 4096

defaults
    log     global
    mode    http
    option  httplog
    timeout connect 5s
    timeout client  30s
    timeout server  30s

frontend http_front
    bind *:8080
    default_backend entitybase_back

backend entitybase_back
    balance roundrobin
    server api1 127.0.0.1:8081 check
    server api2 127.0.0.1:8082 check
    server api3 127.0.0.1:8083 check
    server api4 127.0.0.1:8084 check
```

### Start backends + HAProxy

```bash
cd libs/entitybase-backend
export PYTHONPATH=src
export DB_TYPE=vitess
export DB_HOST=127.0.0.1 DB_PORT=3306
export DB_DATABASE=entitybase DB_USER=entitybase DB_PASSWORD=entitybase
export S3_ENDPOINT=http://localhost:9000
export STREAMING_ENABLED=false
export MEILISEARCH_HOST=127.0.0.1
export MEILISEARCH_PORT=7700

# Start 4 backend instances (one per CPU)
for port in 8081 8082 8083 8084; do
  poetry run uvicorn models.rest_api.main:app --port $port --workers 1 &
done

# Start HAProxy
sudo systemctl start haproxy
```

### Stop

```bash
# Kill backends
kill $(pgrep -f "uvicorn models.rest_api.main") 2>/dev/null

# Stop HAProxy
sudo systemctl stop haproxy
```

API docs: <http://localhost:8080/docs>

## Connection reference

| Service         | Address                 | Credentials            |
|-----------------|-------------------------|------------------------|
| HAProxy (LB)    | `http://localhost:8080` | —                      |
| Backend (×4)    | `127.0.0.1:8081–8084`  | —                      |
| MySQL           | `127.0.0.1:3306`        | `entitybase`/`entitybase`, db `entitybase` |
| rustfs (S3 API) | `http://localhost:9000` | `fakekey`/`fakesecret` |
| rustfs console  | `http://localhost:9001` | `fakekey`/`fakesecret` |
| Valkey          | `localhost:6379`        | none                   |
| Meilisearch     | `http://localhost:7700` | none                   |

## Resetting data

```bash
# Reset MySQL
sudo mariadb -e 'DROP DATABASE IF EXISTS entitybase;'  # then redo step 2

# Wipe rustfs
sudo systemctl stop rustfs && sudo rm -rf /var/lib/rustfs/*

# Wipe Meilisearch
sudo systemctl stop meilisearch && sudo rm -rf /var/lib/meilisearch/*

# Flush Valkey
valkey-cli FLUSHALL
```
