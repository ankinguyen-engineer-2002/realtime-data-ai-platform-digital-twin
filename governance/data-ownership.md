# Data ownership

| Domain | Owns | Owner team (simulated) | Contact |
|---|---|---|---|
| Commerce | `ecom.*.v1`, `cdc.orders.v1`, `gold.order_funnel_hourly` | commerce-platform | #commerce |
| Payment | `payment.*.v1`, `gold.daily_revenue`, `gold.payment_success_rate` | payments | #payments |
| Risk | `fraud.*.v1`, `gold.fraud_alert_summary` | risk | #risk-alerts |
| Supply chain | `cdc.inventory.v1`, `inventory.*.v1`, `shipment.*.v1`, `gold.inventory_availability` | supply-chain | #scm |
| Analytics platform | all `silver.*`, all `gold.*` | data-platform | #data-platform |
| Lakehouse infra | Iceberg catalog, MinIO buckets | data-platform | #data-platform |
| Streaming infra | Redpanda, Flink, Debezium | data-platform | #data-platform |

A change to any topic / table / dataset requires sign-off from its owner team.
