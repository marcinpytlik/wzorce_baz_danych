# Projektowanie

Zanim wzorzec: **co jest encją, jaki ma klucz, jaka liczność**. Potem typy, nazwy, `ON DELETE`. Wzorce w `wzorce/` — gdy pojawi się konkretny ból.

Uczysz się od zera (przedmiot PBD): [`dla-studentow/`](../dla-studentow/README.md) — tu jest katalog decyzji, nie sylabus.

```
projektowanie/
  zasady.md
  notacja-chena.md / crows-foot.md
  klucze.md  typy.md  nazewnictwo.md  on-delete.md  slownik-danych.md
  sekwencje.md  collation.md  kolumna-obliczana.md  lookup.md
  checklist-przegladu.md
  case/                 Chen → 3NF → soft delete / outbox / keyset
```

| Karta | Status | Po co |
|---|---|---|
| [Zasady](zasady.md) | `READY` | Checklist zanim SSMS |
| [Notacja Chena](notacja-chena.md) | `READY` | Warsztat encji i związków |
| [Crow’s Foot](crows-foot.md) | `READY` | Tłumacz Chena na SSMS / draw.io |
| [Klucze](klucze.md) | `READY` | PK, UNIQUE, naturalny vs surrogate |
| [Typy](typy.md) | `READY` | DECIMAL, DATETIME2, NVARCHAR |
| [Nazewnictwo](nazewnictwo.md) | `READY` | Konwencja katalogu |
| [ON DELETE](on-delete.md) | `READY` | CASCADE vs NO ACTION |
| [Słownik danych](slownik-danych.md) | `STARTER` | Ziarno, NULL, extended properties |
| [Sekwencje](sekwencje.md) | `READY` | IDENTITY vs SEQUENCE vs GUID |
| [Collation](collation.md) | `READY` | Unicode, LIKE, UNIQUE na tekście |
| [Kolumna obliczana](kolumna-obliczana.md) | `READY` | Pochodny atrybut z Chena |
| [Lookup](lookup.md) | `READY` | Słownik kodów ≠ EAV |
| [Checklist przeglądu](checklist-przegladu.md) | `READY` | PR do schematu |
| [Case: zamówienie](case/README.md) | `READY` | Jeden domen, trzy warstwy |

SQL: [`sql/projektowanie/`](../sql/projektowanie/).
