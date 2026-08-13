# Typy SQL Server 2022

> Typ to dziedzina. Zły typ = ciche zaokrąglenia, zły `ORDER BY`, ból collations.

| | |
|---|---|
| **Status** | `READY` |
| **Kiedy stosować** | DDL nowej kolumny, review schematu |
| **Kiedy unikać** | `sql_variant` / `NVARCHAR(MAX)` „na wszystko” |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../sql/projektowanie/typy.sql) |

## Domyślne wybory

| Fakt | Typ | Nie |
|---|---|---|
| Pieniądze, stawki | `DECIMAL(p,s)` jawne | `FLOAT`, `REAL`, `MONEY` (dziwne rounding) |
| Licznik, PK | `INT` / `BIGINT` | `DECIMAL` na id |
| Flaga | `BIT` | `CHAR(1)` `'T'/'N'` bez CHECK |
| Data bez czasu | `DATE` | `DATETIME` z zerową godziną |
| Czas na osi (UTC) | `DATETIME2(3)` + konwencja UTC | `DATETIME` (precyzja, zakres), `TIMESTAMP` (= rowversion!) |
| Tylko czas doby | `TIME(0)`–`TIME(7)` | wklejanie w `DATETIME2` |
| Tekst (nazwiska, adresy) | `NVARCHAR(n)` | `VARCHAR` na imiona (Unicode) |
| Kod ASCII (`SKU`, `ISO`) | `VARCHAR(n)` / `CHAR(n)` | `NVARCHAR(MAX)` |
| Dokument JSON | `NVARCHAR(MAX)` + `ISJSON` | `TEXT`/`NTEXT` (deprecated) |
| Krótki kod słownika | `CHAR`/`VARCHAR` stabilny | IDENTITY na 4 statusy — [lookup](lookup.md) |
| Id zewnętrzne / merge | `UNIQUEIDENTIFIER` | clustered + `NEWID()` — [sekwencje](sekwencje.md) |
| Wersja wiersza | `ROWVERSION` | ręczny `INT` bez CAS — [optimistic](../wzorce/wspolbieznosc/optimistic-concurrency.md) |

`n` w `NVARCHAR(n)` to **znaki**, nie bajty. `NVARCHAR(MAX)` = LOB, nie indeksujesz kluczem (prefix / computed).

## Precyzja i NULL

- `DECIMAL(19,4)` na kwoty — zapisz `p,s` w [słowniku](slownik-danych.md), nie „jakoś money”.
- `NOT NULL` jest częścią typu w praktyce. Domyślny NULL w SSMS to nie decyzja.
- `DEFAULT` nie zastępuje `NOT NULL` przy jawnym `NULL` w INSERT.

## Collation jest przyklejona do typu tekstowego

Kolumna `NVARCHAR` dziedziczy collation bazy, chyba że nadpiszesz. Porównania, `UNIQUE`, `LIKE` — [collation / Unicode](collation.md).

## Pułapki

- `TIMESTAMP` w T-SQL to **nie** data — to `ROWVERSION`.
- `FLOAT` na fakturze: `0.1 + 0.2`.
- `DATETIME` i daty sprzed 1753 / zaokrąglenie 3.33 ms.
- `VARCHAR` + polskie nazwisko + collation `SQL_Latin1_General_CP1` — utrata znaków albo zły sort.
- `MAX` wszędzie „bo mało wierszy”.

## Powiązane

- [Nazewnictwo](nazewnictwo.md)
- [Collation](collation.md)
- [Kolumna obliczana](kolumna-obliczana.md)
- [Checklist przeglądu](checklist-przegladu.md)
