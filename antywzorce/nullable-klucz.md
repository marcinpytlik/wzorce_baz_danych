# Nullable „klucz”

> `KlientId INT NULL` bo „zamówienie bez klienta”, „czasem nie wiemy”, „gość”.

## Objaw

FK „prawie”. JOIN gubi wiersze albo mnoży je przez `IS NULL`. Raporty pełne „nieprzypisane”.

## Dlaczego boli

NULL w kolumnie FK to trzeci stan: jest rodzic / nie ma / nie wiadomo. UNIQUE i FK zachowują się inaczej niż myślisz (wiele NULL-i w UNIQUE na SQL Server vs Postgres).

## Zamiast

- Gość jest encją (`Klient` typu `Gosc`) albo osobnym wierszem `Anonimowy`.
- Dwa podtypy: [STI](../wzorce/modelowanie/sti.md) `ZamowienieZalogowane` / `ZamowienieGosc`.
- Jeśli wartość naprawdę opcjonalna i nie jest tożsamością — nie nazywaj tego kluczem i nie buduj na tym JOIN-ów obowiązkowych.
