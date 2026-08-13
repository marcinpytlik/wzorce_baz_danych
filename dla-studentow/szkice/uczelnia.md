# Szkic: uczelnia

## Chen (skrót)

```text
PRZEDMIOT 1 ── ◆ MA_EDYCJE ◆ ── N  EDYCJA
WYKŁADOWCA 1 ── ◆ PROWADZI ◆ ── N  EDYCJA     (edycja: uczestnictwo całkowite)
STUDENT M ── ◆ ZAPISUJE_SIE ◆ ── N  EDYCJA
                    │
               ○ StatusKod
               ○ Ocena     (pochodna? nie — fakt, NULL = brak)
```

`EDYCJA` jest encją mocną (surrogate) albo naturalnym `(PrzedmiotKod, Semestr, Grupa)` UNIQUE. Szkic: surrogate + UNIQUE naturalny (korekta grupy nie przepina PK).

Ocena jest **atrybutem zapisu**, nie encją (brak tożsamości poza zapisem). Gdyby poprawki były wielokrotne w tej samej edycji — wtedy historia ocen = słaba encja; tekst zadania mówi jedną ocenę.

## Ziarno

| Tabela | Jeden wiersz = |
|---|---|
| `Przedmiot` | przedmiot w ofercie katedry |
| `Edycja` | prowadzenie przedmiotu w semestrze w grupie |
| `Zapis` | jeden student na jednej edycji |

## Tabele

- `Wykladowca (WykladowcaId, Nazwisko)`
- `Przedmiot (PrzedmiotKod CHAR/VARCHAR PK, Nazwa)`
- `Edycja (EdycjaId PK, PrzedmiotKod FK NO ACTION, Semestr, Grupa, WykladowcaId NOT NULL NO ACTION)`
  `UNIQUE (PrzedmiotKod, Semestr, Grupa)`
- `Student (StudentId PK, NrAlbumu UNIQUE, Email UNIQUE, Nazwisko)`
- `StatusZapisu` lookup
- `Zapis (EdycjaId, StudentId)` PK para — encja związku, `ON DELETE NO ACTION` obu
  `StatusKod`, `Ocena DECIMAL(2,1) NULL` CHECK `(Ocena IN (2.0, 2.5, …, 5.0) OR Ocena IS NULL)`

Kasowanie wykładowcy z edycjami: NO ACTION. Kasowanie edycji z zapisami: NO ACTION (albo procedura).

SQL: [`sql/dla-studentow/uczelnia.sql`](../../sql/dla-studentow/uczelnia.sql).
