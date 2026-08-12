# Katalog wzorców bazodanowych

Mapa decyzji: **jaki model danych / jaki mechanizm SQL**, kiedy go brać, a kiedy odpuścić.

To nie jest system produkcyjny. Produkcja (kolejki, FCI, quorum, TLS) żyje we własnym repozytorium; stąd tylko **wzorzec** i przykładowy SQL. Z produkcji linkujemy konkretne karty (outbox, inbox, idempotencja) — kod zostaje tam, gdzie jest.

Silniki w przykładach: **PostgreSQL** i **SQL Server**.

```
wzorce/
  modelowanie/     normalizacja, EAV, STI, soft delete, tabele temporalne
  hierarchie/      adjacency, nested set, closure, materialized path
  skalowanie/      sharding, CQRS, widok zmaterializowany, cache
  integracja/      outbox, inbox, CDC, saga, idempotencja
  multi-tenant/    shared schema, RLS, schema-per-tenant, db-per-tenant
antywzorce/
sql/               skrypty Postgres / SQL Server do każdego wzorca
```

## Kiedy który wzorzec

### Modelowanie

| Wzorzec | Bierz gdy | Nie bierz gdy |
|---|---|---|
| [Normalizacja](wzorce/modelowanie/normalizacja.md) | Integralność, jeden fakt w jednym miejscu, OLTP | Raporty „na żywca” z 12 JOIN-ów; wtedy denormalizuj **świadomie** (widok zmaterializowany, read model) |
| [EAV](wzorce/modelowanie/eav.md) | Naprawdę otwarty zestaw atrybutów, rzadkie filtry po wartościach | Katalog produktów, ustawienia, „żeby było elastycznie” — to [antywzorzec](antywzorce/eav-na-wszystko.md) |
| [STI / dziedziczenie tabel](wzorce/modelowanie/sti.md) | Wspólne zapytania po hierarchii typów, podobny zestaw kolumn | Typy rozjeżdżają się schematem — Class Table Inheritance albo osobne tabele |
| [Soft delete](wzorce/modelowanie/soft-delete.md) | Odzyskiwanie, audyt „co zniknęło”, FK które nie mogą wisieć w powietrzu | Compliance wymaga twardego usunięcia; albo tabela jest gorąca i `IsDeleted` psuje indeksy |
| [Tabele temporalne](wzorce/modelowanie/temporal.md) | Historia stanów, „jak było o 14:07”, bitemporalność | Potrzebujesz tylko logu zdarzeń — event store / CDC, nie kopia wiersza przy każdym UPDATE |

### Hierarchie

| Wzorzec | Bierz gdy | Nie bierz gdy |
|---|---|---|
| [Adjacency list](wzorce/hierarchie/adjacency-list.md) | Płytkie drzewo, głównie rodzic↔dzieci | Częste „cała gałąź” / „ścieżka do korzenia” na dużym zbiorze bez CTE/rekurencji pod kontrolą |
| [Nested set](wzorce/hierarchie/nested-set.md) | Dużo odczytów poddrzewa, rzadkie przesunięcia | Częste INSERT/MOVE — przerysowujesz `lft`/`rgt` |
| [Closure table](wzorce/hierarchie/closure-table.md) | Mix odczytów (przodkowie, potomkowie, głębokość) i umiarkowanych zapisów | Ogromne, szerokie drzewa — tabela domknięć rośnie kwadratowo w najgorszym razie |
| [Materialized path](wzorce/hierarchie/materialized-path.md) | LIKE/ltree, prosta ścieżka w UI, Postgres `ltree` | Częste zmiany rodzica w środku drzewa; SQL Server bez `hierarchyid` robi się kruchy |

### Skalowanie

