# Sharding

> Podział danych na partycje (shardy) wg klucza, żeby jedna instancja nie była sufitem.

| | |
|---|---|
| **Kiedy stosować** | Rozmiar / IOPS / locki jednej bazy są realnym limitem; klucz podziału jest w prawie każdym zapytaniu |
| **Kiedy unikać** | „Na zapas”; zapytania regularnie tną w poprzek shardów; potrzebujesz TX między encjami z różnych kluczy |
| **Silniki** | PostgreSQL (partycje, Citus, ręczny routing), SQL Server (partycje, Elastic Scale, ręczny routing) |
| **SQL** | [Postgres](../../sql/postgres/skalowanie/sharding.sql) · [SQL Server](../../sql/sqlserver/skalowanie/sharding.sql) |

## Problem

Jedna baza nie wyrabia. Skalowanie w pionie ma cenę i sufit. Chcesz N mniejszych baz/partycji.

## Model

Najpierw rozróżnij:

| Mechanizm | Co to jest | Cross-partition |
|---|---|---|
| **Partycjonowanie** | Jedna instancja, wiele segmentów tabeli | JOIN i TX działają (z zastrzeżeniami planu) |
| **Sharding** | Wiele instancji, routing w aplikacji / proxy | JOIN i TX **nie** działają tanio |

Klucz sharda musi być w ścieżce gorącej: `TenantId`, `KlientId`, `ZamowienieId` (hash). Lookup „gdzie mieszka X” to mała tabela lub funkcja.

```text
ShardMap (KluczOd, KluczDo, ShardId, Connection)
Fakt (KluczSharda, ...)  -- każda instancja ma ten sam schemat
```

Partycjonowanie w jednej instancji (zakres dat, hash) to często **wystarczający** pierwszy krok zanim ruszysz sharding.

## Kluczowe ograniczenia

- Klucz sharda **w PK** (albo w leading columns), inaczej unique globalne jest kłamstwem.
- Unikalność globalna (`Email`) wymaga albo sharda po tym kluczu, albo osobnego serwisu / indeksu.
- Brak FK między shardami — integralność wraca do aplikacji i [outbox](../integracja/outbox.md).

## Operacje

Routing: `shard = hash(klucz) % N` albo zakres. Resharding (zmiana N) jest projektem, nie ALTER-em. Zapytania fan-out (wszystkie shardy) mają ogon najwolniejszego.

## Pułapki

- Shard po `ZamowienieId`, a listy „zamówienia klienta” tną wszystkie shardy.
- Hot shard (jeden tenant = 80% ruchu) — klucz był zły.
- „Distributed FK” i 2PC między bazami — wracasz do monolitu, tylko wolniej.

## Powiązane

- [CQRS](cqrs.md) — inny podział: zapis vs odczyt, nie tenant vs tenant
- [DB-per-tenant](../multi-tenant/db-per-tenant.md) — sharding po tenancie z izolacją
- [Saga](../integracja/saga.md) — gdy proces musi tknąć dwa shardy
