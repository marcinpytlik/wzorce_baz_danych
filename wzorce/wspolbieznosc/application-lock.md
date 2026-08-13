# Application lock

> `sp_getapplock`: krytyczna sekcja po nazwie, nie po wierszu. Gdy nie ma jednego PK do `UPDLOCK`.

| | |
|---|---|
| **Status** | `READY` |
| **Kiedy stosować** | „Tylko jeden job backfillu”, „jeden provisioning tenanta”, fill cache |
| **Kiedy unikać** | Zamiast UNIQUE / `rowversion` na konkretnym wierszu |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/wspolbieznosc/application-lock.sql) |

## Problem

Dwa workery startują ten sam import. Nie ma wiersza, którego lock by je spiął — albo lock na całej tabeli jest za gruby.

## Model

```sql
EXEC sp_getapplock @Resource = N'backfill:Zamowienie',
                   @LockMode = 'Exclusive',
                   @LockOwner = 'Transaction',
                   @LockTimeout = 1000;
-- 0/1 OK; <0 nie dostałeś
```

Owner `Transaction` zwalnia na COMMIT/ROLLBACK. `Session` żyje do disconnect — łatwiej zostawić zombie przy błędzie.

## Kluczowe ograniczenia

- Stała, przestrzeń nazw w `@Resource` (tenant, job, tabela).
- Timeout i obsługa kodu powrotu — nie ignoruj.
- Ta sama baza: applock nie działa między instancjami.

## Pułapki

- Lock na sesję i connection pooling — następny request dziedziczy.
- Applock wokół długiego HTTP.
- Zastępstwo [idempotencji](idempotencja.md).

## Powiązane

- [Pessimistic concurrency](pessimistic-concurrency.md)
- [Queue-serialization](queue-serialization.md)
- [Cache](../wydajnosc/cache.md)
