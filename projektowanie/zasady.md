# Zasady projektowania baz danych

> Najpierw znaczenie wiersza i integralność, potem indeksy. Diagram koncepcyjny: [notacja Chena](notacja-chena.md).

| | |
|---|---|
| **Status** | `READY` |
| **Kiedy stosować** | Nowy model, przebudowa, spór „czy to kolumna, czy tabela” |
| **Kiedy unikać** | — (to nie jest wzorzec do odpuszczenia; pomijasz je świadomie, z zapisem dlaczego) |
| **Silnik** | SQL Server 2022 |
| **SQL** | [mapowanie przykładu Chen](../sql/projektowanie/chen-na-tabele.sql) |

## Trzy warstwy (w tej kolejności)

| Warstwa | Pytanie | Artefakt |
|---|---|---|
| **Konceptualna** | Jakie byty i związki w świecie? | Diagram ER ([Chen](notacja-chena.md)) |
| **Logiczna** | Jakie relacje, klucze, NF, liczność? | Tabele, PK/FK, UNIQUE, CHECK — bez filegroupów |
| **Fizyczna** | Jak to stoi na SQL Server 2022? | Typy, indeksy, partycje, RLS, filegroup |

Nie projektuj indeksów, zanim nie umiesz powiedzieć, **co oznacza jeden wiersz**. Nie mieszaj warstw na jednym rysunku (Chen z `NVARCHAR(200)` i `IX_…` to już nie Chen).

## Zasady

### 1. Modeluj świat, nie ekran

Formularz „Nowe zamówienie” ma klienta, 15 pozycji i checkbox. To nie jest jedna tabela. Encje biorą się z faktów biznesowych, nie z siatki UI.

### 2. Jeden fakt, jedno miejsce

Atrybut zależy od klucza, nie od sąsiada. Powtórzona `NazwaKlienta` na zamówieniu jest albo **snapshotem** (fakt historyczny — nazwij go tak), albo kopią do rozjazdu. Szczegóły: [normalizacja](../wzorce/modelowanie/normalizacja.md).

### 3. Wiersz ma ziarno (grain)

Jedno zdanie: „wiersz w `Pozycja` = jedna linia jednego zamówienia na jeden produkt”. Jeśli nie umiesz tego powiedzieć, tabela zmieni znaczenie przy pierwszym reporcie.

### 4. Klucz biznesowy i klucz techniczny to dwa byty

`IDENTITY` / `UNIQUEIDENTIFIER` identyfikuje wiersz. Nie zastępuje UNIQUE na `(TenantId, NumerFaktury)`. Bez tego: [brak unikalności](../antywzorce/brak-unikalnosci.md).

### 5. Integralność w silniku

PK, FK, UNIQUE, CHECK, [RLS](../wzorce/multi-tenant/rls.md) — aplikacja kłamie, baza nie. „Sprawdzimy w kodzie” ginie przy jobie, Excelu i drugim serwisie.

Trzy integralności klasyczne:

| Rodzaj | Znaczenie | W SQL Server |
|---|---|---|
| Encji | Wiersz jest identyfikowalny | `PRIMARY KEY`, `NOT NULL` na kluczu |
| Odniesienia | FK wskazuje istniejący rodzic | `FOREIGN KEY` + jawne `ON DELETE` |
| Dziedziny | Wartość z dozwolonego zbioru | `CHECK`, `UNIQUE`, typy, słownik |

### 6. NULL to trzeci stan

`KlientId NULL` to nie „gość”. To „nie wiadomo / nie dotyczy / brak”. Każdy NULL nazwij albo wyeliminuj ([nullable klucz](../antywzorce/nullable-klucz.md)).

### 7. Liczność i opcjonalność zapisujesz, nie zgadujesz

`Klient składa 0..N zamówień`; `Zamówienie należy do dokładnie 1 klienta`. To jest Chen i potem FK `NOT NULL`. Zmiana 1:N na M:N to nowa tabela, nie „dodamy kolumnę”.

### 8. Nazwa jest częścią schematu

`Dane`, `Tabela1`, `Pole3` — nie wiadomo, co chronić UNIQUE. Encja = rzeczownik w liczbie pojedynczej albo ustalony plural; związek = czasownik (`Sklada`, `Zawiera`).

### 9. Związek M:N nie jest kolumną

CSV, JSON „na tagi”, para `(Typ, Id)` bez FK — [antywzorce](../antywzorce/README.md). Związek z atrybutami (`Ilosc`) to [association table](../wzorce/modelowanie/association.md).

### 10. Encja słaba nie dostaje sztucznego życia

`Pozycja` bez `ZamowienieId` nie istnieje. PK zawiera klucz właściciela. Nie „naprawiaj” tego samym `PozycjaId IDENTITY` *zamiast* identyfikacji — surrogate może być *obok*, nie zamiast.

### 11. Fizyka nie udaje modelu

Partycja, covering index, cache — przyspieszają **znany** predykat. Nie zmieniają tego, co jest encją. Najpierw Chen i 3NF, potem [mechanizmy](../mechanizmy/README.md).

### 12. Bezpieczeństwo i tenant są w modelu

`TenantId` w PK i FK albo osobna baza — decyzja na warstwie logicznej, nie „dodamy filtr w LINQ”. Patrz [shared schema](../wzorce/multi-tenant/shared-schema.md).

### 13. Projektuj zmianę, nie wróżenie

Kolejna kolumna: [EMC](../wzorce/ewolucja/expand-migrate-contract.md). Nie sharduj „na zapas”. Nie EAV „żeby było elastycznie”.

### 14. Dokument, którego nie ma w bazie, nie obowiązuje

Licznosci, znaczenia NULL, snapshot vs kopia — albo CHECK/komentarz tabeli/karta wzorca, albo zginą w wiki.

## Kolejność pracy

1. Encje, związki, atrybuty, klucze — [Chen](notacja-chena.md).
2. Mapowanie na relacje (karta Chena, sekcja mapowania).
3. 3NF / BCNF; świadoma denormalizacja odczytu dopiero z uzasadnieniem.
4. Fizyka SQL Server: typy, indeksy pod zapytania, tenancy, retencja.

## Powiązane

- [Notacja Chena](notacja-chena.md)
- [Normalizacja](../wzorce/modelowanie/normalizacja.md)
- [Association table](../wzorce/modelowanie/association.md)
- [Tabela-bóg](../antywzorce/tabela-bog.md)
