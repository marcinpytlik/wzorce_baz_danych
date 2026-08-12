# STI i dziedziczenie tabel

> Hierarchia typów w relacjach: jedna tabela (STI) albo rozbicie na tabele klas.

| | |
|---|---|
| **Kiedy stosować** | Wspólne zapytania po wszystkich podtypach, 80% kolumn wspólnych |
| **Kiedy unikać** | Podtypy mają zupełnie inny schemat albo twarde UNIQUE/FK różne per typ |
| **Silniki** | PostgreSQL (w tym `INHERITS` — ostrożnie), SQL Server (jedna tabela + `discriminator`) |
| **SQL** | [Postgres](../../sql/postgres/modelowanie/sti.sql) · [SQL Server](../../sql/sqlserver/modelowanie/sti.sql) |

## Problem

`Zdarzenie`, `Zadanie`, `Notatka` to „pozycje na osi czasu”, ale każde ma inne pola. Albo `OsobaFizyczna` / `Firma` pod wspólnym `Kontrahent`.

## Model

Trzy klasyczne warianty:

| Wariant | Tabele | Zaleta | Koszt |
|---|---|---|---|
| **STI** (single table) | Jedna + kolumna `Typ` | Proste zapytania, jeden PK | Nullable kolumny podtypów, szeroki wiersz |
| **CTI** (class table) | Bazowa + 1:1 per podtyp | Czyste NOT NULL per typ | JOIN przy każdym odczycie pełnym |
| **Concrete table** | Osobna tabela per liść | Brak nulli, osobne indeksy | UNION do zapytania „wszystkie”, rozjechane PK |

```text
-- STI
Pozycja (Id, Typ, Tytul, ...pola wspólne..., Kwota NULL, Termin NULL)

-- CTI
Pozycja (Id, Typ, Tytul)
Zadanie (Id → Pozycja, Termin)
Wydatek (Id → Pozycja, Kwota)
```

Na Postgresie `INHERITS` **nie** kopiuje UNIQUE/PK na dzieci tak, jak myślisz — nie używaj tego jako substytutu CTI bez przeczytania dokumentacji.

## Kluczowe ograniczenia

- `Typ` jako `CHECK` / enum, nie wolny tekst.
- CHECK: jeśli `Typ = 'Zadanie'` to `Termin IS NOT NULL` (STI).
- CTI: PK dziecka = FK do bazy (`ON DELETE CASCADE`).

## Operacje

Listy mieszane: STI wygrywa. Formularz konkretnego typu: CTI wygrywa (NOT NULL). Unikaj trzeciego wariantu, jeśli UI i tak pokazuje wspólną listę.

## Pułapki

- STI z 40 kolumnami nullable i jednym indeksem na `Typ` — martwy ładunek.
- Dwa podtypy z tym samym UNIQUE biznesowym w CTI bez unikalności w tabeli bazowej.
- `Typ` w aplikacji, bez CHECK w bazie → śmieci.

## Powiązane

- [EAV](eav.md) — gdy podtypów nie da się zamknąć listą
- [Normalizacja](normalizacja.md)
