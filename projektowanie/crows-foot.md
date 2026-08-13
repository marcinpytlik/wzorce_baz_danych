# Crow’s Foot

> Tłumacz Chena na notację, którą rysuje SSMS i draw.io: linia + „kurza łapka”, bez rombu. Ten sam model, inny rysunek — nie nowa metodyka.

| | |
|---|---|
| **Status** | `READY` |
| **Kiedy stosować** | Diagram logiczny/fizyczny, narzędzie nie umie Chena |
| **Kiedy unikać** | Warsztat z biznesem („co istnieje”) — wróć do [Chena](notacja-chena.md) |
| **Silnik** | SQL Server 2022 (diagram bazy w SSMS jest Crow’s Foot) |
| **SQL** | ten sam przykład: [chen-na-tabele.sql](../sql/projektowanie/chen-na-tabele.sql) |

## Legenda (to, co musisz umieć odczytać)

Od strony **dziecka** (wielu) do **rodzica** (jednego):

```text
  KLIENT  ||——o<  ZAMÓWIENIE
           │
           └ palce = „wiele”
             kreski przy rodzicu = „jeden”
             kółko = opcjonalnie (0)
             druga kreska = obowiązkowo (1)
```

| Symbol przy końcu linii | Znaczenie | Chen |
|---|---|---|
| Palce / „łapka” | Wiele (`N`) | `N` |
| Kreska prostopadła | Jeden (`1`) | `1` |
| Kółko | Opcjonalnie (`0`) | uczestnictwo częściowe |
| Dwie kreski (bez kółka) | Obowiązkowo (`1`) | uczestnictwo całkowite |

Czytanie: `KLIENT ||——o< ZAMÓWIENIE` = jeden klient ma zero-lub-wiele zamówień; zamówienie ma dokładnie jednego klienta (`>o——||` z drugiej strony: łapka przy kliencie nie, kreski przy zamówieniu od strony klienta).

Ten sam fakt co w Chenie: *klient składa N zamówień; zamówienie składa dokładnie 1 klient; klient może nie mieć zamówień*.

## Ten sam model: Chen vs łapki

Chen (romb `SKŁADA`):

```text
  KLIENT  1 ── ◆ SKŁADA ◆ ── N  ZAMÓWIENIE
          (częściowe)     (całkowite)
```

Crow’s Foot (związek *jest* linią, nazwa opcjonalna na linii):

```text
  KLIENT  ||————o<  ZAMÓWIENIE     sklada
```

M:N w Chenie ma romb. W Crow’s Foot **nie rysuj łapek w obie strony na dwóch encjach biznesowych** — wstaw tabelę związku (`Pozycja`) i dwie linie 1:N. To samo, co mapowanie M:N na tabele.

Encja słaba: w Crow’s Foot często zaokrąglony róg albo po prostu PK złożony na diagramie tabel. Identyfikacja i tak musi być w kluczu — [klucze](klucze.md).

## Kiedy której notacji

| Pytanie | Notacja |
|---|---|
| Jakie byty w świecie? Jaka liczność? | [Chen](notacja-chena.md) |
| Jakie tabele i FK, do code review / SSMS? | Crow’s Foot (ta karta) |
| Typy, indeksy, filegroup? | Nie diagram — DDL i [typy](typy.md) |

Nie mieszaj na jednym rysunku rombu Chena z łapkami. Dwa diagramy, jedna prawda.

## Pułapki

- Crow’s Foot nazwany Chenem, „bo też ER”.
- M:N jako dwie łapki bez tabeli asocjacji.
- Opcjonalność zgubiona (kółko vs kreska) — wychodzi `NULL` albo `NOT NULL` przypadkiem.
- Diagram SSMS po `IDENTITY` traktowany jako model koncepcyjny.

## Powiązane

- [Notacja Chena](notacja-chena.md)
- [Klucze](klucze.md)
- [ON DELETE](on-delete.md)
- [Case: zamówienie](case/README.md)
