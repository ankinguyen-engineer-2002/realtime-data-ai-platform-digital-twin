# Palette màu cho Mermaid

Dùng nhất quán across toàn repo. Mỗi tầng / vai trò 1 màu.

| Vai trò | Fill | Stroke | Text |
|---|---|---|---|
| Infrastructure / network | `#1e3a5f` | `#7fb8ff` | `#fff` |
| Compute / processing | `#3a5f1e` | `#b8ff7f` | `#fff` |
| Storage / lakehouse | `#5f1e5f` | `#ff7fff` | `#fff` |
| Event / streaming | `#5f1e3a` | `#ff7fb8` | `#fff` |
| Serving / API | `#5f3a1e` | `#ffb87f` | `#fff` |
| AI / ML | `#1e5f5f` | `#7fffff` | `#fff` |
| Observability | `#5f5f1e` | `#ffff7f` | `#000` |
| Chaos / failure | `#5f1e1e` | `#ff7f7f` | `#fff` |
| Governance | `#3a1e5f` | `#b87fff` | `#fff` |
| Neutral / source | `#3a3a3a` | `#aaa` | `#fff` |
| Highlight / OK | `#1e5f1e` | `#7fff7f` | `#fff` |
| Highlight / warning | `#5f5f1e` | `#ffff7f` | `#000` |
| Highlight / danger | `#5f1e1e` | `#ff7f7f` | `#fff` |

## Ví dụ Mermaid

```mermaid
flowchart LR
    classDef infra fill:#1e3a5f,stroke:#7fb8ff,color:#fff
    classDef event fill:#5f1e3a,stroke:#ff7fb8,color:#fff
    classDef store fill:#5f1e5f,stroke:#ff7fff,color:#fff

    A[Network]:::infra --> B[Kafka]:::event --> C[MinIO]:::store
```
