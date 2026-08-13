# Outbox

> Zdarzenie wychodzi w **tej samej transakcji** co zapis stanu. Publisher czyta tabelę, nie „drugi round-trip po COMMIT”.

| | |
|---|---|
| **Status** | `READY` |
| **Kiedy stosować** | Stan + komunikat muszą być atomowe (zamówienie złożone ⇒ `ZamowienieZlozone` w brokerze) |
| **Kiedy unikać** | Nie masz procesu, który drenuje outbox; wtedy to martwa tabela |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/integracja/outbox.sql) |

## Problem

`COMMIT` w bazie, potem `Publish` do kolejki. Między nimi proces pada — stan jest, zdarzenia nie ma. Albo odwrotnie, jeśli publikujesz przed COMMIT.

## Model

```text
-- w tej samej TX:
UPDATE / INSERT encji biznesowej
INSERT Outbox (Id, Typ, AgregatId, Payload, UtworzonoAt, OpublikowanoAt NULL)
COMMIT

-- osobny worker:
SELECT ... WHERE OpublikowanoAt IS NULL ORDER BY UtworzonoAt
Publish → UPDATE OpublikowanoAt
```

Payload: JSON ze **zdarzeniem biznesowym**, nie dumpem wiersza (do dumpu jest [CDC](cdc.md)).

Kolejność: `UtworzonoAt` + sekwencja per agregat (`AgregatId`, `Wersja`), albo partycja brokera po `AgregatId`.

## Kluczowe ograniczenia

- PK na `Id` (UUID / UNIQUEIDENTIFIER).
- Indeks drenujący: `(OpublikowanoAt, UtworzonoAt)` albo filtrowany `WHERE OpublikowanoAt IS NULL`.
- Opcjonalnie UNIQUE `(AgregatId, Wersja)` — kolejność per agregat.
- Worker: `UPDLOCK, READPAST, ROWLOCK`, żeby wiele instancji nie brało tego samego wiersza. To samo narzędzie co w [queue table](../wydajnosc/queue-table.md) — inny cel.

## Operacje

Drenaż w pętlach, batch, backoff przy błędzie brokera. Nie kasuj wiersza od razu — retencja pomaga w debugowaniu; potem archiwum / partition switch.

At-least-once do brokera: konsument **musi** mieć [inbox](inbox.md) / [idempotencję](../wspolbieznosc/idempotencja.md).

## Pułapki

- Publish w aplikacji poza TX „bo tak prościej”.
- Olbrzymi payload (cały graf) — outbox to nie dump bazy.
- Jeden globalny worker bez `READPAST` — serializacja i zatory.
- `OpublikowanoAt` ustawiane **przed** potwierdzeniem brokera — zgubisz komunikat przy crashu.

## Powiązane

- [Inbox](inbox.md)
- [Idempotencja](../wspolbieznosc/idempotencja.md)
- [CDC](cdc.md) — gdy nie możesz ruszyć transakcji aplikacji
- [Saga](saga.md)
- [Queue table](../wydajnosc/queue-table.md)
