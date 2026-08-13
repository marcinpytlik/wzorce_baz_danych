# CQRS (Command Query Responsibility Segregation)

> Model zapisu i model odczytu to osobne schematy, spójne z opóźnieniem.

| | |
|---|---|
| **Status** | `STARTER` |
| **Kiedy stosować** | Komendy mają inny kształt niż ekrany; odczyt jest szeroki/agregujący; różne SLO |
| **Kiedy unikać** | Prosty CRUD, te same pola na wejściu i liście — dublujesz pipeline bez zysku |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/wydajnosc/cqrs.sql) |

## Problem

Tabela znormalizowana jest dobra do zapisu i zła do ekranu „zamówienie + klient + 15 pozycji + status płatności + etykiety”. JOIN na gorącej ścieżce albo denormalizacja w miejscu zapisu.

## Model

```text
write:  Zamowienie, Pozycja, Platnosc     -- 3NF, TX, outbox
read:   ZamowienieLista (denormalizowany wiersz / dokument)
```

Projekcja: handler czyta zdarzenia z [outbox](../integracja/outbox.md) / [CDC](../integracja/cdc.md) i upsertuje read model. Spójność: **eventual**. UI albo pokazuje „przyjęte, indeksujemy”, albo czyta write model na ekranie tuż po zapisie (read-your-writes).

To nie wymaga Event Sourcingu. ES to osobna decyzja (log zdarzeń jako źródło prawdy). CQRS = rozdział modeli.

## Kluczowe ograniczenia

- Write: twarde FK, UNIQUE, CHECK.
- Read: PK = id projekcji; wersja / `UpdatedAt` do idempotentnego upsertu.
- Nie stawiaj FK z read do write across baz.

## Operacje

Komenda: jedna TX na write (+ outbox). Query: `SELECT` z read, bez JOIN-ów domenowych. Rebuild projekcji z logu / snapshotu musi być możliwy od zera.

## Pułapki

- Dwa modele w **tej samej** transakcji „żeby było spójnie” — to nie CQRS, to podwójny zapis.
- Read model jako źródło prawdy do kolejnej komendy.
- Brak idempotencji projekcji przy retry.

## Powiązane

- [Outbox](../integracja/outbox.md)
- [Indexed view](indexed-view.md) — projekcja w tej samej instancji
- [Idempotencja](../wspolbieznosc/idempotencja.md)
