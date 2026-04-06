# Installation

## Prerequisites

| Tool | Version | Description |
|------|---------|-------------|
| [pyenv](https://github.com/pyenv/pyenv) | latest | Python version manager |
| [pipx](https://pipx.pypa.io/) | latest | Python package manager (isolate tools) |
| Docker | latest | Container runtime |
| Docker Compose | latest | Container orchestration |

### Install Python via pyenv

```bash
# Install pyenv (see https://github.com/pyenv/pyenv#installation)

# Install Python 3.13
pyenv install 3.13.0

# Set global version
pyenv global 3.13.0

# Verify
python --version
```

### Install pipx

```bash
# Using pip (via pyenv Python)
pip install pipx

# Using brew (macOS)
brew install pipx

# Then ensure pipx is on your PATH
pipx ensurepath
```

## Poetry 2.0+ Setup

Poetry 2.0+ moved the `export` command to a separate plugin. Use pipx to keep Poetry isolated:

```bash
# Install Poetry via pipx
pipx install poetry

# Install the export plugin (required for build scripts)
pipx inject poetry poetry-plugin-export

# Verify installation
poetry --version
poetry plugin list
```

### Alternative: pip installation

If you prefer pip over pipx:

```bash
pip install poetry poetry-plugin-export
```

## Initial Setup

```bash
# Clone repositories
make clone

# Copy environment template
cp .env.example .env

# Build and start services
make run
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| MYSQL_ROOT_PASSWORD | (empty) | MySQL root password |
| MINIO_ROOT_USER | fakekey | MinIO access key |
| MINIO_ROOT_PASSWORD | fakesecret | MinIO secret key |
| ELASTICSEARCH_HOST | elasticsearch | Elasticsearch host |
| ELASTICSEARCH_PORT | 9200 | Elasticsearch port |
| ELASTICSEARCH_INDEX | entitybase | Elasticsearch index name |

## Troubleshooting

### Poetry export command not found

If you get `The requested command export does not exist`, install the plugin:

```bash
pipx inject poetry poetry-plugin-export
```

### Docker build fails

Ensure you have at least 2GB free disk space:

```bash
make check-diskspace
```

## Quick Reference

```bash
# Build images
make build

# Start services
make run

# Stop services
make stop

# Full cleanup
make clean-all
```