# CHECK jako reguła domeny

> Dziedzina w silniku, nie tylko w aplikacji. Tanie, deterministyczne, bez podzapytań (zwykle).

| | |
|---|---|
| **Po co** | TPH (`Typ` ⇒ kolumny), `Ilosc > 0`, `ISJSON` |
| **SQL** | [skrypt](../sql/mechanizmy/check-constraint.sql) |

```sql
CONSTRAINT CK_tph_zadanie CHECK (Typ <> N'Zadanie' OR Termin IS NOT NULL)
CONSTRAINT CK_json CHECK (ISJSON(Payload) = 1)
```

CHECK nie zastępuje FK i UNIQUE. UDF w CHECK jest możliwy i zwykle żałujesz (sekwencja, zły plan, omijanie przy bulk).

Używane przez: [TPH](../wzorce/modelowanie/tph-tpt-tpct.md), [EAV](../wzorce/modelowanie/eav.md).
