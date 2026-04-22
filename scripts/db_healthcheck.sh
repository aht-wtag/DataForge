#!/usr/bin/env bash
set -euo pipefail

echo "==> Checking PostgreSQL health..."
docker compose exec db pg_isready -U "${POSTGRES_USER:-dataforge}" -d "${POSTGRES_DB:-dataforge_development}"

if [ $? -eq 0 ]; then
  echo "✓ PostgreSQL is healthy."
else
  echo "✗ PostgreSQL is NOT healthy."
  exit 1
fi
