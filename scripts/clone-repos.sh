#!/bin/bash
set -e

cd "$(dirname "$0")"

echo "Cloning entitybase-backend (tag v2026.3.2)..."
git clone --depth 1 --branch v2026.3.2 https://github.com/dpriskorn/entitybase-backend.git entitybase-backend

echo "Cloning entitybase-sse (default branch)..."
git clone --depth 1 https://github.com/dpriskorn/entitybase-sse.git entitybase-sse

echo "Done! entitybase-frontend skipped (ignored)"
