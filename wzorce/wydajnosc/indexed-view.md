# Indexed view

> Projekcja `SELECT` utrzymywana przy DML. W SQL Server to nie jest `REFRESH` — koszt jest na każdym zapisie źródła.

| | |
|---|---|
| **Status** | `STARTER` |
| **Kiedy stosować** | Ciężka agregacja, ta sama instancja, DML źródła umiarkowany |
| **Kiedy unikać** | OUTER JOIN, `UNION`, niedeterministyczne funkcje; albo odczyt musi być w innej bazie — wtedy [CQRS](cqrs.md) |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/wydajnosc/indexed-view.sql) |

## Problem

Raport / lista jest za droga na żywych tabelach.

## Model

```sql
CREATE VIEW dbo.v_sprzedaz_dzien WITH SCHEMABINDING AS
SELECT Dzien, Sku, SUM(Ilosc) AS Ilosc, SUM(Wartosc) AS Wartosc, COUNT_BIG(*) AS Cnt
FROM dbo.Pozycja
GROUP BY Dzien, Sku;

CREATE UNIQUE CLUSTERED INDEX IX ON dbo.v_sprzedaz_dzien (Dzien, Sku);
```

Odczyt: `WITH (NOEXPAND)` — inaczej optymalizator na Standard bywa, że zignoruje indeks.

Gdy indexed view nie przechodzi: tabela snapshot + job `MERGE` (to już [read model](cqrs.md), nie indexed view).

Denormalizacja odczytu, precomputed summary i materialized aggregate to **ta sama decyzja**. Osobnych kart nie ma.

## Kluczowe ograniczenia

- `SCHEMABINDING`, dwuczłonowe nazwy, `COUNT_BIG` przy `GROUP BY`.
- UNIQUE CLUSTERED na kluczu projekcji.
- Źródło nie może być w innej bazie.

## Operacje

Zero joba. INSERT/UPDATE/DELETE na `Pozycja` utrzymuje widok. To zaleta i koszt.

## Pułapki

- Częsty DML na źródle = wolniejszy OLTP niż zysk na SELECT.
- Brak `NOEXPAND` na Standard.
- Traktowanie indexed view jako substytutu CQRS między serwisami.

## Powiązane

- [CQRS](cqrs.md)
- [Cache](cache.md)
- [Normalizacja](../modelowanie/normalizacja.md)
- [Covering index](../../mechanizmy/covering-index.md)
