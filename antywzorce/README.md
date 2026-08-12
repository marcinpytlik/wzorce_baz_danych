# Antywzorce

Wzorce mówią „kiedy tak”. Tutaj: **kiedy wygląda jak rozwiązanie, a psuje model**.

| Antywzorzec | Objaw | Zamiast tego |
|---|---|---|
| [EAV na wszystko](eav-na-wszystko.md) | Każda cecha w `(encja, atrybut, wartość)` | Kolumny, STI, `jsonb` z kontraktem |
| [Tabela-bóg](tabela-bog.md) | 80 kolumn, 12 znaczeń `Status`, NULL wszędzie | Normalizacja, STI, osobne agregaty |
| [CSV / JSON bez kontraktu](csv-w-kolumnie.md) | `Tagi = 'a,b,c'` albo JSON „jaki padnie” | Tabela powiązań, `jsonb` + CHECK / JSON Schema |
| [Polimorficzny FK](polimorficzny-fk.md) | `RodzicTyp + RodzicId` bez FK | Tabela powiązań per typ, CTI |
| [Brak unikalności biznesowej](brak-unikalnosci.md) | Dwa wiersze „tego samego” na surrogate key | UNIQUE / indeks częściowy |
| [Nullable „klucz”](nullable-klucz.md) | `KlientId NULL` „bo czasem gość” | Osobny typ, gość jako encja, CHECK |

Nie jest antywzorcem: denormalizacja **z decyzją** ([widok zmaterializowany](../wzorce/skalowanie/materialized-view.md), [CQRS](../wzorce/skalowanie/cqrs.md)).
