# Retention policy

> „Po N dniach / N latach” to job z właścicielem, nie nadzieja. Polityka wskazuje *co* i *jak* (hard, archive, tombstone).

| | |
|---|---|
| **Status** | `STARTER` |
| **Kiedy stosować** | Różne tabele, różne terminy, audytor pyta „kiedy kasujecie” |
| **Kiedy unikać** | Jedna flaga `IsDeleted` na zawsze |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/usuwanie/retention.sql) |

## Problem

Outbox, inbox, audit, logi, PII — każdy zbiór ma inny obowiązek. Bez tabeli polityki joby są w głowie jednego DBA.

## Model

```text
PolitykaRetencji (Tabela, Dni, Akcja, Wlasciciel, OstatniBiegAt)
-- Akcja: HardDelete | Archive | Tombstone | PartitionSwitch
```

Job czyta politykę, liczy `@prog = DATEADD(DAY, -Dni, SYSUTCDATETIME())`, woła procedurę per tabela. Wynik biegu logujesz (ile wierszy, błąd).

## Kluczowe ograniczenia

- Jedna polityka per tabela (albo per tenant, jeśli RODO per klient).
- Akcja musi istnieć jako procedura — polityka bez kodu to wiki.
- Okno serwisowe / `MAXDOP` / batche, nie jeden DELETE 50 mln.

## Pułapki

- Retencja audytu krótsza niż retencja biznesu, który audyt tłumaczy.
- Job jako `sa` na wszystkich tabelach bez listy.
- Brak `OstatniBiegAt` — nie wiesz, czy polityka żyje.

## Powiązane

- [Hard delete](hard-delete.md)
- [Archive then delete](archive-then-delete.md)
- [Partition switching](partition-switching-purge.md)
