# Katalog wzorców bazodanowych

Mapa decyzji: **jaki model / jaki mechanizm SQL**, kiedy go brać, a kiedy odpuścić.

Silnik: **SQL Server 2022**. Skrypty w [`sql/`](sql/) — jeden plik na kartę, katalogi jak w `wzorce/`.

Status karty:

| Znacznik | Znaczenie |
|---|---|
| `READY` | Karta + SQL, można stosować jako kontrakt |
| `STARTER` | Model i pułapki są, SQL jest szkicem |
| `ADVANCED` | Świadomy koszt operacyjny; nie bierz „na zapas” |

Aliasów nie mnożymy: TPH/TPT/TPCT to jedna karta, EMC połyka shadow column / backfill / compatibility view, saga połyka kompensację.

```
wzorce/
  ewolucja/         Expand–Migrate–Contract, blue-green
  modelowanie/      normalizacja, EAV, TPH/TPT/TPCT, party, association
  hierarchie/       adjacency, nested set, closure, materialized path
  historia/         audit, temporal, effective dating, SCD, append-only, event sourcing
  usuwanie/         hard/soft delete, tombstone, archive, retention, partition switch
  wspolbieznosc/    optimistic/pessimistic, app lock, idempotencja, serializacja kolejką
  integracja/       outbox, inbox, CDC, saga, ownership, ACL
  wydajnosc/        partycje, hot/cold, CQRS, indexed view, cache, keyset, shard, replica, queue table
  multi-tenant/     shared schema, RLS, schema-per-tenant, db-per-tenant
  bezpieczenstwo/   least privilege, masking, szyfrowanie, module signing, ledger
antywzorce/
mechanizmy/         covering/filtered index, CHECK, UNIQUE, EXECUTE AS, chaining
```

## Kiedy który wzorzec

### Ewolucja schematu

| Wzorzec | Status | Bierz gdy | Nie bierz gdy |
|---|---|---|---|
| [Expand–Migrate–Contract](wzorce/ewolucja/expand-migrate-contract.md) | `READY` | Zero-downtime, stara i nowa aplikacja muszą współistnieć | Jedyna instancja, możesz wziąć okno i przerobić w miejscu |
| [Blue-green bazy](wzorce/ewolucja/blue-green.md) | `STARTER` | Cutover całego środowiska, szybki rollback synonym/DNS | Zmiana jest jedną kolumną — wystarczy EMC |

Taktyki wewnątrz EMC (nie osobne karty): shadow column, backfill w batchach, compatibility view, parallel table, feature flag na schemacie.

**Nie bierz:** [dual write](antywzorce/dual-write.md) między bazą a brokerem / drugą bazą.

### Modelowanie

| Wzorzec | Status | Bierz gdy | Nie bierz gdy |
|---|---|---|---|
| [Normalizacja](wzorce/modelowanie/normalizacja.md) | `READY` | OLTP, jeden fakt w jednym miejscu | Ciężki ekran — denormalizuj odczyt ([indexed view](wzorce/wydajnosc/indexed-view.md), [CQRS](wzorce/wydajnosc/cqrs.md)) |
| [EAV](wzorce/modelowanie/eav.md) | `STARTER` | Naprawdę otwarte atrybuty, rzadki filtr po wartości | Stabilny model — to [EAV na wszystko](antywzorce/eav-na-wszystko.md) |
| [TPH / TPT / TPCT](wzorce/modelowanie/tph-tpt-tpct.md) | `READY` | Hierarchia typów (jedna tabela, 1:1, albo liście) | Udajesz hierarchię parą `(Typ, Id)` — to [polimorficzny FK](antywzorce/polimorficzny-fk.md) |
| [Association table](wzorce/modelowanie/association.md) | `STARTER` | N:N z prawdziwym FK | CSV w kolumnie, polimorficzny FK |
| [Party](wzorce/modelowanie/party.md) | `STARTER` | Osoba, firma i rola to osobne fakty | Jeden `Klient` z 40 nullable kolumnami |

