#!/usr/bin/env bash
set -euo pipefail

echo "==> Building Docker images..."
docker compose build --no-cache
echo "==> Build complete."
