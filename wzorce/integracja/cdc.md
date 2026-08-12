# CDC, Change Tracking, polling

> Trzy sposoby czytać zmiany wierszy bez wpinania się w transakcję zapisu. To nie jest outbox: dostajesz wiersz, nie intencję.

| | |
|---|---|
| **Status** | `STARTER` |
| **Kiedy stosować** | Replika, wyszukiwarka, projekcja, gdy nie ruszysz kodu INSERT/UPDATE |
| **Kiedy unikać** | Potrzebujesz `ZamowienieZlozone` — bierz [outbox](outbox.md) |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/integracja/cdc.sql) |

## Problem

Downstream (cache, read model, inna baza) ma wiedzieć, co się zmieniło. Nie chcesz albo nie możesz dodać outboxa do każdej TX.

## Model — trzy warianty, jedna decyzja

| Wariant | Co dostajesz | Koszt | Kiedy |
|---|---|---|---|
| **CDC** | before/after, I/U/D, LSN | Agent, tabele `cdc.*`, retencja logu | Pełny obraz zmiany |
| **Change Tracking** | Który PK się ruszył, wersja | Lżejszy, bez historii kolumn | „odśwież te id” |
| **Polling publisher** | `SELECT TOP n WHERE ZmianaAt > @kursor` | Prosty, łatwo zgubić / zdublować | Nie wolno włączyć CDC |

CDC: `sys.sp_cdc_enable_db` + `sp_cdc_enable_table`. Konsument trzyma LSN.

Change Tracking: `ALTER DATABASE ... SET CHANGE_TRACKING = ON` + `ALTER TABLE ... ENABLE CHANGE_TRACKING`. Konsument trzyma `CHANGE_TRACKING_CURRENT_VERSION()`.

Polling: kolumna `ZmianaAt` / `rowversion` + indeks. To najgorsza semantyka (zgubiony UPDATE w tym samym ticku zegara) — zostaw na systemy, których nie ruszysz.

Żaden wariant nie daje nazwy komendy biznesowej.

## Kluczowe ograniczenia

- PK na źródle (inaczej UPDATE/DELETE niejednoznaczne).
- Retencja CDC — pełny dysk stawia bazę.
- Osobny login czytnika, nie app user.

## Operacje

Snapshot początkowy + dogrywanie od checkpointu. Restart od LSN / wersji CT / kursora.

## Pułapki

- CDC jako outbox.
- CDC na całej bazie „na wszelki wypadek”.
- Slot/job cleanup wyłączony.
- Polling po `datetime` bez `rowversion`.

## Powiązane

- [Outbox](outbox.md)
- [CQRS](../wydajnosc/cqrs.md)
- [Tabele temporalne](../historia/temporal.md)
