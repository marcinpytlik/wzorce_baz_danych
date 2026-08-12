# Covering index

> Indeks zawiera wszystkie kolumny zapytania (`INCLUDE`). Silnik nie wraca do heap/clustered.

| | |
|---|---|
| **Po co** | Lista / keyset / dren kolejki bez lookupów |
| **SQL** | [skrypt](../sql/mechanizmy/covering-index.sql) |

```sql
CREATE INDEX IX_zdarzenie_data
ON dbo.Zdarzenie (Data DESC, ZdarzenieId DESC)
INCLUDE (Typ, Status);
```

Klucz = `WHERE`/`ORDER BY`. `INCLUDE` = `SELECT`. Za szeroki covering puchnie przy UPDATE tych kolumn.

Używane przez: [keyset](../wzorce/wydajnosc/keyset-pagination.md), [queue table](../wzorce/wydajnosc/queue-table.md).
