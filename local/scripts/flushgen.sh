#!/bin/sh
set -eu

host="${MANTICORE_HOST:-manticore}"
port="${MANTICORE_PORT:-9306}"
table="${LOAD_TABLE:-dashboard_load}"
interval="${FLUSH_INTERVAL:-2}"

echo "Waiting for Manticore at ${host}:${port}..."
until mysql -h"$host" -P"$port" -e "SHOW TABLES" >/dev/null 2>&1; do
  sleep 1
done

echo "Starting periodic FLUSH RAMCHUNK on ${table} every ${interval}s..."
while true; do
  mysql -h"$host" -P"$port" -e "FLUSH RAMCHUNK ${table}"
  sleep "$interval"
done
