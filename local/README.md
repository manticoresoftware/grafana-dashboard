# Local Sandbox

This folder contains a small local sandbox for reproducing dashboard behavior against a fresh Manticore `latest` node.

## Start

Start Manticore and the dashboard:

```bash
docker compose -f docker-compose.local.yml up --build
```

If port `3000` is already in use, run:

```bash
DASHBOARD_PORT=3300 docker compose -f docker-compose.local.yml up --build
```

Run the whole local sandbox in one command:

```bash
sh local/scripts/run_sandbox.sh
```

This command resets the local stack, starts Manticore + the dashboard, loads baseline data, and enables both synthetic search/insert load and periodic `FLUSH RAMCHUNK`.

## Access

- Grafana: `http://localhost:3300` if you use `run_sandbox.sh`, otherwise `http://localhost:3000` unless overridden
- Manticore MySQL protocol: `localhost:9306`
- Manticore HTTP/metrics: `localhost:9308`

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
- `scripts/seed.sh`: imports `sql/seed.sql` through the MySQL protocol
- `scripts/loadgen.sh`: uses `manticore-load` to generate read/write pressure
- `scripts/flushgen.sh`: periodically runs `FLUSH RAMCHUNK` against the RT table
- `scripts/run_sandbox.sh`: one-command local reset + boot + seed + load + flush
- `sql/seed.sql`: baseline RT table and a few starter rows
- `wordlists/vocab-1000.txt`: wordlist for synthetic text generation
