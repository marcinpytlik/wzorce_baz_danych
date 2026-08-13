# Event sourcing

> Log zdarzeń jest źródłem prawdy. Stan bieżący to projekcja. Snapshot jest taktyką, nie osobnym wzorcem.

| | |
|---|---|
| **Status** | `ADVANCED` |
| **Kiedy stosować** | Audyt intencji, replay, wiele read modeli z jednego logu |
| **Kiedy unikać** | Chcesz tylko historię UPDATE — [temporal](temporal.md) / [audit](audit-trail.md) |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/historia/event-sourcing.sql) |

## Problem

Stan wiersza nie mówi, *dlaczego* tak jest. CQRS z outboxem publikuje zdarzenia, ale źródłem prawdy nadal jest tabela stanu. ES odwraca to: najpierw zdarzenie, stan da się odbudować.

## Model

```text
Strumien (AgregatId, Wersja, Typ, Payload, UtworzonoAt)
  PK (AgregatId, Wersja)
Snapshot (AgregatId, Wersja, Stan)     -- opcjonalnie, co N zdarzeń
```

Zapis: INSERT zdarzenia z `Wersja = oczekiwana + 1` (CAS). Konflikt wersji = 0 wierszy / UNIQUE. Projekcje: [CQRS](../wydajnosc/cqrs.md) z [inbox](../integracja/inbox.md).

Snapshot skraca replay (załaduj stan z wersji N, dograj N+1…). Nie zastępuje logu.

## Kluczowe ograniczenia

- UNIQUE `(AgregatId, Wersja)` — to jest optymistyczna współbieżność agregatu.
- Zdarzenia immutable.
- Upcast schematu payloadu (v1 JSON → v2) to osobny problem; nie UPDATE-uj starych wierszy w ciemno.

## Pułapki

- ES „bo DDD” na CRUD.
- Projekcja jako źródło kolejnej komendy bez wersji.
- Brak snapshotu na długich strumieniach — replay 2 mln zdarzeń na request.

## Powiązane

- [Append-only](append-only.md)
- [CQRS](../wydajnosc/cqrs.md)
- [Optimistic concurrency](../wspolbieznosc/optimistic-concurrency.md)
- [Outbox](../integracja/outbox.md)
