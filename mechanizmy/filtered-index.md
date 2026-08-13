# Filtered index

> Indeks na podzbiorze wierszy (`WHERE`). Tańszy, selektywny, unikalność tylko na żywych.

| | |
|---|---|
| **Po co** | Soft delete, outbox `OpublikowanoAt IS NULL`, SCD `IsCurrent = 1` |
| **SQL** | [skrypt](../sql/mechanizmy/filtered-index.sql) |

```sql
CREATE UNIQUE INDEX UQ_sku_zywy
ON dbo.Produkt (Sku)
WHERE UsunietoAt IS NULL;
```

Predykat zapytania musi być **zgodny** z filtrem indeksu, inaczej optimizer go nie weźmie. Parametryzacja bywa przeszkodą (`WHERE UsunietoAt IS NULL` w SQL, nie `WHERE UsunietoAt = @p`).

Używane przez: [soft delete](../wzorce/usuwanie/soft-delete.md), [outbox](../wzorce/integracja/outbox.md), [SCD](../wzorce/historia/scd.md).
