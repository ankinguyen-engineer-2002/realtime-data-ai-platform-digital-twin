# lakehouse/

Iceberg DDL + sample queries. See [`docs/09-lakehouse-design.md`](../docs/09-lakehouse-design.md).

## Layout

```
lakehouse/
  catalogs/
    iceberg-rest.yml          # catalog config
  sql/
    create_tables_bronze.sql
    create_tables_silver.sql
    create_tables_gold.sql
    query_examples.sql        # time-travel, snapshots, schema evolution
    maintenance.sql           # expire-snapshots, rewrite-data-files
```

## Querying

```bash
# via Trino
trino --server node-serve:8080 --catalog iceberg --schema silver
> SELECT * FROM fact_payment WHERE event_time > current_timestamp - INTERVAL '1' HOUR;

# via PyIceberg
python -c "from pyiceberg.catalog import load_catalog; \
  c = load_catalog('iceberg', uri='http://node-lake:8181'); \
  print(c.list_tables('silver'))"
```
