# Normalizacja

> Jeden fakt w jednym miejscu; anomalie zapisu wychodzą na wierzch zanim wejdą do produkcji.

| | |
|---|---|
| **Status** | `READY` |
| **Kiedy stosować** | OLTP, spójność, unikanie rozjazdów przy UPDATE |
| **Kiedy unikać** | Ścieżka odczytu wymaga stałego, szerokiego wiersza — wtedy denormalizacja **celowa** (read model, widok zmaterializowany), nie „bo JOIN jest trudny” |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/modelowanie/normalizacja.sql) |

## Problem

Powtórzony atrybut (adres w każdym zamówieniu, nazwa towaru w każdej pozycji) rozjeżdża się przy korekcie. Brak klucza kandydującego pozwala wstawić dwa „te same” wiersze.

## Model

Praktyczny cel w OLTP to **3NF / BCNF** — po diagramie koncepcyjnym ([Chen](../../projektowanie/notacja-chena.md)), nie zamiast niego.

1. **1NF** — atomowe wartości, brak powtarzających się grup (to nie jest „zakaz JSON”; JSON to osobny kontrakt, patrz [antywzorzec](../../antywzorce/csv-w-kolumnie.md)).
2. **2NF** — brak zależności od części klucza złożonego.
3. **3NF / BCNF** — atrybuty zależą od klucza, nie od innych atrybutów nietrivialnie.

```text
Klient (KlientId) 1──* Zamowienie (ZamowienieId, KlientId)
Zamowienie 1──* Pozycja (ZamowienieId, ProduktId, Ilosc, CenaWMomencie)
Produkt (ProduktId, Nazwa, CenaBiezaca)
```

`CenaWMomencie` na pozycji to **nie** denormalizacja błędu — to fakt historyczny. `CenaBiezaca` na produkcie to fakt bieżący. Dwa różne fakty.

## Kluczowe ograniczenia

- `PRIMARY KEY` / `UNIQUE` na naturalnych kandydatach (email, `(ZamowienieId, ProduktId)`).
- `FOREIGN KEY` z jawnym `ON DELETE` (`NO ACTION` / `CASCADE` / `SET NULL` — świadomie).
- `CHECK` na dziedziny (`Ilosc > 0`, `Cena >= 0`).

## Operacje

Zapis idzie wąskimi tabelami. Odczyt „faktury” składa JOIN albo korzysta z [indexed view](../wydajnosc/indexed-view.md) / [CQRS](../wydajnosc/cqrs.md), jeśli JOIN jest za drogi.

## Pułapki

- Normalizacja do 5NF „bo podręcznik” — zysk zerowy, koszt zapytań duży.
- Trzymanie `NazwaKlienta` na zamówieniu „dla wygody” bez decyzji, czy to snapshot, czy kopia do synchronizacji.
- Surrogate key wszędzie **i** brak UNIQUE na kluczu biznesowym → duplikaty.

## Powiązane

- [Notacja Chena](../../projektowanie/notacja-chena.md) — liczność i ziarno zanim JOIN
- [Zasady projektowania](../../projektowanie/zasady.md)
- [Case: zamówienie](../../projektowanie/case/README.md)
- [Indexed view](../wydajnosc/indexed-view.md) — świadoma denormalizacja odczytu
- [EAV](eav.md) — gdy atrybuty naprawdę nie mieszczą się w kolumnach
- [Brak unikalności](../../antywzorce/brak-unikalnosci.md)
