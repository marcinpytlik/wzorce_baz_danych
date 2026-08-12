# Slowly Changing Dimension (T1 / T2)

> Wymiar w hurtowni: T1 nadpisuje, T2 wersjonuje wiersz. To nie jest wzorzec OLTP — do OLTP idź w [temporal](temporal.md) / [effective dating](effective-dating.md).

| | |
|---|---|
| **Status** | `STARTER` |
| **Kiedy stosować** | Star schema, atrybut wymiaru się zmienia, raporty mają być „jak wtedy” (T2) albo „jak teraz” (T1) |
| **Kiedy unikać** | Tabela faktów OLTP; SCD2 na każdej kolumnie „na wszelki wypadek” |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/historia/scd.sql) |

## Problem

Klient zmienił województwo. Stare faktury w kostce mają pokazać stare czy nowe?

## Model

| Typ | Zachowanie | Kiedy |
|---|---|---|
| **SCD1** | UPDATE atrybutu w miejscu | Poprawka błędu, nie interesuje Cię historia wymiaru |
| **SCD2** | Nowy wiersz wymiaru, `WazneOd`/`WazneDo` / `IsCurrent`, nowy SK | Raport as-of, fakty wskazują wersję |

```text
DimKlient (KlientSK, KlientBK, Wojewodztwo, WazneOd, WazneDo, IsCurrent)
FactSprzedaz (..., KlientSK)   -- SK, nie BK
```

T3 (kolumna „poprzednia wartość”) pomijamy — to kompromis, który zwykle żałujesz. T1 i T2 mogą współistnieć na różnych atrybutach tego samego wymiaru.

## Kluczowe ograniczenia

- T2: UNIQUE `(KlientBK) WHERE IsCurrent = 1` (indeks filtrowany).
- Fakty trzymają SK, nie BK.
- ETL idempotentny na BK + data biznesowa.

## Pułapki

- Fakty na BK, JOIN „current” — tracisz as-of.
- SCD2 na komentarzu / kolumnie, która zmienia się co godzinę.
- Mieszanie T2 z system-versioned na tej samej tabeli bez decyzji.

## Powiązane

- [Effective dating](effective-dating.md)
- [Tabele temporalne](temporal.md)
- [Filtered index](../../mechanizmy/filtered-index.md)