### Hierarchie

| Wzorzec | Status | Bierz gdy | Nie bierz gdy |
|---|---|---|---|
| [Adjacency list](wzorce/hierarchie/adjacency-list.md) | `READY` | Płytkie drzewo, rodzic↔dzieci | Częste poddrzewo na szerokim zbiorze |
| [Nested set](wzorce/hierarchie/nested-set.md) | `STARTER` | Dużo odczytów poddrzewa, rzadki MOVE | Częsty INSERT w środku drzewa |
| [Closure table](wzorce/hierarchie/closure-table.md) | `READY` | Przodkowie, potomkowie, głębokość bez rekurencji | Ogromne drzewa z częstym MOVE |
| [Materialized path](wzorce/hierarchie/materialized-path.md) | `READY` | Breadcrumb, `hierarchyid` | Ścieżka z nazw zamiast id |

### Historia i audyt

| Wzorzec | Status | Bierz gdy | Nie bierz gdy |
|---|---|---|---|
| [Audit trail](wzorce/historia/audit-trail.md) | `STARTER` | Kto / kiedy / co zmienił (zdarzenie audytowe) | Potrzebujesz as-of stanu wiersza — [temporal](wzorce/historia/temporal.md) |
| [Tabele temporalne](wzorce/historia/temporal.md) | `READY` | System time, `FOR SYSTEM_TIME AS OF` | Intencja biznesowa — [outbox](wzorce/integracja/outbox.md) / [ES](wzorce/historia/event-sourcing.md) |
| [Effective dating](wzorce/historia/effective-dating.md) | `STARTER` | Valid time w świecie (umowa od–do) | Mieszasz z system time w jednej parze dat |
| [SCD](wzorce/historia/scd.md) | `STARTER` | Wymiar w hurtowni: nadpisz (T1) albo wersjonuj (T2) | OLTP z temporal — nie duplikuj SCD2 „bo Kimball” |
| [Append-only](wzorce/historia/append-only.md) | `STARTER` | Faktów się nie poprawia, tylko dopisuje | Musisz poprawiać w miejscu i nie masz korekty jako nowego zdarzenia |
| [Event sourcing](wzorce/historia/event-sourcing.md) | `ADVANCED` | Log zdarzeń jest źródłem prawdy | Chcesz tylko historię UPDATE — temporal / audit |

Snapshot jest taktyką przy ES i przy [CQRS](wzorce/wydajnosc/cqrs.md), nie osobnym wzorcem.

### Usuwanie i retencja

| Wzorzec | Status | Bierz gdy | Nie bierz gdy |
|---|---|---|---|
| [Hard delete](wzorce/usuwanie/hard-delete.md) | `STARTER` | RODO / fakt ma zniknąć, FK ogarnięte | Kasujesz, bo UI ma przycisk — bez audytu i retencji |
| [Soft delete](wzorce/usuwanie/soft-delete.md) | `READY` | Odzyskiwanie, unikalność tylko na żywych (indeks filtrowany) | Tabela gorąca, `IsDeleted` psuje plany; brak purge |
| [Tombstone](wzorce/usuwanie/tombstone.md) | `STARTER` | Replika / cache musi wiedzieć, że klucz zniknął | Zostawiasz cały wiersz „na wieczność” |
| [Archive then delete](wzorce/usuwanie/archive-then-delete.md) | `STARTER` | Najpierw zimna kopia, potem twarde usunięcie | Archiwum w tej samej gorącej tabeli |
| [Retention](wzorce/usuwanie/retention.md) | `STARTER` | Polityka „N dni / N lat” jako job, nie nadzieja | Różne reguły per tabela bez właściciela |
| [Partition switching (purge)](wzorce/usuwanie/partition-switching-purge.md) | `STARTER` | Skasować miesiąc w metadanych, nie wiersz po wierszu | Tabela nie jest partycjonowana po dacie retencji |

### Współbieżność i integralność

