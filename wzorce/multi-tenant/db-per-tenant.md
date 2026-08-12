# DB-per-tenant

> Osobna baza (czasem osobna instancja) na tenanta. Izolacja, restore i SLO per klient.

| | |
|---|---|
| **Kiedy stosować** | Duży / regulowany tenant, restore „tylko oni”, inne okno utrzymania |
| **Kiedy unikać** | Setki drobnych klientów — koszt licencji, monitoringu, migracji zje produkt |
| **Silniki** | PostgreSQL, SQL Server (tu naturalne: osobna DB, FCI/AG per warstwę, nie per drobnicę) |
| **SQL** | [Postgres](../../sql/postgres/multi-tenant/db-per-tenant.sql) · [SQL Server](../../sql/sqlserver/multi-tenant/db-per-tenant.sql) |

## Problem

Shared schema nie da czystego `RESTORE`. Głośny klient zjada tempdb i plan cache. Audytor chce osobnej bazy.

## Model

```text
Katalog (poza tenantem): TenantId → ConnectionString / nazwa bazy
Baza tenanta: pełny schemat aplikacji, bez TenantId na każdej tabeli
```

Provisioning: kopia z snapshotu / `CREATE DATABASE ... FROM backup` szablonu. Routing w aplikacji albo w proxy.

Na SQL Server: osobna baza na instancji współdzielonej jest już dużą izolacją (backup, pliki, część zasobów). Osobna instancja / FCI to kolejny szczebel — nie mieszaj tego z katalogiem wzorców „na start”.

## Kluczowe ograniczenia

- Katalog połączeń poza bazami tenantów (i z własnym backupem).
- Wersja schematu w każdej bazie (`SELECT z tabeli Migracja`) — migracje muszą być idempotentne i obserwowalne.
- Hasła / TLS per cel; nie jeden `sa` na wszystkie bazy z aplikacji.

## Operacje

Deploy: rolling po katalogu, canary na jednym tenancie. Restore: normalny `RESTORE` tej bazy. Cross-tenant reporting: ETL do hurtowni, nie `UNION ALL` 200 baz w requestcie HTTP.

## Pułapki

- 200 baz × job index rebuild bez okna — zabijesz I/O.
- Drift schematu (ręczny hotfix na jednym kliencie).
- Connection string w kodzie / w tabeli tenanta, którego backup idzie do klienta.

## Powiązane

- [Schema-per-tenant](schema-per-tenant.md)
- [Sharding](../skalowanie/sharding.md)
- [Shared schema](shared-schema.md)
