# Keyset pagination

> Następna strona po `(sort, id)`, nie `OFFSET 50000`. SQL Server 2022: `IS DISTINCT FROM` ułatwia NULL-e.

| | |
|---|---|
| **Status** | `READY` |
| **Kiedy stosować** | Nieskończony scroll, kolejka, backfill |
| **Kiedy unikać** | „Skocz do strony 412” — to OFFSET (i ból) |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/wydajnosc/keyset-pagination.sql) |

## Problem

`ORDER BY Data DESC OFFSET 100000 ROWS FETCH NEXT 50` czyta i odrzuca 100 000 wierszy.

## Model

Klient trzyma ostatni klucz. Serwer:

```sql
SELECT TOP (50) *
FROM dbo.Zdarzenie
WHERE (Data, ZdarzenieId) < (@lastData, @lastId)   -- krotka, 2022
ORDER BY Data DESC, ZdarzenieId DESC;
```

Albo klasycznie: `Data < @d OR (Data = @d AND Id < @id)`. Indeks `(Data, ZdarzenieId)` covering.

## Kluczowe ograniczenia

- Sort deterministyczny (doklej PK).
- Indeks zgodny z `ORDER BY`.
- Stabilny kursor: nie sortuj po kolumnie, która się zmienia pod Tobą.

## Pułapki

- OFFSET „bo strona w UI”.
- Klucz bez PK — duplikaty dat, zgubione/powtórzone wiersze.
- `WHERE Data < @d` bez tie-breakera.

## Powiązane

- [Covering index](../../mechanizmy/covering-index.md)
- [Queue table](queue-table.md)
- [Expand–Migrate–Contract](../ewolucja/expand-migrate-contract.md) — kursor backfillu
