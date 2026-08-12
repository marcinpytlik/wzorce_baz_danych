# Antywzorce

Wzorce mówią „kiedy tak”. Tutaj: **kiedy wygląda jak rozwiązanie, a psuje model**.

| Antywzorzec | Objaw | Zamiast tego |
|---|---|---|
| [Dual write](dual-write.md) | COMMIT tu, publish tam | [Outbox](../wzorce/integracja/outbox.md), EMC w jednej TX |
| [Shared database](shared-database.md) | Kilka serwisów pisze jedną bazę | [Ownership](../wzorce/integracja/data-ownership.md), baza per serwis |
| [EAV na wszystko](eav-na-wszystko.md) | Każda cecha w `(encja, atrybut, wartość)` | Kolumny, [TPH/TPT](../wzorce/modelowanie/tph-tpt-tpct.md), JSON z kontraktem |
| [Tabela-bóg](tabela-bog.md) | 80 kolumn, 12 znaczeń `Status` | [Normalizacja](../wzorce/modelowanie/normalizacja.md), [Party](../wzorce/modelowanie/party.md) |
| [CSV / JSON bez kontraktu](csv-w-kolumnie.md) | `Tagi = 'a,b,c'` | [Association](../wzorce/modelowanie/association.md), `ISJSON` |
| [Polimorficzny FK](polimorficzny-fk.md) | `RodzicTyp + RodzicId` | Association per typ, [TPT](../wzorce/modelowanie/tph-tpt-tpct.md) |
| [Brak unikalności biznesowej](brak-unikalnosci.md) | Dwa SKU na IDENTITY | [UNIQUE](../mechanizmy/unique-constraint.md), [idempotencja](../wzorce/wspolbieznosc/idempotencja.md) |
| [Nullable „klucz”](nullable-klucz.md) | `KlientId NULL` „bo gość” | Encja gościa, [TPT](../wzorce/modelowanie/tph-tpt-tpct.md) |

Nie jest antywzorcem: denormalizacja **z decyzją** ([indexed view](../wzorce/wydajnosc/indexed-view.md), [CQRS](../wzorce/wydajnosc/cqrs.md)).
