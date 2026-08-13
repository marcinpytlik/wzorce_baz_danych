# EAV na wszystko

> Elastyczność jako unik przed modelem. Zapytania, typy i integralność wychodzą bokiem.

## Objaw

`Atrybut` / `Wartosc` dla nazwy, ceny, NIP-u i „czy aktywny”. Lista produktów to 40 JOIN-ów albo pivot w aplikacji. Raport „suma netto” sumuje stringi.

## Dlaczego boli

- Brak `NOT NULL` i typów — kontrakt żyje w wiki.
- Indeksy nie wiedzą, co jest ceną.
- UNIQUE „SKU unikalne” nie da się powiedzieć w jednym zdaniu SQL.

## Zamiast

- Stabilne cechy → kolumny ([normalizacja](../wzorce/modelowanie/normalizacja.md)).
- Skończone warianty → [TPH / TPT](../wzorce/modelowanie/tph-tpt-tpct.md).
- Naprawdę otwarte metadane → [EAV](../wzorce/modelowanie/eav.md) albo JSON **na tej jednej półce**, nie na całej domenie.
