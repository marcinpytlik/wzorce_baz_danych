# Partycjonowanie

> Jedna instancja, tabela pocięta na zakresy (zwykle daty). To nie jest [sharding](sharding.md).

| | |
|---|---|
| **Status** | `STARTER` |
| **Kiedy stosować** | Sliding window, purge, zarządzanie filegroupami |
| **Kiedy unikać** | Myślisz, że partycje skalują zapis jak osobne serwery |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/wydajnosc/partitioning.sql) |

## Problem

Tabela 500 mln wierszy: rebuild indeksu, DELETE starego roku, skan „ostatni miesiąc” topi się w historii.

## Model

`PARTITION FUNCTION` RANGE + `PARTITION SCHEME`. PK **zawiera** klucz partycji. Zapytania z datą w `WHERE` mogą eliminować partycje. Purge: [SWITCH](../usuwanie/partition-switching-purge.md).

## Kluczowe ograniczenia

- Klucz partycji w PK i w unikalnych indeksach.
- `SPLIT`/`MERGE` w oknie, nie w szczycie.
- Statystyki: przy 2022 nadal myśl o partycji, nie tylko o tabeli.

## Pułapki

- Partycja po `Id` a filtry po dacie — zero elimination.
- 15 000 partycji „na dzień” bez potrzeby.
- UNIQUE na kolumnie bez klucza partycji — SQL Server tego nie przyjmie (albo oszukasz i unikalność kłamie globalnie).

## Powiązane

- [Partition switching](../usuwanie/partition-switching-purge.md)
- [Hot / cold](hot-cold.md)
- [Sharding](sharding.md)
