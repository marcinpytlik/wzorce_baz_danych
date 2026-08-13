# Lookup (tabela słownikowa)

> Skończony zbiór kodów (`NOWE`, `PLN`, `VAT23`). To **nie** encja biznesowa (klient) i **nie** EAV (otwarte atrybuty).

| | |
|---|---|
| **Status** | `READY` |
| **Kiedy stosować** | Status, typ, waluta, stawka — lista znana, rzadko się zmienia, FK z OLTP |
| **Kiedy unikać** | Każda cecha produktu w `(Atrybut, Wartosc)` — [EAV](../wzorce/modelowanie/eav.md); albo 2 wartości na zawsze w `CHECK` bez potrzeby tabeli |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../sql/projektowanie/lookup.sql) |

## Czym jest

```text
StatusZamowienia (StatusKod PK, Nazwa, Kolejnosc)
Zamowienie (..., StatusKod FK → StatusZamowienia)
```

- PK często **naturalny kod** (`NOWE`, `PL`), nie IDENTITY — kod jest w kontraktach i outboxie.
- Mało wierszy, dużo odwołań.
- Zmiana listy = wiersz (albo EMC), nie ALTER CHECK przy każdym statusie.

`CHECK (Status IN (...))` wystarczy, gdy lista ma 2–3 wartości **i** nie ma nazwy/kolejności/uprawnień przy kodzie. Gdy UI tłumaczy kod na etykietę albo kolejność workflow — tabela.

## Czym nie jest

| To nie | Różnica |
|---|---|
| Encja `Klient` | Klienci przybywają codziennie; lookup nie |
| [EAV](../wzorce/modelowanie/eav.md) | EAV = otwarte atrybuty *wartości*; lookup = zamknięty *słownik kodów* |
| [TPH](../wzorce/modelowanie/tph-tpt-tpct.md) | Podtypy mają **inne kolumny**; status to ten sam wiersz zamówienia |
| CSV na zamówieniu | `Statusy = 'a,b'` — [antywzorzec](../antywzorce/csv-w-kolumnie.md) |

## Klucz i usuwanie

- `ON DELETE NO ACTION` z OLTP — nie kasuj `NOWE`, gdy wiszą zamówienia.
- Soft delete na lookupie: kod zostaje, `Aktywny = 0` (nie wolno wybrać w UI, stare wiersze nadal FK).
- Nie CASCADE z lookupu na fakty.

## Pułapki

- `StatusId INT IDENTITY` + outbox z liczbą `3` bez znaczenia.
- Lookup na wszystko (`KolorOczu` klienta w słowniku przedsiębiorstwa) — to atrybut albo EAV.
- Duplikat słownika w każdej bazie tenanta bez procesu (dryft kodów).

## Powiązane

- [Klucze](klucze.md) (naturalny PK na kodzie)
- [EAV](../wzorce/modelowanie/eav.md)
- [Nazewnictwo](nazewnictwo.md)
- [Case](case/README.md)