| Wzorzec | Bierz gdy | Nie bierz gdy |
|---|---|---|
| [Sharding](wzorce/skalowanie/sharding.md) | Pojedyncza baza nie mieści się w IOPS/rozmiarze, klucz podziału jest oczywisty | „Na zapas”; cross-shard JOIN i transakcje zjedzą zysk |
| [CQRS](wzorce/skalowanie/cqrs.md) | Model zapisu ≠ model odczytu, różne SLO | Prosty CRUD — dublujesz złożoność bez potrzeby |
| [Widok zmaterializowany](wzorce/skalowanie/materialized-view.md) | Ciężka agregacja, opóźnienie sekundy–minuty OK | Wymagasz odczytu w tej samej transakcji co zapis |
| [Cache](wzorce/skalowanie/cache.md) | Gorące klucze, powtarzalne odczyty, TTL akceptowalny | Dane muszą być zawsze spójne z zapisem (albo cache-aside bez invalidacji) |

### Integracja

| Wzorzec | Bierz gdy | Nie bierz gdy |
|---|---|---|
| [Outbox](wzorce/integracja/outbox.md) | Zapis stanu **i** komunikat muszą być atomowe | Fire-and-forget do brokera w osobnym round-trip po COMMIT — zgubisz zdarzenie |
| [Inbox](wzorce/integracja/inbox.md) | Konsument może dostać duplikat (at-least-once) | Zakładasz at-most-once i nie masz idempotencji |
| [CDC](wzorce/integracja/cdc.md) | Odczyt zmian bez ruszania aplikacji, replika, audyt | Potrzebujesz **semantyki biznesowej** zdarzenia — CDC da wiersz, nie intencję |
| [Saga](wzorce/integracja/saga.md) | Długi proces, wiele zasobów, brak dystrybuowanej TX | Jedna baza, jedna transakcja wystarczy |
| [Idempotencja](wzorce/integracja/idempotencja.md) | Retry, duplikaty, klucze idempotency z API | „UNIQUE na wszystko” bez okna czasowego i bez obsługi wyścigu |

### Multi-tenant

| Wzorzec | Bierz gdy | Nie bierz gdy |
|---|---|---|
| [Shared schema](wzorce/multi-tenant/shared-schema.md) | Dużo małych tenantów, jeden deploy | Silna izolacja regulacyjna, bardzo nierówny rozmiar tenantów |
| [RLS](wzorce/multi-tenant/rls.md) | Shared schema + wymuszenie izolacji **w silniku**, nie tylko w aplikacji | Aplikacja łączy się jako `sa` / superuser i omija polityki |
| [Schema-per-tenant](wzorce/multi-tenant/schema-per-tenant.md) | Średnia liczba tenantów, chcesz izolacji bez N instancji | Tysiące schematów — migracje i planer zabolą |
| [DB-per-tenant](wzorce/multi-tenant/db-per-tenant.md) | Duży tenant, restore per klient, osobne SLO | Koszt operacyjny N baz przy setkach drobnych klientów |

## Antywzorce

Szybka lista „nie tędy” — pełne karty w [`antywzorce/`](antywzorce/README.md):

- [EAV na wszystko](antywzorce/eav-na-wszystko.md)
- [Tabela-bóg](antywzorce/tabela-bog.md)
- [CSV / JSON bez kontraktu w kolumnie relacyjnej](antywzorce/csv-w-kolumnie.md)
- [Polimorficzny FK](antywzorce/polimorficzny-fk.md)
- [Brak unikalności biznesowej](antywzorce/brak-unikalnosci.md)
- [Nullable „klucz”](antywzorce/nullable-klucz.md)

## SQL

Przykłady: [`sql/postgres/`](sql/postgres/) i [`sql/sqlserver/`](sql/sqlserver/). Jak odpalać: [`sql/README.md`](sql/README.md).

## Zasada katalogu

1. Wzorzec = karta (problem, kiedy, model, pułapki) + dwa skrypty SQL.
2. Produkcja linkuje kartę, nie odwrotnie — tu nie wciągamy kodu systemów.
3. Nowy wpis: skopiuj [`wzorce/_szablon.md`](wzorce/_szablon.md).
