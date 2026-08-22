# Installation

## Quick Start

```bash
just clone          # 1. Clone repos  (or: just git-clone-all)
cp env.example .env # 2. Create config
just setup          #    Initialize environment
just build-run-core # 3. Build & start
```

Takes ~5 minutes first time.

## Common Issues

**"poetry export does not exist"**
```bash
pipx inject poetry poetry-plugin-export
```

**Docker: not enough space**
```bash
df -h /           # Check disk
just check-diskspace # Run check
```

## Detailed Guide

### 1. Python (pyenv)

```bash
pyenv install 3.13.0
pyenv global 3.13.0
```

### 2. pipx

```bash
pip install pipx
pipx ensurepath
```

### 3. Poetry + plugin

```bash
pipx install poetry
pipx inject poetry poetry-plugin-export
poetry --version
```

### 4. Docker

Download from [docker.com](https://docker.com).

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| MYSQL_ROOT_PASSWORD | - | MySQL root |
| RUSTFS_ROOT_USER | fakekey | S3 access key |
| RUSTFS_ROOT_PASSWORD | fakesecret | S3 secret key |

## Cheatsheet

```bash
just run-core    # Start (no build)
just stop   # Stop
just build # Build only
just clean-all # Cleanup
```

## Help?

Need help? Ask in the [Entitybase Telegram group](https://www.wikidata.org/wiki/Wikidata:Tools/Entitybase#Telegram).