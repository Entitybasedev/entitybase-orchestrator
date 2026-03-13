#!/bin/bash
set -e

cd "$(dirname "$0")"
cd ..

echo "Creating libs directory..."
mkdir -p libs

clone_repo() {
    local repo_url=$1
    local target_dir=$2
    local description=$3
    
    if [ -d "$target_dir" ]; then
        echo "$description already exists, skipping..."
    else
        echo "Cloning $description..."
        git clone --depth 1 $repo_url "$target_dir"
    fi
}

clone_repo "https://github.com/dpriskorn/entitybase-backend.git" "libs/entitybase-backend" "entitybase-backend"
clone_repo "https://github.com/Entitybasedev/kafka2sse-backend.git" "libs/kafka2sse-backend" "kafka2sse-backend"
clone_repo "https://github.com/Entitybasedev/kafka2sse-frontend.git" "libs/kafka2sse-frontend" "kafka2sse-frontend"

echo "Done! entitybase-frontend skipped (ignored)"
