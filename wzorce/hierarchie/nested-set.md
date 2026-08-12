# Nested set

> Poddrzewo = zakres liczb (`lft`, `rgt`). Odczyt tani, przesunięcie drogie.

| | |
|---|---|
| **Kiedy stosować** | Katalog czytany w kółko, rzadkie INSERT/MOVE (drzewo towarów, menu) |
| **Kiedy unikać** | Częste dokładanie liści i przeciąganie gałęzi — przerysowujesz połowę tabeli |
| **Silniki** | PostgreSQL, SQL Server |
| **SQL** | [Postgres](../../sql/postgres/hierarchie/nested-set.sql) · [SQL Server](../../sql/sqlserver/hierarchie/nested-set.sql) |

## Problem

Adjacency wymaga rekurencji na każde poddrzewo. Chcesz `WHERE lft BETWEEN @lft AND @rgt`.

## Model

```text
Wezel (Id, Nazwa, Lft, Rgt, Poziom)
```

Niezmienniki:

- `Lft < Rgt`
- zakres dziecka zawiera się w zakresie rodzica
- liczby od 1 do `2N` bez dziur (w klasycznej wersji)

```text
      A (1,12)
     / \
  B(2,7) C(8,11)
  / \       \
D(3,4) E(5,6) F(9,10)
```

## Kluczowe ograniczenia

- UNIQUE na `Lft`, UNIQUE na `Rgt`.
- CHECK `Lft < Rgt`.
- Indeks `(Lft, Rgt)` do zapytań zakresowych.

## Operacje

Poddrzewo: jeden zakres. Przodkowie: `WHERE Lft < @lft AND Rgt > @rgt`. INSERT liścia: przesuń wszystkie `Lft/Rgt >= punkt wstawienia` o 2 — to jest koszt.

## Pułapki

- Dwa równoległe INSERT-y bez transakcji / locka na drzewie → dziurawe zakresy.
- Trzymanie samego nested set bez `RodzicId` — MOVE i walidacja stają się czarną magią. Często trzyma się **oba**: adjacency do zapisu, nested set do odczytu (albo closure).
- Rebuild od zera przy każdym imporcie bywa tańszy niż inkrementalny MOVE.

## Powiązane

- [Adjacency list](adjacency-list.md)
- [Closure table](closure-table.md) — zwykle lepszy kompromis zapis/odczyt
