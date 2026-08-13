# Association table

> N:N jako tabela z dwoma prawdziwymi FK, nie CSV i nie para `(Typ, Id)`.

| | |
|---|---|
| **Status** | `STARTER` |
| **Kiedy stosować** | Encja należy do wielu innych (tagi, role, pozycje zestawu) |
| **Kiedy unikać** | To jest 1:N — wystarczy FK na dziecku |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/modelowanie/association.sql) |

## Problem

`Zamowienie` ma wiele `Produkt`, produkt jest na wielu zamówieniach. Albo użytkownik ma wiele ról.

## Model

```text
Zamowienie (ZamowienieId)
Produkt (ProduktId)
Pozycja (ZamowienieId, ProduktId, Ilosc)  -- association + atrybuty związku
```

PK złożony `(ZamowienieId, ProduktId)`. Atrybuty związku (`Ilosc`, `Cena`) żyją tu, nie na rodzicu.

Gdy druga strona ma kilka typów: **osobna** tabela asocjacji per typ (`ZalacznikZamowienia`, `ZalacznikZgloszenia`), nie [polimorficzny FK](../../antywzorce/polimorficzny-fk.md).

## Kluczowe ograniczenia

- Oba FK `ON DELETE` jawne (zwykle CASCADE z rodzicem związku, nie z obu stron).
- UNIQUE / PK na parze.
- Żadnego `Tagi NVARCHAR`.

## Pułapki

- Association bez atrybutów i bez PK — duplikaty par.
- Jedna tabela `Powiazanie (LewyTyp, LewyId, PrawyTyp, PrawyId)`.

## Powiązane

- [Notacja Chena](../../projektowanie/notacja-chena.md) — M:N i atrybuty na związku
- [Normalizacja](normalizacja.md)
- [TPH / TPT](tph-tpt-tpct.md)
- [CSV w kolumnie](../../antywzorce/csv-w-kolumnie.md)
