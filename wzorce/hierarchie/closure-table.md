# Closure table

> Wszystkie pary przodek–potomek (w tym `depth = 0` na siebie). Relacja transytywna jako dane.

| | |
|---|---|
| **Status** | `READY` |
| **Kiedy stosować** | Częste pytania o przodków, potomków, „czy A jest nad B”, umiarkowane zapisy |
| **Kiedy unikać** | Bardzo szerokie, głębokie drzewa z częstym MOVE — tabela domknięć puchnie |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/hierarchie/closure-table.sql) |

## Problem

Chcesz poddrzewo i ścieżkę bez rekurencji w zapytaniu i bez przerysowywania `lft/rgt`.

## Model

Dwie tabele: węzły + domknięcie.

```text
Wezel (Id, Nazwa)
Domkniecie (PrzodekId, PotomekId, Glebokosc)
  PK (PrzodekId, PotomekId)
```

Dla każdego węzła wiersz `(Id, Id, 0)`. Krawędź rodzic→dziecko: `(Rodzic, Dziecko, 1)` plus wszystkie `(Przodek_rodzica, Dziecko, g+1)`.

Adjacency można trzymać obok (`RodzicId`) jako krawędź „natychmiastową”; closure jest pochodną. Albo closure jest źródłem prawdy — wtedy rodzic = `Glebokosc = 1`.

## Kluczowe ograniczenia

- PK `(PrzodekId, PotomekId)`.
- FK obu stron do `Wezel`.
- UNIQUE opcjonalnie na `(PotomekId) WHERE Glebokosc = 1` — jeden rodzic (drzewo, nie DAG).
- Indeks `(PotomekId, Glebokosc)` do ścieżki w górę.

## Operacje

| Potrzeba | Zapytanie |
|---|---|
| Poddrzewo | `WHERE PrzodekId = @id` |
| Ścieżka | `WHERE PotomekId = @id ORDER BY Glebokosc` |
| Liście | węzły bez `Glebokosc = 1` jako przodek |
| INSERT dziecka | skopiuj przodków rodzica + wiersz self |
| MOVE | usuń stare pary z poddrzewa, wstaw względem nowego rodzica (w TX) |

## Pułapki

- DAG vs drzewo: wiele rodziców wymaga innej semantyki `Glebokosc` i braku UNIQUE na rodzicu.
- MOVE bez transakcji zostawia dziurawe domknięcie — zapytania kłamią cicho.
- Zapominanie wierszy `depth = 0`.

## Powiązane

- [Adjacency list](adjacency-list.md) — źródło krawędzi
- [Materialized path](materialized-path.md)
- [Nested set](nested-set.md)
