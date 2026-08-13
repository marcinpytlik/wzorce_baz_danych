# EAV (Entity–Attribute–Value)

> Otwarty zestaw atrybutów kosztem zapytań, typów i spójności.

| | |
|---|---|
| **Status** | `STARTER` |
| **Kiedy stosować** | Atrybuty nieznane w czasie projektowania, rzadko filtrowane, różne per encja (np. metadane urządzenia, cechy zgłoszenia) |
| **Kiedy unikać** | Stabilny model (produkt, klient, faktura). Wtedy to [EAV na wszystko](../../antywzorce/eav-na-wszystko.md) |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/modelowanie/eav.sql) |

## Problem

Encja ma 3 atrybuty albo 300, w zależności od typu. ALTER TABLE przy każdej nowej cesze nie przechodzi.

## Model

Klasycznie trzy tabele: encja, słownik atrybutów, wartości.

```text
Encja (EncjaId)
Atrybut (AtrybutId, Kod, TypDanych)
Wartosc (EncjaId, AtrybutId, WartoscTekst | WartoscLiczba | WartoscData)
```

Lepszy wariant niż jedna kolumna `sql_variant` / `nvarchar`: **osobne kolumny per typ** albo `NVARCHAR(MAX)` z `ISJSON` i znanymi kluczami.

```text
Produkt (ProduktId, Sku, Atrybuty NVARCHAR(MAX) CHECK (ISJSON(Atrybuty)=1))
```

To nadal EAV, tylko w jednym dokumencie. Indeks po `JSON_VALUE` / computed column, nie magia.

## Kluczowe ograniczenia

- UNIQUE `(EncjaId, AtrybutId)`.
- Typ atrybutu w słowniku + CHECK, że wypełniona jest właściwa kolumna wartości.
- Nie mieszaj jednostek w jednym `WartoscTekst` (`"10 kg"` vs `"10"`).

## Operacje

Zapis: upsert wartości. Odczyt „pokaż encję” jest tani. Odczyt „wszystkie encje gdzie kolor=czerwony i waga>10” jest drogi bez computed column / sparse / osobnych kolumn.

## Pułapki

- Filtrowanie po EAV jak po kolumnach relacyjnych — pełne skany, złe plany.
- Brak typów → `"true"`, `"1"`, `"tak"` jako ten sam fakt.
- EAV **i** twarde kolumny na to samo pole.
- Słownik statusów (`NOWE`/`PLN`) to **nie** EAV — [lookup](../../projektowanie/lookup.md).

## Powiązane

- [Lookup](../../projektowanie/lookup.md) — zamknięty zbiór kodów, nie otwarte atrybuty
- [Normalizacja](normalizacja.md)
- [TPH / TPT](tph-tpt-tpct.md) — gdy zestawy atrybutów są skończone i znane per typ
- [CSV w kolumnie](../../antywzorce/csv-w-kolumnie.md)
