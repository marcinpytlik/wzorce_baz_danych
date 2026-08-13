# Queue table

> Tabela jako kolejka pracy: `UPDLOCK, READPAST, ROWLOCK`. To nie jest [outbox](../integracja/outbox.md) — tu praca *jest* w SQL, nie komunikat na zewnątrz.

| | |
|---|---|
| **Status** | `STARTER` |
| **Kiedy stosować** | Job asynchroniczny, kilka workerów, SQL ma być brokerem |
| **Kiedy unikać** | Potrzebujesz brokera z pub/sub, replayem tematów, wieloma konsumentami semantyki — outbox + prawdziwa kolejka |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/wydajnosc/queue-table.sql) |

## Problem

Chcesz przyjąć request szybko i zrobić ciężar w tle, bez Service Brokera i bez zewnętrznego brokera.

## Model

```text
Kolejka (Id, Klucz, Payload, Status, WidocznyAt, Proby)
-- Status: Nowa | WToku | Zrobiona | Martwa
```

Worker:

```sql
;WITH cte AS (
  SELECT TOP (1) *
  FROM dbo.Kolejka WITH (UPDLOCK, READPAST, ROWLOCK)
  WHERE Status = N'Nowa' AND WidocznyAt <= SYSUTCDATETIME()
  ORDER BY Id
)
UPDATE cte SET Status = N'WToku', Proby = Proby + 1
OUTPUT inserted.*;
```

`READPAST` = pomiń zablokowane. Poison: `Proby >= N` → `Martwa`. [Serializacja](../wspolbieznosc/queue-serialization.md) = dodatkowo jeden wiersz `WToku` per `Klucz`.

## Kluczowe ograniczenia

- Indeks `(Status, WidocznyAt, Id)` filtrowany na `Nowa`.
- TX: weź wiersz + efekt biznesowy albo visibility timeout (`WidocznyAt` w przyszłości przy błędzie).
- Nie kasuj od razu — retencja do debugowania.

## Pułapki

- `SELECT` bez `READPAST` — jeden worker, reszta czeka.
- Outbox i queue table w jednej tabeli „bo podobne kolumny”.
- Brak poison handling.

## Powiązane

- [Outbox](../integracja/outbox.md)
- [Serializacja kolejką](../wspolbieznosc/queue-serialization.md)
- [Application lock](../wspolbieznosc/application-lock.md)
