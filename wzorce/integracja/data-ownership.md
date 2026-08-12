# Data ownership per service

> Jedna tabela ma jednego pisarza. Inny serwis czyta kopię albo woła API, nie robi `UPDATE` „po sąsiedzku”.

| | |
|---|---|
| **Status** | `STARTER` |
| **Kiedy stosować** | Kilka serwisów, chcesz wiedzieć kto może zepsuć ten agregat |
| **Kiedy unikać** | Jeden proces, jedna baza — nie rysuj ownership na siłę |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/integracja/data-ownership.sql) |

## Problem

Billing i Magazyn UPDATE-ują `dbo.Zamowienie`. Nikt nie wie, który deploy zepsuł status. To [shared database](../../antywzorce/shared-database.md) w praktyce.

## Model

Tabela w schemacie / bazie właściciela. Runtime innych serwisów: `SELECT` przez widok albo wcale — zamiast tego [outbox](outbox.md) + ich [read model](../wydajnosc/cqrs.md). Uprawnienia: tylko login właściciela ma `INSERT/UPDATE/DELETE`.

## Kluczowe ograniczenia

- Grant pisania = jeden login.
- FK z cudzego serwisu do Twojej tabeli = pęknięcie granicy (albo świadomy kompromis w jednej bazie).
- Kontrakt: zdarzenia, nie kolumny.

## Pułapki

- „Właściciel” w wiki, w bazie `db_datawriter` dla wszystkich.
- Czytanie cudzej tabeli w komendzie (nie w projekcji) i decyzja na tej podstawie bez wersji.

## Powiązane

- [Database per service](database-per-service.md)
- [Shared database](../../antywzorce/shared-database.md)
- [ACL](anti-corruption-layer.md)
