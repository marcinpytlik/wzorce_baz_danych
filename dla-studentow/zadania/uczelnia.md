# Zadanie: uczelnia

Jedna katedra, jeden system zapisów. Nie USOS całej uczelni.

## Tekst (świat)

Student: numer albumu (unikalny, niezmienny w tym modelu), nazwisko, email.

Przedmiot: kod (`PBD`, `SO`), nazwa. Kod się nie powtarza.

**Edycja**: przedmiot w konkretnym semestrze (`2026L`) plus grupa (`A`/`B`), gdy ten sam przedmiot jedzie równolegle. Student zapisuje się na edycję, nie „na PBD w ogóle” — poprawka to nowy zapis w nowej edycji.

Każda edycja ma dokładnie jednego prowadzącego. Prowadzący (wykładowca) prowadzi wiele edycji. Wykładowca bez edycji bywa OK.

Zapis: data, status (`AKTYWNY`, `REZYGN`, `ZALICZONY` — etykiety w UI). Ocena (2.0–5.0, krok 0.5) należy do zapisu; brak oceny ≠ zero, tylko NULL „jeszcze nie wystawiono”. Jeden student raz na daną edycję.

## Polecenia

1. Chen. Gdzie romb `PROWADZI`, gdzie `ZAPISUJE_SIE`. Czy `OCENA` jest atrybutem zapisu, czy encją.
2. Dlaczego związek Student–Przedmiot bez edycji gubi fakt.
3. Tabele, PK edycji (naturalny vs surrogate), `ON DELETE`.
4. UNIQUE, które blokuje podwójny zapis.
5. Zapytanie: studenci edycji `PBD` / `2026L` / `A` bez oceny.

## Pułapki

- `Ocena` na `Student`.
- Jedna tabela `StudentPrzedmiot` z `Semestr NULL`.
- Prowadzący jako atrybut przedmiotu (wtedy wszystkie edycje mają tego samego).
- `ON DELETE CASCADE` z wykładowcy na edycje z zapisami.

Szkic: [`../szkice/uczelnia.md`](../szkice/uczelnia.md). SQL: [`sql/dla-studentow/uczelnia.sql`](../../sql/dla-studentow/uczelnia.sql).
