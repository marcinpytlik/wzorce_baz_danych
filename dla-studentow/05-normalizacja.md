# 5. Normalizacja — rozkład z anomaliami

Karta katalogu ([normalizacja](../wzorce/modelowanie/normalizacja.md)) mówi *kiedy* i *po co*. Ta lekcja pokazuje **krok po kroku**, skąd się biorą 1NF/2NF/3NF/BCNF. SQL: [`normalizacja-anomalie.sql`](../sql/dla-studentow/normalizacja-anomalie.sql).

Cel praktyczny na PBD: **3NF / BCNF** na faktach, które się aktualizuje. Snapshot (`CenaWMomencie`) to inny fakt, nie „grzech denormalizacji”.

## Arkusz, od którego boli

Biznes wkleił Excel do jednej tabeli. Kandydat na klucz, który „widać”: `(ZamowienieNr, Sku)`.

| ZamowienieNr | Data | Email | NazwaKlienta | KodPocztowy | Miasto | Sku | NazwaProduktu | Ilosc | CenaJedn | Telefony |
|---|---|---|---|---|---|---|---|---|---|---|
| 100 | 2026-03-01 | a@x | Ada | 80-001 | Gdańsk | ABC | Śruba | 2 | 1.50 | 500, 501 |
| 100 | 2026-03-01 | a@x | Ada | 80-001 | Gdańsk | DEF | Nakrętka | 10 | 0.40 | 500, 501 |
| 101 | 2026-03-02 | b@y | Bartek | 00-001 | Warszawa | ABC | Śruba | 1 | 1.50 | 600 |

`Telefony` to lista. `NazwaProduktu` powtarza się przy każdym SKU. `Miasto` powtarza się przy kodzie.

### Anomalie (zanim NF)

| Anomalia | Co się dzieje na arkuszu |
|---|---|
| **Modyfikacji** | Ada zmieniła miasto. Poprawiasz wiersz ze śrubą, nakrętka nadal ma Gdańsk. |
| **Wstawiania** | Nowy klient bez zamówienia: nie ma wiersza, bo klucz wymaga `Sku`. |
| **Usuwania** | Bartek miał jedną pozycję. DELETE pozycji kasuje też Bartka. |

To jest powód normalizacji, nie ocena z definicji.

## Zależność funkcyjna

`X → Y` znaczy: przy danym `X` jest **co najwyżej jedna** wartość `Y` w świecie, który modelujesz.

Na arkuszu (przy założeniach biznesu):

```text
ZamowienieNr           → Data, Email
Email                  → NazwaKlienta, KodPocztowy
KodPocztowy            → Miasto          (tylko jeśli to u Was prawda!)
Sku                    → NazwaProduktu
(ZamowienieNr, Sku)    → Ilosc, CenaJedn
```

`CenaJedn` tu jest **ceną w chwili zamówienia** (snapshot), nie ceną bieżącą produktu. Gdyby to była cena katalogowa, FD byłoby `Sku → CenaJedn` i trzymanie jej na linii byłoby kopią do rozjazdu.

FD, która nie jest prawdą, nie wchodzi do rozkładu. Kod pocztowy w Polsce **nie zawsze** wyznacza jedno miasto — nie wymuszaj 3NF na kłamstwie. Zostaw `Miasto` przy kliencie albo triple `(KodPocztowy, Miejscowosc)` ze źródła.

## 1NF — atomy, nie grupy

Powtarzająca się grupa / CSV łamie 1NF.

`Telefony = '500, 501'` → tabela `Telefon (KlientId, Numer)` z PK pary.

JSON w kolumnie to **nie** automatycznie 1NF ani automatycznie grzech. Na PBD: albo osobna tabela, albo jawny kontrakt (`ISJSON` + znane klucze). Nie „lista w `NVARCHAR`”.

Po 1NF arkusz nadal ma resztę anomalii — tylko telefony wyszły.

## 2NF — nic nie zależy od *części* klucza złożonego

Klucz `(ZamowienieNr, Sku)`. `Email` zależy tylko od `ZamowienieNr`. `NazwaProduktu` tylko od `Sku`. To **zależności częściowe** → nie 2NF.

Rozkład:

```text
Klient     (Email ★, Nazwa, KodPocztowy, Miasto)
Zamowienie (ZamowienieNr ★, Data, Email → Klient)
Produkt    (Sku ★, NazwaProduktu)
Pozycja    (ZamowienieNr, Sku) ★  + Ilosc, CenaJedn
Telefon    (Email, Numer) ★
```

Surrogate `KlientId` wolno dodać; UNIQUE na `Email` zostaje.

## 3NF — nic nie zależy od atrybutu, który nie jest kluczem

Jeśli naprawdę `KodPocztowy → Miasto`, to `Miasto` na `Klient` zależy od kodu, nie od emaila → nie 3NF.

```text
Poczta  (KodPocztowy ★, Miasto)
Klient  (Email ★, Nazwa, KodPocztowy → Poczta)
```

BCNF jest ostrzejsze: **każdy** determinant ma być superkluczem. 3NF puszcza zależność do atrybutu, który wchodzi w jakiś klucz kandydujący.

## BCNF — przykład, gdzie 3NF nie wystarcza

Edycja zajęć:

```text
R (Student, Przedmiot, Wykladowca)
{Student, Przedmiot} → Wykladowca     — kto uczy tego studenta z tego przedmiotu
Wykladowca           → Przedmiot      — wykładowca uczy tylko jednego przedmiotu
```

Klucze kandydujące: `{Student, Przedmiot}` oraz `{Student, Wykladowca}`.  
`Przedmiot` jest atrybutem pierwszym (wchodzi w klucz) → **3NF tak**, bo transzytywność idzie do prime.  
`Wykladowca → Przedmiot`, a `Wykladowca` nie jest superkluczem → **nie BCNF**.

Rozkład BCNF: `WykladowcaPrzedmiot (Wykladowca ★, Przedmiot)` + `Zapis (Student, Wykladowca) ★`.  
Zostaje FD `{Student, Przedmiot} → Wykladowca` do sprawdzania w aplikacji / TRIGGER — rozkład BCNF czasem **nie zachowuje** wszystkich FD. Dlatego na PBD mówisz: *cel 3NF, BCNF gdy widać taką FD i rozumiesz koszt*.

4NF/5NF (zależności wielowartościowe) — poza tym skryptem, chyba że M:N×M:N w jednej tabeli bez powodu.

## Snapshot vs kopia

| | |
|---|---|
| `CenaWMomencie` na pozycji | Fakt historyczny; **nie** synchronizujesz z katalogiem |
| `NazwaKlienta` na zamówieniu „żeby faktura się nie zmieniła” | Albo snapshot nazwany (`NazwaNaDokumencie`), albo JOIN do klienta i zmiana nazwy **ma** zmienić historię — zdecyduj |
| `NazwaProduktu` na pozycji + na produkcie, oba „aktualizowalne” | Anomalia; zostaw nazwę przy produkcie albo zrób snapshot świadomie |

## Ćwiczenie

1. Na arkuszu wskaż jedną anomalię każdego rodzaju (INSERT/UPDATE/DELETE).
2. Wypisz FD, potem rozbij do 3NF. Porównaj z [`normalizacja-anomalie.sql`](../sql/dla-studentow/normalizacja-anomalie.sql).
3. Czy `CenaJedn` na pozycji jest 2NF-grzechem, czy snapshotem? Jedno zdanie.
4. (chętni) Rozstrzygnij BCNF na `R(Student, Przedmiot, Wykladowca)` powyżej.

Dalej: [integralność](06-integralnosc.md).
