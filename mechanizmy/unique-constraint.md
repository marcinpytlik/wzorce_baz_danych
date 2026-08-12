# UNIQUE jako strażnik

> Unikalność biznesowa w indeksie, nie w `if exists` w aplikacji. Druga linia [idempotencji](../wzorce/wspolbieznosc/idempotencja.md), nie jej substytut.

| | |
|---|---|
| **Po co** | SKU, `(TenantId, Email)`, `(AgregatId, Wersja)` |
| **SQL** | [skrypt](../sql/mechanizmy/unique-constraint.sql) |

```sql
CONSTRAINT UQ_faktura UNIQUE (TenantId, Numer)
-- wyścig dwóch INSERT-ów: jeden 2627, drugi nie tworzy duplikatu
```

Filtrowany UNIQUE: patrz [filtered index](filtered-index.md). UNIQUE nie daje replay odpowiedzi HTTP — do tego tabela kluczy idempotency.

Używane przez: [idempotencja](../wzorce/wspolbieznosc/idempotencja.md), [event sourcing](../wzorce/historia/event-sourcing.md), [shared schema](../wzorce/multi-tenant/shared-schema.md).
