# Partition switching (purge)

> Usunięcie miesiąca to `SWITCH` + `DROP` pustej partycji, nie `DELETE` miliona wierszy.

| | |
|---|---|
| **Status** | `STARTER` |
| **Kiedy stosować** | Sliding window, retencja po dacie, tabela już partycjonowana po tej dacie |
| **Kiedy unikać** | Tabela nie jest partycjonowana / klucz partycji ≠ klucz retencji |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/usuwanie/partition-switching-purge.sql) |

## Problem

`DELETE WHERE Data < @prog` duri log, locki i tempdb. Chcesz zrzucić partycję w metadanych.

## Model

Partycje RANGE po dacie, staging o **identycznym** kształcie (indeksy, CHECK, filegroup). Purge:

1. `ALTER TABLE ... SWITCH PARTITION n TO staging`
2. `TRUNCATE` / `DROP` staging
3. `MERGE RANGE` / `SPLIT` na nowy miesiąc (sliding window)

Wymaga: PK aligned z kluczem partycji, CHECK na stagingu zgodny z zakresem.

## Kluczowe ograniczenia

- Klucz partycji w PK.
- Staging 1:1 ze źródłem.
- Job, który SPLIT-uje przyszłość zanim wpadną wiersze poza zakres.

## Pułapki

- SWITCH przy niezgodnym indeksie — błąd w nocy, nic nie spadło.
- Partycja po `Id` a retencja po dacie.
- Brak SPLIT: nowe wiersze lecą do partycji „catch-all” i nigdy ich nie zrzucisz czysto.

## Powiązane

- [Partycjonowanie](../wydajnosc/partitioning.md)
- [Retention](retention.md)
- [Archive then delete](archive-then-delete.md)
