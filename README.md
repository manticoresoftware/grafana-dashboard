# Grafana + Prometheus for Manticore Search

Monitoring stack for Manticore Search instances. Dashboards and alert rules are fetched from the [manticoresearch-buddy](https://github.com/manticoresoftware/manticoresearch-buddy) repository on startup.

## Prerequisites

- Docker + Docker Compose

## Quick start

```bash
cp .env.example .env
# edit .env to set your Manticore targets
docker compose up -d
```

## Configuration (.env)

```env
# single instance
MANTICORE_TARGETS=host.docker.internal:9308

# multiple instances
MANTICORE_TARGETS=node1:9308,node2:9308,node3:9308
```

## Access

- Grafana: http://localhost:3000 (login `admin` / `admin`)
- Prometheus: http://localhost:9090

## How it works

1. **init** container downloads the dashboard and alert rules from GitHub into `./monitoring/`
2. **prometheus** starts with targets from `MANTICORE_TARGETS` and loads the alert rules
3. **grafana** starts with Prometheus as a datasource and the pre-provisioned dashboard
