# Anti-corruption layer

> Obcy model (inna baza, vendor, legacy) nie wlewa się do Twojego schematu. Tłumaczysz na granicy.

| | |
|---|---|
| **Status** | `STARTER` |
| **Kiedy stosować** | Integracja z systemem, którego słownika nie chcesz mieć w środku |
| **Kiedy unikać** | Mapujesz kolumnę w kolumnę i udajesz, że to warstwa |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/integracja/anti-corruption-layer.sql) |

## Problem

ERP ma `KNT_KOD`, Ty masz `KlientId`. Wciągasz ich tabele do swojej bazy „żeby JOIN był prosty”. Po roku nie odróżnisz, co jest Twoje.

## Model

```text
zewn.KlientRaw     -- staging, kształt obcy, append/upsert z importu
map.KlientMap      -- ZewnKod ↔ KlientId
dbo.Klient         -- Twój model
```

Import: raw → mapowanie → Twój INSERT/UPDATE. Nigdy FK z `dbo` do `zewn`. Odrzucenie / ręczna mapa na kody, których nie znasz.

## Kluczowe ograniczenia

- Staging bez uprawnień runtime aplikacji.
- Mapowanie UNIQUE w obie strony, jeśli 1:1.
- Wersja / hash payloadu, żeby nie importować tego samego w kółko.

## Pułapki

- Widok `dbo.Klient` = `SELECT * FROM zewn.KNT`.
- Ich enum w Twoim CHECK.
- ACL tylko w kodzie, baza i tak ma ich kolumny.

## Powiązane

- [Data ownership](data-ownership.md)
- [Inbox](inbox.md)
- [EAV](../modelowanie/eav.md) — nie używaj EAV jako „uniwersalnego ACL”
