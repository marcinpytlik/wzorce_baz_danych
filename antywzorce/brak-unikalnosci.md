# Brak unikalności biznesowej

> Jest `Id IDENTITY`, więc „unikalność mamy”. Dwa SKU `ABC`, dwa emaile, dwie faktury `FV/1/2026`.

## Objaw

Duplikaty w raporcie, merge w Excelu, `TOP 1` „na wszelki wypadek”. Retry HTTP tworzy drugi wiersz ([idempotencja](../wzorce/wspolbieznosc/idempotencja.md)).

## Dlaczego boli

Surrogate key identyfikuje wiersz, nie fakt biznesowy. Wyścig dwóch INSERT-ów bez UNIQUE zawsze wygra oba.

## Zamiast

- `UNIQUE (TenantId, Sku)` / indeks częściowy przy [soft delete](../wzorce/usuwanie/soft-delete.md).
- Klucz idempotency obok UNIQUE biznesowego — to dwa różne poziomy.
- Nie zastępuj UNIQUE filtrem w aplikacji.
