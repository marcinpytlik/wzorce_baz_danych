# Optimistic concurrency (CAS)

> Zapis przechodzi, gdy wersja się zgadza. Compare-and-swap to ten sam wzorzec: `UPDATE ... WHERE Wersja = @oczekiwana`.

| | |
|---|---|
| **Status** | `READY` |
| **Kiedy stosować** | Rzadki konflikt, krótka TX, UI z `rowversion` |
| **Kiedy unikać** | Gorące saldo, dwa kasjerów na ten sam wiersz co chwila — [pesymistyczna](pessimistic-concurrency.md) albo [kolejka](queue-serialization.md) |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/wspolbieznosc/optimistic-concurrency.sql) |

## Problem

Dwa requesty czytają wiersz, oba zapisują. Ostatni wygrywa, pierwszy nie wie.

## Model

Kolumna `rowversion` (albo `int Wersja`). UPDATE:

```sql
UPDATE dbo.Dokument
SET Tresc = @tresc
WHERE DokumentId = @id AND WersjaWiersza = @wersja;
-- @@ROWCOUNT = 0 ⇒ konflikt, nie nadpisuj
```

CAS na saldzie: `UPDATE ... SET Saldo = Saldo - @n WHERE Id = @id AND Saldo >= @n`. To też optymistyczne: warunek jest stanem, nie lockiem na czas HTTP.

## Kluczowe ograniczenia

- Klient **musi** przysłać wersję z odczytu.
- 0 wierszy ≠ „nie ma dokumentu” — rozróżnij `EXISTS` vs konflikt.
- Nie mieszaj z pesymistycznym lockiem na ten sam use-case.

## Pułapki

- `rowversion` w SELECT, ale UPDATE bez `WHERE rowversion`.
- Retry, które ponownie czyta i nadpisuje bez decyzji biznesowej.
- Wersja w aplikacji, baza przyjmuje każdy UPDATE.

## Powiązane

- [Pessimistic concurrency](pessimistic-concurrency.md)
- [Idempotencja](idempotencja.md)
- [Event sourcing](../historia/event-sourcing.md) — wersja agregatu
