# schemas/

JSON Schema (Draft 2020-12) for every produced event topic. Each schema:

- Is registered with Schema Registry on producer startup.
- Has matching `governance/data-contracts/<topic>.yaml` (validated by CI).
- Carries `examples/good.json` + `examples/bad.json` next to the schema.

Layout:

```
schemas/
  cdc/
    cdc.customers.v1.json
    cdc.orders.v1.json
    cdc.inventory.v1.json
  ecom/
    ecom.page_view.v1.json
    ecom.add_to_cart.v1.json
    ecom.checkout_started.v1.json
  payment/
    payment.authorized.v1.json
    payment.failed.v1.json
  inventory/
    inventory.stock_changed.v1.json
  fraud/
    fraud.risk_signal.v1.json
  shipment/
    shipment.created.v1.json
    shipment.delivery_updated.v1.json
```

CI runs `make validate-schemas` on every PR.
