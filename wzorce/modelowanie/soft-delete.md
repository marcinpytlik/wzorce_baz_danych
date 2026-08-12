# Soft delete

> Wiersz zostaje, znika z „żywego” zbioru. Usunięcie jest stanem, nie brakiem rekordu.

| | |
|---|---|
| **Kiedy stosować** | Odzyskiwanie, FK, które muszą dalej wskazywać, audyt „kto wyłączył” |
| **Kiedy unikać** | RODO / retencja wymaga twardego DELETE; tabela jest gorąca i filtr `IsDeleted = 0` psuje selektywność |
| **Silniki** | PostgreSQL, SQL Server (filtrowane indeksy / widoki) |
| **SQL** | [Postgres](../../sql/postgres/modelowanie/soft-delete.sql) · [SQL Server](../../sql/sqlserver/modelowanie/soft-delete.sql) |

## Problem

Twardy `DELETE` gubi kontekst i psuje historię. Użytkownik „usuwa” zamówienie, a pozycje, płatności i outbox muszą wiedzieć, co się stało.

## Model

Minimum:

```text
UsunietoAt timestamptz NULL   -- NULL = żywe
UsunietoPrzez ...
```

Albo `IsDeleted bit` + znacznik czasu. **Jeden** kanoniczny warunek: `UsunietoAt IS NULL`.

Unikalność biznesowa musi respektować usunięte wiersze:

- albo UNIQUE tylko na żywych (Postgres: indeks częściowy; SQL Server: indeks filtrowany),
- albo nowe wiersze nigdy nie kolidują z grobami (nowe Id, stary kod SKU wolno użyć ponownie).

## Kluczowe ograniczenia

- Częściowy UNIQUE `(Sku) WHERE UsunietoAt IS NULL`.
- Widok `v_Zamowienie` = `WHERE UsunietoAt IS NULL` jako API odczytu dla aplikacji.
- FK: decyzja — martwy rodzic **blokuje** dziecko albo dziecko też jest miękko usuwane w tej samej transakcji.

## Operacje

`UPDATE ... SET UsunietoAt = now()` zamiast DELETE. Purge (twardy DELETE) to osobny job z retencją, nie ścieżka UI.

## Pułapki

- UNIQUE na `Email` bez filtra → nie da się założyć konta na ten sam email po „usunięciu”.
- Aplikacja zapomina filtr — martwe wiersze wracają do raportów i unikalności.
- Soft delete **i** tabele temporalne bez polityki: historia puchnie, a „usunięte” i tak siedzi w current.

## Powiązane

- [Tabele temporalne](temporal.md) — historia zmian vs flaga usunięcia to dwa mechanizmy
- [Outbox](../integracja/outbox.md) — zdarzenie `Usunieto` wychodzi w tej samej TX
