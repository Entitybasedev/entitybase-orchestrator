#!/bin/bash
set -e
cd "$(dirname "$0")/.."
make stop
make remove
make run
