#!/bin/sh
set -eu

root_dir=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)

if [ -f "$root_dir/.env" ]; then
  set -a
  . "$root_dir/.env"
  set +a
fi

compose_file="${COMPOSE_FILE:-$root_dir/docker-compose.local.yml}"
dashboard_port="${DASHBOARD_PORT:-3300}"
manticore_http_port="${MANTICORE_HTTP_PORT:-9308}"
manticore_mysql_port="${MANTICORE_MYSQL_PORT:-9306}"
dashboard_path="/d/manticore-search-prometheus/manticore-search-prometheus"

compose() {
  DASHBOARD_PORT="$dashboard_port" \
  MANTICORE_HTTP_PORT="$manticore_http_port" \
  MANTICORE_MYSQL_PORT="$manticore_mysql_port" \
  docker compose -f "$compose_file" "$@"
}

wait_http() {
  url="$1"
  label="$2"
  i=0
  until curl -fsS "$url" >/dev/null 2>&1; do
    i=$((i + 1))
    if [ "$i" -ge 60 ]; then
      echo "Timed out waiting for ${label}: ${url}" >&2
      exit 1
    fi
    sleep 2
  done
}

echo "Resetting local sandbox..."
compose down -v >/dev/null 2>&1 || true

echo "Starting Manticore + dashboard..."
compose up --build -d

echo "Waiting for Manticore metrics..."
wait_http "http://localhost:${manticore_http_port}/metrics" "Manticore metrics"

echo "Waiting for Grafana..."
wait_http "http://localhost:${dashboard_port}" "Grafana"

echo "Seeding baseline data..."
compose --profile seed run --rm seed

echo "Starting synthetic load..."
compose --profile load up -d loadgen

echo "Starting periodic flushes..."
compose --profile flush up -d flushgen

echo "Waiting for live metrics after load start..."
sleep 5

echo
echo "Sandbox is ready."
echo "Grafana:   http://localhost:${dashboard_port}${dashboard_path}"
echo "MySQL:     localhost:${manticore_mysql_port}"
echo "Metrics:   http://localhost:${manticore_http_port}/metrics"
echo
echo "Container status:"
compose ps
echo
echo "Version + key metrics:"
curl -fsS "http://localhost:${manticore_http_port}/metrics" | \
  rg '^manticore_(version|mysql_version|uptime_seconds_gauge|workers_total_count|workers_active_count|work_queue_length_count|tables_count|non_served_tables_count|searchd_rss_bytes|buddy_rss_bytes)'
