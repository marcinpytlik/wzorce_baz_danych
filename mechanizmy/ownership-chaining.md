# Ownership chaining

> Ten sam owner: procedura/widok może czytać tabele bez GRANT dla callera na tabelach. Granica = zmiana ownera.

| | |
|---|---|
| **Po co** | Ukryć tabele za widokiem/procedurą w jednym schemacie |
| **SQL** | [skrypt](../sql/mechanizmy/ownership-chaining.sql) |

Caller ma `SELECT` na widoku, nie na tabeli. Działa, dopóki `dbo.Widok` i `dbo.Tabela` mają tego samego ownera. Cross-schema bez tego samego ownera łańcuch pęka — i dobrze.

Nie włączaj `DB_CHAINING` / cross-db chaining „żeby JOIN działał”. To dziura.

Używane ostrożnie z [least privilege](../wzorce/bezpieczenstwo/least-privilege.md). Do elevation ponad ownera: [module signing](../wzorce/bezpieczenstwo/module-signing.md).
