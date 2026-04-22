#!/usr/bin/env bash
set -euo pipefail

echo "==> Running RSpec test suite..."
docker compose run --rm web bundle exec rspec "$@"
echo "==> Tests complete."
