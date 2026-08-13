# Checklist przeglądu schematu

> PR do bazy: nie „czy się kompiluje”, tylko czy model kłamie. Odpalaj od góry; pierwsze NIE zatrzymuje merge w głowie, nie w CI.

| | |
|---|---|
| **Status** | `READY` |
| **Kiedy stosować** | Każda migracja DDL, review cudzego skryptu |
| **Kiedy unikać** | Review tylko indeksów, bez ziarna i kluczy |
| **Silnik** | SQL Server 2022 |
| **SQL** | — (lista pytań; przykłady w pozostałych kartach) |

## Koncepcja i ziarno

- [ ] Wiadomo, **co oznacza jeden wiersz** ([słownik](slownik-danych.md)).
- [ ] Encje i liczność zgadzają się z [Chenem](notacja-chena.md) / [Crow’s Foot](crows-foot.md), nie z siatką UI.
- [ ] M:N ma tabelę związku, nie CSV/JSON.
- [ ] Encja słaba ma PK `(właściciel, częściowy)`, nie samo IDENTITY zamiast tożsamości.

## Klucze i integralność

- [ ] Jest PK; jest UNIQUE biznesowy albo zapisane dlaczego nie ([klucze](klucze.md)).
- [ ] Każdy FK ma **jawne** `ON DELETE` / `ON UPDATE` ([on-delete](on-delete.md)).
- [ ] `NOT NULL` tam, gdzie Chen ma uczestnictwo całkowite.
- [ ] Brak `KlientId NULL` „bo gość” ([nullable klucz](../antywzorce/nullable-klucz.md)).
- [ ] CHECK na dziedziny (`Ilosc > 0`, `Typ IN (...)`).

## Typy, nazwy, tekst

- [ ] Pieniądze `DECIMAL`, daty `DATE`/`DATETIME2`, tekst UI `NVARCHAR` ([typy](typy.md)).
- [ ] Nazwy bez `tbl_`, FK nazywa się jak PK rodzica ([nazewnictwo](nazewnictwo.md)).
- [ ] Collation na nazwiskach / UNIQUE email świadoma ([collation](collation.md)).
- [ ] Pochodne: computed albo SELECT, nie ręcznie synchronizowana kopia ([kolumna obliczana](kolumna-obliczana.md)).

## Wzorce (tylko jeśli ten PR ich dotyka)

- [ ] Soft delete → indeks filtrowany na UNIQUE żywych.
- [ ] Outbox w **tej samej** TX co zapis; nie dual write.
- [ ] TenantId w PK i FK albo osobna baza — nie sam filtr w aplikacji.
- [ ] Lookup to tabela kodów, nie EAV ([lookup](lookup.md)).
- [ ] EMC: expand nie łamie starego kontraktu.

## Fizyka i operacje

- [ ] IDENTITY/sekwencja/GUID wybrane świadomie ([sekwencje](sekwencje.md)).
- [ ] Indeksy pod **znane** predykaty, nie „IX na każdą kolumnę”.
- [ ] Retencja / kto może DROP — choćby zdanie w słowniku.
- [ ] Migracja ma wstecz (albo jawne „breaking, EMC etap contract”).

## Meta

- [ ] `MS_Description` albo karta na ziarno i NULL.
- [ ] Nie ma `SELECT *` w procedurze API jako kontrakt.

Nie wszystko na raz w CI. Ludzki review tych haczyków > 40 warningów lintera bez modelu.
