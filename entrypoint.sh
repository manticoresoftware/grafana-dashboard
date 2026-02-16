#!/bin/sh
set -e

# Generate Prometheus targets from MANTICORE_TARGETS (comma-separated)
TARGETS=""
TOTAL=0
UNREACHABLE=0
IFS=','
for t in $MANTICORE_TARGETS; do
  t=$(echo "$t" | xargs)  # trim whitespace
  host="${t%%:*}"
  port="${t##*:}"
  TOTAL=$((TOTAL + 1))

  if [ "$host" = "localhost" ] || [ "$host" = "127.0.0.1" ]; then
    if nc -z -w2 "$host" "$port" 2>/dev/null; then
      final="$t"
    elif nc -z -w2 "host.docker.internal" "$port" 2>/dev/null; then
      final="host.docker.internal:${port}"
      echo "Resolved ${t} -> ${final}"
    else
      final="$t"
      UNREACHABLE=$((UNREACHABLE + 1))
      echo "ERROR: ${t} is not reachable (tried localhost and host.docker.internal)" >&2
    fi
  else
    if ! nc -z -w2 "$host" "$port" 2>/dev/null; then
      UNREACHABLE=$((UNREACHABLE + 1))
      echo "ERROR: ${t} is not reachable" >&2
    fi
    final="$t"
  fi

  TARGETS="${TARGETS}\n          - \"${final}\""
done

if [ "$TOTAL" -gt 0 ] && [ "$UNREACHABLE" -eq "$TOTAL" ]; then
  echo "FATAL: All ${TOTAL} targets are unreachable, aborting" >&2
  exit 1
fi

sed -i "s|targets: \[\]|targets:${TARGETS}|" /etc/prometheus/prometheus.yml

echo "Manticore targets: ${MANTICORE_TARGETS}"

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
