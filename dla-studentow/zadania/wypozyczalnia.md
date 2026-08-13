# Zadanie: wypożyczalnia

Biblioteka osiedlowa. Nie sieć filii, nie e-book z DRM.

## Tekst (świat)

Czytelnik ma imię i nazwisko, email (unikalny), zero lub więcej telefonów.

Katalog opisuje **dzieło** (tytuł, ISBN gdy jest, rok). Dzieło ma jednego lub wielu autorów; autor ma wiele dzieł. ISBN, jeśli podany, nie powtarza się.

Na półce stoi **egzemplarz**: kod kreskowy (unikalny), inwentarz wewnętrzny, stan (`NA_POLCE`, `WYPOZYCZONY`, `W_NAPRAWIE` — lista urośnie o etykiety w UI). Egzemplarz jest zawsze jednym dziełem. Dzieło może nie mieć jeszcze egzemplarza (zamówione).

Czytelnik wypożycza egzemplarz na termin. To samo fizyczne wydanie wraca i idzie dalej — historia ma zostać. Dwa otwarte wypożyczenia tego samego egzemplarza są bezsensem. Limit: czytelnik ma co najwyżej 5 otwartych wypożyczeń (może być CHECK albo procedura — zapisz decyzję).

Zwrot: data faktyczna, może być po terminie. Kara pieniężna jest poza zakresem (nie rysuj kas).

## Polecenia

1. Chen: encje, związki, liczność, uczestnictwo. Autor–dzieło. Gdzie jest encja słaba, a gdzie nie.
2. Ziarno: `Egzemplarz`, `Wypozyczenie`, `Dzielo` — po jednym zdaniu.
3. FD, które rozbijasz (przynajmniej: egzemplarz→dzieło; otwarte wypożyczenie→egzemplarz).
4. Tabele, typy, UNIQUE, `ON DELETE`.
5. Zapytanie: egzemplarze dzieła ISBN *x* aktualnie na półce.

## Pułapki (nie czytaj jako rozwiązania)

- Tytuł na wypożyczeniu zamiast egzemplarza.
- `CzyWolny BIT` na egzemplarzu **zamiast** historii (stan może być pochodną albo snapshotem — zdecyduj i nazwij).
- Autorzy w `NVARCHAR` z przecinkami.
- CASCADE z `Czytelnik` na `Wypozyczenie`.

Szkic: [`../szkice/wypozyczalnia.md`](../szkice/wypozyczalnia.md). SQL po szkicu: [`sql/dla-studentow/wypozyczalnia.sql`](../../sql/dla-studentow/wypozyczalnia.sql).
