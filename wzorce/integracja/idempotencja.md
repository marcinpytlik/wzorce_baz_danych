# Idempotencja

> Ponowny ten sam request / komunikat nie tworzy drugiego skutku. Klucz + stan, nie „mamy nadzieję”.

| | |
|---|---|
| **Kiedy stosować** | HTTP retry, at-least-once, przycisk dwa razy, replay outbox |
| **Kiedy unikać** | Operacja jest z natury bezpieczna (`GET`, `PUT` pełnego dokumentu) **i** nie ma efektów ubocznych poza tym dokumentem |
| **Silniki** | PostgreSQL, SQL Server |
| **SQL** | [Postgres](../../sql/postgres/integracja/idempotencja.sql) · [SQL Server](../../sql/sqlserver/integracja/idempotencja.sql) |

## Problem

Klient wysłał `POST /platnosci` dwa razy (timeout, retry). Bez klucza masz dwie wypłaty. UNIQUE na tabeli biznesowej czasem wystarczy, czasem nie (ta sama kwota, inny tytuł, ten sam klient).

## Model

Jawna tabela kluczy:

```text
Idempotencja (
  Klucz,           -- z nagłówka Idempotency-Key / MessageId
  Zakres,          -- tenant + endpoint / konsument
  RequestHash,     -- opcjonalnie: ten sam klucz, inny body = 409
  Odpowiedz,       -- replay pierwszego wyniku
  Stan,            -- WToku | Zrobione | Blad
  UtworzonoAt
)
PK (Zakres, Klucz)
```

Protokół:

1. `INSERT` stanu `WToku`. Konflikt:
   - `Zrobione` → zwróć zapisaną odpowiedź,
   - `WToku` → 409 / czekaj (inny worker w środku),
   - inny `RequestHash` → 409 Conflict.
2. Efekty biznesowe w tej samej TX (albo po niej, z ostrożnym przejściem stanu).
3. `Zrobione` + snapshot odpowiedzi.

[Inbox](inbox.md) to specjalizacja: klucz = `MessageId`, zakres = konsument, zwykle bez replay body HTTP.

Unikalność biznesowa (`UNIQUE (KlientId, NumerFaktury)`) jest **drugą** linią, nie zamiast klucza idempotency — inny numer, ten sam retry, nadal duplikat logiczny.

## Kluczowe ograniczenia

- PK `(Zakres, Klucz)`.
- TTL / partycja — klucze nie żyją wiecznie, ale muszą przeżyć okno retry (minuty–dni).
- Hash body, jeśli kontrakt „ten sam klucz = to samo żądanie”.

## Operacje

Hot path: jeden INSERT. Replay: SELECT odpowiedzi. Sweep: kasuj `Zrobione` po retencji.

## Pułapki

- Klucz generowany na serwerze przy każdym retry — bez sensu.
- `WToku` bez timeoutu — zacięty worker blokuje klucz na zawsze.
- Idempotencja tylko w aplikacji, baza przyjmuje dwa INSERT-y.

## Powiązane

- [Inbox](inbox.md)
- [Outbox](outbox.md)
- [Brak unikalności](../../antywzorce/brak-unikalnosci.md)
