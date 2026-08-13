# 8. Zapytanie sprawdza model

Jeśli odczyt wymaga `LIKE '%,500,%'` albo `STRING_SPLIT` po kolumnie biznesowej — model kłamie. Ta lekcja nie uczy SQL od zera; uczy **użyć JOIN-a jako testu liczności**.

## Testy, które mają paść albo przejść

| Pytanie biznesowe | W 3NF | W arkuszu / CSV |
|---|---|---|
| Pozycje zamówienia 100 | `WHERE ZamowienieId = 100` | Filtr po `ZamowienieNr`, powtórzone dane klienta |
| Czytelnicy z telefonem 500 | JOIN `Telefon` | `LIKE` |
| Egzemplarze wolne | `NOT EXISTS` otwartego wypożyczenia | Flaga `CzyWolna` rozjeżdża się z historią |
| Studenci edycji „BD 2026L” | JOIN `Zapis` | Kolumny `Student1`…`Student30` |

Napisz te cztery zapytania na **swoim** DDL. Jeśli nie umiesz bez skanowania tekstu — wróć do lekcji 5.

## Algebra → SQL (ściąga, nie wykład)

Relacyjna algebra jest językiem *co* liczysz; SQL jest *jak* to zapisuje silnik.

| Algebra | SQL | Na modelu |
|---|---|---|
| σ<sub>p</sub> (selekcja) | `WHERE p` | Predykat na atrybutach **tej** relacji |
| π<sub>A</sub> (projekcja) | `SELECT A` | `DISTINCT` gdy projekcja nie zawiera klucza |
| r ⋈ s (równoważność) | `JOIN … ON` | FK = PK; liczność JOIN-a = liczność związku |
| r ∪ s | `UNION` | Ten sam nagłówek (unia zgodna) |
| r − s | `EXCEPT` | „wolne egzemplarze” = wszystkie − wypożyczone |
| γ (agregacja) | `GROUP BY` | Agregat nie jest kolumną encji — [computed](../projektowanie/kolumna-obliczana.md) nie z wielu wierszy |

Nie dowodzimy tu aksjomatów. Sprawdzasz: *czy ⋈ ma oczywisty warunek na FK*.

## Widok to nie nowa encja

`v_faktura` (JOIN pozycji i klienta) jest odczytem. Encja zostaje `Pozycja`. Denormalizacja odczytu ([indexed view](../wzorce/wydajnosc/indexed-view.md)) — świadomie, po 3NF, nie zamiast.

## Ćwiczenie

Na wyniku lekcji 5 / [`normalizacja-anomalie.sql`](../sql/dla-studentow/normalizacja-anomalie.sql):

1. Napisz σπ⋈: „SKU i ilość dla emaila `a@x`”.
2. To samo w SQL.
3. Na arkuszu sprzed rozkładu pokaż, czemu to samo zapytanie kłamie przy anomalii UPDATE.

Projekt: [zadania](zadania/README.md).
