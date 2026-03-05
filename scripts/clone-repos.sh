#!/bin/bash
set -e

cd "$(dirname "$0")"
cd ..

echo "Creating libs directory..."
mkdir -p libs

echo "Cloning entitybase-backend (tag v2026.3.2)..."
git clone --depth 1 --branch v2026.3.2 https://github.com/dpriskorn/entitybase-backend.git libs/entitybase-backend

echo "Cloning kafka2sse-backend..."
git clone --depth 1 https://github.com/Entitybasedev/kafka2sse-backend.git libs/kafka2sse-backend

echo "Cloning kafka2sse-frontend..."
git clone --depth 1 https://github.com/Entitybasedev/kafka2sse-frontend.git libs/kafka2sse-frontend

echo "Done! entitybase-frontend skipped (ignored)"
