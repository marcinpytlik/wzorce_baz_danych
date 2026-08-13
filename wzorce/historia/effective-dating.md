# Effective dating

> Valid time: od kiedy do kiedy fakt był prawdziwy **w świecie**, nie kiedy baza dostała UPDATE.

| | |
|---|---|
| **Status** | `STARTER` |
| **Kiedy stosować** | Cennik, etat, umowa, rola — obowiązuje w przedziale dat |
| **Kiedy unikać** | Mieszasz z system time w jednej parze kolumn „bo data” |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/historia/effective-dating.sql) |

## Problem

Cena 9.99 „od zawsze” w wierszu produktu. Korygujesz cennik wstecz i niszczysz historię. Albo dwa etaty nakładają się.

## Model

```text
Cena (ProduktId, WazneOd, WazneDo, Kwota)
-- WazneDo = '9999-12-31' oznacza current
```

Niezmiennik: zakresy tego samego `ProduktId` **nie nachodzą**. W SQL Server: trigger / constraint z `WHERE` (brak `EXCLUDE` jak w Postgres). Current: `WazneDo = '9999-12-31'` albo `WazneDo IS NULL` — wybierz jeden i nie mieszaj.

To nie jest `SYSTEM_VERSIONING`. System time: [temporal](temporal.md). Hurtownia: [SCD T2](scd.md) jest kuzynem, innym kontekstem.

## Kluczowe ograniczenia

- `WazneOd < WazneDo`.
- Zakaz nakładania (trigger po INSERT/UPDATE).
- Indeks `(ProduktId, WazneOd, WazneDo)`.

## Operacje

Korekta: domknij stary zakres, wstaw nowy. As-of: `WazneOd <= @d AND @d < WazneDo`.

## Pułapki

- Dwie osie w `ValidFrom`/`ValidTo` bez nazwania która.
- `BETWEEN` z zamkniętym `WazneDo` i sąsiednie zakresy w tej samej sekundzie.
- UPDATE w miejscu zamiast nowej wersji zakresu.

## Powiązane

- [Tabele temporalne](temporal.md)
- [SCD](scd.md)
- [Party](../modelowanie/party.md)
