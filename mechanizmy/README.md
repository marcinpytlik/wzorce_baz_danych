# Mechanizmy SQL Server 2022

To nie są decyzje domenowe. To narzędzia, które wzorce **używają**. Karta wzorca mówi *kiedy*; tutaj *jak w T-SQL*.

| Mechanizm | Używane przez |
|---|---|
| [Covering index](covering-index.md) | [Keyset](../wzorce/wydajnosc/keyset-pagination.md), listy, kolejka |
| [Filtered index](filtered-index.md) | [Soft delete](../wzorce/usuwanie/soft-delete.md), [SCD2](../wzorce/historia/scd.md), outbox dren |
| [CHECK](check-constraint.md) | TPH, dziedziny, JSON |
| [UNIQUE](unique-constraint.md) | [Idempotencja](../wzorce/wspolbieznosc/idempotencja.md), klucze biznesowe |
| [EXECUTE AS](execute-as.md) | Procedury; zwykle gorsze niż [module signing](../wzorce/bezpieczenstwo/module-signing.md) |
| [Ownership chaining](ownership-chaining.md) | Widoki/procedury w tym samym ownerze |
| [Security definer](security-definer.md) | Synonim `EXECUTE AS OWNER` — ostrożnie |

Partycjonowanie, RLS, ledger, Always Encrypted mają **własne karty wzorców** — tu ich nie duplikujemy.
