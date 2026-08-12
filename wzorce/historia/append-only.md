# Append-only

> Faktów się nie poprawia. Korekta = nowy wiersz. Tabela jest logiem.

| | |
|---|---|
| **Status** | `STARTER` |
| **Kiedy stosować** | Księgowania, zdarzenia, salda wyliczane z ruchu |
| **Kiedy unikać** | Encja z 20 atrybutami, które poprawiasz w UI — to [temporal](temporal.md) albo zwykły UPDATE |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/historia/append-only.sql) |

## Problem

`UPDATE Saldo SET Kwota = Kwota - 10` gubi historię i wyścigi. Chcesz móc zsumować ruchy i dostać ten sam wynik.

## Model

```text
Ruch (RuchId, KontoId, Kwota, Tresc, UtworzonoAt)  -- tylko INSERT
```

Saldo = `SUM` albo [indexed view](../wydajnosc/indexed-view.md) / tabela salda utrzymywana w tej samej TX. DELETE/UPDATE zabronione uprawnieniem i (opcjonalnie) triggerem.

To nie jest jeszcze [event sourcing](event-sourcing.md): źródłem prawdy może być nadal stan + log ruchów, nie sam log.

## Kluczowe ograniczenia

- Grant: `INSERT, SELECT`, bez `UPDATE, DELETE` dla runtime.
- Idempotencja INSERT-a: [klucz](../wspolbieznosc/idempotencja.md) albo UNIQUE biznesowy.
- Partycja po dacie.

## Pułapki

- „Append-only” i job, który UPDATE-uje status w tej samej tabeli.
- Korekta przez DELETE.
- Brak klucza idempotency przy retry.

## Powiązane

- [Event sourcing](event-sourcing.md)
- [Audit trail](audit-trail.md)
- [Optimistic concurrency](../wspolbieznosc/optimistic-concurrency.md)
