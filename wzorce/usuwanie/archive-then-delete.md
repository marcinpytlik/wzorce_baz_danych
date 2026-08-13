# Archive then delete

> Najpierw zimna kopia, potem twarde usunięcie z gorącej tabeli. Archiwum nie jest „ta sama tabela z flagą”.

| | |
|---|---|
| **Status** | `STARTER` |
| **Kiedy stosować** | OLTP ma być chudy, audyt/księgowość chce stare dokumenty |
| **Kiedy unikać** | Archiwum w filegroup gorącym albo w tej samej tabeli |
| **Silnik** | SQL Server 2022 |
| **SQL** | [skrypt](../../sql/usuwanie/archive-then-delete.sql) |

## Problem

Soft delete zostawia martwe wiersze na gorących stronach. Hard delete niszczy dowód. Chcesz obu: szybki OLTP i półkę.

## Model

```text
dbo.Zamowienie          -- hot
archiwum.Zamowienie     -- cold, ten sam kształt albo węższy
```

Job: `INSERT archiwum SELECT ... WHERE ZlozonoAt < @prog`; potem `DELETE` z dbo w tej samej TX (albo partition switch). Odczyt historyczny idzie na archiwum / widok `UNION ALL` świadomie.

Blisko: [hot/cold](../wydajnosc/hot-cold.md). Tu akcent na **usunięcie ze źródła** po kopii.

## Kluczowe ograniczenia

- TX: kopia + delete, albo switch partycji (atomowy w metadanych).
- Archiwum: filegroup / baza o innym backupie.
- Idempotencja joba (UNIQUE na id w archiwum).

## Pułapki

- `SELECT INTO` archiwum i brak DELETE — duplikaty przy następnym biegu.
- Archiwum bez backupu.
- Aplikacja, która nadal JOIN-uje tylko dbo i „gubi” stare dokumenty bez decyzji.

## Powiązane

- [Hot / cold](../wydajnosc/hot-cold.md)
- [Partition switching](partition-switching-purge.md)
- [Retention](retention.md)
