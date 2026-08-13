# Notacja Chena (ER)

> Model związków encji Petera Chena (1976): **prostokąt = byt, romb = związek, elipsa = atrybut**. To warstwa koncepcyjna — bez typów SQL i bez indeksów.

| | |
|---|---|
| **Status** | `READY` |
| **Kiedy stosować** | Warsztat modelu, spór o liczność, dokumentacja „co istnieje w świecie” |
| **Kiedy unikać** | Diagram fizyczny (filegroup, `NVARCHAR`) — do tego Crow’s Foot / SSMS, nie Chen |
| **Silnik** | SQL Server 2022 (dopiero przy [mapowaniu](#z-diagramu-na-tabele)) |
| **SQL** | [skrypt](../sql/projektowanie/chen-na-tabele.sql) |

Chen odpowiada na: *jakie rzeczy, jakie związki, jakie atrybuty, jaka liczność*. Nie odpowiada na: clustered index, `datetime2`, partycje.

## Legenda symboli

| Symbol | Znaczenie | Jak rysować |
|---|---|---|
| Prostokąt | **Encja** (zbiór bytów tego samego typu) | `KLIENT` |
| Podwójny prostokąt | **Encja słaba** — nie istnieje bez właściciela | `║ POZYCJA ║` |
| Romb | **Związek** między encjami | `◆ SKŁADA ◆` |
| Podwójny romb | **Związek identyfikujący** (właściciel → encja słaba) | `◆◆ ZAWIERA ◆◆` |
| Elipsa | **Atrybut** | `○ Nazwa` |
| Elipsa podkreślona / ★ | **Atrybut kluczowy** (wyróżnik encji) | `○ KlientId ★` |
| Podwójna elipsa | **Atrybut wielowartościowy** (zbiór, nie atom) | `◎ Telefon` |
| Elipsa z kreseczkami do podelips | **Atrybut złożony** | `Adres` → `Miasto`, `Ulica` |
| Elipsa przerywana | **Atrybut pochodny** (wyliczany) | `◌ Wiek` |
| Linia pojedyncza | **Uczestnictwo częściowe** (może nie brać udziału) | `│` |
| Linia podwójna | **Uczestnictwo całkowite** (musi brać udział) | `║` |
| `1` / `N` / `M` przy linii | **Liczność** (ile instancji po tej stronie) | `1` klient, `N` zamówień |

W wariantach (min, max) pisze się `(0,N)`, `(1,1)` zamiast samej cyfry — to samo, tylko jawny minimum.

## Jak czytać diagram

Zdanie z diagramu: *Klient składa N zamówień; każde zamówienie składa dokładnie jeden klient.*

```text
         ○ KlientId ★
         ○ Nazwa
         ○ Email
    ┌────────┴────────┐
    │     KLIENT      │
    └────────┬────────┘
             │ 1
             │          uczestnictwo częściowe
             │          (klient bez zamówień bywa OK)
        ┌────┴────┐
        │ SKŁADA  │
        └────┬────┘
             │ N
             ║          uczestnictwo całkowite
             ║          (zamówienie BEZ klienta nie istnieje)
    ┌────────┴────────┐
    │   ZAMÓWIENIE    │
    └────────┬────────┘
         ○ ZamowienieId ★
         ○ Data
```

Czytaj od rombu: nazwa związku to czasownik. Encje to rzeczowniki. Atrybuty wiszą na encji (albo na związku — patrz niżej), nie „gdzieś obok”.

## Liczność

Liczność mówi, **ile instancji** encji A łączy się z **jedną** instancją encji B (i odwrotnie).

| Związek | Chen | Znaczenie | W tabelach |
|---|---|---|---|
| **1 : 1** | `1` — ◆ — `1` | Co najwyżej jedna para | FK UNIQUE po jednej stronie |
| **1 : N** | `1` — ◆ — `N` | Rodzic ma wiele dzieci | FK po stronie N |
| **M : N** | `M` — ◆ — `N` | Obie strony wiele | Tabela związku ([association](../wzorce/modelowanie/association.md)) |

Przykład 1:N: jeden `KLIENT` składa wiele `ZAMÓWIENIE`.  
Przykład M:N: `ZAMÓWIENIE` zawiera wiele `PRODUKT`, produkt jest na wielu zamówieniach.

Nie zgaduj N. Jeśli biznes mówi „zamówienie ma jednego płatnika i może mieć innego odbiorcę” — to **dwa** związki 1:N (`płaci` / `odbiera`), nie jedna magiczna kolumna.

## Uczestnictwo (opcjonalność)

- **Częściowe** (linia pojedyncza): instancja encji *może* nie mieć związku. Klient bez zamówień.
- **Całkowite** (linia podwójna): instancja *musi* mieć związek. Zamówienie bez klienta jest bezsensem → w SQL `KlientId NOT NULL` + FK.

Liczność `1` to nie to samo co uczestnictwo całkowite. Bywa `1` z uczestnictwem częściowym (osoba *może* mieć jeden paszport, ale nie musi).

## Encja słaba i związek identyfikujący

Encja słaba **nie ma** własnego wyróżnika wystarczającego w świecie. `POZYCJA` nr 3 nic nie znaczy bez zamówienia.

```text
    ┌──────────────┐  1     ┌──────────┐     N    ╔════════════╗
    │  ZAMÓWIENIE  │════════◆◆ ZAWIERA ◆◆═════════║   POZYCJA  ║
    └──────────────┘        └──────────┘          ╚══════╤═════╝
                                                    ○ Lp ★  (klucz częściowy)
                                                    ○ Ilosc
```

- Prostokąt podwójny = słaba.
- Romb podwójny = związek **identyfikujący**.
- Klucz częściowy (`Lp`) + klucz właściciela (`ZamowienieId`) = tożsamość.
- Uczestnictwo słabej strony jest całkowite (podwójna linia).

W SQL: `PRIMARY KEY (ZamowienieId, Lp)`, FK do zamówienia, zwykle `ON DELETE CASCADE`. Surrogate `PozycjaId` wolno dodać **obok**, nie zamiast tej identyfikacji — patrz [zasady](zasady.md) pkt 10.

## Atrybut na związku

Gdy fakt należy do **pary**, nie do jednej encji: `Ilosc`, `CenaWMomencie` wiszą na `ZAWIERA`, nie na `PRODUKT` (cena bieżąca produktu to inny fakt).

```text
    ┌──────────────┐  M     ┌──────────┐     N    ┌─────────┐
    │  ZAMÓWIENIE  │────────◆  ZAWIERA  ◆─────────│ PRODUKT │
    └──────────────┘        └────┬─────┘          └─────────┘
                                 │
                            ○ Ilosc
                            ○ CenaWMomencie
```

Mapowanie M:N z atrybutami = tabela `Pozycja (ZamowienieId, ProduktId, Ilosc, CenaWMomencie)`. To nie denormalizacja: to ziarno związku.

## Atrybuty specjalne

| Rodzaj | Przykład | Mapowanie |
|---|---|---|
| Prosty | `Nazwa` | Kolumna |
| Złożony | `Adres(Miasto, Ulica)` | Kolumny składowe albo osobna encja, jeśli adres żyje samodzielnie |
| Wielowartościowy | `◎ Telefon` | Osobna tabela `(KlientId, Telefon)` — nie CSV |
| Pochodny | `◌ Wartosc = Ilosc × Cena` | Nie trzymać / [kolumna obliczana](kolumna-obliczana.md) / [indexed view](../wzorce/wydajnosc/indexed-view.md) |
| Kluczowy | `KlientId ★` | `PRIMARY KEY` albo UNIQUE kandydujący |

Wielowartościowy atrybut w Chenie **nie jest** 1NF. Na warstwie logicznej znika: staje się tabelą. Nie „naprawiaj” go `NVARCHAR` z przecinkami ([CSV](../antywzorce/csv-w-kolumnie.md)).

## Związek rekurencyjny

Ta sama encja po obu stronach rombu. Role na liniach: `przełożony` / `podwładny`.

```text
                    ┌────────────┐
            1       │ PRACOWNIK  │
         (szef)     └──────┬─────┘
                    ┌──────┴──────┐
                    │  NADZORUJE  │
                    └──────┬──────┘
                           │ N
                      (podwładny)
```

Mapowanie: `PrzelozonyId` NULLABLE FK do `Pracownik` — [adjacency list](../wzorce/hierarchie/adjacency-list.md). NULL u korzenia = uczestnictwo częściowe po stronie szefa.

## Specjalizacja (ISA)

`KONTRAHENT` jako nadtyp, `OSOBA` / `FIRMA` jako podtypy. W Chenie często trójkąt `ISA` albo związek `jest`. Na logicznej warstwie: [TPH / TPT / TPCT](../wzorce/modelowanie/tph-tpt-tpct.md), nie para `(Typ, Id)` bez FK.

## Związek trójargumentowy

Romb z **trzema** encjami (`DOSTAWCA` / `PROJEKT` / `CZĘŚĆ`). Nie rozbijaj automatycznie na trzy pary — stracisz fakt „ten dostawca na tym projekcie tę część”. Rozbijaj dopiero, gdy biznes naprawdę mówi o parach niezależnych.

## Z diagramu na tabele

Reguły (przykład w skrypcie):

| W Chenie | W SQL Server |
|---|---|
| Encja mocna | Tabela; atrybuty kluczowe → `PRIMARY KEY` |
| Encja słaba | Tabela; `PRIMARY KEY (PK_właściciela, klucz_częściowy)` + FK |
| Związek 1:N | FK po stronie N; `NOT NULL` przy uczestnictwie całkowitym |
| Związek 1:1 | FK UNIQUE; zwykle po stronie z uczestnictwem całkowitym |
| Związek M:N | Tabela asocjacji, PK para FK |
| Atrybuty związku | Kolumny tabeli związku / strony N |
| Atrybut wielowartościowy | Osobna tabela z FK |
| Atrybut pochodny | Pomijasz albo `AS` — [kolumna obliczana](kolumna-obliczana.md) |
| Uczestnictwo całkowite | `NOT NULL` + FK; nie „sprawdzimy w aplikacji” |

Pełny przykład (klient–składa–zamówienie–zawiera–produkt + telefony): [`sql/projektowanie/chen-na-tabele.sql`](../sql/projektowanie/chen-na-tabele.sql).

## Chen a inne notacje

| | Chen | Crow’s Foot | UML (klasa) |
|---|---|---|---|
| Warstwa | Koncepcyjna | Logiczna / fizyczna | Logiczna (aplikacja) |
| Związek | Romb z nazwą | Linia, „kurze łapki” | Asocjacja, nazwa na linii |
| Liczność | `1`, `N` przy linii | Łapka / kreska / kółko | `0..*`, `1` |
| Narzędzia | Tablica, dokument | SSMS, ER/Studio, draw.io | Narzędzia OO |
| Kiedy | Warsztat z biznesem | Dokument tabel, FK | Gdy model = obiekty |

W tym katalogu **Chen jest obowiązkowy na starcie**. Crow’s Foot dorysowujesz, gdy tabele już istnieją — karta: [Crow’s Foot](crows-foot.md). Nie odwrotnie.

## Pułapki

- Rysowanie tabel SQL w prostokątach Chena (`KlientId INT IDENTITY`) — to już warstwa fizyczna.
- M:N schowane jako kolumna albo JSON.
- Encja słaba z samym `Id IDENTITY` i bez klucza właściciela w tożsamości.
- Liczność `N` w obie strony, bo „na wszelki wypadek”.
- Dwa fakty w jednym rombie (`płaci i dostarcza`).
- Crow’s Foot nazwany Chenem, bo „też ER”.

Pełny przebieg (Chen → 3NF → soft delete / outbox / keyset): [case zamówienie](case/README.md).

## Powiązane

- [Zasady projektowania](zasady.md)
- [Crow’s Foot](crows-foot.md)
- [Klucze](klucze.md)
- [Kolumna obliczana](kolumna-obliczana.md)
- [Case: zamówienie](case/README.md)
- [Normalizacja](../wzorce/modelowanie/normalizacja.md)
- [Association table](../wzorce/modelowanie/association.md)
- [Adjacency list](../wzorce/hierarchie/adjacency-list.md)
- [TPH / TPT](../wzorce/modelowanie/tph-tpt-tpct.md)
