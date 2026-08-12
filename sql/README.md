# Skrypty SQL Server 2022

Jeden skrypt na kartę wzorca. Katalogi odpowiadają `wzorce/` (oraz `mechanizmy/`).

Przykłady edukacyjne: schemat + typowe operacje. Nie są to migracje produkcyjne.

```bash
sqlcmd -S localhost -d wzorcownia -I -i sql/integracja/outbox.sql
```

Skrypty są tam, gdzie da się tanio, idempotentne (`IF OBJECT_ID ... DROP`, `DROP TABLE IF EXISTS`).
Wymagają SQL Server 2022 (m.in. ledger, `IS [NOT] DISTINCT FROM`, JSON).
