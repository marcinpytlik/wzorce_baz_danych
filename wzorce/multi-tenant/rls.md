# RLS (Row-Level Security)

> Izolacja wierszy w silniku: nawet `SELECT * FROM Zamowienie` nie wraca cudzych danych.

| | |
|---|---|
| **Status** | `READY` |
| **Kiedy stosować** | [Shared schema](shared-schema.md) i chcesz, żeby pomyłka w aplikacji nie wyciekła tenantów |
| **Kiedy unikać** | Połączenie jako superuser / `dbo` omija polityki; wtedy RLS to teatr |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/multi-tenant/rls.sql) |

## Problem

Jeden `DbContext`, jeden user SQL, filtr `Where(t => t.TenantId == current)` zapomniany w nowym raporcie.

## Model

Funkcja predykatu + `CREATE SECURITY POLICY` z **FILTER** i **BLOCK**. Kontekst: `SESSION_CONTEXT(N'TenantId')`.

```sql
CREATE FUNCTION dbo.fn_tenant(@TenantId INT)
RETURNS TABLE WITH SCHEMABINDING AS
RETURN SELECT 1 AS ok
WHERE @TenantId = CONVERT(INT, SESSION_CONTEXT(N'TenantId'));

CREATE SECURITY POLICY dbo.TenantFilter
ADD FILTER PREDICATE dbo.fn_tenant(TenantId) ON dbo.Zamowienie,
ADD BLOCK  PREDICATE dbo.fn_tenant(TenantId) ON dbo.Zamowienie
WITH (STATE = ON);
```

Aplikacja na starcie requestu: `sp_set_session_context`. Przy zwrocie połączenia do puli — reset. `dbo` / `sysadmin` omija polityki.

## Kluczowe ograniczenia

- `BLOCK PREDICATE` — bez tego INSERT cudzego `TenantId` przechodzi.
- Login aplikacji bez `sysadmin` / `CONTROL SERVER`.
- Joby admina: osobna rola, nie ciche wyłączenie polityki na stałe.

## Operacje

Predykat musi być sargable (`TenantId = stała z kontekstu`), indeks jak w shared schema. Test: app-user bez kontekstu ma dostać pusty zbiór albo błąd konwersji — zdecyduj i przetestuj, nie zgaduj.

## Pułapki

- RLS włączone, aplikacja łączy się jako `sa` / `dbo`.
- `FILTER` bez `BLOCK` — odczyt chroniony, zapis w cudzym tenancie nie.
- Funkcja predykatu nie `SCHEMABINDING` / niestabilna — złe plany, bypassy.
- Pooling: kontekst z poprzedniego requestu zostaje na połączeniu.

## Powiązane

- [Shared schema](shared-schema.md)
- [Idempotencja](../wspolbieznosc/idempotencja.md) — klucz z zakresem tenanta
