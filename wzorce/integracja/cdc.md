# CDC (Change Data Capture)

> Strumień zmian wierszy z logu transakcyjnego, bez wpinania się w transakcję aplikacji.

| | |
|---|---|
| **Kiedy stosować** | Replika, wyszukiwarka, audyt wierszy, outbox „po fakcie” gdy nie ruszysz kodu zapisu |
| **Kiedy unikać** | Potrzebujesz intencji biznesowej (`ZamowienieZlozone` vs trzy UPDATE-y kolumn) |
| **Silniki** | SQL Server (CDC / Change Tracking), PostgreSQL (logical decoding, `wal2json`, Debezium) |
| **SQL** | [Postgres](../../sql/postgres/integracja/cdc.sql) · [SQL Server](../../sql/sqlserver/integracja/cdc.sql) |

## Problem

Nie możesz albo nie chcesz dodać INSERT-a do outboxa w każdej TX. Chcesz jednak downstream: cache, read model, inna baza.

## Model

SQL Server CDC: `sys.sp_cdc_enable_db` + `sp_cdc_enable_table` → tabele `cdc.*` + LSN. Change Tracking jest lżejszy (tylko „który wiersz”, nie wszystkie kolumny historyczne).

Postgres: `wal_level = logical`, publikacja `CREATE PUBLICATION ... FOR TABLE`, slot replikacji. Konsument: Debezium / własny decoder. W skryptach: publikacja + przykład odczytu zmian; pełny connector zostaje poza katalogiem.

CDC daje: `before`, `after`, operacja (`I/U/D`), pozycja w logu. Nie daje: nazwy komendy biznesowej, agregatu, gwarancji „jedno zdarzenie na use-case”.

## Kluczowe ograniczenia

- Klucz główny na tabeli źródłowej (inaczej UPDATE/DELETE są niejednoznaczne).
- Retencja logu / cleanup CDC — pełny dysk = stoi produkcja.
- Uprawnienia: osobny użytkownik czytnika, nie app user z prawem do wszystkiego.

## Operacje

Konsument trzyma checkpoint (LSN / slot). Restart od checkpointu. Snapshot początkowy (pełny dump) + dogrywanie logu.

## Pułapki

- Traktowanie CDC jako [outbox](outbox.md) — dostaniesz szum kolumn i utracisz semantykę.
- Jedna publikacja na całą bazę „na wszelki wypadek” — obciążenie I/O i prywatność.
- DDL (drop column) bez procedury na konsumencie.
- Logical slot, którego nikt nie czyta, zatrzymuje VACUUM / obcina dysk WAL.

## Powiązane

- [Outbox](outbox.md) — preferuj, gdy kontrolujesz zapis
- [CQRS](../skalowanie/cqrs.md) — CDC jako rura do projekcji
- [Tabele temporalne](../modelowanie/temporal.md) — historia w tej samej bazie, nie strumień
