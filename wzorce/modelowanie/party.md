# Party

> Osoba, organizacja i rola to osobne fakty. „Klient” jest rolą, nie tabelą-bogiem.

| | |
|---|---|
| **Status** | `STARTER` |
| **Kiedy stosować** | Ten sam byt bywa klientem, dostawcą i pracownikiem; osoba i firma współdzielą adresy / dokumenty |
| **Kiedy unikać** | Prosty CRUD jednego typu kontrahenta — TPT na siłę |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/modelowanie/party.sql) |

## Problem

`Klient` ma `NIP` nullable, `Pesel` nullable, `Imie` nullable, `NazwaFirmy` nullable. Raporty pełne CASE. Ta sama firma jest klientem i dostawcą — dwa wiersze.

## Model

```text
Party (PartyId, Typ)                     -- TPH korzeń albo TPT
Osoba  (PartyId, Imie, Nazwisko, Pesel)
Firma  (PartyId, Nazwa, NIP)
Rola   (PartyId, RodzajRoli, Od, Do)     -- Klient / Dostawca / Pracownik
Relacja (ZPartyId, DoPartyId, Typ)       -- zatrudnia, należy do grupy
```

Adres, telefon, dokument wiszą na `PartyId`, nie na „kliencie”.

## Kluczowe ograniczenia

- `Typ` Party spójny z tabelą podtypu ([TPT](tph-tpt-tpct.md)).
- Rola ma valid time ([effective dating](../historia/effective-dating.md)), nie flagę `CzyKlient`.
- UNIQUE na identyfikatorach naturalnych per podtyp (`Pesel`, `NIP`).

## Pułapki

- Party jako nowa tabela-bóg z 60 kolumnami.
- Rola wklejona w `Party.Typ` — wtedy nie da się być klientem i dostawcą.
- Relacje bez typu i bez zakazu cykli, gdy model tego wymaga.

## Powiązane

- [TPH / TPT](tph-tpt-tpct.md)
- [Effective dating](../historia/effective-dating.md)
- [Tabela-bóg](../../antywzorce/tabela-bog.md)
