# =============================================================================
#  Realtime Data + AI Platform Digital Twin — Makefile
#  One reproducible entry point for every action.
# =============================================================================

SHELL := /usr/bin/env bash
.DEFAULT_GOAL := help

# -- variables -----------------------------------------------------------------
TOPOLOGY     ?= topologies/01-data-platform-mvp.json
SIM_NAME     ?= dsx-data-platform
ENV_FILE     ?= platform/env/.env
COMPOSE      := docker compose --env-file $(ENV_FILE)
SESSION      ?= a
COMPOSE_FILE := platform/docker-compose.session-$(SESSION).yml

PY := python3

# -- help ----------------------------------------------------------------------
.PHONY: help
help: ## show this help
	@echo "Realtime Data + AI Platform Digital Twin"
	@echo ""
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*## "} /^[a-zA-Z_-]+:.*## / {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# =============================================================================
#  Simulation lifecycle (DSX Air)
# =============================================================================

.PHONY: sim-create sim-start sim-stop sim-list sim-status sim-export budget-status

sim-create: ## create a new DSX Air simulation from a topology JSON
	$(PY) dsx-air/scripts/sim_create.py --topology $(TOPOLOGY) --name $(SIM_NAME)

sim-start: ## start a previously created simulation
	$(PY) dsx-air/scripts/sim_start.py --name $(SIM_NAME)

sim-stop: ## stop simulation, save checkpoint
	$(PY) dsx-air/scripts/sim_stop.py --name $(SIM_NAME) --checkpoint

sim-list: ## list all simulations on this account
	$(PY) dsx-air/scripts/sim_list.py

sim-status: ## show simulation status + uptime + cost so far
	$(PY) dsx-air/scripts/sim_status.py --name $(SIM_NAME)

sim-export: ## export topology + inventory.ini from a running sim
	$(PY) dsx-air/scripts/sim_export.py --name $(SIM_NAME)

budget-status: ## show compute hours used / remaining
	$(PY) dsx-air/scripts/budget_guard.py --report-only

# =============================================================================
#  Bootstrapping (Ansible)
# =============================================================================

.PHONY: bootstrap docker-up ansible-check

bootstrap: ## run bootstrap + docker playbooks on all nodes
	ansible-playbook -i infra/ansible/inventory.ini \
		infra/ansible/playbooks/00-bootstrap.yml \
		infra/ansible/playbooks/01-docker.yml

ansible-check: ## dry-run ansible playbooks
	ansible-playbook -i infra/ansible/inventory.ini \
		infra/ansible/playbooks/00-bootstrap.yml --check

# =============================================================================
#  Per-session platform deployment
# =============================================================================

.PHONY: session-a-up session-b-up session-c-up session-down logs

session-a-up: ## bring up Session A (backbone + stream)
	$(COMPOSE) -f platform/docker-compose.session-a.yml up -d

session-b-up: ## bring up Session B (batch + serve)
	$(COMPOSE) -f platform/docker-compose.session-b.yml up -d

session-c-up: ## bring up Session C (AI + governance)
	$(COMPOSE) -f platform/docker-compose.session-c.yml up -d

session-down: ## tear down current session
	$(COMPOSE) -f $(COMPOSE_FILE) down

logs: ## tail compose logs of current session
	$(COMPOSE) -f $(COMPOSE_FILE) logs -f

observability-up: ## bring up observability stack (any session)
	$(COMPOSE) -f platform/docker-compose.observability.yml up -d

# =============================================================================
#  Producers — synthetic events
# =============================================================================

.PHONY: produce-normal produce-burst produce-dirty produce-late produce-duplicates produce-realistic-day

produce-normal: ## 100 events/sec for 10 minutes
	$(PY) producers/order_producer.py --rate 100 --duration 10m
	$(PY) producers/clickstream_producer.py --rate 100 --duration 10m
	$(PY) producers/payment_producer.py --rate 50 --duration 10m

produce-burst: ## 1000 events/sec for 2 minutes
	$(PY) producers/burst_producer.py --rate 1000 --duration 2m

produce-dirty: ## 5% invalid events for 10 minutes
	$(PY) producers/dirty_event_producer.py --invalid-rate 0.05 --duration 10m

produce-late: ## inject late events up to 30 minutes
	$(PY) producers/order_producer.py --late-events true --max-late-minutes 30 --duration 10m

produce-duplicates: ## inject 2% duplicates
	$(PY) producers/order_producer.py --duplicate-rate 0.02 --duration 10m

produce-realistic-day: ## coordinated multi-producer realistic-day run
	$(PY) producers/realistic_day.py --hours 1

# =============================================================================
#  Batch
# =============================================================================