| Wzorzec | Status | Bierz gdy | Nie bierz gdy |
|---|---|---|---|
| [Optimistic concurrency](wzorce/wspolbieznosc/optimistic-concurrency.md) | `READY` | Rzadki konflikt, `rowversion` / CAS | Gorąca kasa — dwa UPDATE-y tego samego salda co chwila |
| [Pessimistic concurrency](wzorce/wspolbieznosc/pessimistic-concurrency.md) | `STARTER` | Musisz trzymać wiersz do końca TX | Trzymasz lock przez HTTP round-trip |
| [Application lock](wzorce/wspolbieznosc/application-lock.md) | `READY` | Krytyczna sekcja nie jest jednym wierszem (`sp_getapplock`) | Zamiast UNIQUE / wersji na wierszu |
| [Idempotencja](wzorce/wspolbieznosc/idempotencja.md) | `READY` | Retry, duplikat komunikatu, `Idempotency-Key` | Sam UNIQUE „jakoś wystarczy” bez replay i okna `WToku` |
| [Serializacja kolejką](wzorce/wspolbieznosc/queue-serialization.md) | `STARTER` | Kolejność per klucz (konto, dokument) | Globalna kolejka na cały system |

UNIQUE i CHECK jako strażnicy domeny: [`mechanizmy/`](mechanizmy/README.md).

### Integracja

| Wzorzec | Status | Bierz gdy | Nie bierz gdy |
|---|---|---|---|
| [Outbox](wzorce/integracja/outbox.md) | `READY` | Stan i komunikat w jednej TX | Drugi round-trip do brokera po COMMIT |
| [Inbox](wzorce/integracja/inbox.md) | `READY` | Konsument at-least-once | Inbox w pamięci procesu |
| [CDC](wzorce/integracja/cdc.md) | `STARTER` | Zmiany z logu, bez ruszania zapisu (CDC / CT / polling) | Semantyka biznesowa zdarzenia |
| [Saga](wzorce/integracja/saga.md) | `ADVANCED` | Długi proces, wiele zasobów; kompensacja w środku | Jedna baza, jedna TX |
| [Data ownership](wzorce/integracja/data-ownership.md) | `STARTER` | Serwis jest jedynym pisarzem swojej tabeli | Każdy UPDATE-uje „wspólną” bazę |
| [Database per service](wzorce/integracja/database-per-service.md) | `ADVANCED` | Twarda granica deployu i awarii | Dwa serwisy, jedna baza „na razie” |
| [Anti-corruption layer](wzorce/integracja/anti-corruption-layer.md) | `STARTER` | Obcy model nie wlewa się do Twojego schematu | Mapujesz 1:1 kolumnę w kolumnę i udajesz, że to ACL |

**Nie bierz:** [współdzielona baza między serwisami](antywzorce/shared-database.md).

### Wydajność i skala

| Wzorzec | Status | Bierz gdy | Nie bierz gdy |
|---|---|---|---|
| [Partycjonowanie](wzorce/wydajnosc/partitioning.md) | `STARTER` | Jedna instancja, sliding window, purge | Myślisz, że to sharding |
| [Hot / cold](wzorce/wydajnosc/hot-cold.md) | `STARTER` | Gorący ogon, zimna historia | Wszystko w jednym filegroup „bo prościej” |
| [CQRS / read model](wzorce/wydajnosc/cqrs.md) | `STARTER` | Inny kształt zapisu i odczytu | Prosty CRUD |
| [Indexed view](wzorce/wydajnosc/indexed-view.md) | `STARTER` | Agregacja utrzymywana przy DML | OUTER JOIN / OR — indexed view nie przejdzie |
| [Cache](wzorce/wydajnosc/cache.md) | `STARTER` | Gorący klucz, TTL OK | Brak invalidacji |
| [Keyset pagination](wzorce/wydajnosc/keyset-pagination.md) | `READY` | Kolejna strona po kluczu, nie `OFFSET` | Losowy skok na stronę 5000 z OFFSET |
| [Write sharding](wzorce/wydajnosc/sharding.md) | `ADVANCED` | Zapis nie mieści się w jednej instancji | Cross-shard JOIN w requestcie |
| [Read replicas](wzorce/wydajnosc/read-replicas.md) | `ADVANCED` | Skala odczytu, stale OK | Zapis na replikę albo read-your-writes bez sticky |
| [Queue table](wzorce/wydajnosc/queue-table.md) | `STARTER` | Praca asynchroniczna w SQL (`READPAST`) | To nie jest outbox (outbox emituje na zewnątrz) |

