# Database per service

> Serwis ma własną bazę. Integracja przez komunikaty, nie przez JOIN.

| | |
|---|---|
| **Status** | `ADVANCED` |
| **Kiedy stosować** | Twarda granica deployu, awarii i schematu |
| **Kiedy unikać** | Dwa serwisy, jedna baza „na razie” — to [shared database](../../antywzorce/shared-database.md) |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/integracja/database-per-service.sql) |

## Problem

Wspólna baza spina cykle życia. Chcesz deploy billingu bez migracji magazynu.

## Model

Katalog: `Serwis → baza`. Brak FK między bazami. Spójność procesów: [saga](saga.md) + [outbox](outbox.md)/[inbox](inbox.md). Raporty: projekcja / hurtownia, nie `JOIN` między bazami w requestcie.

To nie to samo co [db-per-tenant](../multi-tenant/db-per-tenant.md) (tam cięcie jest klientem, tu bounded context).

## Kluczowe ograniczenia

- Zero rozproszonych TX (2PC).
- Wersja schematu per baza.
- Idempotencja na granicach.

## Pułapki

- Linked server jako „tymczasowy JOIN”.
- Dual write do dwóch baz z aplikacji — [antywzorzec](../../antywzorce/dual-write.md).
- Kopia cudzego modelu 1:1 bez [ACL](anti-corruption-layer.md).

## Powiązane

- [Data ownership](data-ownership.md)
- [Saga](saga.md)
- [DB-per-tenant](../multi-tenant/db-per-tenant.md)
