# Local Sandbox

This folder contains a small local sandbox for reproducing dashboard behavior against a fresh Manticore `latest` node.

## Start

From the repository root, create a local env file from the example:

```bash
cp env.example .env
```

Start Manticore and the dashboard:

```bash
docker compose -f docker-compose.local.yml up --build
```

If port `3000` is already in use, run:

```bash
# edit DASHBOARD_PORT in .env, then run:
docker compose -f docker-compose.local.yml up --build
```

Run the whole local sandbox in one command:

```bash
sh local/scripts/run_sandbox.sh
```

This command resets the local stack, starts Manticore + the dashboard, loads baseline data, and enables both synthetic search/insert load and periodic `FLUSH RAMCHUNK`.

## Access

- Grafana dashboard: `http://localhost:3300/d/manticore-search-prometheus/manticore-search-prometheus` if you use `run_sandbox.sh`, otherwise `http://localhost:3000/d/manticore-search-prometheus/manticore-search-prometheus` unless overridden
- Manticore MySQL protocol: `localhost:9306` unless `MANTICORE_MYSQL_PORT` is overridden in `.env`
- Manticore HTTP/metrics: `localhost:9308` unless `MANTICORE_HTTP_PORT` is overridden in `.env`

## Individual steps

Seed a small baseline table:

```bash
docker compose -f docker-compose.local.yml --profile seed run --rm seed
```

Start a continuous synthetic workload generator:

```bash
docker compose -f docker-compose.local.yml --profile load up loadgen
```

Start periodic flush activity:

```bash
docker compose -f docker-compose.local.yml --profile flush up flushgen
```

Stop and remove everything:

```bash
docker compose -f docker-compose.local.yml down -v
```

## Files

- `../docker-compose.local.yml`: local Manticore + dashboard + optional seed/load services
- `../env.example`: example local port overrides for Docker Compose
- `scripts/seed.sh`: imports `sql/seed.sql` through the MySQL protocol
- `scripts/loadgen.sh`: uses `manticore-load` to generate read/write pressure
- `scripts/flushgen.sh`: periodically runs `FLUSH RAMCHUNK` against the RT table
- `scripts/run_sandbox.sh`: one-command local reset + boot + seed + load + flush
- `sql/seed.sql`: baseline RT table and a few starter rows
- `wordlists/vocab-1000.txt`: wordlist for synthetic text generation
