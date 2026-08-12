# Cache (przy bazie)

> Kopia gorących odczytów z TTL albo jawną invalidacją. Baza nie jest Redisem, ale bywa warstwą cache.

| | |
|---|---|
| **Kiedy stosować** | Powtarzalny odczyt, dopuszczalny stale, klucz znany z góry |
| **Kiedy unikać** | Każdy odczyt musi być current; nie masz strategii invalidacji |
| **Silniki** | PostgreSQL, SQL Server; często Redis/od strony aplikacji obok |
| **SQL** | [Postgres](../../sql/postgres/skalowanie/cache.sql) · [SQL Server](../../sql/sqlserver/skalowanie/cache.sql) |

## Problem

Ten sam `GET /produkt/123` wali w JOIN 200 razy na sekundę. Wynik zmienia się rzadko.

## Model

Trzy strategie (niezależnie od tego, czy cache to tabela, Memory-Optimized, czy Redis):

| Strategia | Zapis | Odczyt | Ryzyko |
|---|---|---|---|
| **Cache-aside** | Aplikacja invaliduje / nadpisuje po zapisie | Miss → DB → fill | Wyścig fill vs update |
| **Write-through** | Zapis do DB i cache w jednej ścieżce | Zawsze cache | Cache i DB muszą mieć ten sam kontrakt niepowodzenia |
| **TTL** | Nic | Po prostu wygasa | Stale do końca TTL |

W SQL: tabela `CacheProdukt (Id, Payload, WygasaAt)` albo SQL Server Memory-Optimized / columnstore do snapshotów. To nadal cache — nie źródło prawdy.

Dla jednej instancji często wystarczy [widok zmaterializowany](materialized-view.md). Cache ma sens, gdy TTL jest krótki, klucz jest punktowy, albo warstwa jest poza bazą.

## Kluczowe ograniczenia

- PK = klucz cache.
- `WygasaAt` + job czyszczący (albo `WHERE WygasaAt > now()` na odczycie).
- Wersja / `ETag` jeśli chcesz uniknąć stampede (jeden fill).

## Operacje

Get: hit / miss. Set: upsert. Invalidate: DELETE po kluczu albo prefiksie (tu SQL jest słabszy niż Redis). Stampede: lock poradniczy (`pg_advisory_lock`, `sp_getapplock`) wokół fill.

## Pułapki

- Cache bez invalidacji po UPDATE — cichy stale.
- Trzymanie w cache wyników, które zależą od uprawnień tenanta, bez `TenantId` w kluczu.
- Memory-Optimized jako „szybsza tabela faktów” bez zrozumienia durability (`SCHEMA_ONLY` ginie po restarcie).

## Powiązane

- [Widok zmaterializowany](materialized-view.md)
- [CQRS](cqrs.md)
- [RLS](../multi-tenant/rls.md) — klucz cache musi zawierać tenant
