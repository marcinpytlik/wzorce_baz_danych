# Collation i Unicode

> Sortowanie, porównanie i `LIKE` to nie „ustawienie serwera”, tylko część typu tekstowego. Nazwiska: `NVARCHAR` + świadoma collation.

| | |
|---|---|
| **Status** | `READY` |
| **Kiedy stosować** | Kolumna z imieniem, adresem, wyszukiwarką; UNIQUE na email |
| **Kiedy unikać** | `VARCHAR` + collate bazy „bo wszyscy Polacy” bez sprawdzenia code page |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../sql/projektowanie/collation.sql) |

## Unicode vs code page

| Typ | Co trzyma | Kiedy |
|---|---|---|
| `NVARCHAR` / `NCHAR` | Unicode (UCS-2 / UTF-16; UTF-8 od 2019 przy collation `_UTF8`) | Nazwiska, uwagi, prawie każdy tekst UI |
| `VARCHAR` / `CHAR` | Bajty w code page collate | Kody `SKU`, `ISO-3166`, logi ASCII |

Literał Unicode: `N'Łódź'`. Bez `N` przy `NVARCHAR` zła konwersja.

## Co robi collation

- Porządek `ORDER BY` (`a` vs `ą` vs `A`).
- Równość `UNIQUE` / PK (`email` vs `Email`).
- `LIKE` i akcenty (`Lodz` vs `Łódź`).
- CI/CS (case), AI/AS (akcent), szerokość.

Baza ma collate domyślną. Kolumna może nadpisać. **Porównanie dwóch kolumn o różnym collate bez `COLLATE` w zapytaniu pada.**

Dla polskich nazwisk zwykle: `NVARCHAR` + collation z `Polish` albo `Latin1_General` CI AS — **zdecyduj**, czy `Ł` = `L` w wyszukiwarce. AI ułatwia search, psuje DISTINCT nazwisk.

`LIKE N'%ski'` na `NVARCHAR` z wildcard na początku i tak skanuje — to nie collation, to predykat. Collation psuje wynik, niekoniecznie plan.

## UNIQUE i email

`UNIQUE (Email)` przy CI: `A@B` i `a@b` kolidują (często OK). Przy CS — nie. Zapisz w [słowniku](slownik-danych.md).

## Pułapki

- `VARCHAR` + `Ł` w collate bez polskich znaków w code page.
- Tempdb ma collate instancji — `#tmp` vs tabela użytkownika = błąd collate.
- `LIKE` z collate AI i myślenie, że to full-text.
- Zmiana collate kolumny UNIQUE na żywej tabeli — przebudowa indeksu, duplikaty wychodzą.

## Powiązane

- [Typy](typy.md)
- [Nazewnictwo](nazewnictwo.md)
- [Słownik danych](slownik-danych.md)
