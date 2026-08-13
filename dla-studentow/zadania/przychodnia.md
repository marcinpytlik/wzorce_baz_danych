# Zadanie: przychodnia

Mała przychodnia POZ. Nie szpital, nie NFZ-owe rozliczenia.

## Tekst (świat)

Pacjent: nazwisko, PESEL (unikalny; w tym modelu nie korygujemy — jeśli chcesz korekty, surrogate + UNIQUE). Telefony: zero lub więcej.

Lekarz: nazwisko, NPWZ (unikalny). Lekarz przyjmuje wielu pacjentów w czasie; pacjent chodzi do wielu lekarzy. „Lekarz prowadzący” jest **opcjonalnym** związkiem 1:N (pacjent *może* mieć jednego prowadzącego), osobno od wizyt.

Wizyta: pacjent, lekarz, termin (`DATETIME2`), status (`UMOWIONA`, `ODBYTA`, `ANUL`). Ten sam pacjent nie ma dwóch wizyt u tego samego lekarza w tej samej minucie (UNIQUE). Wizyta bez pacjenta albo bez lekarza nie istnieje.

Po wizycie odbytej: zero lub więcej **pozycji recepty** (lek, dawka, ilość opakowań). Pozycja nie istnieje bez wizyty. Słownik leków: kod wewnętrzny + nazwa (lookup), nie EAV objawów. ICD-10 na wizycie: zero lub więcej kodów z lookupu (M:N wizyta–ICD).

Objawy wolnym tekstem (`NVARCHAR`) na wizycie są OK jako notatka. Nie modeluj „dowolnych cech pacjenta” jako EAV.

## Polecenia

1. Chen: dwa związki pacjent–lekarz (prowadzący vs wizyta) — nie jedna kolumna na dwa fakty.
2. Encja słaba: pozycja recepty.
3. ICD: lookup + tabela związku, nie CSV.
4. `ON DELETE`: wizyta vs pacjent; pozycja vs wizyta; lookup vs wizyta.
5. Zapytanie: recepty wystawione przez lekarza X w marcu 2026.

## Pułapki

- `Lek1`, `Lek2` na wizycie.
- ICD w `VARCHAR` `'J06,I10'`.
- `Pacjent.LekarzId` jako jedyny związek — gubi historię wizyt.
- CASCADE z pacjenta na wizyty (historia medyczna).

Szkic: [`../szkice/przychodnia.md`](../szkice/przychodnia.md). SQL: [`sql/dla-studentow/przychodnia.sql`](../../sql/dla-studentow/przychodnia.sql).
