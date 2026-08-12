# Materialized path

> Ścieżka od korzenia w wierszu: `hierarchyid`, nie stringi z LIKE.

| | |
|---|---|
| **Status** | `READY` |
| **Kiedy stosować** | Breadcrumb, „wszystko pod tym węzłem”, SQL Server `hierarchyid` |
| **Kiedy unikać** | Częsty MOVE w środku drzewa i trzymasz ścieżkę jako `nvarchar` |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/hierarchie/materialized-path.sql) |

## Problem

Chcesz poddrzewo jednym predykatem, bez closure i nested set.

## Model

```text
Wezel (Id, RodzicId, Sciezka hierarchyid, Nazwa)
```

Odczyt poddrzewa: `Sciezka.IsDescendantOf(@rodzic) = 1`.
Głębokość: `Sciezka.GetLevel()`.
Zawsze trzymaj `RodzicId` obok — ścieżka jest pochodną.

`nvarchar` + `LIKE '/1/4/%'` działa, ale `/1/4` vs `/1/40` bez separatorów to klasyka. Nie rób tego, skoro jest `hierarchyid`.

## Kluczowe ograniczenia

- UNIQUE na `Sciezka`.
- Indeks na `Sciezka`.
- Etykiety = id, nie nazwy (rename nie może psuć klucza).

## Operacje

INSERT: `rodzic.GetDescendant(@ostatnieDziecko, NULL)`.
MOVE: `GetReparentedValue` na poddrzewie w jednej TX.

## Pułapki

- `hierarchyid` ma limit głębokości/bajtów.
- MOVE bez locka na rodzicu — dwa INSERT-y dostają tę samą ścieżkę.
- Ścieżka z nazw (`/Elektronika/Audio`).

## Powiązane

- [Adjacency list](adjacency-list.md)
- [Closure table](closure-table.md)
