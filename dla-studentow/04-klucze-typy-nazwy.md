# 4. Klucze, typy, nazwy

Karty (przeczytaj): [klucze](../projektowanie/klucze.md), [typy](../projektowanie/typy.md), [nazewnictwo](../projektowanie/nazewnictwo.md). [Sekwencje](../projektowanie/sekwencje.md) — skąd się bierze id, nie numer faktury.

## Trzy decyzje na każdą tabelę

1. **Czym świat odróżnia dwa fakty?** → `UNIQUE` (email, SKU, `(ZamowienieId, ProduktId)`).
2. **Czym baza odróżnia wiersz?** → PK, zwykle `INT IDENTITY`. To nie zastępuje pkt 1.
3. **Jakiego typu jest dziedzina?** → tabela poniżej, nie `NVARCHAR(MAX)` „na wszelki wypadek”.

Naturalny kod słownika (`PL`, `NOWA`) **może** być PK — [lookup](../projektowanie/lookup.md). NIP jako PK — zwykle nie (korekta literówki przepina FK).

Encja słaba: tożsamość = właściciel + klucz częściowy. `PozycjaId IDENTITY` wolno *obok*, nie zamiast.

## Typy na PBD (domyślne)

| Fakt | Typ |
|---|---|
| Pieniądze | `DECIMAL(19,4)` (albo jawne `p,s`) |
| Data bez godziny | `DATE` |
| Czas zdarzenia (UTC) | `DATETIME2(3)` |
| Nazwisko, adres | `NVARCHAR(n)` + świadoma [collation](../projektowanie/collation.md) |
| SKU, kod ISO | `VARCHAR(n)` |
| Flaga | `BIT` |
| Nie: pieniądze | `FLOAT`, `MONEY` |
| Nie: data | `TIMESTAMP` (= `ROWVERSION`) |

## Nazwy

Tabela = rzeczownik, liczba pojedyncza, PascalCase: `Zamowienie`, nie `tbl_Orders`.  
FK nazywa się jak PK rodzica: `KlientId`. Dwie role = dwie nazwy: `PlatnikKlientId`, `OdbiorcaKlientId`.

## Ćwiczenie

Dobierz typ, NULL, UNIQUE/PK:

| Atrybut | Twoja decyzja |
|---|---|
| Email czytelnika | |
| Kod kreskowy egzemplarza | |
| ISBN wydania | |
| Kwota na recepcie | |
| Pesel | |
| `UsunietoAt` (soft delete — na PBD tylko wiesz, że to fizyka) | |
| Status wizyty (`NOWA` / `ODB` / `ANUL`) | |

Drugie: zamówienie ma płatnika i odbiorcę (obaj to klient). Narysuj **dwa** związki, nie jedną kolumnę `KlientId`.

Dalej: [normalizacja](05-normalizacja.md).
