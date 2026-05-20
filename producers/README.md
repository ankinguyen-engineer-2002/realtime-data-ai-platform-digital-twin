# producers/

Synthetic event generators. See [ADR-0010](../adr/0010-synthetic-data-strategy.md).

## Producers

| Producer | Topics emitted | Notes |
|---|---|---|
| `order_producer.py` | `ecom.checkout_started.v1`, `cdc.orders.v1` (via OLTP write) | supports late + dup |
| `clickstream_producer.py` | `ecom.page_view.v1`, `ecom.add_to_cart.v1` | sessionized |
| `payment_producer.py` | `payment.authorized.v1`, `payment.failed.v1` | correlated with orders |
| `fraud_signal_producer.py` | `fraud.risk_signal.v1` | rule-driven |
| `inventory_producer.py` | `cdc.inventory.v1`, `inventory.stock_changed.v1`, `shipment.*` | OLTP write |
| `dirty_event_producer.py` | any topic, with `--invalid-rate` | bad-data injection |
| `burst_producer.py` | configurable | high-rate stress |
| `late_event_producer.py` | configurable | event_time in the past |
| `realistic_day.py` | all of the above | orchestrates a realistic-day workload |

## Common flags

```text
--rate FLOAT                 events per second (default $PROD_DEFAULT_RATE)
--duration STR               duration "10m" / "1h" / "30s"
--seed INT                   deterministic mode
--invalid-rate FLOAT         0..1 ; fraction of events with schema violation
--invalid-mode STR           which violation: missing_field|negative_amount|future_ts|...
--duplicate-rate FLOAT       0..1
--late-events BOOL           inject late events
--max-late-minutes INT
--dry-run                    don't actually produce
```

## Bad-event labels

Bad events carry `_synthetic_label` so tests can assert correct DLQ routing:

```json
{
  "event_id": "evt_...",
  "_synthetic_label": "negative_amount",
  "amount": -19.99
}
```

## Producer skeleton

```python
# producers/common/base.py
from dataclasses import dataclass
import random, time, json

@dataclass
class BaseProducer:
    rate: float
    duration: str
    seed: int = 42

    def __post_init__(self):
        random.seed(self.seed)

    def emit(self, topic: str, key: str, value: dict):
        # ... confluent_kafka produce + flush
        ...
```

Full implementation lands in Phase 4 (see ROADMAP).
