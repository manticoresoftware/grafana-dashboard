#!/bin/sh
set -eu

host="${MANTICORE_HOST:-manticore}"
port="${MANTICORE_PORT:-9306}"
sql_file="${SQL_FILE:-/work/sql/seed.sql}"

echo "Waiting for Manticore at ${host}:${port}..."
until mysql -h"$host" -P"$port" -e "SHOW TABLES" >/dev/null 2>&1; do
  sleep 1
done

echo "Applying ${sql_file}..."
mysql -h"$host" -P"$port" < "$sql_file"

echo "Seed complete."
