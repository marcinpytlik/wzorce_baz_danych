# Hard delete

> Wiersz znika. To domyślne SQL, nie „wzorzec sukcesu”. Karta jest po to, żeby wiedzieć **kiedy musisz** i co wtedy z FK, audytem i outboxem.

| | |
|---|---|
| **Status** | `STARTER` |
| **Kiedy stosować** | RODO, retencja każe skasować, nie ma obowiązku odzyskania |
| **Kiedy unikać** | Przycisk „usuń” w UI bez polityki — zwykle chcesz [soft delete](soft-delete.md) albo [archive](archive-then-delete.md) |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/usuwanie/hard-delete.sql) |

## Problem

Zostawianie wszystkiego „na miękko” puchnie. Regulacja każe usunąć. FK i repliki zostają z dziurą.

## Model

`DELETE` + jawne `ON DELETE` na FK (`NO ACTION` zmusza do kolejności, `CASCADE` kasuje graf). W tej samej TX: [outbox](../integracja/outbox.md) `Usunieto` albo [tombstone](tombstone.md) dla downstream.

## Kluczowe ograniczenia

- Kolejność kasowania dzieci albo `CASCADE` świadomie.
- Audyt *przed* DELETE ([audit trail](../historia/audit-trail.md)) — po fakcie wiersza nie ma.
- Indeksy i locki: duży DELETE = batch albo [partition switch](partition-switching-purge.md).

## Pułapki

- `ON DELETE CASCADE` na całym grafie „bo wygodnie”.
- DELETE bez komunikatu — cache i replika trzymają zombie.
- Hard delete jako jedyna strategia i jednocześnie wymóg „co się stało tydzień temu”.

## Powiązane

- [Soft delete](soft-delete.md)
- [Archive then delete](archive-then-delete.md)
- [Tombstone](tombstone.md)
