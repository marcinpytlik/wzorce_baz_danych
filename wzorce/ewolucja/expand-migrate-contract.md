# Expand–Migrate–Contract

> Zmiana schematu w trzech fazach, bez wspólnego okna downtime. Shadow column, backfill, compatibility view, parallel table i feature flag to **taktyki wewnątrz**, nie osobne wzorce.

| | |
|---|---|
| **Status** | `READY` |
| **Kiedy stosować** | Stara i nowa wersja aplikacji muszą działać naraz |
| **Kiedy unikać** | Jedyna instancja, możesz wziąć okno i przerobić w miejscu |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/ewolucja/expand-migrate-contract.sql) |

## Problem

`ALTER` z `NOT NULL` + przepisaniem danych blokuje tabelę. Aplikacja v1 nie zna nowej kolumny, v2 nie zna starej. Deploy „big bang” pada w połowie.

## Model — trzy fazy

1. **Expand** — dodaj nowy kształt *obok* starego: nullable kolumna, nowa tabela, nowy widok. Stary kod nie wie i nie boli.
2. **Migrate** — dograj dane (backfill batchami), pisz w **oba** miejsca w tej samej TX (to jedyny dual write, który jest OK: ta sama baza). Feature flag przełącza odczyt.
3. **Contract** — gdy v1 zniknie: drop starej kolumny/tabeli, `NOT NULL`, zdejmij widok kompatybilności.

Taktyki:

| Taktyka | Rola |
|---|---|
| Shadow column | Nowa kolumna obok starej (`Nazwa` → `NazwaNorm`) |
| Backfill in batches | `UPDATE TOP (5000)` + bookmark, nie jeden skan 200 mln wierszy |
| Compatibility view | v1 czyta widok o starym kształcie, pod spodem nowy model |
| Parallel table | Nowy schemat w `dbo2`, cutover później ([blue-green](blue-green.md) to ten sam pomysł w skali środowiska) |
| Feature flag | Odczyt ze starej albo nowej kolumny bez drugiego deployu DDL |

## Kluczowe ograniczenia

- Expand nigdy nie łamie starego kontraktu (brak `NOT NULL` na starcie, brak rename w expand).
- Backfill idempotentny; bookmark w tabeli postępu.
- Trigger / aplikacja w fazie migrate pisze obie strony **w jednej TX**.

## Pułapki

- Dual write do brokera albo drugiej bazy w migrate — to [antywzorzec](../../antywzorce/dual-write.md).
- Contract zanim padnie ostatnia instancja v1.
- Backfill bez batchy: lock escalation i log puchnie.
- Feature flag, która żyje wiecznie — nigdy nie robisz contract.

## Powiązane

- [Blue-green](blue-green.md)
- [Dual write](../../antywzorce/dual-write.md)
- [Keyset pagination](../wydajnosc/keyset-pagination.md) — kursor backfillu
