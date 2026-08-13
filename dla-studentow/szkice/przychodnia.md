# Szkic: przychodnia

## Chen (skrót)

```text
LEKARZ 1 ── ◆ PROWADZI ◆ ── N  PACJENT     (częściowe po obu: pacjent bez prowadzącego OK)
PACJENT 1 ── ◆ ODWIEDZA ◆ ── N  WIZYTA  N ── ◆ PRZYJMUJE ◆ ── 1  LEKARZ
WIZYTA 1 ── ◆◆ WYSTAWIA ◆◆ ── N  ║ POZYCJA_RECEPTY ║
WIZYTA M ── ◆ ROZPOZNAJE ◆ ── N  ICD         (lookup)
POZYCJA  N ── ◆ LEK ◆ ── 1  LEK             (lookup)
     ◎ Telefon na PACJENT
```

Dwa związki pacjent–lekarz: nie łączyć w `Pacjent.LekarzId` *jako* wizytę.

## Ziarno

| Tabela | Jeden wiersz = |
|---|---|
| `Wizyta` | jedno spotkanie pacjent–lekarz w terminie |
| `PozycjaRecepty` | jedna pozycja leku na jednej wizycie |
| `WizytaIcd` | jedno rozpoznanie na wizycie |

## Tabele

- `Lekarz (LekarzId, Npwz UNIQUE, Nazwisko)`
- `Pacjent (PacjentId, Pesel UNIQUE, Nazwisko, ProwadzacyLekarzId NULL FK NO ACTION)`
- `Telefon (PacjentId, Numer)` CASCADE
- `StatusWizyty` lookup
- `Wizyta (WizytaId, PacjentId NOT NULL NO ACTION, LekarzId NOT NULL NO ACTION, Termin, StatusKod)`
  `UNIQUE (PacjentId, LekarzId, Termin)`
- `Icd (IcdKod PK, Nazwa)` lookup
- `WizytaIcd (WizytaId, IcdKod)` PK para, wizyta CASCADE (rozpoznania giną z wizytą) albo NO ACTION — szkic: CASCADE bo słabe do wizyty
- `Lek (LekKod PK, Nazwa)` lookup
- `PozycjaRecepty (WizytaId, Lp)` PK, `LekKod`, `Dawka`, `Opakowania`, `ON DELETE CASCADE` z wizyty

Lookupów nie kasujesz, gdy wiszą FK (`NO ACTION`).

SQL: [`sql/dla-studentow/przychodnia.sql`](../../sql/dla-studentow/przychodnia.sql).
