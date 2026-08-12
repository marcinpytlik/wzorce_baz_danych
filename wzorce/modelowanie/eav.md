# EAV (Entity–Attribute–Value)

> Otwarty zestaw atrybutów kosztem zapytań, typów i spójności.

| | |
|---|---|
| **Kiedy stosować** | Atrybuty nieznane w czasie projektowania, rzadko filtrowane, różne per encja (np. metadane urządzenia, cechy zgłoszenia) |
| **Kiedy unikać** | Stabilny model (produkt, klient, faktura). Wtedy to [EAV na wszystko](../../antywzorce/eav-na-wszystko.md) |
| **Silniki** | PostgreSQL (`jsonb` często lepszy niż klasyczne EAV), SQL Server (`SQL_VARIANT` / sparse / JSON) |
| **SQL** | [Postgres](../../sql/postgres/modelowanie/eav.sql) · [SQL Server](../../sql/sqlserver/modelowanie/eav.sql) |

## Problem

Encja ma 3 atrybuty albo 300, w zależności od typu. ALTER TABLE przy każdej nowej cesze nie przechodzi.

## Model

Klasycznie trzy tabele: encja, słownik atrybutów, wartości.

```text
Encja (EncjaId)
Atrybut (AtrybutId, Kod, TypDanych)
Wartosc (EncjaId, AtrybutId, WartoscTekst | WartoscLiczba | WartoscData)
```

Lepszy wariant niż jedna kolumna `sql_variant` / `text`: **osobne kolumny per typ** albo `jsonb` z JSON Schema / CHECK.

Na Postgresie dla „półotwartych” cech często wygrywa:

```text
produkt (id, sku, atrybuty jsonb)
```

z indeksem GIN i jawną listą znanych kluczy w dokumentacji. To nadal EAV, tylko w jednym dokumencie.

## Kluczowe ograniczenia

- UNIQUE `(EncjaId, AtrybutId)`.
- Typ atrybutu w słowniku + CHECK, że wypełniona jest właściwa kolumna wartości.
- Nie mieszaj jednostek w jednym `WartoscTekst` (`"10 kg"` vs `"10"`).

## Operacje

Zapis: upsert wartości. Odczyt „pokaż encję” jest tani (pivot / jsonb). Odczyt „wszystkie encje gdzie kolor=czerwony i waga>10” jest drogi bez GIN / sparse indexes / osobnych kolumn.

## Pułapki

- Filtrowanie po EAV jak po kolumnach relacyjnych — pełne skany, złe plany.
- Brak typów → `"true"`, `"1"`, `"tak"` jako ten sam fakt.
- EAV **i** twarde kolumny na to samo pole.

## Powiązane

- [Normalizacja](normalizacja.md)
- [STI](sti.md) — gdy zestawy atrybutów są skończone i znane per typ
- [CSV w kolumnie](../../antywzorce/csv-w-kolumnie.md)
