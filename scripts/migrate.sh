#!/usr/bin/env bash
set -euo pipefail

echo "==> Running tracked migrations..."
docker compose run --rm web bundle exec rails "db:migrate:tracked"
echo "==> Migrations complete."