.PHONY: dagster-up dagster-materialize-gold run-quality reconcile

dagster-up: ## start Dagster webserver + daemon
	$(COMPOSE) -f platform/docker-compose.session-b.yml up -d dagster-webserver dagster-daemon

dagster-materialize-gold: ## kick off gold asset materialization
	dagster asset materialize -m batch.dagster --select 'gold_*'

run-quality: ## run Great Expectations checkpoint
	$(PY) batch/dagster/jobs/run_quality_checks.py

reconcile: ## run payment reconciliation
	$(PY) batch/dagster/jobs/reconcile_payments.py

# =============================================================================
#  Tests
# =============================================================================

.PHONY: test test-connectivity test-unit test-integration validate-schemas validate-topologies

test: ## run all tests
	pytest tests/ -v

test-connectivity: ## smoke test: every host reachable, every service healthy
	pytest tests/connectivity -v

test-unit: ## unit tests
	pytest tests/unit -v

test-integration: ## integration tests against running stack
	pytest tests/integration -v

validate-schemas: ## validate every JSON Schema in schemas/
	$(PY) -c "import jsonschema, json, pathlib; [jsonschema.Draft202012Validator.check_schema(json.loads(p.read_text())) for p in pathlib.Path('schemas').rglob('*.json')]"
	@echo "✓ all schemas valid"

validate-topologies: ## validate DSX Air topology JSON files
	$(PY) dsx-air/scripts/validate_topology.py topologies/*.json

# =============================================================================
#  Chaos
# =============================================================================

.PHONY: chaos-redpanda-down chaos-flink-restart chaos-minio-down chaos-postgres-down \
        chaos-vxlan-flap chaos-leaf-down chaos-isl-down chaos-evpn-flap chaos-spine-down chaos-async-loss \
        replay-dlq

# service family
chaos-redpanda-down: ## kill redpanda for 60s
	bash chaos/service/redpanda_down.sh

chaos-flink-restart: ## restart flink taskmanager
	bash chaos/service/flink_restart.sh

chaos-minio-down: ## kill minio for 3 min
	bash chaos/service/minio_down.sh

chaos-postgres-down: ## kill postgres for 60s
	bash chaos/service/postgres_down.sh

# network family — THE differentiator
chaos-vxlan-flap: ## flap VXLAN tunnel on leaf1 (5s)
	bash chaos/network/vxlan_flap.sh

chaos-leaf-down: ## bring down leaf1 (whole rack isolated)
	bash chaos/network/leaf_switch_down.sh

chaos-isl-down: ## drop a single ISL link
	bash chaos/network/isl_link_down.sh

chaos-evpn-flap: ## clear BGP soft on a leaf
	bash chaos/network/evpn_route_flap.sh

chaos-spine-down: ## bring down spine1
	bash chaos/network/spine_down.sh

chaos-async-loss: ## inject 5% packet loss on one ISL
	bash chaos/network/async_packet_loss.sh

replay-dlq: ## replay events from DLQ
	$(PY) chaos/data/replay_dlq.py --topic dlq.invalid_events.v1

# =============================================================================
#  Benchmark
# =============================================================================

.PHONY: benchmark-mvp benchmark-full

benchmark-mvp: ## run MVP benchmark scenarios (B1, B2, B8)
	bash benchmarks/scenarios/run_mvp.sh

benchmark-full: ## run all benchmark scenarios
	bash benchmarks/scenarios/run_all.sh

# =============================================================================
#  Open useful UIs (port-forward via OOB)
# =============================================================================

.PHONY: grafana redpanda-console dagster-ui marquez

grafana: ## open Grafana
	@open "http://$$(awk '/node-obs/ {print $$2}' infra/ansible/inventory.ini):3000" 2>/dev/null || \
		echo "Grafana → http://node-obs:3000 (via OOB)"

redpanda-console:
	@open "http://node-event:8080" 2>/dev/null || echo "Redpanda Console → http://node-event:8080"

dagster-ui:
	@open "http://node-batch:3000" 2>/dev/null || echo "Dagster → http://node-batch:3000"

marquez:
	@open "http://node-obs:3001" 2>/dev/null || echo "Marquez → http://node-obs:3001"

# =============================================================================
#  Repo hygiene
# =============================================================================

.PHONY: fmt lint clean

fmt: ## format python with black
	black producers batch streaming/flink ai serving/fastapi dsx-air/scripts tests

lint: ## ruff lint
	ruff check producers batch streaming/flink ai serving/fastapi dsx-air/scripts tests

clean: ## remove caches
	find . -type d \( -name __pycache__ -o -name .pytest_cache -o -name .ruff_cache \) -prune -exec rm -rf {} +
