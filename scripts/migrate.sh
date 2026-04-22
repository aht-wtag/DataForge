#!/usr/bin/env bash
set -euo pipefail

echo "==> Running migrations..."
docker compose run --rm web bundle exec rails db:migrate
echo "==> Migrations complete."
