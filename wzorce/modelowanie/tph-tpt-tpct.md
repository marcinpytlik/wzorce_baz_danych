# TPH / TPT / TPCT

> Hierarchia typów w relacjach: jedna tabela, tabela na klasę albo tabela na liść. STI/CTI to te same trzy warianty pod innymi nazwami.

| | |
|---|---|
| **Status** | `READY` |
| **Kiedy stosować** | Wspólne zapytania po podtypach albo twardy NOT NULL per typ |
| **Kiedy unikać** | Udajesz hierarchię parą `(Typ, Id)` bez FK — to [polimorficzny FK](../../antywzorce/polimorficzny-fk.md) |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/modelowanie/tph-tpt-tpct.sql) |

## Problem

`Zadanie` i `Wydatek` są „pozycjami na osi czasu”, ale mają inne pola. Albo `Osoba` / `Firma` pod wspólnym kontrahentem.

## Model

| Nazwa | Alias | Tabele | Zaleta | Koszt |
|---|---|---|---|---|
| **TPH** (table per hierarchy) | STI | Jedna + `Typ` | Proste listy, jeden PK | Nullable kolumny podtypów |
| **TPT** (table per type) | CTI, subtype table | Bazowa + 1:1 per podtyp | Czyste NOT NULL, osobne FK | JOIN przy pełnym odczycie |
| **TPCT** (table per concrete type) | concrete table | Osobna tabela per liść | Brak nulli, osobne indeksy | UNION, rozjechane PK |

```text
-- TPH
Pozycja (Id, Typ, Tytul, Kwota NULL, Termin NULL)

-- TPT
Pozycja (Id, Typ, Tytul)
Zadanie (Id → Pozycja, Termin)
Wydatek (Id → Pozycja, Kwota)
```

`Typ` w TPH/TPT to `CHECK` / tabela słownikowa, nie wolny tekst.

## Kluczowe ograniczenia

- TPH: `CHECK (Typ <> 'Zadanie' OR Termin IS NOT NULL)`.
- TPT: PK dziecka = FK do bazy (`ON DELETE CASCADE`).
- UNIQUE biznesowy: w TPT na tabeli bazowej, nie tylko na dziecku.

## Operacje

Listy mieszane: TPH. Formularz jednego typu: TPT. TPCT tylko gdy nigdy nie listujesz razem.

## Pułapki

- TPH z 40 kolumnami nullable.
- TPT bez `Typ` na korzeniu — nie wiesz, którą tabelę JOIN-ować.
- Trzeci wariant i UI i tak pokazuje wspólną listę.

## Powiązane

- [EAV](eav.md) — gdy podtypów nie da się zamknąć listą
- [Party](party.md) — osoba/firma jako TPT
- [Association table](association.md)
