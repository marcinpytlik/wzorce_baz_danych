# Sekwencja vs IDENTITY vs UNIQUEIDENTIFIER

> Skąd się bierze następny identyfikator. Wybór wpływa na clustered index, merge baz i klucze z klienta.

| | |
|---|---|
| **Status** | `READY` |
| **Kiedy stosować** | Nowy PK, klucze z aplikacji, wiele tabel z jednym numeratorem |
| **Kiedy unikać** | `NEWID()` jako clustered PK na gorącej tabeli |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../sql/projektowanie/sekwencje.sql) |

## Trzy mechanizmy

| | `IDENTITY` | `SEQUENCE` | `UNIQUEIDENTIFIER` |
|---|---|---|---|
| Gdzie żyje | Przy kolumnie | Obiekt bazy, wiele tabel może brać | Wartość (klient lub serwer) |
| Luki po rollback | Tak | Tak | N/A |
| `NEXT VALUE` w DEFAULT | — | Tak | `NEWSEQUENTIALID()` tylko jako DEFAULT kolumny |
| Szerokość clustered | 4/8 B | 4/8 B | 16 B, losowość boli |
| Klucz z aplikacji przed INSERT | `OUTPUT` / `SCOPE_IDENTITY` po fakcie | `NEXT VALUE FOR` przed INSERT | Tak (`NEWSEQUENTIALID` tylko w DEFAULT, nie w SELECT swobodnie) |
| Merge / sync baz | Kolizje | Osobne zakresy albo nowy mechanizm | Niski risk kolizji |

`NEWSEQUENTIALID()` — sekwencyjne GUID **tylko** jako `DEFAULT` kolumny. Mniej fragmentacji niż `NEWID()`, nadal 16 B i nieidealne na clustered przy merge z innych maszyn (sekwencje per host).

## Domyślnie

- OLTP, jedna baza: **`INT IDENTITY`** (albo `BIGINT` na log).
- Wspólny numerator (`NumerFaktury` per rok to **nie** sekwencja globalna — to UNIQUE biznesowy z wzorcem numeracji).
- Klucz znany przed INSERT, kilka tabel, restart IDENTITY Cię wkurza: **`SEQUENCE`**.
- Klient generuje id (offline, wiele baz): **GUID**, clustered na czymś wąskim (`INT IDENTITY`) albo `NEWSEQUENTIALID` jeśli GUID *musi* być PK.

Nie używaj sekwencji jako substytutu UNIQUE biznesowego ([klucze](klucze.md)).

## Pułapki

- `NEWID()` na PK clustered — split stron przy każdym INSERT.
- `IDENTITY_INSERT` na stałe w aplikacji.
- Zakładanie, że IDENTITY jest bez luk i nadaje się na numer faktury.
- `NEWSEQUENTIALID()` w `SELECT` — nie wolno; tylko DEFAULT.
- Sekwencja `CACHE` i failover: skok numerów (normalne).

## Powiązane

- [Klucze](klucze.md)
- [Typy](typy.md)
- [Idempotencja](../wzorce/wspolbieznosc/idempotencja.md)
