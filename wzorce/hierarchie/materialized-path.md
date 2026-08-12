# Materialized path

> Ścieżka od korzenia zapisana w wierszu (`/1/4/9/` albo `hierarchyid` / `ltree`).

| | |
|---|---|
| **Kiedy stosować** | UI pokazuje breadcrumb, filtry „wszystko pod /elektronika/”, silnik ma typ hierarchii |
| **Kiedy unikać** | Częste MOVE w środku drzewa bez typu natywnego — stringi i LIKE się sypią |
| **Silniki** | PostgreSQL (`ltree`, `text`), SQL Server (`hierarchyid`) |
| **SQL** | [Postgres](../../sql/postgres/hierarchie/materialized-path.sql) · [SQL Server](../../sql/sqlserver/hierarchie/materialized-path.sql) |

## Problem

Chcesz poddrzewo jednym predykatem, bez tabeli domknięć i bez nested set.

## Model

```text
Wezel (Id, RodzicId, Sciezka, Nazwa)
-- Postgres: Sciezka ltree      np. 'elektronika.audio.sluchawki'
-- SQL Server: Sciezka hierarchyid
```

Odczyt poddrzewa:

- `ltree`: `Sciezka <@ 'elektronika.audio'` albo `Sciezka ~ 'elektronika.*'`
- `hierarchyid`: `Sciezka.IsDescendantOf(@rodzic)`
- `text`: `Sciezka LIKE '/1/4/%'` — działa, ale łatwo o kolizje (`/1/4` vs `/1/40`) jeśli nie ma separatorów i stałej szerokości

Zawsze trzymaj `RodzicId` obok ścieżki. Ścieżka jest pochodną; MOVE aktualizuje ścieżkę poddrzewa.

## Kluczowe ograniczenia

- Indeks GiST na `ltree` / indeks na `hierarchyid`.
- CHECK: ścieżka kończy się na własnym id / etykiecie.
- UNIQUE na ścieżce.

## Operacje

INSERT liścia: `sciezka_rodzica || id`. MOVE: UPDATE ścieżek wszystkich potomków (join z closure albo `LIKE`/`IsDescendantOf`). Głębokość: `nlevel(sciezka)` / `GetLevel()`.

## Pułapki

- `LIKE '1/4%'` bez slashy — dopasuje `1/40`.
- Ścieżka z nazw (`/Elektronika/Audio`) — rename psuje klucze; używaj id.
- SQL Server `hierarchyid` ma limit głębokości/bajtów; nie jest magiczny na dowolnie głębokich drzewach.

## Powiązane

- [Adjacency list](adjacency-list.md)
- [Closure table](closure-table.md) — gdy MOVE ma być relacyjny, nie stringowy
