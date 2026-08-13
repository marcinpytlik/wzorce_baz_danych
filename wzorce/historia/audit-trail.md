# Audit trail

> Dziennik „kto, kiedy, co zrobił”. To zdarzenie audytowe, nie kopia wiersza i nie event sourcing.

| | |
|---|---|
| **Status** | `STARTER` |
| **Kiedy stosować** | Compliance, śledzenie operacji, logon / failed login / zmiana uprawnień |
| **Kiedy unikać** | Pytanie brzmi „jaki był stan wiersza o 14:07” — [temporal](temporal.md) |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/historia/audit-trail.sql) |

## Problem

Wiesz, że ktoś zmienił fakturę, ale nie wiesz kto i z jakiego stanowiska. Temporal da stary wiersz, nie tożsamość operatora ani uzasadnienie.

## Model

```text
Audit (Id, Kiedy, Kto, Encja, EncjaId, Operacja, Przed, Po, Korelacja)
```

Zasilanie: trigger, aplikacja w tej samej TX, albo SQL Server Audit / Extended Events na logon. Trigger jest prosty i omijalny przez `dbo`. Do twardszego kontraktu: [niemutowalny audyt](../bezpieczenstwo/immutable-audit.md) (ledger).

## Kluczowe ograniczenia

- Append-only (brak UPDATE/DELETE dla roli aplikacji).
- `Kto` z `SUSER_SNAME()` / kontekstu aplikacji, nie z kolumny, którą request sam wstawia bez kontroli.
- Retencja i partycja po dacie.

## Pułapki

- Audit w tej samej tabeli biznesowej (`Zmodyfikowal`, `Zmodyfikowano`) — to metadane wiersza, nie trail.
- Payload bez PK encji — nie złożysz historii jednego obiektu.
- Trigger, który woła sieć / kolejkę.

## Powiązane

- [Tabele temporalne](temporal.md)
- [Append-only](append-only.md)
- [Niemutowalny audyt](../bezpieczenstwo/immutable-audit.md)
