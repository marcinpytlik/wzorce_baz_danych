# Nazewnictwo

> Nazwa jest częścią schematu. `Dane`, `tbl_Table1`, `Pole3` nie da się chronić UNIQUE ani wytłumaczyć FK.

| | |
|---|---|
| **Status** | `READY` |
| **Kiedy stosować** | Nowa tabela, review, import z Accessa/Excela |
| **Kiedy unikać** | Prefiksy `tbl_` / `sp_` „bo standard z 2005” |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../sql/projektowanie/nazewnictwo.sql) |

## Konwencja tego katalogu

| Obiekt | Jak | Przykład |
|---|---|---|
| Tabela | Rzeczownik, PascalCase, **liczba pojedyncza** | `Klient`, `Zamowienie` |
| Kolumna | PascalCase, bez prefiksu typu | `UtworzonoAt`, nie `dtCreated` |
| PK | `Id` encji albo `EncjaId` | `KlientId` |
| FK | **Ta sama nazwa** co PK rodzica | `KlientId` w `Zamowienie` |
| Lookup | `Encja` + rzecz statusu / typu | `StatusZamowienia` |
| CONSTRAINT | Prefix `PK_` `FK_` `UQ_` `CK_` + tabela + sens | `FK_Zamowienie_Klient` |
| INDEX | `IX_` / `UQ_` + tabela + kolumny | `IX_Zamowienie_KlientId` |
| Widok | `v_` + rzecz | `v_Faktura` |
| Procedura | Czasownik + rzecz | `DodajZamowienie` (nie `sp_` — to prefix systemowy) |
| Schemat | Domena, nie `dbo` na wszystko | `billing`, `wzorzec_chen` |

Związek z Chena: encja = rzeczownik tabeli, związek = czasownik w dokumentacji (`sklada`), tabela M:N = rzeczownik ziarna (`Pozycja`), nie `KlientProdukt`.

## Zakazy

- `tbl_`, `col_`, `fld_`, `sp_` (oprócz naprawdę systemowych).
- `Dane`, `Dokument`, `Tabela`, `Temp` jako nazwa produkcyjna.
- `ID` vs `Id` vs `Klient_ID` w jednym schemacie — wybierz `Id` / `KlientId` i trzymaj.
- Polskie znaki w identyfikatorach (`Zamówienie`) — w T-SQL działa z `[ ]`, psuje skrypty i grep. W **danych** (`Nazwa`) — `NVARCHAR`, [collation](collation.md).
- Czasowniki na tabelach (`GetKlient`).

## Dwie role, dwa FK, dwie nazwy

`Zamowienie` ma płatnika i odbiorcę — oba to `Klient`. Kolumny: `PlatnikKlientId`, `OdbiorcaKlientId`, nie dwa `KlientId`. To dwa związki z Chena, nie jedna kolumna.

## Pułapki

- Rename w EMC bez compatibility view — zepsujesz aplikację.
- UNIQUE na `Email` bez decyzji o collate (`a@b` vs `A@B`).
- Tabela `User` / `Order` / `Key` bez `[ ]` — słowa zarezerwowane; lepiej `Uzytkownik`, `Zamowienie`.

## Powiązane

- [Zasady](zasady.md) pkt 8
- [Klucze](klucze.md)
- [Lookup](lookup.md)
- [Słownik danych](slownik-danych.md)
