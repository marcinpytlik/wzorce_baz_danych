# RLS (Row-Level Security)

> Izolacja wierszy w silniku: nawet `SELECT * FROM Zamowienie` nie wraca cudzych danych.

| | |
|---|---|
| **Kiedy stosować** | [Shared schema](shared-schema.md) i chcesz, żeby pomyłka w aplikacji nie wyciekła tenantów |
| **Kiedy unikać** | Połączenie jako superuser / `dbo` omija polityki; wtedy RLS to teatr |
| **Silniki** | PostgreSQL (`ENABLE ROW LEVEL SECURITY`), SQL Server (security policy + predicate) |
| **SQL** | [Postgres](../../sql/postgres/multi-tenant/rls.sql) · [SQL Server](../../sql/sqlserver/multi-tenant/rls.sql) |

## Problem

Jeden `DbContext`, jeden user SQL, filtr `Where(t => t.TenantId == current)` zapomniany w nowym raporcie.

## Model

Postgres:

```sql
ALTER TABLE zamowienie ENABLE ROW LEVEL SECURITY;
ALTER TABLE zamowienie FORCE ROW LEVEL SECURITY;  -- także właściciel
CREATE POLICY tenant_izlo ON zamowienie
  USING (tenant_id = current_setting('app.tenant_id')::int)
  WITH CHECK (tenant_id = current_setting('app.tenant_id')::int);
```

SQL Server: funkcja predykatu + `CREATE SECURITY POLICY` z `FILTER` i `BLOCK`. Kontekst: `SESSION_CONTEXT(N'TenantId')` albo `SUSER_SNAME()` przy logowaniu per tenant (rzadkie).

Aplikacja na starcie requestu: ustawia kontekst, **nie** skleja SQL-a z id tenanta ręcznie w każdej kwerendzie (to i tak zostaw jako obrona w głąb).

## Kluczowe ograniczenia

- `FORCE` / `BLOCK PREDICATE` — bez tego INSERT cudzego `TenantId` albo odczyt jako owner przechodzi.
- Osobny login aplikacji **bez** `BYPASSRLS` / `sysadmin`.
- Joby administracyjne: jawna rola `SECURITY BYPASS` albo `SET app.tenant_id` w pętli, nigdy ciche wyłączenie na stałe.

## Operacje

Plan zapytania: predykat RLS musi być sargable (`tenant_id = stała z ustawienia`), indeks jak w shared schema. Test: połączenie app-user bez ustawionego kontekstu ma **paść**, nie zwrócić 0 wierszy po cichu (Postgres: brak `current_setting(..., missing_ok)` bez decyzji).

## Pułapki

- RLS włączone, aplikacja łączy się jako `postgres` / `sa`.
- `FILTER` bez `BLOCK` — odczyt chroniony, zapis w cudzym tenancie nie.
- Funkcja predykatu nie `SCHEMABINDING` / niestabilna — złe plany, bypassy.
- Pooling: kontekst z poprzedniego requestu zostaje na połączeniu.

## Powiązane

- [Shared schema](shared-schema.md)
- [Idempotencja](../integracja/idempotencja.md) — klucz z zakresem tenanta