Covering / filtered index: [`mechanizmy/`](mechanizmy/README.md).

### Multi-tenant

| Wzorzec | Status | Bierz gdy | Nie bierz gdy |
|---|---|---|---|
| [Shared schema](wzorce/multi-tenant/shared-schema.md) | `READY` | Dużo małych tenantów, `TenantId` w PK i FK | Regulacja wymaga fizycznej izolacji |
| [RLS](wzorce/multi-tenant/rls.md) | `READY` | Izolacja w silniku, nie tylko w LINQ | Połączenie jako `sa` / `dbo` |
| [Schema-per-tenant](wzorce/multi-tenant/schema-per-tenant.md) | `STARTER` | Dziesiątki–setki tenantów | Tysiące schematów |
| [DB-per-tenant](wzorce/multi-tenant/db-per-tenant.md) | `ADVANCED` | Duży / regulowany klient, restore per baza | Setki drobnych baz bez automatu |

### Bezpieczeństwo

| Wzorzec | Status | Bierz gdy | Nie bierz gdy |
|---|---|---|---|
| [Least privilege](wzorce/bezpieczenstwo/least-privilege.md) | `STARTER` | Osobne konto migracji i runtime | Aplikacja jako `sysadmin` |
| [Dynamic Data Masking](wzorce/bezpieczenstwo/dynamic-data-masking.md) | `STARTER` | Ukryć PII przed rolą czytającą | Maskowanie zamiast uprawnień / szyfrowania |
| [Szyfrowanie kolumn](wzorce/bezpieczenstwo/column-encryption.md) | `STARTER` | Always Encrypted / envelope na sekrety | Szyfrujesz wszystko i filtrujesz po ciphertext |
| [Module signing](wzorce/bezpieczenstwo/module-signing.md) | `READY` | Procedura z podpisem zamiast `sa` w aplikacji | `EXECUTE AS OWNER` na stałe, bez podpisu i bez kontroli |
| [Niemutowalny audyt](wzorce/bezpieczenstwo/immutable-audit.md) | `STARTER` | Ledger SQL Server 2022, append-only | Trigger „nie ruszaj” bez ochrony przed dbo |

EXECUTE AS, ownership chaining, security definer: [`mechanizmy/`](mechanizmy/README.md). RLS: karta w [multi-tenant](wzorce/multi-tenant/rls.md).

## Antywzorce

Pełne karty: [`antywzorce/`](antywzorce/README.md).

- [Dual write](antywzorce/dual-write.md)
- [Współdzielona baza między serwisami](antywzorce/shared-database.md)
- [EAV na wszystko](antywzorce/eav-na-wszystko.md)
- [Tabela-bóg](antywzorce/tabela-bog.md)
- [CSV / JSON bez kontraktu](antywzorce/csv-w-kolumnie.md)
- [Polimorficzny FK](antywzorce/polimorficzny-fk.md)
- [Brak unikalności biznesowej](antywzorce/brak-unikalnosci.md)
- [Nullable „klucz”](antywzorce/nullable-klucz.md)

## Mechanizmy SQL

Krótkie karty narzędzi, nie decyzji domenowych: [`mechanizmy/`](mechanizmy/README.md).

## Zasada katalogu

1. Wzorzec = karta (problem, kiedy, model, pułapki) + skrypt SQL Server 2022.
2. Alias → jedna karta, taktyka → sekcja, mechanizm silnika → `mechanizmy/`.
3. Nowy wpis: [`wzorce/_szablon.md`](wzorce/_szablon.md).
