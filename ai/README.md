# ai/

AI / RAG layer. Either do it well or cut it — we chose: do it well.

See [`docs/15-ai-rag-layer.md`](../docs/15-ai-rag-layer.md).

## Layout

```
ai/
  embed_documents.py             # index policy/support/product docs into Qdrant
  rag_api.py                     # FastAPI route → hybrid retrieval → LLM
  batch_score_inventory_risk.py  # batch RAG inference job (Dagster asset)
  embeddings/
    model_loader.py              # sentence-transformers
    chunker.py                   # markdown-aware chunking
  evaluation/
    ragas_eval.py                # RAGAS faithfulness, relevancy, ...
    trulens_eval.py              # optional
    seed_questions.yaml          # eval question bank
    run_eval.py                  # CLI: outputs benchmarks/results/rag-<date>.md
```

## Evaluation thresholds

| Metric | Threshold |
|---|---|
| Faithfulness | > 0.85 |
| Answer relevancy | > 0.80 |
| Context precision | > 0.75 |
| Context recall | > 0.70 |
| Latency p95 | < 4s |

## LLM provider

Configured via `LLM_PROVIDER=anthropic|openai|local` in `.env`. The lab demonstrates **all three** by stubbing a small local model (e.g., `Qwen2-0.5B-Instruct`) for cost-free runs and using a hosted API for the eval baseline.
