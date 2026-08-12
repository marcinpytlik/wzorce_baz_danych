# Inbox

> Zapis „ten komunikat już wziąłem” **zanim** (albo atomowo z) efektem ubocznym. Duplikat nie robi drugiej faktury.

| | |
|---|---|
| **Status** | `READY` |
| **Kiedy stosować** | Konsument at-least-once (kolejka, outbox po drugiej stronie, retry) |
| **Kiedy unikać** | Naprawdę at-most-once i akceptujesz utratę — i tak zwykle kłamiesz |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/integracja/inbox.sql) |

## Problem

Broker dostarcza jeszcze raz. Handler jest „prawie” idempotentny, ale INSERT faktury przechodzi dwa razy.

## Model

```text
Inbox (MessageId, Konsument, OdebranoAt, PrzetworzonoAt)
PK (MessageId, Konsument)   -- ten sam temat może mieć wielu konsumentów
```

Wzorzec:

1. `INSERT Inbox (MessageId, ...)` — kolizja PK ⇒ duplikat, ack i wyjście.
2. W **tej samej** TX: efekt biznesowy (INSERT faktury, UPDATE salda).
3. `COMMIT`, potem ack do brokera.

Jeśli ack przed COMMIT: przy crashu dostaniesz komunikat ponownie — dlatego krok 1 musi być odporny na duplikat.

Gdy efekt nie mieści się w TX z inboxem (zewnętrzne API): zapisuj stan maszyny (`Odebrano` → `WToku` → `Zrobione`) i opieraj się na [idempotencji](../wspolbieznosc/idempotencja.md) po stronie API.

## Kluczowe ograniczenia

- PK `(MessageId, Konsument)`.
- `MessageId` pochodzi od **nadawcy** (idempotency key / id zdarzenia), nie `NEWID()` w konsumencie.
- Retencja: inbox puchnie; partycjonuj po dacie albo czyść po TTL, jeśli id nie wrócą.

## Operacje

Hot path: jeden INSERT. Raport „co przetworzyliśmy” = inbox. Replay z brokera jest bezpieczny.

## Pułapki

- Inbox w pamięci procesu — restart czyści pamięć, nie duplikaty.
- `MessageId` = hash payloadu bez id nadawcy — kolizje albo fałszywe duplikaty przy korekcie payloadu.
- Dwa konsumenci, jeden PK tylko na `MessageId` — drugi nie przetworzy.

## Powiązane

- [Outbox](outbox.md) — para: atomowy emit + atomowy odbiór
- [Idempotencja](../wspolbieznosc/idempotencja.md)
- [Saga](saga.md)
