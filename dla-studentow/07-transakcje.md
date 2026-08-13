# 7. Transakcje (na poziomie modelu)

Nie saga, nie outbox, nie isolation-level olympics. Pytanie PBD: **które wiersze muszą stanąć albo spaść razem**, bo to jeden fakt biznesowy.

SQL: [`transakcje.sql`](../sql/dla-studentow/transakcje.sql).

## ACID jako decyzja projektowa

| | Znaczenie na modelu |
|---|---|
| **A**tomicity | `Zamowienie` + `Pozycja` + (ew. `Platnosc`) w **jednej** `BEGIN TRAN` … `COMMIT`. Połowa koszyka nie istnieje. |
| **C**onsistency | Po COMMIT nadal prawdziwe są PK/FK/CHECK. Integralność z lekcji 6 *jest* spójnością. |
| **I**solation | Dwa równoległe „wypożycz ten egzemplarz” nie dają dwóch czytelników. |
| **D**urability | COMMIT przeżył restart — to silnik, nie Twój diagram. |

Granica TX = użycie przypadku (*złóż zamówienie*, *oddaj książkę*), nie request HTTP i nie „cała sesja użytkownika”. Długa TX przez formularz = blokady.

## Co rysujesz, a czego nie

Na Chenie transakcji nie ma. Na logicznej warstwie zapisujesz: *operacja O czyta/pisze tabele {…} i musi być atomowa*.

Przykład: wypożyczenie egzemplarza, który nie jest już na półce.

- INSERT `Wypozyczenie`
- egzemplarz nie może mieć drugiego otwartego wypożyczenia → `UNIQUE` filtrowany / CHECK „jeden `ZwrotAt IS NULL` na egzemplarz”

UNIQUE w silniku jest tańszy niż „uzgodnimy w serwisie”.

## Lost update (żebyś wiedział, że istnieje)

Dwa stanowiska czytają `Ilosc = 1`, oba robią `Ilosc = 0`. Zwycięzca nadpisuje. Na PBD:

1. Najpierw ograniczenie, które **w ogóle nie dopuszcza** dwóch otwartych wypożyczeń.
2. Potem, gdy dwa UPDATE-y tego samego salda są legalne: [optimistic](../wzorce/wspolbieznosc/optimistic-concurrency.md) (`ROWVERSION`) — **po** zaliczeniu modelu.

Poziomy izolacji (`READ COMMITTED` vs `SERIALIZABLE`) są dźwignią silnika. Nie dobierasz ich zamiast klucza.

## Ćwiczenie

1. W [`transakcje.sql`](../sql/dla-studentow/transakcje.sql) wskaż, co musi być w jednej TX, a co może być następną (np. wysyłka maila — już nie ten przedmiot).
2. Na swoim projekcie: wypisz 3 operacje i zbiór tabel atomowych. Jedna operacja, która **nie** powinna trzymać TX przez UI.

Dalej: [zapytanie sprawdza model](08-model-a-zapytanie.md).
