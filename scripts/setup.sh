#!/usr/bin/env bash
set -euo pipefail

echo "==> Checking .env file..."
if [ ! -f .env ]; then
  echo "    Creating .env from .env.example..."
  cp .env.example .env
  echo "    ⚠  Please review .env and set proper values before continuing."
  exit 1
fi

echo "==> Building Docker images..."
docker compose build

echo "==> Creating databases and running migrations..."
docker compose run --rm web bundle exec rails db:create db:migrate

echo "==> Seeding database..."
docker compose run --rm web bundle exec rails db:seed

echo "==> Setup complete! Run 'bash scripts/dev.sh' to start."
