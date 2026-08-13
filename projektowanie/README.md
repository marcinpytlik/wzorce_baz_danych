# Projektowanie

Zanim wzorzec: **co jest encją, jaki ma klucz, jaka liczność**. Ten folder to warstwa koncepcyjna. Wzorce w `wzorce/` wchodzą dopiero na modelu logicznym i fizycznym (SQL Server 2022).

```
projektowanie/
  zasady.md           zasady (konceptualny → logiczny → fizyczny)
  notacja-chena.md    ER Chena: symbole, liczność, encja słaba, mapowanie na tabele
```

SQL z przykładu Chena: [`sql/projektowanie/chen-na-tabele.sql`](../sql/projektowanie/chen-na-tabele.sql).

| Karta | Status | Po co |
|---|---|---|
| [Zasady projektowania](zasady.md) | `READY` | Checklist zanim otworzysz SSMS |
| [Notacja Chena](notacja-chena.md) | `READY` | Wspólny język na warsztacie modelu |

Dalej w katalogu: [normalizacja](../wzorce/modelowanie/normalizacja.md), [association table](../wzorce/modelowanie/association.md), [TPH/TPT](../wzorce/modelowanie/tph-tpt-tpct.md).
