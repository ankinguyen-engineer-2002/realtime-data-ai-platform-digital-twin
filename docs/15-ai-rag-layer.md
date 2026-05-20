# 15 — AI / RAG layer

> Either do it well or cut it. We chose: do it well.

## Architecture

```mermaid
flowchart LR
    classDef doc fill:#3a3a3a,stroke:#aaa,color:#fff
    classDef proc fill:#1e5f5f,stroke:#7fffff,color:#fff
    classDef store fill:#5f1e5f,stroke:#ff7fff,color:#fff
    classDef api fill:#5f3a1e,stroke:#ffb87f,color:#fff
    classDef eval fill:#5f5f1e,stroke:#ffff7f,color:#000

    DOC["rag-docs/<br/>product / support /<br/>policy markdown"]:::doc
    GOLD["gold.* tables"]:::doc

    EMB["embedder<br/>sentence-transformers<br/>all-MiniLM-L6-v2"]:::proc
    BM25["BM25 indexer<br/>(in Qdrant payload search)"]:::proc

    DOC --> EMB
    DOC --> BM25

    EMB --> QD["Qdrant<br/>HNSW + payload"]:::store
    BM25 --> QD

    Q["User question"] --> RAG["RAG service<br/>FastAPI"]:::api
    RAG -- "hybrid:<br/>vector ⊕ BM25" --> QD
    RAG -- "structured context" --> TR["Trino → gold"]:::store
    RAG -- "prompt + context" --> LLM["LLM<br/>(Anthropic / OpenAI / local)"]:::proc
    LLM --> RAG
    RAG --> Q

    RAG -. trace .-> OTEL[OpenTelemetry]
    RAG -. log .-> LOKI[Loki]
    RAG -. eval .-> EV["RAGAS / TruLens<br/>quality eval"]:::eval
```

## Use cases

1. "What's the return policy for category X?" → docs RAG
2. "Why did order_123 fail?" → join docs + gold tables
3. "Summarize today's fraud alerts" → gold-only summarization
4. "Batch score: which SKUs are at stockout risk this week?" → batch RAG / scoring

## Evaluation framework

| Metric | Tool | Threshold |
|---|---|---|
| Faithfulness | RAGAS | > 0.85 |
| Answer relevancy | RAGAS | > 0.80 |
| Context precision | RAGAS | > 0.75 |
| Context recall | RAGAS | > 0.70 |
| Latency p95 | OTEL | < 4s |

Eval suite lives at `ai/evaluation/`. Reports published to `benchmarks/results/rag-runs/`.

## Retrieval strategy

- **Hybrid:** vector cosine (HNSW) ⊕ BM25 sparse, weighted 0.7 / 0.3.
- **Reranker:** Optional cross-encoder (Phase 10 stretch).
- **Top-k:** 20 retrieved → 5 after rerank.

## Why we are NOT building

- Custom fine-tuned model (out of scope; no GPU).
- Conversational memory (single-turn lab).
- Multi-modal (text-only).
- Agent loop with tools (Phase 11 stretch maybe).

## Cost note

If using a hosted LLM API (Anthropic / OpenAI), this is the only off-DSX-Air spend. Document the API cost line item.
