# 1. Warstwy i ziarno

> Najpierw znaczenie wiersza, potem SSMS. Karta: [zasady](../projektowanie/zasady.md) pkt 1–10 (tenant i EMC na później).

## Trzy warstwy — nie na jednym rysunku

| Warstwa | Pytanie | Artefakt na PBD |
|---|---|---|
| Konceptualna | Jakie byty w świecie? | [Chen](../projektowanie/notacja-chena.md) |
| Logiczna | Jakie relacje i klucze? | Tabele, PK/FK — [Crow’s Foot](../projektowanie/crows-foot.md) |
| Fizyczna | Jak to stoi na SQL Server? | Typy, indeksy — **nie na zajęciach 1–2** |

Chen z `INT IDENTITY` i `IX_Klient_Email` to już nie Chen. Indeks bez zdania „jeden wiersz = …” jest zgadywaniem.

## Ekran to nie schemat

Formularz „Nowa wizyta” ma pacjenta, lekarza, datę, trzy leki i kod ICD. To **nie** jest jedna tabela `Wizyta` z `Lek1`, `Lek2`, `Lek3`. Encje biorą się z faktów (kto, co, kiedy), nie z siatki UI.

## Ziarno

Jedno zdanie na tabelę: *wiersz w `Pozycja` = jedna linia jednego zamówienia na jeden produkt*.

Jeśli nie umiesz tego powiedzieć, pierwszy raport zmieni znaczenie tabeli.

## Ćwiczenie (15 min)

Ekran biblioteki: czytelnik, tytuł książki, kod kreskowy egzemplarza, data wypożyczenia, data zwrotu, telefon (dwa pola).

1. Wypisz **fakty**, nie kontrolki.
2. Dla każdego kandydata na tabelę napisz ziarno.
3. Które pole jest **historią** (wiele wypożyczeń tego samego egzemplarza), a które **stanem** (kto trzyma książkę teraz)?

Nie rysuj jeszcze rombów — to lekcja 2. Nie otwieraj [szkicu wypożyczalni](szkice/wypozyczalnia.md).

## Przeczytaj

[Zasady](../projektowanie/zasady.md) 1–10. Pkt 11–14 możesz skimować.

Dalej: [Chen](02-chen.md).
