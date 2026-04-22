#!/usr/bin/env bash
set -euo pipefail

STEP=${1:-1}
echo "==> Rolling back ${STEP} migration(s)..."
docker compose run --rm web bundle exec rails db:rollback STEP="${STEP}"
echo "==> Rollback complete."
