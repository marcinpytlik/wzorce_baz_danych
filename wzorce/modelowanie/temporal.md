# Tabele temporalne

> Stan wiersza w czasie: system versioning (jak było w bazie) i/lub valid time (jak było w świecie).

| | |
|---|---|
| **Kiedy stosować** | Audyt stanu, as-of query, korekty wsteczną datą (bitemporal) |
| **Kiedy unikać** | Potrzebujesz strumienia zdarzeń biznesowych — bierz [CDC](../integracja/cdc.md) albo event store, nie kopię wiersza |
| **Silniki** | SQL Server (system-versioned wbudowane), PostgreSQL (zakresy + trigger / rozszerzenia) |
| **SQL** | [Postgres](../../sql/postgres/modelowanie/temporal.sql) · [SQL Server](../../sql/sqlserver/modelowanie/temporal.sql) |

## Problem

`UPDATE` niszczy poprzednią wartość. Pytanie „jaka była cena 12 marca o 14:07?” albo „jaki etat obowiązywał w maju?” nie da się z samego current.

## Model

Dwa osie czasu, których nie wolno mylić:

| Oś | Znaczenie | Przykład |
|---|---|---|
| **System time** | Kiedy baza widziała ten wiersz | `ValidFrom` / `ValidTo` w SQL Server |
| **Valid time** | Kiedy fakt był prawdziwy w świecie | umowa od–do, cena obowiązująca |

SQL Server: `PERIOD FOR SYSTEM_TIME` + `SYSTEM_VERSIONING = ON`. Zapytanie `FOR SYSTEM_TIME AS OF`.

Postgres: nie ma 1:1 tego mechanizmu. Typowy wzorzec:

- tabela current,
- tabela historii zasilana triggerem `BEFORE UPDATE OR DELETE`,
- albo `tstzrange` + `EXCLUDE USING gist` dla valid-time bez nakładania się.

Bitemporal = obie osie na raz. Koszt modelu i zapytań skacze — rób to tylko gdy regulacja/księgowość tego wymaga.

## Kluczowe ograniczenia

- Historia **append-only** (brak UPDATE na history).
- Indeks na `(Id, ValidFrom)` / GiST na zakresie.
- Valid-time: wykluczenie nakładających się zakresów per encja.

## Operacje

Odczyt bieżący = tabela current (tania). Odczyt as-of = history + current. Korekta valid-time to INSERT nowego zakresu i domknięcie poprzedniego, nie „poprawka w miejscu”.

## Pułapki

- Mieszanie `datetime` lokalnego z UTC na granicach okresu.
- System versioning jako substytut outbox — nie dostaniesz semantyki „ZamowienieZlozone”.
- Ogromna historia bez partycjonowania / retencji.

## Powiązane

- [Soft delete](soft-delete.md)
- [CDC](../integracja/cdc.md)
- [Widok zmaterializowany](../skalowanie/materialized-view.md) — snapshot odczytu, nie historia
