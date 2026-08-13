# Tombstone

> Zamiast pełnego wiersza zostaje znacznik „ten klucz nie istnieje”. Repliki i cache mogą wygasić kopię.

| | |
|---|---|
| **Status** | `STARTER` |
| **Kiedy stosować** | Downstream (cache, search, inna baza) musi odróżnić „nie było” od „było i skasowano” |
| **Kiedy unikać** | Zostawiasz cały martwy wiersz — to [soft delete](soft-delete.md) |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/usuwanie/tombstone.sql) |

## Problem

Hard delete na źródle, replika nie dostała DELETE (albo dostała po swoim INSERT-cie z opóźnienia). Klucz wraca do życia jako duch.

## Model

```text
Tombstone (Klucz, UsunietoAt, WygasaAt)
```

Po DELETE źródła: INSERT tombstone (ta sama TX albo outbox). Konsument: jeśli jest tombstone nowszy niż lokalna kopia — kasuj lokalnie. TTL: po `WygasaAt` wolno zapomnieć (okno retraja minęło).

## Kluczowe ograniczenia

- PK = klucz biznesowy, który zniknął.
- TTL ≥ maksymalne opóźnienie repliki / retry.
- Nie mylić z soft delete: tu nie ma atrybutów encji.

## Pułapki

- Tombstone bez TTL — tabela puchnie jak soft delete.
- TTL krótszy niż retry outboxa — klucz zmartwychwstaje.
- Tombstone w cache bez tenanta w kluczu.

## Powiązane

- [Hard delete](hard-delete.md)
- [Outbox](../integracja/outbox.md)
- [Inbox](../integracja/inbox.md)
