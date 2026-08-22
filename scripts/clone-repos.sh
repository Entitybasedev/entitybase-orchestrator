#!/bin/bash
set -e

cd "$(dirname "$0")"
cd ..

echo "Creating libs directory..."
mkdir -p libs

python3 - <<'PYTHON'
import subprocess
import os

try:
    import yaml

    with open("LIBS.yml", "r") as f:
        config = yaml.safe_load(f)
    repos = config.get("repos", [])
except ImportError:
    # Minimal fallback parser for the simple LIBS.yml format
    # (avoids requiring PyYAML on systems where it is not installed)
    import re

    with open("LIBS.yml", "r") as f:
        content = f.read()
    repos = [
        {"name": m.group(1), "url": m.group(2)}
        for m in re.finditer(r"-\s*name:\s*(\S+)\s*\n\s*url:\s*(\S+)", content)
    ]

for item in repos:
    name = item["name"]
    url = item["url"]
    target_dir = os.path.join("libs", name)

    if os.path.exists(target_dir):
        pass
    else:
        print(f"Cloning {name}...")
        subprocess.run(["git", "clone", "--depth", "1", url, target_dir], check=True)

print("Done!")
PYTHON
