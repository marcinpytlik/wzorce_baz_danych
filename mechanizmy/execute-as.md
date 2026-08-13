# EXECUTE AS

> Moduł biegnie jako wskazany użytkownik. Łatwy, często za szeroki. Preferuj [module signing](../wzorce/bezpieczenstwo/module-signing.md).

| | |
|---|---|
| **Po co** | Szybki elevation w procedurze |
| **SQL** | [skrypt](../sql/mechanizmy/execute-as.sql) |

```sql
CREATE PROCEDURE dbo.Diag
WITH EXECUTE AS OWNER
AS ...
```

`EXECUTE AS OWNER` = uprawnienia właściciela schematu na czas modułu. `EXECUTE AS 'user'` wymaga `IMPERSONATE`. Łańcuch `ORIGINAL_LOGIN()` vs `SUSER_SNAME()` myli audyt.

Pułapka: wszystkie procedury `AS OWNER` = aplikacja z `EXECUTE` ma de facto `dbo`.
