# Szkic: wypożyczalnia

## Chen (skrót)

```text
AUTOR  M ── ◆ NAPISAL ◆ ── N  DZIEŁO  1 ──o<  EGZEMPLARZ
                                │
CZYTELNIK 1 ── ◆ WYPOZYCZA ◆ ── N  WYPOŻYCZENIE  N ── ◆ DOTYCZY ◆ ── 1  EGZEMPLARZ
     ◎ Telefon
```

`WYPOŻYCZENIE` jest encją (fakt w czasie), nie atrybutem egzemplarza.  
`EGZEMPLARZ` jest mocny (ma kod kreskowy w świecie). Nie słaby: egzemplarz przeżywa dzieło? w tym modelu dzieło nie znika — FK `NO ACTION`.  
Lookup `StatusEgzemplarza`. `WYPOZYCZONY` w szkicu SQL jest snapshotem pod UI; integralność to UNIQUE filtrowany na otwartym wypożyczeniu (`ZwrotAt IS NULL`). `W_NAPRAWIE` nie wynika z wypożyczenia — zostaje kolumną.

## Ziarno

| Tabela | Jeden wiersz = |
|---|---|
| `Dzielo` | jedno wydanie katalogowe (ISBN jeśli jest) |
| `Egzemplarz` | jeden fizyczny wolumin |
| `Wypozyczenie` | jedno wydanie egzemplarza jednemu czytelnikowi w jednym okresie |
| `AutorDzielo` | para autor–dzieło |

## Tabele

- `Autor (AutorId, Nazwisko)` UNIQUE nazwisko nie — homonimy.
- `Dzielo (DzieloId, Isbn NULL UNIQUE, Tytul, Rok)`
- `AutorDzielo (AutorId, DzieloId)` PK para, `ON DELETE NO ACTION`
- `Czytelnik (CzytelnikId, Email UNIQUE, Nazwisko)`
- `Telefon (CzytelnikId, Numer)` PK para, `ON DELETE CASCADE` (telefony giną z czytelnikiem)
- `StatusEgzemplarza (StatusKod PK)` lookup
- `Egzemplarz (EgzemplarzId, DzieloId NOT NULL NO ACTION, KodKreskowy UNIQUE, StatusKod)`
- `Wypozyczenie (WypozyczenieId, EgzemplarzId NO ACTION, CzytelnikId NO ACTION, Od, DoPlan, ZwrotAt NULL)`
- UNIQUE filtrowany: jeden `ZwrotAt IS NULL` na `EgzemplarzId`

Limit 5 otwartych: TRIGGER / procedura, nie sama 3NF. Na PBD wystarczy zdanie w słowniku.

`ON DELETE CASCADE` z czytelnika na wypożyczenia — **nie** (historia).

SQL: [`sql/dla-studentow/wypozyczalnia.sql`](../../sql/dla-studentow/wypozyczalnia.sql).
