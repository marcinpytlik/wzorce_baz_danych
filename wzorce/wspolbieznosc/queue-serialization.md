# Serializacja kolejką

> Zamiast lockować wiersz biznesowy, ustawiasz pracę w kolejce per klucz. Jeden konsument na `KontoId` = kolejność bez długiego `HOLDLOCK`.

| | |
|---|---|
| **Status** | `STARTER` |
| **Kiedy stosować** | Kolejność per agregat (konto, dokument), burst zapisów |
| **Kiedy unikać** | Globalna jedna kolejka na cały system |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/wspolbieznosc/queue-serialization.sql) |

## Problem

Pesymistyczny lock na `Konto` trzyma OLTP. Optymistyczny sypie konfliktami. Chcesz: przyjmij request, przetwórz po kolei.

## Model

Wpis do [queue table](../wydajnosc/queue-table.md) z `KluczSerializacji = KontoId`. Worker: `READPAST` + jeden wiersz per klucz naraz (albo partycja po kluczu w brokerze). Efekt biznesowy w TX z usunięciem / oznaczeniem wiersza kolejki.

To nie outbox (outbox emituje na zewnątrz). To nie saga (saga ma wiele zasobów i kompensacje).

## Kluczowe ograniczenia

- Klucz serializacji w wierszu kolejki.
- Idempotencja handlera.
- Timeout / poison message (N prób → martwy list).

## Pułapki

- Jedna kolejka, jeden worker, wszystko serialnie.
- Worker bez `READPAST` — drugi worker czeka na lock i nic nie robi z reszty.
- Kolejka bez klucza: dwa ruchy tego samego konta idą równolegle.

## Powiązane

- [Queue table](../wydajnosc/queue-table.md)
- [Outbox](../integracja/outbox.md)
- [Saga](../integracja/saga.md)
