# Installation

## Få igång snabbt

```bash
make clone          # 1. Klona repos
cp .env.example .env # 2. Skapa config
make run           # 3. Bygg & starta
```

Det tar ~5 minuter första gången.

## Vanliga problem

**"poetry export does not exist"**
```bash
pipx inject poetry poetry-plugin-export
```

**Docker: not enough space**
```bash
df -h /      # Kolla disk
make check-diskspace  # Kör check
```

## Detaljerad guide

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

Ladda ner från [docker.com](https://docker.com).

## Miljövariabler

| Variabel | Default | Beskrivning |
|----------|---------|-------------|
| MYSQL_ROOT_PASSWORD | - | MySQL root |
| MINIO_ROOT_USER | fakekey | S3-nyckel |
| MINIO_ROOT_PASSWORD | fakesecret | S3-hemlighet |

## Cheatsheet

```bash
make run    # Starta
make stop   # Stoppa
make build # Bygg bara
make clean # Städ
```