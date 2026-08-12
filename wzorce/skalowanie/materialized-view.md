# Widok zmaterializowany

> Wynik zapytania zapisany jako tabela, odświeżany na żądanie, co interwał albo inkrementalnie.

| | |
|---|---|
| **Kiedy stosować** | Ciężka agregacja / JOIN, opóźnienie sekundy–godziny jest OK, jedna instancja |
| **Kiedy unikać** | Odczyt musi widzieć zapis z tej samej TX; dane zmieniają się szybciej niż koszt refresh |
| **Silniki** | PostgreSQL (`MATERIALIZED VIEW`), SQL Server (indexed view — węższy kontrakt) |
| **SQL** | [Postgres](../../sql/postgres/skalowanie/materialized-view.sql) · [SQL Server](../../sql/sqlserver/skalowanie/materialized-view.sql) |

## Problem

Raport albo lista jest za droga na żywych tabelach. Cache aplikacyjny nie musi znać SQL.

## Model

Postgres: `CREATE MATERIALIZED VIEW ... AS SELECT ...` + `REFRESH MATERIALIZED VIEW [CONCURRENTLY]`. `CONCURRENTLY` wymaga UNIQUE indeksu i nie blokuje odczytów tak agresywnie.

SQL Server: **indexed view** to nie to samo co MV w Postgresie. Wymaga `SCHEMABINDING`, deterministycznych funkcji, często `COUNT_BIG`, i `WITH (NOEXPAND)` na edycjach bez automatycznego matchowania. To projekcja utrzymywana przy DML — bliżej natychmiastowej denormalizacji, z kosztem na każdym zapisie.

Gdy indexed view nie przechodzi (JOIN-y, OUTER, TOP): tabela snapshot + job (`MERGE` / `TRUNCATE+INSERT`).

## Kluczowe ograniczenia

- UNIQUE na kluczu projekcji (do `CONCURRENTLY` / do MERGE).
- Jawna semantyka świeżości: kolumna `OdswiezoneAt` albo metadane joba.
- Uprawnienia: aplikacja czyta MV, nie bazowe tabele, jeśli to ma być API.

## Operacje

Refresh pełny vs inkrementalny (Postgres 15+ / pg_ivm / własne delta). SQL Server indexed view: zero joba, koszt na INSERT/UPDATE/DELETE źródła.

## Pułapki

- `REFRESH` bez `CONCURRENTLY` blokuje odczyty MV.
- Indexed view + częsty DML na źródle = wolniejszy OLTP niż zysk na SELECT.
- MV jako substytut [CQRS](cqrs.md) między serwisami — nie przekracza granicy bazy.

## Powiązane

- [CQRS](cqrs.md)
- [Cache](cache.md)
- [Normalizacja](../modelowanie/normalizacja.md) — MV jest świadomą denormalizacją odczytu
