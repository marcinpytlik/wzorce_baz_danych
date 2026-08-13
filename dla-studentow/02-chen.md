# 2. Chen

> Prostokąt = byt, romb = związek, elipsa = atrybut. Legenda i pułapki: [notacja Chena](../projektowanie/notacja-chena.md) — **przeczytaj całą kartę**, tu jest tylko jak ćwiczyć.

## Zdanie z diagramu

Czytaj od rombu (czasownik):

*Klient składa N zamówień; każde zamówienie składa dokładnie jeden klient; klient może nie mieć zamówień; zamówienie bez klienta nie istnieje.*

To jest liczność (`1`/`N`) **i** uczestnictwo (linia pojedyncza vs podwójna). `1` ≠ „obowiązkowo”.

## Cztery rzeczy, które musisz umieć narysować

| Pojęcie | Symbol | Typowy błąd studenta |
|---|---|---|
| Encja mocna | prostokąt | Tabela SQL w prostokącie (`KlientId INT`) |
| Związek 1:N | romb + `1`/`N` | Dwa romby na ten sam fakt |
| M:N z atrybutem | romb z elipsą (`Ilosc`) | `Ilosc` na `PRODUKT` |
| Encja słaba | podwójny prostokąt + podwójny romb | Sam `Id IDENTITY` zamiast klucza właściciela |

Atrybut wielowartościowy (`◎ Telefon`) na Chenie **wolno** narysować. Na warstwie logicznej znika: osobna tabela, nie CSV.

Atrybut pochodny (`◌ Wartosc`) **nie** jest kolumną, dopóki nie zdecydujesz w [kolumnie obliczanej](../projektowanie/kolumna-obliczana.md).

Lookup statusów to nie encja biznesowa — [lookup](../projektowanie/lookup.md).

## Ćwiczenie (lab)

Z zdań narysuj Chen (ASCII jak w katalogu). Zaznacz liczność i uczestnictwo.

1. Student może się zapisać na wiele edycji przedmiotu; edycja (przedmiot w semestrze) ma wielu studentów. Ocena należy do **zapisu**, nie do studenta w ogóle.
2. Ten sam wykładowca prowadzi wiele edycji; edycja ma dokładnie jednego prowadzącego.
3. Student bez zapisów bywa OK. Zapis bez studenta — nie.

Pułapka: związek Student–Przedmiot **bez** edycji. Poprawka za semestr ginie.

Nie otwieraj [szkicu uczelni](szkice/uczelnia.md) przed własnym rysunkiem.

## Przeczytaj

Całą [notację Chena](../projektowanie/notacja-chena.md), w tym encję słabą i atrybut na związku.

Dalej: [na tabele](03-na-tabele.md).
