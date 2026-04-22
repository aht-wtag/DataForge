#!/usr/bin/env bash
set -euo pipefail

echo "==> Stopping DataForge..."
docker compose down
echo "==> Stopped."
