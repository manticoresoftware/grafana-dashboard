DROP TABLE IF EXISTS dashboard_load;
CREATE TABLE dashboard_load(title text, body text, category string, shard_id uint, created_at bigint);
INSERT INTO dashboard_load(id, title, body, category, shard_id, created_at) VALUES (1, 'manticore release monitoring', 'dashboard smoke test baseline row for local observability checks', 'release', 1, 1712000000);
INSERT INTO dashboard_load(id, title, body, category, shard_id, created_at) VALUES (2, 'production readiness checklist', 'grafana and prometheus validation for manticore metrics and alerts', 'ops', 1, 1712000060);
INSERT INTO dashboard_load(id, title, body, category, shard_id, created_at) VALUES (3, 'search latency benchmark', 'synthetic queries can be replayed to inspect queue pressure and worker saturation', 'perf', 2, 1712000120);
INSERT INTO dashboard_load(id, title, body, category, shard_id, created_at) VALUES (4, 'buddy activity sample', 'internal buddy tasks may keep background counters above zero on idle nodes', 'ops', 2, 1712000180);
INSERT INTO dashboard_load(id, title, body, category, shard_id, created_at) VALUES (5, 'replication planning note', 'single node local sandboxes are useful before rolling metrics dashboards into production', 'cluster', 3, 1712000240);
INSERT INTO dashboard_load(id, title, body, category, shard_id, created_at) VALUES (6, 'vector and keyword mix', 'hybrid search rollout should still be validated against queue and latency panels', 'search', 3, 1712000300);
