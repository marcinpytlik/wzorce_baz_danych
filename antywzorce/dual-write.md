# Dual write

> Dwa zapisy w dwóch zasobach bez wspólnej transakcji. Wygląda na integrację, kończy się rozjazdem. Jedyny dual write, który jest OK: **ta sama baza, ta sama TX** (faza migrate w EMC).

## Objaw

`COMMIT` w SQL, potem `Publish` do brokera. Albo INSERT w bazie A i bazie B z aplikacji. Po crashu jedno jest, drugiego nie.

## Dlaczego boli

Nie ma atomowości. Retry robi duplikat po jednej stronie. Nikt nie umie powiedzieć, co jest źródłem prawdy.

## Zamiast

- Baza + komunikat → [outbox](../wzorce/integracja/outbox.md)
- Dwa serwisy → [saga](../wzorce/integracja/saga.md) + outbox/inbox
- Zmiana schematu → [EMC](../wzorce/ewolucja/expand-migrate-contract.md) (dwie kolumny, jedna TX)
- Dwie bazy z aplikacji → nie. Projekcja z logu / [CDC](../wzorce/integracja/cdc.md)

## Powiązane

- [Outbox](../wzorce/integracja/outbox.md)
- [Inbox](../wzorce/integracja/inbox.md)
- [Shared database](shared-database.md)
