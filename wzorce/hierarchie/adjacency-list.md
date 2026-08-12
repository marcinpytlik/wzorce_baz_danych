# Adjacency list

> Każdy wiersz zna tylko rodzica. Najprostsze drzewo w SQL.

| | |
|---|---|
| **Kiedy stosować** | Płytkie drzewo (org, kategorie 2–4 poziomy), głównie operacje rodzic↔dzieci |
| **Kiedy unikać** | Częste „cała gałąź” / „ścieżka do korzenia” na szerokim, głębokim drzewie bez kontroli rekurencji |
| **Silniki** | PostgreSQL (`WITH RECURSIVE`), SQL Server (rekurencyjny CTE) |
| **SQL** | [Postgres](../../sql/postgres/hierarchie/adjacency-list.sql) · [SQL Server](../../sql/sqlserver/hierarchie/adjacency-list.sql) |

## Problem

Kategorie, jednostki org, wątki komentarzy: relacja drzewiasta, nie graf ogólny.

## Model

```text
Wezel (Id, RodzicId NULL, Nazwa)
RodzicId → Wezel(Id)
```

Korzeń: `RodzicId IS NULL`. Cykle są legalne w schemacie, dopóki ich nie zablokujesz triggerem / CHECK-iem aplikacyjnym — SQL sam z siebie drzewa nie pilnuje.

## Kluczowe ograniczenia

- FK `RodzicId` → `Id`.
- Indeks na `RodzicId` (dzieci węzła).
- Opcjonalnie: zakaz `Id = RodzicId`; detekcja cykli przy UPDATE.

## Operacje

| Potrzeba | Koszt |
|---|---|
| Dzieci | `WHERE RodzicId = @id` — tanie |
| Rodzic | jeden JOIN — tanie |
| Poddrzewo / ścieżka | CTE rekurencyjne — rośnie z głębokością i szerokością |
| Przenieś węzeł | UPDATE `RodzicId` — tanie, o ile nie tworzysz cyklu |

## Pułapki

- CTE bez `MAXRECURSION` / limitu głębokości na zacyklonych danych.
- `ON DELETE CASCADE` z rodzicem — kasuje całe poddrzewo bez pytania.
- Adjacency na DAG (wiele rodziców) — to już nie to; wtedy closure albo tabela krawędzi.

## Powiązane

- [Closure table](closure-table.md) — gdy poddrzewo jest częstym odczytem
- [Materialized path](materialized-path.md)
- [Nested set](nested-set.md)
