#!/usr/bin/env bash
set -euo pipefail

echo "==> Seeding database..."
docker compose run --rm web bundle exec rails db:seed
echo "==> Seeding complete."
