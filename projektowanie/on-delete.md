# ON DELETE / ON UPDATE

> FK bez akcji to decyzja: **NO ACTION**. CASCADE, SET NULL, SET DEFAULT to świadome skutki uboczne, nie wygoda SSMS.

| | |
|---|---|
| **Status** | `READY` |
| **Kiedy stosować** | Każdy `FOREIGN KEY`; modelowanie usunięcia rodzica |
| **Kiedy unikać** | `ON DELETE CASCADE` na całym grafie „bo przechodzi” |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../sql/projektowanie/on-delete.sql) |

## Akcje

| Akcja | DELETE rodzica | UPDATE PK rodzica | Typowy przypadek |
|---|---|---|---|
| **NO ACTION** (domyślna) | Błąd, gdy są dzieci | Błąd, gdy są dzieci | Zamówienie→klient: najpierw decyzja biznesowa |
| **CASCADE** | Kasuje dzieci | Przepina FK | Encja słaba (`Pozycja` z zamówieniem) |
| **SET NULL** | FK dziecka ← NULL | FK ← NULL | Wymaga kolumny NULL — zwykle zły pomysł na tożsamość |
| **SET DEFAULT** | FK ← DEFAULT | FK ← DEFAULT | Prawie nigdy; DEFAULT musi istnieć w rodzicu |

`NO ACTION` i `RESTRICT` w SQL Server zachowują się jak **NO ACTION** (sprawdzenie na końcu instrukcji). Nie licz na `RESTRICT` z Postgresa.

`ON UPDATE CASCADE` potrzebujesz tylko gdy PK rodzica **się zmienia**. Przy surrogate PK — zwykle zbędne. Przy naturalnym PK, który korygujecie — to argument, żeby nie był PK ([klucze](klucze.md)).

## Jak wybierać

```text
Rodzic znika → dzieci nie mają sensu          → CASCADE
                 (pozycje, wiersze słabe)
Rodzic znika → dzieci mają żyć, FK zostaje    → najpierw soft delete / archiwum,
                 albo zakaz kasowania           potem NO ACTION
Rodzic znika → „odepnij” dziecko              → rzadko SET NULL; nazwij rolę
                                                 (nie udawaj, że FK nadal coś znaczy)
```

Kasowanie klienta z zamówieniami: **NO ACTION** + procedura (`archiwizuj` / `anonimizuj`), nie CASCADE po całym OLTP.

Wielokrotne ścieżki CASCADE do tej samej tabeli SQL Server **odrzuci** (cycles / multiple cascade paths). To znak, że graf usuwania jest za magiczny — rozbij na procedurę.

## Związek z usuwaniem

- [Hard delete](../wzorce/usuwanie/hard-delete.md) — kolejność albo CASCADE świadomie.
- [Soft delete](../wzorce/usuwanie/soft-delete.md) — FK zostaje, CASCADE nie wchodzi w grę na „usunięcie” UI.
- Encja słaba z Chena → CASCADE na związku identyfikującym jest zgodna z modelem.

## Pułapki

- CASCADE z `Klient` na `Zamowienie` na `Platnosc` na `Outbox` — znika historia.
- SET NULL na `KlientId NOT NULL` — DDL nie przejdzie, albo ktoś zrobi kolumnę NULL „żeby działało”.
- Brak jawnego `ON DELETE` w skrypcie — recenzent nie wie, czy to świadome NO ACTION.

Zawsze pisz `ON DELETE NO ACTION` w DDL, jeśli taka jest decyzja.

## Powiązane

- [Klucze](klucze.md)
- [Notacja Chena](notacja-chena.md) (uczestnictwo całkowite ≠ CASCADE)
- [Hard delete](../wzorce/usuwanie/hard-delete.md)
- [Checklist](checklist-przegladu.md)
