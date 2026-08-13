# Blue-green bazy

> Dwa kompletne środowiska (blue = live, green = nowa). Cutover to przełączenie synonimu, aliasu albo connection stringa, nie ALTER w miejscu.

| | |
|---|---|
| **Status** | `STARTER` |
| **Kiedy stosować** | Duża zmiana schematu / wersji, chcesz rollback w sekundy |
| **Kiedy unikać** | Jedna kolumna — wystarczy [EMC](expand-migrate-contract.md) |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/ewolucja/blue-green.sql) |

## Problem

EMC w jednej tabeli nie wystarcza: zmieniasz partycje, collations, albo cały model. Rollback ALTER-a jest gorszy niż rollback wskaźnika.

## Model

```text
blue  (live)     dbo / baza Prod
green (kandydat) dbo_next / baza Prod_Next
przełączenie: SYNONYM, DNS, connection string w katalogu
```

Green zasilasz restore + dogrywaniem ([CDC](../integracja/cdc.md) / log shipping / AG readable) albo replayem zdarzeń. Cutover: krótki freeze zapisu, dogranie ogona, flip.

## Kluczowe ograniczenia

- Identity / sekwencje: po cutover green musi iść dalej, nie od 1.
- Loginów i jobów nie zostawiaj tylko na blue.
- Test restore green **przed** dniem cutover.

## Pułapki

- Dwa środowiska i dual write aplikacji na oba — [antywzorzec](../../antywzorce/dual-write.md).
- Cutover bez freeze: zgubione wiersze z ogona.
- „Blue-green” jako nazwa na zwykły rolling EMC.

## Powiązane

- [Expand–Migrate–Contract](expand-migrate-contract.md)
- [Read replicas](../wydajnosc/read-replicas.md)
