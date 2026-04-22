#!/usr/bin/env bash
set -euo pipefail

FAIL=0

echo "==> Checking PostgreSQL..."
if docker compose exec -T db pg_isready -U "${POSTGRES_USER:-dataforge}" -d "${POSTGRES_DB:-dataforge_development}" > /dev/null 2>&1; then
  echo "  ✓ PostgreSQL: OK"
else
  echo "  ✗ PostgreSQL: FAIL"
  FAIL=1
fi

echo "==> Checking Redis..."
if docker compose exec -T redis redis-cli ping > /dev/null 2>&1; then
  echo "  ✓ Redis: OK"
else
  echo "  ✗ Redis: FAIL"
  FAIL=1
fi

echo "==> Checking Rails web server..."
if curl -sf http://localhost:${APP_PORT:-3000}/up > /dev/null 2>&1; then
  echo "  ✓ Rails Web: OK"
else
  echo "  ✗ Rails Web: FAIL"
  FAIL=1
fi

echo "==> Checking Sidekiq..."
SIDEKIQ_PID=$(docker compose exec -T sidekiq pgrep -f "sidekiq" 2>/dev/null || true)
if [ -n "$SIDEKIQ_PID" ]; then
  echo "  ✓ Sidekiq: OK (PID: ${SIDEKIQ_PID})"
else
  echo "  ✗ Sidekiq: FAIL"
  FAIL=1
fi

echo ""
if [ $FAIL -eq 0 ]; then
  echo "✓ All services healthy."
else
  echo "✗ One or more services failed."
  exit 1
fi
