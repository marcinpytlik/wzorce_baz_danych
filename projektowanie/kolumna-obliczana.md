# Kolumna obliczana vs atrybut pochodny (Chen)

> W Chenie `◌ Wartosc` nie jest składowany. W SQL możesz: nie trzymać, liczyć w `SELECT`, albo `AS` (PERSISTED). To decyzja fizyczna, nie nowa encja.

| | |
|---|---|
| **Status** | `READY` |
| **Kiedy stosować** | Fakt wynika z innych kolumn **tego wiersza** deterministycznie |
| **Kiedy unikać** | Wartość z JOIN / agregatu innych wierszy — to [indexed view](../wzorce/wydajnosc/indexed-view.md) / [CQRS](../wzorce/wydajnosc/cqrs.md) |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../sql/projektowanie/kolumna-obliczana.sql) |

## Trzy poziomy

| | Chen | SQL | Kiedy |
|---|---|---|---|
| Nie składować | Elipsa przerywana | `SELECT Ilosc * CenaWMomencie` | Tanio, zawsze zgodne |
| Computed | To samo | `AS (Ilosc * CenaWMomencie)` | Częsty SELECT, chcesz nazwę kolumny |
| Computed PERSISTED | To samo + miejsce na dysku | `AS (...) PERSISTED` | Filtr/indeks na wyniku, deterministyczne |

W SQL Server indeks na computed wymaga zwykle **PERSISTED** i determinizmu (nie `GETDATE()`, nie niedeterministyczne UDF).

`Wartosc` na pozycji jest pochodna **wiersza**. `SumaZamowienia` z wielu pozycji **nie** jest computed na `Zamowienie` bez triggera / indexed view — nie udawaj.

## Zasady

- Źródła (`Ilosc`, `CenaWMomencie`) zostają kolumnami bazowymi. Nie zastępuj ich samym computed.
- Nie UPDATE-uj computed.
- Snapshot biznesowy (`CenaWMomencie`) to **nie** pochodna `CenaBiezaca` produktu — to inny fakt z Chena (atrybut związku).

## Pułapki

- Computed z `GETDATE()` — niedeterministyczne, bez PERSISTED, bez indeksu.
- `Suma` jako computed na rodzicu.
- Trzymanie `Wartosc` jako zwykłej kolumny i zapominanie UPDATE przy zmianie `Ilosc` — wracasz do anomalii, których Chen chciał uniknąć.

## Powiązane

- [Notacja Chena](notacja-chena.md) (elipsa przerywana)
- [Indexed view](../wzorce/wydajnosc/indexed-view.md)
- [Typy](typy.md)
