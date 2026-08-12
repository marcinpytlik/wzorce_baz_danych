# Security definer

> Moduł definiuje uprawnienia wykonania (w SQL Server: `EXECUTE AS OWNER` / podpis). Caller nie dziedziczy GRANT na obiektach wewnątrz.

| | |
|---|---|
| **Po co** | API = procedura, nie tabele |
| **SQL** | [skrypt](../sql/mechanizmy/security-definer.sql) |

W Postgresie to `SECURITY DEFINER`. Tu: procedura jako jedyne API + [ownership chaining](ownership-chaining.md) albo [podpis](../wzorce/bezpieczenstwo/module-signing.md).

Runtime: `GRANT EXECUTE ON dbo.Api_* TO app_runtime` i zero na tabelach. To jest właściwy kształt [least privilege](../wzorce/bezpieczenstwo/least-privilege.md) dla OLTP.

Nie mylić z „definer = sa”.
