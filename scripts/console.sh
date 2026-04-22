#!/usr/bin/env bash
set -euo pipefail

echo "==> Opening Rails console..."
docker compose run --rm web bundle exec rails console
