# Shared schema (discriminator)

> Wszyscy tenantci w tych samych tabelach, kolumna `TenantId` na każdym wierszu.

| | |
|---|---|
| **Kiedy stosować** | Dużo małych/średnich tenantów, jeden deploy, jeden zestaw migracji |
| **Kiedy unikać** | Regulacja wymaga fizycznej izolacji; jeden tenant = 80% danych i locków |
| **Silniki** | PostgreSQL, SQL Server |
| **SQL** | [Postgres](../../sql/postgres/multi-tenant/shared-schema.sql) · [SQL Server](../../sql/sqlserver/multi-tenant/shared-schema.sql) |

## Problem

SaaS: tysiąc klientów, ten sam produkt. N baz to N backupów i N migracji.

## Model

```text
Tenant (TenantId, Kod, ...)
Zamowienie (TenantId, ZamowienieId, ...)
PK (TenantId, ZamowienieId)     -- TenantId w kluczu, nie „obok”
FK (TenantId, KlientId) → Klient (TenantId, KlientId)
```

`TenantId` **w PK i we wszystkich FK** zamyka wyciek: nie da się podpiąć pozycji tenanta A pod zamówienie tenanta B.

Aplikacja ustawia kontekst (`SET app.tenant_id`, `SESSION_CONTEXT`) i **dodatkowo** filtruje. Sam filtr w LINQ bez ograniczeń w bazie to za mało — patrz [RLS](rls.md).

## Kluczowe ograniczenia

- `TenantId` NOT NULL (poza tabelą `Tenant`).
- FK złożone, nie „gołe” `KlientId`.
- UNIQUE biznesowe: `(TenantId, Email)`, nie globalny `Email` (chyba że tak ma być).
- Indeks leading `TenantId` na gorących tabelach.

## Operacje

Każde zapytanie z `TenantId`. Joby batch: jawna pętla po tenantach albo kolumna w kluczu, nigdy „wszystko na raz” bez świadomości.

## Pułapki

- PK tylko `UNIQUEIDENTIFIER` + `TenantId` jako zwykła kolumna — FK nie chroni przed cross-tenant.
- Backup/restore jednego klienta = chirurgia DELETE / eksport, nie `RESTORE`.
- Głośny tenant psuje plan i cache buforów pozostałym.

## Powiązane

- [RLS](rls.md) — wymuszenie w silniku
- [Schema-per-tenant](schema-per-tenant.md)
- [DB-per-tenant](db-per-tenant.md)
- [Sharding](../skalowanie/sharding.md) — gdy shared schema przestaje się mieścić
