# Niemutowalny audyt (ledger)

> Wiersza audytu nie da się cicho poprawić. SQL Server 2022: ledger tables + digest.

| | |
|---|---|
| **Status** | `STARTER` |
| **Kiedy stosować** | Compliance, „nikt z dbo nie poprawi logu po cichu” |
| **Kiedy unikać** | Zwykły trail bez zagrożenia insider — wystarczy [audit trail](../historia/audit-trail.md) + brak GRANT DELETE |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/bezpieczenstwo/immutable-audit.sql) |

## Problem

Trigger „zamiast DELETE” nie broni przed `dbo`, restore i wyłączeniem triggera.

## Model

```sql
CREATE TABLE dbo.AuditLedger (
    Id BIGINT IDENTITY NOT NULL,
    Kiedy DATETIME2(3) NOT NULL,
    Kto SYSNAME NOT NULL,
    Payload NVARCHAR(MAX) NOT NULL,
    CONSTRAINT PK_audit PRIMARY KEY (Id)
) WITH (LEDGER = ON);
```

Ledger append-only (updatable ledger ma historię w ledger history). Digest: `sys.sp_generate_database_ledger_digest` — trzymaj **poza** bazą. Weryfikacja: `sys.sp_verify_database_ledger`.

Aplikacja: tylko INSERT. To twardszy [append-only](../historia/append-only.md).

## Kluczowe ograniczenia

- Digest off-box (inny system, WORM, papier).
- Ledger ma koszt na DML — nie na każdą tabelę biznesową.
- Backup + digest razem, inaczej nie udowodnisz.

## Pułapki

- Ledger bez digestu poza bazą — insider z backupem przepisze obie rzeczy.
- Updatable ledger mylony z „nie da się zmienić”.
- Trigger zamiast ledger i poczucie bezpieczeństwa.

## Powiązane

- [Audit trail](../historia/audit-trail.md)
- [Append-only](../historia/append-only.md)
- [Least privilege](least-privilege.md)
