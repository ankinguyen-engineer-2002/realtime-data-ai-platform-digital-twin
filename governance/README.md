# governance/

Data contracts, ownership, PII classification, lineage. See [`docs/13-governance-lineage.md`](../docs/13-governance-lineage.md).

```
governance/
  data-contracts/
    payment.authorized.v1.yaml
    ecom.checkout_started.v1.yaml
    fraud.risk_signal.v1.yaml
    ...
  data-ownership.md
  pii-classification.md
  lineage.md
```

CI (`validate-contracts.yml`) enforces: every produced topic has a contract.
