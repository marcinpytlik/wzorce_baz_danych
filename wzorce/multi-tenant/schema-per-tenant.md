# Schema-per-tenant

> Jeden serwer, jedna baza, osobny schemat (`t123.Zamowienie`) na tenanta.

| | |
|---|---|
| **Kiedy stosować** | Dziesiątki–niskie setki tenantów, chcesz izolacji i prostego `DROP SCHEMA`, bez N instancji |
| **Kiedy unikać** | Tysiące schematów (katalog, plany, migracje); albo jeden tenant wymaga osobnego SLO / restore |
| **Silniki** | PostgreSQL (natywnie dobre), SQL Server (`CREATE SCHEMA` + osobny `dbo` per tenant bywa cięższy operacyjnie) |
| **SQL** | [Postgres](../../sql/postgres/multi-tenant/schema-per-tenant.sql) · [SQL Server](../../sql/sqlserver/multi-tenant/schema-per-tenant.sql) |

## Problem

Shared schema miesza dane i plany. DB-per-tenant jest drogie. Środek: namespace na klienta.

## Model

```text
baza
  shared.Tenant, shared.Migracja
  t_acme.Zamowienie, t_acme.Klient
  t_globex.Zamowienie, t_globex.Klient
```

`search_path` / `SET SCHEMA` na połączeniu. Migracje: pętla po schematach albo narzędzie, które naprawdę to umie (nie „jedna migracja EF na dbo”).

SQL Server: schemat + osobny użytkownik z `DEFAULT_SCHEMA`; albo osobna baza (wtedy to już [db-per-tenant](db-per-tenant.md)).

## Kluczowe ograniczenia

- Uprawnienia: login tenanta widzi tylko swój schemat.
- Szablon schematu (`template`) kopiowany przy onboardingu (`CREATE TABLE ... LIKE` / skrypt).
- Rejestr tenantów w `shared` — routing `kod → schemat`.

## Operacje

Onboarding: `CREATE SCHEMA` + apply DDL. Offboarding: `DROP SCHEMA ... CASCADE` (po backupie). Query cross-tenant tylko w jobach admina, jawne.

## Pułapki

- 5 000 schematów × 80 tabel = ból katalogu i backupu.
- Migracja, która przeszła na 90% tenantów i padła na 10% — potrzebujesz wersji per schemat.
- Connection pooling z jednym `search_path` na zawsze.

## Powiązane

- [Shared schema](shared-schema.md)
- [DB-per-tenant](db-per-tenant.md)
