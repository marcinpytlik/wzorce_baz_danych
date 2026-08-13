# Klucze

> Klucz mówi, **który wiersz to ten byt**. Surrogate identyfikuje wiersz; UNIQUE biznesowy identyfikuje fakt. Potrzebujesz obu.

| | |
|---|---|
| **Status** | `READY` |
| **Kiedy stosować** | Każda tabela; spór IDENTITY vs numer faktury vs GUID |
| **Kiedy unikać** | — |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../sql/projektowanie/klucze.sql) |

## Słownik

| Klucz | Znaczenie | W SQL Server |
|---|---|---|
| **Kandydacki** | Minimalny zbiór atrybutów, który zawsze wyróżnia encję | Kandydat na PK albo `UNIQUE` |
| **Główny (PK)** | Wybrany kandydat; cel FK | `PRIMARY KEY` (clustered domyślnie — decyzja fizyczna) |
| **Alternatywny** | Kandydat, który nie został PK | `UNIQUE` (`Email`, `Sku`, `NumerFaktury`) |
| **Obcy (FK)** | Kopia PK (lub UNIQUE) innej tabeli | `FOREIGN KEY` + [ON DELETE](on-delete.md) |
| **Częściowy** | Wyróżnik encji słabej *w ramach* właściciela | `Lp` w `PRIMARY KEY (ZamowienieId, Lp)` |
| **Naturalny** | Istnieje w świecie (NIP, ISBN, numer) | Często UNIQUE, rzadko PK gdy może się zmienić |
| **Surrogate** | Wymyślony przez bazę (`IDENTITY`, GUID, sekwencja) | PK techniczny |

Jedna tabela: **jeden PK**, zero-lub-wiele UNIQUE. Zero UNIQUE biznesowych = [brak unikalności](../antywzorce/brak-unikalnosci.md).

## Naturalny vs surrogate

| | Naturalny jako PK | Surrogate PK + UNIQUE naturalny |
|---|---|---|
| Czytelność | Wysoka | FK to „magiczne inty” |
| Zmiana w świecie | Koszmar kaskady FK | Zmieniasz UNIQUE, PK stoi |
| Stabilność | NIP się koryguje, ISBN bywa zły | `IDENTITY` się nie „poprawia” |
| Domyślnie w tym katalogu | Nie | Tak: PK surrogate, fakt w UNIQUE |

Wyjątek: tabela słownikowa o stabilnym kodzie (`PL`, `VAT23`) — kod **może** być PK. Patrz [lookup](lookup.md).

Encja słaba: tożsamość = PK właściciela + klucz częściowy. Surrogate `PozycjaId` wolno dodać obok, nie zamiast — [zasady](zasady.md) pkt 10, [Chen](notacja-chena.md).

## Jak wybrać PK fizycznie

- `INT IDENTITY` — domyślny OLTP, wąski clustered.
- `BIGINT IDENTITY` — gdy przekroczysz 2 mld (logi, eventy).
- `UNIQUEIDENTIFIER` — łączenie baz, klucze z klienta; nie `NEWID()` na clustered (fragmentacja). [Sekwencje](sekwencje.md).
- PK złożony `(TenantId, ZamowienieId)` — [shared schema](../wzorce/multi-tenant/shared-schema.md): tenant w kluczu i we FK.

Clustered index ≠ obowiązkowo PK. Często PK clustered na surrogate jest OK. Gdy clustered ma być `(Data, Id)` pod zakresami — PK może być nonclustered.

## Pułapki

- Sam `IDENTITY`, zero UNIQUE — dwa „te same” fakty.
- Naturalny PK, który biznes koryguje (literówka w NIP).
- FK do UNIQUE, które nie jest stabilne.
- `NULL` w kolumnie „klucza” — [nullable klucz](../antywzorce/nullable-klucz.md).
- GUID jako clustered + `NEWID()` na każdym INSERT.

## Powiązane

- [Sekwencje / IDENTITY / GUID](sekwencje.md)
- [ON DELETE](on-delete.md)
- [Lookup](lookup.md)
- [Notacja Chena](notacja-chena.md)
