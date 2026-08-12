# Hot / cold

> Gorący ogon i zimna historia w osobnych tabelach / filegroupach / bazach. Archiwalna tabela jest taktyką, nie osobnym wzorcem.

| | |
|---|---|
| **Status** | `STARTER` |
| **Kiedy stosować** | 95% zapytań to ostatnie N dni, reszta to reporting |
| **Kiedy unikać** | Wszystko w jednym filegroup „bo jeden backup” |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/wydajnosc/hot-cold.sql) |

## Problem

Indeksy OLTP służą historii sprzed pięciu lat. Buffer pool zjada zimne strony.

## Model

`dbo.Zdarzenie` (hot, wąskie indeksy) + `archiwum.Zdarzenie` (cold, columnstore / inny filegroup). Job przesuwa wiersze albo [SWITCH](../usuwanie/partition-switching-purge.md) partycji. Widok `UNION ALL` tylko dla świadomych zapytań.

To samo co [archive then delete](../usuwanie/archive-then-delete.md), akcent na **wydajność odczytu/zapisu**, nie na retencję prawną.

## Kluczowe ograniczenia

- Inny filegroup / backup cold.
- Columnstore na cold często wygrywa.
- Aplikacja OLTP nie skanuje cold „na wszelki wypadek”.

## Pułapki

- Widok UNION jako jedyne API — plany zgadują źle.
- Cold na tym samym dysku i w tym samym backupie co hot.
- Przesuwanie wiersz po wierszu bez batchy.

## Powiązane

- [Archive then delete](../usuwanie/archive-then-delete.md)
- [Partycjonowanie](partitioning.md)
- [Indexed view](indexed-view.md)
