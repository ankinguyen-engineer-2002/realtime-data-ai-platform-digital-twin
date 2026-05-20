# PII classification

| Field | Classification | Handling |
|---|---|---|
| `card_number` | PCI / PII high | tokenize at ingress; raw never persists |
| `email` | PII medium | hash for analytics; raw retained in OLTP only |
| `phone_number` | PII medium | same as email |
| `customer_id` | pseudonymous | usable in analytics; map to PII in OLTP only |
| `ip_address` | PII low | retained 30 days, then truncated to /16 |
| `device_id` | pseudonymous | usable in analytics |
| `amount` | non-PII | retained indefinitely in gold |

## Tokenization flow (concrete)

See `docs/13-governance-lineage.md` for the Flink-level diagram. Summary:

1. Producer emits raw card_number to `payment.authorized.v1` (allowed; topic is short-retention).
2. Flink `lakehouse_sink_job` reads, calls `Tokenizer.hmac_sha256(card_number, key)`, writes tokenized value to bronze.
3. Bronze / silver / gold never contain raw PAN.
4. DLQ events have their raw_payload_b64 redacted for PII fields.
5. Marquez dataset has tag `pii.tokenized=true`.

## Key management

- HMAC key stored in SOPS-encrypted secrets.
- Rotation procedure documented in `runbooks/rotate-pii-key.md`.
- Rotation re-tokenizes via backfill (old token → new token map kept for join continuity).
