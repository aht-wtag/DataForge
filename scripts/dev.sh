#!/usr/bin/env bash
set -euo pipefail

echo "==> Starting DataForge (docker compose up)..."
docker compose up --build
