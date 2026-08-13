# Least privilege

> Runtime nie jest `sysadmin`. Migracje mają osobne konto. Aplikacja dostaje tylko to, czego używa.

| | |
|---|---|
| **Status** | `STARTER` |
| **Kiedy stosować** | Zawsze, gdy baza nie jest zabawką na laptopie |
| **Kiedy unikać** | — |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/bezpieczenstwo/least-privilege.sql) |

## Problem

Connection string z `sa`. Ransomware i zły deploy mają DDL, backup i `xp_cmdshell`.

## Model

| Konto | Może |
|---|---|
| `migrator` | DDL, `CREATE USER`, joby — tylko w oknie migracji |
| `app_runtime` | `EXECUTE` na procedurach / `SELECT, INSERT, UPDATE, DELETE` na wybranych tabelach |
| `app_reader` | `SELECT` / RLS / masking |
| `cdc_reader` | odczyt CDC/CT |

Osobne hasła, rotacja, TLS. Brak `CONTROL SERVER` na runtime. [Module signing](module-signing.md) gdy procedura musi zrobić coś ponad grantem callera.

## Kluczowe ograniczenia

- Runtime bez `ALTER`, `CREATE`, `VIEW ANY DATABASE` jeśli niepotrzebne.
- Brak `db_owner` na aplikacji.
- Migrator nie leży w puli połączeń IIS/K8s na stałe.

## Pułapki

- Jedno konto „żeby connection string był prosty”.
- `GRANT CONTROL ON DATABASE` zamiast listy.
- DDM / RLS przy `dbo` — teatr.

## Powiązane

- [Module signing](module-signing.md)
- [RLS](../multi-tenant/rls.md)
- [EXECUTE AS](../../mechanizmy/execute-as.md)
