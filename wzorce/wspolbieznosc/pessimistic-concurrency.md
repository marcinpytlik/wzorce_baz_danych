# Pessimistic concurrency

> Lock na wierszu do końca transakcji. Nikt inny nie zapisze (i zwykle nie przeczyta „na brudno”) w tym czasie.

| | |
|---|---|
| **Status** | `STARTER` |
| **Kiedy stosować** | Krótka TX, wysokie ryzyko konfliktu, musisz policzyć i zapisać atomowo |
| **Kiedy unikać** | Lock przez rundę HTTP / kliknięcie użytkownika |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/wspolbieznosc/pessimistic-concurrency.sql) |

## Problem

Optymistyczna wersja zbyt często wraca „spróbuj ponownie”. Chcesz serializacji na wierszu.

## Model

```sql
BEGIN TRAN;
SELECT ... FROM dbo.Konto WITH (UPDLOCK, HOLDLOCK, ROWLOCK)
WHERE KontoId = @id;
-- liczenie
UPDATE dbo.Konto ...;
COMMIT;
```

`UPDLOCK` — inni pisarze czekają. `HOLDLOCK` (Serializable range) — nikt nie wstawi „obok”, gdy to ważne. `READPAST` tu **nie** stosuj (to kolejka).

## Kluczowe ograniczenia

- TX krótka.
- Indeks na predykacie — inaczej lock na większym zakresie.
- Timeout (`LOCK_TIMEOUT`) zamiast wisieć minutę.

## Pułapki

- `HOLDLOCK` na tabeli bez indeksu = serializacja wszystkiego.
- Aplikacja trzyma otwartą TX na czas formularza.
- Deadlock bez `ROWLOCK` i bez kolejności locków.

## Powiązane

- [Optimistic concurrency](optimistic-concurrency.md)
- [Application lock](application-lock.md)
- [Queue table](../wydajnosc/queue-table.md)
