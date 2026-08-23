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

Set credentials in `/etc/default/rustfs`:

```bash
RUSTFS_ACCESS_KEY=fakekey
RUSTFS_SECRET_KEY=fakesecret
RUSTFS_VOLUMES="/var/lib/rustfs"
RUSTFS_ADDRESS=":9000"
RUSTFS_CONSOLE_ENABLE=true
RUSTFS_CONSOLE_ADDRESS=":9001"
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
export VITESS_HOST=127.0.0.1 VITESS_PORT=3306
export VITESS_DATABASE=entitybase VITESS_USER=entitybase VITESS_PASSWORD=entitybase
export S3_ENDPOINT=http://localhost:9000
export STREAMING_ENABLED=false
export MEILISEARCH_HOST=127.0.0.1
export MEILISEARCH_PORT=7700

poetry run uvicorn models.rest_api.main:app --port 8000 --reload
```

API docs: <http://localhost:8000/docs>

## Connection reference

| Service         | Address                 | Credentials            |
|-----------------|-------------------------|------------------------|
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
