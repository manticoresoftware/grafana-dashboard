#!/bin/sh
set -eu

host="${MANTICORE_HOST:-manticore}"
port="${MANTICORE_PORT:-9306}"
threads="${LOAD_THREADS:-8}"
search_total="${SEARCH_TOTAL:-4000}"
insert_total="${INSERT_TOTAL:-1000}"
insert_batch_size="${INSERT_BATCH_SIZE:-200}"
table="${LOAD_TABLE:-dashboard_load}"
wordlist="${WORDLIST_PATH:-/work/wordlists/vocab-1000.txt}"

wait_for_manticore() {
  until manticore-load --host="$host" --port="$port" --threads=1 --total=1 --quiet \
    --load="SHOW TABLES" >/dev/null 2>&1; do
    sleep 1
  done
}

echo "Waiting for Manticore at ${host}:${port}..."
wait_for_manticore

echo "Priming ${table} with synthetic data..."
manticore-load \
  --host="$host" \
  --port="$port" \
  --threads=4 \
  --batch-size=500 \
  --total=5000 \
  --quiet \
  --init="CREATE TABLE IF NOT EXISTS ${table}(title text, body text, category string, shard_id uint, created_at bigint)" \
  --load="INSERT INTO ${table}(title, body, category, shard_id, created_at) VALUES('<text/{${wordlist}}/3/6>','<text/{${wordlist}}/20/40>','cat<int/1/8>',<int/1/4>,<int/1712000000/1712999999>)"

echo "Starting continuous synthetic workload..."
while true; do
  manticore-load \
    --host="$host" \
    --port="$port" \
    --threads="$threads" \
    --total="$search_total" \
    --quiet \
    --load="SELECT id, title FROM ${table} WHERE MATCH('search | queue | worker | metric | dashboard | latency') LIMIT 20 OPTION max_matches=1000"

  manticore-load \
    --host="$host" \
    --port="$port" \
    --threads=2 \
    --batch-size="$insert_batch_size" \
    --total="$insert_total" \
    --quiet \
    --load="INSERT INTO ${table}(title, body, category, shard_id, created_at) VALUES('<text/{${wordlist}}/3/6>','<text/{${wordlist}}/20/40>','cat<int/1/8>',<int/1/4>,<int/1712000000/1712999999>)"

  sleep 1
done
