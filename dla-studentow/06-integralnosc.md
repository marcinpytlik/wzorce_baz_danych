# 6. Integralność

PK/FK/UNIQUE/CHECK żyją w silniku, nie w „sprawdzimy w API”. Karty: [ON DELETE](../projektowanie/on-delete.md), [lookup](../projektowanie/lookup.md), [checklist](../projektowanie/checklist-przegladu.md).

## Trzy integralności

| Rodzaj | W DDL |
|---|---|
| Encji | `PRIMARY KEY`, `NOT NULL` na kluczu |
| Odniesienia | `FOREIGN KEY` + **jawne** `ON DELETE` / `ON UPDATE` |
| Dziedziny | typ, `CHECK`, `UNIQUE`, tabela [lookup](../projektowanie/lookup.md) |

`KlientId NULL` to nie „gość” — [nullable klucz](../antywzorce/nullable-klucz.md). Gość to inna encja albo inny związek.

## ON DELETE — drzewo na PBD

```text
Dziecko nie ma sensu bez rodzica (pozycja, recepta przy wizycie)
    → CASCADE na związku identyfikującym
Dziecko to fakt, który ma zostać (zamówienie przy kliencie, wypożyczenie przy czytelniku)
    → NO ACTION; kasowanie to procedura (archiwum / anonimizacja), nie łapka w SSMS
Opcjonalna notatka, rodzic znika, notatka żyje
    → rzadko SET NULL; kolumna musi być NULL i związek częściowy
```

Zawsze wypisz `ON DELETE NO ACTION` w skrypcie, jeśli taka jest decyzja — recenzent nie zgaduje.

`ON UPDATE CASCADE` potrzebujesz, gdy PK rodzica **się zmienia**. Przy `IDENTITY` — zwykle nie.

## Lookup vs CHECK vs EAV

| | Kiedy |
|---|---|
| `CHECK (Status IN ('A','B'))` | 2–3 wartości, bez etykiety/kolejności w UI |
| Tabela słownikowa | Status, waluta, stawka, ICD — [lookup](../projektowanie/lookup.md) |
| EAV | Atrybuty **nieznane** przy projektowaniu — nie status wizyty |

PK lookupu: kod (`NOWA`), nie `IDENTITY`, jeśli kod idzie w dokumentach.

## Ćwiczenie

Dla modelu z lekcji 2 (uczelnia) albo z [zadania](zadania/README.md): każdy FK → jedna akcja i jedno zdanie *dlaczego*.  
Drugie: status wizyty — CHECK czy lookup? Napisz kryterium, nie zgaduj.

Self-review: odpal haczyki [checklisty](../projektowanie/checklist-przegladu.md) na swoim DDL (bez sekcji „outbox / tenant”, jeśli ich nie ma).

Dalej: [transakcje](07-transakcje.md).
