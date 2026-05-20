# 13 — Governance + lineage

## What "governance" means in this lab

Four artifacts a senior reviewer expects to see:

1. **Data contracts** — machine-readable schemas with semantic metadata.
2. **Ownership map** — which domain owns what.
3. **PII handling** — concrete, demonstrable, not just a checklist.
4. **Lineage** — automatic, visible end-to-end.

## Data contracts

Each event topic has a YAML contract in [`governance/data-contracts/`](../governance/data-contracts/):

```yaml
# governance/data-contracts/payment.authorized.v1.yaml
name: payment.authorized.v1
domain: payment
owner: payment-team
sla:
  freshness_p95_s: 30
  schema_compat: BACKWARD
schema: schemas/payment/payment.authorized.v1.json
fields:
  - name: customer_id
    pii: false
  - name: card_number
    pii: true
    tokenize: true
    retention_days: 0   # never persisted raw
  - name: amount
    pii: false
  - name: risk_score
    pii: false
quality:
  - rule: amount > 0
  - rule: currency in {USD, EUR, VND, GBP, JPY}
examples:
  good: schemas/payment/payment.authorized.v1.examples/good.json
  bad: schemas/payment/payment.authorized.v1.examples/bad.json
```

CI validates that every produced topic has a contract (`validate-contracts.yml`).

## Ownership map

```mermaid
flowchart LR
    classDef d fill:#1e3a5f,color:#fff
    classDef e fill:#3a3a3a,color:#fff

    D1[Commerce domain]:::d --> E1[ecom.* events]:::e
    D1 --> E2[cdc.orders.v1]:::e
    D1 --> E3[gold.order_funnel_hourly]:::e

    D2[Payment domain]:::d --> E4[payment.* events]:::e
    D2 --> E5[gold.daily_revenue]:::e
    D2 --> E6[gold.payment_success_rate]:::e

    D3[Risk domain]:::d --> E7[fraud.* events]:::e
    D3 --> E8[gold.fraud_alert_summary]:::e

    D4[Supply chain]:::d --> E9[inventory.* events]:::e
    D4 --> E10[shipment.* events]:::e
    D4 --> E11[gold.inventory_availability]:::e

    D5[Analytics platform]:::d --> E12[All silver.* + gold.*]:::e
```

Full table: [`governance/data-ownership.md`](../governance/data-ownership.md).

## PII handling — concrete flow

```mermaid
sequenceDiagram
    participant Prod as payment_producer
    participant RP as Redpanda
    participant Flink as Flink lakehouse_sink_job
    participant Bronze as bronze.events_payment
    participant Vault as Tokenizer (HMAC-SHA256)
    participant Lin as Marquez

    Prod->>RP: payment.authorized.v1<br/>card_number = "4111111111111111"
    Flink->>RP: consume
    Flink->>Vault: tokenize("4111111111111111")
    Vault-->>Flink: "tok_a91f...c4"
    Flink->>Bronze: write row<br/>card_token = "tok_a91f...c4"<br/>(no raw PAN persists)
    Flink->>Lin: emit OpenLineage<br/>dataset has pii.tokenized=true
```

Properties:
- Raw PAN never persists to bronze / silver / gold.
- Token is deterministic per HMAC key → joins still work.
- Key rotation: documented in runbook.

## Lineage — OpenLineage + Marquez

Emitters:
- Flink: `openlineage-flink` listener
- Dagster: built-in emitter
- Trino: `openlineage-trino` plugin

Marquez UI:
- `http://node-obs:3001`
- Dataset graph, run-level lineage, schema history
- Tags propagate: `pii.tokenized`, `domain.payment`

## Why not DataHub

See [ADR-0006](../adr/0006-marquez-over-datahub.md). DataHub is heavier (~6 GB RAM); for lab-scale lineage-only need, Marquez is the right call.
